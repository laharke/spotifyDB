-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it
-- Voy a tener una base de datos de blink 182 y violadores del verso/kase o
-- Una tabla de artistas: id - nombre - genero? - followers

-- Una tabla de discos: id - nombre - genero - relase date - cantidad de temas
-- Una tabla relacionando artistas con discos.

-- Una tabla de GENEROS que esta SETTADA DE ANTES y en generos de artista es enum
--POdria haber sido mas simple pero quise permitir many2many por albums de colaboraciones y cancion con feats

--At first i though about doing a many2many relationship between artist and albums in case theres a FEAT album but it didnt seem optimal just for thoese edge cases,
--same thing with albums and songs for repated songs,
--I did, however, created a many2many realtionship between songs and artist because a feature there is way more frequent and this way you can keep track of all teh songs
--I could've taken a different approach and just have my artist-> album -> songs relationship and it would be way more simpler but this way you can get more information.

--Artists
CREATE TABLE artists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    followers INT NOT NULL,
    genre VARCHAR(255)
);

--Albums
CREATE TABLE albums (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- AUTO_INCREMENT for primary key
    name VARCHAR(255) NOT NULL,   -- VARCHAR for album name
    cant_songs INT,                     -- Number of songs (INT)
    releaseDate DATE,                    -- DATE field for the release date
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artists(id)
);

--Songs
CREATE TABLE songs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    track_number INT,
    duration_ms INT,
    explicit BOOLEAN,
    album_id INT,
    FOREIGN KEY (album_id) REFERENCES albums(id)
);

--Relationship between songs and artist many 2 many porque una SONG puede estar por mas de un artist
--Se ahce asi porque permite que multiples songs tengan mutiples artist, para los feat.

CREATE TABLE artist_songs_relation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    artist_id INT NOT NULL,
    song_id INT NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(id),
    FOREIGN KEY (song_id) REFERENCES songs(id)
);

-- Create indexes on name columns
CREATE INDEX idx_name_artists ON artists(name);
CREATE INDEX idx_name_albums ON albums(name);
CREATE INDEX idx_name_songs ON songs(name);


-- Create a view with the main info we need from the tables.
CREATE VIEW artist_with_albums_songs AS
SELECT
    a.id AS artist_id,
    a.name AS artist_name,
    al.name AS album_name,
    s.name AS song_name,
    s.track_number,
    s.duration_ms
FROM
    artists a
JOIN albums al ON a.id = al.artist_id
JOIN songs s ON al.id = s.album_id;
