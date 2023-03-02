%dw 2.0

import move, MoveRequestType from BattleSnake

input payload: MoveRequestType application/json
output application/json
---
move(payload)
