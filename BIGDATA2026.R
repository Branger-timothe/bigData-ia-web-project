## Projet Big Data

## I- FONCTIONNALITE 1

## 1/ Description du jeu de données

# Charger les bibliothèques nécessaires
library(readr)
library(tidyverse)
library(class)
library(stringr)
library(dplyr)
library(png)
library(corrplot)

# Charger le fichier CSV
dataset <- readr::read_csv("data/Patrimoine_Arboré_data.csv")
View(dataset)

# Afficher un résumé statistique
summary(dataset)

# Examiner les types de données
str(dataset)

# Vérifier les valeurs manquantes
colSums(is.na(dataset))

# Mettre tous les titres sous le même format
dataset <- dataset %>%
  mutate(
    fk_stadedev = str_squish(str_to_lower(fk_stadedev)),
    fk_arb_etat = str_squish(str_to_lower(fk_arb_etat)),
    feuillage = str_squish(str_to_lower(feuillage)),
    remarquable = str_squish(str_to_lower(remarquable)),
    nomfrancais = str_squish(str_to_lower(nomfrancais)),
    clc_quartier = str_squish(str_to_lower(str_replace_all(clc_quartier, "-", " "))),
    clc_secteur = str_squish(str_to_lower(str_replace_all(clc_secteur, "-", " ")))
  )

## 2/ Statistiques descriptives

# Pour remplacer les NA dans les variables quantitatives par leurs moyennes
#dataset$X[is.na(dataset$X)] <- mean(dataset$X, na.rm=TRUE)
#dataset$Y[is.na(dataset$Y)] <- mean(dataset$Y, na.rm=TRUE)
dataset$haut_tot[is.na(dataset$haut_tot)] <- mean(dataset$haut_tot, na.rm=TRUE)
dataset$haut_tronc[is.na(dataset$haut_tronc)] <- mean(dataset$haut_tronc, na.rm=TRUE)
dataset$tronc_diam[is.na(dataset$tronc_diam)] <- mean(dataset$tronc_diam, na.rm=TRUE)
dataset$age_estim[is.na(dataset$age_estim)] <- mean(dataset$age_estim, na.rm=TRUE)

## a) Univariées

# Moyennes
#mean(dataset$X)
#mean(dataset$Y)
mean(dataset$haut_tot)
mean(dataset$haut_tronc)
mean(dataset$tronc_diam)
mean(dataset$age_estim)

# Variances
#var(dataset$X)
#var(dataset$Y)
var(dataset$haut_tot)
var(dataset$haut_tronc)
var(dataset$tronc_diam)
var(dataset$age_estim)

# Ecart-Type
#sqrt(var(dataset$X))
#sqrt(var(dataset$Y))
sqrt(var(dataset$haut_tot))
sqrt(var(dataset$haut_tronc))
sqrt(var(dataset$tronc_diam))
sqrt(var(dataset$age_estim))

# Mode
#sort(table(dataset$X))
#sort(table(dataset$Y))
sort(table(dataset$haut_tronc))
sort(table(dataset$haut_tot))
sort(table(dataset$tronc_diam))
sort(table(dataset$age_estim))


## b) Bivariées

# Covariance
#cov(dataset$X, dataset$Y)
cov(dataset$haut_tot, dataset$haut_tronc)
cov(dataset$haut_tot, dataset$tronc_diam)
cov(dataset$haut_tronc, dataset$tronc_diam)
cov(dataset$haut_tot, dataset$age_estim)
cov(dataset$haut_tronc, dataset$age_estim)
cov(dataset$tronc_diam, dataset$age_estim)

# Diagramme de dispersion
plot(dataset$X, dataset$Y)
plot(dataset$haut_tronc, dataset$haut_tot)
plot(dataset$haut_tot, dataset$age_estim)
plot(dataset$tronc_diam, dataset$haut_tot)
plot(dataset$tronc_diam, dataset$haut_tronc)
plot(dataset$tronc_diam, dataset$age_estim)
plot(dataset$haut_tronc, dataset$age_estim)

## 3/ Nettoyage des données

## a) Valeurs manquantes

# Vérifier les valeurs manquantes
colSums(is.na(dataset))

# Supprimer les arbres qui n'ont pas d'id
clean_data <- dataset[!is.na(dataset$id_arbre), ]

# Supprimer les arbres qui n'ont pas de localisation
clean_data0 <- clean_data %>% filter(!is.na(X) & !is.na(Y))

# Attribution de quartiers au arbres sans quartiers
# K plus proche voisins (attribué un quartier à tout les arbres): 

# Séparer les arbres avec et sans quartier 
data_avec_quartier <- clean_data0 %>% filter(!is.na(clc_quartier)) 
data_sans_quartier <- clean_data0 %>% filter(is.na(clc_quartier)) 

# Extraire les coordonnées et les quartiers des arbres avec quartier 
coords_avec_quartier <- data_avec_quartier %>% select(X, Y)
quartiers <- data_avec_quartier$clc_quartier

# Extraire les coordonnées des arbres sans quartier 
coords_sans_quartier <- data_sans_quartier %>% select(X, Y) 

# Appliquer KNN 
# Choisir une valeur de k, ici 5 par exemple 
predicted_quartiers <- knn(coords_avec_quartier, coords_sans_quartier, quartiers, k = 5) 

# Ajouter les prédictions aux arbres sans quartier 
data_sans_quartier$clc_quartier <- predicted_quartiers 

# Combiner les données 
clean_data1 <- bind_rows(data_avec_quartier, data_sans_quartier)

# Attribution de secteurs au arbres sans secteurs
#K plus proche voisins (attribué un secteur à tout les arbres): 

# Séparer les arbres avec et sans quartier 
data_avec_secteur <- clean_data1 %>% filter(!is.na(clc_secteur)) 
data_sans_secteur <- clean_data1 %>% filter(is.na(clc_secteur)) 

# Extraire les coordonnées et les quartiers des arbres avec quartier 
coords_avec_secteur <- data_avec_secteur %>% select(X, Y)
secteurs <- data_avec_secteur$clc_secteur

# Extraire les coordonnées des arbres sans quartier 
coords_sans_secteur <- data_sans_secteur %>% select(X, Y) 

# Appliquer KNN
# Choisir une valeur de k, ici 5 par exemple 
predicted_secteur <- knn(coords_avec_secteur, coords_sans_secteur, secteurs, k = 5) 

# Ajouter les prédictions aux arbres sans quartier 
data_sans_secteur$clc_secteur <- predicted_secteur

# Combiner les données 
clean_data2 <- bind_rows(data_avec_secteur, data_sans_secteur)


## b) Valeurs abberantes

