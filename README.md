
# N+1 Things Every ColdFusion Programmer Should Know

I've always enjoyed the ["97 Things Every ... Should Know"][97-things] style books. I thought it might be fun to have one that relates to ColdFusion / CFML. I especially like that those books often have many authors and voices, which makes it easier to compile.

Some random ideas that might be meaningful - these are just _working chapter titles_ to be fine-tuned and organized.

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


[97-things]: https://github.com/97-things

