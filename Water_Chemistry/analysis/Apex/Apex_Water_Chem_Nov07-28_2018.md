Apex\_Water\_Chem\_Nov12-29
================
Shelly Trigg
11/28/2018

``` r
#load libraries
library("XML")
```

    ## Warning: package 'XML' was built under R version 3.4.4

``` r
library("plyr")
library("tidyr")
```

    ## Warning: package 'tidyr' was built under R version 3.4.4

``` r
library("ggplot2")
```

    ## Warning: package 'ggplot2' was built under R version 3.4.4

``` r
#read in the date plus x days of Apex data
xmlfile <- xmlParse("http://192.168.1.100:80/cgi-bin/datalog.xml?sdate=181107&days=21")

#convert xml to dataframe
Apex.Data <- ldply(xmlToList(xmlfile), data.frame)

#output the Apex data to a csv file; this is to make a copy of the raw data
write.csv(Apex.Data, "~/Documents/GitHub/P_generosa/Water_Chemistry/Apex_data_20181107-20181128.csv", quote =FALSE, row.names = FALSE)
```

``` r
#read in the csv file
Apex.Data <- read.csv("~/Documents/GitHub/P_generosa/Water_Chemistry/Apex_data_20181107-20181128.csv", stringsAsFactors = FALSE)

#remove uninformative rows and columns
Apex.Data <- Apex.Data[-c(1:3),-c(1:2,grep("type", colnames(Apex.Data)))]

#make a data frame of just probe names
Apex.Data.probe <- Apex.Data[,c(1,grep("name", colnames(Apex.Data)))]
#make a data frame of just probe values
Apex.Data.val <- Apex.Data[,c(1,grep("value", colnames(Apex.Data)))]
#reshabe data frames into long format
Apex.Data.probe <- gather(Apex.Data.probe, probe_name, value ,-1)
Apex.Data.val <- gather(Apex.Data.val, value2, value ,-1)
#recombine probe name and value long data frames
Apex.Data <- cbind(Apex.Data.probe[,-2], Apex.Data.val[,3])
#extract pH, salt, oxygen, and temperature data
Apex.Data <- Apex.Data[grep("pH|Tmp|Salt|ORP", Apex.Data$value),]
#convert date/time from character to POSIX so R will read it as a date
Apex.Data$date <- as.POSIXct(strptime(Apex.Data$date, "%m/%d/%Y %H:%M:%S"))
#rename columns
colnames(Apex.Data) <- c("date", "probe", "value")
#Probe 'Tmpx6' and 'pHx6' were renamed to 'Tmp-2' and 'pH-2' so rename them in the data to reflect that
Apex.Data$probe <- gsub("x6", "_2", Apex.Data$probe)
#replace the hyphen in 'Tmp-2' and 'pH-2' with an underscore
Apex.Data$probe <- gsub("-","_", Apex.Data$probe)
#Probe 'Tmp' was renamed to 'Tmp_1' so rename it in the data to reflect that
Apex.Data$probe <- gsub("^Tmp$", "Tmp_1", Apex.Data$probe)
#Probe 'pH' was renamed to 'pH_1' so rename it in the data to reflect that
Apex.Data$probe <- gsub("^pH$", "pH_1", Apex.Data$probe)
```

Plotting daily pH variability in ambient treatments Feeding typically happens sometime between 8-10am and 4-6pm. The tanks are cleaned (emptied, sprayed, and refilled) on Fridays (Nov. 2 and 9) and possibly some other days. Apex records data every 10 minutes.

### Daily pH variability

![](Apex_Water_Chem_Nov12-29_2018_files/figure-markdown_github/unnamed-chunk-5-1.png) I excluded feeding times to get a better sense of daily pH variability. ![](Apex_Water_Chem_Nov12-29_2018_files/figure-markdown_github/unnamed-chunk-6-1.png)

![](Apex_Water_Chem_Nov12-29_2018_files/figure-markdown_github/unnamed-chunk-7-1.png)

![](Apex_Water_Chem_Nov12-29_2018_files/figure-markdown_github/unnamed-chunk-8-1.png)

![](Apex_Water_Chem_Nov12-29_2018_files/figure-markdown_github/unnamed-chunk-9-1.png) ![](Apex_Water_Chem_Nov12-29_2018_files/figure-markdown_github/unnamed-chunk-10-1.png)
