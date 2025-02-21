Design:
- Artist Info
list: cover_art, name, begin-end year, area, links, open in mbdb button, play in lb button, tags, listen stats, ratings

Tabs:
1. Overview:


Todo:

1. missing icons
2. cover art
3. top recordings
  - cover art
  - artist credits



Resources:

https://github.com/rails-api/active_model_serializers/blob/v0.10.6/docs/general/getting_started.md




# Artists recordings
https://community.metabrainz.org/t/getting-dates-of-recordings-releases-release-groups-from-db-dumps/570195
https://github.com/metabrainz/musicbrainz-server/blob/7c01629a52e11335c1475b273d84a4abe9d628fa/lib/MusicBrainz/Server/Data/Recording.pm#L437-L534
https://github.com/copilot/c/1b219e5c-0b2f-4fed-ae90-3f0acee07d2c
https://github.com/copilot/c/1b219e5c-0b2f-4fed-ae90-3f0acee07d2c

query: 

SELECT rec.id AS recording_id, rec.name AS recording_name, 
       rg.id AS release_group_id, rg.gid AS release_group_gid, rg.name AS release_group_name, 
       rg.type AS primary_type_id, rg.artist_credit AS artist_credit_id, rg.edits_pending, 
       rgm.first_release_date_year, rgm.first_release_date_month, rgm.first_release_date_day
FROM recording rec
JOIN track t ON t.recording = rec.id
JOIN medium m ON m.id = t.medium
JOIN release r ON r.id = m.release
JOIN release_group rg ON rg.id = r.release_group
JOIN release_group_meta rgm ON rgm.id = rg.id
JOIN artist_credit_name acn ON acn.artist_credit = rec.artist_credit
WHERE acn.artist = 1
ORDER BY rgm.first_release_date_year, rgm.first_release_date_month, rgm.first_release_date_day;


query grouped by recording id:

WITH oldest_release_group AS (
    SELECT rec.id AS recording_id, 
           MIN(format('%04d-%02d-%02d', rgm.first_release_date_year, rgm.first_release_date_month, rgm.first_release_date_day)) as first_release_date
    FROM recording rec
    JOIN track t ON t.recording = rec.id
    JOIN medium m ON m.id = t.medium
    JOIN release r ON r.id = m.release
    JOIN release_group rg ON rg.id = r.release_group
    JOIN release_group_meta rgm ON rgm.id = rg.id
    JOIN artist_credit_name acn ON acn.artist_credit = rec.artist_credit
    WHERE acn.artist = 1
    GROUP BY rec.id
)
SELECT rec.id AS recording_id, rec.name AS recording_name, 
       rg.id AS release_group_id, rg.gid AS release_group_gid, rg.name AS release_group_name, 
       rg.type AS primary_type_id, rg.artist_credit AS artist_credit_id, rg.edits_pending, 
       rgm.first_release_date
FROM recording rec
JOIN track t ON t.recording = rec.id
JOIN medium m ON m.id = t.medium
JOIN release r ON r.id = m.release
JOIN release_group rg ON rg.id = r.release_group
JOIN release_group_meta rgm ON rgm.id = rg.id
JOIN artist_credit_name acn ON acn.artist_credit = rec.artist_credit
JOIN oldest_release_group org ON org.recording_id = rec.id 
                              AND org.first_release_date_year = rgm.first_release_date_year
                              AND org.first_release_date_month = rgm.first_release_date_month
                              AND org.first_release_date_day = rgm.first_release_date_day
WHERE acn.artist = 1
ORDER BY rgm.first_release_date_year, rgm.first_release_date_month, rgm.first_release_date_day;







WITH oldest_release_group AS (
    SELECT rec.id AS recording_id, 
      MIN(format('%04d-%02d-%02d', rgm.first_release_date_year, rgm.first_release_date_month, rgm.first_release_date_day)) as first_release_date
    FROM recording rec
    JOIN track t ON t.recording = rec.id
    JOIN medium m ON m.id = t.medium
    JOIN release r ON r.id = m.release
    JOIN release_group rg ON rg.id = r.release_group
    JOIN release_group_meta rgm ON rgm.id = rg.id
    JOIN artist_credit_name acn ON acn.artist_credit = rec.artist_credit
    WHERE acn.artist = 1
    GROUP BY rec.id
)
SELECT rec.id AS recording_id, rec.name AS recording_name, 
       rg.id AS release_group_id, rg.gid AS release_group_gid, rg.name AS release_group_name, 
       rg.type AS primary_type_id, rg.artist_credit AS artist_credit_id, rg.edits_pending, 
       rgm.first_release_date_year, rgm.first_release_date_month, rgm.first_release_date_day
FROM recording rec
JOIN track t ON t.recording = rec.id
JOIN medium m ON m.id = t.medium
JOIN release r ON r.id = m.release
JOIN release_group rg ON rg.id = r.release_group
JOIN release_group_meta rgm ON rgm.id = rg.id
JOIN artist_credit_name acn ON acn.artist_credit = rec.artist_credit
JOIN oldest_release_group org ON org.recording_id = rec.id 
WHERE acn.artist = 1
ORDER BY rgm.first_release_date_year, rgm.first_release_date_month, rgm.first_release_date_day;
