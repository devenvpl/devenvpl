---
date: 2017-05-22 20:45
title: "Ciąg dalszy eksportu wykresów do plików. PDF"
layout: post
description: Wydajnie działający eksport wykresów do pliku PDF
tags: mksiazek dsp2017-mateusz javascript d3.js
category: dsp2017-mateusz
author: mksiazek
comments: true
---

Prezentowałem sposób na [eksport wykresów zapisanych w formacie SVG do pliku PNG](/dsp2017-mateusz/2017/05/10/d3-export-charts.html),
często jednak oprócz eksportu do samego obrazka trzeba także zapewnić możliwośc pobrania pliku PDF i o tym dzisiaj będzie
ten post.

Około 70% procesu eksportu do PDF załatwione już zostało przy okazji eksportu do PNG dlatego też nie będę tutaj opisywał
aspektów, które zostały poruszone w poprzednim poście, więc aby rozwiać wątpliwości zachęcam się z nim zapoznać.

## jsPDF
Z pomocą przychodzi biblioteka [jsPDF](https://github.com/MrRio/jsPDF), dzięki której można tworzyć dokumenty PDF po stronie
przeglądarki internetowej. Poprzednio generowany obrazek z bazowego SVG będzie świetną podstawą bo wystarczy tylko go
"przechwycić" i dodać do dokumentu PDF.

## Flow
1. Pobranie elementu SVG
~~~javascript
var baseSVG = document.getElementById('chart').getElementsByTagName('svg')[0];
~~~

2. Przygotowanie obiektu *canvas* z rozmiarami na podstawie elementu SVG.
~~~javascript
function prepareCanvas(baseSVG, scale) {
  var svgDimensions = baseSVG.getBoundingClientRect();
  var canvas = document.createElement('canvas');
  canvas.width = svgDimensions.width * scale;
  canvas.height = svgDimensions.height * scale;
  return canvas;
}
~~~
Polecam te rozmiary przeskalować conajmniej 4-krotnie aby zwiększyć jakość wyeksportowanego wykresu w PDF.
Niestety konwertując SVG do obrazka staje się on grafiką rastrową więc aby zapewnić dobrą jakość trzeba odpowiedni
powiększyć *canvas* (jednak nie warto przesadzić, myślę, że 8-krotne powiększenie to maksymalna wartość).

3. **Dodanie białego tła do nowego elementu *canvas*** :exclamation:
~~~javascript
function addBackgroundToCanvas(canvas) {
  var ctx = canvas.getContext('2d');
  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = 'black';
}
~~~
To ważny punkt, którego nie można pominąć. Domyślnie *canva* jest przeźroczysta, ale po eksporcie do PDF i tak jest białe
tło. Aby znacząco przyspieszyć proces eksportu warto ustawić tło elementu *canvas*. Napotkałem taki problem, że dodawanie
obrazka do dokumentu trwało kilka sekund, a przy okazji blokowało całą przeglądarkę co jest niedopuszczalne. Powodem było,
że konwertowanie obrazka z przeźroczystym tłem używało nieoptymalnego algorytmu biblioteki jsPDF.

4. Przygotowanie danych obrazka w formacie *base64*
~~~javascript
function prepareImageData(baseSVG) {
  var xml = new XMLSerializer().serializeToString(baseSVG);
  var svg64 = btoa(unescape(encodeURIComponent(xml)));
  var b64Start = 'data:image/svg+xml;base64,';
  return b64Start + svg64;
}
~~~

5. Dodanie obrazka do elementu *canvas*
~~~javascript
function drawOnCanvas(canvas, imageData, exportProcessFn) {
  var img = new Image();
  var ctx = canvas.getContext('2d');
  img.src = imageData;
  img.onload = function () {
     ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
     exportProcessFn();
  };
}
~~~

6. Uworzenie obiektu `jsPDF`
~~~javascript
var doc = new jsPDF({
  orientation: 'landscape',
  unit: 'mm',
  format: 'a4'
});
~~~
Biblioteka *jsPDF* posiada wiele opcji, które można zobaczyć w dokumentacji. Na nasze potrzeby deklarujemy tylko
orientację kartki, jednostkę i format.

7. Dodanie obrazka do dokumentu z elementu *canvas*
~~~javascript
var imgDimensions = getImageDimensions(canvas);
doc.addImage(
  canvas.toDataURL('image/jpeg'),
  'JPEG',
  imgDimensions.x,
  imgDimensions.y,
  imgDimensions.width,
  imgDimensions.height,
  '',
  'FAST'
);
~~~
Do obliczenia wymiarów obrazka napisałem funkcję, która może pomóc zmapować rozmiar obrazka zawarty w pikselach na milimetry
~~~javascript
function getImageDimensions(canvas) {
  var margin = 4;
  var pixelToMillimeter = 0.264583333;
  return {
       x: margin,
       y: margin,
       width: canvas.width * pixelToMillimeter,
       height: canvas.height * pixelToMillimeter
  };
}
~~~
*W przykładzie na samym dole ta funkcja jest trochę bardziej rozbudowana bo zawiera jeszcze zabezpieczenie jeśli szerokość
eksportowanego obrazka przekracza szerokość kartki*.

8. jsPDF posiada wbudowaną metodę, która wyzwala pobieranie, wystarczy tylko wywołać...
~~~javascript
doc.save('chart.pdf');
~~~

## Działający przykład
<iframe width="100%" height="450" src="//jsfiddle.net/9f84e9a2/1/embedded/result,js,html/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>
Nie wszystkie elementy, które znajdują się w powyższym kodzie zostały opisane ze względu na to, że dziejszy post jest
rozwinięciem [eksportu wykresów do obrazków](/dsp2017-mateusz/2017/05/10/d3-export-charts.html), o których można było
przeczytać poprzednio. Zachęcam zapoznać się z tamtym materiałem przede wszystkim jeśli potrzebujesz zapewnić wsparcie
dla przeglądarek Microsoftu :smiley:
