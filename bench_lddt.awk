#!/usr/bin/awk -f
BEGIN{OFS="\t";
      print "AVG LDDT SCORES";
}
{ 
    if( $1 == $2 && $3 != "1.000E+00" ) print $1"\t"$2"\tIDENTITY_ERROR";
    if( $1 != $2) print $1"\t"$2"\t"$3;
} 