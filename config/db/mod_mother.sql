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
  nbr_bc                SMALLINT       DEFAULT 0,
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
