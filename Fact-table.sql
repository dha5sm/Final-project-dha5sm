Use sakila;
DROP TABLE IF EXISTS Fact_Rental;

CREATE TABLE Fact_Rental (
    Rental_ID INT PRIMARY KEY,
    Rental_Date DATETIME,
    Return_Date DATETIME,
    Customer_ID SMALLINT UNSIGNED,
    Staff_ID TINYINT UNSIGNED,
    Film_ID MEDIUMINT UNSIGNED,
    Store_ID TINYINT UNSIGNED,
    Rental_Duration INT, -- Duration of the rental in days
    Rental_Revenue DECIMAL(10, 2), -- Total revenue from the rental
    Late_Fee DECIMAL(10, 2), -- Fee charged for late return
    FOREIGN KEY (Customer_ID) REFERENCES customer (customer_id),
    FOREIGN KEY (Staff_ID) REFERENCES staff (staff_id),
    FOREIGN KEY (Film_ID) REFERENCES inventory (inventory_id),
    FOREIGN KEY (Store_ID) REFERENCES store (store_id)
);

-- Populate Fact_Rental with data from sakila tables
INSERT INTO Fact_Rental (Rental_ID, Rental_Date, Return_Date, Customer_ID, Staff_ID, Film_ID, Store_ID, Rental_Duration, Rental_Revenue, Late_Fee)
SELECT 
    r.rental_id,
    r.rental_date,
    r.return_date,
    r.customer_id,
    r.staff_id,
    i.film_id,
    i.store_id,
    -- Calculate Rental_Duration in days
    DATEDIFF(r.return_date, r.rental_date) AS Rental_Duration,
    -- Use payment.amount as Rental_Revenue
    p.amount AS Rental_Revenue,
    -- Calculate Late_Fee: Assume fee applies if the rental duration exceeds the rental duration in the film table
    CASE 
        WHEN DATEDIFF(r.return_date, r.rental_date) > f.rental_duration 
        THEN (DATEDIFF(r.return_date, r.rental_date) - f.rental_duration) * f.rental_rate
        ELSE 0
    END AS Late_Fee
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id;

-- First Partition
SELECT * 
FROM Fact_Rental
WHERE Rental_Date BETWEEN '2005-05-24 22:53:30' AND '2005-05-26 22:53:30';

-- Second Partition
SELECT * 
FROM Fact_Rental
WHERE DATE(Rental_Date) BETWEEN '2005-05-26 22:53:30' AND '2005-05-28 22:53:30';

-- Third Partition
SELECT * 
FROM Fact_Rental
WHERE Rental_Date BETWEEN '2005-05-28 22:53:30' AND '2005-05-31 22:53:30';

SELECT * 
FROM Fact_Rental