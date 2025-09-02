-- Info & Media System Database Schema
-- Created: 2025-01-02

-- Admin Roles & Permissions
CREATE TABLE admin_roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    permissions JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default roles
INSERT INTO admin_roles (name, display_name, description, permissions) VALUES
('super_admin', 'Super Administrator', 'Full system access', '["*"]'),
('hr_admin', 'HR Administrator', 'HR and employee management', '["announcements.*", "media.*", "employees.view"]'),
('content_admin', 'Content Administrator', 'Content management only', '["announcements.create", "announcements.edit", "media.*"]');

-- Announcements Table
CREATE TABLE announcements (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    category VARCHAR(100) DEFAULT 'general',
    
    -- Scheduling
    start_date TIMESTAMP NULL,
    end_date TIMESTAMP NULL,
    is_scheduled BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Targeting
    target_type ENUM('all', 'department', 'role', 'specific') DEFAULT 'all',
    target_data JSON, -- Store department_ids, role_ids, or user_ids
    
    -- Push notification settings
    send_notification BOOLEAN DEFAULT TRUE,
    notification_sound BOOLEAN DEFAULT FALSE,
    notification_sent_at TIMESTAMP NULL,
    
    -- Metadata
    read_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    
    created_by BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_priority (priority),
    INDEX idx_active (is_active),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_category (category)
);

-- Media Gallery Table
CREATE TABLE media_gallery (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    file_type ENUM('image', 'document', 'video') NOT NULL,
    
    -- Organization
    category VARCHAR(100) DEFAULT 'general',
    tags JSON,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Permissions
    is_public BOOLEAN DEFAULT TRUE,
    target_type ENUM('all', 'department', 'role', 'specific') DEFAULT 'all',
    target_data JSON,
    
    -- Metadata
    download_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    
    uploaded_by BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_type (file_type),
    INDEX idx_category (category),
    INDEX idx_featured (is_featured),
    INDEX idx_public (is_public)
);

-- Announcement Interactions
CREATE TABLE announcement_interactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    announcement_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    interaction_type ENUM('read', 'like', 'unlike') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (announcement_id) REFERENCES announcements(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_announcement (announcement_id, user_id, interaction_type),
    INDEX idx_announcement (announcement_id),
    INDEX idx_user (user_id)
);

-- Announcement Comments
CREATE TABLE announcement_comments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    announcement_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    comment TEXT NOT NULL,
    parent_id BIGINT UNSIGNED NULL, -- For replies
    is_approved BOOLEAN DEFAULT TRUE,
    like_count INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (announcement_id) REFERENCES announcements(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES announcement_comments(id) ON DELETE CASCADE,
    INDEX idx_announcement (announcement_id),
    INDEX idx_user (user_id),
    INDEX idx_parent (parent_id),
    INDEX idx_approved (is_approved)
);

-- Comment Likes
CREATE TABLE comment_likes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    comment_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (comment_id) REFERENCES announcement_comments(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_comment (comment_id, user_id),
    INDEX idx_comment (comment_id),
    INDEX idx_user (user_id)
);

-- Push Notification Queue
CREATE TABLE notification_queue (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type ENUM('announcement', 'media', 'system') NOT NULL,
    reference_id BIGINT UNSIGNED,
    user_id BIGINT UNSIGNED,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSON,
    
    -- Scheduling
    send_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP NULL,
    status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
    attempts INT DEFAULT 0,
    error_message TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_send_at (send_at),
    INDEX idx_type (type),
    INDEX idx_user (user_id)
);

-- User Device Tokens (for push notifications)
CREATE TABLE user_device_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    device_token VARCHAR(500) NOT NULL,
    platform ENUM('android', 'ios') NOT NULL,
    app_version VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_token (user_id, device_token),
    INDEX idx_user (user_id),
    INDEX idx_active (is_active)
);
