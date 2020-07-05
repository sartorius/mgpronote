DROP TABLE IF EXISTS client_partner_xref;
DROP TABLE IF EXISTS wk_tag_com;
DROP TABLE IF EXISTS wk_tag;
DROP TABLE IF EXISTS barcode;
DROP TABLE IF EXISTS mod_workflow;
DROP TABLE IF EXISTS ref_workflow;
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
  website                       VARCHAR(500),
  delivery_addr                 VARCHAR(500),
  -- Where to retrieve in Madagascar
  pickup_addr                   VARCHAR(500),
  pickup_phone                  VARCHAR(20),
  -- Paris Workflow id
  main_wf_id    SMALLINT        DEFAULT 1,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

/*
ALTER TABLE ref_partner ADD COLUMN pickup_phone VARCHAR(20);
UPDATE ref_partner SET pickup_phone = '0326711567' WHERE id IN (2);
UPDATE ref_partner SET pickup_phone = '0338919064' WHERE id IN (3);
UPDATE ref_partner SET to_phone = '0624788912' WHERE id IN (2);
UPDATE ref_partner SET to_phone = '0764288678' WHERE id IN (3);
*/

-- These are example of Carrier
INSERT INTO ref_partner (id, name, description) VALUES (0, 'Particulier', 'Client particulier, je suis le consommateur final du produit');
INSERT INTO ref_partner (id, name, description, type) VALUES (1, 'Revendeur', 'Revendeur, je revends les produits que j''ai commandé', 'R');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, pickup_addr, pickup_phone) VALUES (2, 'Dummy Transporteur', 'Exemple de transporteur', 'C', 1, '0624788912', '48 Rue de la Boétie, 93078 Les Pinsons de la Rivière', 'Box 762, Centre Riviera Malaza Tana 101', '0326711567');

INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, pickup_addr, pickup_phone) VALUES (3, 'Fanny Service Transport', 'Exemple de transporteur 2', 'C', 1, '0764288678', '78 Rue de la Gare, 92304 Maison la Foire', 'Box 782, Centre La City Hazobe Tana 101', '0338919064');

-- Need a cross table partner x mod_workflow
-- Need a cross table client x partner


-- Todo add pickup phone
-- Transition ref
CREATE TABLE ref_status (
  id                  SMALLINT      PRIMARY KEY,
  step                VARCHAR(50)   NOT NULL,
  description         VARCHAR(250)  NOT NULL,
  next_input_needed   CHAR(1)       NOT NULL,
  -- A All
  -- P Partner
  -- Q Personal Reseller
  act_owner           CHAR(1)       NOT NULL,
  need_to_notify      BOOLEAN       DEFAULT FALSE,
  -- if need to notify and txt is null, use description
  txt_to_notify       VARCHAR(250),
  create_date         TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

/*

ALTER TABLE ref_status ADD COLUMN need_to_notify BOOLEAN DEFAULT FALSE;
UPDATE ref_status SET need_to_notify = TRUE WHERE id IN (-1, 0, 6, 10);

ALTER TABLE ref_status ADD COLUMN txt_to_notify VARCHAR(250);
UPDATE ref_status SET txt_to_notify = 'Vous venez de recevoir une référence paquet. Vous avez une action à faire: renseigner le.la réceptionneur.euse, veuillez vous connecter pour effectuer cette action.' WHERE id IN (0);
UPDATE ref_status SET description = 'Le poids a été validé.' WHERE id IN (6);

*/




INSERT INTO ref_status (id, step, description, next_input_needed, act_owner, need_to_notify) VALUES (-1, 'Terminée', 'La gestion de ce paquet est terminée.', 'N', 'P', TRUE);
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner, need_to_notify) VALUES (0, 'Nouveau', 'Ce code barre vient d''être créé.', 'Y', 'P', TRUE);
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (1, 'Adressé', 'Les informations du réceptionneur.euse ont été saisis, avec information enlèvement si nécessaires.', 'N', 'Q');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (2, 'Reception', 'Le paquet a été réceptionné.', 'N', 'P');
-- INSERT INTO ref_status (id, step, description, next_input_needed) VALUES (3, 'Adressé enlèvement', 'Les informations de l''enlèvement ont été saisis. Prêt à être enlevé', 'Y');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (4, 'Enlèvement', 'Le paquet a été enlevé à l''adresse indiqué.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (5, 'Dépôt stock Paris', 'Le paquet a été déposé en zone de stockage.', 'Y', 'P', TRUE);
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner, need_to_notify) VALUES (6, 'Pesé', 'Le poids a été validé.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (7, 'Dépôt frêt CDG', 'Le paquet a été déposé en zone de frêt CDG.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (8, 'Dépôt frêt Orly', 'Le paquet a été déposé en zone de frêt Orly.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (9, 'Arrivé Tana', 'Le paquet est arrivé à Tana. Il est en formalité entrée de territoire.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner, need_to_notify) VALUES (10, 'Disponible Client', 'Le client peut venir récupérer son paquet', 'N', 'P', TRUE);

UPDATE ref_status SET txt_to_notify = 'Vous venez de recevoir une référence paquet. Vous avez une action à faire: renseigner le.la réceptionneur.euse, veuillez vous connecter pour effectuer cette action.' WHERE id IN (0);


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
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 1, 4);
-- INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (1, 3, 4);
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
  -- If someone else need to come for pick up
  to_name               VARCHAR(50),
  to_firstname          VARCHAR(50),
  to_phone              VARCHAR(50),
  p_name_firstname      VARCHAR(50),
  p_phone               VARCHAR(50),
  p_address_note        VARCHAR(250),
  update_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  create_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- INSERT INTO barcode (ref_tag, secure, secret_code) VALUES ('000000000', FLOOR(random() * 9999 + 1)::INT, FLOOR(random() * 9999 + 1)::INT);


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
                  rse_act_owner           CHAR(1),
                  rse_next_input_needed   CHAR(1),
                  rwkf_id                 SMALLINT,
                  mwkf_id                 INT,
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
    rte.act_owner AS rse_act_owner,
    rte.next_input_needed AS rse_next_input_needed,
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
                         JOIN barcode bc ON bc.id = wt.bc_id
                         LEFT JOIN wk_tag_com wtc ON wtc.wk_tag_id = wt.id
		  WHERE wt.id = var_found_last_step;
