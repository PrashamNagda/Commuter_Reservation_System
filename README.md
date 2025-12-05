# Commuter Reservation System (CRS) - Database Project

**DAMG 6210 - Database Management and Database Design (Fall 2025)**  
**Group 3**

## 👥 Team Members

| Name | Github | 
|------|------| 
Prasham Nagda | (https://github.com/Prasham09) |
| Neerajaa Kadam | (https://github.com/kadamneerajaa) |
| Tanya Bansal | (https://github.com/tanya-bansal28) |

---

## 📋 Business Problem

Train passengers face difficulties when booking tickets through fragmented systems that lack real-time seat availability, proper waitlist management, and efficient cancellation handling. The current process involves manual validation of train schedules, booking dates, and passenger information, leading to errors and poor customer experience.

### Key Challenges
- **No Centralized Booking System**: Passengers struggle to check real-time seat availability across different trains and travel dates
- **Manual Validation**: Train number, schedule, and booking date validations are done manually, causing delays and errors
- **Poor Waitlist Management**: No systematic approach to handle waitlisted passengers when confirmed tickets are cancelled
- **Limited Booking Window**: Need to enforce 7-day advance booking policy consistently
- **Duplicate Bookings**: Risk of duplicate passenger records due to lack of email/phone uniqueness checks
- **Age-Based Restrictions**: No automated validation for minor passengers who cannot book independently

---

## 🎯 Project Objectives

1. **Streamline Ticket Booking**: Create a unified system where passengers can search trains, check availability, and book tickets instantly
2. **Automate Validations**: Implement business rules for train schedule validation, booking date restrictions, and passenger eligibility
3. **Manage Capacity**: Track 40 seats per class (Business/Economy) with automatic waitlist handling (5 positions per class)
4. **Handle Cancellations**: Automatically promote first waitlisted passenger when a confirmed booking is cancelled
5. **Enforce Data Integrity**: Ensure unique email/phone per passenger and prevent invalid bookings
6. **Support Age Categories**: Classify passengers as Minor (under 18), Adult, or Senior Citizen (60+) with appropriate restrictions

---

## 🗂️ Database Design Overview

### Data Requirements

**Train Information:**
- Train number, source/destination stations
- Seat capacity (40 Business + 40 Economy)
- Fare structure, operating days

**Train Status:**
- Available booking dates (7-day window)
- Seats available/booked per class
- Waitlist positions

**Passenger Information:**
- Full name (First, Middle, Last)
- Date of birth (determines category)
- Residential address
- Email (unique) and phone (unique)

### Business Rules Implemented

1. Email and phone must be unique
2. Booking allowed only if seats or waitlist available
3. Pre-booking validations: train validity, schedule check, date window, seat class
4. 40 confirmed + 5 waitlist per class; beyond that rejected
5. Cancellation auto-promotes first waitlisted passenger
6. Only 7-day advance booking allowed
7. Two classes: Business and Economy only
8. Minors (under 18) cannot book independently

**Note**: Payment processing NOT implemented. Focus is on reservations and scheduling.

---

## 🗃️ Database Entities

1. **CRS_TRAIN_INFO**: Train details, routes, capacity, fares
2. **CRS_DAY_SCHEDULE**: Days of week with weekend flags
3. **CRS_TRAIN_SCHEDULE**: Train-to-day mapping (M:N)
4. **CRS_PASSENGER**: Customer info with unique constraints
5. **CRS_RESERVATION**: Bookings with status tracking

---

## 📂 Project Structure

```
CRS-Database-Project/
│
├── README.md                           # This file
│
├── SQL_Scripts/
│   ├── 01_CRS_CREATE_USERS.sql        # Run as SYSTEM/ADMIN
│   ├── 02_CRS_CREATE_TABLESl.sql      # Run as CRS_ADMIN
│   ├── 03_CRS_INSERT_SAMPLE_DATA.sql  # Run as CRS_ADMIN
│   ├── 04_CRS_CREATE_VALIDATION_PACKAGE.sql  # Run as CRS_ADMIN
│   ├── 05_CRS_CREATE_BUSINESS_LOGIC_PACKAGE.sql  # Run as CRS_ADMIN
│   ├── 06_CRS_GRANT_PERMISSIONS.sql   # Run as CRS_ADMIN
│   ├── 07_CRS_CREATE_20_PASSENGERS.sql  # Run as CRS_ADMIN
│   ├── 08_CRS_TEST_CASES.sql          # Run as CRS_OPERATOR
│   ├── 09_CRS_CLEANUP_SCRIPT.sql      # Run as CRS_ADMIN
│   ├── 10_CRS_CREATE_VIEWS.sql        # Run as CRS_ADMIN
│   └── 11_CRS_VIEW_OPERATOR.sql       # Run as CRS_OPERATOR
│
└── Documentation/
    ├── CRS_Conceptual_Model.png       # Conceptual Model
    └── CRS_ER_Diagram.pdf             # Entity Relationship Diagram
```

---

## 🚀 Installation & Setup Instructions

### **Step 1: Create Users**
**Run as:** SYSTEM/ADMIN
```sql
@01_CRS_CREATE_USERS.sql
```
- Creates CRS_ADMIN (schema owner) and CRS_OPERATOR (app user)

### **Step 2: Create Tables**
**Run as:** CRS_ADMIN
```sql
@02_CRS_CREATE_TABLESl.sql
```
- Creates 5 tables, 5 sequences, all constraints

### **Step 3: Load Sample Data**
**Run as:** CRS_ADMIN
```sql
@03_CRS_INSERT_SAMPLE_DATA.sql
```
- Inserts 7 days, 6 trains, 6 passengers, train schedules

### **Step 4: Create Validation Package**
**Run as:** CRS_ADMIN
```sql
@04_CRS_CREATE_VALIDATION_PACKAGE.sql
```
- Creates helper functions for validations

### **Step 5: Create Business Logic**
**Run as:** CRS_ADMIN
```sql
@05_CRS_CREATE_BUSINESS_LOGIC_PACKAGE.sql
```
- Core procedures: register_passenger, book_ticket, cancel_ticket

### **Step 6: Grant Permissions**
**Run as:** CRS_ADMIN
```sql
@06_CRS_GRANT_PERMISSIONS.sql
```
- Grants execute/select privileges to CRS_OPERATOR

### **Step 7: Add Test Passengers (Optional)**
**Run as:** CRS_ADMIN
```sql
@07_CRS_CREATE_20_PASSENGERS.sql
```
- Adds 20 more passengers for testing

### **Step 8: Run Tests**
**Run as:** CRS_OPERATOR
```sql
@08_CRS_TEST_CASES.sql
```
- 14+ test cases validating all business rules

### **Step 9: Cleanup (Optional)**
**Run as:** CRS_ADMIN
```sql
@09_CRS_CLEANUP_SCRIPT.sql
```
- Removes test data, resets sequences

### **Step 10: Create Views**
**Run as:** CRS_ADMIN
```sql
@10_CRS_CREATE_VIEWS.sql
```
- Creates 4 reporting views

### **Step 11: Query Views**
**Run as:** CRS_OPERATOR
```sql
@11_CRS_VIEW_OPERATOR.sql
```
- Sample queries for views

---
