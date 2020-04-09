#!/bin/bash

if [ ! -f skrd-npx-pl-newsphp ]; then
    curl -L "http://skrd.npx.pl/news.php" > skrd-npx-pl-newsphp
fi

regex="href='(http://www.archive.org.*\.zip)'"

while IFS= read -r line; do
    if [[ $line =~ $regex ]]; then
        echo ${BASH_REMATCH[1]}
    fi
done < skrd-npx-pl-newsphp | uniq

rm skrd-npx-pl-newsphp

