# Commands

This tool allows to query the stocks done by the US congress. 


It support different actions send by setting the parameter `action` to the name of action to be executed

* download: It downloads all the reported filed transactions by the US congress. 
Example: dw spell -l stock-watcher -p action="download" -o ./stock-watcher/stocks.json   
* trend_by_users: It output the transactions group and order by the amount of congress operating on this stock
Example: dw spell -l stock-watcher -p action="trend_by_users" -o ./stock-watcher/stocks.json -i stocks=./stock-watcher/stocks.json
* trend_by_money: It output the transactions order by the amount of money invested on a given stock
Example: dw spell -l stock-watcher -p action="trend_by_money" -o ./stock-watcher/trends_by_money.json -i stocks=./stock-watcher/stocks.json
* pelosi: 
Example: dw spell -l stock-watcher -p action="pelosi" -o ./stock-watcher/pelosi.json -i stocks=./stock-watcher/stocks.json