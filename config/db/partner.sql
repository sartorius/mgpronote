CREATE TABLE ref_partner (
  id                SMALLINT        PRIMARY KEY,
  name              VARCHAR(100)    NOT NULL,
  description       VARCHAR(250)    NOT NULL,
  to_phone          VARCHAR(20),
  -- C for Carrier
  -- P for Personal
  -- R for Resell
  -- M for Manufacture
  -- O for Other
  type              CHAR(1)         DEFAULT 'P',
  website           VARCHAR(500),
  delivery_addr     VARCHAR(500),
  -- Paris Workflow id
  main_wf_id        SMALLINT        DEFAULT 1,
  max_bc_clt        SMALLINT        DEFAULT 5,
  -- Default currency
  cur_code          CHAR(3)         DEFAULT 'EUR',
  -- Do we manage pick up for this partner
  hdl_pickup         CHAR(1)         DEFAULT 'Y',
  -- Do we manage price for this partner we just notify if it has been paid or no
  hdl_price         CHAR(1)         DEFAULT 'N',
  -- Do we manage pricing for this partner : not implemented yet
  hdl_calc_pricing  CHAR(1)         DEFAULT 'N',
  -- Do we manage big workflow for this partner : not implemented yet
  hdl_mother        CHAR(1)         DEFAULT 'N',
  -- Do we manage merging for this partner : not implemented yet
  hdl_merge         CHAR(1)         DEFAULT 'N',
  -- Usual info
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO ref_partner (id, name, description) VALUES (0, 'Particulier', 'Client particulier, je suis le consommateur final du produit');
INSERT INTO ref_partner (id, name, description, type) VALUES (1, 'Revendeur', 'Revendeur, je revends les produits que j''ai commandé', 'R');

-- type C: Carrier
INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_pickup) VALUES (2, 'Dummy Transporteur', 'Exemple de transporteur', 'C', 1, '0624788912', 'DUMMY Transport@ 48 RUE DE LA BOETIE, 95078 Roissy Z.I', 'N');
INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_price, hdl_mother) VALUES (3, 'Test 3 Fret Service', 'Test 3 Fret Service', 'C', 2, '0664066109', 'Test Trois Fret Service@ 13 AVENUE ALBERT EINSTEIN, 93150 LE BLANC MESNIL', 'Y', 'Y');
INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_price, hdl_mother) VALUES (4, 'Test 4 Transport', 'Test Quatre', 'C', 2, '0664078109', 'Test Quatre Transport@ 12 RUE DES BRINS, 93170 BAGNOLET', 'Y', 'Y');
INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_price, hdl_mother) VALUES (5, 'Mada Groupage France', 'Mada Groupage France', 'C', 1, '06 19 24 13 08', 'RAKOTOMANGA@ 22 AVENUE MAURICE THOREZ, 94200 IVRY SUR SEINE', 'N', 'Y');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_price, hdl_mother, hdl_pickup) VALUES (6, 'Exemple Manufacture', 'Exemple Manufacture', 'M', 1, '032 89 879 38', 'RAKOTOMANGA@ LOT IIC AKT, ANTANANARIVO 101', 'N', 'Y', 'N');


CREATE TABLE ref_partner_workflow (
  id                SMALLINT        PRIMARY KEY,
  partner_id        SMALLINT        NOT NULL,
  wf_id             SMALLINT        NOT NULL,
  pickup_addr       VARCHAR(500)    NOT NULL,
  pickup_phone      VARCHAR(30)     NOT NULL,
  create_date       TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (1, 2, 1, 'BOX 762, CENTRE RIVIERA MALAZA TANA 101', '0326711567');
INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (2, 3, 2, 'AEROPORT A.A NETO - FACE NOUVEL AEROGARE POINTE NOIRE CONGO', '055743447/066443676');
INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (3, 3, 3, 'AEROPORT A.A NETO - FACE NOUVEL AEROGARE POINTE NOIRE CONGO', '055743447/066443676');
INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (4, 3, 4, '9 BIS RUE MBOKO, MOUNGALI', '066251108');
INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (5, 3, 5, '9 BIS RUE MBOKO, MOUNGALI', '066251108');

INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (6, 5, 1, '87 TER RUE RAINANDRIAMAMPIANDRY FARAVOHITRA TANA 101', '034 81 450 68');
-- We wait to handle the boat
-- INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (7, 5, 6, 'BOX 762, CENTRE RIVIERA MALAZA TANA 101', '0326711567');

INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (8, 6, 1, 'LOT IIC AKT, ANTANANARIVO 101', '032 89 879 38');
