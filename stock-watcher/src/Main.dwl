import fail from dw::Runtime
input params:{action: String}
input stocks
---
params.action match {
    case is "download" -> transactions::Download::main({})
    case is "trend_by_users" -> trends::ByUsers::main({stocks: stocks})
    case is "trend_by_money" -> trends::ByMoney::main({stocks: stocks})
    case is "pelosi" -> trends::FromNancy::main({stocks: stocks})
    else -> fail("Action can be either : download or trend_by_users or trend_by_money or pelosi")
} 