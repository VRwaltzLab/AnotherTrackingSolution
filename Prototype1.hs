import Graphite
data RawColor =  RawRGB Byte Byte Byte 
instance Eq
data Color = PhotonRGB Real Real Real
instance Eq
data Hue =  RB Real Real
instance Eq
data Pixel = Point RawColor Int Int 
data WeirdPoint = Point Color Int Int
data CameraPoint = Point Hue Real Real
data RawCameraPoint = Point RawColor Real Real
data IRLPoint = Point Hue Real Real Real
type Gamma = ([Int],[Int],[Int])
type CameraChar = (Matrix Real, Matrix Real)
getImage :: IO Matrix RawColor
getViews :: IO [Matrix RawColor]
getGammas :: IO [Gamma]
getCalibrator:: IO [IRLPoint]
getTrackers:: IO [[IRLPoint]]
getCameraPositions:: IO [CameraChar]
generateGridGraph::(Eq c) => Matrix c -> UGraph Pixel Int
gammaColorCorrect:: Gamma -> RawColor -> Color
getConnectedComponents:: UGraph v e -> [UGraph v e] -- MIGHT NEED TYPE CONSTRAINTS
isRoughBall:: UGraph Pixel Int -> Bool
isSmoothBall:: UGraph Pixel Int -> Bool
convertGraph:: Gamma -> UGraph Pixel Int -> UGraph WeirdPoint Int
isMonochrome:: UGraph WeirdPoint Int -> Bool
isRMonochrome:: UGraph Pixel Int -> Bool
grabCenter:: UGraph Pixel Int -> RawCameraPoint
grabCenterAndHue:: UGraph WeirdPoint Int -> CameraPoint
uPnP:: [RawCameraPoint] -> [IRLPoint] -> CameraChar --NEEDS TO DO COLOR SORTING AT START
mPnP:: [CameraChar] -> [[CameraPoint]] -> [IRLPoint] ->  Matrix Real --NEEDS TO DO COLOR SORTING AT START
getRayIntersect:: [CameraPoint] -> [CameraChar] -> IRLPoint --NEEDS TO DO COLOR SORTING AT START
storeCamera:: CameraChar -> IO ()
storeTracker::[IRLPoint] -> IO ()
storePositions:: [Matrix Real] -> IO()
arrangeByTracker:: [[CameraPoint]] -> [[[CameraPoint]]]
findCamera:: IO ()
findCamera = do singleFrame <- getImage
                calibrationPoints <- getCalibrator
                storeCamera (uPnP (map grabCenter(filter isRMonochrome (filter isSmoothBall (getConnectedComponents (generateGridGraph singleFrame) ) ) ) ) calibrationPoints )
measureGamma::IO ()
measureTracker:: IO ()
mainProcess:: (Matrix Color, Gamma) ->[[CameraPoint]]
mainProcess (x, y) = (map GrabCenter (filter (isMonochrome (gammaColorMatch y ) (gammaColorMean y) )  (filter isRoughBall (getConnectedComponents (generateGridGraph x) ) ) ) )
measureTracker = do manyFrames <- getViews
                    curves <- getGammas
                    cameraPositions <- getPositions
                    storeTracker (map (\(x,y) -> RayIntersect x y cameraPositions) (zip curves (map mainProcess (zip manyViews curves) ) ) )
trackAllTrackers::IO ()
trackAllTrackers = do 
                    manyFrames <- getViews
                    curves <-getGammas
                    cameraPositions <-getPositions
                    trackerArrangements <- getTrackers
                    let ptbyTrackerbyCamerabyColor = arrangeByTracker gammaColormatch curve (map mainProcess(zip manyViews curve) ) in 
                      map  (\(x,y) -> mPnP (gammaColormatch curve) cameraPositions x y) (zip trackerArrangements ptbyTrackerbyCamerabyColor)

                      --FUCKING GAMMA CURVES  : (
