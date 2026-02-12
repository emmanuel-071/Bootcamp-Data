-- exercici 2. Utilitzant JOIN realitzaràs les següents consultes: 

-- Llistat dels països que estan generant vendes.
SELECT DISTINCT c.country AS paises
FROM company c
JOIN transaction tr
ON tr.company_id=c.id
ORDER BY paises; -- añadir el order by para ordenar los paises 

-- Des de quants països es generen les vendes.
SELECT count(paises) numpaises
FROM (SELECT DISTINCT c.country AS paises
	FROM company c
	JOIN transaction tr
	ON tr.company_id=c.id) t;

-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT tr.company_id, c.company_name, ROUND(AVG(tr.amount),2) AS mitjvendes  
FROM transaction tr 
JOIN company c
ON tr.company_id=c.id
WHERE tr.amount > 0 AND tr.declined = 0
GROUP BY tr.company_id, c.company_name
ORDER BY mitjvendes DESC
LIMIT 1; 

-- EX 3
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT t.* 
FROM transaction t
WHERE t.company_id IN (SELECT c.id
	FROM company c 
	WHERE c.country = 'Germany')
;


-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT DISTINCT c.company_name 
FROM company c 
WHERE c.id IN (
	SELECT tra.company_id
	FROM transaction tra
	WHERE tra.amount >(SELECT AVG(tr.amount) AS id_transacciones
					FROM transaction tr));


-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT c.company_name
FROM company c
WHERE c.id NOT IN ( SELECT DISTINCT company_id
		FROM transaction);

-- nivel 2. ex1. Exercici 1 Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT 
    DATE(tr.timestamp) AS dia,
    SUM(tr.amount) AS totalvendes
FROM transaction tr
WHERE tr.declined = 0
GROUP BY DATE(tr.timestamp)
ORDER BY totalvendes DESC
LIMIT 5;

-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT c.country, AVG(tr.amount) AS mitjvendes 
FROM transaction tr 
JOIN company c
ON tr.company_id=c.id
GROUP BY c.country
ORDER BY mitjvendes DESC;


-- ex3. a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT t.*
FROM transaction t 
JOIN company c
ON t.company_id=c.id
WHERE c.country = (
	SELECT c.country
	FROM company c
	WHERE  c.company_name = 'Non Institute') ; 

-- Mostra el llistat aplicant solament subconsultes.
SELECT t.* 
FROM transaction t 
WHERE t.company_id IN (SELECT c.id 
	FROM company c
	WHERE country =  (
		SELECT c.country
		FROM company c
		WHERE  c.company_name = 'Non Institute')) ;
        
-- Nivell 3
-- ex1 mostrar las empresas que realizaron transacciones entre 350 y 400 euros en fechas concretas, indicando nombre, teléfono, país, fecha e importe
SELECT c.company_name,
		c.phone,
		c.country,
		tr.timestamp,
		tr.amount
FROM company c 
JOIN transaction tr
ON c.id=tr.company_id -- declined= 0 
WHERE tr.amount between 350 and 400
	AND date(tr.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
    AND tr.declined = 0
ORDER BY tr.amount DESC 
; 

-- ex2 
SELECT c.company_name AS nombre_empresa, count(tr.id) AS cant_trans,
CASE
	WHEN count(tr.id) >= 400 THEN 'mas de 400 trans'
    ElSE 'menos de 400 trans'
END AS masomenos_400
FROM company c 
LEFT JOIN transaction tr
	ON c.id=tr.company_id
GROUP BY c.company_name
