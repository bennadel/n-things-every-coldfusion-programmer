
# N+1 Things Every ColdFusion Programmer Should Know

I've always enjoyed the ["97 Things Every ... Should Know"][97-things] style books. I thought it might be fun to have one that relates to ColdFusion / CFML. I especially like that those books often have many authors and voices, which makes it easier to compile.

This is not intended to compete with more educational resources, such as:

* Adobe: [Developing ColdFusion Applications](https://helpx.adobe.com/coldfusion/developing-applications/user-guide.html)
* Ortus Solutions: [Modern ColdFusion in 100 Minutes](https://www.ortussolutions.com/learn/books/coldfusion-in-100-minutes)
* Community: [Learn CF in a Week](https://www.learncfinaweek.com/)

This N+1 book isn't so much about _learning_ ColdFusion as it is about _leveraging_ ColdFusion in interesting and / or non-obvious ways.

The following are some random ideas that might be meaningful - these are just _working chapter titles_ to be fine-tuned and organized.

## ColdFusion is built on top of Java

Elevator pitch: we can reach down into the Java layer and also import powerful, battle-tested Java libraries.

## `Application.cfc` is instantiated on every request

Elevator pitch: this component is very dynamic and can have settings enabled / disabled on a per-request basis.

## Functions can be dynamically added to components

Elevator pitch: you can inject methods into a CFC at runtime for meta-programming and dynamically generated methods.

## ColdFusion supports meta-programming strategies

Elevator pitch: supports things like dependency injection.

## Parallel iteration can super-charge performance

Elevator pitch: optional parallel iteration for arrays and structs can be a huge performance boost when doing IO-bound work.

## ColdFusion provides encoding methods for safe output

Elevator pitch: security is a top priority for ColdFusion and there are many methods to make sure you keep pages secure.

## `switch` `case` values can be variable references

Elevator pitch: You can use references instead of "magic strings" to make cases easier to maintain.

## `cfmodule()` can be used to execute templates in isolation

Elevator pitch: You can give a template its own, isolated `variables` scope, which allows you to prevent variables from leaking farther than desired.

## Understanding the interplay between `readonly` and `exclusive` locks

Elevator pitch: ColdFusion has powerful locking semantics for shared code.

## Parent-Child tags can be split across methods (Lucee)

Elevator pitch: Common tags, like `cfhttpparam()`, can be factored out into shared methods.

## Returning SQL queries as arrays and structs

Elevator pitch: The `cfquery` tag can return results as arrays-of-structs (or a struct of structs), which can make data processing easier.

## Strings are inherently multi-line

Elevator pitch: Strings can have line-breaks, which can be helpful.

## Using partial type paths in arguments

Elevator pitch: You don't have to use _full paths_ in function arguments and return types.

## Using partial type paths in error handling

Elevator pitch: You can create more open-ended error handling using partial dot-delimited types.

## `Application.cfc` mappings

Elevator pitch: Mappings can be used in `cfinclude`, `cfmodule`, `expandPath`, `new`, `createObject`, etc.

## ColdFusion is 1-based which is awesome

Elevator pitch: Most things in ColdFusion start at `1`, not `0`. This makes the code much easier to write and read.

## Data type conversions

Elevator pitch: Strings to numbers, binary to text, base64, base64url, JSON, etc.

## Using `CFParam` to param complex objects

Elevator pitch: While `cfparam` is often used to validate and default simple types, it can also be used to validate and default complex objects.

## ColdFusion supports mixins

Elevator pitch: You can use the `cfinclude` tag to pull functions into any context and treat them like mixins. This works in both CFML and CFC files.

## `CFDump` tag attributes

Elevator pitch: The `cfdump` tag (and `writeDump()` function) is one of the most powerful features of ColdFusion debugging. Using the attributes can make it even more effective. Also, you can use this tag to write to the standard-out stream (`output="console"`).

## Manually managing session cookies

Elevator pitch: It's really easy to just set `this.sessionManagement` to `true` and start putting values in the `session` scope. But, this can become problematic for large sites and sites that span multiple servers. Manually managing session cookies opens-up a lot of new possibilities.

## Downstream effects of mutating the `cookie` scope

Elevator pitch: The `cfcookie` tag allows you to set cookie values. But, you can also set values directly on the `cookie` scope. And, doing so will quietly send `Set-Cookie` headers back to the browser.

## Function and variable hoisting

Elevator pitch: `var` and `function` declarations are hoisted, which allows you to make your code read better from top-to-bottom. It also means you can weave `var` declarations into `if`/`else` blocks without having to declare some nonsense variable at the top.

## `cfloop` tag will create `variables`-scoped variables by default

Elevator pitch: Unless you explicitly scope the `index` / `item` / `key` iteration variables in your `cfloop` tag, ColdFusion will define them on the `variable` scope. If done in the context of a persisted ColdFusion component, this can create a subtle memory leak. This is especially problematic in some ColdFusion frameworks.

## Using `getAsBinary` in `CFHttp` for better consistency

Elevator pitch: Sometimes the `cfhttp` tag returns data as string; sometimes it returns it as a binary object. Who knows why. Best to use the `getAsBinary` attribute to always return binary. Which, of course, doesn't actually do that (in edge cases for Connection Failure).

## `cfdump` output options

The `cfdump` and `writeDump()` features are one of the most powerful parts of ColdFusion. They have loads of options that grant you fine control over the output; including writing output to the standard-out stream.


[97-things]: https://github.com/97-things

