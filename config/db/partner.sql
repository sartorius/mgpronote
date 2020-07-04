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
  delivery_addr VARCHAR(500),
  pickup_addr   VARCHAR(500),
  -- Paris Workflow id
  main_wf_id    SMALLINT        DEFAULT 1,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- These are example of Carrier
INSERT INTO ref_partner (id, name, description) VALUES (0, 'Particulier', 'Client particulier, je suis le consommateur final du produit');
INSERT INTO ref_partner (id, name, description, type) VALUES (1, 'Revendeur', 'Revendeur, je revends les produits que j''ai commandé', 'R');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, pickup_addr) VALUES (2, 'Dummy Transporteur', 'Exemple de transporteur, destinataire final', 'C', 1, '032567876', '48 Rue de la Boétie, 93078 Les Pinsons de la Rivière', 'Box 762, Centre Riviera Malaza Tana 101');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, pickup_addr) VALUES (3, 'Fanny Service Transport', 'Exemple de transporteur 2, destinataire final', 'C', 1, '032567852', '78 Rue de la Gare, 92304 Maison la Foire', 'Box 782, Centre La City Hazobe Tana 101');

-- Need a cross table partner x mod_workflow
-- Need a cross table client x partner
