#!/bin/sh -ex
QUERY="${DATADIR}/scop"
QUERYDB="${RESULTS}/query"
"${FOLDSEEK}" createdb "${QUERY}" "${QUERYDB}"

TARGET="${DATADIR}/scop"
SCOPANOTATION="${DATADIR}/scop_lookup_bench.tsv"
TARGETDB="${RESULTS}/target"
"${FOLDSEEK}" createdb "${TARGET}" "${TARGETDB}"

"${FOLDSEEK}" search "$QUERYDB" "$TARGETDB" "$RESULTS/results_aln" "$RESULTS/tmp" --alignment-type 1 -e 10000 -s 5 --max-seqs 100 --tmscore-threshold 0.0 -a
"${FOLDSEEK}" convertalis "$QUERYDB" "$TARGETDB" "$RESULTS/results_aln" "$RESULTS/results_aln.m8" --format-output query,target,lddt,lddtfull 
"${EVALUATE}" "$RESULTS/results_aln.m8" > "${RESULTS}/evaluation.log"
# cat "$RESULTS/results_aln.m8"> "${RESULTS}/evaluation.log"

ACTUAL=$(awk '{for (i=1; i<=NF; ++i) sum += $i} END {print sum}' "${RESULTS}/evaluation.log")
IDENTITY_ERROR=$(awk 'BEGIN {count=0} ($3 == "IDENTITY_ERROR") {count++ } END { print count }' "${RESULTS}/evaluation.log") # this should be zero
TARGET="1902.68"

awk -v actual="$ACTUAL" -v target="$TARGET" -v error="$IDENTITY_ERROR" \
    'BEGIN { print (1.01 * target >= actual && actual >= 0.99 * target && error == 0) ? "GOOD" : "BAD"; print "Expected: ", target, 0; print "Actual: ", actual, error; }' \
    > "${RESULTS}.report"