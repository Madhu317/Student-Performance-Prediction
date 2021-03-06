


## PACKAgeS AND LIBRARIES


#install.packAges("class")
#install.packAges("gmodels")
#install.packAges("caret")
#install.packAges("readr")
#install.packAges("ggplot2")
#install.packAges("GGally")


library(gmodels)
library(caret)
library(class)
library(readr)
library(ggplot2)
library(dplyr)
library(GGally)
library(scales)
library(MASS)
library(nnet)
library(caret)
```



## DATA LOAD

 

StudentData <- read.csv('studentData.csv')

StudentDataBackup <- read.csv('studentData.csv')

StudentData[duplicated(StudentData),] # No duplicates

colnames(StudentData) <- c('School','Sex','Age','Address','FamilySize','ParentsMaritalStatus','MothersEducation','FathersEducation','MothersJob','FathersJob','ReasonToChooseSchool','Guardian','TravelTime','StudyTime','Failures','SchoolSupport','FamilySupport','PaidClasses','Activities','Nursery','HigherEducationInterest','InternetAcess','RomanticRelationship','FamilyRelationship','FreeTime','GoingOut','WorkdayAlcohol','WeekendAlcohol','Health','Absences','FirstPeriodGrade','SecondPeriodGrade','FinalGrade') #,'Subject','AverAgeGrade')

colnames(StudentDataBackup) <- c('School','Sex','Age','Address','FamilySize','ParentsMaritalStatus','MothersEducation','FathersEducation','MothersJob','FathersJob','ReasonToChooseSchool','Guardian','TravelTime','StudyTime','Failures','SchoolSupport','FamilySupport','PaidClasses','Activities','Nursery','HigherEducationInterest','InternetAcess','RomanticRelationship','FamilyRelationship','FreeTime','GoingOut','WorkdayAlcohol','WeekendAlcohol','Health','Absences','FirstPeriodGrade','SecondPeriodGrade','FinalGrade') #,'Subject','AverAgeGrade')


#Adding a new column -"GradeClassified" that includes the final grades classified into three categories:
#Above averAge - classification for final grades between 15 and 20 
#Below averAge - classification for final grades between 0 and 9 
#AverAge - classification for final grades between 10 and 14 


StudentData$GradeClassified <- ifelse(StudentData$FinalGrade<10,"BelowAverAge",
                                      ifelse((StudentData$FinalGrade>=10 & StudentData$FinalGrade<=15),"AverAge","AboveAverAge"))

#Convert GradeClassified as a factored variable with only 3 levels - Above AverAge, averAge and below averAge

StudentData$GradeClassified <- as.factor(StudentData$GradeClassified)





## DATA EXPLORATION

# Here we are slicing, dicing and factorising the data in various level for better analysis and also plotting them with each other and the response variable to understand the data in a better way


# AverAge Grades
StudentData$AverAgeGrades <- round(rowMeans(cbind(StudentData$FirstPeriodGrade, StudentData$SecondPeriodGrade, StudentData$FinalGrade)),2)

# No. of students drinking on Weekday and weekend 
StudentData$WorkdayAlcohol<- as.factor(StudentData$WorkdayAlcohol)      
StudentData$WorkdayAlcohol <- factor(StudentData$WorkdayAlcohol,labels=c("Very Low", "Low", "Medium", "High", "Very High"))

plot(StudentData$WorkdayAlcohol)


StudentData$WeekendAlcohol <- as.factor(StudentData$WeekendAlcohol)      
StudentData$WeekendAlcohol <- factor(StudentData$WeekendAlcohol,labels=c("Very Low", "Low", "Medium", "High", "Very High"))

plot(StudentData$WeekendAlcohol)

ggcorr(StudentData,label = TRUE,label_alpha = TRUE, hjust = 0.75, size = 2)







# Question - Does number of Failures affect your grades?
ggplot(StudentData, aes(x=Failures, y=AverAgeGrades, color=Sex))+
  geom_jitter(alpha=0.7) +
  theme_bw() +
  xlab("Number of Failures") +
  ylab("AverAge grades")
# Observation -  As number of Failures increases, grades decrease 


# Question - Does number of Failures affect your grades?
ggplot(StudentData, aes(x=as.factor(HigherEducationInterest),y=AverAgeGrades, color=Sex))+
  geom_jitter(alpha=0.7) +
  theme_bw() +
  xlab("Number of Failures") +
  ylab("AverAge grades")
# Observation -  As number of Failures increases, grades decrease 


# Question - How does mother's education affect the grades?
ggplot(StudentData, aes(x=as.factor(MothersEducation), y=as.numeric(AverAgeGrades), fill=MothersEducation))+
  geom_boxplot()
# Observation - Grades are better if mother is educated


# Question - How does travel time affect the grades?
ggplot(StudentData, aes(x=as.factor(TravelTime), y=as.numeric(AverAgeGrades), fill=TravelTime))+
  geom_boxplot()
# Observation - Grades gets worse with increase in travel time 




# Question - How does going out affect the study time?
ggplot(aes(as.numeric(GoingOut), as.numeric(StudyTime)), data = StudentData) +
  geom_jitter() +
  geom_smooth(se = FALSE, method = 'lm') +
  xlab("Frequency of Going Out with Friends") +
  ylab("Time Spent Studying")
# Observation - Going out with friends will lead to lessening of study time




# Some other random observations
ggplot(StudentData, aes(x=as.factor(ParentsMaritalStatus), y=AverAgeGrades)) + 
  geom_boxplot(fill="slateblue", alpha=0.2) + 
  xlab("parent's cohabitation status ")



ggplot(StudentData, aes(x=FreeTime, y=AverAgeGrades)) + 
  geom_point()



ggplot(StudentData, aes(x=WorkdayAlcohol, y=AverAgeGrades)) + geom_point()
ggplot(StudentData, aes(x=as.factor(WorkdayAlcohol), y=AverAgeGrades)) + 
  geom_boxplot(fill="slateblue", alpha=0.2) 






#Question - What is the overall grade distribution of the students?

NumberOfStudents <- as.data.frame(sort(table(StudentData$GradeClassified, dnn = 'GradeClassified'), decreasing = T),responseName = 'NumberOfStudents')

ggplot(aes(x= reorder(GradeClassified,NumberOfStudents), y = (NumberOfStudents/sum(NumberOfStudents)), fill = GradeClassified), data = NumberOfStudents) +
  geom_bar(stat = 'identity') +
  geom_text(stat='identity', aes(label = percent((NumberOfStudents)/sum(NumberOfStudents))),
            data = NumberOfStudents, hjust = 0.5,vjust=-0.5) +
  theme(axis.text = element_text(size = 12,face = "bold")) +
  xlab("GradeClassified") +
  ylab("Percentage of Students") + 
  ggtitle("Percentage of Students in the Grade classified categories")
# Observation - Maximum students lie in the Average Grade category with 66% ratio followed by below average and above average



#Question - How does a romantic relationship affects the grade ?
ggplot(aes(x=GradeClassified, fill = RomanticRelationship),
       data = StudentData) +
  geom_histogram(stat = "count", position=position_dodge()) +
  xlab("Grade Category") +
  ylab("Number of students") + 
  ggtitle("Relationship of grade classified with a Student's Romantic Relationship")
# Observation - Students not involved in romantic relationships tends to score than the ones who are in it.


# How does the intake of alcohol during the weekend affect the grade
StudentData$WeekendAlcohol <- as.factor(StudentData$WeekendAlcohol)
ggplot(aes(x=GradeClassified, fill = WeekendAlcohol),
       data = StudentData) +
  geom_histogram(stat = "count", position=position_dodge()) + 
  xlab("Grade Category") +
  ylab("Number of students") + 
  ggtitle("Relationship of grade classified with a Student's weekend alcohol consumption ")
# Observation - Students into high level of weekend alcohol intake tends to score much less


# Better visualization of the above problem with geom point
ggplot(aes(x=WeekendAlcohol, y = GradeClassified, color = GradeClassified),
       data = StudentData) +
  geom_point(alpha = 0.5, position="jitter") + 
  scale_colour_brewer(palette = 'Set1') +
  theme_bw() + theme(legend.key = element_blank()) +
  xlab("Weekend alcohol") +
  ylab("Grade Category") + 
  ggtitle("Relationship of Final grade with weekend alcohol consumption ")



# Checking the dependency of Grade classified with Weekeend Alcohol consumption using Chi-Square Test
chisq.test(StudentData$GradeClassified,StudentData$WeekendAlcohol)
# P-Value is less than the significant value so the null hypothesis should be rejected and conclude that grades are affected by weekend alcohol pattern


# Are Grade classified and Mother's Education related?
StudentData$MothersEducation <- as.factor(StudentData$MothersEducation)

ggplot(aes(x=GradeClassified, fill = MothersEducation),
       data = StudentData) +
  geom_histogram(stat = "count", position=position_dodge()) +
  xlab("Grade Category") +
  ylab("Number of students") + 
  ggtitle("Relationship of grade classified with a Student's Mother's Education")
# Not a clear pattern here for all the level of grades, though mothers of students with above average grade are more educated

# Above problem in different visualization
ggplot(aes(y=MothersEducation, x = GradeClassified, color = GradeClassified),
       data = StudentData) +
  geom_point( alpha = 1, position="jitter") + 
  scale_colour_brewer(palette = 'Set2') +
  theme_bw() + theme(legend.key = element_blank()) +
  ylab("Mothers Education") +
  xlab("Grade Category") + 
  ggtitle("Relationship of Final grade with a Student's Mother's Education ")


# Question - What is the relationship of number of failures and grade score by a student?
StudentData$Failures <- as.factor(StudentData$Failures)
ggplot(aes(x=GradeClassified, fill = Failures),
       data = StudentData) +
  geom_histogram(stat = "count", position=position_dodge()) + 
  xlab("Grade Category") +
  ylab("Number of students") + 
  ggtitle("Relationship of grade classified with a Student's Failures ")
# Observation - students with no or less failure tends to score better grades

# Another visualization for above problem
ggplot(aes(y=Failures, x = GradeClassified, color = GradeClassified),
       data = StudentData) +
  geom_point(alpha = 0.5, position="jitter") + 
  theme_bw() + theme(legend.key = element_blank()) +
  scale_colour_brewer(palette = "Set1") +
  xlab("Grade categoryl") +
  ylab("Failures") + 
  ggtitle("Relationship of Final grade with a Student's Failure ")



# Question - How does going out pattern affect the grades?
StudentData$GoingOut <- as.factor(StudentData$GoingOut)

ggplot(aes(x=GradeClassified, fill = GoingOut),
       data = StudentData) +
  geom_histogram(stat = "count", position=position_dodge()) +
  xlab("Grade Category") +
  ylab("Number of students") + 
  ggtitle("Relationship of grade classified with a Student Going Out ")
# Observation - Not a specific pattern here



#Question - What is the grade of the students who aspire for higher education?
ggplot(aes(x=GradeClassified, fill =HigherEducationInterest),
       data = StudentData) +
  geom_histogram(stat = "count", position=position_dodge()) +
  xlab("Grade Category") +
  ylab("Number of students") + 
  ggtitle("Relationship of grade classified with Higher Education interest ")
# Observation - Almost all the students with good grades aspire for higher studies



# Another visualization for above problem
ggplot(aes(x=HigherEducationInterest, y = GradeClassified, color = GradeClassified),
       data = StudentData) +
  geom_point(alpha = 0.5, position="jitter") + 
  theme_bw() + theme(legend.key = element_blank()) +
  scale_colour_brewer(palette = 'Set2') +
  xlab("HigherEducation Interest") +
  ylab("Grade Category") + 
  ggtitle("Relationship of grade classified with Higher Education Interest ")





######################################################################
## FIRST MODEL -  MULTIPLE LINEAR REGRESSION METHOD IMPLEMENTATION  ##
######################################################################





StudentData1 <- StudentData[c("Age","MothersEducation", "FathersEducation", "TravelTime", "StudyTime", "Failures",
                              "FamilyRelationship","FreeTime", "WeekendAlcohol", "WorkdayAlcohol", "GoingOut", "Health","Absences")]

unique(sort(StudentData$RomanticRelationship))

StudentData1$School.gp <- ifelse(StudentData$School == "GP",1,0) # GP = 1, MS = 0 
StudentData1$HigherEducationInterest.yes <- ifelse(StudentData$HigherEducationInterest == "yes",1,0) # yes = 1, no = 0 
StudentData1$ParentsMaritalStatus.T <- ifelse(StudentData$ParentsMaritalStatus == "T",1,0) # Together = 1, Apart = 0 
StudentData1$InternetAcess.yes <- ifelse(StudentData$InternetAcess == "yes",1,0) # yes = 1, no = 0 
StudentData1$Sex.F <- ifelse(StudentData$Sex == "F",1,0)  # F = 1, M = 0 
StudentData1$Address.R <- ifelse(StudentData$Address == "R",1,0)  # R = 1, U = 0 
StudentData1$FamilySize.GT3 <- ifelse(StudentData$FamilySize == "GT3",1,0)  # GT3 = 1, LE3 = 0 
StudentData1$SchoolSupport.yes <- ifelse(StudentData$SchoolSupport == "yes",1,0) # yes = 1, no = 0 
StudentData1$FamilySupport.yes <- ifelse(StudentData$FamilySupport == "yes",1,0) # yes = 1, no = 0 
StudentData1$PaidClasses.yes <- ifelse(StudentData$PaidClasses == "yes",1,0) # yes = 1, no = 0 
StudentData1$Activities.yes <- ifelse(StudentData$Activities == "yes",1,0) # yes = 1, no = 0 
StudentData1$Nursery.yes <- ifelse(StudentData$Nursery == "yes",1,0) # yes = 1, no = 0 
StudentData1$RomanticRelationship.yes <- ifelse(StudentData$RomanticRelationship == "yes",1,0) # yes = 1, no = 0 



StudentData1$Guardian.M <- ifelse(StudentData$Guardian == "mother",1,0) # Mother = 1, Other = 0 
StudentData1$Guardian.F <- ifelse(StudentData$Guardian == "father",1,0) # Father = 1, Other = 0 


StudentData1$ReasonToChooseSchool.course <- ifelse(StudentData$ReasonToChooseSchool == "course",1,0)
StudentData1$ReasonToChooseSchool.home <- ifelse(StudentData$ReasonToChooseSchool == "home",1,0)
StudentData1$ReasonToChooseSchool.reputation <- ifelse(StudentData$ReasonToChooseSchool == "reputation",1,0)

StudentData1$MothersJob.athome <- ifelse(StudentData$MothersJob == "at_home",1,0)
StudentData1$MothersJob.Health <- ifelse(StudentData$MothersJob == "Health",1,0)
StudentData1$MothersJob.services<-ifelse(StudentData$MothersJob == "services",1,0)
StudentData1$MothersJob.teacher<- ifelse(StudentData$MothersJob == "teacher",1,0)

StudentData1$FathersJob.athome <- ifelse(StudentData$FathersJob == "at_home",1,0)
StudentData1$FathersJob.Health <- ifelse(StudentData$FathersJob == "Health",1,0)
StudentData1$FathersJob.services<-ifelse(StudentData$FathersJob == "services",1,0)
StudentData1$FathersJob.teacher<- ifelse(StudentData$FathersJob == "teacher",1,0)

StudentData1$AverAgeGrades <- StudentData$AverAgeGrades


StudentData2 <- StudentData1


##### MODEL 1 #############################
model1 <- lm(AverAgeGrades ~ ., data = StudentData2)
summary(model1)

StudentData2$FathersJob.Health <- NULL
StudentData2$FathersJob.teacher <- NULL
StudentData2$MothersJob.athome <- NULL
StudentData2$Nursery.yes <- NULL

##### MODEL 2 #############################
model2 <- lm(AverAgeGrades ~ ., data = StudentData2)
summary(model2)

StudentData2$FathersJob.athome <- NULL
StudentData2$ReasonToChooseSchool.home <- NULL
StudentData2$Sex.F <- NULL
StudentData2$ParentsMaritalStatus.T <- NULL

##### MODEL 3 #############################
model3 <- lm(AverAgeGrades ~ ., data = StudentData2)
summary(model3)

StudentData2$Age <- NULL
StudentData2$FreeTime <- NULL
StudentData2$WeekendAlcohol <- NULL
StudentData2$Activities.yes <- NULL
StudentData2$Guardian.F <- NULL

##### MODEL 4 #############################
model4 <- lm(AverAgeGrades ~ ., data = StudentData2)
summary(model4)

StudentData2$TravelTime <- NULL
StudentData2$ReasonToChooseSchool.course <- NULL
StudentData2$MothersJob.teacher <- NULL


##### MODEL 5 #############################
model5 <- lm(AverAgeGrades ~ ., data = StudentData2)
summary(model5)

StudentData2$WorkdayAlcohol <- NULL
StudentData2$ReasonToChooseSchool.reputation <- NULL
StudentData2$Absences <- NULL
StudentData2$FamilyRelationship <- NULL


##### MODEL 6 #############################
model6 <- lm(AverAgeGrades ~ ., data = StudentData2)
summary(model6)

StudentData2$FathersEducation <- NULL
StudentData2$FamilySupport.yes <- NULL
StudentData2$Guardian.M <- NULL
StudentData2$Address.R <- NULL

##### MODEL 7 #############################
model7 <- lm(AverAgeGrades ~ ., data = StudentData2)
summary(model7)

StudentData2$InternetAcess.yes <- NULL
StudentData2$FamilySize.GT3 <- NULL
StudentData2$FathersJob.services <- NULL


##### MODEL 8 #############################
model8 <- lm(AverAgeGrades ~ ., data = StudentData2)
summary(model8)

# MODEL 8 has R-squared as 0.265 and proves to have significant values in it. Refer analysis.xlsx





#######################################################
## SECOND MODEL -  MULTINOMIAL LINEAR REGRESSION     ##
#######################################################

#---------------------------------------------------------------------------------------------------------------------------------


# Creating testing and Training Data using random sampling.

set.seed(100)

TrainingDataRows <- sample(1:nrow(StudentData), 0.5*nrow(StudentData))
TrainingData <- StudentData[TrainingDataRows,]
TestingData <- StudentData[-TrainingDataRows,]


library(MASS)


#Working with the multinominal model, Model 1 is a full model that includes all the data columns

library(nnet)

Model1 <- multinom(GradeClassified ~. , data = TrainingData)
summary(Model1)

library(caret)

# Predicting our model 1

Prediction = predict(Model1, newdata=TestingData)
Accuracy <- table(Prediction, TestingData[,"GradeClassified"])
sum(diag(Accuracy))/sum(Accuracy)
confusionMatrix(data=Prediction, TestingData$GradeClassified)

#From the accuracy calculation, it has predicted the grade calssified  at rate of 92%. The confusion matrix identified the wrongly predicted grades
#We shouldnt probably consider this since this includes the Final grade column with which we derived our Grade classified

# model 2 multinominal , reduced model 

Model2 <- multinom(GradeClassified ~ MothersEducation +RomanticRelationship + WeekendAlcohol  +  GoingOut +
                     HigherEducationInterest + MothersEducation  + StudyTime + InternetAcess + Health  , data = TrainingData)




# Predicting our model 2 

Prediction2 = predict(Model2, newdata=TestingData)
Accuracy <- table(Prediction2, TestingData[,"GradeClassified"])
sum(diag(Accuracy))/sum(Accuracy)
confusionMatrix(data=Prediction2, TestingData$GradeClassified)

#From the accuracy calculation, it has predicted the grade calssified  at rate of 67%. The confusion matrix identified the wrongly predicted grades which is HigherEducationInterest compared to Model 2

#Model 3 - adding  more variables 

Model3 <- multinom(GradeClassified ~ Address + FathersEducation + TravelTime + Failures + SchoolSupport + MothersEducation +RomanticRelationship + WeekendAlcohol  +  GoingOut +
                     HigherEducationInterest + MothersEducation  + StudyTime + InternetAcess + Health +FreeTime + WorkdayAlcohol  , data = TrainingData)






##############################
## THIRD MODEL - KNN METHOD ##
##############################




StudDataChunk1 <- StudentDataBackup

# Converting categorical into numerical values

unique(sort(StudentDataBackup$school))

StudDataChunk1$Sex <-  as.numeric(factor(StudDataChunk1$Sex, 
                                         levels=c("F","M")))


StudDataChunk1$Address <-  as.numeric(factor(StudDataChunk1$Address, 
                                             levels=c("R","U")))

StudDataChunk1$ParentsMaritalStatus <-  as.numeric(factor(StudDataChunk1$ParentsMaritalStatus, 
                                                          levels=c("A","T")))

StudDataChunk1$FamilySize <-  as.numeric(factor(StudDataChunk1$FamilySize, 
                                                levels=c("GT3","LE3")))

StudDataChunk1$School <-  as.numeric(factor(StudDataChunk1$School, 
                                            levels=c("GP","MS")))

StudDataChunk1$MothersJob <-  as.numeric(factor(StudDataChunk1$MothersJob, 
                                                levels=c("at_home","health","other","services","teacher")))

StudDataChunk1$FathersJob <-  as.numeric(factor(StudDataChunk1$FathersJob, 
                                                levels=c("at_home","health","other","services","teacher")))

StudDataChunk1$ReasonToChooseSchool <-  as.numeric(factor(StudDataChunk1$ReasonToChooseSchool, 
                                                          levels=c("course","home","other","reputation")))

StudDataChunk1$Guardian <-  as.numeric(factor(StudDataChunk1$Guardian, 
                                              levels=c("father","mother","other" )))

StudDataChunk1$SchoolSupport <-  as.numeric(factor(StudDataChunk1$SchoolSupport, 
                                                   levels=c("no","yes")))

StudDataChunk1$FamilySupport <-  as.numeric(factor(StudDataChunk1$FamilySupport, 
                                                   levels=c("no","yes")))

StudDataChunk1$PaidClasses <-  as.numeric(factor(StudDataChunk1$PaidClasses, 
                                                 levels=c("no","yes")))

StudDataChunk1$Activities <-  as.numeric(factor(StudDataChunk1$Activities, 
                                                levels=c("no","yes")))

StudDataChunk1$Nursery <-  as.numeric(factor(StudDataChunk1$Nursery, 
                                             levels=c("no","yes")))

StudDataChunk1$HigherEducationInterest <-  as.numeric(factor(StudDataChunk1$HigherEducationInterest, 
                                                             levels=c("no","yes")))

StudDataChunk1$InternetAcess <-  as.numeric(factor(StudDataChunk1$InternetAcess, 
                                                   levels=c("no","yes")))

StudDataChunk1$RomanticRelationship <-  as.numeric(factor(StudDataChunk1$RomanticRelationship, 
                                                          levels=c("no","yes")))

StudDataChunk1$AverAgeGrade <- round(rowMeans(cbind(StudDataChunk1$FirstPeriodGrade, StudDataChunk1$SecondPeriodGrade, StudDataChunk1$FinalGrade)),2)


StudDataChunk1$GradeClassified <- ifelse(StudDataChunk1$AverAgeGrade<12,"Fail","Pass")


StudDataChunk2 <- StudDataChunk1

# Function to Normalize the data


Normalize <- function(x) {
  return((x - min(x))/ (max(x) -  min(x)))
}

# Normalising the student performance data

StudData_Norm <-  as.data.frame(lapply(StudDataChunk2[,c(1:30)], Normalize))
StudData_Norm$GradesClassified <- StudDataChunk2$GradeClassified


# Sampling rows out of it & Training the model - 80% train and 20% testing


set.seed(1234)
index=sample(1:2, length(StudDataChunk2$GradeClassified),replace= T, prob = c(.8,.2))

StudData_train <- StudData_Norm[index==1,]
StudData_test  <- StudData_Norm[index==2,]


PredictedModel <- knn(train = StudData_train[,1:30], test = StudData_test[,1:30],
                      cl = StudData_train$GradesClassified, k=21)

# Evaluating the model

CrossTable(x = StudData_test$GradesClassified, y= PredictedModel, prop.chisq = FALSE)

##   k	 Fail	Pass	Match	TOTAL	ACCURACY
##   20	 76	  69	  145	  218	  0.7005
##   25	 72	  68	  140	  218	  0.6763
##   28	 65	  71	  136	  218	  0.6570
##   21	 76	  71	  147	  218	  0.7053 ****
##   22	 72	  69	  141	  218	  0.6812
##   19	 74	  69	  143	  218	  0.6908
