-- =========================================================
-- Recruitment & Placement Management System (RPMS)
-- MySQL 8.x Database Schema
-- Common for Java and Python project teams
-- =========================================================

DROP DATABASE IF EXISTS rpms_db;
CREATE DATABASE rpms_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE rpms_db;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS placements;
DROP TABLE IF EXISTS offers;
DROP TABLE IF EXISTS interview_feedback;
DROP TABLE IF EXISTS interview_rounds;
DROP TABLE IF EXISTS application_history;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS job_skills;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS candidate_skills;
DROP TABLE IF EXISTS skills;
DROP TABLE IF EXISTS candidates;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS qualifications;
DROP TABLE IF EXISTS locations;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------
-- Optional master tables
-- ---------------------------------------------------------

CREATE TABLE qualifications (
    qualification_id INT PRIMARY KEY AUTO_INCREMENT,
    qualification_name VARCHAR(100) NOT NULL UNIQUE,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(100) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    country_name VARCHAR(100) NOT NULL DEFAULT 'India',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT uq_location UNIQUE (city_name, state_name, country_name)
);

-- ---------------------------------------------------------
-- Security / user tables
-- ---------------------------------------------------------

CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_code VARCHAR(30) NOT NULL UNIQUE,
    role_name VARCHAR(80) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE,
    role_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id) REFERENCES roles(role_id),

    CONSTRAINT chk_user_status
        CHECK (status IN ('ACTIVE','INACTIVE','LOCKED'))
);

-- ---------------------------------------------------------
-- Candidate / skills
-- ---------------------------------------------------------

CREATE TABLE candidates (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT,
    candidate_code VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    mobile VARCHAR(20) NOT NULL UNIQUE,
    date_of_birth DATE NULL,
    gender VARCHAR(20) NULL,
    qualification VARCHAR(80) NOT NULL,
    college VARCHAR(180) NULL,
    university VARCHAR(180) NULL,
    passing_year SMALLINT NOT NULL,
    percentage DECIMAL(5,2) NULL,
    cgpa DECIMAL(4,2) NULL,
    backlog_count INT NOT NULL DEFAULT 0,
    primary_technology VARCHAR(80) NULL,
    current_location VARCHAR(100) NULL,
    preferred_location VARCHAR(100) NULL,
    profile_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    placement_status VARCHAR(20) NOT NULL DEFAULT 'NOT_PLACED',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_candidate_percentage
        CHECK (percentage IS NULL OR (percentage >= 0 AND percentage <= 100)),

    CONSTRAINT chk_candidate_backlog
        CHECK (backlog_count >= 0),

    CONSTRAINT chk_candidate_profile_status
        CHECK (profile_status IN ('ACTIVE','INACTIVE','ON_HOLD','BLACKLISTED')),

    CONSTRAINT chk_candidate_placement_status
        CHECK (placement_status IN ('NOT_PLACED','PLACED'))
);

CREATE INDEX idx_candidates_primary_technology
    ON candidates(primary_technology);

CREATE INDEX idx_candidates_passing_year
    ON candidates(passing_year);

CREATE INDEX idx_candidates_placement_status
    ON candidates(placement_status);

CREATE TABLE skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(60) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE candidate_skills (
    candidate_skill_id INT PRIMARY KEY AUTO_INCREMENT,
    candidate_id INT NOT NULL,
    skill_id INT NOT NULL,
    proficiency_level VARCHAR(20) NULL,
    years_experience DECIMAL(4,1) NOT NULL DEFAULT 0,
    is_primary TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT uq_candidate_skill
        UNIQUE (candidate_id, skill_id),

    CONSTRAINT fk_candidate_skills_candidate
        FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),

    CONSTRAINT fk_candidate_skills_skill
        FOREIGN KEY (skill_id) REFERENCES skills(skill_id),

    CONSTRAINT chk_candidate_skill_level
        CHECK (proficiency_level IS NULL OR proficiency_level IN ('BASIC','INTERMEDIATE','ADVANCED')),

    CONSTRAINT chk_candidate_experience
        CHECK (years_experience >= 0)
);

CREATE INDEX idx_candidate_skills_candidate
    ON candidate_skills(candidate_id);

CREATE INDEX idx_candidate_skills_skill
    ON candidate_skills(skill_id);

-- ---------------------------------------------------------
-- Company / jobs
-- ---------------------------------------------------------

CREATE TABLE companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_code VARCHAR(30) NOT NULL UNIQUE,
    company_name VARCHAR(180) NOT NULL,
    industry VARCHAR(100) NULL,
    website VARCHAR(200) NULL,
    location VARCHAR(120) NULL,
    company_type VARCHAR(30) NULL,
    hr_name VARCHAR(120) NULL,
    hr_email VARCHAR(150) NULL,
    hr_mobile VARCHAR(20) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_company_status
        CHECK (status IN ('ACTIVE','INACTIVE'))
);

CREATE INDEX idx_companies_name
    ON companies(company_name);

CREATE INDEX idx_companies_status
    ON companies(status);

CREATE TABLE jobs (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    job_code VARCHAR(40) NOT NULL UNIQUE,
    company_id INT NOT NULL,
    job_title VARCHAR(150) NOT NULL,
    employment_type VARCHAR(30) NOT NULL DEFAULT 'FULL_TIME',
    location VARCHAR(120) NOT NULL,
    openings INT NOT NULL,
    min_package_lpa DECIMAL(6,2) NULL,
    max_package_lpa DECIMAL(6,2) NULL,
    min_percentage DECIMAL(5,2) NULL,
    min_passing_year SMALLINT NULL,
    max_passing_year SMALLINT NULL,
    max_backlogs INT NOT NULL DEFAULT 0,
    experience_min_years DECIMAL(4,1) NOT NULL DEFAULT 0,
    qualification_rule VARCHAR(255) NULL,
    posted_date DATE NOT NULL,
    application_deadline DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    created_by INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_jobs_company
        FOREIGN KEY (company_id) REFERENCES companies(company_id),

    CONSTRAINT fk_jobs_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id),

    CONSTRAINT chk_jobs_openings
        CHECK (openings > 0),

    CONSTRAINT chk_jobs_percentage
        CHECK (min_percentage IS NULL OR (min_percentage >= 0 AND min_percentage <= 100)),

    CONSTRAINT chk_jobs_package
        CHECK (
            min_package_lpa IS NULL OR
            max_package_lpa IS NULL OR
            min_package_lpa <= max_package_lpa
        ),

    CONSTRAINT chk_jobs_backlogs
        CHECK (max_backlogs >= 0),

    CONSTRAINT chk_jobs_experience
        CHECK (experience_min_years >= 0),

    CONSTRAINT chk_jobs_dates
        CHECK (application_deadline >= posted_date),

    CONSTRAINT chk_job_status
        CHECK (status IN ('DRAFT','OPEN','CLOSED','CANCELLED'))
);

