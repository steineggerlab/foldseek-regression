#!/bin/sh -ex
QUERY="${DATADIR}/cif/1tim.cif"
TARGET="${DATADIR}/complex/8tim.cif"

"${FOLDSEEK}" easy-complexsearch "$QUERY.gz" "$TARGET.gz" "$RESULTS/easyCompAln" "$RESULTS/tmp" 

ACTUAL=$(awk 'NR==1{print $3,$4,$5,$6}' "$RESULTS/easyCompAln_report")
ACTUAL=$ACTUAL" "$(awk 'NR==2{print $3,$4,$5,$6}' "$RESULTS/easyCompAln_report")

TARGET="A,B A,B 0.98941 0.98941 A,B B,A 0.98703 0.98703"

awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual == target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"
