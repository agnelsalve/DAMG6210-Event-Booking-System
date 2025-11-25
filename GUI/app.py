"""
=============================================
Event & Ticket Booking System - Streamlit GUI
Group 5 - DAMG6210
Simple CRUD Interface for SQL Server Database
=============================================
"""

import streamlit as st
import pyodbc
import pandas as pd
from datetime import datetime

# Page configuration
st.set_page_config(
    page_title="Event Booking System",
    page_icon="🎫",
    layout="wide"
)

# Database connection configuration
@st.cache_resource
def get_connection():
    """Create database connection"""
    try:
        conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            'SERVER=localhost,1433;'  # Change to your server
            'DATABASE=EventBookingSystem;'
            'UID=sa;'  # Change to your username
            'PWD=Aggysalve@2627;'  # Change to your password
            'TrustServerCertificate=yes;'
        )
        return conn
    except Exception as e:
        st.error(f"Database connection failed: {e}")
        return None

def execute_query(query, params=None, fetch=True):
    """Execute SQL query"""
    conn = get_connection()
    if conn is None:
        return None
    
    try:
        cursor = conn.cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        if fetch:
            columns = [column[0] for column in cursor.description]
            results = cursor.fetchall()
            return pd.DataFrame.from_records(results, columns=columns)
        else:
            conn.commit()
            return True
    except Exception as e:
        st.error(f"Query error: {e}")
        return None
    finally:
        cursor.close()

# =============================================
# SIDEBAR NAVIGATION
# =============================================

st.sidebar.title("🎫 Event Booking System")
st.sidebar.markdown("---")

menu = st.sidebar.radio(
    "Navigation",
    ["Dashboard", "Customers", "Events", "Bookings", "Reports"]
)

st.sidebar.markdown("---")
st.sidebar.info("Group 5 - DAMG6210\nNortheastern University")

# =============================================
# DASHBOARD PAGE
# =============================================

if menu == "Dashboard":
    st.title("📊 Dashboard")
    
    # Get statistics
    stats_query = """
    SELECT 
        (SELECT COUNT(*) FROM CUSTOMER) AS TotalCustomers,
        (SELECT COUNT(*) FROM EVENT WHERE Status = 'Scheduled') AS UpcomingEvents,
        (SELECT COUNT(*) FROM BOOKING WHERE BookingStatus = 'Confirmed') AS ActiveBookings,
        (SELECT ISNULL(SUM(TotalAmount), 0) FROM BOOKING WHERE BookingStatus IN ('Confirmed', 'Completed')) AS TotalRevenue
    """
    
    stats = execute_query(stats_query)
    
    if stats is not None and not stats.empty:
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("Total Customers", int(stats['TotalCustomers'].iloc[0]))
        
        with col2:
            st.metric("Upcoming Events", int(stats['UpcomingEvents'].iloc[0]))
        
        with col3:
            st.metric("Active Bookings", int(stats['ActiveBookings'].iloc[0]))
        
        with col4:
            revenue = float(stats['TotalRevenue'].iloc[0])
            st.metric("Total Revenue", f"${revenue:,.2f}")
    
    st.markdown("---")
    
    # Recent bookings
    st.subheader("📋 Recent Bookings")
    recent_bookings_query = """
    SELECT TOP 10
        B.BookingID,
        U.FirstName + ' ' + U.LastName AS CustomerName,
        E.Title AS EventName,
        B.BookingDateTime,
        B.TotalAmount,
        B.BookingStatus
    FROM BOOKING B
    INNER JOIN CUSTOMER C ON B.CustomerID = C.CustomerID
    INNER JOIN [USER] U ON C.UserID = U.UserID
    INNER JOIN EVENT E ON B.EventID = E.EventID
    ORDER BY B.BookingDateTime DESC
    """
    
    recent_bookings = execute_query(recent_bookings_query)
    if recent_bookings is not None and not recent_bookings.empty:
        st.dataframe(recent_bookings, use_container_width=True)
    else:
        st.info("No bookings found")

# =============================================
# CUSTOMERS PAGE
# =============================================

