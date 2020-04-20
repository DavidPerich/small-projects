CREATE TABLE expenses (
  id serial PRIMARY KEY,
  amount decimal(6, 2) NOT NULL,
  memo varchar(255) NOT NULL,
  created_on date DEFAULT now() NOT NULL
);

ALTER TABLE expenses ADD CHECK (amount > 0 );