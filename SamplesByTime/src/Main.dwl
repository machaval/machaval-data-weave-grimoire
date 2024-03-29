%dw 2.0
input payload application/csv escape='"', streaming=true
import * from dw::core::Strings
import * from dw::Runtime
import * from dw::io::file::FileSystem

var logPrefix = /\[(SAMPLING|SHUTDOWN)\](.|\n)*/


fun extensionOf(mimeType: String): String =
    (entriesOf(FILE_EXTENSIONS)
        filter ((entry) -> entry.value == mimeType))[0].key as String default ".json"

output json
---
payload
    filter ((logEntry) -> logEntry.logMessage matches logPrefix)
    map ((logEntry) -> {timestamp: logEntry.'_time', args: read(trim(logEntry.logMessage substringAfter '-'), "application/dw", {onlyData:true})[1]})
    map ((logEntry, index) -> do {
        var exceptionLocation = path(path(wd(), "samplesByTime"), "$(logEntry.timestamp)_$(index)")
        var requestPath = path(exceptionLocation, "request.json")
        var transformPath = path(exceptionLocation, "transform.dwl")
        var testInput = write(logEntry.args, "application/json") copyTo  requestPath
        var transform = write(logEntry.args.fs."/main.dwl", "text/plain") copyTo  transformPath
        var allInputs = logEntry.args.inputs pluck ((inputValue, key, index) -> do {
            var outputFile = path(path(exceptionLocation, "inputs"), key as String ++ extensionOf(inputValue.mimeType))
            var scenarios = (if(log(inputValue).kind == "binary" and inputValue.mimeType != "application/xlsx") inputValue.value as Binary {base: "64"} else inputValue.value as Binary {encoding: "UTF-8"})  copyTo outputFile
            ---
            "DONE"
        }) reduce ((a) -> a)
        ---
        "Created: $(exceptionLocation)"
    })
