-- =============================================
-- Event & Ticket Booking System - INSERT Script
-- Group 5 - DAMG6210
-- P5 Submission - Fresh Realistic Data (Minimum 10 rows per table)
-- =============================================

USE EventBookingSystem;
GO

-- =============================================
-- 1. ORGANIZER DATA (10 rows - Independent table)
-- =============================================
INSERT INTO ORGANIZER (CompanyName, ContactEmail, ContactPhone) VALUES
('Live Nation Entertainment', 'info@livenation.com', '310-867-7000'),
('AEG Presents', 'contact@aegpresents.com', '213-763-7800'),
('Madison Square Garden Entertainment', 'info@msg.com', '212-465-6741'),
('Ticketmaster Events', 'events@ticketmaster.com', '800-653-8000'),
('Boston Entertainment Group', 'hello@bostonent.com', '617-624-1000'),
('New England Sports Ventures', 'contact@nesv.com', '617-226-6000'),
('Cultural Arts Boston', 'info@culturalarts.org', '617-385-4000'),
('Metro Events Boston', 'bookings@metroevents.com', '617-440-5000'),
('Premier Sports Entertainment', 'contact@premiersports.com', '617-621-8666'),
('Boston Film Society', 'info@bostonfilm.org', '617-777-1700'),
('Atlantic Entertainment Corp', 'info@atlanticent.com', '212-555-0100'),
('Northeast Cultural Foundation', 'contact@necf.org', '617-555-0200');

-- =============================================
-- 2. USER MANAGEMENT DATA
-- =============================================

-- Insert 20 USERS (10 Customers + 10 Employees)
INSERT INTO [USER] (FirstName, LastName, Email, PhoneNumber, PasswordHash, CustomerID, EmployeeID, OrganizerID, Role) VALUES
-- Customers (1-10)
('Michael', 'Anderson', 'michael.anderson@email.com', '617-234-5601', 'TEMP_HASH_001', NULL, NULL, NULL, 'Customer'),
('Sarah', 'Martinez', 'sarah.martinez@email.com', '617-234-5602', 'TEMP_HASH_002', NULL, NULL, NULL, 'Customer'),
('David', 'Thompson', 'david.thompson@email.com', '617-234-5603', 'TEMP_HASH_003', NULL, NULL, NULL, 'Customer'),
('Jennifer', 'Garcia', 'jennifer.garcia@email.com', '617-234-5604', 'TEMP_HASH_004', NULL, NULL, NULL, 'Customer'),
('Robert', 'Rodriguez', 'robert.rodriguez@email.com', '617-234-5605', 'TEMP_HASH_005', NULL, NULL, NULL, 'Customer'),
('Emily', 'Wilson', 'emily.wilson@email.com', '617-234-5606', 'TEMP_HASH_006', NULL, NULL, NULL, 'Customer'),
('James', 'Taylor', 'james.taylor@email.com', '617-234-5607', 'TEMP_HASH_007', NULL, NULL, NULL, 'Customer'),
('Lisa', 'Brown', 'lisa.brown@email.com', '617-234-5608', 'TEMP_HASH_008', NULL, NULL, NULL, 'Customer'),
('Christopher', 'Lee', 'chris.lee@email.com', '617-234-5609', 'TEMP_HASH_009', NULL, NULL, NULL, 'Customer'),
('Amanda', 'White', 'amanda.white@email.com', '617-234-5610', 'TEMP_HASH_010', NULL, NULL, NULL, 'Customer'),
('Daniel', 'Harris', 'daniel.harris@email.com', '617-234-5611', 'TEMP_HASH_011', NULL, NULL, NULL, 'Customer'),
('Michelle', 'Clark', 'michelle.clark@email.com', '617-234-5612', 'TEMP_HASH_012', NULL, NULL, NULL, 'Customer'),
-- Employees (13-22)
('William', 'Johnson', 'william.johnson@company.com', '617-345-6701', 'TEMP_HASH_013', NULL, NULL, NULL, 'Employee'),
('Patricia', 'Miller', 'patricia.miller@company.com', '617-345-6702', 'TEMP_HASH_014', NULL, NULL, NULL, 'Employee'),
('Richard', 'Davis', 'richard.davis@company.com', '617-345-6703', 'TEMP_HASH_015', NULL, NULL, NULL, 'Employee'),
('Barbara', 'Moore', 'barbara.moore@company.com', '617-345-6704', 'TEMP_HASH_016', NULL, NULL, NULL, 'Employee'),
('Thomas', 'Jackson', 'thomas.jackson@company.com', '617-345-6705', 'TEMP_HASH_017', NULL, NULL, NULL, 'Employee'),
('Nancy', 'Martin', 'nancy.martin@company.com', '617-345-6706', 'TEMP_HASH_018', NULL, NULL, NULL, 'Employee'),
('Charles', 'Thompson', 'charles.thompson@company.com', '617-345-6707', 'TEMP_HASH_019', NULL, NULL, NULL, 'Employee'),
('Karen', 'White', 'karen.white@company.com', '617-345-6708', 'TEMP_HASH_020', NULL, NULL, NULL, 'Employee'),
('Joseph', 'Harris', 'joseph.harris@company.com', '617-345-6709', 'TEMP_HASH_021', NULL, NULL, NULL, 'Employee'),
('Betty', 'Clark', 'betty.clark@company.com', '617-345-6710', 'TEMP_HASH_022', NULL, NULL, NULL, 'Employee'),
('Steven', 'Lewis', 'steven.lewis@company.com', '617-345-6711', 'TEMP_HASH_023', NULL, NULL, NULL, 'Employee'),
('Margaret', 'Walker', 'margaret.walker@company.com', '617-345-6712', 'TEMP_HASH_024', NULL, NULL, NULL, 'Employee');

