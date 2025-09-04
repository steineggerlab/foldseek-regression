#!/bin/sh -ex
QUERY="${DATADIR}/complex/complexcif.tar.gz"

"${FOLDSEEK}" easy-multimercluster "${QUERY}" "${RESULTS}/clu" "${RESULTS}/clutmp"

ACTUAL=$(cut -f1 "${RESULTS}/clu_cluster.tsv" | uniq -c | awk '{print $1}' | sort -n)

TARGET="1\n1\n6"

awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual == target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"