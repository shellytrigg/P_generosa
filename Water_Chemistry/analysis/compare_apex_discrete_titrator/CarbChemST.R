#load libraries
library(readxl)
library(LoLinR)


#load data

#load discrete pH, salinity, and temp measurements
discrete <- read.csv("~/Documents/GitHub/P_generosa/Water_Chemistry/Data/Titrator/Daily_Temp_pH_Sal.csv", stringsAsFactors = FALSE)

#### #load tris data###
tris.path <- "~/Documents/GitHub/P_generosa/Water_Chemistry/Data/Titrator/TrisCalibration.xlsx"
#code from: https://stackoverflow.com/questions/12945687/read-all-worksheets-in-an-excel-workbook-into-an-r-list-with-data-frames
read_excel_allsheets <- function(fileName, tibble = FALSE) {
  sheets <- readxl::excel_sheets(fileName)
  x <- lapply(sheets, function(X) readxl::read_excel(fileName, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

sheets <- read_excel_allsheets(tris.path)
list2env(sheets ,.GlobalEnv)

#read from excel datafile
tris <- data.frame()
for(i in 1:length(sheets)){
  dtemp <- data.frame(sheets[i])
  colnames(dtemp) <- c("date", "pH", "mV", "temp")
  tris <- rbind(tris, dtemp)
}

## model each tris curve
uniq_date <- unique(tris$date)
tris.table <- data.frame(matrix(nrow =1, ncol = 5))
colnames(tris.table) <- c("Date", "alpha", "")

pH.cals <- data.frame(matrix(NA, nrow=length(uniq_date), ncol=3))
colnames(pH.cals) <- c("Date", "Intercept", "Slope","Rsquared") #generate a 3 column dataframe with specific column names
for (i in 1:length(uniq_date)){
  model <- rankLocReg(xall = tris[which(tris$date == uniq_date[i]),"mV"], yall = tris[which(tris$date == uniq_date[i]),"temp"], alpha = 0.4, method = "pc", verbose = TRUE)
  sum.table <- summary(model)
  pdf(paste0("~/Documents/GitHub/P_generosa/Water_Chemistry/analysis/titrator/tris_plots_alpha0.4_",uniq_date[i],"_regression.pdf"))
  plot(model)
  dev.off()
  
  model_lm <-lm(mV ~ temp, data=tris[which(tris$date == uniq_date[i]),]) #runs a linear regression of mV as a function of temperature
  coe <- coef(model_lm) #extracts the coeffecients
  rsq <- summary(model_lm)$r.squared
  #plot(Calib.Data$mVTris, Calib.Data$TTris)
  pH.cals$Rsquared[i] <- rsq
  pH.cals[i,2:3] <- coe #inserts them in the dataframe
  pH.cals$Date[i] <- uniq_date[i] #stores the file name in the Date column
}



mvTris <- SW.chem$Temperature*SW.chem$Slope+SW.chem$Intercept #calculate the mV of the tris standard using the temperature mv relationships in the measured standard curves 
STris<-34.5 #salinity of the Tris
phTris<- (11911.08-18.2499*STris-0.039336*STris^2)*(1/(SW.chem$Temperature+273.15))-366.27059+ 0.53993607*STris+0.00016329*STris^2+(64.52243-0.084041*STris)*log(SW.chem$Temperature+273.15)-0.11149858*(SW.chem$Temperature+273.15) #calculate the pH of the tris (Dickson A. G., Sabine C. L. and Christian J. R., SOP 6a)
SW.chem$pH.Total<-phTris+(mvTris/1000-SW.chem$pH.MV/1000)/(R*(SW.chem$Temperature+273.15)*log(10)/F) #calculate the pH on the total scale (Dickson A. G., Sabine C. L. and Christian J. R., SOP 6a)
