## functions.R

- linki wzgledne (zaczynaja sie od /) zamieniamy na pelne adresy
```
  ifelse(str_starts(links, "/"), paste0(BASE_URL, links), links)
}
```

- **html_text()** zwraca tekst dokładnie tak, jak jest w kodzie HTML, 
razem ze wszystkimi odstępami i przejściami do nowej linii, 
które programista wstawił dla czytelności kodu. 
- **html_text2()** zwraca tekst tak, jak widzi go człowiek w przeglądarce, 
z wyczyszczonymi odstępami.

## scraper.R

- pauza - żeby uniknąć przeciążenia servera
```
Sys.sleep(2) 
```