---
date: 2017-05-05 18:10
title: Krauza - Zapis do bazy z obsługą GraphQL 
description: Opis pierwszego zetknięcia z graphql i próbą jego implementacji w projekcie php
tags: mksiazek dsp2017-mateusz krauza projekt php oop graphql
category: dsp2017-mateusz
author: mksiazek
comments: true
layout: post-with-related-tag
related_tag: "krauza"
related_title: "Zobacz inne posty związane z projektem Krauza"
---

![GraphQL]({{ site.url }}/assets/images/2017/05/graphql/graphql.png)

W [pierwszym poście dotyczącym implementacji GraphQL](/2017/04/23/kruaza-graphql-start.html) w projekcie PHPowym opisałem
w skrócie najważniejsze elementy tego narzędzia, dlatego jeśli nie masz jeszcze żadnej wiedzy na ten temat to możesz do
niego skoczyć aby w szybki sposób poznać podstawy.

Dzisiaj chciałbym omówić kwestię modyfikacji danych na prostym przykładzie dodania nowego elementu do bazy dancyh. 

##### Mutation
Na początek w schemacie naszego API trzeba dodać do typu *Mutation* akcję, którą chcemy wykonać. Poniżej prosta mutacja
zawierająca tylko jedną operację *createBox*.
~~~php
<?php

class MutationType extends ObjectType
{
  public function __construct()
  {
    $config = [
      'name' => 'Mutation',
      'fields' => [
        'createBox' => [
          'type' => TypeRegistry::getCreateBoxType(),
          'args' => [
            'name' => [
              'type' => Type::string(),
              'description' => 'Name of the box'
            ]
          ],
          'resolve' => function ($rootValue, $args, $context) {
            $boxRepository = new BoxRepository($context['database_connection']);
            $boxUseCase = new CreateBoxUseCase($boxRepository, $context['id_policy']);
            $createBox = new CreateBox($boxUseCase, $context['current_user']);
            return $createBox->action($args);
          }
        ]
      ]
    ];

    parent::__construct($config);
  }
}
~~~
W 10 linii zadeklarowano mutację `createBox`, która będzie tworzyć nowy element w naszym systemie. 11 linia to deklaracja
typu zapytania, który determinuje co powinno zostać zwrócone po wykonaniu zadania. Kolejna linia to deklaracja argumentów,
których oczekujemy od klienta, w tym wypadku oczekiwana jest tylko nazwa dla nowego elementu.

W linii 18 deklarowana jest funkcja anonimowa, która odpowiada za wykonanie niezbędnych akcji i zwrócenie danych
w formacie zgodnym z typem.

