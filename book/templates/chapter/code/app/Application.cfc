/*****************************************************************************************
* THIS FOLDER IS FOR YOU. YOU CAN MODIFY ANY CODE IN THIS FOLDER.
* 
* This folder is here as a convenience to provide you with a ready-to-use context in which
* to verify that the code you write in your chapter is semantically correct and ready to
* publish. YOU DO NOT NEED TO USE THIS. If you verified your code elsewhere, you can just
* ignore this folder altogether and focus on your writing.
*****************************************************************************************/
component {

	this.name = "ChapterCode";
	this.applicationTimeout = createTimeSpan( 1, 0, 0, 0 );
	this.sessionManagement = false;
	this.setClientCookies = false;
	this.searchImplicitScopes = false;
	this.serialization = {
		preserveCaseForStructKey: true,
		preserveCaseForQueryColumn: true,
	};
	this.passArrayByReference = true;

}
