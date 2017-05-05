---
date: 2017-04-23 22:30
title: Krauza - pierwszy etap wdrożenia GraphQL w projekcie PHP
description: Opis pierwszego zetknięcia z graphql i próbą jego implementacji w projekcie php
tags: mksiazek dsp2017-mateusz krauza projekt php oop graphql
category: dsp2017-mateusz
author: mksiazek
comments: true
layout: post-with-related-tag
related_tag: "krauza"
related_title: "Zobacz inne posty związane z projektem Krauza"
---

W ramach konkursu *Daj się poznać* realizuję projekt *Krauza*, ostatnio pisałem, że przy okazji tworzenia tej aplikacji
chciałbym poznać zupełnie nowe podejście do komunikacji między aplikacją kliencką, a back-endową dzięki GraphQL.
Dzisiaj chciałbym opisać moje pierwsze kroki z implementacją tego rozwiązania w mojej aplikacji.

## Czym jest GraphQL
*GraphQL* to język zapytań, który udostępnia wspólny interfejs pomiędzy klientem, a serwerem do pobierania i manipulowania
danymi. Zaprojektowany został tak aby zapewnić intuicyjną i elastyczną składnię. Stworzony został przez inżynierów
Facebooka w 2012 roku, jednak jego kod źródłowy został otwarty dopiero w 2015 roku. 

GraphQL daje wszystkim (stronie klienckiej i serwerowej) łatwy sposób dostępu do danych z wykorzystaniem mniejszej ilości
zasobów niż w tradycyjnym REST API, dlatego powstał głownie z myślą o aplikacjach mobilnych.

Najważniejszym konceptem GraphQL jest *silne typowanie*, dzięki któremu definiujemy kontrakt między klientem, a serwerem.
Wewnętrznie aplikacja może korzystać z różnych typów, jednak do komunikacji z inną musi posługiwać się zdefiniowanymi
wcześniej typami.

###### Najważniejszą cechą GraphQL jest elastyczność
Załóżmy, że mamy endpoint w naszym RESTowym API, przez który musimy pobrać informacje o wszystkich książkach
wybranego autora. Zapytanie mogłoby wyglądać tak: `GET /authors/1/books`. Po czasie wymagania dotyczące wyświetlania tych
danych się zmieniają i nie musimy wyświetlać wszystkiego, a jedynie imię i nazwisko autora oraz same tytuły jego książek.
Aby skorzystać z tego samego endpointa trzeba stworzyć jakiś dodatkowy mechanizm wyboru pól które nas interesują, 
a wtedy zapytanie mogłoby wyglądać np. `GET /authors/1/books?only=author.fullname,book.title`.

W GraphQL z zasady w zapytaniu zaznaczamy tylko te pola, które nas interesują w danym momencie. a Przykładowe zapytanie 
może wyglądać mniej więcej tak:
```
query getAuthorBooks {
  author(id: 1) {
    fullname
    books {
      name
    }
  }
}
```

