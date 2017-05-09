---
date: 2017-05-02 22:40
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

##### Pierwsza iteracja (bez wsparcia dla IE)

~~~javascript
exportButton.addEventListener('click', exportToPng);
function exportToPng() {
  var baseSVG = document.getElementById('chart').getElementsByTagName('svg')[0];
  var canvas = prepareCanvas(baseSVG);
  var imageData = prepareImageData(baseSVG);

  drawOnCanvas(canvas, imageData, function () {
    canvas.toBlob(download);
  });
}

function prepareCanvas(baseSVG) {
  var svgDimensions = baseSVG.getBoundingClientRect();
  var canvas = document.createElement('canvas');
  canvas.width = svgDimensions.width;
  canvas.height = svgDimensions.height;
  return canvas;
}

function prepareImageData(baseSVG) {
  var xml = new XMLSerializer().serializeToString(baseSVG);
  var svg64 = btoa(unescape(encodeURIComponent(xml)));
  var b64Start = 'data:image/svg+xml;base64,';
  return b64Start + svg64;
}

function drawOnCanvas(canvas, imageData, exportProcessFn) {
  var img = new Image();
  var ctx = canvas.getContext('2d');
  img.src = imageData;
  img.onload = function () {
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
    exportProcessFn()
  };
}

function download(blob) {
  saveAs(blob, + 'chart.png');
}
~~~

