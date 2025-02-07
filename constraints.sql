ALTER TABLE OcenyHoteli_tab
  ADD CONSTRAINT chk_ocena_wartosc
  CHECK (ocena.wartosc BETWEEN 1 AND 5);
/

ALTER TABLE OfertyWakacyjne_tab
  ADD CONSTRAINT chk_price_positive
  CHECK (price > 0);
/

ALTER TABLE OfertyWakacyjne_tab
  ADD CONSTRAINT chk_date_order
  CHECK (endDate > startDate);
/

ALTER TABLE OfertyWakacyjne_tab
  ADD CONSTRAINT chk_duration_positive
  CHECK (duration > 0);
/

ALTER TABLE Hotele_tab
  ADD CONSTRAINT chk_dla_doroslych
  CHECK (dla_doroslych IN (0, 1));
/

ALTER TABLE Hotele_tab
  ADD CONSTRAINT chk_hotel_country_not_null
  CHECK (kraj IS NOT NULL);
/

ALTER TABLE Kategorie_tab
  ADD CONSTRAINT chk_allIn
  CHECK (allIn IN (0, 1));
/

ALTER TABLE Kategorie_tab
  ADD CONSTRAINT chk_lastMinute
  CHECK (lastMinute IN (0, 1));
/

ALTER TABLE Rezerwacje_tab
  ADD (SCOPE FOR (ref_uzytkownik) IS Uzytkownicy_tab);
/

ALTER TABLE Rezerwacje_tab
  ADD (SCOPE FOR (ref_oferta) IS OfertyWakacyjne_tab);
/

ALTER TABLE Promocje_tab
  ADD (SCOPE FOR (ref_package) IS OfertyWakacyjne_tab);
/

ALTER TABLE OcenyHoteli_tab
  ADD (SCOPE FOR (ref_uzytkownik) IS Uzytkownicy_tab);
/

ALTER TABLE OcenyHoteli_tab
  ADD (SCOPE FOR (ref_hotel) IS Hotele_tab);
/

ALTER TABLE OfertyWakacyjne_tab
  ADD (SCOPE FOR (ref_hotel) IS Hotele_tab);
/

ALTER TABLE OfertyWakacyjne_tab
  ADD (SCOPE FOR (ref_cat) IS Kategorie_tab);
/

COMMIT;
