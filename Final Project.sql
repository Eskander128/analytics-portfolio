select * from Clerk
select * from Customer
select * from Order_Prod
select * from Orders
select * from Product

with CTE as(
SELECT   c.Id AS CustomerID,
    c.Name AS CustomerName,
    COUNT(DISTINCT o.OrderNumber) AS TotalOrders,
    SUM(op.Quantity * op.Price) AS TotalRevenue,
    DATEDIFF(DAY, MAX(o.OrderDate), GETDATE()) AS DaysSinceLastPurchase
FROM dbo.Customer c
JOIN dbo.Orders o ON c.Id = o.CustID
JOIN dbo.Order_Prod op ON o.OrderNumber = op.OrderID
JOIN dbo.Product p ON op.ProductID = p.ProductID
GROUP BY c.Id, c.Name
)
, CTE2 as(
select * , ntile(3) over (order by DaysSinceLastPurchase asc) as Recency
,ntile(3) over (order by TotalOrders asc) as frequency
,ntile(3) over (order by TotalRevenue asc) as monetry
from CTE)

,CTE3 as(
select * , CONCAT(Recency,Frequency, Monetry ) AS RFM_Score from CTE2
), CTE4 as(

select *,
case when  RFM_Score in (311,312,311) then 'New Customers'
when  RFM_Score in (111,121,131,122,133,113,112,132)then 'Lost Customers'
when RFM_Score in (212,313,123,221,232,211) then'Regular Customers'
when RFM_SCore in (223,222,213,322,231,321,331) then 'Loyal Customers'
when RFM_Score in (333,332,322,223) then 'Top Customers' end as Customer_Segmentation
from CTE3)

select Customer_Segmentation , COUNT(customerID) as #OfCustomer, COUNT(customerID)*1.0/(select COUNT(ID)from Customer) as Percntage from CTE4
group by Customer_Segmentation
