-- =============================================
-- Event & Ticket Booking System - INDEXES Script
-- Group 5 - DAMG6210
-- P5 Submission - Non-Clustered Indexes for Performance Optimization
-- =============================================

USE EventBookingSystem;
GO

PRINT '============================================='
PRINT 'CREATING NON-CLUSTERED INDEXES'
PRINT '============================================='
PRINT 'Purpose: Optimize query performance for frequently accessed data'
PRINT '============================================='
GO

-- =============================================
-- SECTION 1: INDEXES ON FOREIGN KEYS
-- =============================================

PRINT ''
PRINT '--- Section 1: Foreign Key Indexes ---'
GO

-- Index 1: BOOKING.CustomerID (Frequent lookups by customer)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Booking_CustomerID' AND object_id = OBJECT_ID('BOOKING'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Booking_CustomerID
    ON BOOKING(CustomerID)
    INCLUDE (BookingDateTime, TotalAmount, BookingStatus);
    PRINT 'Created Index: IX_Booking_CustomerID';
END
GO

-- Index 2: BOOKING.EventID (Frequent lookups by event)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Booking_EventID' AND object_id = OBJECT_ID('BOOKING'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Booking_EventID
    ON BOOKING(EventID)
    INCLUDE (BookingDateTime, TotalAmount, BookingStatus);
    PRINT 'Created Index: IX_Booking_EventID';
END
GO

-- Index 3: SEAT_BOOKING.ShowID (Frequent lookups for seat availability)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SeatBooking_ShowID' AND object_id = OBJECT_ID('SEAT_BOOKING'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SeatBooking_ShowID
    ON SEAT_BOOKING(ShowID)
    INCLUDE (SeatID, BookingID);
    PRINT 'Created Index: IX_SeatBooking_ShowID';
END
GO

-- =============================================
-- SECTION 2: INDEXES ON DATE/TIME COLUMNS
-- =============================================

PRINT ''
PRINT '--- Section 2: DateTime Indexes ---'
GO

-- Index 4: BOOKING.BookingDateTime (For date range queries in reports)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Booking_BookingDateTime' AND object_id = OBJECT_ID('BOOKING'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Booking_BookingDateTime
    ON BOOKING(BookingDateTime DESC)
    INCLUDE (CustomerID, EventID, TotalAmount, BookingStatus);
    PRINT 'Created Index: IX_Booking_BookingDateTime';
END
GO

-- Index 5: EVENT.StartDateTime (For finding upcoming events)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Event_StartDateTime' AND object_id = OBJECT_ID('EVENT'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Event_StartDateTime
    ON EVENT(StartDateTime)
    INCLUDE (EventID, Title, EventType, Status);
    PRINT 'Created Index: IX_Event_StartDateTime';
END
GO

-- Index 6: SHOW.ShowDateTime (For finding show schedules)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Show_ShowDateTime' AND object_id = OBJECT_ID('SHOW'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Show_ShowDateTime
    ON SHOW(ShowDateTime)
    INCLUDE (EventID, MovieID, ScreenID, Price);
    PRINT 'Created Index: IX_Show_ShowDateTime';
END
GO

-- =============================================
-- SECTION 3: INDEXES ON STATUS COLUMNS
-- =============================================

PRINT ''
PRINT '--- Section 3: Status Column Indexes ---'
GO

-- Index 7: BOOKING.BookingStatus (For filtering by booking status)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Booking_BookingStatus' AND object_id = OBJECT_ID('BOOKING'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Booking_BookingStatus
    ON BOOKING(BookingStatus)
    INCLUDE (BookingID, CustomerID, EventID, TotalAmount);
    PRINT 'Created Index: IX_Booking_BookingStatus';
END
GO

-- Index 8: EVENT.Status (For filtering events by status)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Event_Status' AND object_id = OBJECT_ID('EVENT'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Event_Status
    ON EVENT(Status)
    INCLUDE (EventID, Title, EventType, StartDateTime);
    PRINT 'Created Index: IX_Event_Status';
END
GO

-- Index 9: TICKET.TicketStatus (For filtering tickets by status)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Ticket_TicketStatus' AND object_id = OBJECT_ID('TICKET'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Ticket_TicketStatus
    ON TICKET(TicketStatus)
    INCLUDE (TicketID, BookingID, IssueDate);
    PRINT 'Created Index: IX_Ticket_TicketStatus';
END
GO

-- =============================================
-- SECTION 4: INDEXES ON TYPE/CATEGORY COLUMNS
-- =============================================

PRINT ''
PRINT '--- Section 4: Type/Category Indexes ---'
GO

-- Index 10: EVENT.EventType (For filtering by event type)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Event_EventType' AND object_id = OBJECT_ID('EVENT'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Event_EventType
    ON EVENT(EventType)
    INCLUDE (EventID, Title, StartDateTime, Status);
    PRINT 'Created Index: IX_Event_EventType';
END
GO

-- Index 11: SEAT.SeatType (For filtering seats by type)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Seat_SeatType' AND object_id = OBJECT_ID('SEAT'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Seat_SeatType
    ON SEAT(SeatType)
    INCLUDE (SeatID, ScreenID, RowNumber, SeatNumber);
    PRINT 'Created Index: IX_Seat_SeatType';
END
GO

-- =============================================
-- SECTION 5: COMPOSITE INDEXES FOR COMMON QUERIES
-- =============================================

