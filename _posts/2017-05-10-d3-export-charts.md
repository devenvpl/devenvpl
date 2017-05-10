---
date: 2017-05-10 23:20
title: "Eksport wykresów do pliku PNG (ze wsparciem dla IE11 & EDGE)"
layout: post
description: Zapiski z frontendowego pola walki przeciwko nieprzyjaznym przeglądarkom w czasie eksportu wykresów do pliku
tags: mksiazek dsp2017-mateusz javascript d3.js
category: dsp2017-mateusz
author: mksiazek
comments: true
---

Jeśli na Twojej stronie są dostępne jakieś wykresy możesz spodziewać się tego, że prędzej czy później Twoi użytkownicy
zapragną ich eksportu do pliku. Dzisiaj chciałbym opisać prosty sposób na eksportowanie wykresów narysowanych na SVG, w 
moim wypadku opartych o bibliotekę d3.js (ale to w sumie nie jest ważne co je namalowało :smiley:) jako plik PNG z 
przeźroczystym tłem.

Sposób może w miarę prosty, ale jeśli Twoja aplikacja musi obsługiwać IE11 i EDGE, możesz spodziewać się problemów. 
Przypadek? Nie sądzę. Myślę, że mogłeś się tego spodziewać :smiley:. I właśnie tego głównie będzie dotyczyć ten post - 
opisu jak się z tym uporałem.

## Podstawowa funkcjonalność
Jeden z [moich postów](/dsp2017-mateusz/2017/03/22/kursor-wykres-d3.html) dotyczył wykresów malowanych przy pomocy
biblioteki d3.js więc wykorzystam podstawy, które zostały tam zaimplementowane. Do tego co zostało wcześniej wypracowane
dodałem przycisk, po kliknięciu którego będzie wykonywany eksport.

