
# Contributing Content To This Book

The parsing, rendering, and styling of the book content is still very much a **work in progress**. I wanted to get _something_ in place so that anyone keen to contribute could start to do so. Once we have more content in place, I'll focus more on the look-and-feel of the book itself.

## How to Write a Chapter

This book is intended to be a community project that's authored in Markdown and showcases the majesty of ColdFusion. I've done my best to make it as easy as possible to contribute. If you'd like to author a chapter you can:

1. Prepare your author biography.

   1. Copy the `author-template` folder into `authors`.
   2. Rename your folder using kebab case, ex `john-smith`.
   3. Update the `bio.md` content.

2. Prepare your chapter content.

   1. Copy the `chapter-template` folder into `chapters`.
   2. Rename your folder using kebab case, ex `session-management`.
   3. Update the `metadata.json` file (inside your chapter folder) to identify the kebab-case slugs you used for both your author bio and chapter.
   4. Update the `chapter.md` content.

## Markdown Only Lifestyle

If you only want to modify the `chapter.md` file, there's nothing more you need to do. If you have an established authoring workflow and you have a way to preview Markdown content, I'm not here to mess up your flow.

## Markdown + Docker Lifestyle

_That said_, the `chapter-template` comes with a **Docker Compose** file that defines two services:

* **`http://localhost/`** - a Markdown-to-HTML preview of your chapter content, including rendered images.

* **`http://localhost:8080/`** - a ColdFusion application context that you can use to write and verify the CFML code that you want to reference in your chapter. The source code for this application is in `{chapter}/code/app`. You can modify the contents of the `app` folder in any way that helps you write your chapter.

To spin-up the Docker containers, you need to `cd` into your chapter folder and run `docker compose up`. The first time Docker builds the images, it may take 1-2 minutes because the CFML engine is being baked-into the CommandBox base image. After that, spinning up the containers should be fast.

These Docker containers and the ColdFusion application are a development-time / author-time experience only. The content of your `chapter.md` is published though a separate ColdFusion application.
