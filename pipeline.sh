#!/bin/bash

# Definición de variables de entorno

 export WD="/home/dgarrido/project/run"
 export MSA="/home/dgarrido/project/data/LargeNECDataset/msa"
 export BIN="/home/dgarrido/project/bin"
 export DATA="/home/dgarrido/project/data"
 export RES="/home/dgarrido/project/run/results"
 export OUT="/home/dgarrido/project/run/results/final.res"

# Construcción del directorio de trabajo
 cd $WD
 mkdir seqs blast.ids blast.fa year_ids my_msa my_mfa my_msa.filt sdps sdps/xdet sdps/s3det results results/seq1 results/seq2 results/align results/xdet results/s3det results/merged results/common results/mfa results/final.res results/final.res/06 results/final.res/07

# Obtención de la primera secuencia de los MSAs originales

 time for msa in $( ls $MSA ); do
	 perl $BIN/getSeq.pl $MSA/$msa > seqs/$msa.1seq
 done

# BLAST. Obtención de IDs y secuencias en formato FASTA

 qsub $BIN/blast.jarray.sh

	# Tiempo de ejecución = 1h3min9s

##STOP##

# Iterar sobre los distintos años para obtener el resultado correspondiente a cada año. MSA con clustal Omega

 cat $WD/blast.ids/* | sort | uniq > $DATA/all.ids
 time grep -Ff $DATA/all.ids $DATA/swissprot_trembl_dates | awk -F'-' '{print $1"\t"$2"\t"$3}' | cut -f 2,5 > $DATA/all.dates # Tiempo de ejecución = 41s

 for year in {1994..2014..2}; do

	mkdir $WD/year_ids/$year
	mkdir $WD/my_msa/$year
	mkdir $WD/my_mfa/$year
	mkdir $WD/my_msa.filt/$year
	mkdir $WD/sdps/xdet/$year
	mkdir $WD/sdps/s3det/$year
	mkdir $WD/results/xdet/$year
	mkdir $WD/results/s3det/$year
	mkdir $WD/results/merged/$year
	mkdir $WD/results/common/$year
	mkdir $WD/results/align/$year
	mkdir $WD/results/seq2/$year
	mkdir $WD/results/mfa/$year
	cd $WD/year_ids/$year

  Rscript $BIN/retrieve.ids.R $year
	qsub $BIN/clustalo.sh $year > $HOME/tmp/stdout.txt
 done

 cd $WD

 JOB_ID=`cut -c 16-22 $HOME/tmp/stdout.txt` # for hold

	# Tiempo de ejecución = 29min42s


##STOP##


#---------------------------------------- Generar multiFASTAs (keeping track)
 time for year in {1994..2014..2}; do
        for ids in $( ls $WD/year_ids/$year ); do
	name=$( basename $ids | sed 's/^\(.*\)\.ids.*/\1/' )
	perl $BIN/merge.pl --ids $WD/year_ids/$year/$ids --fa $WD/blast.fa/$name.blast.fa > $WD/my_mfa/$year/$name.mfa.$year 2> $HOME/tmp/keeptrack.mfa.txt
	done
 done
#---------------------------------------- Tiempo de ejecución = 1min7s


# Filtro de redundancia al 90% (sin usar el cluster)

 time for year in {1994..2014..2}; do #STEP BY STEP
	for msa in $( ls $WD/my_msa/$year ); do
		if [ -s $WD/my_msa/$year/$msa ]; then
			/home/pazos/bin/filter_aln_linux32 $WD/my_msa/$year/$msa /home/pazos/Maxhom_McLachlan.metric -R=90 -O=F > $WD/my_msa.filt/$year/$msa 2> $HOME/tmp/filter.err
		else
			> $WD/my_msa.filt/$year/$msa
		fi
	done
 done
 
	# Tiempo de ejecución = ~ 1min45s

# Filtro de redundancia al 90% (en el cluster)

 for year in {1994..2014..2}; do 
        qsub -hold_jid $JOB_ID $BIN/filter.sh $year > $HOME/tmp/stdout.txt
 	#qsub $BIN/filter.sh $year > $HOME/tmp/stdout.txt
 done

 JOB_ID=`cut -c 16-22 $HOME/tmp/stdout.txt` # for hold

	# Tiempo de ejecución =  14m57s #(No compensa en este caso ejecutarlo encolado en el cluster)


##STOP##


