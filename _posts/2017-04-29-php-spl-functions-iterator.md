---
date: 2017-04-29 20:00
title: "PHP - Biblioteka SPL - Funkcje iterator_*"
layout: post
description: "Wprowadzenie w świat biblioteki standardowej PHP - SPL (Standard PHP Library). Omówienie funkcji iterator_*."
tags: apietka dsp2017-adrian php spl
category: dsp2017-adrian
author: apietka
comments: true
---

Kontynuując rozpoczętą serię nt. biblioteki standardowej [SPL](/dsp2017-adrian/2017/04/22/php-spl-functions.html) chciałbym przedstawić funkcje wspomagające pracę z iteratorami. Praktycznie pracując na co dzień z językiem PHP mamy do czynienia z iteratorami. Na początek jednak powinniśmy sobie jednak zadać proste pytanie - czym one tak na prawdę są?

## Czym są iteratory?

W języku PHP mamy możliwość iteracji po tablicach oraz obiektach. Kiedy wykonamy mniej więcej taki kod:

~~~php
<?php

foreach($items as $item) {
   // ...
}
~~~

### Interfejs iteratora

Implementacja interfejsu ```Iterator``` umożliwia nam zdefiniowanie w jaki sposób ma zachować się klasa w momencie kiedy zdecydujemy się iterować po jej instancji. Interfejs wymaga zaimplementowania pięciu następujących metod:

- ```current()``` - metoda zwracająca aktualny element iteracji,
- ```key()``` - klucz aktualnego elementu,
- ```next()``` - zmiana pozycji z aktualnego elementu na następny,
- ```rewind()``` - zmiana pozycji na pierwszy element (powrót na początek), jest wywoływana za każdym razem (jako pierwsza) gdy zaczynamy iterować po obiekcie lub wywołana zostanie funkcja ```iterator_*```,
- ```valid()``` - sprawdzenie czy aktualna pozycja jest prawidłowa (np. czy istnieje index w tablicy), jeżeli aktualna pozycja jest nieprawidłowa, to iteracja zostaje przerwana (po jej przerwaniu nie wykonuje się ```rewind()```!)

Dzięki implementacji w.w metod, wskażemy i zwrócimy elementy obiektu podczas iteracji po obiekcie. 

### Implementacja przykładowego iteratora

~~~php
<?php

class CarsIterator implements Iterator
{
    private $position;
    private $cars = [
        'BMW', 'Audi', 'KIA', 'Opel', 'Ford'
    ];

    public function rewind() {
        $this->position = 0;
    }

    public function current() {
        return $this->cars[$this->position];
    }

    public function key() {
        return $this->position;
    }

    public function next() {
        ++$this->position;
    }

    public function valid() {
        return isset($this->cars[$this->position]);
    }
}
~~~

W dalszej części artykułu będę odnosił się do instancji zaprezentowanej powyżej klasy. W przykładach tych, rozbudowałem każdą z metod o dodatkową czynność: ```var_dump(__METHOD__);```. Wszystko po to aby zobaczyć, które z metod obiektu wywoływane są dla poszczególnych przpadków - iteracji, wywołań funkcji z zakresu ```iterator_*```.

## iterator_apply

```
int iterator_apply ( Traversable $iterator , callable $function [, array $args ] )
```



## iterator_count

```
int iterator_count ( Traversable $iterator )
```

Funkcja zwraca ilość elementów obiektu implementującego interfejs ```Traversable``` (Interfejs ```Iterator``` rozszerza ```Traversable```). Poniższy kod:

~~~php
<?php

$cars = new CarsIterator();
var_dump(iterator_count($cars));
~~~

Zwróci wartość typu integer: ```int(5)```. Podczas wykonania funkcji na obiekcie implementującym interfejs ```Iterator``` zostaną wywołane następujące metody obiektu:

```
CarsIterator::rewind
CarsIterator::valid   // cykl - start
CarsIterator::next    // cykl - koniec
CarsIterator::valid   // kolejny cykl
...
```

## iterator_to_array

```
array iterator_to_array ( Traversable $iterator [, bool $use_keys = true ] )
```

~~~php
<?php

$cars = new CarsIterator();
var_dump(iterator_to_array($cars));
~~~

```
array(5) {
  [0] => string(3) "BMW"
  [1] => string(4) "Audi"
  [2] => string(3) "KIA"
  [3] => string(4) "Opel"
  [4] => string(4) "Ford"
}
```

```
CarsIterator::rewind
CarsIterator::valid    // cykl - start
CarsIterator::current
CarsIterator::key
CarsIterator::next     // cykl - koniec
CarsIterator::valid    // kolejny cykl
...
```
