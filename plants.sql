CREATE TABLE plants (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

INSERT INTO
  humans (id, fname, lname)
VALUES
  (1, "Smith", "John"),
  (2, "Zhu", "Stephanie");

INSERT INTO
  plants (id, name, owner_id)
VALUES
  (1, "Cactus", 1),
  (2, "Aloe", 1),
  (3, "Grass", 2),
  (4, "Bamboo", 2);
