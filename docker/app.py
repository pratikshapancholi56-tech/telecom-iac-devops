from flask import Flask, render_template, request, jsonify, session
from datetime import datetime
import secrets
import re

app = Flask(__name__)
app.secret_key = secrets.token_hex(16)

# Service Types
SERVICE_TYPES = {
    "mobile": "Mobile Recharge",
    "dth": "DTH Recharge",
    "broadband": "Broadband/Fiber",
    "postpaid": "Postpaid Bill",
    "electricity": "Electricity Bill",
    "gas": "Gas Bill",
    "water": "Water Bill",
    "landline": "Landline Bill"
}

# Mobile Recharge Operators and Plans
MOBILE_OPERATORS = {
    "airtel": {
        "name": "Airtel",
        "plans": [
            {"id": "air_1", "amount": 199, "validity": "28 days", "data": "2GB/day", "calls": "Unlimited"},
            {"id": "air_2", "amount": 299, "validity": "28 days", "data": "1.5GB/day", "calls": "Unlimited"},
            {"id": "air_3", "amount": 479, "validity": "56 days", "data": "1.5GB/day", "calls": "Unlimited"},
            {"id": "air_4", "amount": 719, "validity": "84 days", "data": "1.5GB/day", "calls": "Unlimited"},
            {"id": "air_5", "amount": 2999, "validity": "365 days", "data": "2GB/day", "calls": "Unlimited"}
        ]
    },
    "jio": {
        "name": "Jio",
        "plans": [
            {"id": "jio_1", "amount": 209, "validity": "28 days", "data": "1GB/day", "calls": "Unlimited"},
            {"id": "jio_2", "amount": 239, "validity": "28 days", "data": "2GB/day", "calls": "Unlimited"},
            {"id": "jio_3", "amount": 533, "validity": "56 days", "data": "2GB/day", "calls": "Unlimited"},
            {"id": "jio_4", "amount": 799, "validity": "84 days", "data": "2GB/day", "calls": "Unlimited"},
            {"id": "jio_5", "amount": 2999, "validity": "365 days", "data": "2.5GB/day", "calls": "Unlimited"}
        ]
    },
    "vi": {
        "name": "Vi (Vodafone Idea)",
        "plans": [
            {"id": "vi_1", "amount": 179, "validity": "28 days", "data": "1GB/day", "calls": "Unlimited"},
            {"id": "vi_2", "amount": 299, "validity": "28 days", "data": "1.5GB/day", "calls": "Unlimited"},
            {"id": "vi_3", "amount": 479, "validity": "56 days", "data": "1.5GB/day", "calls": "Unlimited"},
            {"id": "vi_4", "amount": 719, "validity": "84 days", "data": "1.5GB/day", "calls": "Unlimited"},
            {"id": "vi_5", "amount": 2899, "validity": "365 days", "data": "1.5GB/day", "calls": "Unlimited"}
        ]
    },
    "bsnl": {
        "name": "BSNL",
        "plans": [
            {"id": "bsnl_1", "amount": 197, "validity": "30 days", "data": "2GB/day", "calls": "Unlimited"},
            {"id": "bsnl_2", "amount": 319, "validity": "45 days", "data": "2GB/day", "calls": "Unlimited"},
            {"id": "bsnl_3", "amount": 397, "validity": "60 days", "data": "2GB/day", "calls": "Unlimited"},
            {"id": "bsnl_4", "amount": 797, "validity": "150 days", "data": "2GB/day", "calls": "Unlimited"},
            {"id": "bsnl_5", "amount": 2399, "validity": "365 days", "data": "2GB/day", "calls": "Unlimited"}
        ]
    }
}

