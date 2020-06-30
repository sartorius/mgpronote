-- This is the cross ref table for all partner to get their client
CREATE TABLE client_partner_xref (
  client_id     BIGINT,
  partner_id    SMALLINT,
  -- has power of creation of BC
  has_poc   BOOLEAN  DEFAULT  FALSE,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (client_id, partner_id)
);

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
-- Generate tag
DROP FUNCTION IF EXISTS GEN_REFTAG(par_id BIGINT, par_secure SMALLINT);
CREATE OR REPLACE FUNCTION GEN_REFTAG(par_id BIGINT, par_secure SMALLINT)
  -- By convention we return zero when everything is OK
  RETURNS VARCHAR(25) AS
               -- Do the return at the end
$func$
DECLARE
  var_calc_ref_tag         VARCHAR(25);
  var_ref_tag_tp      CHAR(5);
  var_secure_tp       CHAR(3);
BEGIN

    var_ref_tag_tp := LPAD(CAST(par_id AS VARCHAR), 5, '0');
    var_secure_tp := LPAD(CAST(par_secure AS CHAR(3)), 3, '0');

    var_calc_ref_tag := CONCAT('M',
                          SUBSTRING(var_ref_tag_tp, 1, 3),
                          SUBSTRING(var_secure_tp, 1, 1),
                          SUBSTRING(var_ref_tag_tp, 4, 1),
                          SUBSTRING(var_secure_tp, 2, 1),
                          SUBSTRING(var_ref_tag_tp, 5, 1),
                          SUBSTRING(var_secure_tp, 3, 1));

   RETURN var_calc_ref_tag;
END
$func$  LANGUAGE plpgsql;



-- SELECT * FROM CLI_ADD_CLT(user_id BIGINT, par_email VARCHAR(255));
-- This action is creating BC by partner or by client
-- Has this method can be used by the client we need to check the access right
DROP FUNCTION IF EXISTS CLI_CRT_BC(par_creator_id BIGINT, par_client_id BIGINT, par_partner_id SMALLINT);
CREATE OR REPLACE FUNCTION CLI_CRT_BC(par_creator_id BIGINT, par_client_id BIGINT, par_partner_id SMALLINT)
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


      var_secure := FLOOR(random() * 999 + 1)::INT;
      INSERT INTO barcode (creator_id, owner_id, partner_id, secure, secret_code)
        VALUES (par_creator_id, par_client_id, par_partner_id, var_secure, FLOOR(random() * 9999 + 1)::INT) RETURNING id INTO  var_bc_id;

      UPDATE barcode SET ref_tag = GEN_REFTAG(var_bc_id, CAST(var_secure AS SMALLINT)) WHERE id = var_bc_id;

      var_result := var_bc_id;
    ELSE
      -- The creator has no right to create bc
      var_result := -2;
    END IF;

   RETURN var_result;
END
$func$  LANGUAGE plpgsql;
