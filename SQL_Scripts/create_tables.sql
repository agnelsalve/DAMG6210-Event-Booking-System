-- =============================================
-- Event & Ticket Booking System - DDL Script
-- Group 5 - DAMG6210
-- P5 Submission - Enhanced with Encryption Support
-- =============================================

-- Drop existing database if exists and create new
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'EventBookingSystem')
BEGIN
    ALTER DATABASE EventBookingSystem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EventBookingSystem;
END
GO

CREATE DATABASE EventBookingSystem;
GO

USE EventBookingSystem;
GO

-- =============================================
-- DROP ALL TABLES IF EXIST (in reverse dependency order)
-- =============================================
IF OBJECT_ID('SEAT_BOOKING', 'U') IS NOT NULL DROP TABLE SEAT_BOOKING;
IF OBJECT_ID('BOOKING_SNACK', 'U') IS NOT NULL DROP TABLE BOOKING_SNACK;
IF OBJECT_ID('TICKET', 'U') IS NOT NULL DROP TABLE TICKET;
IF OBJECT_ID('CARD_PAYMENT', 'U') IS NOT NULL DROP TABLE CARD_PAYMENT;
IF OBJECT_ID('WALLET_PAYMENT', 'U') IS NOT NULL DROP TABLE WALLET_PAYMENT;
IF OBJECT_ID('PAYPAL_PAYMENT', 'U') IS NOT NULL DROP TABLE PAYPAL_PAYMENT;
IF OBJECT_ID('PAYMENT', 'U') IS NOT NULL DROP TABLE PAYMENT;
IF OBJECT_ID('BOOKING', 'U') IS NOT NULL DROP TABLE BOOKING;
IF OBJECT_ID('SNACK', 'U') IS NOT NULL DROP TABLE SNACK;
IF OBJECT_ID('SHOW', 'U') IS NOT NULL DROP TABLE SHOW;
IF OBJECT_ID('SEAT', 'U') IS NOT NULL DROP TABLE SEAT;
IF OBJECT_ID('SCREEN', 'U') IS NOT NULL DROP TABLE SCREEN;
IF OBJECT_ID('THEATER', 'U') IS NOT NULL DROP TABLE THEATER;
IF OBJECT_ID('MATCH', 'U') IS NOT NULL DROP TABLE MATCH;
IF OBJECT_ID('TEAM', 'U') IS NOT NULL DROP TABLE TEAM;
IF OBJECT_ID('MOVIE', 'U') IS NOT NULL DROP TABLE MOVIE;
IF OBJECT_ID('SPORT', 'U') IS NOT NULL DROP TABLE SPORT;
IF OBJECT_ID('EXHIBITION', 'U') IS NOT NULL DROP TABLE EXHIBITION;
IF OBJECT_ID('EVENT', 'U') IS NOT NULL DROP TABLE EVENT;
IF OBJECT_ID('ORGANIZER', 'U') IS NOT NULL DROP TABLE ORGANIZER;
IF OBJECT_ID('VENUE', 'U') IS NOT NULL DROP TABLE VENUE;
IF OBJECT_ID('THEATER_MANAGER', 'U') IS NOT NULL DROP TABLE THEATER_MANAGER;
IF OBJECT_ID('ADMIN', 'U') IS NOT NULL DROP TABLE ADMIN;
IF OBJECT_ID('EMPLOYEE', 'U') IS NOT NULL DROP TABLE EMPLOYEE;
IF OBJECT_ID('CUSTOMER', 'U') IS NOT NULL DROP TABLE CUSTOMER;
IF OBJECT_ID('USER', 'U') IS NOT NULL DROP TABLE [USER];
GO

-- =============================================
-- USER MANAGEMENT ENTITIES
-- =============================================

-- 1. USER (Will include encrypted PasswordHash)
CREATE TABLE [USER] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(15),
    PasswordHash VARCHAR(255) NOT NULL, -- Will be encrypted
    CustomerID INT,
    EmployeeID INT,
    OrganizerID INT,
    Role VARCHAR(20) NOT NULL,
    CONSTRAINT CHK_User_Email CHECK (Email LIKE '%_@__%.__%'),
    CONSTRAINT CHK_User_Role CHECK (Role IN ('Customer', 'Employee', 'Organizer'))
);

