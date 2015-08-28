library(ggplot2)
library(reshape2)
library(Hmisc)

pdf("~/Escritorio/plot.07.s3det.pdf", paper = "a4r", width = 0, height = 0)

setwd("~/Escritorio/final.res/07.ok/")

#---------------------------------------------------------------------> OVERLAP (PERCENTAGE)

table.perc <- data.frame(read.delim("perc.s3det.res",header=F))
msa.names <- read.table("../msa.list",as.is=T)[,1]

years<-seq(1994,2014,2)
colnames(table.perc)<-years
rownames(table.perc)<-msa.names

table.perc<-table.perc[apply(table.perc,1,sum,na.rm=T)!=0,]
table.plot <- melt(table.perc)

# Average tendency
perc<-apply(table.perc,2,mean,na.rm=T)*100
df<-data.frame(years,perc)
q <- ggplot(df, aes(x=years,y=perc))
q + geom_line(stat = "identity") +
  xlab("year")+ylab("% overlap")+ggtitle("Historical variation - average overlap (%)")

# Overall boxplots
p <- ggplot(table.plot, aes(factor(variable),value*100))
p + geom_boxplot(aes(fill = variable))+
  stat_summary(fun.y=mean, colour="orange", geom="point", size = 3)+
  xlab("year")+ylab("% overlap")+ggtitle("Historical variation - overlap (%)")+
  theme(legend.position="none")

# For each case
par(mfrow=c(2,2))
names=rownames(table.perc)
for (i in 1:dim(table.perc)[1]){
  barplot(as.numeric(table.perc[i,1:11])*100,ylim=c(0,100),names.arg=years,las=2,
          xlab="year",ylab="% overlap",main=sprintf("%s",names[i]))
}

#---------------------------------------------------------------------> OVERLAP (NUMBER)

# table.num <- data.frame(read.delim("num.merged.res",header=F))
# colnames(table.num)<-years
# rownames(table.num)<-msa.names
# 
# table.num<-table.num[apply(table.num,1,sum,na.rm=T)!=0,]
# table.plot <- melt(table.num)
# 
# # Average tendency
# num<-apply(table.num,2,mean,na.rm=T)
# df<-data.frame(years,num)
# q <- ggplot(df, aes(x=years,y=num))
# q + geom_line(stat = "identity") +
#   xlab("year")+ylab("overlap(number of SDPs)")+ggtitle("Historical variation - average overlap (number of SDPs) ")
# 
# # Overall boxplots
# p <- ggplot(table.plot, aes(factor(variable),value))
# p + geom_boxplot(aes(fill = variable))+
#   stat_summary(fun.y=mean, colour="orange", geom="point", size = 3)+
#   xlab("year")+ylab("overlap(number of SDPs)")+ggtitle("Historical variation - overlap (number of SDPs)")+
#   theme(legend.position="none")
# 
# For each case
# par(mfrow=c(2,2))
# names=rownames(table.num)
# for (i in 1:dim(table.num)[1]){
#   barplot(as.numeric(table.num[i,1:11]),names.arg=years,las=2,
#           xlab="year",ylab="overlap (number of SDPs)",main=sprintf("%s",names[i]))
# }



#---------------------------------------------------------------------> TOTAL NUMBER OF SDPS FOUND

table.count <- data.frame(read.delim("sdp.count.s3det",header=F))
colnames(table.count)<-years
rownames(table.count)<-msa.names

table.count<-table.count[apply(table.count,1,sum,na.rm=T)!=0,]
table.plot <- melt(table.count)

# Average tendency
count<-apply(table.count,2,mean,na.rm=T)
df<-data.frame(years,count)
q <- ggplot(df, aes(x=years,y=count))
q + geom_line(stat = "identity") +
  xlab("year")+ylab("Average number of SDPs found")+ggtitle("Historical variation - average number of SDPs found")

# Overall boxplots
p <- ggplot(table.plot, aes(factor(variable),value))
p + geom_boxplot(aes(fill = variable))+
  stat_summary(fun.y=mean, colour="orange", geom="point", size = 3)+
  xlab("year")+ylab("Number of SDPs found")+ggtitle("Historical variation - number of SDPs found")+
  theme(legend.position="none")

# For each case
par(mfrow=c(2,2))
names=rownames(table.count)
for (i in 1:dim(table.count)[1]){
  barplot(as.numeric(table.count[i,1:11]),names.arg=years,las=2,
          xlab="year",ylab="Number of SDPs found",main=sprintf("%s",names[i]))
}

#---------------------------------------------------------------------> SUBFAMILIES

# Subfamilies in total
setwd("~/Escritorio/final.res/")
fam.data<-read.delim("data.fam", header=F)

par(mfrow=c(1,1))
fams<-apply(fam.data[,2:13],2,sum,na.rm=T)
df2<-data.frame(years=c(years,"DB"),fams)
q <- ggplot(df2, aes(x=years,y=fams))
q + geom_bar(stat="identity",aes(fill=years)) + scale_fill_manual(values = c(rep("blue",11),"red"))+
  theme(legend.position="none")+
  xlab("years")+ylab("Total number of s3det subfamilies")+ggtitle("Historical variation of number of subfamilies")

# Subamilies fam by fam 
par(mfrow=c(2,2))
for (i in 1:dim(fam.data)[1]){
  b<-barplot(as.numeric(fam.data[i,2:12]),las=2,ylim=c(0,max(fam.data[i,2:13][!is.na(fam.data[i,2:13])])+1),names.arg=years,main=sprintf("%s",fam.data[i,1]))
  lines(x=b,y=rep(fam.data[i,13],length(years)))
}


#---------------------------------------------------------------------> NUM FAMS WITH SDPs

# Num fams with SDPs
setwd("~/Escritorio/final.res/06")
table.nb <- data.frame(read.table("nb.famsdps.s3det"))
colnames(table.nb)<-"Number"
rownames(table.nb)<-years
p<-ggplot(table.nb,aes(x=rownames(table.nb),y=Number))
p + geom_bar(stat="identity")+
  xlab("years")+ylab("Number of families with at least one SDP")+ggtitle("Historical variation")


dev.off()

