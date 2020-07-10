CREATE TABLE ref_partner (
  id                SMALLINT        PRIMARY KEY,
  name              VARCHAR(100)    NOT NULL,
  description       VARCHAR(250)    NOT NULL,
  to_phone          VARCHAR(20),
  -- C for Carrier
  -- P for Personal
  -- R for Resell
  -- O for Other
  type              CHAR(1)         DEFAULT 'P',
  website                       VARCHAR(500),
  delivery_addr                 VARCHAR(500),
  -- Where to retrieve in Madagascar
  pickup_addr                   VARCHAR(500),
  pickup_phone                  VARCHAR(20),
  -- Paris Workflow id
  main_wf_id        SMALLINT        DEFAULT 1,
  max_bc_clt        SMALLINT        DEFAULT 5,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

/*
ALTER TABLE ref_partner ADD COLUMN pickup_phone VARCHAR(20);
UPDATE ref_partner SET pickup_phone = '0326711567' WHERE id IN (2);
UPDATE ref_partner SET pickup_phone = '0338919064' WHERE id IN (3);
UPDATE ref_partner SET to_phone = '0624788912' WHERE id IN (2);
UPDATE ref_partner SET to_phone = '0764288678' WHERE id IN (3);

ALTER TABLE ref_partner ADD COLUMN max_bc_clt_day    SMALLINT        DEFAULT 3;
UPDATE ref_partner SET delivery_addr = 'DUMMY Transport@ 48 RUE DE LA BOETIE, 95078 Roissy Z.I' WHERE id IN (2);
UPDATE ref_partner SET delivery_addr = 'FANNY SERVICE TRANSPORT@ 21 RUE DE LA GARE, 92304 Maison la Foire', pickup_addr = 'Box 10A, Centre La City Hazobe Tana 101'  WHERE id IN (3);
*/

-- These are example of Carrier
INSERT INTO ref_partner (id, name, description) VALUES (0, 'Particulier', 'Client particulier, je suis le consommateur final du produit');
INSERT INTO ref_partner (id, name, description, type) VALUES (1, 'Revendeur', 'Revendeur, je revends les produits que j''ai commandé', 'R');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, pickup_addr, pickup_phone) VALUES (2, 'Dummy Transporteur', 'Exemple de transporteur', 'C', 1, '0624788912', '48 Rue de la Boétie, 93078 Les Pinsons de la Rivière', 'Box 762, Centre Riviera Malaza Tana 101', '0326711567');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, pickup_addr, pickup_phone) VALUES (3, 'Fanny Service Transport', 'Exemple de transporteur 2', 'C', 1, '0764288678', '78 Rue de la Gare, 92304 Maison la Foire', 'Box 782, Centre La City Hazobe Tana 101', '0338919064');

UPDATE ref_partner SET delivery_addr = 'DUMMY Transport@ 48 RUE DE LA BOETIE, 95078 Roissy Z.I' WHERE id IN (2);
UPDATE ref_partner SET delivery_addr = 'FANNY SERVICE TRANSPORT@ 21 RUE DE LA GARE, 92304 Maison la Foire', pickup_addr = 'Box 10A, Centre La City Hazobe Tana 101'  WHERE id IN (3);


-- Need a cross table partner x mod_workflow
-- Need a cross table client x partner


-- Todo add pickup phone
