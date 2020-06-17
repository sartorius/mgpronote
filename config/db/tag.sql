CREATE TABLE tag (
  id    BIGSERIAL     PRIMARY KEY,
  bc    VARCHAR(50)   NOT NULL,
  step  VARCHAR(100)  NOT NULL,
  geo   VARCHAR(200)  NOT NULL,
  create_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO tag (bc, step, geo) VALUES ('sdfsqfq', 'sfqf', 'sfqsdf');
