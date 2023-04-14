#!/bin/sh -ex
INPUT="${DATADIR}/scop"
INPUTDB="${RESULTS}/input"
SCOPANOTATION="${DATADIR}/scop_lookup_bench.tsv"
"${FOLDSEEK}" createdb "${INPUT}" "${INPUTDB}"

"${FOLDSEEK}" cluster "$INPUTDB"  "${INPUTDB}_clu" "$RESULTS/tmp" -c 0.9 --min-seq-id 0.3 -s 9
"${FOLDSEEK}" cpdb "${INPUTDB}"  "${INPUTDB}_seq"
"${FOLDSEEK}" cpdb "${INPUTDB}_ss"  "${INPUTDB}_seq_ss"
"${FOLDSEEK}" cpdb "${INPUTDB}_ca"  "${INPUTDB}_seq_ca"
"${FOLDSEEK}" createsubdb  "${INPUTDB}_clu" "${INPUTDB}_seq" "${INPUTDB}"
"${FOLDSEEK}" createsubdb  "${INPUTDB}_clu" "${INPUTDB}_seq_ss" "${INPUTDB}_ss"
"${FOLDSEEK}" createsubdb  "${INPUTDB}_clu" "${INPUTDB}_seq_ca" "${INPUTDB}_ca"
"${FOLDSEEK}" structurealign  "${INPUTDB}" "${INPUTDB}_seq" "${INPUTDB}_clu" "${INPUTDB}_aln" -a -e 0.1
"${FOLDSEEK}" result2profile  "${INPUTDB}" "${INPUTDB}_seq" "${INPUTDB}_aln" "${INPUTDB}_profile"
"${FOLDSEEK}" result2profile  "${INPUTDB}_ss" "${INPUTDB}_seq_ss" "${INPUTDB}_aln" "${INPUTDB}_profile_ss" --pca 1.4 --pcb 1.5 --sub-mat 3di.out --mask-profile 0 --comp-bias-corr 0
"${FOLDSEEK}" profile2consensus "${INPUTDB}_profile" "${INPUTDB}" 
"${FOLDSEEK}" profile2consensus "${INPUTDB}_profile_ss" "${INPUTDB}_ss" 


"${FOLDSEEK}" search "${INPUTDB}_seq" "${INPUTDB}" "$RESULTS/results_aln" "$RESULTS/tmp" --expand-alignment 1 -e 10000 -s 9 --max-seqs 100 -a --remove-tmp-files 0

"${FOLDSEEK}" convertalis "$INPUTDB" "$INPUTDB" "$RESULTS/results_aln" "$RESULTS/results_aln.m8"

"${EVALUATE}" "$SCOPANOTATION" "$RESULTS/results_aln.m8" > "${RESULTS}/evaluation.log"

ACTUAL=$(awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' "${RESULTS}/evaluation.log")
TARGET="0.986667 0.77101 0.435409"
awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual >= target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"
