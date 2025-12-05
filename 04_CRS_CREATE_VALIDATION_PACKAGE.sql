-- ============================================
-- SCRIPT 4: CREATE_VALIDATION_PACKAGE.sql
-- Connect as CRS_ADMIN and run this script
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE CRS_VALIDATION_PKG';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE BODY CRS_VALIDATION_PKG';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ============================================
-- PACKAGE SPECIFICATION: CRS_VALIDATION_PKG
-- Contains all validation functions
-- ============================================
CREATE OR REPLACE PACKAGE CRS_VALIDATION_PKG AS
-- Custom Exception Declarations
    ex_invalid_train EXCEPTION;
    ex_invalid_date EXCEPTION;
    ex_invalid_passenger EXCEPTION;
    ex_invalid_class EXCEPTION;
    ex_no_seats EXCEPTION;
    ex_train_not_available EXCEPTION;
    ex_booking_date_invalid EXCEPTION;
    ex_duplicate_email EXCEPTION;
    ex_duplicate_phone EXCEPTION;
    
    -- Validation Functions
    FUNCTION is_train_valid(p_train_id IN NUMBER) RETURN BOOLEAN;
    
    FUNCTION is_passenger_valid(p_passenger_id IN NUMBER) RETURN BOOLEAN;
    
    FUNCTION is_train_available_on_date(
        p_train_id IN NUMBER,
        p_travel_date IN DATE
    ) RETURN BOOLEAN;
    
    FUNCTION is_booking_date_valid(
        p_booking_date IN DATE,
        p_travel_date IN DATE
    ) RETURN BOOLEAN;
    
    FUNCTION is_seat_class_valid(p_seat_class IN VARCHAR2) RETURN BOOLEAN;
    
    FUNCTION get_available_seats(
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER;
    
    FUNCTION get_waitlist_count(
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER;
    
    FUNCTION is_email_unique(
        p_email IN VARCHAR2,
        p_passenger_id IN NUMBER DEFAULT NULL
    ) RETURN BOOLEAN;
    
    FUNCTION is_phone_unique(
        p_phone IN VARCHAR2,
        p_passenger_id IN NUMBER DEFAULT NULL
    ) RETURN BOOLEAN;
    
    FUNCTION calculate_age(p_dob IN DATE) RETURN NUMBER;
    
    FUNCTION get_passenger_category(p_dob IN DATE) RETURN VARCHAR2;
    
    FUNCTION get_total_seats(
        p_train_id IN NUMBER,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER;
    
END CRS_VALIDATION_PKG;
/

-- ============================================
-- PACKAGE BODY: CRS_VALIDATION_PKG
-- Implementation of all validation functions
-- ============================================
CREATE OR REPLACE PACKAGE BODY CRS_VALIDATION_PKG AS
    
    -- ========================================
    -- FUNCTION: is_train_valid
    -- Validates if train exists in system
    -- Business Rule: Validate train number
    -- ========================================
    FUNCTION is_train_valid(p_train_id IN NUMBER) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM CRS_TRAIN_INFO
        WHERE train_id = p_train_id;
        
        RETURN (v_count > 0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_train_valid;
    
    -- ========================================
    -- FUNCTION: is_passenger_valid
    -- Validates if passenger exists in system
    -- Business Rule: Validate passenger info
    -- ========================================
    FUNCTION is_passenger_valid(p_passenger_id IN NUMBER) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM CRS_PASSENGER
        WHERE passenger_id = p_passenger_id;
        
        RETURN (v_count > 0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_passenger_valid;
    
    -- ========================================
    -- FUNCTION: is_train_available_on_date
    -- Checks if train runs on given date
    -- Business Rule: Train availability check
    -- ========================================
    FUNCTION is_train_available_on_date(
        p_train_id IN NUMBER,
        p_travel_date IN DATE
    ) RETURN BOOLEAN IS
        v_count NUMBER;
        v_day_of_week VARCHAR2(10);
    BEGIN
        -- Get day of week for travel date
        v_day_of_week := UPPER(TO_CHAR(p_travel_date, 'DAY'));
        v_day_of_week := TRIM(v_day_of_week);
        
        -- Check if train is scheduled for that day
        SELECT COUNT(*)
        INTO v_count
        FROM CRS_TRAIN_SCHEDULE ts
        JOIN CRS_DAY_SCHEDULE ds ON ts.sch_id = ds.sch_id
        WHERE ts.train_id = p_train_id
        AND ds.day_of_week = v_day_of_week
        AND ts.is_in_service = 'Y';
        
        RETURN (v_count > 0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_train_available_on_date;
    
    -- ========================================
    -- FUNCTION: is_booking_date_valid
    -- Validates booking is within 7 days advance
    -- Business Rule: Only one week advance booking
    -- ========================================
    FUNCTION is_booking_date_valid(
        p_booking_date IN DATE,
        p_travel_date IN DATE
    ) RETURN BOOLEAN IS
        v_days_diff NUMBER;
    BEGIN
        v_days_diff := TRUNC(p_travel_date) - TRUNC(p_booking_date);
        
        -- Must be between 0 and 7 days in advance
        RETURN (v_days_diff >= 0 AND v_days_diff <= 7);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_booking_date_valid;
    
    -- ========================================
    -- FUNCTION: is_seat_class_valid
    -- Validates seat class (BUSINESS or ECONOMY)
    -- Business Rule: Two classes only
    -- ========================================
    FUNCTION is_seat_class_valid(p_seat_class IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN (UPPER(p_seat_class) IN ('BUSINESS', 'ECONOMY'));
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_seat_class_valid;
    
    -- ========================================
    -- FUNCTION: get_total_seats
    -- Returns total seats for given class
    -- ========================================
    FUNCTION get_total_seats(
        p_train_id IN NUMBER,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER IS
        v_total_seats NUMBER;
    BEGIN
        IF UPPER(p_seat_class) = 'BUSINESS' THEN
            SELECT total_fc_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = p_train_id;
        ELSE
            SELECT total_econ_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = p_train_id;
        END IF;
        
        RETURN v_total_seats;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END get_total_seats;
    
    -- ========================================
    -- FUNCTION: get_available_seats
    -- Returns number of available seats
    -- Business Rule: Check seat availability
    -- ========================================
    FUNCTION get_available_seats(
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER IS
        v_total_seats NUMBER;
        v_booked_seats NUMBER;
        v_available_seats NUMBER;
    BEGIN
        -- Get total seats for class
        v_total_seats := get_total_seats(p_train_id, p_seat_class);
        
        -- Get booked seats (confirmed only, not cancelled)
        SELECT COUNT(*)
        INTO v_booked_seats
        FROM CRS_RESERVATION
        WHERE train_id = p_train_id
        AND travel_date = p_travel_date
        AND UPPER(seat_class) = UPPER(p_seat_class)
        AND seat_status = 'CONFIRMED';
        
        v_available_seats := v_total_seats - v_booked_seats;
        
        RETURN v_available_seats;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END get_available_seats;
    
    -- ========================================
    -- FUNCTION: get_waitlist_count
    -- Returns current waitlist count
    -- Business Rule: Max 5 waitlist per class
    -- ========================================
    FUNCTION get_waitlist_count(
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER IS
        v_waitlist_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_waitlist_count
        FROM CRS_RESERVATION
        WHERE train_id = p_train_id
        AND travel_date = p_travel_date
        AND UPPER(seat_class) = UPPER(p_seat_class)
        AND seat_status = 'WAITLISTED';
        
        RETURN v_waitlist_count;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END get_waitlist_count;
    
    -- ========================================
    -- FUNCTION: is_email_unique
    -- Checks if email is unique
    -- Business Rule: Email must be unique
    -- ========================================
    FUNCTION is_email_unique(
        p_email IN VARCHAR2,
        p_passenger_id IN NUMBER DEFAULT NULL
    ) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        IF p_passenger_id IS NULL THEN
            SELECT COUNT(*)
            INTO v_count
            FROM CRS_PASSENGER
            WHERE LOWER(email) = LOWER(p_email);
        ELSE
            SELECT COUNT(*)
            INTO v_count
            FROM CRS_PASSENGER
            WHERE LOWER(email) = LOWER(p_email)
            AND passenger_id != p_passenger_id;
        END IF;
        
        RETURN (v_count = 0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_email_unique;
    
    -- ========================================
    -- FUNCTION: is_phone_unique
    -- Checks if phone is unique
    -- Business Rule: Phone must be unique
    -- ========================================
    FUNCTION is_phone_unique(
        p_phone IN VARCHAR2,
        p_passenger_id IN NUMBER DEFAULT NULL
    ) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        IF p_passenger_id IS NULL THEN
            SELECT COUNT(*)
            INTO v_count
            FROM CRS_PASSENGER
            WHERE phone = p_phone;
        ELSE
            SELECT COUNT(*)
            INTO v_count
            FROM CRS_PASSENGER
            WHERE phone = p_phone
            AND passenger_id != p_passenger_id;
        END IF;
        
        RETURN (v_count = 0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_phone_unique;
    
    -- ========================================
    -- FUNCTION: calculate_age
    -- Calculates age from date of birth
    -- ========================================
    FUNCTION calculate_age(p_dob IN DATE) RETURN NUMBER IS
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END calculate_age;
    
    -- ========================================
    -- FUNCTION: get_passenger_category
    -- Returns passenger category based on age
    -- Business Rule: Minor/Major/Senior based on DOB
    -- ========================================
    FUNCTION get_passenger_category(p_dob IN DATE) RETURN VARCHAR2 IS
        v_age NUMBER;
    BEGIN
        v_age := calculate_age(p_dob);
        
        IF v_age < 18 THEN
            RETURN 'MINOR';
        ELSIF v_age >= 60 THEN
            RETURN 'SENIOR CITIZEN';
        ELSE
            RETURN 'MAJOR (ADULT)';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'UNKNOWN';
    END get_passenger_category;
    
END CRS_VALIDATION_PKG;
/
