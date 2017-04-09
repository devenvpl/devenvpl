---
date: 2017-04-09 22:00
title: "Auditor - Gulp - czyli sposób na automatyzację powtarzających się zadań"
layout: post
description: "Auditor - Gulp czyli narzędzie automatyzujące powtarzające się zadania związane z tworzeniem oprogramowania."
tags: apietka dsp2017-adrian auditor frontend gulp
category: dsp2017-adrian
author: apietka
comments: true
---

*[Gulp](http://gulpjs.com/)* jest narzędziem automatyzującym często powtarzających się zadań związanych z tworzeniem oprogramowania. Co mam dokładnie na myśli? Przykładem może być: 

- kompilacja plików LESS/SASS do CSS,
- konkatenacja i minifikacja plików JavaScript,
- budowanie archiwum z artefaktami gotowymi do wdrożenia na "produkcji",
- uruchamianie testów wraz z generowaniem raportu (np. z pokrycia kodu testami jednostkowymi).

Przykłady zastosowania można mnożyć praktycznie w nieskończoność. W projekcie *Auditor*, *Gulp* odpowiedzialny jest za trzy główne zadania po stronie aplikacji frontendowej:

1) weryfikację kodu JavaScript za pomocą *ESLint*,
2) generowanie pliku *index.html* wraz z dołączeniem wszystkich niezbędnych plików CSS oraz JS,
3) uruchomienie prostego serwera HTTP w celu serwowania plików statycznych.

Aby rozpocząć pracę z przedstawionym narzędziem, polecam oficjalną dokumentację, a konkretniej artykuł: [Getting Started](https://github.com/gulpjs/gulp/blob/master/docs/getting-started.md).

## Task - lint

~~~js
const eslint = require('gulp-eslint');

gulp.task('lint', function () {
    return gulp.src(['./src/**/*.js', './src/*.js'])
        .pipe(eslint())
        .pipe(eslint.format())
        .pipe(eslint.failAfterError());
});
~~~~

## Task - dist

~~~js
gulp.task('dist:clean', () => {
    return gulp.src('./dist/*')
        .pipe(clean());
});

gulp.task('dist:vendor:lodash', ['dist:clean'], () => {
   return gulp.src('./node_modules/lodash/index.js')
       .pipe(browserify())
       .pipe(rename('lodash.js'))
       .pipe(gulp.dest('./node_modules/lodash/'));
});

gulp.task('dist:vendor', ['dist:clean', 'dist:vendor:lodash'], () => {
    return gulp.src([
            './node_modules/angular/angular.js',
            './node_modules/angular-resource/angular-resource.js',
            './node_modules/angular-animate/angular-animate.js',
            './node_modules/angular-sanitize/angular-sanitize.js',
            './node_modules/angular-loading-bar/build/loading-bar.js',
            './node_modules/angular-ui-router/release/angular-ui-router.js',
            './node_modules/ng-toast/dist/ngToast.js',
            './node_modules/lodash/lodash.js'
        ]).pipe(concat('vendor.js', {newLine: ';'}))
        .pipe(gulp.dest('./dist/'));
});

gulp.task('dist:app', ['dist:clean'], () => {
    return gulp.src('./src/index.html')
        .pipe(gulp.dest('./'));
});

gulp.task('dist:inject', ['dist:clean', 'dist:app', 'dist:vendor'], () => {
    var vendorStream = gulp.src(['./dist/vendor.js'], {read: false});
    var appStream = gulp.src(['./src/*.js'], {read: false});

    return gulp.src('./index.html')
        .pipe(inject(series(vendorStream, appStream), {relative: true}))
        .pipe(gulp.dest('./'));
});

gulp.task('dist', [
    'lint', 'dist:clean', 'dist:app', 'dist:vendor', 'dist:inject'
]);
~~~

## Task - server

~~~js
const serve = require('gulp-serve');

gulp.task('serve', serve('./'));
~~~~

## Podsumowanie

Narzędzie *Gulp* dostarcza przyjemne API do definicji zadań, a koncepcja *pipe* oraz możliwość podzielenia pliku konfiguracyjnego *Gulpfile* na poszczególne moduły ułatwia organizację kodu. W projekcie *Auditor* wykorzystuję jedynie podstawowy potencjał rozwiązania, jednak wraz z rozbudową systemu ilość różnorodnych, powtarzających się zadań może zdecydowanie się powiększyć. Dzięki *Gulp* zaoszczędzę sporo czasu, ponieważ do większości zadań znajdę [dedykowane pluginy](http://gulpjs.com/plugins/).

Po oswojeniu się z podstawami obsługi narzędzia, polecam repozytorium zawierające kilkanaście gotowych rozwiązań: [Gulp Recipes](https://github.com/gulpjs/gulp/tree/master/docs/recipes).
