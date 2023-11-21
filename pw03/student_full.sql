SET search_path = pagila;


-- BEGIN Exercice 01
-- Donnez le numéro, le nom et l’email (customer_id, nom, email) des clients dont le prénom est
-- PHYLLIS, qui sont rattachés au magasin numéro 1, ordonnés par numéro de client décroissant.

SELECT
	customer_id,
	first_name || ' ' || last_name AS nom,
	email
FROM customer
WHERE first_name = 'PHYLLIS'
  AND store_id = 1
ORDER BY customer_id DESC;
-- END Exercice 01


-- BEGIN Exercice 02
-- Donnez l’ensemble des films (titre, annee_sortie) classés (rating) R, ayant une durée de moins
-- de 60 minutes et dont les coûts de remplacements sont 12.99$, en les ordonnant par titre.

SELECT
	title AS titre,
	release_year AS annee_sortie
FROM film
WHERE rating = 'R'
  AND length < 60
  AND replacement_cost = 12.99
ORDER BY title;
-- END Exercice 02


-- BEGIN Exercice 03
-- Listez le pays, la ville et le numéro postal (country, city, postal_code) des villes française, ainsi
-- que des villes dont le numéro de pays est entre 63 et 67 (bornes comprises), en les ordonnant par
-- pays puis par ville et finalement par code postal. N’utilisez pas de BETWEEN.

SELECT
	ctry.country,
	city.city,
	adr.postal_code
FROM city
	JOIN address adr
		ON city.city_id = adr.city_id
	JOIN country ctry
		ON city.country_id = ctry.country_id
WHERE ctry.country = 'France'
   OR (ctry.country_id >= 63 AND ctry.country_id <= 67)
ORDER BY ctry.country, city, adr.postal_code;
-- END Exercice 03


-- BEGIN Exercice 04
-- Listez tous les clients actifs (customer_id, prenom, nom) habitant la ville 171, et rattachés au
-- magasin numéro 1. Triez-les par ordre alphabétique des prénoms.

SELECT
	customer_id,
	first_name AS prenom,
	last_name AS nom
FROM customer
	JOIN address adr
		ON adr.address_id = customer.address_id
WHERE active = TRUE
  AND adr.city_id = 171
  AND store_id = 1
ORDER BY first_name;
-- END Exercice 04


-- BEGIN Exercice 05
-- Donnez le nom et le prénom (prenom_1, nom_1, prenom_2, nom_2) des clients qui ont loué au
-- moins une fois le même film (par exemple, si ALAN et BEN ont loué le film MATRIX, mais pas TRACY,
-- seuls ALAN et BEN doivent être listés).

SELECT
	c1.first_name AS prenom_1,
	c1.last_name AS nom_1,
	c2.first_name AS prenom_2,
	c2.last_name AS nom_2
FROM customer c1
	CROSS JOIN customer c2
	JOIN rental r1
		ON c1.customer_id = r1.customer_id
	JOIN rental r2
		ON c2.customer_id = r2.customer_id
	JOIN inventory i1
		ON i1.inventory_id = r1.inventory_id
	JOIN inventory i2
		ON i2.inventory_id = r2.inventory_id
WHERE i1.film_id = i2.film_id
  AND c1.customer_id < c2.customer_id
GROUP BY c1.first_name, c1.last_name,
		 c2.first_name, c2.last_name;
-- END Exercice 05


-- BEGIN Exercice 06
-- Donnez le nom et le prénom des acteurs (nom, prenom) ayant joué dans un film d’horreur, dont le
-- prénom commence par K, ou dont le nom de famille commence par D sans utiliser le mot clé JOIN.

SELECT
	last_name AS nom,
	first_name AS prenom
FROM actor
WHERE actor_id IN (
	SELECT
		actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT
			film_id
		FROM film_category
		WHERE category_id = (
			SELECT
				category_id
			FROM category
			WHERE name = 'Horror'
		)
	)
)
  AND (first_name LIKE 'K%' OR last_name LIKE 'D%')
GROUP BY first_name, last_name;
-- END Exercice 06


