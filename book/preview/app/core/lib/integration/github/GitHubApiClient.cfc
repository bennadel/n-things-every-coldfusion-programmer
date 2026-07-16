component {

	// Define properties for dependency-injection.
	property name="httpUtilities" ioc:type="core.lib.util.HttpUtilities";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I render Markdown as HTML using the GitHub API.
	*/
	public string function renderMarkdown(
		required string markdownContent,
		numeric timeoutInSeconds = 10
		) {

		cfhttp(
			result = "local.httpResponse",
			method = "post",
			url = "https://api.github.com/markdown/raw",
			getAsBinary = "yes",
			timeout = timeoutInSeconds
			) {

			cfhttpparam(
				type = "header",
				name = "X-GitHub-Api-Version",
				value = "2026-03-10"
			);
			cfhttpparam(
				type = "header",
				name = "Content-Type",
				value = "text/x-markdown"
			);
			cfhttpparam(
				type = "body",
				value = markdownContent
			);
		}

		var statusCode = httpUtilities.parseStatusCode( httpResponse );
		var fileContent = httpUtilities.getFileContentAsString( httpResponse );

		// Internal debugging. This really isn't the place to put this; but since this
		// application is only for preview purposes, I'm OK with the jank.
		if ( httpResponse.responseHeader.keyExists( "X-RateLimit-Limit" ) ) {

			systemOutput( "GitHub Limit: #httpResponse.responseHeader[ 'X-RateLimit-Limit' ]#", true );
			systemOutput( "GitHub Remaining: #httpResponse.responseHeader[ 'X-RateLimit-Remaining' ]#", true );
			systemOutput( "GitHub Used: #httpResponse.responseHeader[ 'X-RateLimit-Used' ]#", true );

		}

		if ( ! statusCode.ok ) {

			throw(
				type = "GitHub.MarkdownApi.StatusCode.NotOk",
				message = "GitHub API status code error.",
				detail = "Returned with status code: #statusCode.original#",
				extendedInfo = fileContent,
				// Embed the status code as an accessible property on the error so it can
				// be read during they retry loop.
				errorCode = statusCode.code
			);

		}

		return fileContent;

	}

}
