
-- Creamos la base de datos
CREATE DATABASE operativa; 

-- Seleccionamos la base de datos
USE operativa;

-- Creación de la tabla "companies"
CREATE TABLE IF NOT EXISTS companies (
	company_id varchar(20),
    company_name varchar(100),
    phone varchar(20),
    email varchar(100) UNIQUE,
    country varchar(50),
    website varchar(100),
    PRIMARY KEY(company_id)
);

    
-- Creación de la tabla "credit_cards"
CREATE TABLE IF NOT EXISTS credit_cards (
	id varchar(20),
    user_id int,
    iban varchar(50) UNIQUE,
    pan varchar(30),
    pin varchar(4),
    cvv int NULL,
    track1 varchar(100),
    track2 varchar(100),
    expiring_date varchar(20),
    PRIMARY KEY(id),
    INDEX(user_id)
);
    
-- Creación de la tabla "users"
CREATE TABLE IF NOT EXISTS users (
	id int,
    name varchar(25),
    surname varchar (50),
    phone varchar (20),
    email varchar(75) UNIQUE,
    birth_date varchar(20),
    country varchar (25),
    city varchar(25),
    postal_code varchar(20),
    address varchar(125),
    PRIMARY KEY (id)
);


-- Creamos la tabla "transactions"
CREATE TABLE IF NOT EXISTS transactions (
	 id varchar(255),
	 card_id varchar(20),
	 business_id varchar(20),
	 timestamp timestamp,
	 amount decimal(10,2),
	 declined tinyint(1),
	 product_ids varchar(15),
	 user_id int,
	 lat float,
	 longitude float,
	 PRIMARY KEY (id)
);


-- Activación de la carga de datos en local
SHOW VARIABLES LIKE "local_infile";
 
SET GLOBAL local_infile=1;
 
-- Carga de registros para "companies"
LOAD DATA LOCAL INFILE "C:/Users/Alex/Downloads/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT *
FROM companies;

-- Carga de registros para "credit_cards"
LOAD DATA LOCAL INFILE "C:/Users/Alex/Downloads/credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'  -- El .csv fue creado en Unix
IGNORE 1 LINES;

SELECT *
FROM credit_cards;


-- Carga de registros para "users"
-- Cargamos users_usa
LOAD DATA LOCAL INFILE "C:/Users/Alex/Downloads/users_usa.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Cargamos "users.ca"
LOAD DATA LOCAL INFILE "C:/Users/Alex/Downloads/users_ca.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Cargamos "users.uk"
LOAD DATA LOCAL INFILE "C:/Users/Alex/Downloads/users_uk.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT *
FROM users;

-- Carga de registros para "transactions"
LOAD DATA LOCAL INFILE "C:/Users/Alex/Downloads/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT *
FROM  transactions;

-- Relaciones entre las tablas
-- Relación con "credit_cards"
ALTER TABLE transactions
ADD CONSTRAINT transactions_ibfk_1
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

-- Relación con "companies"
ALTER TABLE transactions
ADD CONSTRAINT transactions_ibfk_2
FOREIGN KEY (business_id) REFERENCES companies(company_id);

-- Relación con "users"
ALTER TABLE transactions
ADD CONSTRAINT transactions_ibfk_3
FOREIGN KEY (user_id) REFERENCES users(id);


/* Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb
més de 30 transaccions utilitzant almenys 2 taules. */

-- Opción 1
SELECT
 id,
 CONCAT(name, " ", surname) AS full_name
FROM users
WHERE id IN (
			SELECT user_id
			FROM transactions
			WHERE declined = 0
			GROUP BY user_id
			HAVING COUNT(id) > 30);
            
-- Opción 2
SELECT user_id, 
       (SELECT name FROM users WHERE users.id = t.user_id) AS name,
       (SELECT surname FROM users WHERE users.id = t.user_id) AS surname,
       COUNT(t.id) AS num_trans
FROM transactions AS t
WHERE declined = 0
GROUP BY user_id
HAVING num_trans > 30;


/* Exercici 2
Mostra la mitjana d'amount per IBAN de les targetes de
crèdit a la companyia Donec Ltd,utilitza almenys 2 taules. */

SELECT
	c.company_id,
    cc.iban,
	ROUND(AVG(t.amount),2) AS avg_amount
FROM companies AS c
JOIN transactions AS t
	ON c.company_id = t.business_id
JOIN credit_cards AS cc
	ON t.card_id = cc.id
WHERE c.company_id = "b-2242"
	AND declined = 0
GROUP BY cc.iban;

/* Nivell 2
Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat
en si les últimes tres transaccions van ser declinades i genera la següent consulta:
Quantes targetes estàn actives? */

-- Creamos la tabla que contendrá el identificador de la tarjeta y su estatus
CREATE table credit_card_status (
	credit_card_id varchar(20) PRIMARY KEY,
	status enum("active", "inactive") NOT NULL,
	FOREIGN KEY (credit_card_id) REFERENCES transactions(card_id)
	);

DESCRIBE credit_card_status;

SELECT
	card_id AS credit_card_id,
	CASE
		WHEN sum(declined) >= 3 THEN "inactive"
		ELSE "active" 
		END AS status
FROM (SELECT
			card_id,
			timestamp,
			declined,
			DENSE_RANK() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS ranking
			FROM transactions
	  ) AS rt
WHERE rt.ranking <=3
GROUP BY credit_card_id;

-- Inserción datos en "credit_card_status"
INSERT INTO credit_card_status (credit_card_id, status)
SELECT
	card_id AS credit_card_id,
	CASE
		WHEN sum(declined) >= 3 THEN "inactive"
		ELSE "active" 
		END AS status
FROM (
			SELECT
				card_id,
				timestamp,
				declined,
				DENSE_RANK() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS ranking
			FROM transactions
		  ) AS rt
WHERE ranking <= 3  -- Filtramos por las 3 últ. transacciones (las hemos ordenado en DESC)
GROUP BY credit_card_id;

SELECT *
FROM credit_card_status;

-- Relación entre tablas
ALTER TABLE credit_cards
ADD CONSTRAINT fk_ccards_ccards_status
FOREIGN KEY(id) REFERENCES credit_card_status(credit_card_id);

-- Quantes targetes estan actives?
SELECT COUNT(*) AS active_cards
FROM credit_card_status
WHERE status = "active";






-- Creación de la tabla "products"
CREATE TABLE IF NOT EXISTS products (
	id int,
    product_name varchar(50),
    price decimal(8,2),
    colour varchar(10),
    weight decimal(6,2),
    warehouse_id varchar(10),
    PRIMARY KEY (id)
);

-- Carga de registros para "products"
LOAD DATA LOCAL INFILE "C:/Users/Alex/Downloads/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Eliminamos el símbolo del dolar del campo "price"
UPDATE products
SET price = TRIM(LEADING '$' FROM price);

-- Convertimos el campo "price" a dec
ALTER TABLE products
MODIFY COLUMN price dec(8,2);

SELECT *
FROM products;

DESCRIBE products;


-- Creación de la tabla intermedia
CREATE TABLE IF NOT EXISTS orders (
transaction_id VARCHAR(100) NOT NULL,
product_id INT NOT NULL,
PRIMARY KEY (transaction_id, product_id)
);

DESCRIBE orders;

INSERT INTO orders (transaction_id, product_id)
SELECT 
	t.id as transaction_id,
    p.id AS product_id
FROM transactions AS t
JOIN products AS p
	ON FIND_IN_SET(p.id, REPLACE(t.product_ids, " ", "")) > 0;

select *
from orders
ORDER BY transaction_id DESC;

DESCRIBE orders;

-- Relación de "orders" con "products" y "transactions"
ALTER TABLE orders
ADD CONSTRAINT fk_orders_products
FOREIGN KEY (product_id) REFERENCES products(id);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_transactions
FOREIGN KEY (transaction_id) REFERENCES transactions(id);


/* Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte. */
SELECT
	o.product_id,
	COUNT(o.product_id) AS units_sold
FROM orders AS o
JOIN transactions as t
	ON t.id = o.transaction_id
WHERE t.declined = 0
GROUP BY o.product_id
ORDER BY units_sold DESC;




