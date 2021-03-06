#!/bin/bash
#   usage:
#      cg2custnames.bash     (run in the OUTBOX directory of the flowcell, it should contain the fastqfiles and sampleList.csv)
#
DATETIME=$(date +%Y%m%d%H%M%S)
renaminglog="renaminglog.${DATETIME}.txt"
date > ${renaminglog}
metas=$(ls | grep meta)
if [ -f "meta.txt" ] ; then
  rm meta.txt
fi
for meta in ${metas[@]}; do
  awk '{if (NF>1) print $0}' ${meta} >> meta.txt
  new=$(echo ${meta} | sed 's/meta/meOLDta/')
  mv ${meta} ${new}
done
sfil=$(ls | grep stats | grep txt)
if [ -f "stats.txt" ] ; then
  rm stats.txt
fi
for stat in ${sfil[@]}; do
  head -1 ${stat} > stats.txt
done
for stat in ${sfil[@]}; do
  tail -n +2 ${stat} >> stats.txt
  new=$(echo ${stat} | sed 's/stat/stOLDat/')
  mv ${stat} ${new}
done
slist=$(ls | grep sampleList)
if [ -f "sampleList.csv" ] ; then
  rm sampleList.csv
fi
for list in ${slist[@]}; do
  head -1 ${list} > sampleList.csv
done
for list in ${slist[@]}; do
  tail -n +2 ${list} >> sampleList.csv
  new=$(echo ${list} | sed 's/pleLi/pleOLDLi/')
  mv ${list} ${new}
done

meta=$(ls | grep meta)
sfil=$(ls | grep stats | grep txt)
slist=$(ls | grep sampleList)
if [ ! -f "${meta}" ] ; then
  echo meta: ${meta} no such file, will exit
  echo meta: ${meta} no such file, will exit >> ${renaminglog}
  exit 9
else
  echo meta: ${meta} exists
  echo meta: ${meta} exists >> ${renaminglog}
fi
if [ ! -f "${sfil}" ] ; then
  echo stats: ${sfil} no such file, will exit
  echo stats: ${sfil} no such file, will exit >> ${renaminglog}
  exit 9
else
  echo stats: ${sfil} exists
  echo stats: ${sfil} exists >> ${renaminglog}
fi
if [ ! -f "${slist}" ] ; then
  echo samplelist: ${slist} no such file, will exit
  echo samplelist: ${slist} no such file, will exit >> ${renaminglog}
  exit 9
else
  echo samplelist: ${slist} exists
  echo samplelist: ${slist} exists >> ${renaminglog}
fi

#     remove 'Sample_' from sample name in meta file
cp ${meta} ${meta}.bak
awk '{split($1,arr,"_");if (arr[1]=="Sample") {out=arr[2]} else {out=arr[1]};printf out "\t"; {for (i=2; i<NF; i++) printf $i "\t"; print $NF}}' ${meta} > metatext
mv metatext ${meta}
chmod g+w ${meta}
chmod g+x ${meta}
echo cp ${meta} ${meta}.bak >> ${renaminglog}

#     remove 'Sample_' from sample name in stats file if present
cp ${sfil} ${sfil}.bak
echo cp ${sfil} ${sfil}.bak >> ${renaminglog}
awk 'BEGIN {OFS="\t"} {out=$1; if ($1 ~ /Sample_/) {split($1,arr,"_"); out=arr[2]};print out,$2,$3,$4,$5,$6,$7,$8,$9}' ${sfil} > wo${sfil}
mv wo${sfil} ${sfil}
chmod g+w ${sfil}
chmod g+x ${sfil}