# Calcul des quartiles et de l'IQR
Q1ht <- quantile(clean_data2$haut_tot, 0.05, na.rm=TRUE)
Q3ht <- quantile(clean_data2$haut_tot, 0.95, na.rm=TRUE)
IQRht <- Q3ht - Q1ht

Q1htr <- quantile(clean_data2$haut_tronc, 0.05, na.rm=TRUE)
Q3htr <- quantile(clean_data2$haut_tronc, 0.95, na.rm=TRUE)
IQRhtr <- Q3htr - Q1htr

Q1dt <- quantile(clean_data2$tronc_diam, 0.05, na.rm=TRUE)
Q3dt <- quantile(clean_data2$tronc_diam, 0.95, na.rm=TRUE)
IQRdt <- Q3dt - Q1dt

Q1age <- quantile(clean_data2$age_estim, 0.05, na.rm=TRUE)
Q3age <- quantile(clean_data2$age_estim, 0.95, na.rm=TRUE)
IQRage <- Q3age - Q1age

# Définition des limites pour les valeurs aberrantes
limite_inf_ht <- Q1ht - 1.5 * IQRht
limite_sup_ht <- Q3ht + 1.5 * IQRht

limite_inf_htr <- Q1htr - 1.5 * IQRhtr
limite_sup_htr <- Q3htr + 1.5 * IQRhtr

limite_inf_dt <- Q1dt - 1.5 * IQRdt
limite_sup_dt <- Q3dt + 1.5 * IQRdt

limite_inf_age <- Q1age - 1.5 * IQRage
limite_sup_age <- Q3age + 1.5 * IQRage

# On supprime les valeurs abberantes
clean_data3 <- clean_data2[clean_data2$haut_tot >= limite_inf_ht & clean_data2$haut_tot <= limite_sup_ht,]
clean_data4 <- clean_data3[clean_data3$haut_tronc >= limite_inf_htr & clean_data3$haut_tronc <= limite_sup_htr,]
clean_data5 <- clean_data4[clean_data4$tronc_diam >= limite_inf_dt & clean_data4$tronc_diam <= limite_sup_dt,]
clean_data6 <- clean_data5[clean_data5$age_estim >= limite_inf_age & clean_data5$age_estim <= limite_sup_age,]

## c) Doublons
duplicated(clean_data6)
clean_data6[duplicated(clean_data6), ]

# Supprime les doublons
clean_data7 <- clean_data6[!duplicated(clean_data6), ]

# Vérifier les valeurs manquantes
colSums(is.na(clean_data7))


## Nettoyage avancé

## 1. Compléter le feuillage inconnu à partir de l'espèce

clean_data7$feuillage <- ifelse(
  is.na(clean_data7$feuillage) | clean_data7$feuillage == "" | clean_data7$feuillage == "ras",
  NA,
  clean_data7$feuillage
)

