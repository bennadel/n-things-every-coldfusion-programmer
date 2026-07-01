component {

	// Define properties for dependency-injection.
	property name="classLoader" ioc:type="core.lib.parsing.JSoupClassLoader";
	property name="JSoupClass" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the jsoup parser.
	*/
	public void function initAfterInjection() {

		variables.JSoupClass = classLoader.create( "org.jsoup.Jsoup" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I parse the given HTML fragment and return the resultant BODY node.
	*/
	public any function parseFragment( required string input ) {

		return JSoupClass
			.parseBodyFragment( input )
			.body()
		;

	}


	/**
	* I parse the given HTML document and return the resultant DOCUMENT node.
	*/
	public any function parseHtml( required string input ) {

		return JSoupClass.parse( input );

	}

}
