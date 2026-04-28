#  Script de prédiction — Classification des arbres

## Description

`predict_cluster.py` est un script de prédiction qui classifie un arbre en **Petit**, **Moyen** ou **Grand** à partir de ses caractéristiques. Il utilise un modèle K-Means préalablement entraîné et sauvegardé **aucun réentraînement n'est effectué à chaque utilisation**.



## Prérequis

### 1. Dépendances Python
```bash
pip install scikit-learn pandas numpy joblib
```

### 2. Fichier modèle obligatoire
Le fichier `kmeans_model.pkl` doit être présent dans le même dossier que le script.
Pour le générer, exécuter **une seule fois** :
```bash
python train_model.py
```





## Utilisation

### Mode ligne de commande
```bash
python predict_cluster.py --haut_tot 12.5 --tronc_diam 45 --age_estim 30
```

| Argument | Description | Unité |
|---|---|---|
| `--haut_tot` | Hauteur totale de l'arbre | mètres |
| `--tronc_diam` | Diamètre du tronc | centimètres |
| `--age_estim` | Âge estimé de l'arbre | années |

### Mode interactif
Sans arguments, le script pose les questions une par une :
```bash
python predict_cluster.py
```
```
=== Mode interactif ===
Hauteur totale de l'arbre (mètres)    : 12.5
Diamètre du tronc (centimètres)        : 45
Âge estimé de l'arbre (années)         : 30
```

---

## Résultat

```
─── Résultat ───────────────────────────────
  Hauteur totale  : 12.5 m
  Diamètre tronc  : 45 cm
  Âge estimé      : 30 ans
  Cluster ID      : 1
  Catégorie       : Moyen
────────────────────────────────────────────
```


## Correspondance des catégories

| Cluster ID | Catégorie | Description |
|---|---|---|
| 0 | Petit | Arbre de petite taille |
| 1 | Moyen | Arbre de taille intermédiaire |
| 2 | Grand | Grand arbre |




## Erreurs fréquentes

**Modèle introuvable**
```
FileNotFoundError: Modèle introuvable : 'kmeans_model.pkl'
```
→ Lancer d'abord `train_model.py` pour générer le fichier modèle.

**Valeur non numérique**
```
Erreur : veuillez entrer des valeurs numériques.
```
→ Les trois paramètres doivent être des nombres (ex: `12.5` et non `douze`).

**Valeur négative ou nulle**
```
Erreur : la hauteur et le diamètre doivent être des valeurs positives.
```
→ Vérifier que toutes les valeurs saisies sont strictement positives.