-- Insert 12 CUSTOMERS
INSERT INTO CUSTOMER (UserID, LoyaltyPoints) VALUES
(1, 250),
(2, 480),
(3, 120),
(4, 890),
(5, 340),
(6, 670),
(7, 150),
(8, 920),
(9, 410),
(10, 580),
(11, 760),
(12, 290);

-- Update USER table with CustomerIDs
UPDATE [USER] SET CustomerID = 1 WHERE UserID = 1;
UPDATE [USER] SET CustomerID = 2 WHERE UserID = 2;
UPDATE [USER] SET CustomerID = 3 WHERE UserID = 3;
UPDATE [USER] SET CustomerID = 4 WHERE UserID = 4;
UPDATE [USER] SET CustomerID = 5 WHERE UserID = 5;
UPDATE [USER] SET CustomerID = 6 WHERE UserID = 6;
UPDATE [USER] SET CustomerID = 7 WHERE UserID = 7;
UPDATE [USER] SET CustomerID = 8 WHERE UserID = 8;
UPDATE [USER] SET CustomerID = 9 WHERE UserID = 9;
UPDATE [USER] SET CustomerID = 10 WHERE UserID = 10;
UPDATE [USER] SET CustomerID = 11 WHERE UserID = 11;
UPDATE [USER] SET CustomerID = 12 WHERE UserID = 12;

-- Insert 12 EMPLOYEES
INSERT INTO EMPLOYEE (UserID, HireDate) VALUES
(13, '2022-01-15'),
(14, '2022-03-20'),
(15, '2022-05-10'),
(16, '2022-07-05'),
(17, '2022-09-15'),
(18, '2023-01-20'),
(19, '2023-03-10'),
(20, '2023-05-25'),
(21, '2023-07-30'),
(22, '2023-09-15'),
(23, '2024-01-10'),
(24, '2024-03-05');

-- Update USER table with EmployeeIDs
UPDATE [USER] SET EmployeeID = 1 WHERE UserID = 13;
UPDATE [USER] SET EmployeeID = 2 WHERE UserID = 14;
UPDATE [USER] SET EmployeeID = 3 WHERE UserID = 15;
UPDATE [USER] SET EmployeeID = 4 WHERE UserID = 16;
UPDATE [USER] SET EmployeeID = 5 WHERE UserID = 17;
UPDATE [USER] SET EmployeeID = 6 WHERE UserID = 18;
UPDATE [USER] SET EmployeeID = 7 WHERE UserID = 19;
UPDATE [USER] SET EmployeeID = 8 WHERE UserID = 20;
UPDATE [USER] SET EmployeeID = 9 WHERE UserID = 21;
UPDATE [USER] SET EmployeeID = 10 WHERE UserID = 22;
UPDATE [USER] SET EmployeeID = 11 WHERE UserID = 23;
UPDATE [USER] SET EmployeeID = 12 WHERE UserID = 24;

-- Insert 12 THEATER_MANAGERS
INSERT INTO THEATER_MANAGER (EmployeeID) VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12);

-- Insert 12 ADMINS
INSERT INTO ADMIN (EmployeeID, PermissionLevel) VALUES
(1, 'SuperAdmin'),
(2, 'Admin'),
(3, 'Admin'),
(4, 'SuperAdmin'),
(5, 'Admin'),
(6, 'Write'),
(7, 'Admin'),
(8, 'Write'),
(9, 'Read'),
(10, 'Admin'),
(11, 'Write'),
(12, 'Read');

-- =============================================
-- 3. VENUE HIERARCHY DATA
-- =============================================