# SDPs

 # (previo)

 ln -s /home/pazos/conf.h
 ln -s /home/pazos/S3det_Wilcoxon_test.R

 # Run

 for year in {1994..2014..2}; do
	qsub -hold_jid $JOB_ID $BIN/SDPseeker.sh $year > $HOME/tmp/stdout.txt
 done

 JOB_ID=`cut -c 16-22 $HOME/tmp/stdout.txt` # for hold
	# Tiempo de ejecución = 29 min


##STOP##


# Seleccionar el límite de score para Xdet (t=0.6 en este caso)

 t=0.6
 time for year in {1994..2014..2}; do
	for xdet in $( ls $WD/sdps/xdet/$year/* ); do
		cat $xdet | awk -v t=$t '$9>=t {print $1"\t"$2"\t"$9}' > $xdet.06
	done
 done


# Obtener las secuencias y los SDPs para posteriormente evaluar la predicción

 # Obtener seq1's (DB)

  for msa in $( ls $MSA ); do
	name=$( basename $msa | sed 's/^\(.*\)\.msa/\1/' )
        perl $BIN/getSeq.pl $MSA/$msa > $WD/results/seq1/$name.seq1
  done

 # Obtener seq2's (my_msa.filt), obtener el MSA "traductor"

  time for year in {1994..2014..2}; do
	for msaf in $( ls $WD/my_msa.filt/$year ); do
        	name=$( basename $msaf | sed 's/^\(.*\)\.msa\..*/\1/' )
          	perl $BIN/getSeq.pl  $WD/my_msa.filt/$year/$msaf > $WD/results/seq2/$year/$name.seq2 # Seq2
		cat $WD/results/seq1/$name.seq1 $WD/results/seq2/$year/$name.seq2 > $WD/results/mfa/$year/$name.mfa # MFA for translator MSA
		clustalo -i $WD/results/mfa/$year/$name.mfa 2>$HOME/tmp/translate.msa | grep -v 'Transfer:' > $WD/results/align/$year/$name.msa # Translator MSA
		#grep 'RE:' $WD/sdps/s3det/$year/$name.sdps.s3det.$year | cut -f 1 | cut -f 2 -d ' ' | sort -n | uniq > $WD/results/s3det/$year/$name.s3det 2>$HOME/tmp/prep.res # S3det SDPs
		#cut -f1 $WD/sdps/xdet/$year/$name.sdps.xdet.$year.07 | sort -n | uniq > $WD/results/xdet/$year/$name.xdet 2>>$HOME/tmp/prep.res # Xdet SDPs                                        ### WARNING .06/07
		#cat $WD/results/xdet/$year/$name.xdet $WD/results/s3det/$year/$name.s3det | sort | uniq > $WD/results/merged/$year/$name.merged 2>>$HOME/tmp/prep.res # Merged SDPs
		#comm -12 $WD/results/xdet/$year/$name.xdet $WD/results/s3det/$year/$name.s3det > $WD/results/common/$year/$name.common 2>>$HOME/tmp/prep.res # Common SDPs
	done
  done		
  
  # Tiempo de ejecución = ~5min


 # Obtener SDPs

  # S3det

  time for year in {1994..2014..2}; do
        for x in $( ls $WD/sdps/s3det/$year ); do
                name=$( basename $x | sed 's/^\(.*\)\.pre-sdps\.s3det.*/\1/' )
		grep 'Error' $WD/sdps/s3det/$year/$x  >$HOME/tmp/prep.res || ( grep 'RE:\|CP:\|UI: Number of groups selected:' $WD/sdps/s3det/$year/$x > $WD/sdps/s3det/$year/$name.sdps.s3det.$year &&
		grep 'RE:' $WD/sdps/s3det/$year/$name.sdps.s3det.$year 2>$HOME/tmp/prep.res | cut -f 1 | cut -f 2 -d ' ' | sort -n | uniq > $WD/results/s3det/$year/$name.s3det )  # S3det SDPs
	done
  done
		# Tiempo de ejecución = ~ 29s

  # Xdet, unión, intersección

  time for year in {1994..2014..2}; do
        for msa in $( ls $MSA  ); do
                name=$( basename $msa | sed 's/^\(.*\)\.msa/\1/' )
                if  [[ -s $WD/results/seq2/$year/$name.seq2 ]]; then
                	cut -f1 $WD/sdps/xdet/$year/$name.sdps.xdet.$year.06 2>>$HOME/tmp/prep.res | sort -n | uniq > $WD/results/xdet/$year/$name.xdet  # Xdet SDPs                                        ### WARNING .06/07
                	cat $WD/results/xdet/$year/$name.xdet $WD/results/s3det/$year/$name.s3det 2>>$HOME/tmp/prep.res | sort | uniq > $WD/results/merged/$year/$name.merged  # Merged SDPs
                	comm -12 $WD/results/xdet/$year/$name.xdet $WD/results/s3det/$year/$name.s3det 2>>$HOME/tmp/prep.res > $WD/results/common/$year/$name.common  # Common SDPs
		fi
	done
 done
		# Tiempo de ejecución = 38s


# "Traducir" los SDPs y obtener los resultados de bondad de predicción para S3det      WARNING 06/07

  time for year in {1994..2014..2}; do
        >$OUT/06/out.$year
        for msa in $( ls $MSA  ); do
                name=$( basename $msa | sed 's/^\(.*\)\.msa/\1/' )
                if  [[ -e $WD/results/s3det/$year/$name.s3det ]]; then
                        $BIN/translate.py --sequences $RES/seq1/$name.seq1 $RES/seq2/$year/$name.seq2 --msa $RES/align/$year/$name.msa --sdps $DATA/LargeNECDataset/sites/$name.sites $RES/s3det/$year/$name.s3det >>$OUT/06/out.$year
                else
                        echo  >>$OUT/06/out.$year
                fi
        done
 done

# "Traducir" los SDPs y obtener los resultados de bondad de predicción para Xdet, la unión y la intersección       WARNING 06/07

  time for year in {1994..2014..2}; do
        >$OUT/06/out.$year
        for msa in $( ls $MSA  ); do
                name=$( basename $msa | sed 's/^\(.*\)\.msa/\1/' )
                if  [[ -s $WD/results/seq2/$year/$name.seq2 ]]; then
                        $BIN/translate.py --sequences $RES/seq1/$name.seq1 $RES/seq2/$year/$name.seq2 --msa $RES/align/$year/$name.msa --sdps $DATA/LargeNECDataset/sites/$name.sites $RES/merged/$year/$name.merged >>$OUT/06/out.$year
                else
                        echo  >>$OUT/06/out.$year
                fi
        done
 done
                # Time = 1min16s


## Resultado final ## 			# WARNING: Pasos manuales de análisis


 # Porcentaje/número de SDPs

	# Modificar translate.py +  paste out.* > res (perc & num)

 # Número de subfamilias # WARNING 07

	 wc -l $DATA/LargeNECDataset/sub.info/* | grep -v 'total' | sed 's/^  \(.*\)\.sub\.info/\1/' | sed 's/^ //' | cut -d ' ' -f1 > $OUT/ori.fam

	for year in $( ls $WD/sdps/s3det ); do 
		cd $WD/sdps/s3det/$year
		> $OUT/06/s3det.fam.$year
 		for fam in $(ls $MSA);do
 			name=$( basename $fam | sed 's/^\(.*\)\.msa/\1/' )
			echo -e $( grep 'UI: Number of groups selected:' $name.sdps.s3det.$year 2>/tmp/shit | sed 's/UI: Number of groups selected: \(.*\)/\1/' ) >> $OUT/06/s3det.fam.$year
		done
	done

	cd $WD


 # Número de MSAs con al SDPs

	# for y in $( ls ); do ll $y | grep -v ' 0 '| wc -l; done
 

 # Número de SDPs identificado por S3det

 time for year in {1994..2014..2}; do #WARNING 07
        >$OUT/06/count.$year
        for msa in $( ls $MSA  ); do
                name=$( basename $msa | sed 's/^\(.*\)\.msa/\1/' )
                if  [[ -e $WD/results/s3det/$year/$name.s3det ]]; then
                        cat  $RES/s3det/$year/$name.s3det | wc -l >> $OUT/06/count.$year
                else
                        echo  >>$OUT/06/count.$year
                fi
        done
 done


 # Número de SDPs identificado por Xdet, la unión y la intersección

 time for year in {1994..2014..2}; do #WARNING 07
	>$OUT/06/count.$year
	for msa in $( ls $MSA  ); do
		name=$( basename $msa | sed 's/^\(.*\)\.msa/\1/' )
		if  [[ -s $WD/results/seq2/$year/$name.seq2 ]]; then
			cat  $RES/merged/$year/$name.merged | wc -l >> $OUT/06/count.$year
		else
			echo  >>$OUT/06/count.$year
		fi
	done
 done


# Obtener SDPs "traducidos" de los alineamientos originales (keeping track)

 paste out.* | sed 's/\[\]/-/g' | sed 's/\[//g' | sed 's/\]//g' | sed "s/'//g" | sed 's/\, /,/g' > sdps.merged
