# DrawUI

DrawUI is drop in library to support high performance ink. The framework cleanly separates the touch input from the pen-stroke model from the ink rendering itself. This clean separation allows for principled optimizations and customization.

The goal is to be able to easily swap out renderers for the same model data, making it easy to change how a drawing is rendered, either in realtime, by replay, or in a background thread, etc etc.

## Organization

The following describes how touch input is processed by the DrawUI and rendered on screen.

### Step 1: User Input
`MMDrawView` touch methods listen for all of the user's finger or stylus touches. These `touches*:withEvent:` methods might be called faster than
we can render any previous touches, so all touch information is cached into a `MMTouchStream`. This stream is essentially an array of all input events
from the user that will eventually be converted into inked lines. Event `touchesEstimatedPropertiesUpdated:` adds new touch events into this 
stream. Every event in this stream is a `MMTouchStreamEvent` object.


### Step 2: Ink Model
The `MMDrawModel` processes the `MMTouchStreamEvent` and converts it into a more structured model repesenting the ink. This is done in `processTouchStream:withTool:` where all unprocessed events from the stream are converted to inked strokes using the input tool.

To process the data, the `MMDrawModel` will either begin a new stroke for a `UITouchPhaseBegan` event, or will update an existing stroke
with the data. Each stroke's data is stored in separate `MMDrawnStroke` objects. Each stroke is composed of many `MMAbstractBezierPathElement`
objects. Generally, each new element corresponds to an updated touch position, though that's not strictly necessary.

The model calculates an incrementing version number for each event that is processed. Whenever a stroke is updated from an event, that stroke's
version is also matched to the event's version number. Similarly, each element of a stroke is marked with the version of the event that last
affected that element. In this way, a renderer can detech which strokes and which elements of those strokes have changed since a particular
version number.

Some events might be predictions of where the user _might_ draw. In this case the model will create its ink model with that tagged, and then
will automatically remove those predicted pieces of the ink and will update to the final ink (see `[MMDrawnStroke addEvent:]`).

Some events might be updates to existing events. Touch pressure data, for instance, usually lags behind the location data for a touch and will arrive
in a later event. In this case, the model will update the affected stroke to adjust its width or properties to the updated event attributes 
(see `[MMDrawnStroke addEvent:]`).


### Step 3: Render

Multiple renderers can be installed on a single `MMDrawView`. After every touch, the model is updated and renderers are notified of the changes and
given a chance to update. Some renderers might immediately render the changes (for instance, a background thumbnail generator), while some might
`setNeedsDisplayInRect:`  for the affected area (see `SmartDrawRectRenderer`).


### Motivation

The above allows a draw view to separate the concerns of processing touch data, from calculating an ink model from those touches, from rendering that model
to the screen. It's then possible to synthesize fake touch data to draw programatically, or to use the same touch data to render for different needs
(thumbnail vs screen, etc).

## Code Overview

### Input

`MMTouchStream`: A stream of touch and stylus inputs events. An array of `MMTouchStreamEvent`s implement `NSCopying` and `NSSecureCoding` so that they can be easily stored and replayed at any time.

### Model

`MMDrawModel`: The model processes an `MMTouchStream` to generate the ink strokes, including the smoothed bezier paths, tool, color, and other properties. This is pure model data, and can be applied to any renderer. This generates `MMDrawnStroke`s, each composed of concrete implementations of `MMAbstractBezierPathElements`.

### Rendering

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

