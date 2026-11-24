library(tidyverse)

# -------------------- Helper functions -----------------------
to_number <- function(x) {
  x %>%
    str_remove_all("[^0-9,]") %>%
    str_replace(",", ".") %>%
    as.numeric()
}

get_spec <- function(spec, key) {
  pattern <- paste0("(?:^|\\| )", key, "\\t([^\\t|]*)")
  str_match(spec, pattern)[, 2] %>% str_squish()
}

extract_volume <- function(text) {
  str_match(text, regex("(\\d+(?:[,.]\\d+)?)\\s?ml", ignore_case = TRUE))[, 2] %>%
    str_replace(",", ".") %>%
    as.numeric()
}

ascii_name <- function(x) {
  x %>%
    stringi::stri_trans_general("Latin-ASCII") %>%
    str_to_lower() %>%
    str_replace_all("[^a-z0-9]+", "_") %>%
    str_remove("^_|_$")
}

add_dummies <- function(data, column, prefix, top_n) {
  items <- data[[column]] %>%
    str_split(",") %>%
    map(~ unique(str_squish(.x[!is.na(.x)]))) %>%
    map(~ .x[.x != ""])

  top <- items %>%
    unlist() %>%
    table() %>%
    sort(decreasing = TRUE) %>%
    head(top_n) %>%
    names()

  for (item in top) {
    col_name <- paste0(prefix, "_", ascii_name(item))
    data[[col_name]] <- map_int(items, ~ as.integer(item %in% .x))
  }
  data
}


# -------------------- Loading the raw data -----------------------
raw_data <- read_csv("data/raw_data.csv", col_types = cols(.default = col_character()))
print(paste("Rows in raw_data.csv:", nrow(raw_data)))


# -------------------- Cleaning and new variables -----------------------
data <- raw_data %>%
  distinct(url, .keep_all = TRUE) %>%            # remove duplicates
  filter(!is.na(name), !is.na(price_promo)) %>%  # empty rows (download errors)
  mutate(
    price         = to_number(price_promo),
    price_regular = coalesce(to_number(price_reg), price),

    rating        = as.numeric(rating),
    reviews_count = replace_na(as.integer(str_extract(reviews_count, "\\d+")), 0L),
    has_reviews   = reviews_count > 0,

    volume_ml     = extract_volume(paste(name, volume)),

    # not a regular store product
    is_tester     = str_detect(name, regex("tester", ignore_case = TRUE)),

    # parameters from the specification
    gender        = get_spec(spec, "Dla kogo\\?"),
    product_type  = get_spec(spec, "Rodzaj produktu"),
    scent_type    = get_spec(spec, "Rodzaj zapachu"),
    release_year  = as.integer(get_spec(spec, "Rok wydania")),

    notes         = str_remove(notes, "^,\\s*"),
    has_notes     = !is.na(notes)
  ) %>%
  filter(!is_tester) %>%
  filter(is.na(rating) | between(rating, 1, 5)) %>%
  filter(str_detect(product_type, "^(Toaletowe|Perfumowany|Perfum|Kolo.skie)$"))


# -------------------- Derived variables -----------------------
# weighted rating: combines the rating and the number of reviews
# (m = weight of the "prior" reviews, C = mean rating of reviewed products)
C <- mean(data$rating[data$has_reviews], na.rm = TRUE)
m <- 10

data <- data %>%
  mutate(
    volume_group    = cut(volume_ml, breaks = c(0, 30, 60, 100, Inf),
                          labels = c("up to 30 ml", "31-60 ml", "61-100 ml", "over 100 ml")),
    # rare brands are merged into "Other"
    brand_group     = as.character(fct_lump_min(brand, min = 10, other_level = "Other")),
    rating_weighted = if_else(has_reviews,
                              (reviews_count * rating + m * C) / (reviews_count + m),
                              NA_real_)
  )

data <- data %>%
  add_dummies("scent_type", "scent", 12) %>%
  add_dummies("notes",      "note",  25)


# -------------------- Save new data -----------------------
prep_data <- data %>%
  select(-price_reg, -price_promo, -volume, -type, -spec, -is_tester, -notes, -scent_type)

write_csv(prep_data, "data/prep_data.csv")


# -------------------- Quick check (can be deleted later) -----------------------
print(paste("Rows after cleaning:", nrow(prep_data)))
print(paste("Products without reviews:", sum(!prep_data$has_reviews)))

cat("\nMissing values (NA) in the key columns:\n")
# computed on `data`, because notes and scent_type are removed from prep_data
print(colSums(is.na(data[, c("price", "volume_ml", "rating", "gender",
                             "product_type", "scent_type", "notes")])))

cat("\nProduct types:\n")
print(count(prep_data, product_type, sort = TRUE))

cat("\nSummary:\n")
print(summary(prep_data[, c("price", "volume_ml", "rating", "reviews_count")]))