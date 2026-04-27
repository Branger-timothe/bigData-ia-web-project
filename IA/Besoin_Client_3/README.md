# Besoin Client 3 - Système d'alerte tempête

## Objectif

Ce dossier contient la partie Intelligence Artificielle du besoin client 3. L'objectif est de prédire l'état probable d'un arbre à partir de ses caractéristiques, puis d'en déduire une alerte tempête.

La logique retenue est la suivante :

- si l'état prédit est `en place`, le script retourne une absence d'alerte ;
- si l'état prédit est différent de `en place`, le script retourne une alerte.

Le problème a donc été traité comme une **classification supervisée multiclasse** sur la variable cible `fk_arb_etat`.

## Contenu du dossier

- `bc3_colab.ipynb` : notebook d'entraînement et d'évaluation à exécuter dans Google Colab
- `export_IA.csv` : base de données utilisée pour entraîner le modèle
- `bc3_model.pkl` : modèle final exporté
- `predict_bc3.py` : script final de prédiction
- `README.md` : notice d'utilisation

## Rôle des fichiers

Le notebook `bc3_colab.ipynb` sert à :

- préparer les données ;
- entraîner plusieurs modèles ;
- comparer leurs performances ;
- exporter le meilleur modèle au format `.pkl`.

Le script `predict_bc3.py` sert à :

- charger le modèle déjà entraîné ;
- recevoir les caractéristiques d'un arbre ;
- produire une prédiction sans relancer l'apprentissage.

## Principe du programme

Le script final prend en entrée des informations sur un arbre, par exemple :

- sa localisation ;
- sa hauteur ;
- son diamètre ;
- son stade de développement ;
- son essence ;
- son environnement immédiat.

Il charge ensuite le modèle `bc3_model.pkl` et retourne :

- l'état prédit de l'arbre ;
- une alerte tempête (`oui` ou `non`) ;
- la probabilité globale d'alerte ;
- le détail des probabilités par état.

Si certaines variables sont absentes, le script reste capable de produire une prédiction. Les valeurs manquantes sont prises en charge automatiquement par le pipeline de prétraitement intégré dans le modèle.

## Pré-requis

Pour utiliser le script en local, il faut :

- avoir Python installé ;
- disposer du fichier `bc3_model.pkl` ;
- lancer la commande depuis le dossier `BesoinClient_3`, ou fournir le bon chemin vers le modèle.

Si la commande `python` ne fonctionne pas, essayer `py`.

## Entraînement dans Google Colab

L'entraînement standard se fait dans Google Colab.

### Étapes

1. Ouvrir `bc3_colab.ipynb` dans Google Colab.
2. Importer ou monter le fichier `export_IA.csv`.
3. Exécuter toutes les cellules dans l'ordre.
4. Récupérer le fichier `/content/models/bc3_model.pkl`.
5. Placer ensuite `bc3_model.pkl` dans le dossier `BesoinClient_3`.

## Lancer le script

Ouvrir un terminal dans le dossier `BesoinClient_3`, puis exécuter l'une des commandes suivantes.

### Exemple complet

```bash
python predict_bc3.py --model_path bc3_model.pkl --X 1720320.1079 --Y 8294619.3561 --clc_quartier "quartier du centre ville" --clc_secteur "boulevard richelieu" --haut_tot 12 --haut_tronc 3 --tronc_diam 35 --fk_stadedev adulte --fk_pied gazon --fk_situation alignement --nomfrancais erable --feuillage feuillu --remarquable 0 --age_estim 15
```

### Exemple minimal

```bash
python predict_bc3.py --model_path bc3_model.pkl --X 1720320.1079 --Y 8294619.3561 --clc_quartier "quartier du centre ville" --clc_secteur "boulevard richelieu" --haut_tot 12
```

Dans le second cas, le script indique quelles variables ont été imputées automatiquement.

## Comprendre la sortie

Le script affiche plusieurs informations :

- `Etat predit` : classe prédite pour `fk_arb_etat`
- `Alerte tempete` : `non` si l'état prédit est `en place`, sinon `oui`
- `Probabilite d'alerte` : somme des probabilités de toutes les classes différentes de `en place`
- `Probabilites par etat` : détail complet des probabilités par classe

Exemple de sortie :

```text
Etat predit : en place
Alerte tempete : non
Probabilite d'alerte : 0.335000
Probabilites par etat :
- abattu: 0.005000
- en place: 0.665000
- essouché: 0.052500
- non essouché: 0.012500
- remplacé: 0.015000
- supprimé: 0.250000
```

## Remarques importantes

- Le modèle a été entraîné sur la cible `fk_arb_etat`, conformément au cahier des charges du besoin client 3.
- La variable cible `fk_arb_etat` n'est jamais utilisée en entrée, afin d'éviter toute fuite de cible.
- Le format `.pkl` a été retenu pour respecter les consignes du livrable final.
- Le script final constitue une preuve de concept : il est adapté à la démonstration et à l'intégration dans le projet web, mais ses performances restent liées au déséquilibre important entre les classes.

## Résumé

- Le notebook entraîne le modèle.
- Le fichier `bc3_model.pkl` contient le pipeline final prêt à l'emploi.
- Le script `predict_bc3.py` sert à lancer une prédiction sans réentraîner le modèle.
