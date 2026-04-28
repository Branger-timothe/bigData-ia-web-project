# Guide de lancement du script de prédiction d’âge des arbres

## Objectif

Ce script permet de prédire l’âge estimé d’un arbre à partir de ses caractéristiques, sans réentraîner le modèle.

Le modèle a été entraîné dans Google Colab puis sauvegardé au format `.pkl`.  
Le fichier `.pkl` contient le pipeline complet :

- prétraitement des données numériques ;
- encodage des variables catégorielles ;
- modèle final `RandomForestRegressor`.

---

## Fichiers nécessaires

Pour lancer la prédiction, il faut avoir dans le même dossier ou dans un chemin accessible :

- `pkl.py` : script Python de prédiction ;
- `modele_final_prediction_age.pkl` : modèle entraîné sauvegardé.

Exemple d’organisation :

```text
PROJET 2026/IA/Besoin_Client_2
│
├── pkl.py
├── modele_final_prediction_age.pkl
```

---

## Installation des bibliothèques nécessaires

Avant d’exécuter le script, installer les bibliothèques Python nécessaires :

```powershell
c:\python313\python.exe -m pip install pandas scikit-learn joblib
```

Si `pip` n’est pas encore activé :

```powershell
c:\python313\python.exe -m ensurepip --upgrade
c:\python313\python.exe -m pip install pandas scikit-learn joblib
```

---

## Lancement du script

Le script se lance en ligne de commande avec les paramètres de l’arbre à prédire.

Exemple :

```powershell
c:\python313\python.exe "C:\Users\cotte\OneDrive - yncréa\Bureau\PROJET 2026\IA\pkl.py" --tronc_diam 40 --haut_tot 18 --haut_tronc 6 --fk_stadedev jeune --nomfrancais pinningii --modele "C:\Users\cotte\OneDrive - yncréa\Bureau\PROJET 2026\IA\modele_final_prediction_age.pkl"
```

---

## Paramètres attendus

| Paramètre | Description | Exemple |
|---|---|---|
| `--tronc_diam` | Diamètre du tronc | `40` |
| `--haut_tot` | Hauteur totale de l’arbre | `18` |
| `--haut_tronc` | Hauteur du tronc | `6` |
| `--fk_stadedev` | Stade de développement | `jeune` |
| `--nomfrancais` | Espèce / nom français de l’arbre | `pinningii` |
| `--modele` | Chemin vers le fichier `.pkl` sauvegardé | `modele_final_prediction_age.pkl` |

---

## Exemple de résultat attendu

Après exécution, le script affiche l’âge prédit :

```text
Âge prédit : 19.4 ans
```

---

## Remarques importantes

- Le modèle n’est pas réentraîné lors de l’exécution du script.
- Le fichier `.pkl` est simplement chargé avec `joblib.load()`.
- Les noms des colonnes utilisés dans le script doivent rester identiques à ceux utilisés pendant l’entraînement :
  - `tronc_diam`
  - `haut_tot`
  - `haut_tronc`
  - `fk_stadedev`
  - `nomfrancais`
- Les valeurs de `fk_stadedev` et `nomfrancais` doivent correspondre à des valeurs connues ou proches de celles présentes dans la base de données d’entraînement.

---

## Principe général

Le fonctionnement est le suivant :

```text
Paramètres utilisateur
        ↓
Création d’un DataFrame Python
        ↓
Chargement du pipeline sauvegardé (.pkl)
        ↓
Application automatique du prétraitement
        ↓
Prédiction avec RandomForestRegressor
        ↓
Affichage de l’âge estimé
```

Ce fonctionnement permet d’utiliser le modèle final dans une application sans refaire l’entraînement à chaque prédiction.
