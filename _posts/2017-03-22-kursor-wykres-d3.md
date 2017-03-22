---
date: 2017-03-22 17:08
title: Kursor na wykresie opartym o bibliotekę d3.js
layout: post
description: Koncepcja płynnego przechodzenia kursora na wykresie
tags: mksiazek dsp2017-mateusz javascript frontend d3.js
category: dsp2017-mateusz
author: mksiazek
comments: true
---

[d3.js](https://d3js.org/) to fantastyczna biblioteka pozwalająca na wizualizację danych. Idealnie sprawdza się do
tworzenia wykresów i trudno obecnie znaleźć konkurencję. Myślę, że jej popularność może obrazować prawie 62 tyś. zdobytych
gwiazdek na [repozytorium](https://github.com/d3/d3).

Dzisiejszym postem nie chcę opisywać podstaw jak tworzyć wykresy z wykorzystaniem tej biblioteki bo w internecie można
znaleźć tego mnóstwo. Chciałbym przedstawić jaki ostatnio napotkałem problem podczas dodania małej dynamiki do wykresów
liniowych.

## Opis problemu
Załóżmy, że mamy jakiś prosty wykres liniowy gdzie wartości są zależne od czasu. Poniżej wklejam jakiś gotowy wykres. 
<iframe width="100%" height="320" src="//jsfiddle.net/mejt/tzs0LyL9/6/embedded/result,js,css/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>
Naszym zadaniem jest dodanie małej interakcji do powyższego wykresu aby po najechaniu myszką zaznaczyć obecnie wybrane
miejsce. 

## Rozwiązanie
Na początek trzeba dodać dodatkowe elementy, które będa wyświetlane podczas ruchu myszą do bazowego SVG, a następnie
zapiąć się na jakieś zdarzenie (w tym wypatku 'mousemove'). Na szczęście *d3.js* z takimi kwestiami radzi sobie świetnie.

##### Krok 1
Do powyższego kodu dodałem funkcje, których zadaniem jest namalowanie dodatkowych elementów (linia na całą wysokość oraz
kropka na styku z linią danych).

~~~ javascript
function addFocusLine() {
  return svg.append('line')
    .attr('y0', 0)
    .attr('y1', height)
    .attr('x0', 0)
    .attr('x1', 0)
    .style('stroke-width', 1)
    .style('stroke', 'rgba(0,0,0,0.6)')
    .style('fill', 'none');
}

function addPoint() {
  return svg.append('g')
    .append('circle')
    .style('display', 'none')
    .attr('r', 4)
    .attr('fill', 'red');
}
~~~
Następnie czas ustawić nasłuchiwanie na zdarzenia myszy.
~~~ javascript
function addMouseAction() {
  var focusLine = addFocusLine();
  var point = addPoint();
  var bisectDate = d3.bisector(function (d) {
    return new Date(d.x);
  }).left

  svg.append('rect')
    .attr('class', 'overlay')
    .attr('transform', 'translate(' + (-15) + ',0)')
    .attr('width', width + 30)
    .attr('height', height)
    .attr('style', 'fill: none; pointer-events: all')
    .on('mouseout', function () {
    	point.style('display', 'none');
    	focusLine.style('display', 'none');
    })
    .on('mousemove', function () {
      var mouse = d3.mouse(this);
      var mouseX = mouse[0];
      var mouseY = mouse[1];
      var mousePos = mouseX - 15;
      var mouseAsDates = [x.invert(mousePos), x.invert(mouseY)];
      var index = bisectDate(data, mouseAsDates[0]);
      var d0 = data[index];
      var pointPos = y(d0.y);

      point.style('display', 'block');
      focusLine.style('display', 'block');
      focusLine.attr('transform', 'translate(' + mousePos + ',' + 0 + ')');
      point.attr('transform', 'translate(' + mousePos + ',' + pointPos + ')');
  });
}
~~~
Cała akcja polega na stworzeniu niewidocznej "nakładki" na wykresie, do której można przypiąć reakcję na wydarzenia. 
W linii 14 dodane jest nasłuchiwanie na event `mouseout`, po wykryciu którego nasze nowe elementy powinny być ukryte.
W linii 18 rejestrujemy reagowanie na wydarzenie `mousemove` co pozwala za każdym razem po zmianie pozycji myszki
na pobranie jej koordynat *xy* (linie 19-21) i wypozycjonować elementy (linie 33 i 34).

Ciekawe rzeczy dzieją się w liniach 24-26, ponieważ zostaje tutaj ustalony punkt na osi Y. Znajdujemy pod jakim najbliższym
indeksem w tablicy z danymi wejściowymi jest umieszczony obiekt pasujący do obecnie zaznaczonej daty na osi X. Ta operacja
wykonana jest dzięki funkcji [bisector](http://stackoverflow.com/questions/26882631/d3-what-is-a-bisector).
Następnym krokiem jest "wyciągnięcie" tego obiektu z tablicy [linia 80], a potem odwrócenie wartości na pozycję na osi Y
[linia 81].

<iframe width="100%" height="420" src="//jsfiddle.net/mejt/tzs0LyL9/2/embedded/result,js,css/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>
Jak widać na powyższym wykresie już coś działa, ale nie działa idealnie. Z odstępami między wynikami świetnie sobie radzi
d3.js po prostu prowadząc linię z jednego punktu do kolejnego, jednak my zaznaczając ten punkt po najechaniu myszką mamy
dziwny efekt na odstępach między danymi. Nie ma płynnego przejścia po linii wykresu naszej kropki, a raczej skacze od miejsca
do miejsca.

##### Krok 2
W internecie nie znalazłem żadnego sprytnego rozwiązania na to aby punkt podążał płynnie po linii wykresu. W zasadzie
wszystkie instrukcje wyglądały podobnie do powyższego kodu, ale przez to, że najczęścniej wrzucane tam były dane dla bardzo
szerokich zakresów z niewielkimi odstępami w czasie to efekt wydawał się dostateczny. W moim wypadku na wykresie bywają
przerwy w czasie, albo są po prostu duże odstępy między pomiarami. Skoro nie znalazłem żadnego "automatycznego"
rozwiązania trzeba było samemu coś zakodzić ;-)

Anazlizowałem obsługę tego wykresu aż wpadłem na to, że gdyby pobierać dwa punkty obok siebie zamiast jednego
(na podstawie indeksu opisanego w poprzednim akapicie) to wiedziałbym jaka jest między nimi odległość na osi X. Wiedziałbym
także na jakiej pozycji względem osi Y znajduje się punkt 1 i 2. Różnica daje mi odległość między 1 i 2 punktem.
Zakładając, że kursor myszy znajduje się akurat pomiędzy tymi punktami możemy wyliczyć pozycję gdzie powinna znajdować
się kulka dzięki prostemu wzorowi matematycznemu jakim jest [Twierdzenie Telasa](https://pl.wikipedia.org/wiki/Twierdzenie_Talesa).

Załóżmy, że dla obu punktów w czasie utworzymy obiekty, które zawierają koordonaty
~~~ javascript
var firstPoint = {x: x(new Date(d0.x)), y: y(d0.y)};
var secondPoint = {x: x(new Date(d1.x)), y: y(d1.y)};
~~~
Następnie zaimplementujmy funkcję, która wyliczy wysokość na jakiej powinna być wypozycjonowana kropka.
~~~ javascript
function getPositionByThales(currentWidth, previousPoint, currentPoint) {
  var firstHeight = previousPoint.y - currentPoint.y;
  var widthBetweenCursorAndNextPoint = currentPoint.x - currentWidth;
  var widthBetweenPoints = currentPoint.x - previousPoint.x;
  var secondHeight = (firstHeight * widthBetweenCursorAndNextPoint) / widthBetweenPoints;

  return secondHeight + currentPoint.y;
}
~~~
Efekt? Proszę zobaczyć poniżej :)
<iframe width="100%" height="420" src="//jsfiddle.net/mejt/tzs0LyL9/embedded/result,js,css/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

Mam nadzieję, że brak silnego tłumaczenia kodu nie był uciążliwy i w zagnieżdżonych fiddlach można w łatwy sposób zrozumieć
co się dzieje. Jeśli pojawią się jakieś wątpliwości, pytania lub pomysły na lepsze rozwiązanie tego problemu to zapraszam
do komentowania.
