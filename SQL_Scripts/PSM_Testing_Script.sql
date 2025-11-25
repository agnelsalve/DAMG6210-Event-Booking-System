-- =============================================
-- Event & Ticket Booking System - PSM Testing Script
-- Group 5 - DAMG6210
-- P5 Submission - Complete Testing for SPs, Functions, Views, and Triggers
-- =============================================

USE EventBookingSystem;
GO

PRINT '============================================='
PRINT 'PSM TESTING AND VERIFICATION SCRIPT'
PRINT '============================================='
PRINT 'This script tests all stored procedures, functions, views, and triggers'
PRINT 'Created in the PSM script'
PRINT '============================================='
GO

-- =============================================
-- SECTION 1: STORED PROCEDURE TESTS
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'SECTION 1: TESTING STORED PROCEDURES'
PRINT '============================================='
GO

-- =============================================
-- TEST 1: sp_CreateBookingWithPayment (Card Payment)
-- =============================================
PRINT ''
PRINT '--- TEST 1: Creating booking with Card payment ---'
GO

DECLARE @BookingID1 INT, @PaymentID1 INT;

-- Find available seats that are NOT already booked
DECLARE @AvailableSeat1 INT, @AvailableSeat2 INT;

SELECT TOP 1 @AvailableSeat1 = S.SeatID
FROM SEAT S
WHERE S.ScreenID = 1
  AND S.SeatID NOT IN (SELECT SeatID FROM SEAT_BOOKING WHERE ShowID = 1)
ORDER BY S.SeatID;

SELECT TOP 1 @AvailableSeat2 = S.SeatID
FROM SEAT S
WHERE S.ScreenID = 1
  AND S.SeatID NOT IN (SELECT SeatID FROM SEAT_BOOKING WHERE ShowID = 1)
  AND S.SeatID > @AvailableSeat1
ORDER BY S.SeatID;

PRINT 'Using Available Seats:'
SELECT @AvailableSeat1 AS Seat1, @AvailableSeat2 AS Seat2;

DECLARE @SeatIDString1 VARCHAR(50);
SET @SeatIDString1 = CAST(@AvailableSeat1 AS VARCHAR) + ',' + CAST(@AvailableSeat2 AS VARCHAR);

EXEC sp_CreateBookingWithPayment 
    @CustomerID = 1,
    @EventID = 1,
    @ShowID = 1,
    @SeatIDs = @SeatIDString1,
    @PaymentAmount = 45.00,
    @PaymentType = 'Card',
    @CardNumber = '4532756279624512',
    @CardHolderName = 'Michael Anderson',
    @BookingID = @BookingID1 OUTPUT,
    @PaymentID = @PaymentID1 OUTPUT;

PRINT 'Output Variables:'
SELECT @BookingID1 AS NewBookingID, @PaymentID1 AS NewPaymentID;

PRINT 'Verify Booking Created:'
SELECT * FROM BOOKING WHERE BookingID = @BookingID1;

PRINT 'Verify Payment Created:'
SELECT * FROM PAYMENT WHERE PaymentID = @PaymentID1;

PRINT 'Verify Card Payment Created:'
SELECT * FROM CARD_PAYMENT WHERE PaymentID = @PaymentID1;

PRINT 'Verify Tickets Generated:'
SELECT * FROM TICKET WHERE BookingID = @BookingID1;

PRINT 'Verify Seat Bookings:'
SELECT * FROM SEAT_BOOKING WHERE BookingID = @BookingID1;

PRINT 'Verify Customer Loyalty Points Updated:'
SELECT CustomerID, LoyaltyPoints FROM CUSTOMER WHERE CustomerID = 1;
GO

-- =============================================
-- TEST 2: sp_CreateBookingWithPayment (Wallet Payment)
-- =============================================
PRINT ''
PRINT '--- TEST 2: Creating booking with Wallet payment ---'
GO

DECLARE @BookingID2 INT, @PaymentID2 INT;

-- Find available seats for Show 3
DECLARE @AvailableSeat3 INT, @AvailableSeat4 INT;
DECLARE @ScreenID3 INT;

SELECT @ScreenID3 = ScreenID FROM SHOW WHERE ShowID = 3;

SELECT TOP 1 @AvailableSeat3 = S.SeatID
FROM SEAT S
WHERE S.ScreenID = @ScreenID3
  AND S.SeatID NOT IN (SELECT ISNULL(SeatID, 0) FROM SEAT_BOOKING WHERE ShowID = 3)
