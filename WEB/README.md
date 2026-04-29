# Gestion du patrimoine arbore

Application web du projet Big Data / IA / Web.

## Stack

- Front : PHP, HTML, CSS, JavaScript
- Back : PHP
- IA : scripts Python dans `../IA`
- Cartographie : Plotly avec fond OpenStreetMap

## Structure utile

- `index.php` : accueil
- `ajouter-un-arbre/` : formulaire d'ajout
- `visualisation/` : tableau + carte des arbres
- `prediction-age/` : prediction d'age
- `prediction-clusters/` : prediction de clusters
- `api/` : endpoints PHP
- `scripts/` : logique front JavaScript
- `styles/` : feuille CSS globale

## Execution

Servir le dossier `WEB` avec Apache / PHP, puis ouvrir `http://bigdata.test/`.

## Donnees

- `MLD.sql` : schema SQL
- `peuplementTables.sql` : jeu de donnees d'exemple centre sur Saint-Quentin
