DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS recommendation;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS res_timestamp;
DROP TABLE IF EXISTS furniture;
DROP TABLE IF EXISTS room;
DROP TABLE IF EXISTS room_type;
DROP TABLE IF EXISTS lady_companion;
DROP TABLE IF EXISTS cleaner;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS hotel;


CREATE TABLE hotel(
	id SERIAL CONSTRAINT hotel_id_pk PRIMARY KEY,
	name VARCHAR(40) NOT NULL CONSTRAINT hotel_name_unique UNIQUE,
	address VARCHAR(100) NOT NULL
);

CREATE TABLE employee(
	employee_number SMALLINT CONSTRAINT employee_id_pk PRIMARY KEY,
	e_mail VARCHAR(40) NOT NULL,
	name VARCHAR(30) NOT NULL,
	salary INTEGER NOT NULL,
	telephone VARCHAR(13) NOT NULL,
	hotel INTEGER NOT NULL,
	CONSTRAINT employee_hotel_fk 
		FOREIGN KEY (hotel) REFERENCES hotel (id)
		ON UPDATE CASCADE
);
CREATE TABLE cleaner(
	employee_num SMALLINT,
	PRIMARY KEY(employee_num),
	CONSTRAINT cleaner_empl_fk 
		FOREIGN KEY (employee_num) REFERENCES employee (employee_number)
		ON UPDATE CASCADE
);
CREATE TABLE lady_companion(
	employee_num SMALLINT,
	orientation VARCHAR(20) NOT NULL,
	fee INTEGER NOT NULL,
	PRIMARY KEY(employee_num),
	CONSTRAINT lady_comp_empl_fk
		FOREIGN KEY (employee_num) REFERENCES employee (employee_number)
		ON UPDATE CASCADE
);
CREATE TABLE room_type(
	id SERIAL CONSTRAINT room_type_pk PRIMARY KEY,
	description VARCHAR(100) NOT NULL CONSTRAINT room_type_desc_unique UNIQUE,
	size INTEGER NOT NULL,
	max_guests SMALLINT NOT NULL
);
CREATE TABLE room(
	id SERIAL NOT NULL,
	hotel INTEGER NOT NULL,
	price INTEGER NOT NULL,
	rm_type INTEGER NOT NULL,
	CONSTRAINT room_pks PRIMARY KEY(id, hotel),
	CONSTRAINT room_hotel_fk 
		FOREIGN KEY (hotel)
		REFERENCES hotel (id)
		ON UPDATE CASCADE,
	CONSTRAINT room_rm_type_fk
		FOREIGN KEY (rm_type)
		REFERENCES room_type (id)
		ON UPDATE CASCADE
);
CREATE TABLE furniture(
	room_id INTEGER NOT NULL,
	hotel_id INTEGER NOT NULL,
	quantity SMALLINT NOT NULL,
	title VARCHAR(20) NOT NULL,
	PRIMARY KEY(room_id, hotel_id),
	CONSTRAINT furniture_fk 
		FOREIGN KEY (room_id, hotel_id)
		REFERENCES room (id, hotel)
		ON UPDATE CASCADE
);
CREATE TABLE res_timestamp(
	day DATE,
	clock TIME,
	CONSTRAINT timestamp_pks PRIMARY KEY (day, clock) 
);
CREATE TABLE customer(
	customer_number SERIAL NOT NULL,
	name VARCHAR(30) NOT NULL,
	e_mail VARCHAR(40) NOT NULL,
	CONSTRAINT customer_num_pk PRIMARY KEY (customer_number),
	CONSTRAINT customer_ch_email CHECK (e_mail LIKE '%_@_%.__%') 
);
CREATE TABLE recommendation(
	from_ INTEGER NOT NULL,
	to_ INTEGER NOT NULL,
	CONSTRAINT recc_to_pk PRIMARY KEY (to_),
	CONSTRAINT recc_to_fk 
		FOREIGN KEY (to_)
		REFERENCES customer (customer_number)
		ON UPDATE CASCADE,
	CONSTRAINT recc_from_fk
		FOREIGN KEY (from_)
		REFERENCES customer (customer_number)
		ON UPDATE CASCADE
);
CREATE TABLE reservation(
	day DATE NOT NULL,
	clock TIME NOT NULL,
	lady_id SMALLINT,
	customer_id INTEGER,
	room_id INTEGER NOT NULL,
	hotel_id INTEGER NOT NULL,
	CONSTRAINT reserv_pks PRIMARY KEY (day, clock, lady_id, customer_id, room_id, hotel_id),
	CONSTRAINT reserv_timestamp_fk 
		FOREIGN KEY (day, clock)
		REFERENCES res_timestamp (day, clock),
	CONSTRAINT reserv_lady_fk
		FOREIGN KEY (lady_id)
		REFERENCES lady_companion (employee_num)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	CONSTRAINT reserv_custom_fk
		FOREIGN KEY (customer_id)
		REFERENCES customer (customer_number)
		ON DELETE SET NULL,
	CONSTRAINT reserv_room_fk
		FOREIGN KEY (room_id, hotel_id)
		REFERENCES room (id, hotel)
		ON UPDATE CASCADE
);