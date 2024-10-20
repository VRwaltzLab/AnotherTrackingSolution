import Graphite
data Color =  RGB Byte Byte Byte
data Pixel = Point Color Int Int
data CameraPoint = Point Color Real Real
data IRLPoint = Point Color Real Real Real
type Gamma = ([Int],[Int],[Int])
type NamedGraph = UGraph Pixel Int
type CameraChar = (Matrix Real, Matrix Real)
type ColorMatcher = Color -> Color -> Bool
type ColorStat = [Color] -> Color
getImage :: IO Matrix Color
getViews :: IO [Matrix Color]
getGammas :: IO [Gamma]
getCalibrator:: IO [IRLPoint]
getTrackers:: IO [[IRLPoint]]
getCameraPositions:: IO [CameraChar]
generateGridGraph:: ColorMatcher -> Matrix Color -> NamedGraph
roughColorMatch:: ColorMatcher-- Be careful this doesn't work as an equality measure (non transitive)
gammaColorMatch:: Gamma -> ColorMatcher
roughColorMean:: ColorStat
gammaColorMean:: Gamma -> ColorStat
getConnectedComponents:: UGraph v e -> [UGraph v e] -- MIGHT NEED TYPE CONSTRAINTS
isRoughBall:: NamedGraph -> Bool
isSmoothBall:: NamedGraph -> Bool
isMonochrome:: ColorMatcher -> ColorStat -> NamedGraph -> Bool
grabCenter:: NamedGraph -> CameraPoint
uPnP:: ColorMatcher -> [CameraPoint] -> [IRLPoint] -> CameraChar --NEEDS TO DO COLOR SORTING AT START
mPnP:: ColorMatcher -> [CameraChar] -> [[CameraPoint]] -> [IRLPoint] ->  Matrix Real --NEEDS TO DO COLOR SORTING AT START
getRayIntersect:: ColorMatcher -> [CameraPoint] -> [CameraChar] -> IRLPoint --NEEDS TO DO COLOR SORTING AT START
storeCamera:: CameraChar -> IO ()
storeTracker::[IRLPoint] -> IO ()
storePositions:: [Matrix Real] -> IO()
arrangeByTracker:: ColorMatcher -> [[CameraPoint]] -> [[[CameraPoint]]]
findCamera:: IO ()
findCamera = do singleFrame <- getImage
                calibrationPoints <- getCalibrator
                storeCamera (uPnP roughColorMatch (map grabCenter (filter (isMonochrome roughColorMatch roughColorMean) (filter isSmoothBall (getConnectedComponents (generateGridGraph roughColorMatch singleFrame) ) ) ) ) calibrationPoints )
measureGamma::IO ()
measureTracker:: IO ()
mainProcess::[Matrix Colorl]-> Gamma ->[[CameraPoint]]
mainProcess x y = map (map GrabCenter) . (filter (isMonochrome (gammaColorMatch y ) (gammaColorMean y) ) ) . (filter isRoughBall). getConnectedComponents .(generateGridGraph (gammaColorMatch y) ) x
measureTracker = do manyFrames <- getViews
                    curves <- getGammas
                    cameraPositions <- GetPositions
                    storeTracker (map (\x -> RayIntersect x cameraPositions)  (mainProcess manyViews curves)  )
trackAllTrackers::IO ()
trackAllTrackers = do 
                    manyFrames <- GetViews
                    curve <-GetGamma
                    cameraPositions <-GetPositions
                    trackerArrangements <- GetTrackers
                    let ptbyTrackerbyCamerabyColor = arrangeByTracker (gammaColormatch curve) (MainProcess manyViews curve) in 
                      map  (\(x,y) -> mPnP (gammaColormatch curve) cameraPositions x y) (zip trackerArrangements ptbyTrackerbyCamerabyColor)
