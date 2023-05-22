create database restaurant;
use restaurant;
create database sales_and_delivery;
use sales_and_delivery;

-- Question 1: Find the top 3 customers who have the maximum number of 
-- orders.
select Cust_id,count(Ord_id) from market_fact
group by Cust_id
order by count(Ord_id) desc limit 3;

-- Question 2: Create a new column DaysTakenForDelivery that 
-- contains the date difference between Order_Date and Ship_Date.
select *,
datediff(str_to_date(ship_date,"%d-%m-%Y"),str_to_date(order_date,"%d-%m-%Y"))DaysTakenForDelivery
from orders_dimen o join shipping_dimen s
on o.order_id=s.order_id
order by DaysTakenForDelivery desc;

-- Question 3: Find the customer whose order took the maximum time 
-- to get delivered.
select * from 
(select c.Customer_Name,c.Cust_id,o.Order_ID,
datediff(str_to_date(ship_date,"%d-%m-%Y"),str_to_date(order_date,"%d-%m-%Y"))DaysTakenForDelivery
from orders_dimen o join shipping_dimen s
on o.order_id=s.order_id
join market_fact m on o.Ord_id=m.Ord_id
join cust_dimen c on m.Cust_id=c.Cust_id
order by DaysTakenForDelivery desc)t
limit 1;




-- for 3rd value use nth_value function
/*
Question 4: Retrieve total sales made by each product from the data (use Windows function)
*/
select distinct Prod_id,
sum(sales)over(partition by prod_id order by prod_id desc) total_sales
from market_fact
;

/*
Question 5: Retrieve the total profit made from each product from the data (use windows function)
*/
select   distinct prod_id, sum(profit)over(partition by prod_id) as total_profit 
from market_fact;

/*
Question 6: Count the total number of unique customers in January and how many of 
them came back every month over the entire year in 2011
*/

select count(distinct c.Cust_id) from cust_dimen c
join market_fact m on c.Cust_id=m.Cust_id
join orders_dimen o on m.Ord_id=o.Ord_id
where monthname(str_to_date(o.Order_Date,"%d-%m-%Y"))="january" and 
year(str_to_date(o.Order_Date,"%d-%m-%Y"))=2011;

-- restaurant
use restaurant;
select * from chefmozcuisine
group by Rcuisine
order by Rcuisine 
;
select * from chefmozparking;
select * from geoplaces2;

/*
Question 1: - We need to find out the total visits to all restaurants under all 
alcohol categories 
available
*/
select count(u.userID),g.placeID,g.alcohol from geoplaces2 g
join rating_final r on g.placeID=r.placeID
join userprofile u on r.userID=u.userID
group by g.alcohol;

/*
Question 2: -Let's find out the average rating according to alcohol and 
price so that we can understand the rating in respective price categories as well.
*/
select r.placeID,avg(r.rating),g.alcohol,g.price
from geoplaces2 g join rating_final r
on g.placeID=r.placeID
group by g.price,g.alcohol
order by g.price;

/*
Question 3:  Let’s write a query to quantify that what are the parking availability as well in 
different alcohol categories along with the total number of restaurants.
*/
select g.placeID,c.parking_lot,g.alcohol,
count(g.placeid)over(order by g.placeid desc)
from chefmozparking c join geoplaces2 g
group by g.alcohol,c.parking_lot;

/*
Question 4: -Also take out the percentage of different cuisine in each alcohol type.
*/
select * from
 (select *,(no_cuisine/no_alcohol) * 100 as percentage_cuisine from (
select alcohol,rcuisine,count(rcuisine)over(partition by alcohol,rcuisine) no_cuisine,
count(alcohol)over(partition by alcohol) no_alcohol
 from geoplaces2 g join chefmozcuisine c on g.placeID=c.placeID)t)t1
 group  by alcohol,rcuisine;

/*
Questions 5: - let’s take out the average rating of each state.
*/
select g.state,avg(r.rating)
from geoplaces2 g join rating_final r
on g.placeID=r.placeID
group by state;

/*
Questions 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is 
the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.
*/
select g.state,g.alcohol,c.Rcuisine
from geoplaces2 g join chefmozcuisine c
on g.placeID=c.placeID
where g.state like "Tamaulipas" ;

/*
Question 7:  - Find the average weight, food rating, and service rating of the customers who 
have visited KFC and tried Mexican or Italian types of cuisine, and also their budget level is low.
We encourage you to give it a try by not using joins.
*/
select distinct u.userid,avg(weight) over(),name,food_rating,service_rating 
from userprofile u join rating_final r using(userid) 
join geoplaces2 g using(placeid)join usercuisine uc using(userid)
where name='kfc' and Rcuisine in ('mexican','italian') and budget='low';





-- Part 3 - Triggers
/* Question 1:
-- Create two called Student_details and Student_details_backup.
Problem:

Let’s say you are studying SQL for two weeks. In your institute, there is an employee who 
has been maintaining the student’s details and Student Details Backup tables. He / She is 
deleting the records from the Student details after the students completed the course and 
keeping the backup in the student details backup table by inserting the records every time.
 You are noticing this daily and now you want to help him/her by not inserting the records 
 for backup purpose when he/she delete the records.write a trigger that should be capable 
 enough to insert the student details in the backup table whenever the employee deletes 
 records from the student details table.

Note: Your query should insert the rows in the backup table before deleting the 
records from student details.
*/
CREATE TABLE  student_details(
student_id int ,
student_name varchar(50),
mail_id varchar(50),
mobile bigint
); 

insert into student_details values
(1,'ram','ram@gmail.com',988766666),
(2,'shyam','shyam@gmail.com',9883436666),
(3,'jayant','jayant@gmail.com',9887123446),
(4,'mahesh','mahesh@gmail.com',988767896),
(5,'kamal','kamal@gmail.com',956789666);

create table student_details_backup(  
student_id int ,
student_name varchar(50),
mail_id varchar(50),
mobile bigint
); 

delimiter //
create trigger delete_in
after delete on student_details
for each row
begin
insert into student_details_backup values(old.student_id,old.student_name,old.mail_id,old.mobile);
end //

delete from student_details where student_id = 4;

select * from  student_details;
select * from student_details_backup;
truncate student_details_backup
drop trigger delete_in


use restaurant;
select *,dense_rank()over( order by total_rating desc) as rnk from
(select rcuisine, avg(rating) as total_rating from chefmozcuisine c 
join rating_final r using(placeid)
group by rcuisine
order by avg(rating) desc)t

select region,count(region)from cust_dimen
group by region
order by count(region) desc
limit 5;


with temp as 
(select placeId, g.name, g.address, g.city, g.state, g.country, r.rating, r.food_rating, r.service_rating,
dense_rank()over(partition by g.city order by r.food_rating desc) as Dns_Rnk 
from geoplaces2 g join rating_final r using(placeID) where city<>'?')
Select * from temp where Dns_Rnk=1;































































































































