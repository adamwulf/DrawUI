# DrawUI

Draw UI is an inking framework for iOS. The goals are:

1. Low CPU overhead
2. Easy to customize
3. Easy to integrate
4. Multiple rendering methods


### Low CPU Overhead
UITouches can be both predicted and asynchronously updated. Touch inputs from the Pencil arrive extremely quickly, and represent a moment in time of the touch's location, force, azimuth, etc.

A naive approach to smooth these points, generate a fitting UIBezierPath, and render to the screen efficiently a major challenge.

DrawUI aims to be a drop-in inking view that won't consume tons of CPU during drawing, and is flexible for integrating into your project.


### 2. Easy to customize

DrawUI processes all touch inputs in stages:

1. Gesture for capturing touch event data
2. Coalesce touch events into `Stroke` objects
3. Optionally modify each `Stroke`'s points
4. Generate fixed-width or variable-width `UIBezierPath`
5. Render strokes to the screen or an output image

At each of the points in the above pipeline, you have the opportunity to modify DrawUI's behavior.

It's very likely that one of DrawUI's renderers will be sufficient for your needs, but if not, you have the option of modifying DrawUI's behavior at whatever level of detail you need.


### 3. Easy to integrate

To get started:

[ fill in getting started code here ]


### 4. Multiple rendering methods

DrawUI includes multiple rendering methods. Many are unoptimized reference renderers, like `DebugView`. Others are highly optimized renderers. Most involve rendering the ink to the screen, though some are included to generate image or PDF contents.


## TODO

### Smoothing:

- [ ] SmoothStroke model for generating fixed-width UIBezierPaths
- [ ] SmoothStroke model for generating variable-width UIBezierPaths


### Renderers:

The below should also implement undo/redo

- [ ] Basic CGContext rendering
       - with and without background image
- [ ] naive DrawRect
- [ ] smarter DrawRect
- [ ] CAShapeLayer
- [ ] CAShapeLayer with flattened cache 
- [ ] SceneKit (git@github.com:adamwulf/SKDraw.git)


### Filters:

- [x] Implement naive SavitzkyGolay smoothing
- [ ] Implement optimized SavitzkyGolay smoothing
- [ ] Implement naive DouglasPeucker filtering
- [ ] Implement optimized DouglasPeucker filtering
- [ ] Implement naive DistanceThinning filtering
- [ ] Implement optimized DistanceThinning filtering
