# Getting Started

### Hello World Example

```js
include("io");

function print(msg) {
  let len = msg.length;
  for(let i = 0; i < len; i++) {
    io.putchar(msg.codePointAt(i));
  }
}

print("Hello, World!\n");
```

As **Nyxian** is a powerful low level scripting language you gonna come across tasks like this where you need to write ur own functions like print.

***

### Running the Script

You can do it using the **Nyxian** app on iOS.