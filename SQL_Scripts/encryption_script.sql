-- =============================================
-- Event & Ticket Booking System - ENCRYPTION Script
-- Group 5 - DAMG6210
-- P5 Submission - Column-Level Encryption for Sensitive Data
-- =============================================

USE EventBookingSystem;
GO

PRINT '============================================='
PRINT 'COLUMN-LEVEL ENCRYPTION SETUP'
PRINT '============================================='
PRINT 'Purpose: Encrypt sensitive data (passwords, card numbers)'
PRINT '============================================='
GO

-- =============================================
-- SECTION 1: CREATE MASTER KEY
-- =============================================

PRINT ''
PRINT '--- Section 1: Creating Database Master Key ---'
GO

-- Check if master key exists
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'EventBooking@SecureKey2024!';
    PRINT 'Database Master Key created successfully.';
END
ELSE
BEGIN
    PRINT 'Database Master Key already exists.';
END
GO

-- =============================================
-- SECTION 2: CREATE CERTIFICATE
-- =============================================

PRINT ''
PRINT '--- Section 2: Creating Certificate ---'
GO

-- Check if certificate exists
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'EventBookingCert')
BEGIN
    CREATE CERTIFICATE EventBookingCert
    WITH SUBJECT = 'Certificate for Event Booking System Encryption',
    EXPIRY_DATE = '2030-12-31';
    PRINT 'Certificate created successfully.';
END
ELSE
BEGIN
    PRINT 'Certificate already exists.';
END
GO

-- =============================================
-- SECTION 3: CREATE SYMMETRIC KEY
-- =============================================

PRINT ''
PRINT '--- Section 3: Creating Symmetric Key ---'
GO

-- Check if symmetric key exists
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'EventBookingSymKey')
BEGIN
    CREATE SYMMETRIC KEY EventBookingSymKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE EventBookingCert;
    PRINT 'Symmetric Key created successfully.';
END
ELSE
BEGIN
    PRINT 'Symmetric Key already exists.';
END
GO

-- =============================================
-- SECTION 4: ADD ENCRYPTED COLUMNS
-- =============================================

PRINT ''
PRINT '--- Section 4: Adding Encrypted Columns ---'
GO

-- Add encrypted column for USER.PasswordHash
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[USER]') AND name = 'PasswordHashEncrypted')
BEGIN
    ALTER TABLE [USER]
    ADD PasswordHashEncrypted VARBINARY(256);
    PRINT 'Added PasswordHashEncrypted column to USER table.';
END
ELSE
BEGIN
    PRINT 'PasswordHashEncrypted column already exists in USER table.';
END
GO

-- Add encrypted column for CARD_PAYMENT.CardNumber
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('CARD_PAYMENT') AND name = 'CardNumberEncrypted')
BEGIN
    ALTER TABLE CARD_PAYMENT
    ADD CardNumberEncrypted VARBINARY(256);
    PRINT 'Added CardNumberEncrypted column to CARD_PAYMENT table.';
END
ELSE
BEGIN
    PRINT 'CardNumberEncrypted column already exists in CARD_PAYMENT table.';
END
GO

-- =============================================
-- SECTION 5: ENCRYPT EXISTING DATA
-- =============================================

PRINT ''
PRINT '--- Section 5: Encrypting Existing Data ---'
GO

-- Open the symmetric key
OPEN SYMMETRIC KEY EventBookingSymKey
DECRYPTION BY CERTIFICATE EventBookingCert;

-- Encrypt existing passwords in USER table
UPDATE [USER]
SET PasswordHashEncrypted = EncryptByKey(Key_GUID('EventBookingSymKey'), PasswordHash)
WHERE PasswordHashEncrypted IS NULL;

PRINT 'Encrypted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' passwords in USER table.';

-- Encrypt existing card numbers in CARD_PAYMENT table
UPDATE CARD_PAYMENT
SET CardNumberEncrypted = EncryptByKey(Key_GUID('EventBookingSymKey'), CardNumber)
WHERE CardNumberEncrypted IS NULL;

PRINT 'Encrypted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' card numbers in CARD_PAYMENT table.';

-- Close the symmetric key
CLOSE SYMMETRIC KEY EventBookingSymKey;

PRINT 'Symmetric Key closed.';
GO

-- =============================================
-- SECTION 6: CREATE STORED PROCEDURES FOR ENCRYPTION/DECRYPTION
-- =============================================

PRINT ''
PRINT '--- Section 6: Creating Encryption Helper Procedures ---'
GO

