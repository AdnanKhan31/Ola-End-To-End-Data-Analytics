CREATE TABLE ola_rides
ride_date DATE,
ride_time TIME,
booking_id VARCHAR (120),
booking_status CHAR (50),
customer_ID VARCHAR (50),
vehicle_type CHAR (50),
pickup_location CHAR (50),
drop_location VARCHAR (50),
avg_VTAT Numeric,
avg_CTAT Numeric,
cancelled_rides_by_customer Numeric,
reason_for_cancelling_by_customer CHAR (50),
cancelled_rides_by_driver Numeric,
driver_cancellation_reason CHAR (25),
incomplete_rides Numeric,
incomplete_rides_reason Numeric,
booking_value Numeric,
ride_distance Numeric,
driver_ratings Numeric,
customer_ratings Numeric,
payment_method VARCHAR (250),
);

select * from Ola_rides

Q1. Find the total number of Ola bookings for each day.
SELECT * FROM Booking_trend
select ride_date,
count(booking_id) as total_bookings
from ola_rides
group by ride_date
order by total_bookings DESC;

Q2. Find the total number of Ola bookings for each day of the week and each hour.
SELECT * FROM Booking_day_time
SELECT 
EXTRACT(DOW FROM ride_date) AS day_of_week,
COUNT(booking_id) AS total_bookings
FROM ola_rides
GROUP BY 
EXTRACT(DOW FROM ride_date)
ORDER BY day_of_week;

Q3. Find the number and percentage of Completed, Incomplete, Customer Cancelled, and Driver Cancelled rides for each day.
SELECT * FROM Ride_status_trend
select ride_date, booking_status,
count(booking_id) as total_rides,
round(count(booking_id) * 100.0 /
sum(count(booking_id)) over (partition by  ride_date),
2 ) as ride_percentage
from Ola_rides
group by ride_date,booking_status
order by ride_date;

Q4. Find the total bookings and completed rides for each pickup location.
SELECT * FROM Location_completion
SELECT pickup_location,
COUNT(booking_id) AS total_rides,
SUM(CASE 
WHEN booking_status = 'Completed' THEN ELSE 0
END) AS completed_rides,
ROUND(
SUM(CASE 
WHEN booking_status = 'Completed' THEN 1 ELSE 0
END) * 100.0 / COUNT(booking_id), 2
) AS completion_rate
FROM ola_rides
GROUP BY pickup_location;

Q5. Find the total bookings, completed rides, and cancelled rides for each payment method.
SELECT * FROM Payment_analysis
select payment_method,
count(booking_id) as total_bookings,
sum(case when booking_status='Completed' then 1
else 0 end) as completed_rides,
sum(case 
when booking_status LIKE 'Cancel%'
or booking_status='Cancelled by Drivers' then 1 
else 0 end) as Cancelled_rides
from ola_rides
group by payment_method
order by total_bookings DESC;

Q6. Find the total customer cancellations for each pickup location and cancellation reason.
SELECT * FROM Customer_cancel
select pickup_location,reason_for_cancelling_by_customer,
count(booking_id) as total_cancellations
from ola_rides
where booking_status='Cancelled by Customer'
group by pickup_location,reason_for_cancelling_by_customer
order by total_cancellations desc;


Q7. Find the number of customer cancellations and driver cancellations for each vehicle type.
SELECT * FROM Vehicle_cancel
select vehicle_type,
sum(case 
when booking_status='Cancelled by Customer' then 1 
else 0 end) 
as Customer_cancellations,
sum(case
when booking_status='Cancelled by Driver' then 1
else 0 end) 
as Driver_cancellations
from Ola_rides
group by vehicle_type;

Q8. Find the average booking value for different ride distances.
SELECT * FROM Distance_value	
select ride_distance,
count(booking_id) as total_bookings,
round(avg(booking_value),2) as avg_booking_value
from ola_rides
where booking_status='Completed'
group by ride_distance;

Q9. Find the average VTAT, average CTAT, customer rating, and number of cancellations for each vehicle type.
SELECT * FROM Vehicle_performance
select vehicle_type,
round(avg(avg_vtat),2) as Average_VTAT,
round(avg(avg_ctat),2) as Average_CTAT,
round(avg(customer_ratings),2) as Average_customer_ratings,
sum(case 
when booking_status='Cancel%'
or booking_status='Cancelled by Driver' then 1 
else 0 end) as total_cancellations
from ola_rides
group by vehicle_type;

Q10. Find the total bookings and average customer rating for each pickup location.
SELECT * FROM Location_rating
select pickup_location,
count(booking_id) as total_bookings,
round(avg(customer_ratings),2) as Average_customer_ratings
from ola_rides
group by pickup_location;

Q11. Find the vehicle types, payment methods, and pickup locations associated with bookings above the average booking value.
SELECT * FROM High_value_booking
select vehicle_type, payment_method, pickup_location,
round(avg(booking_value),2) as Average_booking_value,
count(booking_id) as total_bookings
from ola_rides
group by
vehicle_type,payment_method, pickup_location;

Q12. Find the vehicle type, pickup location, and hour with the highest number of cancelled and incomplete rides.
SELECT * FROM Problem_areas
select vehicle_type, pickup_location,
extract(hour from ride_time) as ride_hour,
count(booking_id) as total_rides
from ola_rides
where booking_status IN(
'Cancelled by Customer',
'Cancelled by Driver',
'Incomplete'
)
group by 
vehicle_type, 
pickup_location,
extract(hour from ride_time);

Q13. Find the pickup locations with high bookings, low customer ratings, and a high number of unsuccessful rides.
SELECT * FROM Location_performance
select pickup_location,
count(booking_id) as total_bookings,
round(avg(customer_ratings),2) as Average_customer_ratings,
sum(case
when booking_status='Completed' then 1
else 0 end )
as  Unsuccessful_rides
from ola_rides
group by pickup_location
order by total_bookings DESC;

Q14. Find the vehicle type and pickup location combinations with high booking value, high ratings, and fewer unsuccessful rides.
SELECT * FROM Vehicle_location_value
select vehicle_type, pickup_location,
count(booking_id) as total_bookings,
round(sum(booking_value),2) as Total_booking_value,
round(avg(customer_ratings),2) as Average_Customer_Ratings,
sum(case
when booking_status='Incomplete' then 1
else 0 end)
as Unsuccessful_rides
from ola_rides
group by vehicle_type, pickup_location
order by total_booking_value DESC;             

Q15. Find the most common booking problems, customer cancellation reasons, and driver cancellation reasons.
SELECT * FROM Booking_problem_status
select booking_status,
count(booking_id) as total_bookings
from ola_rides
group by booking_status
order by total_bookings DESC;

SELECT * FROM Customer_cancel_reasons
select reason_for_cancelling_by_customer,
count(booking_id)as total_cancellations
from ola_rides
where booking_status='Cancelled by Customer'
group by reason_for_cancelling_by_customer;

SELECT * FROM Driver_cancellation_reason;
select driver_cancellation_reason,
count(booking_id)as total_cancellations
from ola_rides
where booking_status='Cancelled by Driver'
group by driver_cancellation_reason;
