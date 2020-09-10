DROP TABLE IF EXISTS client_partner_xref;
DROP TABLE IF EXISTS mother_barcode_xref;


-- To be deleted to delete barcode #0
DROP TABLE IF EXISTS wk_param;
-- To be deleted to delete barcode #1
DROP TABLE IF EXISTS wk_tag_com;
-- To be deleted to delete barcode #2
DROP TABLE IF EXISTS wk_tag;


-- To be deleted to delete barcode #3
DROP TABLE IF EXISTS mother;

-- To be deleted to delete barcode #4
DROP TABLE IF EXISTS barcode;

DROP TABLE IF EXISTS mod_workflow;
DROP TABLE IF EXISTS ref_workflow;
DROP TABLE IF EXISTS grp_status;
DROP TABLE IF EXISTS ref_status;
DROP TABLE IF EXISTS ref_partner_workflow;
DROP TABLE IF EXISTS ref_partner;
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

-- These are example of Carrier
INSERT INTO ref_partner (id, name, description) VALUES (0, 'Particulier', 'Client particulier, je suis le consommateur final du produit');
INSERT INTO ref_partner (id, name, description, type) VALUES (1, 'Revendeur', 'Revendeur, je revends les produits que j''ai commandé', 'R');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_pickup) VALUES (2, 'Dummy Transporteur', 'Exemple de transporteur', 'C', 1, '0624788912', 'DUMMY Transport@ 48 RUE DE LA BOETIE, 95078 Roissy Z.I', 'N');
INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_price, hdl_mother) VALUES (3, 'Test 3 Fret Service', 'Test 3 Fret Service', 'C', 2, '0664066109', 'Test Trois Fret Service@ 13 AVENUE ALBERT EINSTEIN, 93150 LE BLANC MESNIL', 'Y', 'Y');
INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_price, hdl_mother) VALUES (4, 'Test 4 Transport', 'Test Quatre', 'C', 2, '0664078109', 'Test Quatre Transport@ 12 RUE DES BRINS, 93170 BAGNOLET', 'Y', 'Y');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_price, hdl_mother) VALUES (5, 'Mada Groupage', 'Mada Groupage', 'C', 1, '0664078109', 'Mada Groupage@ 12 RUE DES PRIMTEMPS, 93170 BAGNOLET', 'Y', 'Y');


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

INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (6, 5, 1, 'BOX 762, CENTRE RIVIERA MALAZA TANA 101', '0326711567');
-- We wait to handle the boat
-- INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (7, 5, 6, 'BOX 762, CENTRE RIVIERA MALAZA TANA 101', '0326711567');
-- Transition ref
CREATE TABLE ref_status (
  id                  SMALLINT      PRIMARY KEY,
  step_short          VARCHAR(7)    NOT NULL,
  step                VARCHAR(50)   NOT NULL,
  description         VARCHAR(250)  NOT NULL,
  grp_id              SMALLINT      DEFAULT 0,
  next_input_needed   CHAR(1)       NOT NULL,
  -- A All
  -- P Partner
  -- Q Personal Reseller
  act_owner           CHAR(1)       NOT NULL,
  need_to_notify      BOOLEAN       DEFAULT FALSE,
  -- if need to notify and txt is null, use description
  txt_to_notify       VARCHAR(250),
  -- Can we to to this status by using mother ?
  handle_mother       CHAR(1)       DEFAULT 'N',
  create_date         TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

/*

ALTER TABLE ref_status ADD COLUMN need_to_notify BOOLEAN DEFAULT FALSE;
UPDATE ref_status SET need_to_notify = TRUE WHERE id IN (-1, 0, 6, 10);

ALTER TABLE ref_status ADD COLUMN txt_to_notify VARCHAR(250);
UPDATE ref_status SET txt_to_notify = 'Vous venez de recevoir une référence paquet. Vous avez une action à faire: renseigner le.la réceptionneur.euse, veuillez vous connecter pour effectuer cette action.' WHERE id IN (0);
UPDATE ref_status SET description = 'Le poids a été validé.' WHERE id IN (6);
M000055Y2/M00004YAK
*/

-- Simple hard coded for existing users
UPDATE users SET client_ref = (FLOOR(random() * 999 + 1)::INT);

INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, need_to_notify, grp_id) VALUES (-2, 'Disso.', 'Dissocié', 'Gestion terminée.', 'N', 'P', TRUE, 8);
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, need_to_notify, grp_id) VALUES (-1, 'Remis', 'Remis au client', 'La gestion de ce paquet est terminée.', 'N', 'P', TRUE, 8);
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id) VALUES (0, 'A. Livr', 'Attente de livraison', 'Créé, attente de livraison.', 'Y', 'P', 1);
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id) VALUES (3, 'A. Adre', 'Attente de saisie adresse', 'Créé, l''adresse enlèvement doit être saisie.', 'Y', 'P', 1);


INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id) VALUES (1, 'Adr elv', 'Adressé, attente enlèvement', 'Mise à jour adresse enlèvement.', 'N', 'Q', 2);
-- Make sure the status 4 is specific
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id) VALUES (4, 'Elv loc', 'Enlevé, en cours vers local transporteur', 'Le paquet a été enlevé à l''adresse indiqué.', 'N', 'P', 2);
-- Make sure the status 2 is specific
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id) VALUES (2, 'Local', 'Livré au local transporteur', 'Le paquet a été déposé en zone de stockage.', 'Y', 'P', 3);
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, need_to_notify) VALUES (6, 'Pesé', 'Pesé', 'Le poids a été validé.', 'N', 'P', 4, TRUE);
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (7, 'Ft. CDG', 'Déposé frêt CDG', 'Le paquet a été déposé en zone de frêt CDG.', 'N', 'P', 5, 'Y');
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (8, 'Ft. Orl', 'Déposé frêt Orly', 'Le paquet a été déposé en zone de frêt Orly.', 'N', 'P', 5, 'Y');
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (11, 'Ft. Exp', 'Déposé frêt Express', 'Le paquet a été déposé en zone de frêt Express.', 'N', 'P', 5, 'Y');

INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (9, 'Tana', 'Arrivé à Tana', 'Le paquet est arrivé à Tana. Il passe les formalités.', 'N', 'P', 6, 'Y');
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, need_to_notify, grp_id, handle_mother) VALUES (10, 'Dispo.', 'Disponible Client', 'Le client peut venir récupérer son paquet', 'N', 'P', TRUE, 7, 'Y');



INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (12, 'Pt. Noi', 'Arrivé à Pointe Noire', 'Le paquet est arrivé à Pointe Noire. Il passe les formalités.', 'N', 'P', 6, 'Y');
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (13, 'Brazzav', 'Arrivé à Brazzaville', 'Le paquet est arrivé à Brazzaville. Il passe les formalités.', 'N', 'P', 6, 'Y');


INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (14, 'Ft. Hav', 'Déposé frêt Le Havre', 'Le paquet a été déposé en zone de frêt port Le Havre.', 'N', 'P', 5, 'Y');


INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (15, 'Tamatv.', 'Arrivé à Tamatave', 'Le paquet est arrivé à Tamatave. Il passe les formalités.', 'N', 'P', 6, 'Y');

