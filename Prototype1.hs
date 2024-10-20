data Pixel =  RGB Byte Byte Byte
data Color = ???
data NamedGraph = Name Color GridGraph
data CameraPoint = Point Color Real Real
data IRLPoint = Point Color Real Real Real
GetImage :: IO Matrix Pixel
GetViews :: IO [Matrix Pixel]
SplitImage:: (Pixel -> Color) -> Matrix Pixel ->  [NamedGraph]
RoughC:: Pixel -> Color
GammaC:: [Int]-> Pixel -> Color
GetGamma :: IO [Int]
ContiguousParts:: [NamedGraph] -> [NamedGraph]
IsRoughBall:: NamedGraph -> Bool
IsSmoothBall:: NamedGraph -> Bool
GrabCenter:: NamedGraph -> CameraPoint
UPnP:: [CameraPoint] -> [IRLPoint] -> (Matrix Real, Matrix Real)
mPnP:: [(Matrix Real, Matrix Real)] -> [[CameraPoint]] -> [IRLPoint] ->  Matrix Real
RayIntersect:: [CameraPoint] -> [(Matrix Real, Matrix Real)] -> IRLPoint
StoreCamera:: (Matrix Real,Matrix Real) -> IO ()
StoreTracker::[IRLPoint] -> IO ()
StorePositions:: [Matrix Real] -> IO()
GetCalibrator:: IO [IRLPoint]
GetTrackers:: IO [[IRLPoint]]
ColorSort:: [[CameraPoint]] -> [[CameraPoint]]
ColorArrange::[[CameraPoint]] ->[[[CameraPoint]]]
GetPositions:: IO [(Matrix Real, Matrix Real)]
FindCamera:: IO ()
FindCamera = do singleFrame <- GetImage
                calibrationFormat <- GetCalibrator
                StoreCamera (UPnP (map GrabCenter (filter IsSmoothBall (ContiguousParts (SplitImage RoughC singleFrame) ) ) ) calibrationFormat )
MeasureGamma::IO ()
MeasureTracker:: IO ()
MainProcess::[Matrix Pixel]-> [Int] ->[[CameraPoint]]
MainProcess x y = map (map GrabCenter) . (filter IsRoughBall). ContiguousParts .(SplitImage (GammaC y) ) x
MeasureTracker = do manyFrames <- GetViews
                    curve <- GetGamma
                    cameraPositions <- GetPositions
                    StoreTracker (map (\x -> RayIntersect x cameraPositions) (ColorSort (MainProcess manyViews curve) ) )
TrackAllTrackers::IO ()
TrackAllTrackers = do 
                    manyFrames <- GetViews
                    curve <-GetGamma
                    cameraPositions <-GetPositions
                    trackerArrangements <- GetTrackers
                    let ptbyTrackerbyCamerabyColor = ColorArrange (MainProcess manyViews curve) in 
                      map  (\(x,y) -> mPnP cameraPositions x y) (zip trackerArrangements ptbyTrackerbyCamerabyColor)