-- BEGIN Exercice 07a
-- Donnez les films (id, titre, prix_de_location_par_jour) dont le prix de location par jour est
-- inférieur ou égal à 1.00$ et qui n’ont jamais été loués. Écrire la requête de 2 différentes façons
-- (changer les clauses pour exprimer l’exclusion)

SELECT
	film.film_id AS id,
	title AS titre,
	rental_rate / rental_duration AS prix_de_location_par_jour
FROM film
	LEFT JOIN inventory i
		ON film.film_id = i.film_id
	LEFT JOIN rental r
		ON i.inventory_id = r.inventory_id
WHERE rental_rate / rental_duration <= 1.00
  AND i.inventory_id IS NULL
  AND r.rental_id IS NULL
GROUP BY film.film_id;
-- END Exercice 07a

-- BEGIN Exercice 07b
SELECT
	film_id AS id,
	title AS titre,
	rental_rate / rental_duration AS prix_de_location_par_jour
FROM film
WHERE rental_rate / rental_duration <= 1.00
  AND film_id NOT IN (
	SELECT
		film_id
	FROM inventory i
		JOIN rental r
			ON i.inventory_id = r.inventory_id
)
GROUP BY film.film_id;
-- END Exercice 07b


-- BEGIN Exercice 08a
-- Donnez la liste des clients (id, nom, prenom) espagnols qui n’ont pas encore rendu tous les films
-- qu’ils ont empruntés, en les ordonnant par nom.
-- a) En utilisant EXISTS (pas de GROUP BY, ni de IN ou NOT IN)

SELECT
	c.customer_id AS id,
	c.last_name AS nom,
	c.first_name AS prenom
FROM customer c
	JOIN address adr
		ON c.address_id = adr.address_id
	JOIN city
		ON adr.city_id = city.city_id
	JOIN country ctry
		ON city.country_id = ctry.country_id
WHERE ctry.country = 'Spain'
  AND EXISTS (
	SELECT *
	FROM rental r
	WHERE r.customer_id = c.customer_id
	  AND r.return_date IS NULL
)
ORDER BY nom;
-- END Exercice 08a

-- BEGIN Exercice 08b
-- b) En utilisant IN (pas de GROUP BY, ni de EXISTS ou NOT EXISTS).

SELECT
	c.customer_id AS id,
	c.last_name AS nom,
	c.first_name AS prenom
FROM customer c
	JOIN address adr
		ON c.address_id = adr.address_id
	JOIN city
		ON adr.city_id = city.city_id
	JOIN country ctry
		ON city.country_id = ctry.country_id
WHERE ctry.country = 'Spain'
  AND c.customer_id IN (
	SELECT
		r.customer_id
	FROM rental r
	WHERE r.return_date IS NULL
)
ORDER BY nom;
-- END Exercice 08b

-- BEGIN Exercice 08c
-- c) En utilisant aucun des mot-clés précédent (c’est à dire pas de GROUP BY, IN, NOT IN, EXISTS, NOT EXISTS).

SELECT
	c.customer_id AS id,
	c.last_name AS nom,
	c.first_name AS prenom
FROM customer c
	JOIN address adr
		ON c.address_id = adr.address_id
	JOIN city
		ON adr.city_id = city.city_id
	JOIN country ctry
		ON city.country_id = ctry.country_id
	JOIN rental r
		ON c.customer_id = r.customer_id
WHERE ctry.country = 'Spain'
  AND r.return_date IS NULL
ORDER BY c.last_name;
-- END Exercice 08c


-- BEGIN Exercice 09 (Bonus)
-- Donnez le numéro, le nom et le prénom (customer_id, prenom, nom) des clients qui
-- ont loué tous les films de l’actrice EMILY DEE.

SELECT
	c.customer_id,
	c.first_name AS prenom,
	c.last_name AS nom
FROM customer c
	JOIN rental r
		ON c.customer_id = r.customer_id
	JOIN inventory i
		ON r.inventory_id = i.inventory_id
	JOIN film_actor fa
		ON i.film_id = fa.film_id
	JOIN actor a
		ON fa.actor_id = a.actor_id
WHERE a.first_name = 'EMILY'
  AND a.last_name = 'DEE'
