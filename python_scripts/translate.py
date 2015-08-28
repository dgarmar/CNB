#!/usr/bin/python

import argparse


## Opciones y argumentos del programa
    
parser = argparse.ArgumentParser()

parser.add_argument('--sequences', nargs=2,metavar=('SEQUENCE1','SEQUENCE2'), required=True,
                        help='The two FASTA input sequences.')
parser.add_argument('--msa',
                       help='The FASTA MSA')
parser.add_argument('--sdps', nargs=2,metavar=('SDPs1','SDPs2'),required=True,
                        help='The two SDP lists to compare.')
parser.add_argument('--out', metavar= 'OUTPUT FILE',default=None, 
			help='Output file (SDP overlap).')

parser.add_argument('--test', metavar= 'TEST', type=int, default=None,
			help='For debugging tasks.')

args = parser.parse_args()

## Funciones

def getSeq(seqfile):
	f = open(seqfile,'r')
	seq = f.read().splitlines() 
	seq = "".join(seq[1:])
	f.close()	
	return seq


def getMSA(msafile):
	f = open (msafile, 'r')
	import re
	header = re.compile('>.*')
	count=0	
	msa1=''
	msa2=''
	for line in f:
		if re.match(header,line):						
			count+=1			
			continue
		else:
			if count==1:
				msa1+=line.strip()	
			elif count==2:
				msa2+=line.strip()
	return msa1,msa2
			

def makeDict(seq1,seq2,msa1,msa2):
	d={}
	d2={}	
	d3={}
	j=0
	j2=0

	for i in range(len(seq1)-1):	
		if seq1[i]=='-':
			continue				
		else:			
			if seq1[i]==msa1[j]:
				d[i]=j			
			else:			
				while True:
	     				j+=1
					if seq1[i]==msa1[j]:
						d[i]=j       		 				
						break
		j+=1	

	
	for i2 in range(len(seq2)-1):
		if seq2[i2]=='-':
			continue					
		else:			
			if seq2[i2]==msa2[j2]:
				d2[j2]=i2
			else:			
				while True:
     					j2+=1
					if seq2[i2]==msa2[j2]:
						d2[j2]=i2      		 				
						break
		j2+=1


	for x in d:
		if d[x] in d2:
			d3[x]=d2[d[x]]

	return d3	

	
def getSDPs(sdpfile):
	f = open(sdpfile,'r')
	seq = f.read().splitlines() 
	f.close()	
	return seq		


def overlap (sdps1,sdps2,d):
	sdpsTrans=[]
	n=0
	for sdp in sdps1:
		if int(sdp) in d:
			sdpsTrans.append( str(d[int(sdp)]+1) )
			
		else:
			n+=1
	
	#return list(set(sdpsTrans).intersection(sdps2)), n	
	return sdpsTrans,n

## Parsing

# Secuencias

seq1 = getSeq(args.sequences[0])
seq2 = getSeq(args.sequences[1])

# MSA

msa1, msa2 = getMSA(args.msa)

## Creando el diccionario para la traducción

d = makeDict(seq1,seq2,msa1,msa2)

## SDPs

sdps1 = getSDPs(args.sdps[0])
sdps2 = getSDPs(args.sdps[1])

## Test

if args.test != None:
	print "\n","##############"
	print " ",d[args.test]
	print  "##############","\n"


## PRINCIPAL ##

set, n = overlap(sdps1,sdps2,d)
output = len(set)/float(len(sdps1))


# output

if args.out != None:
        out_file = open(args.out,'w')
        out_file.write(output)
else:
	print output


















