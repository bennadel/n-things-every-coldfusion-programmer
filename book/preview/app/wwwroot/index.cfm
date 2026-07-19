<cfscript>

	// Define properties for dependency-injection.
	githubApiClient = request.ioc.get( "core.lib.integration.github.GitHubApiClient" );
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
		var chapterDom = parseChapter( metadata.chapter, metadata.author );

		addByline( chapterDom );
		transformCodeBlocks( chapterDom );
		transformBlockquotes( chapterDom );
		transformImages( chapterDom );

		return {
			chapterTitle: chapterDom.selectFirst( ".chapter h1" ).text().trim(),
			chapterContent: chapterDom.body().html(),
		};

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I inject the "by" line for the author.
	*/
	private void function addByline( required any chapterDom ) {

		var chapterH1 = chapterDom.selectFirst( ".chapter h1" );
		var bioH1 = chapterDom.selectFirst( ".author h1" );
		var bioTitle = bioH1.text().trim();

		chapterH1.after( "<p>Written by <a href='##author'>#e( bioTitle )#</a></p>" );

	}


	/**
	* I build the fence that can safely wrap the given code block without conflicting with
	* any embedded fences in the same code block. The outer fences need to be longer than
	* any of the inner fences in order to remove ambiguity of the terminating fence.
	*/
	private string function buildFenceFor( required string code ) {

		var maxInnerLength = getMaxFenceLength( code );

		// If there are no inner fences, return the standard fence.
		if ( maxInnerLength < 3 ) {

			return "```";

		}

		// If there are inner fences, make the outer fence twice as long.
		return repeatString( "`", ( maxInnerLength * 2 ) );

	}


	/**
	* I get the language extension associated with the given code block.
	*/
	private string function getCodeLanguage( required any codeNode ) {

		for ( var name in codeNode.classNames().toArray() ) {

			if ( name.reFindNoCase( "^language-\w+$" ) ) {

				return name.listRest( "-" ).lcase();

			}

		}

		return "";

	}


	/**
	* I get the GitHub-powered syntax highlighting for the given code snippet. Valid
	* responses are cached to disk based on their content hash. If the GitHub API fails or
	* times-out, a FALLBACK response is cached to disk (and must be deleted before the
	* same code will be retried against the API).
	*/
	private string function getGithubSyntaxHighlighting(
		required string codeContent,
		string language = "txt"
		) {

		var fingerprint = hash( "#language#:#codeContent#" ).lcase();
		var cacheFile = expandPath( "/mdcache/#fingerprint#.htm" );
		var fallbackCacheFile = expandPath( "/mdcache/fallback-#fingerprint#.htm" );

		if ( fileExists( cacheFile ) ) {

			return fileRead( cacheFile, "utf-8" );

		}

		if ( fileExists( fallbackCacheFile ) ) {

			return fileRead( fallbackCacheFile, "utf-8" );

		}

		// For debugging purposes, indicate when the API is being consumed.
		systemOutput( "Using GitHub Markdown API: #fingerprint#", true );

		// Create a markdown payload that contains nothing but the fenced code block for
		// the given code. The fence we use will be larger than any embedded fence in
		// order to avoid any nested-code-block conflicts.
		var fence = buildFenceFor( codeContent );
		var markdownContent = arrayToList(
			[
				"#fence##language#",
				codeContent,
				"#fence#"
			],
			chr( 10 )
		);

		// The GitHub markdown API is both remote (ie, fragile) and rate-limited. As such,
		// it may return a non-200 status code for several reasons. In any case, if the
		// API calls fails, we're going to fallback to writing a vanilla code file to the
		// local file cache. These files are prefixed with `fallback-` to help make it
		// obvious which files need to be deleted in order to unblock a revaluation of the
		// code against the GitHub API.
		// --
		// Note: the public (unauthenticated) markdown API has a very low rate-limit of
		// 60/hour. This is why we're taking these measures to cut down on the API calls.
		try {

			var htmlContent = githubApiClient.renderMarkdown( markdownContent );

			fileWrite( cacheFile, htmlContent, "utf-8" );

		} catch ( GitHub.MarkdownApi.StatusCode.NotOk error ) {

			var htmlContent = "<pre data-fallback><code>#e( codeContent )#</code></pre>";

			fileWrite( fallbackCacheFile, htmlContent, "utf-8" );

		}

		return htmlContent;

	}


	/**
	* I build a highlight index, keyed by line-number, for the given code block. This can
	* handle both individual lines as well as line-ranges. Example "1-5,10".
	*/
	private struct function getHighlightIndex( required any preNode ) {

		var index = [:];
		var rawAttribute = preNode.attr( "highlight" ).trim();

		if ( ! rawAttribute.len() ) {

			return index;

		}

		var rawRanges = rawAttribute.listToArray( ", " );

		for ( var element in rawRanges ) {

			// Coalesce both single line and range notation into the same from/to shape.
			var parts = element.listToArray( "- " );
			var fromIndex = fix( parts[ 1 ] );
			var toIndex = fix( parts[ 2 ] ?? fromIndex );

			if ( fromIndex > toIndex ) {

				throw(
					type = "InvalidHighlightRange",
					message = "Syntax range highlight must be ascending."
				);

			}

			for ( var i = fromIndex ; i <= toIndex ; i++ ) {

				index[ i ] = true;

			}

		}

		return index;

	}


	/**
	* I return the max length of any fences (code blocks) embedded within the given code.
	*/
	private numeric function getMaxFenceLength( required string code ) {

		return code
			.reMatch( "`+" )
			.reduce(
				( maxLength, fence ) => {

					return max( maxLength, fence.len() );

				},
				0
			)
		;

	}


	/**
	* I read and parse the chapter, author bio, and design system content into a jSoup
	* DOM. To do this, we have to hand-assemble the larger document, which is unfortunate
	* but the easiest approach.
	*/
	private any function parseChapter(
		required string chapterSlug,
		required string authorSlug
		) {

		var chapterFile = expandPath( "/chapters/#chapterSlug#/chapter.md" );
		var chapterContent = fileRead( chapterFile, "utf-8" );

		var authorFile = expandPath( "/authors/#authorSlug#/bio.md" );
		var authorContent = fileRead( authorFile, "utf-8" );

		var designSystemFile = expandPath( "/chapters/#chapterSlug#/design-system.md" );
		var designSystemContent = fileRead( designSystemFile, "utf-8" );

		var newline = chr( 10 );
		var gap = ( newline & newline );
		var lines = [
			"<article id='chapter' class='chapter'>",
				chapterContent,
			"</article>",
			"---",
			"<article id='author' class='author'>",
				authorContent,
			"</article>",
			"---",
			"<details id='designSystem' open class='designSystem'>",
				"<summary>Design System &mdash; see <code>./design-system.md</code> for syntax</summary>",
				"<section>",
					designSystemContent,
				"</section>",
			"</details>",
		];

		var markdownContent = lines.toList( gap );
		var htmlContent = markdownParser.parse( markdownContent );
		var htmlDom = jSoupParser.parseHtml( htmlContent );

		return htmlDom;

	}


	/**
	* I transform tagged blockquotes into their intended semantic elements. Callouts are
	* re-tagged as aside elements.
	*/
	private any function transformBlockquotes( required any chapterDom ) {

		// Index of valid variant tokens, doubles as map of translated CSS class names.
		var calloutVariants = [
			"info": "callout isInfo",
			"warning": "callout isWarning",
			"danger": "callout isDanger",
		];

		for ( var node in chapterDom.select( "blockquote > [variant]:first-child" ) ) {

			var blockquote = node.parent();
			var variant = node.attr( "variant" );

			node.removeAttr( "variant" );

			if ( variant == "quote" ) {

				blockquote.addClass( "isQuote" );
				continue;

			}

			if ( calloutVariants.keyExists( variant ) ) {

				blockquote
					.tagName( "aside" )
					.addClass( calloutVariants[ variant ] )
				;

			}

		}

	}


	/**
	* I transform the plain-text code blocks into syntax highlighted code blocks.
	*/
	private any function transformCodeBlocks( required any chapterDom ) {

		var codeNodes = chapterDom.select( "pre > code" );

		for ( var codeNode in codeNodes ) {

			var preNode = codeNode
				.parent()
				.addClass( "codeFigure_pre" )
			;
			var figureNode = preNode
				.wrap( "<figure></figure>" )
				.parent()
				.addClass( "codeFigure" )
			;

			if ( preNode.attr( "file" ).len() ) {

				var captionNode = figureNode
					.prependElement( "figcaption" )
					.addClass( "codeFigure_caption" )
					.html( "<strong>File:</strong> <code>#e( preNode.attr( "file" ) )#</code>" )
				;

				preNode.removeAttr( "file" );

			}

			var sourceCode = codeNode.wholeText();
			var language = getCodeLanguage( codeNode );

			// For "ColdFusion Script" code - a nod to Lucee CFML - we're going to change
			// the language specification to `cfc`. GitHub appears to highlight this code
			// properly without the presence of the `component{}` wrapper.
			if ( language == "cfs" ) {

				language = "cfc";

			}

			// Use the GitHub API to apply the best-in-class syntax highlighting.
			var githubSourceCode = getGithubSyntaxHighlighting( sourceCode, language );
			var githubDom = jSoupParser.parseFragment( githubSourceCode );

			// GitHub doesn't return code blocks in a consistent shape. If the syntax
			// highlighting has been applied, only the PRE tag comes back. If no syntax
			// highlighting has been applied (or we've fallen-back to a vanilla code
			// file), both the PRE and the CODE tags come back. We won't know without
			// inspecting the DOM.
			var githubPreNode = githubDom.selectFirst( "pre" );
			var githubCodeNode = githubPreNode.selectFirst( "code" );
			var githubTargetNode = ( githubCodeNode ?? gitHubPreNode );

			sourceCode = githubTargetNode.html();

			// If the GitHub API failed (and we fell-back to using a vanilla code file),
			// transfer any fallback indicator over to live DOM in case we need to use it
			// in the rendering.
			if ( gitHubPreNode.hasAttr( "data-fallback" ) ) {

				preNode.attr( "data-fallback", "" );

			}

			var highlightIndex = getHighlightIndex( preNode );
			var sourceLines = sourceCode.reMatch( "[^\r\n]*" );

			codeNode
				.addClass( "codeFigure_code" )
				.empty()
			;

			for ( var entry in toEntries( sourceLines ) ) {

				var lineNode = codeNode.appendElement( "div" )
					.attr( "data-line", toString( entry.index ) )
					.addClass( "codeFigure_line" )
				;

				if ( highlightIndex.keyExists( entry.index ) ) {

					lineNode.addClass( "isMark" );

				}

				var numberNode = lineNode.appendElement( "span" )
					.text( entry.index )
					.addClass( "codeFigure_number" )
				;

				var textNode = lineNode.appendElement( "span" )
					.html( entry.value )
					.addClass( "codeFigure_source" )
				;

			}

		}

	}


	/**
	* I transform the plain images into figures.
	*/
	private void function transformImages( required any chapterDom ) {

		for ( var imageNode in chapterDom.select( "p > img:only-child" ) ) {

			var figureNode = imageNode
				.parent()
				.tagName( "figure" )
				.addClass( "imageFigure" )
			;
			var altAttribute = imageNode.attr( "alt" );
			var captionText = altAttribute.len()
				? altAttribute
				: "Please define ALT text for this image."
			;
			var captionNode = figureNode
				.appendElement( "figcaption" )
				.text( captionText )
				.addClass( "imageFigure_caption" )
			;

			imageNode
				// Now that we've moved it into the figcaption, we have to remove it from
				// the ALT so that we don't get double-speaking in assistive technology.
				.attr( "alt", "" )
				.addClass( "imageFigure_image" )
			;

		}

		// Proxy images through the preview app.
		for ( var node in chapterDom.select( "img" ) ) {

			var srcValue = node.attr( "src" );

			if ( srcValue.reFindNoCase( "^(\./)?images/" ) ) {

				node.attr( "src", "image.cfm?originalSrc=#e4u( srcValue )#" );

			}

		}

	}

</cfscript>