-- Particular case of pickup but it is as well created from screen
UPDATE ref_status SET need_to_notify = FALSE;
UPDATE ref_status SET need_to_notify = TRUE WHERE id IN (-1, 2, 6, 10);

-- /////////////////////////////////////////////////////////////////////// Done set up

-- START GRP Workflow

-- Transition ref
CREATE TABLE grp_status (
  id                  SMALLINT      PRIMARY KEY,
  order_id            SMALLINT      NOT NULL,
  common              BOOLEAN       DEFAULT TRUE,
  grp_step            VARCHAR(50)   NOT NULL
);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (1, 'Réception', TRUE, 1);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (2, 'Enlèvement', FALSE, 2);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (3, 'Local transporteur', TRUE, 3);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (4, 'Pesée', TRUE, 4);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (5, 'Dépot frêt', TRUE, 5);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (6, 'Arrivée au pays', TRUE, 6);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (7, 'Disponible client', TRUE, 7);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (8, 'Remis', TRUE, 8);

-- END GRP Workflow


CREATE TABLE ref_workflow (
  id            SMALLINT      PRIMARY KEY,
  code          CHAR(2)       NOT NULL,
  description   VARCHAR(250)  NOT NULL,
  -- P for plane
  -- B for boat
  -- R for road
  mode          CHAR(1)       NOT NULL,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- The code or workflow may be duplicates but the code is different for the partner
-- mode is to know how to display Plane or B boat
INSERT INTO ref_workflow (id, code, description, mode) VALUES (1, 'TA', 'Paris Tana aérien', 'P');
INSERT INTO ref_workflow (id, code, description, mode) VALUES (6, 'TM', 'Paris Tana Maritime via Tamatave', 'B');


INSERT INTO ref_workflow (id, code, description, mode) VALUES (2, 'PA', 'Paris Pointe Noire aérien', 'P');
INSERT INTO ref_workflow (id, code, description, mode) VALUES (3, 'PM', 'Paris Pointe Noire maritime', 'B');
INSERT INTO ref_workflow (id, code, description, mode) VALUES (4, 'BA', 'Paris Brazzaville aérien', 'P');
INSERT INTO ref_workflow (id, code, description, mode) VALUES (5, 'BM', 'Paris Brazzaville maritime', 'B');


CREATE TABLE mod_workflow (
  id            SERIAL         PRIMARY KEY,
  wkf_id        SMALLINT       NOT NULL REFERENCES ref_workflow(id),
  start_id      SMALLINT       NOT NULL REFERENCES ref_status(id),
  end_id        SMALLINT       NOT NULL REFERENCES ref_status(id),
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Paris Tana Aérien
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 0, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 3, 1);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 1, 4);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 4, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 2, 6);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 6, 7);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 6, 8);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 6, 11);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 8, 9);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 7, 9);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 11, 9);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 9, 10);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 10, -1);


-- Paris Tana Maritime
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 0, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 3, 1);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 1, 4);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 4, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 2, 6);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 6, 14);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 14, 15);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 15, 9);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 9, 10);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (6, 10, -1);


-- Paris Pointe Noire Aérien
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 0, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 3, 1);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 1, 4);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 4, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 2, 6);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 6, 7);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 6, 8);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 6, 11);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 8, 12);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 7, 12);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 11, 12);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 12, 10);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (2, 10, -1);

-- Paris Brazzaville Aérien
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 0, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 3, 1);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 1, 4);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 4, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 2, 6);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 6, 7);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 6, 8);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 6, 11);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 8, 13);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 7, 13);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 11, 13);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 13, 10);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (4, 10, -1);


-- Paris Pointe Maritime
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 0, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 3, 1);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 1, 4);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 4, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 2, 6);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 6, 14);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 14, 12);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 12, 10);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (3, 10, -1);

-- Paris Brazzaville Maritime
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 0, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 3, 1);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 1, 4);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 4, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 2, 6);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 6, 14);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 14, 13);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 13, 10);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (5, 10, -1);



