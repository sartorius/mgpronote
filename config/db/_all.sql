DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS wk_tag_com;
DROP TABLE IF EXISTS wk_tag;
DROP TABLE IF EXISTS barcode;
DROP TABLE IF EXISTS mod_workflow;
DROP TABLE IF EXISTS ref_workflow;
DROP TABLE IF EXISTS ref_transition;
DROP TABLE IF EXISTS ref_status;
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
-- Transition ref


CREATE TABLE ref_status (
  id            SMALLINT      PRIMARY KEY,
  step          VARCHAR(50)   NOT NULL,
  description   VARCHAR(250)  NOT NULL,
  input_needed  CHAR(1)       NOT NULL,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ref_status (id, step, description, input_needed) VALUES (-1, 'Terminée', 'La gestion de ce paquet est terminée.', 'N');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (0, 'Nouveau', 'Ce code barre vient d''être créé.', 'N');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (1, 'Adressé destinataire', 'Les informations nom, prénom et adresse du destinataire ont été saisis.', 'Y');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (2, 'Reception', 'Le paquet a été réceptionné.', 'N');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (3, 'Adressé enlèvement', 'Les informations de l''enlèvement ont été saisis. Prêt à être enlevé', 'Y');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (4, 'Enlèvement', 'Le paquet a été enlevé à l''adresse indiqué.', 'N');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (5, 'Dépôt stock Paris', 'Le paquet a été déposé en zone de stockage.', 'N');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (6, 'Pesé', 'Le poids ont été validé.', 'Y');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (7, 'Dépôt frêt CDG', 'Le paquet a été déposé en zone de frêt CDG.', 'N');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (8, 'Dépôt frêt Orly', 'Le paquet a été déposé en zone de frêt Orly.', 'N');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (9, 'Arrivé Tana', 'Le paquet est arrivé à Tana. Il est en formalité entrée de territoire.', 'N');
INSERT INTO ref_status (id, step, description, input_needed) VALUES (10, 'Disponible Client', 'Le client peut venir récupérer son paquet', 'N');


CREATE TABLE ref_workflow (
  id            SMALLINT      PRIMARY KEY,
  code          CHAR(2)       NOT NULL,
  description   VARCHAR(250)  NOT NULL,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ref_workflow (id, code, description) VALUES (1, 'PA', 'Flux process Paris Tana standard');


CREATE TABLE mod_workflow (
  id            SERIAL         PRIMARY KEY,
  wkf_id        SMALLINT       NOT NULL REFERENCES ref_workflow(id),
  start_id      SMALLINT       NOT NULL REFERENCES ref_status(id),
  end_id        SMALLINT       NOT NULL REFERENCES ref_status(id),
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 0, 1);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 1, 2);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 1, 3);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 3, 4);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 4, 5);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 2, 5);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 5, 6);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 6, 7);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 6, 8);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 8, 9);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 7, 9);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 9, 10);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 10, -1);

/*
select rw.code, rfs.step, rfe.step
                              from mod_workflow mw join ref_status rfs on rfs.id = mw.start_id
                              join ref_status rfe on rfe.id = mw.end_id
                              join ref_workflow rw on rw.id = mw.wkf_id
                                                    and rw.id = 1;
*/


