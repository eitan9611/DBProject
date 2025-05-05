# Gym Equipment Safety Management System – Project Report (Stage A)

## Submitted by:

* **Eliya Masa**
* **Eitan Weitzman**

## System Name:

**Gym Equipment Safety Management System**

## Selected Unit:

**Equipment Safety**

---

## Table of Contents

1. Introduction
2. System Overview
3. Entity-Relationship Diagram (ERD)
4. Data Structure Diagram (DSD)
5. Design Decisions
6. Data Entry Methods
7. Data Backup and Restore

---

## 1. Introduction

This project focuses on managing the safety of gym equipment. The system is designed to ensure that each piece of equipment is monitored for safe usage, undergoes regular safety inspections, and is handled promptly in case of malfunctions.

The database manages various aspects of equipment usage, maintenance, technician assignments, safety standards, and incident tracking to maintain a safe environment for gym users.

---

## 2. System Overview

The system tracks the following types of information:

* **Gym Equipment**: Each item has details like installation date, equipment type, and current safety status. Some equipment is linked to a relevant safety standard.
* **Safety Checks**: Regular inspections are performed on equipment. Each check logs the result, the inspection date, and notes from the inspector.
* **Maintenance Technicians**: Technicians are responsible for addressing equipment malfunctions. Their details include certifications and contact information.
* **Equipment Malfunctions**: When a fault occurs, it is recorded along with its severity, repair status, and optionally the technician assigned to fix it.
* **Equipment Usage**: Tracks when and how long a user uses a particular piece of equipment.
* **Safety Standards**: Define safety requirements based on standard level (local/international) and equipment type. Standards can be associated with multiple pieces of equipment.

These entities are linked through foreign key relationships and enforce data integrity and consistency throughout the system.

---

## 3. Entity-Relationship Diagram (ERD)

![image](https://github.com/user-attachments/assets/036bd48b-8e6a-4142-b049-fdb574db023b)


Key relationships:

* One Safety Standard → Many Equipment (1\:N)
* One Equipment → Many Safety Checks (1\:N)
* One Equipment → Many Equipment Usages (1\:N)
* One Equipment → Many Malfunctions (1\:N)
* One Malfunction → One Technician (nullable) (N:1)

---

## 4. Data Structure Diagram (DSD)

![image](https://github.com/user-attachments/assets/e4a0a963-d383-4008-8306-c17618bff69a)

The DSD illustrates all data types, constraints, primary and foreign keys for each table.

---

## 5. Design Decisions

* We allowed nullable foreign keys in cases where the link is optional (e.g., Equipment without a Safety Standard or a Malfunction without an assigned Technician).
* Used ENUMs or CHECK constraints for fields like severity and statuses to ensure consistent input.
* Indexed foreign keys for better performance during join operations.
* Kept Equipment as the central entity, as most interactions in a gym revolve around it.

---

## 6. Data Entry Methods

We used the following methods to populate the database:

![image](https://github.com/user-attachments/assets/e40eba15-4f48-46ef-89be-eba0c596b8bc)
![image](https://github.com/user-attachments/assets/dfbf11a5-48d9-4000-a150-b85f4ec073a7)


* Excel import of pre-filled .xlsx files
* Manual data entry via Python code
* SQL INSERT statements for batch data input

---

## 7. Data Backup and Restore

📸 *TODO: Add screenshots below*

* **Backup Method**: Performed using SQL dump/export feature.
* **Restore Method**: Reloaded using SQL import and tested integrity post-restore.
