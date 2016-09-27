DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  parent_id INTEGER,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Willy', 'Wonka'),
  ('Nestor', 'Haddaway'),
  ('Alexander', 'Supertramp'),
  ('Sir', 'Likealot');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('What is love?', 'baby don''t hurt me', (SELECT id FROM users WHERE fname = 'Nestor' AND lname = 'Haddaway')),
  ('To be or not to be?', 'that is the question', (SELECT id FROM users WHERE fname = 'Alexander' AND lname = 'Supertramp'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Willy' AND lname = 'Wonka'),
    (SELECT id FROM questions WHERE title = 'What is love?')),
  ((SELECT id FROM users WHERE fname = 'Alexander' AND lname = 'Supertramp'),
    (SELECT id FROM questions WHERE title = 'What is love?')),
  ((SELECT id FROM users WHERE fname = 'Nestor' AND lname = 'Haddaway'),
    (SELECT id FROM questions WHERE title = 'To be or not to be?'));

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
((SELECT id FROM questions WHERE title = 'What is love?'),
  NULL,
  (SELECT id FROM users WHERE fname = 'Willy' AND lname = 'Wonka'),
  'Chocolate!!!!');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
((SELECT id FROM users WHERE fname = 'Sir' AND lname = 'Likealot'),
  (SELECT id FROM questions WHERE title = 'What is love?'));
