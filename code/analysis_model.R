library(tidyverse)
library(stringi)

# -------------------- 1. Wczytanie oczyszczonych danych -----------------------
data_dir  <- if (dir.exists("data")) "data" else "../data"
raw_path  <- file.path(data_dir, "raw_data.csv")
prep_path <- file.path(data_dir, "prep_data.csv")

n_raw <- if (file.exists(raw_path)) {
  nrow(read_csv(raw_path, col_types = cols(.default = col_character()), show_col_types = FALSE))
} else {
  726L
}

df_prep <- read_csv(prep_path, show_col_types = FALSE)
n_prep  <- nrow(df_prep)

# Funkcje porządkujące etykiety do raportu
format_product_type <- function(x) {
  case_when(
    x == "Perfumowany" ~ "Woda perfumowana (EDP)",
    x == "Toaletowe"   ~ "Woda toaletowa (EDT)",
    x == "Perfum"      ~ "Perfumy",
    str_detect(x, "^Kolo") ~ "Woda kolońska (EDC)",
    TRUE ~ as.character(x)
  )
}

format_scent_pl <- function(x) {
  x %>%
    str_remove("^scent_") %>%
    recode(
      "kwiatowy"    = "Kwiatowy",
      "drzewny"     = "Drzewny",
      "owocowy"     = "Owocowy",
      "orientalny"  = "Orientalny",
      "aromatyczny" = "Aromatyczny",
      "pizmowy"     = "Piżmowy",
      "wodny"       = "Wodny",
      "przyprawowy" = "Przyprawowy",
      "swiezy"      = "Świeży",
      "cytrusowy"   = "Cytrusowy",
      "szyprowy"    = "Szyprowy",
      "skorny"      = "Skórzany",
      "waniliowy"   = "Waniliowy",
      "zielony"     = "Zielony",
      .default      = str_to_title(str_replace_all(., "_", " "))
    )
}

format_note_pl <- function(x) {
  x %>%
    str_remove("^note_") %>%
    recode(
      "pizmo"            = "Piżmo",
      "bursztyn"         = "Bursztyn",
      "drzewo_sandalowe" = "Drzewo sandałowe",
      "jasmin"           = "Jaśmin",
      "bergamotka"       = "Bergamotka",
      "cedr"             = "Cedr",
      "wanilia"          = "Wanilia",
      "roze"             = "Róża",
      "roza"             = "Róża",
      "konwalia"         = "Konwalia",
      "paczula"          = "Paczula",
      "wetiweria"        = "Wetiweria",
      "mandarynka"       = "Mandarynka",
      "cytryna"          = "Cytryna",
      "brzoskwinia"      = "Brzoskwinia",
      "irys"             = "Irys",
      "fiolek"           = "Fiołek",
      "bialy_pizmo"      = "Białe piżmo",
      "biale_pizmo"      = "Białe piżmo",
      "pomarancza"       = "Pomarańcza",
      "fasolka_tonka"    = "Fasolka tonka",
      "pieprz"           = "Pieprz",
      "rozowy_pieprz"    = "Różowy pieprz",
      "lawenda"          = "Lawenda",
      "frezya"           = "Frezja",
      "frezja"           = "Frezja",
      "magnolia"         = "Magnolia",
      "peonia"           = "Piwonia",
      "piwonia"          = "Piwonia",
      .default           = str_to_title(str_replace_all(., "_", " "))
    )
}

df <- df_prep %>%
  filter(
    !is.na(price),
    !is.na(volume_ml),
    volume_ml >= 15,
    volume_ml <= 500
  ) %>%
  mutate(
    price_per_100ml = round((price / volume_ml) * 100, 2),
    discount_pct = if_else(
      !is.na(price_regular) & price_regular > price,
      round((1 - price / price_regular) * 100, 1),
      0
    ),
    product_type_pl = format_product_type(product_type),
    volume_group_pl = case_when(
      volume_ml <= 30  ~ "Do 30 ml",
      volume_ml <= 60  ~ "31–60 ml",
      volume_ml <= 100 ~ "61–100 ml",
      TRUE             ~ "Powyżej 100 ml"
    ) %>% factor(levels = c("Do 30 ml", "31–60 ml", "61–100 ml", "Powyżej 100 ml"))
  )

