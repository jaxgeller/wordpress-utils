#!/bin/bash

mkdir \
  page-templates \
  lib

touch \
  functions.php \
  index.php \
  style.css \
  header.php \
  footer.php \
  page-templates/frontpage.php


for i in "$@"; do
  touch \
    page-templates/"$i".php
done
