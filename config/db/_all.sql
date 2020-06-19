DROP TABLE IF EXISTS tag;

CREATE TABLE tag (
  id    BIGSERIAL     PRIMARY KEY,
  bc    VARCHAR(50)   NOT NULL,
  step  VARCHAR(100)  NOT NULL,
  geo   VARCHAR(200)  NOT NULL,
  create_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- Transition ref

DROP TABLE IF EXISTS ref_transition;

CREATE TABLE ref_transition (
  id            SMALLINT      PRIMARY KEY,
  step          VARCHAR(50)   NOT NULL,
  description   VARCHAR(250)  NOT NULL,
  input_needed  CHAR(1)       NOT NULL,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ref_transition (id, step, description, input_needed) VALUES (0, 'Nouveau', 'Ce code barre vient d''être créé.', 'N');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (1, 'Adressé destinataire', 'Les informations du destinataire ont été saisis.', 'Y');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (2, 'Reception', 'Le paquet a été réceptionné.', 'N');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (3, 'Adressé enlèvement', 'Les informations de l''enlèvement ont été saisis.', 'Y');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (4, 'Enlèvement', 'Le paquet a été enlevé à l''adresse indiqué.', 'N');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (5, 'Dépôt stock Paris', 'Le paquet a été déposé en zone de stockage.', 'N');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (6, 'Pesé', 'Les information de poids ont été saisis.', 'Y');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (7, 'Dépôt frêt CDG', 'Le paquet a été déposé en zone de frêt CDG.', 'N');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (8, 'Dépôt frêt Orly', 'Le paquet a été déposé en zone de frêt Orly.', 'N');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (9, 'Arrivé Tana', 'Le paquet est arrivé à Tana. Il est en formalité de sortie.', 'N');
INSERT INTO ref_transition (id, step, description, input_needed) VALUES (10, 'Disponible Client', 'Le client peut venir récupérer son colis', 'N');

DROP TABLE IF EXISTS ref_workflow;

CREATE TABLE ref_workflow (
  id            SMALLINT      PRIMARY KEY,
  code          CHAR(2)       NOT NULL,
  description   VARCHAR(250)  NOT NULL,
  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ref_workflow (id, code, description) VALUES (1, 'PA', 'Flux process Paris Tana standard');

DROP TABLE IF EXISTS mod_workflow;

CREATE TABLE mod_workflow (
  id            SERIAL      PRIMARY KEY,
  wkf_id        SMALLINT       NOT NULL,
  start_id      SMALLINT       NOT NULL,
  end_id        SMALLINT       NOT NULL
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


select rw.code, rfs.step, rfe.step
                              from mod_workflow mw join ref_transition rfs on rfs.id = mw.start_id
                              join ref_transition rfe on rfe.id = mw.end_id
                              join ref_workflow rw on rw.id = mw.wkf_id
                                                    and rw.id = 1;
-- Modify users
-- ADD firstname, phone number, is_company