CREATE TABLE barcode(
  id                    BIGSERIAL      PRIMARY KEY,
  -- Is a code need to be calculated
  ref_tag               VARCHAR(25),
  -- Mostly beween 0 to 9999
  secure                SMALLINT       NOT NULL,
  -- Mostly beween 0 to 9999
  secret_code           SMALLINT       NOT NULL,
  -- Workflow id
  wf_id                 SMALLINT       DEFAULT 1,
  status                SMALLINT       DEFAULT 0,
  under_incident        BOOLEAN        DEFAULT FALSE,
  -- Short description such as Informatique or Zara or something else
  description           VARCHAR(250),
  -- in grams
  weight_in_gr          INT,
  -- delivery particularity
  category              CHAR(1) DEFAULT 'A',
  -- Delivery or Pickup ? Can be D or P
  type_pack             CHAR(1) DEFAULT 'D',
  -- used to be REFERENCES ref_partner(id)
  partner_id            INT            NOT NULL,
  -- creator id can be the partner or the client with high score who is granteed
  -- used to be  REFERENCES users(id)
  creator_id            BIGINT         NOT NULL,
  -- the owner can be null until it is addressed
  -- used to be REFERENCES users(id);
  owner_id              BIGINT         NOT NULL,
  ext_ref               VARCHAR(35)    UNIQUE,
  -- to if someone else come to retrieve at final step details
  to_name               VARCHAR(50),
  to_firstname          VARCHAR(50),
  to_phone              VARCHAR(50),
  -- Pick up/enlèvement details
  p_name_firstname      VARCHAR(50),
  p_phone               VARCHAR(50),
  p_address_note        VARCHAR(250),
  -- Handle price
  price_cts             SMALLINT  DEFAULT 0,
  paid_code             CHAR(1)   DEFAULT 'N',
  -- Handle mother feature
  -- In case it has a mother, this is not null
  mother_id             BIGINT,
  mother_ref            CHAR(11),
  -- billing id to attach a bill to it
  bill_id               BIGINT,
  -- Usual information
  update_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  create_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- INSERT INTO barcode (ref_tag, secure, secret_code) VALUES ('000000000', FLOOR(random() * 9999 + 1)::INT, FLOOR(random() * 9999 + 1)::INT);
-- ALTER TABLE barcode ADD COLUMN description           VARCHAR(250);

CREATE TABLE wk_tag(
  id                    BIGSERIAL      PRIMARY KEY,
  -- REFERENCES barcode(id)
  bc_id                 BIGINT         NOT NULL,
  -- REFERENCES users(id) who has done the action
  user_id               BIGINT         NOT NULL,
  -- This is the transition used to arrived to this step
  --  REFERENCES mod_workflow(id)
  mwkf_id               SMALLINT       NOT NULL,
  --  REFERENCES ref_status(id)
  current_step_id       SMALLINT       NOT NULL,
  geo_l                 VARCHAR(250)   DEFAULT 'N',
  is_incident           BOOLEAN        DEFAULT  FALSE,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE wk_tag_com(
  wk_tag_id BIGINT         PRIMARY KEY,
  user_id   BIGINT,
  comment   VARCHAR(500),
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wk_param(
  id                    BIGSERIAL      PRIMARY KEY,
  -- REFERENCES barcode(id)
  bc_id                 BIGINT         NOT NULL,
  -- REFERENCES users(id) who has done the action
  user_id               BIGINT         NOT NULL,
  comment               VARCHAR(500),
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

/* ------------------------------------------------------------------------------------------------ */

/*
select * from wk_tag;

select
		wt.bc_id,
		rtc.step,
		rte.id,
		rte.step,
		rte.description
		from mod_workflow mw join wk_tag wt on mw.id = wt.mwkf_id
											   and mw.start_id = wt.current_step_id
								join ref_status rtc on rtc.id = wt.current_step_id
								join ref_status rte on rte.id = mw.end_id
		  WHERE wt.id = 1
*/


-- SELECT * FROM CLI_ACT_TAG('39287392', 'N');
-- This retrieve possible steps
-- This action cannot be zero or one (personal client or reseller)
DROP FUNCTION IF EXISTS CLI_ACT_TAG(par_bc_id BIGINT, par_secure_id SMALLINT, user_id BIGINT, part_id INT, par_read_barcode VARCHAR(20), par_geo_l VARCHAR(250));
CREATE OR REPLACE FUNCTION CLI_ACT_TAG(par_bc_id BIGINT, par_secure_id SMALLINT, user_id BIGINT, part_id INT, par_read_barcode VARCHAR(20), par_geo_l VARCHAR(250))
  RETURNS TABLE ( bc_id                   BIGINT,
                  curr_inc                VARCHAR(500),
                  bc_type_pack            CHAR(1),
                  bc_category             CHAR(1),
                  mother_id               BIGINT,
                  mother_ref              CHAR(11),
                  rp_hdl_price            CHAR(1),
                  bc_paid_code            CHAR(1),
                  rse_act_owner           CHAR(1),
                  rse_next_input_needed   CHAR(1),
                  rwkf_id                 SMALLINT,
                  mwkf_id                 INT,
                  curr_step_id            SMALLINT,
                  curr_step               VARCHAR(50),
                  end_step_id             SMALLINT,
                  end_step                VARCHAR(50),
                  end_step_desc           VARCHAR(250)) AS
               -- Do the return at the end
$func$
DECLARE
  var_bc_id           BIGINT;
  var_found_barcode   SMALLINT;
  var_found_last_step SMALLINT;
  var_result_code     CHAR(2);
BEGIN
    -- Check if we found the barcode
    -- CG: We need to look per id not per code
    -- ref tag will be id and secure concatenation
    var_bc_id := NULL;

    IF par_bc_id > 0 THEN
      -- We are using owned barcode
      SELECT id INTO var_bc_id
        FROM barcode bc
        WHERE bc.id = par_bc_id
        AND bc.partner_id = part_id
        AND bc.secure = par_secure_id;
    ELSE
      -- We are in external case
      SELECT id INTO var_bc_id
        FROM barcode bc
        WHERE bc.ext_ref = par_read_barcode
        AND bc.partner_id = part_id;

    END IF;

    -- Now check the  last step
    var_found_last_step := NULL;
    SELECT MAX(id) INTO var_found_last_step
      FROM wk_tag wt
      WHERE wt.bc_id = var_bc_id;

    -- If the BC cannot be found, it is not created.

    -- Note that we can retrieve last status
    -- /!\ Alias column are given in hearder
   RETURN QUERY
   SELECT
    wt.bc_id,
    wtc.comment AS curr_inc,
    bc.type_pack AS bc_type_pack,
    bc.category AS bc_category,
    bc.mother_id AS bc_mother_id,
    bc.mother_ref AS bc_mother_ref,
    rp.hdl_price AS rp_hdl_price,
    bc.paid_code AS bc_paid_code,
    rte.act_owner AS rse_act_owner,
    rte.next_input_needed AS rse_next_input_needed,
    mw.wkf_id, -- here is PA
    mw.id,
    rtc.id,
    rtc.step,
		rte.id,
		rte.step,
		rte.description
		FROM mod_workflow mw JOIN wk_tag wt ON mw.wkf_id = wt.mwkf_id -- mod workflow id is the wf line we use
							             AND mw.start_id = wt.current_step_id
				                 JOIN ref_status rtc ON rtc.id = wt.current_step_id
				                 JOIN ref_status rte ON rte.id = mw.end_id
                         JOIN barcode bc ON bc.id = wt.bc_id
                         JOIN ref_partner rp ON bc.partner_id = rp.id
                         LEFT JOIN wk_tag_com wtc ON wtc.wk_tag_id = wt.id
		  WHERE wt.id = var_found_last_step;
END
$func$  LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS CLI_VERIF_CODE(BIGINT, SMALLINT);
CREATE OR REPLACE FUNCTION CLI_VERIF_CODE(BIGINT, SMALLINT)
-- By convention we return zero when everything is OK
RETURNS INTEGER AS $$
DECLARE
  var_return_code     SMALLINT;
  var_verif_code      SMALLINT;
BEGIN
    var_return_code := -1;
    var_verif_code := 0;

    IF NOT($2 IS NULL) THEN
      -- We need to get the secret code
      SELECT bc.secret_code INTO var_verif_code
        FROM barcode bc
        WHERE bc.id = $1;

      IF (var_verif_code = $2) THEN
        var_return_code := 0;
      END IF;
    END IF;

    -- If code is correct we return 0 else we return -1;
    RETURN var_return_code;
END;
$$ LANGUAGE plpgsql;


-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- Create Procedure Insert Step as we need to handle ref_status
-- CALL stored_procedure_name(parameter_list);
-- sql_query = "INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l)" "VALUES ("+ params[:stepcbid] +", "+ params[:steprwfid] +", "+ params[:stepstep] +", TRIM('"+ params[:stepgeol] +"'));"
-- (bc_id, mwkf_id, current_step_id, geo_l)
-- Change to a function to get notification
-- CREATE OR REPLACE FUNCTION CLI_STEP_TAG
DROP FUNCTION IF EXISTS CLI_STEP_TAG(BIGINT, SMALLINT, SMALLINT, VARCHAR(250), BIGINT, INT);
CREATE OR REPLACE FUNCTION CLI_STEP_TAG(BIGINT, SMALLINT, SMALLINT, VARCHAR(250), BIGINT, INT)
RETURNS TABLE (bc_id                   BIGINT,
                bc_sec                  SMALLINT,
                name                    VARCHAR(250),
                firstname               VARCHAR(250),
                to_addr                 VARCHAR(250),
                step                    VARCHAR(50),
                msg                     VARCHAR(250))
                -- Do the return at the end xxx
AS $$
DECLARE
  var_msg             VARCHAR(250);
  var_verif_code      SMALLINT;
BEGIN
    var_verif_code := 0;

    SELECT CASE WHEN (rs.txt_to_notify IS NULL) THEN rs.description ELSE rs.txt_to_notify END INTO var_msg
      FROM ref_status rs
      WHERE rs.id = $3;

    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l, user_id) VALUES ($1, $2, $3, $4, $5);

    -- Because Weight is specific action
    IF ($3 = 6) AND NOT($6 IS NULL) THEN
      -- We update the barcode with last status
      UPDATE barcode
        SET status = $3,
        weight_in_gr = $6,
        under_incident = FALSE,
        update_date = CURRENT_TIMESTAMP
        WHERE id = $1;

      var_msg := CONCAT(var_msg, ' Validation poids: ', ROUND($6::decimal/1000, 2)::varchar(20), ' Kilogrammes');

    ELSE
      -- We update the barcode with last status
      UPDATE barcode
        SET status = $3,
        under_incident = FALSE,
        update_date = CURRENT_TIMESTAMP
        WHERE id = $1;
    END IF;

    -- After Status update
    IF ($3 = 10) THEN
      -- The step 10 is verification code mandatory
      -- We need to get the secret code
      SELECT bc.secret_code INTO var_verif_code
        FROM barcode bc
        WHERE bc.id = $1;
      var_msg := CONCAT(var_msg, ' Votre code de vérification: ', var_verif_code::varchar(20), ' - ce code est confidentiel, ne le partagez pas.');
    END IF;


    RETURN QUERY
    SELECT
        bc.id,
        bc.secure,
        u.name,
        u.firstname,
        u.email,
        rs.step,
        var_msg
        FROM barcode bc JOIN users u ON u.id = bc.owner_id
                        JOIN ref_status rs ON rs.id = bc.status
                        WHERE bc.id = $1
                        -- Make sure we retrieve only when we need to notify
                        AND need_to_notify = TRUE;
END
$$ LANGUAGE plpgsql;



-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- Create Procedure Insert Step as we need to handle ref_status
-- CALL stored_procedure_name(parameter_list);
-- sql_query = "INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l)" "VALUES ("+ params[:stepcbid] +", "+ params[:steprwfid] +", "+ params[:stepstep] +", TRIM('"+ params[:stepgeol] +"'));"
-- (bc_id, mwkf_id, current_step_id, geo_l)
-- Change to a function to get notification
-- CREATE OR REPLACE FUNCTION CLI_PAYMT_TAG
DROP FUNCTION IF EXISTS CLI_PAYMT_TAG(BIGINT, CHAR(1), BIGINT, VARCHAR(50));
CREATE OR REPLACE FUNCTION CLI_PAYMT_TAG(BIGINT, CHAR(1), BIGINT, VARCHAR(50))
RETURNS TABLE (bc_id                   BIGINT,
                bc_sec                  SMALLINT,
                name                    VARCHAR(250),
                firstname               VARCHAR(250),
                to_addr                 VARCHAR(250),
                step                    VARCHAR(50),
                msg                     VARCHAR(250))
                -- Do the return at the end xxx
AS $$
DECLARE
  var_msg             VARCHAR(250);
BEGIN

    INSERT INTO wk_param (bc_id, user_id, comment) VALUES ($1, $3, $4);
    -- We update the barcode with last status
    UPDATE barcode
      SET paid_code = $2,
      update_date = CURRENT_TIMESTAMP
      WHERE id = $1;

    -- We need to notify
    RETURN QUERY
    SELECT
        bc.id,
        bc.secure,
        u.name,
        u.firstname,
        u.email,
        rs.step,
        $4
        FROM barcode bc JOIN users u ON u.id = bc.owner_id
                        JOIN ref_status rs ON rs.id = bc.status
                        WHERE bc.id = $1;
END
$$ LANGUAGE plpgsql;

-- This will not change the step but add a comment
-- Parameters are BC ID/USER ID/Comment
DROP FUNCTION IF EXISTS CLI_COM_TAG(BIGINT, BIGINT, VARCHAR(250));
CREATE OR REPLACE FUNCTION CLI_COM_TAG(BIGINT, BIGINT, VARCHAR(250))
RETURNS TABLE (bc_id                   BIGINT,
                bc_sec                  SMALLINT,
                name                    VARCHAR(250),
                firstname               VARCHAR(250),
                to_addr                 VARCHAR(250),
                step                    VARCHAR(50),
                msg                     VARCHAR(300))
                -- Do the return at the end xxx
AS $$
DECLARE
  var_last_wk_tag     BIGINT;
  var_incident_exists SMALLINT;
BEGIN

    var_incident_exists := 0;

    -- Retrieve the last wk_tag
    SELECT MAX(id) INTO var_last_wk_tag
      FROM wk_tag wt
      WHERE wt.bc_id = $1;


    SELECT COUNT(1) INTO var_incident_exists
      FROM wk_tag_com wtc
      WHERE wtc.wk_tag_id = var_last_wk_tag;

    IF var_incident_exists = 0 THEN
      -- No incident exist so we are safe to create one
      -- Be careful we can have only one comment per working tag
      INSERT INTO wk_tag_com (wk_tag_id, user_id, comment) VALUES (var_last_wk_tag, $2, $3);

      -- We update the barcode with last status
      UPDATE barcode
        SET update_date = CURRENT_TIMESTAMP,
        under_incident = TRUE
        WHERE id = $1;
    END IF;

    RETURN QUERY
    SELECT
        bc.id,
        bc.secure,
        u.name,
        u.firstname,
        u.email,
        CAST ('Stand by' AS VARCHAR(50)),
        CAST ('Votre paquet est en stand by: ' || $3 AS VARCHAR(300))
        FROM barcode bc JOIN users u ON u.id = bc.owner_id
                        WHERE bc.id = $1;

END
$$ LANGUAGE plpgsql;

-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- CALL stored_procedure_name(parameter_list);
-- CALL CLI_GRPSTEP_TAG_PURE('{20, 19, 18}'::BIGINT[], CAST(7 AS SMALLINT), 'N', 140);
DROP FUNCTION IF EXISTS CLI_GRPSTEP_TAG_PURE(par_bc_id_arr BIGINT[], par_target_step_id SMALLINT, par_geo_l VARCHAR(250), par_user_id BIGINT);
CREATE OR REPLACE FUNCTION CLI_GRPSTEP_TAG_PURE(par_bc_id_arr BIGINT[], par_target_step_id SMALLINT, par_geo_l VARCHAR(250), par_user_id BIGINT)
RETURNS TABLE (bc_id                   BIGINT,
                bc_sec                  SMALLINT,
                name                    VARCHAR(250),
                firstname               VARCHAR(250),
                to_addr                 VARCHAR(250),
                step                    VARCHAR(50),
                msg                     VARCHAR(300))
                -- Do the return at the end xxx
AS $$
DECLARE
    var_partner SMALLINT;
BEGIN
    var_partner := -1;
    SELECT partner INTO var_partner
      FROM users u
      WHERE u.id = par_user_id;

    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    -- select * from ref_status rs
    -- select * from ref_status where id IN (SELECT(UNNEST(('{5, 6, 7, 9}'::bigint[]))));
    INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l, user_id)
            SELECT id, wf_id, par_target_step_id, par_geo_l, par_user_id
            FROM barcode
            WHERE partner_id = var_partner
            AND id IN (SELECT(UNNEST((par_bc_id_arr))));


    -- We update the barcode with last status
    UPDATE barcode
      SET status = par_target_step_id,
      update_date = CURRENT_TIMESTAMP
      WHERE partner_id = var_partner
      AND id IN (SELECT(UNNEST((par_bc_id_arr))));

    RETURN QUERY
      SELECT
          bc.id,
          bc.secure,
          u.name,
          u.firstname,
          u.email,
          rs.step,
          CASE WHEN (rs.txt_to_notify IS NULL) THEN rs.description ELSE rs.txt_to_notify END
          FROM barcode bc JOIN users u ON u.id = bc.owner_id
                          JOIN ref_status rs ON rs.id = bc.status
                          WHERE bc.id IN (SELECT(UNNEST((par_bc_id_arr))))
                          -- Make sure we retrieve only when we need to notify
                          AND need_to_notify = TRUE;
END
$$ LANGUAGE plpgsql;

-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- CALL stored_procedure_name(parameter_list);
-- CALL CLI_GRPSTEP_TAG_EXT('{20, 19, 18}'::BIGINT[], CAST(7 AS SMALLINT), 'N', 140);
DROP FUNCTION IF EXISTS CLI_GRPSTEP_TAG_EXT(par_bc_ext_arr VARCHAR(35)[], par_target_step_id SMALLINT, par_geo_l VARCHAR(250), par_user_id BIGINT);
CREATE OR REPLACE FUNCTION CLI_GRPSTEP_TAG_EXT(par_bc_ext_arr VARCHAR(35)[], par_target_step_id SMALLINT, par_geo_l VARCHAR(250), par_user_id BIGINT)
RETURNS TABLE (bc_id                   BIGINT,
                bc_sec                  SMALLINT,
                name                    VARCHAR(250),
                firstname               VARCHAR(250),
                to_addr                 VARCHAR(250),
                step                    VARCHAR(50),
                msg                     VARCHAR(300))
                -- Do the return at the end xxx
AS $$
DECLARE
    var_partner SMALLINT;
BEGIN
    var_partner := -1;
    SELECT partner INTO var_partner
      FROM users u
      WHERE u.id = par_user_id;

    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    -- select * from ref_status rs
    -- select * from ref_status where id IN (SELECT(UNNEST(('{5, 6, 7, 9}'::bigint[]))));
    INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l, user_id)
            SELECT id, wf_id, par_target_step_id, par_geo_l, par_user_id
            FROM barcode
            WHERE partner_id = var_partner
            AND ext_ref IN (SELECT(UNNEST((par_bc_ext_arr))));


    -- We update the barcode with last status
    UPDATE barcode
      SET status = par_target_step_id,
      update_date = CURRENT_TIMESTAMP
      WHERE partner_id = var_partner
      AND ext_ref IN (SELECT(UNNEST((par_bc_ext_arr))));

    RETURN QUERY
      SELECT
          bc.id,
          bc.secure,
          u.name,
          u.firstname,
          u.email,
          rs.step,
          CASE WHEN (rs.txt_to_notify IS NULL) THEN rs.description ELSE rs.txt_to_notify END
          FROM barcode bc JOIN users u ON u.id = bc.owner_id
                          JOIN ref_status rs ON rs.id = bc.status
                          WHERE bc.ext_ref IN (SELECT(UNNEST((par_bc_ext_arr))))
                          -- Make sure we retrieve only when we need to notify
                          AND need_to_notify = TRUE;

END
$$ LANGUAGE plpgsql;


-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- Copy paste from CLI_STEP_TAG used only for ADDRESSING
-- param order : id, workflow id, localisation, external ref, tname, tfirstname, tphone
-- Todo change this to function to read the result if duplicate
DROP FUNCTION IF EXISTS  CLI_STEP_ADDR_TAG(BIGINT, SMALLINT, VARCHAR(250), VARCHAR(25), VARCHAR(50), VARCHAR(50), VARCHAR(20), BIGINT, VARCHAR(50), VARCHAR(50), VARCHAR(250));
CREATE OR REPLACE FUNCTION CLI_STEP_ADDR_TAG(BIGINT, SMALLINT, VARCHAR(250), VARCHAR(25), VARCHAR(50), VARCHAR(50), VARCHAR(20), BIGINT, VARCHAR(50), VARCHAR(50), VARCHAR(250))
-- By convention we return zero when everything is OK
RETURNS INTEGER AS $$
DECLARE
  var_return_code     SMALLINT;
  var_result_exists   SMALLINT;
BEGIN
    var_return_code := 0;

    -- Check if the ext ref is not null it does not EXISTS
    IF $4 = NULL THEN
      -- Do nothing as null is ok to be inserted in duplicate
    ELSE
      -- Check if any value exist
      -- If any value exists already we have more than zero
      SELECT COUNT(1) INTO var_return_code
        FROM barcode bc
        WHERE bc.ext_ref = $4;
    END IF;


    IF var_return_code = 0 THEN
        -- Do the INSERT
        -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], TRIM('params[:stepgeol]'));
        INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l, user_id) VALUES ($1, $2, 1, $3, $8);

        -- We update the barcode with last status
        UPDATE barcode
          SET status = 1,

          ext_ref = CASE WHEN $4 = '' THEN NULL ELSE $4 END,
          to_name = CASE WHEN $5 = '' THEN NULL ELSE $5 END,
          to_firstname = CASE WHEN $6 = '' THEN NULL ELSE $6 END,
          to_phone = CASE WHEN $7 = '' THEN NULL ELSE $7 END,

          p_name_firstname = CASE WHEN $9 = '' THEN NULL ELSE $9 END,
          p_phone = CASE WHEN $10 = '' THEN NULL ELSE $10 END,
          p_address_note = CASE WHEN $11 = '' THEN NULL ELSE $11 END,
          update_date = CURRENT_TIMESTAMP
          WHERE id = $1
          AND owner_id = $8;
    END IF;
    RETURN var_return_code;
