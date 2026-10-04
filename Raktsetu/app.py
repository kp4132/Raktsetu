from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, send_from_directory, session
import database
import socket
import os

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "dev-secret-key")

# Initialize database on startup
database.init_db()

# PWA Service Worker & Manifest Routes
@app.route("/manifest.json")
def manifest():
    return send_from_directory("static", "manifest.json", mimetype="application/manifest+json")

@app.route("/sw.js")
def service_worker():
    response = send_from_directory("static", "sw.js", mimetype="application/javascript")
    response.headers["Service-Worker-Allowed"] = "/"
    return response

# Web Routes
@app.route("/")
def home():
    stats = database.get_stats()
    recent_requests = database.get_recent_requests(limit=4)
    return render_template("index.html", stats=stats, recent_requests=recent_requests)

@app.route("/donors")
def donors():
    blood_group = request.args.get("blood_group", "").strip()
    city = request.args.get("city", "").strip()
    include_compatible = request.args.get("compatible") == "1"
    all_donors = request.args.get("all") == "1"
    
    donors_list = database.search_donors(
        blood_group=blood_group,
        city=city,
        include_compatible=include_compatible,
        availability_only=not all_donors
    )
    
    compatible_groups = []
    if blood_group and include_compatible and blood_group in database.COMPATIBLE_DONORS_FOR_RECIPIENT:
        compatible_groups = database.COMPATIBLE_DONORS_FOR_RECIPIENT[blood_group]

    return render_template(
        "donors.html",
        donors=donors_list,
        selected_bg=blood_group,
        selected_city=city,
        include_compatible=include_compatible,
        all_donors=all_donors,
        compatible_groups=compatible_groups,
        blood_groups=["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    )

@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        name = request.form.get("name", "").strip()
        blood_group = request.form.get("blood_group", "").strip()
        age = request.form.get("age", "").strip()
        gender = request.form.get("gender", "").strip()
        phone = request.form.get("phone", "").strip()
        email = request.form.get("email", "").strip()
        city = request.form.get("city", "").strip()
        state = request.form.get("state", "").strip()
        pincode = request.form.get("pincode", "").strip()
        last_donation_date = request.form.get("last_donation_date", "").strip()

        # Validation
        if not name or not blood_group or not age or not phone or not city:
            flash("Please fill in all required fields (Name, Blood Group, Age, Phone, City).", "danger")
            return redirect(url_for("register"))

        try:
            age_int = int(age)
            if age_int < 18 or age_int > 65:
                flash("Donor age must be between 18 and 65 years.", "warning")
                return redirect(url_for("register"))
        except ValueError:
            flash("Invalid age entered.", "danger")
            return redirect(url_for("register"))

        database.add_donor(
            name=name,
            blood_group=blood_group,
            age=age_int,
            gender=gender,
            phone=phone,
            email=email,
            city=city,
            state=state,
            pincode=pincode,
            last_donation_date=last_donation_date if last_donation_date else "First Time",
            is_available=1
        )

        flash(f"Thank you {name}! You have been registered successfully as a {blood_group} donor. Your support saves lives!", "success")
        return redirect(url_for("donors", blood_group=blood_group, city=city))

    return render_template("register.html", blood_groups=["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"])

@app.route("/requests", methods=["GET", "POST"])
def requests_page():
    if request.method == "POST":
        patient_name = request.form.get("patient_name", "").strip()
        blood_group = request.form.get("blood_group", "").strip()
        units = request.form.get("units", "1").strip()
        hospital = request.form.get("hospital", "").strip()
        city = request.form.get("city", "").strip()
        contact_name = request.form.get("contact_name", "").strip()
        contact_phone = request.form.get("contact_phone", "").strip()
        urgency = request.form.get("urgency", "Urgent").strip()
        note = request.form.get("note", "").strip()

        if not patient_name or not blood_group or not hospital or not city or not contact_phone:
            flash("Please fill in all required fields for the blood request.", "danger")
            return redirect(url_for("requests_page"))

        database.add_request(
            patient_name=patient_name,
            blood_group=blood_group,
            units=int(units) if units.isdigit() else 1,
            hospital=hospital,
            city=city,
            contact_name=contact_name,
            contact_phone=contact_phone,
            urgency=urgency,
            note=note
        )

        flash("Emergency blood request posted successfully! Donors in your city will see your request.", "success")
        return redirect(url_for("requests_page"))

    requests_list = database.get_recent_requests(limit=50)
    return render_template("requests.html", requests=requests_list, blood_groups=["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"])

@app.route("/compatibility")
def compatibility():
    return render_template(
        "compatibility.html",
        recipient_matrix=database.COMPATIBLE_DONORS_FOR_RECIPIENT,
        donor_matrix=database.COMPATIBLE_RECIPIENTS_FOR_DONOR
    )

# REST API Endpoints for Mobile App Consumption
@app.route("/api/donors", methods=["GET", "POST"])
def api_donors():
    if request.method == "POST":
        data = request.get_json() or request.form
        name = data.get("name")
        blood_group = data.get("blood_group")
        age = int(data.get("age", 25))
        gender = data.get("gender", "Male")
        phone = data.get("phone")
        email = data.get("email", "")
        city = data.get("city")
        state = data.get("state", "")
        pincode = data.get("pincode", "")
        last_donation = data.get("last_donation_date", "First Time")
        
        if not name or not blood_group or not phone or not city:
            return jsonify({"status": "error", "message": "Missing required fields"}), 400
            
        donor_id = database.add_donor(name, blood_group, age, gender, phone, email, city, state, pincode, last_donation, 1)
        return jsonify({"status": "success", "donor_id": donor_id, "message": "Donor registered successfully"}), 201

    blood_group = request.args.get("blood_group", "")
    city = request.args.get("city", "")
    include_compatible = request.args.get("compatible") == "1"
    donors_list = database.search_donors(blood_group, city, include_compatible)
    return jsonify(donors_list)

@app.route("/api/requests", methods=["GET", "POST"])
def api_requests():
    if request.method == "POST":
        data = request.get_json() or request.form
        p_name = data.get("patient_name")
        bg = data.get("blood_group")
        units = int(data.get("units", 1))
        hospital = data.get("hospital")
        city = data.get("city")
        c_name = data.get("contact_name")
        c_phone = data.get("contact_phone")
        urgency = data.get("urgency", "Urgent")
        note = data.get("note", "")
        
        if not p_name or not bg or not hospital or not city or not c_phone:
            return jsonify({"status": "error", "message": "Missing required fields"}), 400
            
        req_id = database.add_request(p_name, bg, units, hospital, city, c_name, c_phone, urgency, note)
        return jsonify({"status": "success", "request_id": req_id, "message": "Request posted successfully"}), 201

    requests_list = database.get_recent_requests(limit=50)
    return jsonify(requests_list)

@app.route("/api/stats")
def api_stats():
    return jsonify(database.get_stats())

@app.route("/toggle-status/<int:donor_id>", methods=["POST"])
def toggle_status(donor_id):
    database.toggle_donor_availability(donor_id)
    flash("Donor status updated successfully.", "info")
    return redirect(request.referrer or url_for("donors"))

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

if __name__ == "__main__":
    local_ip = get_local_ip()
    print("=" * 65)
    print("🩸 RAKTSETU - BLOOD DONOR FINDER SERVER STARTED")
    print(f"📱 Local Desktop Access : http://127.0.0.1:5000")
    print(f"📲 Mobile Phone Access  : http://{local_ip}:5000")
    print("👉 Open the Mobile Phone Access URL in your phone's browser,")
    print("   then tap 'Add to Home Screen' or 'Install App' to install!")
    print("=" * 65)
    app.run(host="0.0.0.0", port=5000, debug=True)
