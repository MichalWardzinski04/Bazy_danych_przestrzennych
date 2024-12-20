-- zad3
CREATE EXTENSION postgis;

-- zad4

create table buildings (
	id integer primary key,
	geometry geometry(Polygon,4326),
	name varchar(50)
);

create table roads (
	id integer primary key,
	geometry geometry(LineString,4326),
	name varchar(50)
);

create table poi (
	id integer primary key,
	geometry geometry(Point,4326),
	name varchar(50)
);

-- 5

insert into buildings (id,geometry, name)
values
    (1,'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))','BuildingA'),
    (2,'POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))','BuildingB'),
	(3,'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))','BuildingC'),
	(4,'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))','BuildingD'),
	(5,'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))','BuildingE')
;

insert into roads (id,geometry, name)
values
    (1,'LINESTRING(0 4.5,12 4.5)','RoadX'),
	(2,'LINESTRING(7.5 0,7.5 10.5)','RoadY')
;

insert into poi (id,geometry, name)
values
    (1,'POINT(1 3.5)','G'),
	(2,'POINT(5.5 1.5)','H'),
	(3,'POINT(9.5 6)','I'),
	(4,'POINT(6.5 6)','J'),
	(5,'POINT(6 9.5)','K')
;

select * from roads

select * from buildings

select * from poi;

-- 6
-- a

select sum(ST_Length(geometry)) 
as total_length_roads
from roads;

-- b

select
    ST_AsText(geometry) as geometry_wkt,
    ST_Area(geometry) AS pole,
    ST_Perimeter(geometry) AS obwod
from buildings
where name = 'BuildingA';

-- c

select
    name,
    ST_Area(geometry) as pole
from buildings
where ST_GeometryType(geometry) = 'ST_Polygon'
order by name;

-- d

select
    name,
    ST_Perimeter(geometry) as obwod
from buildings
order by ST_Area(geometry) desc
limit 2;

-- e

select
    ST_Distance(buildings.geometry, poi.geometry) as shortest_distance
from buildings
join poi on  
	buildings.name = 'BuildingC' and poi.name = 'K';

-- f

SELECT
    ST_Area(ST_Difference(BuildingC.geometry, ST_Buffer(BuildingB.geometry, 0.5))) AS area
FROM buildings AS BuildingC, buildings AS BuildingB
WHERE BuildingC.name = 'BuildingC' AND BuildingB.name = 'BuildingB';

-- g

SELECT b.*
FROM buildings b
WHERE ST_Y(ST_Centroid(b.geometry)) > (SELECT ST_Y(ST_Centroid(geometry)) FROM roads WHERE name = 'RoadX');

--h

WITH buildingC AS (
    SELECT geometry
    FROM buildings
    WHERE name = 'BuildingC'
),
polygon AS (
    SELECT ST_SetSRID('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'::geometry, 4326) AS geometry
)

SELECT 
    ST_Area(ST_Difference(buildingC.geometry, polygon.geometry)) + ST_Area(ST_Difference(polygon.geometry, buildingC.geometry)) AS pole
FROM buildingC, polygon 
WHERE ST_Intersects(buildingC.geometry, polygon.geometry);