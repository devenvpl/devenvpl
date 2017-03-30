---
date: 2017-03-30 21:00
title: "Auditor - CQRS - Query"
layout: post
description: "Wstęp do implementacji CQRS - Query"
tags: apietka dsp2017-adrian auditor cqrs
category: dsp2017-adrian
author: apietka
comments: true
---

*Read Model* w projekcie *Auditor* wykorzystuje bibliotekę [Doctrine DBAL](http://www.doctrine-project.org/projects/dbal.html). Umożliwia ona połączenie z bazą danych (w przypadku tego projektu - *MySQL*) oraz wykonywanie zapytań SQL.

Pomijam tutaj warstwę *Repository*, *Entity* - ona ma swoje zastosowanie dla *[Write Model](/dsp2017-adrian/2017/03/19/auditor-cqrs-command.html)*. W *Read Model* używam czystych zapytań SQL po wykonaniu których otrzymujemy dane w postaci tablicy asocjacyjnej. W pełnym rozwiązaniu dostępnym w [repozytorium projektu](https://github.com/devenvpl/auditor), dane te przetwarzane są na obiekty [DTO](https://en.wikipedia.org/wiki/Data_transfer_object). Teraz postaram się jedynie przybliżyć podstawową koncepcję.

# Query

*Query* służy tylko i wyłącznie do odczytu danych. Nie ma tutaj miejsca na zmianę stanu systemu.

Dlaczego akurat "czyste" zapytania SQL? Ponieważ pomijając abstrakcję narzucaną przez ORM / Query Builder. Mam pełną kontrolę nad zapytaniem które faktycznie się wykonuje na bazie danych. Mogę je dowolnie optymalizować, co nie zawsze jest możliwe gdy używam abstrakcji.

~~~php
<?php

use Doctrine\DBAL\Connection as Dbal;

class ListsProjectQuery
{
    private $limit;

    public function __construct($limit)
    {
        $this->limit = $limit;
    }

    public function execute(Dbal $dbal) : array
    {
        return $dbal->fetchAll('SELECT * FROM project LIMIT :limit', [
            ':limit' => $this->limit
        ]);
    }
}
~~~

Konstruktor przyjmuje jedynie niezbędne do wykonania zapytania parametry. Samo wykonanie zapytania i zwrócenie wyników realizowane jest przez metodę ```execute()```. Aby ją wywołać musimy przekazać połączenie z bazą danych - o tym jednak przy omawianiu *QueryDispatcher*.

Spotkałem się również z podejściem aby dla zapytań które wykonujemy jako *Query* tworzyć widoki na bazie danych. Taki zabieg upraszcza czytelność *Query* w momencie kiedy napisaliśmy skomplikowane zapytanie z wieloma połączeniami, grupowaniem itd. Dodatkowo jest jednym z rozwiązań eliminujących potwórzenia. Czasem *Query* różnią się od siebie jedynie jednym warunkiem np. gdy posiadamy *Query* pobierające zamówienia o różnym statusie (```GetNewOrdersQuery()```, ```GetCanceledOrdersQuery()```).

Dokładamy wtedy jednak dodatkowy element w aplikacji wymagający utrzymywania - skrypty budujące widoki bazodanowe. Moim zdaniem jest to jednak minimalny narzut, tym bardziej, że możemy zminimalizować ilość powtarzającego się kodu SQL. Opcja bez widoków prowadzi często do anomalii: *"... dodaj jedno dodatkowe pole do wyświetlenia"* - i musimy poprawiać X plików :-).

# QueryDispatcher

Rolą *QueryDispatcher* jest przetworzenie *Query*, którego efektem jest wykonanie zapytania na bazie danych, a następnie zwrócenie danych do miejsca wywołania.

Po co *QueryDispatcher*, jeżeli można ręcznie wykonywać niezbędne kroki z poziomu kontrolera? Między innymi po to aby, zapewnić jeden, ustandaryzowany punkt obsługujący wykonywanie zapytań na bazie danych. Dodatkowo to świetne miejsce na logowanie wykonywanych zapytań, ich częstotliwości, różnorodności przekazywanych parametrów czy po prostu czasu wykonywania.

~~~php
<?php

use Doctrine\DBAL\Connection as Dbal;

class QueryDispatcher
{
    private $dbal;

    public function __construct(Dbal $dbal)
    {
        $this->dbal = $dbal;
    }

    public function execute($query)
    {
        return $query->execute($this->dbal);
    }
}
~~~

W klasie *QueryDispatcher* nie dzieje się nic magicznego. Wstrzyknięty zostaje kontekst połączenia z bazą danych, a metoda *execute()* wywołuje metodę *execute()* na dostarczonym obiekcie *Query*, podając jednocześnie wymagany argument.

# Wdrażamy rozwiązanie

Pierwszym krokiem jest dodanie nowej definicji do DIC. W projekcie korzystam z frameworka Symfony 3, kofigurację wstrzykiwania zależności definiuję w pliku *services.yml*:

~~~yml
services:
  app.query_dispatcher:
    class: AppBundle\QueryDispatcher
    arguments: ["@doctrine.dbal.default_connection"]
~~~

Pozostaje jedynie wywołanie *Query* z akcji kontrolera:

~~~php
<?php

class ProjectsController extends AppController
{
    /**
     * @Route("/projects", name="projects_list")
     * @Method("GET")
     * @param Request $request
     * @return JsonResponse
     */
    public function listAction(Request $request) : JsonResponse
    {
        $projects = $this->get('app.query_dispatcher')->execute(new ListsProjectQuery(
            (int)$request->query->get('limit', 10)
        ));

        return $this->json($projects, Response::HTTP_OK);
    }
}
~~~

Pełne rozwiązanie można podejrzeć w projekcie *Auditor*. Jego kod źródłowy dostępny jest w serwisie GitHub: [github.com/devenvpl/auditor](https://github.com/devenvpl/auditor)