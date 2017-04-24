---
date: 2017-04-25 00:35
title: "const i let w javascript (es6) - kiedy ich używać"
layout: post
description: Kilka słów o dobrych praktykach deklarowania zmiennych w Javascript
tags: mksiazek dsp2017-mateusz programowanie javascript nodejs es6
category: dsp2017-mateusz
author: mksiazek
comments: true
---

Od kilku lat głośno było o wielkich zmianach w języku Javascript, które są wprowadzane w ramach standardu 
[ES6](https://nafrontendzie.pl/ecmascript-6-co-nowego/). Jedną z najważniejszych i najpopularniejszych zmian to nowe
słowa kluczowe pozwalające na deklaroweanie zmiennych. Oprócz `var` doszedł jeszcze `const` i `let`.

W projekcie nad którym mam okazję pracować stopniowo zaczęliśmy zastępować starego dobrego `var` na nowe słowa kluczowe.
Cały proces odbywa się w miarę naturalnie, i najczęściej po prostu zamiast `var` stosowany jest `let`, a w momencie
gdy deklarujemy jakieś niezmieniające się wartości używamy `const`. Jakie to proste, nic tylko kodzić :joy:

Ostatnio jednak zaczęliśmy się zastanawiać czy wszyscy członkowie zespołu mają podobne podejście do nowych słów kluczowych
i czy nie warto ujednolicić tych zasad. No i jak się okazuje sprawa nie jest taka oczywista jak się to mogło wydawać :smiley:

Na początek jednak małe przypomnienie...

## Czym różni się let i const od var
Jeśli temat już jest dla Ciebie znany to możesz skoczyć do kolejnego punktu :smiley:

Ogólnie rzecz biorąc tradycyjne deklarowanie zmiennych przy pomocy słowa kluczowego `var` mogło powodować dziwne efekty
uboczne w projektach realizowanych przez mniej doświadczonych programistów języka Javascript. Wiążą się z tym dwa aspekty,
które różnią się od innych języków programowania: zakres zmiennych (scope) i hoisting.

##### Scope
Zmienna zadeklarowana wewnątrz funkcji jest widoczna tylko w jej obrębie.
~~~javascript
function myFunction() {
    var a = 1;
}

myFunction();
console.log(a); // Uncaught ReferenceError: a is not defined
~~~

Ale... Jeśli nigdzie nie zadeklarujemy zmiennej i mimo wszystko przypiszemy do niej wartość wewnątrz funkcji, to
staje się ona globalnie dostępna...
~~~javascript
function myFunction() {
    a = 1;
}

myFunction();
console.log(a); // 1
~~~
Na szczęscie w tym wypadku rozwiązaniem jest użycie [strict mode](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode),
którego polecam używać zawsze i wszędzie.

Zmienna zadeklarowana z użyciem `var` wewnątrz pętli lub w warunku jest widoczna na zewnątrz tego bloku.
~~~javascript
if (true) {
    var a = 2;
}

console.log(a); // 2
~~~
~~~javascript
for (var a = 0; a < 5; a++) {
    // ...
}

console.log(a); // 5
~~~

I tutaj właśnie z pomocą przychodzą `let` i `const`, które zmieniają to działanie:
~~~javascript
if (true) {
    const a = 2;
}

console.log(a); // Uncaught ReferenceError: a is not defined
~~~
~~~javascript
for (let a = 0; a < 5; a++) {
    // ...
}

console.log(a); // Uncaught ReferenceError: a is not defined
~~~


##### Hoisting
W sumie nie wiem czy to bug czy feature, ale jest możliwość przypisania wartości do zmiennej zanim zostanie ona
zadeklarowana ze słowem kluczowym `var`. W moim odczuciu to strasznie głupie. Dlatego zawsze dbam aby wszystkie zmienne
były deklarowane a początku bloku.

Dajmy przykład zachowania...
~~~javascript
function myFunction() {
    a = 5;
    console.log(a); // 5

    var a;
}

myFunction();
~~~

Możemy być pewni, że takie działannie przy użyciu słów kluczowych `const` albo `let` nie przejdzie.
~~~javascript
function myFunction() {
    a = 5;
    console.log(a); // Uncaught ReferenceError: a is not defined

    let a;
}

myFunction();
~~~

## Kiedy używać const, a kiedy let
Po krótkim przypomnieniu jakie są główne różnice między `var`, a `const` i `let` warto przejść do najważniejszej częsci
tego posta, a mianowicie zastanowienia się kiedy używać każdego z tych słów kluczowych.

Na początek przyjmijmy zasadę numer 1, jeśli już piszemy aplikację zgodnie z ES6: **Rezygnujemy z używania `var`**.
Od teraz możesz śmiało uznać `var` jako *DEPRECATED* i pozbywać się go sukcesywnie ze swojego projektu :smiley:

Ustaliliśmy główną zasadę, `var` to już historia. 

##### const
Deklaracja zmiennej z użuciem `const` musi mieć przypisaną wartość, bo inaczej zostanie rzucony wyjątek:
~~~javascript
const a; // Uncaught SyntaxError: Missing initializer in const declaration
~~~

Zadeklarowanej zmiennej typu prymitywnego, nie pozwoli zmienić już tej wartości.
~~~javascript
const a = 5;
a = 7; // (Uncaught TypeError: Assignment to constant variable.)
~~~

Jednak w javascriptcie nic nie jest oczywiste :stuck_out_tongue:, tym razem też nie do końca `const` oznacza to samo co w innych
językach programowania. Używając `const` nie deklarujemy stałej wartości, a stałą referencję. O ile deklarujemy zmienną
z prymitywną wartością, np. typu `Number` to już jej nie zmienimy bo zostanie rzucony wyjątek. Ale jeśli deklarowana
zmienna przyjmuje obiekt albo tablicę to możemy spokojnie zmieniać ich zawartość.

~~~javascript
const b = {};
const c = [];

b.p = 3;
c.push('a');

console.log(b); // Object {p: 3}
console.log(c); // ["a"]
~~~

Tak naprawdę to wnosi ciekawe możliwości. Możemy dowolnie manipulować zawartością obiektu lub tablicy i mamy pewność,
że ich referencja się nie zmieni. To znaczy, że możemy mieć pewność, że w żadnym miejscu tablica nagle nie zmieni się
w `null`, `Number` lub cokolwiek innego. Dlatego **do deklarowania obiektów i tablic powinniśmy używać słowa kluczowego `const`**.

Trzeba odejść od myślenia, że `const` to jakaś zmienna konfiguracyjna lub coś w tym stylu co najczęściej deklarujesz
DUŻYMI_LITERAMI na początku pliku. Dzięki temu, że `const` to zwykła zmienna posiadająca stałą referencję, stanowi
dodatkowe zabezpieczenie przed efektami ubocznymi, które mogą nie zostać zauważone od razu. **Staraj się stosować `const`
jak najczęściej**.

##### Jak stworzyć niezmienny obiekt?!
Są sytuacje, że chcemy aby obiekt lub tablica były całkowicie niemodyfikowalne, chociażby wtedy gdy chcemy je zastosować
jako wspomniana wyżej "konfiguracja". Możemy to załatwić funkcją `Object.freeze`, która nie pozwoli na żadną modyfikację.

~~~javascript
const CONFIG = Object.freeze({
    URL: 'http://devenv.pl',
    NAME: 'DevEnv'
});

CONFIG.NAME = 'replaces';
console.log(CONFIG); // Object {URL: "http://devenv.pl", NAME: "DevEnv"}
~~~

##### let
Tak naprawdę temat został wyczerpany podczas opisywania słowa kluczowego `const`. Co tu więcej mówić... Używaj `let` 
wszędzie tam, gdzie zmienna musi być zmieniana (WAT? :stuck_out_tongue: W sensie *mutable variable*), czyli np. w pętlach.

## Trzy podstawowe zasady
1. Zapomnij o `var`.
2. Tam gdzie to możliwe stosuj `const`.
3. Jeśli już musisz to zadeklaruj zmienną z użyciem `let`.
