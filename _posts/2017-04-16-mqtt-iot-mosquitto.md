---
date: 2017-04-16 13:30
title: "MQTT - protokół transmisji danych dla IoT"
layout: post
description: "Wstęp do protokołu MQTT z wykorzystaniem brokera Mosquitto."
tags: apietka dsp2017-adrian mqtt mosquitto iot integration-patterns
category: dsp2017-adrian
author: apietka
comments: true
---

**Protokół MQTT** (*Message Queue Telemetry Transport*) jest lekkim protokołem transmisji danych. Został stworzony w 1999 roku przez Andy'ego Stanforda-Clarka (IBM) oraz przez Arlena Nippera (Eurotech). Oparty o wzorzec *Publish-Subscribe* (*topic-based*), umożliwia komunikację pomiędzy systemami za pomocą serwera pośredniczącego. *MQTT* w aktualnej wersji specyfikacji (3.1.1) jest także standardem ISO/IEC (ISO/IEC PRF 20922).

Ze względu na łatwość użycia, niskie zapotrzebowanie względem zasobów sprzętowych oraz sieciowych stał się kluczowym protokołem wykorzystywanem w **IoT** (*Internet of Things*).

## Zastosowanie

Protokół *MQTT* wykorzystuje m.in. Facebook Messenger, Amazon w usłudze [AWS IoT](https://aws.amazon.com/iot/) oraz szeroko pojęta dziedzina medycyny np. podczas komunikacji drogą radiową z rozrusznikami serca. Oczywiście to jedynie wybrane przykłady zastosowań.

W moim przypadku protokół *MQTT* wykorzystywany był do wymiany danych pomiarowych, pochodzących z czujników badających zanieczyszczenie powietrza.

## Publish-Subscribe pattern

*MQTT* oparty jest o wzorzec *Publish-Subscribe*. W takiej architekturze wiadomości wysyłane przez nadawców (*publisher*) trafiają do serwerza pośredniczącego (*broker*), a nie bezpośrednio do odbiorców (*subscriber*). Wzorzec ten jest jednym z [wzorców integracyjnych](http://www.enterpriseintegrationpatterns.com/patterns/messaging/index.html).

Odbiorca otrzymuje wiadomości którymi faktycznie jest zainteresowany, nie wie nic na temat jej nadawcy. Nadawca także nie wie który z obiorców otrzyma wiadomość. Nie wiadomo także czy nadaną wiadomość w ogóle ktoś odbierze.

Przy takim rozwiązaniu komunikacji nie występuję tzw. *pooling*, czyli cykliczne odpytywanie serwera czy pojawiły się nowe dane (zapytanie => odpowiedź). Można powiedzieć, że odwrócono koncept o 180 stopni i to serwer poinformuje zainteresowanych klientów o nowej wiadomości.

Jako, że implementacja *MQTT* opiera się o *topic-based*, oznacza to, że wiadomość publikowana jest na tzw. temat (*topic*). Klienci którzy subskrybują dany temat (*topic*) otrzymują opublikowane na nim wiadomości. Warto dodać, że podczas nadawania wiadomości nie musimy przejmować się tym czy dany temat istnieje - nie istnieje coś takiego jak zarządzanie tematami (tworzenie/usuwanie), po prostu wysyłamy dane.

Wzorzec ten jest świetnym pomysłem na osobny artykuł. Ja tym czasem odsyłam was do dokładniejszej lektury chociażby na [Wikipedii](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern).

## Jak to działa?

Generalnie zasada jest bardzo prosta. Do serwera (*broker*) podłączają się klienci. Klient może wysłać wiadomość na dany temat (*topic*) lub odbierać wiadomości na wybranych przez siebie tematach (*topic pattern*).

Możemy zatem wydzielić trzy odpowiedzialności:

### Broker

Serwer, pośrednik w komunikacji. Odpowiedzialny za dostarczanie wiadomości. To do *brokera* podłączają się klienci w celu wysyłania oraz odbierania danych. Taki serwer pośredniczący możemy implementować sami. Jednak ze względu na sporą ilość gotowych i sprawdzonych rozwiązań, proponuję zapoznać się z najpopularniejszymi brokerami specjalizującymi się w protokole *MQTT*:

- [Mosquitto](https://mosquitto.org/),
- [VerneMQ](https://vernemq.com/),
- [HiveMQ](http://www.hivemq.com/),
- [RabbitMQ](https://www.rabbitmq.com/mqtt.html) - za pomocą dodatkowego rozszerzenia.

W moim przypadku wykorzystywany był *Mosquitto*, którego instalacja w systemie Ubuntu 16.04 ograniczała się jedynie do wydania polecenia:

```
$: sudo apt-get install mosquitto
```

### Publisher

Nadawca wiadomości. Podmiot publikujący dane na konkretnym temacie. Dane publikowane przy użyciu protokołu *MQTT* są danymi tekstowymi. Oznacza to, że z łatwością możemy zserializować strukturę danych do formatu *JSON* (lub innego dowolnego formatu tekstowego np. *XML*), a następnie ją opublikować. Rolą odbiorcy dodatkowo będzie deserializacja danych.

### Subscriber

Odbiorca wiadomości. Podmiot nasłuchujący na wybranych tematach, z możliwością nasłuchiwania na tematach o określonym szablonie.

#### Hierarchical Topic & Topic Pattern

Definicja tematów powinna wyglądać w sposób hierarchiczny. Tak aby umożliwić łatwiejsze nasłuchiwanie na wybranych tematach. Dla zobrazowania przykładu zdefiniowałem następujący format: ```device/[numerUrzadzenia]/[parametr]```.

Wskazanie konkretnego subskrybowanego tematu. Nasłuchiwanie danych nt. temperatury dla konkretnego urządzenia:

```
device/01/temperature
```

Znak *plusa* dopasowuje się do dowolnej nazwy na jednym poziomie. Nasłuchiwanie danych nt. temperatury na wszystkich urządzeniach:

```
device/+/temperature
```

Znak *hasz* dopasowuje się do wszystkich zagłębień poziomu. Nasłuchiwanie danych dla wszystkich parametrów urządzenia:

```
device/01/#
```

#### Quality of Service (QoS)

W zależności od ustawienia poziomu QoS, decydujemy czy wysłana wiadomość musi zostać odebrana przez subskrybenta. Specyfikacja *MQTT* definiuje 3 poziomy *Quality of Service*:

- 0 - wysłana wiadomość nie potrzebuje potwierdzenia dostarczenia, wysyłamy i zapominamy,
- 1 - wysłana wiadomość musi zostać dostarczona przynajmniej raz, potwierdzenie jest wymagane, wiadomość może zostać dostarczona do wielu odbiorców (potencjalne miejsce na duplikację przetwarzania odebranej wiadomości),
- 2 - wysłana wiadomość musi zostać dostarczona dokładnie do jednego odbiorcy (*four step handshake*), potwierdzenie jest wymagane.

Jeżeli wiadomość nie została odebrana, zostanie nadana jeszcze raz. Cykl ponownego przesyłania wiadomości zależy od konfiguracji serwera pośredniczącego.

### Podwójna odpowiedzialność

Do podziału zaprezentowanego powyżej należy dodać jeden znaczący fakt. Jeden klient podłączony do serwera może spełniać dwie role - nadawcy (*publisher*) i odbiorcy (*subscriber*). Nic nie przeszkadza w tym, aby np. po otrzymaniu wiadomości na jakimś temacie zareagować podobnie i wysłać nową wiadomość na inny temat.

## Przykład w oparciu o node.js

Do nawiązania połączenia z użyciem protokołu *MQTT* wykorzystałem bibliotekę dostępną w *npm* - [npmjs.com/package/mqtt](https://www.npmjs.com/package/mqtt). Instalacja:

```
$: npm install mqtt --save
```

Sam skrypt wygląda w sposób następujący:

~~~js
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://mosquitto-host.vm.lan', {clear: true}); // 1

client.on('connect', connect); // 2
client.on('message', message); // 3

function connect() {
    client.publish('presence', 'Hello MQTT!'); // 4
    client.subscribe('device/+/temperature', {qos: 0}, (err, granted) => { // 5
        err ? console.log('SUB ERROR:', err) : console.log('SUB GRANTED:', granted);
    });
}

function message(topic, message) {
    console.log('RECEIVED:', topic, message.toString());
}
~~~

1. Nawiązanie połączenia z brokerem oraz definicja ustawień. ```clean``` oznacza czy chcemy rozpocząć pracę:
    - od pustej *kolejki*, wartość ```true```,
    - odebrania wiadomości, które nie zostały przetworzone (dla QoS 1 i 2), wartość ```false```,
2. Definicja zdarzeń które mają zostać wykonane po nawiązaniu połączenia z brokerem,
3. Definicja zdarzenia po otrzymaniu wiadomości na zasubskrybowanych tematach, w tym przypadku informujemy jedynie użytkownika komunikatem na konsoli,
4. Publikacja wiadomości ```Hello MQTT!``` w temacie ```presence```,
5. Zasubskrybowanie tematów spełniających szablon, ustawiamy poziom *QoS* równy 0.

## Podsumowanie

*MQTT* jest prostym w zrozumieniu i obsłudze protokołem dającym spore możliwości. Jest szybki i nie wymaga dużego narzutu na transportowane dane. Spora ilość gotowych *brokerów* oraz bibliotek klienckich (dla różnych języków programowania) sprawia, że jest to protokół który można wykorzystywać bez względu na platformę. Zapewnia luźne powiązania pomiędzy klientami. Dodatkowo umożliwia ustalenie czy dana wiadomość musi zostać dostarczona do obiorcy. Świetnie sprawdza się w zastosowaniach IoT, co potwierdzam osobiście ze względu na dobrze działający, wdrożony system :-)

Polecam także inne artykuły związane z tematem:

- [Getting Started With MQTT](https://dzone.com/refcardz/getting-started-with-mqtt)
- [MQTT (MQ Telemetry Transport)](http://internetofthingsagenda.techtarget.com/definition/MQTT-MQ-Telemetry-Transport)
- [Getting Started with Node.js and MQTT](https://blog.risingstack.com/getting-started-with-nodejs-and-mqtt/)