elif menu == "Customers":
    st.title("👥 Customer Management")
    
    tab1, tab2, tab3 = st.tabs(["View Customers", "Add Customer", "Update/Delete"])
    
    # TAB 1: View Customers
    with tab1:
        st.subheader("All Customers")
        
        customers_query = """
        SELECT 
            C.CustomerID,
            U.FirstName,
            U.LastName,
            U.Email,
            U.PhoneNumber,
            C.LoyaltyPoints
        FROM CUSTOMER C
        INNER JOIN [USER] U ON C.UserID = U.UserID
        ORDER BY C.CustomerID
        """
        
        customers = execute_query(customers_query)
        
        if customers is not None and not customers.empty:
            st.dataframe(customers, use_container_width=True)
            st.info(f"Total Customers: {len(customers)}")
        else:
            st.warning("No customers found")
    
    # TAB 2: Add Customer
    with tab2:
        st.subheader("Add New Customer")
        
        with st.form("add_customer_form"):
            col1, col2 = st.columns(2)
            
            with col1:
                first_name = st.text_input("First Name*")
                last_name = st.text_input("Last Name*")
                email = st.text_input("Email*")
            
            with col2:
                phone_number = st.text_input("Phone Number")
                loyalty_points = st.number_input("Loyalty Points", min_value=0, value=0)
            
            submit_button = st.form_submit_button("Add Customer")
            
            if submit_button:
                if first_name and last_name and email:
                    try:
                        # Insert into USER table
                        user_query = """
                        INSERT INTO [USER] (FirstName, LastName, Email, PhoneNumber, PasswordHash, Role, CustomerID, EmployeeID, OrganizerID)
                        OUTPUT INSERTED.UserID
                        VALUES (?, ?, ?, ?, 'TEMP_HASH', 'Customer', NULL, NULL, NULL)
                        """
                        
                        conn = get_connection()
                        cursor = conn.cursor()
                        cursor.execute(user_query, (first_name, last_name, email, phone_number))
                        user_id = cursor.fetchone()[0]
                        
                        # Insert into CUSTOMER table
                        customer_query = """
                        INSERT INTO CUSTOMER (UserID, LoyaltyPoints)
                        OUTPUT INSERTED.CustomerID
                        VALUES (?, ?)
                        """
                        cursor.execute(customer_query, (user_id, loyalty_points))
                        customer_id = cursor.fetchone()[0]
                        
                        # Update USER with CustomerID
                        update_query = "UPDATE [USER] SET CustomerID = ? WHERE UserID = ?"
                        cursor.execute(update_query, (customer_id, user_id))
                        
                        conn.commit()
                        cursor.close()
                        
                        st.success(f"✅ Customer added successfully! Customer ID: {customer_id}")
                        st.balloons()
                    except Exception as e:
                        st.error(f"Error adding customer: {e}")
                else:
                    st.error("Please fill in all required fields (marked with *)")
    
    # TAB 3: Update/Delete Customer
    with tab3:
        st.subheader("Update or Delete Customer")
        
        customers = execute_query(customers_query)
        
        if customers is not None and not customers.empty:
            customer_options = {f"{row['CustomerID']} - {row['FirstName']} {row['LastName']}": row['CustomerID'] 
                              for _, row in customers.iterrows()}
            
            selected_customer = st.selectbox("Select Customer", list(customer_options.keys()))
            customer_id = customer_options[selected_customer]
            
            # Get customer details
            customer_detail_query = """
            SELECT 
                C.CustomerID,
                C.UserID,
                U.FirstName,
                U.LastName,
                U.Email,
                U.PhoneNumber,
                C.LoyaltyPoints
            FROM CUSTOMER C
            INNER JOIN [USER] U ON C.UserID = U.UserID
            WHERE C.CustomerID = ?
            """
            
            customer_detail = execute_query(customer_detail_query, (customer_id,))
            
            if customer_detail is not None and not customer_detail.empty:
                customer = customer_detail.iloc[0]
                
                col1, col2 = st.columns(2)
                
                with col1:
                    st.markdown("### Update Customer")
                    with st.form("update_customer_form"):
                        new_first_name = st.text_input("First Name", value=customer['FirstName'])
                        new_last_name = st.text_input("Last Name", value=customer['LastName'])
                        new_email = st.text_input("Email", value=customer['Email'])
                        new_phone = st.text_input("Phone Number", value=customer['PhoneNumber'] if pd.notna(customer['PhoneNumber']) else "")
                        new_loyalty = st.number_input("Loyalty Points", min_value=0, value=int(customer['LoyaltyPoints']))
                        
                        update_button = st.form_submit_button("Update Customer")
                        
                        if update_button:
                            try:
                                conn = get_connection()
                                cursor = conn.cursor()
                                
                                # Update USER
                                update_user_query = """
                                UPDATE [USER] 
                                SET FirstName = ?, LastName = ?, Email = ?, PhoneNumber = ?
                                WHERE UserID = ?
                                """
                                cursor.execute(update_user_query, 
                                             (new_first_name, new_last_name, new_email, new_phone, customer['UserID']))
                                
                                # Update CUSTOMER
                                update_customer_query = """
                                UPDATE CUSTOMER 
                                SET LoyaltyPoints = ?
                                WHERE CustomerID = ?
                                """
                                cursor.execute(update_customer_query, (new_loyalty, customer_id))
                                
                                conn.commit()
                                cursor.close()
                                
                                st.success("✅ Customer updated successfully!")
                                st.rerun()
                            except Exception as e:
                                st.error(f"Error updating customer: {e}")
                
                with col2:
                    st.markdown("### Delete Customer")
                    st.warning("⚠️ This action cannot be undone!")
                    
                    if st.button("Delete Customer", type="primary"):
                        try:
                            delete_query = "DELETE FROM [USER] WHERE UserID = ?"
                            execute_query(delete_query, (customer['UserID'],), fetch=False)
                            
                            st.success("✅ Customer deleted successfully!")
                            st.rerun()
                        except Exception as e:
                            st.error(f"Error deleting customer: {e}")

