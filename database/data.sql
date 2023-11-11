INSERT INTO vehicle (name)
VALUES ('Van'), ('Truck');

INSERT INTO delivery (veh_name, name)
VALUES ('Truck', 'test');

INSERT INTO delivery (veh_name, name)
VALUES ('Truck', 'asdf');

INSERT INTO event (del_id, location, step)
VALUES (1, 'Darmstadt', 1);

INSERT INTO event (del_id, location, step)
VALUES (1, 'Kokkola', 2);

INSERT INTO event (del_id, location, step)
VALUES (2, 'Aschaffenburg', 1);

INSERT INTO event (del_id, location, step)
VALUES (2, 'Hamburg', 2);