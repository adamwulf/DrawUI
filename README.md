# DrawUI

DrawUI is drop in library to support high performance ink on iOS. The framework cleanly separates the touch input from the pen-stroke model from the ink rendering itself. This clean separation allows for principled optimizations and customization.

The goal is to be able to easily swap out renderers for the same model data, making it easy to change how a drawing is rendered, either in realtime, by replay, or in a background thread, etc etc.

## Organization

The following describes how touch input is processed by the DrawUI and rendered on screen.

### Step 1: User Input
`MMTouchStreamGestureRecognizer` listens for all of the user's finger or stylus touches. These `touches*:withEvent:` methods 
might be called faster than we can render any previous touches, so all touch information is cached into a `MMDrawModel`'s `MMTouchStream`.
This stream is an array of all input events from the user that will eventually be converted into inked lines. The gesture's internal method
 `touchesEstimatedPropertiesUpdated:` adds new touch events into this stream. Every event in this stream is a `MMTouchStreamEvent` object.


### Step 2: Ink Model
The `MMDrawModel` processes the `MMTouchStreamEvent` and converts it into a more structured model repesenting the ink. This is done in `processTouchStreamWithTool:` where all unprocessed events from the stream are converted to inked strokes using the input tool. Each
event is processed once, and subsequent calls to `processTouchStreamWithTool:` will process all new events since the last processing. 

The `MMDrawModel` will either begin a new stroke for a `UITouchPhaseBegan` event, or will update an existing stroke
with the event's data. Each stroke's data is stored in separate `MMDrawnStroke` objects. Each stroke is composed of many `MMAbstractBezierPathElement`
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

Also, each event contains a `touchIdentifier` which is a unique identifier of the touch that spawned that event. This touch identifier
is used to match the event to the correct stroke. This allows a touch pressure update event (which comes in late), to still be matched to
update an already completed stroke. Segments of a stroke are updated if the `touchIdentifier` and the `estimationUpdateIndex` match.


### Step 3: Render

Multiple renderers can process a single `MMDrawModel`. After every touch, the model is updated and renderers are notified of the changes and
given a chance to update. Some renderers might immediately render the changes (for instance, a background thumbnail generator), while some might
`setNeedsDisplayInRect:`  for the affected area (see `SmartDrawRectRenderer`).

Since every stroke and segment in the model is versioned, renderers can optimize and only update or draw pieces of the model that have been
updated since the last render. For some renderers like the `NaiveDrawRectRenderer`, little optimization is possible, but for others like the
`CALayerRenderer`, significant optimization is possible.

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

