import random
import csv
from datetime import datetime, timedelta

# הגדרות
num_records = 400
equipment_ids = list(range(1, 401))  # נניח שיש לך 400 פריטי ציוד
results = ["Pass", "Fail", "Pending Review", "Conditional Pass"]
notes = [
    "No issues found",
    "Minor issues detected, maintenance recommended",
    "Critical issues found, immediate attention required",
    "Equipment functioning within acceptable parameters",
    "Noise levels above threshold",
    "Wear and tear detected on moving parts",
    "Safety mechanisms functioning properly",
    "Calibration needed",
    "Parts replacement recommended",
    "Software update required"
]

# יצירת נתונים
data = []
for i in range(1, num_records + 1):
    check_id = i
    equipment_id = random.choice(equipment_ids)
    result = random.choice(results)
    note = random.choice(notes)

    # תאריך בדיקה אקראי בטווח השנתיים האחרונות
    days_ago = random.randint(1, 730)
    inspection_date = (datetime.now() - timedelta(days=days_ago)).strftime('%Y-%m-%d')

    data.append([check_id, equipment_id, result, note, inspection_date])

# שמירת הנתונים לקובץ CSV
with open('safety_checks.csv', 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['Check_ID', 'Equipment_ID', 'Result', 'Inspector_Notes', 'Inspection_Date'])
    writer.writerows(data)

print(f"Created {num_records} safety check records and saved to safety_checks.csv")