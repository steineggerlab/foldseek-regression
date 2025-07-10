#!/usr/bin/awk -f
BEGIN{OFS="\t";
      print "NAME","PROTCID","TP","FP","PROTCIDCNT";
}
FNR==NR{
        id2protcid[$1]=$2;
        protcidCnt[$2]++;
        next }
{
      split($1,rep,"_");
      split($2,mem,"_");
}
!(rep[2] in repseq){repseq[rep[2]]=1;}
id2protcid[rep[2]] != id2protcid[mem[2]] {foundFp[rep[2]]++; next}
id2protcid[rep[2]] == id2protcid[mem[2]] {foundTp[rep[2]]++; next}

END{
   for(i in repseq){
        fpCnt = (foundFp[i] == "") ? 0 : foundFp[i];
        tpCnt = (foundTp[i] == "") ? 0 : foundTp[i];
        print i,id2protcid[i],tpCnt,fpCnt,protcidCnt[id2protcid[i]];
   }
}