ORDER BY S.SeatID;

SELECT TOP 1 @AvailableSeat4 = S.SeatID
FROM SEAT S
WHERE S.ScreenID = @ScreenID3
  AND S.SeatID NOT IN (SELECT ISNULL(SeatID, 0) FROM SEAT_BOOKING WHERE ShowID = 3)
  AND S.SeatID > @AvailableSeat3
ORDER BY S.SeatID;

DECLARE @SeatIDString2 VARCHAR(50);
SET @SeatIDString2 = CAST(@AvailableSeat3 AS VARCHAR) + ',' + CAST(@AvailableSeat4 AS VARCHAR);

PRINT 'Using Available Seats for Show 3:'
SELECT @AvailableSeat3 AS Seat1, @AvailableSeat4 AS Seat2;

EXEC sp_CreateBookingWithPayment 
    @CustomerID = 2,
    @EventID = 2,
    @ShowID = 3,
    @SeatIDs = @SeatIDString2,
    @PaymentAmount = 52.00,
    @PaymentType = 'Wallet',
    @WalletType = 'Apple Pay',
    @BookingID = @BookingID2 OUTPUT,
    @PaymentID = @PaymentID2 OUTPUT;

PRINT 'Output Variables:'
SELECT @BookingID2 AS NewBookingID, @PaymentID2 AS NewPaymentID;

PRINT 'Verify Wallet Payment Created:'
SELECT * FROM WALLET_PAYMENT WHERE PaymentID = @PaymentID2;
GO

-- =============================================
-- TEST 3: sp_CreateBookingWithPayment (PayPal Payment)
-- =============================================
PRINT ''
PRINT '--- TEST 3: Creating booking with PayPal payment ---'
GO

DECLARE @BookingID3 INT, @PaymentID3 INT;

-- Find available seats for Show 4
DECLARE @AvailableSeat5 INT, @AvailableSeat6 INT;
DECLARE @ScreenID4 INT;

SELECT @ScreenID4 = ScreenID FROM SHOW WHERE ShowID = 4;

SELECT TOP 1 @AvailableSeat5 = S.SeatID
FROM SEAT S
WHERE S.ScreenID = @ScreenID4
  AND S.SeatID NOT IN (SELECT ISNULL(SeatID, 0) FROM SEAT_BOOKING WHERE ShowID = 4)
ORDER BY S.SeatID;

SELECT TOP 1 @AvailableSeat6 = S.SeatID
FROM SEAT S
WHERE S.ScreenID = @ScreenID4
  AND S.SeatID NOT IN (SELECT ISNULL(SeatID, 0) FROM SEAT_BOOKING WHERE ShowID = 4)
  AND S.SeatID > @AvailableSeat5
ORDER BY S.SeatID;

DECLARE @SeatIDString3 VARCHAR(50);
SET @SeatIDString3 = CAST(@AvailableSeat5 AS VARCHAR) + ',' + CAST(@AvailableSeat6 AS VARCHAR);

PRINT 'Using Available Seats for Show 4:'
SELECT @AvailableSeat5 AS Seat1, @AvailableSeat6 AS Seat2;

EXEC sp_CreateBookingWithPayment 
    @CustomerID = 3,
    @EventID = 3,
    @ShowID = 4,
    @SeatIDs = @SeatIDString3,
    @PaymentAmount = 61.00,
    @PaymentType = 'PayPal',
    @PayPalEmail = 'david.thompson@email.com',
    @BookingID = @BookingID3 OUTPUT,
    @PaymentID = @PaymentID3 OUTPUT;

PRINT 'Output Variables:'
SELECT @BookingID3 AS NewBookingID, @PaymentID3 AS NewPaymentID;

PRINT 'Verify PayPal Payment Created:'
SELECT * FROM PAYPAL_PAYMENT WHERE PaymentID = @PaymentID3;
GO

-- =============================================
-- TEST 4: sp_CreateBookingWithPayment (Error Handling - Invalid Customer)
-- =============================================
PRINT ''
PRINT '--- TEST 4: Error Handling - Invalid Customer (Should Fail) ---'
GO

DECLARE @BookingID4 INT, @PaymentID4 INT;

