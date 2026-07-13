DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
Select*from books;

DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);
SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;


-- Import Data into Books Table
COPY Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock)
FROM 'C:/CSV/Books.csv'
DELIMITER ','
CSV HEADER;

-- Import Data into Customers Table
COPY Customers(Customer_ID, Name, Email, Phone, City, Country)
FROM 'C:/CSV/Customers.csv'
DELIMITER ','
CSV HEADER;

-- Import Data into Orders Table
COPY Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount)
FROM 'C:/CSV/Orders.csv'
DELIMITER ','
CSV HEADER;

---1) Retrieve all books in the "Fiction" genre:
SELECT TITLE, genre FROM BOOKS
WHERE Genre like 'Fiction' ;--or we use thiis WHERE Genre ='Fiction';

--find the published after the year 1950
	SELECT TITLE,   Published_Year
	FROM BOOKS
	WHERE   Published_Year>1950 ;	

--list all customers frim canada
SELECT * FROM CUSTOMERS
WHERE COUNTRY='Canada';

--SHOW ORDER PLACED IN NOVEMBER 2023
SELECT * FROM ORDERS
--WHERE  EXTRACT('MONTH' FROM Order_Date)=11;
 WHERE  Order_Date BETWEEN '2023-11-01' AND '2023-11-30';


--5 FIND TOTAL STOCKS OF BOOKS AVAILABLE
SELECT sum(Stock) as total_stocks
from books;

--find the details of most expensive book
--Select  max(price) over() from books;
	SELECT* FROM BOOKS ORDER BY PRICE DESC limit 1;
	
	--7 show all customer who prdered more than 1 quantity of book
SELECT *FROM ORDERS
WHERE Quantity>1;

--RETRIVE ALL ORDERS WHERE THE TOTAL AMOUNT IS $20
SELECT *FROM ORDERS
WHERE Total_amount > 20;

--RETRIVE ALL GENRES AVAILABLE IN THE books table
SELECT DISTINCT(Genre) FROM  BOOKS;

--find the lowest stock 

SELECT * from books
Order by stock
limit 1;

--11 find total revenue genrated by all orders
SELECT sum(Total_Amount) as Total_revenue
from orders;

-- using join

SELECT SUM(o.Quantity * b.Price) AS Total_Revenue
FROM Orders o
JOIN Books b
ON o.Book_ID = b.Book_ID;



--ADvance queries
--1 Retrive the total number of books sold for each genre
SELECT * from orders;

Select b.genre,sum(o.quantity) AS TOTAL_SOLD
from books b 
join orders o
ON o.Book_ID = b.Book_ID
GROUP BY B.GENRE;

--2 FIND THE AVERAGE PRICE OF BOOKS IN THE ' FANTASY ' GENRE;]
Select AVG(price) AS average from books
WHERE GENRE='Fantasy';

-- list custmoers who have placed at least 2 orders;
select customer_id,count(order_id)as  order_count
from orders 
group by customer_id
having count(order_id)>=2;


select c.name,o.customer_id,count(o.order_id)as  order_count
from orders o
join customers c
on c.Customer_id=o.Customer_id
group by o.Customer_id ,c.name
having count(o.order_id)>=2;


--4 find most freqeuently irder book
SELECT BOOK_ID, COUNT(Order_id) as Mostsold_book
from orders
group by book_id
order by  Mostsold_book DESC limit 1;

--FIND THE MOST EXPENSIVE  BOOKS OF' FANTASY ' GENRE;]
SELECT *
FROM Books
WHERE Genre = 'Fantasy'
ORDER BY Price DESC
LIMIT 3;

--6 retrive the toatl quantity  of sold by each author
SELECT b.Author, sum(o.quantity) as total_sold
from books b
join orders o ON B.Book_id=o.book_id
GROUP BY b.Author;

--7 list the cities where customer who spent over $100 are located
select  DISTINCT c.city , o.Total_amount
from customers c join orders o 
on c.customer_id = o.customer_id
WHERE o.Total_Amount>100;

--8 FIND THE CUSTOMER WHO SPENT THE MOST ON ORDERS
select C.CUSTOMER_ID,c.name, sum(o. Total_amount ) as Total_spent
from customers c
join orders o 
on c.customer_id = o.customer_id
GROUP BY c.customer_id ,c.name
ORDER BY Total_spent desc limit 1;

--9) calculate the stock remaining after fulfilling all orders

select b.book_id,b.title,b.stock, COALESCE (sum(o.quantity),0) AS ORDER_QUANT,
b.stock - COALESCE (sum(o.quantity),0) as Remaining_quant
from books b
left join orders o
on b.book_id=o.book_id
GROUP BY B.BOOK_ID;
