---
date: 2017-04-22 23:00
title: "PHP - Biblioteka SPL - Funkcje class_* oraz spl_*"
description: "Wprowadzenie w świat biblioteki standardowej PHP - SPL (Standard PHP Library). Omówienie funkcji class_* oraz spl_*."
tags: apietka dsp2017-adrian php spl
category: dsp2017-adrian
author: apietka
comments: true
layout: post-with-related-tag
related_tag: "spl"
related_title: "Zobacz inne posty związane z biblioteką standardową PHP - SPL"
---

Chciałbym aby ten artykuł był początkiem serii postów przybliżających możliwości SPL - czyli *Standard PHP Library*.

*SPL* jest zbiorem funkcji, struktur danych, iteratorów, wyjątków oraz klas do pracy z plikami. Podsumowując - zbiorem funkcji, interfejsów i klas pomagających rozwiązać typowe problemy.

Jest to wbudowana biblioteka, której nie musimy instalować osobno ponieważ wraz z posiadanym interpreterem języka PHP (od wersji 5.0) mamy dostęp do jej elementów.

Niestety elementy biblioteki nie są opakowane żadną przestrzenią nazw - nieco zrozumiałe, ponieważ *SPL* pojawił się w PHP 5.0, czyli w momencie kiedy przestrzenie nazw nie były jeszcze zaimplementowane. Drugi minus za dodatkowy prefix (*Spl*) przy nazwach niektórych klas (np. *SplFixedArray*) - moim zdaniem niepotrzebna nadmiarowość.

W tym poście skupię się na przedstawieniu części funkcji zawartych w bibliotece *SPL*, poza ```spl_autoload``` (i pochodnych: ```spl_autoload_*```) oraz ```iterator_*```. O nich napiszę osobno.

## class_implements

```
array class_implements ( mixed $class [, bool $autoload = true ] )
```

Funkcja *class_implements* zwraca listę interfejsów, które zostały zaimplementowane przez klasę. Pierwszy argument przyjmuje nazwę klasy (wraz z przestrzenią nazwy w której się znajduje) lub jej instancję. Drugi wartość *bool* (domyślnie *true*) - oznacza ona, że do załadowania klasy (dla jej podanej nazwy) ma zostać uwzględniona funkcja magiczna ```__autoload```.

Rezultatem wywołania będzie tablica asocjacyjna (klucz => wartość) z nazwą zaimplementowanego interfejsu (jako klucz i wartość) wraz z uwzględnieniem *namespace*.

~~~php
<?php

namespace DevEnv;

interface Foo {}
interface Abc {}

class Bar implements Foo, Abc {}

$bar = new Bar();

var_dump(class_implements($bar));
var_dump(class_implements('DevEnv\Bar'));
~~~

W obu przypadkach wynikiem jest:

```
array(2) {
  ["DevEnv\Foo"] => string(10) "DevEnv\Foo"
  ["DevEnv\Abc"] => string(10) "DevEnv\Abc"
}
```

Jeśli natomiast odwołanie następuje do klasy która nie istnieje:

~~~php
<?php

var_dump(class_implements('UnknownClass'));
~~~

Otrzymamy błąd typu *warning*, a sama funkcja zwróci *false*:

```
Warning: class_implements(): Class UnknownClass does not exist and could not be loaded in class_implements.php on line X
bool(false)
```

## class_parents

```
array class_parents ( mixed $class [, bool $autoload = true ] )
```

Funkcja *class_parents* zwraca listę klas nadrzędnych. Argumenty funkcji są identyczne jak w przypadku *class_implements*.

~~~php
<?php

namespace DevEnv;

class Foo {}
class Bar extends Foo {}
class Abc extends Bar {}

$abc = new Abc();

var_dump(class_parents($abc));
var_dump(class_parents('DevEnv\Abc'));
~~~

Rezultatem wywołania będzie tablica asocjacyjna (klucz => wartość) z nazwą klasy nadrzędnej (jako klucz i wartość) wraz z uwzględnieniem *namespace*. W obu przypadkach wynik jest następujący:

```
array(2) {
  ["DevEnv\Bar"] => string(10) "DevEnv\Bar"
  ["DevEnv\Foo"] => string(10) "DevEnv\Foo"
}
```

W momencie podania nieistniejącej nazwy klasy, interpreter PHP zachowa się identycznie jak w przypadku *class_implements*.

## class_uses

```
array class_uses ( mixed $class [, bool $autoload = true ] )
```

Funkcja *class_uses* zwraca listę użytych przez klasę definicji *trait*. Argumenty funkcji są identyczne jak w przypadku *class_implements* oraz *class_parents*. Rezultatem jest tak jak w przypadku w.w funkcji - tablica asocjacyjna z nazwami *traits*. Warto pamiętać, że w tym przypadku nie są dołączane *traits* klas nadrzędnych. Obrazuje to przykład przedstawiony poniżej:

~~~php
<?php

namespace DevEnv;

trait Foo {}
trait Bar {}
trait Baz {}

class Qux {
    use Baz;
}

class Quux extends Qux {
    use Foo;
    use Bar;
}

