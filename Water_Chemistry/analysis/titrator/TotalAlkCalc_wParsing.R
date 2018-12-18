#Calculate total alkalinity using potentiometric titrations
#Uses a for loop to read in data exported as a titration file and calculate Total alkalinity
#At the end it exports your data as a .csv file. Comment the last line out if your don't want that.

### Files needed ######
# 1. pHCalibration.csv in your "Data" folder
#Inside the Data folder You must have a subfolder for each data set. In each subfolder there is:
#2. the mass file for your run  
#3. a subfolder named "TodaysDate" (where all of your titration files are) directly exported from LabX.
# 

#Created by Nyssa Silbiger 03/28/2014
#modified 20180627 Hollie Putnam
#------------------------------------------------------------
rm(list=ls())

#set working directory---------------------------------------------------------------------------------------------
setwd("~/Documents/GitHub/P_generosa/Water_Chemistry/data/Titrator/")
main<-getwd()

#load libraries----------------------------------------------
library(seacarb) #used to calculate TA
library(tidyverse)

#CHANGE THESE VALUES EVERY DAY----------------------------------------------
# Date that the data were run
date<-'20181128'


#path<-paste("Data/",date, sep = "") #the location of all your titration files
massfile<-paste(date,"mass_run1.csv", sep ="") # name of your file with masses
titrationfile<-paste(date,"_run1.csv",sep = "") # name of the last titration file run


#DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS A NEW BOTTLE OF ACID IS USED
#load Data---------------------------------------------------
#load Mass Data
Mass<-read.csv(file.path(main,date,massfile), header=T, sep=",", na.string="NA", as.is=T) 

#### pH Calibration #####
pHCal<-read.csv(paste(main,'pHCalibration.csv', sep = "/")) # read in the pH Calibration file

#select the calibration for the correct date
pHData<-pHCal[pHCal$Date==date,]

# calculate pH 3 and 3.5 based on the slope and intercept from pH 4, 7, and 10 calibration
mod.pH<-lm(c(pHData$pH4, pHData$pH7, pHData$pH10)~c(4,7,10)) # linear model

# print a plot of the relationship between pH and mV
#png(paste0(path,"/",Sys.Date(),'pHmvplot.png'), height = 400, width = 400)
plot(c(4,7,10), c(pHData$pH4, pHData$pH7, pHData$pH10), xlab = 'pH', ylab = 'mv')
lines(c(4,7,10), predict(mod.pH))
R2<-summary(mod.pH)$r.squared
legend('topright', legend = bquote(R^2 == .(format(R2, digits = 3))), bty='n')
#dev.off()

# Select the mV for pH=3 and pH=3.5 based on your probe calibration
pH35<-mod.pH$coefficients[1]+mod.pH$coefficients[2]*3.5
pH3<-mod.pH$coefficients[1]+mod.pH$coefficients[2]*3

##### titration###########
#create an empty matrix to put the TA values in
nrows<-nrow(Mass) # number of rows in a mass file
TA <- data.frame(matrix(nrow = nrows, ncol = 4))
rownames(TA)<-Mass$Sample.ID1[1:nrows]
colnames(TA)<-c("Sample.ID",'TA','Mass', 'Type')

#run a for loop to bring in the titration files one at a time and calculate TA
# read in the mega concatenated titration results file
filename<-file.path(date,titrationfile)
AllData<-read.csv(filename, sep=",", na.string="NA",as.is=T, skip=12)[ ,1:5] 
#AllData <- AllData[-1,]
# Identifies rows starting with zero seconds "0" in column 2
sample_name_positions <- c(1,grep("^0", AllData[,2]), nrow(AllData))
sample_name_positions <- sample_name_positions[-1] #remove first report of duplicated 1

## parse through all the data in the one file ###
sample_names<-Mass$sample
# create a list with all the sample IDs
sample_names_list <- list()
for (item in 1:length(sample_names)){
  sample_names_list[[item]] <- sample_names[item]
}


# fill the list with the data from each sample
for (i in 1:nrows){
sample_names_list[[i]]<-data.frame(AllData[sample_name_positions[i]:sample_name_positions[i+1],])
colnames(sample_names_list[[i]])<-c("Volume","Time","mV","Temperature","dV/dt")
}


