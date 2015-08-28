#!/bin/bash

#$ -N sdp.seeker
#$ -cwd
#$ -o ../clust_out/$JOB_NAME-$JOB_ID.out
#$ -e ../clust_err/$JOB_NAME-$JOB_ID.err
#$ -t 1-121

export BIN="/home/dgarrido/project/bin"
export WD="/home/dgarrido/project/run"
export IN="/home/dgarrido/project/run/my_msa.filt"

msaf=$( ls $IN/$1 | sort | sed -n ${SGE_TASK_ID}p )

if [ -s $IN/$1/$msaf ]; then
	name=$( basename $msaf | sed 's/^\(.*\)\.msa\.\(.*\)/\1/' )
	/home/pazos/bin/xdet_linux64 $IN/$1/$msaf /home/pazos/Maxhom_McLachlan.metric > $WD/sdps/xdet/$1/$name.sdps.xdet.$1 #| sort -nr -k 9
        /home/pazos/bin/s3det_linux64 -i $IN/$1/$msaf -o $WD/sdps/s3det/$1/$name.pre-sdps.s3det.$1 #> $HOME/tmp/s3det.err 2>$HOME/tmp/s3det.err

fi
