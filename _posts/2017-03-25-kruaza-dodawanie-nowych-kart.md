---
date: 2017-03-26 18:40
title: Krauza - jeszcze więcej o encjach
layout: post
description: Rozszerzenie informacji o klasie typu Entity 
tags: mksiazek dsp2017-mateusz krauza projekt php oop
category: dsp2017-mateusz
author: mksiazek
comments: true
---

Od ostatniego postu w aplikacji *Krauza* nie pojawiło się nic nowego pod względem technicznym. Zaimplementowałem możliwość
dodawania nowych kart. Proces jest bardzo podobny do rejestracji użytkowników, która została opisana w 
[poprzednim poście](/dsp2017-mateusz/2017/03/18/kruaza-rejestracja-uzytkownikow.html). Był to przy okazji dobry moment
aby poprawić wcześniej dodane elementy. Tym razem rozszerzę trochę informacje o encjach i ich zasadach.

## Entity raz jeszcze
Wcześniej prezentowałem encję użytkownika składająca się z elementów ValueObject, nie zawierała ona najważniejszego
elementu, który determinuje klasę jako encję - identyfikatora. Każdy obiekt powinien zawierać swój unikatowy id.

Poniżej przedstawiam kod nowej encji w projekcie - `Card`.

~~~ php
<?php

namespace Krauza\Entity;

use Krauza\ValueObject\CardWord;
use Krauza\Policy\IdPolicy;

class Card implements Entity
{
    private $id;
    private $obverse;
    private $reverse;

    public function __construct(CardWord $obverse, CardWord $reverse)
    {
        $this->obverse = $obverse;
        $this->reverse = $reverse;
    }

    public function setId(IdPolicy $id)
    {
        $this->id = $id;
    }

    public function getId(): string
    {
        return $this->id;
    }

    public function getReverse(): string
    {
        return $this->reverse;
    }

    public function getObverse(): string
    {
        return $this->obverse;
    }
}
~~~
Podczas dodawania identyfikatora do nowej klasy `Card`, ale i wcześniejszej `User` zastanawiałem się czy stworzyć klasę
abstrakcyjną, która będzie bazą dla `Entity` i będzie zawierała getter oraz setter dla własności `id`. Tak na początku
do tego podszedłem. Później jednak wycofałem się z tego pomysłu i utworzyłem interfejs, którego powinny implementować
encje. To rozwiązanie powoduje, że dla każdej nowej encji trzeba powielać praktycznie ten sam kod związany z
ustawianiem i pobieraniem id.

##### Czy to narusza zasadę DRY?
Krótko mówiąc... Nie. [Zasada DRY](https://pl.wikipedia.org/wiki/DRY) dotyczy powielania tej samej logiki,
która pojawia się w kodzie w kilku miejscach. Można ją wtedy zamknąć w jednej funkcji i tylko się do niej odwoływać.
Jeśli bierzemy pod uwagę encję to zdecydowanie lepszym rozwiązaniem jest traktowanie jej jako zamkniętą strukturę, która
nie jest zależna od innych elementów i zawiera cały zestaw własności i zachowań które ją dotyczą.

##### Nadrzędna klasa abstracyjna nie jest dobrym rozwiązaniem 
Tworzenie nadrzędnej klasy encji, po której dziedziczą wszystkie inne tylko po to aby zaoszczędzić kilka linii kodu
nie rekompensuje tego, że w późniejczym czasie architektura może stać się zaciemniona i niejasna, a to stwarza o wiele
większe zagrożenie dla projektu niż powielenie jednego settera i gettera.

Po za tym utworzenie abstrakcyjnej klasy często korci do tego żeby przyjmowała coraz więcej odpowiedzialności. Czasem
dostrzegamy podobieństwa między klasami, więc stwierdzamy, że można to wrzucić poziom wyżej aby zaoszczędzić kolejne
parę linii kodu... Po czasie wszystkie zależne klasy stają się "niewolnikami" klasy abstracyjnej. Dążenie do ciągłej
generyczności w końcu wychodzi bokiem i zmusza do jeszcze większego nakładu pracy kiedy okazuje się, że jednak niektóre
klasy muszą się czymś od siebie różnić.