# DTH Operators and Plans
DTH_OPERATORS = {
    "tatasky": {
        "name": "Tata Play",
        "plans": [
            {"id": "tata_1", "amount": 299, "validity": "30 days", "channels": "150+ SD", "type": "Basic"},
            {"id": "tata_2", "amount": 449, "validity": "30 days", "channels": "200+ SD + 50 HD", "type": "Standard"},
            {"id": "tata_3", "amount": 699, "validity": "30 days", "channels": "250+ SD + 100 HD", "type": "Premium"},
            {"id": "tata_4", "amount": 1299, "validity": "90 days", "channels": "300+ SD + 150 HD", "type": "Premium Plus"}
        ]
    },
    "airtel_dth": {
        "name": "Airtel Digital TV",
        "plans": [
            {"id": "adth_1", "amount": 249, "validity": "30 days", "channels": "120+ SD", "type": "Basic"},
            {"id": "adth_2", "amount": 399, "validity": "30 days", "channels": "180+ SD + 40 HD", "type": "Standard"},
            {"id": "adth_3", "amount": 649, "validity": "30 days", "channels": "220+ SD + 80 HD", "type": "Premium"},
            {"id": "adth_4", "amount": 1199, "validity": "90 days", "channels": "280+ SD + 120 HD", "type": "Premium Plus"}
        ]
    },
    "dish_tv": {
        "name": "Dish TV",
        "plans": [
            {"id": "dish_1", "amount": 199, "validity": "30 days", "channels": "100+ SD", "type": "Basic"},
            {"id": "dish_2", "amount": 349, "validity": "30 days", "channels": "160+ SD + 30 HD", "type": "Standard"},
            {"id": "dish_3", "amount": 599, "validity": "30 days", "channels": "200+ SD + 70 HD", "type": "Premium"}
        ]
    },
    "sun_direct": {
        "name": "Sun Direct",
        "plans": [
            {"id": "sun_1", "amount": 179, "validity": "30 days", "channels": "90+ SD", "type": "Basic"},
            {"id": "sun_2", "amount": 329, "validity": "30 days", "channels": "150+ SD + 25 HD", "type": "Standard"},
            {"id": "sun_3", "amount": 549, "validity": "30 days", "channels": "190+ SD + 60 HD", "type": "Premium"}
        ]
    }
}

# Broadband/Fiber Operators
BROADBAND_OPERATORS = {
    "jio_fiber": {
        "name": "Jio Fiber",
        "plans": [
            {"id": "jf_1", "amount": 399, "validity": "30 days", "speed": "30 Mbps", "data": "Unlimited", "ott": "None"},
            {"id": "jf_2", "amount": 699, "validity": "30 days", "speed": "100 Mbps", "data": "Unlimited", "ott": "14 Apps"},
            {"id": "jf_3", "amount": 999, "validity": "30 days", "speed": "300 Mbps", "data": "Unlimited", "ott": "14 Apps"},
            {"id": "jf_4", "amount": 1499, "validity": "30 days", "speed": "500 Mbps", "data": "Unlimited", "ott": "14 Apps"}
        ]
    },
    "airtel_xstream": {
        "name": "Airtel Xstream Fiber",
        "plans": [
            {"id": "axf_1", "amount": 499, "validity": "30 days", "speed": "40 Mbps", "data": "Unlimited", "ott": "Airtel Xstream"},
            {"id": "axf_2", "amount": 799, "validity": "30 days", "speed": "100 Mbps", "data": "Unlimited", "ott": "Amazon Prime"},
            {"id": "axf_3", "amount": 1099, "validity": "30 days", "speed": "200 Mbps", "data": "Unlimited", "ott": "Netflix Basic"},
            {"id": "axf_4", "amount": 1599, "validity": "30 days", "speed": "1 Gbps", "data": "Unlimited", "ott": "Netflix Premium"}
        ]
    },
    "bsnl_fiber": {
        "name": "BSNL Fiber",
        "plans": [
            {"id": "bf_1", "amount": 449, "validity": "30 days", "speed": "30 Mbps", "data": "3.3TB", "ott": "None"},
            {"id": "bf_2", "amount": 799, "validity": "30 days", "speed": "100 Mbps", "data": "Unlimited", "ott": "Disney+ Hotstar"},
            {"id": "bf_3", "amount": 1299, "validity": "30 days", "speed": "300 Mbps", "data": "Unlimited", "ott": "Multiple"}
        ]
    },
    "act_fibernet": {
        "name": "ACT Fibernet",
        "plans": [
            {"id": "act_1", "amount": 549, "validity": "30 days", "speed": "50 Mbps", "data": "Unlimited", "ott": "None"},
            {"id": "act_2", "amount": 799, "validity": "30 days", "speed": "150 Mbps", "data": "Unlimited", "ott": "Disney+ Hotstar"},
            {"id": "act_3", "amount": 1049, "validity": "30 days", "speed": "300 Mbps", "data": "Unlimited", "ott": "Multiple"}
        ]
    }
}

