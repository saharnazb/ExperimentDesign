# Simulation (in STATA)
Examples of simulation in economics/econometrics: Power Analysis, Effect Size, Sample Size

## Why We Simulate
> "Simulation is the process of using a random process that we control to repeatedly apply our estimator to different samples. This lets us do a few very important things:
>	- We can test whether our estimate will, when applied to the random process / data generating process we choose, give us the true effect
>	- We can get a sense of the sampling distribution of our estimate
>	- We can see how sensitive an estimator is to certain assumptions. If we make those assumptions no longer true, does the estimator stop working?" (The Effect)

## Steps for simulation

1) Decide what the random process/data generating process is and produce the sample. 
2) Apply estimator to our sample and store the results
3) Iterate steps 1-2 many times and save results of each iteration
4) Look at the distribution of estimates across iterations

## Coding each step of simulation

### 1. Data generating process 
- The most important and tricky part that you should spend more time
- random uniform data: ``` runiform() ```
- normal random data: ``` rnormal() ```
- categorical random data: ``` runiformint() ``` This gives equal chance for each category
	- for binary data with a probability p of getting a 1: ``` rbinomial(1,p) ```
- Use randomly defined variables to create another variable to have the causal relationship you want (A -> B)
- Maybe an easy way to do this is to make a function for this because we want to run our simulation repeatedly:
``` stata
	> capture program drop program_name // to ignore any error in dropping
	> program define program_name
  
	  end
```

### 2. Estimator 
- Decide what you are after:
	- If it is the coefficient: ``` _b[varname] ``` after running the model
	- google for anything else: how do I get STATISTIC (e.g. correlation, coefficient, standard error) from ANALYSIS/REGRESSION in STATA/ANY OTHER LANGUGAE
- A function would be helpful because we will call this repeatedly

### 3. Iteration 
> "As a rule of thumb, the more detail you want in your results, or the more variables there are in your estimation, the more you should run." (The Effect)
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
> "This is feasible in experiments where a simple “we randomized the sample into two groups and measured an outcome” design covers thousands of cases. But for observational data where you’re working with dozens of variables, some unmeasured, it’s infeasible for the calculator-maker to guess your intentions ahead of time. That said, calculators work well for some causal inference designs too" (The Effect)
