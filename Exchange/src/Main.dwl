%dw 2.0
import fail from dw::Runtime
import GET, POST from dw::io::http::Client

import * from dw::io::file::FileSystem
import * from dependencies::Dependencies
import * from Exchange

input params : ParamsType

output json
---
params match {
  case is ParamsType -> do {
      var baseUrl = params.host default "https://anypoint.mulesoft.com/"
      var dependency = params.asset splitBy "/"
      var groupId = dependency[0]
      var artifactId = dependency[1]    
      
      var targetFolder = wd()
      var token = login(params, baseUrl)
      var assetsResult = listAsset(groupId, artifactId, token, baseUrl)
      ---
      assetsResult
    }

  
  else -> fail("Invalid parameters: $(write(params) as String)")
}