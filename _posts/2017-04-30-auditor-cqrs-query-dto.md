---
date: 2017-04-30 23:30
title: "Auditor - Wykorzystanie obiektów DTO w Read Model"
layout: post
description: "Rozwinięcie tematu CQRS - Query w projekcie Auditor. Przedstawienie obiektów DTO."
tags: apietka dsp2017-adrian auditor php cqrs dto patterns
category: dsp2017-adrian
author: apietka
comments: true
---

Nawiązując do umieszczonego na łamach bloga artykułu "[Auditor - CQRS - Query](/dsp2017-adrian/2017/03/30/auditor-cqrs-query.html)" chciałbym rozwinąć nieco bardziej tematykę zwracania danych przez *Query*. W opisywanej implementacji *Query*, wszystkie dane były reprezentowane za pomocą tablic asocjacyjnych - pojedyńczy rekord jak i również kolekcja rekordów. W taki sposób były przekazywane do warstwy wyżej. Niestety nie daje to konkretnej informacji na temat faktycznej zwracanej struktury. Były to tablice asocjacyjne, zawierające *jakieś* dane w postaci jakiś *klucz* => wartość. Tyle.

Moim celem było zakomunikowanie w jasny sposób, jakie konkretnie informacje zwraca dane *Query*. Rozwiązanie zostało oparte o wzorzec *DTO*, o którym przeczytasz poniżej.

## DTO

*DTO* czyli *Data Transfer Object* jest wzorcem dystrybucji. Jego zadaniem jest grupowanie danych do postaci obiektu, i przenoszenia ich pomiędzy:

- metodami, klasami, modułami, warstwami aplikacji,
- procesami, aplikacjami, systemami,
- i w każdym innym przypadku gdy jest to niezbędne, czytaj - gdy zachodzi potrzeba przekazania danych.

Taki kontener na dane, który nie zawiera żadnej logiki. Łatwo go zserializować do dowolnego formatu (np. *JSON*, *XML*), a następnie przywrócić do postaci obiektu. *DTO* to obiekty niezależne od domeny, ale także domena jest niezależna od nich - wykluczając obiekty które na podstawie *DTO* tworzą obiekty domenowe (i odwrotnie) - np. wykorzystując wzroce kreacyjne.

## Query a DTO

W projekcie *Auditor* wyróżniam dwa typy obiektów DTO które zwracane są przez *Query*:

### DTO reprezentujące pojedyńczy byt

### DTO będące kolekcją innych DTO

## Podsumowanie