import Graphite
import hGeometry
import Data.List
roughEquals:: Real -> Real -> Bool
roughEquals a b =  (a*1.05 > b &&  b >= a ) || (b*1.05 > a  && a >= b ) --1.05 is a 5 percent margin or error
data Shade = RGB Real Real Real --SOMETIMES USES PHOTON AND SOMETIMES USES Computer Numbers
--always between 0.0 and 1.0 inclusive
instance Eq Shade where
  (RGB r g b) == (RGB r' g' b') = (roughEquals r r') && (roughEquals g g') && (roughEquals b b')
instance AdditiveGroup Shade where
  zeroV = (RGB 0.0 0.0 0.0 )
  (RGB r g b) + (RGB r' g' b') = (RGB (r+r') (g+g') (b+b') )
instance VectorSpace Shade where
  Scalar Shade = Real
  (*^) s (RGB r g b) = (RGB s*r s*g s*b)
  
data Color =  RBoverG Real Real 
-- | RGoverB Real Real | GBoverR Real Real | Black
instance Eq Color where
  (RBoverG r b) == (RBoverG r' b') = (roughEquals r r') && (roughEquals b b')
 -- (RGoverB r g) == (RBoverG r' g') = (roughEquals r r') && (roughEquals g g')
 -- (GBoverR g b) == (GBoverR g' b') = (roughEquals g g') && (roughEquals b b') 
 
toColor:: Shade -> Color
toColor (RGB r g b) = (RBoverG (r/g) (b/g) )

data CameraPoint = Point Shade Real Real
instance AdditiveGroup CameraPoint where
  zeroV = (Point (RGB 0.0 0.0 0.0) 0.0 0.0 )
  (Point c u v ) + (Point c' u' v') = (Point (c + c') (u + u') (v + v') )
instance VectorSpace CameraPoint where
  Scalar CameraPoint = Real
  (*^) s (Point c u v)  = (Point s*c s*u s*v)
