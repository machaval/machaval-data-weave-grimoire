%dw 2.0
import POST from dw::io::http::Client
var statistics: Array<{statisticName: String, value: Number}> = 
  POST('https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery', 
    {
      body: {
          "assetTypes": [
              "Microsoft.VisualStudio.Services.Icons.Default",
              "Microsoft.VisualStudio.Services.Icons.Branding",
              "Microsoft.VisualStudio.Services.Icons.Small"
            ],  
          "filters": [
              {
                "criteria": [
                    {
                      "filterType": 8,  
                      "value": "Microsoft.VisualStudio.Code"
                    },
                    {
                      "filterType": 10,  
                      "value": "DataWeave"
                    },
                    {
                      "filterType": 12,  
                      "value": "37888"
                    }
                  ],  
                "direction": 2,
                "pageSize": 54,  
                "pageNumber": 1,
                "sortBy": 0,  
                "sortOrder": 0,
                "pagingToken": null
              }
            ],
          "flags": 870
        }
                }).body.results[0].extensions[0].statistics as  Array<{statisticName: String, value: Number}>
  ---

{
  (statistics map ((item, index) -> {
    (item.statisticName): item.value
  }) )
}