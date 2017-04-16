---
date: 2017-04-16 20:30
title: "Auditor - Controllers"
layout: post
description: "Omówienie wzorca MVC wraz z jego zależnościami względem routingu."
tags: apietka dsp2017-adrian auditor controllers mvc
category: dsp2017-adrian
author: apietka
comments: true
---

Tworzenie *controller* który odpiowada za obsługę zdarzenia nie jest rzeczą prostą.
Biorąc pod uwagę *controller* poniżej mam ochotę rozprawić się zz jego autorami nieco później.

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
     * @param Request $request
     * @return JsonResponse
     */
    public function listAction(Request $request) : JsonResponse
    {
        // ...
    }
    
    // ...
}
~~~

W rzeczywistośći bliżej jest mi do podejścia *action*. Jednak w rzeczywistośći staramy się grupować wywoływane żądania,
