# UI Module

### Introduction

**Nyxian features a UI bridge**. It can be used with **UIKit**. The bridge supports **the spawning of [UIElements](UI/UIElements.md) and the destruction of those** as well, as well as **communication with [Buttons](UI/UIElements/Button.md) and simulare elements** using something I wrote called **UISurface**.



###### Function Index

- Information
  - `uiReport`
- [UISurface](UI/UISurface-md)
  - `waitOnMsg`
  - `gotMsg`
  - `getMsg`
- Spawning
  - `spawnAlert`
  - `spawnBox`
  - `spawnLabel`
  - `spawnButton`
  - `spawnDisplay`
- Management
  - `goTop`
  - `goBottom`
  - `destroy`
- Misc
  - `hapticFeedback`



***

### Screen Information

Getting the Screen sizing is very crucial. For this you can use a **`ui` module** function called `uiReport`.

###### Examples

```js
// include UI library
include("ui");

// getting screen info object
let uirep = ui.uiReport();

let width = uirep.width;
let heigth = uirep.heigth;
```



***

### Spawning

To spawn [UIElements](UI/UIElements.md) the **`ui` module** has a few **Nyxian Runtime** passed through functions. These functions return a **Nyxian Runtime** object you can use to control each UI element. More on that further down.

###### Example

```js
// include UI library first
include("ui");

// spawning some UI
let box = ui.spawnBox();
let label = ui.spawnLabel();
let button = ui.spawnButton();
let display = ui.spawnDisplay();
```



***

### Destruction

If you have spawned UI and you wanna get rid of it while ur executing code thats no problem. You can do it by executing `ui.destroy(element);` which removes the view from the hierachie.

###### Example

```js
// include UI library first
include("ui");

// spawning UI
let box = ui.spawnBox();

// some actions
// ...

// destroying it
ui.destroy(box);
```