END;
$$ LANGUAGE plpgsql;
-- Modify users
-- ADD firstname, phone number, is_company
-- This is the cross ref table for all partner to get their client
CREATE TABLE client_partner_xref (
  client_id     BIGINT,
  partner_id    SMALLINT,
  -- has power of creation of BC
  has_poc   BOOLEAN  DEFAULT  TRUE,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (client_id, partner_id)
);


INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'mgsuivi@protonmail.com'), 2);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'mgsuivi@gmail.com'), 2);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'tapotyetsesamis@gmail.com'), 2);

INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'mgsuivi@protonmail.com'), 3);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'mgsuivi@gmail.com'), 3);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'tapotyetsesamis@gmail.com'), 3);


INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'mgsuivi@protonmail.com'), 5);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'mgsuivi@gmail.com'), 5);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'tapotyetsesamis@gmail.com'), 5);


-- UPDATE users SET name = 'Delamare' WHERE email = 'tsiky.d@gmail.com';
-- UPDATE users SET name = 'Mada techno mafy' WHERE email = 'njara.h@gmail.com';

-- Error to be solved Here
-- UPDATE users set firstname = 'Rado' WHERE email = 'rado.r@gmail.com';


-- SELECT * FROM CLI_ADD_CLT(user_id BIGINT, par_email VARCHAR(255));
-- This action is attaching client to a company
-- 3 is initial error
-- 1 is not found
-- 2 is already in the list of partner
-- 4 is not activated
DROP FUNCTION IF EXISTS CLI_ADD_CLT(par_user_id BIGINT, par_email VARCHAR(255));
CREATE OR REPLACE FUNCTION CLI_ADD_CLT(par_user_id BIGINT, par_email VARCHAR(255))
  -- By convention we return zero when everything is OK
  RETURNS INTEGER AS
               -- Do the return at the end
