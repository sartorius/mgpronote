DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS ref_partner;

CREATE TABLE ref_partner (
  id            SMALLINT        PRIMARY KEY,
  name          VARCHAR(100)    NOT NULL,
  description   VARCHAR(250)    NOT NULL,
  to_phone      VARCHAR(20),
  -- C for Carrier
  -- P for Personal
  -- R for Resell
  -- O for Other
  type          CHAR(1)         DEFAULT 'P',
  website       VARCHAR(500),
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- These are example of Carrier
INSERT INTO ref_partner (id, name, description) VALUES (0, 'Particulier', 'Client particulier, je suis le consommateur final du produit');
INSERT INTO ref_partner (id, name, description) VALUES (1, 'Revendeur', 'Revendeur, je vais revendre les produits que j''ai commandé');

INSERT INTO ref_partner (id, name, description, type) VALUES (2, 'Dummy Transporteur', 'Exemple de transporteur, destinataire final', 'C');

UPDATE users set partner = 2, incharge = TRUE where users.email = 'rakoto.mamy@gmail.com';
UPDATE users set partner = 2, incharge = FALSE where users.email = 'raza.hery@gmail.com';

-- Need a cross table partner x mod_workflow
-- Need a cross table client x partner
