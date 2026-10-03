# 🩸 Blood Donor Finder (RaktSetu) - Mini Project

A full-stack, responsive web application designed to connect voluntary blood donors directly with patients and hospitals in emergency need without intermediaries.

Built with **Python (Flask)**, **SQLite3**, **HTML5/CSS3**, and **Bootstrap 5**.

---

## 🌟 Key Features

1. **Smart Blood Donor Search & Filtering**:
   - Filter by Blood Group (`A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-`).
   - Filter by City / Location.
   - **Clinical Compatibility Matcher**: Tick *"Include Compatible Groups"* to automatically include clinically safe donor groups (e.g. searching for $B+$ automatically returns $B+, B-, O+, O-$ donors).
   - Filter by real-time donor availability.

2. **One-Click Direct Contact (Phone & WhatsApp)**:
   - Instant direct `tel:` dialing for mobile phones.
   - Instant WhatsApp messaging button with auto-formatted, pre-filled emergency messages (`https://wa.me/...`).

3. **Emergency Blood Request Feed**:
   - Patients or hospital relatives can post urgent blood requirements.
   - Urgency levels: *Critical (1-2 hrs)*, *Immediate (6-12 hrs)*, *Scheduled (24-48 hrs)*.
   - Live public board for community awareness.

4. **Donor Registration with Health Validation**:
   - Age validation ($18 - 65$ years).
   - 10-digit mobile number validation.
   - Mandatory voluntary donation pledge.
   - Tracking of last donation date.

5. **Interactive Blood Compatibility Matrix**:
   - Visual educational tool showing who can donate red blood cells to whom and who can receive from whom.
   - Highlights Universal Donor ($O^-$) and Universal Recipient ($AB^+$).

6. **SQLite Embedded Database**:
   - Zero-configuration lightweight database pre-seeded with realistic sample donors and hospital requests.

---

## 📂 Project Directory Structure

```text
blood_donor_finder/
│
├── app.py                  # Main Flask backend server & routing
├── database.py             # SQLite database setup, schema, helper queries & seed data
├── requirements.txt        # Python dependencies (Flask)
├── README.md               # Project documentation & viva guide
│
├── templates/              # HTML Jinja2 Templates
│   ├── base.html           # Master layout with navbar, footer, CDN imports
│   ├── index.html          # Homepage with hero search, stats & recent requests
│   ├── donors.html         # Donor search & directory listing
│   ├── register.html       # Donor registration form with client/server validation
│   ├── requests.html       # Emergency blood requests feed & submission modal
│   └── compatibility.html  # Interactive blood compatibility matrix & guide
│
└── static/                 # Static Assets
    ├── css/
    │   └── style.css       # Custom modern red medical theme styling
    └── js/
        └── main.js         # Interactive matrix script & validation logic
```

---

## 🚀 How to Run the Project

### 1. Prerequisites
- Python 3.8 or higher installed on your system.

### 2. Navigate to the project directory
Open your command prompt or terminal in the project folder:
```powershell
cd C:\Users\Kartik\.gemini\antigravity\scratch\blood_donor_finder
```

### 3. Install Requirements
```powershell
pip install -r requirements.txt
```

### 4. Run the Application
```powershell
python app.py
```

### 5. Open in Your Browser
Open your browser and visit:
👉 **[http://127.0.0.1:5000](http://127.0.0.1:5000)**

---

## 🗄️ Database Schema

### Table: `donors`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Primary Key, Auto-increment |
| `name` | TEXT | Donor's full name |
| `blood_group` | TEXT | Blood group ($A+, B+, O-, etc.$) |
| `age` | INTEGER | Age of donor ($18-65$) |
| `gender` | TEXT | Male / Female / Other |
| `phone` | TEXT | Contact mobile number |
| `email` | TEXT | Donor's email address |
| `city` | TEXT | City / Town name |
| `state` | TEXT | State |
| `pincode` | TEXT | Postal Pin Code |
| `last_donation_date` | TEXT | Date of last blood donation |
| `is_available` | INTEGER | 1 = Available, 0 = Unavailable |
| `created_at` | TIMESTAMP | Record creation timestamp |

### Table: `requests`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Primary Key, Auto-increment |
| `patient_name` | TEXT | Patient's full name |
| `blood_group` | TEXT | Needed blood group |
| `units` | INTEGER | Number of blood bags/units required |
| `hospital` | TEXT | Hospital name & branch |
| `city` | TEXT | City where hospital is located |
| `contact_name` | TEXT | Relative or attendant name |
| `contact_phone` | TEXT | Contact phone number |
| `urgency` | TEXT | Critical / Immediate / Within 24h |
| `status` | TEXT | Open / Fulfilled / Closed |
| `note` | TEXT | Additional medical details |
| `created_at` | TIMESTAMP | Request posting timestamp |

---

## 🎯 Viva / Project Presentation Q&A

**Q1: What is the main objective of this project?**  
> *Answer:* To eliminate time delays during medical emergencies by providing a direct, searchable digital bridge between voluntary blood donors and patients/hospitals without middle-agents or red tape.

**Q2: What is the clinical blood compatibility feature?**  
> *Answer:* Often patients cannot find donors with their exact blood type in emergencies. Our system implements clinical red blood cell compatibility rules. For instance, an $A^+$ patient can receive from $A+, A-, O+, O-$. When the user checks "Include Compatible Donors", the query expands to include all medically viable options.

**Q3: Why did you choose SQLite?**  
> *Answer:* SQLite is serverless, zero-configuration, and integrated directly into Python's standard library. It stores the entire database in a single portable file (`blood_finder.db`), making it fast, robust, and ideal for mini projects and demonstrations.

**Q4: How does WhatsApp and phone integration work without paid third-party APIs?**  
> *Answer:* We leverage URI schemes: `tel:<phone>` triggers the native mobile dialer directly, and `https://wa.me/<number>?text=<encoded_msg>` uses WhatsApp's official deep-linking protocol to pre-populate urgent distress messages without requiring paid SMS gateways.
