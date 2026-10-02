
-- =============================================
-- P1. CREANDO LAS TABLAS
-- =============================================


-- =================================
-- 1. customers
-- =================================
CREATE TABLE customers (
	customer_id  	int NOT NULL,
	first_name		varchar(50) NOT NULL,
	last_name 		varchar(50) NOT NULL,
	address 		varchar(50) NOT NULL,
	email 			varchar(50) NOT NULL,
	phone_number 	varchar(50) ,
	CONSTRAINT customers_pk PRIMARY KEY (customer_id),
	CONSTRAINT customers_unique UNIQUE (email)
);

-- =================================
-- 2. suppliers
-- =================================
CREATE TABLE suppliers (
	supplier_id 	int 		NOT NULL,
	supplier_name 	varchar(50) NOT NULL,
	contact_name 	varchar(50) NOT NULL,
	address 		varchar(50) ,
	phone_number 	varchar(50) ,
	email 			varchar(50) ,
	CONSTRAINT suppliers_pk PRIMARY KEY (supplier_id)
);

-- =================================
-- 3. products
-- =================================
CREATE TABLE products (
	product_id 		int 			NOT NULL,
	product_name 	varchar(50) 	NOT NULL,
	category 		varchar(50) 	, 
	price 			numeric(10,2) 	NOT NULL,
	supplier_id 	int 			,
	CONSTRAINT products_pk PRIMARY KEY (product_id),
	CONSTRAINT products_suppliers_fk FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
	
	CONSTRAINT products_price_positive_chk CHECK (price > 0)
);


-- =================================
-- 4. orders
-- =================================
CREATE TABLE orders (
	order_id 		int 			NOT NULL,
	order_date 		date 			NOT NULL,
	customer_id 	int 			NOT NULL,
	total_price 	numeric(10,2) 	NOT NULL,
	CONSTRAINT orders_pk PRIMARY KEY (order_id),
	CONSTRAINT orders_customers_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	
	CONSTRAINT orders_total_price_chk CHECK (total_price >= 0)
);

-- =================================
-- 5. order_items
-- =================================
CREATE TABLE order_items (
	order_item_id 		int 			NOT NULL,
	order_id 			int 			NOT NULL,
	product_id 			int 			NOT NULL,
	quantity 			int 			NOT NULL,
	price_at_purchase 	numeric(10,2) 	NOT NULL,
	CONSTRAINT order_items_pk PRIMARY KEY (order_item_id),
	CONSTRAINT order_items_orders_fk FOREIGN KEY (order_id) REFERENCES orders(order_id),
	CONSTRAINT order_items_products_fk FOREIGN KEY (product_id) REFERENCES products(product_id),
	
	CONSTRAINT order_quantity_positive_chck CHECK (quantity > 0),
	CONSTRAINT order_price_positive_chk CHECK (price_at_purchase >= 0)
);


-- =================================
-- 6. payment
-- =================================
CREATE TABLE payment (
	payment_id 			int 			NOT NULL,
	order_id 			int 			NOT NULL,
	payment_method 		varchar(50) 	NOT NULL,
	amount 				numeric(10,2) 	NOT NULL,
	transaction_status 	varchar(50) 	NOT NULL,
	CONSTRAINT payment_pk PRIMARY KEY (payment_id),
	CONSTRAINT payment_orders_fk FOREIGN KEY (order_id) REFERENCES orders(order_id),
	
	CONSTRAINT payment_check CHECK (amount > 0),
	CONSTRAINT payment_orden_unique UNIQUE (order_id)
);


-- =================================
-- 7. shipments
-- =================================
CREATE TABLE shipments (
	shipment_id 		int 			NOT NULL,
	order_id 			int 			NOT NULL,
	shipment_date 		date 			NOT NULL,
	carrier 			varchar(50) 	NOT NULL,
	tracking_number 	varchar(50) 	NOT NULL,
	delivery_date 		date 			,
	shipment_status 	varchar(50) 	NOT NULL,
	CONSTRAINT shipments_pk PRIMARY KEY (shipment_id),
	CONSTRAINT shipments_orders_fk FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- =================================
-- 8. reviews
-- =================================
CREATE TABLE reviews (
	review_id 		int 		NOT NULL,
	product_id 		int 		NOT NULL,
	customer_id 	int 		NOT NULL,
	rating 			int 		NOT NULL,
	review_text 	varchar(50) ,
	review_date 	date 		NOT NULL,
	CONSTRAINT reviews_pk PRIMARY KEY (review_id),
	CONSTRAINT reviews_customers_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	CONSTRAINT reviews_products_fk FOREIGN KEY (product_id) REFERENCES products(product_id)
);