PRINT ''
PRINT '--- Section 5: Composite Indexes ---'
GO

-- Index 12: PAYMENT.BookingID + PaymentDateTime (For payment history queries)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Payment_BookingID_DateTime' AND object_id = OBJECT_ID('PAYMENT'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Payment_BookingID_DateTime
    ON PAYMENT(BookingID, PaymentDateTime DESC)
    INCLUDE (Amount, TransactionReference);
    PRINT 'Created Index: IX_Payment_BookingID_DateTime';
END
GO

-- Index 13: SHOW.EventID + ScreenID (For finding shows by event and screen)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Show_EventID_ScreenID' AND object_id = OBJECT_ID('SHOW'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Show_EventID_ScreenID
    ON SHOW(EventID, ScreenID)
    INCLUDE (ShowID, ShowDateTime, Price);
    PRINT 'Created Index: IX_Show_EventID_ScreenID';
END
GO

-- Index 14: SEAT.ScreenID + RowNumber (For seat selection queries)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Seat_ScreenID_RowNumber' AND object_id = OBJECT_ID('SEAT'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Seat_ScreenID_RowNumber
    ON SEAT(ScreenID, RowNumber)
    INCLUDE (SeatID, SeatNumber, SeatType);
    PRINT 'Created Index: IX_Seat_ScreenID_RowNumber';
END
GO

-- =============================================
-- SECTION 6: INDEXES FOR SEARCH OPERATIONS
-- =============================================

PRINT ''
PRINT '--- Section 6: Search Operation Indexes ---'
GO

-- Index 15: USER.Email (For user login and authentication)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_User_Email' AND object_id = OBJECT_ID('[USER]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_User_Email
    ON [USER](Email)
    INCLUDE (UserID, FirstName, LastName, Role);
    PRINT 'Created Index: IX_User_Email';
END
GO

-- Index 16: CUSTOMER.UserID (For customer lookups)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customer_UserID' AND object_id = OBJECT_ID('CUSTOMER'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Customer_UserID
    ON CUSTOMER(UserID)
    INCLUDE (CustomerID, LoyaltyPoints);
    PRINT 'Created Index: IX_Customer_UserID';
END
GO

-- Index 17: EMPLOYEE.UserID (For employee lookups)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employee_UserID' AND object_id = OBJECT_ID('EMPLOYEE'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Employee_UserID
    ON EMPLOYEE(UserID)
    INCLUDE (EmployeeID, HireDate);
    PRINT 'Created Index: IX_Employee_UserID';
END
GO

-- =============================================
-- SECTION 7: INDEXES FOR REPORTING QUERIES
-- =============================================

PRINT ''
PRINT '--- Section 7: Reporting Indexes ---'
GO

-- Index 18: BOOKING_SNACK.BookingID (For order details)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BookingSnack_BookingID' AND object_id = OBJECT_ID('BOOKING_SNACK'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_BookingSnack_BookingID
    ON BOOKING_SNACK(BookingID)
    INCLUDE (SnackID, Quantity, Subtotal);
    PRINT 'Created Index: IX_BookingSnack_BookingID';
END
GO

-- Index 19: TICKET.BookingID (For ticket lookups by booking)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Ticket_BookingID' AND object_id = OBJECT_ID('TICKET'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Ticket_BookingID
    ON TICKET(BookingID)
    INCLUDE (TicketID, TicketStatus, QRCode);
    PRINT 'Created Index: IX_Ticket_BookingID';
END
GO

-- Index 20: SCREEN.TheaterID (For theater screen lookups)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Screen_TheaterID' AND object_id = OBJECT_ID('SCREEN'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Screen_TheaterID
    ON SCREEN(TheaterID)
    INCLUDE (ScreenID, ScreenNumber, SeatCapacity);
    PRINT 'Created Index: IX_Screen_TheaterID';
END
GO

-- =============================================
-- SECTION 8: VERIFY ALL INDEXES CREATED
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'INDEX CREATION SUMMARY'
PRINT '============================================='
GO

-- Display all non-clustered indexes created
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    STUFF((
        SELECT ', ' + c.name
        FROM sys.index_columns ic
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        ORDER BY ic.key_ordinal
        FOR XML PATH('')
    ), 1, 2, '') AS KeyColumns,
    STUFF((
        SELECT ', ' + c.name
        FROM sys.index_columns ic
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
        FOR XML PATH('')
    ), 1, 2, '') AS IncludedColumns
FROM sys.indexes i
WHERE i.object_id IN (
    OBJECT_ID('BOOKING'), OBJECT_ID('SEAT_BOOKING'), OBJECT_ID('EVENT'),
    OBJECT_ID('SHOW'), OBJECT_ID('TICKET'), OBJECT_ID('PAYMENT'),
    OBJECT_ID('SEAT'), OBJECT_ID('[USER]'), OBJECT_ID('CUSTOMER'),
    OBJECT_ID('EMPLOYEE'), OBJECT_ID('BOOKING_SNACK'), OBJECT_ID('SCREEN')
)
AND i.type_desc = 'NONCLUSTERED'
AND i.name LIKE 'IX_%'
ORDER BY TableName, IndexName;

PRINT ''
PRINT 'Total Non-Clustered Indexes Created: 20'
PRINT '============================================='
GO

PRINT ''
PRINT '============================================='
PRINT 'INDEX SCRIPT COMPLETED SUCCESSFULLY!'
PRINT '============================================='
GO