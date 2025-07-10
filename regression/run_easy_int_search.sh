#!/bin/sh -ex
QUERYDB="${DATADIR}/ddi"
TARGETDB="${DATADIR}/ddi_foldseekdb/ddiintdb"
PROTCIDANNOTATION="${DATADIR}/ddi_lookup_bench.tsv"

"${FOLDSEEK}" createdb "$QUERYDB" "$RESULTS/ddidb"
"${FOLDSEEK}" createdimerdb "$RESULTS/ddidb" "$RESULTS/ddidimerdb" "$RESULTS/tmp"
"${FOLDSEEK}" createinterfacedb "$RESULTS/ddidimerdb" "$RESULTS/ddiintdb"

"${FOLDSEEK}" easy-multimersearch "$RESULTS/ddiintdb" "$TARGETDB" "$RESULTS/ddi_aln" "$RESULTS/tmp" -e 10000000 --exhaustive-search --min-assigned-chains-ratio 1.0

"${EVALUATE}" "$PROTCIDANNOTATION" "$RESULTS/ddi_aln_report" > "$RESULTS/int_aln_eval.log"

ACTUAL=$(awk '{ protcidsum+=$3}END{print protcidsum/NR}' "$RESULTS/int_aln_eval.log")
TARGET="0.982883"
awk -v actual="$ACTUAL" -v target="$TARGET" \
	'BEGIN {print (actual >= target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
	> "${RESULTS}.report"
