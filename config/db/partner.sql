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
  -- Paris Workflow id
  main_wf_id    SMALLINT        DEFAULT 1,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- These are example of Carrier
INSERT INTO ref_partner (id, name, description) VALUES (0, 'Particulier', 'Client particulier, je suis le consommateur final du produit');
INSERT INTO ref_partner (id, name, description, type) VALUES (1, 'Revendeur', 'Revendeur, je revends les produits que j''ai commandé', 'R');

INSERT INTO ref_partner (id, name, description, type, main_wf_id) VALUES (2, 'Dummy Transporteur', 'Exemple de transporteur, destinataire final', 'C', 1);

-- Need a cross table partner x mod_workflow
-- Need a cross table client x partner
