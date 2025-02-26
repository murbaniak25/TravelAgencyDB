-- WYUSZKIWARKA --

CREATE OR REPLACE PACKAGE pkg_travel_search AS
    TYPE t_refcursor IS REF CURSOR;
    PROCEDURE search_offers(
        p_min_rating     IN NUMBER   DEFAULT NULL,
        p_min_duration   IN NUMBER   DEFAULT NULL,
        p_max_duration   IN NUMBER   DEFAULT NULL,
        p_country        IN VARCHAR2 DEFAULT NULL,
        p_region         IN VARCHAR2 DEFAULT NULL,
        p_dla_doroslych  IN NUMBER   DEFAULT NULL,
        p_allIn          IN NUMBER   DEFAULT NULL,
        p_lastMinute     IN NUMBER   DEFAULT NULL,
        p_min_price      IN NUMBER   DEFAULT NULL,
        p_max_price      IN NUMBER   DEFAULT NULL,
        p_wakacje_z_dziecmi IN NUMBER DEFAULT NULL,
        p_rc             OUT t_refcursor
    );
    
    FUNCTION get_available_countries RETURN t_refcursor;
    
    FUNCTION get_available_regions(
        p_country IN VARCHAR2
    ) RETURN t_refcursor;
END pkg_travel_search;
/

CREATE OR REPLACE PACKAGE BODY pkg_travel_search AS
    PROCEDURE search_offers(
        p_min_rating     IN NUMBER   DEFAULT NULL,
        p_min_duration   IN NUMBER   DEFAULT NULL,
        p_max_duration   IN NUMBER   DEFAULT NULL,
        p_country        IN VARCHAR2 DEFAULT NULL,
        p_region         IN VARCHAR2 DEFAULT NULL,
        p_dla_doroslych  IN NUMBER   DEFAULT NULL,
        p_allIn          IN NUMBER   DEFAULT NULL,
        p_lastMinute     IN NUMBER   DEFAULT NULL,
        p_min_price      IN NUMBER   DEFAULT NULL,
        p_max_price      IN NUMBER   DEFAULT NULL,
        p_wakacje_z_dziecmi IN NUMBER DEFAULT NULL,
        p_rc             OUT t_refcursor
    ) IS
    BEGIN
        OPEN p_rc FOR
            SELECT *
            FROM v_oferty_details v
            WHERE v.srednia_ocena >= NVL(p_min_rating, 0)
            AND v.liczba_dni >= NVL(p_min_duration, 0)
            AND v.liczba_dni <= NVL(p_max_duration, 999)
            AND (p_country IS NULL OR v.kraj = p_country)
            AND (p_region IS NULL OR v.region = p_region)
            AND (p_dla_doroslych IS NULL OR v.dla_doroslych = p_dla_doroslych)
            AND (p_allIn IS NULL OR v.all_inclusive = p_allIn)
            AND (p_lastMinute IS NULL OR v.last_minute = p_lastMinute)
            AND (p_min_price IS NULL OR v.cena >= p_min_price)
            AND (p_max_price IS NULL OR v.cena <= p_max_price)
            AND (p_wakacje_z_dziecmi IS NULL OR v.wakacje_z_dziecmi = p_wakacje_z_dziecmi)
            ORDER BY v.srednia_ocena DESC;
    END search_offers;
    
    FUNCTION get_available_countries RETURN t_refcursor IS
        v_rc t_refcursor;
    BEGIN
        OPEN v_rc FOR
            SELECT DISTINCT kraj
            FROM Hotele_tab
            ORDER BY kraj;
        RETURN v_rc;
    END get_available_countries;
    
    FUNCTION get_available_regions(
        p_country IN VARCHAR2
    ) RETURN t_refcursor IS
        v_rc t_refcursor;
    BEGIN
        OPEN v_rc FOR
            SELECT DISTINCT region
            FROM Hotele_tab
            WHERE kraj = p_country
            ORDER BY region;
        RETURN v_rc;
    END get_available_regions;
END pkg_travel_search;
/

