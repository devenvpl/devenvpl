---
date: 2017-04-09 22:35
title: Krauza - pobieranie kart
description: Opis głównej logiki aplikacji
tags: mksiazek dsp2017-mateusz krauza projekt php oop
category: dsp2017-mateusz
author: mksiazek
comments: true
layout: post-with-related-tag
related_tag: "krauza"
related_title: "Zobacz inne posty związane z projektem Krauza"
related_message: Projekt <i>Krauza</i> realizowany jest w ramach konkursu <a href="http://devstyle.pl/daj-sie-poznac/">Daj Się Poznać 2017</a>. Repozytorium dostępne jest w serwisie <a href="https://github.com/mejt/Krauza">GitHub</a>.
---

W końcu udało mi się uporać z główną częścią logiki aplikacji, czyli pobieraniem kolejnej karty z pudełka. Temat nie był
skomplikowany, ale trzeba było znaleźć odrobinę czasu żeby przy tym przysiąść i pokryć wszystkie przypadki użycia.
Okazało się, że piękna kwietniowa niedziela okazała się idealnym dniem aby to zaimplementować :smile:

Dzisiejszy post będzie bardziej teoretyczny, aby opisać zasady działania, nie widzę sensu aby na razie wklejać tutaj
listingi kodu, te pojawią się może przy okazji kolejnych postów. Mimo wszystko dotychczasowy kod aplikacji dostępny
jest w [repozytorium](https://github.com/mejt/Krauza).

## Podstawowe zasady systemu Leitnera
Zwyczajne pudełko, które jest używane do kartoteki autodydaktycznej składa się z 5 przegródek. W uproszczeniu według
założeń Sebastiana Leitnera wystarczy, że jedna karta, która zawiera hasło do nauki przejdzie przez wszystkie przegródki
aby zostało one uznane za takie którego się nauczyliśmy.

Przegródki w pudełku nie powinny być jednakowej wielkości, każda kolejna powinna być większa. Przykładowo powinno
się w nich mieścić kolejno 50, 100, 200, 400, 600, 800 kartek. Dodajemy kartki do pierwszej przegródki (ale nie do pełna).
Zaczynamy naukę od pierwszej przegródki i jeśli znamy odpowiedź na hasło to przekładamy do kolejnej przegródki. Kiedy
druga przegródka zostanie zapełniona to przechodzimy do niej i przerabiamy pewną ilośc kartek, ale nie wszystkie,
powiedzmy 40 ze 100. Te, karty na które znamy odpowiedź przekładamy do następnej, a te których nie znamy wracają do 1 (zawsze do 1).
Taki proces odbywa się do 5 przegródki, bo z ostatniej częsci hasła które znamy powinny zostać wyciągnięte z pudełka i uznać
je za takie, które zostały "zakodowane w naszej głowie".

## Warianty, które musiały zostać pokryte
Poniżej przedstawiam kompletny zestaw wariantów, które zostały pokryte przypadkami testowymi z wykorzystaniem TDD.

* Podstawowe pobranie kartki z przegródki
* Sprawdzenie czy w kolejnej przegródce nie został osiągnięty limit, jeśli tak to należy przejść do niej, pobrać pierwszą
kartkę i pozostać w tej przegródce na czas przerobienia 40 kolejnych kartek, chyba, że w następnej przegródce został
osiągięty limit... Oczywiście nie sprawdzamy kolejnej przegródki jeśli jesteśmy na ostatniej.
* Kiedy przerobimy 40 kartek z innej przegródki niż pierwsza wracamy do początkowej
* Jeśli w pierwszej przegródce pozostało mniej niż 10 kartek pobieramy nowe hasła z "inboxu". Powiedzmy za każdym razem
wrzucamy 20 nowych kartek. Oczywiście tylko wtedy jeśli są jakieś kartki w "poczekalni".
* W momencie kiedy w przerabianej przegródce nie ma żadnych kartek do pobrania to przechodzimy do kolejnej, która nie
jest pusta.
* Kiedy nie ma kartek ani w poczekalni ani w żadych przegródkach nic nie pobieramy.

Na tę chwilę to wszystkie warianty i wydaje mi się, że nic nie powinno mnie zaskoczyć, ale oczywiście wszystko się okaże
kiedy będzie trzeba to już wykorzystać.

## Co następne?
Ostatnim elementem logiki, który powinien pojawić się w najbliższym czasie będzie reakcja na odpowiedź, czyli do jakiego
miejsca powinna pójść karta jeśli użytkownik udzielił poprawnej odpowiedzi na hasło.
