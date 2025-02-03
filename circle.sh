#!/bin/bash
# This program prints a circle with radius [option]
# Note: if the character spacing and the line spacing are not the same,
#  the circle will not be perfectly circular
NUMARGUMENTS=1
if [ $# -lt $NUMARGUMENTS ]; then
 echo Invalid arguments, provided $# required $NUMARGUMENTS. >&2
 exit 5
fi
if [ $1 -lt 1 ]; then
 echo Invalid radius, provided $1 required positive. >&2
 exit 1
fi
# returns the quadrant the coordinate is in
quadrant() {
 if [ $1 -gt 0 ] && [ $2 -ge 0 ]; then
  return 1
 elif [ $1 -le 0 ] && [ $2 -ge 0 ]; then
  return 2
 elif [ $1 -le 0 ] && [ $2 -lt 0 ]; then
  return 3
 elif [ $1 -gt 0 ] && [ $2 -lt 0 ]; then
  return 4
 else
  echo Given coordinates $1, $2 not Cartesian >&2
  exit 1
 fi
}
# returns the slope on a scale from 1 to 4 for (\_/|)
slope() {
 quadrant $1 $2
 q=$?
 if [ $q -eq 1 ] || [ $q -eq 3 ]; then
  diff=$(($1-$2))
 else
  diff=$(($1+$2))
 fi
 if [ $(($diff*$diff)) -le $(( $(($1*$1)) < $(($2*$2)) ? $(($1*$1)) : $(($2*$2)) )) ]; then
  if [ $q -eq 1 ] || [ $q -eq 3 ]; then
   return 1
  else
   return 3
  fi
 elif [ $(($1*$1)) -lt $(($2*$2)) ]; then
  return 4
 else
  return 2
 fi
}
MAXLENGTH=$(($1+$1+1))
TARGET=$(($1*$1))
ERRORRADIUS=$TARGET
RADIUS=$1
SHOWALL=0
FILL=0
SHOWVALUE=0
SLOPE=0
DEFAULTTEXT="[]"
while [ "$2" != "" ]; do
 if [ "$2" == "-f" ]; then
  FILL=1
 elif [ "$2" == "-A" ]; then
  SHOWALL=1
 elif [ "${2:0:2}" == "-w" ]; then
  ERRORRADIUS=$(($ERRORRADIUS+${2:2:10}))
 elif [ "${2:0:2}" == "-t" ]; then
  DEFAULTTEXT="${2:2:4}"
 elif [ "$2" == "-s" ]; then
  SLOPE=1
 elif [ "$2" == "-v" ]; then
  SHOWVALUE=1
 fi
 shift
done

row=0
while [ $row -lt $MAXLENGTH ]; do
 col=0
 while [ $col -lt $MAXLENGTH ]; do
  temprow=$(($row-$RADIUS))
  tempcol=$(($col-$RADIUS))
  value=$(($temprow*$temprow+$tempcol*$tempcol))
  diff=$(($value-$TARGET))
  temp=$(($ERRORRADIUS-$diff*$diff))
  if [ $temp -gt 0 ] || [[ $FILL -eq 1 && $value -le $TARGET ]] || [ $SHOWALL -eq 1 ]; then
   if [ "$3" == "-q" ]; then
    quadrant $temprow $tempcol
    echo -n "$?,"
   elif [ $SHOWVALUE -eq 1 ]; then
    echo -n "$temp,"
   elif [ $SLOPE -eq 1 ]; then
    slope $temprow $tempcol
    s=$?
    if [ $s -eq 1 ]; then
     t='/'
    elif [ $s -eq 2 ]; then
     t='_'
    elif [ $s -eq 3 ]; then
     t='\'
    else
     t='|'
    fi
    echo -n "${t}$t"
   else
    echo -n $DEFAULTTEXT
   fi
  else
   echo -n "  "
  fi
  col=$(($col+1))
 done
 echo
 row=$(($row+1))
done