CREATE OR REPLACE PACKAGE pkg_travel_display AS
    TYPE r_oferta IS RECORD (
        id_oferty NUMBER,
        opis VARCHAR2(2000),
        cena NUMBER,
        liczba_dni NUMBER,
        data_rozpoczecia DATE,
        data_zakonczenia DATE,
        id_hotelu NUMBER,
        nazwa_hotelu VARCHAR2(200),
        kraj VARCHAR2(100),
        region VARCHAR2(100),
        dla_doroslych NUMBER,
        id_kategorii NUMBER,
        nazwa_kategorii VARCHAR2(100),
        all_inclusive NUMBER,
        last_minute NUMBER,
        wakacje_z_dziecmi NUMBER,
        srednia_ocena NUMBER
    );
    
    PROCEDURE display_search_results(
        p_min_rating IN NUMBER DEFAULT 4,
        p_min_duration IN NUMBER DEFAULT 7,
        p_max_duration IN NUMBER DEFAULT 14,
        p_country IN VARCHAR2 DEFAULT NULL,
        p_region IN VARCHAR2 DEFAULT NULL,
        p_allIn IN NUMBER DEFAULT NULL,
        p_min_price IN NUMBER DEFAULT 2000,
        p_max_price IN NUMBER DEFAULT 5000
    );
    
    FUNCTION format_offer_details(p_record IN r_oferta) RETURN VARCHAR2;
END pkg_travel_display;
/


-- WYSWIETLANIE WYNIKOW SWYSZUKIWANIA -- 


CREATE OR REPLACE PACKAGE BODY pkg_travel_display AS
    PROCEDURE print_separator IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    END print_separator;
    
    PROCEDURE print_offer_details(p_record IN r_oferta) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID Oferty: ' || p_record.id_oferty);
        DBMS_OUTPUT.PUT_LINE('Hotel: ' || p_record.nazwa_hotelu || ' (' || p_record.kraj || ', ' || p_record.region || ')');
        DBMS_OUTPUT.PUT_LINE('Cena: ' || p_record.cena || ' PLN');
        DBMS_OUTPUT.PUT_LINE('Liczba dni: ' || p_record.liczba_dni);
        DBMS_OUTPUT.PUT_LINE('Średnia ocena: ' || ROUND(p_record.srednia_ocena, 2));
        DBMS_OUTPUT.PUT_LINE('Kategoria: ' || p_record.nazwa_kategorii);
        DBMS_OUTPUT.PUT_LINE('All Inclusive: ' || CASE WHEN p_record.all_inclusive = 1 THEN 'Tak' ELSE 'Nie' END);
        DBMS_OUTPUT.PUT_LINE('Last Minute: ' || CASE WHEN p_record.last_minute = 1 THEN 'Tak' ELSE 'Nie' END);
        DBMS_OUTPUT.PUT_LINE('Data: ' || TO_CHAR(p_record.data_rozpoczecia, 'YYYY-MM-DD') || ' - ' || 
                                       TO_CHAR(p_record.data_zakonczenia, 'YYYY-MM-DD'));
        print_separator;
    END print_offer_details;
    
    FUNCTION format_offer_details(p_record IN r_oferta) RETURN VARCHAR2 IS
        v_result VARCHAR2(4000);
    BEGIN
        v_result := 
            'ID: ' || p_record.id_oferty || CHR(10) ||
            'Hotel: ' || p_record.nazwa_hotelu || ' (' || p_record.kraj || ', ' || p_record.region || ')' || CHR(10) ||
            'Cena: ' || p_record.cena || ' PLN' || CHR(10) ||
            'Liczba dni: ' || p_record.liczba_dni || CHR(10) ||
            '�rednia ocena: ' || ROUND(p_record.srednia_ocena, 2);
        RETURN v_result;
    END format_offer_details;
    
    PROCEDURE display_search_results(
        p_min_rating IN NUMBER DEFAULT 4,
        p_min_duration IN NUMBER DEFAULT 7,
        p_max_duration IN NUMBER DEFAULT 14,
        p_country IN VARCHAR2 DEFAULT NULL,
        p_region IN VARCHAR2 DEFAULT NULL,
        p_allIn IN NUMBER DEFAULT NULL,
        p_min_price IN NUMBER DEFAULT 2000,
        p_max_price IN NUMBER DEFAULT 5000
    ) IS
        v_rc pkg_travel_search.t_refcursor;
        v_record r_oferta;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Wyniki wyszukiwania ===');
        DBMS_OUTPUT.PUT_LINE(
            'Kryteria: rating>=' || p_min_rating || 
            ', d�ugo�� ' || p_min_duration || '-' || p_max_duration || ' dni' ||
            CASE WHEN p_country IS NOT NULL THEN ', kraj: ' || p_country ELSE '' END ||
            CASE WHEN p_region IS NOT NULL THEN ', region: ' || p_region ELSE '' END ||
            CASE WHEN p_allIn IS NOT NULL THEN ', all inclusive: ' || CASE WHEN p_allIn = 1 THEN 'Tak' ELSE 'Nie' END ELSE '' END ||
            ', cena: ' || p_min_price || '-' || p_max_price || ' PLN'
        );
        print_separator;
        
        pkg_travel_search.search_offers(
            p_min_rating => p_min_rating,
            p_min_duration => p_min_duration,
            p_max_duration => p_max_duration,
            p_country => p_country,
            p_region => p_region,
            p_allIn => p_allIn,
            p_min_price => p_min_price,
            p_max_price => p_max_price,
            p_rc => v_rc
        );
        
        LOOP
            FETCH v_rc INTO v_record;
            EXIT WHEN v_rc%NOTFOUND;
            print_offer_details(v_record);
        END LOOP;
        CLOSE v_rc;
    END display_search_results;
