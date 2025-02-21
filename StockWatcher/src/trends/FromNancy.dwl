import * from Stocks
input stocks: {data: Array<Data>, hdata: Array<HData> } application/json
input params:InputParams

var family = dataToTransactions(stocks.data)
var politic = hdataToTransactions(stocks.hdata)
---
(family ++ politic)    
    filter 
        (((now() as Date) - ($.transactionDate as Date)  ).days < dateRange(params))
    filter ((item, index) -> item.buyer contains  "Pelosi")            
    groupBy $."type"       
    orderBy ((value, key) -> value.amount)