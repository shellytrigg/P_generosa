
#http://www.informit.com/articles/article.aspx?p=2215520

#modified as of 20180715 SJG
#added reminders on lines 39 and 43 to prevent overwritting files ->  SJG
#changes in lines 20 - 36 for column name changes for switched conicals -> 20170708 by SJG 

library("XML")
library("plyr")



xmlfile <- xmlParse("http://192.168.1.101:80/cgi-bin/datalog.xml?sdate=181026&days=14") #read in the date plus x days of Apex data
xmlfile <- xmlParse("http://192.168.0.1:80/cgi-bin/datalog.xml?sdate=181107&days=2") #read in the date plus x days of Apex data

Apex.Data <- ldply(xmlToList(xmlfile), data.frame) #convert xml to dataframe

Apex.Data <- read.csv("~/Documents/GitHub/P_generosa/Water_Chemistry/Apex_data_20181026-20181107.csv", stringsAsFactors = FALSE)
Apex.Data <- Apex.Data[-c(1:3),-c(1:2,grep("type", colnames(Apex.Data)))]

Apex.Data.probe <- Apex.Data[,c(1,grep("name", colnames(Apex.Data)))]
Apex.Data.val <- Apex.Data[,c(1,grep("value", colnames(Apex.Data)))]
Apex.Data.probe <- gather(Apex.Data.probe, probe_name, value ,-1)
Apex.Data.val <- gather(Apex.Data.val, value2, value ,-1)
Apex.Data <- cbind(Apex.Data.probe[,-2], Apex.Data.val[,3])
Apex.Data <- Apex.Data[grep("pH|Tmp", Apex.Data$value),]
Apex.Data <- Apex.Data[-grep("6", Apex.Data$value),]
Apex.Data$date <- as.POSIXct(strptime(Apex.Data$date, "%m/%d/%Y %H:%M:%S"))
colnames(Apex.Data) <- c("date", "probe", "value")
Apex.Data$probe <- gsub("^Tmp$", "Tmp_1", Apex.Data$probe)
Apex.Data$probe <- gsub("^pH$", "pH_1", Apex.Data$probe)
ggplot(Apex.Data[grep("pH", Apex.Data$probe),], aes(x= date, y= value)) + geom_point() + scale_x_datetime("date", date_breaks = "day", date_labels = "%b %d", expand = c(0,0), minor_breaks = NULL) + xlab("Date") + ylab("pH")  + facet_wrap(~probe) + theme(axis.text.x=element_text(angle = 90, hjust = 0))
ggplot(Apex.Data[grep("Tmp", Apex.Data$probe),], aes(x= date, y= value)) + geom_point() + scale_x_datetime("date", date_breaks = "day", date_labels = "%b %d", expand = c(0,0), minor_breaks = NULL) + xlab("Date") + ylab("Temp (Celcius)")  + facet_wrap(~probe) + theme(axis.text.x=element_text(angle = 90, hjust = 0))





Apex.Data2 <- Apex.Data[4:nrow(Apex.Data),] #remove extra metadata from top
Apex.Data2 <- head(Apex.Data2,-2) #remove extra metadata from bottom

# view data and names to ID the raw probe.name or probe.type or probe.value
Apex.Data2
names(Apex.Data2)

# Column names modified as of 20180707
# Date.Time = column 2
# TMP_T0 = column 6
# pH_T0= column 9
# salinity = column 12
# TMP_T2 = column 66
# pH_T2 = column 69
# TMP_T3 = column 72
# pH_T3 = column 75
# TMP_T1 = column 78
# pH_T1 = column 81
# NOTE: 10 in total above

#keep columnes with data of interest. This needs to be changed as it will be specific to the Apex configuration
Probe.Data <- Apex.Data2[,c(3,6,9,12,66, 69, 72, 75, 78, 81)] #select columns
colnames(Probe.Data ) <- c("Date.Time", "TMP_T0", "pH_T0", "Sal", "TMP_T2", "pH_T2","Temp_T3",
                           "pH_T3", "TMP_T1", "pH_T1")  #rename columns
Probe.Data$Date.Time <- as.POSIXct(Probe.Data$Date.Time, format = "%m/%d/%Y %H:%M:%S", tz="HST") #convert date to HI time
# CHANGE DATE FOR NEW CSV (risk overwritting previous)
write.csv(Probe.Data, "C:/Users/samjg/Documents/Notebook/data/Geoduck_Conditioning/RAnalysis/Data/Apex_data/Output/20180715_Apex_Data_Output.data.csv") #write file to save data

#plot Temp and pH and save to output
# CHANGE DATE FOR NEW PDF (risk overwritting previous)
pdf("C:/Users/samjg/Documents/Notebook/data/Geoduck_Conditioning/RAnalysis/Data/Apex_data/Output/Graphs/20180715_Apex_Output.data.pdf")
par(mfrow=c(2,1))
plot(as.numeric(as.character(TMP_T0)) ~ Date.Time, Probe.Data, col = "grey", type="l", ylim=c(12, 20),  xlab="Time", ylab="Temperature °C")
lines(as.numeric(as.character(TMP_T1)) ~ Date.Time, Probe.Data, col = "red")
lines(as.numeric(as.character(TMP_T2)) ~ Date.Time, Probe.Data, col = "blue")
lines(as.numeric(as.character(Temp_T3)) ~ Date.Time, Probe.Data, col = "black")
axis.POSIXct(side=1, Probe.Data$Date.Time)

plot(as.numeric(as.character(pH_T0)) ~ Date.Time, Probe.Data, col = "grey", type="l", ylim=c(7.1, 8.1),  xlab="Time", ylab="pH NBS")
lines(as.numeric(as.character(pH_T1)) ~ Date.Time, Probe.Data, col = "red")
lines(as.numeric(as.character(pH_T2)) ~ Date.Time, Probe.Data, col = "blue")
lines(as.numeric(as.character(pH_T3)) ~ Date.Time, Probe.Data, col = "black")
axis.POSIXct(side=1, Probe.Data$Date.Time)

# plot(as.numeric(as.character(Salt_XL)) ~ Date.Time, Probe.Data, col = "grey", type="l", ylim=c(20, 35),  xlab="Time", ylab="Salinity psu")
# lines(as.numeric(as.character(Salt_L)) ~ Date.Time, Probe.Data, col = "red")
# lines(as.numeric(as.character(Salt_A)) ~ Date.Time, Probe.Data, col = "blue")
# axis.POSIXct(side=1, Probe.Data$Date.Time)
dev.off()