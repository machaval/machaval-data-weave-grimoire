%dw 2.0
import fail from dw::Runtime
import GET, POST from dw::io::http::Client

import * from dw::io::file::FileSystem
import * from dependencies::Dependencies
output text

type LoginConfig = {
  username?: String,
  password?: String,
  client_id?: String,
  client_secret?: String,
  host?: String,
}

type ParamsType = LoginConfig & {
  asset: String
}

input params : ParamsType


fun login(loginConfig: LoginConfig, baseUrl: String): String = do {
    
    var loginResult = loginConfig  match {
        case basicAuth is { username: String, password: String } -> do{                      
            POST("$(baseUrl)/accounts/login", { body:  { username: basicAuth.username, password: basicAuth.password } })
          }
        case clientSert is { client_id: String, client_secret: String } -> do {
          
          log(POST("$(baseUrl)/accounts/api/v2/oauth2/token", { body:  { client_id: clientSert.client_id, client_secret: clientSert.client_secret, "grant_type": "client_credentials" } }))
        }
        else -> fail("Missing username/password or client_id/client_secret")
      }
    
    ---
    if(loginResult.status == 200)
      loginResult.body.access_token! as String
    else
      fail(loginResult.statusText default "Unable to login")
  }

/**
* Returns all the information of the given asset identifier
 */
fun assetBy(groupId: String, artifactId: String, version: String, token: String, baseUrl: String) =
  GET("$(baseUrl)/exchange/api/v2/assets/$(groupId)/$(artifactId)/$(version)/asset", { headers: { "Authorization": "bearer $(token)" } })
---
params  match {
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

