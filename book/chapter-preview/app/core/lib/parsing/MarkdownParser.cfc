component {

	// Define properties for dependency-injection.
	property name="classLoader" ioc:type="core.lib.parsing.FlexmarkClassLoader";
	property name="parser" ioc:skip;
	property name="renderer" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the parser.
	*/
	public void function initAfterInjection() {

		var AutolinkExtensionClass = classLoader.create( "com.vladsch.flexmark.ext.autolink.AutolinkExtension" );
		var StrikethroughExtensionClass = classLoader.create( "com.vladsch.flexmark.ext.gfm.strikethrough.StrikethroughExtension" );
		var HtmlRendererClass = classLoader.create( "com.vladsch.flexmark.html.HtmlRenderer" );
		var ParserClass = classLoader.create( "com.vladsch.flexmark.parser.Parser" );

		// The options are used to configure both the parser and the renderer.
		var options = classLoader.create( "com.vladsch.flexmark.util.data.MutableDataSet" )
			.init()
		;
		options.set(
			ParserClass.EXTENSIONS,
			[
				AutolinkExtensionClass.create(),
				StrikethroughExtensionClass.create()
			]
		);

		// Ignore "mailto:" auto-linking.
		options.set(
			AutolinkExtensionClass.IGNORE_LINKS,
			"[^@:]+@[^@]+"
		);
		// Turn soft-breaks into hard-breaks (ie. line-returns into BR tags).
		options.set(
			HtmlRendererClass.SOFT_BREAK,
			"<br />#chr( 10 )#"
		);

		variables.parser = ParserClass
			.builder( options )
			.build()
		;
		variables.renderer = HtmlRendererClass
			.builder( options )
			.build()
		;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I parse the given markdown input into HTML.
	*/
	public string function parse( required string markdown ) {

		return renderer.render( parser.parse( markdown.trim() ) );

	}

}
