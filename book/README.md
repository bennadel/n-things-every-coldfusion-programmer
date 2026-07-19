
# Contributing Content To This Book

See the [root `README.md`](../README.md) for technical instructions.

## Human Intentions

This book is intended to relay our personal journeys through the land of ColdFusion. These experiences are human; and the discussion about them should feel human as well. You are more than welcome to use AI as an _aide_ in your writing; but your prose _must_ read as human. Phrases like _"honest take"_, _"jagged edge"_, _"load-bearing"_, _"sharp insight"_, _"precise decision"_, and _"important distinction worth mentioning"_ are the bromides of the mindless machine and read as such. You have a personality &mdash; let that funky-ass personality shine through in your writing!

## Chapter Formatting

Chapters are written in [Markdown][markdown], parsed into HTML using [Flexmark][flexmark], and then massaged for final rendering using [jSoup][jsoup]. All of the basic Markdown syntax is supported &mdash; headings, lists, blockquotes, images, font styles, etc. Additional components &mdash; figure captions, code highlighting, and callouts (info, warning, danger) &mdash; are provided via the attributes extension.

Each chapter template comes with a local copy of the "design system" library (`design-system.md`). This file is automatically appended to the end of your chapter _rendering_ so that you can see the visual experience delivered by each Markdown technique and extension.

Markdown supports HTML blocks. And, if you _absolutely_ need to write HTML in your chapter, you can do so. But, please stick to plain Markdown as much as possible. And, if you have an idea of a design system "extension" that'd be helpful for other authors, [open an issue][issues] so that we can discuss it &mdash; I'm more than happy to add additional syntax capabilities.


[flexmark]: https://github.com/vsch/flexmark-java

[issues]: https://github.com/bennadel/coldfusion-caveats/issues

[jsoup]: https://jsoup.org/

[markdown]: https://commonmark.org/help/
