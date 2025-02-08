CREATE OR REPLACE TRIGGER trg_check_ocena_hoteli
BEFORE INSERT OR UPDATE ON OcenyHoteli_tab
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM Rezerwacje_tab r
    JOIN OfertyWakacyjne_tab o ON r.ref_oferta = REF(o)
    WHERE r.ref_uzytkownik = :NEW.ref_uzytkownik
      AND o.ref_hotel = :NEW.ref_hotel
      AND o.endDate < SYSDATE;
      
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'U¿ytkownik musi mieæ zakoñczon¹ rezerwacjê na ten hotel, aby wystawiæ ocenê.');
    END IF;
END;
/


---------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_update_price_after_promotion
AFTER INSERT OR UPDATE ON Promocje_tab
FOR EACH ROW
DECLARE
    v_offer OfertyWakacyjne_typ;
    v_new_price NUMBER;
BEGIN

    SELECT VALUE(o) INTO v_offer
    FROM OfertyWakacyjne_tab o
    WHERE REF(o) = :NEW.ref_package;
    v_new_price := v_offer.original_price * (1 - :NEW.discount/100);
    
    DBMS_OUTPUT.PUT_LINE('Oryginalna cena: ' || v_offer.original_price);
    DBMS_OUTPUT.PUT_LINE('Zni¿ka: ' || :NEW.discount || '%');
    DBMS_OUTPUT.PUT_LINE('Nowa cena: ' || v_new_price);
    
    UPDATE OfertyWakacyjne_tab o
    SET o.price = v_new_price
    WHERE o.packID = v_offer.packID;

    DBMS_OUTPUT.PUT_LINE('Aktualizacja zakoñczona');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('B³¹d w wyzwalaczu: ' || SQLERRM);
        RAISE;
END;
/

---------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_restore_price_after_promotion_delete
AFTER DELETE ON Promocje_tab
FOR EACH ROW
DECLARE
    v_offer OfertyWakacyjne_typ;
BEGIN

    SELECT VALUE(o) INTO v_offer
    FROM OfertyWakacyjne_tab o
    WHERE REF(o) = :OLD.ref_package;
    
    UPDATE OfertyWakacyjne_tab o
    SET o.price = o.original_price
    WHERE o.packID = v_offer.packID;
    
    DBMS_OUTPUT.PUT_LINE('Przywrócono oryginaln¹ cenê: ' || v_offer.original_price);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('B³¹d w wyzwalaczu przywracania ceny: ' || SQLERRM);
        RAISE;
END;
/

---------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_set_original_price
BEFORE INSERT ON OfertyWakacyjne_tab
FOR EACH ROW
BEGIN
    :NEW.original_price := :NEW.price;
END;
/

---------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_check_reservation_conflict
BEFORE INSERT ON Rezerwacje_tab
FOR EACH ROW
DECLARE
    v_count      NUMBER;
    v_start_date DATE;
    v_end_date   DATE;
BEGIN
    SELECT o.startDate, o.endDate
      INTO v_start_date, v_end_date
      FROM OfertyWakacyjne_tab o
     WHERE REF(o) = :NEW.ref_oferta;

    SELECT COUNT(*)
      INTO v_count
      FROM Rezerwacje_tab r
      JOIN OfertyWakacyjne_tab o ON r.ref_oferta = REF(o)
     WHERE r.ref_uzytkownik = :NEW.ref_uzytkownik
       AND (
           (v_start_date BETWEEN o.startDate AND o.endDate)
        OR (v_end_date   BETWEEN o.startDate AND o.endDate)
       );

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'U¿ytkownik ma ju¿ rezerwacjê w tym terminie');
    END IF;
END;
/

---------------------------------------------------------------------------------------------------------


CREATE SEQUENCE seq_rezerwacja_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
/


CREATE OR REPLACE TRIGGER trg_rezerwacja_id_gen
BEFORE INSERT ON Rezerwacje_tab
FOR EACH ROW
BEGIN
    IF :NEW.rezerwacja_id IS NULL THEN
        SELECT seq_rezerwacja_id.NEXTVAL 
        INTO :NEW.rezerwacja_id 
        FROM dual;
    END IF;
END;
/
---------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_set_reservation_price
BEFORE INSERT ON Rezerwacje_tab
FOR EACH ROW
DECLARE
    v_current_price NUMBER;
BEGIN
    SELECT o.price INTO v_current_price
    FROM OfertyWakacyjne_tab o
    WHERE REF(o) = :NEW.ref_oferta;

    :NEW.cena_rezerwacji := v_current_price;
END;
/


commit;
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER limit_miejsc
BEFORE INSERT ON Rezerwacje_tab
FOR EACH ROW
DECLARE
    v_limit NUMBER;
    v_count NUMBER;
BEGIN
    SELECT t.max_capacity
      INTO v_limit
      FROM OfertyWakacyjne_tab t
     WHERE REF(t) = :NEW.ref_oferta
       FOR UPDATE;
    SELECT COUNT(*)
      INTO v_count
      FROM Rezerwacje_tab r
     WHERE r.ref_oferta = :NEW.ref_oferta;

    IF v_count >= v_limit THEN
        RAISE_APPLICATION_ERROR(-20000, 'Przekroczony limit miejsc dla tej oferty!');
    END IF;
END;
/