CREATE INDEX idx_jobs_company ON jobs(company_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_deadline ON jobs(application_deadline);
CREATE INDEX idx_jobs_location ON jobs(location);

CREATE TABLE job_skills (
    job_skill_id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    skill_id INT NOT NULL,
    minimum_level VARCHAR(20) NULL,
    mandatory_flag TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uq_job_skill UNIQUE (job_id, skill_id),

    CONSTRAINT fk_job_skills_job
        FOREIGN KEY (job_id) REFERENCES jobs(job_id),

    CONSTRAINT fk_job_skills_skill
        FOREIGN KEY (skill_id) REFERENCES skills(skill_id),

    CONSTRAINT chk_job_skill_level
        CHECK (minimum_level IS NULL OR minimum_level IN ('BASIC','INTERMEDIATE','ADVANCED'))
);

-- ---------------------------------------------------------
-- Applications / workflow
-- ---------------------------------------------------------

CREATE TABLE applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    application_code VARCHAR(40) NOT NULL UNIQUE,
    candidate_id INT NOT NULL,
    job_id INT NOT NULL,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    eligibility_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    eligibility_reason VARCHAR(500) NULL,
    application_status VARCHAR(30) NOT NULL DEFAULT 'APPLIED',
    source VARCHAR(50) NULL,
    assigned_recruiter_id INT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_candidate_job UNIQUE (candidate_id, job_id),

    CONSTRAINT fk_app_candidate
        FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),

    CONSTRAINT fk_app_job
        FOREIGN KEY (job_id) REFERENCES jobs(job_id),

    CONSTRAINT fk_app_recruiter
        FOREIGN KEY (assigned_recruiter_id) REFERENCES users(user_id),

    CONSTRAINT chk_eligibility_status
        CHECK (eligibility_status IN ('PENDING','ELIGIBLE','NOT_ELIGIBLE')),

    CONSTRAINT chk_application_status
        CHECK (application_status IN (
            'APPLIED',
            'ELIGIBILITY_VERIFIED',
            'SHORTLISTED',
            'INTERVIEW_SCHEDULED',
            'INTERVIEWED',
            'SELECTED',
            'REJECTED',
            'OFFERED',
            'JOINED',
            'WITHDRAWN'
        ))
);

CREATE INDEX idx_applications_status
    ON applications(application_status);

CREATE INDEX idx_applications_recruiter
    ON applications(assigned_recruiter_id);

CREATE TABLE application_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    old_status VARCHAR(30) NULL,
    new_status VARCHAR(30) NOT NULL,
    remarks VARCHAR(500) NULL,
    changed_by INT NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_app_history_application
        FOREIGN KEY (application_id) REFERENCES applications(application_id),

    CONSTRAINT fk_app_history_user
        FOREIGN KEY (changed_by) REFERENCES users(user_id)
);

CREATE INDEX idx_app_history_application
    ON application_history(application_id);

CREATE INDEX idx_app_history_changed_at
    ON application_history(changed_at);

-- ---------------------------------------------------------
-- Interview / feedback
-- ---------------------------------------------------------

CREATE TABLE interview_rounds (
    interview_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    round_number INT NOT NULL,
    round_type VARCHAR(50) NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NULL,
    mode VARCHAR(20) NOT NULL,
    interviewer_name VARCHAR(120) NULL,
    meeting_or_location VARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_application_round
        UNIQUE (application_id, round_number),

    CONSTRAINT fk_interview_application
        FOREIGN KEY (application_id) REFERENCES applications(application_id),

    CONSTRAINT chk_interview_round_number
        CHECK (round_number > 0),

    CONSTRAINT chk_interview_mode
        CHECK (mode IN ('ONLINE','OFFLINE','TELEPHONIC')),

    CONSTRAINT chk_interview_status
        CHECK (status IN ('SCHEDULED','COMPLETED','RESCHEDULED','CANCELLED','NO_SHOW'))
);

CREATE INDEX idx_interviews_date
    ON interview_rounds(scheduled_date);

CREATE INDEX idx_interviews_status
    ON interview_rounds(status);

CREATE TABLE interview_feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    interview_id INT NOT NULL UNIQUE,
    technical_rating DECIMAL(3,1) NULL,
    communication_rating DECIMAL(3,1) NULL,
    problem_solving_rating DECIMAL(3,1) NULL,
    overall_rating DECIMAL(3,1) NULL,
    recommendation VARCHAR(30) NOT NULL,
    remarks TEXT NULL,
    submitted_by INT NOT NULL,
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_feedback_interview
        FOREIGN KEY (interview_id) REFERENCES interview_rounds(interview_id),

    CONSTRAINT fk_feedback_user
        FOREIGN KEY (submitted_by) REFERENCES users(user_id),

    CONSTRAINT chk_feedback_technical
        CHECK (technical_rating IS NULL OR (technical_rating >= 0 AND technical_rating <= 5)),

    CONSTRAINT chk_feedback_communication
        CHECK (communication_rating IS NULL OR (communication_rating >= 0 AND communication_rating <= 5)),

    CONSTRAINT chk_feedback_problem_solving
        CHECK (problem_solving_rating IS NULL OR (problem_solving_rating >= 0 AND problem_solving_rating <= 5)),

    CONSTRAINT chk_feedback_overall
        CHECK (overall_rating IS NULL OR (overall_rating >= 0 AND overall_rating <= 5)),

    CONSTRAINT chk_feedback_recommendation
        CHECK (recommendation IN ('NEXT_ROUND','SELECTED','REJECTED','ON_HOLD'))
);

CREATE INDEX idx_feedback_recommendation
    ON interview_feedback(recommendation);

-- ---------------------------------------------------------
-- Offer / placement
-- ---------------------------------------------------------

CREATE TABLE offers (
    offer_id INT PRIMARY KEY AUTO_INCREMENT,
    offer_code VARCHAR(40) NOT NULL UNIQUE,
    application_id INT NOT NULL UNIQUE,
    designation VARCHAR(120) NOT NULL,
    offered_package_lpa DECIMAL(6,2) NOT NULL,
    offer_date DATE NOT NULL,
    expected_joining_date DATE NULL,
    offer_status VARCHAR(20) NOT NULL DEFAULT 'OFFERED',
    remarks VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_offer_application
        FOREIGN KEY (application_id) REFERENCES applications(application_id),

    CONSTRAINT chk_offer_package
        CHECK (offered_package_lpa >= 0),

    CONSTRAINT chk_offer_status
        CHECK (offer_status IN ('OFFERED','ACCEPTED','REJECTED','EXPIRED','WITHDRAWN'))
);

CREATE INDEX idx_offers_status
    ON offers(offer_status);

