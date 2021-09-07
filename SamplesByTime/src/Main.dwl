%dw 2.0
input payload application/csv escape='"', streaming=true
import * from dw::core::Strings
import * from dw::Runtime
import * from dw::io::file::FileSystem

var logPrefix = '[SAMPLING]'


fun extensionOf(mimeType: String): String = 
    (entriesOf(FILE_EXTENSIONS) 
        filter ((entry) -> entry.value == mimeType))[0].key as String default ".json"

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

fun time(timestamp) = 
    timestamp as DateTime as String {format: "yyy-MM-dd'T'hh:mm"}

output json 
---
payload.'_raw'
    map ((logEntry) -> read(logEntry, 'json').log) 
    filter ((logEntry) -> logEntry is Object and (logEntry.message startsWith logPrefix))
    map ((logEntry) -> {timestamp: logEntry.timestamp, args: read(trim(logEntry.message substringAfter '-'), "application/dw", {onlyData:true})[1]}) 
    map ((logEntry, index) -> do {                
        var exceptionLocation = path(path(wd(), "samplesByTime"), "$(logEntry.timestamp)")
        var requestPath = path(exceptionLocation, "request.json")
        var transformPath = path(exceptionLocation, "transform.dwl")
        var testInput = write(logEntry.args, "application/json") copyTo  requestPath
        var transform = write(logEntry.args.fs."/main.dwl", "text/plain") copyTo  transformPath
        var allInputs = logEntry.args.inputs pluck ((inputValue, key, index) -> do {
            var outputFile = path(path(exceptionLocation, "inputs"), key as String ++ extensionOf(inputValue.mimeType))
            var scenarios = (if(inputValue.kind == "binary") inputValue.value as Binary {base: "64"} else inputValue.value as Binary {encoding: "UTF-8"})  copyTo outputFile            
            ---
            "DONE"
        }) reduce ((a) -> a)
        ---
        "Created: $(exceptionLocation)"        
    })
       
   
    


