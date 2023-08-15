# leagues-cup-2023
Estimates team strength parameters for all MLS and Liga MX teams in 2023 using all data from 2023 up to 8/15/23 (will be updated when Leagues Cup concludes). The model used to estimate team strength parameters models goals scored by the home and away teams of each match as having a bivariate Poisson distribution, which is derived as the product of two Poisson marginal distibutions with a multiplicative factor. The modeling used here allows for the correlation of goals scored between home and away team to be positive, zero, or negative. For theoretical details, see 

Lakshminarayana, J., Pandit, S., and Srinivasa Rao, K. (1999). On a Bivariate Poisson Distribution. Communications in Statistics - Theory and Methods, 28:267–276.
https://www.tandfonline.com/doi/abs/10.1080/03610929908832297

The model was estimated using Stata's _bivcnto_ command with the _pfamoye_ option. For details, see

Xu, X. and Hardin, J. W. (2016). Regression models for bivariate count outcomes. The Stata Journal, 16(2):301–315.
https://journals.sagepub.com/doi/pdf/10.1177/1536867X1601600203

# Organization of Files

## data

All data is in the "data" folder, which contains two subfolders.

### raw

The subfolder "raw" contains all raw data used as inputs to the model. These include game data from MLS, Liga MX, and Leagues Cup as well as logo image files and an excel file connecting each team with its image file.

### output

The subfolder "output" is where all output (data and images) will be saved. The folder currently has all files that the code will create when all do-files and R files are run.

# do files

Contains both do-files (data prep.do and bivariate Poisson.do) needed to estimate team strength parameters and create match outcome probability charts for matches between the top teams in MLS and Liga MX.

# R files

Contains the R script (bar chart) that creates the rankings of teams as horizontal bar charts using team logos.

# Order of Operations
To reproduce the results of my SubStackm article "Comparable Rankings of MLS and Liga MX Teams" (still in draft as of this README.md draft), follow this order of operations
   
1. run data prep.do in Stata (change file paths to location of data folder on your computer)
2. run bivariate Poisson.do in Stata (change file paths to location of data folder on your computer)
3. run bar chart.R in R (change file paths to location of data folder on your computer)
4. Let me know if you have any issues with steps 1-8