# -------------------- 2. Zestawienia opisowe -----------------------
summary_type <- df %>%
  group_by(product_type_pl) %>%
  summarise(
    liczba_produktow      = n(),
    laczna_liczba_opinii  = sum(reviews_count, na.rm = TRUE),
    srednia_opinii_prod   = round(mean(reviews_count, na.rm = TRUE), 1),
    mediana_opinii        = median(reviews_count, na.rm = TRUE),
    srednia_ocena_wazona  = round(mean(rating_weighted, na.rm = TRUE), 3),
    mediana_ceny_pln      = round(median(price, na.rm = TRUE), 2),
    mediana_ceny_100ml    = round(median(price_per_100ml, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(laczna_liczba_opinii))

summary_volume <- df %>%
  filter(!is.na(volume_group_pl)) %>%
  group_by(volume_group_pl) %>%
  summarise(
    liczba_produktow      = n(),
    laczna_liczba_opinii  = sum(reviews_count, na.rm = TRUE),
    srednia_opinii_prod   = round(mean(reviews_count, na.rm = TRUE), 1),
    srednia_ocena_wazona  = round(mean(rating_weighted, na.rm = TRUE), 3),
    mediana_ceny_pln      = round(median(price, na.rm = TRUE), 2),
    mediana_ceny_100ml    = round(median(price_per_100ml, na.rm = TRUE), 2),
    .groups = "drop"
  )

summary_gender <- df %>%
  filter(!is.na(gender)) %>%
  group_by(gender) %>%
  summarise(
    liczba_produktow      = n(),
    laczna_liczba_opinii  = sum(reviews_count, na.rm = TRUE),
    srednia_opinii_prod   = round(mean(reviews_count, na.rm = TRUE), 1),
    srednia_ocena_wazona  = round(mean(rating_weighted, na.rm = TRUE), 3),
    mediana_ceny_pln      = round(median(price, na.rm = TRUE), 2),
    mediana_ceny_100ml    = round(median(price_per_100ml, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(laczna_liczba_opinii))

scent_cols <- names(df)[startsWith(names(df), "scent_")]

summary_scents <- map_dfr(scent_cols, function(col) {
  sub_df <- df[df[[col]] == 1, ]
  tibble(
    kolumna               = col,
    rodzina_zapachowa     = format_scent_pl(col),
    liczba_produktow      = nrow(sub_df),
    laczna_liczba_opinii  = sum(sub_df$reviews_count, na.rm = TRUE),
    srednia_opinii_prod   = round(mean(sub_df$reviews_count, na.rm = TRUE), 1),
    srednia_ocena_wazona  = round(mean(sub_df$rating_weighted, na.rm = TRUE), 3),
    mediana_ceny_100ml    = round(median(sub_df$price_per_100ml, na.rm = TRUE), 2)
  )
}) %>%
  arrange(desc(laczna_liczba_opinii))

df_with_notes <- df %>% filter(has_notes)
note_cols <- names(df)[startsWith(names(df), "note_")]

summary_notes <- map_dfr(note_cols, function(col) {
  sub_df <- df_with_notes[df_with_notes[[col]] == 1, ]
  tibble(
    kolumna               = col,
    nuta_zapachowa        = format_note_pl(col),
    liczba_produktow      = nrow(sub_df),
    udzial_proc           = round(nrow(sub_df) / nrow(df_with_notes) * 100, 1),
    laczna_liczba_opinii  = sum(sub_df$reviews_count, na.rm = TRUE),
    srednia_opinii_prod   = round(mean(sub_df$reviews_count, na.rm = TRUE), 1),
    srednia_ocena_wazona  = round(mean(sub_df$rating_weighted, na.rm = TRUE), 3),
    mediana_ceny_100ml    = round(median(sub_df$price_per_100ml, na.rm = TRUE), 2)
  )
}) %>%
  arrange(desc(laczna_liczba_opinii))

# -------------------- 3. Modelowanie regresyjne (lm) -----------------------
df_mod <- df %>%
  filter(!is.na(gender), !is.na(brand_group)) %>%
  mutate(
    product_type_pl = factor(product_type_pl),
    gender          = factor(gender),
    brand_group     = factor(brand_group)
  )

scent_formula_part <- paste(scent_cols, collapse = " + ")

# Model 1: Log-liniowy model wyceny rynkowej (log(price)) z uwzględnieniem segmentu marki
formula_price <- as.formula(
  paste("log(price) ~ log(volume_ml) + product_type_pl + gender + brand_group +", scent_formula_part)
)
model_price <- lm(formula_price, data = df_mod)

# Parametry do symulacji produktu premierowego (najczęstszy segment, pojemność 50 ml, nowa marka = "Other")
top_type <- if ("Woda perfumowana (EDP)" %in% levels(df_mod$product_type_pl)) {
  "Woda perfumowana (EDP)"
} else {
  names(sort(table(df_mod$product_type_pl), decreasing = TRUE))[1]
}

top_gender <- summary_gender$gender[1]
target_brand_group <- if ("Other" %in% levels(df_mod$brand_group)) {
  "Other"
} else {
  names(sort(table(df_mod$brand_group), decreasing = TRUE))[1]
}

top_two_scents <- summary_scents$kolumna[1:min(2, nrow(summary_scents))]
top_two_scents_names <- summary_scents$rodzina_zapachowa[1:min(2, nrow(summary_scents))]

new_product <- df_mod[1, ]
new_product$volume_ml       <- 50
new_product$product_type_pl <- factor(top_type, levels = levels(df_mod$product_type_pl))
new_product$gender          <- factor(top_gender, levels = levels(df_mod$gender))
new_product$brand_group     <- factor(target_brand_group, levels = levels(df_mod$brand_group))

for (col in scent_cols) new_product[[col]] <- 0L
for (col in top_two_scents) new_product[[col]] <- 1L

# Predykcja punktowa oraz 95% przedział predykcji z korektą smearing (Duan) dla log(price)
smearing_factor <- mean(exp(residuals(model_price)))
pred_log <- predict(model_price, newdata = new_product, interval = "prediction", level = 0.95)

predicted_price_50ml <- round(as.numeric(exp(pred_log[1, "fit"]) * smearing_factor), 2)
predicted_price_lwr  <- round(as.numeric(exp(pred_log[1, "lwr"]) * smearing_factor), 2)
predicted_price_upr  <- round(as.numeric(exp(pred_log[1, "upr"]) * smearing_factor), 2)

# Model 2A: Determinanty popularności produktu (log1p(reviews_count))
formula_reviews <- as.formula(
  paste("log1p(reviews_count) ~ price_per_100ml + volume_ml + product_type_pl + gender +", scent_formula_part)
)
model_reviews <- lm(formula_reviews, data = df_mod)

# Model 2B: Determinanty satysfakcji konsumentów (rating_weighted)
df_rating_mod <- df_mod %>%
  filter(has_reviews, !is.na(rating_weighted))

formula_rating <- as.formula(
  paste("rating_weighted ~ price_per_100ml + volume_ml + product_type_pl + gender +", scent_formula_part)
)
model_rating <- lm(formula_rating, data = df_rating_mod)

# -------------------- 4. Zapis wyników analizy i modeli -----------------------
results <- list(
  meta = list(
    n_raw        = n_raw,
    n_prep       = n_prep,
    n_clean      = nrow(df),
    n_brands     = n_distinct(df$brand, na.rm = TRUE),
    n_with_notes = nrow(df_with_notes),
    n_mod        = nrow(df_mod),
    n_rating_mod = nrow(df_rating_mod)
  ),
  df_clean       = df,
  summary_type   = summary_type,
  summary_volume = summary_volume,
  summary_gender = summary_gender,
  summary_scents = summary_scents %>% select(-kolumna),
  summary_notes  = summary_notes %>% select(-kolumna),
  model_price    = model_price,
  model_reviews  = model_reviews,
  model_rating   = model_rating,
  sim_params = list(
    volume_ml    = 50,
    product_type = top_type,
    gender       = top_gender,
    brand_group  = target_brand_group,
    scents       = top_two_scents_names,
    price_fit    = predicted_price_50ml,
    price_lwr    = predicted_price_lwr,
    price_upr    = predicted_price_upr
  )
)

saveRDS(results, file.path(data_dir, "model_results.rds"))
message("Analiza i modele zostały zapisane do: ", file.path(data_dir, "model_results.rds"))