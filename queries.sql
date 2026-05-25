-- Q01. Active driver headcount.

SELECT COUNT(*) AS active_driver_count
FROM driver
WHERE left_date IS NULL;



-- Q02. Total platform GMV.

SELECT ROUND(SUM(amount),2) AS total_gmv
FROM payment
WHERE status = 'succeeded';



-- Q03. Total refund exposure.

SELECT ROUND(SUM(amount),2) AS total_refunded
FROM payment
WHERE status = 'refunded';





-- Q04. Customer base split.

SELECT
    customer_type,
    COUNT(*) AS customer_count
FROM customer
GROUP BY customer_type
ORDER BY customer_type ASC
LIMIT 5;





-- Q05. Voucher pool size.

SELECT
    COUNT(DISTINCT rider_customer_id)
    AS voucher_eligible_customer_count
FROM trip
WHERE LOWER(TRIM(status)) IN (
    'cancelled_by_rider',
    'cancelled_by_driver',
    'aborted',
    'no_show',
    'noshow'
);







-- Q06. Busiest pickup zones.

SELECT
    z.zone_name,
    COUNT(*) AS trip_count
FROM trip t
JOIN zone z
ON t.pickup_zone_id = z.zone_id
GROUP BY z.zone_name
ORDER BY trip_count DESC,
z.zone_name ASC
LIMIT 10;






-- Q07. Average ride fare by source.

SELECT
    t.source_system,
    ROUND(AVG(p.amount),2)
    AS avg_ride_fare
FROM payment p
JOIN trip t
ON p.service_id = t.trip_id::text
WHERE p.status = 'succeeded'
AND p.service_type = 'ride'
GROUP BY t.source_system
ORDER BY avg_ride_fare DESC,
t.source_system ASC
LIMIT 5;








-- Q08. Payment success rate by service.

SELECT
    service_type,
    COUNT(*) AS total_attempts,
    SUM(
        CASE
            WHEN status='succeeded'
            THEN 1
            ELSE 0
        END
    ) AS successful_attempts,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN status='succeeded'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate
FROM payment
GROUP BY service_type
ORDER BY success_rate DESC,
service_type ASC
LIMIT 5;







-- Q09. Trip outcome breakdown.

SELECT
    CASE
        WHEN LOWER(TRIM(status))='finished'
        THEN 'completed'
        WHEN LOWER(TRIM(status))='aborted'
        THEN 'cancelled'
        WHEN LOWER(TRIM(status))='noshow'
        THEN 'no_show'
        ELSE LOWER(TRIM(status))
    END AS normalized_status,
    COUNT(*) AS trip_count
FROM trip
GROUP BY normalized_status
ORDER BY normalized_status ASC
LIMIT 10;







-- Q10. Premium fare zones.

SELECT
    z.zone_name,
    COUNT(*) AS completed_ride_count,
    ROUND(AVG(p.amount),2)
    AS avg_fare
FROM payment p
JOIN trip t
ON p.service_id = t.trip_id::text
JOIN zone z
ON t.pickup_zone_id = z.zone_id
WHERE p.status='succeeded'
AND p.service_type='ride'
GROUP BY z.zone_name
ORDER BY avg_fare DESC,
z.zone_name ASC
LIMIT 10;








-- Q11. Top earning drivers.\

SELECT
    d.driver_id,
    d.driver_name,
    ROUND(SUM(p.amount),2)
    AS total_earnings
FROM driver d
JOIN trip t
ON d.driver_id = t.driver_id
JOIN payment p
ON p.service_id = t.trip_id::text
WHERE p.status='succeeded'
AND p.service_type='ride'
GROUP BY d.driver_id,
d.driver_name
ORDER BY total_earnings DESC,
d.driver_id ASC
LIMIT 10;







-- Q12. Average customer rating by source.

SELECT
    source_system,
    ROUND(
        AVG(
            CASE
                WHEN source_system='quickhop'
                THEN score/2.0
                ELSE score
            END
        ),
        2
    ) AS avg_rating
FROM rating
GROUP BY source_system
ORDER BY avg_rating DESC,
source_system ASC
LIMIT 5;






-- Q13. Most active customers.

SELECT
    c.customer_id,
    c.name,
    COUNT(t.trip_id)
    AS total_trips
FROM customer c
JOIN trip t
ON c.customer_id = t.rider_customer_id
GROUP BY c.customer_id,
c.name
ORDER BY total_trips DESC,
c.customer_id ASC
LIMIT 10;










-- Q14. Drivers with highest completed trips.

SELECT
    d.driver_id,
    d.driver_name,
    COUNT(t.trip_id) AS completed_trip_count
