-- =============================================
-- Event & Ticket Booking System - PSM Script
-- Group 5 - DAMG6210
-- P5 Submission - Stored Procedures, Functions, Views, and Triggers
-- =============================================

USE EventBookingSystem;
GO

-- =============================================
-- SECTION 1: STORED PROCEDURES (5 with Transaction Management & Error Handling)
-- =============================================

-- =============================================
-- SP1: Create New Booking with Payment
-- Purpose: Creates a complete booking with tickets, seat assignments, and payment in a single transaction
-- =============================================
IF OBJECT_ID('sp_CreateBookingWithPayment', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateBookingWithPayment;
GO

CREATE PROCEDURE sp_CreateBookingWithPayment
    @CustomerID INT,
    @EventID INT,
    @ShowID INT,
    @SeatIDs VARCHAR(MAX), -- Comma-separated seat IDs
    @PaymentAmount DECIMAL(10,2),
    @PaymentType VARCHAR(20), -- 'Card', 'Wallet', 'PayPal'
    @CardNumber VARCHAR(16) = NULL,
    @CardHolderName VARCHAR(100) = NULL,
    @WalletType VARCHAR(50) = NULL,
    @PayPalEmail VARCHAR(100) = NULL,
    @BookingID INT OUTPUT,
    @PaymentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Error handling variables
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    -- Transaction control
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate customer exists
        IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE CustomerID = @CustomerID)
        BEGIN
            RAISERROR('Customer does not exist.', 16, 1);
        END
        
        -- Validate event exists
        IF NOT EXISTS (SELECT 1 FROM EVENT WHERE EventID = @EventID)
        BEGIN
            RAISERROR('Event does not exist.', 16, 1);
        END
        
        -- Validate show exists
        IF NOT EXISTS (SELECT 1 FROM SHOW WHERE ShowID = @ShowID)
        BEGIN
            RAISERROR('Show does not exist.', 16, 1);
        END
        
        -- Check if seats are already booked
        IF EXISTS (
            SELECT 1 FROM SEAT_BOOKING SB
            WHERE SB.ShowID = @ShowID 
            AND SB.SeatID IN (SELECT value FROM STRING_SPLIT(@SeatIDs, ','))
        )
        BEGIN
            RAISERROR('One or more seats are already booked for this show.', 16, 1);
        END
        
        -- Create booking
        INSERT INTO BOOKING (CustomerID, EventID, BookingDateTime, TotalAmount, BookingStatus)
        VALUES (@CustomerID, @EventID, GETDATE(), @PaymentAmount, 'Confirmed');
        
        SET @BookingID = SCOPE_IDENTITY();
        
        -- Create seat bookings
        INSERT INTO SEAT_BOOKING (BookingID, SeatID, ShowID)
        SELECT @BookingID, value, @ShowID
        FROM STRING_SPLIT(@SeatIDs, ',');
        
        -- Generate tickets for each seat
        INSERT INTO TICKET (BookingID, TicketStatus, IssueDate, ValidUntil, QRCode)
        SELECT 
            @BookingID,
            'Active',
            CAST(GETDATE() AS DATE),
            DATEADD(DAY, 30, CAST(GETDATE() AS DATE)),
            'QR' + CAST(@BookingID AS VARCHAR) + '-' + CAST(value AS VARCHAR)
        FROM STRING_SPLIT(@SeatIDs, ',');
        
        -- Create payment
        DECLARE @TransactionRef VARCHAR(100) = 'TXN-' + FORMAT(GETDATE(), 'yyyyMMddHHmmss') + '-' + CAST(@BookingID AS VARCHAR);
        
        INSERT INTO PAYMENT (BookingID, Amount, PaymentDateTime, TransactionReference)
        VALUES (@BookingID, @PaymentAmount, GETDATE(), @TransactionRef);
        
        SET @PaymentID = SCOPE_IDENTITY();
        
        -- Create specific payment type
        IF @PaymentType = 'Card'
        BEGIN
            IF @CardNumber IS NULL OR @CardHolderName IS NULL
                RAISERROR('Card details are required for card payment.', 16, 1);
                
            INSERT INTO CARD_PAYMENT (PaymentID, CardNumber, CardHolderName, ExpiryDate)
            VALUES (@PaymentID, @CardNumber, @CardHolderName, DATEADD(YEAR, 3, GETDATE()));
        END
        ELSE IF @PaymentType = 'Wallet'
        BEGIN
            IF @WalletType IS NULL
                RAISERROR('Wallet type is required for wallet payment.', 16, 1);
                
            INSERT INTO WALLET_PAYMENT (PaymentID, WalletType)
            VALUES (@PaymentID, @WalletType);
        END
        ELSE IF @PaymentType = 'PayPal'
        BEGIN
            IF @PayPalEmail IS NULL
                RAISERROR('PayPal email is required for PayPal payment.', 16, 1);
                
            INSERT INTO PAYPAL_PAYMENT (PaymentID, PayPalEmail)
            VALUES (@PaymentID, @PayPalEmail);
        END
        ELSE
        BEGIN
            RAISERROR('Invalid payment type. Must be Card, Wallet, or PayPal.', 16, 1);
        END
        
        -- Update customer loyalty points (1 point per dollar spent)
        UPDATE CUSTOMER 
        SET LoyaltyPoints = LoyaltyPoints + CAST(@PaymentAmount AS INT)
        WHERE CustomerID = @CustomerID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Booking created successfully. BookingID: ' + CAST(@BookingID AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =============================================
