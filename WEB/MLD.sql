DROP TABLE IF EXISTS arbre;
DROP TABLE IF EXISTS espece;
DROP TABLE IF EXISTS etat;

CREATE TABLE espece (
    id INT NOT NULL,
    libelle VARCHAR(50) NOT NULL,
    CONSTRAINT espece_PK PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE etat (
    id INT NOT NULL,
    libelle VARCHAR(50) NOT NULL,
    CONSTRAINT etat_PK PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE arbre (
    id_arbre VARCHAR(50) NOT NULL,
    hauteur_total INT NOT NULL,
    hauteur_tronc INT NOT NULL,
    diametre_tronc INT NOT NULL,
    stade_developpement VARCHAR(50) NOT NULL,
    type_port VARCHAR(50) NOT NULL,
    type_pied VARCHAR(50) NOT NULL,
    remarquable TINYINT(1) NOT NULL,
    longitude FLOAT NOT NULL,
    latitude FLOAT NOT NULL,
    espece_id INT NOT NULL,
    etat_id INT NOT NULL,
    CONSTRAINT arbre_PK PRIMARY KEY (id_arbre),
    CONSTRAINT arbre_espece_FK FOREIGN KEY (espece_id) REFERENCES espece (id),
    CONSTRAINT arbre_etat_FK FOREIGN KEY (etat_id) REFERENCES etat (id)
) ENGINE=InnoDB;