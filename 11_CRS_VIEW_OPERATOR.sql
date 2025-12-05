-- ============================================
-- SCRIPT 11_PRACTICAL_QUERIES.sql
-- Run as CRS_OPERATOR
-- ============================================

SET LINESIZE 200;
SET PAGESIZE 100;

-- ========================================
-- QUERY 1: Complete Booking Breakdown
-- ========================================
PROMPT '========================================';
PROMPT 'QUERY 1: COMPLETE BOOKING SUMMARY BY TRAIN';
PROMPT '========================================';
PROMPT '';

SELECT 
    train_number,
    route,
    seat_class,
    minor_passengers AS minors,
    adult_passengers AS adults,
    senior_passengers AS seniors,
    confirmed_bookings AS confirmed,
    waitlisted_bookings AS waitlisted,
    cancelled_bookings AS cancelled,
    total_bookings AS total,
    total_capacity AS capacity,
    seats_available AS available,
    confirmed_revenue AS revenue,
    occupancy_percent || '%' AS occupancy
FROM CRS_ADMIN.vw_booking_summary
ORDER BY train_number, seat_class;



-- ========================================
-- QUERY 2: Which Trains Make Most Money?
-- ========================================
PROMPT 'QUERY 2: TRAIN REVENUE RANKING';
PROMPT '========================================';
PROMPT '';

COLUMN train_number FORMAT A10 HEADING 'TRAIN|NUMBER'
COLUMN route FORMAT A50 HEADING 'ROUTE'
COLUMN business_tickets_sold FORMAT 999 HEADING 'BIZ|TICKETS'
COLUMN economy_tickets_sold FORMAT 999 HEADING 'ECON|TICKETS'
COLUMN total_tickets_sold FORMAT 999 HEADING 'TOTAL|TICKETS'
COLUMN biz_revenue FORMAT $99,999.99 HEADING 'BUSINESS|REVENUE'
COLUMN eco_revenue FORMAT $99,999.99 HEADING 'ECONOMY|REVENUE'
COLUMN total_revenue FORMAT $99,999.99 HEADING 'TOTAL|REVENUE'
COLUMN revenue_lost FORMAT $99,999.99 HEADING 'REVENUE|LOST'

SELECT 
    train_number,
    route,
    business_tickets_sold,
    business_revenue AS biz_revenue,
    economy_tickets_sold,
    economy_revenue AS eco_revenue,
    total_tickets_sold,
    total_revenue,
    revenue_lost
FROM CRS_ADMIN.vw_train_revenue
ORDER BY total_revenue DESC;

CLEAR COLUMNS;

PROMPT '';
PROMPT '';

-- ========================================
-- QUERY 3: Top Customers
-- ========================================
PROMPT 'QUERY 3: TOP CUSTOMERS BY REVENUE';
PROMPT '========================================';
PROMPT '';

SELECT 
    passenger_name,
    age_category,
    customer_tier,
    total_bookings,
    confirmed_bookings,
    TO_CHAR(revenue_generated, '$99,999.99') AS revenue
FROM CRS_ADMIN.vw_passenger_summary
WHERE total_bookings > 0
ORDER BY revenue_generated DESC
FETCH FIRST 10 ROWS ONLY;


-- ========================================
-- QUERY 4: Seat Efficiency Report
-- ========================================
PROMPT 'QUERY 4: SEAT UTILIZATION BY TRAIN';
PROMPT '========================================';
PROMPT '';

SELECT 
    train_number,
    route,
    business_seats_filled || '/' || business_total_seats AS business,
    business_occupancy_percent || '%' AS biz_occ,
    economy_seats_filled || '/' || economy_total_seats AS economy,
    economy_occupancy_percent || '%' AS eco_occ,
    overall_occupancy_percent || '%' AS total_occ,
    performance_rating AS rating
FROM CRS_ADMIN.vw_seat_utilization
ORDER BY overall_occupancy_percent DESC;


-- ========================================
-- QUERY 5: Waitlist Action Items
-- ========================================
PROMPT 'QUERY 5: WAITLIST CUSTOMERS NEEDING ATTENTION';
PROMPT '========================================';
PROMPT '';

SELECT 
    booking_id,
    passenger_name,
    phone,
    train_number,
    seat_class,
    waitlist_position AS position,
    current_seats_available AS seats_free,
    days_until_travel AS days_left,
    priority,
    action_needed
FROM CRS_ADMIN.vw_waitlist_dashboard
ORDER BY waitlist_position;


-- ========================================
-- QUERY 6: System-Wide Summary Stats
-- ========================================
PROMPT 'QUERY 6: OVERALL SYSTEM STATISTICS';
PROMPT '========================================';
PROMPT '';

SELECT 
    'Total Trains' AS metric,
    TO_CHAR(COUNT(DISTINCT train_number)) AS value
FROM CRS_ADMIN.vw_booking_summary
UNION ALL
SELECT 
    'Total Passengers',
    TO_CHAR(COUNT(DISTINCT passenger_id))
FROM CRS_ADMIN.vw_passenger_summary
UNION ALL
SELECT 
    'Total Bookings',
    TO_CHAR(SUM(total_bookings))
FROM CRS_ADMIN.vw_booking_summary
UNION ALL
SELECT 
    'Confirmed Bookings',
    TO_CHAR(SUM(confirmed_bookings))
FROM CRS_ADMIN.vw_booking_summary
UNION ALL
SELECT 
    'Total Revenue',
    TO_CHAR(SUM(total_revenue), '$999,999.99')
FROM CRS_ADMIN.vw_train_revenue;

PROMPT '';
PROMPT '========================================';