# =============================================
# EVENTS PAGE
# =============================================

elif menu == "Events":
    st.title("📅 Event Management")
    
    tab1, tab2, tab3 = st.tabs(["View Events", "Add Event", "Update/Delete"])
    
    # TAB 1: View Events
    with tab1:
        st.subheader("All Events")
        
        # Filter options
        col1, col2 = st.columns(2)
        with col1:
            event_type_filter = st.selectbox("Filter by Type", ["All", "Movie", "Sport", "Exhibition"])
        with col2:
            status_filter = st.selectbox("Filter by Status", ["All", "Scheduled", "Ongoing", "Completed", "Cancelled"])
        
        events_query = """
        SELECT 
            E.EventID,
            E.Title,
            E.EventType,
            E.Status,
            E.StartDateTime,
            E.EndDateTime,
            E.Duration,
            O.CompanyName AS Organizer
        FROM EVENT E
        LEFT JOIN ORGANIZER O ON E.OrganizerID = O.OrganizerID
        WHERE 1=1
        """
        
        if event_type_filter != "All":
            events_query += f" AND E.EventType = '{event_type_filter}'"
        if status_filter != "All":
            events_query += f" AND E.Status = '{status_filter}'"
        
        events_query += " ORDER BY E.StartDateTime DESC"
        
        events = execute_query(events_query)
        
        if events is not None and not events.empty:
            st.dataframe(events, use_container_width=True)
            st.info(f"Total Events: {len(events)}")
        else:
            st.warning("No events found")
    
    # TAB 2: Add Event
    with tab2:
        st.subheader("Add New Event")
        
        # Get organizers for dropdown
        organizers_query = "SELECT OrganizerID, CompanyName FROM ORGANIZER ORDER BY CompanyName"
        organizers = execute_query(organizers_query)
        
        with st.form("add_event_form"):
            col1, col2 = st.columns(2)
            
            with col1:
                title = st.text_input("Event Title*")
                event_type = st.selectbox("Event Type*", ["Movie", "Sport", "Exhibition"])
                description = st.text_area("Description")
                language = st.text_input("Language", value="English")
            
            with col2:
                status = st.selectbox("Status", ["Scheduled", "Ongoing", "Completed", "Cancelled"])
                start_datetime = st.datetime_input("Start Date & Time*")
                end_datetime = st.datetime_input("End Date & Time*")
                duration = st.number_input("Duration (minutes)", min_value=0, value=120)
                
                if organizers is not None and not organizers.empty:
                    organizer_options = {row['CompanyName']: row['OrganizerID'] 
                                       for _, row in organizers.iterrows()}
                    organizer_options["None"] = None
                    selected_organizer = st.selectbox("Organizer", list(organizer_options.keys()))
                    organizer_id = organizer_options[selected_organizer]
                else:
                    organizer_id = None
            
            submit_button = st.form_submit_button("Add Event")
            
            if submit_button:
                if title and event_type and start_datetime and end_datetime:
                    try:
                        event_query = """
                        INSERT INTO EVENT (OrganizerID, Title, Description, EventType, Status, Language, StartDateTime, EndDateTime, Duration)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """
                        
                        execute_query(event_query, 
                                    (organizer_id, title, description, event_type, status, language, 
                                     start_datetime, end_datetime, duration), 
                                    fetch=False)
                        
                        st.success("✅ Event added successfully!")
                        st.balloons()
                    except Exception as e:
                        st.error(f"Error adding event: {e}")
                else:
                    st.error("Please fill in all required fields (marked with *)")
    
    # TAB 3: Update/Delete Event
    with tab3:
        st.subheader("Update or Delete Event")
        
        events_query = "SELECT EventID, Title FROM EVENT ORDER BY StartDateTime DESC"
        events = execute_query(events_query)
        
        if events is not None and not events.empty:
            event_options = {f"{row['EventID']} - {row['Title']}": row['EventID'] 
                           for _, row in events.iterrows()}
            
            selected_event = st.selectbox("Select Event", list(event_options.keys()))
            event_id = event_options[selected_event]
            
            # Get event details
            event_detail_query = "SELECT * FROM EVENT WHERE EventID = ?"
            event_detail = execute_query(event_detail_query, (event_id,))
            
            if event_detail is not None and not event_detail.empty:
                event = event_detail.iloc[0]
                
                col1, col2 = st.columns(2)
                
                with col1:
                    st.markdown("### Update Event")
                    with st.form("update_event_form"):
                        new_title = st.text_input("Title", value=event['Title'])
                        new_status = st.selectbox("Status", 
                                                 ["Scheduled", "Ongoing", "Completed", "Cancelled"],
                                                 index=["Scheduled", "Ongoing", "Completed", "Cancelled"].index(event['Status']))
                        
                        update_button = st.form_submit_button("Update Event")
                        
                        if update_button:
                            try:
                                update_query = """
                                UPDATE EVENT 
                                SET Title = ?, Status = ?
                                WHERE EventID = ?
                                """
                                execute_query(update_query, (new_title, new_status, event_id), fetch=False)
                                
                                st.success("✅ Event updated successfully!")
                                st.rerun()
                            except Exception as e:
                                st.error(f"Error updating event: {e}")
                
                with col2:
                    st.markdown("### Delete Event")
                    st.warning("⚠️ This will also delete related bookings!")
                    
                    if st.button("Delete Event", type="primary"):
                        try:
                            delete_query = "DELETE FROM EVENT WHERE EventID = ?"
                            execute_query(delete_query, (event_id,), fetch=False)
                            
                            st.success("✅ Event deleted successfully!")
                            st.rerun()
                        except Exception as e:
                            st.error(f"Error deleting event: {e}")

