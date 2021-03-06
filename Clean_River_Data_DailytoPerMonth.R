#for SWALIM datasets before you need to
#1 - change column names to COLLECTIONDATE, Level and Discharge
#2 - eliminate the space (replace all = _/ --> /)
#3  - text to columns - fixed with -> date -> DMY

library(gsheet)
library(lubridate)
library(zoo)
library(rJava)
library(xlsx)
library(plyr)
library(readxl)
options(digits=5)
setwd("~/Desktop")
BW_riverlevel <- read_excel("BW_riverlevel.xlsx")
  col_types = c("date", "text", "text")

#View
(BW_riverlevel)

#rename columns
library(reshape)
BW_riverlevel <- rename(BW_riverlevel, c(COLLECTIONDATE="Date"))

#change date format and create a variable (df) of date
Date<-as.Date(BW_riverlevel$Date, "%m/%d/%y") #ignore the timezone warning
as.numeric(as.character(BW_riverlevel$Level)) #ignore the warnings
Level<-lapply(substr(BW_riverlevel$Level, 1, nchar(BW_riverlevel$Level)-1), FUN = mean)

#install XTS packages
library(xts)
#install.packages("highfrequency")
library(highfrequency)

#convert to XTS
BW_riverlevel_xts=xts(BW_riverlevel, order.by=as.POSIXct(BW_riverlevel$Date, format="%m-d%-%y"))
head(BW_riverlevel_xts) #ignore the timezone thing for now

#remove column from XTS file
BW_riverlevel_xts$Date=NULL

library(dplyr)
library (data.table)

BW_riverlevel$Date <- as.Date( as.Date(BW_riverlevel$Date), "%y-%m-%d")
BW_riverlevel[,2:ncol(BW_riverlevel)] <- sapply(BW_riverlevel[,2:ncol(BW_riverlevel)], as.character)
as.numeric(BW_riverlevel$Level)

#convert Level in XTS numeric values
Levelnumeric= data.matrix(as.data.frame(BW_riverlevel_xts))

#calculate daily to monthly average
monthlyaverage <-apply.monthly(BW_riverlevel_xts$Level, FUN = mean)

#export in excel
write.xlsx(x = monthlyaverage, file = "averagemonthly.xlsx",
           sheetName = "LevelperMonth", row.names = TRUE)

#put monthly values together ~ doing some wrong calculation 
#riverlevel <- aggregate(cbind(Level)~(month(Date)+year(Date)), data=BW_riverlevel_xts$Level, means=rowMeans(Level), FUN =mean, na.rm=TRUE)


#________________ for future/parking lot ------------
#more XTS?
#x <- as.POSIXct(c(Date))
#mo <- strftime(x, "%m")
#yr <- strftime(x, "%Y")
#riverlevel <- runif(n = 1732)

#create df from all the variables
#dd <- data.frame(mo, yr, riverlevel)

#gather per month
#permonth<- aggregate(riverlevel ~ mo + yr, dd, FUN = mean)

#average per day per month
#averagemonth<-aggregate(riverlevel, by=list(MO=mo, YR=yr), mean)


#in case you need to subset per months
#riverlevelJAN <- subset(BW_riverlevel, date > "2010-01-01" & date < "2010-12-31")

#???? do know what it does, but is not working, suppposed to be after line 23
#permonth$Date <- as.POSIXct(paste(permonth$yr, permonth$riverlevel, "01", sep = "-"))

#average all "January's or February's"
#Avg_eachmonth<-aggregate(dd$riverlevel~mo,dd,mean)
