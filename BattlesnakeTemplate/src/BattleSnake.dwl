%dw 2.0
import fail from dw::Runtime
import * from dw::core::Arrays

type CoordsType = 
{
  x: Number,
  y: Number
}

type SnakeType = {
  id: String,
  name: String,
  health: Number,
  body: Array<CoordsType>,
  latency: String,
  head: CoordsType,
  length: Number,
  shout: String,
  squad: String,
  customizations: {
      color: String,
      head: String,
      tail: String
    }
}

type GameType = {
  id: String,
  ruleset: {
      name: String,
      version: String,
      settings: {
          foodSpawnChance: Number,
          minimumFood: Number,
          hazardDamagePerTurn: Number,
          royale: {
              shrinkEveryNTurns: Number 
            },
          squad: {
              allowBodyCollisions: Boolean,
              sharedElimination: Boolean,
              sharedHealth: Boolean,
              sharedLength: Boolean
            }
        }
    },
  map: String,
  source: String,
  timeout: Number
}

type BoardType = {
  height: Number,
  width: Number,
  food: Array<CoordsType>,
  hazards: Array<CoordsType>,
  snakes: Array<SnakeType>
}    

type MoveRequestType = 
{
  game: GameType,
  turn: Number,
  board: BoardType,
  you: SnakeType
}

type StartRequestType = MoveRequestType

type EndRequestType = MoveRequestType


type MovesType = "up" | "down" | "left" | "right"

type MoveType = {
  move: MovesType,
  shout?: String
}

type InitType = {
  "apiversion": "1",
  "author"?: String,
  "color"?: String,
  "head"?: "default" | "beluga" | "bendr" | "dead" | "evil" | "fang" | "pixel" | "safe" | "sand-worm" | "shades"| "silly"| "smile" | "tongue" ,
  "tail"?: "default" | "curled" | "bolt"| "curled"| "fat-rattle"| "freckled"| "hook" | "sharp"| "skinny" | "small-rattle",
  "version"?: String
}

var allMoves = [ "up", "down", "left", "right" ] 


fun init(): InitType = 
  {
    apiversion: "1",
    color: "#cccccc",
    head: "default",
    tail: "default"
  } 


fun neckLocation(head: CoordsType, neck: CoordsType): MovesType = 
  neck match {
   	case neck if neck.x < head.x -> "left" //my neck is on the left of my head
   	case neck if neck.x > head.x -> "right" //my neck is on the right of my head
   	case neck if neck.y < head.y -> "down" //my neck is below my head
   	case neck if neck.y > head.y -> "up"	//my neck is above my head
   	else -> fail("Unable to detect neck location")
  }


fun moveTo(movement: MovesType, location: CoordsType): CoordsType = 
  movement  match {
    case is "up" -> 
      location update {
        case .y -> $ + 1
      }
    case is "down" -> 
      location update {
        case .y -> $ - 1
      }
    case is "left" -> 
      location update {
        case .x -> $ - 1
      }
    case is "right" -> 
      location update {
        case .x -> $ + 1
      }
  }

fun outOfBoard(location: CoordsType, board: BoardType): Boolean = 
  location.x < 0 or location.x >= board.width or location.y < 0 or location.y >= board.height


fun distance(left: CoordsType, right: CoordsType): Number =
  abs(left.x - right.x) + abs(left.y - right.y)  

fun move(payload: MoveRequestType): MoveType = do {       
    {
      move: "up",
      shout: "I'm going UP Baby!"
    }    
   
  }

fun start(moveReques: StartRequestType): Any = null

fun end(moveReques: EndRequestType): Any = null
  