#     change internal sample name to customer sample name in fastq file names as shown in 'sampleList'
# awk 'BEGIN {FS=","} {if (substr($2, length($2))=="B") {$2=substr($2,1,length($2)-1)};if ($1 != "Project") print $3"KLISTERKLISTER"$2}' sampleList.csv
#awk 'BEGIN {FS=","} {if ($1 != "Project") print $3"KLISTERKLISTER"$2}' ${slist})
namepairs=$(awk 'BEGIN {FS=","} {if (NF>1) {cgout=$3;if (substr($3, length($3))=="B") {cgout=substr($3,1,length($3)-1)};if (substr($3, length($3))=="F") {cgout=substr($3,1,length($3)-1)}}; if ($1 != "Project") print cgout"KLISTERKLISTER"$2}' ${slist})
fastqfiles=$(ls | grep ".fastq.gz$")
for fil in ${fastqfiles[@]};do
  if [[ $fil =~ 'Undetermined' ]]; then
      continue
  fi
  for pair in ${namepairs[@]};do
    cgname=$(echo ${pair} | awk 'BEGIN {FS="KLISTERKLISTER"} {print $1}')
    cuname=$(echo ${pair} | awk 'BEGIN {FS="KLISTERKLISTER"} {print $2}')
    if [[ ${fil} == *${cgname}* ]]; then
      newname=$(echo ${fil} | sed "s/_${cgname}_/_${cuname}_/")
    fi
    if [[ ${fil} == *${cgname}F* ]]; then
      newname=$(echo ${fil} | sed "s/_${cgname}F_/_${cuname}_/")
    fi
    if [[ ${fil} == *${cgname}B* ]]; then
      newname=$(echo ${fil} | sed "s/_${cgname}B_/_${cuname}_/")
    fi
    newname=$(echo ${newname} | sed 's/Sample_//g' | sed 's/_R1/_1/g' | sed 's/_R2/_2/g')
    nnwopn=$(echo ${newname} | awk 'BEGIN {FS="_";OFS="_"} {if ($7!="") print $1,$2,$3,$4,$6,$7}')
    if [ ! -z ${nnwopn} ]; then
      newname=${nnwopn}
    fi
  done
  sed -i "s/${fil}/${newname}/g" ${meta}
  echo sed -i "s/${fil}/${newname}/g" ${meta} >> ${renaminglog}
  echo renaming ${fil} to ${newname} in ${meta}
  mv ${fil} ${newname}
  chmod g+x ${newname}
  echo mv ${fil} ${newname} >> ${renaminglog}
  echo renaming file ${fil} to ${newname}
done

head -1 ${sfil} > wo${sfil}

#     change internal sample name to customer sample name in meta and stats files as shown in 'sampleList'
for pair in ${namepairs[@]};do
  cgname=$(echo ${pair} | awk 'BEGIN {FS="KLISTERKLISTER"} {print $1}')
  cuname=$(echo ${pair} | awk 'BEGIN {FS="KLISTERKLISTER"} {print $2}')
  grep ${cgname} ${sfil} >> wo${sfil}
  sed -i "s/${cgname}F/${cuname}/g" wo${sfil}
  sed -i "s/${cgname}B/${cuname}/g" wo${sfil}
  sed -i "s/${cgname}/${cuname}/g" wo${sfil}
  echo sed -i "s/${cgname}[FB]/${cuname}/g" ${sfil} >> ${renaminglog}
#  sed -i "s/_${cgname}F_/_${cuname}_/g" ${meta}
#  sed -i "s/_${cgname}B_/_${cuname}_/g" ${meta}
#  sed -i "s/_${cgname}_/_${cuname}_/g" ${meta}
  sed -i "s/${cgname}F/${cuname}/g" ${meta}
  sed -i "s/${cgname}B/${cuname}/g" ${meta}
  sed -i "s/${cgname}/${cuname}/g" ${meta}
  echo sed -i "s/_${cgname}[FB]_/_${cuname}_/g" ${meta} >> ${renaminglog}
  echo renaming sample ${cgname}[FB] to ${cuname} in ${sfil} and ${meta}
done

mv wo${sfil} ${sfil}

prj=$(ls | grep meOLDta | awk 'BEGIN {FS="-"} {print $2}')
flc=$(ls | grep meOLDta | awk 'BEGIN {FS="-"} {print $3}' | sed 's/.txt//')
echo copying ${renaminglog} to /mnt/hds/proj/bioinfo/OUTBOX/Project_${prj}/${flc}/
cp ${renaminglog} /mnt/hds/proj/bioinfo/OUTBOX/Project_${prj}/${flc}/