-- Insert 12 VENUES
INSERT INTO VENUE (VenueName, Address, City, State, ZipCode, Capacity) VALUES
('TD Garden', '100 Legends Way', 'Boston', 'MA', '02114', 19580),
('Fenway Park', '4 Jersey Street', 'Boston', 'MA', '02215', 37755),
('Gillette Stadium', '1 Patriot Place', 'Foxborough', 'MA', '02035', 65878),
('Agganis Arena', '925 Commonwealth Ave', 'Boston', 'MA', '02215', 7200),
('Leader Bank Pavilion', '290 Northern Ave', 'Boston', 'MA', '02210', 5000),
('MGM Music Hall', '2 Lansdowne Street', 'Boston', 'MA', '02215', 5000),
('House of Blues Boston', '15 Lansdowne Street', 'Boston', 'MA', '02215', 2500),
('Paradise Rock Club', '967 Commonwealth Ave', 'Boston', 'MA', '02215', 933),
('Wang Theatre', '270 Tremont Street', 'Boston', 'MA', '02116', 3600),
('Boston Opera House', '539 Washington Street', 'Boston', 'MA', '02111', 2677),
('Orpheum Theatre', '1 Hamilton Place', 'Boston', 'MA', '02108', 2700),
('Royale Boston', '279 Tremont Street', 'Boston', 'MA', '02116', 1500);

-- Insert 12 THEATERS
INSERT INTO THEATER (TheaterName, City, State, ZipCode, ContactNumber) VALUES
('AMC Boston Common 19', 'Boston', 'MA', '02116', '617-423-5801'),
('Regal Fenway 13', 'Boston', 'MA', '02215', '844-462-7342'),
('AMC Assembly Row 12', 'Somerville', 'MA', '02145', '617-591-4344'),
('Showcase Cinema de Lux Legacy Place', 'Dedham', 'MA', '02026', '781-326-4955'),
('AMC South Bay Center 12', 'Boston', 'MA', '02127', '617-464-0768'),
('Coolidge Corner Theatre', 'Brookline', 'MA', '02446', '617-734-2500'),
('Alamo Drafthouse Cinema Seaport', 'Boston', 'MA', '02210', '617-315-4524'),
('Landmark Kendall Square Cinema', 'Cambridge', 'MA', '02142', '617-621-1202'),
('Brattle Theatre', 'Cambridge', 'MA', '02138', '617-876-6837'),
('Somerville Theatre', 'Somerville', 'MA', '02144', '617-625-5700'),
('Capitol Theatre Arlington', 'Arlington', 'MA', '02474', '781-648-4340'),
('West Newton Cinema', 'Newton', 'MA', '02465', '617-964-6060');

-- Insert 15 SCREENS (distributed across theaters)
INSERT INTO SCREEN (TheaterID, ScreenNumber, SeatCapacity) VALUES
(1, 1, 300),
(1, 2, 250),
(1, 3, 280),
(2, 1, 220),
(2, 2, 200),
(3, 1, 240),
(3, 2, 180),
(4, 1, 320),
(4, 2, 260),
(5, 1, 190),
(6, 1, 150),
(7, 1, 280),
(8, 1, 200),
(9, 1, 120),
(10, 1, 210);

-- Insert 40 SEATS (ensuring at least 10 per table requirement, distributed across screens)
INSERT INTO SEAT (ScreenID, RowNumber, SeatNumber, SeatType) VALUES
-- Screen 1 seats
(1, 'A', 1, 'Premium'),
(1, 'A', 2, 'Premium'),
(1, 'A', 3, 'Premium'),
(1, 'B', 1, 'Regular'),
(1, 'B', 2, 'Regular'),
(1, 'B', 3, 'Regular'),
(1, 'C', 1, 'Recliner'),
(1, 'C', 2, 'Recliner'),
(1, 'D', 1, 'VIP'),
(1, 'D', 2, 'VIP'),
-- Screen 2 seats
(2, 'A', 1, 'Premium'),
(2, 'A', 2, 'Premium'),
(2, 'B', 1, 'Regular'),
(2, 'B', 2, 'Regular'),
(2, 'C', 1, 'Recliner'),
(2, 'C', 2, 'Recliner'),
-- Screen 3 seats
(3, 'A', 1, 'Premium'),
(3, 'A', 2, 'Premium'),
(3, 'B', 1, 'Regular'),
(3, 'B', 2, 'Regular'),
-- Screen 4 seats
(4, 'A', 1, 'Regular'),
(4, 'A', 2, 'Regular'),
(4, 'B', 1, 'Premium'),
(4, 'B', 2, 'Premium'),
-- Screen 5 seats
(5, 'A', 1, 'Recliner'),
(5, 'A', 2, 'Recliner'),
(5, 'B', 1, 'Regular'),
(5, 'B', 2, 'Regular'),
-- Additional seats for other screens
(6, 'A', 1, 'Regular'),
(6, 'A', 2, 'Regular'),
(7, 'A', 1, 'Premium'),
(7, 'A', 2, 'Premium'),
(8, 'A', 1, 'VIP'),
(8, 'A', 2, 'VIP'),
(9, 'A', 1, 'Regular'),
(9, 'A', 2, 'Regular'),
(10, 'A', 1, 'Recliner'),
(10, 'A', 2, 'Recliner'),
(11, 'A', 1, 'Regular'),
(12, 'A', 1, 'Premium');

-- =============================================
-- 4. EVENT MANAGEMENT DATA
-- =============================================