-- Procedure to decrypt and verify user password
IF OBJECT_ID('sp_VerifyUserPassword', 'P') IS NOT NULL
    DROP PROCEDURE sp_VerifyUserPassword;
GO

CREATE PROCEDURE sp_VerifyUserPassword
    @Email VARCHAR(100),
    @PasswordToVerify VARCHAR(255),
    @IsValid BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DecryptedPassword VARCHAR(255);
    
    BEGIN TRY
        -- Open symmetric key
        OPEN SYMMETRIC KEY EventBookingSymKey
        DECRYPTION BY CERTIFICATE EventBookingCert;
        
        -- Decrypt and compare password
        SELECT @DecryptedPassword = CONVERT(VARCHAR(255), DecryptByKey(PasswordHashEncrypted))
        FROM [USER]
        WHERE Email = @Email;
        
        -- Close symmetric key
        CLOSE SYMMETRIC KEY EventBookingSymKey;
        
        -- Verify password
        IF @DecryptedPassword = @PasswordToVerify
            SET @IsValid = 1;
        ELSE
            SET @IsValid = 0;
    END TRY
    BEGIN CATCH
        -- Ensure key is closed on error
        IF EXISTS (SELECT * FROM sys.openkeys WHERE key_name = 'EventBookingSymKey')
            CLOSE SYMMETRIC KEY EventBookingSymKey;
        
        SET @IsValid = 0;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Error in sp_VerifyUserPassword: ' + @ErrorMessage;
    END CATCH
END;
GO

PRINT 'Created sp_VerifyUserPassword procedure.';
GO

