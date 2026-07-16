component hint = "I provide utility methods to aide in making CFHttp requests." {

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I apply a 20% jitter to a given back-off delay value in order to ensure some kind of
	* randomness to the repeated requests against the target. This is a small effort to
	* prevent the thundering heard problem for the target.
	*/
	public numeric function applyJitter( required numeric delayInMilliseconds ) {

		return fix( delayInMilliseconds * ( randRange( 80, 120 ) / 100 ) );

	}


	/**
	* I return the delays durations (in milliseconds) to be used during back-off retries.
	* Rather than relying on the maths to perform exponential back-off calculations, this
	* collection provides an explicit set of back-off values and doubles as the number of
	* attempts that we should execute against the underlying HTTP API.
	* 
	* Note: the last value is always "0" to indicate the end of the retry attempts.
	*/
	public array function getBackoffDurations() {

		return [
			applyJitter( 50 ),
			applyJitter( 100 ),
			applyJitter( 200 ),
			applyJitter( 400 ),
			applyJitter( 800 ),
			0 // Indicates end of retry attempts.
		];

	}


	/**
	* I return the embedded fileContent property as a string. This is particularly helpful
	* when a CFHttp is configured to return binary but there is an underlying network
	* failure (the network failure won't be returned as binary).
	*/
	public string function getFileContentAsString( required struct httpResponse ) {

		if ( isBinary( httpResponse.fileContent ) ) {

			return charsetEncode( httpResponse.fileContent, "utf-8" );

		}

		return httpResponse.fileContent;

	}


	/**
	* I try to parse the given fileContent as a JSON string. If the string cannot be
	* parsed, an error containing the fileContent is thrown.
	*/
	public any function parseFileContentAsJson( required string fileContent ) {

		try {

			return deserializeJson( fileContent );

		} catch ( any error ) {

			throw(
				type = "HttpUtilities.JsonParse",
				message = "File content could not be parsed as JSON.",
				extendedInfo = "File content: #fileContent#"
			);

		}

	}


	/**
	* I parse the status code field into a structured response.
	*/
	public struct function parseStatusCode( required struct httpResponse ) {

		return {
			code: val( httpResponse.statusCode ),
			text: listRest( httpResponse.statusCode, " " ),
			family: "#httpResponse.statusCode[ 1 ]#xx",
			ok: ( httpResponse.statusCode[ 1 ] == "2" ),
			original: httpResponse.statusCode
		};

	}


	/**
	* I determine if the given response has a corrupt status code (usually indicating a
	* connection failure).
	*/
	public boolean function statusCodeIsCorrupt( required struct httpResponse ) {

		return ! parseStatusCode( httpResponse ).code;

	}


	/**
	* I determine if the given response has a failure status code.
	*/
	public boolean function statusCodeIsFailure( required struct httpResponse ) {

		return ! statusCodeIsOk( httpResponse );

	}


	/**
	* I determine if the given response has a success status code.
	*/
	public boolean function statusCodeIsOk( required struct httpResponse ) {

		return httpResponse.statusCode
			.reFind( "2\d\d" )
		;

	}


	/**
	* I determine if the given HTTP status code is considered safe to retry.
	*/
	public boolean function statusCodeIsRetriable( required string statusCode ) {

		switch ( statusCode ) {
			case 0:   // Connection Failure.
			case 408: // Request Timeout.
			case 500: // Server error.
			case 502: // Bad Gateway.
			case 503: // Service Unavailable.
			case 504: // Gateway Timeout.
				return true;
			break;
			default:
				return false;
			break;
		}

	}

}