END pkg_travel_display;
/


--  ZARZADZANIE REZERWACJAMI --

create or replace PACKAGE pkg_reservation_management AS
    TYPE t_refcursor IS REF CURSOR;
    PROCEDURE create_reservation(
        p_user_id IN NUMBER,
        p_package_id IN NUMBER,
        p_reservation_date IN DATE DEFAULT SYSDATE,
        p_status OUT VARCHAR2
    );
    FUNCTION check_availability(
        p_package_id IN NUMBER,
        p_start_date IN DATE
    ) RETURN BOOLEAN;
    PROCEDURE cancel_reservation(
        p_reservation_id IN NUMBER,
        p_status OUT VARCHAR2
    );
    PROCEDURE generate_user_reservations_report(
        p_user_id IN NUMBER
    );
END pkg_reservation_management;
/
CREATE OR REPLACE PACKAGE BODY pkg_reservation_management AS

   ex_reservation_not_found    EXCEPTION;
   PRAGMA EXCEPTION_INIT(ex_reservation_not_found, -20001);

   ex_reservation_ended        EXCEPTION;
   PRAGMA EXCEPTION_INIT(ex_reservation_ended, -20002);

   ex_user_not_found           EXCEPTION;
   PRAGMA EXCEPTION_INIT(ex_user_not_found, -20003);

   ex_package_not_found        EXCEPTION;
   PRAGMA EXCEPTION_INIT(ex_package_not_found, -20004);

   ex_package_unavailable      EXCEPTION;
   PRAGMA EXCEPTION_INIT(ex_package_unavailable, -20005);

   ex_reservation_conflict     EXCEPTION;
   PRAGMA EXCEPTION_INIT(ex_reservation_conflict, -20006);


   PROCEDURE create_reservation(
       p_user_id         IN NUMBER,
       p_package_id      IN NUMBER,
       p_reservation_date IN DATE DEFAULT SYSDATE,
       p_status          OUT VARCHAR2
   ) IS
       v_package_ref        REF OfertyWakacyjne_typ;
       v_user_ref           REF Uzytkownik_typ;
       v_package_available  BOOLEAN;
       v_user_exists        NUMBER;
       v_package_exists     NUMBER;
       v_current_price      NUMBER;
   BEGIN

       SELECT COUNT(*)
         INTO v_user_exists
         FROM Uzytkownicy_tab 
         WHERE uzytkownik_id = p_user_id;

       IF v_user_exists = 0 THEN
          RAISE_APPLICATION_ERROR(-20003, 'ERROR: User does not exist.');
       END IF;

       SELECT COUNT(*)
         INTO v_package_exists
         FROM OfertyWakacyjne_tab
         WHERE packID = p_package_id;

       IF v_package_exists = 0 THEN
          RAISE_APPLICATION_ERROR(-20004, 'ERROR: Package does not exist.');
       END IF;

       SELECT REF(o), o.price
         INTO v_package_ref, v_current_price
         FROM OfertyWakacyjne_tab o
         WHERE o.packID = p_package_id;

       SELECT REF(u)
         INTO v_user_ref
         FROM Uzytkownicy_tab u
         WHERE u.uzytkownik_id = p_user_id;

       v_package_available := check_availability(p_package_id, p_reservation_date);
       IF v_package_available THEN
           INSERT INTO Rezerwacje_tab VALUES (
               Rezerwacja_typ(
                   NULL,
                   v_user_ref,
                   v_package_ref,
                   p_reservation_date,
                   v_current_price
               )
           );
           p_status := 'SUCCESS';
           COMMIT;
       ELSE
           RAISE_APPLICATION_ERROR(-20005, 'ERROR: Package not available.');
       END IF;

   EXCEPTION
       WHEN ex_user_not_found THEN
           p_status := 'ERROR: ' || SUBSTR(SQLERRM, 1, 200);
           ROLLBACK;

       WHEN ex_package_not_found THEN
           p_status := 'ERROR: ' || SUBSTR(SQLERRM, 1, 200);
           ROLLBACK;

       WHEN ex_package_unavailable THEN
           p_status := 'ERROR: ' || SUBSTR(SQLERRM, 1, 200);
           ROLLBACK;

       WHEN ex_reservation_conflict THEN
           p_status := 'ERROR: U�ytkownik ma ju� rezerwacj� w tym terminie';
           ROLLBACK;

       WHEN DUP_VAL_ON_INDEX THEN
           p_status := 'ERROR: Duplicate reservation.';
           ROLLBACK;

       WHEN NO_DATA_FOUND THEN
           p_status := 'ERROR: Required data not found.';
           ROLLBACK;

       WHEN OTHERS THEN
           p_status := 'ERROR: ' || SUBSTR(SQLERRM, 1, 200);
           ROLLBACK;
   END create_reservation;


   FUNCTION check_availability(
       p_package_id IN NUMBER,
       p_start_date IN DATE
   ) RETURN BOOLEAN IS
       v_available NUMBER;
   BEGIN
       SELECT COUNT(*)
         INTO v_available
         FROM OfertyWakacyjne_tab o
         WHERE o.packID = p_package_id 
           AND o.startDate >= p_start_date;

       RETURN v_available > 0;
   END check_availability;


   PROCEDURE cancel_reservation(
       p_reservation_id IN NUMBER,
       p_status OUT VARCHAR2
   ) IS
       v_exists NUMBER;
       v_upcoming NUMBER;
   BEGIN
       SELECT COUNT(*)
         INTO v_exists
         FROM Rezerwacje_tab 
         WHERE rezerwacja_id = p_reservation_id;
       IF v_exists = 0 THEN
           RAISE_APPLICATION_ERROR(-20001, 'ERROR: Reservation not found.');
       END IF;

       SELECT COUNT(*)
         INTO v_upcoming
         FROM Rezerwacje_tab r 
         JOIN OfertyWakacyjne_tab o ON REF(o) = r.ref_oferta 
         WHERE r.rezerwacja_id = p_reservation_id 
           AND o.endDate > SYSDATE;
       IF v_upcoming = 0 THEN
           RAISE_APPLICATION_ERROR(-20002, 'ERROR: The reservation has already ended.');
       END IF;

       DELETE FROM Rezerwacje_tab 
       WHERE rezerwacja_id = p_reservation_id;

       p_status := 'SUCCESS';
       COMMIT;

   EXCEPTION
       WHEN ex_reservation_not_found THEN
           p_status := 'ERROR: ' || SUBSTR(SQLERRM, 1, 200);
           ROLLBACK;

       WHEN ex_reservation_ended THEN
           p_status := 'ERROR: ' || SUBSTR(SQLERRM, 1, 200);
           ROLLBACK;

       WHEN OTHERS THEN
           p_status := 'ERROR: ' || SUBSTR(SQLERRM, 1, 200);
           ROLLBACK;
   END cancel_reservation;


   PROCEDURE generate_user_reservations_report(
       p_user_id IN NUMBER
   ) IS
       CURSOR c_reservations IS
           SELECT r.rezerwacja_id,
                  o.packID,
                  o.price,
                  o.startDate,
                  o.endDate,
                  h.nazwa,
                  h.kraj,
                  r.cena_rezerwacji
           FROM Rezerwacje_tab r
           JOIN OfertyWakacyjne_tab o ON REF(o) = r.ref_oferta
           JOIN Hotele_tab h          ON REF(h) = o.ref_hotel
           JOIN Uzytkownicy_tab u     ON REF(u) = r.ref_uzytkownik
           WHERE u.uzytkownik_id = p_user_id
           ORDER BY o.startDate;
   BEGIN
       DBMS_OUTPUT.PUT_LINE('=== Raport rezerwacji dla u�ytkownika ' || p_user_id || ' ===');
       DBMS_OUTPUT.PUT_LINE('Data wygenerowania: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
       DBMS_OUTPUT.PUT_LINE('-----------------------------------------');

       FOR r IN c_reservations LOOP
           DBMS_OUTPUT.PUT_LINE('Rezerwacja ID: ' || r.rezerwacja_id);
           DBMS_OUTPUT.PUT_LINE('Oferta ID: ' || r.packID);
           DBMS_OUTPUT.PUT_LINE('Hotel: ' || r.nazwa || ' (' || r.kraj || ')');
           DBMS_OUTPUT.PUT_LINE('Termin: ' || TO_CHAR(r.startDate, 'YYYY-MM-DD')
                                || ' - ' || TO_CHAR(r.endDate, 'YYYY-MM-DD'));
           DBMS_OUTPUT.PUT_LINE('Cena w momencie rezerwacji: ' || r.cena_rezerwacji || ' PLN');
           DBMS_OUTPUT.PUT_LINE('Aktualna cena oferty: ' || r.price || ' PLN');
           DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
       END LOOP;
   END generate_user_reservations_report;

END pkg_reservation_management;
/
