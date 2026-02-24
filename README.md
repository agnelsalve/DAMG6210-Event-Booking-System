# Event & Ticket Booking System
## DAMG6210 - Database Management and Database Design
### Group 5 - Project P5

## 📋 Project Overview
A comprehensive Event & Ticket Booking System database with full CRUD operations, advanced SQL features, and a web-based GUI interface.

## ERD
<img width="2010" height="2709" alt="image" src="https://github.com/user-attachments/assets/aed6fd28-f90a-4065-a48b-7ac8e3f771e1" />


## 🎯 Features Implemented

### Database Components
- **26 Tables** with proper normalization (3NF)
- **5 Stored Procedures** with transaction management and error handling
- **3 User-Defined Functions** for business logic
- **3 Views** for reporting and analytics
- **1 DML Trigger** for audit logging
- **20 Non-Clustered Indexes** for performance optimization
- **Column-Level Encryption** for sensitive data (passwords, card numbers)

### GUI Features
- Simple CRUD interface built with Streamlit
- Dashboard with real-time statistics
- Customer, Event, and Booking management
- Report generation with CSV export
- Direct SQL Server integration

## 🗂️ Project Structure
```
p5/
├── SQL_Scripts/
│   ├── create_tables.sql          # DDL for 26 tables
│   ├── insert_script.sql          # Sample data insertion
│   ├── psm_script.sql             # Stored procedures, functions, views, triggers
│   ├── PSM_Testing_Script.sql     # Comprehensive testing (26 tests)
│   ├── indexes_script.sql         # 20 non-clustered indexes
│   └── encryption_script.sql      # Column encryption setup
├── GUI/
│   └── app.py                     # Streamlit GUI application
├── requirements.txt               # Python dependencies
└── README.md                      # This file
```

## 🚀 Installation & Setup

### Prerequisites
- SQL Server 2019 or later
- Python 3.8+
- ODBC Driver 17 for SQL Server

### Database Setup

1. **Create the database and tables:**
```sql
-- Run in SQL Server Management Studio
sqlcmd -S localhost -i SQL_Scripts/create_tables.sql
```

2. **Insert sample data:**
```sql
sqlcmd -S localhost -i SQL_Scripts/insert_script.sql
```

3. **Create stored procedures, functions, views, and triggers:**
```sql
sqlcmd -S localhost -i SQL_Scripts/psm_script.sql
```

4. **Create indexes:**
```sql
sqlcmd -S localhost -i SQL_Scripts/indexes_script.sql
```

5. **Setup encryption:**
```sql
sqlcmd -S localhost -i SQL_Scripts/encryption_script.sql
```

6. **Run tests (optional):**
```sql
sqlcmd -S localhost -i SQL_Scripts/PSM_Testing_Script.sql
```

### GUI Setup

1. **Install Python dependencies:**
```bash
pip install -r requirements.txt
```

2. **Configure database connection in `GUI/app.py`:**
```python
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=your_server;'
    'DATABASE=EventBookingSystem;'
    'UID=your_username;'
    'PWD=your_password;'
)
```

3. **Run the GUI:**
```bash
cd GUI
streamlit run app.py
```

4. **Access the application:**
```
http://localhost:8501
```

## 📊 Database Schema Highlights

### Core Entities
- **USER**: Base user authentication and profile
- **CUSTOMER**: Customer-specific data with loyalty points
- **EMPLOYEE**: Staff members and their roles
- **EVENT**: Movies, sports events, and exhibitions
- **BOOKING**: Customer bookings with payment tracking
- **VENUE/THEATER**: Physical locations and screens
- **PAYMENT**: Multiple payment methods (Card, Wallet, PayPal)

### Key Relationships
- Users can be Customers, Employees, or Organizers
- Events can be Movies, Sports, or Exhibitions
- Bookings link Customers to Events with seat assignments
- Payments support multiple methods with encryption

## 🔐 Security Features

- **Encrypted Columns**: 
  - USER.PasswordHashEncrypted (AES-256)
  - CARD_PAYMENT.CardNumberEncrypted (AES-256)
- **Audit Logging**: All booking changes tracked in BOOKING_AUDIT
- **Transaction Management**: ACID compliance with rollback support
- **Input Validation**: Constraints and check conditions on all tables

## 📈 Performance Optimizations

- 20 non-clustered indexes on frequently queried columns
- Indexed foreign keys for faster joins
- Composite indexes for complex queries
- Views for pre-computed aggregations

## 🧪 Testing

Run the comprehensive test suite:
```sql
sqlcmd -S localhost -i SQL_Scripts/PSM_Testing_Script.sql
```

**Test Coverage:**
- 14 Stored Procedure tests (including error handling)
- 6 User-Defined Function tests
- 3 View tests
- 3 DML Trigger tests

## 👥 Team Information

**Group 5 - DAMG6210**
- Course: Database Management and Database Design
- Institution: Northeastern University
- Semester: Fall 2025

## 📝 License

This project is part of academic coursework for DAMG6210 at Northeastern University.

## 🎓 Acknowledgments

- Professor and TAs of DAMG6210
- Northeastern University
- Course materials and guidelines

---


**Note**: This is an academic project. Database credentials should be properly secured in production environments.