## Implementacja po stronie serwera
Jako, że cały projekt *Krauza* powstanie w oparciu o PHP przykładowa implementacja wykorzystuje bibliotekę 
[graphql-php](https://github.com/webonyx/graphql-php).

##### Type system
Najważniejszym elementem implementacji systemu opartego o GraphQL jest definicja tego co typy obiektów mogą zwrócić.
Domyślnie zaimplementowane jest kilka podstawowych typów skalarnych: `ID`, `String`, `Int`, `Float`, `Boolean`. 

Wszystkie inne typy (*object*, *enum*, *interface*, *union*) powinny być zaiplementowane w aplikacji. 

##### ObjectType
Zacznijmy od najważniejszego elementu składanki, czyli `ObjectType` na przykładzie wewnętrznego typu `Box`. Na tę chwilę
obiekt typu `Box` zawiera tylko id oraz nazwę. Trzeba utworzyć reprezentację tego typu.
~~~php
<?php

namespace Krauza\Infrastructure\Api\Type;

use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;

class BoxType extends ObjectType
{
    public function __construct()
    {
        $config = [
            'fields' => [
                'id' => [
                    'type' => Type::string(),
                    'description' => 'The id of the box'
                ],
                'name' => [
                    'type' => Type::string(),
                    'description' => 'The name of the box'
                ]
            ]
        ];

        parent::__construct($config);
    }
}
~~~
Podstawowa definicja obiektu to lista pól zadeklarowana w `fields`. Każde pole musi posiadać swój typ, w tym wypadku
zarówno pole `id` jak i `name` zwracają wartości typu `String`.

##### Schema, Query, Mutation
GraphQL pozwala na dwa rodzaje zapytań, które najprościej można określić jako odczyt (`Query`) i zapis (`Mutation`).
Zarówno `Query` jak i `Mutation` to specjalne typy w których definujemy zachowania naszego "API". `Query` i `Mutation`
powinny zostać zdefiniowane w `Schema` jako typy na poziomie *root*. Warto jeszcze zauważyć, że `Query` w schemacie
jest wymagane, a `Mutation` opcjonalne.

Zdefiniujmy na początek proste zapytanie odczytu, które powinno pobierać wcześniej uworzony typ `Box`.
~~~php
<?php

namespace Krauza\Infrastructure\Api\Type;

use GraphQL\Type\Definition\ObjectType;
use Krauza\Infrastructure\Api\TypeRegistry;

class QueryType extends ObjectType
{
    public function __construct()
    {
        $config = [
            'name' => 'Query',
            'fields' => [
                'box' => [
                    'type' => TypeRegistry::getBoxType(),
                    'resolve' => function () {
                        return ['id' => 'test', 'name' => 'super test name'];
                    }
                ]
            ]
        ];

        parent::__construct($config);
    }
}
~~~
`Query` definiujemy identycznie jak zwykłe `ObjectType`, jedynie musimy uwzględnić w nim `name` jako `Query`, a w tablicy
`fields` dodajemy wszystkie możliwe zapytania. W zapytaniu dodawana jest funkcja `resolve`, która powinna zwrócić element
zgodny z definicją typu.

Definiowanie typu `Mutation` jest bardzo podobne...
~~~php
<?php

namespace Krauza\Infrastructure\Api\Type;

use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;
use Krauza\Infrastructure\Api\TypeRegistry;

class MutationType extends ObjectType
{
    public function __construct()
    {
        $config = [
            'name' => 'Mutation',
            'fields' => [
                'createBox' => [
                    'type' => TypeRegistry::getBoxType(),
                    'args' => [
                        'name' => Type::string()
                    ],
                    'resolve' => function () {
                        // action
                    }
                ]
            ]
        ];

        parent::__construct($config);
    }
}
~~~

Po utworzeniu `Query` i `Mutation` można zadeklarować schemat.
~~~php
<?php
$schema = new Schema([
    'query' => TypeRegistry::getQueryType(),
    'mutation' => TypeRegistry::getMutationType()
]);
~~~

##### TypeRegistry
W poprzednich listingach kodu można było zauważyć pojawiające się kilka razy `TypeRegistry`. Nie jest to żaden oficjalny
element GraphQL. Każdy typ w `Schema` może być reprezentowany przez jedną instancję obiektu, inaczej zostanie rzucony
wyjątek.

Jednym z rozwiązań może być utworzenie "rejestru" typów, który zadba aby każda defincja typu była utworzona tylko raz.
~~~php
<?php

namespace Krauza\Infrastructure\Api;

use Krauza\Infrastructure\Api\Type\MutationType;
use Krauza\Infrastructure\Api\Type\QueryType;
use Krauza\Infrastructure\Api\Type\BoxType;

class TypeRegistry
{
    private static $boxType;
    private static $queryType;
    private static $mutationType;

    public static function getQueryType(): QueryType
    {
        return self::$queryType ?: (self::$queryType = new QueryType);
    }

    public static function getMutationType(): MutationType
    {
        return self::$mutationType ?: (self::$mutationType = new MutationType());
    }

    public static function getBoxType(): BoxType
    {
        return self::$boxType ?: (self::$boxType = new BoxType);
    }
}
~~~

##### HTTP Endpoint
Poniżej przykładowy kod `index.php`, który może być endpointem aplikacji.
~~~php
<?php

require __DIR__ . '/../vendor/autoload.php';

use GraphQL\GraphQL;
use GraphQL\Schema;
use Krauza\Infrastructure\Api\TypeRegistry;

if (isset($_SERVER['CONTENT_TYPE']) && $_SERVER['CONTENT_TYPE'] === 'application/json') {
    $rawBody = file_get_contents('php://input');
    $data = json_decode($rawBody ?: '', true);
} else {
    $data = $_POST;
}

$requestString = isset($data['query']) ? $data['query'] : null;
$operationName = isset($data['operation']) ? $data['operation'] : null;
$variableValues = isset($data['variables']) ? $data['variables'] : null;

try {
    $schema = new Schema([
        'query' => TypeRegistry::getQueryType(),
        'mutation' => TypeRegistry::getMutationType()
    ]);
    $result = GraphQL::execute(
        $schema,
        $requestString,
        null,
        null,
        $variableValues,
        $operationName
    );
} catch (Exception $exception) {
    $result = [
        'errors' => [
            ['message' => $exception->getMessage()]
        ]
    ];
}

header('Content-Type: application/json');
echo json_encode($result);
~~~

## GraphiQL
Do łatwego testowania API opartego o GraphQL przygotowana została aplikacja [*GraphiQL*](https://github.com/graphql/graphiql).
Na szczęście dostępna jest wtyczka ([ChromeIQL](https://chrome.google.com/webstore/detail/chromeiql/fkkiamalmpiidkljmicmjfbieiclmeij))
do przeglądarki *Chrome*, dzięki której można w bardzo szybki sposób przetestować naszą aplikację.

![ChromeIQL]({{ site.url }}/assets/images/2017/04/graphql/1.png)

## Podsumowanie
Dziejszym postem pobieżnie przeszliśmy przekrojowo po wszystkich najważniejszych elementach, które są niezbędne do
uruchomienia podstawowej aplikacji z wykorzystaniem GraphQL. Mam nadzieję, że w miarę jasno udało mi się przekazać informacje.
Szczerze mówiąc są to także moje pierwsze kroki z tym rozwiązaniem i myślę, że wkrótce pojawią się posty zawierające
konkretniejsze implementacje.

W razie pytań lub sugestii zachęcam do pozostawienia komentarza! :smiley:
