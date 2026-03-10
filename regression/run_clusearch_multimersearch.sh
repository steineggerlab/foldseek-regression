#!/bin/sh -ex

QUERY="${DATADIR}/complex/complexdir.tar.gz"

"${FOLDSEEK}" createdb "$QUERY" "$RESULTS/db"
"${FOLDSEEK}" linclust "$RESULTS/db" "$RESULTS/clu" "$RESULTS/clutmp" --min-seq-id 0.3
"${FOLDSEEK}" createclusearchdb "$RESULTS/db" "$RESULTS/clu" "$RESULTS/clusearchdb"
"${FOLDSEEK}" easy-multimersearch "$RESULTS/db" "$RESULTS/clusearchdb" "$RESULTS/aln" "$RESULTS/tmp" --chain-tm-threshold 0.5 --multimer-tm-threshold 0 --interface-lddt-threshold 0.3 --cov-mode 1

ACTUAL=$(awk 'BEGIN{qtm=0;ttm=0;n=0}{qtm+=$5;ttm+=$6;n++}END{print qtm,ttm,n}' "$RESULTS/aln_report")

TARGET="240.751 1110.31 10967"

awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual == target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"
