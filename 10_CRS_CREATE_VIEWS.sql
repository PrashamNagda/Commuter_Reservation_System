-- ============================================
-- SCRIPT 10_PRACTICAL_VIEWS.sql
-- Run as CRS_ADMIN
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

SHOW USER;

-- Drop existing views
BEGIN EXECUTE IMMEDIATE 'DROP VIEW vw_booking_summary'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW vw_train_revenue'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW vw_passenger_summary'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW vw_seat_utilization'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW vw_waitlist_dashboard'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ============================================
-- VIEW 1: Complete Booking Summary by Train and Class
-- ============================================
CREATE OR REPLACE VIEW vw_booking_summary AS
SELECT 
    t.train_number,
    t.source_station || ' → ' || t.dest_station AS route,
    r.seat_class,
    
    -- Passenger Category Breakdown
    COUNT(CASE WHEN p.date_of_birth IS NOT NULL AND 
               FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) < 18 
               THEN 1 END) AS minor_passengers,
    COUNT(CASE WHEN p.date_of_birth IS NOT NULL AND 
               FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) BETWEEN 18 AND 59 
               THEN 1 END) AS adult_passengers,
    COUNT(CASE WHEN p.date_of_birth IS NOT NULL AND 
               FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) >= 60 
               THEN 1 END) AS senior_passengers,
    
    -- Booking Status Breakdown
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed_bookings,
    COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) AS waitlisted_bookings,
    COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) AS cancelled_bookings,
    COUNT(*) AS total_bookings,
    
    -- Capacity Info
    CASE r.seat_class
        WHEN 'BUSINESS' THEN t.total_fc_seats
        ELSE t.total_econ_seats
    END AS total_capacity,
    
    CASE r.seat_class
        WHEN 'BUSINESS' THEN t.total_fc_seats
        ELSE t.total_econ_seats
    END - COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS seats_available,
    
    -- Revenue
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 
    CASE r.seat_class
        WHEN 'BUSINESS' THEN t.fc_seat_fare
        ELSE t.econ_seat_fare
    END AS confirmed_revenue,
    
    -- Performance Indicator
    ROUND(
        (COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0) / 
        CASE r.seat_class WHEN 'BUSINESS' THEN t.total_fc_seats ELSE t.total_econ_seats END, 
        1
    ) AS occupancy_percent

FROM CRS_TRAIN_INFO t
LEFT JOIN CRS_RESERVATION r ON t.train_id = r.train_id
LEFT JOIN CRS_PASSENGER p ON r.passenger_id = p.passenger_id
WHERE r.booking_id IS NOT NULL
GROUP BY t.train_number, t.source_station, t.dest_station, r.seat_class, 
         t.total_fc_seats, t.total_econ_seats, t.fc_seat_fare, t.econ_seat_fare
ORDER BY t.train_number, r.seat_class;


