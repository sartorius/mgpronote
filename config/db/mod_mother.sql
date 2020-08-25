-- Mother starts with M
CREATE TABLE mother(
  id                    BIGSERIAL      PRIMARY KEY,
  -- Mostly beween 0 to 9999
  secure                SMALLINT       NOT NULL,
  -- Detail creation
  partner_id            INT            NOT NULL,
  -- creator id can be the partner or the client with high score who is granteed
  creator_id            BIGINT         NOT NULL,
  -- Workflow id
  -- Default no workflow until we add one element
  wf_id                 SMALLINT       DEFAULT 0,
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
