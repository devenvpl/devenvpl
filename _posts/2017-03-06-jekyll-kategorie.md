---
date: 2017-03-06 21:30
title: "Pierwsze zetknięcie z Jekyll. Podział na kategorie"
layout: post
description: Krótki opis "pierwszych chwil" z Jekyllem oraz mały tutorial jak zorganizować strony z kategoriamii
tags: mksiazek dsp2017-mateusz jekyll
category: dsp2017-mateusz
author: mksiazek
---
Nasz blog *devenv* hostowany jest na [github pages](https://pages.github.com/) z wykorzystaniem narzędzia 
[jekyll](https://jekyllrb.com/). Jeszcze 3 tygodnie temu github pages kojarzyły mi się tylko jako statyczne stronki HTML,
jednak kiedy postanowiliśmy uruchomić bloga i zastanawialiśmy się czy ma to być kolejna strona oparta o *WordPressa*,
@Adrian zaproponował użycie *Jekyll*a. Nie miałem nic przeciwko, tym bardziej, że "instalacja" zajęła mu chwilkę, a dla
mnie to kolejna nowość, którą warto poznać.

Jeśli w przyszłości to rozwiązanie okaże się niewystarczające to zawsze można zmienić, ale na razie wydaje się być
całkiem ok ;-)

## Jekyll - jak to działa?
Kiedy pobrałem pierwszy raz kod z repozytorium i odpaliłem dokumentację to trochę się zdziwiłem. *Github pages* to statyczny
HTML, a *Jekyll* to projekt napisany w *ruby*. Więc... W jaki sposób to działa? Github musi jakoś to interpretować.


## Nie ma tak kolorowo

## Podział na kategorie
###### Layout
*_layouts/page_category.html*
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

###### Kolekcje
 *_config.yml*
```yaml
collections:
  categories:
    output: true
```

*_categories/super-kateoria.md*
```markdown
---
permalink: /super-kategoria.html
layout: page_category
category: 'super-kategoria'
---
```

## Podsumowanie
