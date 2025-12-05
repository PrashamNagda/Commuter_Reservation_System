-- ============================================
-- SCRIPT 3: INSERT_SAMPLE_DATA.sql
-- Connect as CRS_ADMIN and run this script
-- ============================================
SHOW USER;


TRUNCATE TABLE CRS_RESERVATION;
TRUNCATE TABLE CRS_TRAIN_SCHEDULE;
TRUNCATE TABLE CRS_PASSENGER;
TRUNCATE TABLE CRS_TRAIN_INFO;
TRUNCATE TABLE CRS_DAY_SCHEDULE;


SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT '========================================';
PROMPT 'Inserting Sample Data...';
PROMPT '========================================';

-- Insert Day Schedule (7 days of the week)
PROMPT 'Inserting Day Schedule...';
INSERT INTO CRS_DAY_SCHEDULE VALUES (seq_sch_id.NEXTVAL, 'MONDAY', 'N');
INSERT INTO CRS_DAY_SCHEDULE VALUES (seq_sch_id.NEXTVAL, 'TUESDAY', 'N');
INSERT INTO CRS_DAY_SCHEDULE VALUES (seq_sch_id.NEXTVAL, 'WEDNESDAY', 'N');
INSERT INTO CRS_DAY_SCHEDULE VALUES (seq_sch_id.NEXTVAL, 'THURSDAY', 'N');
INSERT INTO CRS_DAY_SCHEDULE VALUES (seq_sch_id.NEXTVAL, 'FRIDAY', 'N');
INSERT INTO CRS_DAY_SCHEDULE VALUES (seq_sch_id.NEXTVAL, 'SATURDAY', 'Y');
INSERT INTO CRS_DAY_SCHEDULE VALUES (seq_sch_id.NEXTVAL, 'SUNDAY', 'Y');

PROMPT '7 days inserted successfully.';

-- Insert Train Information
PROMPT 'Inserting Train Information...';
INSERT INTO CRS_TRAIN_INFO VALUES (seq_train_id.NEXTVAL, 'TRN001', 'Boston South Station', 'New York Penn Station', 40, 40, 150.00, 75.00);
INSERT INTO CRS_TRAIN_INFO VALUES (seq_train_id.NEXTVAL, 'TRN002', 'Boston South Station', 'Washington DC Union', 40, 40, 200.00, 100.00);
INSERT INTO CRS_TRAIN_INFO VALUES (seq_train_id.NEXTVAL, 'TRN003', 'New York Penn Station', 'Philadelphia 30th Street', 40, 40, 80.00, 45.00);
INSERT INTO CRS_TRAIN_INFO VALUES (seq_train_id.NEXTVAL, 'TRN004', 'Boston South Station', 'Providence Station', 40, 40, 50.00, 25.00);
INSERT INTO CRS_TRAIN_INFO VALUES (seq_train_id.NEXTVAL, 'TRN005', 'New York Penn Station', 'Boston South Station', 40, 40, 150.00, 75.00);
INSERT INTO CRS_TRAIN_INFO VALUES (seq_train_id.NEXTVAL, 'TRN006', 'Philadelphia 30th Street', 'Washington DC Union', 40, 40, 90.00, 50.00);

PROMPT '6 trains inserted successfully.';

-- Insert Train Schedules
PROMPT 'Creating Train Schedules...';

-- TRN001 - Available all days (7 days a week)
DECLARE
    v_train_id NUMBER;
BEGIN
    SELECT train_id INTO v_train_id FROM CRS_TRAIN_INFO WHERE train_number = 'TRN001';
    FOR day IN (SELECT sch_id FROM CRS_DAY_SCHEDULE) LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE VALUES (seq_tsch_id.NEXTVAL, day.sch_id, v_train_id, 'Y');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TRN001 scheduled for all days');
END;
/

-- TRN002 - Available only on weekdays (Monday to Friday)
DECLARE
    v_train_id NUMBER;
BEGIN
    SELECT train_id INTO v_train_id FROM CRS_TRAIN_INFO WHERE train_number = 'TRN002';
    FOR day IN (SELECT sch_id FROM CRS_DAY_SCHEDULE WHERE is_week_end = 'N') LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE VALUES (seq_tsch_id.NEXTVAL, day.sch_id, v_train_id, 'Y');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TRN002 scheduled for weekdays only');
