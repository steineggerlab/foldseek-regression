#!/bin/sh -ex
DB="${DATADIR}/ddi"
PROTCIDANNOTATION="${DATADIR}/ddi_lookup_bench.tsv"

"${FOLDSEEK}" createdb "$DB" "$RESULTS/ddidb"
"${FOLDSEEK}" createdimerdb "$RESULTS/ddidb" "$RESULTS/ddidimerdb" "$RESULTS/tmp"
"${FOLDSEEK}" createinterfacedb "$RESULTS/ddidimerdb" "$RESULTS/ddiintdb"

"${FOLDSEEK}" easy-multimercluster "$RESULTS/ddiintdb" "$RESULTS/ddi_clu" "$RESULTS/tmp" -e 10000000 --exhaustive-search --multimer-tm-threshold 0.30 --chain-tm-threshold 0 --interface-lddt-threshold 0 --cov-mode 0 -c 0 --cluster-mode 0

"${EVALUATE}" "$PROTCIDANNOTATION" "$RESULTS/ddi_clu_cluster.tsv" > "${RESULTS}/ddi_clu_eval.log"

ACTUAL=$(awk '{ if($3 > 0 && $4 == 0 ){ goodcluster+=1;} if( $4 > 0 ){ badcluster+=1;} tp+=$3; fp+=$4; }END{print goodcluster,badcluster,tp,fp}' "${RESULTS}/ddi_clu_eval.log")
TARGET="50 1 654 0"
awk -v actual="$ACTUAL" -v target="$TARGET" \
	'BEGIN { print (actual==target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
	> "${RESULTS}.report"
