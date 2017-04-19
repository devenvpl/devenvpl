---
date: 2017-04-16 20:30
title: "Auditor - Route i Controller"
layout: post
description: "Czyli słów kilka o definicji ścieżek i kontrolerów w Symfony 3."
tags: apietka dsp2017-adrian auditor symfony
category: dsp2017-adrian
author: apietka
comments: true
---

Framework Symfony, powiązanie ścieżki (*route*) z kontrolerem (*controller*) umożliwia na dwa sposoby:

- adnotacje na poziomie kontrolera - czyli silne powiązanie akcja kontrolera - ścieżka,
- osobny plik konfiguracyjny YAML, XML lub PHP - rozluźnienie powiązania, osobny plik z definicją.

W projekcie *Auditor* (w sumie jak i również w większości innych projektów) zdecydowałem się na definicję ścieżki na poziomie adnotacji zawartych w kontrolerze. Całość sprowadza się do dodania komentarza z adnotacją ```@Route``` oraz opcjonalnie ```@Method```.

~~~php
<?php

namespace AppBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class ProjectsController extends AppController
{
    /**
     * @Route("/projects", name="projects_list")
     * @Method("GET")
     */
    public function listAction(Request $request) : JsonResponse
    {
        // ...
    }
    
    // ...
}
~~~

Kontroler jest "wejściem" do systemu - prostym, czytelnym i jednoznacznym. Jego rola powinna zakończyć się na przekazaniu wgłąb aplikacji danych wejściowych i zwróceniu rezultatu. Jest również mocno powiązany z adresem który musi zostać wywołany aby wykonać akcję kontrolera. To taka nieodłączna część. Dlatego też definicję ścieżek umieszczam w tym konkretnym miejscu. Nie w zewnętrznym pliku, tylko w adnotacji dla konkretnej akcji. Z drugiej strony widzę dwa potencjalne zagrożenia:

- nazwy ścieżek (*name*) - zahardkodowane jako *string*. W widoku często wykorzystuje się nazwe ścieżki do generowania linku. Za każdym razem należy powielać wartość, co jest problematyczne w momencie zmiany nazwy ścieżki. Jednak istnieje na to proste rozwiązanie - używanie stałych dla nazwy ścieżki np. ```@Route("/projects", name=ProjectsController::ROUTE_LIST)```,
- podmiana wykonywanej akcji dla konkretnej ścieżki - niestety czeka nas ręczna zmiana w kontrolerze.

Jeszcze jedna kwestia. Przeszukiwanie takiego zbioru może okazać się problematyczne. Zdecentralizowana definicja czyli rozproszony zapis ścieżek w kilku/kilkunastu plikach z kontrolerami nie ułatwia zadania. Na szczęście problem ten rozwiązuje wywołanie komendy ```debug:router``` w konsoli Symfony. Wyświetla ona listę wszystkich zdefiniowanych ścieżek w aplikacji:

```
$: php bin/console debug:router
```

Wynikiem jest:

```
----------------- ------- ------- ----- ----------
 Name             Method  Scheme  Host  Path
----------------- ------- ------- ----- ----------
 homepage         ANY     ANY     ANY   /
 projects_list    GET     ANY     ANY   /projects
 projects_create  POST    ANY     ANY   /projects
----------------- ------- ------- ----- ----------
```
