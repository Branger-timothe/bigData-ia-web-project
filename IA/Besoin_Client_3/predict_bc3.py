import argparse
import pickle
from pathlib import Path

import pandas as pd


SAFE_STATE = "en place"
FEATURE_COLUMNS = [
    "X",
    "Y",
    "clc_quartier",
    "clc_secteur",
    "haut_tot",
    "haut_tronc",
    "tronc_diam",
    "fk_stadedev",
    "fk_pied",
    "fk_situation",
    "nomfrancais",
    "feuillage",
    "remarquable",
    "age_estim",
]


def parse_args():
    parser = argparse.ArgumentParser(
        description="Prediction de l'alerte tempete pour le besoin client 3."
    )
    parser.add_argument(
        "--model_path",
        required=True,
        help="Chemin vers le fichier bc3_model.pkl exporte depuis Colab.",
    )

    for feature in FEATURE_COLUMNS:
        parser.add_argument(f"--{feature}", dest=feature)

    return parser.parse_args()


def normalize_value(column, value):
    if value is None:
        return None
    if column in {"X", "Y", "haut_tot", "haut_tronc", "tronc_diam", "age_estim"}:
        return float(value)
    if column == "remarquable":
        return str(value).strip().lower()
    value = str(value).strip().lower()
    replacements = {
        "ras": None,
        "inconnu": None,
        "date inconnu": None,
    }
    return replacements.get(value, value)


def load_input_from_args(args):
    payload = {}
    for column in FEATURE_COLUMNS:
        payload[column] = normalize_value(column, getattr(args, column))
    if all(value is None for value in payload.values()):
        raise ValueError("Aucune variable d'entree fournie en ligne de commande.")
    return payload


def load_model(model_path):
    with open(model_path, "rb") as f:
        return pickle.load(f)


def main():
    args = parse_args()
    model_path = Path(args.model_path)
    model = load_model(model_path)

    payload = load_input_from_args(args)
    missing_columns = [column for column, value in payload.items() if value is None]

    features = pd.DataFrame([payload], columns=FEATURE_COLUMNS)
    predicted_state = str(model.predict(features)[0])

    if hasattr(model, "predict_proba"):
        classes = [str(value) for value in model.classes_]
        probabilities = model.predict_proba(features)[0]
        probability_by_state = {
            state: float(probability) for state, probability in zip(classes, probabilities)
        }
        probability_alert = float(
            sum(
                probability
                for state, probability in probability_by_state.items()
                if state != SAFE_STATE
            )
        )
    else:
        probability_by_state = None
        probability_alert = None

    alert = predicted_state != SAFE_STATE

    print(f"Etat predit : {predicted_state}")
    print(f"Alerte tempete : {'oui' if alert else 'non'}")
    if missing_columns:
        print("Variables imputees automatiquement : " + ", ".join(missing_columns))
    if probability_alert is not None:
        print(f"Probabilite d'alerte : {probability_alert:.6f}")
    if probability_by_state is not None:
        print("Probabilites par etat :")
        for state, probability in probability_by_state.items():
            print(f"- {state}: {probability:.6f}")


if __name__ == "__main__":
    main()
