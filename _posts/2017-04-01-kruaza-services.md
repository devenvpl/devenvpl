---
date: 2017-04-01 11:11
title: Krauza - ciut więcej o serwisach
layout: post
description: Wiecej informacji o klasie Service
tags: mksiazek dsp2017-mateusz krauza projekt php oop
category: dsp2017-mateusz
author: mksiazek
comments: true
---

## Jakie zadania pełnią serwisy w projekcie "Krauza"?
W jednym z pierwszych postów, w których opisywałem rejestrację użytkowników dałem krótką informację, że użyłem klasy
`RegistrationService` do kontrolowania całego procesu, jednak wtedy nie zagłębiłem się w temat mocniej. Może to i dobrze,
bo całe zagadnienie "dojrzało" w mojej głowie i teraz, kiedy dodałem już więcej serwisów mogę powiedzieć więcej na temat
tego mechanizmu.

Poniżej prezentuję prosty serwis pochodzący z aplikacji, którego celem jest utworzenie nowego bytu w bazie o nazwie "Box".
W kolejnych krokach będę starał się opowiedzieć o założeniach na podstawie tego przykładu.

~~~ php
<?php

namespace Krauza\Service;

use Krauza\Entity\User;
use Krauza\Factory\BoxFactory;
use Krauza\Policy\IdPolicy;
use Krauza\Repository\BoxRepository;

class NewBoxService
{
    private $boxRepository;
    private $idPolicy;

    public function __construct(BoxRepository $boxRepository, IdPolicy $idPolicy)
    {
        $this->boxRepository = $boxRepository;
        $this->idPolicy = $idPolicy;
    }

    public function addNewBox(array $data, User $user)
    {
        $card = BoxFactory::createBox($data, $this->idPolicy);
        $this->boxRepository->add($card, $user);
    }
}
~~~

##### Most między warstwą infrastruktury, a domeną
W mojej aplikacji to serwisy odpowiadają za logikę i przepływ informacji. Docelowo mają być inicjalizowane w kontrolerach,
a jako parametry konstruktura powinny być przekazywane konkretne implementacje określonych interfejsów. W powyższym kodzie
w linii 15 widać bardzo dobrze jakich typów oczekuje konstruktor.

Funkcja `addNewBox` jest wywoływana prosto z kontrolera i jako parametr przekazywana jest tablica `$data`, która zawiera
dane wpisane w formularzu.

Głównym założeniem jest odseparowanie logiki od warstwy infastruktury i myślę, ze tego typu serwisy bardzo dobrze się w
to wpasowują, ponieważ implementacja serwisów odbywa się tylko na abstrakcyjnych bytach.

##### Tylko jedna odpowiedzialność
Serwis powinien zajmować się tylko jednym zadaniem, dlatego ten w przytoczonym przykładzie posiada nazwę, która tłumaczy
jego zadanie - `NewBoxService`, czyli tworzenie nowego elementu `Box`.

Równie dobrze możnabyłoby utworzyć ogólną klasę `BoxService`, która oprócz dodawanie bytu `Box` pozwalałaby na edycję,
usuwanie albo inne akcje. Ale wtedy poważnie naruszamy zasadę [SRP](https://pl.wikipedia.org/wiki/Zasada_jednej_odpowiedzialno%C5%9Bci).
Dlatego dużo lepszym rozwiązaniem jest tworzenie osobnego serwisu dla każdej akcji.

## Czy takie podejście zawsze jest dobre?
Nie. Jak ze wszystkim tak i teraz trzeba dobierać dobre rozwiązania do projektu. W większych projektach na pewno dużo
lepsza będzie implementacja CQRS, o której rozpisuje się @Adrian w swojej [części bloga](http://devenv.pl/dsp2017-adrian.html),
lub podobnych bardziej zaawansowanych rozwiązań.

Jednak przy niewielkich projektach pozwala to na łatwą separację logikę od infrastruktury i zachowanie dobrych zasad
programowania, które będą procentować w dalszym utrzymywaniu projektu. Po za tym takie podejście jest w miarę elastyczne
i łatwe w rozbudowaniu lub przebudowaniu kiedy aplikacja będzie się rozszerzać.