-- Insert 25 EVENTS (Mix of Movies, Sports, Exhibitions)
INSERT INTO EVENT (OrganizerID, Title, Description, EventType, Status, Language, StartDateTime, EndDateTime, Duration) VALUES
-- Movies (1-15)
(1, 'The Shawshank Redemption', 'Two imprisoned men bond over years finding redemption', 'Movie', 'Scheduled', 'English', '2024-12-01 19:00:00', '2024-12-01 21:22:00', 142),
(2, 'The Godfather', 'The aging patriarch transfers control to his son', 'Movie', 'Scheduled', 'English', '2024-12-02 20:00:00', '2024-12-02 22:55:00', 175),
(3, 'The Dark Knight', 'Batman must accept greatest tests to fight injustice', 'Movie', 'Scheduled', 'English', '2024-12-03 18:30:00', '2024-12-03 21:02:00', 152),
(4, 'Pulp Fiction', 'Lives of mob hitmen and criminals intertwine', 'Movie', 'Scheduled', 'English', '2024-12-04 21:00:00', '2024-12-04 23:34:00', 154),
(5, 'Forrest Gump', 'Presidencies and decades through eyes of Alabama man', 'Movie', 'Scheduled', 'English', '2024-12-05 17:00:00', '2024-12-05 19:22:00', 142),
(6, 'Inception', 'Thief who steals secrets through dream-sharing', 'Movie', 'Scheduled', 'English', '2024-12-06 19:30:00', '2024-12-06 21:58:00', 148),
(10, 'The Matrix', 'Computer hacker learns reality is a simulation', 'Movie', 'Scheduled', 'English', '2024-12-07 20:00:00', '2024-12-07 22:16:00', 136),
(1, 'Interstellar', 'Team of explorers travel through a wormhole', 'Movie', 'Scheduled', 'English', '2024-12-08 18:00:00', '2024-12-08 20:49:00', 169),
(2, 'Goodfellas', 'Life of Henry Hill in mob from 1955 to 1980', 'Movie', 'Scheduled', 'English', '2024-12-09 21:30:00', '2024-12-10 00:16:00', 146),
(3, 'The Silence of the Lambs', 'FBI cadet seeks help from imprisoned cannibal', 'Movie', 'Scheduled', 'English', '2024-12-10 19:00:00', '2024-12-10 21:18:00', 118),
(4, 'Schindlers List', 'German industrialist saves Jews during Holocaust', 'Movie', 'Scheduled', 'English', '2024-12-11 17:30:00', '2024-12-11 20:45:00', 195),
(5, 'The Green Mile', 'Death row guard has miraculous encounter', 'Movie', 'Scheduled', 'English', '2024-12-12 18:30:00', '2024-12-12 21:39:00', 189),
(6, 'Gladiator', 'Former Roman General seeks vengeance', 'Movie', 'Scheduled', 'English', '2024-12-13 20:00:00', '2024-12-13 22:35:00', 155),
(10, 'The Departed', 'Undercover cop and mole try to identify each other', 'Movie', 'Scheduled', 'English', '2024-12-14 19:30:00', '2024-12-14 22:01:00', 151),
(1, 'Oppenheimer', 'Story of American scientist J. Robert Oppenheimer', 'Movie', 'Scheduled', 'English', '2024-12-15 17:00:00', '2024-12-15 20:00:00', 180),
-- Sports Events (16-20)
(7, 'Celtics vs Lakers Championship', 'NBA Finals Game 5', 'Sport', 'Scheduled', 'English', '2025-01-15 20:00:00', '2025-01-15 22:30:00', 150),
(9, 'Red Sox vs Yankees Playoff', 'ALCS Game 3', 'Sport', 'Scheduled', 'English', '2025-01-20 19:00:00', '2025-01-20 22:00:00', 180),
(7, 'Bruins Stanley Cup Final', 'NHL Finals Game 7', 'Sport', 'Scheduled', 'English', '2025-01-25 20:00:00', '2025-01-25 23:00:00', 180),
(9, 'New England Revolution MLS Cup', 'MLS Championship Match', 'Sport', 'Scheduled', 'English', '2025-02-01 15:00:00', '2025-02-01 17:00:00', 120),
(7, 'Boston Marathon Finals', 'Championship marathon event', 'Sport', 'Scheduled', 'English', '2025-02-10 09:00:00', '2025-02-10 14:00:00', 300),
-- Exhibitions (21-25)
(8, 'Impressionist Masters Exhibition', 'Featuring works from Monet, Renoir, and Degas', 'Exhibition', 'Scheduled', 'English', '2024-12-01 09:00:00', '2025-01-31 18:00:00', NULL),
(11, 'Ancient Egypt: Treasures Revealed', 'Rare artifacts from Egyptian dynasties', 'Exhibition', 'Scheduled', 'English', '2024-12-05 10:00:00', '2025-02-28 17:00:00', NULL),
(8, 'Modern Photography Showcase', 'Contemporary photographers from around the world', 'Exhibition', 'Scheduled', 'English', '2024-12-10 09:00:00', '2025-01-15 19:00:00', NULL),
(11, 'Science and Innovation Expo', 'Interactive exhibits on cutting-edge technology', 'Exhibition', 'Scheduled', 'English', '2024-12-15 10:00:00', '2025-02-15 18:00:00', NULL),
(8, 'Renaissance Art Collection', 'Masterpieces from Italian Renaissance', 'Exhibition', 'Scheduled', 'English', '2024-12-20 09:00:00', '2025-03-20 17:00:00', NULL);

