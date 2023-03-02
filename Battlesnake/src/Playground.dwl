%dw 2.0

import MoveRequestType from Types
import move, MoveRequestType from BattleSnake

input payload: MoveRequestType application/json


output application/json
---
move(payload)
