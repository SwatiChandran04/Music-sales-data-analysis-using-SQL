#Q1: Who is the senior most employee based on job title?
use music_database;

select * from employee
order by levels desc
limit 1;

#Q2: Which countries have the most invoices?
select count(*) as c, billing_country 
from invoice
group by billing_country
order by c desc;

#Q3: What are the top 3 values of total invoices?
select * from invoice
order by total desc
limit 3;

#Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money the most. 
# Write a query that returns one city that has the highest sum of invoice totals.
# Return both the city name ansd sum of all invoice totals
select billing_city, sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc
limit 1;

#Q5: Who is the best customer? The customer who has spent the most money will be decalred the best customer.
# Write a query that returns the person who has spent the most money.
select customer.customer_id, any_value(customer.first_name),any_value(customer.last_name),sum(invoice.total) as total_invoice from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total_invoice desc
limit 1;

#Q6: Write query to return the email, first name, last name and genre of all rock music listeners. 
# Return your list ordered alphabetically by email starting with A
select distinct customer.email,customer.first_name,customer.last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
    join genre on track.genre_id = genre.genre_id
    where genre.name like'Rock'
)
ORDER BY email;

#Q7: Let's invite the artists who have written the most rock music in our dataset. 
# Write a query that returns the Artist nmae and total track count of all the top 10 rock bands
select any_value(artist.artist_id), any_value(artist.name), count(artist.artist_id) as number_of_songs from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
order by number_of_songs Desc
limit 10;

#Q8: Return all the track names that have a song length longer than the average song lerngth.
#Return the name and milliseconds for each track. Order by the song length with the longest songs
#listed first
Select name, milliseconds
from track
where milliseconds>(
	select avg(milliseconds) as avg_track_length
    from track)
order by milliseconds desc;


#Q9: Find how much amount spent by each customers on artists? 
# Write a query to return customer name, artist name and total spent

WITH best_selling_artist AS(
	SELECT any_value(artist.artist_id)
    AS artist_id, any_value(artist.name) AS artist_name,
    SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 1
)
SELECT any_value(c.customer_id), any_value(c.first_name), any_value(c.last_name), any_value(bsa.artist_name),
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i 
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

#Q10: We want to find out the most popular music genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
# Write a query that returns each country along with top genre.
# For countries where the maximum number of purchases is shared return all genres.

WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Rowno
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY 2,3,4
    ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



    




    
