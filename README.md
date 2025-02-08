# System Rezerwacji Wakacyjnych

**Opis:**  
Projekt przedstawia bazę danych opartą na typach obiektowych Oracle. System umożliwia zarządzanie ofertami wakacyjnymi, rezerwacjami, promocjami oraz ocenami hoteli. Wykorzystuje zaawansowane mechanizmy wyzwalaczy (triggerów) i pakietów PL/SQL do zapewnienia integralności danych i obsługi logiki biznesowej.

---

## Spis treści

1. [Struktura Bazodanowa](#struktura-bazodanowa)
   - [Typy Obiektowe](#typy-obiektowe)
   - [Tabele](#tabele)
2. [Sekwencje](#sekwencje)
3. [Wyzwalacze (Triggery)](#wyzwalacze-triggery)
4. [Pakiety](#pakiety)
   - [pkg_travel_search](#pkg_travel_search)
   - [pkg_travel_display](#pkg_travel_display)
   - [pkg_reservation_management](#pkg_reservation_management)
5. [Instrukcje Instalacji](#instrukcje-instalacji)
6. [Uwagi Końcowe](#uwagi-końcowe)

---

## Struktura Bazodanowa

### Typy Obiektowe

W projekcie zdefiniowano szereg typów obiektowych, m.in.:

- **Adresy_typ**  
  Reprezentuje adres, zawiera pola: `adresID`, `ulica`, `nr_domu`, `nr_mieszkania`, `kod_pocztowy`, `miasto`, `kraj`.

- **Ocena_typ**  
  Zawiera ocenę: `wartosc`, `komentarz` oraz `data`.

- **Hotel_typ**  
  Opisuje hotel, zawiera: `hotelID`, `nazwa`, `lokalizacja`, `kraj`, `region`, `opisLong`, `dla_doroslych` oraz `adres` (typu `Adresy_typ`).

- **Uzytkownik_typ**  
  Przechowuje dane użytkownika: `uzytkownik_id`, `imie`, `nazwisko`, `email`, `telefon`, `typ_uzytkownika`, `data_urodzenia`.

- **OcenaHoteli_typ**  
  Łączy ocenę z REF-ami do użytkownika i hotelu oraz obiekt `Ocena_typ`.

- **Atrakcja_typ**  
  Opisuje pojedynczą atrakcję: `atrakcjaID`, `nazwa` oraz `opis_atrakcji`.

- **ListaAtrakcje_typ**  
  Kolekcja obiektów `Atrakcja_typ` (nested table).

- **Kategorie_typ**  
  Definiuje kategorię oferty, np. all inclusive, last minute, wakacje z dziećmi.

- **OfertyWakacyjne_typ**  
  Reprezentuje ofertę wakacyjną. Zawiera: `packID`, REF do kategorii i hotelu, `startDate`, `endDate`, `price`, `original_price`, `opis_pakietu`, `duration`, `atrakcje` oraz `max_capacity`.

- **Promotions_typ**  
  Opisuje promocję powiązaną z ofertą: `promoId`, REF do oferty, `promoName`, `promoDesc`, `discount`, `startDate`, `endDate`.

- **Rezerwacja_typ**  
  Przechowuje rezerwację, zawiera: `rezerwacja_id`, REF do użytkownika, REF do oferty, `data_rezerwacji` oraz `cena_rezerwacji`.

### Tabele

Na bazie powyższych typów obiektowych utworzono tabele:

- **Hotele_tab** – obiekty typu `Hotel_typ`  
  *Primary Key:* `hotelID`

- **OcenyHoteli_tab** – obiekty typu `OcenaHoteli_typ`  
  *Primary Key:* `ocena_id`

- **OfertyWakacyjne_tab** – obiekty typu `OfertyWakacyjne_typ`  
  *Primary Key:* `packID`  
  *Dodatkowo:* Nested table `atrakcje` (STORE AS AtrakcjeStore)

- **Promocje_tab** – obiekty typu `Promotions_typ`  
  *Primary Key:* `promoId`

- **Uzytkownicy_tab** – obiekty typu `Uzytkownik_typ`  
  *Primary Key:* `uzytkownik_id`

- **Rezerwacje_tab** – obiekty typu `Rezerwacja_typ`  
  *Primary Key:* `rezerwacja_id`

- **Kategorie_tab** – obiekty typu `Kategorie_typ`  
  *Primary Key:* `catId`

Dla tabel zdefiniowano dodatkowe **CHECK** constraints (np. cena > 0, `endDate` > `startDate`, rating między 1 a 5) oraz klauzule `SCOPE FOR`, aby REF-y wskazywały na odpowiednie tabele.

---

## Sekwencje

- **seq_rezerwacja_id**  
  Służy do generowania unikatowych identyfikatorów dla rezerwacji w tabeli `Rezerwacje_tab`. Wyzwalacz `trg_rezerwacja_id_gen` wykorzystuje tę sekwencję podczas INSERT-u.

---

## Wyzwalacze (Triggery)

Projekt zawiera szereg wyzwalaczy, między innymi:

1. **trg_check_ocena_hoteli**  
   Sprawdza, czy użytkownik ma zakończoną rezerwację w danym hotelu, zanim umożliwi wystawienie oceny.

2. **trg_update_price_after_promotion**  
   Po wstawieniu lub aktualizacji promocji wylicza nową cenę oferty i aktualizuje pole `price` w tabeli `OfertyWakacyjne_tab`.

3. **trg_restore_price_after_promotion_delete**  
   Po usunięciu promocji przywraca oryginalną cenę oferty.

4. **trg_set_original_price**  
   Przed wstawieniem nowej oferty ustawia `original_price` na wartość pola `price`.

5. **trg_check_reservation_conflict**  
   Sprawdza, czy użytkownik nie posiada już rezerwacji o pokrywających się terminach. W przypadku konfliktu rzuca błąd `ORA-20006` z komunikatem:  
   **"Użytkownik ma już rezerwację w tym terminie"**

6. **trg_rezerwacja_id_gen**  
   Automatycznie nadaje identyfikator rezerwacji z sekwencji `seq_rezerwacja_id` przed INSERT-em w `Rezerwacje_tab`.

7. **trg_set_reservation_price**  
   Ustawia pole `cena_rezerwacji` na aktualną cenę oferty w momencie tworzenia rezerwacji.

8. **limit_miejsc**  
   Kontroluje, czy liczba rezerwacji nie przekracza maksymalnej pojemności oferty (`max_capacity`). W przypadku przekroczenia wyzwala błąd.

---

## Pakiety

### pkg_travel_search

- **Cel:** Umożliwia wyszukiwanie ofert wakacyjnych według wielu kryteriów.
- **Funkcjonalność:**
  - Procedura `search_offers` przyjmuje parametry takie jak rating, długość pobytu, kraj, region, cena, itp. i zwraca wyniki jako REF CURSOR.
  - Funkcje `get_available_countries` oraz `get_available_regions` zwracają listę dostępnych krajów i regionów.

### pkg_travel_display

- **Cel:** Prezentacja wyników wyszukiwania.
- **Funkcjonalność:**
  - Definiuje rekord `r_oferta` do przechowywania szczegółów oferty.
  - Procedura `display_search_results` pobiera wyniki z `pkg_travel_search` i wyświetla je przy użyciu `DBMS_OUTPUT.PUT_LINE`.

### pkg_reservation_management

- **Cel:** Zarządzanie rezerwacjami.
- **Funkcjonalność:**
  - **create_reservation:** Tworzy rezerwację, sprawdza istnienie użytkownika i oferty, weryfikuje dostępność oraz obsługuje wyjątki, m.in. konflikt terminów.
  - **cancel_reservation:** Anuluje rezerwację, o ile jeszcze się nie zakończyła.
  - **generate_user_reservations_report:** Generuje raport rezerwacji dla danego użytkownika.
  - **check_availability:** Prosta weryfikacja dostępności oferty według dat.

> **Uwaga:** W `create_reservation` przechwytywany jest wyjątek `ex_reservation_conflict` (kod -20006) rzucany przez wyzwalacz `trg_check_reservation_conflict`. Wówczas użytkownik otrzymuje komunikat:  
> **"ERROR: Użytkownik ma już rezerwację w tym terminie"**

---

## Instrukcje Instalacji

1. **Utwórz użytkownika** w bazie Oracle i nadaj mu odpowiednie uprawnienia (np. `CREATE SESSION`, `CREATE TABLE`, `CREATE TYPE`).
2. **Uruchom skrypty**:
   - Najpierw zdefiniuj **typy obiektowe** (np. `Adresy_typ`, `Hotel_typ`, `Uzytkownik_typ`, itd.).
   - Następnie utwórz **tabele obiektowe** wraz z constraintami i klauzulami `SCOPE FOR`.
   - Wykonaj skrypt tworzący **sekwencje** oraz **wyzwalacze** (triggery).
   - Na końcu uruchom skrypty definiujące **pakiety**: `pkg_travel_search`, `pkg_travel_display`, `pkg_reservation_management`.
3. **COMMIT** wszystkie zmiany.
4. (Opcjonalnie) Dodaj dane testowe (np. przykładowe hotele, oferty, użytkowników) i przetestuj działanie systemu.

---

## Uwagi Końcowe

- **Konflikt rezerwacji:**  
  Wyzwalacz `trg_check_reservation_conflict` zapobiega sytuacjom, gdy użytkownik rezerwuje oferty o nachodzących się terminach. W przypadku konfliktu wyświetlany jest komunikat:  
  **"ERROR: Użytkownik ma już rezerwację w tym terminie"**

- **Obsługa promocji:**  
  Wyzwalacze `trg_update_price_after_promotion` oraz `trg_restore_price_after_promotion_delete` automatycznie aktualizują cenę oferty w zależności od promocji.

- **Modularność:**  
  Pakiety zostały podzielone na moduły wyszukiwania, wyświetlania oraz zarządzania rezerwacjami, co umożliwia łatwą rozbudowę systemu.

---

## Przykład Użycia

Tworzenie rezerwacji:

```sql
DECLARE
    v_status VARCHAR2(200);
BEGIN
    pkg_reservation_management.create_reservation(
        p_user_id => 1,
        p_package_id => 5,
        p_status => v_status
    );
    DBMS_OUTPUT.PUT_LINE('Wynik: ' || v_status);
END;
/
