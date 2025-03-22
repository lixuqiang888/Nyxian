# Core Concepts and Syntax

### Syntax Overview

**Nyxian** uses a combination of statements, expressions, and functions to create a program. Code is typically written in plain text files with the `.nx` extension. Key elements of **Nyxian** syntax include:

- **Statements**: Instructions that **Nyxian** executes (e.g., assignments, conditionals).
- **Semicolons**: End of a statement, though they can sometimes be optional.
- **Curly braces `{}`**: Used to define blocks of code, such as in functions or conditionals.

``````js
let name = "John"; // Assignment statement
print(name);  // Function call to print value
``````

***

### Keywords

Keywords are reserved words that have special meaning in **Nyxian** and cannot be used for variable names. Examples include:

- **let**: Declare a block-scoped variable.
- **const**: Declare a constant variable.
- **function**: Define a function.
- **if, else, switch**: Control flow keywords.
- **return**: Return a value from a function.
- **for, while**: Looping keywords.

```js
let age = 25;   // let to declare variable
const PI = 3.14;  // const for a constant
```

***

### Data Types

**Nyxian** has several basic data types, including:

- **Primitive Types**:

  - **Number**: Represents both integer and floating-point numbers.
  - **String**: Represents sequences of characters.
  - **Boolean**: Represents true or false values.
  - **Null**: Represents a "no value" or "empty" state.
  - **Undefined**: Represents an uninitialized variable.
  - **Symbol**: Represents a unique and immutable value.
  - **BigInt**: Represents large integers.

- **Object**: A collection of key-value pairs, including arrays and functions.

  ```js
  let number = 10;           // Number
  let name = "JavaScript";   // String
  let isActive = true;       // Boolean
  let user = { name: "Jane" }; // Object
  ```

***

### Control Flow

Control flow structures allow you to dictate how your program executes based on conditions.

- **if/else**: Conditional statements.
- **switch**: A multi-condition switch statement.
- **for, while, do-while**: Looping constructs for repeating code.

```js
if (age > 18) {
  print("Adult");
} else {
  print("Minor");
}

for (let i = 0; i < 5; i++) {
  print(i);  // Loop from 0 to 4
}
```

***

### Functions

Functions are blocks of code designed to perform a particular task. They can take parameters and return a result.

- **Function Declaration**:

  ```js
  function greet(name) {
    return "Hello " + name;
  }
  ```

- **Function Expression**:

  ```js
  const greet = function(name) {
    return "Hello " + name;
  };
  ```

- **Arrow Functions** (shorter syntax):

  ```js
  const greet = (name) => "Hello " + name;
  ```

Functions can be called by their name with arguments, and they can return values.

``````js
function greet(name) {
  return "Hello " + name;
}

print(greet("Alice")); // Output: Hello Alice
``````