-- Procedure to get decrypted card number (last 4 digits only for display)
IF OBJECT_ID('sp_GetMaskedCardNumber', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetMaskedCardNumber;
GO

CREATE PROCEDURE sp_GetMaskedCardNumber
    @CardID INT,
    @MaskedCardNumber VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DecryptedCardNumber VARCHAR(16);
    
    BEGIN TRY
        -- Open symmetric key
        OPEN SYMMETRIC KEY EventBookingSymKey
        DECRYPTION BY CERTIFICATE EventBookingCert;
        
        -- Decrypt card number
        SELECT @DecryptedCardNumber = CONVERT(VARCHAR(16), DecryptByKey(CardNumberEncrypted))
        FROM CARD_PAYMENT
        WHERE CardID = @CardID;
        
        -- Close symmetric key
        CLOSE SYMMETRIC KEY EventBookingSymKey;
        
        -- Return masked card number (show last 4 digits only)
        IF @DecryptedCardNumber IS NOT NULL
            SET @MaskedCardNumber = '************' + RIGHT(@DecryptedCardNumber, 4);
        ELSE
            SET @MaskedCardNumber = NULL;
    END TRY
    BEGIN CATCH
        -- Ensure key is closed on error
        IF EXISTS (SELECT * FROM sys.openkeys WHERE key_name = 'EventBookingSymKey')
            CLOSE SYMMETRIC KEY EventBookingSymKey;
        
        SET @MaskedCardNumber = NULL;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Error in sp_GetMaskedCardNumber: ' + @ErrorMessage;
    END CATCH
END;
GO

PRINT 'Created sp_GetMaskedCardNumber procedure.';
GO

-- Procedure to add new user with encrypted password
IF OBJECT_ID('sp_CreateUserWithEncryption', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateUserWithEncryption;
GO

CREATE PROCEDURE sp_CreateUserWithEncryption
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @PhoneNumber VARCHAR(15),
    @Password VARCHAR(255),
    @Role VARCHAR(20),
    @UserID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EncryptedPassword VARBINARY(256);
    
    BEGIN TRY
        -- Open symmetric key
        OPEN SYMMETRIC KEY EventBookingSymKey
        DECRYPTION BY CERTIFICATE EventBookingCert;
        
        -- Encrypt password
        SET @EncryptedPassword = EncryptByKey(Key_GUID('EventBookingSymKey'), @Password);
        
        -- Close symmetric key
        CLOSE SYMMETRIC KEY EventBookingSymKey;
        
        -- Start transaction
        BEGIN TRANSACTION;
        
        -- Insert user with encrypted password
        INSERT INTO [USER] (FirstName, LastName, Email, PhoneNumber, PasswordHash, PasswordHashEncrypted, Role, CustomerID, EmployeeID, OrganizerID)
        VALUES (
            @FirstName,
            @LastName,
            @Email,
            @PhoneNumber,
            @Password, -- Store plain text temporarily (will be removed later)
            @EncryptedPassword,
            @Role,
            NULL,
            NULL,
            NULL
        );
        
        SET @UserID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'User created with encrypted password. UserID: ' + CAST(@UserID AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Ensure key is closed on error
        IF EXISTS (SELECT * FROM sys.openkeys WHERE key_name = 'EventBookingSymKey')
            CLOSE SYMMETRIC KEY EventBookingSymKey;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

PRINT 'Created sp_CreateUserWithEncryption procedure.';
GO

-- Procedure to add card payment with encrypted card number
IF OBJECT_ID('sp_AddCardPaymentWithEncryption', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddCardPaymentWithEncryption;
GO

CREATE PROCEDURE sp_AddCardPaymentWithEncryption
    @PaymentID INT,
    @CardNumber VARCHAR(16),
    @CardHolderName VARCHAR(100),
    @ExpiryDate DATE,
    @CardID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EncryptedCardNumber VARBINARY(256);
    
    BEGIN TRY
        -- Open symmetric key
        OPEN SYMMETRIC KEY EventBookingSymKey
        DECRYPTION BY CERTIFICATE EventBookingCert;
        
        -- Encrypt card number
        SET @EncryptedCardNumber = EncryptByKey(Key_GUID('EventBookingSymKey'), @CardNumber);
        
        -- Close symmetric key
        CLOSE SYMMETRIC KEY EventBookingSymKey;
        
        -- Start transaction
        BEGIN TRANSACTION;
        
        -- Insert card payment with encrypted card number
        INSERT INTO CARD_PAYMENT (PaymentID, CardNumber, CardNumberEncrypted, CardHolderName, ExpiryDate)
        VALUES (
            @PaymentID,
            @CardNumber, -- Store plain text temporarily (will be removed later)
            @EncryptedCardNumber,
            @CardHolderName,
            @ExpiryDate
        );
        
        SET @CardID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Card payment created with encrypted card number. CardID: ' + CAST(@CardID AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Ensure key is closed on error
        IF EXISTS (SELECT * FROM sys.openkeys WHERE key_name = 'EventBookingSymKey')
            CLOSE SYMMETRIC KEY EventBookingSymKey;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

PRINT 'Created sp_AddCardPaymentWithEncryption procedure.';
GO

-- =============================================
-- SECTION 7: VERIFICATION AND TESTING
-- =============================================

PRINT ''
PRINT '--- Section 7: Verification ---'
GO

-- Verify encryption setup
PRINT 'Verifying Encryption Setup:'
PRINT ''

-- Check Master Key
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    PRINT '✓ Database Master Key exists'
ELSE
    PRINT '✗ Database Master Key missing'

-- Check Certificate
IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'EventBookingCert')
    PRINT '✓ Certificate exists'
ELSE
    PRINT '✗ Certificate missing'

-- Check Symmetric Key
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'EventBookingSymKey')
    PRINT '✓ Symmetric Key exists'
ELSE
    PRINT '✗ Symmetric Key missing'

-- Check encrypted columns
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[USER]') AND name = 'PasswordHashEncrypted')
    PRINT '✓ PasswordHashEncrypted column exists'
ELSE
    PRINT '✗ PasswordHashEncrypted column missing'

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('CARD_PAYMENT') AND name = 'CardNumberEncrypted')
    PRINT '✓ CardNumberEncrypted column exists'
ELSE
    PRINT '✗ CardNumberEncrypted column missing'

GO

-- =============================================
-- SECTION 8: SAMPLE DECRYPTION QUERIES
-- =============================================

PRINT ''
PRINT '--- Section 8: Sample Encrypted Data View ---'
GO

PRINT 'Encrypted vs Plain Text Comparison (First 5 Users):'

-- Open symmetric key
OPEN SYMMETRIC KEY EventBookingSymKey
DECRYPTION BY CERTIFICATE EventBookingCert;

-- Show comparison for users
SELECT TOP 5
    UserID,
    FirstName,
    LastName,
    Email,
    PasswordHash AS PlainTextPassword,
    PasswordHashEncrypted AS EncryptedPassword,
    CONVERT(VARCHAR(255), DecryptByKey(PasswordHashEncrypted)) AS DecryptedPassword
FROM [USER];

PRINT ''
PRINT 'Encrypted vs Plain Text Comparison (First 5 Card Payments):'

-- Show comparison for card payments
SELECT TOP 5
    CardID,
    PaymentID,
    CardHolderName,
    CardNumber AS PlainTextCardNumber,
    CardNumberEncrypted AS EncryptedCardNumber,
    CONVERT(VARCHAR(16), DecryptByKey(CardNumberEncrypted)) AS DecryptedCardNumber,
    '************' + RIGHT(CONVERT(VARCHAR(16), DecryptByKey(CardNumberEncrypted)), 4) AS MaskedCardNumber
FROM CARD_PAYMENT
WHERE CardNumberEncrypted IS NOT NULL;

-- Close symmetric key
CLOSE SYMMETRIC KEY EventBookingSymKey;

GO

-- =============================================
-- SECTION 9: TESTING ENCRYPTION PROCEDURES
-- =============================================

PRINT ''
PRINT '--- Section 9: Testing Encryption Procedures ---'
GO

-- Test 1: Verify user password
PRINT 'Test 1: Password Verification'
DECLARE @IsPasswordValid BIT;
EXEC sp_VerifyUserPassword 
    @Email = 'michael.anderson@email.com',
    @PasswordToVerify = 'TEMP_HASH_001',
    @IsValid = @IsPasswordValid OUTPUT;

IF @IsPasswordValid = 1
    PRINT '✓ Password verification successful'
ELSE
    PRINT '✗ Password verification failed'
GO

-- Test 2: Get masked card number
PRINT ''
PRINT 'Test 2: Masked Card Number Retrieval'
DECLARE @MaskedCard VARCHAR(20);
EXEC sp_GetMaskedCardNumber 
    @CardID = 1,
    @MaskedCardNumber = @MaskedCard OUTPUT;

PRINT 'Masked Card Number: ' + ISNULL(@MaskedCard, 'NULL');
GO

-- Test 3: Create new user with encryption
PRINT ''
PRINT 'Test 3: Create New User with Encrypted Password'
DECLARE @NewUserID INT;
EXEC sp_CreateUserWithEncryption
    @FirstName = 'Test',
    @LastName = 'User',
    @Email = 'test.user@email.com',
    @PhoneNumber = '617-555-9999',
    @Password = 'TestPassword123',
    @Role = 'Customer',
    @UserID = @NewUserID OUTPUT;

PRINT 'New User Created with UserID: ' + CAST(@NewUserID AS VARCHAR);

-- Verify the new user
OPEN SYMMETRIC KEY EventBookingSymKey
DECRYPTION BY CERTIFICATE EventBookingCert;

SELECT 
    UserID,
    FirstName,
    LastName,
    Email,
    CONVERT(VARCHAR(255), DecryptByKey(PasswordHashEncrypted)) AS DecryptedPassword
FROM [USER]
WHERE UserID = @NewUserID;

CLOSE SYMMETRIC KEY EventBookingSymKey;
GO

-- =============================================
-- FINAL SUMMARY
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'ENCRYPTION SCRIPT COMPLETED SUCCESSFULLY!'
PRINT '============================================='
PRINT ''
PRINT 'Summary:'
PRINT '- Database Master Key created'
PRINT '- Certificate created (valid until 2030-12-31)'
PRINT '- Symmetric Key created (AES-256)'
PRINT '- 2 columns encrypted (PasswordHash, CardNumber)'
PRINT '- 4 encryption helper procedures created'
PRINT '- All existing data encrypted'
PRINT '============================================='
PRINT ''
PRINT 'IMPORTANT SECURITY NOTES:'
PRINT '1. Keep master key password secure: EventBooking@SecureKey2024!'
PRINT '2. Backup certificate regularly using BACKUP CERTIFICATE'
PRINT '3. Original plain text columns can be dropped after verification'
PRINT '4. Use encryption procedures for all new data'
PRINT '5. Never expose decrypted data in application logs'
PRINT '============================================='
PRINT ''
PRINT 'Next Steps (Optional - For Production):'
PRINT '1. DROP plain text columns after verification:'
PRINT '   ALTER TABLE [USER] DROP COLUMN PasswordHash;'
PRINT '   ALTER TABLE CARD_PAYMENT DROP COLUMN CardNumber;'
PRINT '2. Backup certificate:'
PRINT '   BACKUP CERTIFICATE EventBookingCert TO FILE = ''path\EventBookingCert.cer'''
PRINT '   WITH PRIVATE KEY (FILE = ''path\EventBookingCert.pvk'','
PRINT '   ENCRYPTION BY PASSWORD = ''CertPassword123!'');'
PRINT '============================================='
GO