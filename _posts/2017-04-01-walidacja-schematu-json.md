---
date: 2017-04-01 15:00
title: "JSON Schema - czyli sposób na opisanie struktury JSON"
layout: post
description: "Przykład zastosowania JSON Schema"
tags: apietka dsp2017-adrian json php
category: dsp2017-adrian
author: apietka
comments: true
---

Niedawno, w jednym z realizowanych projektów zaistniała potrzeba sprawdzania czy dostarczony przez klienta końcowego dokument *JSON* jest prawidłowy pod względem struktury.

Nie potrzebowaliśmy walidacji na poziomie poprawności wartości (np. czy identyfikator kategorii faktycznie występuje w naszym systemie). Ważny był dla nas fakt, aby schemat dostarczonych danych w formacie *JSON* był taki jakiego sobie życzymy. Musiał zawierać odpowiednie właściwości, a dane musiały być odpowiedniego typu (np. string, number, object). Odrzucaliśmy w ten sposób błędne dokumenty jeszcze przed rozpoczęciem ich właściwego przetwarzania.

Ręczna implementacja każdego z oczekiwanych schematów *JSON* wymagała by od nas sporego nakładu pracy. Na szczęście istnieje coś takiego jak *JSON Schema*.

## Czym jest JSON Schema

*JSON Schema* pozwala na opisanie struktury dokumentu *JSON*, w sposób przejrzysty i czytelny dla człowieka. Następnie na tej podstawie można zwerferyfikować czy dostarczony dokument *JSON* spełnia założone kryteria.

Świetnie nadaje się do wykorzystania przy testach automatycznych (np. API) oraz walidacji danych wysyłanych do aplikacji przez użytkownika.

Więcej informacji oraz wyczerpującą dokumentację możesz znaleźć na stronie: [json-schema.org](http://json-schema.org/).

## Przykład JSON Schema

Dla następującego dokumentu JSON:

~~~json
{
  "metadata": {
    "timestamp": 123123,
      "source": "github",
      "authinfo": {
        "agent": "agentName",
        "auth": "uniqueAndSecretApiKey"
      }
  },
  "data": []
}
~~~

Implementacja schematu wygląda w sposób przedstawiony poniżej:

~~~json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "Packet",
  "description": "Incoming packet of messages",
  "type": "object",
  "properties": {
    "metadata": {
      "type": "object",
      "properties": {
        "timestamp": {
          "type": "number"
        },
        "source": {
          "type": "string"
        },
        "authinfo": {
          "type": "object",
          "properties": {
            "agent": {"type": "string"},
            "auth": {"type": "string"}
          },
          "required": [
            "agent",
            "auth"
          ]
        }
      },
      "required": [
        "timestamp",
        "source",
        "authinfo"
      ]
    },
    "data": {
      "type": "array"
    }
  },
  "required": [
    "metadata",
    "data"
  ]
}
~~~

Opisane zostały wymagane pola oraz ich prawidłowe typy danych. Na oficjalnej stronie *JSON Schema* można również podpatrzeć [kilka innych przykładów](http://json-schema.org/examples.html).

Do stworzenia takiego opisu dokumentu, można wykorzystać narzędzie [JSON Schema Generator](http://jsonschema.net/#/). Na podstawie dostarczonego dokumentu *JSON*, generowany jest jego opis w formacie *JSON Schema*.

## Przykład walidacji (PHP)

Do walidacji schematu wykorzystałem zewnętrzną bibliotekę: [justinrainbow/json-schema](https://github.com/justinrainbow/json-schema).

Wystarczy zainstalować ją za pomocą *Composer*:

```
$: composer require justinrainbow/json-schema
```

Zastosowanie w praktyce:

~~~php
<?php

$retriever = new JsonSchema\Uri\UriRetriever;
$validator = new JsonSchema\Validator;

$jsonToValid = 'toValidate.json';
$schemaFile = 'scheme.json';

$packetData = json_decode($packetJson);
$packetSchema = $retriever->retrieve($schemaFile);

$validator->check($packetData, $packetSchema);

if ($validator->isValid()) {
    echo 'Data is a valid JSON schema';
} else {
    var_dump($validator->getErrors());
}
~~~

Zmienna ```$jsonToValid``` zawiera ścieżkę do danych przechowywanych w formacie JSON. Natomiast ```$schemaFile``` ścieżkę do pliku z schematem *JSON Schema*.

## Podsumowanie

Walidacja schematu dokumentu *JSON* nie musi być uciążliwa i "manualna". Dzięki zastosowaniu *JSON Schema* i generatora [JSON Schema Generator](http://jsonschema.net/#/) można ułatwić i zautomatyzować sobie pracę. W moim przypadku przyśpieszyło to znacząco wdrożenie funkcji walidacji schematu dostarczanych przez użytkownika danych w formacie *JSON*.
