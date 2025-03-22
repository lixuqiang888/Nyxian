# Memory Module

### Introduction

As memory is not low level in usual JavaScript I wrote a implementation for Heapmemory. This is mostly done for things like [ArbCall](ArbCall.md). So you have to read it in order to use ArbCall correctly.



###### Function Index

- **Allocation**
  - `malloc`
  - `free`

- **Reading**
  - `mread8`
  - `mread16`
  - `mread32`
  - `mread64`
- **Writing**
  - `mwrite8`
  - `mwrite16`
  - `mwrite32`
  - `mwrite64`

- **Buffering**
  - `mread_buf_str`
  - `mwrite_buf_str`




***

### Allocation and releasing heap memory

Memory is handled also with pointers in this case. In case you dont release memory it's **automatically released on the end of the execution**

###### Example

```js
include("memory");

// allocating a pointer with the size of a 8bit value
let ptr = memory.malloc(1);

// releasing the heap memory again
memory.free(ptr);
```

***

### Simple reading and writing of heap memory

Reading and writing of heap memory is obviously crucial if you can already allocate and free it. **Nyxian** has certain functions to do that.

- **Reading**:
  - `mread8`: reads a 8 bit value of a pointer
  - `mread16` : reads a 16bit value of a pointer
  - `mread32`: reads a 32bit value of a pointer
  - `mread64` reads a 64bit value of a pointer
- **Writing**:
  - `mwrite8`: writes a 8 bit value to a pointer
  - `mwrite16`: writes a 16bit value to a pointer
  - `mwrite32`: writes a 32bit value to a pointer
  - `mwrite64` writes a 64bit value to a pointer

###### Example

```js
include("memory");

// allocating a pointer with the size of a 8bit value
let ptr = memory.malloc(1);

// writing a 8 bit value to the pointer
memory.mwrite8(ptr, 12);

// reading a 8 bit value of of the pointer
let value = memory.mread8(ptr);

// releasing the heap memory again
memory.free(ptr);
```

***

### Memory string buffering

Reading and writing of memory string buffers is important for example for other modules like [ArbCall](ArbCall.md). **Nyxian** has certain functions to acomplish that.

- **Reading**:
  - `mread_buf_str`: reads a string buffer with a arbitary length of a pointer
- **Writing**:
  - `mwrite_buf_str`: writes a string buffer with a arbitary length to a pointer

###### Example

```js
include("memory");

// having some string
const buffer = "Hello, World!\n";

// allocating enough memory for the buffer
let ptr = memory.malloc(buffer.length);

// writing the buffer to the pointer
memory.mwrite_buf_str(ptr, 0, buffer.length, buffer);

// reading the buffer back from the pointer
let newbuffer = memory.mread_buf_str(ptr, 0, buffer.length);

// free the pointer
memory.free(ptr);
```

