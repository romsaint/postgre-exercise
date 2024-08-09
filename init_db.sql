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

-- 10. Вывести все товары (уникальные названия продуктов), которых
-- заказано ровно 10 единиц.

-- 11. Определить общий объем продаж для каждого продукта, учитывая количество единиц продукта, заказанных клиентами, и 
-- количество единиц продукта, которые уже находятся в заказе (units_on_order). Используй CASE WHEN THEN ELSE END

-- 12. Выведи все повторяющиеся номера заказов.

-- 13. Вывести уникальные order_id, сумму unit_price для каждого order_id
-- и список product_id, разделенных запятыми, для каждого order_id

-- 14. Вывести список категорий(category_id, category_name) и соответствующие им списки продуктов, разделенные запятыми

-- 15. Вывести для каждого заказа контактное имя клиента, идентификатор заказа, общую сумму заказа(quantity * unit_price), 
-- округленную до одного знака после запятой и список продуктов(STRING_AGG), разделенных запятыми, 
-- отсортированных по убыванию общей суммы заказа
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
SELECT DISTINCT p.product_name FROM products p
JOIN order_details od USING(product_id)
WHERE od.quantity = 10
ORDER BY p.product_name

-- 11.
SELECT p.product_id, 
       SUM(CASE WHEN p.units_on_order != 0 THEN od.quantity * p.units_on_order ELSE od.quantity END) AS total_quantity
FROM order_details od
JOIN products p USING(product_id)
GROUP BY p.product_id
ORDER BY total_quantity

-- 12.
SELECT order_id FROM order_details
GROUP BY order_id
HAVING COUNT(order_id) > 1

-- 13.
WITH od AS (
    SELECT * FROM order_details
)

SELECT 
    order_id, 
    sum_unit_price, 
    STRING_AGG(product_id::TEXT, ', ') AS product_ids
FROM (
    SELECT order_id, SUM(unit_price) AS sum_unit_price FROM od
    GROUP BY order_id
) AS summary
JOIN od USING(order_id)
GROUP BY order_id, sum_unit_price
ORDER BY order_id;

-- 14.
WITH product_list AS (
	SELECT category_id, STRING_AGG(product_name, ', ') AS product_list FROM products
	GROUP BY category_id
	ORDER BY category_id
)

SELECT category_id, category_name, product_list FROM categories
JOIN product_list USING(category_id)

-- 15.
WITH sums AS (
    SELECT order_id, SUM(unit_price * quantity) AS total_amount
    FROM order_details
    GROUP BY order_id
),
list AS (
    SELECT order_id, STRING_AGG(product_name, ', ') AS product_list
    FROM order_details
    JOIN products USING(product_id)
    GROUP BY order_id
)
SELECT c.contact_name, order_id, ROUND(total_amount::NUMERIC, 1) AS total_sum, product_list FROM orders
JOIN sums s USING(order_id)
JOIN customers c USING(customer_id)
JOIN list l USING(order_id)
ORDER BY total_sum DESC

-- 16.

-- USEFUL CODE  -- USEFUL CODE  -- USEFUL CODE  -- USEFUL CODE  -- USEFUL CODE  -- USEFUL CODE  -- USEFUL CODE  -- USEFUL CODE
SELECT order_id, product_name, p.unit_price, ROW_NUMBER()OVER(PARTITION BY order_id ORDER BY p.unit_price DESC) || '_' || order_id::TEXT AS row_number_id FROM order_details
JOIN products p USING(product_id);

SELECT o.order_id, p.product_name, p.unit_price,  o.ship_region, ROW_NUMBER()OVER(PARTITION BY o.ship_region ORDER BY p.unit_price DESC) AS num FROM orders o
JOIN order_details od USING(order_id)
JOIN products p USING(product_id);