


INSERT INTO ref_workflow (id, code, description, mode) VALUES (7, 'MA', 'Tana manufacture', 'M');

INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (9, 'Créée', TRUE, 1);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (10, 'Commencée', TRUE, 2);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (11, 'Finalisée', TRUE, 3);
INSERT INTO grp_status (id, grp_step, common, order_id) VALUES (12, 'Réalisée', TRUE, 4);


-- Manufacturer status
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (16, 'Créée', 'Commande créée', 'Votre commande est créée.', 'N', 'P', 9, 'Y');
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (17, 'Commen.', 'Commande commencée', 'Un ouvrier a pris en charge votre commande.', 'N', 'P', 10, 'Y');
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (18, 'Finiti.', 'Commande en cours de finition', 'Votre commande est en cours de finition.', 'N', 'P', 11, 'Y');
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, grp_id, handle_mother) VALUES (19, 'Réali.', 'Commande réalisée', 'Votre commande est réalisée.', 'N', 'P', 12, 'Y');
INSERT INTO ref_status (id, step_short, step, description, next_input_needed, act_owner, need_to_notify, grp_id, handle_mother) VALUES (20, 'Dispo.', 'Disponible Client', 'Le client peut venir récupérer son paquet', 'N', 'P', TRUE, 7, 'Y');


INSERT INTO ref_partner (id, name, description, type, main_wf_id, to_phone, delivery_addr, hdl_price, hdl_mother, hdl_pickup) VALUES (6, 'Exemple Manufacture', 'Exemple Manufacture', 'M', 7, '032 89 879 38', 'RAKOTOMANGA@ LOT IIC AKT, ANTANANARIVO 101', 'N', 'Y', 'N');
INSERT INTO ref_partner_workflow (id, partner_id, wf_id, pickup_addr, pickup_phone) VALUES (8, 6, 7, 'LOT IIC AKT, ANTANANARIVO 101', '032 89 879 38');

-- Tana Manufacture
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (7, 16, 17);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (7, 17, 18);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (7, 18, 19);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (7, 19, 20);
INSERT INTO mod_workflow (wkf_id, start_id, end_id) VALUES (7, 20, -1);

ALTER TABLE grp_status ADD COLUMN mode CHAR(1) DEFAULT 'M';
update grp_status set mode = 'A' where id IN (7, 8);
update grp_status set mode = 'T' where id IN (1, 2, 3, 4, 5, 6);

update grp_status set id = 5007 where id = 7;
update grp_status set id = 5008 where id = 8;

update ref_status rs set grp_id = 5007 where rs.grp_id = 7;
update ref_status rs set grp_id = 5008 where rs.grp_id = 8;

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
  var_part_type                     CHAR(1);

  var_create_step_id                SMALLINT;

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

      -- Check if the partner is manufacturer
      -- par_partner_id > the partner on which we create the bc
      -- var_partner_id > we read if the creator is partner or not
      SELECT type INTO var_part_type
        FROM ref_partner rp
        WHERE rp.id = par_partner_id;

      -- Manufacture is overwritting
      var_create_step_id := CASE WHEN par_order = 'D' THEN 0 ELSE 3 END;
      var_create_step_id := CASE WHEN var_part_type = 'M' THEN 16 ELSE var_create_step_id END;

      -- Do the insert
      var_secure := FLOOR(random() * 9999 + 1)::INT;
      INSERT INTO barcode (creator_id, owner_id, partner_id, wf_id, secure, secret_code, type_pack, status)
        VALUES (par_creator_id, par_client_id, par_partner_id, par_wf_id, var_secure, FLOOR(random() * 9999 + 1)::INT, par_order, var_create_step_id) RETURNING id INTO  var_bc_id;
      -- Need to insert the first step Nouveau
      INSERT INTO wk_tag (bc_id, mwkf_id, current_step_id, user_id) VALUES (var_bc_id, par_wf_id, var_create_step_id, par_creator_id);

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
