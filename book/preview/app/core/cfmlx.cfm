<cfscript>

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// These are CFML e(X)tensions. These are intended to be runtime extensions for CFML
	// template execution. As such, they should pertain almost entirely to polyfills, data
	// structure manipulation, and short-hand aliases for existing functions. There should
	// be NOTHING in here that is coupled to the application business logic.

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I convert the given arguments collection into a proper array.
	*/
	private array function argumentsToArray(
		required any args,
		boolean includeNullValues = true
		) {

		var result = arrayMap( args, ( arg ) => arguments?.arg );

		if ( includeNullValues ) {

			return result;

		}

		return result.filter( ( value ) => ! isNull( value ) );

	}


	/**
	* I return a flattened collection (flattens only the first level of elements).
	*/
	private array function arrayFlatten( required array collection ) {

		return collection.reduce(
			( reduction, element ) => {

				return reduction.append( element, isArray( element ) );

			},
			[]
		);

	}


	/**
	* I return a shallow copy / slice of the given array.
	*/
	private array function arrayCopy( required array collection ) {

		return [ ...collection ];

	}


	/**
	* I group the given collection using the given key as the associative entry.
	*/
	private struct function arrayGroupBy(
		required array collection,
		required string key
		) {

		var index = {};

		for ( var element in collection ) {

			var groupKey = element[ key ];

			if ( ! index.keyExists( groupKey ) ) {

				index[ groupKey ] = [];

			}

			index[ groupKey ].append( element );

		}

		return index;

	}


	/**
	* I index the given collection using the given key as the associative entry.
	*/
	private struct function arrayIndexBy(
		required array collection,
		required string key
		) {

		var index = {};

		for ( var element in collection ) {

			index[ element[ key ] ] = element;

		}

		return index;

	}


	/**
	* I return an array of plucked values using the given key.
	*/
	private array function arrayPluck(
		required array collection,
		required string key
		) {

		return arrayPluckPath( collection, [ key ] );

	}


	/**
	* I return an array of plucked values using the given key path.
	*/
	private array function arrayPluckPath(
		required array collection,
		required array keyPath
		) {

		return collection.map(
			( element ) => {

				return keyPath.reduce(
					( reduction, key ) => {

						return reduction[ key ];

					},
					element
				);

			}
		);

	}


	/**
	* I return an array of plucked values using the given key. Duplicate values will be
	* omitted from the result.
	*/
	private array function arrayPluckUnique(
		required array collection,
		required string key
		) {

		var results = [];
		var valueIndex = {};

		for ( var element in collection ) {

			var value = element[ key ];

			if ( ! valueIndex.keyExists( value ) ) {

				valueIndex[ value ] = true;
				results.append( value );

			}

		}

		return results;

	}


	/**
	* I return an index of the values reflected as struct keys.
	*/
	private struct function arrayReflect( required array collection ) {

		var index = {};

		for ( var element in collection ) {

			index[ element ] = element;

		}

		return index;

	}


	/**
	* I perform an in-place shuffle on the given array using Java's Collection class.
	*/
	private array function arrayShuffle( required array input ) {

		createObject( "java", "java.util.Collections" )
			.shuffle( input )
		;

		return input;

	}


	/**
	* I perform an in-place sort of the given array using the provided operators. Each
	* subsequent operator is only consumed when the previous operator returns 0.
	*/
	private array function arraySortByOperators(
		required array collection,
		required function operator
		/* , operator-2 */
		/* , operator-3 */
		/* , operator-4 */
		) {

		var operators = argumentsToArray( arguments ).slice( 2 )

		return collection.sort(
			( a, b ) => {

				for ( var operator in operators ) {

					var comparison = sgn( operator( a, b ) );

					if ( comparison != 0 ) {

						return comparison;

					}

				}

				return 0;

			}
		);

	}


	/**
	* I clamp the given value to the given bounds.
	*/
	private numeric function clamp(
		required numeric value,
		required numeric minValue,
		required numeric maxValue
		) {

		return max( min( value, maxValue ), minValue );

	}


	/**
	* I return the first non-null argument.
	*/
	private any function coalesce(/* variadic function */) {

		// Caution: the `false` argument omits null values during conversion.
		for ( var value in argumentsToArray( arguments, false ) ) {

			return value;

		}

	}


	/**
	* I return the first truthy / non-falsy argument.
	*/
	private any function coalesceTruthy(/* variadic function */) {

		// Caution: the `false` argument omits null values during conversion.
		for ( var value in argumentsToArray( arguments, false ) ) {

			if ( isTruthy( value ) ) {

				return value;

			}

		}

	}


	/**
	* I return the number of milliseconds since January 1, 1970, 00:00:00 GMT represented
	* by this given date/time value.
	*/
	private numeric function dateGetTime( required any input ) {

		if ( isInstanceOf( input, "java.util.Date" ) ) {

			return input.getTime();

		}

		return dateAdd( "d", 0, input ).getTime();
	}


	/**
	* I polyfill the dump() function in Adobe ColdFusion.
	*/
	private void function dump(
		required any var,
		boolean expand = true,
		string format = "html",
		string hide = "",
		numeric keys = 9999,
		string label = "",
		string output = "browser",
		string show = "all",
		boolean showUDFs = true,
		numeric top = 9999,
		boolean abort = false
		) {

		// Note: under the hood, Adobe ColdFusion seems to be compiling this down into an
		// instance of the CFDump tag (based on error messages). As such, it's much more
		// temperamental than a normal function invocation (include my attempts at using
		// the argumentCollection construct). We have to be much more explicit in our
		// argument pass-through; and, certain attributes CANNOT be passed in as NULL.
		writeDump(
			var = var,
			expand = expand,
			format = format,
			hide = hide,
			keys = keys,
			label = label,
			output = output,
			show = show,
			showUDFs = showUDFs,
			top = top,
			abort = abort
		);

	}


	/**
	* I dump the top N entries of the given value.
	*/
	private void function dumpN(
		required any var,
		numeric top = 10
		) {

		dump( argumentCollection = arguments );

	}


	/**
	* Alias for native method: encodeForHtml().
	*/
	private string function e( required string value ) {

		return encodeForHtml( value );

	}


	/**
	* Alias for native method: encodeForHtmlAttribute().
	*/
	private string function e4a( required string value ) {

		return encodeForHtmlAttribute( value );

	}


	/**
	* Alias for native method: encodeForJavaScript().
	*/
	private string function e4j( required string value ) {

		return encodeForJavaScript( value );

	}


	/**
	* I serialize the given value as JSON and encode for JavaScript. This is intended to
	* be consumed in a `JSON.parse( "#e4Json()#" )` call.
	*/
	private string function e4json( required any value ) {

		return encodeForJavaScript( serializeJson( value ) );

	}


	/**
	* Alias for native method: encodeForUrl().
	*/
	private string function e4u( required string value ) {

		return encodeForUrl( value );

	}


	/**
	* I polyfill the echo() function in Adobe ColdFusion.
	*/
	private void function echo( any value = "" ) {

		writeOutput( value );

	}


	/**
	* I determine if the given value is a ColdFusion component instance.
	*/
	private boolean function isComponent( required any value ) {

		if ( ! isObject( value ) ) {

			return false;

		}

		// The isObject() function will return true for both components and Java objects.
		// As such, we need to go one step further to see if we can get at the component
		// metadata before we can truly determine if the value is a ColdFusion component.
		try {

			var metadata = getMetadata( value );

			return ( metadata?.type == "component" );

		} catch ( any error ) {

			return false;

		}

	}


	/**
	* I determine if the two arguments are different using a case-sensitive comparison.
	* This is just a semantic convenience wrapper for the underlying compare() method.
	*/
	private boolean function isDifferent(
		required string a,
		required string b
		) {

		return !! compare( a, b );

	}


	/**
	* I determine if the given value is a Falsy (according to JavaScript rules).
	*
	* See JavaScript definition on the Mozilla Developer Network (MDN):
	* https://developer.mozilla.org/en-US/docs/Glossary/Falsy
	*/
	private boolean function isFalsy( any value ) {

		if ( isNull( value ) ) {

			return true;

		}

		if ( ! isSimpleValue( value ) ) {

			return false;

		}

		if ( isString( value ) ) {

			return ! value.len();

		}

		if ( isBoolean( value ) || isNumeric( value ) ) {

			return ! value;

		}

		return false;

	}


	/**
	* Polyfill Lucee CFML's isInThread() function using Adobe ColdFusion's page-context.
	*/
	private boolean function isInThread() {

		return getPageContext().isUnderCFThread();

	}


	/**
	* I determine if the given value is NOT a date.
	*/
	private boolean function isNotDate( required any value ) {

		return ! isDate( value );

	}


	/**
	* I determine if the two arguments are the same using a case-sensitive comparison.
	* This is just a semantic convenience wrapper for the underlying compare() method.
	*/
	private boolean function isSame(
		required string a,
		required string b
		) {

		return ! compare( a, b );

	}


	/**
	* I determine if the given value is a native string.
	*/
	private boolean function isString( required any value ) {

		return isInstanceOf( value, "java.lang.String" );

	}


	/**
	* I determine if the given value is a Truthy (according to JavaScript rules). A
	* Truthy value is any value that is not explicitly designated as a Falsy.
	*
	* See JavaScript definition on the Mozilla Developer Network (MDN):
	* https://developer.mozilla.org/en-US/docs/Glossary/Truthy
	*/
	private boolean function isTruthy( any value ) {

		if ( isNull( value ) ) {

			return false;

		}

		return ! isFalsy( value );

	}


	/**
	* I return a maybe for the first element in the given array.
	*/
	private struct function maybeArrayFirst( required array collection ) {

		return maybeNew( collection[ 1 ] ?: nullValue() );

	}


	/**
	* I create a maybe with the given value. Passing-in a null value results in a non-
	* exists value.
	*/
	private struct function maybeNew( any value ) {

		return maybePatchMemberMethods({
			exists: ! isNull( value ),
			value: arguments?.value
		});

	}


	/**
	* I patch-in the member methods for the given maybe.
	*/
	private struct function maybePatchMemberMethods( required any maybe ) {

		maybe.set = ( newValue ) => maybeSet( maybe, newValue );

		return maybe;

	}


	/**
	* I update the maybe to be an exists value using the given input. The updated-in-place
	* maybe is returned.
	*/
	private struct function maybeSet(
		required struct maybe,
		required any value
		) {

		maybe.exists = true;
		maybe.value = value;

		return maybe;

	}


	/**
	* I return a closure that binds given method to the given source component, allowing
	* the closure to be passed-around without scoping.
	*/
	private function function methodBind(
		required any source,
		required string methodName,
		any methodArguments
		) {

		return () => invoke( source, methodName, ( methodArguments ?: arguments ) );

	}


	/**
	* I polyfill the nullValue() function in Adobe ColdFusion.
	*/
	private void function nullValue() {

		// Atreyu: What is the Nothing?
		// Gmork: It's the emptiness that's left. It is like a despair, destroying this world.

	}


	/**
	* I create an index in which each row is referenced by the value in the given column.
	*/
	public struct function queryIndexBy(
		required query results,
		required string key
		) {

		var index = [:];

		for ( var result in results ) {

			index[ result[ key ] ] = result;

		}

		return index;

	}


	/**
	* I create a new range with the given indicies.
	*/
	private array function rangeNew(
		required numeric start,
		numeric end
		) {

		// If only one index is provided, assume start from 1.
		if ( isNull( end ) ) {

			arguments.end = arguments.start;
			arguments.start = 1;

		}

		var size = ( end - start + 1 );
		var range = [];
		range.resize( size );

		for ( var i = 1 ; i <= size ; i++ ) {

			range[ i ] = ( start + i - 1 );

		}

		return range;

	}


	/**
	* HOTFIX: I provide a version of the serializeJson() method that runs mulitple
	* attempts on failure. This is to patch an emergent bug in one of the latest ACF
	* updates that seems to have introduced some timing wonkiness.
	*/
	private string function serializeJsonHotfix( required any input ) {

		try {

			return serializeJson( input );

		} catch ( any error ) {

			return serializeJson( input );

		}

	}


	/**
	* I return a new struct with the given subset of keys filtered-in.
	*/
	private struct function structPick(
		required struct target,
		required array keys
		) {

		var keysIndex = arrayReflect( keys );

		return target.filter( ( key ) => keysIndex.keyExists( key ) );

	}


	/**
	* I polyfill the systemOutput() function in Adobe ColdFusion.
	*/
	private void function systemOutput(
		required any value,
		boolean addNewline = false, // Ignored.
		boolean doErrorStream = false // Ignored.
		) {

		if ( isString( value ) && value.find( "<print-stack-trace>" ) ) {

			var stacktrace = callStackGet()
				.map( ( frame ) => "#frame.template#:#frame.lineNumber#" )
				.prepend( "Stacktrace:" )
				.toList( chr( 10 ) )
			;

			value = value.replace( "<print-stack-trace>", stacktrace );

		}

		dump(
			var = value,
			format = "text",
			output = "console"
		);

	}


	/**
	* I convert the given collection to an array of entries. Each entry has (index, key,
	* and value) properties. This is intended as a sort-of polyfill for the fact that
	* Lucee can provide key/value and index/item during collection iteration. ColdFusion
	* has some of this; but, the implementation is not complete. This would at least
	* provide some sort of unified way to get at this data.
	*/
	private array function toEntries( required any collection ) {

		if ( isArray( collection ) ) {

			return collection.map(
				( value, i ) => {

					return {
						index: i,
						key: i,
						value: value
					};

				}
			);

		}

		if ( isStruct( collection ) ) {

			return collection.keyArray().map(
				( key, i ) => {

					return {
						index: i,
						key: key,
						value: collection[ key ]
					};

				}
			);

		}

		throw(
			type = "CFMLX.UnsupportedCollectionType",
			message = "Cannot get entries for unsupported collection type."
		);

	}


	/**
	* I capitalize the first letter. If "all", I capitalize the first letter of each word.
	* A word is classified as any alpha characters that come after whitespace, dot, dash,
	* or parenthesis.
	*/
	private string function ucFirst(
		required string input,
		boolean doAll = false
		) {

		if ( doAll ) {

			return input.reReplace( "(^|\s|\.|\(|\[|-)(\w)", "\1\u\2", "all" );

		}

		return input.reReplace( "^(\w)", "\u\1" );

	}


	/**
	* I return the current date/time in UTC.
	*/
	private date function utcNow() {

		return dateConvert( "local2utc", now() );

	}

</cfscript>
