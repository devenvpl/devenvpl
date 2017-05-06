---
date: 2017-04-30 23:30
title: "Auditor - Wykorzystanie obiektów DTO w Read Model"
layout: post
description: "Rozwinięcie tematu CQRS - Query w projekcie Auditor. Przedstawienie obiektów DTO."
tags: apietka dsp2017-adrian auditor php cqrs dto patterns
category: dsp2017-adrian
author: apietka
comments: true
---

Nawiązując do umieszczonego na łamach bloga artykułu "[Auditor - CQRS - Query](/dsp2017-adrian/2017/03/30/auditor-cqrs-query.html)" chciałbym rozwinąć nieco bardziej tematykę zwracania danych przez *Query*. W opisywanej implementacji *Query*, wszystkie dane były reprezentowane za pomocą tablic asocjacyjnych - pojedynczy rekord jak i również kolekcja rekordów. W taki sposób były przekazywane do warstwy wyżej. Niestety nie daje to konkretnej informacji na temat faktycznej zwracanej struktury. Były to tablice asocjacyjne, zawierające *jakieś* dane w postaci jakiś *klucz* => wartość. Tyle.

Moim celem było zakomunikowanie w jasny sposób, jakie konkretnie informacje zwraca dane *Query*. Rozwiązanie zostało oparte o wzorzec *DTO*, o którym przeczytasz poniżej.

## DTO

*DTO* czyli *Data Transfer Object* jest wzorcem dystrybucji. Jego zadaniem jest grupowanie danych do postaci obiektu, i przenoszenia ich pomiędzy:

- metodami, klasami, modułami, warstwami aplikacji,
- procesami, aplikacjami, systemami,
- i w każdym innym przypadku gdy jest to niezbędne, czytaj - gdy zachodzi potrzeba przekazania danych.

Taki kontener na dane, który nie zawiera żadnej logiki. Łatwo go serializować do dowolnego formatu (np. *JSON*, *XML*), a następnie przywrócić do postaci obiektu. *DTO* to obiekty niezależne od domeny, ale także domena jest niezależna od nich - wykluczając obiekty które na podstawie *DTO* tworzą obiekty domenowe (i odwrotnie) - np. wykorzystując wzorce kreacyjne.

## Query a DTO

W projekcie *Auditor* wyróżniam dwa typy obiektów DTO które zwracane są przez *Query*:

### DTO reprezentujące pojedynczy byt

Czyli *DTO* reprezentujące jednostkę - w przypadku *Auditor* jest to np. *ProjectDto*, zawierający podstawowe informacje o identyfikatorze i nazwie projektu.

~~~php
<?php

class ProjectDto implements \JsonSerializable
{
    public $id;
    public $name;

    public function __construct(array $data)
    {
        $this->id = isset($data['id']) ? (int)$data['id'] : null;
        $this->name = isset($data['name']) ? (string)$data['name'] : '';
    }

    public function jsonSerialize()
    {
        return $this;
    }
}
~~~

Obiekt uzupełniany jest w momencie tworzenia instancji, z danych dostarczonych w postaci tablicy asocjacyjnej. W konstruktorze następuje etap przypisania odpowiednich wartości do właściwości obiektu. Właściwości posiadają widoczność typu *public*, aby w łatwy sposób można było uzyskiwać informacje na temat transportowanych danych.

Każdy *DTO* w projekcie musi być łatwo serializowany do formatu *JSON*. Dlatego też, implementuję interfejs *JsonSerializable*. O samym interfejsie rozpisałem się w artykule: [PHP - Serializacja obiektów za pomocą interfejsu JsonSerializable](/dsp2017-adrian/2017/04/08/php-jsonserializable.html).

Jak się domyślasz właściwości o widoczności *public* można dowolnie zmieniać po utworzeniu instancji obiektu. Aby temu zapobiec musiałbym zmienić widoczność tych właściwości na *private* i stworzyć *gettery* dla każdego z nich. Najlepszym rozwiązaniem byłoby ustawienie ich jako *readonly*, taką możliwość daje np. język *C#*. Niestety w *PHP* takiej możliwości nie posiadamy, a gettery dla właściwości to przerost formy nad treścią (jak na razie). Dlatego zdecydowałem aby operować na właściwościach publicznych z założeniem, że na obiektach *DTO* nie można zmieniać wartości właściwości.

To jednak jedynie założenie, i w projekcie większym, tworzonym przez kilku programistów pewne założenia mogą się zatracać - jak nie od razu, to po jakimś czasie. To temat akurat na kolejny artykuł :)

Po stworzeniu *DTO* musiałem jeszcze nanieść poprawkę na *Query*.

~~~php
<?php

public function execute(Dbal $dbal) : ProjectDto
{
    $sql = 'SELECT * FROM project WHERE id = :id LIMIT 1';
    $project = $dbal->fetchAssoc($sql, [':id' => $this->projectId]);

    return new ProjectDto($project);
}
~~~

