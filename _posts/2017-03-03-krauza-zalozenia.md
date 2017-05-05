---
date: 2017-03-03 16:10
title: "Krauza - założenia do projektu"
description: Wstępne założenia i wprowadzenie do projektu
tags: mksiazek dsp2017-mateusz projekt krauza
category: dsp2017-mateusz
author: mksiazek
comments: true
layout: post-with-related-tag
related_tag: "krauza"
related_title: "Zobacz inne posty związane z projektem Krauza"
---

W ramach konkursu [Daj się poznać](http://dajsiepoznac.pl) postanowiłem zrealizować projekt [Krauza](https://github.com/mejt/Krauza)\*,
który w założeniach będzie implementacją kartoteki autodydaktycznej, czyli popularnego systemu nauki potocznie zwanego
jako fiszki. Chciałbym aby aplikacja swoim działaniem była jak najbardziej zbliżona do rzeczywistej pracy z fiszkami
oraz dobrze odwzorowywała metodę Leitnera opisaną w książce "*Naucz się uczyć*".

Tę aplikację tworzyłem już jakiś czas temu, jednak było to raczej "radosne kodzenie"  co z czasem musiało skutkować tym,
 że nic dobrego z tego nie wyszło. Wziąłem też na siebie próbę implementacji
[DDD](http://simon-says-architecture.com/2010/06/28/programowanie-przez-modelowanie/) nie posiadając na ten temat za
dużej wiedzy. Popełniłem sporo błędów, których teraz chciałbym uniknąć, więc dlatego zamierzam wrócić do projektu
i doprowadzić go do końca jako solidny, działający [MVP](https://en.wikipedia.org/wiki/Minimum_viable_product).

## Co to za pomysł, komu to potrzebne?
Nie uważam, żeby to była najistotniejsza kwestia, niestety nie wpadłem na pomysł zrealizowania projektu, który odmieni
losy ludzkości. I osobiście wątpię czy realizowałbym go jako projekt OpenSource w ramach konkursu gdybym taki wymyślił ;-)

Założenie jest takie, aby stworzyć standardowy [pet project](http://devstyle.pl/2015/03/09/o-pet-projects/) i mam nadzieję,
że pozwoli mi on na praktyczne zastosowanie technik i umiejętności, które nabyłem w ostatnim czasie, a przy okazji nauczyć
się czegoś nowego. Czy faktycznie aplikacja znajdzie kiedyś jakieś zastosowanie w rzeczywistości? Nie wiem, fajnie by
było, ale nie to jest najwyższym celem.

# Wymagania
## Planowanie
Patrząc z perspektywy czasu myślę, że będzie to najważniejsza część projektu. Na samym początku chciałbym stworzyć listę
zadań do zrealizowania oraz przemyśleć architekturę aplikacji.

## Co aplikacja powinna zawierać
Podstawowa wersja aplikacji nie powinna być skomplikowana...
* *Konta użytkowników* - dostępna rejestracja i profil użytkownika w ramach, którego można zarządzać swoimi kartotekami.
* *Kartoteki użytkownika* - każdy użytkownik może tworzyć i zarządzać swoimi kartotekami (dodawać nowe karty [fiszki],
lub je edytować). 
* *Proces nauki* - najważniejszy element aplikacji, który ze strony użytkowej wydaje się prosty, jednak prawidłowa
implementacja tego procesu może okazać się ciut skomplikowana. 

## Technologia
Nie chcę w tym momencie skupiać się na wyborze poszczególnych narzędzi, które będa użyte podczas implementacji. Na tę
chwilę mogę powiedzieć, że backend powstanie w najnowszej wersjii PHP. Nie mam zamiaru z góry zakładac użycia jakiegoś
typu bazy danych lub frameworka. Najpierw trzeba wszystko dobrze poukładać i nie zamykać się na jeden typ rozwiązania.

---
*\* Krauza w gwarze śląskiej to nic innego jak słoik ;-)* 
