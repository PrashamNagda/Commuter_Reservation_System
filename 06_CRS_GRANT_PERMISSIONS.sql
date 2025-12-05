-- ============================================
-- SCRIPT 6: GRANT_PERMISSIONS.sql
-- Connect as CRS_ADMIN and run this script
-- Grants EXECUTE and SELECT permissions
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT '========================================';
PROMPT 'Granting Permissions to CRS_OPERATOR...';
PROMPT '========================================';
PROMPT '';

-- ============================================
-- PART 1: Grant EXECUTE permissions on packages
-- ============================================
PROMPT '1. Granting EXECUTE permissions on packages...';

GRANT EXECUTE ON CRS_VALIDATION_PKG TO CRS_OPERATOR;
GRANT EXECUTE ON CRS_BOOKING_PKG TO CRS_OPERATOR;

BEGIN
    DBMS_OUTPUT.PUT_LINE('   ✓ EXECUTE granted on CRS_VALIDATION_PKG');
    DBMS_OUTPUT.PUT_LINE('   ✓ EXECUTE granted on CRS_BOOKING_PKG');
END;
/

-- ============================================
-- PART 2: Create public synonyms
-- ============================================
PROMPT '';
PROMPT '2. Creating public synonyms...';

BEGIN
    EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM CRS_VALIDATION_PKG FOR CRS_ADMIN.CRS_VALIDATION_PKG';
    DBMS_OUTPUT.PUT_LINE('   ✓ Synonym created for CRS_VALIDATION_PKG');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('   ⊗ Synonym creation requires additional privileges');
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM CRS_BOOKING_PKG FOR CRS_ADMIN.CRS_BOOKING_PKG';
    DBMS_OUTPUT.PUT_LINE('   ✓ Synonym created for CRS_BOOKING_PKG');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('   ⊗ Synonym creation requires additional privileges');
END;
/

-- ============================================
-- PART 3: Grant SELECT permissions on tables
-- ============================================
PROMPT '';
PROMPT '3. Granting SELECT permissions on tables...';

GRANT SELECT ON CRS_TRAIN_INFO TO CRS_OPERATOR;
GRANT SELECT ON CRS_DAY_SCHEDULE TO CRS_OPERATOR;
GRANT SELECT ON CRS_TRAIN_SCHEDULE TO CRS_OPERATOR;
GRANT SELECT ON CRS_PASSENGER TO CRS_OPERATOR;
GRANT SELECT ON CRS_RESERVATION TO CRS_OPERATOR;

BEGIN
    DBMS_OUTPUT.PUT_LINE('   ✓ SELECT granted on all 5 tables');
END;
/

COMMIT;

PROMPT '';
PROMPT '========================================';
PROMPT 'PERMISSIONS SUMMARY';
PROMPT '========================================';
PROMPT 'CRS_OPERATOR can now:';

BEGIN
    DBMS_OUTPUT.PUT_LINE('  ✓ EXECUTE packages (register, book, cancel)');
    DBMS_OUTPUT.PUT_LINE('  ✓ SELECT from tables (for testing/verification)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('CRS_OPERATOR CANNOT:');
    DBMS_OUTPUT.PUT_LINE('  ✗ INSERT/UPDATE/DELETE tables directly');
    DBMS_OUTPUT.PUT_LINE('  ✗ CREATE tables or procedures');
    DBMS_OUTPUT.PUT_LINE('  ✗ Modify schema structure');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('All permissions granted successfully!');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
