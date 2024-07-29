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

-- 4. Найти все заказы, которые были доставлены в тот же город, 
-- что и город заказчика, и были оформлены сотрудником, который 
-- также проживает в этом городе. Вывести номер заказа, город 
-- заказчика и ФИО сотрудника.

-- 5. Найти все продукты, которые были заказаны более чем в 10 
-- разных заказах, и у которых средняя стоимость за единицу 
-- продукта выше средней стоимости всех продуктов. 
-- Вывести наименование продукта, количество разных заказов и 
-- среднюю стоимость за единицу.

-- 6. Найти всех поставщиков, которые поставляют более одного продукта,
-- и у которых общее количество единиц всех поставляемых продуктов
-- превышает 100 единиц. Вывести имя поставщика, количество
-- поставляемых продуктов и общее количество единиц

-- 7. Найти названия компаний клиентов, которые сделали заказы,
-- включающие продукты в количестве более 40 единиц

-- 8. Вывести информацию о всех продуктах, количество которых в заказах (units_on_order) 
-- превышает среднее количество продуктов в заказах. Отсортировать по возрастанию количества в заказах

-- 9.Вывести продукты количество которых в продаже меньше 
-- самого малого среднего количества продуктов в деталях 
-- заказов (группировка по product_id). Результирующая 
-- таблица должна иметь колонки product_name и units_in_stock.

--     --     --     --     --     --     --     --     --     --     --     --

select * from categories
select * from products
select * from suppliers
select * from orders
select * from customers
select * from shippers
--     --     --     --     --     --     --     --     --     --     --     --
--     1.
SELECT c.company_name, e.first_name || ' ' || e.last_name AS employee FROM employees e
JOIN orders o USING(employee_id)
JOIN customers c USING(customer_id) 
JOIN shippers s ON o.ship_via = s.shipper_id 
WHERE s.company_name = 'Speedy Express' AND e.city = 'London' AND c.city = 'London'

--     2.
SELECT product_name, units_in_stock, s.contact_name, s.phone from products
JOIN categories c USING(category_id)
JOIN suppliers s USING(supplier_id)
WHERE discontinued = 0 AND c.category_name IN('Beverages', 'Seafood') AND units_in_stock < 20
ORDER BY units_in_stock

--     3.
SELECT contact_name FROM customers
LEFT JOIN orders o USING(customer_id)
WHERE o.order_id IS NULL

--     4.
SELECT DISTINCT o.order_id, c.city, e.first_name || ' ' || e.last_name AS employee FROM orders o
JOIN customers c ON o.ship_city = c.city
JOIN employees e USING(employee_id)
WHERE e.city = c.city
ORDER BY o.order_id

--     5.
SELECT product_name, orders_count, avg_price FROM (
	SELECT p.product_name, p.unit_price, COUNT(o.order_id) AS orders_count, AVG(o.unit_price) AS avg_price FROM products p
	JOIN order_details o USING(product_id)
	GROUP BY p.product_name, p.unit_price
)
WHERE orders_count > 10 AND unit_price > (
    SELECT AVG(unit_price) FROM order_details
)
ORDER BY orders_count

-- 6.
SELECT 
	s.contact_name, 
	SUM(p.units_in_stock) AS sum_stock, 
	COUNT(p.product_id) AS quantity_products
FROM suppliers s
JOIN products p USING(supplier_id)
GROUP BY s.supplier_id, s.contact_name
HAVING SUM(p.units_in_stock) > 100 AND COUNT(p.product_id) > 1

-- 7.
SELECT DISTINCT c.company_name FROM customers c
JOIN orders o USING(customer_id)
JOIN order_details od USING(order_id)
JOIN products p USING(product_id)
WHERE od.quantity > 40

-- 8.
SELECT * FROM products
WHERE units_on_order > (
	SELECT AVG(units_on_order)
	FROM products
)
ORDER BY units_on_order

-- 9.
SELECT p.product_name, p.units_in_stock FROM products p
JOIN order_details o USING(product_id)
GROUP BY p.product_id, p.units_in_stock
HAVING p.units_in_stock < (
	SELECT AVG(quantity) from order_details
	GROUP BY product_id
	ORDER BY avg
	LIMIT 1
)
-- OR -- OR  -- OR -- OR  -- OR -- OR  -- OR -- OR 
SELECT p.product_name, p.units_in_stock FROM products p
JOIN order_details o USING(product_id)
GROUP BY p.product_id, p.units_in_stock
HAVING p.units_in_stock < ALL(
	SELECT AVG(quantity) from order_details
	GROUP BY product_id
)

-- 10.