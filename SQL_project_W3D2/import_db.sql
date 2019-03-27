PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_follows; 
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies; 
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users(
    id INTEGER PRIMARY KEY,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL
);


CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body VARCHAR(255) NOT NULL, 
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);



CREATE TABLE question_follows(
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
    
);


CREATE TABLE replies(
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    body VARCHAR(500) NOT NULL,
    question_id INTEGER NOT NULL,
    parent_reply_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);


CREATE TABLE question_likes(
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
    users (fname, lname)
VALUES
    ('Mengna', 'Lin'),
    ('Cameron', 'Carter'),
    ('Joe', 'Dirt');

INSERT INTO  
    questions(title,body,user_id) 
VALUES 
    ('what''s up', 'i dont know', 1),
     ('greeting', 'hello', 2) ,
     ('hi', 'ok', 2) ;

INSERT INTO 
    question_follows(user_id, question_id)
VALUES
    (1,1),
    (2,2),
    (2,1),
    (3,1);

INSERT INTO 
    replies(user_id,body,question_id,parent_reply_id)
VALUES 
    (1,'whaaaaaat',2,NULL),
    (1,'dfhuef',2,1);







