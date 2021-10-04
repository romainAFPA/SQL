/*2. Analyser la base de données*/
/*2.1 Analyse structurelle*/
/*
table 'customers':
contient les informations des clients
liée à la table 'payments' par les colonnes 'customerNumber' clés primaire et étrangère 
liée à la table 'orders' par les colonnes 'customerNumber' clés primaire et étrangère

table 'employees':
contient les informations des employés
liée à la table 'customers' par les colonnes 'employeNumber' clé primaire et 'salesRepEmployeeNumber' clé étrangère
liée à la table 'offices' par les colonnes 'officeCode' clés primaire et étrangère

table 'offices':
contient les informations des bureaux
liée à la table 'employees' par les colonnes 'officeCode' clés primaire et étrangère

table 'orderdetails':
contient les informations des details de commandes
liée à la table 'orders' par les colonnes 'orderNumber' clés primaire et étrangère
liée à la table 'products' par les colonnes 'productCode' clés primaire et étrangère 
liée à la table 'productlines' par les colonnes 'productline' clé primaire et 'orderLineNumber' clé étrangère

table 'orders':
contient les informations des commandes
liée à la table 'orderdetails' par les colonnes 'orderNumber' clés primaire et étrangère

table 'payments':
contient les informations des paiements
liée à la table 'customers' par les colonnes 'customerNumber' clés primaire et étrangère

table 'productlines':
contient les informations des gammes de produits
liée à la table 'orderdetails' par les colonnes 'orderLineNumber'clé étrangère et 'productline' clé primaire 

table 'products':
contient les informations des produits
liée à la table 'orderdetails' par les colonnes 'productCode' clés primaire et étrangère
*/


/*2.2 Analyse de données*/
/*
Ces données sont issues d'entreprises de commerce de 
voitures, motos, avions, bateaux, trains, camion, bus et voitures de collection.
*/select productLine from productlines;

/*Le dictionnaire de données des tables 'customers' et 'offices'
est fourni en fichier Word dans le Github.
*/


/*3. Manipulations*/
/*3.1 Interrogations - Requêtes*/

/*question1*/
SELECT sum((select count(*) from customers)    +
           (select count(*) from employees)    +
           (select count(*) from offices)      +
           (select count(*) from orders)       +
           (select count(*) from payments)     +
           (select count(*) from products)	
          ) AS 'nb_enreg_total';

select count(*) AS 'nb_enreg_customers' from customers;
select count(*) AS "nb_enreg_employees" from employees;
select count(*) AS "nb_enreg_offices"   from offices;
select count(*) AS "nb_enreg_orders"    from orders;
select count(*) AS "nb_enreg_payments"  from payments;
select count(*) AS "nb_enreg_products"  from products;
/*resultats:
il y a 861 enregistrements au total de toutes les tables mentionées*/
/*il y a 122 enregistrements pour la table customers*/
/*il y a 23  enregistrements pour la table employees*/
/*il y a 7   enregistrements pour la table offices */
/*il y a 326 enregistrements pour la table orders*/
/*il y a 273 enregistrements pour la table payments*/
/*il y a 110 enregistrements pour la table products*/

/*question2*/
SELECT productName, quantityInStock
FROM products
WHERE productName LIKE '%Harley%'
ORDER BY quantityInStock DESC;
/*resultats:
1969 Harley Davidson Ultimate Chopper | 7931 |
2003 Harley-Davidson Eagle Drag Bike  | 7931 |
1936 Harley Davidson El Knucklehead   | 7931 |
*/

/*question3*/
SELECT contactFirstName, contactLastName FROM customers
WHERE contactFirstName LIKE '_a%' 
ORDER BY contactFirstName ASC;
/*resultats: 33 rows*/

/*question4*/
SELECT COUNT(*) FROM customers
WHERE contactFirstName LIKE '_a%';
/*Il y a 33 clients dans la table 'customers' dont le prénom a un 'a' en deuxième position*/

