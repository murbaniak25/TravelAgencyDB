--TRIGGER SPRAWDZAJ�CY POPRAWNO�� WYSTAWIANIA OCENY PRZEZ U�YTKOWNIKA
CREATE OR REPLACE TRIGGER trg_check_ocena_hoteli
BEFORE INSERT OR UPDATE ON OcenyHoteli_tab
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Sprawdzenie, czy u�ytkownik ma zako�czon� rezerwacj� na dany hotel
    SELECT COUNT(*)
    INTO v_count
    FROM Rezerwacje_tab r
    JOIN OfertyWakacyjne_tab o ON r.ref_oferta = REF(o)
    WHERE r.ref_uzytkownik = :NEW.ref_uzytkownik
      AND o.ref_hotel = :NEW.ref_hotel
      AND o.endDate < SYSDATE;
      
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'U�ytkownik musi mie� zako�czon� rezerwacj� na ten hotel, aby wystawi� ocen�.');
    END IF;
END;
/