$func$
DECLARE
  var_client_id       BIGINT;
  var_result          SMALLINT;
  var_result_exists   SMALLINT;
  var_partner_id      SMALLINT;
  var_is_activated    BOOLEAN;
BEGIN
    var_result := 3;
    -- Check if we found the email
    var_client_id := NULL;
    var_is_activated := FALSE;

    SELECT id, activated INTO var_client_id, var_is_activated
      FROM users u
      WHERE u.email = par_email
      AND u.partner IN (0, 1);

    IF var_client_id IS NULL THEN
      -- The client does not exists
      -- Todo : send an email to the client to create an account
      var_result := 1;
    ELSE

        -- Check if we found the partner
        -- par user id is the creator and work for the company
        var_partner_id := NULL;
        SELECT partner INTO var_partner_id
          FROM users u
          WHERE u.id = par_user_id;

        var_result_exists := 0;
        SELECT COUNT(1) INTO var_result_exists
          FROM client_partner_xref cpx
          WHERE cpx.client_id = var_client_id
                AND cpx.partner_id = var_partner_id;

        IF var_result_exists > 0 THEN
          -- The client is already a client of this company
          var_result := 2;
        ELSE
          -- Here we are good !
          INSERT INTO client_partner_xref (client_id, partner_id) VALUES (var_client_id, var_partner_id);

          IF var_is_activated = TRUE THEN
            var_result := 0;
          ELSE
            var_result := 4;
          END IF; -- is activated
        END IF;

    END IF;

   RETURN var_result;
