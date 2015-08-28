library(ggplot2)
library(reshape2)
library(Hmisc)

setwd("~/Escritorio/final.res/06/")

#---------------------------------------------------------------------> OVERLAP (PERCENTAGE)
#table.perc.na <- data.frame(read.delim("sdp.count.s3det",header=F))*0
table.perc <- data.frame(read.delim("perc.s3det.res",header=F))#+table.perc.na
msa.names <- read.table("../msa.list",as.is=T)[,1]

years<-seq(1994,2014,2)
colnames(table.perc)<-years
rownames(table.perc)<-msa.names

table.perc<-table.perc[apply(table.perc,1,sum,na.rm=T)!=0,]
table.plot <- melt(table.perc)

# Average tendency
perc<-apply(table.perc,2,mean,na.rm=T)*100
df<-data.frame(years,perc)

## df<-rbind (df0,df1,df2,df3)
## df<-cbind (df,leyenda=c(rep("3. Unión",11),rep("1. Xdet (0.7)",11),rep("2. S3det",11),rep("4. Intersección",11)))

q <- ggplot(df, aes(x=years,y=perc,group=leyenda,colour=leyenda))
q + geom_line() +
  xlab("Año")+ylab("% de solapamiento medio")+ggtitle("Variación histórica - bondad de la predicción")+
  scale_x_continuous(breaks=seq(1994,2014,2))+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"))+
  theme(plot.title = element_text(size=16,face="bold"))+
  theme(legend.title = element_text(size = 12))+
  theme(legend.text = element_text(size = 12))
  

ggplotColours <- function(n=6, h=c(0, 360) +15){
  if ((diff(h)%%360) < 1) h[2] <- h[2] - 360/n
  hcl(h = (seq(h[1], h[2], length = n)), c = 100, l = 65)
}
col<-ggplotColours(4)

# Overall boxplots
p <- ggplot(table.plot, aes(factor(variable),value*100))
p + geom_boxplot(aes(fill = variable))+
  stat_summary(fun.y=mean, colour="orange", geom="line",aes(group=1), size = 1)+
  stat_summary(fun.y=mean, colour="orange", geom="point", size = 3)+
  xlab("Año")+ylab("% solapamiento")+ggtitle("Variación histórica - bondad de predicción (S3det)")+
  theme(legend.position="none")+
  scale_fill_manual(values=rep(col[2],11))+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"))+
  theme(plot.title = element_text(size=16,face="bold"))

#---------------------------------------------------------------------> TOTAL NUMBER OF SDPS FOUND

#table.count.na <- data.frame(read.delim("sdp.count.s3det",header=F))*0

table.count <- data.frame(read.delim("sdp.count.s3det",header=F))#+table.count.na
colnames(table.count)<-years
rownames(table.count)<-msa.names

table.count<-table.count[apply(table.count,1,sum,na.rm=T)!=0,]
table.plot <- melt(table.count)

## df<-rbind (df0,df1,df2,df3)
## df<-cbind (df,leyenda=c(rep("3. Unión",11),rep("1. Xdet (0.7)",11),rep("2. S3det",11),rep("4. Intersección",11)))

# Average tendency
count<-apply(table.count,2,mean,na.rm=T)
df<-data.frame(years,count)
q <- ggplot(df, aes(x=years,y=count,group=leyenda,colour=leyenda))
q + geom_line() +
  xlab("Año")+ylab("Número medio de SDPS identificados")+ggtitle("Variación histórica - Número medio de SDPs identificados")+
  scale_x_continuous(breaks=seq(1994,2014,2))+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"))+
  theme(plot.title = element_text(size=16,face="bold"))+
  theme(legend.title = element_text(size = 14))+
  theme(legend.text = element_text(size = 14))

# Overall boxplots
p <- ggplot(table.plot, aes(factor(variable),value))
p + geom_boxplot(aes(fill = variable))+
  stat_summary(fun.y=mean, colour="orange", geom="line",aes(group=1), size = 1)+
  stat_summary(fun.y=mean, colour="orange", geom="point", size = 3)+
  ylim(0,200)+
  xlab("Año")+ylab("Número de SDPs identificados")+ggtitle("Variación histórica - Número de SDPs identificados (S3det))")+
  theme(legend.position="none")+
  scale_fill_manual(values=rep(col[2],11))+
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"))+
  theme(plot.title = element_text(size=16,face="bold"))