CREATE TABLE placements (
    placement_id INT PRIMARY KEY AUTO_INCREMENT,
    candidate_id INT NOT NULL,
    company_id INT NOT NULL,
    job_id INT NOT NULL,
    offer_id INT NOT NULL UNIQUE,
    designation VARCHAR(120) NOT NULL,
    final_package_lpa DECIMAL(6,2) NOT NULL,
    expected_joining_date DATE NULL,
    actual_joining_date DATE NULL,
    joining_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    placement_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_placement_candidate
        FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),

    CONSTRAINT fk_placement_company
        FOREIGN KEY (company_id) REFERENCES companies(company_id),

    CONSTRAINT fk_placement_job
        FOREIGN KEY (job_id) REFERENCES jobs(job_id),

    CONSTRAINT fk_placement_offer
        FOREIGN KEY (offer_id) REFERENCES offers(offer_id),

    CONSTRAINT chk_placement_package
        CHECK (final_package_lpa >= 0),

    CONSTRAINT chk_joining_status
        CHECK (joining_status IN ('PENDING','JOINED','NOT_JOINED','DEFERRED','NO_SHOW')),

    CONSTRAINT chk_placement_status
        CHECK (placement_status IN ('ACTIVE','CANCELLED'))
);

CREATE INDEX idx_placements_candidate
    ON placements(candidate_id);

CREATE INDEX idx_placements_company
    ON placements(company_id);

CREATE INDEX idx_placements_joining_status
    ON placements(joining_status);

-- ---------------------------------------------------------
-- Activity logs
-- ---------------------------------------------------------

CREATE TABLE activity_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    module_name VARCHAR(60) NOT NULL,
    action_name VARCHAR(80) NOT NULL,
    record_id VARCHAR(60) NULL,
    description VARCHAR(500) NULL,
    logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_activity_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE INDEX idx_activity_user
    ON activity_logs(user_id);

CREATE INDEX idx_activity_module
    ON activity_logs(module_name);

CREATE INDEX idx_activity_logged_at
    ON activity_logs(logged_at);

-- =========================================================
-- End of schema
-- =========================================================


-- =========================================================
-- RPMS Sample Data
-- Run after rpms_schema.sql
-- =========================================================
USE rpms_db;

-- Optional masters
INSERT INTO qualifications (qualification_name) VALUES ('BE');
INSERT INTO qualifications (qualification_name) VALUES ('BTech');
INSERT INTO qualifications (qualification_name) VALUES ('MCA');
INSERT INTO qualifications (qualification_name) VALUES ('BCA');
INSERT INTO qualifications (qualification_name) VALUES ('BSc Computer Science');
INSERT INTO qualifications (qualification_name) VALUES ('MSc Computer Science');
INSERT INTO locations (city_name,state_name,country_name) VALUES ('Pune','Maharashtra','India');
INSERT INTO locations (city_name,state_name,country_name) VALUES ('Mumbai','Maharashtra','India');
INSERT INTO locations (city_name,state_name,country_name) VALUES ('Nashik','Maharashtra','India');
INSERT INTO locations (city_name,state_name,country_name) VALUES ('Bengaluru','Karnataka','India');
INSERT INTO locations (city_name,state_name,country_name) VALUES ('Hyderabad','Telangana','India');
INSERT INTO locations (city_name,state_name,country_name) VALUES ('Chennai','Tamil Nadu','India');

-- Roles
INSERT INTO roles (role_id,role_code,role_name) VALUES (1,'ADMIN','Administrator');
INSERT INTO roles (role_id,role_code,role_name) VALUES (2,'RECRUITER','Recruiter');
INSERT INTO roles (role_id,role_code,role_name) VALUES (3,'PLACEMENT_OFFICER','Placement Officer');

-- Users (hashes are demo placeholders only)
INSERT INTO users (user_id,username,password_hash,full_name,email,role_id,status) VALUES (1,'admin','$2y$10$DEMO_ADMIN_HASH_ONLY','System Admin','admin@example.com',1,'ACTIVE');
INSERT INTO users (user_id,username,password_hash,full_name,email,role_id,status) VALUES (2,'amit.recruiter','$2y$10$DEMO_AMIT_HASH_ONLY','Amit Kulkarni','amit.recruiter@example.com',2,'ACTIVE');
INSERT INTO users (user_id,username,password_hash,full_name,email,role_id,status) VALUES (3,'sneha.recruiter','$2y$10$DEMO_SNEHA_HASH_ONLY','Sneha Patil','sneha.recruiter@example.com',2,'ACTIVE');
INSERT INTO users (user_id,username,password_hash,full_name,email,role_id,status) VALUES (4,'neha.placement','$2y$10$DEMO_NEHA_HASH_ONLY','Neha Deshmukh','neha.placement@example.com',3,'ACTIVE');
INSERT INTO users (user_id,username,password_hash,full_name,email,role_id,status) VALUES (5,'rahul.placement','$2y$10$DEMO_RAHUL_HASH_ONLY','Rahul Joshi','rahul.placement@example.com',3,'ACTIVE');

-- Skills
INSERT INTO skills (skill_id,skill_name,category) VALUES (1,'Java','Programming');
INSERT INTO skills (skill_id,skill_name,category) VALUES (2,'Python','Programming');
INSERT INTO skills (skill_id,skill_name,category) VALUES (3,'SQL','Database');
INSERT INTO skills (skill_id,skill_name,category) VALUES (4,'HTML','Web');
INSERT INTO skills (skill_id,skill_name,category) VALUES (5,'CSS','Web');
INSERT INTO skills (skill_id,skill_name,category) VALUES (6,'JDBC','Database Connectivity');
INSERT INTO skills (skill_id,skill_name,category) VALUES (7,'MySQL','Database');
INSERT INTO skills (skill_id,skill_name,category) VALUES (8,'Manual Testing','Testing');
INSERT INTO skills (skill_id,skill_name,category) VALUES (9,'Selenium','Testing');
INSERT INTO skills (skill_id,skill_name,category) VALUES (10,'Data Analytics','Analytics');

