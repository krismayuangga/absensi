-- =============================================
-- DATABASE SCHEMA: ATTENDANCE & KPI SYSTEM
-- =============================================

CREATE DATABASE IF NOT EXISTS `attendance_kpi` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `attendance_kpi`;

-- =============================================
-- TABLE: companies (Multi-tenant support)
-- =============================================
CREATE TABLE `companies` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text,
  `logo` varchar(255) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT 'Asia/Jakarta',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `companies_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE: departments
-- =============================================
CREATE TABLE `departments` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `head_id` bigint UNSIGNED DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `departments_company_id_foreign` (`company_id`),
  KEY `departments_head_id_foreign` (`head_id`),
  CONSTRAINT `departments_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE: positions
-- =============================================
CREATE TABLE `positions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `department_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `level` int NOT NULL DEFAULT '1',
  `base_salary` decimal(15,2) DEFAULT '0.00',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `positions_department_id_foreign` (`department_id`),
  CONSTRAINT `positions_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE: shifts
-- =============================================
CREATE TABLE `shifts` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `break_start` time DEFAULT NULL,
  `break_end` time DEFAULT NULL,
  `late_tolerance` int DEFAULT '15' COMMENT 'minutes',
  `early_leave_tolerance` int DEFAULT '15' COMMENT 'minutes',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shifts_company_id_foreign` (`company_id`),
  CONSTRAINT `shifts_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE: users (Employees + Admins)
-- =============================================
CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_id` bigint UNSIGNED NOT NULL,
  `employee_id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `gender` enum('male','female') DEFAULT NULL,
  `address` text,
  `avatar` varchar(255) DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `position_id` bigint UNSIGNED DEFAULT NULL,
  `shift_id` bigint UNSIGNED DEFAULT NULL,
  `manager_id` bigint UNSIGNED DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  `salary` decimal(15,2) DEFAULT '0.00',
  `role` enum('superadmin','admin','hr','employee') DEFAULT 'employee',
  `status` enum('active','inactive','terminated') DEFAULT 'active',
  `face_data` text COMMENT 'Face recognition data',
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_employee_id_company_unique` (`employee_id`,`company_id`),
  KEY `users_company_id_foreign` (`company_id`),
  KEY `users_department_id_foreign` (`department_id`),
  KEY `users_position_id_foreign` (`position_id`),
  KEY `users_shift_id_foreign` (`shift_id`),
  KEY `users_manager_id_foreign` (`manager_id`),
  CONSTRAINT `users_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `users_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_position_id_foreign` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_shift_id_foreign` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE: locations (Office locations for GPS)
-- =============================================
CREATE TABLE `locations` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` text NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `radius` int NOT NULL DEFAULT '100' COMMENT 'meters',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `locations_company_id_foreign` (`company_id`),
  CONSTRAINT `locations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE: attendances