##### Element canvas
Aby wyeksportować dane zapisane w formacie SVG do pliku PNG z pomocą przychodzi element [canvas](https://www.w3schools.com/html/html5_canvas.asp).
Poniżej przedstawiony jest kod funkcji, która przygotuje element `canvas` w rozmiarach opartych o rozmiary elementu SVG.
~~~javascript
function prepareCanvas(baseSVG) {
  var svgDimensions = baseSVG.getBoundingClientRect();
  var canvas = document.createElement('canvas');
  canvas.width = svgDimensions.width;
  canvas.height = svgDimensions.height;
  return canvas;
}
~~~

##### Konwersja danych
Trzeba zakodować dane zapisane w SVG do [base64](https://pl.wikipedia.org/wiki/Base64).
~~~javascript
function prepareImageData(baseSVG) {
  var xml = new XMLSerializer().serializeToString(baseSVG);
  var svg64 = btoa(unescape(encodeURIComponent(xml)));
  var b64Start = 'data:image/svg+xml;base64,';
  return b64Start + svg64;
}
~~~

##### Zapis obrazu na elemencie canvas
~~~javascript
function drawOnCanvas(canvas, imageData, exportProcessFn) {
  var img = new Image();
  var ctx = canvas.getContext('2d');
  img.src = imageData;
  img.onload = function () {
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
    exportProcessFn()
  };
}
~~~
W drugiej linii tworzony jest obiekt `Image`, do którego przypisywane są dane zakodowane w formacie base64 (linia 4).
Po załadowaniu danych na obraz można go umieścić w elemencie canvas (linia 6).

##### Obsługa kliknięcia w guzik i zapis do pliku
Po kliknięciu w przycisk trzeba wywołać funkcje, które zostały przedstawione powyżej.
~~~javascript
exportButton.addEventListener('click', exportToPng);
function exportToPng() {
  var baseSVG = document.getElementById('chart').getElementsByTagName('svg')[0];
  var canvas = prepareCanvas(baseSVG);
  var imageData = prepareImageData(baseSVG);

  drawOnCanvas(canvas, imageData, function () {
    canvas.toBlob(function (blob) {
      saveAs(blob, + 'chart.png');
    });
  });
}
~~~
Proces trzeba zacząć od pobrania elementu SVG, który nas interesuje (3 linia), następnie tworzony jest element canvas na
podstawie SVG oraz następuje konwersja danych (4 i 5 linia). W ostatnim kroku wywoływana jest funkcja, która zapisuje
dane na elemencie canva (7 linia), a jako 3 argument przekazywany jest callback, w którym wyciągamy dane *BLOB* z elementu
canva (8 linia), które można już zapisać jako normalny plik, trzeba jedynie wyzwolić proces pobierania. Można napisać do
tego swoje parę linii kodu, ale ja użyłem do tego prostej biblioteki [FileSaver.js](https://github.com/eligrey/FileSaver.js/)
(9 linia), którą również polecam bo zapewnia nam poprawne działanie na wszystkich popularnych przeglądarkach.

##### Style wykresów powinny być zahardkodowane inline
Jedną z niefajnych kwestii, które muszą być spełnione aby eksportowane wykresy wyglądały identycznie jak na stronie
jest fakt, że wszystkie style muszą być dodane inline, a nie w pliku CSS. Może istnieje jakieś bardziej eleganckie rozwiązanie,
ale przyznam szczerze, że ilość tych tyli była na tyle mała, że nie widziałem sensu większego researchu.

##### To działa!
Powyższe rozwiązanie działa na większości popularnych przeglądarek, jednak nie na Internet Explorer. Chyba nikogo to nie
zaskoczyło. Jednak trzeba się z tym jakoś uporać. 

## Wsparcie dla IE 11, Edge
Znalazłem rozwiązania, które zapewnią optymalne działanie dla wersji 11 i Edge (starszych nie testowałem).

##### IE posiada własną implementację funkcji `canvas.toBlob`
Pierwsza nieprawidłowość, która zablokowała działanie w przeglądarkach IE jest dość prosta w naprawie, jednak zaskakująca.
Większość przeglądarek korzysta z asynchronicznej funkcji `canvas.toBlob`, która zwraca obiekt BLOB z elementu canva, ale
przeglądarki z rodziny Microsoft posiadają swojego synchronicznego odpowiednika o tajemniczej nazwie `canvas.msToBlob`.
 
No więc trzeba trochę zmodyfikować wcześniejszy kod i używać funkcji `msToBlob` jeśli jest dostępna...
~~~javascript
if (canvas.msToBlob) {
  download(canvas.msToBlob());
} else {
  canvas.toBlob(download);
}

function download(blob) {
  saveAs(blob, + 'chart.png');
}
~~~

##### Funkcja `ctx.drawImage` nie działa jak należy w IE11
Problem napotkany z działaniem funkcji `ctx.drawImage` w IE11 mocno mnie zaskoczył. Nie dlatego, że coś nie działa jak należy.
Zaskoczył mnie bo problrm występuje w specyficznym momencie i było to zgłaszane kilkukrotnie w Issue Trackerach z
Microsoftu, jednak nic z tym nie zrobiono.

Funkcja `ctx.drawImage` nie działa w momencie kiedy obrazek, który chcemy wrzucić do elementu *canvas* jest zakodowany
w formacie base64 i problem występuje prawdopodobnie ze względu na implementację CORS w przeglądarce IE11.

W obejściu tego problemu z pomocą przyszła mi biblioteka [canvg](https://github.com/canvg/canvg), która jakoś sobie
poradziła z tym problemem. Bibliotekę używam **tylko i wyłącznie** dla przeglądarki IE11 jako **wyjątek** w celu
zapewnienia działania funkcjonalności. Problem związany z tą biblioteką jest taki, że wykryłem wycieki pamięci podczas
jej używania, dlatego jest ona wykorzystywana tylko warunkowo.

Zamiast zwykłej funkcji `drawOnCanvas`, dodałem drugą `drawOnCanvasForIE11`, która jest używana tylko w tym szczególnym
przypadku
~~~javascript
function drawOnCanvasForIE11(canvas, baseSVG, exportProcessFn) {
  canvg(canvas, (new XMLSerializer()).serializeToString(baseSVG), {
    ignoreDimensions: true,
    ignoreClear: true,
    ignoreMouse: true,
    ignoreAnimation: true,
    scaleWidth: canvas.width,
    scaleHeight: canvas.height
  });

  exportProcessFn();
}
~~~

## Działający przykład
<iframe width="100%" height="450" src="//jsfiddle.net/mejt/sLo88h3x/1/embedded/result,js,html/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>