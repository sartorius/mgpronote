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
  status                SMALLINT       DEFAULT 0,
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