-- 2. CUSTOMER
CREATE TABLE CUSTOMER (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    LoyaltyPoints INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Customer_User FOREIGN KEY (UserID) REFERENCES [USER](UserID) ON DELETE CASCADE,
    CONSTRAINT CHK_Customer_LoyaltyPoints CHECK (LoyaltyPoints >= 0)
);

-- 3. EMPLOYEE
CREATE TABLE EMPLOYEE (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    HireDate DATE NOT NULL,
    CONSTRAINT FK_Employee_User FOREIGN KEY (UserID) REFERENCES [USER](UserID) ON DELETE CASCADE
);

-- 4. THEATER_MANAGER
CREATE TABLE THEATER_MANAGER (
    ManagerID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL UNIQUE,
    CONSTRAINT FK_TheaterManager_Employee FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(EmployeeID) ON DELETE CASCADE
);

-- 5. ADMIN
CREATE TABLE ADMIN (
    AdminID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL UNIQUE,
    PermissionLevel VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Admin_Employee FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(EmployeeID) ON DELETE CASCADE,
    CONSTRAINT CHK_Admin_Permission CHECK (PermissionLevel IN ('Read', 'Write', 'Admin', 'SuperAdmin'))
);

-- =============================================
-- VENUE HIERARCHY
-- =============================================

-- 6. VENUE
CREATE TABLE VENUE (
    VenueID INT IDENTITY(1,1) PRIMARY KEY,
    VenueName VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    ZipCode VARCHAR(10) NOT NULL,
    Capacity INT NOT NULL,
    CONSTRAINT CHK_Venue_Capacity CHECK (Capacity > 0)
);

-- 7. THEATER
CREATE TABLE THEATER (
    TheaterID INT IDENTITY(1,1) PRIMARY KEY,
    TheaterName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    ZipCode VARCHAR(10) NOT NULL,
    ContactNumber VARCHAR(15)
);

-- 8. SCREEN
CREATE TABLE SCREEN (
    ScreenID INT IDENTITY(1,1) PRIMARY KEY,
    TheaterID INT NOT NULL,
    ScreenNumber INT NOT NULL,
    SeatCapacity INT NOT NULL,
    CONSTRAINT FK_Screen_Theater FOREIGN KEY (TheaterID) REFERENCES THEATER(TheaterID),
    CONSTRAINT CHK_Screen_Capacity CHECK (SeatCapacity > 0)
);

-- 9. SEAT
CREATE TABLE SEAT (
    SeatID INT IDENTITY(1,1) PRIMARY KEY,
    ScreenID INT NOT NULL,
    RowNumber VARCHAR(5) NOT NULL,
    SeatNumber INT NOT NULL,
    SeatType VARCHAR(20) DEFAULT 'Regular',
    CONSTRAINT FK_Seat_Screen FOREIGN KEY (ScreenID) REFERENCES SCREEN(ScreenID),
    CONSTRAINT CHK_Seat_Type CHECK (SeatType IN ('Regular', 'Premium', 'Recliner', 'VIP'))
);

-- =============================================
-- EVENT MANAGEMENT
-- =============================================

-- 10. ORGANIZER
CREATE TABLE ORGANIZER (
    OrganizerID INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(100),
    ContactPhone VARCHAR(15)
);

-- 11. EVENT
CREATE TABLE EVENT (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganizerID INT,
    Title VARCHAR(200) NOT NULL,
    Description VARCHAR(1000),
    EventType VARCHAR(50) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Scheduled',
    Language VARCHAR(30),
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME NOT NULL,
    Duration INT,
    CONSTRAINT FK_Event_Organizer FOREIGN KEY (OrganizerID) REFERENCES ORGANIZER(OrganizerID),
    CONSTRAINT CHK_Event_DateTime CHECK (EndDateTime > StartDateTime),
    CONSTRAINT CHK_Event_Type CHECK (EventType IN ('Movie', 'Sport', 'Exhibition')),
    CONSTRAINT CHK_Event_Status CHECK (Status IN ('Scheduled', 'Ongoing', 'Completed', 'Cancelled'))
);

