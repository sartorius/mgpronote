DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS ref_partner;

CREATE TABLE ref_partner (
  id            SERIAL          PRIMARY KEY,
  name          VARCHAR(100)    NOT NULL,
  description   VARCHAR(250)    NOT NULL,
  to_phone      VARCHAR(20)     NOT NULL,
  -- C for Carrier
  -- P for Personal
  -- O for Other
  type          CHAR(1)         DEFAULT 'T',
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
