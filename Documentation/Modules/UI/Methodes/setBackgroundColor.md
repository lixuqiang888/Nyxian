# setBackgroundColor

`setBackgroundColor` is a function that changes the color of a [**UIElement**](../UIElements.md).



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
      <td><code>red</code></td>
      <td><code>integer</code></td>
      <td>The new red color value of the UIElement background</td>
      <td>Maximum integer you can pass is 255</td>
    </tr>
    <tr>
      <td><code>blue</code></td>
      <td><code>integer</code></td>
      <td>The new blue color value of the UIElement background</td>
      <td>Maximum integer you can pass is 255</td>
    </tr>
    <tr>
      <td><code>green</code></td>
      <td><code>integer</code></td>
      <td>The new red color value of the UIElement background</td>
      <td>Maximum integer you can pass is 255</td>
    </tr>
    <tr>
      <td><code>alpha</code></td>
      <td><code>double</code></td>
      <td>The new alpha color value of the UIElement background</td>
      <td>Maximum double you can pass is 1.0</td>
    </tr>
  </tbody>
</table>


###### Example

```js
include("ui");

let box = ui.spawnBox();
box.setBackgroundColor(255, 255, 255, 1.0);
```

