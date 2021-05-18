
CREATE TABLE holiday(
  holiday_id int,
  name varchar(255),
  statutory bool,
  PRIMARY KEY (holiday_id)
  );

CREATE TABLE person(
  person_id INT,
  age_group VARCHAR(50),
  gender VARCHAR(50),
  PRIMARY KEY (person_id)
  );

CREATE TABLE "restriction" (
  restriction_id int PRIMARY KEY, 
  intervention_category varchar(255),
  intervention_type VARCHAR(255),
  description VARCHAR(255), 
  organisation VARCHAR(255), 
  start_date date
  );
 

 
