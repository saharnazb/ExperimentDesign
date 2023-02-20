# Random assignment design for an experiment  
We are going to do a controlled experiment where the assignment into treated and control groups is random. Our focus here is not observational studies where assignment into treated and control groups is not random. Through controlled experiment, we manipulate the independent variable(s) and measure the causal effect of such changes on the dependent variable. 
*Example:* effects of a training program on job performance

## Steps to design an experiment:
### 1.	Define variables (control and outcome) and how they are related 
We start with the research question definition: How a training program affects employee performance or employee turnover? 
We should define variables needed: outcome, treatment, and confounders/controls. If our variable is measured with likelihood of an event, the likelihood can be asked in a survey. If any variable is affecting the assignment of each unit/firm to control or treatment group, it should be defined at this level. Its relation should also be defined/determined. (e.g. is this variable increasing or decreasing the probability of assignment into a group). If this is the case (there is a relationship between treatment and one of independent variables), we should consider in the power analysis too. But if the assignment is random, we don’t need it. 

### 2.	Define your testable hypothesis
H0: participation of firms in training program does not correlate with the rate of turnover.
H0: participation of firm in training program does not correlate with the likelihood of turnover.

### 3.	Design your experimental treatment 
Design should be in a way that we can manipulate the independent variables and control confounding variables. This will affect your experiment’s external validity and will increase generalizability of your results. Here, the treatment variable is a dichotomized variable which is equal to 1 if school is treated and 0 otherwise. You might also decide to define treatment in another way, such as the hours the employee participated in the program or the number of absences in the sessions of program. It all depends on the researcher how to define the treatment that (s)he can manipulate systematically and precisely. 

### 4.	Assign subjects (schools) to treatment and control groups
First, we determine the sample size which I did using power analysis with some assumptions that should be considered while designing the experiment. Select a representative sample and account for any factor that might have an impact on the results (potential control variables). If a controlled experiment in which participants are assigned to control and treatment groups is impossible/unethical, consider conducting an observational study. 
Second, randomly assign subjects (firms/schools) to treatment group. If your treatment defined as hours of attendance, to manipulate it, you can have multiple treatment groups (low attendance and high attendance). Control group receives no training. There are two important choices:
1)	Experiment design could be completely random or stratification (randomized within block)  
Here, I am assuming using stratified random design in which subjects are grouped first based on their characteristics. Then, they are assigned randomly into treatment and control inside those blocks/strata using a random number generator. 
2)	Choice of between-subject design vs within-subject design 
This project follows between-subject assignment design in which subjects are assigned to the treatment group randomly and are kept at that group throughout the experiment. 

#### 4.1.	  Stratification 
We plan to conduct an evaluation to compare the impacts of a training program across a subgroup of firms/schools. Then, we can use stratified random sampling which helps us to ensure that different subgroups (e.g. rural, high poverty subgroups) within a population are well-represented in both the sample and the treatment groups.   

**Example: Stratifying the firms/schools:**  
*First Step:* Based on some characteristics, we dichotomize each variable with a median split classifying firms into high and low level of variables. It might be categorized to regions or locales (rural vs. non-rural). 
*Second Step:* Then, we organized the sample into multiple cells (e.g. 4 cells where 2 locale codes × 2 poverty categories).   
*Third Step:* Then, we randomly assigned each firm/school to one of control or treatment groups. For this purpose, we use “randtreat” package in STATA. Through the random assignment using this package, we ensure that the probability of assignment to each group is equal or close to equal as possible while the treatment group and control group are as similar as possible with respect to aforementioned characteristics. If there are misfits, we randomly allocate them.    

### 5.	Define a measurement for your dependent variable 
This is the researcher’s decision how to measure outcome variabel (performance or turnover). You can ask the likelihood of leave from the employees themselves or observe how many of them left and calculate the percent of employees who left the firm/school. Depending on this measurement, your estimation method for calculating the effect size might differ: you might have to use a logit/probit to estimate the likelihood or do a linear regression with the framework of Difference-in-Differences method. 

### A Practice: Testing random assignment 
To test the success of  random assignment, we estimate a logit model with the treatment being the dependent variable and all the variables used for stratification as independent variables. Clearly, none of them are significantly affecting the likelihood of bring treated. We also compare a simple summary statistics of those variables in two groups of control and treatment. We can observe the similarity of two groups. Finally, we can use a Propensity Score Matching (PSM) to match individuals between treatment and control groups based on their propensity scores. That is, propensity score represents the probability of being assigned to the treatment group based on observed covariates. If the assignment was successful, the propensity scores should not significantly differ between the control and treatment groups. Therefore, the matched samples should be well-balanced, the random assignment is successful, and the observed treatment effect can be attributed to the treatment. We may repeat the PSM after the experiment to test the observations and collected data. 

### References
Huber, S., Dietrich, J. F., Nagengast, B., & Moeller, K. (2017). Using propensity score matching to construct experimental stimuli. Behavior Research Methods, 49, 1107-1119.  
https://dimewiki.worldbank.org/Main_Page  
https://www.scribbr.com/methodology/experimental-design/  
https://learning.eupati.eu/mod/book/view.php?id=340&chapterid=262   
https://learning.eupati.eu/mod/book/view.php?id=340&chapterid=257  
