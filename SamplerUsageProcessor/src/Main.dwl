%dw 2.0
input payload application/json streaming=true
output json
---
payload 
    filter ((item, index) -> item.success)
    map ((item, index) -> do {                
        {
           imports: item.ast..[?($ is Object and $.class == "ImportDirective")].children map $[0].children[0].value default [],
           out: item.ast..[?($ is Object and $.class == "OutputDirective")].children[0].value[0] default "none",
           functions: item.ast..[?($ is Object and $.class == "FunctionCallNode")] map ($.children[0]..value[0] default "Unknown") default [],
           customFunctions: (item.ast..[?($ is Object and $.class == "FunctionDirectiveNode")] map ($.children[0]..value[0] default "Unknown")) default []
        }
      }
    )
    reduce ((result, accumulator = {imports: {}, out: {}, functions: {}, customFunctions: {}}) -> 
                accumulator update {
                    case imported at .imports -> do {
                        result.imports reduce ((name, acc = imported) -> 
                                acc update {
                                    case ."$(name)"! -> ($ default 0) + 1
                                }
                        )
                    }
                    case .out."$(result.out)"!  -> ($ default 0) + 1
                    case functions at .functions  -> do {
                        result.functions reduce ((name, acc = functions) -> 
                                acc update {
                                    case ."$(name)"! -> ($ default 0) + 1
                                }
                        )
                    }
                    case customFunctions at .customFunctions -> do {
                        result.customFunctions reduce ((name, acc = customFunctions) -> 
                                acc update {
                                    case ."$(name)"! -> ($ default 0) + 1
                                }
                        )
                    }
                }
           )
    mapObject ((value, key, index) -> {(key): value orderBy ((value, key) -> value)}) 