#!/bin/sh -ex

INPUT="${DATADIR}/complex/*"
INPUTDB="${RESULTS}/input"
DIMERDB="${RESULTS}/dimer"
DIMERDB2="${RESULTS}/dimer2"
DIMERTMP="${RESULTS}/dimertmp"
DIMERTMP2="${RESULTS}/dimertmp2"

"${FOLDSEEK}" createdb "${INPUT}" "${INPUTDB}"
"${FOLDSEEK}" createdimerdb "${INPUTDB}" "${DIMERDB}" "${DIMERTMP}"
"${FOLDSEEK}" createdimerdb "${DIMERDB}" "${DIMERDB2}" "${DIMERTMP2}"

TARGET="648"
ACTUAL=$(awk -F"\t" 'BEGIN{sum=0}{sum+=$3}END{print sum}' "${DIMERDB2}.index")
awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual < target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"
