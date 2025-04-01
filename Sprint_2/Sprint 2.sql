
-- NIVELL 1

-- 2.1 Llistat de països que estan fent compres
SELECT DISTINCT country
FROM company
INNER JOIN transaction
	ON company.id = transaction.company_id
ORDER BY country ASC;

-- 2.2 Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT country) AS total_countries
FROM company
INNER JOIN transaction
	ON company.id = transaction.company_id
ORDER BY country ASC;

-- 2.3 Identifica a la companyia amb la mitjana més gran de vendes
SELECT
	company.id,
    company.company_name,
	ROUND(AVG(amount),2) AS avg_amount
FROM company
INNER JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0                                   -- Filtre per les companyies amb transaccions acceptades
GROUP BY company.id, company.company_name
ORDER BY AVG(amount) DESC
LIMIT 1;

-- 3.1 Mostra totes les transaccions realitzades per empreses d’Alemanya
SELECT
	id,
	company_id
FROM transaction
WHERE company_id IN (
					SELECT id
					FROM company
					WHERE country = "Germany"
					);
                    
/* 3.2 Llista les empreses que han realitzat transaccions per un
amount superior a la mitjana de totes les transaccions */

SELECT DISTINCT id, company_name
FROM company
WHERE ID IN (					 -- Aquesta primera subquery substitueix el JOIN i em vincula les taules
SELECT company_id
FROM transaction
WHERE amount >
(SELECT ROUND(AVG(amount),2)
FROM transaction
))
ORDER BY company_name;

-- 3.3 Llistat d'empreses que no tenen transaccions registrades

SELECT DISTINCT company_name
FROM company
WHERE company.id NOT IN (
		SELECT company_id
        FROM transaction
        );

-- NIVELL 2
/* 1. Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa
per vendes. Mostra la data de cada transacció juntament amb el total de les vendes */

SELECT
	DATE(timestamp)  AS fecha,
    SUM(amount) AS total_ventas
FROM transaction
WHERE declined = 0					
GROUP BY DATE(timestamp)
ORDER  BY SUM(amount) DESC
LIMIT 5;

-- 2. Quina és la mitjana de vendes per pais? Presenta els resultats ordenats de major a menor mitja

SELECT
	country,
    ROUND(AVG(amount),2) AS avg_vendes
FROM company
INNER JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
ORDER BY AVG(amount) DESC;

/* 3. En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries
per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les
transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia */
 
 -- Mostra el llistat aplicant JOIN i subconsultes
SELECT
	company.id, 
    company.company_name, 
    transaction.id AS transaction_id
FROM company
JOIN transaction
  ON company.id = transaction.company_id
WHERE country = (
				SELECT country
                FROM company
                WHERE company_name = "Non Institute"
                ) 
AND NOT company_name = "Non Institute"
ORDER BY company_name;

-- Mostra el llistat aplicant subconsultes
SELECT
	company_id,
    transaction.id AS transaction_id
FROM transaction
WHERE company_id IN (
		SELECT id
        FROM company
        WHERE country = (
						SELECT country
                        FROM company
                        WHERE company_name ="Non Institute"
						)
		AND company_name != "Non Institute")
ORDER BY company_id;

-- Nivell 3
/* 3.1 Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions
amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021,
20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat */

SELECT
	company_name,
    phone, country,
    DATE(transaction.timestamp) AS date,
    transaction.amount
FROM company
INNER JOIN transaction
	ON company.id = transaction.company_id
WHERE amount BETWEEN 100 AND 200
	AND DATE(transaction.timestamp) IN ("2021-04-29", "2021-07-20", "2022-03-13")
ORDER BY amount DESC;


/* 3.2 Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es
requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen
les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on
especifiquis si tenen més de 4 transaccions o menys */

SELECT company_name,
	CASE 
		WHEN COUNT(transaction.id) <= 4 THEN "Less than 4 transactions"
        WHEN COUNT(transaction.id) = 4 THEN "4 transactions"
		ELSE "More than 4 transactions"
END AS transactions_quantity
FROM company
JOIN transaction
	ON company.id = transaction.company_id
GROUP BY company_id
ORDER BY transactions_quantity DESC;