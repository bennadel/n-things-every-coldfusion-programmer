component hint = "I provide an Inversion of Control (IoC) container." {

	// Define properties for dependency-injection.
	property name="internalCache" ioc:skip;
	property name="services" ioc:skip;
	property name="typeMappings" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the IoC container with no services.
	*/
	public void function init() {

		// In order to allow for circular references to not blow-up the construction of
		// the dependency graph, we need to keep an internal scratch-pad of services that
		// might be "in process" before we save the given injectable to the external
		// service cache.
		variables.internalCache = [:];
		// The "services" container will, therefore, only contain fully constructed
		// dependency graphs that are safe to return to the calling context.
		variables.services = [:];
		variables.typeMappings = [:];

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get the service identified by the given token. If the service hasn't yet been
	* provided, it will be instantiated (as a ColdFusion component) and cached before
	* being returned. If you're trying to get a value that is not a ColdFusion component,
	* you must first explicitly provide it to the IoC container.
	*/
	public any function get( required string serviceToken ) {

		if ( services.keyExists( serviceToken ) ) {

			return services[ serviceToken ];

		}

		lock
			name = "Core.Lib.Util.Injector.ServiceCreation"
			type = "exclusive"
			timeout = 60
			{

			return ( services[ serviceToken ] ?: buildService( serviceToken ) );

		}

	}


	/**
	* I return all of the cached services.
	*/
	public struct function getAll() {

		// Note: I'm using a lock here because I'm worried that the copy() requires an
		// iteration under the hood which doesn't always play nice if another request is
		// adding an entry to the services struct at the same time.
		lock
			name = "Core.Lib.Util.Injector.ServiceCreation"
			type = "exclusive"
			timeout = 60
			{

			return services.copy();

		}

	}


	/**
	* I return a MAYBE result for the service identified by the given token. If the
	* service has not yet been provided, the service does not get auto-instantiated.
	*/
	public struct function maybeGet( required string serviceToken ) {

		return maybeNew( services[ serviceToken ] ?: nullValue() );

	}


	/**
	* I provide the given service to be associated with the given token identifier. The
	* provided service will also be returned from the function such that it can be used in
	* am assignment operation in the calling context.
	*/
	public any function provide(
		required string serviceToken,
		required any serviceValue
		) {

		services[ serviceToken ] = internalCache[ serviceToken ] = serviceValue;

		return serviceValue;

	}


	/**
	* I provide a mapping from the given service token to the given concrete service
	* token. This will only be used when instantiating new components; and is really only
	* valuable when you want to swap an implementation without the consuming service
	* needing to know about it.
	*/
	public void function provideTypeMapping(
		required string serviceToken,
		required string concreteServiceToken
		) {

		typeMappings[ serviceToken ] = concreteServiceToken;

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I provide a temporary tunnel into any ColdFusion component that allows the given
	* payload to be appended to the internal, private scope of the component.
	*/
	private void function $$injectValues$$( required struct values ) {

		// Caution: In this moment, the "variables" scope here is the private scope of an
		// arbitrary component - it is NOT the Injector's private scope.
		structAppend( variables, values );

	}


	/**
	* I build the ColdFusion component using the given token. Since this is part of an
	* auto-provisioning workflow, the token here is assumed to be a path to a ColdFusion
	* component.
	*/
	private any function buildComponent( required string serviceToken ) {

		try {

			var componentPath = ( typeMappings[ serviceToken ] ?: serviceToken );
			var service = createObject( "component", componentPath );

			// Caution: The native init() function is called BEFORE any of the component's
			// dependencies are injected. There is a special "initAfterInjection()" method
			// that can be used to provide a post-injection setup hook.
			if ( structKeyExists( service, "init" ) ) {

				service.init();

			}

			return service;

		} catch ( any error ) {

			throw(
				type = "Core.Lib.Util.Injector.CreationError",
				message = "Injector could not create component.",
				detail = "Component [#serviceToken#] could not be created via createObject(#componentPath#).",
				extendedInfo = serializeErrorForNesting( error )
			);

		}

	}


	/**
	* I build the injectable service from the given CFProperty entry.
	*/
	private any function buildInjectable(
		required string serviceToken,
		required struct entry
		) {

		if ( entry.type.len() ) {

			return ( internalCache[ entry.type ] ?: buildService( entry.type ) );

		}

		// If we have a GET defined, the service look-up is a property-chain lookup within
		// the injector cache.
		if ( entry.get.len() ) {

			var value = structGet( "variables.internalCache.#entry.get#" );

			// Caution: Unfortunately, the StructGet() function basically "never fails".
			// If you try to access a value that doesn't exist, ColdFusion will auto-
			// generate the path to the value, store an empty struct in the path, and then
			// return the empty struct. We do not want this to fail quietly. As such, if
			// the found value is an empty struct, we are going to assume that this was an
			// error outcome and raise an exception.
			if ( isStruct( value ) && value.isEmpty() ) {

				throw(
					type = "Core.Lib.Util.Injector.EmptyGet",
					message = "Injector found an empty struct at get-path.",
					detail = "Component [#serviceToken#] has a property named [#entry.name#] with [ioc:get][#entry.get#], which resulted in an empty struct look-up. This is likely an error in the object path."
				);

			}

			return value;

		}

		// If we have NO IOC METADATA defined, we will assume that the NAME is tantamount
		// to the TYPE. However, this will only be considered valid if there is already a
		// service cached under the given name - we can't assume that the name matches a
		// valid ColdFusion component since it isn't fully qualified.
		if ( internalCache.keyExists( entry.name ) ) {

			return internalCache[ entry.name ];

		}

		throw(
			type = "Core.Lib.Util.Injector.MissingDependency",
			message = "Injector could not find injectable by name.",
			detail = "Component [#serviceToken#] has a property named [#entry.name#] with no IoC metadata and which is not cached in the injector. Try adding an [ioc:type] attribute; or, explicitly provide the value (with the given name) to the injector during the application bootstrapping process."
		);

	}


	/**
	* I inspect the given ColdFusion component for CFProperty tags and then use those tags
	* to collect the dependencies for subsequent injection.
	*/
	private struct function buildInjectables(
		required string serviceToken,
		required any service
		) {

		var properties = extractProperties( serviceToken, service );
		var injectables = [:];

		for ( var entry in properties ) {

			injectables[ entry.name ] = buildInjectable( serviceToken, entry );

		}

		return injectables;

	}


	/**
	* I build the service to be identified by the given token. Since this is part of an
	* auto-provisioning workflow, the token is assumed to be a path to a ColdFusion
	* component.
	*/
	private any function buildService( required string serviceToken ) {

		// Caution: I'm caching the "uninitialized" component instance in the internal
		// cache so that we avoid potentially hanging on a circular reference. This way,
		// each service can be injected into another service before it is ready. However,
		// the internally cached services are only "promoted" to the "services cache" once
		// they are fully wired-up. As such, it should create a stable application since
		// no calling context can ever be given an "uninitialized" instance.
		try {

			var service = internalCache[ serviceToken ] = buildComponent( serviceToken );
			var injectables = buildInjectables( serviceToken, service );
			// Wire injectables into the transient service and finish initializing it.
			// Once it's initialized, the service can be promoted from the internal cache
			// to the external "services" cache.
			services[ serviceToken ] = setupComponent( service, injectables );

			return service;

		// If the service couldn't be created without error, evict it from the cache. This
		// should only matter during development. Meaning, if an error is thrown here, it
		// will likely lead to code that never gets deployed to production. As such, we
		// just want to semi-reset the injector (for this entry) in order to aide in
		// easier development.
		} catch ( any error ) {

			internalCache.delete( serviceToken );
			services.delete( serviceToken );
			rethrow;

		}

	}


	/**
	* I inspect the metadata of the given service and provide a standardized properties
	* array relating to dependency injection.
	*/
	private array function extractProperties(
		required string serviceToken,
		required any service
		) {

		try {

			var metadata = getMetadata( service );

		} catch ( any error ) {

			throw(
				type = "Core.Lib.Util.Injector.MetadataError",
				message = "Injector could not inspect metadata.",
				detail = "Component [#serviceToken#] could not be inspected for metadata.",
				extendedInfo = serializeErrorForNesting( error )
			);

		}

		var iocProperties = flattenPropertyChain( metadata )
			.filter(
				( entry ) => {

					if ( entry.keyExists( "ioc:skip" ) ) {

						return false;

					}

					return entry.name.len();

				}
			)
			.map(
				( entry ) => {

					var name = entry.name;
					var type = ( entry[ "ioc:type" ] ?: entry.type ?: "" );
					var get = ( entry[ "ioc:get" ] ?: "" );

					// Depending on how the CFProperty tag is defined, the native type is
					// sometimes the empty string and sometimes "any". Let's normalize
					// this to be the empty string.
					if ( type == "any" ) {

						type = "";

					}

					return [
						name: name,
						type: type,
						get: get
					];

				}
			)
		;

		return iocProperties;

	}


	/**
	* I walk up the component inheritance chain and compile the properties into a single
	* collection. Conflicting property names give higher precedence to the more concrete
	* components.
	*/
	private array function flattenPropertyChain( required struct metadata ) {

		var target = {
			extends: metadata
		};
		var props = [];
		var propIndex = {};

		do {

			target = target.extends;

			for ( var entry in target.properties ) {

				if ( ! entry.name.len() || propIndex.keyExists( entry.name ) ) {

					continue;

				}

				props.append( entry );
				propIndex[ entry.name ] = true;

			}

		} while ( target.keyExists( "extends" ) );

		return props;

	}


	/**
	* I serialize the given error for use in the [extendedInfo] property of another error
	* object. This will help strike a balance between usefulness and noise in the errors
	* thrown by the injector.
	*/
	private string function serializeErrorForNesting( required any error ) {

		var simplifiedTagContext = error.tagContext
			.filter(
				( entry ) => {

					return entry.template.reFindNoCase( "\.(cfc|cfml?)$" );

				}
			)
			.map(
				( entry ) => {

					return [
						template: entry.template,
						line: entry.line
					];

				}
			)
		;

		return serializeJson([
			type: error.type,
			message: error.message,
			detail: error.detail,
			extendedInfo: error.extendedInfo,
			tagContext: simplifiedTagContext
		]);

	}


	/**
	* I wire the given injectables into the given service, initialize it, and return it.
	*/
	private any function setupComponent(
		required any service,
		required struct injectables
		) {

		// When it comes to injecting dependencies, we're going to try two different
		// approaches. First, we'll try to use any setter / accessor methods available for
		// a given property. And second, we'll tunnel-in and deploy any injectables that
		// weren't deployed via the setters.

		// Step 1: Look for setter / accessor methods.
		for ( var key in injectables ) {

			var setterMethodName = "set#key#";

			if (
				structKeyExists( service, setterMethodName ) &&
				isCustomFunction( service[ setterMethodName ] )
				) {

				invoke( service, setterMethodName, [ injectables[ key ] ] );
				// Remove from the collection so that we don't double-deploy this
				// dependency through the dynamic tunneling in step-2.
				injectables.delete( key );

			}

		}

		// Step 2: If we have any injectables left to deploy, we're going to apply a
		// temporary injection tunnel on the target ColdFusion component and just append
		// all the injectables to the variables scope.
		if ( structCount( injectables ) ) {

			try {

				service.$$injectValues$$ = $$injectValues$$;
				service.$$injectValues$$( injectables );

			} finally {

				structDelete( service, "$$injectValues$$" );

			}

		}

		// Since the native init() method is invoked prior to the injection of its
		// dependencies, see if there is an "initAfterInjection()" hook to allow for post-
		//injection setup / initialization of the service component.
		if ( structKeyExists( service, "initAfterInjection" ) ) {

			service.initAfterInjection();

		}

		return service;

	}

}
