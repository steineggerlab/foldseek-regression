#!/bin/sh -ex
QUERY="${DATADIR}/scop"
TARGET="${DATADIR}/scop"
SCOPANOTATION="${DATADIR}/scop_lookup_bench.tsv"

"${FOLDSEEK}" easy-search "$QUERY" "$TARGET" "$RESULTS/results_aln.m8" "$RESULTS/tmp" -e 10000 -s 5 --max-seqs 100

awk '{gsub("_[A-Za-z0-9]*$","",$1); gsub("_[A-Za-z0-9]*$","",$2); print $1"\t"$2}' "$RESULTS/results_aln.m8" > "$RESULTS/results_aln.nochain.m8" 
"${EVALUATE}" "$SCOPANOTATION" "$RESULTS/results_aln.nochain.m8" > "${RESULTS}/evaluation.log"

ACTUAL=$(awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' "${RESULTS}/evaluation.log")
TARGET="0.886667 0.49 0.265313"
awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual >= target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"
