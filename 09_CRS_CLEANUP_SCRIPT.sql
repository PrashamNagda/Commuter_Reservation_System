-- ============================================
-- CLEANUP FOR YOUR DATABASE -- SCRIPT 9
-- Run as CRS_ADMIN
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT '========================================';
PROMPT 'Before Cleanup:';
SELECT 'Passengers: ' || COUNT(*) FROM CRS_PASSENGER;
SELECT 'Reservations: ' || COUNT(*) FROM CRS_RESERVATION;

PROMPT '';
PROMPT 'Cleaning up...';

-- 1. Clear ALL reservations
DELETE FROM CRS_RESERVATION;
--DBMS_OUTPUT.PUT_LINE('✓ Deleted all reservations');

-- 2. Delete ONLY test passengers (the Alice ones with .test. in email)
DELETE FROM CRS_PASSENGER 
WHERE email LIKE '%.test.%@%';

--DBMS_OUTPUT.PUT_LINE('✓ Deleted test passengers: ' || SQL%ROWCOUNT || ' removed');

-- 3. Reset booking sequence
DROP SEQUENCE seq_booking_id;
CREATE SEQUENCE seq_booking_id START WITH 5001 INCREMENT BY 1 NOCACHE;
--DBMS_OUTPUT.PUT_LINE('✓ Reset booking sequence to 5001');

COMMIT;

PROMPT '';
PROMPT '========================================';
PROMPT 'After Cleanup:';

-- Show what remains
SELECT 
    COUNT(*) AS total_passengers,
    MIN(passenger_id) AS first_id,
    MAX(passenger_id) AS last_id
FROM CRS_PASSENGER;

SELECT 'Reservations: ' || COUNT(*) FROM CRS_RESERVATION;

PROMPT '';
PROMPT '========================================';
PROMPT 'Passenger List (should be 1001-1029):';

SELECT passenger_id, first_name, last_name, email
FROM CRS_PASSENGER
WHERE passenger_id >= 1025  -- Show last few
ORDER BY passenger_id;

PROMPT '';
PROMPT 'Database ready for testing!';
PROMPT '========================================';



SELECT passenger_id, first_name, last_name, email
FROM CRS_PASSENGER
ORDER BY passenger_id;



