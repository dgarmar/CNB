#!/bin/bash

#$ -N clustalo
#$ -cwd
#$ -o ../../../clust_out/$JOB_NAME-$JOB_ID.out
#$ -e ../../../clust_err/$JOB_NAME-$JOB_ID.err
#$ -t 1-121

export BIN="/home/dgarrido/project/bin"
export WD="/home/dgarrido/project/run"
export IN1="/home/dgarrido/project/run/year_ids"
export IN2="/home/dgarrido/project/run/blast.fa"

ids=$( ls $IN1/$1 | sort | sed -n ${SGE_TASK_ID}p )
fa=$( ls $IN2 | sort | sed -n ${SGE_TASK_ID}p )
OUTPUT=("output.names" $( ls $IN2 | sort | sed 's/^\(.*\)\.blast\.fa/\1.msa/' ) )

perl $BIN/merge.pl --ids $ids --fa $WD/blast.fa/$fa | clustalo -i - > $WD/my_msa/$1/${OUTPUT[ $SGE_TASK_ID ]}.$1
