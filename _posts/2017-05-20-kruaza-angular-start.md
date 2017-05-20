---
date: 2017-05-20 16:15
title: Krauza - Szybki start z Angularem!
description: ""
tags: mksiazek dsp2017-mateusz krauza projekt javascript angular angularjs
category: dsp2017-mateusz
author: mksiazek
comments: true
layout: post-with-related-tag
related_tag: "krauza"
related_title: "Zobacz inne posty związane z projektem Krauza"
related_message: Projekt <i>Krauza</i> realizowany jest w ramach konkursu <a href="http://devstyle.pl/daj-sie-poznac/">Daj Się Poznać 2017</a>. Repozytorium dostępne jest w serwisie <a href="https://github.com/mejt/Krauza">GitHub</a>.
---

Od dwóch tygodni nie pojawił się żaden post związany z projektem *Krauza*. Na ten stan rzeczy składają się dwa powody:
w ostatnim czasie w projekcie nie działo się nic nadzwyczajnego i odkrywczego, skupiłem się na dokończeniu komunikacji
z bazą danych i API, jedyną ciekawą rzeczą, która pojawiła się w projekcie są migracje bazodanowe z wykorzystaniem
narzędzia [Phinx](https://phinx.org/), jednak @adrianpietka już rozpisał się na ten temat więc zapraszam do jego
[posta](/dsp2017-adrian/2017/05/19/auditor-database-migration-phinx.html).

Po uprzątnięciu warstwy backendowej przyszła pora na frontend i to dzisiaj chciałbym opisać, bo wspominałem już wcześniej,
że chciałbym na front wrzucić najnowszego Angulara żeby poznać coś świeżego i nowego. Na razie ta część projektu jest
na bardzo podstawowym poziomie, jednak jest już co opisać :smiley:. Już kiedyś pisałem posta z 
[podstawowymi informacjami](/dsp2017-mateusz/2017/03/14/angular.html) o tym frameworku świeżo po szkoleniu,
ale dopiero teraz mogę zacząć pisać konkrety na przykładzie prawdziwego użycia w projekcie.

## Angular CLI
Na wzór innych popularnych frameworków Angular wprowadził narzędzie [Angular CLI](https://github.com/angular/angular-cli),
które znacząco przyspiesza pracę podczas developmentu. Myślę, że narzędzie będzie potrzebne każdemu początkującemu w tym
frameworku bo dzięki niemu szybko utworzymy sam projekt jak i wszystkie elementy (komponenty, moduły , dyrektywy itp),
ale oprócz tego dostępnych jest sporo innych udogodnień, jak np. wbudowany webserver, który jest automatycznie
przeładowywany, a całość jest prekompilowana podczas każdej zmiany w kodzie.

Jedynie co trzeba zrobić to zainstalować globalnie node package. 
~~~
$ npm install -g @angular/cli
~~~

Po zainstalowaniu warto zobaczyć jakie daje nam możliwości to narzędzie wyświetlając pomoc.
~~~
$ ng help
ng build <options...>
  Builds your app and places it into the output path (dist/ by default).

ng completion <options...>
  Adds autocomplete functionality to `ng` commands and subcommands.

ng doc <keyword>
  Opens the official Angular documentation for a given keyword.

ng e2e <options...>
  Run e2e tests in existing project.

ng eject <options...>
  Ejects your app and output the proper webpack configuration and scripts.

ng generate <blueprint> <options...>
  Generates and/or modifies files based on a blueprint.

ng get <options...>
  Get a value from the configuration. Example: ng get [key]

ng help <command-name (Default: all)>
  Shows help for the CLI.

ng lint <options...>
  Lints code in existing project.

ng new <options...>
  Creates a new directory and a new Angular app eg. "ng new [name]".

ng serve <options...>
  Builds and serves your app, rebuilding on file changes.

ng set <options...>
  Set a value in the configuration.

ng test <options...>
  Run unit tests in existing project.

ng version <options...>
  Outputs Angular CLI version.

ng xi18n <options...>
  Extracts i18n messages from source code.
~~~
 
## Utworzenie projektu jest ekspresowe
Po zainstalowaniu *Angular CLI* jesteś gotowy aby utworzyć pierwszy projekt. W konsoli wpisz poniższe polecenia:
~~~
$ ng new PROJECT-NAME
$ cd PROJECT-NAME
$ ng serve --open
~~~
Poczekaj chwilę, aż wszystko się pobierze i przekompiluje... Ok, aplikacja już widoczna w Twojej przeglądarce? Wow, to
działa! Cały niezbędny zestaw do developmentu już ogarnięty i nie potrzebujesz instalować żadnych gruntów, gulpów czy
webpacków, nie musisz konfigurować żadnych zadań w tych task runnerach bo te które są Ci potrzebne na teraz już są dla
Ciebie skonfigurowane i wątpię czy będa Ci na razie potrzebne jakieś inne bajery.

## Pierwsze komponenty
Lecimy dalej! Stwórzmy pierwsze komponenty np. header, footer, nawigacja i stronę startową.

##### Footer i header
W konsoli wpisz polecenia niezbędne do utworzenia nowych  komponentów.
~~~
$ ng generate component header
$ ng generate component footer
~~~
Powinny zostać dodane nowe foldery `footer` i `header` w katalogu `src/app`, w których dostępny jest plik html, css oraz
dwa pliki w formacie *TypeScript* komponentu i testów. Na tę chwilę wystarczy wypełnić pliki html jakąś zawartością i 
w miarę potrzeb dodać jakieś style. Teraz aby nasze komponenty zostały wyświetlone w odpowiednim miejscu na stronie trzeba
je dodać do pliku html głównego komponentu aplikacji (`src/app/app.component.html`).

~~~angular2html
<app-header></app-header>
<app-footer></app-footer>
~~~

##### Nawigacja
Stwórzmy prostą nawigację aby przechodzić między stronami. W moim wypadku nawigacja jest częścią headera, więc dodam ją
jako podkomponent komponentu *header*.

~~~
$ ng generate component navigation
~~~

Plik html trzeba wypełnić jakimiś odnośnikami...
~~~html
<div class="collapse navbar-collapse">
  <ul class="nav navbar-nav navbar-right">
    <li><a href="/">Home</a></li>
    <li><a href="/boxes">Boxes</a></li>
  </ul>
</div>
~~~

Teraz trzeba dodać routing. Otwieramy główny plik modułu (`src/app/app.module.ts`) i tam trzeba zadeklarować odpowiednie
ścieżki. Poniżej wklejam kod, który trzeba dodać oprócz tego, który już tam istnieje.
~~~typescript
import { RouterModule, Routes } from '@angular/router';

const appRoutes: Routes = [
  { path: '', component: HomePageComponent },
  { path: 'boxes', component: BoxesComponent },
  { path: '**', component: PageNotFoundComponent }
];

@NgModule({
  imports: [
    RouterModule.forRoot(appRoutes)
  ]
})
~~~

## Podsumowanie