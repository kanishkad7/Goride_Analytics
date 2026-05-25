# GoRide Analytics Assignment

## Student Information

- Name: Kanishk Akula Damodar
- Matric Number: 80234254
- Course: DATA ENGINEERING
- Assignment: Assignment 2 – GoRide Analytics

---

# Files Included

This submission contains the following files:

1. `queries.sql`
   - Contains all 25 SQL queries required for the assignment.

2. `outputs.md`
   - Contains the outputs/results generated from running the SQL queries in pgAdmin.

3. `notes.md`
   - Contains notes about challenges faced, data quirks handled, and lessons learned during the assignment.

---

# Software Used

- PostgreSQL 18
- pgAdmin 4
- Notepad / VS Code

---

# Database Setup Steps

1. Created a database named: GoRideDB

```sql
GoRideDB
```

2. Opened pgAdmin Query Tool.

3. Executed the provided `seed.sql` file.

4. Verified all tables were created successfully.

5. Generated the ER Diagram to understand table relationships.

---

# Important Data Cleaning Handled

The dataset contained several inconsistencies which were handled in the queries:

- `finished` treated as `completed`
- `noshow` treated as `no_show`
- QuickHop ratings converted from `/10` scale to `/5`
- UUID and text joins handled using explicit casting
- Zone names normalized using trimming and formatting
- Only successful payments counted for revenue calculations

---

# Challenges Faced

Some queries were difficult because the dataset contained inconsistent values and different data types across tables. The hardest part was correctly joining payment data with trip and package delivery tables while ensuring no duplicate or incorrect records were counted.

Another challenge was handling normalization issues such as status values and rating scales between GoRide and QuickHop systems.

---

# Learning Outcome

This assignment helped me improve my understanding of:

- SQL joins
- Aggregation functions
- GROUP BY and HAVING
- Data normalization
- Real-world data cleaning
- PostgreSQL query debugging

---