# Postpaid Operators
POSTPAID_OPERATORS = {
    "airtel_postpaid": {
        "name": "Airtel Postpaid",
        "info": "Pay your monthly postpaid bill"
    },
    "jio_postpaid": {
        "name": "Jio Postpaid",
        "info": "Pay your monthly postpaid bill"
    },
    "vi_postpaid": {
        "name": "Vi Postpaid",
        "info": "Pay your monthly postpaid bill"
    },
    "bsnl_postpaid": {
        "name": "BSNL Postpaid",
        "info": "Pay your monthly postpaid bill"
    }
}

# Utility Providers
UTILITY_PROVIDERS = {
    "electricity": {
        "providers": ["Adani Electricity", "BSES Rajdhani", "BSES Yamuna", "Tata Power", "MSEDCL", "BESCOM", "TNEB"],
        "info": "Pay your electricity bill"
    },
    "gas": {
        "providers": ["Indraprastha Gas", "Mahanagar Gas", "Gujarat Gas", "Adani Gas"],
        "info": "Pay your gas bill"
    },
    "water": {
        "providers": ["Delhi Jal Board", "Mumbai Water", "Bangalore Water", "Chennai Water"],
        "info": "Pay your water bill"
    },
    "landline": {
        "providers": ["BSNL Landline", "MTNL Landline", "Airtel Landline"],
        "info": "Pay your landline bill"
    }
}

# Store transactions in memory (in production, use a database)
transactions = []

@app.route("/")
def home():
    return render_template("landing.html")

@app.route("/app")
def app_page():
    return render_template("index.html")

@app.route("/api/services")
def get_services():
    return jsonify(SERVICE_TYPES)

@app.route("/api/operators/<service_type>")
def get_operators(service_type):
    if service_type == "mobile":
        return jsonify(MOBILE_OPERATORS)
    elif service_type == "dth":
        return jsonify(DTH_OPERATORS)
    elif service_type == "broadband":
        return jsonify(BROADBAND_OPERATORS)
    elif service_type == "postpaid":
        return jsonify(POSTPAID_OPERATORS)
    elif service_type in ["electricity", "gas", "water", "landline"]:
        return jsonify(UTILITY_PROVIDERS.get(service_type, {}))
    return jsonify({"error": "Service type not found"}), 404

@app.route("/api/plans/<service_type>/<operator>")
def get_plans(service_type, operator):
    if service_type == "mobile" and operator in MOBILE_OPERATORS:
        return jsonify(MOBILE_OPERATORS[operator]["plans"])
    elif service_type == "dth" and operator in DTH_OPERATORS:
        return jsonify(DTH_OPERATORS[operator]["plans"])
    elif service_type == "broadband" and operator in BROADBAND_OPERATORS:
        return jsonify(BROADBAND_OPERATORS[operator]["plans"])
    return jsonify({"error": "Plans not found"}), 404

