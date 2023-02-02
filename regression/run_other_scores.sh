#!/bin/sh -ex
QUERY="${DATADIR}/scop/d1a12a_"
QUERYDB="${RESULTS}/query"
"${FOLDSEEK}" createdb "${QUERY}" "${QUERYDB}"

TARGET="${DATADIR}/scop"
SCOPANOTATION="${DATADIR}/scop_lookup_bench.tsv"
TARGETDB="${RESULTS}/target"
"${FOLDSEEK}" createdb "${TARGET}" "${TARGETDB}"

"${FOLDSEEK}" createindex "$TARGETDB"  "$RESULTS/tmp"
"${FOLDSEEK}" search "$QUERYDB" "$TARGETDB" "$RESULTS/results_aln" "$RESULTS/tmp" -e 10000 -s 3 --max-seqs 100 -a
"${FOLDSEEK}" convertalis "$QUERYDB" "$TARGETDB" "$RESULTS/results_aln" "$RESULTS/results_aln.m8" --format-output "query,target,lddt,prob,rmsd,alntmscore,u,t,lddtfull"

head -n 3  "$RESULTS/results_aln.m8" | tail -n 1 \
  | awk '{ print ($3 == 3.475E-01 && $4 == 1.000 && $5 == 1.074E+01 && $6 == 4.630E-01) ? "GOOD" : "BAD"; }' \
  > "${RESULTS}.report"
