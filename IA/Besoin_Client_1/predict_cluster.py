
import argparse
import joblib
import numpy as np
import os

# ── Chemins des fichiers sauvegardés ──
MODEL_PATH  = 'kmeans_model.pkl'

CLUSTER_LABELS = {0: 'Petit', 1: 'Moyen', 2: 'Grand'}


def charger_modele():
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(
            f"Modèle introuvable : '{MODEL_PATH}'.\n"
            "Veuillez d'abord exécuter train_model.py pour entraîner et sauvegarder le modèle."
        )

    kmeans = joblib.load(MODEL_PATH)
    return kmeans


def predire_cluster(haut_tot: float, tronc_diam: float, age_estim: float) -> dict:
    kmeans = charger_modele()

    # Mise en forme et normalisation des données d'entrée
    features = np.array([[haut_tot, tronc_diam ,age_estim]])

    # Prédiction
    cluster_id = int(kmeans.predict(features)[0])
    categorie  = CLUSTER_LABELS.get(cluster_id, f"Cluster {cluster_id}")

    return {
        'cluster_id': cluster_id,
        'categorie':  categorie,
        'haut_tot':   haut_tot,
        'tronc_diam': tronc_diam,
        'age_estim': age_estim
    }


def main():
    parser = argparse.ArgumentParser(
        description="Prédit la catégorie de taille d'un arbre (Petit / Moyen / Grand)."
    )
    parser.add_argument('--haut_tot',   type=float, help="Hauteur totale de l'arbre (en mètres)")
    parser.add_argument('--tronc_diam', type=float, help="Diamètre du tronc (en centimètres)")
    parser.add_argument('--age_estim', type=float, help="Age de l'arbre (en années)")
    args = parser.parse_args()

    # On fait directement dans le terminal si on a aucun argument
    if args.haut_tot is None or args.tronc_diam is None or args.age_estim is None:
        print("=== Mode interactif ===")
        try:
            args.haut_tot   = float(input("Hauteur totale de l'arbre (mètres)    : "))
            args.tronc_diam = float(input("Diamètre du tronc (centimètres)        : "))
            args.age_estim = float(input("Age de l'arbre                           : "))
        except ValueError:
            print("Erreur : veuillez entrer des valeurs numériques.")
            return

    # Validation basique
    if args.haut_tot <= 0 or args.tronc_diam <= 0:
        print("Erreur :les paramètres ne peuvent pas être négatif")
        return

    # Prédiction
    resultat = predire_cluster(args.haut_tot, args.tronc_diam ,args.age_estim)

    print("\n─── Résultat ───────────────────────────────")
    print(f"  Hauteur totale  : {resultat['haut_tot']} m")
    print(f"  Diamètre tronc  : {resultat['tronc_diam']} cm")
    print(f"  Age estimé : {resultat['age_estim']} années")
    print(f"  Cluster ID      : {resultat['cluster_id']}")
    print(f"  Catégorie       : {resultat['categorie']}")
    print("────────────────────────────────────────────\n")


if __name__ == '__main__':
    main()
