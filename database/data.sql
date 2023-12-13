INSERT INTO VEHICLE (name)
VALUES ('Truck'),
       ('Van');

INSERT INTO DELIVERY (veh_name)
VALUES ('Truck'),
       ('Truck'),
       ('Truck'),
       ('Van'),
       ('Van');

INSERT INTO event (del_id, location, step)
VALUES (1, 'Darmstadt', 1),
       (1, 'Hamburg Port', 2),
       (1, 'Helsinki Port', 3),
       (1, 'Kokkola', 4);

INSERT INTO event (del_id, location, step)
VALUES (2, 'Darmstadt', 1),
       (2, 'Frankfurt', 2),
       (2, 'Frankfurt Airport', 3),
       (2, 'Helsinki Airport', 4),
       (2, 'Oulu Airport', 5),
       (2, 'Oulu', 6),
       (2, 'Kokkola', 7);

INSERT INTO event (del_id, location, step)
VALUES (3, 'Helsinki Airport', 1),
       (3, 'Kokkola', 2);

INSERT INTO event (del_id, location, step)
VALUES (4, 'Darmstadt Distribution Center', 1),
       (4, 'Darmstadt University of Applied Sciences', 2);

INSERT INTO event (del_id, location, step)
VALUES (5, 'Kokkola Distribution Center', 1),
       (5, 'Centria University of Applied Sciences', 2);

INSERT INTO driver (name, password, veh_name)
VALUES ('Christian', '1234', 'Truck'),
       ('Oli', '1234', 'Van'),
       ('Atta', '1234', 'Truck');


UPDATE driver SET id = 2 WHERE name = 'Atta';

UPDATE delivery set name = 'Atta' WHERE id = 2;
