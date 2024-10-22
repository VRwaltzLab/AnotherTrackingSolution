import Graphite
import Data.List
roughEquals:: Real -> Real -> Bool
roughEquals a b =  (a*1.05 > b &&  b >= a ) || (b*1.05 > a  && a >= b ) --1.05 is a 5 percent margin or error
data Color = RGB Real Real Real --SOMETIMES USES PHOTON AND SOMETIMES USES Computer Numbers
instance Eq Color where
  (RGB r g b) == (RGB a d c) = (roughEquals r a) && (roughEquals g d) && (roughEquals b c)
instance AdditiveGroup Color where
  zeroV = (RGB 0.0 0.0 0.0 )
  (RGB r g b) + (RGB r' g' b') = (RGB (r+r') (g+g') (b+b') )
instance VectorSpace Color where
  Scalar Color = Real
  (*^) s (RGB r g b) = (RGB s*r s*g s*b)
data Hue =  RB Real Real
instance Eq Hue where
  (RB r b) == (RB r' b') = (roughEquals r r') && (roughEquals b b')
(RB r b ) == (RGB r' g' b') = (RB r b) == (RB (r'/g') (b'/g') )
(RGB r g b) == (RB r' b') = (RB (r/g) (b/g) ) == (RB r' b')
data CameraPoint = Point Color Real Real
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
instance Hashable CameraPoint where 
  ????
data WierdPoint = Point Color Real Real Real
data IRLPoint = Point Hue Real Real Real
type Gamma = ([Int],[Int],[Int])
type CameraChar = (Matrix Real, Matrix Real)
getImage :: IO Matrix Color --USE IDENTITY FUNCTION TO GO FROM RGB to Color
getViews :: [Gamma] -> IO [Matrix Color] --DO GAMMA CORRECTION HERE
getGammas :: IO [Gamma]
getCalibrator:: IO [WeirdPoint]
getTrackers:: IO [[IRLPoint]]
getCameraPositions:: IO [CameraChar]
generateGridGraph:: Matrix Color -> UGraph CameraPoint Int

getConnectedComponents::(Hashable v, Eq v, Ord v) => UGraph v e -> [UGraph v e] -- MIGHT NEED TYPE CONSTRAINTS
getConnectedComponents g = 
  if (order g) > 0  then
    let v:vs = verticies g in 
      let oneComponent = bfsVerticies g v in
        let notComponent = vs \\ oneComponent in 
          (removeVerticies notComponent g ):( getConnectedComponents (removeVerticies oneComponent g) )
  else [] --RUNTIME MIGHT BE BAD :(
isRoughBall:: UGraph CameraPoint Int -> Bool 
safetyFactor = 2.0
pi = 3.14159
isRoughBall g =
  let perimeterEstimate = length . filter (<4) . degrees g in
    let areaEstimate = order g in
       areaEstimate*4*pi < perimeterEstimate*perimeterEstimate*safetyFactor 
       -- constants come from circle fact 4*pi*area = circumference^2
isSmoothBall:: UGraph CameraPoint Int -> Bool

mean:: (VectorSpace v, s ~ Scalar v, Fractional s) => [v] -> v
mean xs = (sum xs) / (fromInteger length xs) 
isMonochrome:: UGraph CameraPoint Int -> Bool -- Converts to Hue
isMonochrome g = 
  let colors = map (\(Point c u v) -> c) (verticies g) in
    let (RGB r g b) =  mean colors in
      all (== (RB (r/g) (b/g) ) ) colors
isMonoShaded:: UGraph CameraPoint Int -> Bool -- Doesn't convert to hue
isMonoShaded g = 
  let colors = map (\(Point c u v) -> c) (verticies g) in
    let meanColor = mean colors in 
      all (== meanColor) colors
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
measureTracker:: IO ()
mainProcess:: Matrix Color ->[CameraPoint]
mainProcess = (map mean) . (filter isMonochrome) . (filter isRoughBall) . getConnectedComponents . generateGridGraph
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
