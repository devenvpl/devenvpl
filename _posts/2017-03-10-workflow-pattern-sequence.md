---
date: 2017-03-10 16:00
title: "Workflow Pattern - Sequence"
layout: post
description: "Prosta implementacja procesu sekwencyjnego."
tags: apietka dsp2017-adrian patterns
category: dsp2017-adrian
author: apietka
comments: true
---

Tworząc aplikacje często mam doczynienia z sekwencją pewnych czynności - procesem. Samowolnie i wręcz automatycznie, nazywamy takie zachowanie angielskim słowem *workflow* (polskie tłumaczenie "przepływ pracy" brzmi co najmniej głupio). Przykładem procesu może być składanie zamówienia w sklepie internetowym, wypełnianie wieloetapowego formularza, po sprawy teoretycznie mniej skomplikowane - jak przetwarzanie danych do formatu wyjściowego (niejednokrotnie wymagające kilku etapów np. ETL).

Dla zobrazowania sytuacji:

```
  A -> B -> C
```

Wykonujemy akcję A, po niej następuje wykonanie akcji B, następnie akcji C. Na tym kończy się nasz *workflow*.

Modelując niedawno jedną z funkcji aplikacji, spotkałem się ponownie z podobnym problemem - musiałem wywoływać akcje jedna po drugiej z zachowaniem ich odpowiedniej kolejność oraz współdzieleniem pewnych danych pomiędzy poszczególnymi krokami. Pierwsza akcja generowała dane które były niezbędne do przeprowadzenia kolejnej akcji. Po początkowej fazie stworzenia szkicu, zabrałem się za implementacja rozwiązania. Nie wyglądało ono sympatycznie, a jego poziom skomplikowania nie był adekwatny do tego co faktycznie dzieje się w systemie. Natomiast druga iteracja doprowadziła kod do bardziej czytelnej formy. Poniżej prezentuję PoC rozwiązania, odcięte od produkcyjnego kodu, jednak dające zobrazowanie organizacji kodu.

Najpierw zdefiniowałem *context*, czyli obiekt który będzie współdzielony pomiędzy poszczególnymi akcjami. Taki "pojemnik" na dane. Dla przykładu, mój *context* będzie zawierał tylko jedną właściwość.


```php
class WorkflowContext
{
    private $sequenceId;

    public function getSequenceId() : ?int
    {
        return $this->sequenceId;
    }

    public function setSequenceId(int $sequenceId) : void
    {
        $this->sequenceId = $sequenceId;
    }
}
```

Każda akcja będzie implementować następujący interfejs:

```php
interface WorkflowAction
{
    public function execute(WorkflowContext $context);
}
```

Szkielet implementacji trzech niemal identycznych akcji:

```php
class FirstWorkflowAction implements WorkflowAction
{
    public function execute(WorkflowContext $context)
    {
        echo 'FirstWorkflowAction. SequenceId = ' . $context->getSequenceId() . PHP_EOL;
        $context->setSequenceId(rand(1, 100));
        return new SecondWorkflowAction();
    }
}

class SecondWorkflowAction implements WorkflowAction
{
    public function execute(WorkflowContext $context)
    {
        echo 'SecondWorkflowAction. SequenceId = ' . $context->getSequenceId() . PHP_EOL;
        return new ThirdWorkflowAction();
    }
}

class ThirdWorkflowAction implements WorkflowAction
{
    public function execute(WorkflowContext $context)
    {
        echo 'ThirdWorkflowAction. SequenceId = ' . $context->getSequenceId() . PHP_EOL;
        return null;
    }
}
```

Każde wykonanie akcji, czyli wywołanie metody *execute* zwraca nam instancję obiektu kolejnej do wykonania akcji (za wyjątkiem ostatniej akcji w procesie - ona zwraca wartość *null*).
Implementacja poszczególnych akcji może zostać oddelegowana do zupełnie innego miejsca - nowej klasy. W ten sposób wszystko co implementuje *WorkflowAction* może być tylko opakowaniem na sekwencyjny proces, bez implementacji konkretnej logiki.

Pozostaje jedynie uruchomienie *workflow*:

```php
$context = new WorkflowContext();
$action = new FirstWorkflowAction();

while ($action) {
    $action = $action->execute($context);
}
```

Tworzę instancję *WorkflowContext*, ustawiam pierwszą akcję do wykonania *FirstWorkflowAction*. Następnie wykorzystując pętlę *while*  wywoływana jest metoda *execute* (na kolejnych akcjach), tak długo aż otrzymamy wartość niespełniającą warunku pętli. W tym przypadku jest to wartość *null*, która zwracana jest przez ostatnią akcję procesu.

Rezultatem końcowym będzie wyrzucenie na konsolę następujących informacji:

```
$: php sequence.php
FirstWorkflowAction. SequenceId = 
SecondWorkflowAction. SequenceId = 5
ThirdWorkflowAction. SequenceId = 5
```

Podsumowując. Wykonane zostały sekwencyjnie trzy akcje. Współdzielony *context* umożliwia transport danych pomiędzy poszczególnymi akcjami. Zaprezentowany kod jest jedynie szkieletem. Umożliwia łatwe odseparowanie sterowania procesem (*workflow*) od logiki wykonywanej w poszczególnych akcjach.

PS. Więcej o *Workflow Patterns* możesz poczytać na stronie [workflowpatterns.com](http://www.workflowpatterns.com/patterns/control/). Problem o którym piszę można sklasyfikować jako "Basic Control Flow Pattern - Sequence".