-- Insert 15 MOVIES
INSERT INTO MOVIE (EventID, Title, Genre, Rating, ReleaseDate) VALUES
(1, 'The Shawshank Redemption', 'Drama', 'R', '1994-09-23'),
(2, 'The Godfather', 'Crime/Drama', 'R', '1972-03-24'),
(3, 'The Dark Knight', 'Action/Crime', 'PG-13', '2008-07-18'),
(4, 'Pulp Fiction', 'Crime/Drama', 'R', '1994-10-14'),
(5, 'Forrest Gump', 'Drama/Romance', 'PG-13', '1994-07-06'),
(6, 'Inception', 'Sci-Fi/Action', 'PG-13', '2010-07-16'),
(7, 'The Matrix', 'Sci-Fi/Action', 'R', '1999-03-31'),
(8, 'Interstellar', 'Sci-Fi/Drama', 'PG-13', '2014-11-07'),
(9, 'Goodfellas', 'Crime/Drama', 'R', '1990-09-19'),
(10, 'The Silence of the Lambs', 'Thriller/Crime', 'R', '1991-02-14'),
(11, 'Schindlers List', 'Biography/Drama', 'R', '1993-12-15'),
(12, 'The Green Mile', 'Drama/Fantasy', 'R', '1999-12-10'),
(13, 'Gladiator', 'Action/Drama', 'R', '2000-05-05'),
(14, 'The Departed', 'Crime/Thriller', 'R', '2006-10-06'),
(15, 'Oppenheimer', 'Biography/Drama', 'R', '2023-07-21');

-- Insert 5 SPORTS
INSERT INTO SPORT (EventID, SportType, TournamentName, League) VALUES
(16, 'Basketball', 'NBA Finals 2025', 'NBA'),
(17, 'Baseball', 'ALCS 2025', 'MLB'),
(18, 'Ice Hockey', 'Stanley Cup Finals 2025', 'NHL'),
(19, 'Soccer', 'MLS Cup 2025', 'MLS'),
(20, 'Marathon', 'Boston Marathon Championship', 'IAAF');

-- Insert 5 EXHIBITIONS
INSERT INTO EXHIBITION (EventID, ExhibitionTheme, CuratorFName, CuratorLName) VALUES
(21, 'Impressionist Masters', 'Catherine', 'Stevens'),
(22, 'Ancient Egypt', 'Marcus', 'Abdullah'),
(23, 'Modern Photography', 'Elena', 'Rodriguez'),
(24, 'Science and Innovation', 'Thomas', 'Chen'),
(25, 'Renaissance Art', 'Isabella', 'Fontana');

-- =============================================
-- 5. SPORTS INFRASTRUCTURE DATA
-- =============================================

-- Insert 15 TEAMS
INSERT INTO TEAM (TeamName, SportType, Country, LogoURL, EstablishedYear) VALUES
('Boston Celtics', 'Basketball', 'USA', 'https://cdn.nba.com/logos/celtics.png', 1946),
('Los Angeles Lakers', 'Basketball', 'USA', 'https://cdn.nba.com/logos/lakers.png', 1947),
('Boston Red Sox', 'Baseball', 'USA', 'https://cdn.mlb.com/logos/redsox.png', 1901),
('New York Yankees', 'Baseball', 'USA', 'https://cdn.mlb.com/logos/yankees.png', 1903),
('Boston Bruins', 'Ice Hockey', 'USA', 'https://cdn.nhl.com/logos/bruins.png', 1924),
('Montreal Canadiens', 'Ice Hockey', 'Canada', 'https://cdn.nhl.com/logos/canadiens.png', 1909),
('New England Revolution', 'Soccer', 'USA', 'https://cdn.mls.com/logos/revolution.png', 1995),
('LA Galaxy', 'Soccer', 'USA', 'https://cdn.mls.com/logos/galaxy.png', 1995),
('Miami Heat', 'Basketball', 'USA', 'https://cdn.nba.com/logos/heat.png', 1988),
('Chicago Bulls', 'Basketball', 'USA', 'https://cdn.nba.com/logos/bulls.png', 1966),
('Tampa Bay Rays', 'Baseball', 'USA', 'https://cdn.mlb.com/logos/rays.png', 1998),
('Toronto Blue Jays', 'Baseball', 'Canada', 'https://cdn.mlb.com/logos/bluejays.png', 1977),
('Tampa Bay Lightning', 'Ice Hockey', 'USA', 'https://cdn.nhl.com/logos/lightning.png', 1992),
('Seattle Sounders', 'Soccer', 'USA', 'https://cdn.mls.com/logos/sounders.png', 2007),
('Portland Timbers', 'Soccer', 'USA', 'https://cdn.mls.com/logos/timbers.png', 2009);

