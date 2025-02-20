%dw 2.5

import * from dependencies::Dependencies
import GET, POST from dw::io::http::Client
import fail from dw::Runtime
import * from dw::io::file::FileSystem

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

fun login(loginConfig: LoginConfig, baseUrl: String): String = do {
    
    var loginResult = loginConfig  match {
        case basicAuth is { username: String, password: String } -> do{                      
            POST("$(baseUrl)/accounts/login", { body:  { username: basicAuth.username, password: basicAuth.password } })
          }
        case clientSert is { client_id: String, client_secret: String } -> do {        
          POST("$(baseUrl)/accounts/api/v2/oauth2/token", { body:  { client_id: clientSert.client_id, client_secret: clientSert.client_secret, "grant_type": "client_credentials" } })
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

fun listAsset(groupId: String, artifactId: String, token: String, baseUrl: String) = 
  GET("$(baseUrl)/exchange/api/v2/assets/$(groupId)/$(artifactId)/asset", { headers: { "Authorization": "bearer $(token)" } })