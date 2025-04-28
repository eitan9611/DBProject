CREATE TABLE Safety_Standard (
  Standard_ID VARCHAR(50) NOT NULL PRIMARY KEY,
  Standard_Name VARCHAR(255) NOT NULL,
  Safety_Requirements_Description VARCHAR(1000) NOT NULL,
  Standard_Level VARCHAR(50) NOT NULL,
  Equipment_Type VARCHAR(100) NOT NULL
);

CREATE TABLE Equipment (
  Equipment_ID VARCHAR(50) NOT NULL PRIMARY KEY,
  Equipment_Name VARCHAR(255) NOT NULL,
  Equipment_Type VARCHAR(100) NOT NULL,
  Safety_Status VARCHAR(50) NOT NULL,
  Installation_Date DATE NOT NULL,
  Standard_ID VARCHAR(50) NOT NULL,
  FOREIGN KEY (Standard_ID) REFERENCES Safety_Standard(Standard_ID)
);

CREATE TABLE Safety_Check (
  Check_ID INT NOT NULL,
  Equipment_ID VARCHAR(50) NOT NULL,
  Result VARCHAR(50) NOT NULL,
  Inspector_Notes VARCHAR(500) NOT NULL,
  Inspection_Date DATE NOT NULL,
  PRIMARY KEY (Check_ID, Equipment_ID),
  FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);

CREATE TABLE Maintenance_Technician (
  Technician_ID VARCHAR(50) NOT NULL PRIMARY KEY,
  Full_Name VARCHAR(255) NOT NULL,
  Professional_Certifications VARCHAR(255) NOT NULL,
  Phone_Number VARCHAR(20) NOT NULL,
  Last_Certification_Date DATE NOT NULL
);

CREATE TABLE Equipment_Malfunction (
  Malfunction_ID VARCHAR(50) NOT NULL UNIQUE,
  Report_Date DATE NOT NULL,
  Malfunction_Severity VARCHAR(50) NOT NULL,
  Repair_Status VARCHAR(50) NOT NULL,
  Equipment_ID VARCHAR(50) NOT NULL,
  Technician_ID VARCHAR(50) NOT NULL,
  PRIMARY KEY (Malfunction_ID),
  FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID),
  FOREIGN KEY (Technician_ID) REFERENCES Maintenance_Technician(Technician_ID)
);

CREATE TABLE Equipment_Usage (
  Usage_ID VARCHAR(50) NOT NULL,
  Equipment_ID VARCHAR(50) NOT NULL,
  User_ID VARCHAR(50) NOT NULL,
  Start_Time TIMESTAMP NOT NULL,
  Usage_Duration INT NOT NULL, -- Time in minutes
  PRIMARY KEY (Usage_ID, Equipment_ID),
  FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);

-- These tables seem unnecessary given your sample data and may cause issues
-- with your current data structure. They create many-to-many relationships
-- that aren't represented in your sample data.
-- Consider if you need these tables:

CREATE TABLE Equipment_Standard (
  Equipment_ID VARCHAR(50) NOT NULL,
  Standard_ID VARCHAR(50) NOT NULL,
  PRIMARY KEY (Equipment_ID, Standard_ID),
  FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID),
  FOREIGN KEY (Standard_ID) REFERENCES Safety_Standard(Standard_ID)
);

CREATE TABLE Repairs (
  Technician_ID VARCHAR(50) NOT NULL,
  Equipment_ID VARCHAR(50) NOT NULL,
  Malfunction_ID VARCHAR(50) NOT NULL,
  PRIMARY KEY (Technician_ID, Equipment_ID, Malfunction_ID),
  FOREIGN KEY (Technician_ID) REFERENCES Maintenance_Technician(Technician_ID),
  FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID),
  FOREIGN KEY (Malfunction_ID) REFERENCES Equipment_Malfunction(Malfunction_ID)
);
