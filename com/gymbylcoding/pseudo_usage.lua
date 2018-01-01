local perspective = require("perspective") -- Include the library

local camera = perspective.createView([numLayers]) -- Optional parameter is the number of layers

camera:appendLayer() -- Add a new layer to the back of the camera

camera:prependLayer() -- Add a new layer to the front of the camera indexed with 0, -1, -2, etc.

camera:add(obj, layer, [isFocus]) -- obj is any display object; layer is the layer to add the object to (lower numbers = front of camera); isFocus is a convenience value for whether to initially set the focus to this object

camera:trackFocus() -- "Tick" the camera once

camera:setBounds(x1, x2, y1, y2) -- Set the bounding box that tracking is confined to. Any values that evaluate to Boolean negative are interpreted as infinite; infinite values apply to an entire axis (if x2 is infinite and x1 is not, X-axis constraint will be disabled)

camera:track() -- Begin auto-tracking. This eliminates the need to update the camera every frame

camera:cancel() -- Stop auto-tracking

camera:remove(obj) -- Remove an object from the camera

camera:setFocus(obj) -- Set the camera focus to an object

camera:snap() -- Snap the camera to the focus point (ignores damping)

camera:toPoint(x, y) -- Change the camera's focus to an X,Y point

camera:layer(n) -- Get a layer object of the camera

camera:layers() -- Get the array holding each layer

camera:destroy() -- Destroy the camera and clear memory

camera:setParallax(...) -- Set parallax quickly for multiple layers. Each value provided will apply to the correspondingly indexed layer. Provide a table with {x, y} values for an argument to set X and Y parallax independently

camera:layerCount() -- Get the number of layers in the camera

camera:setMasterOffset(x, y) -- Set a camera-wide offset (for layer offset, use layer:setCameraOffset())

----------------------

camera.damping = n -- "Fluidity" the camera implements with tracking. Higher values will make the camera move more slowly; values approaching 1 will make the camera move more rigidly

layer.xParallax = n -- X-parallax ratio of a layer; expressed as fraction of "normal" movement

layer.yParallax = n -- Y-parallax ratio of a layer; expressed as fraction of "normal" movement

layer:setCameraOffset(x, y) -- Set an offset for the layer's tracking