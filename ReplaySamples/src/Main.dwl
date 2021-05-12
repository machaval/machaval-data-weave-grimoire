%dw 2.0
output application/json

import * from dw::Runtime
import dw::core::Binaries
import * from dw::io::file::FileSystem



fun decodeInputs(inputs) =
  inputs mapObject ((value, key, index) ->
      (key): value  update {
              case content at .value -> if(value.kind == "binary") Binaries::fromBase64(content) else content as Binary {encoding: "UTF-8"}
              case encoding at .encoding! if(value.kind == "text") -> "UTF-8"
      })


fun runMapping(in0) = 
    run(
            in0.main,
            in0.fs,
            decodeInputs(in0.inputs), {},
            {timeOut: 5000 , securityManager: (grant, args) -> false, maxStackSize: 10}
        ) then {
                "kind": $.kind,
                "success": $.success,
            }      

---
ls(path(wd(), "samplesByTime")) 
        map ((folder, index) -> do {
            var request = read(contentOf(path(folder, "request.json")), "application/json")
            var l =  log("Processing $(nameOf(folder))" )
            ---
            try(() -> runMapping(request) )
        })