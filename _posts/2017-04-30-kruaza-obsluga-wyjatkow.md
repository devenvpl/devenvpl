---
date: 2017-04-30 15:50
title: "Krauza - obsługa wyjątków"
layout: post
description: Trochę informacji o obsłudze wyjątków i o tym jak powinno się je traktować
tags: mksiazek dsp2017-mateusz krauza projekt php oop dobre-praktyki
category: dsp2017-mateusz
author: mksiazek
comments: true
---

> Tester webaplikacji wchodzi do baru. Zamawia piwo. Zamawia 0 piw. Zamawia 99999999999 piw. Zamawia zlew. Zamawia -1,337
piw. Zamawia 1"> piw. Zamawia aishd78hsdf.

Pewnie większość z was kojarzy ten suchar, ale musiałem go tutaj wrzucić bo jest idealnym wstępem do dzisiejszego tematu
:smiley:. Wszędzie tam gdzie dajemy użytkownikowi możliwość wprowadzania danych musimy liczyć się z tym, że może się to
niedobrze skończyć dla aplikacji, która jest źle zabezpieczona.

Pierwsza linia walidacji formularzy zykle pojawia się już w aplikacji frontendowej, sam HTML w wersji 5 posiada kilka
wbudowanych funkcji, a dodatkowo najczęściej dopisywane są walidatory w Javascriptcie. Nie jest to jednak wystarczające.
Najważniejsza jest walidacja po stronie serwerowej, bo tą frontendową łatwo ominąć.

##### Złamanie zasad logiki biznesowej powinno zatrzymać cały proces
Jeśli w aplikacji istnieją jakieś założenia i zasady biznesowe, na które mogą mieć wpływ użytkownicy zewnętrzni 
(np. wprowadzić błędne dane) to wtedy powinniśmy zatrzymać cały proces, który właśnie miał zostać wywołany i wyrzucić
odpowiedni wyjątek.
 
Weźmy jakiś prosty przykład: Jeśli użytkownik chce utworzyć nowy byt w projekcie i musi podać jego nazwę, ale ta nazwa
musi zawierać ilość znaków w odpowiednim zakresie (np. minimum 3 i maksymalnie 128), a wprowadzi w formularzu tylko dwa
znaki to wtedy doszło do złamania kontraktu logiki biznesowej. Leci wyjątek.

W moim przekonaniu taka "walidacja" powinna odbywać się w niskiej warstwie logiki, a obsługa wyjątków w warstwie
infrastruktury, np. w kontrolerze.

W mojej aplikacji utworzyłem klasę abstrakcyjną `FieldException`, która będzie reprezentowała wyjątki związane z błędnym
wypełnieniem pola formularza. Zawiera podstawową wiadomość, a dodatkowo `fieldName` aby określić, które pole się nie zgadza.
~~~php
<?php

namespace Krauza\Core\Exception;

abstract class FieldException extends \Exception
{
    protected $fieldName;
    protected $message;

    public function __construct($field, $message)
    {
        $this->fieldName = $field;
        $this->message = $message;
    }

    public function getFieldName()
    {
        return $this->fieldName;
    }
}
~~~

Przykładowym, który rozszerza abstrakcyjną klasę `FieldException` może być wyjątek dla zbyt długiej wartości,
opatrzony nazwą `ValueIsTooLong`.
~~~php
<?php

namespace Krauza\Core\Exception;

class ValueIsTooLong extends FieldException
{
    public function __construct($field)
    {
        parent::__construct($field, 'Value is too long');
    }
}
~~~

Przykład użycia można zaobserwować w klasie `BoxName`, która zawiera jasne zasady tworzenia obiektu. Parametr konstruktora,
musi zawierać odpowiednią ilość znaków, w innym wypadku zostaną rzucone wyjątki `ValueIsTooShort` lub `ValueIsTooLong`.
Wyjątki zostaną obsłużone w wyższej warstwie aplikacji.
~~~php
<?php

namespace Krauza\Core\ValueObject;

