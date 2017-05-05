---
date: 2017-04-15 17:30
title: Krauza - trochę HDD nikomu nie zaszkodzi
description: Podsumowanie pierwszego etapu i założenia przed kolejnym
tags: mksiazek dsp2017-mateusz krauza projekt php oop javascript mysql doctrine dbal graphql angular
category: dsp2017-mateusz
author: mksiazek
comments: true
layout: post-with-related-tag
related_tag: "krauza"
related_title: "Zobacz inne posty związane z projektem Krauza"
---

Logika, którą zakładałem jako podstawa do mojego projektu została już zaimplementowana i przeszła już pierwszy refaktor.
W miarę dobrze to wygląda, udało się osiągnąć 100% pokrycia kodu (chociaż w ogóle mi na tym nie zależało :stuck_out_tongue_winking_eye:),
ale pewnie jeszcze coś poprawię w niedalekiej przyszłości :smiley: 

Teraz nadchodzi czas aby dokonać już wyboru częsci infrastruktury do aplikacji. Pomimo tego, że w pierwszym poście
dotyczącym projektu pisałem, że chciałbym się skupić na znanych mi technologiach aby dociągnąć go do końca to patrząc
na fakt, że implementacja idzie w miarę sprawnie i ciągle mam sporo ochoty do kontynuowania pracy zastanawiam się
trochę nad poeksmerymentowaniem z nowościami.

Przecież odrobina HDD (Hype Driven Development :smiley:) nie może zaszkodzić... Doszedłem do wniosku, że skoro
*Krauza* to pet-project to jest idealnym miejscem aby poduczyć się czegoś nowego i co przy okazji może się przydać
w normalnych projektach.

##### API
Początkowo myślałem o użyciu mikroframworka [Silex](https://silex.sensiolabs.org/) do zapewnienia REST API, ale w ostatnim
czasie śledząc najnowsze trendy zauważyłem, że wszyscy najwięksi gracze eksperymentują z [GraphQL](http://graphql.org/)
więc może to być całkiem przyszłosciowe rozwiązanie. Stwierdziłem, że na razie mój projekt jest na tyle mały, a ilość
endpointów jest niewielka dzięki czemu mogę sprawdzić to narzędzie, a jeśli okaże się złym rozwiązaniem to bez problemów
mogę się wycofać do pierowtnego pomysłu. Na razie jestem ciekawy co wyjdzie z tego eksperymentu i na pewno już wkrótce 
pojawią się posty na ten temat.

##### Baza danych
W tym wypadku stawiam na sprawdzone i najszybsze rozwiązanie, czyli tradycyjną relacyjną bazę MySQL, a do tego
[DBAL](http://www.doctrine-project.org/projects/dbal.html) jako warstwa abstrakcji bazodanowej. Długo zastanawiałem się
nad nierelacyjną bazą danych (np. mongodb), ale nie chcę tracić czasu na rozstawianiu kolejnych usług serwerowych, skoro
mam gotową i dostępną bazę danych.

##### Frontend
Warstwą prezentacji będzie osobna aplikaca, którą postanowiłem oprzeć o Angular (aktualnie w wersji 4). Obecnie na co
dzień pracuję w projekcie z wykorzystaniem AngularJS, więc chętnie zagłębię się w najnowszą wersję tego frameworka
front-endowego. [Byłem na szkoleniu](/dsp2017-mateusz/2017/03/14/angular.html) z Angulara więc podstawy
już poznałem, ale chętnie wypróbuję go w jakimś projekcie. To idealny moment. Przy okazji poznam też
[TypeScript](https://www.typescriptlang.org/).

## Będzie co robić!
Za mną sporo pracy koncepcyjnej bo logika aplikacji w zasadzie jest gotowa, jednak przede mną jeszcze więcej.
Adaptacja nowych narzędzi może jeszcze bardziej spotęgować ilość potrzebnego czasu do skończenia projektu, ale jestem
dobrych myśli. A przy okazji czego się nauczę to już nikt mi nie zabierze :sunglasses:
