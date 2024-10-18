data Pixel =  RGB Byte Byte Byte
data Color = ???
data NamedGraph = Name Color GridGraph
data CameraPoint = Point Real Real
data IRLPoint = Point Real Real Real
GetImage :: IO Matrix Pixel
SplitImage:: (Pixel -> Color) -> Matrix Pixel ->  [NamedGraph]
RoughC:: Pixel -> Color
GammaC:: [Int]-> Pixel -> Color
ContiguousParts:: [NamedGraph] -> [NamedGraph]
IsRoughBall:: GridGraph -> Bool
IsSmoothBall:: GridGraph -> Bool
Center:: GridGraph -> CameraPoint
UPnP:: [CameraPoint] -> [IRLPoint] -> (Matrix Real, Matrix Real)
mPnP:: [[CameraPoint]] -> [IRLPoint] -> [Matrix Real] -> Matrix Real
RayIntersect:: [CameraPoint] -> [Matrix Real] -> IRLPoint
Store
