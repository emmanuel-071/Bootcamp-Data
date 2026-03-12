
-- primero creo la base de datos
CREATE DATABASE IF NOT EXISTS transacciones;
USE transacciones;

-- a continuacion preparo las tablas 
CREATE TABLE IF NOT EXISTS ptransaction (
	id VARCHAR(200) PRIMARY KEY,
    card_id VARCHAR(200), 
    business_id VARCHAR(200) ,
    timestamp VARCHAR(200), -- cambiar tipo dato fecha
    amount VARCHAR(200),
    declined VARCHAR(200),
    product_ids VARCHAR(200),
    user_id VARCHAR(200),
    lat VARCHAR(200),
    longitude VARCHAR(200)
    );
    
CREATE TABLE IF NOT EXISTS pcompanies (
	company_id VARCHAR(10)  PRIMARY KEY,
    company_name VARCHAR(100), 
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(100)
    );

CREATE TABLE IF NOT EXISTS pcredit_cards (
	id VARCHAR(20),
    user_id VARCHAR(100), 
    iban VARCHAR(35),
    pan VARCHAR(50),
    pin VARCHAR(100),
    cvv VARCHAR(100),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(100) -- cambiar dato a dato fecha
    ) ;
    
CREATE TABLE IF NOT EXISTS pproducts (
	id VARCHAR(100) PRIMARY KEY,
    product_name VARCHAR(100), 
    price VARCHAR(100),
    colour VARCHAR(100),
    weight VARCHAR(100),
    warehouse_id VARCHAR(100)
    
    );
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
-- al intentar grabar los datos a las tablas me salia un error que me obligaba a hacer algunos ajustes porque no me dejaba 
-- ingresar otro tipo de datos que no fuera sql?
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

SHOW VARIABLES LIKE 'secure_file_priv';

-- Comienzo a registrar 
-- ingreso datos tabla companies
LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv' -- hay que cambiar a /
INTO TABLE pcompanies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ingreso datos tabla products
LOAD DATA INFILE -- descubrir que ha hecho para que funcione
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE pproducts
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,product_name,price,colour,weight,warehouse_id);

-- ingreso datos tabla peuropean_users

LOAD DATA INFILE 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\european_users.csv"
INTO TABLE peuropean_users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ingreso datos tabla american_users
LOAD DATA INFILE 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\american_users.csv"
INTO TABLE pamerican_users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;

-- ingreso datos tabla pcredit_cards

LOAD DATA INFILE -- descubrir que ha hecho para que funcione
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE pcredit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date);
-- ingreso datos tabla TRANSACCIONES

LOAD DATA INFILE -- descubrir que ha hecho para que funcione
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE ptransaction
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, card_id,business_id,timestamp,amount,declined,product_ids,user_id,lat,longitude);

-- crear las relaciones

-- nivel 1
-- ex1
-- juntar las dos tablas de usuarios

DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(150),
    birth_date VARCHAR(50), -- cambiar dato a tipo fecha
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);
INSERT INTO users
SELECT * FROM peuropean_users;

INSERT INTO users
SELECT * FROM pamerican_users;

-- hacemos las relaciones entre las tablas
-- transacciones- usuarios

-- cambio el tipo de dato de la columna user_id de la tabla transaction
ALTER TABLE ptransaction
MODIFY user_id INT NULL;


DESCRIBE ptransaction;
DESCRIBE users;

ALTER TABLE ptransaction
ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id)
REFERENCES users(id);

-- Relacion entre credit_card con transaction
DESCRIBE pcredit_cards;
DESCRIBE ptransaction;

	-- modificamos el tipo de datos
ALTER TABLE pcredit_cards
MODIFY id VARCHAR(20) PRIMARY KEY;

	-- creamos relacion
ALTER TABLE ptransaction
ADD CONSTRAINT fk_transaction_credictcard
FOREIGN KEY (card_id)
REFERENCES pcredit_cards(id);

-- Relacion entre pcompanies y transaction 
-- primero verificamos que el tipo de dato coincidan entre las dos tablas 
DESCRIBE ptransaction;
DESCRIBE pcompanies;

ALTER TABLE ptransaction 
MODIFY business_id VARCHAR(10);

	-- relacion
ALTER TABLE ptransaction 
ADD CONSTRAINT fk_ptransaction_pcompanies
FOREIGN KEY (business_id)
REFERENCES pcompanies(company_id);


-- relacion pproducts- trantaction
DESCRIBE ptransaction;
DESCRIBE pproducts; -- varchar(100)

ALTER TABLE ptransaction
MODIFY product_ids VARCHAR(100);

-- creamos relacion
ALTER TABLE ptransaction
ADD CONSTRAINT fk_ptransaction_pproducts
FOREIGN KEY (product_ids)
REFERENCES pproducts(id);

-- nivell 1
-- hacemos ahora hacemos ejercicio 1 
-- EX1 

  SELECT name
FROM users u
WHERE EXISTS (
SELECT 1
FROM ptransaction pt
WHERE pt.user_id = u.id
GROUP BY pt.user_id
HAVING COUNT(*) > 80
);
-- EX2

SELECT pc.iban, ROUND(AVG(pt.amount),2) AS media_ingresos -- agregar ROUND con dos decimales
FROM pcredit_cards pc
JOIN ptransaction pt
ON pc.id = pt.card_id
JOIN pcompanies pcom
ON pcom.company_id= pt.business_id
WHERE pcom.company_name = 'Donec Ltd'
GROUP BY pc.iban
;
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
FROM ptransaction;

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
    FROM ptransaction
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
FROM ptransaction;

-- ahora usamos la Json_table sobre products_ids y una vez hecha la tabla con JSONTABLE se une con products
-- Numero de veces que ha vendido cada producto
SELECT
p.id,
COUNT(*) AS total_ventas
FROM ptransaction pt,
JSON_TABLE(
CONCAT('[', pt.product_ids, ']'),
"$[*]"
COLUMNS(product_id INT PATH "$")
) AS jt
JOIN pproducts p
ON jt.product_id = p.id
GROUP BY p.id; 




-- para crear la relacion entre la tabla products y ptransaction
-- primero se crea una tabla puente que pueda unir la tabla products con la tabla ptransaction
-- esto porque la columna de products de la tabla ptransaction tiene
-- diferentes ids en cada fila separados por comas. 
CREATE TABLE IF NOT EXISTS transaction_products (
transaction_id VARCHAR(50),
product_id INT,
PRIMARY KEY (transaction_id, product_id)
);
-- creamos las relaciones con transaction

ALTER TABLE transaction_products
ADD CONSTRAINT fk_tp_transaction
FOREIGN KEY (transaction_id)
REFERENCES ptransaction(id);
-- el error expone que el tipo de columna de la variable product en la tabla transaction
-- no es el mismo que en la tabla puente transaction_products. prodcedemos a cambiar el tipo
ALTER TABLE transaction_products
MODIFY product_id VARCHAR(100);

-- ahora la relacion con products 
ALTER TABLE transaction_products
ADD CONSTRAINT fk_tp_product
FOREIGN KEY (product_id)
REFERENCES pproducts(id);

-- Cambio de tipo de dato y formato de las variables que contenian fechas

UPDATE pcredit_cards
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');

ALTER TABLE pcredit_cards
MODIFY expiring_date DATE;

UPDATE users
SET birth_date = STR_TO_DATE(birth_date, '%b %d, %Y');
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE users
MODIFY birth_date DATE;
SET SQL_SAFE_UPDATES = 1
