
CREATE TABLE teams (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  logo text
);

CREATE TABLE seasons (
  year INTEGER PRIMARY KEY
);

CREATE TABLE venues (
  id SERIAL PRIMARY KEY,
  name varchar(255) NOT NULL UNIQUE
);

CREATE TABLE fixtures (
  id SERIAL PRIMARY KEY,
  year INTEGER REFERENCES seasons(year),
  competition VARCHAR(255) NOT NULL,
  round INTEGER NOT NULL,
  datetime TIMESTAMP NOT NULL,
  day VARCHAR(255) NOT NULL,
  hteam_id INTEGER REFERENCES teams(id),
  ateam_id INTEGER REFERENCES teams(id),
  venue_id INTEGER REFERENCES venues(id),
  hsupergoals INTEGER,
  hgoals INTEGER,
  hbehinds INTEGER,
  hscore  INTEGER,
  asupergoals INTEGER,
  agoals INTEGER,
  abehinds INTEGER,
  ascore INTEGER,
  margin INTEGER
);