ref_feuillage <- clean_data7 %>%
  filter(!is.na(nomfrancais), !is.na(feuillage)) %>%
  group_by(nomfrancais, feuillage) %>%
  summarise(nb = n(), .groups = "drop") %>%
  group_by(nomfrancais) %>%
  slice_max(order_by = nb, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(nomfrancais, feuillage_ref = feuillage)

clean_data7 <- clean_data7 %>%
  left_join(ref_feuillage, by = "nomfrancais") %>%
  mutate(
    feuillage = ifelse(is.na(feuillage), feuillage_ref, feuillage)
  ) %>%
  select(-feuillage_ref)

clean_data7$feuillage <- ifelse(
  is.na(clean_data7$feuillage),
  "inconnu",
  clean_data7$feuillage
)


## 2. Normaliser quartier et secteur

clean_data7 <- clean_data7 %>%
  mutate(
    clc_quartier = str_to_lower(clc_quartier),
    clc_quartier = str_replace_all(clc_quartier, "-", " "),
    clc_quartier = str_squish(clc_quartier),
    
    clc_secteur = str_to_lower(clc_secteur),
    clc_secteur = str_replace_all(clc_secteur, "-", " "),
    clc_secteur = str_squish(clc_secteur)
  )

## Vérification finale

colSums(is.na(clean_data7))
View(clean_data7)


## II- FONCTIONNALITE 2

# Graphe 1 : Hauteur totale en fonction de la hauteur du tronc
plot(clean_data7$haut_tot, clean_data7$haut_tronc, pch=16,col=rgb(0,1,0,0.4), 
     xlab="hauteur totale", ylab="hauteur du tronc", main="Hauteur totale en fonction de la hauteur du tronc")

# Graphe 2 : Diamètre du tronc en fonction de la hauteur du tronc
plot(clean_data7$tronc_diam, clean_data7$haut_tronc, pch=16,col=rgb(0,1,0,0.4), 
     xlab="diamètre du tronc", ylab="hauteur du tronc", main="Diamètre du tronc en fonction de la hauteur du tronc")

# Graphe 3 : Hauteur du tronc en fonction de l'âge estimé
plot(clean_data7$haut_tronc, clean_data7$age_estim, pch=16,col=rgb(0,1,0,0.4), 
     xlab="hauteur du tronc", ylab="âge estimé", main="Hauteur du tronc en fonction de l'âge estimé")

# Graphe 4 : Hauteur totale en fonction de l'âge estimé
plot(clean_data7$haut_tot, clean_data7$age_estim, pch=16,col=rgb(0,1,0,0.4),
     xlab="hauteur totale", ylab="âge estimé", main="Hauteur totale en fonction de l'âge estimé")

# Graphe 5 : Âge estimé en fonction du diamètre du tronc
plot(clean_data7$age_estim, clean_data7$tronc_diam, pch=19,col=rgb(0.1,0.2,1,0.5), 
     xlab="âge estimé", ylab="diamètre du tronc", main="Diamètre du tronc en fonction de l'âge")

# Graphe 6 : Hauteur totale en fonction du diamètre du tronc
plot(clean_data7$haut_tot,clean_data7$tronc_diam, pch=19,col=rgb(0.1,0.2,1,0.5), 
     xlab="hauteur total", ylab="diamètre du tronc", main="Hauteur total en fonction du diamètre du tronc")

# Visualisation des données
effectifs<-table(clean_data7$fk_stadedev)
effectifs <- sort(effectifs)
barplot(effectifs, main = "Diagramme en barre des arbres en fonction de leur états d'avancement")

effectifs<-table(clean_data7$clc_quartier)
effectifs <- sort(effectifs)
pie(effectifs, main = "Diagramme en fromage des arbres en fonction de leur quartier")

effectifs<-table(clean_data7$fk_situation)
effectifs <- sort(effectifs)
pie(effectifs, main = "Diagramme en fromage des arbres en fonction de leur situation")

effectifs<-table(clean_data7$nomfrancais) 
effectifs <- sort(effectifs) 
pie(effectifs[], main = "Diagramme en fromage des arbres en fonction de leur type")

# Export des graphiques issus de Fonctionnalites/Fonctionnalite2.R
output_dir_fonctionnalite2 <- file.path("Fonctionnalites", "figures_fonctionnalite2")
dir.create(output_dir_fonctionnalite2, recursive = TRUE, showWarnings = FALSE)

normalize_text_fonctionnalite2 <- function(x) {
  x <- trimws(tolower(as.character(x)))
  x[is.na(x) | x == "" | x == "ras"] <- "inconnu"
  x
}

save_histogram_fonctionnalite2 <- function(values, title, x_label, output_name, top_n = 20) {
  cleaned_values <- normalize_text_fonctionnalite2(values)
  counts <- sort(table(cleaned_values), decreasing = TRUE)
  counts <- counts[names(counts) != "inconnu"]
  if (length(counts) == 0) {
    return(invisible(NULL))
  }
  counts <- counts[seq_len(min(length(counts), top_n))]

  png(filename = file.path(output_dir_fonctionnalite2, output_name), width = 1400, height = 900, res = 120)
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

save_boxplot_fonctionnalite2 <- function(y, group, title, x_label, y_label, output_name) {
  y_num <- as.numeric(y)
  grp <- normalize_text_fonctionnalite2(group)
  keep <- is.finite(y_num) & !is.na(grp) & grp != "inconnu"
  if (sum(keep) == 0) {
    return(invisible(NULL))
  }
  values_by_group <- split(y_num[keep], factor(grp[keep]))
  values_by_group <- values_by_group[lengths(values_by_group) > 0]
  if (length(values_by_group) == 0) {
    return(invisible(NULL))
  }

  png(filename = file.path(output_dir_fonctionnalite2, output_name), width = 1400, height = 900, res = 120)
  par(mar = c(10, 5, 4, 2))
  boxplot(
    values_by_group,
    las = 2,
    col = "#A1D99B",
    border = "#238B45",
    main = title,
    xlab = x_label,
    ylab = y_label
  )
  dev.off()
}

save_histogram_fonctionnalite2(
  clean_data7$fk_stadedev,
  "Repartition des arbres suivant leur stade de developpement",
  "Stade de developpement",
  "hist_stade_developpement.png"
)

quartier_ou_secteur <- ifelse(
  is.na(clean_data7$clc_quartier) |
    trimws(clean_data7$clc_quartier) == "" |
    tolower(trimws(clean_data7$clc_quartier)) == "ras",
  clean_data7$clc_secteur,
  clean_data7$clc_quartier
)

save_histogram_fonctionnalite2(
  quartier_ou_secteur,
  "Quantite d'arbres par quartier / secteur",
  "Quartier / secteur",
  "hist_quartier_secteur.png"
)

save_histogram_fonctionnalite2(
  clean_data7$fk_situation,
  "Quantite d'arbres selon leur situation",
  "Situation",
  "hist_situation.png"
)

save_boxplot_fonctionnalite2(
  clean_data7$tronc_diam,
  clean_data7$fk_situation,
  "Diametre du tronc par situation",
  "Situation",
  "Diametre du tronc",
  "boxplot_diametre_par_situation.png"
)

cat("Graphiques de la fonctionnalite 2 exportes dans :", output_dir_fonctionnalite2, "\n")


## III - FONCTIONNALITE 3

output_dir_fonctionnalite3 <- file.path("Fonctionnalites", "cartes_fonctionnalite3")
dir.create(output_dir_fonctionnalite3, recursive = TRUE, showWarnings = FALSE)

epsg3949_to_lonlat <- function(x, y) {
  a <- 6378137
  inv_f <- 298.257222101
  f <- 1 / inv_f
  e <- sqrt(2 * f - f^2)

  lat1 <- 48.25 * pi / 180
  lat2 <- 49.75 * pi / 180
  lat0 <- 49 * pi / 180
  lon0 <- 3 * pi / 180
  x0 <- 1700000
  y0 <- 8200000

  m <- function(phi) cos(phi) / sqrt(1 - e^2 * sin(phi)^2)
  t <- function(phi) {
    tan(pi / 4 - phi / 2) / ((1 - e * sin(phi)) / (1 + e * sin(phi)))^(e / 2)
  }

  n <- (log(m(lat1)) - log(m(lat2))) / (log(t(lat1)) - log(t(lat2)))
  f_lambert <- m(lat1) / (n * t(lat1)^n)
  rho0 <- a * f_lambert * t(lat0)^n

  dx <- x - x0
  dy <- rho0 - (y - y0)
  rho <- sqrt(dx^2 + dy^2)
  theta <- atan2(dx, dy)

  lon <- lon0 + theta / n
  t_inv <- (rho / (a * f_lambert))^(1 / n)
  lat <- pi / 2 - 2 * atan(t_inv)

  for (i in 1:8) {
    lat <- pi / 2 - 2 * atan(t_inv * ((1 - e * sin(lat)) / (1 + e * sin(lat)))^(e / 2))
  }

  data.frame(
    lon = lon * 180 / pi,
    lat = lat * 180 / pi
  )
}

lonlat_to_tile <- function(lon, lat, zoom) {
  n <- 2^zoom
  lat_rad <- lat * pi / 180
  data.frame(
    x = floor((lon + 180) / 360 * n),
    y = floor((1 - log(tan(lat_rad) + 1 / cos(lat_rad)) / pi) / 2 * n)
  )
}

tile_x_to_lon <- function(x, zoom) {
  x / 2^zoom * 360 - 180
}

tile_y_to_lat <- function(y, zoom) {
  atan(sinh(pi * (1 - 2 * y / 2^zoom))) * 180 / pi
}

get_osm_background <- function(lon_range, lat_range, output_dir, zoom = 13) {
  lon_padding <- diff(lon_range) * 0.08
  lat_padding <- diff(lat_range) * 0.08
  lon_range <- lon_range + c(-lon_padding, lon_padding)
  lat_range <- lat_range + c(-lat_padding, lat_padding)

  tiles_min <- lonlat_to_tile(lon_range[1], lat_range[2], zoom)
  tiles_max <- lonlat_to_tile(lon_range[2], lat_range[1], zoom)

  x_tiles <- seq(tiles_min$x, tiles_max$x)
  y_tiles <- seq(tiles_min$y, tiles_max$y)
  if (length(x_tiles) * length(y_tiles) > 80) {
    return(get_osm_background(lon_range, lat_range, output_dir, zoom = zoom - 1))
  }

  tile_dir <- file.path(output_dir, "osm_tiles")
  dir.create(tile_dir, recursive = TRUE, showWarnings = FALSE)

  tile_size <- 256
  background <- array(1, dim = c(length(y_tiles) * tile_size, length(x_tiles) * tile_size, 4))

  for (ix in seq_along(x_tiles)) {
    for (iy in seq_along(y_tiles)) {
      tile_file <- file.path(tile_dir, paste0(zoom, "_", x_tiles[ix], "_", y_tiles[iy], ".png"))
      tile_url <- paste0("https://tile.openstreetmap.org/", zoom, "/", x_tiles[ix], "/", y_tiles[iy], ".png")

      if (!file.exists(tile_file)) {
        downloaded <- tryCatch({
          utils::download.file(
            tile_url,
            destfile = tile_file,
            quiet = TRUE,
            mode = "wb",
            method = "libcurl",
            headers = c("User-Agent" = "bigData-ia-web-project/1.0")
          )
          TRUE
        }, error = function(e) FALSE)

        if (!downloaded) {
          if (file.exists(tile_file)) {
            unlink(tile_file)
          }
          return(NULL)
        }
      }

      tile <- tryCatch(png::readPNG(tile_file), error = function(e) NULL)
      if (is.null(tile)) {
        return(NULL)
      }

      row_start <- (iy - 1) * tile_size + 1
      row_end <- iy * tile_size
      col_start <- (ix - 1) * tile_size + 1
      col_end <- ix * tile_size
      background[row_start:row_end, col_start:col_end, seq_len(dim(tile)[3])] <- tile
    }
  }

  list(
    image = background,
    xmin = tile_x_to_lon(min(x_tiles), zoom),
    xmax = tile_x_to_lon(max(x_tiles) + 1, zoom),
    ymin = tile_y_to_lat(max(y_tiles) + 1, zoom),
    ymax = tile_y_to_lat(min(y_tiles), zoom)
  )
}

save_static_tree_maps <- function(data, output_dir) {
  map_data <- data %>%
    filter(is.finite(X), is.finite(Y)) %>%
    mutate(
      clc_quartier = ifelse(is.na(clc_quartier) | clc_quartier == "", "quartier inconnu", clc_quartier),
      remarquable = ifelse(is.na(remarquable) | remarquable == "", "non", remarquable),
      tronc_diam_plot = ifelse(is.finite(tronc_diam), tronc_diam, median(tronc_diam, na.rm = TRUE))
    )

  if (nrow(map_data) == 0) {
    message("Cartes statiques non generees : aucune coordonnee exploitable.")
    return(invisible(NULL))
  }

  map_lonlat <- epsg3949_to_lonlat(map_data$X, map_data$Y)
  map_data$lon <- map_lonlat$lon
  map_data$lat <- map_lonlat$lat

  quartier_hulls <- map_data %>%
    group_by(clc_quartier) %>%
    filter(n() >= 3) %>%
    slice(chull(X, Y)) %>%
    ungroup()

  quartier_hulls_geo <- map_data %>%
    group_by(clc_quartier) %>%
    filter(n() >= 3) %>%
    slice(chull(lon, lat)) %>%
    ungroup()

  quartier_labels <- map_data %>%
    group_by(clc_quartier) %>%
    summarise(
      X = median(X, na.rm = TRUE),
      Y = median(Y, na.rm = TRUE),
      nb_arbres = n(),
      .groups = "drop"
    )

  quartier_labels_geo <- map_data %>%
    group_by(clc_quartier) %>%
    summarise(
      lon = median(lon, na.rm = TRUE),
      lat = median(lat, na.rm = TRUE),
      nb_arbres = n(),
      .groups = "drop"
    )

  quartier_summary <- map_data %>%
    group_by(clc_quartier) %>%
    summarise(
      X = mean(X, na.rm = TRUE),
      Y = mean(Y, na.rm = TRUE),
      nb_arbres = n(),
      diametre_moyen = mean(tronc_diam, na.rm = TRUE),
      .groups = "drop"
    )

  osm_background <- get_osm_background(
    range(map_data$lon, na.rm = TRUE),
    range(map_data$lat, na.rm = TRUE),
    output_dir
  )

  carte_quartiers <- ggplot() +
    {
      if (!is.null(osm_background)) {
        annotation_raster(
          osm_background$image,
          xmin = osm_background$xmin,
          xmax = osm_background$xmax,
          ymin = osm_background$ymin,
          ymax = osm_background$ymax
        )
      }
    } +
    geom_polygon(
      data = quartier_hulls_geo,
      aes(x = lon, y = lat, group = clc_quartier, fill = clc_quartier),
      color = "grey35",
      linewidth = 0.45,
      alpha = 0.14
    ) +
    geom_point(
      data = map_data,
      aes(x = lon, y = lat, color = clc_quartier, size = tronc_diam_plot),
      alpha = 0.68
    ) +
    geom_point(
      data = map_data %>% filter(remarquable == "oui"),
      aes(x = lon, y = lat),
      shape = 8,
      color = "red",
      size = 2.5,
      alpha = 0.9
    ) +
    geom_text(
      data = quartier_labels_geo,
      aes(x = lon, y = lat, label = paste0(clc_quartier, "\n", nb_arbres, " arbres")),
      size = 3,
      color = "grey15",
      check_overlap = TRUE
    ) +
    coord_equal() +
    scale_size_continuous(range = c(0.5, 4), guide = "none") +
    guides(fill = "none", color = guide_legend(title = "Quartier")) +
    labs(
      title = "Population d'arbres par quartier",
      subtitle = ifelse(is.null(osm_background), "Fond cartographique indisponible : affichage local", "Fond cartographique OpenStreetMap"),
      x = "Longitude",
      y = "Latitude"
    ) +
    theme_minimal() +
    theme(
      legend.position = "right",
      panel.grid.minor = element_blank()
    )

  ggsave(
    filename = file.path(output_dir, "carte_arbres_par_quartier.png"),
    plot = carte_quartiers,
    width = 14,
    height = 10,
    dpi = 150
  )

  carte_densite <- ggplot() +
    geom_polygon(
      data = quartier_hulls,
      aes(x = X, y = Y, group = clc_quartier),
      fill = "grey94",
      color = "grey45",
      linewidth = 0.3
    ) +
    geom_point(
      data = quartier_summary,
      aes(x = X, y = Y, size = nb_arbres, fill = nb_arbres),
      shape = 21,
      color = "grey20",
      alpha = 0.82
    ) +
    geom_text(
      data = quartier_summary,
      aes(x = X, y = Y, label = clc_quartier),
      size = 3,
      color = "grey10",
      vjust = -1.1,
      check_overlap = TRUE
    ) +
    coord_equal() +
    scale_size_continuous(range = c(4, 18), name = "Nombre d'arbres") +
    scale_fill_gradient(low = "#B7E4C7", high = "#1B4332", name = "Nombre d'arbres") +
    labs(
      title = "Volume d'arbres par quartier",
      subtitle = "La taille des cercles represente le nombre d'arbres recenses",
      x = "Coordonnee X",
      y = "Coordonnee Y"
    ) +
    theme_minimal() +
    theme(panel.grid.minor = element_blank())

  ggsave(
    filename = file.path(output_dir, "carte_volume_arbres_par_quartier.png"),
    plot = carte_densite,
    width = 14,
    height = 10,
    dpi = 150
  )

  message("Cartes statiques generees dans : ", output_dir)
}

save_static_tree_maps(
  clean_data7,
  output_dir_fonctionnalite3
)

centre_ville = clean_data7[grepl("centre ville", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(centre_ville$X), max(centre_ville$X)), 
     ylim = c(min(centre_ville$Y), max(centre_ville$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du Centre-Ville")

# Ajout de points noirs pour les arbres non-remarquables
points(x = centre_ville$X[centre_ville$remarquable == "non"],
       y = centre_ville$Y[centre_ville$remarquable == "non"],
       pch = 16,
       cex=centre_ville$tronc_diam[centre_ville$remarquable == "non"] / 200,
       col = "pink")

# Ajout de points rouges pour les arbres remarquables
points(x = centre_ville$X[centre_ville$remarquable == "oui"],
       y = centre_ville$Y[centre_ville$remarquable == "oui"],
       pch = 13,
       cex=centre_ville$tronc_diam[centre_ville$remarquable == "oui"] / 200,
       col = "red")


quartier = clean_data7[grepl("saint martin", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier Saint-Martin")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "turquoise")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")


quartier = clean_data7[grepl("rouvroy", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier Rouvroy")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "orange")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")


quartier = clean_data7[grepl("remicourt", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier Remicourt")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "darkred")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")

quartier = clean_data7[grepl("isle", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier du faubourg d'Isle")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "purple")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")


quartier = clean_data7[grepl("europe", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier de l'Europe")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "black")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")

quartier = clean_data7[grepl("vermandois", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier du Vermandois")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "darkblue")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")


quartier = clean_data7[grepl("saint jean", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier Saint-Jean")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "yellow")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")


quartier = clean_data7[grepl("omissy", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier OMISSY")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "blue")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")


quartier = clean_data7[grepl("neuville", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier de Neuville")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "green")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")


quartier = clean_data7[grepl("harly", clean_data7$clc_quartier), ]

plot(x = 1,
     type = "n",
     xlim = c(min(quartier$X), max(quartier$X)), 
     ylim = c(min(quartier$Y), max(quartier$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres du quartier HARLY")

# Ajout de points noirs pour les arbres non-remarquables
points(x = quartier$X[quartier$remarquable == "non"],
       y = quartier$Y[quartier$remarquable == "non"],
       pch = 16,
       cex=quartier$tronc_diam[quartier$remarquable == "non"] / 200,
       col = "magenta")

# Ajout de points rouges pour les arbres remarquables
points(x = quartier$X[quartier$remarquable == "oui"],
       y = quartier$Y[quartier$remarquable == "oui"],
       pch = 13,
       cex=quartier$tronc_diam[quartier$remarquable == "oui"] / 200,
       col = "red")


# Carte générale
plot(x = 1,
     type = "n",
     xlim = c(min(clean_data7$X), max(clean_data7$X)), 
     ylim = c(min(clean_data7$Y), max(clean_data7$Y)),
     pch = 16,
     xlab = "X", 
     ylab = "Y",
     main = "Arbres de Saint-Quentin")

# Ajout de points pour chaque quartier
points(x = clean_data7[grepl("isle", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("isle", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("isle", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "purple")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("isle", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("isle", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("isle", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")


points(x = clean_data7[grepl("saint martin", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("saint martin", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("saint martin", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "turquoise")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("saint martin", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("saint martin", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("saint martin", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")


points(x = clean_data7[grepl("remicourt", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("remicourt", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("remicourt", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "darkred")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("remicourt", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("remicourt", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("remicourt", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")


points(x = clean_data7[grepl("vermandois", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("vermandois", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("vermandois", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "darkblue")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("vermandois", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("vermandois", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("vermandois", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")

points(x = clean_data7[grepl("europe", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("europe", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("europe", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "black")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("europe", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("europe", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("europe", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")

points(x = clean_data7[grepl("saint jean", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("saint jean", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("saint jean", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "yellow")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("saint jean", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("saint jean", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("saint jean", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")

points(x = clean_data7[grepl("centre ville", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("centre ville", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("centre ville", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "pink")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("centre ville", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("centre ville", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("centre ville", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")

points(x = clean_data7[grepl("omissy", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("omissy", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("omissy", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "blue")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("omissy", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("omissy", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("omissy", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")

points(x = clean_data7[grepl("neuville", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("neuville", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("neuville", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "green")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("neuville", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("neuville", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("neuville", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")

points(x = clean_data7[grepl("harly", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("harly", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("harly", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "magenta")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("harly", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("harly", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("harly", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")

points(x = clean_data7[grepl("rouvroy", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$X,
       y = clean_data7[grepl("rouvroy", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$Y,
       pch = 16,
       cex=clean_data7[grepl("rouvroy", clean_data7$clc_quartier) & clean_data7$remarquable == "non", ]$tronc_diam / 500,
       col = "orange")

# Ajout de carrés pour les arbres remarquables
points(x = clean_data7[grepl("rouvroy", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$X,
       y = clean_data7[grepl("rouvroy", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$Y,
       pch = 8,
       cex=clean_data7[grepl("rouvroy", clean_data7$clc_quartier) & clean_data7$remarquable == "oui", ]$tronc_diam / 500,
       col = "red")


## IV - FONCTIONNALITE 4

#Analyse des variables qualitatives

#les couleurs pour les schémas
colors <- c("lightblue", "lightgreen", "pink", "yellow")

#Etude de la corrélation entre les quartiers et l'état des arbres
cor_quartier1=table(clean_data7$clc_quartier, clean_data7$fk_arb_etat)
cor_quartier1
chisq.test(cor_quartier1)
# Les résultats du test du chi2 montre que les valeurs sont fortement liée ( X très grand) et que la probabilité est bien inférieure à 0.005. Donc on peut supooser qu'il y a corréaltion

mosaicplot(cor_quartier1, las=2,  color = colors,  main="Lien entre les quartiers et l'etat des arbres")

#Etude de la corrélation entre les quartiers et le stade de développement des arbres
cor_quartier2=table(clean_data7$clc_quartier, clean_data7$fk_stadedev)
cor_quartier2
chisq.test(cor_quartier2)
mosaicplot(cor_quartier2,las=2 ,color=colors, main="lien entre les quartiers et l'état des arbres")

#Etude de la corrélation entre les quartiers et l'etat du sol
cor_quartier3=table(clean_data7$clc_quartier,clean_data7$fk_pied)
cor_quartier3
chisq.test(cor_quartier3)
mosaicplot(cor_quartier3,las=2 ,color=colors)

#Etude de la corrélation entre les quartiers et la situation des arbres
cor_quartier4=table(clean_data7$clc_quartier, clean_data7$fk_situation)
cor_quartier4
chisq.test(cor_quartier4)
# Les résultats du test du chi2 montre que les valeurs sont fortement liée ( X très grand) et que la probabilité est bien inférieure à 0.005. Donc on peut supooser qu'il y a corréaltion
mosaicplot(cor_quartier4, las=3,  color = colors,main="lien entre les quartiers et la situation des arbres")# le graphique est difficil à aborder

#Etude de la corrélation entre les feuillages et les quatiers
cor_feuillage1=table(clean_data7$clc_quartier,clean_data7$feuillage )
cor_feuillage1
chisq.test(cor_feuillage1)
mosaicplot(cor_feuillage1, las=3,  color = colors, main="lien entre les quartiers et l'état du feuillage")

#Etude de la corrélation entre les feuillages et le stade de développement  
cor_feuillage2=table(clean_data7$fk_stadedev,clean_data7$feuillage )
cor_feuillage2
chisq.test(cor_feuillage2)
mosaicplot(cor_feuillage2, las=3,  color = colors, main="lien entre le feuillage et le stade de développement")

#Quantitatives
#Etude de la corrélation entre la hauteur total et la hauteur du tronc
cor_haut=cor(clean_data7$haut_tot, clean_data7$haut_tronc)
cor_haut

#Représentation graphique
ggplot(clean_data7, aes(x = haut_tot, y = haut_tronc)) +
  geom_point(color = 'green', size = 3) +   # Points verts de taille 3
  geom_smooth( color = 'blue', se = FALSE) +  # trace une régression non linéaire avec un modèle addititif
  # Ligne de régression rouge
  geom_smooth(method="lm" ,color = 'red', se = FALSE) + # trace une droite suivant une régression linéaire
  labs(title = "Corrélation entre la hauteur total et la hauteur du tronc",
       x = "hauteur total",
       y = "hauteur du tronc") +
  theme_minimal()

#Etude de la corrélation entre la hauteur total et le diamètre du tronc de l'arbre
cor_tronc1=cor(clean_data7$haut_tot, clean_data7$tronc_diam) 
cor_tronc1

#Représentation graphique
ggplot(clean_data7, aes(x = haut_tot, y = tronc_diam)) +
  geom_point(color = 'green', size = 3) +   # Points verts de taille 3
  geom_smooth( color = 'blue', se = FALSE) +  # trace une régression non linéaire avec un modèle addititif
  # Ligne de régression rouge
  geom_smooth(method="lm" ,color = 'red', se = FALSE) + # trace une droite suivant une régression linéaire
  labs(title = "Corrélation entre la hauteur total et la hauteur du tronc",
       x = "hauteur total",
       y = "diamètre du tronc") +
  theme_minimal()

#Etude de la corrélation entre la hauteur du tronc et le diamètre du tronc
cor_tronc2=cor(clean_data7$haut_tronc, clean_data7$tronc_diam)
cor_tronc2

#Représentaion graphique
ggplot(clean_data7, aes(x = haut_tronc, y = tronc_diam)) +
  geom_point(color = 'green', size = 3) +   # Points verts de taille 3
  geom_smooth( color = 'blue', se = FALSE) +  # trace une régression non linéaire avec un modèle addititif
  # Ligne de régression rouge
  geom_smooth(method="lm" ,color = 'red', se = FALSE) + # trace une droite suivant une régression linéaire
  labs(title = "Corrélation entre la hauteur du tronc et le diamètre du tronc",
       x = "hauteur du tronc",
       y = "diamètre du tronc") +
  theme_minimal()

#Etude de la corrélation entre la hauteur total et l'age estimé de l'arbre
cor_age1=cor(clean_data7$haut_tot, clean_data7$age_estim) 
cor_age1
ggplot(clean_data7, aes(x = clean_data7$haut_tot, y =  clean_data7$age_estim)) +
  geom_point(color = 'green', size = 3) +   # Points verts de taille 3
  geom_smooth( color = 'blue', se = FALSE) +  # trace une régression non linéaire avec un modèle addititif
  # Ligne de régression rouge
  geom_smooth(method="lm" ,color = 'red', se = FALSE) + # trace une droite suivant une régression linéaire
  labs(title = "Corrélation entre la hauteur total et l'âge estimé",
       x = "hauteur total",
       y = "âge estimé") +
  theme_minimal()

#Etude de la corrélation entre la hauteur du tronc et l'âge estimé
cor_age2=cor(clean_data7$haut_tronc, clean_data7$age_estim)
cor_age2
ggplot(clean_data7, aes(x =haut_tronc, y =age_estim)) +
  geom_point(color = 'green', size = 3) +   # Points bleus de taille 3
  geom_smooth(method="lm" ,color = 'red', se = FALSE) +  
  # Ligne de régression rouge
  geom_smooth(color = 'blue', se = FALSE)+
  labs(title = "Corrélation entre la hauteur du tronc et l'âge estimé",
       x = "hauteur du tronc",
       y = "âge estimé") +
  theme_minimal()

#Etude de la correlation entre le diamètre du tronc et l'âge estimé
cor_age3=cor(clean_data7$tronc_diam, clean_data7$age_estim) 
cor_age3
ggplot(clean_data7, aes(x = tronc_diam,  y =  age_estim)) +
  geom_point(color = 'green', size = 3) +   # Points bleus de taille 3
  geom_smooth(method="lm" ,color = 'red', se = FALSE) +  
  # Ligne de régression rouge
  geom_smooth(color = 'blue', se = FALSE)+
  labs(title = "Corrélation entre le diamètre du tronc et l'âge estimé",
       x = "diamètre du tronc",
       y = "âge estimé") +
  theme_minimal()

# Créer une matrice de corrélation
cor_matrix <- cor(clean_data7 %>% select(where(is.numeric)), use = "complete.obs")

# Transformer la matrice en tableau lisible par ggplot
cor_data <- as.data.frame(as.table(cor_matrix))

# Créer la heatmap avec ggplot2
ggplot(data = cor_data, aes(x = Var1, y = Var2, fill = Freq)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue",
    high = "red",
    mid = "white",
    midpoint = 0,
    limit = c(-1, 1),
    space = "Lab",
    name = "Corrélation"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1)
  ) +
  coord_fixed()


# quantitatives / qualitatives

# Création des classes
class_data1 <- clean_data7[clean_data7$feuillage == "feuillu", ]
class_data2 <- clean_data7[clean_data7$feuillage == "conifère", ]

plot_boxplot_by_group <- function(y, group, main, xlab, ylab) {
  y_num <- as.numeric(y)
  group_clean <- as.factor(group)
  keep <- is.finite(y_num) & !is.na(group_clean)
  
  if (sum(keep) == 0 || length(unique(group_clean[keep])) == 0) {
    message("Boxplot ignoré, données insuffisantes : ", main)
    return(invisible(NULL))
  }
  
  values_by_group <- split(y_num[keep], group_clean[keep])
  values_by_group <- values_by_group[lengths(values_by_group) > 0]
  
  if (length(values_by_group) == 0) {
    message("Boxplot ignoré, données insuffisantes : ", main)
    return(invisible(NULL))
  }
  
  boxplot(values_by_group, main = main, xlab = xlab, ylab = ylab)
}

safe_kruskal_by_group <- function(y, group, label) {
  y_num <- as.numeric(y)
  group_clean <- as.factor(group)
  keep <- is.finite(y_num) & !is.na(group_clean)
  
  if (sum(keep) == 0 || length(unique(group_clean[keep])) < 2) {
    message("Test de Kruskal-Wallis ignoré, données insuffisantes : ", label)
    return(invisible(NULL))
  }
  
  kruskal.test(y_num[keep] ~ group_clean[keep])
}

## 1. Analyse globale : âge estimé selon le stade de développement

plot_boxplot_by_group(
  clean_data7$age_estim,
  clean_data7$fk_stadedev,
  "Répartition des âges par stade de développement",
  "Stade de développement",
  "Âge"
)

kruskal_global <- safe_kruskal_by_group(
  clean_data7$age_estim,
  clean_data7$fk_stadedev,
  "Global"
)
kruskal_global

ggplot(clean_data7, aes(x = fk_stadedev, y = age_estim)) +
  geom_violin(fill = "lightblue") +
  labs(
    title = "Répartition des âges par stade de développement",
    x = "Stade de développement",
    y = "Âge"
  ) +
  theme_minimal()

## 2. Analyse pour une espèce précise : querub

filtered_data <- clean_data7[clean_data7$nomfrancais == "querub", ]

plot_boxplot_by_group(
  filtered_data$age_estim,
  filtered_data$fk_stadedev,
  "Âge selon le stade de développement pour l'espèce querub",
  "Stade de développement",
  "Âge"
)

kruskal_querub <- safe_kruskal_by_group(
  filtered_data$age_estim,
  filtered_data$fk_stadedev,
  "Espèce querub"
)
kruskal_querub

## 3. Analyse pour la classe 1 d'espèces : feuillus

plot_boxplot_by_group(
  class_data1$age_estim,
  class_data1$fk_stadedev,
  "Âge selon le stade de développement pour les feuillus",
  "Stade de développement",
  "Âge"
)

kruskal_feuillus <- safe_kruskal_by_group(
  class_data1$age_estim,
  class_data1$fk_stadedev,
  "Classe feuillus"
)
kruskal_feuillus

ggplot(class_data1, aes(x = fk_stadedev, y = age_estim)) +
  geom_violin(fill = "lightblue") +
  labs(
    title = "Répartition des âges pour les feuillus",
    x = "Stade de développement",
    y = "Âge"
  ) +
  theme_minimal()


## 4. Analyse pour la classe 2 d'espèces : conifères

plot_boxplot_by_group(
  class_data2$age_estim,
  class_data2$fk_stadedev,
  "Âge selon le stade de développement pour les conifères",
  "Stade de développement",
  "Âge"
)

kruskal_coniferes <- safe_kruskal_by_group(
  class_data2$age_estim,
  class_data2$fk_stadedev,
  "Classe conifères"
)
kruskal_coniferes

ggplot(class_data2, aes(x = fk_stadedev, y = age_estim)) +
  geom_violin(fill = "lightblue") +
  labs(
    title = "Répartition des âges pour les conifères",
    x = "Stade de développement",
    y = "Âge"
  ) +
  theme_minimal()


## V - FONCTIONNALITE 5

# Par rapport à l'âge

# On effectue une étude de regression linéaire
age=clean_data7$age_estim
tronc_diam=clean_data7$tronc_diam
haut_tot=clean_data7$haut_tot
haut_tronc=clean_data7$haut_tronc

model1=lm(age~tronc_diam)
summary(model1)
anova(model1)

model2=lm(age~haut_tronc)
summary(model2)
anova(model2)

model3=lm(age~haut_tot)
summary(model3)
anova(model3)

model4= lm(age~haut_tot+haut_tronc)
summary(model4)
anova(model4)

model5= lm(age~haut_tot+tronc_diam)
summary(model5)
anova(model5)

model6= lm(age~tronc_diam+haut_tronc)
summary(model6)
anova(model6)

model7= lm(age~haut_tot+haut_tronc+tronc_diam)
summary(model7)
anova(model7)

regresion_data1<-clean_data7
regresion_data1$predicted_age <- predict(model6)
predict(model6)
regresion_data1$residuals <- residuals(model6)


# Graphique des valeurs observées vs valeurs prédites
ggplot(regresion_data1, aes(x = age_estim, y = predicted_age)) +
  geom_point(color = 'blue') +
  geom_abline(intercept = 0, slope = 1, color = 'red') +
  labs(title = "Valeurs observées vs valeurs prédites",
       x = "Valeurs observées",
       y = "Valeurs prédites") +
  theme_minimal()

# Graphique des résidus
ggplot(regresion_data1, aes(x = predicted_age, y = residuals)) +
  geom_point(color = 'blue') +
  geom_hline(yintercept = 0, color = 'red') +
  labs(title = "Graphique des résidus",
       x = "Valeurs prédites",
       y = "Résidus") +
  theme_minimal()

# Essai d'optimisation
# Pour la classe 1 elle est plus précise
age1=class_data1$age_estim
tronc_diam1=class_data1$tronc_diam
haut_tot1=class_data1$haut_tot
haut_tronc1=class_data1$haut_tronc

model1=lm(age1~tronc_diam1)
summary(model1)
anova(model1)

model2=lm(age1~haut_tronc1)
summary(model2)
anova(model2)

model3=lm(age1~haut_tot1)
summary(model3)
anova(model3)

model4= lm(age1~haut_tot1+haut_tronc1)
summary(model4)
anova(model4)

model5= lm(age1~haut_tot1+tronc_diam1)
summary(model5)
anova(model5)

model6= lm(age1~tronc_diam1+haut_tronc1)
summary(model6)
anova(model6)

model7= lm(age1~haut_tot1+haut_tronc1+tronc_diam1)
summary(model7)
anova(model7)

#Pour la classe 2 mieux vaut utiliser le premier modèle
age2=class_data2$age_estim
tronc_diam2=class_data2$tronc_diam
haut_tot2=class_data2$haut_tot
haut_tronc2=class_data2$haut_tronc

model1=lm(age2~tronc_diam2)
summary(model1)
anova(model1)

model2=lm(age2~haut_tronc2)
summary(model2)
anova(model2)

model3=lm(age2~haut_tot2)
summary(model3)
anova(model3)

model4= lm(age2~haut_tot2+haut_tronc2)
summary(model4)
anova(model4)

model5= lm(age2~haut_tot2+tronc_diam2)
summary(model5)
anova(model5)

model6= lm(age2~tronc_diam2+haut_tronc2)
summary(model6)
anova(model6)

model7= lm(age2~haut_tot2+haut_tronc2+tronc_diam2)
summary(model7)
anova(model7)


# Régression logistique : prédire si un arbre est à abattre / supprimé

# Création de la variable cible
clean_data7$abattre <- ifelse(
  clean_data7$fk_arb_etat %in% c("supprimé", "abattu", "essouché"),
  1,
  0
)

# Création d'un sous-jeu de données utile pour le modèle
subset_data <- clean_data7 %>%
  select(haut_tot, haut_tronc, tronc_diam, fk_stadedev, age_estim, fk_arb_etat, abattre)

# Suppression des lignes avec valeurs manquantes pour éviter les erreurs du modèle
subset_data <- na.omit(subset_data)

# Transformation du stade de développement en variable qualitative
subset_data$fk_stadedev <- as.factor(subset_data$fk_stadedev)

View(subset_data)

# Séparation train / test
set.seed(42)
sample_size <- floor(0.8 * nrow(subset_data))
train_indices <- sample(seq_len(nrow(subset_data)), size = sample_size)

train <- subset_data[train_indices, ]
test <- subset_data[-train_indices, ]

# Modèle de régression logistique
log_model <- glm(
  abattre ~ haut_tot + haut_tronc + tronc_diam + fk_stadedev,
  data = train,
  family = binomial
)

summary(log_model)

# Prédictions sur les données de test
predictions <- predict(log_model, newdata = test, type = "response")

# Conversion des probabilités en classes 0 / 1
predicted_classes <- ifelse(predictions > 0.5, 1, 0)

# Calcul de l'accuracy
accuracy <- mean(predicted_classes == test$abattre)
accuracy

# Matrice de confusion
confusion_matrix <- table(
  Réel = test$abattre,
  Prédit = predicted_classes
)

confusion_matrix

# Ajout des prédictions au jeu de test
test$prediction <- predicted_classes
test$probabilite_abattage <- predictions

View(test)

# Etude de zone afin de planter de nouveaux arbres
# Calcul de la densité approximative d'arbres par quartier

densite_quartier <- clean_data7 %>%
  group_by(clc_quartier) %>%
  summarise(
    nb_arbres = n(),
    xmin = min(X, na.rm = TRUE),
    xmax = max(X, na.rm = TRUE),
    ymin = min(Y, na.rm = TRUE),
    ymax = max(Y, na.rm = TRUE),
    surface_approx = (xmax - xmin) * (ymax - ymin),
    densite = nb_arbres / surface_approx,
    .groups = "drop"
  ) %>%
  arrange(densite)

View(densite_quartier)

quartiers_a_planter <- densite_quartier %>%
  arrange(densite) %>%
  select(clc_quartier, nb_arbres, surface_approx, densite)

View(quartiers_a_planter)


## VI- FONCTIONNALITE 6

# On crée une copie dédiée à l'export IA pour ne pas casser les graphiques précédents
export_IA <- clean_data7


## 1. Supprimer les variables inutiles pour l'IA

colonnes_a_supprimer <- c(
  "created_date",
  "created_user",
  "src_geo",
  "fk_prec_estim",
  "last_edited_user",
  "last_edited_date",
  "CreationDate",
  "Creator",
  "EditDate",
  "Editor",
  "nomlatin",
  "commentaire_environnement",
  "fk_revetement",
  "fk_port",
  "clc_nbr_diag",
  "fk_nomtech",
  "villeca",
  "dte_abattage"
)

export_IA <- export_IA %>%
  select(-any_of(colonnes_a_supprimer))

## 3. Remplacer les NA restants dans les variables qualitatives utiles

export_IA <- export_IA %>%
  mutate(
    remarquable = ifelse(is.na(remarquable), "non", remarquable),
    fk_stadedev = ifelse(is.na(fk_stadedev), "ras", fk_stadedev),
    fk_pied = ifelse(is.na(fk_pied), "ras", fk_pied),
    fk_situation = ifelse(is.na(fk_situation), "ras", fk_situation),
    nomfrancais = ifelse(is.na(nomfrancais), "ras", nomfrancais),
    feuillage = ifelse(is.na(feuillage), "ras", feuillage),
    dte_plantation = ifelse(is.na(dte_plantation), "date inconnu", dte_plantation)
  )

## 5. Convertir les colonnes Oui/Non et Vrai/Faux en 1/0

convert_bool_to_binary <- function(x) {
  x_clean <- str_to_lower(as.character(x))
  x_clean <- str_squish(x_clean)
  
  case_when(
    x_clean %in% c("oui", "vrai", "true", "1") ~ 1,
    x_clean %in% c("non", "faux", "false", "0") ~ 0,
    TRUE ~ NA_real_
  )
}

colonnes_bool <- names(export_IA)[sapply(export_IA, function(col) {
  valeurs <- unique(na.omit(str_to_lower(str_squish(as.character(col)))))
  length(valeurs) > 0 && all(valeurs %in% c("oui", "non", "vrai", "faux", "true", "false", "1", "0"))
})]

export_IA <- export_IA %>%
  mutate(across(all_of(colonnes_bool), convert_bool_to_binary))

print(colonnes_bool)


## 6. Supprimer les lignes restantes avec des NA

export_IA <- na.omit(export_IA)


## 7. Vérification finale

colSums(is.na(export_IA))
View(export_IA)


## 8. Exporter pour le projet IA

write.csv(export_IA,
          "data/export_IA.csv",
          row.names = FALSE,
          fileEncoding = "UTF-8")