BEGIN TRY
    EXEC sp_CreateBookingWithPayment 
        @CustomerID = 9999, -- Non-existent customer
        @EventID = 1,
        @ShowID = 1,
        @SeatIDs = '999,1000',
        @PaymentAmount = 45.00,
        @PaymentType = 'Card',
        @CardNumber = '4532756279624512',
        @CardHolderName = 'Test User',
        @BookingID = @BookingID4 OUTPUT,
        @PaymentID = @PaymentID4 OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Expected Error Caught:'
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- =============================================
-- TEST 5: sp_CreateBookingWithPayment (Error Handling - Duplicate Seat Booking)
-- =============================================
PRINT ''
PRINT '--- TEST 5: Error Handling - Duplicate Seat Booking (Should Fail) ---'
GO

DECLARE @BookingID5 INT, @PaymentID5 INT;

-- Get seats that ARE already booked
DECLARE @AlreadyBookedSeat INT;
SELECT TOP 1 @AlreadyBookedSeat = SeatID
FROM SEAT_BOOKING
WHERE ShowID = 1;

DECLARE @AlreadyBookedSeats VARCHAR(50);
SET @AlreadyBookedSeats = CAST(@AlreadyBookedSeat AS VARCHAR) + ',' + CAST(@AlreadyBookedSeat + 1 AS VARCHAR);

PRINT 'Attempting to book already-booked seats:'
SELECT @AlreadyBookedSeats AS AlreadyBookedSeats;

BEGIN TRY
    EXEC sp_CreateBookingWithPayment 
        @CustomerID = 1,
        @EventID = 1,
        @ShowID = 1,
        @SeatIDs = @AlreadyBookedSeats,
        @PaymentAmount = 45.00,
        @PaymentType = 'Card',
        @CardNumber = '4532756279624512',
        @CardHolderName = 'Michael Anderson',
        @BookingID = @BookingID5 OUTPUT,
        @PaymentID = @PaymentID5 OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Expected Error Caught:'
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- =============================================
-- TEST 6: sp_AddSnacksToBooking
-- =============================================
PRINT ''
PRINT '--- TEST 6: Adding snacks to booking ---'
GO

DECLARE @NewTotal1 DECIMAL(10,2);

-- Get a valid BookingID
DECLARE @TestBookingID INT;
SELECT TOP 1 @TestBookingID = BookingID FROM BOOKING WHERE BookingStatus = 'Confirmed' ORDER BY BookingID DESC;

PRINT 'Original Booking Details:'
SELECT BookingID, TotalAmount, BookingStatus FROM BOOKING WHERE BookingID = @TestBookingID;

EXEC sp_AddSnacksToBooking 
    @BookingID = @TestBookingID,
    @SnackID = 1, -- Jumbo Popcorn
    @Quantity = 2,
    @NewTotalAmount = @NewTotal1 OUTPUT;

PRINT 'New Total Amount:'
SELECT @NewTotal1 AS NewTotalAmount;

PRINT 'Updated Booking Details:'
SELECT BookingID, TotalAmount, BookingStatus FROM BOOKING WHERE BookingID = @TestBookingID;

PRINT 'Snacks Added:'
SELECT * FROM BOOKING_SNACK WHERE BookingID = @TestBookingID;
GO

-- =============================================
-- TEST 7: sp_AddSnacksToBooking (Add More Snacks)
-- =============================================
PRINT ''
PRINT '--- TEST 7: Adding more snacks to same booking ---'
GO

DECLARE @NewTotal2 DECIMAL(10,2);
DECLARE @TestBookingID2 INT;
SELECT TOP 1 @TestBookingID2 = BookingID FROM BOOKING WHERE BookingStatus = 'Confirmed' ORDER BY BookingID DESC;

EXEC sp_AddSnacksToBooking 
    @BookingID = @TestBookingID2,
    @SnackID = 5, -- Jumbo Soda
    @Quantity = 3,
    @NewTotalAmount = @NewTotal2 OUTPUT;

PRINT 'New Total Amount After Adding Soda:'
SELECT @NewTotal2 AS NewTotalAmount;

PRINT 'All Snacks in Booking:'
SELECT * FROM BOOKING_SNACK WHERE BookingID = @TestBookingID2;
GO

-- =============================================
-- TEST 8: sp_CancelBooking
-- =============================================
PRINT ''
PRINT '--- TEST 8: Cancelling a booking ---'
GO

