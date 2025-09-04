#!/bin/sh -ex
QUERY="${DATADIR}/complex/complexcif.tar.gz"
QUERYDB="${RESULTS}/querydb"

"${FOLDSEEK}" createdb "${QUERY}" "${QUERYDB}"
head "${QUERYDB}.index" >  "${RESULTS}/sublist"
"${FOLDSEEK}" createsubdb "${RESULTS}/sublist" "${QUERY}" "${RESULTS}/subquery"
"${FOLDSEEK}" easy-multimersearch "${RESULTS}/subquery" "${QUERYDB}" "${RESULTS}/searchresult" "${RESULTS}/searchtmp"
sort "${RESULTS}/searchresult_report" > "${RESULTS}/searchresult_report2"

ACTUAL=$(awk 'NR==1{print $3,$4,$5,$6}' "${RESULTS}/searchresult_report2")
ACTUAL=$ACTUAL" "$(awk 'NR==2{print $3,$4,$5,$6}' "${RESULTS}/searchresult_report2")

TARGET="A,B,C A,B,C 1.00000 1.00000 A,B,C B,C,A 0.99867 0.99867"

awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual == target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"