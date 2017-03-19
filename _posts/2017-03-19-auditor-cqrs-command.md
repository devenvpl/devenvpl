---
date: 2017-03-06 22:30
title: "Auditor - CQRS - Command"
layout: post
description: "Wstęp do implementacji CQRS - Command"
tags: apietka dsp2017-adrian auditor cqrs
category: dsp2017-adrian
author: apietka
comments: true
---

W projekcie *Auditor* podjąłem decyzję o wdrożeniu wzorca *CQRS*. Rozdzielając write i read model. W tym artykule skupię się na opisaniu implementacji w projekcie write modelu - *Commands*.

# Command

*Command* jest żadaniem w systemie, żądaniem którego efektem jest zmiana stan systemu.

W implementacji możemy rozdzielić dwie główne odpowiedzialności *Command* jako struktura danych, obiekt immutable (raz skonstruowany obiekt nie może zostać zmodyfikowany). Oraz *CommandHandler* czyli klasa która reaguje na *Command* - wykonując *jakieś* polecenia.

W aplikacji *Auditor* przykładem żądania *Command* jest akcja "stwórz nowy projekt". Aby akcja mogła zostać wykonana pomyślnie należy podać jedynie nazwę projektu.

~~~php
<?php

class CreateNewProjectCommand
{
    private $name;

    public function __construct(string $name)
    {
        $this->name = $name;
    }

    public function name() : string
    {
        return $this->name;
    }
}
~~~

W strzukturze projektowej *Command* znajduje się w folderze: ```src/AppBundle/Command```.

# CommandHandler

*CommandHandler* czyli implementacja tego, co ma dziać się po wywołaniu żądania. W przypadku *CreateNewProjectCommand* będzie to utworzenie nowej encji, ustawienie nazwy projektu oraz dodanie encji do repozytorium. Na początek tyle, wystarczy aby zobrazować granice odpowiedzialności każdego z elementów układanki.

~~~php
<?php

class CreateNewProjectHandler
{
    private $projectRepository;

    public function __construct(ProjectRepositoryInterface $projectRepository)
    {
        $this->projectRepository = $projectRepository;
    }

    public function handle(CreateNewProjectCommand $command) : void
    {
        $project = new ProjectEntity();
        $project->setName($command->name());

        $this->projectRepository->add($project);
    }
}
~~~

Ważna zasada. *CommandHandler* nie zwraca danych - żadnych. Wywołujemy go i zapominamy, że może zostać coś zwrócone. 

W strzukturze projektowej *CommandHandler* znajduje się w folderze: ```src/AppBundle/Command/Handler```.

# CommandBus

Pozostaje jedynie kwestia wywołania odpowiedniego (jednego) *CommandHandler* dla przekazanego *Command*. Sam element rozwiązywania nazewnictwa i zwracania gotowej instancji *CommandHandler* przeniosłem do zewnętrznej klasy, tutaj posługuję się jedynie zdefiniowanym interfejsem *HandlerResolverInterface*, a jego przykładowa implementacja zawarta została w klasie *SymfonyCommandHandlerResolver*.

~~~php
<?php

class CommandBus
{
    private $handlerResolver;

    public function __construct(HandlerResolverInterface $handlerResolver)
    {
        $this->handlerResolver = $handlerResolver;
    }

    public function handle($command) : void
    {
        $handler = $this->handlerResolver->handler($command);
        $handler->handle($command);
    }
}
~~~

Jak widać, *CommandBus*, pobiera instancję *CommandHandler* z instancji klasy implementującej *HandlerResolverInterface*. Następnie na zwróconym obiekcie wywoływana jest metoda *handle()* do której przekazujemy instancję *Command*.

Niestety w PHP 7.1 nie mamy jeszcze [Generic Types](https://wiki.php.net/rfc/generics), więc interfejs ma odrobinę magii - nie wiadomo jakiego typu (i czy wogóle) zostatnie zwrócona informacja po wywołaniu metody *handler()*:

~~~php
<?php

interface HandlerResolverInterface
{
    public function handler($command);
}
~~~

Zaimplementowanie interfejsu *HandlerResolverInterface*, może wyglądać m.in. w sposób przedstawiony poniżej (wersja PoC).

Ustaliłem konwencję nazewnictwa *CommandHandler* w kontenerze zależności:

```
app.command_handler.create_new_project
app.command_handler.add_comment_to_project_file
```

Na podstawie nazwy klasy wywołanego *Command* staram się ustalić nazwę klucza w kontenerze zależności (DIC, Dependency Injection Container), czyli dla *CreateNewProjectCommand* będzie to ```app.command_handler.create_new_project```. W łatwy sposób dostaję utworzony obiekt z wszelkimi zależnościami. Jeżeli nie zostanie odnaleziona definicja w DIC, rzucony zostanie wyjątej *CommandHandlerNotFoundException*.

~~~php
<?php

class SymfonyCommandHandlerResolver implements HandlerResolverInterface
{
    private $container;

    public function __construct(ContainerInterface $container)
    {
        $this->container = $container;
    }

    public function handler($command)
    {
        $handlerContainerName = $this->getHandlerName($command);

        if (!$this->container->has($handlerContainerName)) {
            throw new CommandHandlerNotFoundException(get_class($command));
        }

        return $this->container->get($handlerContainerName);
    }

    private function getHandlerName($command) : string
    {
        $commandNamespace = explode('\\', get_class($command));
        $commandName = end($commandNamespace);
        $handlerName = str_replace('_command', '', $this->camelCaseToUnderscore($commandName));

        return 'app.command_handler.' . $handlerName;
    }

    private function camelCaseToUnderscore(string $input) : string
    {
        return strtolower(preg_replace('/(?<!^)[A-Z]/', '_$0', $input));
    }
}
~~~

# Wdrażamy rozwiązanie

Definicję DIC ustalam w formacie yml, ze względu na jego czytelność i skrócony format zapisu. Zależności znajdujące się w *services.yml* prezentują się następująco:

~~~yml
services:
  app.command_handler_resolver:
    class: SymfonyCommandHandlerResolver
    arguments: ["@service_container"]

  app.command_bus:
    class: CommandBus
    arguments: ["@app.command_handler_resolver"]

  app.command_handler.create_new_project:
    class: Command\Handler\CreateNewProjectHandler
    arguments: ["@app.repository.project"]
~~~

Pozostaje jedynie wywołanie *Command* z akcji kontrolera:

~~~php
<?php

class ProjectsController extends AppController
{
    /**
     * @Route("/projects", name="projects_create")
     * @Method("POST")
     */
    public function createAction(Request $request) : JsonResponse
    {
        $this->get('app.command_bus')->handle(new CreateNewProjectCommand(
            (string)$request->request->get('name')
        ));

        return $this->json(null, Response::HTTP_CREATED);
    }
}
~~~

Pełne rozwiązanie można podejrzeć w projekcie *Auditor*. Jego kod źródłowy dostępny jest w serwisie GitHub: github.com/devenvpl/auditor](https://github.com/devenvpl/auditor)