DECLARE @RefundAmount DECIMAL(10,2);

-- Create a new booking to cancel with available seats
DECLARE @CancelBookingID INT, @CancelPaymentID INT;

-- Find available seats for Show 5
DECLARE @CancelSeat1 INT, @CancelSeat2 INT;
DECLARE @ScreenID5 INT;

SELECT @ScreenID5 = ScreenID FROM SHOW WHERE ShowID = 5;

SELECT TOP 1 @CancelSeat1 = S.SeatID
FROM SEAT S
WHERE S.ScreenID = @ScreenID5
  AND S.SeatID NOT IN (SELECT ISNULL(SeatID, 0) FROM SEAT_BOOKING WHERE ShowID = 5)
ORDER BY S.SeatID;

SELECT TOP 1 @CancelSeat2 = S.SeatID
FROM SEAT S
WHERE S.ScreenID = @ScreenID5
  AND S.SeatID NOT IN (SELECT ISNULL(SeatID, 0) FROM SEAT_BOOKING WHERE ShowID = 5)
  AND S.SeatID > @CancelSeat1
ORDER BY S.SeatID;

DECLARE @CancelSeatString VARCHAR(50);
SET @CancelSeatString = CAST(@CancelSeat1 AS VARCHAR) + ',' + CAST(@CancelSeat2 AS VARCHAR);

PRINT 'Creating booking to cancel with seats:'
SELECT @CancelSeat1 AS Seat1, @CancelSeat2 AS Seat2;

EXEC sp_CreateBookingWithPayment 
    @CustomerID = 4,
    @EventID = 4,
    @ShowID = 5,
    @SeatIDs = @CancelSeatString,
    @PaymentAmount = 50.00,
    @PaymentType = 'Card',
    @CardNumber = '4532756279624512',
    @CardHolderName = 'Jennifer Garcia',
    @BookingID = @CancelBookingID OUTPUT,
    @PaymentID = @CancelPaymentID OUTPUT;

PRINT 'Booking Created for Cancellation:'
SELECT * FROM BOOKING WHERE BookingID = @CancelBookingID;

PRINT 'Tickets Before Cancellation:'
SELECT * FROM TICKET WHERE BookingID = @CancelBookingID;

-- Now cancel it
EXEC sp_CancelBooking 
    @BookingID = @CancelBookingID,
    @RefundAmount = @RefundAmount OUTPUT;

PRINT 'Refund Amount:'
SELECT @RefundAmount AS RefundAmount;

PRINT 'Booking After Cancellation:'
SELECT * FROM BOOKING WHERE BookingID = @CancelBookingID;

PRINT 'Tickets After Cancellation:'
SELECT * FROM TICKET WHERE BookingID = @CancelBookingID;

PRINT 'Seat Bookings After Cancellation (Should be empty):'
SELECT * FROM SEAT_BOOKING WHERE BookingID = @CancelBookingID;
GO

-- =============================================
-- TEST 9: sp_UpdateEventStatus (Change to Ongoing)
-- =============================================
PRINT ''
PRINT '--- TEST 9: Updating event status to Ongoing ---'
GO

DECLARE @AffectedBookings1 INT;

PRINT 'Event Before Update:'
SELECT EventID, Title, Status FROM EVENT WHERE EventID = 5;

PRINT 'Bookings Before Update:'
SELECT BookingID, EventID, BookingStatus FROM BOOKING WHERE EventID = 5;

EXEC sp_UpdateEventStatus 
    @EventID = 5,
    @NewStatus = 'Ongoing',
    @AffectedBookings = @AffectedBookings1 OUTPUT;

PRINT 'Affected Bookings:'
SELECT @AffectedBookings1 AS AffectedBookings;

PRINT 'Event After Update:'
SELECT EventID, Title, Status FROM EVENT WHERE EventID = 5;
GO

-- =============================================
-- TEST 10: sp_UpdateEventStatus (Cancel Event)
-- =============================================
PRINT ''
PRINT '--- TEST 10: Cancelling an event ---'
GO

DECLARE @AffectedBookings2 INT;

PRINT 'Event Before Cancellation:'
SELECT EventID, Title, Status FROM EVENT WHERE EventID = 6;

PRINT 'Bookings Before Cancellation:'
SELECT BookingID, EventID, BookingStatus FROM BOOKING WHERE EventID = 6;

