import sqlite3
import os
from datetime import datetime, timedelta

DB_PATH = os.path.join(os.path.dirname(__file__), "blood_finder.db")

# Compatibility mapping: Recipient -> List of compatible donor blood groups
COMPATIBLE_DONORS_FOR_RECIPIENT = {
    "O-": ["O-"],
    "O+": ["O+", "O-"],
    "A-": ["A-", "O-"],
    "A+": ["A+", "A-", "O+", "O-"],
    "B-": ["B-", "O-"],
    "B+": ["B+", "B-", "O+", "O-"],
    "AB-": ["AB-", "A-", "B-", "O-"],
    "AB+": ["AB+", "AB-", "A+", "A-", "B+", "B-", "O+", "O-"]
}

# Compatibility mapping: Donor -> List of compatible recipient blood groups
COMPATIBLE_RECIPIENTS_FOR_DONOR = {
    "O-": ["O-", "O+", "A-", "A+", "B-", "B+", "AB-", "AB+"],
    "O+": ["O+", "A+", "B+", "AB+"],
    "A-": ["A-", "A+", "AB-", "AB+"],
    "A+": ["A+", "AB+"],
    "B-": ["B-", "B+", "AB-", "AB+"],
    "B+": ["B+", "AB+"],
    "AB-": ["AB-", "AB+"],
    "AB+": ["AB+"]
}

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    cursor = conn.cursor()

    # Donors Table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS donors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            blood_group TEXT NOT NULL,
            age INTEGER NOT NULL,
            gender TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            city TEXT NOT NULL,
            state TEXT,
            pincode TEXT,
            last_donation_date TEXT,
            is_available INTEGER DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # Emergency Requests Table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS requests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_name TEXT NOT NULL,
            blood_group TEXT NOT NULL,
            units INTEGER DEFAULT 1,
            hospital TEXT NOT NULL,
            city TEXT NOT NULL,
            contact_name TEXT NOT NULL,
            contact_phone TEXT NOT NULL,
            urgency TEXT DEFAULT 'Urgent',
            status TEXT DEFAULT 'Open',
            note TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()

    # Populate sample data if table is empty
    cursor.execute("SELECT COUNT(*) FROM donors")
    if cursor.fetchone()[0] == 0:
        seed_sample_data(conn)

    conn.close()

def seed_sample_data(conn):
    cursor = conn.cursor()
    sample_donors = [
        ("Rahul Sharma", "O+", 26, "Male", "9876543210", "rahul.sharma@example.com", "Mumbai", "Maharashtra", "400001", "2025-11-15", 1),
        ("Priya Patel", "A+", 24, "Female", "9876543211", "priya.patel@example.com", "Ahmedabad", "Gujarat", "380001", "2026-01-10", 1),
        ("Amit Verma", "B+", 29, "Male", "9876543212", "amit.v@example.com", "Delhi", "Delhi", "110001", "2025-09-20", 1),
        ("Sneha Kulkarni", "O-", 27, "Female", "9876543213", "sneha.k@example.com", "Pune", "Maharashtra", "411001", "2026-02-01", 1),
        ("Vikram Singh", "AB+", 32, "Male", "9876543214", "vikram.s@example.com", "Jaipur", "Rajasthan", "302001", "2025-08-14", 1),
        ("Ananya Das", "A-", 23, "Female", "9876543215", "ananya.das@example.com", "Kolkata", "West Bengal", "700001", "2026-01-25", 1),
        ("Karthik Nair", "B-", 31, "Male", "9876543216", "karthik.n@example.com", "Bengaluru", "Karnataka", "560001", "2025-12-05", 1),
        ("Divya Reddy", "AB-", 28, "Female", "9876543217", "divya.reddy@example.com", "Hyderabad", "Telangana", "500001", "2026-02-14", 1),
        ("Arjun Mehta", "O+", 25, "Male", "9876543218", "arjun.m@example.com", "Pune", "Maharashtra", "411038", "2025-10-18", 1),
        ("Pooja Joshi", "B+", 30, "Female", "9876543219", "pooja.j@example.com", "Mumbai", "Maharashtra", "400050", "2026-03-01", 1),
        ("Rohan Gupta", "O-", 34, "Male", "9876543220", "rohan.g@example.com", "Delhi", "Delhi", "110016", "2025-07-22", 1),
        ("Meera Menon", "A+", 22, "Female", "9876543221", "meera.m@example.com", "Bengaluru", "Karnataka", "560034", "2026-02-28", 1),
    ]

    cursor.executemany("""
        INSERT INTO donors (name, blood_group, age, gender, phone, email, city, state, pincode, last_donation_date, is_available)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, sample_donors)

    sample_requests = [
        ("Suresh Rao", "B+", 2, "City Care Hospital", "Mumbai", "Kavita Rao", "9811223344", "Critical", "Open", "Urgent requirement for heart surgery tomorrow morning."),
        ("Ramesh Chandra", "O-", 1, "Apollo Hospital", "Delhi", "Sunita Chandra", "9822334455", "Immediate", "Open", "Rare blood group needed for accident emergency ICU ward."),
        ("Aditi Saxena", "A+", 3, "Fortis Hospital", "Bengaluru", "Naveen Saxena", "9833445566", "Within 24 Hours", "Open", "Required for elective orthopedic surgery."),
    ]

    cursor.executemany("""
        INSERT INTO requests (patient_name, blood_group, units, hospital, city, contact_name, contact_phone, urgency, status, note)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, sample_requests)

    conn.commit()

