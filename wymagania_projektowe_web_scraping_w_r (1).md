# Specyfikacja projektu: Web Scraping i modelowanie w języku R

---

## 1. Informacje organizacyjne i terminy

* **Zadanie wstępne („na dziś”):** Wysłanie prowadzącemu roboczego adresu URL strony internetowej, z której będą pobierane dane.
* **Ostateczny termin oddania projektu:** **29.11.2026 r.**
* **Forma oddania:** Wszystkie wymagane pliki należy spakować do jednego archiwum **`.zip`** i wysłać drogą mailową.
* **Materiały pomocnicze:** 
  * Szablon raportu znajduje się na platformie **MS Teams** (`nazwisko1_nazwisko2.Rmd`).
  * Dokładne nazewnictwo i struktura plików bazują na przykładowych kodach udostępnionych przez prowadzącego na zajęciach.

---

## 2. Cel projektu: Problem biznesowy i model

Projekt **nie może** polegać wyłącznie na czystej analizie eksploracyjnej danych (wykresach i statystykach). Jego głównym celem jest **rozwiązanie konkretnego problemu biznesowego**.

1. **Definicja problemu:** Należy jasno opisać, jaki problem rozwiązujemy, dla kogo i w jaki sposób podeszliśmy do jego rozwiązania.
   * *Przykład z wykładu:* Wycena używanego samochodu osobowego na potrzeby salonów/komisów samochodowych.
2. **Wymagany model:** Rozwiązaniem problemu biznesowego musi być działający **model** – może to być model sztucznej inteligencji / uczenia maszynowego (AI/ML) lub inny model matematyczny/statystyczny.

---

## 3. Wybór źródła i zakres danych do pobrania

* **Źródło danych:** Należy podać dokładny adres URL strony docelowej. Jeśli serwis jest bardzo duży, wystarczające jest pobranie jego sensownego podzbioru.
* **Weryfikacja dostępności (`robots.txt`):** Przed napisaniem scrapera należy sprawdzić regulamin wybranego serwisu oraz plik `robots.txt` (w szczególności dyrektywy `User-agent`, `Disallow` oraz ewentualny parametr `Crawl-delay`).
* **Wymagana skala:** Wybrana kategoria musi mieć odpowiednio dużo podstron (minimum **kilkanaście stron** z produktami/ogłoszeniami).
  * *Przykłady skali:* x-kom (kategoria telefony – np. 30 stron po 30 modeli = 900 adresów URL) lub serwis posiadający 80 stron ofert.
* **Przykładowe zmienne do wydobycia:**
  * model / nazwa produktu,
  * cena regularna oraz cena promocyjna,
  * liczba opinii i oceny (nie trzeba ograniczać się wyłącznie do samej liczby gwiazdek),
  * szczegółowa specyfikacja techniczna.

---

## 4. Architektura projektu i wymagane pliki

Na podstawie notatek oraz schematu z tablicy projekt musi składać się z następujących elementów połączonych w logiczny przepływ danych:

```text
[ funkcje.R ] ──(source)──▶ [ scraper.R ] ──▶ [ dane_raw.csv ] ──▶ [ przygot_danych.R ] ──▶ [ dane przygotowane + model ] ──▶ [ nazwisko1_nazwisko2.Rmd -> .html ]
```

### Lista plików, które muszą znaleźć się w paczce `.zip`:
1. **`funkcje.R`** – plik zawierający własne, wielokrotnie wykorzystywane funkcje (jest to absolutne minimum wymagane dla zachowania porządku w kodzie).
2. **`scraper.R`** – główny skrypt pobierający dane ze strony. Na początku pliku musi znajdować się odwołanie ładujące funkcje z odpowiednim kodowaniem:
   ```r
   source("funkcje.R", encoding = "UTF8")
   ```
3. **Dane surowe (`dane_raw.csv`)** – plik `.csv` będący bezpośrednim wynikiem działania skryptu `scraper.R`.
4. **Przygotowanie danych (`przygot_danych.R`)** – skrypt wczytujący `dane_raw.csv` oraz czyszczący i przekształcający dane do postaci gotowej do analizy i modelowania.
5. **Dane przygotowane oraz kod analizy/modelu** – przetworzony zbiór danych oraz skrypt `.R`, w którym przeprowadzana jest właściwa analiza i budowa modelu.
6. **Plik źródłowy raportu (`nazwisko1_nazwisko2.Rmd`)** – plik R Markdown zgodny z szablonem prowadzącego (w przypadku pracy w parze oba nazwiska oddzielone podkreślnikiem).
7. **Raport wynikowy (`nazwisko1_nazwisko2.html`)** – wygenerowany (skompilowany) z pliku `.Rmd` raport w formacie HTML.

---

## 5. Wskazówki techniczne dotyczące scrapowania (z wykładu i przykładów kodu)

* **Dwuetapowy proces scrapowania:**
  1. **Krok 1 (Zbieranie linków i paginacja):** Scraper przechodzi po kolejnych podstronach listy produktów (budując adresy na podstawie stałego elementu URL i doklejając kolejne numery stron, np. `page2`, `page3` lub `?page=2`) i zbiera wszystkie linki prowadzące do konkretnych ofert.
  2. **Krok 2 (Pobieranie szczegółów):** Dopiero na podstawie zebranej listy linków scraper wchodzi w każdy pojedynczy adres i pobiera szczegółowe dane o produkcie.
