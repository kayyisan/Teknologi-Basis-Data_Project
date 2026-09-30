-- ---------------------------------------------------------
-- 1. INSERT DATA KATALOG KONTEN & METADATA
-- ---------------------------------------------------------

INSERT INTO content (title, description, release_year, content_type, duration_minutes) VALUES
('The Matrix', 'Hacker discovers reality is a simulation.', 1999, 'Movie', 136),
('Stranger Things', 'Kids fight monsters from the Upside Down.', 2016, 'Series', NULL),
('Inception', 'Thieves steal secrets through dreams.', 2010, 'Movie', 148),
('Planet Earth II', 'Nature documentary.', 2016, 'Series', NULL);

INSERT INTO episodes (content_id, season_number, episode_number, duration_minutes, title) VALUES
(2, 1, 1, 48, 'Chapter One: The Vanishing of Will Byers'),
(2, 1, 2, 55, 'Chapter Two: The Weirdo on Maple Street'),
(4, 1, 1, 51, 'Islands');

INSERT INTO genres (name) VALUES ('Sci-Fi'), ('Action'), ('Thriller'), ('Documentary');

INSERT INTO content_genres (content_id, genre_id) VALUES
(1, 1), (1, 2), (2, 1), (2, 3), (3, 1), (3, 2), (4, 4);

INSERT INTO cast_members (first_name, last_name) VALUES
('Keanu', 'Reeves'), ('Millie Bobby', 'Brown'), ('Leonardo', 'DiCaprio');

INSERT INTO content_cast (content_id, cast_id) VALUES
(1, 1), (2, 2), (3, 3);

INSERT INTO audio_subtitles (content_id, language_name, track_type) VALUES
(1, 'English', 'Audio'), (1, 'Indonesian', 'Subtitle'), (2, 'English', 'Audio');

-- ---------------------------------------------------------
-- 2. INSERT DATA PENGGUNA & PERANGKAT
-- ---------------------------------------------------------

INSERT INTO users (email, password_hash, full_name, created_at) VALUES
('alice@email.com', 'hash123', 'Alice Smith', '2026-09-01 10:00:00'),
('bob@email.com', 'hash456', 'Bob Johnson', '2026-09-05 14:30:00'),
('charlie@email.com', 'hash789', 'Charlie Brown', '2026-09-10 09:15:00');

INSERT INTO user_profiles (user_id, profile_name, is_kids_mode) VALUES
(1, 'Alice', FALSE), (1, 'Kids', TRUE), 
(2, 'Bob', FALSE), 
(3, 'Charlie', FALSE);

INSERT INTO subscriptions (user_id, plan_name, status, start_date, end_date) VALUES
(1, 'Premium', 'Active', '2026-09-01 10:00:00', '2026-10-01 10:00:00'),
-- Charlie adalah simulasi akun yang akan Churn (habis dlm 7 hari & tidak aktif)
(3, 'Basic', 'Active', '2026-09-10 09:15:00', '2026-10-05 09:15:00'),
-- Bob adalah simulasi akun yang sudah expired
(2, 'Standard', 'Expired', '2026-08-05 14:30:00', '2026-09-05 14:30:00');

INSERT INTO devices (device_type, os_version) VALUES
('Smart TV', 'WebOS'), ('Mobile', 'Android 14'), ('Web', 'Chrome OS');

-- Misal: The Matrix (content_id = 1) bisa ditonton di Indonesia dan US saat ini
INSERT INTO content_regions (content_id, country_code, available_from, available_to) VALUES
(1, 'ID', '2026-01-01 00:00:00', '2026-12-31 23:59:59'),
(1, 'US', '2026-01-01 00:00:00', '2026-12-31 23:59:59'),
-- Misal: Inception (content_id = 3) lisensinya khusus di Indonesia saja dan sudah habis (expired)
(3, 'ID', '2025-01-01 00:00:00', '2025-12-31 23:59:59');

-- ---------------------------------------------------------
-- 3. INSERT DATA TRANSAKSIONAL (ANALITIK & OFFLINE)
-- ---------------------------------------------------------

INSERT INTO streaming_sessions (profile_id, content_id, episode_id, device_id, start_time, end_time, average_bitrate_kbps) VALUES
-- Sesi Alice (nonton The Matrix & Inception di Smart TV, bitrate bagus)
(1, 1, NULL, 1, '2026-09-28 20:00:00', '2026-09-28 22:16:00', 4500),
(1, 3, NULL, 1, '2026-09-29 19:30:00', '2026-09-29 21:58:00', 4300),

-- Sesi anak Alice (nonton Planet Earth II episode 1 di Mobile, bitrate rendah)
(2, 4, 3, 2, '2026-09-28 15:00:00', '2026-09-28 15:51:00', 1200),

-- Sesi Bob (nonton Stranger Things episode 1 & 2 di Mobile)
(3, 2, 1, 2, '2026-09-02 21:00:00', '2026-09-02 21:48:00', 1500),
(3, 2, 2, 2, '2026-09-03 21:00:00', '2026-09-03 21:55:00', 1450),
(3, 1, NULL, 2, '2026-09-04 10:00:00', '2026-09-04 12:16:00', 1600);

-- Charlie sengaja TIDAK KITA MASUKKAN ke sesi streaming untuk simulasi CHURN.

INSERT INTO offline_downloads (profile_id, content_id, device_id, expires_at) VALUES
-- Alice mengunduh The Matrix (belum expired)
(1, 1, 2, '2026-10-05 20:00:00'),
-- Bob mengunduh Stranger Things (sudah expired karena batasnya tgl 10 Sept)
(3, 2, 2, '2026-09-10 21:00:00');

INSERT INTO experiments (experiment_name, variant, description) VALUES
('UI_Redesign_Homepage', 'Control', 'Tata letak thumbnail lama (standar)'),
('UI_Redesign_Homepage', 'Variant_A', 'Tata letak thumbnail baru dengan poster vertikal besar'),
('Checkout_Flow', 'Variant_B', 'Tombol berlangganan satu klik (One-click subscription)');

INSERT INTO user_experiment_exposures (user_id, experiment_id, exposed_at) VALUES
(1, 1, '2026-09-20 10:00:00'), -- Alice terekspos Control Homepage
(2, 2, '2026-09-21 11:30:00'), -- Bob terekspos Variant_A Homepage
(3, 2, '2026-09-22 14:15:00'); -- Charlie terekspos Variant_A Homepage
