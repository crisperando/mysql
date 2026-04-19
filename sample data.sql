DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS numbers;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    created_at DATETIME
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    created_at DATETIME
);

CREATE TABLE orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    status VARCHAR(20),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SET SESSION cte_max_recursion_depth = 10000;

CREATE TABLE numbers (
    n INT PRIMARY KEY
);

INSERT INTO numbers (n)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 10000
)
SELECT n
FROM seq;

INSERT INTO customers (
    first_name,
    last_name,
    email,
    city,
    created_at
)
SELECT
    CONCAT('first', n),
    CONCAT('last', n),
    CASE
        WHEN n % 20 = 0 THEN NULL
        ELSE CONCAT('user', n, '@example.com')
    END AS email,
    CASE
        WHEN n % 15 = 0 THEN NULL
        ELSE ELT(1 + (n % 5), 'Manila', 'Cebu', 'Davao', 'Iloilo', 'Bacolod')
    END AS city,
    CASE
        WHEN n % 25 = 0 THEN NULL
        ELSE NOW() - INTERVAL (n % 1000) DAY
    END AS created_at
FROM numbers
WHERE n <= 1000;

INSERT INTO products (
    product_name,
    category,
    price,
    created_at
)
SELECT
    CONCAT('product', n),
    CASE
        WHEN n % 18 = 0 THEN NULL
        ELSE ELT(1 + (n % 5), 'Electronics', 'Clothing', 'Food', 'Home', 'Sports')
    END AS category,
    CASE
        WHEN n % 22 = 0 THEN NULL
        ELSE ROUND(10 + ((n * 7.35) % 1000), 2)
    END AS price,
    CASE
        WHEN n % 30 = 0 THEN NULL
        ELSE NOW() - INTERVAL (n % 1000) DAY
    END AS created_at
FROM numbers
WHERE n <= 500;

INSERT INTO orders (
    customer_id,
    order_date,
    status
)
SELECT
    CASE
        WHEN n % 40 = 0 THEN NULL
        ELSE 1 + (n % 1000)
    END AS customer_id,
    CASE
        WHEN n % 35 = 0 THEN NULL
        ELSE NOW() - INTERVAL (n % 365) DAY
    END AS order_date,
    CASE
        WHEN n % 28 = 0 THEN NULL
        ELSE ELT(1 + (n % 4), 'Pending', 'Shipped', 'Delivered', 'Cancelled')
    END AS status
FROM numbers
WHERE n <= 10000;

INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    o.order_id,
    CASE
        WHEN (o.order_id + n.n) % 45 = 0 THEN NULL
        ELSE 1 + ((o.order_id + n.n) % 500)
    END AS product_id,
    CASE
        WHEN (o.order_id + n.n) % 27 = 0 THEN NULL
        ELSE 1 + ((o.order_id + n.n) % 5)
    END AS quantity,
    CASE
        WHEN (o.order_id + n.n) % 33 = 0 THEN NULL
        ELSE ROUND(10 + (((o.order_id * n.n) % 1000) * 0.91), 2)
    END AS unit_price
FROM orders o
JOIN numbers n
    ON n.n <= 3;

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_customers_city ON customers(city);