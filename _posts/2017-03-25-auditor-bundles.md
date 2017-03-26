---
date: 2017-03-25 22:00
title: "Auditor - Bundles"
layout: post
description: "Podzia³ projektu Auditor na Symfonowe bundle"
tags: apietka dsp2017-adrian auditor symfony bundle
category: dsp2017-adrian
author: apietka
comments: true
---

W mojej przygodzie programistycznej wspiera³em zespo³y projektowe w tworzeniu aplikacji w oparciu o ró¿ne platformy, a co za tym idzie równie¿ ró¿ne jêzyki programowania i frameworki. W projektach .NET bardzo podoba mi siê uk³adanie struktury solucji. Dowolnoœæ w tworzeniu podfolderów, podzia³ na projekty. W ekosystemie Symfony mamy tzw. podzia³ na Bundle. Jest on co prawda doœæ restrykcyjnie opisany w dokumentacji - "modu³y które mo¿na reu¿ywaæ pomiêdzy projektami". Moje rowziw¹zanie troszkê przeczy tej g³ównej zasadzie, ale mam ku temu pewne argumenty. O tym jednak za moment, najpierw rzuæcie okiem na to jak wygl¹da struktura projektu.

# AppBundle

AppBundle to g³ówny modu³ - zawieraj¹cy dostêpne endpointy (kontrolery) oraz implementacje niezbêdnych interfejsów.

- Controller - definicja kontrolerów - czyli adresów URL dostêpnych dla aplikacji frontendowej,
- EventListener	- implementacja zwi¹zana z przechwytywaniem zdarzeñ, w przypadku aplikacji *Auditor* - funkcjonalnoœci wykonywanych po akcjach zdefiniowanych w ¿adaniach - *Commands*,
- Repository - implementacja repozytorium w oparciu o ORM *Doctrine*.

AppBudle posiada referencje do wszystkich pozosta³ych modu³ów - spina je do *kupy* :)

# AuditorBundle

To mo¿liwie najbardziej abstrakcyjny byt. Wszelka implementacja podlega zasadzie *Design by Contract* (poza zaleznoœci¹ od CqrsBundle). Wszystkie zewnêtrzne zale¿noœci wykorzystuj¹ interfejsy. Po to by dostarczyæ w fazie implementacji odpowiedni¹ klasê.

- Command - ¿adania, akcje zmieniaj¹ce stan systemu (struktura danych oraz obs³uga ¿¹dania - je¿eli korzysta z zewnêtrznych serwisów, korzysta z zdefiniowanych interfejsów),
- Entity - "pseudo" domain obejcts, w faktycznym stanie s¹ to encje dostarczone za pomoc¹ *ORM Doctrine*, przechowuj¹ dane, umo¿liwiaj¹ ustawianie oraz odczytywanie danych,
- Event - definicja zdarzenia - co siê sta³o (nazwa klasy), jakie informacje nale¿y przekazajæ (w³aœciwoœci klasy),
- Repository - interfejsy dostêpu do repozytorium, implementowane w *AppBudle*.

AuditorBundle posiada referencje do modu³u *CqrsBundle*.

# CqrsBundle

To najbardziej uniwersalny *modu³*. Nie jest w ¿aden sposób skojarzonuy

- Commanding - 
- Eventing -
- Exception -

CqrsBundle nie posiada referencji do ¿adnych modu³ów. Jedynie do podstawowych bibliotek PHP 7.x.

# Dlaczego?

Mam jasny podzia³ pomiêdzy kontraktem (zdefiniowanym w AuditorBundle), a jego implementacj¹ (czyli implementacj¹ interfejsów w AppBundle). Je¿eli bêdê chcia³ oprzeæ projekt o zupe³nie inny *model write* - wystarczy, ¿e podmieniê definicjê w konfiguracji DIC oraz dodam brakuj¹ce implementacje adapterów (dla *Repository*). Definicja  z zasad SOLID zostaje spe³niona - Open/Closed Principle.

Reu¿ywalnoœæ (CqrsBundle), podmiana (implementacja interfejsów z AuditorBundle) - ¿yæ i nie umieraæ :)