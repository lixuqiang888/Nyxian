## Code Execution

Sooo... usually utilities that are sandboxed used **JIT(Just-In-Time)** compilation, but iOS doesnt allow for that... so what do we do?

1. `WKWebView`

   The `WKWebView` in iOS applications allows for **JIT** execution of Web developed code, but also supports **WASM(WebAssembly)** which can be beneficial in the future for example with WebHooks and a **embedded in app WASM compiler that could compile Rust and C code to Wasm** and then open `WKWebView` which is a external process on iOS. We could use WebHooks hosting a on-device HTML server using stuff like [Swifter](https://github.com/httpswift/swifter). The Webhooks to get console I/O.

2. The [iSH](https://github.com/ish-app/ish) project, specifically their CPU

   [iSH](https://github.com/ish-app/ish) made a great **threaded i386 CPU and a lightweight linux syscall interpreter**. Its also faster than emulators like [Qemu](https://github.com/qemu/qemu) because **it directly interprets linux syscalls**. We could **embed a musl compiler to the iOS application** and then **execute the binary** using the i386 cpu and linux syscall interpreter to execute the binary.

3. [Blink](https://github.com/jart/blink)

   Its a tiny x86_64 emulator, we could use it for Code execution, its relatively fast and I was already successfully in running C code in the past using Blink.

4. Interpreter

   **Not really the best option** but also possible, you could **embed a JITless interpreter** to interpret the code someone wrote directly in app, thats tho not recommended as thats prone to be slow, etc. **unless the interpreter first compiles the code to a byte code level and then interprets the byte code**.

5. Last Resort... iOS allows JIT under condition

   Actually we dont want this to be the case, but in last resort you could use JITfull compilers in combination with a JIT enabler... why is it bad? **because the user has to enable it using their computer**.. which would destroy the reason for making our coding app which is made to be used on-the-go. **Additionally the user would have to enable JIT eachtime the app launches**.