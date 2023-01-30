
/*
===============================================================================
Power analysis with simulation for finding sample size (DiD estimation model)
===============================================================================

I calculated effect size in R:
esc_beta(beta = -0.09,   # standardized regression coefficient = (b*Sx)/Sy = (-0.05*0.50)/0.26
           sdy = 0.29,    # St.D. of predicted variable y; SE = sd/SQR(n) --> sd = SE * SQR(n) = 0.03*SQR(91) = 0.29
           grp1n = 41,    # Number of treated schools
           grp2n = 50,    # Number of control schools
           es.type = "d") # convert to SMD

This is the result:
Effect Size Calculation for Meta Analysis

     Conversion: standardized regression coefficient to effect size d
    Effect Size:  -0.1796
 Standard Error:   0.2111
       Variance:   0.0446
       Lower CI:  -0.5934
       Upper CI:   0.2342
         Weight:  22.4379

*/

/*
===============================================================================
1. Assumptions:
	- I assume there is single level in data: schools. We can augment state, district or other levels in data generating process (DGP) if needed.
	- Schools are tracked before and after treatment (Panel data)
	- Assignment to treated and control groups is assumed to be random. 
	- Treatment happens at school level in the median year of total sample (mid-period under study; median of `T'). 
	- We could add other covariates: Socioeconomic Status (SES), region variable (Locals of urban and rural), school size, etc. I am packing them all in one control variable. Uncomment any variable that is needed. We need to know what part of variation in y or teacher turnover is coming from each of these variables.

2. Start data generation with top level of the data hierarchy
	- Start from district if we need to cluster schools in districts.
	- I only have one level: school/principal
3. Create variables for the level ID and its random effect. 
4. Expand the data.
5. Repeat steps 3 and 4 until the bottom level is reached.
6. Start coding a function for estimation of a DID and mixed models.
7. Start Coding iteration.
8. Run the code and get results.
===============================================================================
*/


*ssc install egenmore // uncomment if needed. Some commands in this code might not work without this.

set seed 10000 

*=====================================
* Data Creation Function
*=====================================
capture program drop create_data
program define create_data 
	/* =====================================
	   Set the number of observations
	   =====================================*/
		local NS = `1'  // number of schools; first thing typed after the name of the program while using it
		local T = `2'  // time dimention of the panel; second thing after the name of the program
		local effect = `3' // effect; third thing after the name of the program
	
	/* =====================================
	   Create panel (ID and Time)
	   =====================================*/	
		clear
	
		*local obs = `NS'*`T'
		set obs `NS' // The number of observations that we want
	
		gen id = _n // schools
		expand `T'
		bysort id: generate t = _n // time - years
	
	/* =====================================
	   Create fixed effects 
	   =====================================*/	
		gen temp = rnormal() // temporary variable used to create individual FE
		bysort id: egen SFE = first(temp) // indivudal FE; School FE
		drop temp
		
		gen temp = rnormal()
		bysort t: egen TFE = first(temp) // time FE
		drop temp 

	/* =====================================
	   Create treatment 
	   =====================================*/	
		gen treated = runiformint(0,1) if t==`T'
		forvalues i = 1(1)`T'{
			bysort id: replace treated = treated[_n+1] if missing(treated)
		}
		
		bysort id: egen temp = median(t)
		gen treat_time = (t>=temp)
		drop temp
	
		/* or
		gen treat_time = 0 if t<floor(`T'/2)
		replace treat_time = 1 if missing(treat_time)
		*/
		
	/* =====================================
	   Create independent variables
	   =====================================*/	 
		gen controls = rnormal() // I packed all control variables in one variable 
		* gen X0 = rnormal(0.48, 0.14) // %FreeLunch
		* gen X1 = runiform(0,1) // SES - based on %FreeLunch
		* gen X2 = runiformint(0,1) // Locales: Urban (=0) and Rural (=1) only 
		* gen X3 = runiformint(0,1) // Gender
		* gen X4 = runiformint(0,1) <0.2 // %Minority Status
		* gen X5 = rnormal(313,153) // SchoolSize
		* gen X6 = rnormal(430,13) // reading
		* gen X7 = rnormal(427,10) // math
		
	/* =====================================
	   Create error term
	   =====================================*/	
		gen temp = rnormal() // temporary variable used to create individual FE
		bysort id: egen C = first(temp) // indivudal FE; Clusters
		drop temp
		gen eps = C + rnormal(0,0.20) // error term has two components: the individual cluster SFE and the individual-and-time-varying element (rnormal()) The variation in Y not coming from treatment and controls

	/* =====================================
	   Create outcome variable Y
	   =====================================*/
		gen Y = TFE + SFE + `effect'*treated*treat_time + 0.15*controls + eps // defined using the model in page 324 

end

*=====================================
* Estimation Function
*=====================================
*h xtmixed
*xtmixed Y T X1 X2 i.time || group: X2, vce(robust) mle

capture program drop est_model
program define est_model
	local NS = `1'  
	local T = `2' 
	local effect = `3'
    
	* Use the DGP function to create data
    create_data `NS' `T' `effect'
    
    * Model
	xtset id t
    xtreg Y i.treated##i.treat_time controls i.t, fe vce(robust)
	
end

*=====================================
* Iteration Function
*=====================================
capture program drop iterate
program define iterate
    local NS = `1'
    local T = `2'
    local effect = `3'
    local iters = `4'
    
    quietly {
        * Parent data to store results 
        clear
        set obs `iters'
        gen sig_results = . // store results of significance 
		gen coef_results = . // store coefficients 
        
        forvalues i = 1(1)`iters' {
            * Keep track of progress
            if (mod(`i',100) == 0) {
                display `i'
            }
            
            preserve
            est_model `NS' `T' `effect'
            restore
            
            * Get significance of the interaction (1.treated#1.treat_time)
            matrix R = r(table)
			local coef = _b[1.treated#1.treat_time]
            matrix p = R["pvalue","1.treated#1.treat_time"]
			local sig = 2*ttail(e(df_r),abs(_b[1.treated#1.treat_time]/_se[1.treated#1.treat_time])) <= .05
            *local sig = p[1,1] < .05
            *local sig = `p' < .05
			replace coef_results = `coef' in `i'
            replace sig_results = `sig' in `i'
        }
        
        * Get proportion significant
        summ sig_results
    }
    display r(mean)
end

*=====================================
* Find Sample Size
*=====================================
* Set required values for iteration and the functions 
foreach NS in 30 50 75 90 100 110 120 150 200 {
	foreach T in 3 4 5 {
		foreach effect in -.70 -.50 -.25 -.20 -.18 -.15 -.10 -.05 -.04 {
			display "With a sample size of `NS'*`T' and an effect of `effect', the mean of sig_results is "
			iterate `NS' `T' `effect' 1000
			}
		}
	}

*==============================================================================	
* The sample should be between the two samle size numbers where the power passes 90%
*=====================================
* Examine results by some graphs
*=====================================
label def sig 0 "Not Significant" 1 "Significant"
label values sig_results sig

set scheme s1color
tw kdensity coef_results, xti("Coefficient on T") yti("Density") lc(red)

graph bar, over(sig_results) yti("Percentage")
