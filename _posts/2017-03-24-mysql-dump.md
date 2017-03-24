---
date: 2017-03-24 22:30
title: "MySQL - Dump"
layout: post
description: "Tworzenie i przywracanie zrzutu bazy danych MySQL."
tags: apietka dsp2017-adrian mysql database
category: dsp2017-adrian
author: apietka
comments: true
---

W większości projektów w których mam przyjemność pracować, wykorzystywana jest relacyjna baza danych *MySQL*. Niektóre z baz osiągają rozmiary kilku GB i odtwarzanie ich stanu na lokalnym środowisku wymaga pewnej gimnastyki. Narzędzia GUI wspierające zarządzanie bazą danych oferują importowanie oraz eksportowanie jej zawartości. Jednak zaimplementowane mechanizmy niejednokrotnie nie potrafią poradzić sobie z dużym rozmiarem przetwarzanych danych.

Eksport takich baz danych realizuję za pomocą dostarczanego z *MySQL* narzędzia *mysqldump*. Import natomiast oparty jest o przełączenie standardowego wejścia (*stdin*) na sczytanie danych z pliku. Idealnie radzi sobie z tym *mysql*.

Poniżej zamieszczam kilka najczęściej używanych poleceń obsługujących import oraz eksport poszczególnych baz danych jak i również wybranych tabel.

## Tworzenie zrzutu bazy danych

Dla wybranej/wybranych bazy danych:

```
$: mysqldump -h[host] -u[user] -p[password] [database] > [backup_file]
$: mysqldump -hlocalhost -uroot -phaslo baza_cms > baza_cms_backup.sql
```

```
$: mysqldump -h[host] -u[user] -p[password] --databases [database1] [database2] [database3] > [backup_file]
$: mysqldump -hlocalhost -uroot -phaslo --databases baza_cms baza_cmr baza_erp > dbs_backup.sql
```

Dla wszystkich baz danych użytkownika:

```
$: mysqldump -h[host] -u[user] -p[password] --all-databases > [backup_file]
$: mysqldump -hlocalhost -uroot -phaslo --all-databases > full_backup.sql
```

Dla wybranej tabeli w bazie danych:

```
$: mysqldump -h[host] -u[user] -p[password] [database] [table] > [backup_file]
$: mysqldump -hlocalhost -uroot -phaslo baza_cms artykuly > baza_cms_artykuly_backup.sql
```

## Przywracanie zrzutu bazy danych

Dla wszystkich baz danych użytkownika:

```
$: mysql -h[host] -u[user] -p[password] < [backup_file]
$: mysql -hlocalhost -uroot -phaslo < full_backup.sql
```

Dla wybranej bazy danych:

```
$: mysql -h[host] -u[user] -p[password] [database] < [backup_file]
$: mysql -hlocalhost -uroot -phaslo baza_cms < baza_cms_backup.sql
```

lub:

```
$: mysql -h[host] -u[user] -p[password]
$: use [database];
$: \. db_backup.sql
```

Należy pamiętać, że operacja ta zadziała tylko jeśli wskazana baza danych została wcześniej stworzona.

## Problemy

Podczas eksportu danych, często natrafiam na problem zablokowanej tabeli. Jego rozwiązanie zamieszczam poniżej.

### Error 1016 "LOCK TABLES" - Podczas zrzucania bazy danych do pliku

*Komunikat:*

```
Error: MySQL - mysqldump: Got error: 1016: Can't open file: './exampledb/xxx.frm' (errno: 24) when using LOCK TABLES
```

*Rozwiązanie:*

Należy dodać parametr ```--lock-tables=false``` do uruchamianego polecenia ```mysqldump```.