CREATE TABLE barcode(
  id                    BIGSERIAL      PRIMARY KEY,
  -- Should reference user id
  ref_tag               VARCHAR(20)    NOT NULL,
  -- Mostly beween 0 to 9999
  secure                SMALLINT       NOT NULL,
  -- Mostly beween 0 to 9999
  secret_code           SMALLINT       NOT NULL,
  status                SMALLINT       DEFAULT 0,
  partner_id            INT            NOT NULL REFERENCES ref_partner(id),
  -- creator id can be the partner or the client with high score who is granteed
  creator_id            BIGINT         NOT NULL REFERENCES users(id),
  -- the owner can be null until it is addressed
  owner_id              BIGINT         REFERENCES users(id),
  -- If someone else need to come for pick up
  to_name               VARCHAR(50),
  to_firstname          VARCHAR(50),
  to_phone              VARCHAR(50),
  update_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  create_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- INSERT INTO barcode (ref_tag, secure, secret_code) VALUES ('000000000', FLOOR(random() * 9999 + 1)::INT, FLOOR(random() * 9999 + 1)::INT);


CREATE TABLE wk_tag(
  id                    BIGSERIAL      PRIMARY KEY,
  bc_id                 BIGINT         NOT NULL REFERENCES barcode(id),
  -- This is the transition used to arrived to this step
  mwkf_id               SMALLINT       NOT NULL REFERENCES mod_workflow(id),
  current_step_id       SMALLINT       NOT NULL REFERENCES ref_status(id),
  geo_l                 VARCHAR(250)   DEFAULT 'N',
  is_incident           BOOLEAN        DEFAULT  FALSE,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE wk_tag_com(
  id        BIGSERIAL      PRIMARY KEY,
  wk_tag_id BIGINT         NOT NULL REFERENCES wk_tag(id),
  comment   VARCHAR(500)
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
-- This action is creating the bar code if it does not exist
-- This action canoot be zero or one (personal client or reseller)
DROP FUNCTION IF EXISTS CLI_ACT_TAG(user_id BIGINT, part_id INT, par_read_barcode VARCHAR(20), par_geo_l VARCHAR(250));
CREATE OR REPLACE FUNCTION CLI_ACT_TAG(user_id BIGINT, part_id INT, par_read_barcode VARCHAR(20), par_geo_l VARCHAR(250))
  RETURNS TABLE ( bc_id         BIGINT,
                  rwkf_id       SMALLINT,
                  mwkf_id       INT,
                  curr_step     VARCHAR(50),
                  end_step_id   SMALLINT,
                  end_step      VARCHAR(50),
                  end_step_desc VARCHAR(250)) AS
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
    SELECT id INTO var_bc_id
      FROM barcode bc
      WHERE bc.ref_tag = par_read_barcode;

    IF var_bc_id IS NULL THEN
      -- Bar code is new // or do not exist
      -- This need to be changed later when we have the barcode format
      -- The status will be zero by default
      INSERT INTO barcode (creator_id, partner_id, ref_tag, secure, secret_code)
        VALUES (user_id, part_id, par_read_barcode, FLOOR(random() * 9999 + 1)::INT, FLOOR(random() * 9999 + 1)::INT) RETURNING id INTO  var_bc_id;
    END IF;

    -- Now check the  last step
    var_found_last_step := NULL;
    SELECT MAX(id) INTO var_found_last_step
      FROM wk_tag wt
      WHERE wt.bc_id = var_bc_id;

    IF var_found_last_step IS NULL THEN
      INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l)
        VALUES (var_bc_id, 1, 0, par_geo_l) RETURNING id INTO  var_found_last_step;
    END IF;


   RETURN QUERY
   SELECT
    wt.bc_id,
    mw.wkf_id, -- here is PA
    mw.id,
    rtc.step,
		rte.id,
		rte.step,
		rte.description
		FROM mod_workflow mw JOIN wk_tag wt ON mw.wkf_id = wt.mwkf_id -- mod workflow id is the wf line we use
							             AND mw.start_id = wt.current_step_id
				                 JOIN ref_status rtc ON rtc.id = wt.current_step_id
				                 JOIN ref_status rte ON rte.id = mw.end_id
		  WHERE wt.id = var_found_last_step;
END
$func$  LANGUAGE plpgsql;


-- Create Procedure Insert Step as we need to handle ref_status
-- CALL stored_procedure_name(parameter_list);
-- sql_query = "INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l)" "VALUES ("+ params[:stepcbid] +", "+ params[:steprwfid] +", "+ params[:stepstep] +", TRIM('"+ params[:stepgeol] +"'));"
-- (bc_id, mwkf_id, current_step_id, geo_l)
CREATE OR REPLACE PROCEDURE CLI_STEP_TAG(BIGINT, SMALLINT, SMALLINT, VARCHAR(250))
LANGUAGE plpgsql
AS $$
BEGIN
    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES ($1, $2, $3, $4);

    -- We update the barcode with last status
    UPDATE barcode
      SET status = $3, update_date = CURRENT_TIMESTAMP
      WHERE id = $1;

    COMMIT;
END;
$$;
-- Modify users
-- ADD firstname, phone number, is_company