for(i in 1:nrows) {
#  Data<-read.csv(file.names[i], header=F, sep=",", na.string="NA",as.is=T, skip=10)[ ,1:5] 
 # colnames(Data) <-  c("Volume","Time",	"mV",	"Temperature",	"dV/dt")
  Data<-sample_names_list[[i]]
  # everything was brought in as a character because of the second line, converts back to numeric
  Data$mV<-suppressWarnings(as.numeric(Data$mV)) ## supress the warnings since NA will be produced through coercion
  Data$Temperature<-suppressWarnings(as.numeric(Data$Temperature)) ## supress the warnings since NA will be produced through coercion
  Data$Volume<-suppressWarnings(as.numeric(Data$Volume)) ## supress the warnings since NA will be produced through coercion
  #name of the file without .csv
  #name<-unlist(strsplit(file.names[i], split='.', fixed=TRUE))[1]
  name<-sample_names[i]
  
  #calculates the index of values between pH 2 and 3.5 
  mV<-which(Data$mV<pH3 & Data$mV>pH35) 
  
  #CHANGE ONLY WHEN NEW BOTTLE OF ACID IS USED----------------------------------
  #Bottle A14 - acid titrant# , changed 20180921 K. Silliman
  #density of your titrant: change every time acid is changed
  
  d<-1.02900 -(0.0001233*mean(Data$Temperature[mV], na.rm=T)) - (0.0000037*(mean(Data$Temperature[mV], na.rm=T)^2)) 
  #Batch A14
  
  #concentration of your titrant: CHANGE EVERYTIME ACID IS CHANGED 
  c<-0.100183 #Batch A14
  
  #------------------------------------------------------------------------------
  
  #Salinity of your samples
  s<-Mass[Mass$sample==name,3]
  #s<-Mass[name,2]
  #mass of sample in g: changed with every sample
  #mass<-Mass[name,1]
  mass<-Mass[Mass$sample==name,2]
  #sample.index<-Mass[Mass$Sample.ID1==name,3]# this is the order that the sample was run
  #-------------------------------------------------------------------
  #Calculate TA
  
  #at function is based on code in saecarb package by Steeve Comeau, Heloise Lavigne and Jean-Pierre Gattuso
  TA[i,1]<-name
  TA[i,2]<-1000000*at(S=s,T=mean(Data$Temperature[mV], na.rm=T), C=c, d=d, pHTris=NULL, ETris=NULL, weight=mass, E=Data$mV[mV], volume=Data$Volume[mV])
  TA[i,3]<-mass
  #TA[i,4]<-sample.index
}
TA[,2:3]<-sapply(TA[,2:3], as.numeric) # make sure the appropriate columns are numeric
#exports your data as a CSV file
write.table(TA,paste0(date,"/","TA_Output_",titrationfile),sep=",", row.names=FALSE)




#Cumulative TA

cumu.data <- read.csv(paste(main,"/Cumulative_TA_Output.csv", sep =""), header=TRUE, sep=",")

folderlist <- list.dirs(path = main)
TA.files <- dir(folderlist, pattern = "TA_Output_", full.names = TRUE )
update.data <- data.frame()
for(i in 1:length(TA.files)){
 TA.file <- read.csv(TA.files[i], stringsAsFactors=FALSE)
 update.data <- rbind(update.data, TA.file[,1:3])
}

cumu.data <- rbind(cumu.data,update.data)
cumu.data$date <- as.POSIXct(substr(cumu.data$Sample.ID,0,8), format = "%Y%m%d")
cumu.data$sample.name <- substr(cumu.data$Sample.ID,10,length(cumu.data$Sample.ID))
#write.table(update.data,paste(main,"/Cumulative_TA_Output.csv", sep = ""),sep=",", row.names=FALSE)

fall.data <- cumu.data[which(cumu.data$date > as.Date("2018-11-06")),]
fall.data$treatment <- "treatment"
for(i in 1:length(fall.data$treatment)){
  if(grepl("CRM",fall.data$sample.name[i])){
    fall.data$treatment[i] <- "STD"
  }
  if(grepl("JUNK", fall.data$sample.name[i], ignore.case = TRUE)){
    fall.data$treatment[i] <- "JUNK"
  }
  if(grepl("^3|^4", fall.data$sample.name[i])){
    fall.data$treatment[i] <- "ambient"
  }
  if(grepl("^1|^2", fall.data$sample.name[i])){
    fall.data$treatment[i] <- "low"
  }

}                              
             
#plot TA over time for amb and low on the same plot
ggplot(fall.data[which(fall.data$Mass > 59 & fall.data$treatment == "ambient"| fall.data$treatment == "low"),], aes(date, TA)) + geom_line(aes(color = sample.name)) + scale_x_datetime("date", date_breaks = "day", date_labels = "%b %d", expand = c(0,0), minor_breaks = NULL) + theme(axis.text.x=element_text(angle = 90, hjust = 0)) + geom_point(aes(color = sample.name))



#plot TA over time facetted by sample name
ggplot(fall.data, aes(date, TA)) + geom_line(aes(color = sample.name)) + facet_wrap(~treatment, scale = "free")
                 