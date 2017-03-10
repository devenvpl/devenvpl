---
date: 2017-03-10 15:05
title: Krauza po pierwszych zmianach
layout: post
description: Opis pierwszych zaimplementowanych elementów aplikacji. 
tags: mksiazek dsp2017-mateusz projekt krauza php
category: dsp2017-mateusz
author: mksiazek
comments: true
---

W ostatnim czasie dokonałem pierwszych zmian w repozytorium czego efektem jest już wstępny zarys struktury aplikacji.
Oczywiście prace rozpocząłem od wyczyszczenia repo z poprzedniej wersji. Chciałem tworzyć projekt od podstaw aby nie
sugerować się poprzednim podejściem. Oczywiście *backup* pozostawiłem na osobnym branchu, głównie dlatego, że była tam
już gotowa całkiem dobrze wyglądająca warstwa prezentacji.

## Wstępna architektura
Nie chciałem implementować złożonych struktur opartych o zasady [DDD](http://bottega.com.pl/pdf/materialy/ddd/ddd1.pdf)
czy [CQRS](https://www.martinfowler.com/bliki/CQRS.html), chociażby dlatego, że ten projekt tego nie wymaga, a po za tym
nie czuję się w tych zagadnieniach jeszcze na tyle mocny aby ryzykowac pogrzebanie projektu na samym starcie.

Mimo, że moja aplikacja nie będzie powstawała zgodnie z zasadami *DDD* to nie znaczy, że nie mogę wzorować się wzorować
na kilku elementach pochodzących z tego rozwiązania. Jednym z głównym założeń podczas procesu implementacji jest stosowanie
technik *TDD*, a także spełniać zasady *GRASP*, *SOLID*. Dlatego też w strukturze pojawią się na przykład takie bloki
jak *Value Objects*, które idealnie pozwolą odseparować logikę poszczególnych elementów.

## Użytkownicy
Na pierwszy ogień zaimplementowałem prostą encję *User*, która na tę chwilę zawiera pola *name*, *password* i *email*.
~~~ php
<?php
namespace Krauza\Entity;

use Krauza\ValueObject\UserName;
use Krauza\ValueObject\UserEmail;
use Krauza\Policy\PasswordPolicy;

class User
{
    private $name;
    private $password;
    private $email;

    public function __construct(UserName $userName)
    {
        $this->name = $userName;
    }

    public function setPassword(PasswordPolicy $password)
    {
        $this->password = $password;
    }

    public function setEmail(UserEmail $email)
    {
        $this->email = $email;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getEmail(): string
    {
        return $this->email;
    }
}
~~~

W konstruktorze jako parametr przyjmowany jest tylko obiekt klasy `UserName`, a reszta pól (email, password) ustawiana
jest przez settery. Dlaczego tak? Taks struktura jest bardziej elastyczna podczas dodawania lub usuwania pól. Na przykład,
jeśli zrezugnuję z przechowywania informacji o adresie e-mail nie będzie konieczna edycja wszystkich miejsc gdzie
inicjalizowany jest obiekt klasy `User`.

##### Value Objects
Jak można zuważyć, w powyższym kodzie właściwości `name` i `email`, nie są zwykłymi zmiennymi o typie `string`, 
a instancjami obiektów `UserName` oraz `UserEmail` są to bloki *ValueObject* w których zaimplementowana jest
dodatkowo walidacja.

* `UserName` - z założenia długość nazwy użytkownika musi mieć minimum 3 znaki, a maksymalnie 48. Dodatkowo muszą to być
znaki alfanumeryczne.

~~~ php
<?php

namespace Krauza\ValueObject;

use Krauza\Exception\ValueHasWrongChars;
use Krauza\Exception\ValueIsTooShort;
use Krauza\Exception\ValueIsTooLong;

class UserName
{
    private const ALLOWED_CHARS = '/[^a-zA-Z0-9]+/';
    private const MIN_NAME_LENGTH = 3;
    private const MAX_NAME_LENGTH = 48;

    private $userName;

    public function __construct(string $userName)
    {
        $this->checkUserNameChars($userName);
        $this->checkUserNameLength($userName);

        $this->userName = $userName;
    }

    private function checkUserNameChars($userName)
    {
        if (preg_match(self::ALLOWED_CHARS, $userName)) {
            throw new ValueHasWrongChars;
        }
    }

    private function checkUserNameLength($userName)
    {
        $nameLength = strlen($userName);

        if ($nameLength < self::MIN_NAME_LENGTH) {
            throw new ValueIsTooShort;
        }

        if ($nameLength > self::MAX_NAME_LENGTH) {
            throw new ValueIsTooLong;
        }
    }

    public function __toString()
    {
        return $this->userName;
    }
}
~~~

Jeśli podczas tworzenia obiektu, przekazana wartość do konstruktura nie spełnia wymagań to to rzucany jest odpowiedni
`Exception`, który będzie przechwytywany na wyższych warstwach aplikacji użytkownika.

W klasie `UserName` nie ma tradycyjnego gettera, a w zamian dostępna jest publiczna magiczna metoda 
[`__toString()`](http://php.net/manual/en/language.oop5.magic.php#object.tostring), która pozwala
zdefiniować jaki powinien być wynik rzutowania obiektu na *string*. Dzięki temu w metodzie `getName()` klasy `User`,
można po prostu użyć obiektu `UserName`, a wynik zostanie wyświetlony w interecujący nas sposób jako `string`.

* `UserEmail` - jest to zbliżona implementacja do klasy `UserName`, z tą różnicą, że sprawdzana jest zgodność formatu
adresu email.

##### Policy
Hasło do klasy `User` przekazywane jest jako element typu `PasswordPolicy`, w tym momencie `PasswordPolicy` to nic innego
jak interfejs, który będzie implementowany w warstwie infrastruktury. Rodzaj hashowania nie powinien być zaszyty w niższych
warstwach aplikacji. Jak wiadomo bezpieczne algorytmy bardzo często przestają być bezpieczne i muszą być aktualizowane
na nowsze, jeszcze bezpieczniejsze ;-) Dzięki temu, że klasa `User` oczekuje typu, a nie konkretnej implementacji
sprawia, że można spokojnie podmieniać funkcje hashujące w wyższych warstwach aplikacji bez konieczności modyfikacji
klasy `User`.

## To wszystko, ale co dalej?
Dzięki tym kilku prostym klasom struktura aplikacji zaczyna się powoli krystalizować. Będąc już przy encji użytkownika,
w najbliższym czasie powinna pojawić się implementacja serwisu służącego do rejestracji nowych użytkowników.
W następnych krokach będą też przybywać kolejne elementy, a także pierwsza podstawowa logika, która będzie używana w
procesie nauki zgodnego z systemem Leitnera.