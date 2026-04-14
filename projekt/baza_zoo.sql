--   BAZA DANYCH: ZOO

DROP DATABASE IF EXISTS baza_zoo;
CREATE DATABASE baza_zoo CHARACTER SET utf8mb4 COLLATE utf8mb4_polish_ci;
USE baza_zoo;


-- TABELA 1: gatunki

CREATE TABLE gatunki (
    id_gatunku      INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_gatunku   VARCHAR(80)  NOT NULL,
    nazwa_lacinska  VARCHAR(100),
    rodzina         VARCHAR(60),
    typ_diety       ENUM('roslinozerca', 'miesnozerca', 'wszystkozerca') NOT NULL,
    kraj_pochodzenia VARCHAR(60),
    status_ochrony  ENUM('LC', 'NT', 'VU', 'EN', 'CR', 'EW', 'EX') DEFAULT 'LC'
    -- LC=least concern, NT=near threatened, VU=vulnerable,
    -- EN=endangered, CR=critically endangered, EW=extinct in wild, EX=extinct
);


-- TABELA 2: strefy

CREATE TABLE strefy (
    id_strefy   INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_strefy VARCHAR(60) NOT NULL,
    kontynent   VARCHAR(40),
    opis        TEXT
);


-- TABELA 3: klatki (wybiegi / woliery / akwaria)

