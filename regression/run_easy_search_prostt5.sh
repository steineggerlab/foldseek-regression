#!/bin/sh -e
QUERY="${RESULTS}/query.fasta"
TARGET="${DATADIR}/scop"

cat <<EOF > "${QUERY}"
>d2pf1a2
SATDAFWAKYTACESARNPREKLNECLEGN
EOF

if [ ! -f "$RESULTS/qpt5/model/config.json" ]; then
    # quantized weights are worse and slower
    # they were only added to reduce download size in continous integration
    PROSTT5_QUANTIZED=1 "${FOLDSEEK}" databases ProstT5 "$RESULTS/qpt5" "$RESULTS/tmp"
fi
"${FOLDSEEK}" easy-search "$QUERY" "$TARGET" "$RESULTS/results_aln.m8" "$RESULTS/tmp" -e 10000 -s 9 --max-seqs 100 --prostt5-model "$RESULTS/qpt5"

awk -v target="d2pf1a2" \
    'NR == 1 { result = "BAD"; if ($1 == $2 && $1 == target) result = "GOOD"; printf("%s\nExpected:\n%s %s\nActual:\n%s %s\n", result, target, target, $1, $2); exit; }' \
    "$RESULTS/results_aln.m8" > "${RESULTS}.report"
