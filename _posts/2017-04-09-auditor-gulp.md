---
date: 2017-04-09 22:00
title: "Auditor - Gulp"
layout: post
description: "Auditor - Gulp czyli narzędzie automatyzujące pracę przy aplikacji frontendowej"
tags: apietka dsp2017-adrian auditor frontend gulp
category: dsp2017-adrian
author: apietka
comments: true
---

*[Gulp](http://gulpjs.com/)* jest narzędziem automatyzującym często powtarzających się zadań związanych z tworzeniem oprogramowania. Co mam dokładnie na myśli? Przykładem może być: 

- kompilacja plików LESS/SASS do CSS,
- konkatenacja i minifikacja plików JavaScript,
- budowanie archiwum z artefaktami gotowymi do wdrożenia na "produkcji",
- uruchamianie testów wraz z generowaniem raportu (np. z pokrycia kodu testami jednostkowymi).

Przykłady zastosowania można mnożyć praktycznie w nieskończoność. W projekcie *Auditor*, *Gulp* odpowiedzialny jest za trzy główne zadania:

1) weryfikację kodu JavaScript za pomocą *ESLint*,
2) "zbudowanie" pliku *index.html* - czyli dołączenie wszystkich niezbędnych plików CSS ora JS,
3) serwowanie plików statycznych.

# lint

# dist

# server
