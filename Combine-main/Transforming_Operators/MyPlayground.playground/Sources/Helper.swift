import Foundation


public func example(of description:String,action: () -> Void){
    print("\n——— Example of:", description, "———")
    action()
}

public struct Coordinate {
  public let x: Int
  public let y: Int
  
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
}

public func quadrantOf(x: Int, y: Int) -> String {
  var quadrant = ""
  
  switch (x, y) {
  case (1..., 1...):
    quadrant = "1"
  case (..<0, 1...):
    quadrant = "2"
  case (..<0, ..<0):
    quadrant = "3"
  case (1..., ..<0):
    quadrant = "4"
  default:
    quadrant = "boundary"
  }
  
  return quadrant
}