EXEC sp_UpdateEventStatus 
    @EventID = 6,
    @NewStatus = 'Cancelled',
    @AffectedBookings = @AffectedBookings2 OUTPUT;

PRINT 'Affected Bookings:'
SELECT @AffectedBookings2 AS AffectedBookings;

PRINT 'Event After Cancellation:'
SELECT EventID, Title, Status FROM EVENT WHERE EventID = 6;

PRINT 'Bookings After Cancellation:'
SELECT BookingID, EventID, BookingStatus FROM BOOKING WHERE EventID = 6;

PRINT 'Tickets After Event Cancellation:'
SELECT T.TicketID, T.BookingID, T.TicketStatus 
FROM TICKET T
INNER JOIN BOOKING B ON T.BookingID = B.BookingID
WHERE B.EventID = 6;
GO

-- =============================================
-- TEST 11: sp_UpdateEventStatus (Complete Event)
-- =============================================
PRINT ''
PRINT '--- TEST 11: Marking event as completed ---'
GO

DECLARE @AffectedBookings3 INT;

PRINT 'Event Before Completion:'
SELECT EventID, Title, Status FROM EVENT WHERE EventID = 7;

PRINT 'Bookings Before Completion:'
SELECT BookingID, EventID, BookingStatus FROM BOOKING WHERE EventID = 7;

EXEC sp_UpdateEventStatus 
    @EventID = 7,
    @NewStatus = 'Completed',
    @AffectedBookings = @AffectedBookings3 OUTPUT;

PRINT 'Affected Bookings:'
SELECT @AffectedBookings3 AS AffectedBookings;

PRINT 'Event After Completion:'
SELECT EventID, Title, Status FROM EVENT WHERE EventID = 7;

PRINT 'Bookings After Completion:'
SELECT BookingID, EventID, BookingStatus FROM BOOKING WHERE EventID = 7;
GO

-- =============================================
-- TEST 12: sp_GenerateRevenueReport (All Events)
-- =============================================
PRINT ''
PRINT '--- TEST 12: Generating revenue report for all events ---'
GO

EXEC sp_GenerateRevenueReport 
    @StartDate = '2024-11-01',
    @EndDate = '2024-12-31',
    @EventType = NULL;
GO

-- =============================================
-- TEST 13: sp_GenerateRevenueReport (Movies Only)
-- =============================================
PRINT ''
PRINT '--- TEST 13: Generating revenue report for Movies only ---'
GO

EXEC sp_GenerateRevenueReport 
    @StartDate = '2024-11-01',
    @EndDate = '2024-12-31',
    @EventType = 'Movie';
GO

-- =============================================
-- TEST 14: sp_GenerateRevenueReport (Sports Only)
-- =============================================
PRINT ''
PRINT '--- TEST 14: Generating revenue report for Sports only ---'
GO

EXEC sp_GenerateRevenueReport 
    @StartDate = '2024-11-01',
    @EndDate = '2025-12-31',
    @EventType = 'Sport';
GO

-- =============================================
-- SECTION 2: USER-DEFINED FUNCTION TESTS
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'SECTION 2: TESTING USER-DEFINED FUNCTIONS'
PRINT '============================================='
GO

-- =============================================
-- TEST 15: fn_CalculateCustomerLifetimeValue
-- =============================================
PRINT ''
PRINT '--- TEST 15: Calculate Customer Lifetime Value ---'
GO

PRINT 'Customer Lifetime Values for All Customers:'
SELECT 
    C.CustomerID,
    U.FirstName,
    U.LastName,
    dbo.fn_CalculateCustomerLifetimeValue(C.CustomerID) AS LifetimeValue,
    C.LoyaltyPoints
FROM CUSTOMER C
INNER JOIN [USER] U ON C.UserID = U.UserID
ORDER BY LifetimeValue DESC;
GO

-- =============================================
-- TEST 16: fn_CalculateCustomerLifetimeValue (Specific Customer)
-- =============================================
PRINT ''
PRINT '--- TEST 16: Calculate Lifetime Value for Customer 1 ---'
GO

DECLARE @LTV DECIMAL(10,2);
SET @LTV = dbo.fn_CalculateCustomerLifetimeValue(1);

PRINT 'Customer 1 Lifetime Value:'
SELECT @LTV AS LifetimeValue;