-- ============================================
-- VIEW 2: Train Revenue Analysis
-- Shows which trains are profitable
-- ============================================
CREATE OR REPLACE VIEW vw_train_revenue AS
SELECT t.train_number,
    t.source_station || ' → ' || t.dest_station AS route,
    
    -- Business Class Stats
    COUNT(CASE WHEN r.seat_class = 'BUSINESS' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS business_tickets_sold,
    COUNT(CASE WHEN r.seat_class = 'BUSINESS' AND r.seat_status = 'CONFIRMED' THEN 1 END) * t.fc_seat_fare AS business_revenue,
    
    -- Economy Class Stats
    COUNT(CASE WHEN r.seat_class = 'ECONOMY' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS economy_tickets_sold,
    COUNT(CASE WHEN r.seat_class = 'ECONOMY' AND r.seat_status = 'CONFIRMED' THEN 1 END) * t.econ_seat_fare AS economy_revenue,
    
    -- Total Stats
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS total_tickets_sold,
    (COUNT(CASE WHEN r.seat_class = 'BUSINESS' AND r.seat_status = 'CONFIRMED' THEN 1 END) * t.fc_seat_fare) +
    (COUNT(CASE WHEN r.seat_class = 'ECONOMY' AND r.seat_status = 'CONFIRMED' THEN 1 END) * t.econ_seat_fare) AS total_revenue,
    
    -- Lost Revenue from Cancellations
    COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) AS cancelled_tickets,
    (COUNT(CASE WHEN r.seat_class = 'BUSINESS' AND r.seat_status = 'CANCELLED' THEN 1 END) * t.fc_seat_fare) +
    (COUNT(CASE WHEN r.seat_class = 'ECONOMY' AND r.seat_status = 'CANCELLED' THEN 1 END) * t.econ_seat_fare) AS revenue_lost

FROM CRS_TRAIN_INFO t
LEFT JOIN CRS_RESERVATION r ON t.train_id = r.train_id
GROUP BY t.train_number, t.source_station, t.dest_station, t.fc_seat_fare, t.econ_seat_fare
HAVING COUNT(r.booking_id) > 0
ORDER BY total_revenue DESC;

-- ============================================
-- VIEW 3: Passenger Activity Summary
-- Know your customers
-- ============================================
CREATE OR REPLACE VIEW vw_passenger_summary AS
SELECT 
    p.passenger_id,
    p.first_name || ' ' || p.last_name AS passenger_name,
    p.email,
    p.phone,
    
    -- Age Category
    CASE 
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) < 18 THEN 'MINOR'
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) >= 60 THEN 'SENIOR'
        ELSE 'ADULT'
    END AS age_category,
    
    FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) AS age,
    
    -- Booking Stats
    COUNT(r.booking_id) AS total_bookings,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed_bookings,
    COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) AS waitlisted_bookings,
    COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) AS cancelled_bookings,
    
    -- Class Preference
    COUNT(CASE WHEN r.seat_class = 'BUSINESS' THEN 1 END) AS business_bookings,
    COUNT(CASE WHEN r.seat_class = 'ECONOMY' THEN 1 END) AS economy_bookings,
    
    -- Revenue Contribution
    SUM(CASE 
        WHEN r.seat_status = 'CONFIRMED' THEN 
            CASE r.seat_class
                WHEN 'BUSINESS' THEN (SELECT fc_seat_fare FROM CRS_TRAIN_INFO WHERE train_id = r.train_id)
                ELSE (SELECT econ_seat_fare FROM CRS_TRAIN_INFO WHERE train_id = r.train_id)
            END
        ELSE 0
    END) AS revenue_generated,
    
    -- Customer Loyalty
    CASE 
        WHEN COUNT(r.booking_id) >= 5 THEN 'VIP'
        WHEN COUNT(r.booking_id) >= 3 THEN 'FREQUENT'
        WHEN COUNT(r.booking_id) >= 1 THEN 'REGULAR'
        ELSE 'NEW'
    END AS customer_tier

FROM CRS_PASSENGER p
LEFT JOIN CRS_RESERVATION r ON p.passenger_id = r.passenger_id
GROUP BY p.passenger_id, p.first_name, p.last_name, p.email, p.phone, p.date_of_birth
HAVING COUNT(r.booking_id) > 0
ORDER BY revenue_generated DESC, total_bookings DESC;