* **Przedstawienie się jako przeglądarka (User-Agent):** Aby uniknąć zablokowania przez serwer, należy użyć funkcji `GET()` z nagłówkiem `user_agent()` (z pakietu `httr`):
  ```r
  my_agent <- user_agent("...")
  www_start <- GET(url, my_agent)
  ```
* **Niezawodność i spowalnianie żądań (`httr`, `purrr`):**
  * **Kontrola odpowiedzi serwera:** Sprawdzanie poprawności pobrania strony za pomocą `status_code()` oraz `http_error()`.
  * **Obsługa wyjątków:** Zabezpieczenie pętli pobierającej za pomocą `tryCatch(..., error = function(e) ...)`, aby błąd na pojedynczej podstronie nie przerywał działania całego skryptu.
  * **Opóźnienia między zapytaniami:** Stosowanie przerw czasowych przy użyciu funkcji `purrr::slowly(..., rate = rate_delay(...))` lub `Sys.sleep()`, aby nie przeciążać serwera.
* **Analiza struktury HTML i ekstrakcja danych (`rvest`):**
  * W przeglądarce internetowej otwieramy narzędzia deweloperskie skrótem **`Ctrl + Shift + I`**, klikamy ikonę wyboru elementu w lewym górnym rogu i wskazujemy interesujący nas kontener na stronie, aby odczytać jego selektory CSS lub ścieżkę XPath.
  * W R strukturę strony wczytujemy funkcją `read_html()`, elementy wyszukujemy przez `html_element()` i `html_elements()`, a właściwe wartości wydobywamy za pomocą `html_text()`, `html_attr()` oraz `html_table()`.
* **Rozdzielenie kodu (Ważna uwaga do notatek):** W jednej z notatek pojawił się zapis *„Nie pisać w żadnym wypadku scrapera w R script!”* – w praktyce pracy w R oznacza to zakaz umieszczania kodu scrapera **bezpośrednio w raporcie R Markdown (`.Rmd`)** (ponieważ w szablonie ustawione jest `cache = FALSE`, raport przy każdej kompilacji od nowa pobierałby setki stron). Zarówno scraper (`scraper.R`), jak i właściwą analizę danych piszemy w osobnych plikach `.R`, a raport wczytuje gotowe dane z dysku.

---

## 6. Zasady tworzenia raportu (`nazwisko1_nazwisko2.Rmd` -> `.html`)

Raport ma być zwięzłą **syntezą** projektu, a nie zrzutem całego kodu.

* **Szablon z MS Teams:** Pracujemy na udostępnionym szablonie – **nie wolno usuwać jego początku** (nagłówka konfiguracyjnego YAML, który odpowiada za numerację sekcji `number_sections: yes`, pływający spis treści `toc_float: yes`, motyw `united` oraz wykresy wektorowe `dev: svg`).
* **Wymagane elementy merytoryczne:**
  * tytuł projektu oraz autor/autorzy,
  * opis problemu biznesowego i sposobu podejścia do jego rozwiązania,
  * wykresy oraz kluczowe wnioski z analizy i działania modelu.
* **Składnia R Markdown do wykorzystania:**
  * `#` – tytuł rozdziału,
  * `##` – tytuł podrozdziału,
  * `**tekst**` – pogrubienie tekstu,
  * `{r}` – wstawka (chunk) traktowana przez R jako kod do wykonania,
  * `` `r ...` `` – dynamiczne wstawki kodu R w treści akapitu (*inline R*, np. `` `r max(mtcars$hp)` ``), używane do automatycznego wstawiania wyników liczbowych bezpośrednio w zdaniach.
* **Zasady prezentacji tabel:**
  * Do estetycznego formatowania tabel używamy funkcji **`kable()`** (z pakietu `knitr`).
  * **Zakaz wklejania całych zbiorów danych** (np. tabel mających 100 i więcej wierszy) – w raporcie prezentujemy wyłącznie krótki wycinek danych (kilka przykładowych wierszy, np. `kable(dane[1:5, ])` lub `head()`).
* **Uwagi techniczne do szablonu prowadzącego:**
  * Globalnie w szablonie ustawiono `echo = TRUE` – wszystkie bloki `{r}` będą widoczne w wygenerowanym pliku `.html` (dlatego w raporcie umieszczamy tylko krótkie wstawki prezentujące wyniki; w razie potrzeby ukrycia kodu dla pojedynczego bloku można ustawić `echo = FALSE`).
  * Ustawienie `tidy = TRUE` w szablonie wymaga zainstalowanego pakietu `formatR`, aby kod w raporcie kompilował się bez błędów formatowania.

---

## 7. Kryteria oceny (kolejność weryfikacji)

Prowadzący sprawdza oddane projekty etapami, poczynając od wymagań minimalnych:

1. **Etap 1 (Minimum):** Czy działają skrypty `funkcje.R` oraz `scraper.R`.
2. **Etap 2:** Czy poprawnie wygenerowano zbiór surowy (`dane_raw.csv`) oraz dane przygotowane do analizy (`przygot_danych.R`).
3. **Etap 3:** Czy załączono poprawny plik raportu (`nazwisko1_nazwisko2.Rmd`) oraz wygenerowany plik wynikowy `nazwisko1_nazwisko2.html` (wraz z plikami potrzebnymi do jego skompilowania).
4. **Etap 4:** Czy całość została poprawnie spakowana w plik `.zip` i wysłana mailem w terminie.