#!/bin/sh -ex
QUERY="${DATADIR}/complex/complexcif.tar.gz"

"${FOLDSEEK}" createdb "${QUERY}" "${RESULTS}/querydb"
head "${RESULTS}/querydb.index" > "${RESULTS}/sublist"
"${FOLDSEEK}" createsubdb "${RESULTS}/sublist" "${RESULTS}/querydb" "${RESULTS}/subquery"
"${FOLDSEEK}" easy-multimercluster "${RESULTS}/subquery" "${RESULTS}/clu" "${RESULTS}/clutmp"

ACTUAL=$(cut -f1 "${RESULTS}/clu_cluster.tsv" | uniq | wc -l)
TARGET="3"

awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual == target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"