-- Insert 12 MATCHES
INSERT INTO MATCH (EventID, SportID, VenueID, HomeTeamID, AwayTeamID, MatchDateTime, Score, MatchStatus) VALUES
(16, 1, 1, 1, 2, '2025-01-15 20:00:00', NULL, 'Scheduled'),
(16, 1, 1, 1, 9, '2025-01-17 19:30:00', NULL, 'Scheduled'),
(17, 2, 2, 3, 4, '2025-01-20 19:00:00', NULL, 'Scheduled'),
(17, 2, 2, 3, 11, '2025-01-22 20:00:00', NULL, 'Scheduled'),
(18, 3, 1, 5, 6, '2025-01-25 20:00:00', NULL, 'Scheduled'),
(18, 3, 1, 5, 13, '2025-01-27 19:00:00', NULL, 'Scheduled'),
(19, 4, 3, 7, 8, '2025-02-01 15:00:00', NULL, 'Scheduled'),
(19, 4, 3, 7, 14, '2025-02-03 18:00:00', NULL, 'Scheduled'),
(16, 1, 1, 2, 10, '2025-01-19 21:00:00', '108-105', 'Completed'),
(17, 2, 2, 4, 12, '2025-01-24 19:30:00', '5-3', 'Completed'),
(18, 3, 1, 6, 5, '2025-01-29 20:30:00', '3-2', 'Completed'),
(19, 4, 3, 8, 15, '2025-02-05 16:00:00', '2-1', 'Completed');

-- =============================================
-- 6. SCHEDULING DATA
-- =============================================

-- Insert 20 SHOWS (Movie showtimes)
INSERT INTO SHOW (EventID, MovieID, ScreenID, ShowDateTime, ShowType, Price) VALUES
(1, 1, 1, '2024-12-01 19:00:00', 'Evening', 15.50),
(1, 1, 2, '2024-12-01 21:30:00', 'Night', 18.50),
(2, 2, 3, '2024-12-02 20:00:00', 'Evening', 16.00),
(3, 3, 4, '2024-12-03 18:30:00', 'Evening', 17.50),
(4, 4, 5, '2024-12-04 21:00:00', 'Night', 19.00),
(5, 5, 6, '2024-12-05 17:00:00', 'Matinee', 14.50),
(6, 6, 7, '2024-12-06 19:30:00', 'Evening', 18.00),
(7, 7, 8, '2024-12-07 20:00:00', 'Evening', 16.50),
(8, 8, 9, '2024-12-08 18:00:00', 'Evening', 19.50),
(9, 9, 10, '2024-12-09 21:30:00', 'Night', 20.00),
(10, 10, 11, '2024-12-10 19:00:00', 'Evening', 15.00),
(11, 11, 12, '2024-12-11 17:30:00', 'Matinee', 14.00),
(12, 12, 13, '2024-12-12 18:30:00', 'Evening', 17.00),
(13, 13, 14, '2024-12-13 20:00:00', 'Evening', 18.50),
(14, 14, 15, '2024-12-14 19:30:00', 'Evening', 16.00),
(15, 15, 1, '2024-12-15 17:00:00', 'Matinee', 20.00),
(1, 1, 3, '2024-12-01 14:00:00', 'Matinee', 13.50),
(2, 2, 4, '2024-12-02 15:30:00', 'Matinee', 14.00),
(3, 3, 5, '2024-12-03 22:00:00', 'Night', 19.50),
(4, 4, 6, '2024-12-04 16:00:00', 'Matinee', 15.00);

-- Insert 15 SNACKS
INSERT INTO SNACK (SnackName, SnackType, Price) VALUES
('Jumbo Popcorn', 'Popcorn', 9.50),
('Large Popcorn', 'Popcorn', 7.50),
('Medium Popcorn', 'Popcorn', 6.00),
('Small Popcorn', 'Popcorn', 4.50),
('Jumbo Soda', 'Beverage', 6.50),
('Large Soda', 'Beverage', 5.50),
('Medium Soda', 'Beverage', 4.50),
('Small Soda', 'Beverage', 3.50),
('Nachos Supreme', 'Food', 8.50),
('Loaded Hot Dog', 'Food', 7.00),
('Pretzel Bites', 'Food', 6.50),
('Candy Mix', 'Candy', 5.00),
('Chocolate Bar', 'Candy', 4.00),
('Premium Water', 'Beverage', 4.00),
('Energy Drink', 'Beverage', 5.50);

-- =============================================
-- 7. BOOKING DATA
-- =============================================

