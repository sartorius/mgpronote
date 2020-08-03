-- This is the cross ref table for all partner to get their client
CREATE TABLE client_partner_xref (
  client_id     BIGINT,
  partner_id    SMALLINT,
  -- has power of creation of BC
  has_poc   BOOLEAN  DEFAULT  TRUE,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (client_id, partner_id)
);


INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'njara.h@gmail.com'), 2);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'tsiky.d@gmail.com'), 2);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'hanitra.r@gmail.com'), 2);
INSERT INTO client_partner_xref (client_id, partner_id) VALUES ((SELECT id FROM users WHERE email = 'maeva.r@gmail.com'), 2);


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
CREATE OR REPLACE FUNCTION CLI_CRT_BC(par_creator_id BIGINT, par_client_id BIGINT, par_partner_id SMALLINT, par_order CHAR(1))
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

      var_secure := FLOOR(random() * 9999 + 1)::INT;
      INSERT INTO barcode (creator_id, owner_id, partner_id, secure, secret_code, type_pack, status)
        VALUES (par_creator_id, par_client_id, par_partner_id, var_secure, FLOOR(random() * 9999 + 1)::INT, par_order, CASE WHEN par_order = 'D' THEN 0 ELSE 3 END) RETURNING id INTO  var_bc_id;
      -- Need to insert the first step Nouveau
      INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, user_id) VALUES (var_bc_id, 1, CASE WHEN par_order = 'D' THEN 0 ELSE 3 END, par_creator_id);

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
