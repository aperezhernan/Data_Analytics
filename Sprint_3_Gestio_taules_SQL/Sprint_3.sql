-- NIVELL 1
-- Exercici 1
/* La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials
sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta i
establir una relació adequada amb les altres dues taules ("transaction" i "company").
Després de crear la taula serà necessari que ingressis la informació del document denominat
"dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest. */


-- Creamos la tabla credit_card
CREATE TABLE credit_card (
	id varchar(15) NOT NULL,
    iban varchar(50) NULL,
    pan varchar(100) NULL,
    pin smallint NULL,
    cvv smallint NULL,
    expiring_date date NULL,
    PRIMARY KEY(id),
    UNIQUE(iban)
    );

-- Mostramos la estructura para asegurarnos que se ha creado correctamente
DESCRIBE credit_card;

-- Insertamos los registros para "credit_card" y comprobamos los resultados que devuelve
SELECT *
FROM credit_card;

-- Cambiamos el tipo de dato que acepta "expiring_date"
ALTER TABLE credit_card
MODIFY COLUMN expiring_date varchar(25) NOT NULL;

-- Relacionamos la relación con la tabla "transaction"
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit
FOREIGN KEY(credit_card_id) REFERENCES credit_card(id);

-- Exercici 2
/* El departament de Recursos Humans ha identificat un error en el número de compte de l’usuari amb
ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999 */

SELECT *
FROM credit_card
WHERE id  = "CcU-2938";

UPDATE credit_card
SET iban = "R323456312213576817699999"
WHERE id = "CcU-2938";


-- Exercici 3
-- En la taula "transaction" ingressa un nou usuari

-- Añadimos a la empresa en la tabla "company" ya que aún no existe
INSERT INTO company (id)
VALUES ("b-9999");

SELECT *
FROM company
WHERE id = "b-9999";

-- Añadimos la tarjeta de crédito a "credit_card"
INSERT INTO credit_card (id)
VALUES ("CcU-9999");

SELECT *
FROM credit_card
WHERE id = "CcU-9999";

-- Añadimos el registro para esta empresa en la "transaction"
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", 9999, 829.999, -117.999, 111.11, 0);

-- Comprobación
SELECT * 
FROM transaction
WHERE id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";


-- Exercici 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card.

ALTER TABLE credit_card
DROP pan;

SELECT *
FROM credit_card;

-- NIVELL 2
-- Exercici 1
/* Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02
de la base de dades. */

SELECT *
FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

DELETE FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";


-- Exercici 2
/* Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació:
Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada
companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra. */

CREATE VIEW VistaMarketing AS
SELECT
	company_name,
    phone,
    country,
    ROUND(AVG(amount), 2) AS avg_amount
   FROM company AS c
JOIN transaction AS t
	ON  c.id = t.company_id
WHERE declined = 0
GROUP BY company_name, phone, country
ORDER BY avg_amount DESC;
    
-- Invocamos la vista
SELECT *
FROM vistamarketing;

-- Exercici 3
/* Filtra la vista VistaMarketing per a mostrar només les
companyies que tenen el seu país de residència en "Germany” */
SELECT *
FROM vistamarketing
WHERE country = "Germany";

-- Nivell 3
-- Exercici 1

-- Eliminamos "website" de la tabla "company"
ALTER TABLE company
DROP website;

DESCRIBE company;

-- Modificamos la columna id en "credit_card"
ALTER TABLE credit_card
MODIFY COLUMN id varchar(20) NOT NULL;

Describe credit_card;

-- Modificamos el campo "pin"
ALTER TABLE credit_card
MODIFY COLUMN pin varchar(4) NULL;

-- Modificamos "cvv" a integer
ALTER TABLE credit_card
MODIFY COLUMN cvv int NULL;

-- Modificamos "expiring_date"
ALTER TABLE credit_card
MODIFY COLUMN expiring_date varchar(20) NULL;

-- Agregamos el campo "fecha_actual_como date
ALTER TABLE credit_card
ADD fecha_actual date NULL;

DESCRIBE credit_card;

-- Creamos la tabla "data_user"
/* Convertimos a INDEX el campo user_id de la tabla
transactions para realizar la relación entre tablas*/

CREATE INDEX idx_user_id
ON transaction(user_id);   

-- Creamos la tabla
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );

-- Cambiamos el nombre de la tabla
ALTER TABLE user
RENAME TO data_user;

-- Cambiamos el nombre del campo "email"
ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

DESCRIBE data_user;

-- LEFT JOIN para comparar "transactions" con "data_user"
SELECT
	t.user_id,
	d.id
FROM transaction AS t
LEFT JOIN data_user AS d
 ON d.id = t.user_id
WHERE d.id IS NULL;

-- Eliminamos la relación actual entre "transactions" y "data_user"
ALTER TABLE data_user
DROP FOREIGN KEY data_user_ibfk_1;

-- Introducimos el usuario 9999 en "data_user"
INSERT INTO data_user (id)
VALUES ("9999");

-- Relacionamos ambas tablas
ALTER table transaction
ADD CONSTRAINT fk_datau_transaction
FOREIGN KEY(user_id) REFERENCES data_user(id);

-- Exercici 2
-- Creamos la vista InformeTecnico
CREATE VIEW InformeTecnico AS
SELECT
	t.id,
	d.name,
	d.surname,
	cc.iban,
	c.company_name
FROM transaction AS t
JOIN data_user AS d
	ON t.user_id = d.id
JOIN company AS c
	ON t.company_id = c.id
JOIN credit_card AS cc
	ON t.credit_card_id = cc.id
ORDER BY t.id DESC;

-- Probamos la vista
SELECT *
FROM InformeTecnico



