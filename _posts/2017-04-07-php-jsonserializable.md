---
date: 2017-04-08 22:00
title: "PHP - Serializacja obiektów za pomocą interfejsu JsonSerializable"
layout: post
description: "Przykładowa implementacja interfejsu JsonSerializable umożliwiającego serializację obiektów do formatu JSON."
tags: apietka dsp2017-adrian php json
category: dsp2017-adrian
author: apietka
comments: true
---

Miałem ostatnio potrzebę serializacji obiektów do formatu *JSON*. Nie potrzebowałem rozbudowanych bibliotek, a tym bardziej wprowadzania kolejnych zależności do projektu. Mam nieodparte wrażenie, że w każdym z projektów w których pracuje, jesteśmy krok od *[Dependency Hell](https://en.wikipedia.org/wiki/Dependency_hell)*.

Na szczęście do prostych zadań, świetnie spisuje się dostarczony w PHP (od wersji 5.4 wraz z modułem *[JSON](http://php.net/manual/en/book.json.php)*) interfejs *JsonSerializable*. Wystarczy aby klasa implementująca interfejs posiadała metodę *jsonSerialize()* która zwraca dane mogące zostać zserializowane funkcją *json_encode()*. Czyli tak na prawdę każdy dowolny typ danych, za wyjątkiem typu *resource*.

Zdefiniuję na początek trzy różne klasy - *Author*, *Comment*, *Article*. Każda z nich posiada implementację interfejsu *JsonSerializable*. Dla uproszczenia przykładu w klasie *Article*, na sztywno ustawiam wymagane wartości.

~~~php
<?php

class Author implements JsonSerializable
{
    private $name;
    private $surname;
    
    public function __construct($name, $surname)
    {
        $this->name = $name;
        $this->surname = $surname;
    }
    
    public function jsonSerialize()
    {
        return $this->name . ' ' . $this->surname;
    }
}

class Comment implements JsonSerializable
{
    private $author;
    private $content;
    
    public function __construct(Author $author, $content)
    {
        $this->author = $author;
        $this->content = $content;
    }
    
    public function jsonSerialize()
    {
        return [
            'author' => $this->author,
            'content' => $this->content
        ];
    }
    
}

class Article implements JsonSerializable
{
    private $id;
    private $added;
    private $title;
    private $author;
    private $publicated;
    private $comments;
    
    public function __construct()
    {
        $this->id = 1;
        $this->added = new DateTime('-1 day');
        $this->title = 'JsonSerializable';
        $this->author = new Author('Adrian', 'Pietka');
        $this->publicated = true;
        $this->comments = [
            new Comment(new Author('John', 'Smith'), 'Nice document!')
        ];
    }

    public function jsonSerialize()
    {
        return [
            'id' => $this->id,
            'added' => $this->added,
            'title' => $this->title,
            'author' => $this->author,
            'publicated' => $this->publicated,
            'comments' => $this->comments
        ];
    }
}
~~~

Obiekt klasy *Author* przy serializacji do formatu *JSON* zwróci najprostszą informację - dana typu *string*. Natomiast instancja klasy *Comment* - tablicę asocjacyjną. Najbardziej złożona w tym przypadku jest klasa *Article*. Jej instancja po serializacji do formatu *JSON* wymaga również transformacji obiektów zależnych - *Author* oraz tablicy obiektów *Comment*.

Sprowadzenie obiektów do formatu *JSON* wymaga jedynie wywołania funkcji *json_encode()*:

~~~php
<?php

echo json_encode(new Article(), JSON_PRETTY_PRINT);
~~~

Rezultatem wywołania funkcji będzie następujący format danych:

~~~json
{
    "id": 1,
    "added": {
        "date": "2016-11-29 23:03:11.000000",
        "timezone_type": 3,
        "timezone": "Europe\/Warsaw"
    },
    "title": "JsonSerializable",
    "author": "Adrian Pietka",
    "publicated": true,
    "comments": [
        {
            "author": "John Smith",
            "content": "Nice document!"
        }
    ]
}
~~~

Można również zmienić domyślny sposób serializacji danych dla klasy *DateTime*. Wystarczy stwórzyć własną (np. *MyDateTime*), rozszerzając klasę *DateTime*, a następnie implementując interfejs *JsonSerializable*. Potrzeba przykładu? Proszę:

~~~php
<?php

class MyDateTime extends DateTime implements JsonSerializable
{
    public function jsonSerialize()
    {
        return $this->format('Y-m-d H:i:s');
    }
}
~~~

Jeżeli Twój system nie składa się z kilkudziesiąciu klas które należy serializować do formatu *JSON*, rozwiązanie zaprezentowane powyżej jest całkiem przyjemne. Implementacja jednej metody, możliwość definiowania formatu końcowego (struktury oraz nazewnictwa powszczególnych pól) jest szybka, a dodatkowo nie wymaga kolejnej zalezności do biblioteki zewnętrznej. Jeśli natomiast nasz system bardzo szybko się rozrasta, posiadamy z dnia na dzień kolejne klasy wymagające transformacji - to prawdopodobnie jest to dobry moment na zastanowienie się nad automatyzacją serializacji.