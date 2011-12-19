SELECT EXISTS(SELECT *
FROM boundary
WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(-87.64581 41.92683)', 4326)));

SELECT EXISTS(SELECT *
FROM boundary
WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(-87.843113 41.632342)', 4326)));

SELECT pri_neigh AS Neighborhood 
FROM hoods 
WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(-87.64581 41.92683)', 4326));

SELECT ward, alderman
FROM wards 
WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(-87.64581 41.92683)', 4326));

SELECT police_stations.* FROM police_stations
INNER JOIN police_districts
ON police_districts.dist_num = police_stations.descriptio
WHERE ST_Contains(police_districts.the_geom,ST_GeomFromText('POINT(-87.64581 41.92683)', 4326));

SELECT * FROM il_congress
WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(-87.64581 41.92683)', 4326));

SELECT * FROM il_senate
WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(-87.64581 41.92683)', 4326));

SELECT hoods.pri_neigh AS neighborhood, farmers_markets.location AS market_name, farmers_markets.intersecti FROM hoods,farmers_markets
WHERE ST_Contains(hoods.the_geom,farmers_markets.the_geom); 

SELECT ST_Distance(ST_Transform(ST_GeomFromText('POINT(-87.64581 41.92683)', 4326),900913),ST_Transform(farmers_markets.the_geom,900913)) / 1609 AS dist, farmers_markets.location AS market_name, farmers_markets.intersecti AS location
FROM farmers_markets 
ORDER BY dist ASC
LIMIT 5;

select * from landmarks 
order by date_built DESC;

select public_schools.facility_n from public_schools, hoods
WHERE ST_Contains(hoods.the_geom,public_schools.the_geom) AND hoods.pri_neigh = 'Bucktown'

SELECT landmarks.name FROM landmarks, hoods
WHERE ST_Contains(hoods.the_geom,landmarks.the_geom) AND hoods.pri_neigh = 'Lincoln Park'

select hospitals.hname from hospitals, hoods
WHERE ST_Contains(hoods.the_geom,hospitals.the_geom) AND hoods.pri_neigh = 'Lakeview'

SELECT ST_Distance(ST_Transform(ST_GeomFromText('POINT(-87.64581 41.92683)', 4326),900913),ST_Transform(hospitals.the_geom,900913)) / 1609 AS dist, hospitals.hname AS hospital
FROM hospitals 
ORDER BY dist ASC
LIMIT 5;

SELECT zipcodes.zip
FROM zipcodes,hoods
WHERE ST_Intersects(hoods.the_geom,zipcodes.the_geom) AND hoods.pri_neigh = 'Wrigleyville'