PRINT 'Verify with Booking Data:'
SELECT 
    CustomerID,
    COUNT(*) AS TotalBookings,
    SUM(TotalAmount) AS TotalSpent
FROM BOOKING
WHERE CustomerID = 1 AND BookingStatus IN ('Confirmed', 'Completed')
GROUP BY CustomerID;
GO

-- =============================================
-- TEST 17: fn_GetAvailableSeatsForShow
-- =============================================
PRINT ''
PRINT '--- TEST 17: Get Available Seats for Shows ---'
GO

PRINT 'Available Seats for All Shows:'
SELECT 
    S.ShowID,
    E.Title AS EventName,
    S.ShowDateTime,
    SC.SeatCapacity AS TotalSeats,
    COUNT(SB.SeatBookingID) AS BookedSeats,
    dbo.fn_GetAvailableSeatsForShow(S.ShowID) AS AvailableSeats
FROM SHOW S
INNER JOIN EVENT E ON S.EventID = E.EventID
INNER JOIN SCREEN SC ON S.ScreenID = SC.ScreenID
LEFT JOIN SEAT_BOOKING SB ON S.ShowID = SB.ShowID
GROUP BY S.ShowID, E.Title, S.ShowDateTime, SC.SeatCapacity
ORDER BY S.ShowID;
GO

-- =============================================
-- TEST 18: fn_GetAvailableSeatsForShow (Specific Show)
-- =============================================
PRINT ''
PRINT '--- TEST 18: Get Available Seats for Show 1 ---'
GO

DECLARE @AvailableSeats INT;
SET @AvailableSeats = dbo.fn_GetAvailableSeatsForShow(1);

PRINT 'Available Seats for Show 1:'
SELECT @AvailableSeats AS AvailableSeats;

PRINT 'Verify with Manual Calculation:'
SELECT 
    S.ShowID,
    SC.SeatCapacity AS TotalSeats,
    COUNT(SB.SeatBookingID) AS BookedSeats,
    SC.SeatCapacity - COUNT(SB.SeatBookingID) AS CalculatedAvailable
FROM SHOW S
INNER JOIN SCREEN SC ON S.ScreenID = SC.ScreenID
LEFT JOIN SEAT_BOOKING SB ON S.ShowID = SB.ShowID
WHERE S.ShowID = 1
GROUP BY S.ShowID, SC.SeatCapacity;
GO

-- =============================================
-- TEST 19: fn_CalculateEventOccupancy
-- =============================================
PRINT ''
PRINT '--- TEST 19: Calculate Event Occupancy Rates ---'
GO

PRINT 'Event Occupancy Rates for All Events:'
SELECT 
    E.EventID,
    E.Title AS EventName,
    E.EventType,
    dbo.fn_CalculateEventOccupancy(E.EventID) AS OccupancyRate,
    COUNT(DISTINCT B.BookingID) AS TotalBookings,
    COUNT(DISTINCT T.TicketID) AS TicketsSold
FROM EVENT E
LEFT JOIN BOOKING B ON E.EventID = B.EventID
LEFT JOIN TICKET T ON B.BookingID = T.BookingID
GROUP BY E.EventID, E.Title, E.EventType
ORDER BY OccupancyRate DESC;
GO

-- =============================================
-- TEST 20: fn_CalculateEventOccupancy (Specific Event)
-- =============================================
PRINT ''
PRINT '--- TEST 20: Calculate Occupancy for Event 1 ---'
GO

DECLARE @OccupancyRate DECIMAL(5,2);
SET @OccupancyRate = dbo.fn_CalculateEventOccupancy(1);

PRINT 'Event 1 Occupancy Rate:'
SELECT @OccupancyRate AS OccupancyRate;

PRINT 'Verify with Detailed Data:'
SELECT 
    S.ShowID,
    SC.SeatCapacity,
    COUNT(SB.SeatBookingID) AS BookedSeats
FROM SHOW S
INNER JOIN SCREEN SC ON S.ScreenID = SC.ScreenID
LEFT JOIN SEAT_BOOKING SB ON S.ShowID = SB.ShowID
WHERE S.EventID = 1
GROUP BY S.ShowID, SC.SeatCapacity;
GO

-- =============================================
-- SECTION 3: VIEW TESTS
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'SECTION 3: TESTING VIEWS'
PRINT '============================================='
GO

-- =============================================
-- TEST 21: vw_CustomerBookingSummary
-- =============================================
PRINT ''
PRINT '--- TEST 21: Customer Booking Summary View ---'
GO

