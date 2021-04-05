%dw 2.0
input payload application/json
output json
---
payload 
    reduce ((result, accumulator = {valid: 0, invalid: 0}) -> 
                accumulator update {
                    case .valid if(result.success) -> $ + 1
                    case .invalid if(!result.success) -> $ + 1
                }
           )