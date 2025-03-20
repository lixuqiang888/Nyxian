# Nyxian [WIP]
## Intro
This project is an attempt to create a new JIT-less script language based on the JavaScriptCore Framework by apple. Im working on that to make coding on just your phone easier and just because I am bored. JavaScriptCore also offers a extremely easy way to expose ObjectiveC Objects and interact with them inside ur script. This enables us to do awesome things. I also might work on creating a `ui` module for FridaScript to create GUIs for your code.
## Modules
Modules are like libraries in FridaScript, you can use the `include("<module name>");` function to load modules into ur FridaScript code. They expose a lot of apples low level functions and make them usable in a safe way. We call the safety `Runtime Safety` it prevents the app from being crashed by low level operations, by tracking and disallowing their malicious use. If you still wish to do malicious things you can call `disable_safety_checks();` which will show up a user alert the user has to consent to. Also the modules currently available are...

- [`io`](Nyxian/Runtime/Modules/IO/IO.md)
- `memory`
- `string`
- `math`
- `proc`

`io` is the most finished module from all and it's for now the most advanced module in FridaScript. `io` is exposing low level C functions so you can basically interact with files.
