# AnotherTrackingSolution
Goal: Small cheap VR trackers via monochromatic balls and good computer vision algorithms.

There are probably a lot of VR tracking solutions out there, but two of the good solutions have major flaws:
1. The april tag trackers - These trackers are cheap! but they are clunky and the current repository doesn't combine different camera feeds (last the writer checked).
2. The PSMove trackers - These trackers use interesting image detection and are accurate! but they use a bunch of electronics to correct for noise in the optical system.
 
The layers of this solution are as follows:
1. A rig of a few(>3) Monochromatic balls (do they need to be internally lit?)
2. Generic (but characterized) Cameras
3. Break Images into different color masks. (Need units of color)
4. Find connected components in color masks when treated as a grid graph. (Fast algorithms exist)
5. Decide if a connected component is roughly a ball. (via perimeter^2 to area ratio)
6. Apply multi Camera Perspecitive N Point algorithm to generate trackers position orientation.

Pros:
Very Interprable Steps.
Step 3 and 6 are likely of independent interest.

Cons: 
If a color appears in the room and the light it might get confused.
Distance data might be being thrown out.
This implementation won't let colors be reused.

Difficulties: 
Correctness of steps 3,5,6 might be hard to establish.