/*question5*/
SELECT productName AS 'Les articles', buyPrice AS 'Les prix'
FROM products
WHERE buyPrice BETWEEN 50 AND 65;
/*resultats: 27 rows*/

/*question6*/
SELECT SUM(amount) AS 'TOTAL [07/2004]'
FROM payments
WHERE paymentDate >= '2004-07-01';
/*resultats: 4290600.94*/

/*question7*/
SELECT  orderNumber, sum(quantityOrdered) AS 'quantity ordered'
FROM orderDetails
WHERE quantityOrdered >= 50
GROUP BY orderNumber;
/*resultats: 26 rows*/

/*question8*/
SELECT customerName, contactFirstName, orderNumber
FROM customers
LEFT JOIN orders ON orders.customerNumber = customers.customerNumber
WHERE orders.customerNumber IS NULL
ORDER BY customerName ASC;
/*resultats: 72 rows*/

/*question9*/
SELECT lastName, firstName, employeeNumber, jobTitle
FROM employees
WHERE officeCode IS NULL;
/*0 employés ne sont ratachés à aucun bureau*/

/*question10*/
SELECT COUNT(DISTINCT city) 
FROM customers 
ORDER BY city ASC;
/*Il y a 95 villes différentes dans la table 'customers' */


/*question11*/
SELECT c.customerName                                   AS 'Name', 
       CONCAT(c.contactFirstName,' ',c.contactLastName) AS 'Contact', 
       SUM(p.amount)                                    AS 'Total Amount',
       c.customerNumber                                 AS 'Customer Number'
FROM customers AS c
LEFT JOIN payments AS p ON p.customerNumber = c.customerNumber
GROUP BY p.customerNumber ORDER BY SUM(p.amount) DESC /*LIMIT 1*/;
/*Le nom et le numéro du client qui a payé le plus dans la table payments est 'Euro+ Shopping Channel'.
  Le numéro du client qui a payé le plus dans la table payments est '141'.
*/

/*question12*/
SELECT p.productCode, 
       p.productName,
       o.quantityOrdered,
       SUM(quantityOrdered)           AS 'Sum QuantityOrdered',
       SUM(quantityOrdered*priceEach) AS 'Sum Sales'
FROM orderDetails AS o 
LEFT JOIN products AS p   ON p.productCode = o.productCode
LEFT JOIN orders    AS ord ON ord.orderNumber = o.orderNumber
WHERE ord.orderDate >= 2005-01-01
GROUP BY 1
ORDER BY 1;
/*resultats: 109 rows*/

/*question13*/
SELECT *
FROM
(      
       SELECT orders.orderNumber     AS 'orderNumber', 
              orders.orderDate       AS 'orderDate & productCode', 
              orders.status          AS 'Status & quantityOrdered', 
              customers.customerName AS 'customerName & productName'
       FROM orders
       LEFT JOIN customers ON orders.customerNumber = customers.customerNumber
       UNION
       SELECT orderDetails.orderNumber,
              orderDetails.productCode ,
              orderDetails.quantityOrdered,
              products.productName                               
       FROM orderDetails
       LEFT JOIN products ON orderDetails.productCode = products.productCode
) 
AS wrapper
ORDER BY 1,2;
/*resultats: 1242 rows*/

/*question14*/
SELECT customers.customerName, 
       offices.city, offices.country, 
       employees.firstName, employees.lastName, employees.jobTitle,
       products.productCode,
       orders.orderNumber,
       orderdetails.quantityOrdered, orderdetails.orderLineNumber
FROM customers
INNER JOIN employees    ON employees.employeeNumber = customers.salesRepEmployeeNumber
INNER JOIN offices      ON offices.officeCode       = employees.officeCode
INNER JOIN orders       ON orders.customerNumber    = customers.customerNumber
INNER JOIN orderdetails ON orderdetails.orderNumber = orders.orderNumber
INNER JOIN products     ON products.productCode     = orderdetails.productCode;
/*resultats: 566 rows*/
