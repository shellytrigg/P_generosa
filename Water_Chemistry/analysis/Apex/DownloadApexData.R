#load libraries
library("XML")  
library("plyr")

#set start date, number of days from start date, and IP address variables
startdate <- 181201 #start date of data to download in yymmdd format   
numdays <- 20 #number of days of of data to download  
IPaddress <- "192.168.1.201:80" #this is listed under 'IP Address' in Apex app under the wifi icon. I included this variable because when the internet goes out or routers get reset, the Apex IP address can change.
#retrieve Apex data for specified date range
xmlfile <- xmlParse(paste("http://",IPaddress,"/cgi-bin/datalog.xml?sdate=",startdate,"&days=",numdays, sep="")) 

#convert xml to dataframe
Apex.Data <- ldply(xmlToList(xmlfile), data.frame) 

#set end date variable that will be added to the filename of the exported data
#this code excludes lines of the data which contain NAs in the date column, 
#tells R that the date column is formatted as a date, and finds the max date in the data 
enddate <- max(as.Date(Apex.Data[which(!is.na(Apex.Data$date)),"date"], format = "%m/%d/%Y"))

#save data as csv file
write.csv(Apex.Data, paste("~/Documents/GitHub/P_generosa/Water_Chemistry/data/Apex/Apex_data_",startdate,"-",enddate,".csv"), quote =FALSE, row.names = FALSE)