END
$func$  LANGUAGE plpgsql;


-- SELECT * FROM CLI_ADD_CLT(user_id BIGINT, par_email VARCHAR(255));
-- This action is creating BC by partner or by client
-- Has this method can be used by the client we need to check the access right
DROP FUNCTION IF EXISTS CLI_CRT_BC(par_creator_id BIGINT, par_client_id BIGINT, par_partner_id SMALLINT, par_order CHAR(1));
DROP FUNCTION IF EXISTS CLI_CRT_BC(par_creator_id BIGINT, par_client_id BIGINT, par_partner_id SMALLINT, par_order CHAR(1), par_wf_id SMALLINT);
CREATE OR REPLACE FUNCTION CLI_CRT_BC(par_creator_id BIGINT, par_client_id BIGINT, par_partner_id SMALLINT, par_order CHAR(1), par_wf_id SMALLINT)
  -- By convention we return zero when everything is OK
  RETURNS BIGINT AS
               -- Do the return at the end
$func$
DECLARE
  var_partner_id                    SMALLINT;
  var_can_crt                       BOOLEAN;
  var_reach_limit                   BOOLEAN;
  var_bc_id                         BIGINT;
  var_ref_tag                       VARCHAR(25);
  var_secure                        SMALLINT;
  var_count_client_created          SMALLINT;
  var_max_bc_clt                    SMALLINT;

  var_result          BIGINT;
  var_result_exists   SMALLINT;
BEGIN
    var_result := -3;
    var_can_crt := FALSE;

    -- Check if the creator can create a BC
    var_partner_id := NULL;
    SELECT partner INTO var_partner_id
      FROM users u
      WHERE u.id = par_creator_id
      AND u.partner > 1
      AND u.activated = TRUE;


    -- Not in general way
    IF var_partner_id IS NULL THEN
      -- The creator is not a partner but client: personal or reseller
      -- For this partner
      SELECT has_poc INTO var_can_crt
        FROM client_partner_xref cpx
        WHERE cpx.client_id = par_creator_id
        AND cpx.partner_id = par_partner_id;

      -- We need to check the limit
      var_count_client_created := 0;
      SELECT COUNT(1) INTO var_count_client_created
        FROM barcode bc
        WHERE bc.create_date > NOW() - INTERVAL '7 DAY'
        AND bc.creator_id = par_creator_id;

      -- We retrieve the limit here but the main WORKFLOW as well
      SELECT max_bc_clt INTO var_max_bc_clt
          FROM ref_partner rp
          WHERE rp.id = par_partner_id;

      var_reach_limit := FALSE;

      IF var_count_client_created > var_max_bc_clt THEN
        var_reach_limit := TRUE;
        var_can_crt := FALSE;
      END IF;

    ELSE
      var_can_crt := TRUE;
    END IF;

    IF var_can_crt = TRUE THEN

      -- Do the insert
      var_secure := FLOOR(random() * 9999 + 1)::INT;
      INSERT INTO barcode (creator_id, owner_id, partner_id, wf_id, secure, secret_code, type_pack, status)
        VALUES (par_creator_id, par_client_id, par_partner_id, par_wf_id, var_secure, FLOOR(random() * 9999 + 1)::INT, par_order, CASE WHEN par_order = 'D' THEN 0 ELSE 3 END) RETURNING id INTO  var_bc_id;
      -- Need to insert the first step Nouveau
      INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, user_id) VALUES (var_bc_id, par_wf_id, CASE WHEN par_order = 'D' THEN 0 ELSE 3 END, par_creator_id);

      var_result := var_bc_id;
    ELSIF var_reach_limit = TRUE THEN
      -- The creator has no right to create more bc
      var_result := -3;
    ELSE
      -- The creator has no right to create bc
      var_result := -2;
    END IF;

   RETURN var_result;
