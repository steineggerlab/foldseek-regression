#!/usr/bin/awk -f
BEGIN{OFS="\t";
      print "NAME","PROTCIDCLU","FP","PROTCIDCLUCNT";
}
FNR==NR{
        id2protcid[$1]=$2;
        protcidCnt[$2]++;
        next }
{
  split($1,query,"_");
  split($2,target,"_");
}
foundFp[query[2]] < 5 && id2protcid[query[2]] != id2protcid[target[2]] {foundFp[query[2]]++; next}
foundFp[query[2]] < 5 && id2protcid[query[2]] == id2protcid[target[2]] {foundProtcid[query[2]]++; next}
END{
   for(i in id2protcid){
      if(id2protcid[i] != ""){
        protcidVal=foundProtcid[i]/protcidCnt[id2protcid[i]];
        fpCnt = (foundFp[i] == "") ? 0 : foundFp[i];
        print i,id2protcid[i],protcidVal,fpCnt,protcidCnt[id2protcid[i]];
      }
   }
}
