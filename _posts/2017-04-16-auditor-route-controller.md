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

W projekcie *Auditor* (w sumie jak i również w większości projektów) zdecydowałem się na definicję ścieżki na poziomie adnotacji zawartych w kontrolerze:

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

Trochę zdecentralizowana definicja może okazać się problematyczna ze względu na rozproszenie zapisu ścieżek po kilku/kilkunastu  plikach z kontrolerami. Przeszukiwanie takiego zbioru może okazać się problematyczne. Na szczęście problem ten można bardzo łatwo rozwiązać, poprzez wywołanie komendy ```debug:router``` w konsoli Symfony. Wyświetla ona listę wszystkich zdefiniowanych ścieżek w aplikacji:

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