CREATE TABLE klatki (
    id_klatki       INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_klatki    VARCHAR(80) NOT NULL,
    id_strefy       INT,
    typ_klatki      ENUM('wybieg_zewnetrzny','woliera','akwarium','terrarium','wybieg_wewnetrzny') NOT NULL,
    powierzchnia_m2 DECIMAL(8,2),
    max_pojemnosc   INT,
    CONSTRAINT fk_klatki_strefy
        FOREIGN KEY (id_strefy) REFERENCES strefy(id_strefy)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- TABELA 4: pracownicy

CREATE TABLE pracownicy (
    id_pracownika   INT AUTO_INCREMENT PRIMARY KEY,
    imie            VARCHAR(45) NOT NULL,
    nazwisko        VARCHAR(45) NOT NULL,
    stanowisko      ENUM('opiekun','weterynarz','przewodnik','kasjer','administrator','dyrektor') NOT NULL,
    telefon         VARCHAR(14),
    email           VARCHAR(60),
    data_zatrudnienia DATE,
    szef_id         INT,
    CONSTRAINT fk_pracownicy_szef
        FOREIGN KEY (szef_id) REFERENCES pracownicy(id_pracownika)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- TABELA 5: zwierzeta

CREATE TABLE zwierzeta (
    id_zwierzecia   INT AUTO_INCREMENT PRIMARY KEY,
    imie            VARCHAR(60),
    id_gatunku      INT NOT NULL,
    id_klatki       INT,
    id_opiekuna     INT,
    plec            ENUM('M','F','nieznana') DEFAULT 'nieznana',
    data_urodzenia  DATE,
    data_przybycia  DATE NOT NULL,
    waga_kg         DECIMAL(7,2),
    status          ENUM('aktywne','przeniesione','wypozyczone','umarle') DEFAULT 'aktywne',
    CONSTRAINT fk_zwierzeta_gatunek
        FOREIGN KEY (id_gatunku) REFERENCES gatunki(id_gatunku)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_zwierzeta_klatka
        FOREIGN KEY (id_klatki) REFERENCES klatki(id_klatki)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_zwierzeta_opiekun
        FOREIGN KEY (id_opiekuna) REFERENCES pracownicy(id_pracownika)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- TABELA 6: rodzaje_biletow

CREATE TABLE rodzaje_biletow (
    id_rodzaju      INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_rodzaju   VARCHAR(60) NOT NULL,
    cena_bazowa     DECIMAL(8,2) NOT NULL,
    opis            VARCHAR(200),
    wiek_min        INT DEFAULT 0,   -- minimalni wiek (lata)
    wiek_max        INT DEFAULT 120  -- maksymalny wiek (lata)
);


-- TABELA 7: bilety

CREATE TABLE bilety (
    id_biletu           INT AUTO_INCREMENT PRIMARY KEY,
    id_rodzaju          INT NOT NULL,
    id_pracownika         INT,
    data_zakupu         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_wizyty         DATE NOT NULL,
    ilosc_biletow       INT NOT NULL DEFAULT 1,
    cena_laczna         DECIMAL(10,2) NOT NULL,
    metoda_platnosci    ENUM('gotowka','karta','online','blik') DEFAULT 'gotowka',
    CONSTRAINT fk_bilety_rodzaj
        FOREIGN KEY (id_rodzaju) REFERENCES rodzaje_biletow(id_rodzaju)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bilety_kasjer
        FOREIGN KEY (id_pracownika) REFERENCES pracownicy(id_pracownika)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- TABELA 8: atrakcje_dodatkowe

CREATE TABLE atrakcje_dodatkowe (
    id_atrakcji         INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_atrakcji      VARCHAR(100) NOT NULL,
    opis                TEXT,
    cena_za_osobe       DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    czas_trwania_min    INT,
    max_uczestnikow     INT,
    id_strefy           INT,
    aktywna             TINYINT(1) DEFAULT 1,
    CONSTRAINT fk_atrakcje_strefa
        FOREIGN KEY (id_strefy) REFERENCES strefy(id_strefy)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- TABELA 9: rezerwacje_atrakcji  (łączy bilety z atrakcjami)

CREATE TABLE rezerwacje_atrakcji (
    id_rezerwacji       INT AUTO_INCREMENT PRIMARY KEY,
    id_biletu           INT NOT NULL,
    id_atrakcji         INT NOT NULL,
    ilosc_osob          INT NOT NULL DEFAULT 1,
    godzina_atrakcji    TIME,
    CONSTRAINT fk_rez_bilet
        FOREIGN KEY (id_biletu) REFERENCES bilety(id_biletu)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rez_atrakcja
        FOREIGN KEY (id_atrakcji) REFERENCES atrakcje_dodatkowe(id_atrakcji)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


-- TABELA 10: karmienie

CREATE TABLE karmienie (
    id_karmienia    INT AUTO_INCREMENT PRIMARY KEY,
    id_zwierzecia   INT NOT NULL,
    id_pracownika   INT NOT NULL,
    data_karmienia  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pora_dnia       ENUM('rano','poludnie','wieczor') NOT NULL,
    rodzaj_pokarmu  VARCHAR(100) NOT NULL,
    ilosc_kg        DECIMAL(6,3) NOT NULL,
    uwagi           VARCHAR(200),
    CONSTRAINT fk_karmienie_zwierze
        FOREIGN KEY (id_zwierzecia) REFERENCES zwierzeta(id_zwierzecia)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_karmienie_pracownik
        FOREIGN KEY (id_pracownika) REFERENCES pracownicy(id_pracownika)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


-- TABELA 11: wizyty_weterynaryjne

CREATE TABLE wizyty_weterynaryjne (
    id_wizyty       INT AUTO_INCREMENT PRIMARY KEY,
    id_zwierzecia   INT NOT NULL,
    id_weterynarza  INT NOT NULL,
    data_wizyty     DATE NOT NULL,
    powod_wizyty    VARCHAR(200) NOT NULL,
    diagnoza        TEXT,
    zalecenia       TEXT,
    nastepna_wizyta DATE,
    CONSTRAINT fk_wizyta_zwierze
        FOREIGN KEY (id_zwierzecia) REFERENCES zwierzeta(id_zwierzecia)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_wizyta_weterynarz
        FOREIGN KEY (id_weterynarza) REFERENCES pracownicy(id_pracownika)
        ON DELETE RESTRICT ON UPDATE CASCADE
);



--   DANE


-- gatunki 
INSERT INTO gatunki (nazwa_gatunku, nazwa_lacinska, rodzina, typ_diety, kraj_pochodzenia, status_ochrony) VALUES
('Lew afrykański',       'Panthera leo',           'Felidae',      'miesnozerca',   'Kenia',          'VU'),
('Słoń afrykański',      'Loxodonta africana',     'Elephantidae', 'roslinozerca',  'Tanzania',       'EN'),
('Żyrafa',               'Giraffa camelopardalis', 'Giraffidae',   'roslinozerca',  'Kenia',          'VU'),
('Goryl nizinny',        'Gorilla gorilla',         'Hominidae',    'roslinozerca',  'Kamerun',        'CR'),
('Szympans',             'Pan troglodytes',         'Hominidae',    'wszystkozerca', 'Uganda',         'EN'),
('Tygrys bengalski',     'Panthera tigris tigris',  'Felidae',      'miesnozerca',   'Indie',          'EN'),
('Niedźwiedź polarny',   'Ursus maritimus',         'Ursidae',      'miesnozerca',   'Kanada',         'VU'),
('Pingwin przylądkowy',  'Spheniscus demersus',     'Spheniscidae', 'miesnozerca',   'RPA',            'EN'),
('Foka szara',           'Halichoerus grypus',      'Phocidae',     'miesnozerca',   'Wielka Brytania','LC'),
('Zebra Burchella',      'Equus quagga burchellii', 'Equidae',      'roslinozerca',  'Botswana',       'NT'),
('Gepard',               'Acinonyx jubatus',        'Felidae',      'miesnozerca',   'Tanzania',       'VU'),
('Hipopotam',            'Hippopotamus amphibius',  'Hippopotamidae','roslinozerca',  'Nigeria',        'VU'),
('Krokodyl nilowy',      'Crocodylus niloticus',    'Crocodylidae', 'miesnozerca',   'Egipt',          'LC'),
('Wąż boa dusiciel',     'Boa constrictor',         'Boidae',       'miesnozerca',   'Kolumbia',       'LC'),
('Lemur katta',          'Lemur catta',             'Lemuridae',    'wszystkozerca', 'Madagaskar',     'EN'),
('Flaming różowy',       'Phoenicopterus roseus',   'Phoenicopteridae','roslinozerca','Namibia',        'LC'),
('Żółw olbrzymi',        'Aldabrachelys gigantea',  'Testudinidae', 'roslinozerca',  'Seszele',        'VU'),
('Orangutan bornejski',  'Pongo pygmaeus',           'Hominidae',    'wszystkozerca', 'Indonezja',      'CR'),
('Ryś eurazjatycki',     'Lynx lynx',               'Felidae',      'miesnozerca',   'Polska',         'LC'),
('Wilk szary',           'Canis lupus',             'Canidae',      'miesnozerca',   'Polska',         'LC');


-- strefy 
INSERT INTO strefy (nazwa_strefy, kontynent, opis) VALUES
('Sawanna Afrykańska',  'Afryka',     'Wybieg z roślinnością sabanową, lwy, żyrafy, zebry'),
('Dżungla Równikowa',   'Afryka',     'Naczelne: goryle, szympansy, lemury'),
('Azja Tropikalna',     'Azja',       'Tygrysy bengalskie, orangutany, węże'),
('Arktyka',             'Arktyka',    'Niedźwiedzie polarne, foki, pingwiny'),
('Mokradła i Rzeki',    'Afryka',     'Hipopotamy, krokodyle, flamingi'),
('Europa Leśna',        'Europa',     'Rysie, wilki, żbiki'),
('Terrarium',           'Różne',      'Gady i płazy z całego świata'),
('Oceanarium',          'Różne',      'Akwarium morskie, foki, ryby tropikalne');


-- klatki 
INSERT INTO klatki (nazwa_klatki, id_strefy, typ_klatki, powierzchnia_m2, max_pojemnosc) VALUES
('Wybieg Lwów',            1, 'wybieg_zewnetrzny', 2500.00, 8),
('Wybieg Słoni',           1, 'wybieg_zewnetrzny', 5000.00, 5),
('Wybieg Żyraf',           1, 'wybieg_zewnetrzny', 3200.00, 6),
('Wyspa Goryli',           2, 'wybieg_zewnetrzny', 1800.00, 12),
('Woliera Szympansów',     2, 'woliera',            1200.00, 10),
('Wybieg Tygrysów',        3, 'wybieg_zewnetrzny', 2000.00, 4),
('Grota Niedźwiedzi',      4, 'wybieg_zewnetrzny', 3000.00, 3),
('Basen Pingwinów',        4, 'akwarium',            800.00, 20),
('Basen Fok',              8, 'akwarium',           1200.00, 8),
('Wybieg Zebr',            1, 'wybieg_zewnetrzny', 4000.00, 15),
('Wybieg Gepardów',        1, 'wybieg_zewnetrzny', 2200.00, 4),
('Staw Hipopotamów',       5, 'wybieg_zewnetrzny', 2800.00, 4),
('Terrarium Krokodyli',    7, 'terrarium',           600.00, 6),
('Terrarium Węży',         7, 'terrarium',           200.00, 10),
('Wyspa Lemurów',          2, 'wybieg_zewnetrzny',  900.00, 20),
('Laguna Flamingów',       5, 'wybieg_zewnetrzny', 1500.00, 30),
('Terrarium Żółwi',        7, 'terrarium',           400.00, 8),
('Wybieg Orangutanów',     3, 'woliera',            1400.00, 6),
('Wybieg Rysi',            6, 'wybieg_zewnetrzny', 1600.00, 4),
('Wybieg Wilków',          6, 'wybieg_zewnetrzny', 2200.00, 10);


-- pracownicy 
INSERT INTO pracownicy (imie, nazwisko, stanowisko, telefon, email, data_zatrudnienia, szef_id) VALUES
('Marek',     'Zielinski',  'dyrektor',      '500-100-200', 'dyrektor@zoo.pl',          '2010-03-01', NULL),
('Anna',      'Kowalska',   'administrator', '500-100-201', 'admin@zoo.pl',             '2012-06-15', 1),
('Piotr',     'Nowak',      'weterynarz',    '500-100-202', 'wet.nowak@zoo.pl',         '2015-09-01', 1),
('Katarzyna', 'Wiśniewska', 'weterynarz',    '500-100-203', 'wet.wisniewska@zoo.pl',    '2018-01-10', 3),
('Tomasz',    'Kowalczyk',  'opiekun',       '500-100-204', 'op.kowalczyk@zoo.pl',      '2016-04-20', 2),
('Maria',     'Kamińska',   'opiekun',       '500-100-205', 'op.kaminska@zoo.pl',       '2017-07-05', 2),
('Jakub',     'Lewandowski','opiekun',       '500-100-206', 'op.lewandowski@zoo.pl',    '2019-03-12', 2),
('Aleksandra','Wojcik',     'opiekun',       '500-100-207', 'op.wojcik@zoo.pl',         '2020-08-01', 2),
('Michał',    'Kaczmarek',  'opiekun',       '500-100-208', 'op.kaczmarek@zoo.pl',      '2021-01-15', 2),
('Natalia',   'Zając',      'przewodnik',    '500-100-209', 'prz.zajac@zoo.pl',         '2018-06-01', 2),
('Bartosz',   'Szymański',  'przewodnik',    '500-100-210', 'prz.szymanski@zoo.pl',     '2019-09-01', 2),
('Ewa',       'Woźniak',    'kasjer',        '500-100-211', 'kas.wozniak@zoo.pl',       '2020-02-01', 2),
('Rafał',     'Dąbrowski',  'kasjer',        '500-100-212', 'kas.dabrowski@zoo.pl',     '2021-06-01', 2),
('Monika',    'Kozłowska',  'opiekun',       '500-100-213', 'op.kozlowska@zoo.pl',      '2022-01-10', 2),
('Krzysztof', 'Jankowski',  'opiekun',       '500-100-214', 'op.jankowski@zoo.pl',      '2022-09-05', 2);


-- zwierzeta 
INSERT INTO zwierzeta (imie, id_gatunku, id_klatki, id_opiekuna, plec, data_urodzenia, data_przybycia, waga_kg, status) VALUES
('Simba',      1,  1,  5,  'M', '2018-05-12', '2019-03-01', 190.00, 'aktywne'),
('Nala',       1,  1,  5,  'F', '2019-08-20', '2020-01-15', 140.00, 'aktywne'),
('Tembo',      2,  2,  5,  'M', '2010-02-14', '2011-06-01', 5200.00,'aktywne'),
('Weza',       2,  2,  5,  'F', '2012-11-30', '2013-02-10', 4800.00,'aktywne'),
('Twiga',      3,  3,  6,  'M', '2016-07-04', '2017-04-20', 1100.00,'aktywne'),
('Doti',       3,  3,  6,  'F', '2017-09-11', '2018-05-05', 900.00, 'aktywne'),
('Bongo',      4,  4,  7,  'M', '2009-03-15', '2010-01-20', 185.00, 'aktywne'),
('Kesi',       4,  4,  7,  'F', '2011-06-22', '2012-03-10', 92.00,  'aktywne'),
('Charlie',    5,  5,  7,  'M', '2015-10-08', '2016-07-01', 55.00,  'aktywne'),
('Lucy',       5,  5,  7,  'F', '2016-12-01', '2017-08-15', 48.00,  'aktywne'),
('Rajan',      6,  6,  8,  'M', '2013-04-18', '2014-02-28', 220.00, 'aktywne'),
('Maya',       6,  6,  8,  'F', '2015-08-30', '2016-05-10', 175.00, 'aktywne'),
('Lars',       7,  7,  9,  'M', '2017-01-09', '2018-09-01', 490.00, 'aktywne'),
('Freya',      7,  7,  9,  'F', '2018-03-22', '2019-06-15', 260.00, 'aktywne'),
('Pedro',      8,  8,  9,  'M', '2020-06-14', '2021-01-10', 3.50,   'aktywne'),
('Rosa',       8,  8,  9,  'F', '2020-09-05', '2021-01-10', 3.20,   'aktywne'),
('Baltyk',     9,  9,  9,  'M', '2019-02-28', '2020-04-05', 185.00, 'aktywne'),
('Morska',     9,  9,  9,  'F', '2018-11-14', '2020-04-05', 150.00, 'aktywne'),
('Zebek',     10, 10,  5,  'M', '2019-07-03', '2020-02-20', 340.00, 'aktywne'),
('Paskuda',   10, 10,  5,  'F', '2020-01-17', '2020-09-01', 310.00, 'aktywne'),
('Flash',     11, 11,  6,  'M', '2021-03-25', '2022-01-10', 62.00,  'aktywne'),
('Lara',      11, 11,  6,  'F', '2022-05-08', '2023-02-01', 54.00,  'aktywne'),
('Rzeka',     12, 12, 14,  'M', '2012-08-16', '2013-07-01', 1650.00,'aktywne'),
('Nil',       13, 13, 14,  'M', '2015-04-04', '2016-03-01', 480.00, 'aktywne'),
('Baza',      14, 14, 14,  'F', '2018-09-12', '2019-08-01', 12.50,  'aktywne'),
('Kiko',      15, 15,  6,  'M', '2020-11-20', '2021-06-15', 2.80,   'aktywne'),
('Mila',      15, 15,  6,  'F', '2021-02-14', '2021-06-15', 2.50,   'aktywne'),
('Różek',     16, 16, 15,  'M', '2019-05-01', '2020-03-10', 2.80,   'aktywne'),
('Shell',     17, 17, 15,  'M', '1985-01-01', '2005-06-01', 185.00, 'aktywne'),
('Borno',     18, 18,  8,  'M', '2014-07-19', '2015-05-20', 75.00,  'aktywne'),
('Sutra',     18, 18,  8,  'F', '2016-10-03', '2017-09-01', 68.00,  'aktywne'),
('Borys',     19, 19, 15,  'M', '2019-12-01', '2021-03-15', 30.00,  'aktywne'),
('Lyra',      19, 19, 15,  'F', '2020-08-15', '2021-03-15', 22.00,  'aktywne'),
('Alfa',      20, 20, 15,  'M', '2018-04-22', '2019-07-10', 55.00,  'aktywne'),
('Luna',      20, 20, 15,  'F', '2019-06-30', '2019-07-10', 48.00,  'aktywne');


-- rodzaje_biletow 
INSERT INTO rodzaje_biletow (nazwa_rodzaju, cena_bazowa, opis, wiek_min, wiek_max) VALUES
('Normalny',        35.00, 'Bilet normalny dla dorosłych',                       18, 64),
('Ulgowy dziecięcy', 20.00, 'Dla dzieci od 3 do 12 lat',                          3, 12),
('Ulgowy młodzieżowy',25.00,'Dla młodzieży 13-17 lat oraz studentów',            13, 25),
('Ulgowy seniorski', 22.00, 'Dla osób powyżej 65. roku życia',                   65,120),
('Rodzinny 2+2',    110.00,'2 osoby dorosłe + 2 dzieci do 12 lat',               0,120),
('Rodzinny 2+3',    130.00,'2 osoby dorosłe + 3 dzieci do 12 lat',               0,120),
('Grupowy (min 15)',  20.00,'Bilet grupowy, min. 15 osób',                        0,120),
('Bezpłatny',         0.00,'Dzieci poniżej 3 lat wchodzą bezpłatnie',             0,  2),
('Karnet roczny',   180.00,'Nielimitowane wejścia przez 12 miesięcy',             0,120);


-- bilety (70 rekordów) 
INSERT INTO bilety (id_rodzaju, id_kasjera, data_zakupu, data_wizyty, ilosc_biletow, cena_laczna, metoda_platnosci) VALUES
(1,12,'2024-06-01 09:10:00','2024-06-01',2,  70.00,'karta'),
(2,12,'2024-06-01 09:15:00','2024-06-01',3,  60.00,'gotowka'),
(5,13,'2024-06-01 09:20:00','2024-06-01',1, 110.00,'blik'),
(1,12,'2024-06-01 09:45:00','2024-06-01',1,  35.00,'karta'),
(3,13,'2024-06-01 10:00:00','2024-06-01',2,  50.00,'online'),
(7,12,'2024-06-02 08:30:00','2024-06-02',20, 400.00,'przelew' ),
(1,13,'2024-06-02 09:00:00','2024-06-02',3, 105.00,'karta'),
(2,12,'2024-06-02 09:30:00','2024-06-02',2,  40.00,'gotowka'),
(6,13,'2024-06-02 10:00:00','2024-06-02',1, 130.00,'blik'),
(4,12,'2024-06-02 10:15:00','2024-06-02',2,  44.00,'karta'),
(1,12,'2024-06-03 09:00:00','2024-06-03',4, 140.00,'online'),
(5,13,'2024-06-03 09:30:00','2024-06-03',2, 220.00,'karta'),
(2,12,'2024-06-03 10:00:00','2024-06-03',4,  80.00,'gotowka'),
(3,13,'2024-06-03 10:30:00','2024-06-03',3,  75.00,'blik'),
(9,12,'2024-06-03 11:00:00','2024-06-03',1, 180.00,'karta'),
(1,13,'2024-06-04 09:00:00','2024-06-04',2,  70.00,'gotowka'),
(2,12,'2024-06-04 09:20:00','2024-06-04',3,  60.00,'karta'),
(7,13,'2024-06-04 09:40:00','2024-06-04',30, 600.00,'przelew'),
(4,12,'2024-06-04 10:00:00','2024-06-04',1,  22.00,'blik'),
(6,13,'2024-06-04 10:30:00','2024-06-04',2, 260.00,'karta'),
(1,12,'2024-06-05 09:00:00','2024-06-05',5, 175.00,'online'),
(3,13,'2024-06-05 09:30:00','2024-06-05',2,  50.00,'karta'),
(2,12,'2024-06-05 10:00:00','2024-06-05',5, 100.00,'gotowka'),
(5,13,'2024-06-05 10:30:00','2024-06-05',3, 330.00,'blik'),
(1,12,'2024-06-06 09:00:00','2024-06-06',2,  70.00,'karta'),
(4,13,'2024-06-06 09:30:00','2024-06-06',3,  66.00,'gotowka'),
(7,12,'2024-06-06 10:00:00','2024-06-06',25, 500.00,'przelew'),
(2,13,'2024-06-06 10:30:00','2024-06-06',4,  80.00,'karta'),
(9,12,'2024-06-06 11:00:00','2024-06-06',2, 360.00,'online'),
(1,13,'2024-06-07 09:00:00','2024-06-07',3, 105.00,'karta'),
(6,12,'2024-06-07 09:30:00','2024-06-07',1, 130.00,'blik'),
(2,13,'2024-06-07 10:00:00','2024-06-07',2,  40.00,'gotowka'),
(3,12,'2024-06-07 10:30:00','2024-06-07',4, 100.00,'karta'),
(1,13,'2024-06-08 09:00:00','2024-06-08',2,  70.00,'online'),
(5,12,'2024-06-08 09:30:00','2024-06-08',2, 220.00,'karta'),
(4,13,'2024-06-08 10:00:00','2024-06-08',2,  44.00,'blik'),
(7,12,'2024-06-08 10:30:00','2024-06-08',18, 360.00,'przelew'),
(2,13,'2024-06-08 11:00:00','2024-06-08',3,  60.00,'gotowka'),
(1,12,'2024-06-09 09:00:00','2024-06-09',1,  35.00,'karta'),
(9,13,'2024-06-09 09:30:00','2024-06-09',1, 180.00,'online'),
(6,12,'2024-06-09 10:00:00','2024-06-09',2, 260.00,'blik'),
(1,13,'2024-06-10 09:00:00','2024-06-10',4, 140.00,'karta'),
(2,12,'2024-06-10 09:30:00','2024-06-10',6, 120.00,'gotowka'),
(3,13,'2024-06-10 10:00:00','2024-06-10',2,  50.00,'karta'),
(5,12,'2024-06-10 10:30:00','2024-06-10',1, 110.00,'blik'),
(4,13,'2024-06-11 09:00:00','2024-06-11',4,  88.00,'karta'),
(1,12,'2024-06-11 09:30:00','2024-06-11',3, 105.00,'online'),
(7,13,'2024-06-11 10:00:00','2024-06-11',22, 440.00,'przelew'),
(2,12,'2024-06-11 10:30:00','2024-06-11',5, 100.00,'gotowka'),
(6,13,'2024-06-12 09:00:00','2024-06-12',1, 130.00,'karta'),
(1,12,'2024-06-12 09:30:00','2024-06-12',2,  70.00,'blik'),
(9,13,'2024-06-12 10:00:00','2024-06-12',1, 180.00,'online'),
(3,12,'2024-06-12 10:30:00','2024-06-12',3,  75.00,'karta'),
(5,13,'2024-06-13 09:00:00','2024-06-13',2, 220.00,'gotowka'),
(1,12,'2024-06-13 09:30:00','2024-06-13',5, 175.00,'karta'),
(2,13,'2024-06-13 10:00:00','2024-06-13',4,  80.00,'blik'),
(4,12,'2024-06-13 10:30:00','2024-06-13',2,  44.00,'karta'),
(7,13,'2024-06-14 09:00:00','2024-06-14',30, 600.00,'przelew'),
(1,12,'2024-06-14 09:30:00','2024-06-14',2,  70.00,'karta'),
(6,13,'2024-06-14 10:00:00','2024-06-14',1, 130.00,'gotowka'),
(3,12,'2024-06-14 10:30:00','2024-06-14',2,  50.00,'online'),
(2,13,'2024-06-15 09:00:00','2024-06-15',7, 140.00,'karta'),
(1,12,'2024-06-15 09:30:00','2024-06-15',3, 105.00,'blik'),
(9,13,'2024-06-15 10:00:00','2024-06-15',2, 360.00,'karta'),
(5,12,'2024-06-15 10:30:00','2024-06-15',1, 110.00,'gotowka'),
(4,13,'2024-06-16 09:00:00','2024-06-16',3,  66.00,'karta'),
(1,12,'2024-06-16 09:30:00','2024-06-16',4, 140.00,'online'),
(7,13,'2024-06-16 10:00:00','2024-06-16',20, 400.00,'przelew'),
(2,12,'2024-06-16 10:30:00','2024-06-16',5, 100.00,'karta'),
(6,13,'2024-06-17 09:00:00','2024-06-17',2, 260.00,'blik');


-- atrakcje_dodatkowe
INSERT INTO atrakcje_dodatkowe (nazwa_atrakcji, opis, cena_za_osobe, czas_trwania_min, max_uczestnikow, id_strefy, aktywna) VALUES
('Karmienie żyraf',          'Możliwość nakarmienia żyraf z platformy',           25.00, 20, 10, 1, 1),
('Pokaz krokodyli',          'Opiekun pokazuje i omawia zachowanie krokodyli',    15.00, 30,  8, 5, 1),
('Wycieczka z przewodnikiem','Godzinna trasa z licencjonowanym przewodnikiem',    20.00, 60, 20, 1, 1),
('Fotografowanie z lemurami','Sesja zdjęciowa w strefie lemurów',                30.00, 15,  6, 2, 1),
('Pokaz treserski fok',      'Trening i pokaz umiejętności fok morskich',        10.00, 25, 30, 8, 1),
('Nocna wyprawa do zoo',     'Wizyta w zoo po zmroku z latarką (12+)',            45.00, 90, 15, 1, 1),
('Adopcja zwierzęcia',       'Symboliczna adopcja – certyfikat + prezenty',      100.00, 30, 20, 1, 1),
('Karmienie pingwinów',      'Wspólne karmienie ryb przez opiekuna',             20.00, 20, 12, 4, 1),
('Lekcja zoologii',          'Edukacyjny wykład dla grup szkolnych',              8.00, 45, 30, 1, 1),
('Wycieczka terenowa 4x4',   'Jeep tour po terenie zoo',                         35.00, 50,  8, 1, 1);


-- rezerwacje_atrakcji
INSERT INTO rezerwacje_atrakcji (id_biletu, id_atrakcji, ilosc_osob, godzina_atrakcji) VALUES
(1, 1, 2,'11:00:00'),
(2, 4, 3,'12:00:00'),
(3, 3, 4,'10:30:00'),
(5, 5, 2,'13:00:00'),
(6, 9,20,'09:30:00'),
(7, 1, 2,'11:30:00'),
(9, 7, 1,'14:00:00'),
(11,3, 3,'10:00:00'),
(12,1, 2,'11:00:00'),
(14,4, 2,'12:30:00'),
(15,7, 1,'15:00:00'),
(16,5, 2,'13:30:00'),
(18,9,25,'09:00:00'),
(20,6, 2,'20:00:00'),
(21,10,4,'11:00:00'),
(22,2, 2,'12:00:00'),
(24,8, 3,'13:00:00'),
(25,1, 2,'11:00:00'),
(27,9,20,'09:30:00'),
(29,7, 1,'14:30:00'),
(30,3, 3,'10:30:00'),
(32,5, 2,'13:00:00'),
(34,1, 2,'11:00:00'),
(35,6, 1,'20:00:00'),
(37,9,15,'09:00:00'),
(38,4, 3,'12:00:00'),
(40,7, 1,'15:00:00'),
(41,8, 2,'13:00:00'),
(42,3, 4,'10:00:00'),
(44,2, 2,'12:30:00');


-- karmienie (60 rekordów) 
INSERT INTO karmienie (id_zwierzecia, id_pracownika, data_karmienia, pora_dnia, rodzaj_pokarmu, ilosc_kg, uwagi) VALUES
(1,  5,'2024-06-01 07:00:00','rano',    'wołowina',          5.000, NULL),
(2,  5,'2024-06-01 07:10:00','rano',    'wołowina',          4.000, NULL),
(3,  5,'2024-06-01 06:30:00','rano',    'siano, owoce',     80.000, 'Dodać witaminę E'),
(5,  6,'2024-06-01 07:00:00','rano',    'liście akacji',    15.000, NULL),
(7,  7,'2024-06-01 07:30:00','rano',    'owoce, warzywa',    4.500, NULL),
(9,  7,'2024-06-01 07:45:00','rano',    'owoce, termity',    2.000, NULL),
(11, 8,'2024-06-01 07:00:00','rano',    'wołowina, drób',   12.000, NULL),
(13, 9,'2024-06-01 07:00:00','rano',    'ryby, mięso foki',  8.000, NULL),
(15, 9,'2024-06-01 07:30:00','rano',    'ryby (makrela)',     0.500, NULL),
(17, 9,'2024-06-01 08:00:00','rano',    'ryby (śledź)',       4.000, NULL),
(19, 5,'2024-06-01 07:00:00','rano',    'trawa, siano',     12.000, NULL),
(21, 6,'2024-06-01 07:00:00','rano',    'mięso (antylopa)',   5.500, NULL),
(23,14,'2024-06-01 07:00:00','rano',    'trawa, warzywa',   30.000, NULL),
(24,14,'2024-06-01 07:30:00','rano',    'ryby, ptaki',       9.000, NULL),
(25,14,'2024-06-01 08:00:00','rano',    'myszy, szczury',    0.800, NULL),
(1,  5,'2024-06-01 17:00:00','wieczor', 'wołowina',          5.000, NULL),
(2,  5,'2024-06-01 17:10:00','wieczor', 'wołowina',          4.000, NULL),
(3,  5,'2024-06-01 17:00:00','wieczor', 'siano',            40.000, NULL),
(11, 8,'2024-06-01 17:30:00','wieczor', 'wołowina',         10.000, NULL),
(13, 9,'2024-06-01 17:00:00','wieczor', 'ryby',              3.000, NULL),
(1,  5,'2024-06-02 07:00:00','rano',    'wołowina',          5.000, NULL),
(2,  5,'2024-06-02 07:10:00','rano',    'wołowina',          4.000, NULL),
(3,  5,'2024-06-02 06:30:00','rano',    'siano, owoce',     80.000, NULL),
(4,  5,'2024-06-02 06:45:00','rano',    'siano, warzywa',   75.000, NULL),
(5,  6,'2024-06-02 07:00:00','rano',    'liście akacji',    15.000, NULL),
(6,  6,'2024-06-02 07:05:00','rano',    'liście akacji',    12.000, NULL),
(7,  7,'2024-06-02 07:30:00','rano',    'owoce, warzywa',    4.500, NULL),
(8,  7,'2024-06-02 07:35:00','rano',    'owoce, warzywa',    2.000, NULL),
(9,  7,'2024-06-02 07:45:00','rano',    'owoce, termity',    2.000, NULL),
(10, 7,'2024-06-02 07:50:00','rano',    'owoce, termity',    1.800, NULL),
(11, 8,'2024-06-02 07:00:00','rano',    'wołowina, drób',   12.000, NULL),
(12, 8,'2024-06-02 07:05:00','rano',    'wołowina, drób',    9.000, NULL),
(13, 9,'2024-06-02 07:00:00','rano',    'ryby, mięso foki',  8.000, NULL),
(14, 9,'2024-06-02 07:05:00','rano',    'ryby, foki',        6.000, NULL),
(15, 9,'2024-06-02 07:30:00','rano',    'ryby (makrela)',     0.500, NULL),
(16, 9,'2024-06-02 07:35:00','rano',    'ryby (makrela)',     0.500, NULL),
(17, 9,'2024-06-02 08:00:00','rano',    'ryby (śledź)',       4.000, NULL),
(18, 9,'2024-06-02 08:05:00','rano',    'ryby (śledź)',       3.500, NULL),
(19, 5,'2024-06-02 07:00:00','rano',    'trawa, siano',     12.000, NULL),
(20, 5,'2024-06-02 07:05:00','rano',    'trawa, siano',     11.000, NULL),
(21, 6,'2024-06-02 07:00:00','rano',    'mięso (antylopa)',   5.500, NULL),
(22, 6,'2024-06-02 07:05:00','rano',    'mięso (antylopa)',   4.800, NULL),
(23,14,'2024-06-02 07:00:00','rano',    'trawa, warzywa',   30.000, 'Niski apetyt'),
(24,14,'2024-06-02 07:30:00','rano',    'ryby, ptaki',       9.000, NULL),
(25,14,'2024-06-02 08:00:00','rano',    'myszy, szczury',    0.800, NULL),
(26, 6,'2024-06-02 07:15:00','rano',    'owoce, owady',      0.600, NULL),
(27, 6,'2024-06-02 07:20:00','rano',    'owoce, owady',      0.550, NULL),
(28,15,'2024-06-02 07:00:00','rano',    'krewetki, algi',    0.200, NULL),
(29,15,'2024-06-02 07:30:00','rano',    'trawa, liście',     5.000, NULL),
(30, 8,'2024-06-02 07:00:00','rano',    'owoce, liście',     4.000, NULL),
(31, 8,'2024-06-02 07:05:00','rano',    'owoce, liście',     3.800, NULL),
(32,15,'2024-06-02 08:00:00','rano',    'mięso, ryby',       2.500, NULL),
(33,15,'2024-06-02 08:05:00','rano',    'mięso, ryby',       2.000, NULL),
(34,15,'2024-06-02 08:30:00','rano',    'mięso',             4.000, NULL),
(35,15,'2024-06-02 08:35:00','rano',    'mięso',             3.500, NULL),
(1,  5,'2024-06-02 12:30:00','poludnie','wołowina',          3.000, NULL),
(11, 8,'2024-06-02 12:30:00','poludnie','drób',              5.000, NULL),
(3,  5,'2024-06-02 12:00:00','poludnie','siano',            30.000, NULL),
(23,14,'2024-06-02 12:00:00','poludnie','trawa',            20.000, NULL),
(13, 9,'2024-06-02 12:00:00','poludnie','ryby',              3.000, NULL),
(17, 9,'2024-06-02 12:00:00','poludnie','ryby',              2.000, NULL);


-- wizyty_weterynaryjne (30 rekordów) 
INSERT INTO wizyty_weterynaryjne (id_zwierzecia, id_weterynarza, data_wizyty, powod_wizyty, diagnoza, zalecenia, nastepna_wizyta) VALUES
(1,  3,'2024-01-10','Rutynowe badanie','Zdrowy, waga prawidłowa','Szczepienie booster za 6 miesięcy','2024-07-10'),
(2,  3,'2024-01-10','Rutynowe badanie','Zdrowa','Kontynuacja diety','2024-07-10'),
(3,  4,'2024-01-15','Problemy z jelitami','Zaburzenia trawienne','Zmiana diety, probiotyki na 2 tygodnie','2024-02-15'),
(3,  4,'2024-02-16','Kontrola po leczeniu','Stan poprawny','Powrót do normalnej diety','2024-08-16'),
(5,  3,'2024-01-20','Rutynowe badanie','Brak anomalii','Kolejne badanie za pół roku','2024-07-20'),
(7,  4,'2024-02-01','Kaszel, brak apetytu','Infekcja górnych dróg oddechowych','Antybiotyki 10 dni','2024-02-15'),
(7,  4,'2024-02-16','Kontrola','Wyleczony','Obserwacja przez 2 tygodnie','2024-03-01'),
(11, 3,'2024-02-05','Rutynowe badanie','Zdrowy, waga 220 kg','Szczepienie za 6 miesięcy','2024-08-05'),
(12, 3,'2024-02-05','Rutynowe badanie','Zdrowa, waga 175 kg','Regularne badania','2024-08-05'),
(13, 4,'2024-02-10','Wycieńczenie','Niedobory witaminowe','Suplementacja witaminy D i B12','2024-03-10'),
(15, 3,'2024-03-01','Rutynowe badanie','Zdrowy','Badania krwi OK','2024-09-01'),
(16, 3,'2024-03-01','Rutynowe badanie','Zdrowa, waga 3.2 kg','Dieta prawidłowa','2024-09-01'),
(17, 4,'2024-03-05','Rana na płetwie','Powierzchowne zadrapanie','Opatrunek, obserwacja','2024-03-12'),
(23, 3,'2024-03-10','Rutynowe badanie','Hipopotam w dobrej kondycji','Kontynuacja żywienia','2024-09-10'),
(24, 4,'2024-03-15','Letarg','Stres związany ze zmianą opiekuna','Stabilizacja otoczenia','2024-04-15'),
(25, 3,'2024-04-01','Rutynowe badanie','Zdrowy boa','Nie wymagana interwencja','2024-10-01'),
(29, 4,'2024-04-05','Rutynowe badanie','Żółw zdrowy, waga 185 kg','Diety liściowe wystarczające','2025-04-05'),
(30, 3,'2024-04-10','Kaszel','Infekcja układu oddechowego','Inhalacje, antybiotyk','2024-04-25'),
(30, 3,'2024-04-26','Kontrola','Wyleczony','Brak zaleceń','2024-10-26'),
(32, 4,'2024-04-15','Utrata wagi','Niedożywienie','Zwiększenie porcji o 20%','2024-05-15'),
(32, 4,'2024-05-16','Kontrola wagi','Waga wzrosła o 1.5 kg','Utrzymać zwiększoną dietę','2024-06-16'),
(34, 3,'2024-05-01','Rutynowe badanie','Samiec wilka w dobrej formie','Badania za rok','2025-05-01'),
(35, 3,'2024-05-01','Rutynowe badanie','Samica wilka zdrowa','Badania za rok','2025-05-01'),
(19, 4,'2024-05-10','Skaleczenie nogi','Rana po kontakcie z ogrodzeniem','Opatrunek, antybiotyk miejscowy','2024-05-20'),
(19, 4,'2024-05-21','Kontrola rany','Rana zagojona','Brak zaleceń','2024-11-21'),
(21, 3,'2024-05-15','Rutynowe badanie','Gepard w świetnej formie','Badania krwi prawidłowe','2024-11-15'),
(4,  4,'2024-06-01','Rutynowe badanie','Słoń zdrowy, 4800 kg','Regularne badania','2024-12-01'),
(9,  3,'2024-06-05','Otarcia na ciele','Kontakt z twardym elementem','Maść, obserwacja','2024-06-12'),
(26, 4,'2024-06-08','Brak apetytu','Stres terytorialny (nowy lemur)','Izolacja czasowa','2024-06-22'),
(8,  3,'2024-06-10','Rutynowe badanie','Gorylica w dobrej kondycji','Dieta bogata w owoce','2024-12-10');

