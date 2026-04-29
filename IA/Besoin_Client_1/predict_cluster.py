import argparse
import joblib
import numpy as np
import os
import warnings


MODEL_PATH = "kmeans_model.pkl"
CLUSTER_LABELS = {0: "Petit", 1: "Moyen", 2: "Grand"}

warnings.filterwarnings("ignore")


def charger_modele():
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(
            f"Modele introuvable : '{MODEL_PATH}'. "
            "Veuillez d'abord executer train_model.py pour le generer."
        )

    return joblib.load(MODEL_PATH)


def predire_cluster(haut_tot: float, tronc_diam: float, age_estim: float) -> dict:
    kmeans = charger_modele()
    features = np.array([[haut_tot, tronc_diam, age_estim]])

    cluster_id = int(kmeans.predict(features)[0])
    categorie = CLUSTER_LABELS.get(cluster_id, f"Cluster {cluster_id}")

    return {
        "cluster_id": cluster_id,
        "categorie": categorie,
        "haut_tot": haut_tot,
        "tronc_diam": tronc_diam,
        "age_estim": age_estim,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Predit la categorie de taille d'un arbre (Petit / Moyen / Grand)."
    )
    parser.add_argument("--haut_tot", type=float, help="Hauteur totale de l'arbre")
    parser.add_argument("--tronc_diam", type=float, help="Diametre du tronc")
    parser.add_argument("--age_estim", type=float, help="Age estime de l'arbre")
    args = parser.parse_args()

    if args.haut_tot is None or args.tronc_diam is None or args.age_estim is None:
        print("=== Mode interactif ===")
        try:
            args.haut_tot = float(input("Hauteur totale de l'arbre : "))
            args.tronc_diam = float(input("Diametre du tronc : "))
            args.age_estim = float(input("Age estime de l'arbre : "))
        except ValueError:
            print("Erreur : veuillez entrer des valeurs numeriques.")
            return

    if args.haut_tot <= 0 or args.tronc_diam <= 0 or args.age_estim <= 0:
        print("Erreur : les parametres doivent etre strictement positifs.")
        return

    resultat = predire_cluster(args.haut_tot, args.tronc_diam, args.age_estim)

    print("\n=== Resultat ===")
    print(f"Hauteur totale : {resultat['haut_tot']} m")
    print(f"Diametre tronc : {resultat['tronc_diam']} cm")
    print(f"Age estime : {resultat['age_estim']} annees")
    print(f"Cluster ID : {resultat['cluster_id']}")
    print(f"Categorie : {resultat['categorie']}")
    print("================")


if __name__ == "__main__":
    main()
