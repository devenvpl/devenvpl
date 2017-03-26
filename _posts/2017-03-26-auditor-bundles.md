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

W mojej przygodzie programistycznej wspierałem zespoły projektowe w tworzeniu aplikacji w oparciu o różne platformy, a co za tym idzie również różne języki programowania i frameworki. W projektach .NET bardzo podoba mi się układanie struktury solucji. Dowolność w tworzeniu podfolderów, podział na projekty. W ekosystemie Symfony mamy tzw. podział na Bundle. Jest on co prawda dość restrykcyjnie opisany w dokumentacji - "moduły które można reużywać pomiędzy projektami". Moje rowziwązanie troszkę przeczy tej głównej zasadzie, ale mam ku temu pewne argumenty. O tym jednak za moment, najpierw rzućcie okiem na to jak wygląda struktura projektu.

# AppBundle

AppBundle to główny moduł - zawierający dostępne endpointy (kontrolery) oraz implementacje niezbędnych interfejsów.

- Controller - definicja kontrolerów - czyli adresów URL dostępnych dla aplikacji frontendowej,
- EventListener	- implementacja związana z przechwytywaniem zdarzeń, w przypadku aplikacji *Auditor* - funkcjonalności wykonywanych po akcjach zdefiniowanych w żadaniach - *Commands*,
- Repository - implementacja repozytorium w oparciu o ORM *Doctrine*.

AppBudle posiada referencje do wszystkich pozostałych modułów - spina je do *kupy* :)

# AuditorBundle

To możliwie najbardziej abstrakcyjny byt. Wszelka implementacja podlega zasadzie *Design by Contract* (poza zaleznością od CqrsBundle). Wszystkie zewnętrzne zależności wykorzystują interfejsy. Po to by dostarczyć w fazie implementacji odpowiednią klasę.

- Command - żadania, akcje zmieniające stan systemu (struktura danych oraz obsługa żądania - jeżeli korzysta z zewnętrznych serwisów, korzysta z zdefiniowanych interfejsów),
- Entity - "pseudo" domain obejcts, w faktycznym stanie są to encje dostarczone za pomocą *ORM Doctrine*, przechowują dane, umożliwiają ustawianie oraz odczytywanie danych,
- Event - definicja zdarzenia - co się stało (nazwa klasy), jakie informacje należy przekazajć (właściwości klasy),
- Repository - interfejsy dostępu do repozytorium, implementowane w *AppBudle*.

AuditorBundle posiada referencje do modułu *CqrsBundle*.

# CqrsBundle

To najbardziej uniwersalny *moduł*. Nie jest w żaden sposób skojarzony z resztą *bundle*.

- Commanding - definicja interfejsów oraz podstawowych klas wspierająca wykonywanie żądań w systemie,
- Eventing - obsługa zdarzeń wywoływanych po żądaniach przesłanych do systemu, ich definicja wraz z właściwościami,
- Exception - generyczne zdarzenia wyjątkowe, np. brak obsługi wywoływanego żądania (*CommandHandler*).

CqrsBundle nie posiada referencji do żadnych modułów. Jedynie do podstawowych bibliotek PHP 7.x.

# Dlaczego?

Mam jasny podział pomiędzy kontraktem (zdefiniowanym w AuditorBundle), a jego implementacją (czyli implementacją interfejsów w AppBundle). Jeżeli będę chciał oprzeć projekt o zupełnie inny *model write* - wystarczy, że podmienię definicję w konfiguracji DIC oraz dodam brakujące implementacje adapterów (dla *Repository*). Definicja  z zasad SOLID zostaje spełniona - Open/Closed Principle.

Reużywalność (CqrsBundle), podmiana (implementacja interfejsów z AuditorBundle) - żyć i nie umierać :)
