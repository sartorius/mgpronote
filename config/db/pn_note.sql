-- This is the cross ref table for all partner to get their client
DROP TABLE IF EXISTS wakeup_pnnote;
CREATE TABLE wakeup_pnnote (
  id            BIGSERIAL        PRIMARY KEY,
  exam_date     DATE,
  exam_subject  VARCHAR(50),
  exam_name     VARCHAR(50),
  exam_note     NUMERIC(4, 2),
  exam_best     NUMERIC(4, 2),
  exam_avg      NUMERIC(4, 2),

  create_date   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO wakeup_pnnote (exam_date, exam_subject, exam_name, exam_note, exam_best, exam_avg)
VALUES ('20210315', 'Marketing', 'Techniques anglaises', 15.67, 18.00, 16.00);

INSERT INTO wakeup_pnnote (exam_date, exam_subject, exam_name, exam_note, exam_best, exam_avg)
VALUES ('20210314', 'Anglais', 'Présentation', 12.67, 16.00, 11.00);

INSERT INTO wakeup_pnnote (exam_date, exam_subject, exam_name, exam_note, exam_best, exam_avg)
VALUES ('20210312', 'Francais', 'Rhétorique', 12.67, 16.00, 10.00);

INSERT INTO wakeup_pnnote (exam_date, exam_subject, exam_name, exam_note, exam_best, exam_avg)
VALUES ('20210312', 'Marketing', 'Réseaux sociaux', 18.89, 20.00, 17.00);

INSERT INTO wakeup_pnnote (exam_date, exam_subject, exam_name, exam_note, exam_best, exam_avg)
VALUES ('20210310', 'Francais', 'Conjugaison', 13.10, 18.00, 13.30);

INSERT INTO wakeup_pnnote (exam_date, exam_subject, exam_name, exam_note, exam_best, exam_avg)
VALUES ('20210309', 'Géopolitique', 'Conflit Moyen Orient', 9.67, 13.00, 10.49);

INSERT INTO wakeup_pnnote (exam_date, exam_subject, exam_name, exam_note, exam_best, exam_avg)
VALUES ('20210222', 'Malagasy', 'Kabary', 12.10, 17.20, 15.47);