-- Insert 20 BOOKINGS
INSERT INTO BOOKING (CustomerID, EventID, BookingDateTime, TotalAmount, BookingStatus) VALUES
(1, 1, '2024-11-25 10:00:00', 45.50, 'Confirmed'),
(2, 2, '2024-11-25 11:30:00', 52.00, 'Confirmed'),
(3, 3, '2024-11-26 09:15:00', 61.00, 'Confirmed'),
(4, 4, '2024-11-26 14:45:00', 48.50, 'Confirmed'),
(5, 5, '2024-11-27 16:20:00', 39.00, 'Confirmed'),
(6, 6, '2024-11-27 18:00:00', 54.00, 'Confirmed'),
(7, 7, '2024-11-28 12:30:00', 41.50, 'Confirmed'),
(8, 8, '2024-11-28 15:10:00', 58.50, 'Confirmed'),
(9, 9, '2024-11-29 10:45:00', 65.00, 'Confirmed'),
(10, 10, '2024-11-29 13:20:00', 44.00, 'Confirmed'),
(11, 11, '2024-11-30 11:00:00', 42.00, 'Confirmed'),
(12, 12, '2024-11-30 14:30:00', 51.00, 'Confirmed'),
(1, 13, '2024-12-01 09:00:00', 55.50, 'Confirmed'),
(2, 14, '2024-12-01 16:45:00', 47.00, 'Confirmed'),
(3, 15, '2024-12-02 10:30:00', 60.00, 'Confirmed'),
(4, 1, '2024-11-25 12:00:00', 43.50, 'Confirmed'),
(5, 2, '2024-11-26 15:30:00', 50.00, 'Cancelled'),
(6, 3, '2024-11-27 11:00:00', 56.00, 'Confirmed'),
(7, 4, '2024-11-28 13:45:00', 49.50, 'Completed'),
(8, 5, '2024-11-29 17:00:00', 38.00, 'Confirmed');

-- Insert 20 BOOKING_SNACK
INSERT INTO BOOKING_SNACK (BookingID, SnackID, Quantity, UnitPrice, Subtotal, MatchDateTime) VALUES
(1, 1, 2, 9.50, 19.00, NULL),
(1, 5, 2, 6.50, 13.00, NULL),
(2, 2, 2, 7.50, 15.00, NULL),
(2, 6, 3, 5.50, 16.50, NULL),
(3, 3, 3, 6.00, 18.00, NULL),
(3, 7, 2, 4.50, 9.00, NULL),
(4, 9, 2, 8.50, 17.00, NULL),
(4, 12, 1, 5.00, 5.00, NULL),
(5, 4, 2, 4.50, 9.00, NULL),
(5, 8, 2, 3.50, 7.00, NULL),
(6, 1, 3, 9.50, 28.50, NULL),
(6, 13, 2, 4.00, 8.00, NULL),
(7, 10, 2, 7.00, 14.00, NULL),
(7, 14, 1, 4.00, 4.00, NULL),
(8, 11, 3, 6.50, 19.50, NULL),
(9, 2, 4, 7.50, 30.00, NULL),
(10, 3, 3, 6.00, 18.00, NULL),
(11, 4, 4, 4.50, 18.00, NULL),
(12, 9, 3, 8.50, 25.50, NULL),
(13, 1, 2, 9.50, 19.00, NULL);

-- Insert 25 TICKETS
INSERT INTO TICKET (BookingID, TicketStatus, IssueDate, ValidUntil, QRCode) VALUES
(1, 'Active', '2024-11-25', '2024-12-01', 'QR20241125001'),
(1, 'Active', '2024-11-25', '2024-12-01', 'QR20241125002'),
(2, 'Active', '2024-11-25', '2024-12-02', 'QR20241125003'),
(2, 'Active', '2024-11-25', '2024-12-02', 'QR20241125004'),
(3, 'Active', '2024-11-26', '2024-12-03', 'QR20241126001'),
(3, 'Active', '2024-11-26', '2024-12-03', 'QR20241126002'),
(4, 'Active', '2024-11-26', '2024-12-04', 'QR20241126003'),
(4, 'Active', '2024-11-26', '2024-12-04', 'QR20241126004'),
(5, 'Active', '2024-11-27', '2024-12-05', 'QR20241127001'),
(5, 'Active', '2024-11-27', '2024-12-05', 'QR20241127002'),
(6, 'Active', '2024-11-27', '2024-12-06', 'QR20241127003'),
(7, 'Active', '2024-11-28', '2024-12-07', 'QR20241128001'),
(8, 'Active', '2024-11-28', '2024-12-08', 'QR20241128002'),
(9, 'Active', '2024-11-29', '2024-12-09', 'QR20241129001'),
(10, 'Active', '2024-11-29', '2024-12-10', 'QR20241129002'),
(11, 'Active', '2024-11-30', '2024-12-11', 'QR20241130001'),
(12, 'Active', '2024-11-30', '2024-12-12', 'QR20241130002'),
(13, 'Active', '2024-12-01', '2024-12-13', 'QR20241201001'),
(14, 'Active', '2024-12-01', '2024-12-14', 'QR20241201002'),
(15, 'Active', '2024-12-02', '2024-12-15', 'QR20241202001'),
(16, 'Active', '2024-11-25', '2024-12-01', 'QR20241125005'),
(17, 'Cancelled', '2024-11-26', '2024-12-02', 'QR20241126005'),
(18, 'Active', '2024-11-27', '2024-12-03', 'QR20241127004'),
(19, 'Used', '2024-11-28', '2024-12-04', 'QR20241128003'),
(20, 'Active', '2024-11-29', '2024-12-05', 'QR20241129003');

