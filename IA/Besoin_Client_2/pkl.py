import argparse
from pathlib import Path
import sys

import joblib
import pandas as pd


def charger_modele(chemin_modele: str):
    """
    Charge le fichier .pkl/.joblib contenant le modèle.
    """
    path = Path(chemin_modele)

    if not path.exists():
        raise FileNotFoundError(f"Fichier modèle introuvable : {path}")

    return joblib.load(path)


def predire_age_arbre(
    tronc_diam: float,
    haut_tot: float,
    haut_tronc: float,
    fk_stadedev: str,
    nomfrancais: str,
    chemin_modele: str,
):
    """
    Fait une prédiction d'âge à partir d'un modèle sauvegardé.

    Le script essaie plusieurs formats possibles :
    1. modèle direct avec .predict()
    2. dictionnaire contenant 'model'
    3. pipeline sklearn complet
    """

    objet = charger_modele(chemin_modele)

    # Données d'entrée sous forme de DataFrame
    X = pd.DataFrame([{
        "tronc_diam": tronc_diam,
        "haut_tot": haut_tot,
        "haut_tronc": haut_tronc,
        "fk_stadedev": fk_stadedev,
        "nomfrancais": nomfrancais,
    }])

    # Cas 1 : le pickle contient directement un pipeline / modèle sklearn
    if hasattr(objet, "predict"):
        prediction = objet.predict(X)
        return float(prediction[0])

    # Cas 2 : le pickle contient un dictionnaire avec une clé "model"
    if isinstance(objet, dict):
        if "model" in objet and hasattr(objet["model"], "predict"):
            prediction = objet["model"].predict(X)
            return float(prediction[0])

        # Cas possible : objet contenant scaler / encoder / model séparés
        if "preprocessor" in objet and "model" in objet:
            preprocessor = objet["preprocessor"]
            model = objet["model"]

            if hasattr(preprocessor, "transform") and hasattr(model, "predict"):
                X_transforme = preprocessor.transform(X)
                prediction = model.predict(X_transforme)
                return float(prediction[0])

    raise ValueError(
        "Format du modèle non reconnu. "
        "Le fichier .pkl doit contenir soit un modèle/pipeline sklearn, "
        "soit un dict avec une clé 'model', "
        "ou un dict avec 'preprocessor' + 'model'."
    )


def main():
    parser = argparse.ArgumentParser(
        description="Prédire l'âge d'un arbre à partir d'un modèle .pkl"
    )

    parser.add_argument("--tronc_diam", type=float, required=True, help="Diamètre du tronc")
    parser.add_argument("--haut_tot", type=float, required=True, help="Hauteur totale")
    parser.add_argument("--haut_tronc", type=float, required=True, help="Hauteur du tronc")
    parser.add_argument("--fk_stadedev", type=str, required=True, help="Stade de développement")
    parser.add_argument("--nomfrancais", type=str, required=True, help="Nom français de l'arbre")
    parser.add_argument(
        "--modele",
        type=str,
        required=True,
        help="Chemin vers le fichier modèle .pkl/.joblib"
    )

    args = parser.parse_args()

    try:
        age = predire_age_arbre(
            tronc_diam=args.tronc_diam,
            haut_tot=args.haut_tot,
            haut_tronc=args.haut_tronc,
            fk_stadedev=args.fk_stadedev,
            nomfrancais=args.nomfrancais,
            chemin_modele=args.modele,
        )

        print(f"Âge prédit : {age:.2f}")

    except Exception as e:
        print(f"Erreur : {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()