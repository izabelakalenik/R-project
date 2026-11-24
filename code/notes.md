## functions.R

- linki względne (zaczynają sie od /) zamieniamy na pełne adresy
```
  ifelse(str_starts(links, "/"), paste0(BASE_URL, links), links)
}
```

- ``html_text()`` --> zwraca tekst dokładnie tak, jak jest w kodzie HTML, 
razem ze wszystkimi odstępami i przejściami do nowej linii, 
które programista wstawił dla czytelności kodu. 
- ``html_text2()`` --> zwraca tekst tak, jak widzi go człowiek w przeglądarce, 
z wyczyszczonymi odstępami.

## scraper.R

- ```Sys.sleep(2)``` --> pauza - żeby uniknąć przeciążenia servera

## data_preprocessing.R

- ```to_number``` --> "1 428,29 zl" -> 1428.29

- ```get_spec``` --> wyciaga wartość z kolumny spec, np. "Rodzaj produktu\tToaletowe\t | ..."
  (key to wzorzec regex (znak ? trzeba zapisac jako \\?) )

- ```ascii_name``` --> "drzewo sandałowe" -> "drzewo_sandalowe" (nazwy kolumn bez polskich znakow)

- ```add_dummies``` --> dla listy wartosci rozdzielonych przecinkami (nuty, rodzaj zapachu, pory roku)
tworzy kolumny 0/1 dla top_n najczestszych wartości

- ```coalesce``` --> zwraca dla każdego wiersza pierwszą wartość, która nie jest NA, z podanych kolumn lub wektorów;
weź cenę przed obniżką (price_reg), a jeśli jej nie ma (NA, bo produkt nie jest w promocji), weź aktualną cenę (price)

### Results
- Czyszczenie: 726 wierszy zostało przefiltrowane do 620. Braków w cenie i pojemności nie ma, a scent_type ma 0 braków.
- Brak opinii: 86 produktów (14%). Mediana liczby opinii to 4, a trzeci kwartyl 10, więc rating_weighted był dobrą decyzją.
- Nuty: 65 produktów nie ma nut, więc has_notes = FALSE. Wykluczaj je przy analizie nut.
- Płeć: 3 braki. Jeśli używasz gender w modelu, wyrzuć te wiersze.
- Cena minimalna 8,18 zł i pojemność 5 ml: to pewnie miniatury lub próbki. Jeśli nie chcecie ich w analizie, dodaj filtr, np. filter(volume_ml >= 15). To Wasza decyzja, mogą też zostać jako grupa „do 30 ml“.