-- IMPORT DATABASE UNTUK DOCKER MYSQL
-- User: admin@test.com / Password: 123456

USE attendance_kpi;

-- Reset database
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS companies, departments, positions, shifts, locations, users, employees, attendances, announcements, kpi_categories, kpi_templates, kpi_indicators, kpi_evaluations;
SET FOREIGN_KEY_CHECKS = 1;

-- Companies
CREATE TABLE companies (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    logo VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'Asia/Jakarta',
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Departments
CREATE TABLE departments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    head_id BIGINT UNSIGNED NULL,
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Positions
CREATE TABLE positions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    department_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    level ENUM('staff','supervisor','manager','director') DEFAULT 'staff',
    base_salary DECIMAL(15,2) DEFAULT 0,
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE
);

-- Shifts
CREATE TABLE shifts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    late_tolerance INT DEFAULT 15,
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Locations
CREATE TABLE locations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    radius INT DEFAULT 100,
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Users
CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    employee_id VARCHAR(20) UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    department_id BIGINT UNSIGNED NULL,
    position_id BIGINT UNSIGNED NULL,
    shift_id BIGINT UNSIGNED NULL,
    phone VARCHAR(20),
    avatar VARCHAR(255),
    role ENUM('admin','hr','manager','employee') DEFAULT 'employee',
    status ENUM('active','inactive','suspended') DEFAULT 'active',
    remember_token VARCHAR(100),
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE SET NULL,
    FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE SET NULL
);

-- Announcements
CREATE TABLE announcements (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100),
    priority ENUM('low','medium','high','urgent') DEFAULT 'medium',
    status ENUM('draft','published','archived') DEFAULT 'draft',
    published_at TIMESTAMP NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- INSERT SAMPLE DATA

-- Company
INSERT INTO companies (id, name, email, phone, address, status) VALUES 
(1, 'Tech Innovation Corp', 'admin@test.com', '+62-21-1234567', 'Jakarta, Indonesia', 'active');

-- Departments
INSERT INTO departments (id, company_id, name, description, status) VALUES 
(1, 1, 'Information Technology', 'IT Department', 'active'),
(2, 1, 'Human Resources', 'HR Department', 'active'),
(3, 1, 'Finance', 'Finance Department', 'active');

-- Positions
INSERT INTO positions (id, department_id, name, level, base_salary, status) VALUES 
(1, 1, 'System Administrator', 'manager', 15000000, 'active'),
(2, 1, 'Software Developer', 'staff', 10000000, 'active'),
(3, 2, 'HR Manager', 'manager', 12000000, 'active'),
(4, 3, 'Finance Manager', 'manager', 12000000, 'active');

-- Shifts
INSERT INTO shifts (id, company_id, name, start_time, end_time, late_tolerance, status) VALUES 
(1, 1, 'Regular Shift', '08:00:00', '17:00:00', 15, 'active'),
(2, 1, 'Morning Shift', '06:00:00', '15:00:00', 15, 'active');

-- Locations
INSERT INTO locations (id, company_id, name, address, latitude, longitude, radius, status) VALUES 
(1, 1, 'Head Office', 'Jakarta Pusat', -6.2000000, 106.8166700, 50, 'active');

-- Admin User (admin@test.com / 123456)
INSERT INTO users (id, company_id, employee_id, name, email, password, department_id, position_id, shift_id, role, status) VALUES 
(1, 1, 'ADM001', 'Administrator', 'admin@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 1, 1, 'admin', 'active');

-- Sample Employees
INSERT INTO users (id, company_id, employee_id, name, email, password, department_id, position_id, shift_id, role, status) VALUES 
(2, 1, 'DEV001', 'John Developer', 'john@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 2, 1, 'employee', 'active'),
(3, 1, 'HR001', 'Sarah HR', 'sarah@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 2, 3, 1, 'hr', 'active'),
(4, 1, 'FIN001', 'Mike Finance', 'mike@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 3, 4, 1, 'employee', 'active');

-- Sample Announcements
INSERT INTO announcements (id, company_id, title, content, category, priority, status, published_at, created_by) VALUES 
(1, 1, 'Welcome to New System', 'Welcome to our new attendance and KPI management system. Please explore all features.', 'general', 'high', 'published', NOW(), 1),
(2, 1, 'System Maintenance', 'System maintenance will be conducted on Sunday from 01:00 to 03:00 AM.', 'maintenance', 'medium', 'published', NOW(), 1),
(3, 1, 'New Policy Update', 'Updated attendance policy. Please read carefully.', 'policy', 'high', 'published', NOW(), 1),
(4, 1, 'Holiday Announcement', 'Company holiday schedule for next month.', 'holiday', 'low', 'published', NOW(), 1);
