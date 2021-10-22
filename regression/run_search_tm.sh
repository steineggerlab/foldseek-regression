#!/bin/sh -ex
QUERY="${DATADIR}/scop"
QUERYDB="${RESULTS}/query"
"${FOLDSEEK}" createdb "${QUERY}" "${QUERYDB}"

TARGET="${DATADIR}/scop"
SCOPANOTATION="${DATADIR}/scop_lookup_bench.tsv"
TARGETDB="${RESULTS}/target"
"${FOLDSEEK}" createdb "${TARGET}" "${TARGETDB}"

"${FOLDSEEK}" search "$QUERYDB" "$TARGETDB" "$RESULTS/results_aln" "$RESULTS/tmp" --alignment-type 1 -e 10000 -s 5 --max-seqs 100 --tmscore-threshold 0.0
"${FOLDSEEK}" convertalis "$QUERYDB" "$TARGETDB" "$RESULTS/results_aln" "$RESULTS/results_aln.m8"

awk '{gsub("_[A-Za-z0-9]*$","",$1); gsub("_[A-Za-z0-9]*$","",$2); print $1"\t"$2}' "$RESULTS/results_aln.m8" > "$RESULTS/results_aln.nochain.m8" 
"${EVALUATE}" "$SCOPANOTATION" "$RESULTS/results_aln.nochain.m8" > "${RESULTS}/evaluation.log"

ACTUAL=$(awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' "${RESULTS}/evaluation.log")
TARGET="0.886667 0.503333 0.284489"
awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual >= target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"
