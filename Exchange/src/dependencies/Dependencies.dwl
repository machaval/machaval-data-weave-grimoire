import * from dw::io::file::FileSystem

type DependencyType = String

/**
* Calculates the folder for a given asset
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `targetFolder` | String | The base folder
* | `groupId` | String | The groupId of the asset
* | `artifactId` | String | The artifactId of the asset
* | `version` | String | The version of the asset
* |===
*
* === Example
*
* This example shows how the `assetFolder` function behaves under different inputs.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* assetFolder(wd(),"org.acme","test","1.1.1")
*
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* "/home/machaval/project/.dwl/dependencies/org.acme/test/1.1.1"
* ----
**/
fun assetFolder(targetFolder: String, groupId: String, artifactId: String, version: String) =
    targetFolder path groupId path artifactId path version