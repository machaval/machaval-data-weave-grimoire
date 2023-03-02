%dw 2.0
import * from Types
import fail from dw::Runtime
import * from dw::core::Arrays


var MAX_DEPTH = 5


type STRATEGY = "EAT" | "SAFE" | "ATTACK"

var allMoves = [ "up", "left", "down", "right" ]      

fun init(): InitType = 
  {
    apiversion: "1",
    color: "#468735",
    head: "evil",
    tail: "bolt"
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


fun validBoardMoves(board: BoardType, head: CoordsType, body: Array<CoordsType>, yourName: String): Array<{|move: MovesType, nextLocation: CoordsType|}> = 
  allMoves
    map ((move, index) -> {
          move: move,
          nextLocation: moveTo(move, head)
        })
        // filter ((nextHead, index) -> !(body contains nextHead.nextLocation)) //Remove suicide
    filter ((nextHead, index) -> !outOfBoard(nextHead.nextLocation, board)) //Remove outof board
    filter ((nextHead, index) -> !(board.snakes some ((snake) -> 
              (
                if(snake.name == yourName or (sizeOf(snake.body) > sizeOf(body)))
                snake.body 
              else
                snake.body[1 to -1] //We can remove the head as it is valid to attack the head
                ) //    
                contains nextHead.nextLocation))) //Remove location that heats other snake
    filter ((nextHead, index) -> !(board.hazards contains nextHead.nextLocation )) //Remove location that heats other hazard



fun weightMove(board: BoardType, body: Array<CoordsType>, move: {|move: MovesType, nextLocation: CoordsType|}, maxTreeExploration: Number, yourName: String, depth: Number = 1): Number =              	        
  if(depth <= maxTreeExploration) do {                  
      var nextBody = if(board.food contains move.nextLocation) body else body[0 to -2]
      var allValidMoves = validBoardMoves(board, move.nextLocation, move.nextLocation >> nextBody, yourName)
      var branchWeight = sum(
          allValidMoves 
            map ((move, index) -> weightMove(board, move.nextLocation >> nextBody, { move: move.move, nextLocation: moveTo(move.move, move.nextLocation) }, maxTreeExploration, yourName, depth + 1))
          ) 
      ---
      sizeOf(allValidMoves) * branchWeight
    }
  else 1   

fun eat(boardCenter: {|x: Number, y: Number|}, payload: MoveRequestType, yourName: String, moves: Array<{|move: MovesType, nextLocation: CoordsType|}>) = do {
    var foodOrderByDistance =
      payload.board.food
        filter ((food, index) -> do {
              var myDistance = distance(payload.you.head, food)
              var allSnakesDistance = 
                payload.board.snakes 
                  filter ((snake, index) -> snake.id != payload.you.id)
                  map ((snake, index) -> distance(snake.body[0], food)) 
                  orderBy ((distance, index) -> distance)
              ---
              (allSnakesDistance[0] default 100000000) > myDistance
            })     
        orderBy ((food, index) -> distance(payload.you.head, food))          
    ---
    moves
      filter ((move, index) -> weightMove(payload.board, payload.you.body, move, min([ payload.you.length, MAX_DEPTH ]) default MAX_DEPTH, yourName) > 0)
      map ((nextHead, index) -> do {   
            var target = 
              foodOrderByDistance[0] default 
              boardCenter// Target the middle of the screen
            ---         
            nextHead update {
              case .distance! -> distance(nextHead.nextLocation, target) 
            }     
          })
      orderBy ((nextHead, index) -> nextHead.distance)             
  }     

 
fun safe(payload: MoveRequestType, smartMoves: Array<{|move: MovesType,nextLocation: CoordsType|}>, yourName: String) = do {                    
    smartMoves 
      filter ((item, index) -> !(payload.board.food contains item.nextLocation )) //Try to avoid food to continur growing
      map ((move, index) -> { w: weightMove(payload.board, payload.you.body, move, min([ payload.you.length, MAX_DEPTH ]) default MAX_DEPTH, yourName), m: move }) //Order by to the one that at the next option gives me more options
      filter ((item, index) -> item.w != 0)
      orderBy ((item, index) -> -item.w)
      map ((item, index) -> item.m)
  }       


fun move(payload: MoveRequestType): MoveType = do {     
    var body = payload.you.body
    var board = payload.board
    var head = body[0] // First body part is always head
    var neck = body[1] // Second body part is always neck  
    var tail = body[-1]
    var reverseHeadlessbody = body[-1 to 1]
    var strategy: STRATEGY = 
      if(sizeOf(payload.board.snakes) == 1 and payload.you.health > 20) //If it is only me then play safe        
        "SAFE"
      else do {
        if(
          payload.board.snakes 
            some 
              ((s) -> (s.name != payload.you.name) and sizeOf(s.body) >= (sizeOf(payload.you.body) - 2))
          ) //If there is a snake that is bigger lets go to eat
          "EAT"  
        else 
          "ATTACK"
      } //If there are snakes let's go to
        
        
    var l = log(strategy)    

    var boardCenter = { x: floor(payload.board.width / 2), y: floor(payload.board.height / 2) } 
    var centerOfGravity = body 
        reduce ((item, accumulator = {x:0, y: 0}) -> { x: item.x + accumulator.x, y: item.y + accumulator.y })
        then 
          ((result) -> {
              x: result.x / sizeOf(body),
              y: result.y / sizeOf(body)
            })
  
      
    var basicMoves = validBoardMoves(board, head, body, payload.you.name)  //All valid moves without basic kill
           
    var basicMovesOptimizeForDistribution =       
      basicMoves
        orderBy ((move, index) -> - distance(move.nextLocation, centerOfGravity)) //Optimize for the move that moves away from our center of gravity 
  
    var nextMove = 
      if("EAT" == strategy) 
        eat(boardCenter, payload, payload.you.name, basicMoves)
      else if("SAFE" == strategy) 
        safe(payload, basicMovesOptimizeForDistribution, payload.you.name)
      else do {
        basicMoves              
      }
              
    var finalMove = nextMove[0].move        
    ---
    if(finalMove == null) do {
        var a = log("Unable to find a smart move")
        ---
        {
          move: basicMovesOptimizeForDistribution[0].move default "down",
          shout: basicMovesOptimizeForDistribution[0].move default "down"
        }    
      }
    else
      {
        move: finalMove,
        shout: finalMove
      }    
  }

fun start(moveReques: StartRequestType): Any = null

fun end(moveReques: EndRequestType): Any = null
  