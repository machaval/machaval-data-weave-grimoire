%dw 2.0
import * from dw::io::http::Client
var body = GET("https://www.insiderfinance.io/congress-trades").body as String
var json_start = '<script id="__NEXT_DATA__" type="application/json">'
var bought = do {
    var startIndex = body indexOf json_start
    var json = body[startIndex + sizeOf(json_start) to -(sizeOf("</script></body></html>")+1)]
    ---
    read(json, "json")
}

---
bought.props.pageProps