clear
cd "The folder where your project is located"

*================================================================
*             IMPORT AND CLEAN
*================================================================
clear
import excel "Sample.xlsx", sheet("SC") firstrow

* Clean and define the varibales that you need

*================================================================
*             RANDOM ASSIGNMENT USING STRATIFICATION
*================================================================
egen var1_median = median(var1)
egen var2_median = median(var2)
egen var3_median = median(var3)
egen var4_median = median(var4)

gen var1_h = (var1>=var1_median)
label var var1_h "=1 if high"

gen var2_h = (var2>=var2_median)
label var var2_h "=1 if high"

gen var3_h = (var3>=var3_median)
label var var3_h "=1 if high"

gen var4_h = (var4>var4_median)
label var var4_h "=1 if high"

* You can add other categorical variables to the list while stratifying the sample (e.g. rural, town, city)
egen strata = group(var1 var2 var3 var4)
randtreat, gen(treatment) setseed(123456) strata(rural var1 var2 var3 var4) multiple(2) 
* To deal with misfits:
br strata treatment if missing(treatment)
sort strata
* Assume there are 15 misfits
set seed 1234
gen rand_num = runiformint(1, 15) if missing(treatment)
sort rand_num
* If median of rand_num is 8:
replace treatment = 1 if rand_num<8 & missing(treatment)
replace treatment = 0 if rand_num>=8 & missing(treatment)
drop rand_num

save "treatment_assignment.dta", replace

* Another package to do the random assignment (if needed)
h stratarand // install this package

*================================================================
*             TEST RANDOM ASSIGNMENT
*================================================================
logit treatment rural var1 var2 var3 var4
su locale SES wage_indx turnover performance_indx if treatment==1
su locale SES wage_indx turnover performance_indx if treatment==0
h psmatch2
psmatch2 treatment rural var1 var2 var3 var4, outcome(turnover) logit
su _pscore
su _pscore if treatment==1
su _pscore if treatment==0
