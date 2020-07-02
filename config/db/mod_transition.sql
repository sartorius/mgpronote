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
  create_date         TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (-1, 'Terminée', 'La gestion de ce paquet est terminée.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (0, 'Nouveau', 'Ce code barre vient d''être créé.', 'Y', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (1, 'Adressé', 'Les informations du réceptionneur.euse ont été saisis, avec information enlèvement si nécessaires.', 'N', 'Q');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (2, 'Reception', 'Le paquet a été réceptionné.', 'N', 'P');
-- INSERT INTO ref_status (id, step, description, next_input_needed) VALUES (3, 'Adressé enlèvement', 'Les informations de l''enlèvement ont été saisis. Prêt à être enlevé', 'Y');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (4, 'Enlèvement', 'Le paquet a été enlevé à l''adresse indiqué.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (5, 'Dépôt stock Paris', 'Le paquet a été déposé en zone de stockage.', 'Y', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (6, 'Pesé', 'Le poids ont été validé.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (7, 'Dépôt frêt CDG', 'Le paquet a été déposé en zone de frêt CDG.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (8, 'Dépôt frêt Orly', 'Le paquet a été déposé en zone de frêt Orly.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (9, 'Arrivé Tana', 'Le paquet est arrivé à Tana. Il est en formalité entrée de territoire.', 'N', 'P');
INSERT INTO ref_status (id, step, description, next_input_needed, act_owner) VALUES (10, 'Disponible Client', 'Le client peut venir récupérer son paquet', 'N', 'P');


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
  owner_id              BIGINT,
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
-- This action is creating the bar code if it does not exist
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
        AND bc.secure = par_secure_id;
    ELSE
      -- We are in external case
      SELECT id INTO var_bc_id
        FROM barcode bc
        WHERE bc.ext_ref = par_read_barcode;

    END IF;

    IF var_bc_id IS NULL THEN
      -- Bar code is new // or do not exist
      -- This need to be changed later when we have the barcode format
      -- The status will be zero by default
      INSERT INTO barcode (creator_id, partner_id, ref_tag, secure, secret_code)
        VALUES (user_id, part_id, par_read_barcode, FLOOR(random() * 999 + 1)::INT, FLOOR(random() * 9999 + 1)::INT) RETURNING id INTO  var_bc_id;
    END IF;

    -- Now check the  last step
    var_found_last_step := NULL;
    SELECT MAX(id) INTO var_found_last_step
      FROM wk_tag wt
      WHERE wt.bc_id = var_bc_id;

    IF var_found_last_step IS NULL THEN
      INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l, user_id)
        VALUES (var_bc_id, 1, 0, par_geo_l, user_id) RETURNING id INTO  var_found_last_step;
    END IF;


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
DROP PROCEDURE IF EXISTS CLI_STEP_TAG(BIGINT, SMALLINT, SMALLINT, VARCHAR(250), BIGINT);
CREATE OR REPLACE PROCEDURE CLI_STEP_TAG(BIGINT, SMALLINT, SMALLINT, VARCHAR(250), BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Do the INSERT
    -- INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l) VALUES (params[:stepcbid], params[:steprwfid], params[:stepstep], TRIM('params[:stepgeol]'));
    INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, geo_l, user_id) VALUES ($1, $2, $3, $4, $5);

    -- We update the barcode with last status
    UPDATE barcode
      SET status = $3,
      under_incident = FALSE,
      update_date = CURRENT_TIMESTAMP
      WHERE id = $1;

    COMMIT;
END;
$$;

-- This will not change the step but add a comment
-- Parameters are BC ID/USER ID/Comment
DROP PROCEDURE IF EXISTS CLI_COM_TAG(BIGINT, BIGINT, VARCHAR(250));
CREATE OR REPLACE PROCEDURE CLI_COM_TAG(BIGINT, BIGINT, VARCHAR(250))
LANGUAGE plpgsql
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


    COMMIT;
END;
$$;


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
          WHERE id = $1;
    END IF;
    RETURN var_return_code;
END;
$$ LANGUAGE plpgsql;
