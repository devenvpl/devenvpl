---
date: 2017-03-06 23:00
title: "Auditor - Uruchamiamy projekt"
layout: post
description: "Struktura projektu wraz z podstawową konfiguracją"
tags: apietka dsp2017-adrian auditor
category: dsp2017-adrian
author: apietka
comments: true
---

Postanowiłem rozdzielić interfejs użytkownika od części backendowej. Dlatego też, będę tworzył aplikację składającą się z dwóch elementów - *backend* oraz *frontend*. Pamiętaj, że tworzę aplikację typu **SPA** (*Single-page application*).

## Backend - API

Aplikację backendową napędza framework **Symfony 3**, wykorzystujący wzorzec architektoniczny **MVC** (*Model-View-Controller*). Będzie to swoiste API dla aplikacji frontendowej. Całość oparta o zasadę (en. *priniciple*) - **CQRS** (*Command Query Responsibility Segregation*). Czyli w wielkim skrócie mówiąc - rozdzielam model zapisu od odczytu, a wszystko co dzieje się w aplikacji może być przyporządkowane do jednego rodzaju akcji - odczytu (*Query*) lub zapisu (*Command*).

O samej implementacji, rozpiszę się w dwóch zupełnie niezależnych artykułach. Jednak będzie to omówienie implementacji w języku PHP. Na teraz polecam z zapoznaniem się z ebookiem Maćka z [devstyle.pl](http://devstyle.pl/) - [CQRS Pragmatycznie](http://devstyle.pl/ksiazki/cqrs-pragmatycznie/).

## Frontend - WebUI

AngularJS jak wszystko, ma swoje wady i zalety. Jedną z wad jest zdecydowanie bardzo ubogi routing. Dlatego też, od początku będę używał rozbudowanej wersji, usprawniającej routing aplikacji - [AngularUI Router](https://github.com/angular-ui/ui-router). W utrzymaniu *Clean Code* pomogą mi reguły zaproponowane przez John Papa, choć będzie to raczje wybór kilku z nich, niżeli próba implementacji każdej. Możesz o nich poczytać tutaj - [Angular 1 Style Guide](https://github.com/johnpapa/angular-styleguide/blob/master/a1/README.md).

## Wymagania

Co jednak jest niezbędne aby uruchomić aplikację? Aktualnie po stronie backendowej, wymagany jest interpreter PHP w wersji 7.1 oraz PHPowy dependency manager - [composer](https://getcomposer.org/). That's all.

Aplikacja frontendowa jest nieco bardziej wymagająca. Należy zainstalować [Node.js](https://nodejs.org) wraz z managerem pakietów *npm*. Następnie doinstalować globalnie task runnera - [gulp.js](http://gulpjs.com/) oraz bundlera [browserify](http://browserify.org/). Najlepiej wszystko w najnowszej, stabilnej wersji.

```
$: npm install gulp -g
$: npm install browserify -g
```

Uff... Na początek to tyle. Tworzenie frontendu staje się coraz bardziej wymagające pod kątem stosowanych narzędzi ;-)

## Uruchomienie

Jeżeli jesteśmy pewni, że wszystkie niezbędne elementy układanki zostały zainstalowane, pozostaje nam ściągnięcie repozytorium kodu i uruchomienie aplikacji.

```
$: git clone git@github.com:devenvpl/auditor.git
$: cd auditor
```

Uruchomienie backendu, jest banalnie proste. Composer pobiera niezbędne zależności, a następnie wykorzystując wbudowany serwer HTTP w interpreterze PHP, uruchamiana jest aplikacja.

```
$: cd api && composer install && php bin/console server:run
```

Start aplikacji frontendowej, wygląda bardzo podobnie. Npm instaluje wszystkie potrzebne biblioteki, gulp przygotowuje pliki (m.in konkatenacja bibliotek), a następnie zaczynamy serwować pliki statyczne.

```
$: cd webui && npm install && gulp dist && gulp serve
```

Od tej pory dwa elementy aplikacji dostępne są pod adresami:

- backend - [http://localhost:8000](http://localhost:8000)
- frontend - [http://localhost:3000](http://localhost:3000)

Na razie jednak pusto. Mam szkielet. Nic się nie dzieje, ale to do czasu :)