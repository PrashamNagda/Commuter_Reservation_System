-- ============================================
-- SCRIPT 1: CREATE_USERS.sql
-- Run this as ADMIN or SYSTEM user
-- ============================================
SHOW USER;

-- Drop users if they exist (for fresh start)
BEGIN
    EXECUTE IMMEDIATE 'DROP USER CRS_ADMIN CASCADE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP USER CRS_OPERATOR CASCADE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create CRS_ADMIN user (Schema owner - can create tables, procedures)
CREATE USER CRS_ADMIN IDENTIFIED BY AdminNeuBoston2025#
DEFAULT TABLESPACE DATA
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON DATA;

-- Grant necessary privileges to CRS_ADMIN
GRANT CONNECT, RESOURCE TO CRS_ADMIN;
GRANT CREATE SESSION TO CRS_ADMIN;
GRANT CREATE TABLE TO CRS_ADMIN;
GRANT CREATE SEQUENCE TO CRS_ADMIN;
GRANT CREATE PROCEDURE TO CRS_ADMIN;
GRANT CREATE TRIGGER TO CRS_ADMIN;
GRANT CREATE VIEW TO CRS_ADMIN;
GRANT CREATE SYNONYM TO CRS_ADMIN;

-- Create CRS_OPERATOR user (Application user - can only execute procedures)
CREATE USER CRS_OPERATOR IDENTIFIED BY Operator#2025
DEFAULT TABLESPACE DATA
TEMPORARY TABLESPACE TEMP;

-- Grant minimal privileges to CRS_OPERATOR
GRANT CONNECT TO CRS_OPERATOR;
GRANT CREATE SESSION TO CRS_OPERATOR;

COMMIT;

-- Verify users created
SELECT username, account_status, default_tablespace 
FROM dba_users 
WHERE username IN ('CRS_ADMIN', 'CRS_OPERATOR');

PROMPT 'Users created successfully!';
PROMPT 'CRS_ADMIN - Schema Owner (can create tables, procedures)';
PROMPT 'CRS_OPERATOR - Application User (can only execute procedures)';

--------------------------------------------------------------------------------
