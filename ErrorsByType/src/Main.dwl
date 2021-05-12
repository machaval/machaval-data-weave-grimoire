
    
%dw 2.0


input payload application/csv escape='"', streaming=true

import * from dw::core::Strings
import * from dw::Runtime
import * from dw::io::file::FileSystem

fun extensionOf(mimeType: String): String = 
    (entriesOf(FILE_EXTENSIONS) 
        filter ((entry) -> entry.value == mimeType))[0].key as String default ".json"

        


var logPrefix = '[ERROR]'

output json 
---
payload."_raw"
    map ((logEntry) -> try(() -> read(logEntry, 'json')).result.log)
    filter ((logEntry) -> logEntry is Object and (logEntry.message startsWith logPrefix))
    map ((logEntry) -> {timestamp: logEntry.timestamp, value: read(trim(logEntry.message substringAfter "-"), "application/dw", {onlyData:true})})
    // filter ((logEntry) -> isBlank(f) or (logEntry.value.result.error.message contains criteria))
    map ((logEntry, index) -> {timestamp: logEntry.timestamp, error: logEntry.value.result.error.message, args: logEntry.value.args[0]})
    map ((logEntry, index) -> do {        
        
        var exceptionLocation = path(path(path(wd(), "errorsByType"), trim(logEntry.error substringBefore " ")),"$(logEntry.timestamp)")
        var requestPath = path(exceptionLocation, "request.json")
        var transformPath = path(exceptionLocation, "transform.dwl")
        var testInput = write(logEntry.args, "application/json") copyTo  requestPath
        var transform = write(logEntry.args.fs."/main.dwl", "text/plain") copyTo  transformPath
        var allInputs = logEntry.args.inputs pluck ((inputValue, key, index) -> do {
            var outputFile = path(path(exceptionLocation, "inputs"), key as String ++ extensionOf(inputValue.mimeType))
            var scenarios = (if(inputValue.kind == "binary") inputValue.value as Binary {base: "64"} else inputValue.value as Binary {encoding: "UTF-8"}) copyTo outputFile            
            ---
            "DONE"
        }) reduce ((a) -> a)
        ---
        "Created: $(exceptionLocation)"        
    })
   
   
    