-- 12. MOVIE
CREATE TABLE MOVIE (
    MovieID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL UNIQUE,
    Title VARCHAR(200) NOT NULL,
    Genre VARCHAR(50) NOT NULL,
    Rating VARCHAR(10),
    ReleaseDate DATE,
    CONSTRAINT FK_Movie_Event FOREIGN KEY (EventID) REFERENCES EVENT(EventID) ON DELETE CASCADE
);

-- 13. SPORT
CREATE TABLE SPORT (
    SportID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL UNIQUE,
    SportType VARCHAR(50) NOT NULL,
    TournamentName VARCHAR(100),
    League VARCHAR(50),
    CONSTRAINT FK_Sport_Event FOREIGN KEY (EventID) REFERENCES EVENT(EventID) ON DELETE CASCADE
);

-- 14. EXHIBITION
CREATE TABLE EXHIBITION (
    ExhibitionID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL UNIQUE,
    ExhibitionTheme VARCHAR(100),
    CuratorFName VARCHAR(50),
    CuratorLName VARCHAR(50),
    CONSTRAINT FK_Exhibition_Event FOREIGN KEY (EventID) REFERENCES EVENT(EventID) ON DELETE CASCADE
);

-- =============================================
-- SPORTS INFRASTRUCTURE
-- =============================================

-- 15. TEAM
CREATE TABLE TEAM (
    TeamID INT IDENTITY(1,1) PRIMARY KEY,
    TeamName VARCHAR(100) NOT NULL,
    SportType VARCHAR(50) NOT NULL,
    Country VARCHAR(50),
    LogoURL VARCHAR(255),
    EstablishedYear INT
);

-- 16. MATCH
CREATE TABLE MATCH (
    MatchID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    SportID INT NOT NULL,
    VenueID INT NOT NULL,
    HomeTeamID INT NOT NULL,
    AwayTeamID INT NOT NULL,
    MatchDateTime DATETIME NOT NULL,
    Score VARCHAR(20),
    MatchStatus VARCHAR(20) DEFAULT 'Scheduled',
    CONSTRAINT FK_Match_Event FOREIGN KEY (EventID) REFERENCES EVENT(EventID),
    CONSTRAINT FK_Match_Sport FOREIGN KEY (SportID) REFERENCES SPORT(SportID),
    CONSTRAINT FK_Match_Venue FOREIGN KEY (VenueID) REFERENCES VENUE(VenueID),
    CONSTRAINT FK_Match_HomeTeam FOREIGN KEY (HomeTeamID) REFERENCES TEAM(TeamID),
    CONSTRAINT FK_Match_AwayTeam FOREIGN KEY (AwayTeamID) REFERENCES TEAM(TeamID),
    CONSTRAINT CHK_Match_Status CHECK (MatchStatus IN ('Scheduled', 'Live', 'Completed', 'Cancelled'))
);

-- =============================================
-- SCHEDULING AND BOOKING
-- =============================================

-- 17. SHOW
CREATE TABLE SHOW (
    ShowID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    MovieID INT,
    ScreenID INT NOT NULL,
    ShowDateTime DATETIME NOT NULL,
    ShowType VARCHAR(20),
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Show_Event FOREIGN KEY (EventID) REFERENCES EVENT(EventID),
    CONSTRAINT FK_Show_Movie FOREIGN KEY (MovieID) REFERENCES MOVIE(MovieID),
    CONSTRAINT FK_Show_Screen FOREIGN KEY (ScreenID) REFERENCES SCREEN(ScreenID),
    CONSTRAINT CHK_Show_Price CHECK (Price > 0)
);

-- 18. SNACK
CREATE TABLE SNACK (
    SnackID INT IDENTITY(1,1) PRIMARY KEY,
    SnackName VARCHAR(100) NOT NULL,
    SnackType VARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT CHK_Snack_Price CHECK (Price > 0)
);

