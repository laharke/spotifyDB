from cs50 import SQL
from requests import post, get
import json
import base64
import mysql.connector

#DB CONNECTION
config = {
  'user': 'root',
  'password': 'crimson',
  'host': '127.0.0.1',
  'database': 'spotify'
}
cnx = mysql.connector.connect(**config)
cursor = cnx.cursor()

# Execute the SELECT query
# cursor.execute("SELECT * FROM cards;")
# Fetch the results
#results = cursor.fetchall()


ClientID = '76602d0ba1f14df4a61dc8292d745ab9'
ClientSecret = 'cd391e24231d4902bd8a6c6153b07a79'

def get_token():
    auth_string = ClientID + ":" + ClientSecret
    auth_bytes = auth_string.encode("utf-8")
    auth_base64 = str(base64.b64encode(auth_bytes), "utf-8")

    url = "https://accounts.spotify.com/api/token"
    headers = {
        "Authorization": "Basic " + auth_base64,
        "Content-Type": "application/x-www-form-urlencoded"
    }
    data = {"grant_type": "client_credentials"}
    result = post(url, headers = headers, data = data)
    json_result = json.loads(result.content)
    token = json_result["access_token"]
    return token


def get_auth_header(token):
    return {"Authorization": "Bearer " + token}

def search_for_artist(token, artist_name):
    url = "https://api.spotify.com/v1/search"
    headers = get_auth_header(token)
    query = f"?q={artist_name}&type=artist&limit=1"
    query_url = url + query
    result = get(query_url, headers= headers)
    json_result = json.loads(result.content)
    #print(json_result)
    return json_result['artists']['items']

def search_for_albums(token, artist_id):
    url = f"https://api.spotify.com/v1/artists/{artist_id}/albums"
    headers = get_auth_header(token)
    result = get(url, headers= headers)
    json_result = json.loads(result.content)
    return json_result

def search_for_songs(token, album_id):
    #/albums/{id}/tracks
    url = f"https://api.spotify.com/v1/albums/{album_id}/tracks"
    headers = get_auth_header(token)
    result = get(url, headers= headers)
    json_result = json.loads(result.content)
    return json_result


token = get_token()


artistInputed = input("Which artist you want to add to the database?")
artistInfo = search_for_artist(token, artistInputed)

artistId = artistInfo[0]['id']
artistName = artistInfo[0]['name']
artistFollowers = artistInfo[0]['followers']['total']
artistGenres = artistInfo[0]['genres']

artistData= (artistName, artistFollowers, str(artistGenres))
cursor.execute("INSERT INTO artists(name, followers, genre) VALUES (%s,%s, %s)", artistData)
#id del insert
artistIdDb = cursor.lastrowid
albums = search_for_albums(token, artistId)

albums = albums['items']
for album in albums:
    album_id = album['id']
    albumName = album['name']
    albumTotalTracks = album['total_tracks']
    albumReleaseDate = album['release_date']
    if (len(albumReleaseDate) == 4):
        albumReleaseDate= albumReleaseDate + '-01-01'

    #Aca hago el insert into albums
    albumData = (albumName, albumTotalTracks, albumReleaseDate, artistIdDb)
    cursor.execute("INSERT INTO albums(name, cant_songs, releaseDate, artist_id) VALUES (%s,%s,%s, %s)", albumData)
    #Id del album recien insertado
    albumIdDb = cursor.lastrowid
    #Y por cada album tengo que consultar a la API por las canciones del album
    album_songs = search_for_songs(token, album_id)
    album_songs = album_songs['items']
    for song in album_songs:
        #Insert de las songs a la DB
        songName = song['name']
        songTrackNumber = song['track_number']
        songDuration = song['duration_ms']
        songExplicit = song['explicit']
        songData = (songName, songTrackNumber, songDuration, songExplicit, albumIdDb)
        cursor.execute("INSERT INTO songs(name, track_number, duration_ms, explicit, album_id) VALUES (%s,%s,%s,%s, %s)", songData)
        #relacion song - artist (tengo que hacer select para saber que id tiene el artist)
        songIdDb = cursor.lastrowid
        relationSongArtistData = (artistIdDb, songIdDb)
        cursor.execute("INSERT INTO artist_songs_relation(artist_id, song_id) VALUES (%s,%s)", relationSongArtistData)


cnx.commit()
cnx.close()