-- Candidates
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (1,'CAN-2026-0001','Rahul Patil','rahul.patil01@example.com','9000000001','2002-04-12','Male','BE','ABC College Pune','SPPU',2025,68.5,NULL,0,'Java','Pune','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (2,'CAN-2026-0002','Sneha More','sneha.more02@example.com','9000000002','2002-08-21','Female','BTech','Modern College','SPPU',2025,74.2,NULL,0,'Python','Pune','Bengaluru','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (3,'CAN-2026-0003','Amit Shinde','amit.shinde03@example.com','9000000003','2001-12-02','Male','MCA','MIT College','SPPU',2024,71.0,NULL,0,'Java','Pune','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (4,'CAN-2026-0004','Neha Jadhav','neha.jadhav04@example.com','9000000004','2002-06-13','Female','BE','DY Patil College','SPPU',2025,82.4,NULL,0,'Python','Pimpri','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (5,'CAN-2026-0005','Rohit Pawar','rohit.pawar05@example.com','9000000005','2002-03-03','Male','BTech','PCCOE','SPPU',2025,59.5,NULL,1,'Java','Pimpri','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (6,'CAN-2026-0006','Priya Desai','priya.desai06@example.com','9000000006','2001-09-17','Female','MCA','Fergusson College','SPPU',2024,76.1,NULL,0,'Python','Pune','Hyderabad','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (7,'CAN-2026-0007','Akash Kale','akash.kale07@example.com','9000000007','2002-10-11','Male','BE','Sinhgad College','SPPU',2025,64.8,NULL,0,'Testing','Pune','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (8,'CAN-2026-0008','Pooja Mali','pooja.mali08@example.com','9000000008','2002-02-24','Female','BCA','Indira College','SPPU',2025,72.6,NULL,0,'Data Analytics','Pune','Mumbai','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (9,'CAN-2026-0009','Sagar Chavan','sagar.chavan09@example.com','9000000009','2001-11-14','Male','BSc Computer Science','Nowrosjee Wadia College','SPPU',2024,66.3,NULL,0,'Python','Pune','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (10,'CAN-2026-0010','Komal Gaikwad','komal.gaikwad10@example.com','9000000010','2002-05-09','Female','BE','AISSMS','SPPU',2025,78.9,NULL,0,'Java','Pune','Bengaluru','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (11,'CAN-2026-0011','Vishal Khot','vishal.khot11@example.com','9000000011','2002-01-28','Male','BTech','VIT Pune','SPPU',2025,69.4,NULL,0,'Java','Pune','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (12,'CAN-2026-0012','Anjali Bhosale','anjali.bhosale12@example.com','9000000012','2002-07-30','Female','MCA','IMCC Pune','SPPU',2025,80.1,NULL,0,'Python','Pune','Hyderabad','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (13,'CAN-2026-0013','Kunal Wagh','kunal.wagh13@example.com','9000000013','2001-04-05','Male','BE','MET Nashik','SPPU',2024,62.7,NULL,0,'Testing','Nashik','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (14,'CAN-2026-0014','Rutuja Salunkhe','rutuja.salunkhe14@example.com','9000000014','2002-09-23','Female','BTech','PCCOE','SPPU',2025,85.0,NULL,0,'Data Analytics','Pimpri','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (15,'CAN-2026-0015','Nikhil Patil','nikhil.patil15@example.com','9000000015','2001-03-12','Male','MCA','DY Patil','SPPU',2024,73.3,NULL,0,'Java','Pune','Mumbai','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (16,'CAN-2026-0016','Shruti Joshi','shruti.joshi16@example.com','9000000016','2002-12-16','Female','BE','MIT WPU','MIT WPU',2025,67.9,NULL,0,'Python','Pune','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (17,'CAN-2026-0017','Omkar Mane','omkar.mane17@example.com','9000000017','2002-06-06','Male','BTech','Sinhgad College','SPPU',2025,61.2,NULL,1,'Java','Pune','Pune','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (18,'CAN-2026-0018','Sayali Patil','sayali.patil18@example.com','9000000018','2002-10-19','Female','BCA','Modern College','SPPU',2025,77.5,NULL,0,'Testing','Pune','Mumbai','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (19,'CAN-2026-0019','Aditya Jagtap','aditya.jagtap19@example.com','9000000019','2001-08-08','Male','BE','AISSMS','SPPU',2024,70.6,NULL,0,'Java','Pune','Bengaluru','ACTIVE','NOT_PLACED');
INSERT INTO candidates (candidate_id,candidate_code,full_name,email,mobile,date_of_birth,gender,qualification,college,university,passing_year,percentage,cgpa,backlog_count,primary_technology,current_location,preferred_location,profile_status,placement_status) VALUES (20,'CAN-2026-0020','Mansi Kulkarni','mansi.kulkarni20@example.com','9000000020','2002-11-11','Female','MCA','IMCC Pune','SPPU',2025,83.2,NULL,0,'Python','Pune','Pune','ACTIVE','NOT_PLACED');

-- Candidate skills
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (1,1,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (1,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (1,6,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (1,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (2,2,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (2,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (2,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (2,4,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (3,1,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (3,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (3,6,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (3,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (4,2,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (4,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (4,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (4,4,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (5,1,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (5,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (5,6,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (5,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (6,2,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (6,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (6,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (6,4,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (7,8,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (7,9,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (7,3,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (8,10,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (8,2,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (8,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (9,2,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (9,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (9,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (9,4,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (10,1,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (10,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (10,6,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (10,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (11,1,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (11,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (11,6,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (11,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (12,2,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (12,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (12,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (12,4,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (13,8,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (13,9,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (13,3,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (14,10,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (14,2,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (14,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (15,1,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (15,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (15,6,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (15,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (16,2,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (16,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (16,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (16,4,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (17,1,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (17,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (17,6,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (17,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (18,8,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (18,9,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (18,3,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (19,1,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (19,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (19,6,'BASIC',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (19,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (20,2,'INTERMEDIATE',0.0,1);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (20,3,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (20,7,'INTERMEDIATE',0.0,0);
INSERT INTO candidate_skills (candidate_id,skill_id,proficiency_level,years_experience,is_primary) VALUES (20,4,'BASIC',0.0,0);

-- Companies
INSERT INTO companies (company_id,company_code,company_name,industry,website,location,company_type,hr_name,hr_email,hr_mobile,status) VALUES (1,'COM-001','TechNova Solutions','IT Services','https://example.com/technova','Pune','MID_SIZE','Meera Shah','meera.hr@example.com','9100000001','ACTIVE');
INSERT INTO companies (company_id,company_code,company_name,industry,website,location,company_type,hr_name,hr_email,hr_mobile,status) VALUES (2,'COM-002','BluePeak Systems','Software','https://example.com/bluepeak','Bengaluru','MNC','Rakesh Nair','rakesh.hr@example.com','9100000002','ACTIVE');
INSERT INTO companies (company_id,company_code,company_name,industry,website,location,company_type,hr_name,hr_email,hr_mobile,status) VALUES (3,'COM-003','DataSphere Labs','Analytics','https://example.com/datasphere','Pune','STARTUP','Anita Rao','anita.hr@example.com','9100000003','ACTIVE');
INSERT INTO companies (company_id,company_code,company_name,industry,website,location,company_type,hr_name,hr_email,hr_mobile,status) VALUES (4,'COM-004','QualityFirst Tech','Testing','https://example.com/qualityfirst','Mumbai','MID_SIZE','Kavita Mehta','kavita.hr@example.com','9100000004','ACTIVE');
INSERT INTO companies (company_id,company_code,company_name,industry,website,location,company_type,hr_name,hr_email,hr_mobile,status) VALUES (5,'COM-005','CloudBridge India','Cloud & Software','https://example.com/cloudbridge','Hyderabad','MNC','Arun Das','arun.hr@example.com','9100000005','ACTIVE');
INSERT INTO companies (company_id,company_code,company_name,industry,website,location,company_type,hr_name,hr_email,hr_mobile,status) VALUES (6,'COM-006','NexGen Infotech','IT Services','https://example.com/nexgen','Pune','CONSULTANCY','Priyanka Sen','priyanka.hr@example.com','9100000006','ACTIVE');
INSERT INTO companies (company_id,company_code,company_name,industry,website,location,company_type,hr_name,hr_email,hr_mobile,status) VALUES (7,'COM-007','FinEdge Technologies','FinTech','https://example.com/finedge','Mumbai','MNC','Harish Jain','harish.hr@example.com','9100000007','ACTIVE');
INSERT INTO companies (company_id,company_code,company_name,industry,website,location,company_type,hr_name,hr_email,hr_mobile,status) VALUES (8,'COM-008','RetailIQ Labs','Retail Analytics','https://example.com/retailiq','Chennai','STARTUP','Divya Krishnan','divya.hr@example.com','9100000008','ACTIVE');

-- Jobs
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (1,'JOB-2026-001',1,'Associate Java Developer','FULL_TIME','Pune',8,4.0,5.5,60,2024,2026,0,0,'BE/BTech/MCA','2026-10-01','2026-11-15','OPEN',2);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (2,'JOB-2026-002',2,'Python Developer Trainee','FULL_TIME','Bengaluru',10,4.2,6.0,65,2024,2026,0,0,'BE/BTech/MCA/BCA','2026-10-02','2026-11-20','OPEN',3);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (3,'JOB-2026-003',3,'Junior Data Analyst','FULL_TIME','Pune',6,4.0,5.0,60,2024,2026,0,0,'BE/BTech/BCA/BSc/MCA','2026-10-03','2026-11-18','OPEN',2);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (4,'JOB-2026-004',4,'QA Engineer Trainee','FULL_TIME','Mumbai',7,3.8,5.0,55,2024,2026,1,0,'Any Computer Graduate','2026-10-04','2026-11-22','OPEN',3);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (5,'JOB-2026-005',5,'Graduate Software Engineer','FULL_TIME','Hyderabad',12,5.0,7.0,65,2024,2026,0,0,'BE/BTech/MCA','2026-10-05','2026-11-25','OPEN',2);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (6,'JOB-2026-006',6,'Java Support Engineer','FULL_TIME','Pune',5,3.6,4.8,55,2023,2026,1,0,'BE/BTech/MCA/BCA','2026-09-15','2026-10-31','OPEN',3);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (7,'JOB-2026-007',7,'Software Engineer - Java','FULL_TIME','Mumbai',4,5.5,7.5,70,2024,2026,0,0,'BE/BTech/MCA','2026-09-20','2026-10-30','CLOSED',2);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (8,'JOB-2026-008',8,'Data Analytics Intern','INTERNSHIP','Chennai',10,2.4,3.0,60,2024,2026,0,0,'Any Graduate','2026-10-07','2026-11-30','OPEN',3);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (9,'JOB-2026-009',1,'SQL Developer Trainee','FULL_TIME','Pune',5,3.8,5.0,60,2024,2026,0,0,'BE/BTech/MCA/BCA','2026-10-08','2026-11-28','OPEN',2);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (10,'JOB-2026-010',4,'Automation Testing Trainee','FULL_TIME','Pune',5,4.0,5.2,60,2024,2026,0,0,'BE/BTech/MCA/BCA','2026-10-10','2026-11-29','OPEN',3);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (11,'JOB-2026-011',6,'Application Support Associate','FULL_TIME','Pune',6,3.5,4.5,55,2023,2026,1,0,'Any Computer Graduate','2026-10-11','2026-12-01','OPEN',2);
INSERT INTO jobs (job_id,job_code,company_id,job_title,employment_type,location,openings,min_package_lpa,max_package_lpa,min_percentage,min_passing_year,max_passing_year,max_backlogs,experience_min_years,qualification_rule,posted_date,application_deadline,status,created_by) VALUES (12,'JOB-2026-012',3,'BI Analyst Trainee','FULL_TIME','Pune',4,4.5,5.8,65,2024,2026,0,0,'BE/BTech/BCA/BSc/MCA','2026-10-12','2026-12-05','OPEN',3);

-- Job skills
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (1,1,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (1,3,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (1,6,'BASIC',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (2,2,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (2,3,'BASIC',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (2,7,'BASIC',0);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (3,10,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (3,3,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (3,2,'BASIC',0);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (4,8,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (4,3,'BASIC',0);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (5,1,'BASIC',0);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (5,2,'BASIC',0);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (5,3,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (6,1,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (6,3,'BASIC',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (7,1,'ADVANCED',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (7,3,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (7,6,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (8,10,'BASIC',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (8,3,'BASIC',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (9,3,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (9,7,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (10,8,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (10,9,'BASIC',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (10,3,'BASIC',0);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (11,3,'BASIC',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (11,1,'BASIC',0);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (11,2,'BASIC',0);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (12,10,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (12,3,'INTERMEDIATE',1);
INSERT INTO job_skills (job_id,skill_id,minimum_level,mandatory_flag) VALUES (12,2,'BASIC',0);

-- Applications
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (1,'APP-2026-0001',1,1,'2026-10-02 10:07:00','ELIGIBLE','Meets eligibility criteria','SHORTLISTED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (2,'APP-2026-0002',1,9,'2026-10-03 10:14:00','ELIGIBLE','Meets eligibility criteria','INTERVIEW_SCHEDULED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (3,'APP-2026-0003',2,2,'2026-10-04 10:21:00','ELIGIBLE','Meets eligibility criteria','INTERVIEWED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (4,'APP-2026-0004',2,3,'2026-10-05 10:28:00','ELIGIBLE','Meets eligibility criteria','SELECTED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (5,'APP-2026-0005',3,1,'2026-10-06 10:35:00','ELIGIBLE','Meets eligibility criteria','OFFERED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (6,'APP-2026-0006',3,6,'2026-10-07 10:42:00','NOT_ELIGIBLE','Minimum percentage/backlog criteria not met','REJECTED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (7,'APP-2026-0007',4,2,'2026-10-08 10:49:00','ELIGIBLE','Meets eligibility criteria','APPLIED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (8,'APP-2026-0008',4,5,'2026-10-09 10:56:00','ELIGIBLE','Meets eligibility criteria','ELIGIBILITY_VERIFIED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (9,'APP-2026-0009',5,1,'2026-10-10 10:03:00','ELIGIBLE','Meets eligibility criteria','SHORTLISTED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (10,'APP-2026-0010',5,11,'2026-10-11 10:10:00','ELIGIBLE','Meets eligibility criteria','INTERVIEW_SCHEDULED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (11,'APP-2026-0011',6,2,'2026-10-12 10:17:00','ELIGIBLE','Meets eligibility criteria','INTERVIEWED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (12,'APP-2026-0012',6,12,'2026-10-13 10:24:00','ELIGIBLE','Meets eligibility criteria','SELECTED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (13,'APP-2026-0013',7,4,'2026-10-14 10:31:00','ELIGIBLE','Meets eligibility criteria','OFFERED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (14,'APP-2026-0014',7,10,'2026-10-15 10:38:00','NOT_ELIGIBLE','Minimum percentage/backlog criteria not met','REJECTED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (15,'APP-2026-0015',8,3,'2026-10-16 10:45:00','ELIGIBLE','Meets eligibility criteria','APPLIED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (16,'APP-2026-0016',8,8,'2026-10-17 10:52:00','ELIGIBLE','Meets eligibility criteria','ELIGIBILITY_VERIFIED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (17,'APP-2026-0017',9,2,'2026-10-18 10:59:00','ELIGIBLE','Meets eligibility criteria','SHORTLISTED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (18,'APP-2026-0018',9,11,'2026-10-19 10:06:00','ELIGIBLE','Meets eligibility criteria','INTERVIEW_SCHEDULED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (19,'APP-2026-0019',10,1,'2026-10-20 10:13:00','ELIGIBLE','Meets eligibility criteria','INTERVIEWED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (20,'APP-2026-0020',10,7,'2026-10-21 10:20:00','ELIGIBLE','Meets eligibility criteria','SELECTED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (21,'APP-2026-0021',11,1,'2026-10-22 10:27:00','ELIGIBLE','Meets eligibility criteria','OFFERED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (22,'APP-2026-0022',11,9,'2026-10-23 10:34:00','NOT_ELIGIBLE','Minimum percentage/backlog criteria not met','REJECTED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (23,'APP-2026-0023',12,2,'2026-10-24 10:41:00','ELIGIBLE','Meets eligibility criteria','APPLIED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (24,'APP-2026-0024',12,5,'2026-10-25 10:48:00','ELIGIBLE','Meets eligibility criteria','ELIGIBILITY_VERIFIED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (25,'APP-2026-0025',13,4,'2026-10-26 10:55:00','ELIGIBLE','Meets eligibility criteria','SHORTLISTED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (26,'APP-2026-0026',13,10,'2026-10-27 10:02:00','ELIGIBLE','Meets eligibility criteria','INTERVIEW_SCHEDULED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (27,'APP-2026-0027',14,3,'2026-10-01 10:09:00','ELIGIBLE','Meets eligibility criteria','INTERVIEWED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (28,'APP-2026-0028',14,8,'2026-10-02 10:16:00','ELIGIBLE','Meets eligibility criteria','SELECTED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (29,'APP-2026-0029',15,1,'2026-10-03 10:23:00','ELIGIBLE','Meets eligibility criteria','OFFERED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (30,'APP-2026-0030',15,7,'2026-10-04 10:30:00','NOT_ELIGIBLE','Minimum percentage/backlog criteria not met','REJECTED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (31,'APP-2026-0031',16,2,'2026-10-05 10:37:00','ELIGIBLE','Meets eligibility criteria','APPLIED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (32,'APP-2026-0032',16,12,'2026-10-06 10:44:00','ELIGIBLE','Meets eligibility criteria','ELIGIBILITY_VERIFIED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (33,'APP-2026-0033',17,6,'2026-10-07 10:51:00','ELIGIBLE','Meets eligibility criteria','SHORTLISTED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (34,'APP-2026-0034',17,11,'2026-10-08 10:58:00','ELIGIBLE','Meets eligibility criteria','INTERVIEW_SCHEDULED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (35,'APP-2026-0035',18,4,'2026-10-09 10:05:00','ELIGIBLE','Meets eligibility criteria','INTERVIEWED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (36,'APP-2026-0036',18,10,'2026-10-10 10:12:00','ELIGIBLE','Meets eligibility criteria','SELECTED','Portal',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (37,'APP-2026-0037',19,1,'2026-10-11 10:19:00','ELIGIBLE','Meets eligibility criteria','OFFERED','Internal',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (38,'APP-2026-0038',19,5,'2026-10-12 10:26:00','NOT_ELIGIBLE','Minimum percentage/backlog criteria not met','REJECTED','Recruiter',3);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (39,'APP-2026-0039',20,2,'2026-10-13 10:33:00','ELIGIBLE','Meets eligibility criteria','APPLIED','Referral',2);
INSERT INTO applications (application_id,application_code,candidate_id,job_id,applied_at,eligibility_status,eligibility_reason,application_status,source,assigned_recruiter_id) VALUES (40,'APP-2026-0040',20,12,'2026-10-14 10:40:00','ELIGIBLE','Meets eligibility criteria','ELIGIBILITY_VERIFIED','Portal',3);

-- Application history: initial + current-state audit
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (1,NULL,'APPLIED','Application created',2,'2026-10-02 10:07:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (1,'APPLIED','SHORTLISTED','Sample workflow status update',2,DATE_ADD('2026-10-02 10:07:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (2,NULL,'APPLIED','Application created',3,'2026-10-03 10:14:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (2,'APPLIED','INTERVIEW_SCHEDULED','Sample workflow status update',3,DATE_ADD('2026-10-03 10:14:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (3,NULL,'APPLIED','Application created',2,'2026-10-04 10:21:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (3,'APPLIED','INTERVIEWED','Sample workflow status update',2,DATE_ADD('2026-10-04 10:21:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (4,NULL,'APPLIED','Application created',3,'2026-10-05 10:28:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (4,'APPLIED','SELECTED','Sample workflow status update',3,DATE_ADD('2026-10-05 10:28:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (5,NULL,'APPLIED','Application created',2,'2026-10-06 10:35:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (5,'APPLIED','OFFERED','Sample workflow status update',2,DATE_ADD('2026-10-06 10:35:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (6,NULL,'APPLIED','Application created',3,'2026-10-07 10:42:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (6,'APPLIED','REJECTED','Sample workflow status update',3,DATE_ADD('2026-10-07 10:42:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (7,NULL,'APPLIED','Application created',2,'2026-10-08 10:49:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (8,NULL,'APPLIED','Application created',3,'2026-10-09 10:56:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (8,'APPLIED','ELIGIBILITY_VERIFIED','Sample workflow status update',3,DATE_ADD('2026-10-09 10:56:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (9,NULL,'APPLIED','Application created',2,'2026-10-10 10:03:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (9,'APPLIED','SHORTLISTED','Sample workflow status update',2,DATE_ADD('2026-10-10 10:03:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (10,NULL,'APPLIED','Application created',3,'2026-10-11 10:10:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (10,'APPLIED','INTERVIEW_SCHEDULED','Sample workflow status update',3,DATE_ADD('2026-10-11 10:10:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (11,NULL,'APPLIED','Application created',2,'2026-10-12 10:17:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (11,'APPLIED','INTERVIEWED','Sample workflow status update',2,DATE_ADD('2026-10-12 10:17:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (12,NULL,'APPLIED','Application created',3,'2026-10-13 10:24:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (12,'APPLIED','SELECTED','Sample workflow status update',3,DATE_ADD('2026-10-13 10:24:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (13,NULL,'APPLIED','Application created',2,'2026-10-14 10:31:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (13,'APPLIED','OFFERED','Sample workflow status update',2,DATE_ADD('2026-10-14 10:31:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (14,NULL,'APPLIED','Application created',3,'2026-10-15 10:38:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (14,'APPLIED','REJECTED','Sample workflow status update',3,DATE_ADD('2026-10-15 10:38:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (15,NULL,'APPLIED','Application created',2,'2026-10-16 10:45:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (16,NULL,'APPLIED','Application created',3,'2026-10-17 10:52:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (16,'APPLIED','ELIGIBILITY_VERIFIED','Sample workflow status update',3,DATE_ADD('2026-10-17 10:52:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (17,NULL,'APPLIED','Application created',2,'2026-10-18 10:59:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (17,'APPLIED','SHORTLISTED','Sample workflow status update',2,DATE_ADD('2026-10-18 10:59:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (18,NULL,'APPLIED','Application created',3,'2026-10-19 10:06:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (18,'APPLIED','INTERVIEW_SCHEDULED','Sample workflow status update',3,DATE_ADD('2026-10-19 10:06:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (19,NULL,'APPLIED','Application created',2,'2026-10-20 10:13:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (19,'APPLIED','INTERVIEWED','Sample workflow status update',2,DATE_ADD('2026-10-20 10:13:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (20,NULL,'APPLIED','Application created',3,'2026-10-21 10:20:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (20,'APPLIED','SELECTED','Sample workflow status update',3,DATE_ADD('2026-10-21 10:20:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (21,NULL,'APPLIED','Application created',2,'2026-10-22 10:27:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (21,'APPLIED','OFFERED','Sample workflow status update',2,DATE_ADD('2026-10-22 10:27:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (22,NULL,'APPLIED','Application created',3,'2026-10-23 10:34:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (22,'APPLIED','REJECTED','Sample workflow status update',3,DATE_ADD('2026-10-23 10:34:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (23,NULL,'APPLIED','Application created',2,'2026-10-24 10:41:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (24,NULL,'APPLIED','Application created',3,'2026-10-25 10:48:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (24,'APPLIED','ELIGIBILITY_VERIFIED','Sample workflow status update',3,DATE_ADD('2026-10-25 10:48:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (25,NULL,'APPLIED','Application created',2,'2026-10-26 10:55:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (25,'APPLIED','SHORTLISTED','Sample workflow status update',2,DATE_ADD('2026-10-26 10:55:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (26,NULL,'APPLIED','Application created',3,'2026-10-27 10:02:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (26,'APPLIED','INTERVIEW_SCHEDULED','Sample workflow status update',3,DATE_ADD('2026-10-27 10:02:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (27,NULL,'APPLIED','Application created',2,'2026-10-01 10:09:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (27,'APPLIED','INTERVIEWED','Sample workflow status update',2,DATE_ADD('2026-10-01 10:09:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (28,NULL,'APPLIED','Application created',3,'2026-10-02 10:16:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (28,'APPLIED','SELECTED','Sample workflow status update',3,DATE_ADD('2026-10-02 10:16:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (29,NULL,'APPLIED','Application created',2,'2026-10-03 10:23:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (29,'APPLIED','OFFERED','Sample workflow status update',2,DATE_ADD('2026-10-03 10:23:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (30,NULL,'APPLIED','Application created',3,'2026-10-04 10:30:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (30,'APPLIED','REJECTED','Sample workflow status update',3,DATE_ADD('2026-10-04 10:30:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (31,NULL,'APPLIED','Application created',2,'2026-10-05 10:37:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (32,NULL,'APPLIED','Application created',3,'2026-10-06 10:44:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (32,'APPLIED','ELIGIBILITY_VERIFIED','Sample workflow status update',3,DATE_ADD('2026-10-06 10:44:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (33,NULL,'APPLIED','Application created',2,'2026-10-07 10:51:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (33,'APPLIED','SHORTLISTED','Sample workflow status update',2,DATE_ADD('2026-10-07 10:51:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (34,NULL,'APPLIED','Application created',3,'2026-10-08 10:58:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (34,'APPLIED','INTERVIEW_SCHEDULED','Sample workflow status update',3,DATE_ADD('2026-10-08 10:58:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (35,NULL,'APPLIED','Application created',2,'2026-10-09 10:05:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (35,'APPLIED','INTERVIEWED','Sample workflow status update',2,DATE_ADD('2026-10-09 10:05:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (36,NULL,'APPLIED','Application created',3,'2026-10-10 10:12:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (36,'APPLIED','SELECTED','Sample workflow status update',3,DATE_ADD('2026-10-10 10:12:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (37,NULL,'APPLIED','Application created',2,'2026-10-11 10:19:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (37,'APPLIED','OFFERED','Sample workflow status update',2,DATE_ADD('2026-10-11 10:19:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (38,NULL,'APPLIED','Application created',3,'2026-10-12 10:26:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (38,'APPLIED','REJECTED','Sample workflow status update',3,DATE_ADD('2026-10-12 10:26:00', INTERVAL 1 DAY));
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (39,NULL,'APPLIED','Application created',2,'2026-10-13 10:33:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (40,NULL,'APPLIED','Application created',3,'2026-10-14 10:40:00');
INSERT INTO application_history (application_id,old_status,new_status,remarks,changed_by,changed_at) VALUES (40,'APPLIED','ELIGIBILITY_VERIFIED','Sample workflow status update',3,DATE_ADD('2026-10-14 10:40:00', INTERVAL 1 DAY));

-- Interview rounds
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (1,2,1,'TECHNICAL','2026-11-03','11:00:00','ONLINE','Interviewer 2','https://meet.example.com/rpms-2','SCHEDULED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (2,3,1,'TECHNICAL','2026-11-04','11:00:00','ONLINE','Interviewer 3','https://meet.example.com/rpms-3','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (3,4,1,'TECHNICAL','2026-11-05','11:00:00','ONLINE','Interviewer 4','https://meet.example.com/rpms-4','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (4,5,1,'TECHNICAL','2026-11-06','11:00:00','ONLINE','Interviewer 5','https://meet.example.com/rpms-5','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (5,10,1,'TECHNICAL','2026-11-11','11:00:00','ONLINE','Interviewer 5','https://meet.example.com/rpms-10','SCHEDULED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (6,11,1,'TECHNICAL','2026-11-12','11:00:00','ONLINE','Interviewer 1','https://meet.example.com/rpms-11','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (7,12,1,'TECHNICAL','2026-11-13','11:00:00','ONLINE','Interviewer 2','https://meet.example.com/rpms-12','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (8,13,1,'TECHNICAL','2026-11-14','11:00:00','ONLINE','Interviewer 3','https://meet.example.com/rpms-13','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (9,18,1,'TECHNICAL','2026-11-19','11:00:00','ONLINE','Interviewer 3','https://meet.example.com/rpms-18','SCHEDULED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (10,19,1,'TECHNICAL','2026-11-20','11:00:00','ONLINE','Interviewer 4','https://meet.example.com/rpms-19','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (11,20,1,'TECHNICAL','2026-11-01','11:00:00','ONLINE','Interviewer 5','https://meet.example.com/rpms-20','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (12,21,1,'TECHNICAL','2026-11-02','11:00:00','ONLINE','Interviewer 1','https://meet.example.com/rpms-21','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (13,26,1,'TECHNICAL','2026-11-07','11:00:00','ONLINE','Interviewer 1','https://meet.example.com/rpms-26','SCHEDULED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (14,27,1,'TECHNICAL','2026-11-08','11:00:00','ONLINE','Interviewer 2','https://meet.example.com/rpms-27','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (15,28,1,'TECHNICAL','2026-11-09','11:00:00','ONLINE','Interviewer 3','https://meet.example.com/rpms-28','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (16,29,1,'TECHNICAL','2026-11-10','11:00:00','ONLINE','Interviewer 4','https://meet.example.com/rpms-29','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (17,34,1,'TECHNICAL','2026-11-15','11:00:00','ONLINE','Interviewer 4','https://meet.example.com/rpms-34','SCHEDULED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (18,35,1,'TECHNICAL','2026-11-16','11:00:00','ONLINE','Interviewer 5','https://meet.example.com/rpms-35','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (19,36,1,'TECHNICAL','2026-11-17','11:00:00','ONLINE','Interviewer 1','https://meet.example.com/rpms-36','COMPLETED');
INSERT INTO interview_rounds (interview_id,application_id,round_number,round_type,scheduled_date,scheduled_time,mode,interviewer_name,meeting_or_location,status) VALUES (20,37,1,'TECHNICAL','2026-11-18','11:00:00','ONLINE','Interviewer 2','https://meet.example.com/rpms-37','COMPLETED');

-- Interview feedback
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (1,2,4.0,3.5,4.0,3.8,'NEXT_ROUND','Good fundamentals; continue to next stage.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (2,3,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',3);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (3,4,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (4,6,4.0,3.5,4.0,3.8,'NEXT_ROUND','Good fundamentals; continue to next stage.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (5,7,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',3);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (6,8,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (7,10,4.0,3.5,4.0,3.8,'NEXT_ROUND','Good fundamentals; continue to next stage.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (8,11,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',3);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (9,12,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (10,14,4.0,3.5,4.0,3.8,'NEXT_ROUND','Good fundamentals; continue to next stage.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (11,15,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',3);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (12,16,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (13,18,4.0,3.5,4.0,3.8,'NEXT_ROUND','Good fundamentals; continue to next stage.',2);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (14,19,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',3);
INSERT INTO interview_feedback (feedback_id,interview_id,technical_rating,communication_rating,problem_solving_rating,overall_rating,recommendation,remarks,submitted_by) VALUES (15,20,4.0,3.5,4.0,3.8,'SELECTED','Recommended for selection.',2);

-- Offers
INSERT INTO offers (offer_id,offer_code,application_id,designation,offered_package_lpa,offer_date,expected_joining_date,offer_status,remarks) VALUES (1,'OFF-2026-001',5,'Associate Java Developer',4.3,'2026-11-11','2026-12-02','ACCEPTED','Sample offer record');
INSERT INTO offers (offer_id,offer_code,application_id,designation,offered_package_lpa,offer_date,expected_joining_date,offer_status,remarks) VALUES (2,'OFF-2026-002',13,'QA Engineer Trainee',4.1,'2026-11-12','2026-12-03','ACCEPTED','Sample offer record');
INSERT INTO offers (offer_id,offer_code,application_id,designation,offered_package_lpa,offer_date,expected_joining_date,offer_status,remarks) VALUES (3,'OFF-2026-003',21,'Associate Java Developer',4.3,'2026-11-13','2026-12-04','ACCEPTED','Sample offer record');
INSERT INTO offers (offer_id,offer_code,application_id,designation,offered_package_lpa,offer_date,expected_joining_date,offer_status,remarks) VALUES (4,'OFF-2026-004',29,'Associate Java Developer',4.3,'2026-11-14','2026-12-05','OFFERED','Sample offer record');
INSERT INTO offers (offer_id,offer_code,application_id,designation,offered_package_lpa,offer_date,expected_joining_date,offer_status,remarks) VALUES (5,'OFF-2026-005',4,'Junior Data Analyst',4.3,'2026-11-15','2026-12-06','ACCEPTED','Sample offer record');
INSERT INTO offers (offer_id,offer_code,application_id,designation,offered_package_lpa,offer_date,expected_joining_date,offer_status,remarks) VALUES (6,'OFF-2026-006',12,'BI Analyst Trainee',4.8,'2026-11-16','2026-12-07','OFFERED','Sample offer record');

-- Placements
INSERT INTO placements (placement_id,candidate_id,company_id,job_id,offer_id,designation,final_package_lpa,expected_joining_date,actual_joining_date,joining_status,placement_status) VALUES (1,3,1,1,1,'Associate Java Developer',4.3,'2026-12-02','2026-12-02','JOINED','ACTIVE');
INSERT INTO placements (placement_id,candidate_id,company_id,job_id,offer_id,designation,final_package_lpa,expected_joining_date,actual_joining_date,joining_status,placement_status) VALUES (2,7,4,4,2,'QA Engineer Trainee',4.1,'2026-12-03','2026-12-03','JOINED','ACTIVE');
INSERT INTO placements (placement_id,candidate_id,company_id,job_id,offer_id,designation,final_package_lpa,expected_joining_date,actual_joining_date,joining_status,placement_status) VALUES (3,11,1,1,3,'Associate Java Developer',4.3,'2026-12-04','2026-12-04','JOINED','ACTIVE');

UPDATE candidates SET placement_status='PLACED' WHERE candidate_id IN (3,7,11);

-- Activity logs
INSERT INTO activity_logs (user_id,module_name,action_name,record_id,description) VALUES (1,'USER','LOGIN','1','Admin logged in');
INSERT INTO activity_logs (user_id,module_name,action_name,record_id,description) VALUES (2,'JOB','CREATE','JOB-2026-001','Created Java job opening');
INSERT INTO activity_logs (user_id,module_name,action_name,record_id,description) VALUES (3,'APPLICATION','SHORTLIST','APP-2026-0001','Candidate shortlisted');
INSERT INTO activity_logs (user_id,module_name,action_name,record_id,description) VALUES (4,'OFFER','CREATE','OFF-2026-001','Offer created');
INSERT INTO activity_logs (user_id,module_name,action_name,record_id,description) VALUES (5,'PLACEMENT','JOINING','1','Candidate marked as joined');

-- =========================================================
-- Sample verification queries
-- =========================================================
SELECT COUNT(*) AS candidates FROM candidates;
SELECT COUNT(*) AS companies FROM companies;
SELECT COUNT(*) AS jobs FROM jobs;
SELECT COUNT(*) AS applications FROM applications;
SELECT COUNT(*) AS interviews FROM interview_rounds;
SELECT COUNT(*) AS offers FROM offers;
SELECT COUNT(*) AS placements FROM placements;

-- Company-wise placements
SELECT c.company_name,
       COUNT(p.placement_id) AS placed_count
FROM placements p
JOIN companies c ON c.company_id = p.company_id
WHERE p.joining_status='JOINED'
GROUP BY c.company_id, c.company_name
ORDER BY placed_count DESC;

-- Applications by status
SELECT application_status, COUNT(*) AS total
FROM applications
GROUP BY application_status
ORDER BY total DESC;
