---
date: 2017-03-26 22:00
title: "Auditor - Bundles"
layout: post
description: "Podział projektu Auditor na Symfonowe bundle"
tags: apietka dsp2017-adrian auditor symfony bundle
category: dsp2017-adrian
author: apietka
comments: true
---

W mojej przygodzie programistycznej wspierałem zespoły projektowe w tworzeniu aplikacji w oparciu o różne platformy, a co za tym idzie również różne języki programowania i frameworki. Dzięki temu poznałem kilka (jak nie kilkanaście) sposobów na "układanie" struktury plików. W projektach .NET bardzo podoba mi się podział solucji na projekty, a później dowolność w ich układaniu w podfoldery. W ekosystemie Symfony mamy tzw. podział na Bundle. Jest on co prawda dość restrykcyjnie opisany w dokumentacji - "moduły które można reużywać pomiędzy projektami". Moje rowziwązanie jednak trochę przeczy tej głównej zasadzie, ale mam ku temu pewne argumenty. O tym jednak za moment, najpierw rzućcie okiem na to jak wygląda struktura projektu.

# AppBundle

AppBundle to główny moduł - zawierający dostępne endpointy (kontrolery/akcje, *wejście* do systemu) oraz implementacje niezbędnych interfejsów.

- Controller - definicja kontrolerów, akcji oraz adresów URL dostępnych dla aplikacji frontendowej,
- EventListener	- implementacja związana z przechwytywaniem zdarzeń, w przypadku aplikacji *Auditor* - funkcjonalności wykonywanych po akcjach zdefiniowanych w żądaniach - *Commands*,
- Repository - implementacja repozytorium w oparciu o ORM *Doctrine*.

AppBudle posiada referencje do wszystkich pozostałych modułów - spina je do *kupy* :)

# AuditorBundle

To możliwie najbardziej abstrakcyjny byt. Oczekuję interfejsów, a nie konkretnych implementacji. Umożliwia mi to, łatwą podmianę komponentów z których korzystam - np. w szybki sposób mogę odciąć się od korzystania z *Doctrine ORM*.

- Command - żądania, akcje zmieniające stan systemu (struktura danych oraz obsługa żądania), jeżeli wymaga zewnętrznych serwisów to oczekuje interfejsu,
- Entity - "pseudo" *Domain Object*, struktura danych, w faktycznym stanie są to obiekty zasilone danymi dostarczonymi za pomocą *ORM Doctrine*, przechowują dane, umożliwiają ustawianie oraz odczytywanie danych,
- Event - definicja zdarzenia - co się stało (nazwa klasy) oraz jakie informacje należy przekazać (właściwości klasy),
- Repository - interfejsy dostępu do repozytorium, odpowiednia implementacja znajduje się w *AppBudle*.

AuditorBundle posiada referencje do modułu *CqrsBundle*.

# CqrsBundle

To najbardziej uniwersalny *moduł*. Nie jest w żaden sposób skojarzony z resztą *bundle*.

- Commanding - definicja interfejsów oraz podstawowych klas wspierająca wykonywanie żądań w systemie,
- Eventing - obsługa zdarzeń wywoływanych po żądaniach przesłanych do systemu, ich definicja wraz z właściwościami,
- Exception - generyczne zdarzenia wyjątkowe, np. brak obsługi wywoływanego żądania (*CommandHandler*).

CqrsBundle nie posiada referencji do żadnych modułów. Jedynie do podstawowych bibliotek PHP 7.x.

# Dlaczego?

1) Mam jasny podział pomiędzy kontraktem (zdefiniowanym w AuditorBundle), a jego implementacją (czyli implementacją interfejsów w AppBundle). Jeżeli będę chciał oprzeć projekt o zupełnie inny *write model* - wystarczy, że podmienię definicję w konfiguracji DIC oraz dodam brakujące implementacje adapterów (dla *Repository*). Zostaje spełniona zasada SOLID - *Open/Closed Principle*.

2) Reużywalność - AuditorBundle, CqrsBundle mogę przekopiować do dowolnego innego projektu PHP, 

3) Jedno miejsce do wprowadzania konkretnej zmiany (przykład z punktu 1),

4) Jasność:
   - odpowiedzialności - każdy *bundle* ma swoje konkretne zadanie, można jeszcze zmniejszać granulację jednak na ten moment jest ona wystarczająca,
   - integracji - spięcie do kupy w AppBundle,
   - wymaganych referencji - AppBundle do wszystkich, AuditorBundle do CqrsBundle, CqrsBundle jedynie do bibliotek standardowych języka PHP.
