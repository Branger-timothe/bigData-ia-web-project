INSERT INTO espece (id, libelle) VALUES
    (1, 'Chene pedoncule'),
    (2, 'Platane commun'),
    (3, 'Tilleul a grandes feuilles'),
    (4, 'Erable plane');

INSERT INTO etat (id, libelle) VALUES
    (1, 'En place'),
    (2, 'Supprime'),
    (3, 'Abattu');

INSERT INTO arbre (
    id_arbre,
    hauteur_total,
    hauteur_tronc,
    diametre_tronc,
    stade_developpement,
    type_port,
    type_pied,
    remarquable,
    longitude,
    latitude,
    espece_id,
    etat_id
  ) VALUES
    ('ARB001', 25, 3, 85, 'Adulte', 'Colonnaire', 'Isole', 1, 3.2870, 49.8489, 1, 1),
    ('ARB002', 18, 2, 55, 'Jeune', 'Etale', 'Alignement', 0, 3.3014, 49.8441, 4, 1),
    ('ARB003', 30, 4, 120, 'Adulte', 'Arrondi', 'Parc', 0, 3.2762, 49.8583, 2, 2);
