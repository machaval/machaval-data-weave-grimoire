%dw 2.0
input payload application/csv escape='"', streaming=true
import * from dw::core::Strings
import * from dw::Runtime

var logPrefix = 'buildTransformResponse -'

fun parseScript(script) = do {
    var mainName = script.main
    var scriptContent = script.fs[mainName]!
    ---
    try(() -> (read(scriptContent, "application/dw", {astMode: true}))) 
        then ((result) -> {
            success: result.success,
            ast: result.result,
            script: script
        })
}

output json 
---
payload.'_raw'
    map ((logEntry) -> read(logEntry, 'json').log) 
    filter ((logEntry) -> logEntry is Object and (logEntry.message startsWith logPrefix))
    map ((logEntry) -> read(trim(logEntry.message substringAfter logPrefix), "application/dw", {onlyData:true}))
    map ((scriptExecution) -> parseScript(scriptExecution[0]))
   
    


