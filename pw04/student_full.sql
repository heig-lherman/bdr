SET search_path = pagila;

--
-- Triggers
---------------------------

-- BEGIN Exercice 01
CREATE FUNCTION update_payment()
	RETURNS TRIGGER
	LANGUAGE plpgsql
AS
$$
BEGIN
	NEW.amount := NEW.amount * 1.08;
	NEW.payment_date := CURRENT_TIMESTAMP;
	RETURN NEW;
END;
$$;

CREATE TRIGGER payment_before_insert
	BEFORE INSERT
	ON payment
	FOR EACH ROW
EXECUTE FUNCTION update_payment();
-- CHECK
INSERT INTO payment (customer_id, staff_id, rental_id, amount)
VALUES (1, 1, 1, 1);

SELECT *
FROM payment
WHERE payment_id = (
	SELECT
		MAX(payment_id)
	FROM payment
);
-- END Exercice 01

-- BEGIN Exercice 02
CREATE TABLE staff_creation_log
(
	username     VARCHAR(16),
	when_created TIMESTAMP WITH TIME ZONE
);

CREATE FUNCTION log_staff_creation()
	RETURNS TRIGGER
	LANGUAGE plpgsql
AS
$$
BEGIN
	INSERT INTO staff_creation_log(username, when_created)
	VALUES (NEW.username, CURRENT_TIMESTAMP);
	RETURN NEW;
END;
$$;

CREATE TRIGGER after_staff_insert
	AFTER INSERT
	ON staff
	FOR EACH ROW
EXECUTE FUNCTION log_staff_creation();
-- CHECK
INSERT INTO staff (first_name, last_name, address_id, email, store_id, active, username, password)
VALUES ('John', 'Doe', 1, 'example@example.ch', 1, TRUE, 'johndoe', 'password');

SELECT *
FROM staff_creation_log;
-- END Exercice 02

-- BEGIN Exercice 03
CREATE FUNCTION update_staff_email()
	RETURNS TRIGGER
	LANGUAGE plpgsql
AS
$$
BEGIN
	NEW.email := LOWER(NEW.first_name || '.' || NEW.last_name || '@sakilastaff.com');
	RETURN NEW;
END;
$$;

CREATE TRIGGER update_staff_email
	BEFORE INSERT OR UPDATE
	ON staff
	FOR EACH ROW
EXECUTE FUNCTION update_staff_email();
-- CHECK
INSERT INTO staff (first_name, last_name, address_id, email, store_id, active, username, password)
VALUES ('John', 'Doe', 1, 'example@example.net', 1, TRUE, 'johndoe', 'password');

SELECT *
FROM staff
WHERE staff_id = (
	SELECT
		MAX(staff_id)
	FROM staff
);

UPDATE staff
SET first_name = 'Jane'
WHERE staff_id = (
	SELECT
		MAX(staff_id)
	FROM staff
);

SELECT *
FROM staff
WHERE staff_id = (
	SELECT
		MAX(staff_id)
	FROM staff
);
-- END Exercice 03

--
-- Vues
---------------------------

-- BEGIN Exercice 04
CREATE VIEW staff_contact_info AS
SELECT
	first_name,
	last_name,
	address.phone,
	address.address,
	address.address2,
	address.district,
	address.postal_code,
	city.city
FROM staff
	JOIN address
		ON staff.address_id = address.address_id
	JOIN city
		ON address.city_id = city.city_id;
-- CHECK
SELECT *
FROM staff_contact_info;
---- Question: Est-ce que Franklin pourra mettre à jour la base de donnée à travers cette vue ?
--
-- Non, car une vue qui contient des données de plusieurs tables ne peut pas être mise à jour.
--
-- END Exercice 04

-- BEGIN Exercice 05
CREATE VIEW overdue_rentals_reminder AS
SELECT
	customer.email,
	film.title,
	CEIL(EXTRACT(EPOCH FROM CURRENT_TIMESTAMP - (rental_date + film.rental_duration * INTERVAL '1 day'))
		/ (24 * 60 * 60)) AS days_overdue
FROM rental
	JOIN customer
		ON rental.customer_id = customer.customer_id
	JOIN inventory
		ON rental.inventory_id = inventory.inventory_id
	JOIN film
		ON inventory.film_id = film.film_id
