use sakila; 

 -- 1a Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;   

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, ' ', last_name) as ' Actor Name' from actor;

-- 2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor 
where first_name = 'Joe';

-- 2b Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name from actor 
where last_name like '%GEN%';

-- 2c Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name from actor 
where last_name like '%LI%' 
order by last_name, first_name; 

-- 2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country 
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a create a column in the table actor named description and use the data type BLOB 
alter table actor 
add(description blob not null);

-- 3b Delete the description column.
alter table actor drop description; 

-- 4a List the last names of actors, as well as how many actors have that last name.
select count(last_name), last_name from actor 
group by last_name;

-- 4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select count(last_name), last_name from actor 
group by last_name
having count(last_name) > 2;

-- 4c The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor 
set first_name = 'HARPO'
where first_name='GROUCHO' and last_name='WILLIAMS';

-- 4d In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor 
set first_name = 'GROUCHO'
where first_name='HARPO' and last_name='WILLIAMS';

-- 5a You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

-- 6a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address, address2 from staff s
inner join address a on s.address_id = a.address_id; 

-- 6b Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) AS 'Total amount'
from staff s left join payment p  on s.staff_id = p.staff_id
where payment_date between cast('2005-08-01' as date) and cast('2005-08-31' as date)
group by s.staff_id;

-- 6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(a.actor_id) as 'Number of actors' 
from film f inner join film_actor a on f.film_id = a.film_id
group by f.film_id; 

-- 6d How many copies of the film Hunchback Impossible exist in the inventory system?
select count(film_id) as 'Number of Copies' from inventory 
where film_id =
	(select film_id from film
	where title = 'Hunchback Impossible');

-- 6e Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
select c.first_name, c.last_name, sum(p.amount) as 'Total amount paid' 
from customer c inner join payment p on c.customer_id = p.customer_id
group by c.customer_id
order by c.last_name;

-- 7a Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film
where title like 'K%' or title like 'Q%'
and language_id =
	(select language_id from language where name = 'English');

-- 7b Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor 
where actor_id in 
	(select actor_id from film_actor 
	where film_id = 
		(select film_id from film
		where title = 'Alone Trip')
	);

-- 7c You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email from customer c 
	join address a ON (c.address_id = a.address_id)
where city_id in (select city_id from city where country_id = 
		(select country_id from country where country = 'Canada'));
 
-- 7d  Identify all movies categorized as family films.
select title from film 
where film_id in 
	(select film_id from film_category
	where category_id = 
		(select category_id from category
		where name = 'Family')
	); 
    
-- 7e Display the most frequently rented movies in descending order.
select f.title, r.rental_date from rental r 
join inventory i on (i.inventory_id = r.inventory_id) 
join film f on (f.film_id = i.film_id)
order by rental_date desc; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as 'Revenue' from payment p
join staff s on (p.staff_id=s.staff_id)
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country from store s
join address a on (s.address_id=a.address_id)
join city c on (a.city_id=c.city_id)
join country co on (c.country_id=co.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name as "Top Five Genres", sum(p.amount) as "Gross Revenue" from category c
join film_category fc on (c.category_id=fc.category_id)
join inventory i on (fc.film_id=i.film_id)
join rental r on (i.inventory_id=r.inventory_id)
join payment p on (r.rental_id=p.rental_id)
group by c.name 
order by sum(p.amount) desc Limit 5;

-- 8a. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view topfivegenres as 	
    select c.name as "Top Five Genres", sum(p.amount) as "Gross Revenue" from category c
	join film_category fc on (c.category_id=fc.category_id)
	join inventory i on (fc.film_id=i.film_id)
	join rental r on (i.inventory_id=r.inventory_id)
	join payment p on (r.rental_id=p.rental_id)	
	group by c.name 
	order by sum(p.amount) desc Limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from topfivegenres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view topfivegenres;

 
 
 