END
$func$  LANGUAGE plpgsql;
-- Mother starts with M
CREATE TABLE mother(
  id                    BIGSERIAL      PRIMARY KEY,
  -- Mostly beween 0 to 9999
  secure                SMALLINT       NOT NULL,
  -- creator id can be the partner or the client with high score who is granteed
  creator_id            BIGINT         NOT NULL,
  -- Detail creation
  partner_id            INT            NOT NULL,
  -- Workflow id
  -- Default no workflow until we add one element
  wf_id                 SMALLINT       NOT NULL,
  status                SMALLINT,
  active                CHAR(1)        DEFAULT 'Y',
  under_incident        BOOLEAN        DEFAULT FALSE,
  -- Usual information
  update_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  create_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- This is the cross ref table for all mother to get their barcode
CREATE TABLE mother_barcode_xref (
  mother_id     BIGINT,
  bc_id         BIGINT,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (mother_id, bc_id)
);

-- STORED PROCEDURE STARTS


-- SELECT * FROM CLI_ADD_CLT(user_id BIGINT, par_email VARCHAR(255));
-- This action is creating BC by partner or by client
-- Has this method can be used by the client we need to check the access right
DROP FUNCTION IF EXISTS CLI_CRT_MOTHER(par_creator_id BIGINT, par_partner_id SMALLINT, par_wf_id SMALLINT);
CREATE OR REPLACE FUNCTION CLI_CRT_MOTHER(par_creator_id BIGINT, par_partner_id SMALLINT, par_wf_id SMALLINT)
  -- By convention we return zero when everything is OK
  RETURNS BIGINT AS
               -- Do the return at the end
$func$
DECLARE
  var_mother_id                     BIGINT;
  var_secure                        SMALLINT;

  var_result          BIGINT;
BEGIN
    var_result := -3;

    -- Do the insert
    var_secure := FLOOR(random() * 9999 + 1)::INT;

    INSERT INTO mother (secure, creator_id, partner_id, wf_id)
      VALUES (var_secure, par_creator_id, par_partner_id, par_wf_id) RETURNING id INTO  var_mother_id;

    var_result := CAST((CAST(var_mother_id AS VARCHAR) || LPAD(CAST(var_secure AS VARCHAR), 4, '0')) AS BIGINT);

    RETURN var_result;
END
$func$  LANGUAGE plpgsql;


-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- CALL stored_procedure_name(parameter_list);
-- CALL CLI_GRPASSO_PURE('{20, 19, 18}'::BIGINT[], CAST(7 AS SMALLINT), 'N', 140);
DROP FUNCTION IF EXISTS CLI_GRPASSO_PURE(par_bc_id_arr BIGINT[], par_user_id BIGINT, par_mother_id BIGINT, par_mother_ref CHAR(11));
CREATE OR REPLACE FUNCTION CLI_GRPASSO_PURE(par_bc_id_arr BIGINT[], par_user_id BIGINT, par_mother_id BIGINT, par_mother_ref CHAR(11))
RETURNS INTEGER
AS $$
DECLARE
    var_return_code SMALLINT;
    var_partner     SMALLINT;
    var_status      SMALLINT;
BEGIN
    var_return_code := -1;
    var_partner := -1;
    SELECT partner INTO var_partner
      FROM users u
      WHERE u.id = par_user_id;

    -- Get the current status to update mother
    SELECT DISTINCT status INTO var_status
      FROM barcode
      WHERE id IN (SELECT(UNNEST((par_bc_id_arr))));

    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    -- select * from ref_status rs
    -- select * from ref_status where id IN (SELECT(UNNEST(('{5, 6, 7, 9}'::bigint[]))));
    INSERT INTO wk_param (bc_id, user_id, comment)
            SELECT id, par_user_id, '+ ' || par_mother_ref || '//MOTHER'
            FROM barcode
            WHERE partner_id = var_partner
            AND id IN (SELECT(UNNEST((par_bc_id_arr))));


    -- INSERT with ignore in the xref table
    -- https://stackoverflow.com/questions/4069718/postgres-insert-if-does-not-exist-already
    INSERT INTO mother_barcode_xref (mother_id, bc_id)
            SELECT par_mother_id, id
            FROM barcode
            WHERE partner_id = var_partner
            AND id IN (SELECT(UNNEST((par_bc_id_arr))))
            ON CONFLICT (mother_id, bc_id) DO NOTHING;

    -- Update MOTHER - it must take the status
    UPDATE mother
      SET status = var_status,
          update_date = CURRENT_TIMESTAMP
      WHERE partner_id = var_partner
      AND id = par_mother_id;

    -- Update the BC with the Mother ref
    UPDATE barcode
      SET mother_id = par_mother_id,
          mother_ref = par_mother_ref,
          update_date = CURRENT_TIMESTAMP
      WHERE partner_id = var_partner
      AND id IN (SELECT(UNNEST((par_bc_id_arr))));

    var_return_code := 0;

    RETURN var_return_code;
END
$$ LANGUAGE plpgsql;



-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- CALL stored_procedure_name(parameter_list);
-- CALL CLI_GRPASSO_PURE('{20, 19, 18}'::BIGINT[], CAST(7 AS SMALLINT), 'N', 140);
-- CLI_GRPSTEP_TAG_EXT(par_bc_ext_arr VARCHAR(35)[], par_target_step_id SMALLINT, par_geo_l VARCHAR(250), par_user_id BIGINT)
DROP FUNCTION IF EXISTS CLI_GRPASSO_EXT(par_bc_ext_arr VARCHAR(35)[], par_user_id BIGINT, par_mother_id BIGINT, par_mother_ref CHAR(11));
CREATE OR REPLACE FUNCTION CLI_GRPASSO_EXT(par_bc_ext_arr VARCHAR(35)[], par_user_id BIGINT, par_mother_id BIGINT, par_mother_ref CHAR(11))
RETURNS INTEGER
AS $$
DECLARE
    var_return_code SMALLINT;
    var_partner     SMALLINT;
    var_status      SMALLINT;
BEGIN
    var_return_code := -1;
    var_partner := -1;
    SELECT partner INTO var_partner
      FROM users u
      WHERE u.id = par_user_id;

    -- Get the current status to update mother
    SELECT DISTINCT status INTO var_status
      FROM barcode
      WHERE ext_ref IN (SELECT(UNNEST((par_bc_ext_arr))));

    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    -- select * from ref_status rs
    -- select * from ref_status where id IN (SELECT(UNNEST(('{5, 6, 7, 9}'::bigint[]))));
    INSERT INTO wk_param (bc_id, user_id, comment)
            SELECT id, par_user_id, '+ ' || par_mother_ref || '//MOTHER'
            FROM barcode
            WHERE partner_id = var_partner
            AND ext_ref IN (SELECT(UNNEST((par_bc_ext_arr))));


    -- INSERT with ignore in the xref table
    -- https://stackoverflow.com/questions/4069718/postgres-insert-if-does-not-exist-already
    INSERT INTO mother_barcode_xref (mother_id, bc_id)
            SELECT par_mother_id, id
            FROM barcode
            WHERE partner_id = var_partner
            AND ext_ref IN (SELECT(UNNEST((par_bc_ext_arr))))
            ON CONFLICT (mother_id, bc_id) DO NOTHING;

    -- Update MOTHER - it must take the status
    UPDATE mother
      SET status = var_status,
          update_date = CURRENT_TIMESTAMP
      WHERE partner_id = var_partner
      AND id = par_mother_id;

    -- Update the BC with the Mother ref
    UPDATE barcode
      SET mother_id = par_mother_id,
          mother_ref = par_mother_ref,
          update_date = CURRENT_TIMESTAMP
      WHERE partner_id = var_partner
      AND ext_ref IN (SELECT(UNNEST((par_bc_ext_arr))));

    var_return_code := 0;

    RETURN var_return_code;
END
$$ LANGUAGE plpgsql;


-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- Create Procedure Insert Step as we need to handle ref_status
-- CALL stored_procedure_name(parameter_list);
-- sql_query = "INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l)" "VALUES ("+ params[:stepcbid] +", "+ params[:steprwfid] +", "+ params[:stepstep] +", TRIM('"+ params[:stepgeol] +"'));"
-- (array_of_mother_id, mwkf_id, step_id, geo_l, user_id)
-- Change to a function to get notification
-- CREATE OR REPLACE FUNCTION CLI_STEP_MT
DROP FUNCTION IF EXISTS CLI_STEP_MT(BIGINT[], SMALLINT, SMALLINT, VARCHAR(250), BIGINT);
CREATE OR REPLACE FUNCTION CLI_STEP_MT(BIGINT[], SMALLINT, SMALLINT, VARCHAR(250), BIGINT)
RETURNS TABLE (bc_id                   BIGINT,
                bc_sec                  SMALLINT,
                name                    VARCHAR(250),
                firstname               VARCHAR(250),
                to_addr                 VARCHAR(250),
                step                    VARCHAR(50),
                msg                     VARCHAR(250))
                -- Do the return at the end xxx
AS $$
DECLARE
  var_msg             VARCHAR(250);
BEGIN

    SELECT CASE WHEN (rs.txt_to_notify IS NULL) THEN rs.description ELSE rs.txt_to_notify END INTO var_msg
      FROM ref_status rs
      WHERE rs.id = $3;

    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l, user_id)
          SELECT mbx.bc_id, $2, $3, $4, $5
          FROM mother_barcode_xref mbx
          WHERE mother_id IN (SELECT(UNNEST(($1))));

    UPDATE barcode
      SET status = $3,
      under_incident = FALSE,
      update_date = CURRENT_TIMESTAMP
      WHERE id IN (
        SELECT mbx.bc_id FROM mother_barcode_xref mbx WHERE mother_id IN (SELECT(UNNEST(($1))))
      );

    UPDATE mother
      SET status = $3,
      under_incident = FALSE,
      update_date = CURRENT_TIMESTAMP
      WHERE id IN (SELECT(UNNEST(($1))));

    -- After Status update

    RETURN QUERY
    SELECT
        bc.id,
        bc.secure,
        u.name,
        u.firstname,
        u.email,
        rs.step,
        CASE WHEN ($3 = 10) THEN CONCAT(var_msg, ' Votre code de vérification: ', bc.secret_code::varchar(20), ' - ce code est confidentiel, ne le partagez pas.') ELSE var_msg END -- handle the case $3 = 10 here
        FROM barcode bc JOIN users u ON u.id = bc.owner_id
                        JOIN ref_status rs ON rs.id = bc.status
                        WHERE bc.id IN (
                          SELECT mbx.bc_id FROM mother_barcode_xref mbx WHERE mother_id IN (SELECT(UNNEST(($1))))
                        )
                        -- Make sure we retrieve only when we need to notify
                        AND need_to_notify = TRUE;