END
$func$  LANGUAGE plpgsql;


-- /!\ NEW PARAMETERS NEED TO BE APPEND AT THE END !!! !!!
-- Create Procedure Insert Step as we need to handle ref_status
-- CALL stored_procedure_name(parameter_list);
-- sql_query = "INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l)" "VALUES ("+ params[:stepcbid] +", "+ params[:steprwfid] +", "+ params[:stepstep] +", TRIM('"+ params[:stepgeol] +"'));"
-- (bc_id, mwkf_id, current_step_id, geo_l)
-- Change to a function to get notification
-- CREATE OR REPLACE FUNCTION CLI_ACT_TAG
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
BEGIN
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

    ELSE
      -- We update the barcode with last status
      UPDATE barcode
        SET status = $3,
        under_incident = FALSE,
        update_date = CURRENT_TIMESTAMP
        WHERE id = $1;
    END IF;

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
                        WHERE bc.id = $1
                        -- Make sure we retrieve only when we need to notify
                        AND need_to_notify = TRUE;
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
        CAST ('Incident' AS VARCHAR(50)),
        CAST ('Un incident a été relevé: ' || $3 AS VARCHAR(300))
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
  has_poc   BOOLEAN  DEFAULT  FALSE,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (client_id, partner_id)
);

INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'njara.h@gmail.com'), 2);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'tsiky.d@gmail.com'), 2);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'hanitra.r@gmail.com'), 2);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'maeva.r@gmail.com'), 2);
-- Error to be solved Here
UPDATE users set firstname = 'Rado' WHERE email = 'rado.r@gmail.com';

-- SELECT * FROM CLI_ADD_CLT(user_id BIGINT, par_email VARCHAR(255));
-- This action is attaching client to a company
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
BEGIN
    var_result := 3;
    -- Check if we found the email
    var_client_id := NULL;
    SELECT id INTO var_client_id
      FROM users u
      WHERE u.email = par_email
      AND u.partner IN (0, 1)
      AND u.activated = TRUE;

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
          var_result := 0;
        END IF;

    END IF;

   RETURN var_result;
END
$func$  LANGUAGE plpgsql;


-- SELECT * FROM CLI_ADD_CLT(user_id BIGINT, par_email VARCHAR(255));
-- This action is creating BC by partner or by client
-- Has this method can be used by the client we need to check the access right
DROP FUNCTION IF EXISTS CLI_CRT_BC(par_creator_id BIGINT, par_client_id BIGINT, par_partner_id SMALLINT, par_order CHAR(1));
CREATE OR REPLACE FUNCTION CLI_CRT_BC(par_creator_id BIGINT, par_client_id BIGINT, par_partner_id SMALLINT, par_order CHAR(1))
  -- By convention we return zero when everything is OK
  RETURNS BIGINT AS
               -- Do the return at the end
$func$
DECLARE
  var_partner_id      SMALLINT;
  var_can_crt         BOOLEAN;
  var_bc_id           BIGINT;
  var_ref_tag         VARCHAR(25);
  var_secure          SMALLINT;

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

    IF var_partner_id IS NULL THEN
      -- The creator is not a partner but client: personal or reseller
      -- For this partner
      SELECT has_poc INTO var_can_crt
        FROM client_partner_xref cpx
        WHERE cpx.client_id = par_creator_id
        AND cpx.partner_id = par_partner_id;

    ELSE
      var_can_crt := TRUE;
    END IF;

    IF var_can_crt = TRUE THEN

      var_secure := FLOOR(random() * 9999 + 1)::INT;
      INSERT INTO barcode (creator_id, owner_id, partner_id, secure, secret_code, type_pack)
        VALUES (par_creator_id, par_client_id, par_partner_id, var_secure, FLOOR(random() * 9999 + 1)::INT, par_order) RETURNING id INTO  var_bc_id;
      -- Need to insert the first step Nouveau
      INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, user_id) VALUES (var_bc_id, 1, 0, par_creator_id);

      var_result := var_bc_id;
    ELSE
      -- The creator has no right to create bc
      var_result := -2;
    END IF;

   RETURN var_result;
END
$func$  LANGUAGE plpgsql;