END;
/

-- TRN003 - Available only on weekends (Saturday and Sunday)
DECLARE
    v_train_id NUMBER;
BEGIN
    SELECT train_id INTO v_train_id FROM CRS_TRAIN_INFO WHERE train_number = 'TRN003';
    FOR day IN (SELECT sch_id FROM CRS_DAY_SCHEDULE WHERE is_week_end = 'Y') LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE VALUES (seq_tsch_id.NEXTVAL, day.sch_id, v_train_id, 'Y');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TRN003 scheduled for weekends only');
END;
/

-- TRN004 - Available all days
DECLARE
    v_train_id NUMBER;
BEGIN
    SELECT train_id INTO v_train_id FROM CRS_TRAIN_INFO WHERE train_number = 'TRN004';
    FOR day IN (SELECT sch_id FROM CRS_DAY_SCHEDULE) LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE VALUES (seq_tsch_id.NEXTVAL, day.sch_id, v_train_id, 'Y');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TRN004 scheduled for all days');
END;
/

-- TRN005 - Available on weekdays
DECLARE
    v_train_id NUMBER;
BEGIN
    SELECT train_id INTO v_train_id FROM CRS_TRAIN_INFO WHERE train_number = 'TRN005';
    FOR day IN (SELECT sch_id FROM CRS_DAY_SCHEDULE WHERE is_week_end = 'N') LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE VALUES (seq_tsch_id.NEXTVAL, day.sch_id, v_train_id, 'Y');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TRN005 scheduled for weekdays only');
END;
/

-- TRN006 - Available on weekends
DECLARE
    v_train_id NUMBER;
BEGIN
    SELECT train_id INTO v_train_id FROM CRS_TRAIN_INFO WHERE train_number = 'TRN006';
    FOR day IN (SELECT sch_id FROM CRS_DAY_SCHEDULE WHERE is_week_end = 'Y') LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE VALUES (seq_tsch_id.NEXTVAL, day.sch_id, v_train_id, 'Y');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TRN006 scheduled for weekends only');
END;
/

-- Insert Sample Passengers
PROMPT 'Inserting Sample Passengers...';

INSERT INTO CRS_PASSENGER VALUES (seq_passenger_id.NEXTVAL, 'John', 'Michael', 'Smith', 
    TO_DATE('1990-05-15', 'YYYY-MM-DD'), '123 Main St', 'Boston', 'MA', '02101', 
    'john.smith@email.com', '6171234567', SYSDATE);

INSERT INTO CRS_PASSENGER VALUES (seq_passenger_id.NEXTVAL, 'Sarah', 'Anne', 'Johnson', 
    TO_DATE('1985-08-22', 'YYYY-MM-DD'), '456 Oak Ave', 'Cambridge', 'MA', '02139', 
    'sarah.johnson@email.com', '6179876543', SYSDATE);

INSERT INTO CRS_PASSENGER VALUES (seq_passenger_id.NEXTVAL, 'Michael', NULL, 'Williams', 
    TO_DATE('2010-03-10', 'YYYY-MM-DD'), '789 Elm St', 'Somerville', 'MA', '02144', 
    'michael.williams@email.com', '6175551234', SYSDATE);

INSERT INTO CRS_PASSENGER VALUES (seq_passenger_id.NEXTVAL, 'Emily', 'Grace', 'Brown', 
    TO_DATE('1955-12-05', 'YYYY-MM-DD'), '321 Pine Rd', 'Brookline', 'MA', '02445', 
    'emily.brown@email.com', '6175559876', SYSDATE);

INSERT INTO CRS_PASSENGER VALUES (seq_passenger_id.NEXTVAL, 'David', 'Robert', 'Davis', 
    TO_DATE('1995-07-18', 'YYYY-MM-DD'), '654 Maple Dr', 'Newton', 'MA', '02458', 
    'david.davis@email.com', '6175555678', SYSDATE);

INSERT INTO CRS_PASSENGER VALUES (seq_passenger_id.NEXTVAL, 'Jennifer', 'Marie', 'Wilson', 
    TO_DATE('2008-11-30', 'YYYY-MM-DD'), '987 Cedar Ln', 'Quincy', 'MA', '02169', 
    'jennifer.wilson@email.com', '6175554321', SYSDATE);

COMMIT;