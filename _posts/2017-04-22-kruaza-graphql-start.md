---
date: 2017-04-22 12:00
title: Krauza - pierwszy etap wdrożenia GraphQL w projekcie PHP
layout: post
description: Opis pierwszego zetknięcia z graphql i próbą jego implementacji w projekcie php
tags: mksiazek dsp2017-mateusz krauza projekt php oop graphql
category: dsp2017-mateusz
author: mksiazek
comments: true
---

W ramach konkursu *Daj się poznać* realizuję projekt *Krauza*, ostatnio pisałem, że przy okazji tworzenia tej aplikacji
chciałbym poznać zupełnie nowe podejście do komunikacji między aplikacją kliencką, a back-endową dzięki GraphQL.
Dzisiaj chciałbym opisać moje pierwsze kroki z implementacją tego rozwiązania w mojej aplikacji.

## Czym jest GraphQL
*GraphQL* to język zapytań, który udostępnia wspólny interfejs pomiędzy klientem, a serwerem do pobierania i manipulowania
danymi. Zaprojektowany został tak, że zapewnie intuicyjną i elastyczną składnię. Stworzony został przez inżynierów
Facebooka w 2012 roku, jednak jego kod źródłowy został otwarty dopiero w 2015 roku. 

GraphQL daje wszystkim (stronie klienckiej i serwerowej) łatwy sposób do dostępu do danych z mniejszą ilością zasobów
niż w tradycyjnym REST API, dlatego powstał głownie z myślą o aplikacjach mobilnych.

Najważniejszym konceptem GraphQL jest *silne typowanie*, dzięki któremu definiujemy kontrakt między klientem, a serwerem.
Wewnętrznie aplikacja może korzystać z różnych typów, jednak do komunikacji z inną musi posługiwać się zdefiniowanymi
wcześniej typami.

###### Najważniejszą cechą GraphQL jest elastyczność
Załóżmy, że mamy endpoint w naszym RESTowym API, przez który musimy pobrać informacje o wszystkich książkach
wybranego autora. Zapytanie mogłoby wyglądać tak: `GET /authors/1/books`. Po czasie wymagania dotyczące wyświetlania tych
danych się zmieniają i nie musimy wyświetlać wszystkiego, a jedynie imię i nazwisko autora oraz same tytuły jego książek.
Aby skorzystać z tego samego endpointa trzeba stworzyć jakiś dodatkowy mechanizm wyboru pól które nas interesują, np.
`GET /authors/1/books?only=author.fullname,book.title`.

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

## serwer
##### Type system
Najważniejszym elementem implementacji systemu opartego o GraphQL jest definicja tego co typy obiektów mogą zwrócić.
Domyślnie zaimplementowane jest kilka podstawowych typów skalarnych: `ID`, `String`, `Int`, `Float`, `Boolean`. 

Wszystkie inne typy (*object*, *enum*, *interface*, *union*) powinny być zaiplementowane w aplikacji. 

##### ObjectType
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

##### QueryType
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

##### MutationType
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

##### TypeRegistry
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

## Podsumowanie
