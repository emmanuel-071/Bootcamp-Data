-- ex1 Crear la tabla credit_card con clave primaria y relaciones con transaction y company, 
-- insertar los datos indicados, mostrar el diagrama actualizado y describirlo brevemente.
CREATE TABLE IF NOT EXISTS credit_card ( -- mirar if not exist 
    id VARCHAR(20) PRIMARY KEY,
    iban VARCHAR(34)  NULL,
    pan VARCHAR(30)  NULL,
    pin VARCHAR(5)  NULL,
    cvv VARCHAR(5)  NULL,
    expiring_date VARCHAR(10)  NULL
);

-- ex2 Actualizar el número de cuenta de la tarjeta con ID CcU-2938 
-- y demostrar que el cambio se realizó correctamente
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT * FROM credit_card
WHERE id = 'CcU-2938'; 

-- ex3 → Insertar una nueva transacción en la tabla transaction con los datos proporcionados.
-- guardo primero 
INSERT INTO company (id, company_name, phone, email, country, website)
VALUES ('b-9999', NULL, NULL,NULL ,NULL, NULL);

;
INSERT INTO transaction (id, credit_card_id,company_id,user_id,lat, longitude,timestamp, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999,NULL, 111.11,0 ) 

;
SELECT * 
FROM transaction 
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD'
;
-- ex4. Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. 
-- Recorda mostrar el canvi realitzat.
ALTER TABLE credit_card DROP COLUMN pan;
DESCRIBE credit_card;

-- nivel 2
-- ex1. Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transaction 
WHERE ID = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
SELECT * FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- ex2. Crear la vista VistaMarketing con nombre, teléfono, país y media de compra por compañía, ordenada de mayor a menor promedio

CREATE VIEW  VistaMarketing AS
SELECT c.id, c.company_name AS nombre_empresa,
 c.phone AS telefono,
 c.country AS pais,
 AVG(t.amount) AS media_compra
FROM company c
JOIN transaction t 
ON c.id = t.company_id
GROUP BY c.id,c.company_name, c.phone, c.country;

SELECT * 
FROM VistaMarketing
ORDER BY media_compra DESC;


;

-- ex3. Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
SELECT *
FROM vistamarketing v
WHERE v.pais = 'GERMANY';

-- Nivel 3
-- ex1.

-- crear tabla user 
CREATE TABLE user (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255)
);
SELECT DISTINCT user_id
FROM transaction
WHERE user_id NOT IN (
    SELECT id FROM user) 
    
-- hay un user el 9999 que no esta en la tabla de user, lo voy a agregar manualmente
;
INSERT INTO user(id)
VALUES (9999)
;
ALTER TABLE transaction
ADD CONSTRAINT id_user
FOREIGN KEY (user_id)
REFERENCES user(id);

-- relacion credit-trans 
;        
        
SELECT DISTINCT credit_card_id
FROM transaction
WHERE credit_card_id NOT IN (
    SELECT id FROM credit_card
);
-- para crear la relacion han de tener la misma candidad de primary keys, al no dejarme agrego la PK
-- que faltaba en la tabla credit_card
select * from credit_card
WHERE id  = 'CcU-9999';

INSERT INTO credit_card 
(id)
VALUES 
('CcU-9999');
 
ALTER TABLE transaction
ADD CONSTRAINT fk_creditcard
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

SELECT DISTINCT t.credit_card_id
FROM transaction t
LEFT JOIN credit_card c
    ON t.credit_card_id = c.id
WHERE c.id IS NULL;

-- cambiar nombre de la tabla user > data_user 

RENAME TABLE user 
TO data_user;

-- agregar columna en credit_card
ALTER TABLE credit_card 
ADD fecha_actual DATE
;
-- eliminar la columna website de la tabla company
ALTER TABLE company 
DROP COLUMN website;

-- cambiar nombre de columna email de columna data_user
ALTER TABLE data_user RENAME COLUMN email TO personal_email ;

-- cambiar el tipo de datos de las columnas de la tabla credit card 


ALTER TABLE credit_card 
MODIFY iban VARCHAR(50);

ALTER TABLE credit_card 
MODIFY pin VARCHAR(4);

ALTER TABLE credit_card 
MODIFY cvv INT;  
   
ALTER TABLE transaction 
MODIFY credit_card_id VARCHAR(20);    

ALTER TABLE credit_card 
MODIFY expiring_date VARCHAR(20); 

-- EX2.
DROP VIEW IF EXISTS InformeTecnico;

CREATE VIEW InformeTecnico AS
SELECT 
    t.id AS id_transaccio,
    u.name AS nom_usuario,
    u.surname AS apellido_usuario,
    cc.iban AS iban_tarjeta,
    c.company_name AS nom_compañia
FROM transaction t
JOIN data_user u
    ON t.user_id = u.id
JOIN company c
    ON t.company_id = c.id
JOIN credit_card cc
    ON t.credit_card_id = cc.id
WHERE t.declined = 0;

SELECT *
FROM InformeTecnico
ORDER BY id_transaccio DESC;




