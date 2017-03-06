---
date: 2017-03-06 23:00
title: "Auditor - Uruchamiamy projekt"
layout: post
description: "Struktura projektu wraz z podstawow¹ konfiguracj¹"
tags: apietka dsp2017-adrian auditor
category: dsp2017-adrian
author: apietka
---

Postanowi³em rozdzieliæ interfejs u¿ytkownika od czêœci backendowej. Dlatego te¿, bêdê tworzy³ aplikacjê sk³adaj¹c¹ siê z dwóch elementów - *backend* oraz *frontend*. Pamiêtaj, ¿e tworzê aplikacjê typu **SPA** (*Single-page application*).

### Backend - API

Aplikacjê backendow¹ napêdza framework **Symfony 3**, wykorzystuj¹cy wzorzec architektoniczny **MVC** (*Model-View-Controller*). Bêdzie to swoiste API dla aplikacji frontendowej. Ca³oœæ oparta o zasadê (en. *priniciple*) - **CQRS** (*Command Query Responsibility Segregation*). Czyli w wielkim skrócie mówi¹c - rozdzielam model zapisu od odczytu, a wszystko co dzieje siê w aplikacji mo¿e byæ przyporz¹dkowane do jednego rodzaju akcji - odczytu (*Query*) lub zapisu (*Command*).

O samej implementacji, rozpiszê siê w dwóch zupe³nie niezale¿nych artyku³ach. Jednak bêdzie to omówienie implementacji w jêzyku PHP. Na teraz polecam z zapoznaniem siê z ebookiem Maæka z [devstyle.pl](http://devstyle.pl/) - [CQRS Pragmatycznie](http://devstyle.pl/ksiazki/cqrs-pragmatycznie/).

### Frontend - WebUI

AngularJS jak wszystko, ma swoje wady i zalety. Jedn¹ z wad jest zdecydowanie bardzo ubogi routing. Dlatego te¿, od pocz¹tku bêdê u¿ywa³ rozbudowanej wersji, upsrawniaj¹cej routing aplikacji - [AngularUI Router](https://github.com/angular-ui/ui-router). W utrzymaniu *Clean Code* pomog¹ mi regu³y spisane przez John Papa, choæ bêdzie to raczje wybór kilku z nich, ni¿eli próba implementacji ka¿dej. Mo¿esz o nich poczytaæ tutaj - [Angular 1 Style Guide](https://github.com/johnpapa/angular-styleguide/blob/master/a1/README.md).

## Wymagania

Co jednak jest niezbêdne aby uruchomiæ aplikacjê? Aktualnie po stronie backendowej, wymagany jest interpreter PHP w wersji 7.1 oraz PHPowy dependency manager - [composer](https://getcomposer.org/). That's all.

Aplikacja frontendowa jest nieco bardziej wymagaj¹ca. Nale¿y zainstalowaæ [Node.js](https://nodejs.org) wraz z managerem pakietów *npm*. Nastêpnie doinstalowaæ globalnie task runnera - [grunt](https://gruntjs.com/). Najlepiej wszystko w najnowszej, stabilnej wersji.

## Uruchomienie

Je¿eli jesteœmy pewni, ¿e wszystkie niezbêdne elementy uk³adanki zosta³y zainstalowane, pozostaje nam œci¹gniêcie repozytorium kodu.

```
$: git clone git@github.com:devenvpl/auditor.git
$: cd auditor
```

Uruchomienie backendu, jest banalnie proste.

```
$: cd api && composer install && php bin/console server:run
```

Pozostaje jedynie uruchomiæ aplikacjê frontendow¹.

```
$: cd webui && npm install && grunt build && grunt server
```

Od tej pory dwa elementy aplikacji dostêpne s¹ pod adresami:

- backend - [http://localhost:8000](http://localhost:8000)
- frontend - [http://localhost:3000](http://localhost:3000)

Na razie jednak pusto. Mam szkielet. Nic siê nie dzieje, ale to do czasu :)