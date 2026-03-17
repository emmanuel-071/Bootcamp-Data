-- primero creo la base de datos
CREATE DATABASE IF NOT EXISTS corregido;
USE corregido;
-- crear tabla credit_card
CREATE TABLE IF NOT EXISTS credit_cards (
id VARCHAR(20) PRIMARY KEY,
user_id INT,
iban VARCHAR(34),
pan VARCHAR(20),
pin CHAR(4),
cvv CHAR(3),
track1 VARCHAR(100),
track2 VARCHAR(100),
expiring_date DATE
);
-- CREATE TABLE products 

CREATE TABLE IF NOT EXISTS products (
id INT PRIMARY KEY,
product_name VARCHAR(255),
price VARCHAR(255),
colour VARCHAR(10),
weight VARCHAR(255),
warehouse_id VARCHAR(20)
);
-- tablas users americanos y europeos 

 CREATE TABLE IF NOT EXISTS pamerican_users (
	id VARCHAR(255) ,
    name VARCHAR(255), 
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date VARCHAR(255), 
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255)
    );
    
    CREATE TABLE IF NOT EXISTS peuropean_users (
	id VARCHAR(255) ,
    name VARCHAR(255), 
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255)
    );
    
-- crear tabla users 

CREATE TABLE IF NOT EXISTS users (
id INT PRIMARY KEY,
name VARCHAR(255),
surname VARCHAR(255),
phone VARCHAR(20),
email VARCHAR(100),
birth_date DATE,
country VARCHAR(50),
city VARCHAR(50),
postal_code VARCHAR(10),
address VARCHAR(100)
);
CREATE TABLE companies (
company_id VARCHAR(8) PRIMARY KEY,
company_name VARCHAR(255),
phone VARCHAR(20),
email VARCHAR(50),
country VARCHAR(60),
website VARCHAR(255)
);

-- crear tabla de hecho con las relaciones...
CREATE TABLE transactions (
id VARCHAR(50) PRIMARY KEY,
card_id VARCHAR(20),
company_id VARCHAR(8),
timestamp DATETIME,
amount DECIMAL(10,2),
declined TINYINT(1),
product_ids VARCHAR(50),
user_id INT,
latitude DECIMAL(9,6),
longitude DECIMAL(9,6),

FOREIGN KEY (card_id) REFERENCES credit_cards(id),
FOREIGN KEY (company_id) REFERENCES companies(company_id),
FOREIGN KEY (user_id) REFERENCES users(id)
);

-- al intentar grabar los datos a las tablas me salia un error que me obligaba a hacer algunos ajustes porque no me dejaba 
-- ingresar otro tipo de datos que no fuera sql?
-- Comienzo a registrar 
-- ingreso datos tabla companies
LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv' -- hay que cambiar a /
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ingreso datos tabla products
LOAD DATA INFILE -- descubrir que ha hecho para que funcione
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,product_name,price,colour,weight,warehouse_id);

-- ingreso datos tabla peuropean_users

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS
(id,name,surname,phone,email,@birth_date,country,city,postal_code,address)
SET birth_date = STR_TO_DATE(@birth_date,'%b %d, %Y');


-- ingreso datos tabla american_users
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS
(id,name,surname,phone,email,@birth_date,country,city,postal_code,address)
SET birth_date = STR_TO_DATE(@birth_date,'%b %d, %Y') ;

-- ingreso datos tabla pcredit_cards

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date)
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');
-- ingreso datos tabla TRANSACCIONES

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, card_id,company_id,timestamp,amount,declined,product_ids,user_id,latitude,longitude);



--
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'secure_file_priv';

-- CARGAR DATOS (CORRECCIÓN DATOS) 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS
(id,name,surname,phone,email,@birth_date,country,city,postal_code,address)
SET birth_date = STR_TO_DATE(@birth_date,'%b %d, %Y');

--  modificamos el tipo de dato de la columna price 
-- identifico que la columna de precio tiene signo $, lo quito para poder cambiar tipo de dato a DECIMAL (10,2)
UPDATE products
SET price = REPLACE(price, '$', '');

ALTER TABLE products
MODIFY price DECIMAL(10,2);
ALTER TABLE credit_cards
MODIFY cvv INT ;
-- eliminamos las tablas que no usamos en el diagrama (estan integrados en la tabla users)
DROP TABLE pamerican_users;
DROP TABLE peuropean_users;




-- nivell 1
-- hacemos ahora hacemos ejercicio 1 
-- EX1 

  SELECT name
FROM users u
WHERE EXISTS (
SELECT 1
FROM transactions t
WHERE t.user_id = u.id
GROUP BY t.user_id
HAVING COUNT(*) > 80
);
-- EX2

SELECT c.iban, ROUND(AVG(t.amount),2) AS media_ingresos 
FROM credit_cards c
JOIN transactions t
ON c.id = t.card_id
JOIN companies com
ON com.company_id= t.company_id
WHERE com.company_name = 'Donec Ltd'
GROUP BY c.iban;

-- nivel 2 
-- EX3 -- mirar el with, divide un problema en pasos claros...
SELECT
card_id,
timestamp,
declined,
ROW_NUMBER() OVER(
    PARTITION BY card_id
    ORDER BY timestamp DESC
) AS rn
FROM transactions;

CREATE TABLE IF NOT EXISTS card_status AS
SELECT
card_id,
CASE
    WHEN SUM(declined) = 3 THEN 'INACTIVE'
    ELSE 'ACTIVE'
END AS status
FROM (
    SELECT
        card_id,
        declined,
        ROW_NUMBER() OVER(
            PARTITION BY card_id
            ORDER BY timestamp DESC
        ) AS rn
    FROM transactions
) t
WHERE rn <= 3
GROUP BY card_id;
-- cuantas tarjetas estan activas? 
SELECT count(*) as tarjetas_acts
FROM card_status 
WHERE status = 'ACTIVE';


-- Nivel 3. 
-- Primero convertimos los datos de la columna product_ids en una lista
SELECT CONCAT('[', product_ids, ']') AS list_idprod
FROM transactions;

-- ahora usamos la Json_table sobre products_ids y una vez hecha la tabla con JSONTABLE se une con products
-- Numero de veces que ha vendido cada producto


-- para crear la relacion entre la tabla products y ptransaction
-- primero se crea una tabla puente que pueda unir la tabla products con la tabla ptransaction
-- esto porque la columna de products de la tabla ptransaction tiene
-- diferentes ids en cada fila separados por comas. 
CREATE TABLE transaction_products (
transaction_product_id INT AUTO_INCREMENT PRIMARY KEY,
transaction_id VARCHAR(50),
product_id INT,
UNIQUE (transaction_id,product_id),
FOREIGN KEY(transaction_id) REFERENCES transactions(id),
FOREIGN KEY(product_id) REFERENCES products(id)
);
INSERT INTO transaction_products (transaction_id, product_id)
SELECT
t.id,
jt.product_id
FROM transactions t,
JSON_TABLE(
CONCAT('[',t.product_ids,']'),
"$[*]"
COLUMNS(
product_id INT PATH "$"
)
) AS jt;

SELECT
p.product_name,
COUNT(tp.product_id) AS total_sales
FROM transaction_products tp
JOIN products p
ON tp.product_id = p.id

GROUP BY p.product_name;