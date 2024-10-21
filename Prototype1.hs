import Graphite
roughEquals:: Real -> Real -> Bool
roughEquals a b = a*1.05 > b && b*1.05 > a
data Color = RGB Real Real Real --SOMETIMES USES PHOTON AND SOMETIMES USES Computer Numbers
instance Eq Color where
  (RGB r g b) == (RGB a d c) = (roughEquals r a) && (roughEquals g d) && (roughEquals b c)
data Hue =  RB Real Real
instance Eq Color where
  (RB r b) == (RB a c) = (roughEquals r a) && (roughEquals b c)
data CameraPoint = Point Color Real Real
instance AdditiveGroup CameraPoint where
  zeroV = (Point (RGB 0.0 0.0 0.0) 0.0 0.0 )
  (Point (RGB r g b) u v ) + (Point (RGB r' g' b') u' v') = (Point (RGB (r + r') (g + g') (b + b') ) (u + u') (v + v') )
instance VectorSpace CameraPoint where
  Scalar CameraPoint = Real
  (*^) s (Point (RGB r g b) u v)  = (Point (RGB r*s g*s b*s) u*s v*s)
data WierdPoint = Point Color Real Real Real
data IRLPoint = Point Hue Real Real Real
type Gamma = ([Int],[Int],[Int])
type CameraChar = (Matrix Real, Matrix Real)
getImage :: IO Matrix Color --USE IDENTITY FUNCTION TO GO FROM RGB to Color
getViews :: [Gamma] -> IO [Matrix RawColor] --DO GAMMA CORRECTION HERE
getGammas :: IO [Gamma]
getCalibrator:: IO [WeirdPoint]
getTrackers:: IO [[IRLPoint]]
getCameraPositions:: IO [CameraChar]
generateGridGraph:: Matrix Color -> UGraph CameraPoint Int
getConnectedComponents:: UGraph v e -> [UGraph v e] -- MIGHT NEED TYPE CONSTRAINTS
isRoughBall:: UGraph CameraPoint Int -> Bool
isSmoothBall:: UGraph CameraPoint Int -> Bool
isMonochrome:: UGraph CameraPoint Int -> Bool -- Converts to Hue
isMonoShaded:: UGraph CameraPoint Int -> Bool -- Doesn't convert to hue
mean:: (VectorSpace v, s ~ Scalar v, Fractional s) => [v] -> v
uPnP:: [CameraPoint] -> [WierdPoint] -> CameraChar --NEEDS TO DO COLOR SORTING AT START
mPnP:: [CameraChar] -> [[CameraPoint]] -> [IRLPoint] ->  Matrix Real --NEEDS TO DO COLOR SORTING AT START
getRayIntersect:: [[CameraPoint]] -> [CameraChar] -> IRLPoint --NEEDS TO DO COLOR SORTING AT START
storeCamera:: CameraChar -> IO ()
storeTracker::[IRLPoint] -> IO ()
storePositions:: [Matrix Real] -> IO()
arrangeByTracker:: [[CameraPoint]] -> [[[CameraPoint]]]
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
                    let ptbyTrackerbyCamerabyColor = arrangeByTracker (map mainProcess manyViews) in 
                    storePositions (map (\(x,y) -> mPnP cameraPositions x y) (zip ptbyTrackerbyCamerabyColor trackerArrangements) )
