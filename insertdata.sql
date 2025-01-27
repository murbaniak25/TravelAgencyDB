--UZYTKOWNICY
BEGIN
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(1, 'Jan', 'Kowalski', 'jan.kowalski@example.com', '123456789', 'standard', TO_DATE('1990-01-01', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(2, 'Anna', 'Nowak', 'anna.nowak@example.com', '987654321', 'premium', TO_DATE('1985-05-15', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(3, 'Piotr', 'Wi�niewski', 'piotr.wisniewski@example.com', '564738291', 'standard', TO_DATE('1992-03-22', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(4, 'Katarzyna', 'Krawczyk', 'katarzyna.krawczyk@example.com', '473829101', 'premium', TO_DATE('1988-11-11', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(5, 'Tomasz', 'Zieli�ski', 'tomasz.zielinski@example.com', '238476591', 'standard', TO_DATE('1975-07-07', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(6, 'Maria', 'Wo�niak', 'maria.wozniak@example.com', '984721506', 'premium', TO_DATE('1995-12-12', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(7, 'Robert', 'Szyma�ski', 'robert.szymanski@example.com', '764302198', 'standard', TO_DATE('1983-04-20', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(8, 'Magdalena', 'Lewandowska', 'magdalena.lewandowska@example.com', '502341678', 'premium', TO_DATE('1998-02-28', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(9, 'Pawe�', 'Kami�ski', 'pawel.kaminski@example.com', '612435789', 'standard', TO_DATE('2000-06-14', 'YYYY-MM-DD')));
    INSERT INTO Uzytkownicy_tab VALUES (Uzytkownik_typ(10, 'Joanna', 'D�browska', 'joanna.dabrowska@example.com', '123789456', 'premium', TO_DATE('1993-09-09', 'YYYY-MM-DD')));
END;
/

--HOTELE
BEGIN
    INSERT INTO Hotele_tab VALUES (
        Hotel_typ(
            1, 
            'Hotel Pary�',
            'Champs-�lys�es, 101',
            'Francja',
            '�le-de-France',
            'Luksusowy hotel po�o�ony w sercu Pary�a, z widokiem na Wie�� Eiffla.',
            1,
            Adresy_typ(1, 'Champs-�lys�es', '101', NULL, '75008', 'Pary�', 'Francja'),
            NULL -- Brak �redniej oceny na pocz�tku
        )
    );

    INSERT INTO Hotele_tab VALUES (
        Hotel_typ(
            2, 
            'Hotel Londyn',
            'Oxford Street, 200',
            'Wielka Brytania',
            'Greater London',
            'Hotel w centrum Londynu, blisko g��wnych atrakcji turystycznych.',
            1,
            Adresy_typ(2, 'Oxford Street', '200', NULL, 'W1D 1NU', 'Londyn', 'Wielka Brytania'),
            NULL
        )
    );

    INSERT INTO Hotele_tab VALUES (
        Hotel_typ(
            3, 
            'Hotel Nowy Jork',
            'Fifth Avenue, 350',
            'USA',
            'New York',
            'Hotel w Nowym Jorku z widokiem na Central Park.',
            1,
            Adresy_typ(3, 'Fifth Avenue', '350', NULL, '10001', 'Nowy Jork', 'USA'),
            NULL
        )
    );

    INSERT INTO Hotele_tab VALUES (
        Hotel_typ(
            4, 
            'Hotel Barcelona',
            'La Rambla, 45',
            'Hiszpania',
            'Katalonia',
            'Hotel w Barcelonie w pobli�u pla�y i s�ynnej La Rambla.',
            0,
            Adresy_typ(4, 'La Rambla', '45', '2B', '08002', 'Barcelona', 'Hiszpania'),
            NULL
        )
    );

    INSERT INTO Hotele_tab VALUES (
        Hotel_typ(
            5, 
            'Hotel Berlin',
            'Kurf�rstendamm, 180',
            'Niemcy',
            'Berlin',
            'Nowoczesny hotel w centrum Berlina, blisko Bramy Brandenburskiej.',
            1,
            Adresy_typ(5, 'Kurf�rstendamm', '180', '4C', '10719', 'Berlin', 'Niemcy'),
            NULL
        )
    );
END;
/
--KATEGORIE
BEGIN
    INSERT INTO Kategorie_tab VALUES (
        Kategorie_typ(
            1,
            'Rodzinne wakacje',
            'Idealne dla rodzin z dzie�mi, oferuj�ce wiele atrakcji dla najm�odszych.',
            1, -- All-inclusive
            1, -- Wakacje z dzie�mi
            0  -- Last minute
        )
    );

    INSERT INTO Kategorie_tab VALUES (
        Kategorie_typ(
            2,
            'Romantyczne wyjazdy',
            'Pakiety dla par, obejmuj�ce romantyczne kolacje i atrakcje.',
            1,
            0,
            0
        )
    );

    INSERT INTO Kategorie_tab VALUES (
        Kategorie_typ(
            3,
            'Wakacje last minute',
            'Oferty last minute w atrakcyjnych cenach.',
            0,
            0,
            1
        )
    );

    INSERT INTO Kategorie_tab VALUES (
        Kategorie_typ(
            4,
            'Ekskluzywne wakacje',
            'Pakiety premium w luksusowych hotelach.',
            1,
            0,
            0
        )
    );

    INSERT INTO Kategorie_tab VALUES (
        Kategorie_typ(
            5,
            'Przygoda i aktywno��',
            'Pakiety dla mi�o�nik�w sportu i aktywno�ci na �wie�ym powietrzu.',
            0,
            0,
            0
        )
    );
END;
/
--OFERTY
-- Oferta 1: Rodzinne wakacje w Barcelonie
INSERT INTO OfertyWakacyjne_tab VALUES (
    OfertyWakacyjne_typ(
        1, -- packID
        (SELECT REF(k) FROM Kategorie_tab k WHERE k.catId = 1), -- ref_cat
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 4), -- ref_hotel
        TO_DATE('2024-06-01', 'YYYY-MM-DD'), -- startDate
        TO_DATE('2024-06-14', 'YYYY-MM-DD'), -- endDate
        3999.99, -- price
        'Wakacje all inclusive w Rio', -- opis_pakietu
        1, -- avalibitystatus
        14, -- duration
        ListaAtrakcje_typ( -- atrakcje
            Atrakcja_typ(1, 'Wycieczka po mie�cie', 'Zwiedzanie g��wnych atrakcji miasta.'),
            Atrakcja_typ(2, 'Rejs statkiem', 'Romantyczny rejs po rzece.'),
            Atrakcja_typ(3, 'Lekcja samby', 'Nauka ta�ca samby.')
        )
    )
);

-- Oferta 2: Romantyczny wyjazd do Londynu
INSERT INTO OfertyWakacyjne_tab VALUES (
    OfertyWakacyjne_typ(
        2, -- packID
        (SELECT REF(k) FROM Kategorie_tab k WHERE k.catId = 2), -- ref_cat
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 2), -- ref_hotel
        TO_DATE('2024-07-15', 'YYYY-MM-DD'), -- startDate
        TO_DATE('2024-07-22', 'YYYY-MM-DD'), -- endDate
        2900.00, -- price
        'Romantyczny wyjazd do Londynu z atrakcjami dla par.', -- opis_pakietu
        1, -- avalibitystatus
        7, -- duration
        ListaAtrakcje_typ( -- atrakcje
            Atrakcja_typ(4, 'Spacer wzd�u� Tamizy', 'Ciesz si� pi�knymi widokami Londynu.'),
            Atrakcja_typ(5, 'Zwiedzanie Pa�acu Buckingham', 'Odkryj histori� rodziny kr�lewskiej.'),
            Atrakcja_typ(6, 'Kolacja w The Shard', 'Romantyczna kolacja z widokiem na miasto.')
        )
    )
);

-- Oferta 3: Nowy Jork - Miasto, kt�re nigdy nie �pi
INSERT INTO OfertyWakacyjne_tab VALUES (
    OfertyWakacyjne_typ(
        3, -- packID
        (SELECT REF(k) FROM Kategorie_tab k WHERE k.catId = 5), -- ref_cat
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 3), -- ref_hotel
        TO_DATE('2024-05-01', 'YYYY-MM-DD'), -- startDate
        TO_DATE('2024-05-08', 'YYYY-MM-DD'), -- endDate
        4000.00, -- price
        'Wakacje w Nowym Jorku pe�ne aktywno�ci i przyg�d.', -- opis_pakietu
        1, -- avalibitystatus
        7, -- duration
        ListaAtrakcje_typ( -- atrakcje
            Atrakcja_typ(7, 'Zwiedzanie Central Parku', 'Odpoczynek i przygoda w Central Parku.'),
            Atrakcja_typ(8, 'Rejs wok� Manhattanu', 'Zobacz panoram� Nowego Jorku z wody.'),
            Atrakcja_typ(9, 'Broadway Show', 'Zanurz si� w magii Broadwayu.')
        )
    )
);

-- Oferta 4: Barcelona - S�oneczna Katalonia
INSERT INTO OfertyWakacyjne_tab VALUES (
    OfertyWakacyjne_typ(
        4, -- packID
        (SELECT REF(k) FROM Kategorie_tab k WHERE k.catId = 1), -- ref_cat
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 4), -- ref_hotel
        TO_DATE('2024-08-10', 'YYYY-MM-DD'), -- startDate
        TO_DATE('2024-08-20', 'YYYY-MM-DD'), -- endDate
        2800.00, -- price
        'Rodzinne wakacje w Barcelonie z atrakcjami dla dzieci.', -- opis_pakietu
        1, -- avalibitystatus
        10, -- duration
        ListaAtrakcje_typ( -- atrakcje
            Atrakcja_typ(10, 'Sagrada Familia', 'Odwied� jedn� z najbardziej znanych katedr na �wiecie.'),
            Atrakcja_typ(11, 'Pla�e Barcelony', 'Relaks i zabawa na pla�ach Barcelony.'),
            Atrakcja_typ(12, 'Park Guell', 'Odkryj niesamowite dzie�a Gaudiego.')
        )
    )
);

-- Oferta 5: Berlin - Miasto historii
INSERT INTO OfertyWakacyjne_tab VALUES (
    OfertyWakacyjne_typ(
        5, -- packID
        (SELECT REF(k) FROM Kategorie_tab k WHERE k.catId = 3), -- ref_cat
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 5), -- ref_hotel
        TO_DATE('2024-09-01', 'YYYY-MM-DD'), -- startDate
        TO_DATE('2024-09-07', 'YYYY-MM-DD'), -- endDate
        2200.00, -- price
        'Odkryj histori� Berlina podczas tej wyj�tkowej wycieczki.', -- opis_pakietu
        1, -- avalibitystatus
        6, -- duration
        ListaAtrakcje_typ( -- atrakcje
            Atrakcja_typ(13, 'Brama Brandenburska', 'Odwied� jedn� z najbardziej znanych ikon Berlina.'),
            Atrakcja_typ(14, 'Zwiedzanie Muru Berli�skiego', 'Poznaj histori� podzielonego miasta.'),
            Atrakcja_typ(15, 'Wycieczka do Reichstagu', 'Odkryj serce niemieckiej polityki.')
        )
    )
);
--PROMOCJE
-- Promocja 1: Summer Special
INSERT INTO Promocje_tab VALUES (
    Promotions_typ(
        1, -- promoId
        (SELECT REF(o) FROM OfertyWakacyjne_tab o WHERE o.packID = 1), -- ref_package
        'Summer Special', -- promoName
        'Discount on summer packages', -- promoDesc
        10, -- discount in %
        TO_DATE('2024-06-01', 'YYYY-MM-DD'), -- startDate
        TO_DATE('2024-06-30', 'YYYY-MM-DD')  -- endDate
    )
);

-- Promocja 2: Early Booking Discount
INSERT INTO Promocje_tab VALUES (
    Promotions_typ(
        2, -- promoId
        (SELECT REF(o) FROM OfertyWakacyjne_tab o WHERE o.packID = 3), -- ref_package
        'Early Booking Discount', -- promoName
        'Save 15% when booking early', -- promoDesc
        15, -- discount in %
        TO_DATE('2024-04-01', 'YYYY-MM-DD'), -- startDate
        TO_DATE('2024-04-30', 'YYYY-MM-DD')  -- endDate
    )
);
--REZERWACJE
-- Rezerwacja 1: Rezerwacja u�ytkownika 1 na ofert� 2
INSERT INTO Rezerwacje_tab VALUES (
    Rezerwacja_typ(
        1, -- rezerwacja_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 1), -- ref_uzytkownik
        (SELECT REF(o) FROM OfertyWakacyjne_tab o WHERE o.packID = 2), -- ref_oferta
        TO_DATE('2024-04-15', 'YYYY-MM-DD') -- data_rezerwacji
    )
);

-- Rezerwacja 2: Rezerwacja u�ytkownika 3 na ofert� 1
INSERT INTO Rezerwacje_tab VALUES (
    Rezerwacja_typ(
        2, -- rezerwacja_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 3), -- ref_uzytkownik
        (SELECT REF(o) FROM OfertyWakacyjne_tab o WHERE o.packID = 1), -- ref_oferta
        TO_DATE('2024-05-20', 'YYYY-MM-DD') -- data_rezerwacji
    )
);

-- Rezerwacja 3: Rezerwacja u�ytkownika 5 na ofert� 5
INSERT INTO Rezerwacje_tab VALUES (
    Rezerwacja_typ(
        3, -- rezerwacja_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 5), -- ref_uzytkownik
        (SELECT REF(o) FROM OfertyWakacyjne_tab o WHERE o.packID = 5), -- ref_oferta
        TO_DATE('2024-06-10', 'YYYY-MM-DD') -- data_rezerwacji
    )
);

-- Rezerwacja 4: Rezerwacja u�ytkownika 2 na ofert� 3
INSERT INTO Rezerwacje_tab VALUES (
    Rezerwacja_typ(
        4, -- rezerwacja_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 2), -- ref_uzytkownik
        (SELECT REF(o) FROM OfertyWakacyjne_tab o WHERE o.packID = 3), -- ref_oferta
        TO_DATE('2024-03-25', 'YYYY-MM-DD') -- data_rezerwacji
    )
);

-- Rezerwacja 5: Rezerwacja u�ytkownika 7 na ofert� 4
INSERT INTO Rezerwacje_tab VALUES (
    Rezerwacja_typ(
        5, -- rezerwacja_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 7), -- ref_uzytkownik
        (SELECT REF(o) FROM OfertyWakacyjne_tab o WHERE o.packID = 4), -- ref_oferta
        TO_DATE('2024-07-05', 'YYYY-MM-DD') -- data_rezerwacji
    )
);
--OCENY
-- Dodanie kilku ocen do tabeli OcenyHoteli_tab

-- Ocena 1: U�ytkownik 1 dla hotelu 2
INSERT INTO OcenyHoteli_tab VALUES (
    OcenaHoteli_typ(
        1, -- ocena_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 1), -- ref_uzytkownik
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 2), -- ref_hotel
        Ocena_typ(
            9, -- wartosc
            'Bardzo komfortowy hotel z doskona�� obs�ug�.', -- komentarz
            TO_DATE('2024-07-20', 'YYYY-MM-DD') -- data oceny
        )
    )
);

-- Ocena 2: U�ytkownik 4 dla hotelu 1
INSERT INTO OcenyHoteli_tab VALUES (
    OcenaHoteli_typ(
        2, -- ocena_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 4), -- ref_uzytkownik
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 1), -- ref_hotel
        Ocena_typ(
            8, -- wartosc
            'Hotel ma �wietne po�o�enie, ale pokoje mog�yby by� wi�ksze.', -- komentarz
            TO_DATE('2024-06-15', 'YYYY-MM-DD') -- data oceny
        )
    )
);

-- Ocena 3: U�ytkownik 2 dla hotelu 5
INSERT INTO OcenyHoteli_tab VALUES (
    OcenaHoteli_typ(
        3, -- ocena_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 2), -- ref_uzytkownik
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 5), -- ref_hotel
        Ocena_typ(
            10, -- wartosc
            'Najlepszy hotel, w kt�rym kiedykolwiek by�em! Wszystko na najwy�szym poziomie.', -- komentarz
            TO_DATE('2024-05-10', 'YYYY-MM-DD') -- data oceny
        )
    )
);

-- Ocena 4: U�ytkownik 6 dla hotelu 3
INSERT INTO OcenyHoteli_tab VALUES (
    OcenaHoteli_typ(
        4, -- ocena_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 6), -- ref_uzytkownik
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 3), -- ref_hotel
        Ocena_typ(
            7, -- wartosc
            'Przyjazny personel, ale restauracja by�a nieco g�o�na.', -- komentarz
            TO_DATE('2024-08-05', 'YYYY-MM-DD') -- data oceny
        )
    )
);

-- Ocena 5: U�ytkownik 9 dla hotelu 4
INSERT INTO OcenyHoteli_tab VALUES (
    OcenaHoteli_typ(
        5, -- ocena_id
        (SELECT REF(u) FROM Uzytkownicy_tab u WHERE u.uzytkownik_id = 9), -- ref_uzytkownik
        (SELECT REF(h) FROM Hotele_tab h WHERE h.hotelID = 4), -- ref_hotel
        Ocena_typ(
            6, -- wartosc
            'Hotel oferuje �wietne udogodnienia, ale basen by� zamkni�ty podczas mojego pobytu.', -- komentarz
            TO_DATE('2024-09-12', 'YYYY-MM-DD') -- data oceny
        )
    )
);