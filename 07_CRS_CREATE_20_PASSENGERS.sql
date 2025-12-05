-- ============================================
-- SCRIPT:  _7__ CREATE_20_PASSENGERS.sql
-- Run as CRS_ADMIN
-- Creates 20 diverse passengers for testing
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_passenger_id NUMBER;
    v_status VARCHAR2(500);
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Creating 20 Test Passengers');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Passenger 1
    CRS_BOOKING_PKG.register_passenger(
        'James', 'Robert', 'Anderson', TO_DATE('1988-03-15', 'YYYY-MM-DD'),
        '234 Oak Street', 'Boston', 'MA', '02101',
        'james.anderson@email.com', '6171111001',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 2
    CRS_BOOKING_PKG.register_passenger(
        'Maria', 'Elena', 'Garcia', TO_DATE('1995-07-22', 'YYYY-MM-DD'),
        '567 Elm Avenue', 'Cambridge', 'MA', '02139',
        'maria.garcia@email.com', '6171111002',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 3
    CRS_BOOKING_PKG.register_passenger(
        'Robert', 'William', 'Martinez', TO_DATE('1982-11-08', 'YYYY-MM-DD'),
        '890 Pine Road', 'Somerville', 'MA', '02144',
        'robert.martinez@email.com', '6171111003',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 4
    CRS_BOOKING_PKG.register_passenger(
        'Jennifer', 'Lynn', 'Rodriguez', TO_DATE('1998-05-30', 'YYYY-MM-DD'),
        '123 Maple Drive', 'Brookline', 'MA', '02445',
        'jennifer.rodriguez@email.com', '6171111004',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 5
    CRS_BOOKING_PKG.register_passenger(
        'William', 'Charles', 'Wilson', TO_DATE('1975-09-12', 'YYYY-MM-DD'),
        '456 Cedar Lane', 'Newton', 'MA', '02458',
        'william.wilson@email.com', '6171111005',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 6
    CRS_BOOKING_PKG.register_passenger(
        'Linda', 'Marie', 'Taylor', TO_DATE('1991-12-25', 'YYYY-MM-DD'),
        '789 Birch Street', 'Quincy', 'MA', '02169',
        'linda.taylor@email.com', '6171111006',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 7
    CRS_BOOKING_PKG.register_passenger(
        'Richard', 'John', 'Thomas', TO_DATE('2005-04-18', 'YYYY-MM-DD'),
        '321 Walnut Avenue', 'Medford', 'MA', '02155',
        'richard.thomas@email.com', '6171111007',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 8
    CRS_BOOKING_PKG.register_passenger(
        'Patricia', 'Ann', 'Jackson', TO_DATE('1968-08-07', 'YYYY-MM-DD'),
        '654 Spruce Road', 'Waltham', 'MA', '02451',
        'patricia.jackson@email.com', '6171111008',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 9
    CRS_BOOKING_PKG.register_passenger(
        'Christopher', 'James', 'White', TO_DATE('1993-02-14', 'YYYY-MM-DD'),
        '987 Ash Drive', 'Malden', 'MA', '02148',
        'christopher.white@email.com', '6171111009',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 10
    CRS_BOOKING_PKG.register_passenger(
        'Barbara', 'Jean', 'Harris', TO_DATE('1987-10-29', 'YYYY-MM-DD'),
        '147 Willow Lane', 'Revere', 'MA', '02151',
        'barbara.harris@email.com', '6171111010',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
     -- Passenger 11
    CRS_BOOKING_PKG.register_passenger(
        'Daniel', 'Patrick', 'Martin', TO_DATE('1996-06-03', 'YYYY-MM-DD'),
        '258 Hickory Street', 'Chelsea', 'MA', '02150',
        'daniel.martin@email.com', '6171111011',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 12
    CRS_BOOKING_PKG.register_passenger(
        'Susan', 'Elizabeth', 'Thompson', TO_DATE('1979-01-16', 'YYYY-MM-DD'),
        '369 Poplar Avenue', 'Everett', 'MA', '02149',
        'susan.thompson@email.com', '6171111012',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 13
    CRS_BOOKING_PKG.register_passenger(
        'Matthew', 'David', 'Moore', TO_DATE('2000-11-21', 'YYYY-MM-DD'),
        '741 Magnolia Road', 'Arlington', 'MA', '02474',
        'matthew.moore@email.com', '6171111013',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 14
    CRS_BOOKING_PKG.register_passenger(
        'Jessica', 'Nicole', 'Lee', TO_DATE('1984-07-09', 'YYYY-MM-DD'),
        '852 Sycamore Drive', 'Belmont', 'MA', '02478',
        'jessica.lee@email.com', '6171111014',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 15
    CRS_BOOKING_PKG.register_passenger(
        'Anthony', 'Michael', 'Walker', TO_DATE('1990-03-27', 'YYYY-MM-DD'),
        '963 Chestnut Lane', 'Watertown', 'MA', '02472',
        'anthony.walker@email.com', '6171111015',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
      
    -- Passenger 16
    CRS_BOOKING_PKG.register_passenger(
        'Nancy', 'Carol', 'Hall', TO_DATE('1972-12-04', 'YYYY-MM-DD'),
        '159 Dogwood Street', 'Lexington', 'MA', '02420',
        'nancy.hall@email.com', '6171111016',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 17
    CRS_BOOKING_PKG.register_passenger(
        'Kevin', 'Joseph', 'Allen', TO_DATE('1997-08-19', 'YYYY-MM-DD'),
        '357 Redwood Avenue', 'Burlington', 'MA', '01803',
        'kevin.allen@email.com', '6171111017',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 18
    CRS_BOOKING_PKG.register_passenger(
        'Karen', 'Michelle', 'Young', TO_DATE('1989-05-11', 'YYYY-MM-DD'),
        '486 Sequoia Road', 'Woburn', 'MA', '01801',
        'karen.young@email.com', '6171111018',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 19
    CRS_BOOKING_PKG.register_passenger(
        'Steven', 'Andrew', 'King', TO_DATE('2003-09-23', 'YYYY-MM-DD'),
        '597 Beech Drive', 'Medford', 'MA', '02155',
        'steven.king@email.com', '6171111019',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    -- Passenger 20
    CRS_BOOKING_PKG.register_passenger(
        'Betty', 'Rose', 'Wright', TO_DATE('1965-02-28', 'YYYY-MM-DD'),
        '753 Cypress Lane', 'Stoneham', 'MA', '02180',
        'betty.wright@email.com', '6171111020',
        v_passenger_id, v_status
    );
    IF v_status LIKE 'SUCCESS%' THEN v_count := v_count + 1; END IF;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Successfully created ' || v_count || ' passengers');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
END;
/

-- Verify passengers created
SELECT 
    passenger_id,
    first_name || ' ' || last_name AS full_name,
    email,
    FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) AS age
FROM CRS_PASSENGER
WHERE passenger_id >= 1007
ORDER BY passenger_id;

PROMPT 'Passenger creation complete!';