use Krauza\Core\Exception\ValueIsTooShort;
use Krauza\Core\Exception\ValueIsTooLong;

class BoxName
{
    private const MIN_NAME_LENGTH = 3;
    private const MAX_NAME_LENGTH = 128;

    private $boxName;

    public function __construct(string $boxName)
    {
        $this->checkBoxNameLength($boxName);
        $this->boxName = $boxName;
    }

    private function checkBoxNameLength($boxName)
    {
        $nameLength = strlen($boxName);

        if ($nameLength < self::MIN_NAME_LENGTH) {
            throw new ValueIsTooShort((new \ReflectionClass($this))->getShortName());
        }

        if ($nameLength > self::MAX_NAME_LENGTH) {
            throw new ValueIsTooLong((new \ReflectionClass($this))->getShortName());
        }
    }

    public function __toString()
    {
        return $this->boxName;
    }
}
~~~

##### Oddziel wyjątki warstwy logiki od wyjątków warstwy infrastruktury
To prawdopodobnie najważniejsza zasada. Kiedy zamierzamy stosować praktyki opisane powyżej to nie możemy zapomnieć aby
obsługa wyjątków inaczej traktowała te, które zostały spowodowane złamaniem kontraktu logiki biznesowej, a tych, które
wynikają z błędów aplikacji, np. kiedy serwer bazodanowy przestanie działać i klient rzuci wyjątek. To są dwie różne sprawy
i trzeba je zupełnie inaczej obsłużyć.

Poniżej przedstawiam klasę `CreateBox`, która jest akcją API odpowiedzialną za tworzenie nowego elementu. Najważniejszą
rzeczą w tym punkcie jest to aby funkcja `action` zawsze zwróciła odpowiedź niezależnie od tego co się stanie podczas
wykonywania operacji dodawania nowego 'Boxu'.
~~~php
<?php

namespace Krauza\Infrastructure\Api\Action;

use Krauza\Core\Entity\User;
use Krauza\Core\Exception\FieldException;
use Krauza\Core\UseCase\CreateBox as CreateBoxUseCase;

class CreateBox
{
    /**
     * @var CreateBoxUseCase
     */
    private $boxUseCase;

    /**
     * @var User
     */
    private $currentUser;

    public function __construct(CreateBoxUseCase $boxUseCase, User $currentUser)
    {
        $this->boxUseCase = $boxUseCase;
        $this->currentUser = $currentUser;
    }

    public function action(array $data): array
    {
        $box = null;
        $error = null;

        try {
            $newBox = $this->boxUseCase->add($data, $this->currentUser);
            $box = ['id' => $newBox->getId(), 'name' => $newBox->getName()];
        } catch (FieldException $exception) {
            $error = $this->buildError('fieldException', $exception->getFieldName(), $exception->getMessage());
        } catch (\Exception $exception) {
            // Dodanie jakiegoś loggera, który zapisze szczegóły co poszło nie tak...
            $error = $this->buildError('infrastructureException', '', 'Something went wrong, try again.');
        }

        return ['box' => $box, 'errors' => $error];
    }

    private function buildError(string $type, string $key, string $message): array
    {
        return ['errorType' => $type, 'key' => $key, 'message' => $message];
    }
}
~~~
W powyższym kodzie w liniach 33-34 odbywa się główna operacja tworzenia nowego 'Boxu'. Jak widać całość jest opakowana
w blok `try` i `catch`. W liniach 35 i 37 widoczne są dwa elementy `catch`. Pierwszy z nich przechwytuje niezgodności
związane z logiką aplikacji, a drugi obsługuje wszystkie inne błędy, które mogły wystąpić w systemie.

W 36 linii tworzona jest wiadomość odpowiedzi do której przekazujemy `message` pochodzące bezpośrednio z wyjątku.
Z kolei w linii 39 ustawiamy niezależnie dla rodzaju błędu zawsze jedną wiadomość w stylu 'Something went wrong, try again.'.
Dlaczego? To proste, użytkownik nie musi wiedzieć, a nawet nie powinien co w danym momencie zepsuło się w naszej aplikacji.
Takie szczegóły to kwestie dla administratora tego systemu i warto te szczegóły zapisać jakimś loggerem aby można było
łatwo debugować co się wydarzyło.

