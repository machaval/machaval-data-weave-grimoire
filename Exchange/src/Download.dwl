%dw 2.0
import fail from dw::Runtime
import GET, POST from dw::io::http::Client

import * from dw::io::file::FileSystem
import * from dependencies::Dependencies
import * from Exchange

input params : ParamsType

output text
---
params match {
  case is ParamsType -> do {
      var baseUrl = params.host default "https://anypoint.mulesoft.com/"
      var dependency = params.asset splitBy "/"
      var groupId = dependency[0]
      var artifactId = dependency[1]
      var version = dependency[2]
      
      var targetFolder = wd()
      var token = login(params, baseUrl)
      var assetsResult = assetBy(groupId, artifactId, version, token, baseUrl)

      ---
      if(assetsResult.status == 200)
        assetsResult.body.files!
          map ((f) -> do {
                var fileName: String = (assetsResult.body.assetId default "") ++ "-" ++ (f.classifier default "default") ++ "." ++ (f.packaging default "" )
                var filePath: String = assetFolder(targetFolder, groupId, artifactId, version) path fileName
                var copy = GET(f.externalLink).body as Binary { encoding: "UTF-8" } copyTo filePath
                ---
                fileName
              })
          joinBy "\n"
      else
        fail("Fail to obtain artifact `$(groupId):$(artifactId):$(version)`. Reason" ++ (assetsResult.statusText default ""))
    }

  
  else -> fail("Invalid parameters: $(write(params) as String)")
}

