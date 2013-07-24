<a href='index.html'>
  <img id="logo" src="img/pixi.png" />
</a>

# Pixi.js Isometric Map Part 1

:::BEGIN Example

This example draws an isometric map using a tile created from Pixi.js primitives. Inpired by [Juwal Bose's Isometric Worlds](http://gamedev.tutsplus.com/tutorials/implementation/creating-isometric-worlds-a-primer-for-game-developers/).

{{{EXAMPLE style='height: 310px;'}}}

## Setup Stage and Renderer

Setup the stage as usual.

```js
var WIDTH = 700;
var HEIGHT = 300;
var stage = new PIXI.Stage(0xEEFFFF);
var renderer = PIXI.autoDetectRenderer(WIDTH, HEIGHT);

document.body.appendChild(renderer.view);
```

## Rendering a Tile

Let's use Pixi.js primitives to draw an isometric tile. The function draws a rhombus
within a rectangle representing an image provided a designer. Normally a sprite from an
image would be used, but let's leave that for the next tutorial.

```js
var graphics = new PIXI.Graphics();
stage.addChild(graphics);

// create a closure to simplify code
function colorRhombus(backgroundColor, borderColor, w, h) {
    return function(x, y) {
        graphics.beginFill(backgroundColor);
        graphics.lineStyle(1, borderColor, 1);
        graphics.moveTo(x + w/2, y);
        graphics.lineTo(x + w, y + h/2);
        graphics.lineTo(x + w/2, y + h);
        graphics.lineTo(x, y + h/2);
        graphics.lineTo(x + w/2, y);
        graphics.endFill();
    }
}
```

## Map and Tile Metadata

To better visualize how the tiles are drawn let's define constants.
Note, game logic should remain in 2D coordinates and that is empasized below
with different variables.

```js
// map
var rows = 5;
var cols = 4;
var G = 0, D = 1, W = 2;
var tiles = [
    G, G, G, G,
    D, D, D, D,
    D, G, W, W,
    D, G, W, W,
    G, G, W, W
];

var twoDHeight =  120;
var twoDWidth =  120;
var tileWidth = twoDWidth;
var tileHeight = twoDHeight / 2;

// tiles
var grass = colorRhombus(0x80CF5A, 0x339900, tileWidth, tileHeight);
var dirt = colorRhombus(0x96712F, 0x403014, tileWidth, tileHeight);
var water = colorRhombus(0x85b9bb, 0x476263, tileWidth, tileHeight);
```

## Rendering the Isometric Map

This algorithm draws the map with the x-axis increasing
in southeast direction and the y-axis increasing in a southwest direction.

```js
// sort depth & draw to canvas
function drawMap(rows, cols) {
    var tileType;
    var x, y;
    var idx;
    var xOffset = WIDTH / 2;

    for (var i = 0; i < rows; i++) {
        for (var j = 0; j < cols; j++) {
            idx = i * cols + j;

            tileType = tiles[idx];
            console.log(idx, tileType);

            // 2D coordinate
            x = j * twoDWidth;
            y = i * twoDHeight;

            // image placement coordinates
            x = (x - y) / 2;
            y =  (x + y) / 2;

            if (tileType === G) drawTile = grass;
            else if (tileType === D) drawTile = dirt;
            else if (tileType === W) drawTile = water;

            drawTile(xOffset + x, y);
        }
    }
}

drawMap(rows, cols);
```

Since there is no interactivity, render the map once.

```js
function animate() {
  renderer.render(stage);
}

requestAnimFrame(animate);
```

:::> support/common.md


:::END