Zwrócone dane z zapytania *SQL* wykorzystuję do stworzenia instancji obiektu *DTO*. Dodatkowo poprawiam *return type* dla metody. Teraz w jasny i jednoznaczny sposób określiłem, jaka struktura danych zwracana jest przez metodę, a zwracam instancję klasy *ProjectDto*. Nie muszę się już domyślać, ani też debugować kodu aby dowiedzieć się co zwraca metoda *execute*.
 
### DTO będące kolekcją innych DTO

Tablica obiektów zawsze przyprawia mnie o dreszcze. Podobnie jak zwracanie tablicy asocjacyjnej w przypadku pojedynczych elementów, tak i tutaj nie wiadomo nic na temat struktury zwracanych danych. Moim celem było stworzenie obiektu który jasno wskazuje z jaką kolekcją elementów mamy doczynienia. ```ProjectCollectionDto``` jest kolekcją obiektów ```ProjectDto```. Czyli "opakowaniem" na zbiór obiektów *DTO* reprezentujących "projekt".

Do implementacji takiej kolekcji wykorzystałem klasę z biblioteki standardowej *SPL* - [```ArrayIterator```](http://php.net/manual/en/class.arrayiterator.php). Wystarczy, że podczas tworzenia instancji obiektu przekażę tablicę z wynikami zapytania, a następnie zmodyfikuję zachowanie metody ```current```. Tak aby zwracała obiekt *DTO*. Całość obrazuje poniższy przykład:

~~~php
<?php

class ProjectCollectionDto extends \ArrayIterator implements \JsonSerializable
{
    public function current()
    {
        return new ProjectDto(parent::current());
    }

    public function jsonSerialize()
    {
        return iterator_to_array($this);
    }
}
~~~

Warto zwrócić uwagę na metodę ```jsonSerialize```. Wykorzystałem funkcję [```iterator_to_array```](/dsp2017-adrian/2017/04/29/php-spl-functions-iterator.html) po to aby móc dalej korzystać z konwertowania *DTO* do typu *JSON* - z prawidłowym uwzględnieniem *DTO* dla pojedynczych elementów. Inaczej konwertowany jest element tablicy, a nie instancja *DTO* ( funkcja ```iterator_to_array``` przetworzy iterator do tablicy, wywołując jednocześnie metodę ```current``` dla każdego elementu w celu jego pobrania).

Innym rozwiązaniem jest tworzenie wszystkich *DTO* w konstruktorze. Byłoby to o tyle lepsze rozwiązanie, że *DTO* tworzymy tylko raz. W aktualnej wersji tworzenie instancji obiektu *DTO* następuje za każdym razem gdy chcemy pobrać element kolekcji. Ulepszoną implementację, zamierzam wprowadzić w projekcie *Auditor*.

Została jeszcze do wprowadzenia mała poprawka dla *Query*:

~~~php
<?php

public function execute(Dbal $dbal) : ProjectCollectionDto
{
    $sql = 'SELECT * FROM project';
    $results = $dbal->fetchAll($sql);

    return new ProjectCollectionDto($results);
}
~~~

Podobnie jak w przypadku zwracania *DTO* reprezentującego pojedynczy byt, zmieniony został *return type*.

## Podsumowanie

W artykule zaprezentowałem przykład wykorzystania obiektów *DTO*. Zwracanie ich z *Query* zamiast tablic informuje programistę o strukturze zwracanych danych - jak pisałem wyżej:

> "Nie muszę się już domyślać, ani też debugować kodu aby dowiedzieć się co zwraca metoda"

Dla mnie to największa wartość dodana. Raz zainwestowany czas w stworzenie jednej klasy (lub dwóch w przypadku kolekcji) procentuje podczas powrotu do kodu (po dniu, tygodniu czy miesiącu). Nie ma potrzeby zagłębiania się w szczegóły - jakie wykonywane jest zapytanie SQL, jakie pola zwraca (które od razu lądowały w *response* do użytkownika). Dostaję podpowiedzi w IDE (a nie magiczne klucze tablic) oraz możliwość nazwania zwracanych pól w dowolnie inny sposób - bez modyfikacji w zapytaniu SQL.

Podsumowując - programujmy obiektowo, wykorzystujmy obiekty - niech reprezentują *byt*. Uważajmy z tablicami asocjacyjnymi - one nie zapewniają struktury, a źle wykorzystane wprowadzają magię w kodzie którą ciężko zrozumieć, a tym bardziej ujarzmić.

PS. Mięsko związane z *Query* i *DTO* możesz na bieżąco śledzić w [repozytorium projektu Auditor](https://github.com/devenvpl/auditor/tree/master/api/src/AppBundle/Query).