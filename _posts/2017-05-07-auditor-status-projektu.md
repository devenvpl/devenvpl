---
date: 2017-05-07 14:45
title: "Auditor - Status projektu"
description: "Podsumowanie 10 tygodni od rozpoczęcia prac nad projektem Auditor."
tags: apietka dsp2017-adrian auditor
category: dsp2017-adrian
author: apietka
comments: true
layout: post-with-related-tag
related_tag: "auditor"
related_title: "Zobacz inne posty związane z projektem Auditor"
related_message: Projekt <i>Auditor</i> realizowany jest w ramach konkursu <a href="http://devstyle.pl/daj-sie-poznac/">Daj Się Poznać 2017</a>. Repozytorium kodu dostępne jest w serwisie <a href="https://github.com/devenvpl/auditor">GitHub</a>.
---

Minęły dwa miesiące od rozpoczęcia prac nad projektem *Auditor* realizowanym w ramach konkursu **Daj Się Poznać 2017**. W trakcie tych 10 tygodnii powstało [kilka artykułów](/tag/auditor.html) opisujących wdrożenie w projekcie architektury *CQRS* oraz prezentujących kilka aspektów pracy z użytymi narzędziami (np. frameworkiem *Symfony 3*). Z tej części jestem bardzo zadowolony ze względu na przekazanie swoich koncepcji w sposób opisowy.

Odbiło się jednak na samej aplikacji - o ile struktura kodu wydaje się być zorganizowana w sposób rozsądny, to o tyle jeszcze nic nie robi ;) Takie programowanie, dla samego programowania. Jak by jednak nie patrzeć, odcięcie się od codziennych obowiązków zawodowych (efekt, dostarczanie, nowy release :)) i przyjęcie założenia *wycacany kodzik* jest przyjemne.

## Trochę statystyk

Projekt *Auditor* to zaledwie:

- *25 commitów*,
- *8 unit testów*,
- *14 success buildów*,
- oraz *3 failed buildy* (spowodowane brakiem uruchomienia testów przed *commitem* zmian :)).

Średni czas trwania *builda* w serwisie Travis CI to około 2 minuty. W tym czasie wykonuje się uruchomienie środowiska, sklonowanie repozytorium, pobranie wymaganych bibliotek za pomocą *Composer* oraz uruchomienie testów.
   
## Co zrealizowano?

O założeniach i wymaganiach względem projektu *Auditor* rozpisałem się w artykule "[Auditor - Specyfikacja](/dsp2017-adrian/2017/03/02/auditor-specyfikacja.html)". Odwołując się do zdefiniowanych wymagań - dwa ważne aspekty - małą ilość małych commitów oraz skupenie się na przygotowaniu struktury aplikacji, przełożyły się na realizację funkcji aplikacji. Przeglądając wyznaczone *milestones* udało się "odchaczyć" tylko jeden z pięciu: "Konfiguracja projektu oraz CI, struktura kodu".

Natomiast pod względem wymagań niefunkcjonalnych projekt wypada zdecydowanie lepiej. Spełnia aktualnie wszystkie z nich. Można popracować jeszcze nad środowiskiem uruchomieniowym, aby maksymalnie je uprościć wykorzystując do tego np. *[Dockera](https://www.docker.com/)* lub *[Vagranta](https://www.vagrantup.com/)*.

## Podsumowanie

Do końca *DSP 2017* pozostały 3 tygodnie. Nadszedł więc czas na obranie odpowiedniego kierunku. Od teraz skupiam się na uruchomieniu podstawowej wersji aplikacji - dostarczając jej działającą instancję. Czyli najważniejsza jest teraz - **implementacja kodu odpowiadającego za funkcje oprogramowania**. Aktualnie cały stworzony kod to fundament projektu - jego podstawowa struktura i jednocześnie rozwiązanie architektury aplikacji.

Następne, a jednocześnie ostatnie podsumowanie projeku (w ramach *DSP 2017*) - po 31 maja 2017.