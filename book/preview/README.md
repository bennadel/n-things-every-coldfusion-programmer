
# Chapter Preview - **Internal Use Only**

This directory provides a ColdFusion application that mounts as a Docker service inside your `chapters/{chapter-slug}` context. When you run:

`docker compose up`

... within your chapter, this application is defined as a service and is provided as `http://localhost/`. It shows you a Markdown-to-HTML preview of your chapter content, complete with formatting, syntax-highlighted code, and embedded images.