-- 19. BOOKING
CREATE TABLE BOOKING (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    EventID INT NOT NULL,
    BookingDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    BookingStatus VARCHAR(20) DEFAULT 'Confirmed',
    CONSTRAINT FK_Booking_Customer FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID),
    CONSTRAINT FK_Booking_Event FOREIGN KEY (EventID) REFERENCES EVENT(EventID),
    CONSTRAINT CHK_Booking_TotalAmount CHECK (TotalAmount >= 0),
    CONSTRAINT CHK_Booking_Status CHECK (BookingStatus IN ('Confirmed', 'Cancelled', 'Completed'))
);

-- 20. BOOKING_SNACK
CREATE TABLE BOOKING_SNACK (
    BookingSnackID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    SnackID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    MatchDateTime DATETIME,
    CONSTRAINT FK_BookingSnack_Booking FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID) ON DELETE CASCADE,
    CONSTRAINT FK_BookingSnack_Snack FOREIGN KEY (SnackID) REFERENCES SNACK(SnackID),
    CONSTRAINT CHK_BookingSnack_Quantity CHECK (Quantity > 0)
);

-- 21. TICKET
CREATE TABLE TICKET (
    TicketID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    TicketStatus VARCHAR(20) DEFAULT 'Active',
    IssueDate DATE NOT NULL DEFAULT GETDATE(),
    ValidUntil DATE,
    QRCode VARCHAR(255),
    CONSTRAINT FK_Ticket_Booking FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID) ON DELETE CASCADE,
    CONSTRAINT CHK_Ticket_Status CHECK (TicketStatus IN ('Active', 'Used', 'Expired', 'Cancelled'))
);

-- 22. SEAT_BOOKING
CREATE TABLE SEAT_BOOKING (
    SeatBookingID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    SeatID INT NOT NULL,
    ShowID INT NOT NULL,
    CONSTRAINT FK_SeatBooking_Booking FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID) ON DELETE CASCADE,
    CONSTRAINT FK_SeatBooking_Seat FOREIGN KEY (SeatID) REFERENCES SEAT(SeatID),
    CONSTRAINT FK_SeatBooking_Show FOREIGN KEY (ShowID) REFERENCES SHOW(ShowID)
);

-- =============================================
-- PAYMENT PROCESSING (Will include encrypted CardNumber)
-- =============================================

-- 23. PAYMENT
CREATE TABLE PAYMENT (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL UNIQUE,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    TransactionReference VARCHAR(100) UNIQUE,
    CONSTRAINT FK_Payment_Booking FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID),
    CONSTRAINT CHK_Payment_Amount CHECK (Amount > 0)
);

-- 24. CARD_PAYMENT (CardNumber will be encrypted)
CREATE TABLE CARD_PAYMENT (
    CardID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID INT NOT NULL UNIQUE,
    CardNumber VARCHAR(16) NOT NULL, -- Will be encrypted
    CardHolderName VARCHAR(100) NOT NULL,
    ExpiryDate DATE,
    CONSTRAINT FK_CardPayment_Payment FOREIGN KEY (PaymentID) REFERENCES PAYMENT(PaymentID) ON DELETE CASCADE
);

-- 25. WALLET_PAYMENT
CREATE TABLE WALLET_PAYMENT (
    WalletID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID INT NOT NULL UNIQUE,
    WalletType VARCHAR(50) NOT NULL,
    CONSTRAINT FK_WalletPayment_Payment FOREIGN KEY (PaymentID) REFERENCES PAYMENT(PaymentID) ON DELETE CASCADE
);

-- 26. PAYPAL_PAYMENT
CREATE TABLE PAYPAL_PAYMENT (
    PayPalID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID INT NOT NULL UNIQUE,
    PayPalEmail VARCHAR(100) NOT NULL,
    CONSTRAINT FK_PayPalPayment_Payment FOREIGN KEY (PaymentID) REFERENCES PAYMENT(PaymentID) ON DELETE CASCADE
);

GO

PRINT 'DDL Script execution completed successfully!';
GO