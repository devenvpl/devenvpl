---
date: 2017-04-11 20:20
title: "Jekyll - sposób na generowanie stron z tagami przyjazny dla GitHub Pages"
layout: post
description: Prosty sposób na generowanie stron z tagami na githubie w jekyllu
tags: mksiazek dsp2017-mateusz jekyll jekyll-plugins
category: dsp2017-mateusz
author: mksiazek
comments: true
---

W moim pierwszym [poście](/dsp2017-mateusz/2017/03/07/jekyll-kategorie.html) związanym z Jekyll'em pisałem o tym, że
GitHub wspiera tylko kilka oficjalnych pluginów, a własne skrypty i gemy innych użytkowników są pomijane ze względów
bezpieczeństwa. Ostatnio opisywałem sposób na stworzenie stron z kategoriami przy pomocy
[kolekcji](https://jekyllrb.com/docs/collections/) Jekyll'a.

Teraz chciałbym aby dla każdego z tagów używanych w postach po kliknięciu w nie strona przekierowywała do listy wszystkich
postów pasujących do tego taga.

Przy pierwszym starciu chciałem dodać po prostu w miarę popularnego gem'a [jekyll-tagging](https://github.com/pattex/jekyll-tagging),
który po prostu robi całą robotę, ale niestety nie na GitHubie... Oczywiście dałoby się pewnie jakoś naciągnąć funkcjonalność,
aby przechwytywać wygenerowane HTMLe i je umieszczać w projekcie, ale wyobrażam sobie ile byłoby za każdym razem zmian we
wszystkich tych plikach za każdym razem jak zmienimy cokolwiek w templatce.
 
Sposób z kolekcjami, który został wykorzystany w kategoriach i opisany w [poprzednim poście](http://localhost:4000/dsp2017-mateusz/2017/03/07/jekyll-kategorie.html#kolekcje)
wydaje mi się optymalny w tej sytuacji. Co prawda dla każdego taga będzie potrzebny do stworzenia plik, który będzie
definiować każdą stronę dla taga, ale są to na tyle generyczne pliki, że nie powinny ulegać zmianom już nigdy po ich
utworzeniu.

No to dobra, ale chyba nie będę teraz produkować miliona plików ręcznie, bez przesady... Trzeba przynajmniej trochę ten
proces zautomatyzować. Dlatego też dopisałem mały skrypcik w języku `ruby`, który automatycznie generuje te pliki za mnie.
Jedyną rzeczą o której trzeba pamiętać to dołączyć ten plik do zmian podczas commitowania i tyle. Wystarczy wysłać zmiany
na GitHuba i strona z listą postów dla każdego taga będzie śmigać.

## Przejdźmy do konkretów :punch:

##### Template
Zacznijmy od przygotowania szablonu pod stronę z listą postów dla danego taga. Do katalogu *_layouts/* dodajemy plik 
**.html*. W moim wypadku dodałem plik *page_tag.html*
{% raw %}
~~~ html
---
layout: default
title: {{ page.tag }}
---

<div id="home">
  <h2 class="page-header">
    Tag: <span class="color">{{ page.tag }}</span>
  </h2>
  <ul class="posts">
    {% for post in site.posts %}
      {% if post.tags contains page.tag %}
      <li>
        <a href="{{ site.baseurl }}{{ post.url }}">
          <div class="p-wrap">
            <time datetime="{{ post.date | date_to_xmlschema }}" class="date">
              {{ post.date | date: "%Y-%m-%d" }}
            </time>
            <p>{{ post.title }}</p>
          </div>
        </a>
      </li>
      {% endif %}
    {% endfor %}
  </ul>
</div>
~~~
{% endraw %}
W templatce mamy już dostęp do taga, dla którego chcemy wyświetlić listę w obiekcie `page`. Wystarczy, że wywołamy
`page.tag` aby mieć dostęp do konkretnego taga. W linii 11 lecimy pętlą po wszystkich postach, a w 12 linii dodany jest
warunek, który pozwala wyświelić tylko te posty, które zawierają taga, który nas interesuje na danej stronie. 
Nieoptymalne? Coż, nie ma lepszego rozwiązania, a po za tym kto by się tym przejmował, skoro ta pętla użwana jest tylko
podczas budowania plików HTML, a później już serwowane są tylko statyczne pliki :innocent:

##### Dodanie kolekcji w pliku konfiguracyjnym
To najprostszy moment, otwieramy plik *_config.yml*, który znajduje się w głównym katalogu i definiujemy kolekcję.
~~~ yaml
collections:
  tags:
    output: true
~~~

##### Plik definiujący stronę dla taga
Ten krok może zostać pominięty, jednak zachęcam do jego wykonania w celu przetestowania jak działa cały mechanizm.
Tworzoymy w głównym katalogu folder *_tags* i w nim plik **.md* dla wybranego taga (najlepiej dla takiego, który już był
użyty w jakimś poście na stronie). Powiedzmy, że nazwa taga to *wiosna*, tworzymy dla niego plik *wiosna.md* i wypełniamy
go zawartością:
~~~ markdown
---
permalink: /tag/wiosna.html
layout: page_tag
tag: 'wiosna'
---
~~~
W drugiej linii definujemy adres, w kolejnej linkujemy do templatki, którą stworzyliśmy w pierwszym kroku. W czwartej
linii przekazywany jest tag, który będzie wykorzystywany w templatce.

##### Skrypt
Poprzedni krok trzeba powtórzyć dla każdego taga za każdym razem... Założę się, że często o tym można zapomnieć :smirk:
Minimalny proces automatyzacji w tym wypadku wydaje się niezbędny. Jekyll pozwala na pisanie własnych skryptów i właśnie
to trzeba wykorzystać.

Dodajemy folder *_plugins* w katalogu głównym i tworzymy plik *ext.rb* i dodajemy poniższą zawartość.
~~~ ruby
module Jekyll
  module Tags
    class TagGenerator < Generator
      def generate(site)
        dir_name = "_tags";
        Dir.mkdir(dir_name) unless File.exists?(dir_name)

        for tag in site.tags
          tag_name = tag[0]
          File.open(dir_name + "/#{tag_name}.md", "w") do |f|
            f.puts(file_content(tag_name))
          end
        end
      end

      private

      def file_content(tag)
        <<~HEREDOC
          ---
          permalink: /tag/#{tag}.html
          layout: page_tag
          tag: '#{tag}'
          ---
        HEREDOC
      end
    end
  end
end
~~~
Skrypt jest na tyle prosty, że nie widzę sensu, żeby go jakoś mocniej wyjaśniać. Główną operację skryptu można zobaczyć
w liniach 8-13. Wypełnienie pliku zawartością odbywa się przy pomocy metody `file_content`, jak widać jest tam wrzucony
na żywo tekst używany w poprzednim kroku. Szczerze mówiąc nie widziałem sensu aby zaciągać to z jakiegoś zewnętrznego
pliku i konwertować za każdym razem. To ma być prosty skrypt, który ma ułatwić pracę Jekyll'em :v:

##### Co teraz?
Dobra, tak naprawdę wszystko gotowe. Teraz po wywołaniu komendy w konsoli `bundle exec jekyll build` w folderze *_tags*
powinny zostać dodane wszystkie pliki na podstawie tagów z wszystkich postów na stronie. Tak samo te pliki są ciągle
generowane kiedy na żywo edytujemy stronę i uruchomiony został "serwer" przy pomocy komendy `bundle exec jekyll serve`.

Teraz wystarczy, że dodamy wszystkie wygenerowane pliki do commita i wyślemy do repo na GitHubie, a strony z tagami
powinny być dostępne.

## Podsumowanie
Zaproponowane rozwiązanie być może nie jest idealne, ale ze względu na ograniczenia jakie panują na GitHub Pages to jest
to w zupełności wystarczająca metoda. Jedyną rzeczą o której trzeba zawsze pamiętać to przebudowanie projektu i zawarcie
wygenerowanych plików do commitu. 
