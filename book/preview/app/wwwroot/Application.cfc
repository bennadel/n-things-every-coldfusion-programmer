component {

	// ColdFusion language extensions (global functions).
	include "../core/cfmlx.cfm";

	// Define application settings.
	this.applicationTimeout = createTimeSpan( 1, 0, 0, 0 );
	this.sessionManagement =  false;
	this.setClientCookies = false;
	// As a security best practice, we DO NOT WANT to search for unscoped variables in any
	// scope other than the core variables, local, and arguments scope. The CGI, FORM,
	// URL, COOKIE, etc. should only ever be referenced explicitly.
	this.searchImplicitScopes = false;
	// Make sure that every struct key-case matches its original defining context. This
	// way, we don't get any unexpected upper-casing of keys (a legacy CFML behavior).
	this.serialization = {
		preserveCaseForStructKey: true,
		preserveCaseForQueryColumn: true,
	};
	// Make sure that all arrays are passed by reference. Historically, arrays have been
	// passed by value, which has no place in a modern language.
	this.passArrayByReference = true;
	// In addition to CFM/CFML files, only allow HTML files to be compiled and executed
	// as CFML code when transcluded with a cfinclude tag. All other includes will be
	// consumed as static content.
	this.compileExtForInclude = "html";
	// Stop ColdFusion from replacing "<script>" tags with "InvalidTag". This doesn't
	// really help us out and provides "security theater" more than anything else.
	this.scriptProtect = "none";
	// Block all file extensions by default. This will require all fileUpload() calls to
	// have an explicit set of allow-listed mime-types.
	this.blockedExtForFileUpload = "*";

	// Define the server mappings (for components and expandPath() calls).
	this.wwwRoot = getDirectoryFromPath( getCurrentTemplatePath() );
	this.appRoot = "#this.wwwRoot#..";
	this.mappings = {
		"/": this.appRoot,
		// Since these are at the root of the server (mounted as Docker Compose volumes),
		// not at the root of the application, we need to explicitly map the "/{file}"
		// pattern so that they don't accidentally map locally to the application.
		"/authors": "/authors",
		"/chapters": "/chapters",
		"/metadata.json": "/metadata.json",
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I get called once when the application is being bootstrapped. This method is
	* inherently single-threaded by the ColdFusion application server.
	*/
	public void function onApplicationStart() {

		var ioc
			= application.ioc
				= new core.lib.util.Injector()
		;
		// Register the IoC Injector with itself so that it can be injected into other
		// components (for some rare meta-programming, like scheduled task management).
		ioc.provide( "core.lib.util.Injector", ioc );

	}


	/**
	* I initialize the request.
	*/
	public void function onRequestStart( required string script ) {

		// Check to see if we should re-init the app.
		if ( url.keyExists( "init" ) ) {

			this.onApplicationStart();

		}

		request.ioc = application.ioc;

	}


	/**
	* I handle uncaught errors within the application.
	*/
	public void function onError( required any exception ) {

		var error = ( exception.rootCause ?: exception.cause ?: exception );

		// This is not a production app - outputting the error is safe.
		dump( exception );
		abort;

	}

}
