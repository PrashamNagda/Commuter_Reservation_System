-- ============================================
-- SCRIPT 5: CREATE_BUSINESS_LOGIC_PACKAGE.sql
--️ MUST RUN AS CRS_ADMIN ️
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Verify you're connected as CRS_ADMIN
SHOW USER;

-- Drop existing package
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE CRS_BOOKING_PKG';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ============================================
-- PACKAGE SPECIFICATION
-- ============================================
CREATE OR REPLACE PACKAGE CRS_BOOKING_PKG AS

    PROCEDURE register_passenger(
        p_first_name IN VARCHAR2,
        p_middle_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_dob IN DATE,
        p_address_line1 IN VARCHAR2,
        p_address_city IN VARCHAR2,
        p_address_state IN VARCHAR2,
        p_address_zip IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_passenger_id OUT NUMBER,
        p_status OUT VARCHAR2
    );
    
    PROCEDURE book_ticket(
        p_passenger_id IN NUMBER,
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2,
        p_booking_id OUT NUMBER,
        p_status OUT VARCHAR2,
        p_seat_status OUT VARCHAR2,
        p_waitlist_position OUT NUMBER
    );
    
    PROCEDURE cancel_ticket(
        p_booking_id IN NUMBER,
        p_status OUT VARCHAR2
    );
    
    FUNCTION get_booking_details(p_booking_id IN NUMBER) 
        RETURN SYS_REFCURSOR;
    
    FUNCTION get_passenger_bookings(p_passenger_id IN NUMBER) 
        RETURN SYS_REFCURSOR;
    
    PROCEDURE view_train_schedule(
        p_train_number IN VARCHAR2,
        p_result OUT SYS_REFCURSOR
    );
    
    FUNCTION check_seat_availability(
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN VARCHAR2;
    
END CRS_BOOKING_PKG;
/
PROMPT 'Package specification created';

-- ============================================
-- PACKAGE BODY
-- ============================================
CREATE OR REPLACE PACKAGE BODY CRS_BOOKING_PKG AS

    PROCEDURE register_passenger(
        p_first_name IN VARCHAR2,
        p_middle_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_dob IN DATE,
        p_address_line1 IN VARCHAR2,
        p_address_city IN VARCHAR2,
        p_address_state IN VARCHAR2,
        p_address_zip IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_passenger_id OUT NUMBER,
        p_status OUT VARCHAR2
    ) IS
        v_passenger_id NUMBER;
    BEGIN
        IF p_first_name IS NULL OR TRIM(p_first_name) = '' THEN
            p_status := 'ERROR: First name is required';
            RETURN;
        END IF;
        
        IF p_last_name IS NULL OR TRIM(p_last_name) = '' THEN
            p_status := 'ERROR: Last name is required';
            RETURN;
        END IF;
        
        IF p_dob IS NULL OR p_dob >= SYSDATE THEN
            p_status := 'ERROR: Valid date of birth is required (must be in the past)';
            RETURN;
        END IF;
        
        IF p_email IS NULL OR NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$') THEN
            p_status := 'ERROR: Valid email address is required';
            RETURN;
        END IF;
        
        IF p_phone IS NULL OR LENGTH(TRIM(p_phone)) < 10 THEN
            p_status := 'ERROR: Valid phone number is required (minimum 10 digits)';
            RETURN;
        END IF;
        
        IF NOT CRS_VALIDATION_PKG.is_email_unique(p_email) THEN
            p_status := 'ERROR: Email address already registered in the system';
            RETURN;
        END IF;
        
        IF NOT CRS_VALIDATION_PKG.is_phone_unique(p_phone) THEN
            p_status := 'ERROR: Phone number already registered in the system';
            RETURN;
        END IF;
        
        v_passenger_id := seq_passenger_id.NEXTVAL;
        
        INSERT INTO CRS_PASSENGER (
            passenger_id, first_name, middle_name, last_name,
            date_of_birth, address_line1, address_city, address_state,
            address_zip, email, phone
        ) VALUES (
            v_passenger_id, p_first_name, p_middle_name, p_last_name,
            p_dob, p_address_line1, p_address_city, p_address_state,
            p_address_zip, p_email, p_phone
        );
        
        COMMIT;
        
        p_passenger_id := v_passenger_id;
        p_status := 'SUCCESS: Passenger registered successfully with ID ' || v_passenger_id || 
                   ' (Category: ' || CRS_VALIDATION_PKG.get_passenger_category(p_dob) || ')';
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            p_status := 'ERROR: Duplicate email or phone number found';
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR: Failed to register passenger - ' || SQLERRM;
    END register_passenger;
    

    -- PROCEDURE: book_ticket    
    PROCEDURE book_ticket(
        p_passenger_id IN NUMBER,
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2,
        p_booking_id OUT NUMBER,
        p_status OUT VARCHAR2,
        p_seat_status OUT VARCHAR2,
        p_waitlist_position OUT NUMBER
    ) IS
        v_booking_id NUMBER;
        v_available_seats NUMBER;
        v_waitlist_count NUMBER;
        v_seat_status VARCHAR2(20);
        v_waitlist_pos NUMBER := NULL;
        v_booking_date DATE := SYSDATE;
        v_seat_class_upper VARCHAR2(10);
        v_passenger_dob DATE;
        v_passenger_age NUMBER;
    BEGIN
        -- Initialize output parameters
        p_booking_id := NULL;
        p_seat_status := NULL;
        p_waitlist_position := NULL;
        
        -- Normalize seat class to uppercase
        v_seat_class_upper := UPPER(TRIM(p_seat_class));
        
        -- Validate seat class length (prevent buffer overflow)
        IF LENGTH(v_seat_class_upper) > 10 THEN
            p_status := 'ERROR: Invalid seat class - Use BUSINESS or ECONOMY only';
            RETURN;
        END IF;
        
        -- Validate passenger exists
        IF NOT CRS_VALIDATION_PKG.is_passenger_valid(p_passenger_id) THEN
            p_status := 'ERROR: Invalid passenger ID - Passenger does not exist';
            RETURN;
        END IF;
        
        -- ========================================
        -- NEW: Validate passenger age - Minors not allowed
        -- Minors (under 18) cannot book tickets
        -- ========================================
        BEGIN
            SELECT date_of_birth INTO v_passenger_dob
            FROM CRS_PASSENGER
            WHERE passenger_id = p_passenger_id;
            
            v_passenger_age := FLOOR(MONTHS_BETWEEN(SYSDATE, v_passenger_dob) / 12);
            
            IF v_passenger_age < 18 THEN
                p_status := 'ERROR: Minors (under 18 years) are not allowed to book tickets independently';
                RETURN;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;  -- Already validated above
        END;
        
        -- Validate train
        IF NOT CRS_VALIDATION_PKG.is_train_valid(p_train_id) THEN
            p_status := 'ERROR: Invalid train ID - Train does not exist';
            RETURN;
        END IF;
        
        -- Validate seat class
        IF NOT CRS_VALIDATION_PKG.is_seat_class_valid(v_seat_class_upper) THEN
            p_status := 'ERROR: Invalid seat class - Use BUSINESS or ECONOMY only';
            RETURN;
        END IF;
        
        -- Validate booking date (within 7 days advance)
        IF NOT CRS_VALIDATION_PKG.is_booking_date_valid(v_booking_date, p_travel_date) THEN
            p_status := 'ERROR: Invalid booking date - Only 7 days advance booking allowed (travel date: ' || 
                       TO_CHAR(p_travel_date, 'DD-MON-YYYY') || ')';
            RETURN;
        END IF;
        
        -- Validate train availability on travel date
        IF NOT CRS_VALIDATION_PKG.is_train_available_on_date(p_train_id, p_travel_date) THEN
            p_status := 'ERROR: Train not available on ' || TO_CHAR(p_travel_date, 'DAY DD-MON-YYYY') || 
                       ' - Check train schedule';
            RETURN;
        END IF;
        
        -- Check seat availability
        v_available_seats := CRS_VALIDATION_PKG.get_available_seats(
            p_train_id, p_travel_date, v_seat_class_upper
        );
        
        v_waitlist_count := CRS_VALIDATION_PKG.get_waitlist_count(
            p_train_id, p_travel_date, v_seat_class_upper
        );
        
        -- Determine seat status based on availability
        IF v_available_seats > 0 THEN
            -- Seats available - CONFIRMED
            v_seat_status := 'CONFIRMED';
        ELSIF v_waitlist_count < 5 THEN
            -- No seats but waitlist available - WAITLISTED
            v_seat_status := 'WAITLISTED';
            v_waitlist_pos := v_waitlist_count + 1;
        ELSE
            -- No seats and waitlist full
            p_status := 'ERROR: No seats available - All confirmed seats (40) and waitlist positions (5) are full for ' || 
                       v_seat_class_upper || ' class';
            RETURN;
        END IF;
        
        -- Generate booking ID
        v_booking_id := seq_booking_id.NEXTVAL;
        
        -- Insert reservation
        INSERT INTO CRS_RESERVATION (
            booking_id, passenger_id, train_id, travel_date,
            booking_date, seat_class, seat_status, waitlist_position
        ) VALUES (
            v_booking_id, p_passenger_id, p_train_id, p_travel_date,
            v_booking_date, v_seat_class_upper, v_seat_status, v_waitlist_pos
        );
        
        COMMIT;
        
        p_booking_id := v_booking_id;
        p_seat_status := v_seat_status;
        p_waitlist_position := v_waitlist_pos;
        
        IF v_seat_status = 'CONFIRMED' THEN
            p_status := 'SUCCESS: Ticket CONFIRMED with Booking ID ' || v_booking_id || 
                       ' for ' || v_seat_class_upper || ' class';
        ELSE
            p_status := 'SUCCESS: Ticket WAITLISTED (Position: ' || v_waitlist_pos || 
                       '/5) with Booking ID ' || v_booking_id || ' for ' || v_seat_class_upper || ' class';
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR: Booking failed - ' || SQLERRM;
    END book_ticket;
    
    PROCEDURE cancel_ticket(
        p_booking_id IN NUMBER,
        p_status OUT VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;  -- ← THIS LINE FIXES ORA-12839! -- occurs when an attempt is made to perform a parallel modification on a table within the same transaction
        
        v_train_id NUMBER;
        v_travel_date DATE;
        v_seat_class VARCHAR2(10);
        v_current_status VARCHAR2(20);
        v_first_waitlist_id NUMBER := NULL;
        
        TYPE booking_list IS TABLE OF NUMBER;
        v_waitlist_bookings booking_list;
    BEGIN
        BEGIN
            SELECT train_id, travel_date, seat_class, seat_status
            INTO v_train_id, v_travel_date, v_seat_class, v_current_status
            FROM CRS_RESERVATION
            WHERE booking_id = p_booking_id
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ROLLBACK;
                p_status := 'ERROR: Booking ID ' || p_booking_id || ' not found in system';
                RETURN;
        END;
        
        IF v_current_status = 'CANCELLED' THEN
            ROLLBACK;
            p_status := 'ERROR: Booking ID ' || p_booking_id || ' is already cancelled';
            RETURN;
        END IF;
        
        UPDATE CRS_RESERVATION
        SET seat_status = 'CANCELLED',
            waitlist_position = NULL
        WHERE booking_id = p_booking_id;
        
        IF v_current_status = 'CONFIRMED' THEN
            SELECT booking_id
            BULK COLLECT INTO v_waitlist_bookings
            FROM CRS_RESERVATION
            WHERE train_id = v_train_id
            AND travel_date = v_travel_date
            AND seat_class = v_seat_class
            AND seat_status = 'WAITLISTED'
            ORDER BY waitlist_position
            FOR UPDATE;
            
            IF v_waitlist_bookings.COUNT > 0 THEN
                v_first_waitlist_id := v_waitlist_bookings(1);
                
                UPDATE CRS_RESERVATION
                SET seat_status = 'CONFIRMED',
                    waitlist_position = NULL
                WHERE booking_id = v_first_waitlist_id;
                
                FOR i IN 2..v_waitlist_bookings.COUNT LOOP
                    UPDATE CRS_RESERVATION
                    SET waitlist_position = i - 1
                    WHERE booking_id = v_waitlist_bookings(i);
                END LOOP;
                
                COMMIT;
                
                p_status := 'SUCCESS: Booking ID ' || p_booking_id || ' cancelled successfully. ' ||
                           'Booking ID ' || v_first_waitlist_id || ' promoted from waitlist to CONFIRMED';
            ELSE
                COMMIT;
                p_status := 'SUCCESS: Booking ID ' || p_booking_id || ' cancelled successfully';
            END IF;
        ELSE
            UPDATE CRS_RESERVATION
            SET waitlist_position = waitlist_position - 1
            WHERE train_id = v_train_id
            AND travel_date = v_travel_date
            AND seat_class = v_seat_class
            AND seat_status = 'WAITLISTED'
            AND booking_id != p_booking_id;
            
            COMMIT;
            
            p_status := 'SUCCESS: Waitlisted booking ID ' || p_booking_id || ' cancelled successfully';
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR: Cancellation failed - ' || SQLERRM;
    END cancel_ticket;
    
    FUNCTION get_booking_details(p_booking_id IN NUMBER) 
        RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                r.booking_id,
                r.booking_date,
                r.travel_date,
                p.first_name || ' ' || NVL(p.middle_name || ' ', '') || p.last_name AS passenger_name,
                p.email,
                p.phone,
                t.train_number,
                t.source_station,
                t.dest_station,
                r.seat_class,
                CASE r.seat_class
                    WHEN 'BUSINESS' THEN t.fc_seat_fare
                    ELSE t.econ_seat_fare
                END AS fare,
                r.seat_status,
                r.waitlist_position,
                CRS_VALIDATION_PKG.get_passenger_category(p.date_of_birth) AS passenger_category
            FROM CRS_RESERVATION r
            JOIN CRS_PASSENGER p ON r.passenger_id = p.passenger_id
            JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id
            WHERE r.booking_id = p_booking_id;
            
        RETURN v_cursor;
    END get_booking_details;
    
    FUNCTION get_passenger_bookings(p_passenger_id IN NUMBER) 
        RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                r.booking_id,
                r.booking_date,
                r.travel_date,
                t.train_number,
                t.source_station,
                t.dest_station,
                r.seat_class,
                r.seat_status,
                r.waitlist_position
            FROM CRS_RESERVATION r
            JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id
            WHERE r.passenger_id = p_passenger_id
            ORDER BY r.booking_date DESC;
            
        RETURN v_cursor;
    END get_passenger_bookings;
    
    PROCEDURE view_train_schedule(
        p_train_number IN VARCHAR2,
        p_result OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_result FOR
            SELECT 
                t.train_number,
                t.source_station,
                t.dest_station,
                ds.day_of_week,
                ds.is_week_end,
                ts.is_in_service,
                t.total_fc_seats AS business_seats,
                t.total_econ_seats AS economy_seats,
                t.fc_seat_fare AS business_fare,
                t.econ_seat_fare AS economy_fare
            FROM CRS_TRAIN_INFO t
            JOIN CRS_TRAIN_SCHEDULE ts ON t.train_id = ts.train_id
            JOIN CRS_DAY_SCHEDULE ds ON ts.sch_id = ds.sch_id
            WHERE t.train_number = p_train_number
            ORDER BY 
                CASE ds.day_of_week
                    WHEN 'MONDAY' THEN 1
                    WHEN 'TUESDAY' THEN 2
                    WHEN 'WEDNESDAY' THEN 3
                    WHEN 'THURSDAY' THEN 4
                    WHEN 'FRIDAY' THEN 5
                    WHEN 'SATURDAY' THEN 6
                    WHEN 'SUNDAY' THEN 7
                END;
    END view_train_schedule;
    
    FUNCTION check_seat_availability(
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_available NUMBER;
        v_waitlist NUMBER;
        v_total NUMBER;
        v_message VARCHAR2(500);
    BEGIN
        v_total := CRS_VALIDATION_PKG.get_total_seats(p_train_id, p_seat_class);
        v_available := CRS_VALIDATION_PKG.get_available_seats(
            p_train_id, p_travel_date, p_seat_class
        );
        v_waitlist := CRS_VALIDATION_PKG.get_waitlist_count(
            p_train_id, p_travel_date, p_seat_class
        );
        
        v_message := UPPER(p_seat_class) || ' Class - ' ||
                    'Total: ' || v_total || ', ' ||
                    'Available: ' || v_available || ', ' ||
                    'Booked: ' || (v_total - v_available) || ', ' ||
                    'Waitlist: ' || v_waitlist || '/5';
        
        RETURN v_message;
    END check_seat_availability;
END CRS_BOOKING_PKG;
/

PROMPT 'Package body created successfully!';

-- Verify package was created
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'CRS_BOOKING_PKG';

PROMPT '========================================';
PROMPT 'CRS_BOOKING_PKG created successfully!';
PROMPT 'Ready to grant permissions.';
PROMPT '========================================';


