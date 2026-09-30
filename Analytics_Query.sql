SELECT 
    c.title AS recommended_content,
    COUNT(DISTINCT ss2.profile_id) AS co_watch_count
FROM streaming_sessions ss1
JOIN streaming_sessions ss2 ON ss1.profile_id = ss2.profile_id
JOIN content c ON ss2.content_id = c.content_id
WHERE ss1.content_id = 1       -- ID Konten acuan the matrix
  AND ss2.content_id != 1      -- Mengecualikan konten itu sendiri
GROUP BY c.title
ORDER BY co_watch_count DESC –-jml penonton bersama
LIMIT 5;

SELECT 
    d.device_type,
    COUNT(s.session_id) AS total_sessions,
    ROUND(AVG(s.average_bitrate_kbps), 2) AS avg_bitrate_kbps
FROM streaming_sessions s
JOIN devices d ON s.device_id = d.device_id –-untuk tau jenis perangkatnya
GROUP BY d.device_type
ORDER BY avg_bitrate_kbps DESC;

SELECT 
    c.content_id,
    c.title,
    c.content_type,
    cr.country_code,
    cr.available_from,
    cr.available_to
FROM content_regions cr
JOIN content c ON cr.content_id = c.content_id
WHERE cr.country_code = 'ID'
  AND CURRENT_TIMESTAMP BETWEEN cr.available_from AND cr.available_to;

SELECT 
    od.download_id,
    c.title,
    d.device_type,
    od.expires_at
FROM offline_downloads od
JOIN content c ON od.content_id = c.content_id
JOIN devices d ON od.device_id = d.device_id
WHERE od.expires_at > CURRENT_TIMESTAMP;

SELECT 
    u.user_id,
    u.email,
    sub.plan_name,
    sub.end_date
FROM users u
JOIN subscriptions sub ON u.user_id = sub.user_id
WHERE sub.status = 'Active' 
  AND sub.end_date BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '7 days'
  AND u.user_id NOT IN (
      SELECT DISTINCT up.user_id
      FROM streaming_sessions ss
      JOIN user_profiles up ON ss.profile_id = up.profile_id
      WHERE ss.start_time >= CURRENT_TIMESTAMP - INTERVAL '14 days' –-punya Riwayat 14 hari ini
  );

SELECT 
    e.experiment_name,
    e.variant,
    e.description,
    COUNT(ue.user_id) AS total_exposed_users
FROM user_experiment_exposures ue
JOIN experiments e ON ue.experiment_id = e.experiment_id
GROUP BY e.experiment_name, e.variant, e.description
ORDER BY e.experiment_name, total_exposed_users DESC;
