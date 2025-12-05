-- ============================================
-- SCRIPT 2: CREATE_TABLES.sql (NO INDEXES)
-- Connect as CRS_ADMIN and run this script
-- ============================================
show user;

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Drop existing tables 
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CRS_RESERVATION CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CRS_TRAIN_SCHEDULE CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CRS_PASSENGER CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CRS_DAY_SCHEDULE CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CRS_TRAIN_INFO CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Drop sequences 
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_train_id'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_sch_id'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_tsch_id'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_passenger_id'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_booking_id'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Create sequences
CREATE SEQUENCE seq_train_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_sch_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_tsch_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_passenger_id START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_booking_id START WITH 5001 INCREMENT BY 1 NOCACHE;

-- ============================================
-- TABLE 1: CRS_TRAIN_INFO
-- ============================================
CREATE TABLE CRS_TRAIN_INFO (
    train_id NUMBER PRIMARY KEY,
    train_number VARCHAR2(20) NOT NULL UNIQUE,
    source_station VARCHAR2(100) NOT NULL,
    dest_station VARCHAR2(100) NOT NULL,
    total_fc_seats NUMBER DEFAULT 40 NOT NULL,
    total_econ_seats NUMBER DEFAULT 40 NOT NULL,
    fc_seat_fare NUMBER(10,2) NOT NULL,
    econ_seat_fare NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_train_seats CHECK (total_fc_seats > 0 AND total_econ_seats > 0),
    CONSTRAINT chk_train_fare CHECK (fc_seat_fare > 0 AND econ_seat_fare > 0),
    CONSTRAINT chk_train_stations CHECK (source_station != dest_station)
);

PROMPT 'CRS_TRAIN_INFO created';

-- ============================================
-- TABLE 2: CRS_DAY_SCHEDULE
-- ============================================
CREATE TABLE CRS_DAY_SCHEDULE (
    sch_id NUMBER PRIMARY KEY,
    day_of_week VARCHAR2(10) NOT NULL UNIQUE,
    is_week_end CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT chk_day_weekend CHECK (is_week_end IN ('Y', 'N'))
);

PROMPT 'CRS_DAY_SCHEDULE created';

-- ============================================
-- TABLE 3: CRS_TRAIN_SCHEDULE
-- ============================================
CREATE TABLE CRS_TRAIN_SCHEDULE (
    tsch_id NUMBER PRIMARY KEY,
    sch_id NUMBER NOT NULL,
    train_id NUMBER NOT NULL,
    is_in_service CHAR(1) DEFAULT 'Y' NOT NULL,
    CONSTRAINT fk_tsch_schedule FOREIGN KEY (sch_id) REFERENCES CRS_DAY_SCHEDULE(sch_id),
    CONSTRAINT fk_tsch_train FOREIGN KEY (train_id) REFERENCES CRS_TRAIN_INFO(train_id),
    CONSTRAINT chk_tsch_service CHECK (is_in_service IN ('Y', 'N')),
    CONSTRAINT uk_tsch_schedule UNIQUE (sch_id, train_id)
);

PROMPT 'CRS_TRAIN_SCHEDULE created';

-- ============================================
-- TABLE 4: CRS_PASSENGER
-- ============================================
CREATE TABLE CRS_PASSENGER (
    passenger_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    middle_name VARCHAR2(50),
    last_name VARCHAR2(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    address_line1 VARCHAR2(200) NOT NULL,
    address_city VARCHAR2(100) NOT NULL,
    address_state VARCHAR2(50) NOT NULL,
    address_zip VARCHAR2(10) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    phone VARCHAR2(15) NOT NULL UNIQUE,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT chk_pass_email CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'))
);

PROMPT 'CRS_PASSENGER created';

-- ============================================
-- TABLE 5: CRS_RESERVATION
-- ============================================
CREATE TABLE CRS_RESERVATION (
    booking_id NUMBER PRIMARY KEY,
    passenger_id NUMBER NOT NULL,
    train_id NUMBER NOT NULL,
    travel_date DATE NOT NULL,
    booking_date DATE DEFAULT SYSDATE NOT NULL,
    seat_class VARCHAR2(10) NOT NULL,
    seat_status VARCHAR2(20) DEFAULT 'CONFIRMED' NOT NULL,
    waitlist_position NUMBER,
    CONSTRAINT fk_res_passenger FOREIGN KEY (passenger_id) REFERENCES CRS_PASSENGER(passenger_id),
    CONSTRAINT fk_res_train FOREIGN KEY (train_id) REFERENCES CRS_TRAIN_INFO(train_id),
    CONSTRAINT chk_res_class CHECK (seat_class IN ('BUSINESS', 'ECONOMY')),
    CONSTRAINT chk_res_status CHECK (seat_status IN ('CONFIRMED', 'WAITLISTED', 'CANCELLED')),
    CONSTRAINT chk_res_dates CHECK (travel_date >= TRUNC(booking_date))
);

PROMPT 'CRS_RESERVATION created';

COMMIT;

PROMPT 'All tables created successfully!';