---
date: 2017-03-18 15:00
title: Krauza - rejestracja użytkowników
layout: post
description: Proces rejestracji użytkowników
tags: mksiazek dsp2017-mateusz krauza projekt php oop
category: dsp2017-mateusz
author: mksiazek
comments: true
---

Dzisiejszy post będzie uzupełnieniem do [wpisu sprzed tygodnia](/dsp2017-mateusz/2017/03/10/krauza-po-pierwszych-commitach.html),
w którym była mowa głównie o użytkownikach. Będąc nadal w niższych warstwach aplikacji, tym razem opiszę proces
rejestracji nowych użytkowników.

## Factory
W poprzednim poście była mowa o tym, że encja `User`, składa się również z bloków będącymi implementacją `ValueObject`.
Dlatego aby zapewnić, że inicjalizowanie klasy `User` będzie się odbywało zawsze poprawnie należy utworzyć metodę fabrykującą,
która w tym pomoże.
~~~ php
<?php

namespace Krauza\Factory;

use Krauza\Entity\User;
use Krauza\Policy\PasswordPolicy;
use Krauza\ValueObject\UserEmail;
use Krauza\ValueObject\UserName;

class UserFactory
{
    public static function createUser(array $data, PasswordPolicy $passwordPolicy): User
    {
        $userName = new UserName($data['name']);
        $userEmail = new UserEmail($data['email']);

        $user = new User($userName);
        $user->setEmail($userEmail);
        $user->setPassword($passwordPolicy->getPassword());

        return $user;
    }
}
~~~
Do metody `createUser` przekazujemy dwa parametry: tablicę `$data`, zawierająca dane, które będą pochodzić z formularza
uzupełnianego przez użytkownika, oraz obiekt typu `PasswordPolicy`. Zwracana jest instancja klasy `User`.
Wewnątrz metody, podczas inicjalizacji obiektów `UserName` oraz `UserEmail` następuje walidacja, która w razie niezgodności
rzuca wyjątek, który powinien być przechwycony na wyższych warstwach aplikacji.

## Repository Pattern
Repozytorium jest kolekcją elementów danego typu. Dodaję interfejs `UserRepository`, którego będą implementować w
przyszłości klasy na wyższej warstwie aplikacji posiadające informacje o typie bazy danych i komunikacji z nią. 
Na tę chwilę zadanie jest bardzo proste - dodać nowego użytkownika do kolekcji.
~~~ php
<?php

namespace Krauza\Repository;

use Krauza\Entity\User;

interface UserRepository
{
    public function __construct($engine);
    public function add(User $user);
}
~~~

## Service
Serwis `RegistrationService` stanowi most między warstwą bliższą użytkownikowi końcowemu, a warstwą domenową.
~~~ php
<?php

namespace Krauza\Service;

use Krauza\Factory\UserFactory;
use Krauza\Policy\PasswordPolicy;
use Krauza\Repository\UserRepository;

class RegistrationService
{
    private $userRepository;
    private $passwordPolicy;

    public function __construct(UserRepository $userRepository, PasswordPolicy $passwordPolicy)
    {
        $this->userRepository = $userRepository;
        $this->passwordPolicy = $passwordPolicy;
    }

    public function register(array $data)
    {
        $user = UserFactory::createUser($data, $this->passwordPolicy);
        $this->userRepository->add($user);
    }
}
~~~
Serwis będzie inicjalizowany w odpowiednym kontrolerze, a jako parametry konsruktura przekazywane będa już konkretne
implementacje `UserRepository` oraz `PasswordPolicy`. Po wywołaniu metody `register` zostanie utworzony nowy obiekt `User`
dzięki uprzednio dodanej fabryce `UserFactory`, a następnie obiekt ten zostanie przekazany do kolekcji `UserRepository`
(docelowo ma to być zapis do bazy danych).
 