GROUP BY c.customer_id, c.first_name, c.last_name, a.actor_id
HAVING COUNT(DISTINCT i.film_id) = (
	SELECT
		COUNT(film_id)
	FROM film_actor
	WHERE actor_id = a.actor_id
);
-- END Exercice 09 (Bonus)


-- BEGIN Exercice 10
-- Donnez le titre des films et le nombre d’acteurs (titre, nb_acteurs) des films dramatiques en les
-- triant par le nombre d’acteur décroissant. Retenez uniquement les films avec moins de 5 acteurs.

SELECT
	f.title AS titre,
	COUNT(fa.actor_id) AS nb_acteurs
FROM film f
	JOIN film_actor fa
		ON f.film_id = fa.film_id
	JOIN film_category fc
		ON f.film_id = fc.film_id
	JOIN category c
		ON fc.category_id = c.category_id
WHERE c.name = 'Drama'
GROUP BY f.title
HAVING COUNT(fa.actor_id) < 5
ORDER BY nb_acteurs DESC;
-- END Exercice 10


-- BEGIN Exercice 11
-- Listez les catégories (id, nom, nb_films) de films associées à plus de 65 films, sans utiliser de
-- sous-requête, et en les ordonnant par nombre de films.

SELECT
	c.category_id AS id,
	c.name AS nom,
	COUNT(fc.film_id) AS nb_films
FROM category c
	JOIN film_category fc
		ON c.category_id = fc.category_id
GROUP BY c.category_id
HAVING COUNT(fc.film_id) > 65
ORDER BY nb_films;
-- END Exercice 11


-- BEGIN Exercice 12
-- Affichez le(s) film(s) (id, titre, duree) ayant la durée la moins longue. Si plusieurs films ont la
-- même durée (la moins longue), il faut afficher l’ensemble de ces derniers.

SELECT
	f.film_id AS id,
	f.title AS titre,
	f.length AS duree
FROM film f
WHERE f.length = (
	SELECT
		MIN(length)
	FROM film
);
-- END Exercice 12


-- BEGIN Exercice 13a
-- Listez les film (id, titre) dans lesquels jouent au moins un acteur qui a joué dans plus de 40
-- films, en les ordonnant par titre.
-- a) En utilisant le mot-clé IN

SELECT
	f.film_id AS id,
	f.title AS titre
FROM film f
	JOIN film_actor fa
		ON f.film_id = fa.film_id
WHERE fa.actor_id IN (
	SELECT
		actor_id
	FROM film_actor
	GROUP BY actor_id
	HAVING COUNT(film_id) > 40
)
GROUP BY id, titre
ORDER BY titre;
-- END Exercice 13a

-- BEGIN Exercice 13b
-- b) Sans utiliser le mot-clé IN

SELECT
	f.film_id AS id,
	f.title AS titre
FROM film f
	JOIN film_actor fa
		ON f.film_id = fa.film_id
	JOIN (
	SELECT
		actor_id
	FROM film_actor
	GROUP BY actor_id
	HAVING COUNT(film_id) > 40
) fa2
		ON fa.actor_id = fa2.actor_id
GROUP BY id, titre
ORDER BY titre;
-- END Exercice 13b


-- BEGIN Exercice 14
-- Un fou furieux décide de regarder l’ensemble des films qui sont présents dans la base de données.
-- Etablissez une requête qui donne le nombre de jours (nb_jours) qu’il devra y consacrer sachant
-- qu’il dispose de 8 h par jour.

SELECT
	SUM(length) / 60.0 / 8 AS nb_jours
FROM film;
-- END Exercice 14


-- BEGIN Exercice 15
-- Affichez tous les clients (id, nom, email, pays, nb_locations, depense_totale, depense_moyenne)
-- résidant en Suisse, en France ou en Allemagne, dont la dépense moyenne (montant payé) par lo-
-- cation est supérieure à 3.0, en les ordonnant par pays puis par nom.

SELECT
	c.customer_id AS id,
	c.last_name AS nom,
	c.email AS email,
	ctry.country AS pays,
	COUNT(r.rental_id) AS nb_locations,
	SUM(p.amount) AS depense_totale,
	AVG(p.amount) AS depense_moyenne
