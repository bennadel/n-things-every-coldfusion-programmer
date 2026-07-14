
# ColdFusion Caveats

A field guide for CFML developers _by CFML developers_.


## What This Book Is

Managed by [Ben Nadel][ben-nadel], this project is intended to be a community-driven anthology of hard-won lessons from the ColdFusion developers who've luxuriated in both the pains and the pleasures of CFML. Part lessons learned, part cookbook, part technical pontification, this book brings together any and all _"Ah ha!"_ moments that our wonderful CFML community wants to share.

Each chapter is intended to be a standalone, cohesive look at some aspect of ColdFusion. The chapters can be read in any order; and no chapter depends on another chapter. The only prerequisite is an introductory understanding of ColdFusion and a love of web-based application development.


## What This Book Is Not

This book isn't intended to compete with more education-oriented resources, such as:

* Adobe: [Developing ColdFusion Applications][acf-user-guide]
* Ortus Solutions: [Modern ColdFusion in 100 Minutes][learn-cf-100]
* Community: [Learn CF in a Week][learn-cf-week]

This book isn't a beginning-to-end linear approach to learning ColdFusion. Instead, each chapter is designed to live on its own as a cohesive insight into the CFML platform. This book is more a collection of essays than it is an education curriculum.


## Contributing Content To This Book

The parsing, rendering, and styling of the book content is still very much a **work in progress**. I wanted to get _something_ in place so that anyone keen to contribute could start to do so. Once we have more content in place, I'll focus more on the look-and-feel of the book itself.

### How Contributing Works (Fork & Pull Request)

This book is intended to be a community project that's authored in [Markdown][markdown] and showcases the majesty of [ColdFusion][coldfusion]. I've done my best to make it as easy as possible to contribute. But, collaborating across GitHub accounts isn't the easiest concept in the world. There is some essential complexity.

When contributing chapters to this book, you don't push changes directly to this repository. Instead, you fork this repository into your own GitHub account, work directly on your own copy, and then propose your changes back to this repository using a pull request (PR):

1. [Fork][github-fork] this repository.
2. [Clone][github-clone] your copy to your computer.
3. Create a feature branch for your chapter: `git checkout -b my-chapter`.
4. Write and commit content to your feature branch (see some additional details in next section on how to write a chapter).
5. Push the branch to your fork / repository: `git push origin -u my-chapter`.
6. [Open a Pull Request (PR)][github-upstream] from your fork's branch back to this repository.

At that point, I'll review the prose, images, and any accompanying code and we'll discuss any changes that need to be made prior to merging. This is intended to be a **low pressure project**; so if any of this sounds intimidating, don't stress. The goal here is to have fun and spread the Joy of CFML.

### How to Write a Chapter

To author a chapter &mdash; or chapters &mdash; you must:

1. Prepare your author biography (within the `book` directory).

   1. Copy the `author-template` folder into `authors`.
   2. Rename your folder using kebab case, ex `john-smith`.
   3. Update the `bio.md` content.

2. Prepare your chapter content (within the `book` directory).

   1. Copy the `chapter-template` folder into `chapters`.
   2. Rename your folder using kebab case, ex `session-management`.
   3. Update the `metadata.json` file (inside your chapter folder) to identify the kebab-case directory names you used for both your author bio and chapter.
   4. Update the `chapter.md` content with your insights, wisdom, and passion.

When you're ready, push your branch back up to GitHub and open a pull request (see previous section).

### Markdown Only Lifestyle

If you only want to modify the `chapter.md` file, there's nothing more you need to do. If you have an established authoring workflow and you have a way to preview Markdown content, I'm not here to mess up your flow.

### Markdown + Docker Lifestyle

_That said_, the `chapter-template` comes with a **Docker Compose** file that defines two services:

* [**`http://localhost/`**](http://localhost/) - a Markdown-to-HTML preview of your chapter content, including rendered images and syntax-highlighted code blocks.

* [**`http://localhost:8080/`**](http://localhost:8080/) - a ColdFusion application context that you can use to write and verify the CFML code that you want to reference in your chapter. The source code for this application is in `{chapter}/code/app`. You can modify the contents of the `app` folder in any way that helps you write your chapter.

To spin-up the Docker containers, you need to `cd` into your chapter folder and run `docker compose up`. The first time Docker builds the images, it may take 1-2 minutes because the CFML engine is being baked-into the [CommandBox][commandbox] [base image][commandbox-image]. After that, spinning up the containers should be fast.

If your chapter deals with other external resources, such as relational databases, key-value stores, mail servers, etc, feel free to modify the `Dockerfile` and `docker-compose.yaml` file in any way that you see fit. The containerization is here to make your life easier.

These Docker containers and the ColdFusion application are a development-time / author-time experience only. The content of your `chapter.md` is published through a separate ColdFusion application.


[acf-user-guide]: https://helpx.adobe.com/coldfusion/developing-applications/user-guide.html

[ben-nadel]: https://www.bennadel.com/

[coldfusion]: https://www.adobe.com/products/coldfusion-family.html

[commandbox]: https://www.ortussolutions.com/products/commandbox

[commandbox-image]: https://hub.docker.com/r/ortussolutions/commandbox/

[github-clone]: https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository

[github-fork]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo

[github-upstream]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork

[learn-cf-100]: https://www.ortussolutions.com/learn/books/coldfusion-in-100-minutes

[learn-cf-week]: https://www.learncfinaweek.com/

[markdown]: https://www.markdownguide.org/
