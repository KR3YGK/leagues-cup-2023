# leagues-cup-2023
Analysis of Leagues Cup 2023 in Stata/R

# Order of Operations
To reproduce the results of my SubStackm article "Comparable Rankings of MLS and Liga MX Teams" (still in draft as of this README.md draft), follow this order of operations

1. Creat work folder with subfolder titled "data". 
2. Create subfolder within the "data" folder called "output". This is where all your output will be saved.
3. Create subfolder within the "data" folder called "raw"
4. Put all data inputs into the "raw" subfolder. These include
     i. MLS.dta
    ii. Liga MX.dta
   iii. Leagues Cup.xlsx
    iv. logos.xlsx
     v. the "logos" folder containing all team logo image files
6. run data prep.do in Stata
7. run bivariate Poisson.do in Stata
8. run bar chart.R in R
9. Let me know if you have any issues with steps 1-8
