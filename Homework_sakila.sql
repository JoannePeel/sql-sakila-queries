/*Access sakila data base */
USE sakila;
/*1a. Display the first and last names of all actors from the table actor.*/
SELECT first_name, last_name FROM actor;
/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. */
SELECT CONCAT(first_name, " ", last_name) AS ActorName FROM actor;
/*2a. You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/
SELECT actor_id FROM actor WHERE first_name = "Joe";
/*2b. Find all actors whose last name contain the letters GEN: */
SELECT * FROM actor WHERE last_name LIKE "%GEN%";
/*2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order: */
SELECT * FROM actor WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name;
/* 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/
SELECT country_id, country  
FROM country 
WHERE country IN ("Afghanistan", "Bangladesh", "China");
/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a 
description, so create a column in the table actor named description and use the data 
type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant). */
ALTER TABLE actor 
ADD COLUMN description BLOB NULL AFTER last_update;
/*3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column. */
ALTER TABLE actor DROP description;
/* 4a. List the last names of actors, as well as how many actors have that last name.*/
SELECT last_name, COUNT(*)
FROM actor GROUP BY last_name;
/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
SELECT last_name, COUNT(*)
FROM actor GROUP BY last_name
HAVING COUNT(*) > 1;
/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record. */
UPDATE actor SET first_name = 'HARPO' WHERE (actor_id = 172);
/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. */
UPDATE actor SET first_name = 'GROUCHO' WHERE (first_name = "HARPO");
/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it? */
SHOW CREATE TABLE address;
/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address: */
SELECT staff.first_name, staff.last_name, address.address
FROM address
INNER JOIN staff ON
staff.address_id=address.address_id;
/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
Use tables staff and payment.*/ 
CREATE VIEW total_rung AS
SELECT staff_id, SUM(amount) AS total FROM payment WHERE
payment_date BETWEEN '2005/08/01 00:00:00'AND '2005/08/31 23:59:59'
Group BY staff_id;

SELECT staff.first_name, staff.last_name, total_rung.total
FROM total_rung
INNER JOIN staff ON
staff.staff_id=total_rung.staff_id;	
/*6c. List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join. */
CREATE VIEW actor_count AS 
SELECT film_id, COUNT(actor_id) AS "number_actors" FROM film_actor 
GROUP BY film_id;	

SELECT film.film_id, film.title, actor_count.number_actors
FROM actor_count
INNER JOIN film ON
film.film_id = actor_count.film_id;

/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?
Answer: There are 6 copies*/
SELECT film_id FROM film WHERE title = "Hunchback Impossible";
SELECT COUNT(*) FROM inventory WHERE film_id = 439;
/*6e. Using the tables payment and customer and the JOIN command, 
list the total paid by each customer. 
List the customers alphabetically by last name:*/
CREATE VIEW customer_total AS
SELECT customer_id, SUM(amount) AS total FROM payment 
Group BY customer_id;

SELECT customer.first_name, customer.last_name, customer_total.total
FROM customer_total
INNER JOIN customer ON
customer.customer_id = customer_total.customer_id
ORDER BY last_name;
/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
SELECT * 
FROM film 
WHERE (title LIKE 'Q%' OR title LIKE 'K%') 
AND language_id IN (SELECT language_id FROM language WHERE name = "english");
/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/
SELECT first_name, last_name 
FROM actor 
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id IN
(SELECT film_id FROM film WHERE title = "Alone Trip"));
/*7c. You want to run an email marketing campaign in Canada, for which you will 
need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.*/
SELECT first_name, last_name, email FROM customer WHERE address_id IN
(SELECT address_id FROM address WHERE city_id IN
(SELECT city_id FROM city WHERE country_id IN
(SELECT country_id FROM country WHERE country = "Canada")));
/* 7d. Sales have been lagging among young families, and you wish to target all family 
movies for a promotion. Identify all movies categorized as family films.*/
SELECT title FROM film WHERE film_id IN
(SELECT film_id FROM film_category WHERE category_id IN
(SELECT category_id FROM category WHERE name = "Family"));
/*7e. Display the most frequently rented movies in descending order*/
CREATE VIEW rentals_count AS
SELECT inventory_id, COUNT(rental_id) AS number_rented FROM rental
GROUP BY inventory_id;

