# Display

The Display is something new and advanced taken from the Sean16 CPU which is also made by me. Its made to display arbitary Graphics.

> Gonna support more features soon. Support like uploading 2D models to the GPU and then drawing them at a specific location.

Here is example code for the Display.

###### Example

```js
// include modules
include("ui");
include("timer");
include("math");

// Display Functionality
// Again Reminder "Nyxian" is low level, you need to write ur own drawing functions
let display = ui.spawnDisplay();

function drawLine(startX, startY, endX, endY, colorIndex) {
    let dx = math.abs(endX - startX);
    let dy = math.abs(endY - startY);
    let sx = (startX < endX) ? 1 : -1;
    let sy = (startY < endY) ? 1 : -1;
    let err = dx - dy;

    while (true) {
        // Set the pixel at the current position
        display.setPixel(startX, startY, colorIndex);

        // If we've reached the end point, break the loop
        if (startX === endX && startY === endY) {
            break;
        }

        let e2 = err * 2;
        
        // Determine which direction to step in
        if (e2 > -dy) {
            err -= dy;
            startX += sx;
        }
        if (e2 < dx) {
            err += dx;
            startY += sy;
        }
    }
}

function drawBox(startX, startY, width, height, colorIndex) {
  drawLine(startX, startY, startX + width, startY, colorIndex);										// Top side
  drawLine(startX, startY + height, startX + width, startY + height, colorIndex); // Bottom side
  drawLine(startX, startY, startX, startY + height, colorIndex);           				// Left side
  drawLine(startX + width, startY, startX + width, startY + height, colorIndex); 	// Right side
}

function fillBox(startX, startY, width, height, colorIndex) {
    // Fill the interior of the box with the given color
    for (let x = startX + 1; x < startX + width; x++) {
        for (let y = startY + 1; y < startY + height; y++) {
            display.setPixel(x, y, colorIndex);
        }
    }
}


// init
fillBox(0, 0, 256, 256, 32);

// you have to redraw the screen
display.redrawScreen();

timer.wait(3);
ui.destroy(display);
```

