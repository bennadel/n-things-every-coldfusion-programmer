<cfscript>

	// Define properties for dependency-injection.
	jSoupParser = request.ioc.get( "core.lib.parsing.JSoupParser" );
	markdownParser = request.ioc.get( "core.lib.parsing.MarkdownParser" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	partial = getPartial();
	
	include "./index.view.cfm";
	exit;

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I prepare data for view rendering.
	*/
	private struct function getPartial() {

		var metadata = deserializeJson( fileRead( expandPath( "/metadata.json" ), "utf-8" ) );
		var chapterDom = parseChapter( metadata.chapter );
		var bioDom = parseBio( metadata.author );

		var chapterH1 = chapterDom.selectFirst( "h1" );
		var chapterTitle = chapterH1.text().trim();

		var bioH1 = bioDom.selectFirst( "h1" );
		var bioTitle = bioH1.text().trim();

		chapterH1.after( "<p>Written by #e( bioTitle )#</p>" );

		// Proxy images through the preview app.
		for ( var node in chapterDom.select( "img" ) ) {

			var srcValue = node.attr( "src" );

			if ( srcValue.reFindNoCase( "^(\./)?images/" ) ) {

				node.attr( "src", "image.cfm?originalSrc=#e4u( srcValue )#" );

			}

		}

		return {
			chapterTitle: chapterTitle,
			chapterContent: chapterDom.body().html(),
			bioTitle: bioTitle,
			bioContent: bioDom.body().html(),
		};

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I read and parse the author bio into a jSoup DOM.
	*/
	private any function parseBio( required string authorSlug ) {

		var markdownContent = fileRead( expandPath( "/authors/#authorSlug#/bio.md" ), "utf-8" );
		var htmlContent = markdownParser.parse( markdownContent );
		var htmlDom = jSoupParser.parseHtml( htmlContent );

		return htmlDom;

	}


	/**
	* I read and parse the chapter into a jSoup DOM.
	*/
	private any function parseChapter( required string chapterSlug ) {

		var markdownContent = fileRead( expandPath( "/chapters/#chapterSlug#/chapter.md" ), "utf-8" );
		var htmlContent = markdownParser.parse( markdownContent );
		var htmlDom = jSoupParser.parseHtml( htmlContent );

		return htmlDom;

	}

</cfscript>
