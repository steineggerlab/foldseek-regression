#!/bin/bash -ex

DB="${DATADIR}/ddi"
DBINDEX="${DATADIR}/ddi_foldseekdb/ddiintdb.index"

"${FOLDSEEK}" createdb "$DB" "$RESULTS/ddidb"
"${FOLDSEEK}" createdimerdb "$RESULTS/ddidb" "$RESULTS/ddidimerdb" "$RESULTS/tmp"
"${FOLDSEEK}" createinterfacedb "$RESULTS/ddidimerdb" "$RESULTS/ddiintdb"


ACTUAL=$(awk -F "\t" 'FNR==NR{len[$1]=$3;next} {lendiff+=(len[$1]-$3)} END{print lendiff < 0 ? -lendiff : lendiff}' "$RESULTS/ddiintdb.index" "$DBINDEX")
TARGET="0"
awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual < target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"

