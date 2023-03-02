%dw 2.0
import * from BattleSnake
import * from dw::io::http::Server
var config = { port: 8282, host: "localhost" }

---
api(config, 
  {
    "/": {
        GET: (request) -> do {                    
              {
                body: init()
              }
            }
      },
    "/start": {
        POST: (request) -> 
            {
              body: start(request.body)
            }
      },
    "/end": {
        POST: (request) -> 
            {
              body: end(request.body)
            }
      },
    "/move": {
        POST: (request) -> 
            {
              body: move(request.body)
            }
      }
  })
