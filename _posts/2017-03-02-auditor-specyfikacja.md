---
date: 2017-03-02 00:30
title: "Auditor - Specyfikacja"
layout: post
description: "Sprecyzowanie wymagań dla projektu AUDITOR"
tags: apietka dsp2017-adrian auditor
category: dsp2017-adrian
author: apietka
---

Czas nakreślić nieco bardziej szczegółowe ramy projektu *AUDITOR*. Jeżeli jeszcze nie wiesz czym jest projekt oraz jaki problem ma potencjalnie rozwiązać, to zapraszam Cię do pierwszego postu z serii: [Daj się poznać 2017 [Adrian]](/dsp2017-adrian/2017/02/28/daj-sie-poznac-adrian.html).

## Jest specka?

Nie ma. Będą jedynie z grubsza zdefiniowane wymagania funkcjonalne oraz trochę naciągnięte niefunkcjonalne. Nie chcę zamykać się w raz przyjętych założeniach - one nakreślą początkową wizję. Reszta (bardziej doprecyzowana) mam nadziej wyklaruje się w sposób naturalny. Niech się dzieje - [Agile](https://pl.wikipedia.org/wiki/Manifest_Agile) ... :)

## Wymagania funkcjonalne

> "Wymagania funkcjonalne opisują funkcjonalność, którą system ma realizować"
> 
> *via wikipedia.org*

1. *AUDITOR* ma być aplikacją internetową, dostępną przez przeglądarkę internetową.
2. Zarządzanie audytowanymi projektami
    - Lista projektów składająca się z: nazwy projektu, postępu (np: zaudytowano 87% kodu, poświęcono 14h 39m)
    - Użytkownik posiada możliwość dodawania nowego projektu
    - Po utworzeniu projektu, można wgrać paczkę *zip* wraz z kodem źródłowym, który zostanie przypisany do projektu
3. Podgląd kodu źródłowego dla wybranego projektu
    - Wyświetlenie struktury katalogowej w sposób ułatwiający poruszanie się pomiędzy poszczególnymi plikami z kodem źródłowym
    - Szybkie wyszukiwanie konkretnego katalogu oraz pliku
    - Kolorowanie składni kodu źródłowego podczas przeglądania zawartości pliku
    - Możliwość komentowania jednej lub kilku zaznaczonych linii w kodzie źródłowym (od - do)
    - Informacja o ilości zgłoszonych uwag w danym pliku oraz sumarycznie dla każdego węzła katalogów
    - Logowanie czasu spędzonego na przeglądaniu kodu źródłowego, liczone dla każdego pliku z osobna
4. Generowanie raportu na podstawie zgłoszonych komentarzy
    - Raport zostanie wygenerowany w postaci pliku PDF
    - Zawierać będzie informacje na temat: nazwy projektu, czasu poświęconego na audyt, procent zaudytowanego kodu
    - Każdy fragment kodu źródłowego który został opatrzony komentarzem zostanie zaprezentowany w raporcie wraz z komentarzem

## Wymagania niefunkcjonalne

O tym czym są wymagania niefunkcjonalne możesz przeczytać w artykule na stronie [http://analizawymagan.pl](http://analizawymagan.pl/wymagania-niefunkcjonalne/)

1. Wsparcie dla najnowszych wersji przeglądarek Chrome, Firefox.
2. Testy automatyczne (na różnym poziomie) dla najważniejszych elementów aplikacji.
3. Wykorzystanie Travis CI do uruchomienia testów automatycznych po każdym dostarczeniu kodu do repozytorium.
4. Proste do uruchomienia środowisko developerskie.
5. Zastosowanie PHP w wersji 7.1 oraz HTML5 i standardu ECMAScript 6 po stronie interfejsu użytkownika.

## Milestones

1. Konfiguracja projektu oraz CI, struktura kodu.
2. Zarządzanie i wyświetlanie listy audytowanych projektów.
3. Prezentowanie struktury projektu, wraz z podglądem kodu źródłowego.
4. Możliwość przeprowadzenia audytu kodu wraz z zliczaniem czasu poświęconego na jego wykonanie.
5. Generowanie raportu z przeprowadzonego audytu.

## Stack technologiczny

W tej kwestii będę nieco monotonny, nudny i przygnębiający. **Nie będzie Reacta**. Nie i chuj. Po prostu, przy tym projekcie pominę hype na nieg. Chcę dostarczyć działający, w miarę ustrukturyzowany i ogarnięty kawałek oprogramowania. Reacta najzwyczajniej nie znam, a jego nieznajomość mogłaby spowolnić tempo prac.

Backend zostanie zasilany przez **PHP** + **Symfony3**, przewinie się też kilka popularnych bibliotek. Dane wylądują *prawdopodobnie* w **MongoDB**. UI napędzi stary, poczciwy **AngularJS**. To w sumie tyle z podstawowego stacka. Po drodze na pewno zahaczę o parę popularnych słów kluczowych - jednak o tym później.

Dlaczego? Primo - dawno nic nie pisałem w PHP. Aktualnie realizuję projekty wykorzystując inne technologie. Secundo - w tym PHPie też się da zakodzić coś z głową! Postaram się to chociaż po części udowodnić :)