Funkcja anonima *resolve* obsługuje 3 parametry:
* `$rootValue` - wartość, która może zostać przekazana od samego korzenia grafu (w momencie deklarowania schematu API).
* `$args` - argumenty przekazane przez klienta (według schematu zadeklarowanego w 12 linii kodu).
* `$context` - to wartość również przekazywana od samego korzenia, mogą tam być dodane takie iformacje jak zalogowany
użytkownik. W wypadku mojej aplikacji przekazuję instancję DIC ([Dependency Injection Container](https://pimple.sensiolabs.org/))
w którym przechowuję m.in. połączenie z bazą danych. 

Deklaracja typu dla tworzenia nowego elementu w tym wypadku wygląda tak jak na poniższym listingu.
~~~php
<?php

class CreateBoxType extends ObjectType
{
  public function __construct()
  {
    $config = [
      'fields' => [
        'box' => [
          'type' => TypeRegistry::getBoxType(),
          'description' => 'Created box'
        ],
        'errors' => [
          'type' => TypeRegistry::getErrorType(),
          'description' => 'List of errors'
        ]
      ]
    ];

    parent::__construct($config);
  }
}
~~~
Jeśli nowy element `Box` zostanie poprawnie utworzony to zostanie zwrócony element typu `Box`, a jeśli coś poszło nie tak
jak powinno bądź wprowadzony argument był niepoprawny odpowiednie informacje zostaną przekazane w polu `errors`.

##### Akcja
Znasz wzorzec [MVC](https://pl.wikipedia.org/wiki/Model-View-Controller)? Pewnie, że znasz. W większości aplikacji
kontrolery to klasy, które zawierają w sobie metody będące akcjami, ja w tym wypadku podszedłem do tego trochę inaczej
wzorując się na artykule Macieja Aniserowicza [Kontroler jest jak wyrostek](http://devstyle.pl/2016/04/28/kontroler-jest-jak-wyrostek/).

Za każdym razem kiedy wykonywane jest zapytanie do API tworzona jest nowa instancja obiektu reprezentującego akcję.
Zgodnie z zasadą [DIP](https://en.wikipedia.org/wiki/Dependency_inversion_principle) do konstruktora przekazywane są
wszystkie komponenty, z których będzie korzystać akcja. 

~~~php
<?php

class CreateBox
{
  /**
   * @var CreateBoxUseCase
   */
  private $boxUseCase;

  /**
   * @var User
   */
  private $currentUser;

  public function __construct(CreateBoxUseCase $boxUseCase, User $currentUser)
  {
    $this->boxUseCase = $boxUseCase;
    $this->currentUser = $currentUser;
  }

  public function action(array $data): array
  {
    $box = null;
    $error = null;

    try {
      $newBox = $this->boxUseCase->add($data, $this->currentUser);
      $box = ['id' => $newBox->getId(), 'name' => $newBox->getName()];
    } catch (FieldException $exception) {
      $error = $this->buildError('fieldException', $exception->getFieldName(), $exception->getMessage());
    } catch (\Exception $exception) {
      $error = $this->buildError('infrastructureException', '', 'Something went wrong, try again.');
    }

    return ['box' => $box, 'errors' => $error];
  }

  private function buildError(string $type, string $key, string $message): array
  {
    return ['errorType' => $type, 'key' => $key, 'message' => $message];
  }
}
~~~

Na powyższym listingu konkretne zadanie wykonywane jest w liniach 27 i 28, reszta to obsługa błędów itp. Logika
tworzenia nowego elementu i tak jest ukryta na niższych warstwach aplikacji, których teraz nie będę już tutaj przeklejać.
Po krótce wykonywana jest walidacja danych wejściowych, następnie tworzony jest obiekt `Box` i na jego podstawie
odbywa się zapis nowego elementu do bazy danych.

##### Obsługa błędów w GraphQL - jak poradzić sobie bez kodu odpowiedzi?
Przy tradycyjnym REST API mamy cały zestaw kodów odpowiedzi dla różnego wyniku rządania, np. dla niepoprawnych danych
wejściowych zwrócilibyśmy kod `400`, ale przy GraphQL nie jest to takie oczywiste. Trzeba wprowadzić swój schemat obsługi
błędów.

Jak działa [obsługa wyjątków](/dsp2017-mateusz/2017/04/30/kruaza-obsluga-wyjatkow.html) na przykładzie tej samej akcji
opisałem w poprzednim poście. Warto go przejrzeć aby lepiej zrozumieć koncepcję obsługi błędów.

Do klienta zwracana jest tablica według typu `CreateBoxType` zaprezentowanego wcześniej. Jeśli wszystko się powiodło to
zwracana jest tablica, gdzie element `box` przyjmuje dane dla nowo utworzonego elementu, a `errors` jest wartością `null`.
W przeciwnym razie (jeśli wystąpiły jakieś błędy) element `box` posiada wartość `null`, a w polu `errors` ustawiana
jest wartość według typu `ErrorType` zaprezentowanego poniżej.

~~~php
<?php

class ErrorType extends ObjectType
{
  public function __construct()
  {
    $config = [
      'fields' => [
        'errorType' => [
          'type' => Type::string(),
          'description' => 'The type of the error (infrastructure issue or breaking the domain contract)'
        ],
        'key' => [
          'type' => Type::string(),
          'description' => 'The key of the error'
        ],
        'message' => [
          'type' => Type::string(),
          'description' => 'The message of the error'
        ]
      ]
    ];

    parent::__construct($config);
  }
}
~~~