@app.route("/api/recharge", methods=["POST"])
def recharge():
    data = request.json
    
    # Validate input
    service_type = data.get("service_type", "").strip()
    account_number = data.get("account_number", "").strip()
    operator = data.get("operator", "").strip()
    plan_id = data.get("plan_id", "").strip()
    amount = data.get("amount", 0)
    
    # Validate based on service type
    if service_type == "mobile":
        if not re.match(r"^[6-9]\d{9}$", account_number):
            return jsonify({"success": False, "error": "Invalid mobile number. Must be 10 digits starting with 6-9"}), 400
        
        if operator not in MOBILE_OPERATORS:
            return jsonify({"success": False, "error": "Invalid operator"}), 400
        
        # Find plan
        plan = None
        for p in MOBILE_OPERATORS[operator]["plans"]:
            if p["id"] == plan_id:
                plan = p
                break
        
        if not plan:
            return jsonify({"success": False, "error": "Invalid plan selected"}), 400
        
        operator_name = MOBILE_OPERATORS[operator]["name"]
        amount = plan["amount"]
        
    elif service_type == "dth":
        if not re.match(r"^\d{10,12}$", account_number):
            return jsonify({"success": False, "error": "Invalid DTH subscriber ID"}), 400
        
        if operator not in DTH_OPERATORS:
            return jsonify({"success": False, "error": "Invalid DTH operator"}), 400
        
        # Find plan
        plan = None
        for p in DTH_OPERATORS[operator]["plans"]:
            if p["id"] == plan_id:
                plan = p
                break
        
        if not plan:
            return jsonify({"success": False, "error": "Invalid plan selected"}), 400
        
        operator_name = DTH_OPERATORS[operator]["name"]
        amount = plan["amount"]
        
    elif service_type == "broadband":
        if not account_number:
            return jsonify({"success": False, "error": "Invalid account number"}), 400
        
        if operator not in BROADBAND_OPERATORS:
            return jsonify({"success": False, "error": "Invalid broadband operator"}), 400
        
        # Find plan
        plan = None
        for p in BROADBAND_OPERATORS[operator]["plans"]:
            if p["id"] == plan_id:
                plan = p
                break
        
        if not plan:
            return jsonify({"success": False, "error": "Invalid plan selected"}), 400
        
        operator_name = BROADBAND_OPERATORS[operator]["name"]
        amount = plan["amount"]
        
    elif service_type == "postpaid":
        if not re.match(r"^[6-9]\d{9}$", account_number):
            return jsonify({"success": False, "error": "Invalid mobile number"}), 400
        
        if operator not in POSTPAID_OPERATORS:
            return jsonify({"success": False, "error": "Invalid postpaid operator"}), 400
        
        if amount <= 0:
            return jsonify({"success": False, "error": "Invalid bill amount"}), 400
        
        operator_name = POSTPAID_OPERATORS[operator]["name"]
        plan = {"amount": amount, "type": "Bill Payment"}
        
    elif service_type in ["electricity", "gas", "water", "landline"]:
        if not account_number:
            return jsonify({"success": False, "error": "Invalid account/consumer number"}), 400
        
        if amount <= 0:
            return jsonify({"success": False, "error": "Invalid bill amount"}), 400
        
        operator_name = operator
        plan = {"amount": amount, "type": "Bill Payment"}
        
    else:
        return jsonify({"success": False, "error": "Invalid service type"}), 400
    
    # Generate transaction ID
    transaction_id = f"TXN{datetime.now().strftime('%Y%m%d%H%M%S')}{secrets.token_hex(3).upper()}"
    
    # Store transaction
    transaction = {
        "id": transaction_id,
        "service_type": service_type,
        "account_number": account_number,
        "operator": operator_name,
        "plan": plan,
        "amount": amount,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "status": "Success"
    }
    transactions.append(transaction)
    
    return jsonify({
        "success": True,
        "transaction_id": transaction_id,
        "message": f"Payment of ₹{amount} successful for {account_number}",
        "details": transaction
    })

@app.route("/api/transactions")
def get_transactions():
    return jsonify(transactions[-10:])  # Return last 10 transactions

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