CREATE VIEW rented_movies AS
SELECT inventory.film_id, rentals_count.number_rented
FROM rentals_count
INNER JOIN inventory ON
inventory.inventory_id=rentals_count.inventory_id;

CREATE VIEW sum_rentals AS
SELECT film_id, SUM(number_rented) AS number_of_times_rented FROM rented_movies
GROUP BY film_id;

SELECT film.title, sum_rentals.number_of_times_rented
FROM sum_rentals
INNER JOIN film ON
film.film_id = sum_rentals.film_id
ORDER BY number_of_times_rented DESC;

/*7f. Write a query to display how much business, in dollars, each store brought in.*/
CREATE VIEW  bucks_made AS
SELECT staff_id, SUM(amount) AS sum_cash FROM payment
GROUP BY staff_id;

SELECT staff.store_id, bucks_made.sum_cash
FROM bucks_made
INNER JOIN staff ON 
staff.staff_id = bucks_made.staff_id;

/*Write a query to display for each store its store ID, city, and country.*/
CREATE VIEW city_store AS
SELECT address.city_id, store.store_id
FROM store 
INNER JOIN address ON
address.address_id = store.address_id;

CREATE VIEW store_country AS
SELECT city.city, city.country_id, city_store.store_id
FROM city_store
INNER JOIN city ON
city.city_id = city_store.city_id;

SELECT store_country.city, store_country.store_id, country.country
FROM country
INNER JOIN store_country ON
store_country.country_id = country.country_id;

/*7h. List the top five genres in gross revenue in descending order.
(Hint: you may need to use the following tables: category, film_category, 
inventory, payment, and rental.)*/
CREATE VIEW list_rental_inventory AS
SELECT payment.amount, rental.inventory_id
FROM payment
INNER JOIN rental ON
payment.rental_id = rental.rental_id;

CREATE VIEW sum_movie AS
SELECT inventory_id, SUM(amount) AS total_movie FROM list_rental_inventory
GROUP BY inventory_id;

CREATE VIEW sum_by_film AS
SELECT sum_movie.total_movie, inventory.film_id 
FROM sum_movie
INNER JOIN inventory ON
inventory.inventory_id = sum_movie.inventory_id;

CREATE VIEW sum_film AS
SELECT film_id, SUM(total_movie) AS total_film FROM sum_by_film
GROUP BY film_id;

CREATE VIEW sum_category AS
SELECT sum_film.total_film, film_category.category_id
FROM sum_film
INNER JOIN film_category ON
film_category.film_id = sum_film.film_id;

CREATE VIEW sum_by_category AS
SELECT category_id, SUM(total_film) AS total_category FROM sum_category
GROUP BY category_id;

CREATE VIEW most_profitable_category AS
SELECT sum_by_category.total_category, category.name
FROM sum_by_category
INNER JOIN category ON
sum_by_category.category_id= category.category_id
ORDER BY total_category DESC;
/*8a. In your new role as an executive, you would like to have an easy way of 
viewing the Top five genres by gross revenue. Use the solution from the 
problem above to create a view. If you haven't solved 7h, you can substitute 
another query to create a view.*/
CREATE VIEW most_profitable_category AS
SELECT sum_by_category.total_category, category.name
FROM sum_by_category
INNER JOIN category ON
sum_by_category.category_id= category.category_id
ORDER BY total_category DESC;
/*8b. How would you display the view that you created in 8a?*/
SELECT * FROM most_profitable_category
LIMIT 5; 
/*8c. You find that you no longer need the view top_five_genres. 
Write a query to delete it.*/
DROP VIEW most_profitable_category; 