library(httr)
library(rvest)
library(tidyverse)

START_URL <- "https://www.e-glamour.pl/perfumy/"
BASE_URL  <- "https://www.e-glamour.pl"

my_agent <- user_agent("Student project PWr - Analysis of perfumes")


# -------------------- Download the page --------------------
get_page <- function(url) {
  tryCatch({
    response <- GET(url, my_agent)
    status <- status_code(response)

    if (status < 200 || status >= 400) {
      message("HTTP error: ", status, " for URL: ", url)
      return(NULL)
    } else {
      content(response, encoding = "UTF-8")
    }
  }, error = function(e) {
    message("Failed to fetch page ", url, ": ", conditionMessage(e))
    return(NULL)
  })
}


# -------------------- Collect links from one page of the list --------------------
get_links <- function(page_nr) {
  url <- paste0(START_URL, "?page=", page_nr)
  page <- get_page(url)
  if (is.null(page)) return(c())

  SEL_LINK  <- "a.product-link"

  links <- page %>%
    html_elements(SEL_LINK) %>%
    html_attr("href")

  ifelse(str_starts(links, "/"), paste0(BASE_URL, links), links)
}


# -------------------- Collect product details --------------------
get_product <- function(url) {
  page <- get_page(url)
  if (is.null(page)) return(NULL)

  SEL_NAME          <- "h1 span.title"
  SEL_BRAND         <- "h1 a.producer-name"
  SEL_PRICE_BLOCK   <- "div.c-product-price"
  SEL_PRICE_REG     <- "p > strong"
  SEL_PRICE_PROMO   <- "div > strong"
  SEL_RATING        <- "div.c-product-reviews-rating span.reviews-count:nth-child(1)"
  SEL_REVIEWS_COUNT <- "div.c-product-reviews-rating span.reviews-count:nth-child(2)"
  SEL_NOTES         <- "p.c-product-parameters-parameter span.value"
  SEL_VOLUME        <- "h1 span.short-title"
  SEL_TYPE          <- "h1 span.short-title"
  SEL_SPEC          <- "div.c-product-parameters table.table-default tr"

  price_block <- page %>% html_element(SEL_PRICE_BLOCK)

  data.frame(
    url           = url,
    name          = page %>% html_element(SEL_NAME) %>% html_text(),
    brand         = page %>% html_element(SEL_BRAND) %>% html_text(),
    price_reg     = price_block %>% html_element(SEL_PRICE_REG) %>% html_text(),
    price_promo   = price_block %>% html_element(SEL_PRICE_PROMO) %>% html_text(),
    rating        = page %>% html_element(SEL_RATING) %>% html_text(),
    reviews_count = page %>% html_element(SEL_REVIEWS_COUNT) %>% html_text(),
    notes         = page %>% html_elements(SEL_NOTES) %>% html_text2() %>% paste(collapse = ", "),
    volume        = page %>% html_element(SEL_VOLUME) %>% html_text(),
    type          = page %>% html_element(SEL_TYPE) %>% html_text(),
    spec          = page %>% html_elements(SEL_SPEC) %>% html_text2() %>% paste(collapse = " | ")
  )
}
