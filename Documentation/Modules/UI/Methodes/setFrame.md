# setFrame

`setFrame` is a function that changes the position and size of a [**UIElement**](../UIElements.md).



***

###### Arguments

<table border="1">
  <thead>
    <tr>
      <th>Argument Name</th>
      <th>Type</th>
      <th>Description</th>
      <th>Notice</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>x</code></td>
      <td><code>double</code></td>
      <td>The new X coordinate of the UIElement</td>
      <td>None</td>
    </tr>
    <tr>
      <td><code>y</code></td>
      <td><code>double</code></td>
      <td>The new Y coordinate of the UIElement</td>
      <td>None</td>
    </tr>
    <tr>
      <td><code>width</code></td>
      <td><code>double</code></td>
      <td>The new width of the UIElement</td>
      <td>None</td>
    </tr>
    <tr>
      <td><code>heigth</code></td>
      <td><code>double</code></td>
      <td>The new heigth of the UIElement</td>
      <td>None</td>
    </tr>
  </tbody>
</table>


###### Example

```js
include("ui");

let box = ui.spawnBox();
box.setFrame(10, 10, 100, 100);
```

