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
            (key) : {
                Sale : {
                   total: value filter ((item, index) -> item."type" ==  "Sale") map ((item, index) -> item.amount) then sum($),
                   sellers: value filter ((item, index) -> item."type" ==  "Sale") map ((item, index) -> {name: item.buyer, amount: item.amount}),
                },
                Purchase : {
                   total: value filter ((item, index) -> item."type" ==  "Purchase") map ((item, index) -> item.amount) then sum($),
                   buyers: value filter ((item, index) -> item."type" ==  "Purchase") map ((item, index) -> {name: item.buyer, amount: item.amount}),
                }
            }
       }
    }) 
    orderBy ((value, key) -> -(value.Sale.total + value.Purchase.total))
    


    
    