# Simulation (in STATA)
Examples of simulation for Power Analysis, Effect Size, and Sample Size.
The following is a summary of steps to follow based on the references at the end.

## Why We Simulate
> "Simulation is the process of using a random process that we control to repeatedly apply our estimator to different samples. This lets us do a few very important things:
>	- We can test whether our estimate will, when applied to the random process / data generating process we choose, give us the true effect
>	- We can get a sense of the sampling distribution of our estimate
>	- We can see how sensitive an estimator is to certain assumptions. If we make those assumptions no longer true, does the estimator stop working?" (The Effect book)

## Steps for simulation

1) Decide what the random process/data generating process (DGP) is and produce the sample. 
2) Apply estimator to our sample and store the results
3) Iterate steps 1-2 many times and save results of each iteration
4) Look at the distribution of estimates across iterations

## Coding each step of simulation

### 1. Data generating process (DGP)
- The most important and tricky part that you should spend more time
- random uniform data: ``` runiform() ```
- normal random data: ``` rnormal() ```
- categorical random data: ``` runiformint() ``` This gives equal chance for each category
	- for binary data with a probability p of getting a 1: ``` rbinomial(1,p) ```
- Use randomly defined variables to create another variable to have the causal relationship you want (A &rarr; B)
- Maybe an easy way to do this is to make a function for this because we want to run our simulation repeatedly:
``` stata
	> capture program drop program_name // to ignore any error in dropping
	> program define program_name
  
	  end
```

### 2. Estimator 
- Decide what you are after:
	- If it is the coefficient: ``` _b[varname] ``` after running the model
	- google for anything else: how do I get STATISTIC (e.g. correlation, coefficient, standard error) from ANALYSIS/REGRESSION in STATA/ANY OTHER PROGRAMMING LANGUGAE
- A function would be helpful because we will call this repeatedly  

### 3. Iteration 
> "As a rule of thumb, the more detail you want in your results, or the more variables there are in your estimation, the more you should run." (The Effect book)

Iterate using a for loop 
```stata
forvalues i = 1(1)1000 { 
		quietly program_name N1 N2 N3
		}
```	
### Store results 
Then, store the results using any of these commands:
```stata
preserve
restore
```
or
```stata
simulate 
```

### 4. Evaluate
Depends on what characteristics of the sampling estimator we want.

# Power analysis with simulation (in STATA)
Power analysis calculator is specific to our estimate and research design. 
> "This is feasible in experiments where a simple “we randomized the sample into two groups and measured an outcome” design covers thousands of cases. But for observational data where you’re working with dozens of variables, some unmeasured, it’s infeasible for the calculator-maker to guess your intentions ahead of time. That said, calculators work well for some causal inference designs too" (The Effect book)
If you are going to do a randomized experiment, you need to know/control your sample size before you start the experiment. In that case, a power analysis would be illuminating and what we need. 

***Example:***
> "If we think the effect is probably A (effect size), and there’s B variation in X (var(X)), and there’s C variation in Y unrelated to X (var(Y)), and you want to have at least a D% chance of finding an effect (statistical precision) if it’s really there, then you’ll need a sample size of at least E."

Holding four of these constant, the power analysis tells us the minimum acceptable value for the fifth element. I am doing that practice for the sample size here. 
## Steps to calculate sample size
1) Specify a hypothesis test 
2) Specify the significance level of the test (e.g. ```alpha = 0.05```)
3) Specify the smallest effect size that is of scientific interest.
	* The point here is not to specify the effect size that you expect to find or that others have found, but the smallest effect size of scientific interest. (Economic Significance not Statistical Significance)
	* (e.g. coefficient in a regression, a correlation, a Cohen’s d, etc.)
	* If you are using other papers and they have not provided enough information to extract "raw" effect size data, most likely, you can still calculate it. 
		- Use ```{esc}``` package in R. Its ```esc_B``` and ```esc_beta``` function are helpful in the regression coefficient case. 
		- Or make educated guess. 
4) Estimate the values of other parameters necessary to compute the power function. 
	* The amount of variation in the treatment (the variance of X or T, say)
	* The amount of other variation in Y 
		* The R2, or the variation from the residual after explaining Y with X, or just the variation in Y
		* Find S.D. using data from a pilot study
		* Find S.D. using historical data (other study/studies)
	* Statistical precision (the standard error of the estimate, 
	  statistical power, AKA the true-positive rate)
	* Standard Error (S.E.) = Standard Deviation (S.D.) / n^(1/2)
5) Specify the intended power of the test. 
	* The standard used to be 80%. Now, 90% is mostly considered 
6) Start coding 
	* A function for data creation
	* A function for estimation and storing results
		* Pull statistical power using: 
			```
			matrix R = r(table) \\ matrix of results
			matrix p = R["pvalue", "X"] \\ getting p-values
			```
			* put p-values where you want by referring to it with ```p[1,1]```
	* Iterate
		* We might try a bunch of different effect sizes or sample sizes
		
# References
Huntington-Klein, N. (2022). The effect: An introduction to research design and causality. Chapman and Hall/CRC.    
Abadie, A., Athey, S., Imbens, G. W., & Wooldridge, J. M. (2023). When should you adjust standard errors for clustering?. The Quarterly Journal of Economics, 138(1), 1-35.     
https://nickch-k.github.io/EconometricsSlides/Week_08/Power_Simulations_Stata.html    
https://www.theanalysisfactor.com/5-steps-for-calculating-sample-size/    
https://www.youtube.com/watch?v=szNkh8Z7Op8   
https://bookdown.org/MathiasHarrer/Doing_Meta_Analysis_in_R/es-calc.html   
https://blog.stata.com/2014/07/18/how-to-simulate-multilevellongitudinal-data/   