instance Eq CameraPoint where
  (Point (RGB r g b) u v) == (Point (RGB r' g' b') u' v') = (r==r') && (g==g') && (b==b') && (u==u') && (v==v')
instance Ord CameraPoint where --needed for weird graph algorithms
  (Point (RGB r g b) u v) <= (Point (RGB r' g' b') u' v') =
    (r < r') || 
    ((r==r') && (g <g') ) ||
    ((r==r') && (g==g') && (b<b') ) ||
    ((r==r') && (g==g') && (b==b') && (u<u') ) ||
    ((r==r') && (g==g') && (b==b') && (u==u') && (v<=v')
--Hopefully hashable generic
data WierdPoint = Point Shade Real Real Real
data IRLPoint = Point Color Real Real Real
type Gamma = ([Int],[Int],[Int])
type CameraChar = (Matrix Real, Matrix Real)

getImage :: IO Matrix Shade --USE IDENTITY FUNCTION TO GO FROM RGB to Shade
getViews :: [Gamma] -> IO [Matrix Shade] --DO GAMMA CORRECTION HERE
getGammas :: IO [Gamma]
getCalibrator:: IO [WeirdPoint]
getTrackers:: IO [[IRLPoint]]
getCameraPositions:: IO [CameraChar]

generateGridGraph:: Matrix Shade -> UGraph CameraPoint Int

getConnectedComponents::(Hashable v, Eq v, Ord v) => UGraph v e -> [UGraph v e] -- MIGHT NEED TYPE CONSTRAINTS
getConnectedComponents g = 
  if (order g) > 0  then
    let v:vs = verticies g in 
      let oneComponent = bfsVerticies g v in
        let notComponent = vs \\ oneComponent in 
          (removeVerticies notComponent g ):( getConnectedComponents (removeVerticies oneComponent g) )
  else [] --RUNTIME MIGHT BE BAD :(
safetyFactor = 2.0
pi = 3.14159
ballTest:: Real -> Real -> Bool
ballTest area perimeter = area*4*pi < perimeter*perimeter*safetyFactor 
       -- constants come from circle fact 4*pi*area = circumference^2
isRoughBall:: UGraph CameraPoint Int -> Bool        
isRoughBall g =
  let perimeterEstimate = length . filter (<4) . degrees g in
    let areaEstimate = order g in
       ballTest areaEstimate perimeterEstimate
distance:: (Real, Real) -> (Real, Real) -> Real
distance (x,y) (z,w) = sqrt ((x-z)*(x-z) + (y-w)*(y-w) )
perimeterFromPoints:: [(Real,Real)] -> Real
perimeterFromPoints x:xs = (distance x (last xs)) + (pathlengthFromPoints (x:xs) ) 
pathlengthFromPoints:: Nonempty( (Real,Real) ) -> Real
pathlengthFromPoints x:[] = 0
pathlengthFromPoints x:(y:ys) = (distance x y) + (pathlengthFromPoints (y:ys) )
unpackPoint::CameraPoint -> (Real,Real)
unpackPoint (Point c u v) = (u,v)
--convexHull, toPoints  from hgeometry package
isSmoothBall:: UGraph CameraPoint Int -> Bool
isSmoothBall g = 
  let areaEstimate = order g in 
    let perimeterEstimate = perimeterFromPoints . toPoints . convexHull . map unpackPoint . verticies g in 
     ballTest areaEstimate perimeterEstimate
mean:: (VectorSpace v, s ~ Scalar v, Fractional s) => [v] -> v
mean xs = (sum xs) / (fromInteger length xs) 
isMonochrome:: UGraph CameraPoint Int -> Bool -- Converts to Color
isMonochrome g = 
  let shades = map (\(Point s u v) -> s) (verticies g) in
    let c = toColor mean shades in
      all (== c) . map toColor shades
isMonoShaded:: UGraph CameraPoint Int -> Bool -- Doesn't convert to hue
isMonoShaded g = 
  let shades = map (\(Point s u v) -> s) (verticies g) in
    let meanShade = mean shades in 
      all (== meanShade) shades
uPnP:: [CameraPoint] -> [WierdPoint] -> CameraChar --NEEDS TO DO COLOR SORTING AT START

mPnP:: [CameraChar] -> [[CameraPoint]] -> [IRLPoint] ->  Matrix Real --NEEDS TO DO COLOR SORTING AT START

getRayIntersect:: [[CameraPoint]] -> [CameraChar] -> IRLPoint --NEEDS TO DO COLOR SORTING AT START

storeCamera:: CameraChar -> IO ()
storeTracker::[IRLPoint] -> IO ()
storePositions:: [Matrix Real] -> IO()
arrangeByTracker:: [[IRLPoint]] -> [[CameraPoint]] -> [[[CameraPoint]]]
findCamera:: IO ()
findCamera = do singleFrame <- getImage
                calibrationPoints <- getCalibrator
                storeCamera (uPnP (map mean(filter isMonoShaded (filter isSmoothBall (getConnectedComponents (generateGridGraph singleFrame) ) ) ) ) calibrationPoints )
measureGamma::IO () --Strategy undefined

mainProcess:: Matrix Shade ->[CameraPoint]
mainProcess = (map mean) . (filter isMonochrome) . (filter isRoughBall) . getConnectedComponents . generateGridGraph
measureTracker:: IO ()
measureTracker = do curves <- getGammas
                    manyFrames <- getViews curves
                    cameraPositions <- getPositions
                    storeTracker (getRayIntersect (map mainProcess manyFrames ) cameraPositions )
trackAllTrackers::IO ()
trackAllTrackers = do curves <- getGammas
                    manyFrames <- getViews curves
                    cameraPositions <-getPositions
                    trackerArrangements <- getTrackers
                    let ptbyTrackerbyCamerabyColor = arrangeByTracker trackerArrangements (map mainProcess manyViews) in 
                    storePositions (map (\(x,y) -> mPnP cameraPositions x y) (zip ptbyTrackerbyCamerabyColor trackerArrangements) )
