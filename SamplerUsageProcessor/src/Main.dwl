%dw 2.0
input payload application/json streaming=true
import * from dw::Runtime
output json
---
payload 
    filter ((item, index) -> do {
        var mainName = item.script.main
        var scriptContent = item.script.fs[mainName]!
        ---
        item.success and !(scriptContent contains  "payload.message") //Filter invalid and default scripts
    })
    map ((item, index) -> do {     
        var mainName = item.script.main
        var scriptContent = item.script.fs[mainName]!
        ---           
        {
           imports: item.ast..[?($ is Object and $.class == "ImportDirective")].children map $[0].children[0].value default [],
           out: item.ast..[?($ is Object and $.class == "OutputDirective")].children[0].value[0] default "none",
           functions: item.ast..[?($ is Object and $.class == "FunctionCallNode")] map ($.children[0]..value[0] default "Unknown") default [],
           customFunctions: (item.ast..[?($ is Object and $.class == "FunctionDirectiveNode")] map ($.children[0]..value[0] default "Unknown")) default [],
           inputSize: (try(() -> sizeOf(item.script.inputs.payload.value as Binary {base: "64"})) 
                        orElseTry (() -> sizeOf(item.script.inputs.payload.value)))
                        .result default 0,
           scriptSize: sizeOf(scriptContent)
        }
      }
    )
    reduce ((result, accumulator = {imports: {}, out: {}, functions: {}, customFunctions: {}, count: 0, inputSize: 0, scriptSize: 0}) -> 
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
                    case .count -> $ + 1
                    case .inputSize -> $ + result.inputSize
                    case .scriptSize -> $ + result.scriptSize
                }
           )
    mapObject ((value, key, index) -> {(key): if(value is Object) value orderBy ((value, key) -> value) else value}) 