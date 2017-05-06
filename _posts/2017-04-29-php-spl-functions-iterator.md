---
date: 2017-04-29 20:00
title: "PHP - Biblioteka SPL - Funkcje iterator_*"
description: "Wprowadzenie w świat biblioteki standardowej PHP - SPL (Standard PHP Library). Omówienie funkcji iterator_*."
tags: apietka dsp2017-adrian php spl
category: dsp2017-adrian
author: apietka
comments: true
layout: post-with-related-tag
related_tag: "spl"
related_title: "Zobacz inne posty związane z biblioteką standardową PHP - SPL"
---

Kontynuując rozpoczętą serię nt. biblioteki standardowej [SPL](/dsp2017-adrian/2017/04/22/php-spl-functions.html) chciałbym przedstawić funkcje wspomagające pracę z iteratorami. Pracując na co dzień z językiem *PHP* mamy do czynienia z iteratorami. Na początek powinniśmy sobie jednak zadać proste pytanie - czym one tak na prawdę są?

## Czym są iteratory?

W języku *PHP* mamy możliwość iteracji po tablicach oraz obiektach. Wykorzystujemy do tego np. pętlę ```foreach```:

~~~php
<?php

foreach($items as $item) {
   // ...
}
~~~

W przypadku tablic, iteracja odbywa się po wszystkich jej elementach. Jak to wygląda dla obiektów? Otóż, iteracja będzie odbywać się jedynie po publicznych właściwościach obiektu. Aby zapanować nad jej sposobem, należy zaimplementować interfejs [```Iterator```](http://php.net/manual/pl/class.iterator.php). Mówimy wtedy, że obiekt jest *iteratorem*.

Biblioteka *SPL* udostępnia [zbiór kilkunastu gotowych iteratorów](http://php.net/manual/pl/spl.iterators.php) (gotowych do wykorzystania klas). W kolejnych częściach serii o bibliotece *SPL* postaram się przybliżyć większość z nich.

### Interfejs iteratora

Implementacja interfejsu ```Iterator``` umożliwia zdefinowanie zachowania obiektu, w momencie iterowania po nim. Można wskazać, że dane po których chcemy iterować znajdują się w wewnętrznej tablicy obiektu lub pochodzą z dowolnego, innego źródła. To wszystko zależy od nas, musimy jedynie dostarczyć implementację, zachowującą się tak jak wymaga tego interfejs. ```Iterator``` wymaga zaimplementowania pięciu następujących metod:

- ```current()``` - metoda zwracająca aktualny element iteracji,
- ```key()``` - metoda zwracająca klucz aktualnego elementu iteracji,
- ```next()``` - zmiana klucza z aktualnego elementu na następny,
- ```rewind()``` - zmiana klucza na klucz pierwszego elementu (powrót na początek), metoda wywoływana za każdym razem (jako pierwsza) gdy zaczynamy iterować po obiekcie lub wywołana zostanie funkcja ```iterator_*```,
- ```valid()``` - sprawdzenie czy aktualny klucz jest prawidłowy (np. czy istnieje element pod wskazanym kluczem w tablicy), jeżeli aktualny klucz jest nieprawidłowy, to iteracja zostaje przerwana (po jej przerwaniu nie wykonuje się ```rewind()```!)

Dzięki implementacji w.w metod, wskażemy i zwrócimy elementy podczas iteracji po obiekcie.

### Implementacja przykładowego iteratora

Przykładowy sposób na zaimplementowanie metod interfejsu ```Iterator``` prezentuję w postaci klasy ```CarsIterator```. Dane zawarte zostały w postaci tablicy z indeksami od 0 do 4.

~~~php
<?php

class CarsIterator implements Iterator
{
    private $position;
    private $cars = ['BMW', 'Audi', 'KIA', 'Opel', 'Ford'];

    public function current()
    {
        return $this->cars[$this->position];
    }

    public function key()
    {
        return $this->position;
    }

    public function next()
    {
        ++$this->position;
    }

    public function rewind()
    {
        $this->position = 0;
    }
    
    public function valid()
    {
        return array_key_exists($this->position, $this->cars);
    }
}
~~~

Metoda:

- ```current()``` - zwraca element z tablicy ```$this->cars``` dla aktualnej pozycji,
- ```key()``` - zwraca aktualną pozycję,
- ```next()``` - inkrementuje o jeden aktualną pozycję,
- ```rewind()``` - ustawia aktualną pozycję na 0,
- ```valid()``` - sprawdza czy istnieje element w tablicy pod wskazaną pozycją.

W dalszej części artykułu będę odnosił się do instancji zaprezentowanej powyżej klasy. W przykładach tych, rozbudowałem każdą z metod o dodatkową czynność: ```var_dump(__METHOD__);```. Wszystko po to aby zobaczyć, które z metod obiektu wywoływane są dla poszczególnych przypadków - iteracji, wywołań funkcji z zakresu ```iterator_*```.

## iterator_apply

```
int iterator_apply ( Traversable $iterator , callable $function [, array $args ] )
```

Funkcja *iterator_apply* pozwala na wykonanie dowolnej funkcji dla każdego elementu w iteratorze. Drugi parametr przyjmuje typ *[callable](http://php.net/manual/en/language.types.callable.php)* (np. nazwa funkcji, tablica lub funkcja anonimowa), jest to funkcja (lub metoda obiektu) która zostanie wywołana dla każdego elementu. Trzeci parametr definiuje jakie parametry zostaną przekazane do wywoływanej funkcji.

~~~php
<?php

function lower(Iterator $iterator) {
    echo strtolower($iterator->current()) . PHP_EOL;
    return true;
}

iterator_apply($cars, 'lower', array($cars));
~~~

Wynikiem wykonania *iterator_apply*, będzie lista nazw marek samochodów. Każda z nazw została sprowadzona do małych liter.

```
bmw
audi
kia
opel
ford
```

Przy wywołaniu *iterator_apply*, zostaną wykonane następujące metody obiektu:

```
CarsIterator::rewind
CarsIterator::valid    // cykl - start
CarsIterator::current
CarsIterator::next     // cykl - koniec
CarsIterator::valid    // kolejny cykl lub zakończenie jeśli valid() zwróci false
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

Zwróci wartość typu integer: ```int(5)```. Przy wywołaniu *iterator_count*, zostaną wykonane następujące metody obiektu:

```
CarsIterator::rewind
CarsIterator::valid   // cykl - start
CarsIterator::next    // cykl - koniec
CarsIterator::valid   // kolejny cykl lub zakończenie jeśli valid() zwróci false
...
```

## iterator_to_array

```
array iterator_to_array ( Traversable $iterator [, bool $use_keys = true ] )
```

Funkcja *iterator_to_array* konwertuje obiekt iteratora do tablicy. Drugi parametr funkcji, wskazuje czy podczas konwertowania, klucz zawarty w iteratorze (metoda *key()*) ma stać się kluczem dla elementu w tablicy - domyślnie takie jest zachowanie. Jeśli przekażemy wartość *false* - kluczami elementów będą wartości *integer*, nadawane w sposób inkrementacyjny (zaczynając od 0).

~~~php
<?php

$cars = new CarsIterator();
var_dump(iterator_to_array($cars));
~~~

Funkcja zwróci tablicę z pięcioma elementami:

```
array(5) {
  [0] => string(3) "BMW"
  [1] => string(4) "Audi"
  [2] => string(3) "KIA"
  [3] => string(4) "Opel"
  [4] => string(4) "Ford"
}
```

Przy wywołaniu *iterator_to_array*, zostaną wykonane następujące metody obiektu:

```
CarsIterator::rewind
CarsIterator::valid    // cykl - start
CarsIterator::current
CarsIterator::key
CarsIterator::next     // cykl - koniec
CarsIterator::valid    // kolejny cykl lub zakończenie jeśli valid() zwróci false
...
```