END
$$ LANGUAGE plpgsql;


-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- CALL stored_procedure_name(parameter_list);
-- CALL CLI_GRPASSO_PURE('{20, 19, 18}'::BIGINT[], CAST(7 AS SMALLINT), 'N', 140);
-- CLI_GRPSTEP_TAG_EXT(par_bc_ext_arr VARCHAR(35)[], par_target_step_id SMALLINT, par_geo_l VARCHAR(250), par_user_id BIGINT)
DROP FUNCTION IF EXISTS CLI_UNGRP_MT(par_bc_mt_arr BIGINT[], par_user_id BIGINT);
CREATE OR REPLACE FUNCTION CLI_UNGRP_MT(par_bc_mt_arr BIGINT[], par_user_id BIGINT)
RETURNS INTEGER
AS $$
DECLARE
    var_return_code SMALLINT;
    var_partner     SMALLINT;
    var_status      SMALLINT;
BEGIN
    var_return_code := -1;
    var_partner := -1;
    SELECT partner INTO var_partner
      FROM users u
      WHERE u.id = par_user_id;

    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    -- select * from ref_status rs
    -- select * from ref_status where id IN (SELECT(UNNEST(('{5, 6, 7, 9}'::bigint[]))));
    INSERT INTO wk_param (bc_id, user_id, comment)
            SELECT id, par_user_id, '- Dissocié//MOTHER'
            FROM barcode
            WHERE partner_id = var_partner
            AND mother_id IN (SELECT(UNNEST((par_bc_mt_arr))));


    -- Remove
    DELETE FROM mother_barcode_xref
            WHERE mother_id IN (SELECT(UNNEST((par_bc_mt_arr))));

    -- Update the BC with the Mother ref
    UPDATE barcode
      SET mother_id = NULL,
          mother_ref = NULL,
          update_date = CURRENT_TIMESTAMP
      WHERE partner_id = var_partner
      AND mother_id IN (SELECT(UNNEST((par_bc_mt_arr))));


    -- Update MOTHER - it must take the status
    UPDATE mother
      SET status = -2, -- Handle ended
          update_date = CURRENT_TIMESTAMP
      WHERE partner_id = var_partner
      AND id IN (SELECT(UNNEST((par_bc_mt_arr))));

    var_return_code := 0;

    RETURN var_return_code;
END
$$ LANGUAGE plpgsql;


-- This will not change the step but add a comment
-- Parameters are BC ID/USER ID/Comment
DROP FUNCTION IF EXISTS CLI_DECLARE_INC_MT(par_bc_mt_arr BIGINT[], par_user_id BIGINT);
CREATE OR REPLACE FUNCTION CLI_DECLARE_INC_MT(par_bc_mt_arr BIGINT[], par_user_id BIGINT)
RETURNS TABLE (bc_id                   BIGINT,
                bc_sec                  SMALLINT,
                name                    VARCHAR(250),
                firstname               VARCHAR(250),
                to_addr                 VARCHAR(250),
                step                    VARCHAR(50),
                msg                     VARCHAR(300))
                -- Do the return at the end xxx
AS $$
DECLARE
  var_last_wk_tag     BIGINT;
  var_incident_exists SMALLINT;
BEGIN


    -- Be careful we can have only one comment per working tag
    INSERT INTO wk_tag_com (wk_tag_id, user_id, comment)
                SELECT wt_id, par_user_id, 'Stand by - Opérationnel' FROM
                (
                    SELECT MAX(wt.id) AS wt_id, wt.bc_id AS bc_id
                    FROM wk_tag wt JOIN barcode bc ON bc.id = wt.bc_id
                                                    AND bc.under_incident = FALSE
                    WHERE bc.mother_id IN (SELECT(UNNEST((par_bc_mt_arr))))
                    GROUP BY wt.bc_id
                ) AS tp;

    -- Update the BC with the Mother ref
    UPDATE barcode
      SET under_incident = TRUE,
          update_date = CURRENT_TIMESTAMP
      WHERE mother_id IN (SELECT(UNNEST((par_bc_mt_arr)))) AND under_incident = FALSE;

    -- Update the BC with the Mother ref
    UPDATE mother
      SET under_incident = TRUE,
          update_date = CURRENT_TIMESTAMP
      WHERE id IN (SELECT(UNNEST((par_bc_mt_arr)))) AND under_incident = FALSE;

    RETURN QUERY
    SELECT
        bc.id,
        bc.secure,
        u.name,
        u.firstname,
        u.email,
        CAST ('Stand by' AS VARCHAR(50)),
        CAST ('Votre paquet a été mis en Stand By par un de nos fournisseurs. Nous vous tenons au courant de son évolution.' AS VARCHAR(300))
        FROM barcode bc JOIN users u ON u.id = bc.owner_id
                        WHERE bc.under_incident = TRUE
                        AND bc.mother_id IN (SELECT(UNNEST((par_bc_mt_arr))));

END
$$ LANGUAGE plpgsql;