-- SP2: Cancel Booking and Process Refund
-- Purpose: Cancels a booking and processes refund with proper transaction handling
-- =============================================
IF OBJECT_ID('sp_CancelBooking', 'P') IS NOT NULL
    DROP PROCEDURE sp_CancelBooking;
GO

CREATE PROCEDURE sp_CancelBooking
    @BookingID INT,
    @RefundAmount DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @CustomerID INT;
    DECLARE @BookingStatus VARCHAR(20);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate booking exists and get details
        SELECT @CustomerID = CustomerID, @BookingStatus = BookingStatus, @RefundAmount = TotalAmount
        FROM BOOKING
        WHERE BookingID = @BookingID;
        
        IF @CustomerID IS NULL
        BEGIN
            RAISERROR('Booking does not exist.', 16, 1);
        END
        
        IF @BookingStatus = 'Cancelled'
        BEGIN
            RAISERROR('Booking is already cancelled.', 16, 1);
        END
        
        IF @BookingStatus = 'Completed'
        BEGIN
            RAISERROR('Cannot cancel a completed booking.', 16, 1);
        END
        
        -- Update booking status
        UPDATE BOOKING
        SET BookingStatus = 'Cancelled'
        WHERE BookingID = @BookingID;
        
        -- Cancel all tickets
        UPDATE TICKET
        SET TicketStatus = 'Cancelled'
        WHERE BookingID = @BookingID;
        
        -- Remove seat bookings to free up seats
        DELETE FROM SEAT_BOOKING
        WHERE BookingID = @BookingID;
        
        -- Deduct loyalty points (refund policy: lose points on cancellation)
        UPDATE CUSTOMER
        SET LoyaltyPoints = LoyaltyPoints - CAST(@RefundAmount AS INT)
        WHERE CustomerID = @CustomerID AND LoyaltyPoints >= CAST(@RefundAmount AS INT);
        
        COMMIT TRANSACTION;
        
        PRINT 'Booking cancelled successfully. RefundAmount: ' + CAST(@RefundAmount AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =============================================
-- SP3: Add Snacks to Booking
-- Purpose: Adds snack items to an existing booking and updates total amount
-- =============================================
IF OBJECT_ID('sp_AddSnacksToBooking', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddSnacksToBooking;
GO

CREATE PROCEDURE sp_AddSnacksToBooking
    @BookingID INT,
    @SnackID INT,
    @Quantity INT,
    @NewTotalAmount DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @UnitPrice DECIMAL(10,2);
    DECLARE @Subtotal DECIMAL(10,2);
    DECLARE @CurrentTotal DECIMAL(10,2);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate booking exists and is active
        IF NOT EXISTS (SELECT 1 FROM BOOKING WHERE BookingID = @BookingID AND BookingStatus = 'Confirmed')
        BEGIN
            RAISERROR('Booking does not exist or is not in confirmed status.', 16, 1);
        END
        
        -- Validate snack exists and get price
        SELECT @UnitPrice = Price
        FROM SNACK
        WHERE SnackID = @SnackID;
        
        IF @UnitPrice IS NULL
        BEGIN
            RAISERROR('Snack does not exist.', 16, 1);
        END
        
        -- Validate quantity
        IF @Quantity <= 0
        BEGIN
            RAISERROR('Quantity must be greater than zero.', 16, 1);
        END
        
        -- Calculate subtotal
        SET @Subtotal = @UnitPrice * @Quantity;
        
        -- Check if snack already exists in booking
        IF EXISTS (SELECT 1 FROM BOOKING_SNACK WHERE BookingID = @BookingID AND SnackID = @SnackID)
        BEGIN
            -- Update existing snack quantity
            UPDATE BOOKING_SNACK
            SET Quantity = Quantity + @Quantity,
                Subtotal = Subtotal + @Subtotal
            WHERE BookingID = @BookingID AND SnackID = @SnackID;
        END
        ELSE
        BEGIN
            -- Add new snack
            INSERT INTO BOOKING_SNACK (BookingID, SnackID, Quantity, UnitPrice, Subtotal, MatchDateTime)
            VALUES (@BookingID, @SnackID, @Quantity, @UnitPrice, @Subtotal, NULL);
        END
        
        -- Update booking total amount
        UPDATE BOOKING
        SET TotalAmount = TotalAmount + @Subtotal
        WHERE BookingID = @BookingID;
        
        -- Get new total
        SELECT @NewTotalAmount = TotalAmount
        FROM BOOKING
        WHERE BookingID = @BookingID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Snacks added successfully. New Total: ' + CAST(@NewTotalAmount AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =============================================
-- SP4: Update Event Status
-- Purpose: Updates event status and cascades changes to related shows and bookings
-- =============================================
IF OBJECT_ID('sp_UpdateEventStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateEventStatus;
GO

CREATE PROCEDURE sp_UpdateEventStatus
    @EventID INT,
    @NewStatus VARCHAR(20),
    @AffectedBookings INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @CurrentStatus VARCHAR(20);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate event exists
        SELECT @CurrentStatus = Status
        FROM EVENT
        WHERE EventID = @EventID;
        
        IF @CurrentStatus IS NULL
        BEGIN
            RAISERROR('Event does not exist.', 16, 1);
        END
        
        -- Validate new status
        IF @NewStatus NOT IN ('Scheduled', 'Ongoing', 'Completed', 'Cancelled')
        BEGIN
            RAISERROR('Invalid status. Must be Scheduled, Ongoing, Completed, or Cancelled.', 16, 1);
        END
        
        -- Update event status
        UPDATE EVENT
        SET Status = @NewStatus
        WHERE EventID = @EventID;
        
        -- If event is cancelled, cancel all associated bookings
        IF @NewStatus = 'Cancelled'
        BEGIN
            UPDATE BOOKING
            SET BookingStatus = 'Cancelled'
            WHERE EventID = @EventID AND BookingStatus = 'Confirmed';
            
            SET @AffectedBookings = @@ROWCOUNT;
            
            -- Cancel all tickets for these bookings
            UPDATE T
            SET T.TicketStatus = 'Cancelled'
            FROM TICKET T
            INNER JOIN BOOKING B ON T.BookingID = B.BookingID
            WHERE B.EventID = @EventID AND B.BookingStatus = 'Cancelled';
        END
        ELSE IF @NewStatus = 'Completed'
        BEGIN
            -- Mark all confirmed bookings as completed
            UPDATE BOOKING
            SET BookingStatus = 'Completed'
            WHERE EventID = @EventID AND BookingStatus = 'Confirmed';
            
            SET @AffectedBookings = @@ROWCOUNT;
            
            -- Mark all active tickets as used
            UPDATE T
            SET T.TicketStatus = 'Used'
            FROM TICKET T
            INNER JOIN BOOKING B ON T.BookingID = B.BookingID
            WHERE B.EventID = @EventID AND T.TicketStatus = 'Active';
        END
        ELSE
        BEGIN
            SET @AffectedBookings = 0;
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Event status updated successfully. Affected bookings: ' + CAST(@AffectedBookings AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =============================================
-- SP5: Generate Revenue Report
-- Purpose: Generates comprehensive revenue report with transaction management
-- =============================================
IF OBJECT_ID('sp_GenerateRevenueReport', 'P') IS NOT NULL
    DROP PROCEDURE sp_GenerateRevenueReport;
GO

CREATE PROCEDURE sp_GenerateRevenueReport
    @StartDate DATETIME,
    @EndDate DATETIME,
    @EventType VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        -- Validate date range
        IF @StartDate > @EndDate
        BEGIN
            RAISERROR('Start date must be before end date.', 16, 1);
        END
        
        -- Validate event type if provided
        IF @EventType IS NOT NULL AND @EventType NOT IN ('Movie', 'Sport', 'Exhibition')
        BEGIN
            RAISERROR('Invalid event type. Must be Movie, Sport, or Exhibition.', 16, 1);
        END
        
        -- Generate comprehensive revenue report
        SELECT 
            E.EventType,
            E.Title AS EventName,
            COUNT(DISTINCT B.BookingID) AS TotalBookings,
            COUNT(DISTINCT T.TicketID) AS TotalTickets,
            SUM(B.TotalAmount) AS TotalRevenue,
            SUM(BS.Subtotal) AS SnackRevenue,
            SUM(P.Amount) AS PaymentReceived,
            AVG(B.TotalAmount) AS AvgBookingAmount,
            MIN(B.BookingDateTime) AS FirstBooking,
            MAX(B.BookingDateTime) AS LastBooking
        FROM EVENT E
        INNER JOIN BOOKING B ON E.EventID = B.EventID
        LEFT JOIN TICKET T ON B.BookingID = T.BookingID
        LEFT JOIN BOOKING_SNACK BS ON B.BookingID = BS.BookingID
        LEFT JOIN PAYMENT P ON B.BookingID = P.BookingID
        WHERE B.BookingDateTime BETWEEN @StartDate AND @EndDate
            AND B.BookingStatus IN ('Confirmed', 'Completed')
            AND (@EventType IS NULL OR E.EventType = @EventType)
        GROUP BY E.EventType, E.Title
        ORDER BY TotalRevenue DESC;
        
        -- Summary statistics
        SELECT 
            'Summary' AS ReportType,
            COUNT(DISTINCT B.BookingID) AS TotalBookings,
            COUNT(DISTINCT T.TicketID) AS TotalTickets,
            SUM(B.TotalAmount) AS TotalRevenue,
            AVG(B.TotalAmount) AS AvgBookingAmount,
            SUM(CASE WHEN B.BookingStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledBookings,
            SUM(CASE WHEN B.BookingStatus = 'Confirmed' THEN 1 ELSE 0 END) AS ConfirmedBookings,
            SUM(CASE WHEN B.BookingStatus = 'Completed' THEN 1 ELSE 0 END) AS CompletedBookings
        FROM BOOKING B
        LEFT JOIN TICKET T ON B.BookingID = T.BookingID
        LEFT JOIN EVENT E ON B.EventID = E.EventID
        WHERE B.BookingDateTime BETWEEN @StartDate AND @EndDate
            AND (@EventType IS NULL OR E.EventType = @EventType);
        
        PRINT 'Revenue report generated successfully.';
        
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =============================================
-- SECTION 2: USER-DEFINED FUNCTIONS (3 Functions)
-- =============================================

-- =============================================
-- UDF1: Calculate Customer Lifetime Value
-- Purpose: Calculates total revenue generated by a customer
-- =============================================
IF OBJECT_ID('dbo.fn_CalculateCustomerLifetimeValue', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalculateCustomerLifetimeValue;
GO

CREATE FUNCTION dbo.fn_CalculateCustomerLifetimeValue
(
    @CustomerID INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @LifetimeValue DECIMAL(10,2);
    
    SELECT @LifetimeValue = ISNULL(SUM(TotalAmount), 0)
    FROM BOOKING
    WHERE CustomerID = @CustomerID 
        AND BookingStatus IN ('Confirmed', 'Completed');
    
    RETURN @LifetimeValue;
END;
GO

-- =============================================
-- UDF2: Get Available Seats for Show
-- Purpose: Returns count of available seats for a specific show
-- =============================================
IF OBJECT_ID('dbo.fn_GetAvailableSeatsForShow', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetAvailableSeatsForShow;
GO

CREATE FUNCTION dbo.fn_GetAvailableSeatsForShow
(
    @ShowID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalSeats INT;
    DECLARE @BookedSeats INT;
    DECLARE @AvailableSeats INT;
    DECLARE @ScreenID INT;
    
    -- Get screen for this show
    SELECT @ScreenID = ScreenID
    FROM SHOW
    WHERE ShowID = @ShowID;
    
    -- Get total seats in screen
    SELECT @TotalSeats = COUNT(*)
    FROM SEAT
    WHERE ScreenID = @ScreenID;
    
    -- Get booked seats for this show
    SELECT @BookedSeats = COUNT(*)
    FROM SEAT_BOOKING
    WHERE ShowID = @ShowID;
    
    SET @AvailableSeats = @TotalSeats - ISNULL(@BookedSeats, 0);
    
    RETURN @AvailableSeats;
END;
GO

-- =============================================
-- UDF3: Calculate Event Occupancy Rate
-- Purpose: Calculates the occupancy percentage for an event
-- =============================================
IF OBJECT_ID('dbo.fn_CalculateEventOccupancy', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalculateEventOccupancy;
GO

CREATE FUNCTION dbo.fn_CalculateEventOccupancy
(
    @EventID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @TotalCapacity INT;
    DECLARE @BookedSeats INT;
    DECLARE @OccupancyRate DECIMAL(5,2);
    
    -- Get total capacity for all shows of this event
    SELECT @TotalCapacity = SUM(SC.SeatCapacity)
    FROM SHOW S
    INNER JOIN SCREEN SC ON S.ScreenID = SC.ScreenID
    WHERE S.EventID = @EventID;
    
    -- Get total booked seats
    SELECT @BookedSeats = COUNT(*)
    FROM SEAT_BOOKING SB
    INNER JOIN SHOW S ON SB.ShowID = S.ShowID
    WHERE S.EventID = @EventID;
    
    -- Calculate occupancy rate
    IF @TotalCapacity > 0
        SET @OccupancyRate = (CAST(@BookedSeats AS DECIMAL(10,2)) / @TotalCapacity) * 100;
    ELSE
        SET @OccupancyRate = 0;
    
    RETURN @OccupancyRate;
END;
GO

-- =============================================
-- SECTION 3: VIEWS (3 Views for Reporting)
-- =============================================

-- =============================================
-- VIEW1: Customer Booking Summary
-- Purpose: Comprehensive view of customer booking history and statistics
-- =============================================
IF OBJECT_ID('vw_CustomerBookingSummary', 'V') IS NOT NULL
    DROP VIEW vw_CustomerBookingSummary;
GO

CREATE VIEW vw_CustomerBookingSummary
AS
SELECT 
    C.CustomerID,
    U.FirstName,
    U.LastName,
    U.Email,
    C.LoyaltyPoints,
    COUNT(B.BookingID) AS TotalBookings,
    SUM(CASE WHEN B.BookingStatus = 'Confirmed' THEN 1 ELSE 0 END) AS ActiveBookings,
    SUM(CASE WHEN B.BookingStatus = 'Completed' THEN 1 ELSE 0 END) AS CompletedBookings,
    SUM(CASE WHEN B.BookingStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledBookings,
    SUM(B.TotalAmount) AS TotalSpent,
    AVG(B.TotalAmount) AS AvgBookingAmount,
    MAX(B.BookingDateTime) AS LastBookingDate,
    COUNT(DISTINCT T.TicketID) AS TotalTickets
FROM CUSTOMER C
INNER JOIN [USER] U ON C.UserID = U.UserID
LEFT JOIN BOOKING B ON C.CustomerID = B.CustomerID
LEFT JOIN TICKET T ON B.BookingID = T.BookingID
GROUP BY C.CustomerID, U.FirstName, U.LastName, U.Email, C.LoyaltyPoints;
GO

-- =============================================
-- VIEW2: Event Performance Dashboard
-- Purpose: Real-time event performance metrics
-- =============================================
IF OBJECT_ID('vw_EventPerformanceDashboard', 'V') IS NOT NULL
    DROP VIEW vw_EventPerformanceDashboard;
GO

CREATE VIEW vw_EventPerformanceDashboard
AS
SELECT 
    E.EventID,
    E.Title AS EventName,
    E.EventType,
    E.Status AS EventStatus,
    E.StartDateTime,
    E.EndDateTime,
    O.CompanyName AS OrganizerName,
    COUNT(DISTINCT B.BookingID) AS TotalBookings,
    COUNT(DISTINCT T.TicketID) AS TicketsSold,
    SUM(B.TotalAmount) AS TotalRevenue,
    AVG(B.TotalAmount) AS AvgRevenuePerBooking,
    COUNT(DISTINCT S.ShowID) AS TotalShows,
    SUM(CASE WHEN B.BookingStatus = 'Cancelled' THEN B.TotalAmount ELSE 0 END) AS LostRevenue,
    CAST(COUNT(DISTINCT T.TicketID) AS FLOAT) / NULLIF(COUNT(DISTINCT S.ShowID), 0) AS AvgTicketsPerShow
FROM EVENT E
LEFT JOIN ORGANIZER O ON E.OrganizerID = O.OrganizerID
LEFT JOIN BOOKING B ON E.EventID = B.EventID
LEFT JOIN TICKET T ON B.BookingID = T.BookingID
LEFT JOIN SHOW S ON E.EventID = S.EventID
GROUP BY E.EventID, E.Title, E.EventType, E.Status, E.StartDateTime, E.EndDateTime, O.CompanyName;
GO

-- =============================================
-- VIEW3: Theater Screen Utilization
-- Purpose: Analyzes screen usage and revenue across theaters
-- =============================================
IF OBJECT_ID('vw_TheaterScreenUtilization', 'V') IS NOT NULL
    DROP VIEW vw_TheaterScreenUtilization;
GO

CREATE VIEW vw_TheaterScreenUtilization
AS
SELECT 
    TH.TheaterID,
    TH.TheaterName,
    TH.City,
    TH.State,
    SC.ScreenID,
    SC.ScreenNumber,
    SC.SeatCapacity,
    COUNT(DISTINCT SH.ShowID) AS TotalShows,
    COUNT(SB.SeatBookingID) AS TotalSeatBookings,
    CASE 
        WHEN COUNT(DISTINCT SH.ShowID) > 0 THEN
            CAST(COUNT(SB.SeatBookingID) AS FLOAT) / (SC.SeatCapacity * COUNT(DISTINCT SH.ShowID)) * 100
        ELSE 0
    END AS UtilizationRate,
    ISNULL(SUM(SH.Price), 0) AS TotalShowRevenue,
    AVG(SH.Price) AS AvgTicketPrice
FROM THEATER TH
INNER JOIN SCREEN SC ON TH.TheaterID = SC.TheaterID
LEFT JOIN SHOW SH ON SC.ScreenID = SH.ScreenID
LEFT JOIN SEAT_BOOKING SB ON SH.ShowID = SB.ShowID
GROUP BY TH.TheaterID, TH.TheaterName, TH.City, TH.State, SC.ScreenID, SC.ScreenNumber, SC.SeatCapacity;
GO


-- =============================================
-- Additional Power BI Data Views
-- =============================================
USE EventBookingSystem;
GO

-- View 1: Sales Overview
CREATE OR ALTER VIEW vw_PowerBI_SalesOverview
AS
SELECT 
    B.BookingID,
    B.BookingDateTime,
    CAST(B.BookingDateTime AS DATE) AS BookingDate,
    DATEPART(YEAR, B.BookingDateTime) AS BookingYear,
    DATEPART(MONTH, B.BookingDateTime) AS BookingMonth,
    DATENAME(MONTH, B.BookingDateTime) AS MonthName,
    DATEPART(QUARTER, B.BookingDateTime) AS BookingQuarter,
    DATENAME(WEEKDAY, B.BookingDateTime) AS DayOfWeek,
    B.TotalAmount,
    B.BookingStatus,
    
    -- Customer Info
    C.CustomerID,
    U.FirstName + ' ' + U.LastName AS CustomerName,
    C.LoyaltyPoints,
    
    -- Event Info
    E.EventID,
    E.Title AS EventName,
    E.EventType,
    E.Status AS EventStatus,
    E.StartDateTime AS EventStartDate,
    O.CompanyName AS OrganizerName,
    
    -- Ticket Count
    (SELECT COUNT(*) FROM TICKET T WHERE T.BookingID = B.BookingID) AS TicketCount,
    
    -- Snack Revenue
    ISNULL((SELECT SUM(Subtotal) FROM BOOKING_SNACK BS WHERE BS.BookingID = B.BookingID), 0) AS SnackRevenue,
    B.TotalAmount - ISNULL((SELECT SUM(Subtotal) FROM BOOKING_SNACK BS WHERE BS.BookingID = B.BookingID), 0) AS TicketRevenue
FROM BOOKING B
INNER JOIN CUSTOMER C ON B.CustomerID = C.CustomerID
INNER JOIN [USER] U ON C.UserID = U.UserID
INNER JOIN EVENT E ON B.EventID = E.EventID
LEFT JOIN ORGANIZER O ON E.OrganizerID = O.OrganizerID;
GO

-- View 2: Theater Performance
CREATE OR ALTER VIEW vw_PowerBI_TheaterPerformance
AS
SELECT 
    T.TheaterID,
    T.TheaterName,
    T.City,
    T.State,
    SC.ScreenID,
    SC.ScreenNumber,
    SC.SeatCapacity,
    
    SH.ShowID,
    SH.ShowDateTime,
    CAST(SH.ShowDateTime AS DATE) AS ShowDate,
    SH.ShowType,
    SH.Price AS TicketPrice,
    
    E.Title AS MovieTitle,
    M.Genre,
    M.Rating,
    
    -- Occupancy Metrics
    (SELECT COUNT(*) FROM SEAT_BOOKING SB WHERE SB.ShowID = SH.ShowID) AS SeatsSold,
    SC.SeatCapacity AS TotalSeats,
    CAST((SELECT COUNT(*) FROM SEAT_BOOKING SB WHERE SB.ShowID = SH.ShowID) AS FLOAT) / SC.SeatCapacity * 100 AS OccupancyRate,
    
    -- Revenue
    SH.Price * (SELECT COUNT(*) FROM SEAT_BOOKING SB WHERE SB.ShowID = SH.ShowID) AS ShowRevenue
FROM THEATER T
INNER JOIN SCREEN SC ON T.TheaterID = SC.TheaterID
INNER JOIN SHOW SH ON SC.ScreenID = SH.ScreenID
INNER JOIN EVENT E ON SH.EventID = E.EventID
LEFT JOIN MOVIE M ON SH.MovieID = M.MovieID;
GO

-- View 3: Customer Insights
CREATE OR ALTER VIEW vw_PowerBI_CustomerInsights
AS
SELECT 
    C.CustomerID,
    U.FirstName,
    U.LastName,
    U.FirstName + ' ' + U.LastName AS FullName,
    U.Email,
    U.PhoneNumber,
    C.LoyaltyPoints,
    
    -- Booking Metrics
    COUNT(DISTINCT B.BookingID) AS TotalBookings,
    SUM(CASE WHEN B.BookingStatus = 'Confirmed' THEN 1 ELSE 0 END) AS ActiveBookings,
    SUM(CASE WHEN B.BookingStatus = 'Completed' THEN 1 ELSE 0 END) AS CompletedBookings,
    SUM(CASE WHEN B.BookingStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledBookings,
    
    -- Revenue Metrics
    SUM(CASE WHEN B.BookingStatus IN ('Confirmed', 'Completed') THEN B.TotalAmount ELSE 0 END) AS TotalSpent,
    AVG(CASE WHEN B.BookingStatus IN ('Confirmed', 'Completed') THEN B.TotalAmount ELSE NULL END) AS AvgBookingValue,
    MAX(B.BookingDateTime) AS LastBookingDate,
    MIN(B.BookingDateTime) AS FirstBookingDate,
    
    -- Ticket Count
    COUNT(DISTINCT T.TicketID) AS TotalTickets,
    
    -- Customer Segment
    CASE 
        WHEN SUM(CASE WHEN B.BookingStatus IN ('Confirmed', 'Completed') THEN B.TotalAmount ELSE 0 END) > 500 THEN 'VIP'
        WHEN SUM(CASE WHEN B.BookingStatus IN ('Confirmed', 'Completed') THEN B.TotalAmount ELSE 0 END) > 200 THEN 'Regular'
        ELSE 'Occasional'
    END AS CustomerSegment
FROM CUSTOMER C
INNER JOIN [USER] U ON C.UserID = U.UserID
LEFT JOIN BOOKING B ON C.CustomerID = B.CustomerID
LEFT JOIN TICKET T ON B.BookingID = T.BookingID
GROUP BY C.CustomerID, U.FirstName, U.LastName, U.Email, U.PhoneNumber, C.LoyaltyPoints;
GO

-- View 4: Product Performance (Movies, Events, Snacks)
CREATE OR ALTER VIEW vw_PowerBI_ProductPerformance
AS
SELECT 
    E.EventID,
    E.Title AS EventName,
    E.EventType,
    E.StartDateTime,
    E.EndDateTime,
    E.Status,
    
    -- Movie Specifics
    M.Genre,
    M.Rating,
    
    -- Sport Specifics
    S.SportType,
    S.TournamentName,
    
    -- Booking Metrics
    COUNT(DISTINCT B.BookingID) AS TotalBookings,
    COUNT(DISTINCT T.TicketID) AS TicketsSold,
    SUM(B.TotalAmount) AS TotalRevenue,
    AVG(B.TotalAmount) AS AvgRevenuePerBooking,
    
    -- Show Metrics
    COUNT(DISTINCT SH.ShowID) AS TotalShows,
    
    -- Occupancy
    CAST(COUNT(DISTINCT T.TicketID) AS FLOAT) / NULLIF(COUNT(DISTINCT SH.ShowID), 0) AS AvgTicketsPerShow
FROM EVENT E
LEFT JOIN MOVIE M ON E.EventID = M.EventID
LEFT JOIN SPORT S ON E.EventID = S.EventID
LEFT JOIN BOOKING B ON E.EventID = B.EventID
LEFT JOIN TICKET T ON B.BookingID = T.BookingID
LEFT JOIN SHOW SH ON E.EventID = SH.EventID
GROUP BY E.EventID, E.Title, E.EventType, E.StartDateTime, E.EndDateTime, E.Status, 
         M.Genre, M.Rating, S.SportType, S.TournamentName;
GO

-- View 5: Time Series Analysis
CREATE OR ALTER VIEW vw_PowerBI_TimeSeries
AS
SELECT 
    CAST(B.BookingDateTime AS DATE) AS Date,
    DATEPART(YEAR, B.BookingDateTime) AS Year,
    DATEPART(MONTH, B.BookingDateTime) AS Month,
    DATEPART(QUARTER, B.BookingDateTime) AS Quarter,
    DATENAME(WEEKDAY, B.BookingDateTime) AS DayOfWeek,
    DATEPART(HOUR, B.BookingDateTime) AS HourOfDay,
    
    COUNT(DISTINCT B.BookingID) AS DailyBookings,
    COUNT(DISTINCT T.TicketID) AS DailyTickets,
    SUM(B.TotalAmount) AS DailyRevenue,
    AVG(B.TotalAmount) AS AvgDailyBookingValue,
    
    COUNT(DISTINCT B.CustomerID) AS UniqueCustomers,
    
    E.EventType,
    
    -- Running Totals (for cumulative charts)
    SUM(SUM(B.TotalAmount)) OVER (ORDER BY CAST(B.BookingDateTime AS DATE)) AS CumulativeRevenue
FROM BOOKING B
INNER JOIN TICKET T ON B.BookingID = T.BookingID
INNER JOIN EVENT E ON B.EventID = E.EventID
WHERE B.BookingStatus IN ('Confirmed', 'Completed')
GROUP BY CAST(B.BookingDateTime AS DATE), 
         DATEPART(YEAR, B.BookingDateTime),
         DATEPART(MONTH, B.BookingDateTime),
         DATEPART(QUARTER, B.BookingDateTime),
         DATENAME(WEEKDAY, B.BookingDateTime),
         DATEPART(HOUR, B.BookingDateTime),
         E.EventType;
GO

-- View 6: Snack Sales Analysis
CREATE OR ALTER VIEW vw_PowerBI_SnackSales
AS
SELECT 
    S.SnackID,
    S.SnackName,
    S.SnackType,
    S.Price AS UnitPrice,
    
    COUNT(DISTINCT BS.BookingID) AS OrderCount,
    SUM(BS.Quantity) AS TotalQuantitySold,
    SUM(BS.Subtotal) AS TotalRevenue,
    AVG(BS.Quantity) AS AvgQuantityPerOrder,
    AVG(BS.Subtotal) AS AvgRevenuePerOrder,
    
    -- Rank by popularity
    RANK() OVER (ORDER BY SUM(BS.Quantity) DESC) AS PopularityRank,
    
    -- Revenue contribution
    SUM(BS.Subtotal) * 100.0 / SUM(SUM(BS.Subtotal)) OVER () AS RevenueContributionPercent
FROM SNACK S
LEFT JOIN BOOKING_SNACK BS ON S.SnackID = BS.SnackID
GROUP BY S.SnackID, S.SnackName, S.SnackType, S.Price;
GO

PRINT 'Power BI views created successfully!';


-- =============================================
-- SECTION 4: DML TRIGGER (1 Trigger for Auditing)
-- =============================================

-- =============================================
-- TRIGGER: Audit Booking Changes
-- Purpose: Logs all changes to booking status for audit trail
-- =============================================

-- First, create audit table
IF OBJECT_ID('BOOKING_AUDIT', 'U') IS NOT NULL
    DROP TABLE BOOKING_AUDIT;
GO

CREATE TABLE BOOKING_AUDIT (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    OldStatus VARCHAR(20),
    NewStatus VARCHAR(20),
    OldTotalAmount DECIMAL(10,2),
    NewTotalAmount DECIMAL(10,2),
    ChangeDateTime DATETIME DEFAULT GETDATE(),
    ChangedBy VARCHAR(100) DEFAULT SYSTEM_USER,
    ChangeType VARCHAR(20) -- 'UPDATE', 'DELETE'
);
GO

-- Create the trigger
IF OBJECT_ID('trg_Booking_Audit', 'TR') IS NOT NULL
    DROP TRIGGER trg_Booking_Audit;
GO

CREATE TRIGGER trg_Booking_Audit
ON BOOKING
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Handle UPDATE operations
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO BOOKING_AUDIT (BookingID, OldStatus, NewStatus, OldTotalAmount, NewTotalAmount, ChangeType)
        SELECT 
            d.BookingID,
            d.BookingStatus,
            i.BookingStatus,
            d.TotalAmount,
            i.TotalAmount,
            'UPDATE'
        FROM deleted d
        INNER JOIN inserted i ON d.BookingID = i.BookingID
        WHERE d.BookingStatus <> i.BookingStatus 
           OR d.TotalAmount <> i.TotalAmount;
    END
    
    -- Handle DELETE operations
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO BOOKING_AUDIT (BookingID, OldStatus, NewStatus, OldTotalAmount, NewTotalAmount, ChangeType)
        SELECT 
            d.BookingID,
            d.BookingStatus,
            'DELETED',
            d.TotalAmount,
            0,
            'DELETE'
        FROM deleted d;
    END
END;
GO

-- =============================================
-- TEST SCRIPTS FOR VERIFICATION
-- =============================================

PRINT '============================================='
PRINT 'PSM Script Created Successfully!'
PRINT '============================================='
PRINT 'Created Objects:'
PRINT '- 5 Stored Procedures with Transaction Management'
PRINT '- 3 User-Defined Functions'
PRINT '- 3 Views for Reporting'
PRINT '- 1 DML Trigger for Auditing'
PRINT '============================================='
GO


GO