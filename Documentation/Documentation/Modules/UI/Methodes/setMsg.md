# setMsg

`setMsg` is a function that changes the text of a [**UIElement**](../UIElements.md). Its specifically for the use with [UISurface](../UISurface.md)



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
      <td><code>text</code></td>
      <td><code>string</code></td>
      <td>The new message a UIElement sends</td>
      <td>None</td>
    </tr>
  </tbody>
</table>



###### Example

```js
include("ui");

let box = ui.spawnBox();
box.setMsg("some message");
```

