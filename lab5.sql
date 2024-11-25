CREATE EXTENSION postgis;

CREATE TABLE obiekty (
	nazwa VARCHAR,
	geom GEOMETRY
);

INSERT INTO obiekty (nazwa, geom)
SELECT 
    'obiekt1',
    ST_Union(
        ST_Collect(ARRAY[
            ST_GeomFromText('LINESTRING(0 1, 1 1)'),
            ST_LineToCurve(ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)')),
            ST_LineToCurve(ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)')),
            ST_GeomFromText('LINESTRING(5 1, 6 1)')
        ])
    );

INSERT INTO obiekty (nazwa, geom)
SELECT 
    'obiekt2',
    ST_Union(
        ST_Collect(ARRAY[
            ST_GeomFromText('LINESTRING(10 6, 14 6)'),
            ST_LineToCurve(ST_GeomFromText('CIRCULARSTRING(14 6, 16 4, 14 2)')),
            ST_LineToCurve(ST_GeomFromText('CIRCULARSTRING(14 2, 12 0, 10 2)')),
            ST_GeomFromText('LINESTRING(10 2, 10 6)'),
			ST_LineToCurve(ST_GeomFromText('CIRCULARSTRING(11 2, 12 3, 13 2)')),
			ST_LineToCurve(ST_GeomFromText('CIRCULARSTRING(13 2, 12 1, 11 2)'))
        ])
    );



INSERT INTO obiekty (nazwa, geom) 
VALUES ('obiekt3',
  ST_GeomFromText(
    'MULTILINESTRING(
      (7 15, 10 17),
      (10 17, 12 13),
	  (12 13, 7 15)
    )')
);

INSERT INTO obiekty (nazwa, geom) 
VALUES ('obiekt4',
  ST_GeomFromText(
    'MULTILINESTRING(
      (20 20, 25 25),
      (25 25, 27 24),
	  (27 24, 25 22),
	  (25 22, 26 21),
	  (26 21, 22 19),
	  (22 19, 20.5 19.5)
    )')
);

INSERT INTO obiekty (nazwa, geom)
SELECT 
    'obiekt5',
    ST_Union(
        ST_Collect(ARRAY[
            ST_GeomFromText('POINT(30 30 59)'), 
            ST_GeomFromText('POINT(38 32 234)')
        ])
    );

INSERT INTO obiekty (nazwa, geom)
SELECT 
    'obiekt6',
    ST_Union(
        ST_Collect(ARRAY[
            ST_GeomFromText('LINESTRING(1 1, 3 2)'), 
            ST_GeomFromText('POINT(4 2)')
        ])
    );

-- 2
SELECT ST_Area(ST_Buffer(ST_ShortestLine(o1.geom, o2.geom), 5))
FROM obiekty o1, obiekty o2
WHERE o1.nazwa = 'obiekt3' AND o2.nazwa = 'obiekt4';

-- 3
UPDATE obiekty
SET geom = ST_GeomFromText(
            'MULTILINESTRING(
              (20 20, 25 25),
              (25 25, 27 24),
              (27 24, 25 22),
              (25 22, 26 21),
              (26 21, 22 19),
              (22 19, 20.5 19.5, 20 20)
            )'
          )
WHERE nazwa = 'obiekt4';

UPDATE obiekty
SET geom = (
  SELECT ST_MakePolygon(ST_LineMerge(ST_Collect(geom)))
  FROM obiekty
  WHERE nazwa = 'obiekt4'
)
WHERE nazwa = 'obiekt4';

-- 4
INSERT INTO obiekty (nazwa, geom)
SELECT 
    'obiekt7',
    ST_Union(o1.geom, o2.geom)
FROM obiekty o1, obiekty o2
WHERE o1.nazwa = 'obiekt3' AND o2.nazwa = 'obiekt4';