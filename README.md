# DrawUI

DrawUI is drop in library to support high performance ink. The framework cleanly separates the touch input from the pen-stroke model from the ink rendering itself. This clean separation allows for principled optimizations and customization.

## Input

`MMTouchStream`: A stream of touch and stylus inputs events. An array of `MMTouchStreamEvent`s implement `NSCopying` and `NSSecureCoding` so that they can be easily stored and replayed at any time.

## Model

`MMDrawModel`: The model processes an `MMTouchStream` to generate the ink strokes, including the smoothed bezier paths, tool, color, and other properties. This is pure model data, and can be applied to any renderer.

## Rendering

The following renderers are supported:

1. `MMThumbnailRenderer` will generate a `UIImage` from the model
2. `DebugRenderer` will render the drawn strokes with additional debug data
3. `NaiveDrawRectRenderer` renders the model inside a `UIView`'s `drawRect:` method
4. `SmartDrawRectRenderer` same as above, but optimizes with `setNeedsDisplayInRect:`
5. `CATiledLayerRenderer` renders the model within a `CATiledLayer`
6. `CALayerRenderer` uses CAShapeLayers and masks to render the model

Other possible renderers yet-to-be-written:

1. Using SpriteKit (prototype at https://github.com/adamwulf/SKDraw)
2. SceneKit for closer-to-metal rendering
3. OpenGL or Metal

