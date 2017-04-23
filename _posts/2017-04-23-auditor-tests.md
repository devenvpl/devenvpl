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

Aktualnie w projekcie *Auditor* wykorzystujê dwa typy testów automatycznych - testy jednostkowe oraz integracyjne. W obu przypadkach za uruchamianie testów, ich uk³ad i wykorzystywane asercje odpowiada najpopularniejszy PHPowy test framework - **[PHPUnit](https://phpunit.de/)**. Jego autorem jest [Sebastian Bergmann](https://twitter.com/s_bergmann). Zreszt¹ bardzo spoko goœæ - w 2015 roku mia³em okazjê uczestniczyæ w warsztatach prowadzonych przez Sebastiana na konferencji [IPC Berlin](https://phpconference.com/en/). Poni¿ej pami¹tkowe zdjêcie ekipy *Future Processing* wraz z Sebastianem i Stefanem (thePHP.cc):

![Future Processing & thePHP.cc]({{ site.url }}/assets/images/2017/04/auditor-tests/ipc-2015.jpg)

## Testy jednostkowe (*unit test*)

Najproœciej mówi¹c **testy jednostkowe** to kod weryfikuj¹cy poprawnoœæ zachowania kodu produkcyjnego. Sprawdzenie czy elementy systemu zachowuj¹ siê w sposób jaki zaplanowa³ programista. Co jest bardzo wa¿ne - testuje siê jednostkê czyli mo¿liwie najmniejszy element systemu - obiekt, a najlepiej konkretn¹ metodê lub funkcjê.

O testach jednostkowych rozpisa³ siê ciekawie Maciej, polecam zatem jego artyku³ - [ZapowiedŸ minicyklu o testach](http://devstyle.pl/2011/08/08/ut-0-zapowiedz-minicyklu-o-testach/)

## Testy integracyjne (*integration test*)

**Testy integracyjne** odpowiadaj¹ za sprawdzenie kilku komponentów, które ze sob¹ wspó³pracuj¹. Nie dotycz¹ konkretnej jednostki, a grupy jednostek realizuj¹cych zadanie. To ten rodzaj testów, który nie powinien posiadaæ mocków na operacje bazodanowe czy I/O. Komunikacja z zewnêtrznymi serwisami, baz¹ danych czy systemem plików s¹ naturaln¹ czêœci¹ takich testów.

W projekcie *Auditor* testy integracyjne wykorzystuj¹ osobn¹ bazê danych. Ich "wejœciem" jest akcja kontrolera dla której dostarczam dane wejœciowe (symulacja metody POST). Nastêpnie weryfikujê stan bazy danych - czy wszystkie dane zosta³y zapisane w za³o¿ony sposób. Te testy bêd¹ pokrywa³y w projekcie jedynie œcie¿kê *[Happy Path](https://en.wikipedia.org/wiki/Happy_path)*, przypadki brzegowe powinny zostaæ pokryte testami jednostkowymi (uwaga - potencjalnie to podejœcie mo¿e ulec zmianie).

Sposobów na przeprowadzanie i weryfikacjê testów integracyjnych jest wiele. Wszystko zale¿y od kontekstu œrodowiska w którym dzia³a aplikacja oraz prawdê mówi¹c - przyjêtego w zespole programistycznym za³o¿enia (oby tylko popartego konkretnymi argumentami :)).

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

**Common** - jest folderem zawieraj¹cym wspó³dzielone pomiêdzy testami klasy. To tutaj znajdowaæ bêd¹ siê *buildery*, *mocki*, *stuby* i *fake* wykorzystywane w testach.

**Integration** - przestrzeñ do umieszczania *testów integracyjnych*. Bez podfolderów. Spowodowane jest to sam¹ iloœci¹ testów oraz faktem, ¿e dotycz¹ one jedynie ¿¹dañ (*[Command](/dsp2017-adrian/2017/03/19/auditor-cqrs-command.html)* czyli akcji zmieniaj¹cych stan systemu) które mo¿e wykonaæ u¿ytkownik aplikacji.

**Unit** - przestrzeñ dla *testów jednostkowych*. Podfoldery odzwierciedlaj¹ *[bundle](/dsp2017-adrian/2017/03/26/auditor-bundles.html)* aplikacji.

Poszczególne *Test Suite* to kolejne klasy (zawieraj¹ce przypadki testowe - *Test Case*). Nie s¹ one równoznaczne z bardzo czêsto przyjêtym za³o¿eniem (momentami b³ednym!), jedna klasa produkcyjna = jedna klasa testowa. Jeœli potrzebujê utworzyæ kilka przypadków testowych dla metody - mogê wyodrêbniæ je do osobnego *Test Suite*. Jednak warto zadaæ sobie wtedy pytanie: "*Czy na pewno metoda któr¹ chcê przetestowaæ nie robi zbyt du¿o? Mo¿e lepiej wyodrêbniæ j¹ jako osobn¹ klasê?*"

Ka¿dy z typów testów posiada osob¹ konfiguracjê *PHPUnit*, ze wzglêdu na fakt, ¿e przy najbli¿szych zmianach zamierzam dodaæ *Code Coverage* dla *testów jednostkowych*.

## Composer Scripts

Aby u³atwiæ sobie uruchamianie testów z konsoli, stworzy³em dwa aliasy na poziomie [Composer Scripts](https://getcomposer.org/doc/articles/scripts.md). Wpis w *composer.json* wygl¹da nastêpuj¹co:

~~~json
{
  "scripts": {
    "unit": "php vendor/phpunit/phpunit/phpunit --testdox --configuration tests/Unit/phpunit.xml",
    "integration": "php vendor/phpunit/phpunit/phpunit --testdox --configuration tests/Integration/phpunit.xml"
  }
}
~~~

Dziêki takiemu rozwi¹zaniu, do uruchomienia konkretnego zestawu testów (jednostkowych lub integracyjnych) wystarczy, ¿e wydam polecenie:

```
$: composer unit

// lub

$: composer integration
```

W tym poœcie przedstawi³em podejœcie do struktury testów w moim projekcie. Wiêcej szczegó³ów (g³ównie implementacyjnych) postaram siê opisaæ w osobnych artyku³ach.

Jak organizujecie swoje testy w aplikacjach PHP? Podzielcie siê swoimi doœwiadczeniami :-)