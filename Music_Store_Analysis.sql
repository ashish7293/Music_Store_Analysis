--Question Set 1 - Easy 



--Q1: Who is the senior most employee based on job title?
SELECT top(1) *
  FROM [Music_Store_Project].[dbo].[employee]
  order by 6 desc;


--Q2: Which countries have the most Invoices? */

select billing_country, count(invoice_id) as invoice_count 
from dbo.invoice
group by billing_country
order by 2 desc;


--Q3: What are top 3 values of total invoice? 

Select top(3) invoice_id, total
from dbo.invoice
order by total desc;


/*			Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, billing_state, sum(total) 
from dbo.invoice 
group by billing_city, billing_state
order by 3 desc;


/*			Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select top(1) c.first_name, c.last_name, i.customer_id, sum(total) total
from dbo.invoice i join dbo.customer c on i.customer_id = c.customer_id
group by i.customer_id, c.first_name, c.last_name
order by total desc;

			Question Set 2 - Moderate


/*			Q1: Write query to return the email, first name and last name of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct c.email, c.first_name, c.last_name
from dbo.customer c join dbo.invoice i on c.customer_id = i.customer_id
					join dbo.invoice_line il on i.invoice_id = il.invoice_id
					join dbo.track t on t.track_id = il.track_id
where il.track_id in (select t.track_id from dbo.track t join dbo.genre g on t.genre_id = g.genre_id where g.name like '%rock%')
order by 1;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select top(10) a.name, count(t.track_id)
from dbo.artist a join dbo.album al on a.artist_id = al.artist_id
				  join dbo.track t on al.album_id = t.album_id
				  join dbo.genre g on t.genre_id = g.genre_id
where g.name like '%rock%'
group by a.name
order by 2 desc;



/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


select name, milliseconds
from dbo.track
where milliseconds > (select avg(milliseconds) from track)
order by 2 desc;

/* Question Set 3 - Advance */

--Q1: Find how much amount spent by each customer on best selling artists? Write a query to return customer name, artist name and total spent

with best_selling_artist as (
SELECT ar.artist_id AS artist_id, ar.name AS artist_name, SUM(il.unit_price*il.quantity) AS total_sales
FROM invoice_line il JOIN track t ON il.track_id = t.track_id
					 JOIN album al ON al.album_id = t.album_id
					 JOIN artist ar ON ar.artist_id = al.artist_id
GROUP BY ar.artist_id,ar.name
)
select c.customer_id , c.first_name,c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as total_spent
from dbo.customer c join dbo.invoice i on c.customer_id = i.customer_id
					join dbo.invoice_line il on i.invoice_id = il.invoice_id
					join dbo.track t on t.track_id = il.track_id
					join dbo.album al on al.album_id = t.album_id
					join best_selling_artist bsa on bsa.artist_id = al.artist_id
group by c.customer_id , c.first_name,c.last_name, bsa.artist_name
order by 5 desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


with country_genre as (
select RANK() over (partition by c.country order by count(il.quantity) desc) as rn, c.country,g.genre_id ,g.name as genre, count(il.quantity) as purchase_quant
from dbo.customer c join dbo.invoice i on c.customer_id = i.customer_id
					join dbo.invoice_line il  on i.invoice_id = il.invoice_id
					join dbo.track t on il.track_id = t.track_id
					join dbo.genre g on t.genre_id = g.genre_id
group by c.country, g.genre_id,g.name
)

select country, genre from country_genre where rn = 1



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


with country_customer_ranking as (
select c.country,
Rank() over (partition by c.country order by sum(i.total) desc) as rn,
c.first_name,c.last_name, sum(i.total) as spent
from dbo.customer c join dbo.invoice i on c.customer_id = i.customer_id
group by c.country,c.first_name,c.last_name
)
select first_name, last_name, country, spent from country_customer_ranking where rn = 1