# =============================================
# BOOKINGS PAGE
# =============================================

elif menu == "Bookings":
    st.title("🎫 Booking Management")
    
    tab1, tab2 = st.tabs(["View Bookings", "Update/Delete"])
    
    # TAB 1: View Bookings
    with tab1:
        st.subheader("All Bookings")
        
        # Filter
        status_filter = st.selectbox("Filter by Status", ["All", "Confirmed", "Cancelled", "Completed"])
        
        bookings_query = """
        SELECT 
            B.BookingID,
            U.FirstName + ' ' + U.LastName AS CustomerName,
            E.Title AS EventName,
            B.BookingDateTime,
            B.TotalAmount,
            B.BookingStatus
        FROM BOOKING B
        INNER JOIN CUSTOMER C ON B.CustomerID = C.CustomerID
        INNER JOIN [USER] U ON C.UserID = U.UserID
        INNER JOIN EVENT E ON B.EventID = E.EventID
        WHERE 1=1
        """
        
        if status_filter != "All":
            bookings_query += f" AND B.BookingStatus = '{status_filter}'"
        
        bookings_query += " ORDER BY B.BookingDateTime DESC"
        
        bookings = execute_query(bookings_query)
        
        if bookings is not None and not bookings.empty:
            st.dataframe(bookings, use_container_width=True)
            st.info(f"Total Bookings: {len(bookings)}")
        else:
            st.warning("No bookings found")
    
    # TAB 2: Update/Delete Booking
    with tab2:
        st.subheader("Update or Delete Booking")
        
        bookings = execute_query(bookings_query)
        
        if bookings is not None and not bookings.empty:
            booking_options = {f"{row['BookingID']} - {row['CustomerName']} - {row['EventName']}": row['BookingID'] 
                             for _, row in bookings.iterrows()}
            
            selected_booking = st.selectbox("Select Booking", list(booking_options.keys()))
            booking_id = booking_options[selected_booking]
            
            # Get booking details
            booking_detail_query = "SELECT * FROM BOOKING WHERE BookingID = ?"
            booking_detail = execute_query(booking_detail_query, (booking_id,))
            
            if booking_detail is not None and not booking_detail.empty:
                booking = booking_detail.iloc[0]
                
                col1, col2 = st.columns(2)
                
                with col1:
                    st.markdown("### Update Booking")
                    with st.form("update_booking_form"):
                        new_status = st.selectbox("Status", 
                                                 ["Confirmed", "Cancelled", "Completed"],
                                                 index=["Confirmed", "Cancelled", "Completed"].index(booking['BookingStatus']))
                        new_amount = st.number_input("Total Amount", min_value=0.0, value=float(booking['TotalAmount']), step=0.01)
                        
                        update_button = st.form_submit_button("Update Booking")
                        
                        if update_button:
                            try:
                                update_query = """
                                UPDATE BOOKING 
                                SET BookingStatus = ?, TotalAmount = ?
                                WHERE BookingID = ?
                                """
                                execute_query(update_query, (new_status, new_amount, booking_id), fetch=False)
                                
                                st.success("✅ Booking updated successfully!")
                                st.rerun()
                            except Exception as e:
                                st.error(f"Error updating booking: {e}")
                
                with col2:
                    st.markdown("### Delete Booking")
                    st.warning("⚠️ This action cannot be undone!")
                    
                    if st.button("Delete Booking", type="primary"):
                        try:
                            delete_query = "DELETE FROM BOOKING WHERE BookingID = ?"
                            execute_query(delete_query, (booking_id,), fetch=False)
                            
                            st.success("✅ Booking deleted successfully!")
                            st.rerun()
                        except Exception as e:
                            st.error(f"Error deleting booking: {e}")

