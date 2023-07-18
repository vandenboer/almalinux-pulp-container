#!/bin/bash

arr=`dnf search locale | grep glibc-langpack | cut -d'.' -f 1`
for i in $arr; do dnf install -y $i; done