###### Testy integracyjne
Na sam koniec przedstawiam testy integracyjne naszej akcji, które powinny pokryć każde możliwe zachowanie aplikacji. 
~~~php
<?php

use Krauza\Core\Policy\IdPolicy;
use Krauza\Core\ValueObject\EntityId;
use Krauza\Core\Entity\User;
use Krauza\Infrastructure\DataAccess\BoxRepository;
use Krauza\Core\UseCase\CreateBox as CreateBoxUseCase;
use Krauza\Infrastructure\Api\Action\CreateBox;
use Doctrine\DBAL\Connection;

class CreateBoxActionTest extends PHPUnit_Framework_TestCase
{
    /**
     * @var CreateBox
     */
    private $createBoxAction;

    /**
     * @var PHPUnit_Framework_MockObject_MockObject
     */
    private $idPolicyMock;

    public function setUp()
    {
        $this->idPolicyMock = $this->getMock(IdPolicy::class);
        $this->idPolicyMock->method('generate')->willReturn(new EntityId('1'));
        $userMock = $this->getMockBuilder(User::class)->disableOriginalConstructor()->getMock();
        $connectionMock = $this->getMockBuilder(Connection::class)->disableOriginalConstructor()->getMock();
        $boxRepositoryMock = new BoxRepository($connectionMock);
        $boxUseCase = new CreateBoxUseCase($boxRepositoryMock, $this->idPolicyMock);
        $this->createBoxAction = new CreateBox($boxUseCase, $userMock);
    }

    /**
     * @test
     */
    public function shouldCreateBox()
    {
        // when
        $result = $this->createBoxAction->action(['name' => 'Box name']);

        // then
        $this->assertEquals(['box' => ['name' => 'Box name', 'id' => '1'], 'errors' => null], $result);
    }

    /**
     * @test
     */
    public function shouldReturnInformationWhenBoxNameIsTooShort()
    {
        // when
        $result = $this->createBoxAction->action(['name' => 'a']);

        // then
        $error = ['errorType' => 'fieldException', 'key' => 'BoxName', 'message' => 'Value is too short'];
        $this->assertEquals(['box' => null, 'errors' => $error], $result);
    }

    /**
     * @test
     */
    public function shouldReturnInformationWhenBoxNameIsTooLong()
    {
        // when
        $longName = '11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        $result = $this->createBoxAction->action(['name' => $longName]);

        // then
        $error = ['errorType' => 'fieldException', 'key' => 'BoxName', 'message' => 'Value is too long'];
        $this->assertEquals(['box' => null, 'errors' => $error], $result);
    }

    /**
     * @test
     */
    public function shouldReturnInformationWhenErrorWasThrown()
    {
        // when
        $this->idPolicyMock->method('generate')->will($this->throwException(new Exception('Internal error')));
        $result = $this->createBoxAction->action(['name' => 'Box name']);

        // then
        $error = ['errorType' => 'infrastructureException', 'key' => '', 'message' => 'Something went wrong, try again.'];
        $this->assertEquals(['box' => null, 'errors' => $error], $result);
    }
}
~~~

## Podsumowanie
1. Nigdy nie zapomnij o walidacji danych wejściowych po stronie serwera.
2. Złamanie kontraktu logiki biznesowej jest takim samym błędem jak wewnętrzny błąd systemu, należy niezwłocznie
przerwać cały proces. Idealnym rozwiązaniem aby to zapewnić są wyjątki.
3. Nigdy nie traktuj wyjątków wynikających z niezgodnością logiki tak samo jak błędów aplikacji (np. problem połączenia
z bazą danych).
4. Aplikacja musi być zawsze stabilna i odporna na błędy.
5. Ukrywaj przed użytkownikiem szczegóły błędów aplikacji, ale loguj informacje o nich aby móc szybciej znaleźć
i usunąć problemy.
