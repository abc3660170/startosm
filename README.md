# startosm

thanks for <a href="https://github.com/Overv/openstreetmap-tile-server">Overv</a>'s demo

### careate shared database volume 
```
docker volume create --driver local --opt type=nfs --opt device=/path/to/pgdata --opt o=bind --name pgdata
```

### careate tilescache volume 

```
docker volume create --driver local --opt type=nfs --opt device=/path/to/tilescache --opt o=bind --name tilescache
```


### import pbf data
docker run --rm -it -e MAX_MEM=6000 -v pgdata:/home/pgdata -v /absolutePath/to/XXXX.pbf:/data.osm.pbf abc3660170/startosm import

### start tileserver
docker run  -p 3000:3000 -e THREADS=2 -d -v pgdata:/home/pgdata -v tilescache:/home/tilecache --name osmserver abc3660170/startosm run

<p>If tileserver startup,you can access: <a href ="http://ip:3000/test.html">http://ip:3000/test.html</a></p>


## ref 9 docker images I mad
<a href="https://cloud.docker.com/repository/docker/abc3660170/gcc">abc3660170/gcc</a>

<a href="https://cloud.docker.com/repository/docker/abc3660170/boost">abc3660170/boost</a>

<a href="https://cloud.docker.com/repository/docker/abc3660170/mapnik">abc3660170/mapnik</a>

<a href="https://cloud.docker.com/repository/docker/abc3660170/pg">abc3660170/pg</a>

<a href="https://cloud.docker.com/repository/docker/abc3660170/osm2pgsql">abc3660170/osm2pgsql</a>

<a href="https://cloud.docker.com/repository/docker/abc3660170/osmstyle">abc3660170/osmstyle</a>

<a href="https://cloud.docker.com/repository/docker/abc3660170/nodemapnik">abc3660170/nodemapnik</a>

<a href="https://cloud.docker.com/repository/docker/abc3660170/font">abc3660170/font</a>

<a href="https://cloud.docker.com/repository/docker/abc3660170/startosm">abc3660170/startosm</a>
