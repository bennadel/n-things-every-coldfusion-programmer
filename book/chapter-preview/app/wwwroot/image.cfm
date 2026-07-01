<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.originalSrc" type="string";

	partial = getPartial( url.originalSrc );

	cfheader(
		name = "Content-Disposition",
		value = "attachment; filename=""#partial.imageName#""; filename*=UTF-8''#e4u( partial.imageName )#"
	);
	cfcontent(
		type = partial.imageType,
		variable = partial.imageBlob
	);

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I prepare data for view rendering.
	*/
	private struct function getPartial( required string originalSrc ) {

		var metadata = deserializeJson( fileRead( expandPath( "/metadata.json" ), "utf-8" ) );
		var chapterSlug = metadata.chapter;

		var imagePath = expandPath( "/chapters/#chapterSlug#/#originalSrc#" );
		var imageType = fileGetMimeType( imagePath, false );
		var imageBlob = fileReadBinary( imagePath );
		var imageName = getFileFromPath( imagePath );

		return {
			imagePath,
			imageType,
			imageBlob,
			imageName,
		};

	}

</cfscript>