# =============================================
# REPORTS PAGE
# =============================================

elif menu == "Reports":
    st.title("📈 Reports")
    
    # Customer Summary Report
    st.subheader("Customer Summary Report")
    customer_report_query = """
    SELECT * FROM vw_CustomerBookingSummary
    ORDER BY TotalSpent DESC
    """
    customer_report = execute_query(customer_report_query)
    
    if customer_report is not None and not customer_report.empty:
        st.dataframe(customer_report, use_container_width=True)
        
        # Download button
        csv = customer_report.to_csv(index=False)
        st.download_button(
            label="Download Customer Report",
            data=csv,
            file_name="customer_report.csv",
            mime="text/csv"
        )
    
    st.markdown("---")
    
    # Event Performance Report
    st.subheader("Event Performance Report")
    event_report_query = """
    SELECT * FROM vw_EventPerformanceDashboard
    ORDER BY TotalRevenue DESC
    """
    event_report = execute_query(event_report_query)
    
    if event_report is not None and not event_report.empty:
        st.dataframe(event_report, use_container_width=True)
        
        # Download button
        csv = event_report.to_csv(index=False)
        st.download_button(
            label="Download Event Report",
            data=csv,
            file_name="event_report.csv",
            mime="text/csv"
        )
    
    st.markdown("---")
    
    # Theater Utilization Report
    st.subheader("Theater Screen Utilization Report")
    theater_report_query = """
    SELECT * FROM vw_TheaterScreenUtilization
    ORDER BY UtilizationRate DESC
    """
    theater_report = execute_query(theater_report_query)
    
    if theater_report is not None and not theater_report.empty:
        st.dataframe(theater_report, use_container_width=True)
        
        # Download button
        csv = theater_report.to_csv(index=False)
        st.download_button(
            label="Download Theater Report",
            data=csv,
            file_name="theater_report.csv",
            mime="text/csv"
        )