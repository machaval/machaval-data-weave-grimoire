%dw 2.6
type InputParams = {action: String, days?: String}
type Data = {
    "firstName": String,
    "lastName": String,
    "office": String,
    "link": String,
    "dateRecieved": String,
    "transactionDate": String,
    "owner": String,
    "assetDescription": String,
    "assetType": String,
    "type": String,
    "amount": String,
    "comment": String,
    "symbol": String,
    "party": String
}

type HData = {
    "disclosureYear": String,
    "disclosureDate": String,
    "transactionDate": String,
    "owner": String,
    "ticker": String,
    "assetDescription": String,
    "type": "Sale" | "Purchase",
    "amount": String,
    "representative": String,
    "district": String,
    "link": String,
    "capitalGainsOver200USD": String,
    "party": String
}

type Transaction = { 
    "type": "Sale" | "Purchase", 
    amount: Number, 
    transactionDate: String, 
    symbol: String, 
    buyer: String, 
    link: String 
}


fun dateRange(params: InputParams): Number = 
 (params.days default 45) as Number

fun dataToTransactions(data: Array<Data>): Array<Transaction> = do {
        data map ((item, index) -> {
                        'type': if(item."type" contains "Sale") "Sale" else "Purchase",
                        'amount': item.amount splitBy "-" then trim($[1])[1 to -1] as Number { format: "##,###" } default 0,
                        'transactionDate': item.transactionDate,
                        "symbol": item.symbol,
                        "buyer": if(isEmpty(item.office))  "$(item.firstName) $(item.lastName)" else item.office,
                        "link": item.link
                    })
    }


fun hdataToTransactions(data: Array<HData>): Array<Transaction> = do {
        data map ((item, index) -> {
                        'type': item."type",
                        'amount': item.amount splitBy "-" then trim($[1])[1 to -1] as Number { format: "##,###" } default 0 ,
                        'transactionDate': item.transactionDate,
                        "symbol": if(isEmpty(item.ticker)) item.assetDescription else item.ticker,
                        "buyer": if(isEmpty(item.representative)) item.owner else item.representative,
                        "link": item.link
    
                    })    
    }