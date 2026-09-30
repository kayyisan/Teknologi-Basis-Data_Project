-- =========================================================
-- SQL DDL: VOD STREAMING SERVICE SCHEMA (PostgreSQL)
-- =========================================================

-- ---------------------------------------------------------
-- A. DOMAIN PENGGUNA & TRANSAKSI
-- ---------------------------------------------------------

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    profile_name VARCHAR(100) NOT NULL,
    is_kids_mode BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    plan_name VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (status IN ('Active', 'Canceled', 'Expired'))
);

-- ---------------------------------------------------------
-- B. DOMAIN KATALOG KONTEN 
-- ---------------------------------------------------------

CREATE TABLE content (
    content_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year INT,
    content_type VARCHAR(20) NOT NULL,
    duration_minutes INT,
    CHECK (content_type IN ('Movie', 'Series'))
);

CREATE TABLE episodes (
    episode_id SERIAL PRIMARY KEY,
    content_id INT NOT NULL,
    season_number INT NOT NULL,
    episode_number INT NOT NULL,
    duration_minutes INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE
);

CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE content_genres (
    content_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (content_id, genre_id),
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE cast_members (
    cast_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

CREATE TABLE content_cast (
    content_id INT NOT NULL,
    cast_id INT NOT NULL,
    PRIMARY KEY (content_id, cast_id),
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE,
    FOREIGN KEY (cast_id) REFERENCES cast_members(cast_id) ON DELETE CASCADE
);

CREATE TABLE audio_subtitles (
    track_id SERIAL PRIMARY KEY,
    content_id INT NOT NULL,
    language_name VARCHAR(50) NOT NULL,
    track_type VARCHAR(20) NOT NULL,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE,
    CHECK (track_type IN ('Audio', 'Subtitle'))
);

CREATE TABLE content_regions (
    licensing_id SERIAL PRIMARY KEY,
    content_id INT NOT NULL,
    country_code VARCHAR(10) NOT NULL, -- Contoh: 'ID', 'US', 'SG'
    available_from TIMESTAMP NOT NULL,
    available_to TIMESTAMP NOT NULL,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- C. DOMAIN ANALITIK & EKSTENSI FITUR
-- ---------------------------------------------------------

CREATE TABLE devices (
    device_id SERIAL PRIMARY KEY,
    device_type VARCHAR(50) NOT NULL,
    os_version VARCHAR(50)
);

CREATE TABLE streaming_sessions (
    session_id SERIAL PRIMARY KEY,
    profile_id INT NOT NULL,
    content_id INT NOT NULL,
    episode_id INT, -- Kardinalitas 0..1 (NULLABLE, sengaja tidak pakai NOT NULL)
    device_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    average_bitrate_kbps INT,
    FOREIGN KEY (profile_id) REFERENCES user_profiles(profile_id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE,
    FOREIGN KEY (episode_id) REFERENCES episodes(episode_id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
);

CREATE TABLE offline_downloads (
    download_id SERIAL PRIMARY KEY,
    profile_id INT NOT NULL,
    content_id INT NOT NULL,
    device_id INT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES user_profiles(profile_id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
);

CREATE TABLE experiments (
    experiment_id SERIAL PRIMARY KEY,
    experiment_name VARCHAR(100) NOT NULL,
    variant VARCHAR(50) NOT NULL, -- Contoh: 'Control' atau 'Variant_A'
    description TEXT
);

CREATE TABLE user_experiment_exposures (
    exposure_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    experiment_id INT NOT NULL,
    exposed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (experiment_id) REFERENCES experiments(experiment_id) ON DELETE CASCADE
);


-- ==============================================================================
-- INDEXES FOR ANALYTIC WORKLOADS
-- ==============================================================================

-- 1. Index untuk fitur Churn Prediction (mempercepat pencarian langganan yang mau habis)
CREATE INDEX idx_subscriptions_status_end ON subscriptions(status, end_date);

-- 2. Index untuk metrik Retention & Daily Active Users (mempercepat filter log harian)
CREATE INDEX idx_sessions_start_profile ON streaming_sessions(start_time, profile_id);

-- 3. Index untuk algoritma Personalized Recommendation (mempercepat co-watch matrix)
CREATE INDEX idx_sessions_profile_content ON streaming_sessions(profile_id, content_id);

-- 4. Index untuk Quality of Experience / QoE (mempercepat hitung rata-rata bitrate)
CREATE INDEX idx_sessions_content_bitrate ON streaming_sessions(content_id, average_bitrate_kbps);

-- 5. Index untuk Offline Tracking (mempercepat pemindaian lisensi yang kedaluwarsa)
CREATE INDEX idx_offline_expires_at ON offline_downloads(expires_at);
