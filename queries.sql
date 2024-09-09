-- Find all songs by an artist name
SELECT * FROM artist_songs_relation
JOIN songs ON songs.id = artist_songs_relation.song_id
WHERE artist_id IN (
    SELECT id
    FROM artists
    WHERE name LIKE "%blink%"
);

-- Find all songs on an album by album name
SELECT * FROM songs
JOIN albums ON songs.album_id = albums.id
WHERE albums.id IN (
    SELECT id
    FROM albums
    WHERE name LIKE "%ONE MORE TIME%"
);

-- Find all albums from an artist by artist name
SELECT * FROM albums
JOIN artists ON artists.id = albums.artist_id
WHERE artist_id IN (
    SELECT id
    FROM artists
    WHERE name LIKE "%blink%"
);

-- Query on the view that has all related info
SELECT * FROM artist_with_albums_songs
WHERE artist_name like "%blink%"
ORDER BY album_name, track_number;

-- Insert a new artist
INSERT INTO artists(name, followers, genre) VALUES ("blink 182", 8446480, "['alternative metal', 'modern rock', 'pop punk', 'punk', 'rock', 'socal pop punk']");

-- Insert a new album
INSERT INTO albums(name, cant_songs, releaseDate, artist_id) VALUES ("ONE MORE TIME...", 19, "2023-10-27", 12);

-- Insert a new song
INSERT INTO songs(name, track_number, duration_ms, explicit, album_id) VALUES ("DANCE WITH ME", 2, 188155, 1, 17)

-- Create a new relation between artist and song
-- Asuming 2 and 12 are ids corresponding to an artist and a song.
INSERT INTO artist_songs_relation(artist_id, song_id) VALUES (2,12);
