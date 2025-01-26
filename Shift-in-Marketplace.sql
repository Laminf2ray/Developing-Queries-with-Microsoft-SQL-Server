/*Lets see whether there's a shift in the market place
towards digital.
To prove this we have to use the data.
1. Lets compare the two market places, Reseller and Online.
2. Let's compare their revenue, profit, volume of transactions
and items sold (order quantities) over time*/
/* The data is in the AdventureWorks2022 database */
/* Createing a Temporary View */
WITH SalesData AS
(
  SELECT sod.[SalesOrderID]
      ,sod.[SalesOrderDetailID]
      ,format(soh.[OrderDate],'yyyy-MM') as OrderDate
      ,sod.[OrderQty]
      ,sod.[OrderQty] * p.StandardCost as Cost
      ,sod.[ProductID]
      ,sod.[UnitPrice]
      ,sod.[LineTotal] as Revenue
      ,sod.LineTotal - (sod.OrderQty * p.StandardCost) as Profit    
      ,soh.[Status]
      ,"OnlineOrderFlag" = CASE soh.[OnlineOrderFlag]
                            WHEN 1 THEN 'Online'
                            ELSE 'Reseller'
                            END
  FROM [AdventureWorks2022].[Sales].[SalesOrderDetail] sod
  inner join [AdventureWorks2022].[Sales].[SalesOrderHeader] soh
    on sod.SalesOrderID = soh.SalesOrderID
  inner join [AdventureWorks2022].[Production].[Product] p
    on sod.ProductID = p.ProductID
  
),
--SELECT * FROM SalesData


/* Compare the revenue of the reseller and online sales */
RevenueComparison AS
(
  SELECT 
    cast(SUM(Revenue) as DECIMAL(18,2)) as Revenue,
    OnlineOrderFlag
  FROM SalesData
  GROUP BY OnlineOrderFlag
),
--SELECT * FROM RevenueComparison

ProfitComparison AS
(
  SELECT OnlineOrderFlag
        ,cast(SUM(Revenue) as DECIMAL(18,2)) as Profit
  FROM SalesData
  GROUP BY OnlineOrderFlag
),
/* Compare the number of transactions */
TransactionComparison AS
(
  SELECT OnlineOrderFlag
        ,count(distinct SalesOrderID) as Transactions
  FROM SalesData
  GROUP BY OnlineOrderFlag
),
ItemsComparison AS
(
  SELECT OnlineOrderFlag
        ,sum(OrderQty) as Items
  FROM SalesData
  GROUP BY OnlineOrderFlag
)
SELECT Revenue
      ,Profit
      ,Transactions
        ,Items
      ,rc.OnlineOrderFlag
      from RevenueComparison rc
        JOIN ProfitComparison pc
        ON rc.OnlineOrderFlag = pc.OnlineOrderFlag
        JOIN TransactionComparison tc
        ON rc.OnlineOrderFlag = tc.OnlineOrderFlag
        JOIN ItemsComparison ic
        ON rc.OnlineOrderFlag = ic.OnlineOrderFlag



