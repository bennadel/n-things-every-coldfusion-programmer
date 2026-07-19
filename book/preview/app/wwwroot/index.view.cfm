<cfoutput>

	<!doctype html>
	<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title>
			#e( partial.chapterTitle )#
		</title>
		<style type="text/css">
			<cfinclude template="./main.css" />
		</style>
	</head>
	<body>
		<main>
			#partial.chapterContent#
		</main>
	</body>
	</html>

</cfoutput>
