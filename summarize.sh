#!/bin/sh

for DIR in results\.*; do
    rm summary-${DIR}.csv || true
    echo "-----"
    for FILE in $(ls $DIR); do
        #cat $DIR/$FILE | sort -n | 
        MEDIAN=$(sort -n $DIR/$FILE| tail -n 2 | head -n 1)
        echo "$FILE,$MEDIAN" >> summary-${DIR}.csv
    done
done