-- ============================================
-- VIEW 4: Seat Utilization by Train
-- Operational efficiency view
-- ============================================
CREATE OR REPLACE VIEW vw_seat_utilization AS
SELECT 
    t.train_number,
    t.source_station || ' → ' || t.dest_station AS route,
    
    -- Business Class Utilization
    t.total_fc_seats AS business_total_seats,
    COUNT(CASE WHEN r.seat_class = 'BUSINESS' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS business_seats_filled,
    t.total_fc_seats - COUNT(CASE WHEN r.seat_class = 'BUSINESS' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS business_seats_empty,
    ROUND(
        (COUNT(CASE WHEN r.seat_class = 'BUSINESS' AND r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0) / t.total_fc_seats, 
        1
    ) AS business_occupancy_percent,
    
    -- Economy Class Utilization
    t.total_econ_seats AS economy_total_seats,
    COUNT(CASE WHEN r.seat_class = 'ECONOMY' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS economy_seats_filled,
    t.total_econ_seats - COUNT(CASE WHEN r.seat_class = 'ECONOMY' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS economy_seats_empty,
    ROUND(
        (COUNT(CASE WHEN r.seat_class = 'ECONOMY' AND r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0) / t.total_econ_seats, 
        1
    ) AS economy_occupancy_percent,
    
    -- Overall Train Performance
    (t.total_fc_seats + t.total_econ_seats) AS total_train_capacity,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS total_seats_filled,
    ROUND(
        (COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0) / (t.total_fc_seats + t.total_econ_seats), 
        1
    ) AS overall_occupancy_percent,
    
    -- Performance Rating
    CASE 
        WHEN ROUND((COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0) / 
             (t.total_fc_seats + t.total_econ_seats), 1) >= 75 THEN 'EXCELLENT'
        WHEN ROUND((COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0) / 
             (t.total_fc_seats + t.total_econ_seats), 1) >= 50 THEN 'GOOD'
        WHEN ROUND((COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0) / 
             (t.total_fc_seats + t.total_econ_seats), 1) >= 25 THEN 'FAIR'
        ELSE 'POOR'
    END AS performance_rating

FROM CRS_TRAIN_INFO t
LEFT JOIN CRS_RESERVATION r ON t.train_id = r.train_id
GROUP BY t.train_number, t.source_station, t.dest_station, t.total_fc_seats, t.total_econ_seats
ORDER BY overall_occupancy_percent DESC;


-- ============================================
-- VIEW 5: Waitlist Dashboard
-- Customer service priority view
-- ============================================
CREATE OR REPLACE VIEW vw_waitlist_dashboard AS
SELECT 
    r.booking_id,
    p.first_name || ' ' || p.last_name AS passenger_name,
    p.email,
    p.phone,
    
    CASE 
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) < 18 THEN 'MINOR'
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) >= 60 THEN 'SENIOR'
        ELSE 'ADULT'
    END AS passenger_category,
    
    t.train_number,
    t.source_station || ' → ' || t.dest_station AS route,
    r.travel_date,
    r.seat_class,
    r.waitlist_position,
    
    -- Current seat availability
    CASE r.seat_class
        WHEN 'BUSINESS' THEN t.total_fc_seats
        ELSE t.total_econ_seats
    END - (SELECT COUNT(*) 
           FROM CRS_RESERVATION r2 
           WHERE r2.train_id = r.train_id 
           AND r2.travel_date = r.travel_date 
           AND r2.seat_class = r.seat_class 
           AND r2.seat_status = 'CONFIRMED') AS current_seats_available,
    
    -- How long on waitlist
    TRUNC(SYSDATE - r.booking_date) AS days_on_waitlist,
    TRUNC(r.travel_date - SYSDATE) AS days_until_travel,
    
    -- Priority flag
    CASE 
        WHEN r.waitlist_position = 1 THEN 'HIGH - Next to confirm'
        WHEN r.waitlist_position <= 2 THEN 'MEDIUM - Good chance'
        ELSE 'LOW - Monitor'
    END AS priority,
    
    -- Action required
    CASE 
        WHEN TRUNC(r.travel_date - SYSDATE) <= 1 THEN 'URGENT - Call customer'
        WHEN TRUNC(r.travel_date - SYSDATE) <= 3 THEN 'Email customer update'
        ELSE 'Routine monitoring'
    END AS action_needed

FROM CRS_RESERVATION r
JOIN CRS_PASSENGER p ON r.passenger_id = p.passenger_id
JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id
WHERE r.seat_status = 'WAITLISTED'
ORDER BY r.travel_date, r.waitlist_position;






-- Grant permissions
GRANT SELECT ON vw_booking_summary TO CRS_OPERATOR;
GRANT SELECT ON vw_train_revenue TO CRS_OPERATOR;
GRANT SELECT ON vw_passenger_summary TO CRS_OPERATOR;
GRANT SELECT ON vw_seat_utilization TO CRS_OPERATOR;
GRANT SELECT ON vw_waitlist_dashboard TO CRS_OPERATOR;

PROMPT '';
PROMPT '========================================';
PROMPT 'ALL 5 VIEWS SUMMARY!';
PROMPT '========================================';
PROMPT '';
PROMPT 'VIEW 1: vw_booking_summary;
PROMPT '        Complete breakdown by train, class, passenger category, and status';
PROMPT '';
PROMPT 'VIEW 2: vw_train_revenue';
PROMPT '        Revenue by train with business vs economy breakdown';
PROMPT '';
PROMPT 'VIEW 3: vw_passenger_summary';
PROMPT '        Customer loyalty and spending patterns';
PROMPT '';
PROMPT 'VIEW 4: vw_seat_utilization';
PROMPT '        Capacity management by train and class';
PROMPT '';
PROMPT 'VIEW 5: vw_waitlist_dashboard';
PROMPT '        Customer service action items';
PROMPT '========================================';