$quux = new Quux();

var_dump(class_uses($quux));
var_dump(class_uses('DevEnv\Quux'));
~~~

Wynik powyższego kodu jest następujący (identyczny dla obu wywołań):

```
array(2) {
  ["DevEnv\Foo"] => string(10) "DevEnv\Foo"
  ["DevEnv\Bar"] => string(10) "DevEnv\Bar"
}
```

Jeśli natomiast wywołamy funkcję *class_uses* dla klasy *Qux*, to wynikiem będzie:

```
array(1) {
  ["DevEnv\Baz"] => string(10) "DevEnv\Baz"
}
```

W przypadku podania nieistniejącej nazwy klasy, funkcja poinformuje nas błędem podobnie jak w przypadku *class_implements* oraz *class_parents*.

## spl_classes

```
array spl_classes ( void )
```

Funkcja *spl_classes* zwraca listę dostępnych klas biblioteki *SPL*. W przypadku interpretera PHP w wersji 7.1.1 (ZTS MSVC14 (Visual C++ 2015) x86) lista zwórconych klas wygląda następująco:

```
Array(
  [AppendIterator] => AppendIterator
  [ArrayIterator] => ArrayIterator
  [ArrayObject] => ArrayObject
  [BadFunctionCallException] => BadFunctionCallException
  [BadMethodCallException] => BadMethodCallException
  [CachingIterator] => CachingIterator
  [CallbackFilterIterator] => CallbackFilterIterator
  [Countable] => Countable
  [DirectoryIterator] => DirectoryIterator
  [DomainException] => DomainException
  [EmptyIterator] => EmptyIterator
  [FilesystemIterator] => FilesystemIterator
  [FilterIterator] => FilterIterator
  [GlobIterator] => GlobIterator
  [InfiniteIterator] => InfiniteIterator
  [InvalidArgumentException] => InvalidArgumentException
  [IteratorIterator] => IteratorIterator
  [LengthException] => LengthException
  [LimitIterator] => LimitIterator
  [LogicException] => LogicException
  [MultipleIterator] => MultipleIterator
  [NoRewindIterator] => NoRewindIterator
  [OuterIterator] => OuterIterator
  [OutOfBoundsException] => OutOfBoundsException
  [OutOfRangeException] => OutOfRangeException
  [OverflowException] => OverflowException
  [ParentIterator] => ParentIterator
  [RangeException] => RangeException
  [RecursiveArrayIterator] => RecursiveArrayIterator
  [RecursiveCachingIterator] => RecursiveCachingIterator
  [RecursiveCallbackFilterIterator] => RecursiveCallbackFilterIterator
  [RecursiveDirectoryIterator] => RecursiveDirectoryIterator
  [RecursiveFilterIterator] => RecursiveFilterIterator
  [RecursiveIterator] => RecursiveIterator
  [RecursiveIteratorIterator] => RecursiveIteratorIterator
  [RecursiveRegexIterator] => RecursiveRegexIterator
  [RecursiveTreeIterator] => RecursiveTreeIterator
  [RegexIterator] => RegexIterator
  [RuntimeException] => RuntimeException
  [SeekableIterator] => SeekableIterator
  [SplDoublyLinkedList] => SplDoublyLinkedList
  [SplFileInfo] => SplFileInfo
  [SplFileObject] => SplFileObject
  [SplFixedArray] => SplFixedArray
  [SplHeap] => SplHeap
  [SplMinHeap] => SplMinHeap
  [SplMaxHeap] => SplMaxHeap
  [SplObjectStorage] => SplObjectStorage
  [SplObserver] => SplObserver
  [SplPriorityQueue] => SplPriorityQueue
  [SplQueue] => SplQueue
  [SplStack] => SplStack
  [SplSubject] => SplSubject
  [SplTempFileObject] => SplTempFileObject
  [UnderflowException] => UnderflowException
  [UnexpectedValueException] => UnexpectedValueException
)
```

## spl_object_hash

```
string spl_object_hash ( object $obj )
```

Funkcja *spl_object_hash* zwraca unikalny identyfikator (typu *string*) dla instancji obiektu. Id żyje tak długo jak dany obiekt. Usunięcie obiektu (za pomocą funkcji ```unset```) powoduje, że wygenerowany dla niego identyfikator może zostać przypisany do innego obiektu.

Przykład zastosowania z uwzględnieniem klonowania oraz tworzenia instancji klasy z takimi samymi danymi:

~~~php
<?php

$object1 = new stdClass;
$object1->name = 'Foo Bar';
$object1->age = 20;
var_dump(spl_object_hash($object1));

$object2 = clone $object1;
var_dump(spl_object_hash($object2));

$object3 = new stdClass;
$object3->name = 'Foo Bar';
$object3->age = 20;
var_dump(spl_object_hash($object3));
~~~

Wynikiem jest:

```
string(32) "0000000039b784ec000000005811fe38" // dla $object1
string(32) "0000000039b784ef000000005811fe38" // dla $object2
string(32) "0000000039b784ee000000005811fe38" // dla $object3
```