FROM driver d
JOIN trip t
ON d.driver_id = t.driver_id
WHERE LOWER(TRIM(t.status)) IN (
    'completed',
    'finished'
)
GROUP BY d.driver_id,
d.driver_name
ORDER BY completed_trip_count DESC,
d.driver_id ASC
LIMIT 10;




-- Q15. Business customers sending parcels.

SELECT
    c.customer_id,
    c.business_name,
    COUNT(pd.delivery_id) AS total_packages
FROM customer c
JOIN package_delivery pd
ON c.customer_id = pd.sender_customer_id
WHERE LOWER(TRIM(c.customer_type)) = 'business'
GROUP BY c.customer_id,
c.business_name
ORDER BY total_packages DESC,
c.customer_id ASC
LIMIT 10;



-- Q16. Revenue by pickup zone.

SELECT
    z.zone_name,
    ROUND(SUM(p.amount),2) AS total_revenue
FROM payment p
JOIN trip t
ON p.service_id = t.trip_id::text
JOIN zone z
ON t.pickup_zone_id = z.zone_id
WHERE p.status = 'succeeded'
AND p.service_type = 'ride'
GROUP BY z.zone_name
ORDER BY total_revenue DESC,
z.zone_name ASC
LIMIT 10;




-- Q17. Average trip fare by source system.

SELECT
    source_system,
    ROUND(AVG(fare_amount),2) AS avg_trip_fare
FROM trip
GROUP BY source_system
ORDER BY avg_trip_fare DESC,
source_system ASC
LIMIT 5;




-- Q18. Monthly successful payment revenue.

SELECT
    DATE_TRUNC('month', attempted_at) AS revenue_month,
    ROUND(SUM(amount),2) AS monthly_revenue
FROM payment
WHERE status = 'succeeded'
GROUP BY revenue_month
ORDER BY revenue_month ASC
LIMIT 12;




-- Q19. Drivers using multiple vehicles.

SELECT
    d.driver_id,
    d.driver_name,
    COUNT(DISTINCT dva.vehicle_id) AS vehicle_count
FROM driver d
JOIN driver_vehicle_assignment dva
ON d.driver_id = dva.driver_id
GROUP BY d.driver_id,
d.driver_name
HAVING COUNT(DISTINCT dva.vehicle_id) > 1
ORDER BY vehicle_count DESC,
d.driver_id ASC
LIMIT 10;






-- Q20. Top parcel pickup zones.

SELECT
    z.zone_name,
    COUNT(pd.delivery_id) AS package_count
FROM package_delivery pd
JOIN zone z
ON pd.pickup_zone_id = z.zone_id
GROUP BY z.zone_name
ORDER BY package_count DESC,
z.zone_name ASC
LIMIT 10;






-- Q21. Customers with both trips and parcel deliveries.

SELECT
    c.customer_id,
    c.name
FROM customer c
WHERE c.customer_id IN (
    SELECT rider_customer_id
    FROM trip
)
AND c.customer_id IN (
    SELECT sender_customer_id
    FROM package_delivery
)
ORDER BY c.customer_id ASC
LIMIT 10;






-- Q22. Highest rated services by source system.

SELECT
    source_system,
    ROUND(
        AVG(
            CASE
                WHEN source_system = 'quickhop'
                THEN score / 2.0
                ELSE score
            END
        ),
        2
    ) AS avg_rating
FROM rating
GROUP BY source_system
ORDER BY avg_rating DESC,
source_system ASC
LIMIT 5;







-- Q23. Highest grossing business customers.

SELECT
    c.customer_id,
    c.business_name,
    ROUND(SUM(p.amount),2) AS total_spend
FROM customer c
JOIN package_delivery pd
ON c.customer_id = pd.sender_customer_id
JOIN payment p
ON p.service_id = pd.delivery_id::text
WHERE LOWER(TRIM(c.customer_type)) = 'business'
AND p.status = 'succeeded'
GROUP BY c.customer_id,
c.business_name
ORDER BY total_spend DESC,
c.customer_id ASC
LIMIT 10;







-- Q24. Most active drivers by total services.

SELECT
    d.driver_id,
    d.driver_name,
    (
        COUNT(DISTINCT t.trip_id)
        +
        COUNT(DISTINCT pd.delivery_id)
    ) AS total_services
FROM driver d
LEFT JOIN trip t
ON d.driver_id = t.driver_id
LEFT JOIN package_delivery pd
ON d.driver_id = pd.driver_id
GROUP BY d.driver_id,
d.driver_name
ORDER BY total_services DESC,
d.driver_id ASC
LIMIT 10;







-- Q25. Cross-platform duplicate customers.

SELECT
    LOWER(TRIM(name)) AS normalized_name,
    COUNT(*) AS duplicate_count
FROM customer
GROUP BY normalized_name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC,
normalized_name ASC
LIMIT 10;