FROM customer c
	JOIN address adr
		ON c.address_id = adr.address_id
	JOIN city
		ON adr.city_id = city.city_id
	JOIN country ctry
		ON city.country_id = ctry.country_id
	JOIN rental r
		ON c.customer_id = r.customer_id
	JOIN payment p
		ON r.rental_id = p.rental_id
WHERE ctry.country IN ('Switzerland', 'France', 'Germany')
GROUP BY c.customer_id, c.last_name, c.email, ctry.country
HAVING AVG(p.amount) > 3.0
ORDER BY ctry.country, c.last_name;
-- END Exercice 15


-- BEGIN Exercice 16a
-- Donnez les 3 requêtes suivantes ainsi que le résultat de la première et de la dernière
-- a) Comptez les paiements dont la valeur est inférieure ou égale à 9.

SELECT
	COUNT(*) AS nb_paiements
FROM payment
WHERE amount <= 9;
-- END Exercice 16a

-- BEGIN Exercice 16b
-- Effacez ces mêmes paiements

DELETE
FROM payment
WHERE amount <= 9;
-- END Exercice 16b

-- BEGIN Exercice 16c
-- Comptez à nouveau ces mêmes paiements pour vérifier que l’opération a bien eu lieu.

SELECT
	COUNT(*) AS nb_paiements
FROM payment
WHERE amount <= 9;
-- END Exercice 16c


-- BEGIN Exercice 17
-- En une seule requête, modifiez les paiements comme suit :
-- (a) Chaque paiement de plus de 4$ est majoré de 50 %.
-- (b) La date de paiement est mise à jour avec la date courante du serveur.

UPDATE payment
SET amount       = CASE WHEN amount > 4 THEN amount * 1.5 ELSE amount END,
	payment_date = CURRENT_DATE;
-- END Exercice 17

-- BEGIN Exercice 18
-- Un nouveau client possèdant les informations suivantes souhaite louer des films :
--      M. Guillaume Ransome
--      Adresse : Rue du centre, 1260 Nyon
--      Pays : Suisse / Switzerland
--      Téléphone : 021/360.00.00
--      E-mail : gr@bluewin.ch
--      -> Ce client est rattaché au magasin 1.
-- Insérez-le dans la base de données, avec toutes les informations requises pour lui permettre de
-- louer des films.
--  (a) Spécifiez les attributs (colonnes) lors de l’insertion.
--  (b) Pour chaque nouveau tuple, la base de données doit générer l’id. Pourquoi ne pouvez-vous
--      pas le faire ?
--  (c) Pour chaque clé étrangère pour laquelle une valeur est requise, une requête doit donner cette
--      valeur. On considère que l’ensemble des requêtes nécessaires sera fait dans une transaction,
--      ainsi, seules vos modifications de la base de données seront effectives (pas de soucis de
--      concurrence avec une éventuelle autre application).
BEGIN;

INSERT INTO city (city, country_id)
VALUES ('Nyon', (
	SELECT
		country_id
	FROM country
	WHERE country = 'Switzerland'
));

INSERT INTO address (address, address2, district, city_id, postal_code, phone)
VALUES ('Rue du centre', NULL, 'Vaud', (
	SELECT
		MAX(city_id)
	FROM city
), '1260', '021/360.00.00');

INSERT INTO customer (store_id, first_name, last_name, email, address_id, active)
VALUES (1, 'Guillaume', 'Ransome', 'r@bluewin.ch', (
	SELECT
		MAX(address_id)
	FROM address
), TRUE);

COMMIT;
-- END Exercice 18

-- BEGIN Exercice 18d
-- d) Ecrivez une requête d’interrogation, qui montrera que l’ensemble des opérations s’est bien déroulé.

SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	adr.address,
	adr.address2,
	adr.district,
	adr.postal_code,
	adr.phone,
	city.city,
	ctry.country,
	c.store_id
FROM customer c
	JOIN address adr
		ON c.address_id = adr.address_id
	JOIN city
		ON adr.city_id = city.city_id
	JOIN country ctry
		ON city.country_id = ctry.country_id
WHERE c.first_name = 'Guillaume'
  AND c.last_name = 'Ransome';
-- END Exercice 18d
