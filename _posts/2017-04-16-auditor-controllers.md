---
date: 2017-04-16 13:30
title: "MQTT - protokół transmisji danych dla IoT"
layout: post
description: "Wstęp do protokołu MQTT z wykorzystaniem brokera Mosquitto."
tags: apietka dsp2017-adrian mqtt mosquitto iot integration-patterns
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