PRINT 'Top 10 Customers by Total Spent:'
SELECT TOP 10 * 
FROM vw_CustomerBookingSummary 
ORDER BY TotalSpent DESC;

PRINT ''
PRINT 'Customers with Most Active Bookings:'
SELECT TOP 10 * 
FROM vw_CustomerBookingSummary 
ORDER BY ActiveBookings DESC;

PRINT ''
PRINT 'Customers with Highest Loyalty Points:'
SELECT TOP 10 * 
FROM vw_CustomerBookingSummary 
ORDER BY LoyaltyPoints DESC;
GO

-- =============================================
-- TEST 22: vw_EventPerformanceDashboard
-- =============================================
PRINT ''
PRINT '--- TEST 22: Event Performance Dashboard View ---'
GO

PRINT 'Top Events by Revenue:'
SELECT TOP 10 * 
FROM vw_EventPerformanceDashboard 
ORDER BY TotalRevenue DESC;

PRINT ''
PRINT 'Events by Ticket Sales:'
SELECT TOP 10 * 
FROM vw_EventPerformanceDashboard 
ORDER BY TicketsSold DESC;

PRINT ''
PRINT 'Movies Performance:'
SELECT * 
FROM vw_EventPerformanceDashboard 
WHERE EventType = 'Movie'
ORDER BY TotalRevenue DESC;

PRINT ''
PRINT 'Sports Events Performance:'
SELECT * 
FROM vw_EventPerformanceDashboard 
WHERE EventType = 'Sport'
ORDER BY TotalRevenue DESC;
GO

-- =============================================
-- TEST 23: vw_TheaterScreenUtilization
-- =============================================
PRINT ''
PRINT '--- TEST 23: Theater Screen Utilization View ---'
GO

PRINT 'Theater Utilization by City:'
SELECT * 
FROM vw_TheaterScreenUtilization 
ORDER BY City, TheaterName, ScreenNumber;

PRINT ''
PRINT 'Highest Utilized Screens:'
SELECT TOP 10 * 
FROM vw_TheaterScreenUtilization 
ORDER BY UtilizationRate DESC;

PRINT ''
PRINT 'Lowest Utilized Screens:'
SELECT TOP 10 * 
FROM vw_TheaterScreenUtilization 
ORDER BY UtilizationRate ASC;

PRINT ''
PRINT 'Total Revenue by Theater:'
SELECT 
    TheaterID,
    TheaterName,
    City,
    SUM(TotalShowRevenue) AS TotalRevenue,
    AVG(UtilizationRate) AS AvgUtilizationRate
FROM vw_TheaterScreenUtilization
GROUP BY TheaterID, TheaterName, City
ORDER BY TotalRevenue DESC;
GO

-- =============================================
-- SECTION 4: TRIGGER TESTS
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'SECTION 4: TESTING DML TRIGGER'
PRINT '============================================='
GO

-- =============================================
-- TEST 24: Trigger on Booking UPDATE
-- =============================================
PRINT ''
PRINT '--- TEST 24: Testing Audit Trigger on UPDATE ---'
GO

-- Get a booking to update
DECLARE @TestBookingForTrigger INT;
SELECT TOP 1 @TestBookingForTrigger = BookingID 
FROM BOOKING 
WHERE BookingStatus = 'Confirmed'
ORDER BY BookingID DESC;

PRINT 'Booking Before Update:'
SELECT BookingID, BookingStatus, TotalAmount FROM BOOKING WHERE BookingID = @TestBookingForTrigger;

PRINT 'Audit Table Before Update:'
SELECT COUNT(*) AS AuditRecordsBefore FROM BOOKING_AUDIT;

-- Update the booking
UPDATE BOOKING
SET BookingStatus = 'Completed', TotalAmount = TotalAmount + 10.00
WHERE BookingID = @TestBookingForTrigger;

PRINT 'Booking After Update:'
SELECT BookingID, BookingStatus, TotalAmount FROM BOOKING WHERE BookingID = @TestBookingForTrigger;

PRINT 'Audit Table After Update:'
SELECT TOP 5 * FROM BOOKING_AUDIT ORDER BY AuditID DESC;
GO

-- =============================================
-- TEST 25: Trigger on Multiple Booking UPDATES
-- =============================================
PRINT ''
PRINT '--- TEST 25: Testing Audit Trigger on Multiple UPDATES ---'
GO

