source("./code/functions.R", encoding = "UTF8")

n_pages <- 278  # all possible pages, number of products: 9971


# -------------------- Collect product links --------------------
all_links <- c()

for (i in 1:n_pages) {
  print(paste("List, page", i))
  links <- get_links(i)
  all_links <- c(all_links, links)
  Sys.sleep(2)
}

all_links <- unique(all_links)
print(paste("Number of links:", length(all_links)))

if (length(all_links) == 0) {
  stop("No links found - check SEL_LINK in functions.R")
}


# -------------------- Download each product's details --------------------
products_list <- list()

for (i in seq_along(all_links)) {
  print(paste0(i, "/", length(all_links), " ", all_links[i]))
  products_list[[i]] <- get_product(all_links[i])
  Sys.sleep(2)
}

data_raw <- bind_rows(products_list)   # invalid (NULL) products are skipped


# -------------------- Save --------------------
write_csv(data_raw, "data/raw_data.csv")
print(paste("Saved raw_data.csv, number of rows:", nrow(data_raw)))
