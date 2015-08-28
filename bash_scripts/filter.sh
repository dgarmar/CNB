#!/bin/bash

#$ -N filter
#$ -cwd
#$ -o ../clust_out/$JOB_NAME-$JOB_ID.out
#$ -e ../clust_err/$JOB_NAME-$JOB_ID.err
#$ -t 1-121

 export BIN="/home/dgarrido/project/bin"
 export WD="/home/dgarrido/project/run"
 export IN="/home/dgarrido/project/run/my_msa"

 msa=$( ls $IN/$1 | sort | sed -n ${SGE_TASK_ID}p )

 if [ -s $IN/$1/$msa ]; then
 	/home/pazos/bin/filter_aln_linux32 $IN/$1/$msa /home/pazos/Maxhom_McLachlan.metric -R=90 -O=F > $WD/my_msa.filt/$1/$msa 2> $HOME/tmp/filter.err
 else
        > $WD/my_msa.filt/$1/$msa
 fi