WHERE rental.return_date IS NULL
  AND CURRENT_TIMESTAMP > rental_date + film.rental_duration * INTERVAL '1 day';
-- CHECK
SELECT *
FROM overdue_rentals_reminder;
-- END Exercice 05

-- BEGIN Exercice 06
CREATE VIEW customers_with_overdue_rentals AS
SELECT *
FROM overdue_rentals_reminder
WHERE days_overdue > 3;
-- CHECK
SELECT *
FROM customers_with_overdue_rentals;
-- END Exercice 06

-- BEGIN Exercice 07
CREATE VIEW customer_rental_count AS
SELECT
	customer.customer_id,
	customer.first_name,
	customer.last_name,
	COUNT(rental.rental_id) AS nb_locations
FROM customer
	JOIN rental
		ON customer.customer_id = rental.customer_id
GROUP BY customer.customer_id;
--
SELECT *
FROM customer_rental_count
ORDER BY nb_locations DESC
LIMIT 20;
-- END Exercice 07

-- BEGIN Exercice 08
CREATE VIEW daily_rental_count AS
SELECT
	DATE_TRUNC('day', rental_date) AS rental_day,
	COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY rental_day;
-- CHECK
SELECT *
FROM daily_rental_count;
-- Combien de locations sont effectués en 1er août 2005 ? Donner la requête SQL.
SELECT
	total_rentals
FROM daily_rental_count
WHERE rental_day = '2005-08-01';
-- END Exercice 08

--
-- Procédures / Fonctions
---------------------------

-- BEGIN Exercice 09
CREATE FUNCTION count_films_by_store(in_store_id INTEGER)
	RETURNS INTEGER
	LANGUAGE plpgsql
AS
$$
DECLARE
	film_count INTEGER;
BEGIN
	SELECT
		COUNT(DISTINCT film_id)
	INTO film_count
	FROM inventory
	WHERE store_id = in_store_id;

	RETURN film_count;
END;
$$;
--
SELECT
	count_films_by_store(1) AS store_1_film_count,
	count_films_by_store(2) AS store_2_film_count;
--
SELECT
	store_id,
	COUNT(DISTINCT film_id) AS total_films
FROM inventory
WHERE store_id IN (1, 2)
GROUP BY store_id;
-- END Exercice 09

-- BEGIN Exercice 10
CREATE PROCEDURE update_film_last_update()
	LANGUAGE plpgsql
AS
$$
BEGIN
	UPDATE film
	SET last_update = CURRENT_TIMESTAMP;
END;
$$;
--
SELECT
	last_update
FROM film
GROUP BY last_update;
-- > Avant la mise à jour la date de tous les films était à 2017-09-10 17:46:03.905795+00:00
--
CALL update_film_last_update();

SELECT
	last_update
FROM film
GROUP BY last_update;
-- > Après la mise à jour la date de tous les films est à CURRENT_TIMESTAMP
-- > (2023-11-28 15:56:15.859313+00:00, lors de l'exécution)
-- END Exercice 10

--
-- SQL Avancé
---------------------------

-- BEGIN Exercice 11
WITH RECURSIVE actor_connections AS (
	-- Initial query to get the actor_id of 'ED GUINESS'
	SELECT
		actor.actor_id,
		0 AS distance
	FROM actor
	WHERE actor.first_name = 'ED'
	  AND actor.last_name = 'GUINESS'

	UNION ALL

	-- Recursive part of the query
	SELECT
		a.actor_id,
		ac.distance + 1
	FROM actor a
		JOIN film_actor fa
			ON a.actor_id = fa.actor_id
		JOIN film
			ON fa.film_id = film.film_id
		JOIN actor_connections ac
			ON film.film_id IN (
				SELECT film_id
				FROM film_actor
				WHERE actor_id = ac.actor_id
			)
	WHERE film.length < 50 -- only consider short files
	  AND ac.distance < 3 -- Limit to actors within 3 films of distance
)
SELECT actor_id
FROM actor_connections
WHERE distance > 0
GROUP BY actor_id;
-- END Exercice 11

-- BEGIN Exercice 12
SELECT
	payment_id,
	customer_id,
	payment_date,
	amount,
	SUM(amount) OVER (PARTITION BY customer_id ORDER BY payment_date) AS cumulative_amount
FROM payment
ORDER BY customer_id, payment_date;
-- END Exercice 12
