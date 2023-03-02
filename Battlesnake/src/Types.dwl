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