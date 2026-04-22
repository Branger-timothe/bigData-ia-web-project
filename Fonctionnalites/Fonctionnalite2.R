input_path <- file.path("data", "export_IA.csv")
output_dir <- file.path("Fonctionnalites", "figures_fonctionnalite2")

if (!file.exists(input_path)) {
  stop(paste("Fichier introuvable :", input_path))
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

arbres <- read.csv(input_path, stringsAsFactors = FALSE)

normalize_text <- function(x) {
  x <- trimws(tolower(as.character(x)))
  x[is.na(x) | x == "" | x == "ras"] <- "inconnu"
  x
}

save_histogram <- function(values, title, x_label, output_name, top_n = 20) {
  cleaned_values <- normalize_text(values)
  counts <- sort(table(cleaned_values), decreasing = TRUE)
  counts <- counts[names(counts) != "inconnu"]
  if (length(counts) == 0) {
    return(invisible(NULL))
  }
  counts <- counts[seq_len(min(length(counts), top_n))]

  png(filename = file.path(output_dir, output_name), width = 1400, height = 900, res = 120)
  par(mar = c(11, 5, 4, 2))
  barplot(
    counts,
    las = 2,
    col = "#2C7FB8",
    border = "#1D4E89",
    main = title,
    xlab = x_label,
    ylab = "Quantite d'arbres"
  )
  dev.off()
}

save_boxplot <- function(y, group, title, x_label, y_label, output_name) {
  y_num <- as.numeric(y)
  grp <- normalize_text(group)
  keep <- is.finite(y_num) & !is.na(grp) & grp != "inconnu"
  if (sum(keep) == 0) {
    return(invisible(NULL))
  }

  png(filename = file.path(output_dir, output_name), width = 1400, height = 900, res = 120)
  par(mar = c(10, 5, 4, 2))
  boxplot(
    y_num[keep] ~ factor(grp[keep]),
    las = 2,
    col = "#A1D99B",
    border = "#238B45",
    main = title,
    xlab = x_label,
    ylab = y_label
  )
  dev.off()
}

save_histogram(
  arbres$fk_stadedev,
  "Repartition des arbres suivant leur stade de developpement",
  "Stade de developpement",
  "hist_stade_developpement.png"
)

quartier_ou_secteur <- ifelse(
  is.na(arbres$clc_quartier) | trimws(arbres$clc_quartier) == "" | tolower(trimws(arbres$clc_quartier)) == "ras",
  arbres$clc_secteur,
  arbres$clc_quartier
)

save_histogram(
  quartier_ou_secteur,
  "Quantite d'arbres par quartier / secteur",
  "Quartier / secteur",
  "hist_quartier_secteur.png"
)

save_histogram(
  arbres$fk_situation,
  "Quantite d'arbres selon leur situation",
  "Situation",
  "hist_situation.png"
)

save_boxplot(
  arbres$tronc_diam,
  arbres$fk_situation,
  "Diametre du tronc par situation",
  "Situation",
  "Diametre du tronc",
  "boxplot_diametre_par_situation.png"
)

cat("Graphiques generes sans categorie 'inconnu' dans :", output_dir, "\n")
