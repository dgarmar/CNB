#!/bin/bash

#$ -N blast
#$ -cwd
#$ -o ../clust_out/$JOB_NAME-$JOB_ID.out
#$ -e ../clust_err/$JOB_NAME-$JOB_ID.err
#$ -t 1-121

export IN="/home/dgarrido/project/run/seqs"
export WD="/home/dgarrido/project/run"

INPUT=$( ls $IN | sort | sed -n ${SGE_TASK_ID}p )
OUTPUT1=("output.names" $( ls $IN | sort | sed 's/^\(.*\).msa.1seq/\1.blast.fa/' ) )
OUTPUT2=("output.names" $( ls $IN | sort | sed 's/^\(.*\).msa.1seq/\1.blast.ids/' ) )

blastout=$( blastall -p blastp -d "/scratch/db/uniprot/uniprot_sprot /scratch/db/uniprot/uniprot_trembl" -i $IN/$INPUT -m8 -e 0.0001 | sed 's/.*\:\t..|\([^|]*\)|.*/\1/' | sort | uniq | paste -d, -s )
fastacmd -d "/scratch/db/uniprot/uniprot_sprot /scratch/db/uniprot/uniprot_trembl" -p T -s $blastout > $WD/blast.fa/${OUTPUT1[ $SGE_TASK_ID ]}


echo $blastout > $WD/blast.ids/${OUTPUT2[ $SGE_TASK_ID ]}
sed 's/,/\n/g' -i  $WD/blast.ids/${OUTPUT2[ $SGE_TASK_ID ]}
