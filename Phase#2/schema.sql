CREATE TABLE restriction_group(
    restriction_group_id int,
    PRIMARY KEY (restriction_group_id)
    );
    
CREATE TABLE restriction_group_bridge(
    restriction_group_id int,
    restriction_id int,   
    FOREIGN KEY (restriction_group_id) REFERENCES restriction_group(restriction_group_id),
    FOREIGN KEY (restriction_id) REFERENCES restriction(restriction_id)
    );

CREATE TABLE weather(
weather_key int,
longitude float,
latitude float,
station_name varchar(255),
mean_tempreture_c float,
total_precipitation_mm float,
snow boolean,
rain boolean,
PRIMARY KEY (weather_key)
);

CREATE TABLE mobility_trends(
mobility_key int,
country varchar(255) NOT NULL,
province varchar(255) NOT NULL,
municipality varchar(255) NOT NULL,
retail_and_recreation float,
grocery_and_pharmacy float,
parks float,
transit_stations float,
workplaces float,
residential float,
PRIMARY KEY (mobility_key)
);

CREATE TABLE phu(
phu_key int,
postal_code varchar(255),
phu_name varchar(255),
address varchar(255),
city varchar(255),
province varchar(255),
url varchar(255),
latitude float,
longitude float,
municipality varchar(255),
PRIMARY KEY (phu_key)
);