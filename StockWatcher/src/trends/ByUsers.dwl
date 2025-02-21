import * from Stocks
input stocks: {data: Array<Data>, hdata: Array<HData> } application/json
input params:InputParams

var family = dataToTransactions(stocks.data)
var politic = hdataToTransactions(stocks.hdata)
---
(family ++ politic)    
    filter 
        (((now() as Date) - ($.transactionDate as Date)  ).days < dateRange(params))        
    groupBy $.symbol       
    mapObject ((value, key, index) -> do {
       {
            (key) :   value groupBy ((item, index) -> item.buyer)
                            mapObject ((value, key, index) -> 
                            {
                                (key): value groupBy ((item, index) -> item."type")
                            })                                        
            
       }
    }) 
    orderBy ((value, key) -> -sizeOf(value))
    


    
    