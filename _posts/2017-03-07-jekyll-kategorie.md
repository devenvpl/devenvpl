---
date: 2017-03-07 23:20
title: "Pierwsze zetknięcie z Jekyll. Podział na kategorie"
layout: post
description: Krótki opis "pierwszych chwil" z Jekyllem oraz mały tutorial jak zorganizować strony z kategoriami
tags: mksiazek dsp2017-mateusz jekyll
category: dsp2017-mateusz
author: mksiazek
comments: true
---

Nasz blog *devenv* hostowany jest na [github pages](https://pages.github.com/) z wykorzystaniem narzędzia 
[jekyll](https://jekyllrb.com/). Jeszcze 3 tygodnie temu *github pages* kojarzyły mi się tylko jako statyczne stronki HTML,
jednak kiedy postanowiliśmy uruchomić bloga i zastanawialiśmy się czy ma to być kolejna strona oparta o *WordPressa*,
@adrianpietka zaproponował użycie *Jekyll*a. Nie miałem nic przeciwko, tym bardziej, że "instalacja" zajęła mu chwilkę, a dla
mnie to kolejna nowość, którą warto poznać.

Jeśli w przyszłości to rozwiązanie okaże się niewystarczające to zawsze można zmienić, ale na razie wydaje się być
całkiem ok ;-)

## Jekyll - jak to działa?
Kiedy pobrałem pierwszy raz kod z repozytorium i odpaliłem dokumentację to trochę się zdziwiłem. *Github pages* to statyczny
HTML, a *Jekyll* to projekt napisany w *ruby*. Więc... W jaki sposób to działa? Github musi jakoś to interpretować...

Długo nie trzeba było szukać, w informacjach na *github pages* można znaleźć info o tym, że wspierany jest *Jekyll*, a 
dodatkowo kilka dodatkowych pluginów. Wszystkie wersje zależności używanych przez *github pages*, można zobaczyć
[na tej stronie](https://pages.github.com/versions/).

## Nie ma tak kolorowo
W internecie można znaleźć mnóstwo pluginów oraz przykładowych implementacji, które mają dodać jeszcze większej mocy
stronie opartej na *Jekyll*u. Jest tylko jeden problem, o którym można przeczytać w
[dokumentacji](https://jekyllrb.com/docs/plugins/):
> GitHub Pages is powered by Jekyll. However, all Pages sites are generated using the --safe option to disable custom
plugins for security reasons. Unfortunately, this means your plugins won’t work if you’re deploying to GitHub Pages.

> You can still use GitHub Pages to publish your site, but you’ll need to convert the site locally and push the generated
static files to your GitHub repository instead of the Jekyll source files. 

Tak więc jeśli nie masz ochoty wysyłać pełno wygenerowaych plików HTML trzeba ograniczyć się do możliwości, które daje 
"goły" *Jekyll* albo ewentualnie wykorzystać pluginy wspierane przez *github pages* dostępne na liście, którą można znaleźć
wyżej w poprzedniej sekcji.

## Podział na kategorie
Pierwszy problem z jakim się napotkaliśmy było stworzenie podstron dla kategorii. Na blogu *devenv* przyjęliśmy zasadę,
że jeden post może być przydzielony tylko do jednej kategorii, tak więc dobrze by było aby po wejściu na stronę powiedzmy
*adres.pl/super-kategoria.html* pojawiła się lista postów tylko z tej kategorii. Jak by to zrobić bezboleśnie?

###### Layout
Na początek trzeba stworzyć templatkę, która będzie wyświetlać listę postów. Trzeba dodać nowy plik do katalogu 
*_layouts/*. W tym wypadku dodajemy plik *page_category.html*.
{% raw %}
```html
---
layout: default
title: {{ page.category }}
---

<div id="home">
  <h2 class="page-header">
    Kategoria: <span class="color">{{ page.category }}</span>
  </h2>
  <ul class="posts">
    {% for post in site.posts %}
      {% if post.category == page.category %}
        <li>{{ post.title }}</li>
      {% endif %}
    {% endfor %}
  </ul>
</div>
```
{% endraw %}

Cała "logika" znajduje się w 10 i 11 linii. Iterujemy po wszystkich postach, a następnie wyświetlamy tylko te, które
należą do właściwej kategorii.

###### Kolekcje
Dla każdej strony z kategoriami trzeba stworzyć plik, który będzie ją wyświetlał. Aby uniknąć zanieczyszczenia projektu
z różnymi plikami w głównym katalogu z pomocą przychodzą *kolekcje*, które pozwalają grupować różne elementy strony.

Aby zadeklarować kolekcję trzeba dodać do pliku *_config.yml* sekcję, w tym wypadku dodamy *categories*
```yaml
collections:
  categories:
    output: true
```
Dzięki temu zabiegowi wszystkie pliki *\*.md* dodawane do katalogu o nazwie kolekcji z poprzedzającym underscorem, czyli
*_categories* będą renderowane jako pliki *\*.html*

No to czas dodać plik, który zadeklaruje tę kategorię. Tworzymy plik *_categories/super-kategoria.md*
```markdown
---
permalink: /super-kategoria.html
layout: page_category
category: 'super-kategoria'
---
```
W 2 linii można ustawić *permalink* czyli adres, pod którym będzie wyświetlana strona, w 3 linii wybrany został layout,
który został utworzony wcześniej, a w 4 linii bindujemy odpowiednią kategorię.

###### Czy jest to dobre?
Niestety nie znalazłem na to "super-automatycznego" rozwiązania i kiedy potrzebna jest strona dla danej kategorii trzeba
ręcznie utworzyć nowy plik z deklaracją. Nie jest to idealne rozwiązanie, ale jest na tyle dobre, że nie trzeba edytować
sporej ilości plików jeśli będzie potrzebna jedna zmiana w layoucie. Po za tym daje to też taki plus, że możemy utworzyć
podstrony tylko dla tych kategorii, których chcemy.

## Przemyślenia na koniec
Podsumowując, muszę stwierdzić, że jak na razie jestem bardzo zadowolony z narzędzia *Jekyll* i myślę, że jeszcze długo,
będziemy wykorzystywać to rozwiązanie. Nie wszystko jest tutaj idealne, ale czy istnieje taki system? Nie. Dlatego jeśli
dokonało się jakiegoś wyboru to nie trzeba od razu rezygnować po pierwszym małym niepowodzeniu. Warto podjąć próbę
rozwiązania napotykanych problemów i czasem zgadzać się na kompromisy... To także jest dobra szkoła dla programisty.