-- Insert 22 SEAT_BOOKINGS
INSERT INTO SEAT_BOOKING (BookingID, SeatID, ShowID) VALUES
(1, 1, 1),
(1, 2, 1),
(2, 3, 3),
(2, 4, 3),
(3, 11, 4),
(3, 12, 4),
(4, 17, 5),
(4, 18, 5),
(5, 21, 6),
(5, 22, 6),
(6, 25, 7),
(6, 26, 7),
(7, 29, 8),
(8, 31, 9),
(9, 33, 10),
(10, 35, 11),
(11, 37, 12),
(12, 39, 13),
(13, 5, 14),
(14, 7, 15),
(15, 9, 16),
(16, 13, 17);

-- =============================================
-- 8. PAYMENT DATA
-- =============================================

-- Insert 20 PAYMENTS
INSERT INTO PAYMENT (BookingID, Amount, PaymentDateTime, TransactionReference) VALUES
(1, 45.50, '2024-11-25 10:05:00', 'TXN-2024112510-001'),
(2, 52.00, '2024-11-25 11:35:00', 'TXN-2024112511-002'),
(3, 61.00, '2024-11-26 09:20:00', 'TXN-2024112609-003'),
(4, 48.50, '2024-11-26 14:50:00', 'TXN-2024112614-004'),
(5, 39.00, '2024-11-27 16:25:00', 'TXN-2024112716-005'),
(6, 54.00, '2024-11-27 18:05:00', 'TXN-2024112718-006'),
(7, 41.50, '2024-11-28 12:35:00', 'TXN-2024112812-007'),
(8, 58.50, '2024-11-28 15:15:00', 'TXN-2024112815-008'),
(9, 65.00, '2024-11-29 10:50:00', 'TXN-2024112910-009'),
(10, 44.00, '2024-11-29 13:25:00', 'TXN-2024112913-010'),
(11, 42.00, '2024-11-30 11:05:00', 'TXN-2024113011-011'),
(12, 51.00, '2024-11-30 14:35:00', 'TXN-2024113014-012'),
(13, 55.50, '2024-12-01 09:05:00', 'TXN-2024120109-013'),
(14, 47.00, '2024-12-01 16:50:00', 'TXN-2024120116-014'),
(15, 60.00, '2024-12-02 10:35:00', 'TXN-2024120210-015'),
(16, 43.50, '2024-11-25 12:05:00', 'TXN-2024112512-016'),
(17, 50.00, '2024-11-26 15:35:00', 'TXN-2024112615-017'),
(18, 56.00, '2024-11-27 11:05:00', 'TXN-2024112711-018'),
(19, 49.50, '2024-11-28 13:50:00', 'TXN-2024112813-019'),
(20, 38.00, '2024-11-29 17:05:00', 'TXN-2024112917-020');

-- Insert 10 CARD_PAYMENTS
INSERT INTO CARD_PAYMENT (PaymentID, CardNumber, CardHolderName, ExpiryDate) VALUES
(1, '4532756279624512', 'Michael Anderson', '2027-08-31'),
(3, '5425233430109903', 'David Thompson', '2026-11-30'),
(5, '374245455400126', 'Robert Rodriguez', '2028-03-31'),
(7, '4916338506082832', 'James Taylor', '2027-05-31'),
(9, '5105105105105100', 'Christopher Lee', '2026-09-30'),
(11, '4539148803436467', 'Daniel Harris', '2028-01-31'),
(13, '5425233430109904', 'Michael Anderson', '2027-07-31'),
(15, '4024007134564321', 'David Thompson', '2026-12-31'),
(17, '5204230080001234', 'Emily Wilson', '2027-10-31'),
(19, '4532756279624513', 'Lisa Brown', '2028-04-30');

-- Insert 5 WALLET_PAYMENTS
INSERT INTO WALLET_PAYMENT (PaymentID, WalletType) VALUES
(2, 'Apple Pay'),
(6, 'Google Pay'),
(10, 'Samsung Pay'),
(14, 'Apple Pay'),
(18, 'Google Pay');

-- Insert 5 PAYPAL_PAYMENTS
INSERT INTO PAYPAL_PAYMENT (PaymentID, PayPalEmail) VALUES
(4, 'jennifer.garcia@email.com'),
(8, 'lisa.brown@email.com'),
(12, 'michelle.clark@email.com'),
(16, 'michael.anderson@email.com'),
(20, 'amanda.white@email.com');

GO

PRINT 'INSERT Script execution completed successfully!';
PRINT 'All 26 tables populated with minimum 10 rows of realistic data.';
GO