-- =============================================
CREATE TABLE `attendances` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `clock_in` datetime DEFAULT NULL,
  `clock_out` datetime DEFAULT NULL,
  `break_start` datetime DEFAULT NULL,
  `break_end` datetime DEFAULT NULL,
  `clock_in_location_id` bigint UNSIGNED DEFAULT NULL,
  `clock_out_location_id` bigint UNSIGNED DEFAULT NULL,
  `clock_in_latitude` decimal(10,8) DEFAULT NULL,
  `clock_in_longitude` decimal(11,8) DEFAULT NULL,
  `clock_out_latitude` decimal(10,8) DEFAULT NULL,
  `clock_out_longitude` decimal(11,8) DEFAULT NULL,
  `clock_in_photo` varchar(255) DEFAULT NULL,
  `clock_out_photo` varchar(255) DEFAULT NULL,
  `notes` text,
  `status` enum('present','late','early_leave','absent','holiday') DEFAULT 'present',
  `total_hours` decimal(5,2) DEFAULT '0.00',
  `overtime_hours` decimal(5,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `attendances_user_date_unique` (`user_id`,`date`),
  KEY `attendances_clock_in_location_id_foreign` (`clock_in_location_id`),
  KEY `attendances_clock_out_location_id_foreign` (`clock_out_location_id`),
  CONSTRAINT `attendances_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attendances_clock_in_location_id_foreign` FOREIGN KEY (`clock_in_location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `attendances_clock_out_location_id_foreign` FOREIGN KEY (`clock_out_location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLE: leaves (Izin/Cuti)
-- =============================================
CREATE TABLE `leaves` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `type` enum('sick','annual','maternity','emergency','other') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `days` int NOT NULL,
  `reason` text NOT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `approved_by` bigint UNSIGNED DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `leaves_user_id_foreign` (`user_id`),
  KEY `leaves_approved_by_foreign` (`approved_by`),
  CONSTRAINT `leaves_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leaves_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- KPI SYSTEM TABLES
-- =============================================

-- TABLE: kpi_categories
CREATE TABLE `kpi_categories` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `weight` decimal(5,2) DEFAULT '1.00' COMMENT 'Weight in percentage',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kpi_categories_company_id_foreign` (`company_id`),
  CONSTRAINT `kpi_categories_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE: kpi_templates
CREATE TABLE `kpi_templates` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_id` bigint UNSIGNED NOT NULL,
  `position_id` bigint UNSIGNED DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `period_type` enum('monthly','quarterly','yearly') DEFAULT 'monthly',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kpi_templates_company_id_foreign` (`company_id`),
  KEY `kpi_templates_position_id_foreign` (`position_id`),
  KEY `kpi_templates_department_id_foreign` (`department_id`),
  CONSTRAINT `kpi_templates_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `kpi_templates_position_id_foreign` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `kpi_templates_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE: kpi_indicators
CREATE TABLE `kpi_indicators` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `kpi_template_id` bigint UNSIGNED NOT NULL,
  `category_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `measurement_unit` varchar(50) DEFAULT NULL,
  `target_value` decimal(15,2) NOT NULL,
  `weight` decimal(5,2) DEFAULT '1.00' COMMENT 'Weight in percentage',
  `calculation_type` enum('sum','average','percentage','count') DEFAULT 'sum',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kpi_indicators_template_id_foreign` (`kpi_template_id`),
  KEY `kpi_indicators_category_id_foreign` (`category_id`),
  CONSTRAINT `kpi_indicators_template_id_foreign` FOREIGN KEY (`kpi_template_id`) REFERENCES `kpi_templates` (`id`) ON DELETE CASCADE,
  CONSTRAINT `kpi_indicators_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `kpi_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE: user_kpis (Employee KPI Assignments)
CREATE TABLE `user_kpis` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `kpi_template_id` bigint UNSIGNED NOT NULL,
  `period_year` year NOT NULL,
  `period_month` tinyint DEFAULT NULL,
  `period_quarter` tinyint DEFAULT NULL,
  `status` enum('active','completed','cancelled') DEFAULT 'active',
  `total_score` decimal(5,2) DEFAULT '0.00',
  `grade` enum('A','B','C','D','E') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_kpis_unique` (`user_id`,`kpi_template_id`,`period_year`,`period_month`,`period_quarter`),
  KEY `user_kpis_user_id_foreign` (`user_id`),
  KEY `user_kpis_kpi_template_id_foreign` (`kpi_template_id`),
  CONSTRAINT `user_kpis_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_kpis_kpi_template_id_foreign` FOREIGN KEY (`kpi_template_id`) REFERENCES `kpi_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE: kpi_scores
CREATE TABLE `kpi_scores` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_kpi_id` bigint UNSIGNED NOT NULL,
  `kpi_indicator_id` bigint UNSIGNED NOT NULL,
  `actual_value` decimal(15,2) DEFAULT '0.00',
  `score` decimal(5,2) DEFAULT '0.00' COMMENT 'Score 0-100',
  `notes` text,
  `evidence` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `kpi_scores_unique` (`user_kpi_id`,`kpi_indicator_id`),
  KEY `kpi_scores_user_kpi_id_foreign` (`user_kpi_id`),
  KEY `kpi_scores_kpi_indicator_id_foreign` (`kpi_indicator_id`),
  CONSTRAINT `kpi_scores_user_kpi_id_foreign` FOREIGN KEY (`user_kpi_id`) REFERENCES `user_kpis` (`id`) ON DELETE CASCADE,
  CONSTRAINT `kpi_scores_kpi_indicator_id_foreign` FOREIGN KEY (`kpi_indicator_id`) REFERENCES `kpi_indicators` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INDEXES for Performance
-- =============================================
CREATE INDEX idx_attendances_date ON attendances(date);
CREATE INDEX idx_attendances_status ON attendances(status);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_leaves_status ON leaves(status);
CREATE INDEX idx_leaves_dates ON leaves(start_date, end_date);

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Insert sample company
INSERT INTO `companies` (`id`, `name`, `email`, `phone`, `address`, `timezone`, `status`, `created_at`, `updated_at`) VALUES
(1, 'PT Tech Innovation', 'admin@techinnovation.com', '021-1234567', 'Jakarta Selatan', 'Asia/Jakarta', 'active', NOW(), NOW());

-- Insert sample departments
INSERT INTO `departments` (`id`, `company_id`, `name`, `description`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'IT Development', 'Information Technology Development', 'active', NOW(), NOW()),
(2, 1, 'Human Resources', 'Human Resources Management', 'active', NOW(), NOW()),
(3, 1, 'Finance', 'Finance and Accounting', 'active', NOW(), NOW());

-- Insert sample positions
INSERT INTO `positions` (`id`, `department_id`, `name`, `level`, `base_salary`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Senior Developer', 3, 15000000.00, 'active', NOW(), NOW()),
(2, 1, 'Junior Developer', 1, 8000000.00, 'active', NOW(), NOW()),
(3, 2, 'HR Manager', 4, 12000000.00, 'active', NOW(), NOW()),
(4, 3, 'Finance Staff', 2, 7000000.00, 'active', NOW(), NOW());

-- Insert sample shifts
INSERT INTO `shifts` (`id`, `company_id`, `name`, `start_time`, `end_time`, `late_tolerance`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Regular Shift', '08:00:00', '17:00:00', 15, 'active', NOW(), NOW()),
(2, 1, 'Early Shift', '06:00:00', '15:00:00', 10, 'active', NOW(), NOW());

-- Insert sample location
INSERT INTO `locations` (`id`, `company_id`, `name`, `address`, `latitude`, `longitude`, `radius`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Head Office', 'Jakarta Selatan', -6.2608, 106.7811, 100, 'active', NOW(), NOW());

-- Insert sample admin user
INSERT INTO `users` (`id`, `company_id`, `employee_id`, `name`, `email`, `password`, `department_id`, `position_id`, `shift_id`, `role`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'ADMIN001', 'System Administrator', 'admin@techinnovation.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 2, 3, 1, 'admin', 'active', NOW(), NOW());

-- Insert sample KPI categories
INSERT INTO `kpi_categories` (`id`, `company_id`, `name`, `description`, `weight`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Productivity', 'Produktivitas kerja karyawan', 40.00, 'active', NOW(), NOW()),
(2, 1, 'Quality', 'Kualitas hasil kerja', 30.00, 'active', NOW(), NOW()),
(3, 1, 'Teamwork', 'Kemampuan bekerja dalam tim', 20.00, 'active', NOW(), NOW()),
(4, 1, 'Initiative', 'Inisiatif dan inovasi', 10.00, 'active', NOW(), NOW());

-- Insert sample KPI template
INSERT INTO `kpi_templates` (`id`, `company_id`, `position_id`, `name`, `description`, `period_type`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Senior Developer KPI', 'KPI template for Senior Developer position', 'monthly', 'active', NOW(), NOW());

-- Insert sample KPI indicators
INSERT INTO `kpi_indicators` (`id`, `kpi_template_id`, `category_id`, `name`, `description`, `target_value`, `weight`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Tasks Completed', 'Number of tasks completed per month', 20.00, 25.00, NOW(), NOW()),
(2, 1, 2, 'Bug Rate', 'Number of bugs per 100 lines of code', 2.00, 25.00, NOW(), NOW()),
(3, 1, 3, 'Team Collaboration', 'Team collaboration score', 85.00, 25.00, NOW(), NOW()),
(4, 1, 4, 'Innovation Ideas', 'Number of innovation ideas submitted', 3.00, 25.00, NOW(), NOW());
