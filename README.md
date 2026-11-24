# Badanie preferencji klientów perfumeri na potrzeby wprowadzenia na rynek nowych produktów

Strona internetowa: https://www.e-glamour.pl/perfumy

# Jak uruchomić

1. Otwórz folder `projekt_web_scraping` jako projekt w R
2. Uruchom plik `scraper.R` --> surowe dane zapiszą się w *data/raw_data.csv* (pobieranie danych zajmuje czas)
3. Uruchom plik `data_preprocessing.R` --> wyczyszczone dane zapiszą się w *data/data_prep.csv*, a podsumowanie wyświetli się w konsoli

# Opis plików
1. `code/functions.R` --> plik z funkcjami wykorzystywanymi podczas scrapowania
2. `code/scraper.R` --> plik pobierający dane ze strony, wykorzysujący funkcje z `code/functions.R`
3. `data_preprocessing.R` --> plik przygotowujący surowe dane do analizy (czyści dane)


# Dodatkowe pliki
W pliku `code/notes.md` są notatki dotyczące konkretnych linii kodu - można tam dopisywać rzeczy na bieżąco

# TO DO
Napisać skrypt z analizą i modelem (np. `code/analysis_model.R`), który:
- policzy, jakie nuty, zapachy, pojemności i rodzaje mają najwięcej opinii i najlepsze oceny (zestawienia i wykresy),
- zbuduje prosty model, np. regresję przewidującą reviews_count lub rating_weighted z cech produktu,
- zapisze wyniki, z których zrobi się wnioski do raportu.