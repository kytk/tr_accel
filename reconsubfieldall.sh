#!/bin/bash
set -x # debug mode

# users definition
FRSURFER_SCRIPTSDIR=~/git/fs-scripts
ANALYSIS_ID_REGEXP=^U280.._[12]$

FRSURFER_SCRIPTNAME=/usr/local/freesurfer/bin/recon-all

maxrunning=$(getconf _NPROCESSORS_ONLN)

for fid in $(ls |grep "$ANALYSIS_ID_REGEXP"); 
do 
	running=$(ps -aux|grep "$FRSURFER_SCRIPTNAME"|while read -a tempary;do for ii in "${!tempary[@]}";do if [ $ii -ge 12 ];then echo -n "${tempary[$ii]} ";fi;done;echo "";done|sort|uniq|wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux|grep "$FRSURFER_SCRIPTNAME"|while read -a tempary;do for ii in "${!tempary[@]}";do if [ $ii -ge 12 ];then echo -n "${tempary[$ii]} ";fi;done;echo "";done|sort|uniq|wc -l)

	done
	$FRSURFER_SCRIPTNAME -s $fid -hippocampal-subfields-T1 &
done

wait

for fid in $(ls |grep "$ANALYSIS_ID_REGEXP"); 
do 
	running=$(ps -aux|grep "$FRSURFER_SCRIPTNAME"|while read -a tempary;do for ii in "${!tempary[@]}";do if [ $ii -ge 12 ];then echo -n "${tempary[$ii]} ";fi;done;echo "";done|sort|uniq|wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux|grep "$FRSURFER_SCRIPTNAME"|while read -a tempary;do for ii in "${!tempary[@]}";do if [ $ii -ge 12 ];then echo -n "${tempary[$ii]} ";fi;done;echo "";done|sort|uniq|wc -l)
	done
	$FRSURFER_SCRIPTNAME -s $fid -brainstem-structures &
done

wait

# QC hippo
#<analysisID>/mri/[lr]h.hippoSfLabels-<T1>-<analysisID>.v10.mgz
#<analysisID>/mri/[lr]h.hippoSfLabels-<T1>-<analysisID>.v10.FsvoxelSpace.mgz
#<analysisID>/mri/[lr]h.hippoSfVolumes-<T1>-<analysisID>.v10.txt

# QC brainstem
#<analysisID>/mri/brainstemSslabels.v10.mgz
#<analysisID>/mri/brainstemSslabels.v10.FsvoxelSpace.mgz
#<analysisID>/mri/brainstemSsVolumes.v10.txt

$FRSURFER_SCRIPTSDIR/fs_stats_hipposf.sh $ANALYSIS_ID_REGEXP

timestamp=$(date +%Y%m%d_%H%M)
quantifyBrainstemStructures.sh tables/${timestamp}_brainstem.csv

echo "end of reconsubfieldall.sh"