PRINT 'Audit Records Before Multiple Updates:'
SELECT COUNT(*) AS TotalAuditRecords FROM BOOKING_AUDIT;

-- Update multiple bookings
UPDATE BOOKING
SET TotalAmount = TotalAmount + 5.00
WHERE BookingStatus = 'Confirmed' AND BookingID IN (
    SELECT TOP 3 BookingID FROM BOOKING WHERE BookingStatus = 'Confirmed' ORDER BY BookingID
);

PRINT 'Audit Records After Multiple Updates:'
SELECT TOP 10 * FROM BOOKING_AUDIT ORDER BY AuditID DESC;

PRINT 'Total Audit Records:'
SELECT COUNT(*) AS TotalAuditRecords FROM BOOKING_AUDIT;
GO

-- =============================================
-- TEST 26: Trigger on Booking Status Change
-- =============================================
PRINT ''
PRINT '--- TEST 26: Testing Audit Trigger on Status Change Only ---'
GO

-- Get a confirmed booking
DECLARE @StatusChangeBooking INT;
SELECT TOP 1 @StatusChangeBooking = BookingID 
FROM BOOKING 
WHERE BookingStatus = 'Confirmed'
ORDER BY BookingID DESC;

PRINT 'Before Status Change:'
SELECT BookingID, BookingStatus, TotalAmount FROM BOOKING WHERE BookingID = @StatusChangeBooking;

-- Change only the status
UPDATE BOOKING
SET BookingStatus = 'Completed'
WHERE BookingID = @StatusChangeBooking;

PRINT 'After Status Change:'
SELECT BookingID, BookingStatus, TotalAmount FROM BOOKING WHERE BookingID = @StatusChangeBooking;

PRINT 'Corresponding Audit Record:'
SELECT TOP 1 * FROM BOOKING_AUDIT WHERE BookingID = @StatusChangeBooking ORDER BY AuditID DESC;
GO

-- =============================================
-- FINAL SUMMARY
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'TESTING COMPLETED SUCCESSFULLY!'
PRINT '============================================='
PRINT ''
PRINT 'Summary of Tests Performed:'
PRINT '- 14 Stored Procedure Tests (including error handling)'
PRINT '- 6 User-Defined Function Tests'
PRINT '- 3 View Tests with multiple queries'
PRINT '- 3 DML Trigger Tests'
PRINT '============================================='
PRINT 'Total: 26 Comprehensive Tests'
PRINT '============================================='
PRINT ''
PRINT 'Review Results Above to Verify:'
PRINT '1. All stored procedures execute without errors'
PRINT '2. All functions return correct values'
PRINT '3. All views display data correctly'
PRINT '4. Trigger logs all changes to BOOKING_AUDIT table'
PRINT '============================================='
GO

-- =============================================
-- BONUS: Quick Verification Queries
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'QUICK VERIFICATION QUERIES'
PRINT '============================================='
GO

PRINT 'Total Bookings Created During Tests:'
SELECT COUNT(*) AS TotalBookings FROM BOOKING;

PRINT ''
PRINT 'Total Payments Processed:'
SELECT COUNT(*) AS TotalPayments FROM PAYMENT;

PRINT ''
PRINT 'Total Audit Records Created:'
SELECT COUNT(*) AS TotalAuditRecords FROM BOOKING_AUDIT;

PRINT ''
PRINT 'Payment Type Distribution:'
SELECT 
    'Card Payment' AS PaymentType, COUNT(*) AS Count FROM CARD_PAYMENT
UNION ALL
SELECT 
    'Wallet Payment', COUNT(*) FROM WALLET_PAYMENT
UNION ALL
SELECT 
    'PayPal Payment', COUNT(*) FROM PAYPAL_PAYMENT;

PRINT ''
PRINT 'Booking Status Distribution:'
SELECT 
    BookingStatus, 
    COUNT(*) AS Count 
FROM BOOKING 
GROUP BY BookingStatus;

PRINT ''
PRINT 'Recent Audit Log (Last 10 entries):'
SELECT TOP 10 * FROM BOOKING_AUDIT ORDER BY AuditID DESC;

GO

PRINT ''
PRINT '============================================='
PRINT 'END OF PSM TESTING SCRIPT'
PRINT '============================================='
GO