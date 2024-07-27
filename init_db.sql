-- northwind DB
-- 1. Найти заказчиков и обслуживающих их заказы сотрудников таких,
-- что и заказчики и сотрудники из города London, а доставка идёт
-- компанией Speedy Express. Вывести компанию заказчика и ФИО сотрудника.

-- 2. Найти активные (см. поле discontinued) продукты из категории 
-- Beverages и Seafood, которых в продаже менее 20 единиц. 
-- Вывести наименование продуктов, кол-во единиц в продаже, 
-- имя контакта поставщика и его телефонный номер.

--	3. Найти заказчиков, не сделавших ни одного заказа. 
--	Вывести имя заказчика и order_id.


-- 1
select * from orders
select * from customers
select * from shippers

SELECT c.company_name, e.first_name || ' ' || e.last_name AS employee FROM employees e
JOIN orders o USING(employee_id)
JOIN customers c USING(customer_id) 
JOIN shippers s ON o.ship_via = s.shipper_id 
WHERE s.company_name = 'Speedy Express' AND e.city = 'London' AND c.city = 'London'
--2
select * from categories
select * from products
select * from suppliers

SELECT product_name, units_in_stock, s.contact_name, s.phone from products
JOIN categories c USING(category_id)
JOIN suppliers s USING(supplier_id)
WHERE discontinued = 0 AND c.category_name IN('Beverages', 'Seafood') AND units_in_stock < 20
ORDER BY units_in_stock
--3
select * from orders
select * from customers

SELECT contact_name FROM customers
LEFT JOIN orders o USING(customer_id)
WHERE o.order_id IS NULL