# Query helper functions
def search_donors(blood_group=None, city=None, include_compatible=False, availability_only=True):
    conn = get_db()
    cursor = conn.cursor()

    query = "SELECT * FROM donors WHERE 1=1"
    params = []

    if blood_group and blood_group.strip():
        bg = blood_group.strip().upper()
        if include_compatible and bg in COMPATIBLE_DONORS_FOR_RECIPIENT:
            compatible_groups = COMPATIBLE_DONORS_FOR_RECIPIENT[bg]
            placeholders = ",".join("?" for _ in compatible_groups)
            query += f" AND blood_group IN ({placeholders})"
            params.extend(compatible_groups)
        else:
            query += " AND blood_group = ?"
            params.append(bg)

    if city and city.strip():
        query += " AND LOWER(city) LIKE ?"
        params.append(f"%{city.strip().lower()}%")

    if availability_only:
        query += " AND is_available = 1"

    query += " ORDER BY is_available DESC, created_at DESC"

    cursor.execute(query, params)
    donors = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return donors

def add_donor(name, blood_group, age, gender, phone, email, city, state, pincode, last_donation_date, is_available=1):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO donors (name, blood_group, age, gender, phone, email, city, state, pincode, last_donation_date, is_available)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (name, blood_group, age, gender, phone, email, city, state, pincode, last_donation_date, is_available))
    donor_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return donor_id

def add_request(patient_name, blood_group, units, hospital, city, contact_name, contact_phone, urgency, note):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO requests (patient_name, blood_group, units, hospital, city, contact_name, contact_phone, urgency, status, note)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Open', ?)
    """, (patient_name, blood_group, units, hospital, city, contact_name, contact_phone, urgency, note))
    req_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return req_id

def get_recent_requests(limit=10):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM requests WHERE status = 'Open' ORDER BY CASE urgency WHEN 'Critical' THEN 1 WHEN 'Immediate' THEN 2 ELSE 3 END, created_at DESC LIMIT ?", (limit,))
    requests = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return requests

def get_stats():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM donors")
    total_donors = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM donors WHERE is_available = 1")
    available_donors = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM requests WHERE status = 'Open'")
    open_requests = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM requests WHERE status = 'completed'")
    lives_helped = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(DISTINCT city) FROM donors")
    cities_covered = cursor.fetchone()[0]

    conn.close()
    return {
    "total_donors": total_donors,
    "available_donors": available_donors,
    "open_requests": open_requests,
    "lives_helped": lives_helped,
    "cities_covered": cities_covered
}

def toggle_donor_availability(donor_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("UPDATE donors SET is_available = CASE WHEN is_available = 1 THEN 0 ELSE 1 END WHERE id = ?", (donor_id,))
    conn.commit()
    conn.close()
