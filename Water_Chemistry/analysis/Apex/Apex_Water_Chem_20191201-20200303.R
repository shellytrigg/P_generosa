#load libraries
library("XML")
library("plyr")
library("tidyr")
library("ggplot2")
```

```{r, eval = FALSE}
#read in the date plus x days of Apex data
xmlfile <- xmlParse("http://192.168.1.100:80/cgi-bin/datalog.xml?sdate=191201&days=90")

#convert xml to dataframe
Apex.Data <- ldply(xmlToList(xmlfile), data.frame)

#output the Apex data to a csv file; this is to make a copy of the raw data
write.csv(Apex.Data, "~/Documents/GitHub/P_generosa/Water_Chemistry/data/Apex/Apex_data_20191201-20200303.csv", quote =FALSE, row.names = FALSE)
