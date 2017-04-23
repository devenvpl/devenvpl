---
date: 2017-04-23 23:30
title: "Auditor - O organizacji testów automatycznych"
layout: post
description: "Organizacja testów jednostkowych oraz integracyjnych dla projektu Auditor."
tags: apietka dsp2017-adrian auditor php tests symfony
category: dsp2017-adrian
author: apietka
comments: true
---

Aktualnie w projekcie *Auditor* wykorzystuję dwa typy testów automatycznych - testy jednostkowe oraz integracyjne. W obu przypadkach za uruchamianie testów, ich układ i wykorzystywane asercje odpowiada najpopularniejszy PHPowy test framework - **[PHPUnit](https://phpunit.de/)**. Jego autorem jest [Sebastian Bergmann](https://twitter.com/s_bergmann). Zresztą bardzo spoko gość - w 2015 roku miałem okazję uczestniczyć w warsztatach prowadzonych przez Sebastiana na konferencji [IPC Berlin](https://phpconference.com/en/). Poniżej pamiątkowe zdjęcie ekipy *Future Processing* wraz z Sebastianem i Stefanem (thePHP.cc):

![Future Processing & thePHP.cc]({{ site.url }}/assets/images/2017/04/auditor-tests/ipc-2015.jpg)

## Testy jednostkowe (*unit test*)

Najprościej mówiąc **testy jednostkowe** to kod weryfikujący poprawność zachowania kodu produkcyjnego. Sprawdzenie czy elementy systemu zachowują się w sposób jaki zaplanował programista. Co jest bardzo ważne - testuje się jednostkę czyli możliwie najmniejszy element systemu - obiekt, a najlepiej konkretną metodę lub funkcję.

O testach jednostkowych rozpisał się ciekawie Maciej, polecam zatem jego artykuł - [Zapowiedź minicyklu o testach](http://devstyle.pl/2011/08/08/ut-0-zapowiedz-minicyklu-o-testach/)

## Testy integracyjne (*integration test*)

**Testy integracyjne** odpowiadają za sprawdzenie kilku komponentów, które ze sobą współpracują. Nie dotyczą konkretnej jednostki, a grupy jednostek realizujących zadanie. To ten rodzaj testów, który nie powinien posiadać mocków na operacje bazodanowe czy I/O. Komunikacja z zewnętrznymi serwisami, bazą danych czy systemem plików są naturalną częścią takich testów.

W projekcie *Auditor* testy integracyjne wykorzystują osobną bazę danych. Ich "wejściem" jest akcja kontrolera dla której dostarczam dane wejściowe (symulacja metody POST). Następnie weryfikuję stan bazy danych - czy wszystkie dane zostały zapisane w założony sposób. Te testy będą pokrywały w projekcie jedynie ścieżkę *[Happy Path](https://en.wikipedia.org/wiki/Happy_path)*, przypadki brzegowe powinny zostać pokryte testami jednostkowymi (uwaga - potencjalnie to podejście może ulec zmianie).

Sposobów na przeprowadzanie i weryfikację testów integracyjnych jest wiele. Wszystko zależy od kontekstu środowiska w którym działa aplikacja oraz prawdę mówiąc - przyjętego w zespole programistycznym założenia (oby tylko popartego konkretnymi argumentami :)).

## Struktura

```
tests
|-- Common
|  |-- Mock
|  |-- Builder
|
|-- Integration
|  |-- CreateNewProjectTest.php
|  |-- phpunit.xml
|
|-- Unit
|  |-- AppBundle
|     |-- SymfonyCommandHandlerResolverTest.php
|  |-- phpunit.xml
```

**Common** - jest folderem zawierającym współdzielone pomiędzy testami klasy. To tutaj znajdować będą się *buildery*, *mocki*, *stuby* i *fake* wykorzystywane w testach.

**Integration** - przestrzeń do umieszczania *testów integracyjnych*. Bez podfolderów. Spowodowane jest to samą ilością testów oraz faktem, że dotyczą one jedynie żądań (*[Command](/dsp2017-adrian/2017/03/19/auditor-cqrs-command.html)* czyli akcji zmieniających stan systemu) które może wykonać użytkownik aplikacji.

**Unit** - przestrzeń dla *testów jednostkowych*. Podfoldery odzwierciedlają *[bundle](/dsp2017-adrian/2017/03/26/auditor-bundles.html)* aplikacji.

Poszczególne *Test Suite* to kolejne klasy (zawierające przypadki testowe - *Test Case*). Nie są one równoznaczne z bardzo często przyjętym założeniem (momentami błednym!), jedna klasa produkcyjna = jedna klasa testowa. Jeśli potrzebuję utworzyć kilka przypadków testowych dla metody - mogę wyodrębnić je do osobnego *Test Suite*. Jednak warto zadać sobie wtedy pytanie: "*Czy na pewno metoda którą chcę przetestować nie robi zbyt dużo? Może lepiej wyodrębnić ją jako osobną klasę?*"

Każdy z typów testów posiada osobą konfigurację *PHPUnit*, ze względu na fakt, że przy najbliższych zmianach zamierzam dodać *Code Coverage* dla *testów jednostkowych*.

## Composer Scripts

Aby ułatwić sobie uruchamianie testów z konsoli, stworzyłem dwa aliasy na poziomie [Composer Scripts](https://getcomposer.org/doc/articles/scripts.md). Wpis w *composer.json* wygląda następująco:

~~~json
{
  "scripts": {
    "unit": "php vendor/phpunit/phpunit/phpunit --testdox --configuration tests/Unit/phpunit.xml",
    "integration": "php vendor/phpunit/phpunit/phpunit --testdox --configuration tests/Integration/phpunit.xml"
  }
}
~~~

Dzięki takiemu rozwiązaniu, do uruchomienia konkretnego zestawu testów (jednostkowych lub integracyjnych) wystarczy, że wydam polecenie:

```
$: composer unit

// lub

$: composer integration
```

W tym poście przedstawiłem podejście do struktury testów w moim projekcie. Więcej szczegółów (głównie implementacyjnych) postaram się opisać w osobnych artykułach.

Jak organizujecie swoje testy w aplikacjach PHP? Podzielcie się swoimi doświadczeniami :-)