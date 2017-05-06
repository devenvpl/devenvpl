---
date: 2017-05-06 23:30
title: "PHP - Biblioteka SPL - Klasa SplObjectStorage"
description: "Wprowadzenie w świat biblioteki standardowej PHP - SPL (Standard PHP Library). Omówienie klasy SplObjectStorage."
tags: apietka dsp2017-adrian php spl
category: dsp2017-adrian
author: apietka
comments: true
layout: post-with-related-tag
related_tag: "spl"
related_title: "Zobacz inne posty związane z biblioteką standardową PHP - SPL"
---

Klasa *SplObjectStorage* dostarcza dwa rozwiązania:

#### Zarządzanie obiektami, zapewniając ich unikalność w obrębie instancji.

~~~php
<?php

$storage = new SplObjectStorage();

$object = new StdClass();
$object->name = 'Object';

$storage->attach($object);
$storage->attach($object);
~~~

Dodanie tej samej instancji obiektu nie powoduje jej duplikacji w *storage*. Jedna instancja obiektu = maksymalnie jedna instancja w *storage*.

#### Mapowanie obiekt => dane.

Ciekawsze według mnie zastosowanie, umożliwiające identyfikację *jakiś* danych za pomocą obiektów. Instancja obiektu staje się *kluczem dostępowym* do danych.

~~~php
<?php

$storage = new SplObjectStorage();

$object1 = new StdClass();
$object1->name = 'Object 1';

$object2 = new StdClass();
$object2->name = 'Object 2';

$storage->attach($object1, [1, 2, 3]);
$storage->attach($object2, 'Lorem ipsum.');
~~~

Istnieje również alternatywny sposób wiązania obiektu z danymi. Klasa implementuje interfejs *[ArrayAccess](http://php.net/manual/en/class.arrayaccess.php)*, a dzięki temu, do obiektu *storage* można odwoływać się tak samo jak do normalnej tablicy:

~~~php
<?php

$storage[$object1] = [1, 2, 3];
$storage[$object2] = 'Lorem ipsum.';

var_dump($storage[$object1]);
~~~

## Podstawowe operacje

*SplObjectStorage* udostępnia dość rozbudowane *API* (21 metod publicznych). Postaram się zaprezentować jedynie wybrane z nich. Poniżej znajduje się kontekst wszystkich opisanych przykładów.

~~~php
<?php

$storage = new SplObjectStorage();

for ($i = 1; $i <= 3; $i++) {
    $object = new StdClass();
    $object->name = 'Object - '.$i;

    $storage->attach($object);
}
~~~

### Dodaj obiekt do storage

~~~php
<?php

$storage->attach(new StdClass());
~~~

### Usuń obiekt z storage

~~~php
<?php

$stdObject = new StdClass();
$storage->attach($stdObject);

$storage->detach($stdObject);
~~~

### Zwróć ilość obiektów w storage

~~~php
<?php

var_dump($storage->count()); // 3
~~~

### Dodaj wszystkie obiekty z innej instancji *SplObjectStorage*

~~~php
<?php

$storage2 = new SplObjectStorage();
$storage2->attach(new StdClass);
$storage2->attach(new StdClass);

$storage->addAll($storage2);

echo $storage->count(); // 5
~~~

### Iterowanie po dodanych obiektach

~~~php
<?php

foreach($storage as $item) {
    echo $item->name . PHP_EOL;
}
~~~

### Sprawdź czy w storage istnieje konkretny obiekt

~~~php
<?php

$newObject = new StdClass();

var_dump($storage->contains($newObject)); // false
$storage->attach($newObject);
var_dump($storage->contains($newObject)); // true
~~~

### Serializacja

~~~php
<?php

echo $storage->serialize();

// x:i:3;O:8:"stdClass":1:{s:4:"name";s:10:"Object - 1";},N;;O:8:"stdClass":1:{s:4:"name";s:10:"Object - 2";},N;;O:8:"stdClass":1:{s:4:"name";s:10:"Object - 3";},N;;m:a:0:{}
~~~

### Deserializacja

~~~php
<?php

$serialized = 'x:i:3;O:8:"stdClass":1:{s:4:"name";s:10:"Object - 1";},N;;O:8:"stdClass":1:{s:4:"name";s:10:"Object - 2";},N;;O:8:"stdClass":1:{s:4:"name";s:10:"Object - 3";},N;;m:a:0:{}';

$storage->unserialize($serialized);

var_dump($storage);
~~~

Wynikiem będzie storage z 3 obiektami posiadającymi następujące właściwości *name*: Object - 1; Object - 2; Object - 3.

## Przykład użycia

Wiesz już co oferuje klasa *SplObjectStorage*, jednak rodzi się pytanie - gdzie można ją realnie zastosować? Ja użyłem jej przy okazji implementacji wzorca *Observer*. Wykorzystując przy tym dwie inne klasy wchodzące w skład biblioteki *SPL* - *SplObserver* oraz  *SplSubject*. Kod źródłowy tego przykładu dostępny jest na moim profilu [Github](https://github.com/adrianpietka/notes/blob/master/php-spl/spl-observer-pattern.php).