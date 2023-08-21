*(1) data prep.do 
*(2) bivariate Poisson.do <-- you are here
*(3) bar chart.R

*!!!CHANGE FILE PATH NAME TO MATCH WHERE YOU PUT DATA FOLDER!!!
global dir_output="C:\Users\...\data\output"

use "$dir_output\game data.dta", replace

/*for a discussion on how to set constraints, see
https://www.statalist.org/forums/forum/general-stata-discussion/general/
1567787-how-to-define-a-constraint-on-all-parameters-of-all-levels-of-a-factor-
variable-in-a-restricted-regression
*/

*strengths are same home offense/away defense
*[hg] specifies the home goal equation
*[ag] sepcifies the away goal equation
*There are 47 teams
forval t=1/47{
	constraint def `t' [hg]`t'.hid=-[hg]`t'.aid
}

*strengths are same home offense/away offense
forval t=48/94{
	local u=`t'-47
	constraint def `t' [hg]`u'.hid=[ag]`u'.aid
}

*strengths are same home offense/away defense
forval t=95/141{
	local u=`t'-94
	constraint def `t' [hg]`u'.hid=-[ag]`u'.hid
}


*strengths sum to zero for both equations
constraint def 142  [hg]1.hid+[hg]2.hid + [hg]3.hid+[hg]4.hid+[hg]5.hi+ [hg]6.hid+[hg]7.hid+[hg]8.hid + [hg]9.hid+[hg]10.hid+[hg]11.hid + [hg]12.hid+[hg]13.hid+[hg]14.hid + [hg]15.hid+[hg]16.hid+[hg]17.hid + [hg]18.hid+[hg]19.hid+[hg]20.hid + [hg]21.hid+[hg]22.hid+[hg]23.hid + [hg]24.hid+[hg]25.hid+[hg]26.hid + [hg]27.hid+[hg]28.hid+[hg]29.hid + [hg]30.hid+[hg]31.hid+[hg]32.hid + [hg]33.hid+[hg]34.hid+[hg]35.hid + [hg]36.hid+[hg]37.hid+[hg]38.hid + [hg]39.hid+[hg]40.hid+[hg]41.hid + [hg]42.hid+[hg]43.hid+[hg]44.hid + [hg]45.hid+[hg]46.hid+[hg]47.hid=0
*this constraint redundant given others so will be left out
constraint def 143  [ag]1.hid+[ag]2.hid + [ag]3.hid+[ag]4.hid+[ag]5.hi+ [ag]6.hid+[ag]7.hid+[ag]8.hid + [ag]9.hid+[ag]10.hid+[ag]11.hid + [ag]12.hid+[ag]13.hid+[ag]14.hid + [ag]15.hid+[ag]16.hid+[ag]17.hid + [ag]18.hid+[ag]19.hid+[ag]20.hid + [ag]21.hid+[ag]22.hid+[ag]23.hid + [ag]24.hid+[ag]25.hid+[ag]26.hid + [ag]27.hid+[ag]28.hid+[ag]29.hid + [ag]30.hid+[ag]31.hid+[ag]32.hid + [ag]33.hid+[ag]34.hid+[ag]35.hid + [ag]36.hid+[ag]37.hid+[ag]38.hid + [ag]39.hid+[ag]40.hid+[ag]41.hid + [ag]42.hid+[ag]43.hid+[ag]44.hid + [ag]45.hid+[ag]46.hid+[ag]47.hid=0


*all constraints except #143 (have to leave one out b/c redundant)
bivcnto (hg ibn.hid ibn.aid) (ag ibn.hid ibn.aid, noconstant), pfamoye constraint(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142) collinear
est store model

	*make sure all coefs same (or diff by tiny rounding error)
	forval u=1/47{
	assert abs([hg]`u'.hid+[ag]`u'.hid)<1e-14
	assert abs([hg]`u'.hid-[ag]`u'.aid)<1e-14
	assert abs([hg]`u'.hid+[ag]`u'.hid)<1e-14
	}

tempfile temp
save `temp'

*save list of teams for predictions
keep home hid
rename home team
duplicates drop 
	count
	assert r(N)==47
	
tempfile teamid
save `teamid'

use `temp', replace

*save list of team for predictions
keep away aid
rename away team
duplicates drop 
	count
	assert r(N)==47

merge 1:1 team using `teamid', assert(3) keep(3)
drop _merge

	*hid should be same as aid for each team but check
	count if hid~=aid
	assert r(N)==0

save `teamid', replace

use `temp', replace

*keep hid for team names
keep hid home_league
duplicates drop
count
assert r(N)==47
rename home_league league
tempfile teams
save `teams'

clear

*get only one set of coefs and put in matrix (home at home)
matrix teams=e(b)[1,1..47]

*transpose to column vector
matrix teams=teams'
svmat teams
rename teams1 coef
gen hid=_n

merge 1:1 hid using `teams', assert(match) update replace
drop _merge
gsort -coef

*coefficients exported for R graphs
export excel using "$dir_output\coefficients.xls", firstrow(variables) replace

**********************
*Match Outcome Charts*
**********************

/*Script below estimates probability of any match outcome and uses it to 
create a chart of probabilities of match outcome for matches between the top MLS 
and Liga MX team where the MLS (Liga MX) team is at home.*/

gen ncoef=-coef
bysort league (ncoef): gen rank=_n



decode hid, gen(team)
keep team rank league
merge 1:1 team using `teamid', assert(3) 
drop _merge

*make all possible combos of hid/aid
fillin aid hid

*********************************************************************
*Convert diff in coefs into prob of any possible outcome (hg and ag)*
*prcounts doesn't work after bivncto so must do manually            *
*********************************************************************

	*dummy for each home team to match coefs
	tab hid, gen(H)
	*dummies for away
	tab aid, gen(A)
	
	
	/*theta1 and theta2 below are from the first unnumbered equation of section 
	2 in Famoye, Felix (2010). On the bivariate negative binomial regression  
	model. Journal of Applied Statistics 37: 969–981.  
	https://www.researchgate.net/profile/Felix-Famoye/publication/
	227617928_On_the_bivariate_negative_binomial_regression_model/links/
	004635298b2985eab4000000/
	On-the-bivariate-negative-binomial-regression-model.pdf
	*/
	
	*home theta has home field advantage constant
	local theta1 "[hg]_b[1.hid]*H1+[hg]_b[1.aid]*A1+[hg]_b[_cons]"
	
	forval t=2/47{
	local theta1 "`theta1'+[hg]_b[`t'.hid]*H`t'"
	local theta1 "`theta1'+[hg]_b[`t'.aid]*A`t'"
	}

	
	*confirmed that exponentiating is the way to go here for coefs but not lambdas
	*see do-file in bivncto simulations sub-folder
	gen double theta1=exp(`theta1')

	*away theta does not have home field advantage constant
	local theta2 "[ag]_b[1.aid]*A1+[ag]_b[1.hid]*H1"
	forval t=2/47{
	local theta2 "`theta2'+[ag]_b[`t'.aid]*A`t'"
	local theta2 "`theta2'+[ag]_b[`t'.hid]*H`t'"
	}
	
	gen double theta2=exp(`theta2')
	
	local d=1-exp(-1)
	
	*Getting max # goals
	tempfile sim
	save `sim'
	
	*reload temp briefly to get max goals
	use `temp', replace
	sum hg
	local hg_max=r(max)
	sum ag
	local ag_max=r(max)
	*added two to max goals to get overall pr() to over 99% for all games
	local g_max=max(`hg_max',`ag_max')+2

	use `sim', replace
	
	*probabilities of each outcome (up to g_max goals per team)
	forval x=0/`g_max'{
	forval y=0/`g_max'{
	
	gen double pr`x'_`y'=(theta1^`x')*(theta2^`y')*exp(-theta1-theta2)*(1+_b[/lambda]*(exp(-`x')-exp(-`d'*theta1))*(exp(-`y')-exp(-`d'*theta2)))/(round(exp(lnfactorial(`x')))*round(exp(lnfactorial(`y'))))
		}/*y (away goal)*/	
		}/*x (away goal)*/
		
*make sure all probabilities add close to 1 
egen overall_pr=rowtotal(pr0_0-pr`g_max'_`g_max')
count if overall<0.99
assert r(N)==0 

*spread leftover prob (less than 1% in all matches) proportionately over all outcomes
*(force overall prob to be 1)
forval x=0/`g_max'{
forval y=0/`g_max'{
	
	local mingoal=min(`x',`y')
	
	replace pr`x'_`y'=pr`x'_`y'/overall
		}/*y (away goal)*/	
		}/*x (away goal)*/	

		*overall_pr for each game should add to approx 1 now.
		*(rounding will cause cumulative prob below to be a tiny amount over 1 for some)
		egen overall_pr2=rowtotal(pr0_0-pr`g_max'_`g_max')
		drop overall_pr
		rename overall_pr2 overall_pr
		sum overall_pr
		assert 1-r(min)<1e-6
	
*gen pr(win/lose/draw) for any possible game
gen double pr_hw=0
gen double pr_hl=0
gen double pr_t=0

forval x=0/`g_max'{
    local lose=`x'+1
	local win=`x'-1
	
	*Pr(home loss)
	forval y=`lose'/`g_max'{
	replace pr_hl=pr_hl+pr`x'_`y'
	}
	
	*Pr(home win)
	*don't run if x==0
	if `x'>0{
		forval y=0/`win'{
		replace pr_hw=pr_hw+pr`x'_`y' if `x'>`y'
		}
	}
	
	*Pr(tie)
	replace pr_t=pr_t+pr`x'_`x'
	
		}/*x (home goal)*/	

	*round last one up to 1 after making sure it's rounding error
	gen cum_pr=pr_hw+pr_hl+pr_t
	sum cum_pr
	assert(abs(r(min)-1)<1e-5)		

************************ 
*Comparing median teams*
************************


*get median team from each league. ceil() takes better team of 2 median teams 
*if odd # of teams in league
sum rank if league=="MX"
local MX_med=ceil(r(max)/2)

sum rank if league=="MLS"
local MLS_med=ceil(r(max)/2)



levelsof hid if (rank==`MX_med' & league=="MX") | (rank==`MLS_med' & league=="MLS"), local(median)
gen team1=0
gen team2=0


local i=0
foreach team of local median{
    local i=`i'+1
	
	if `i'==1{
	    replace team1=(hid==`team' | aid==`team')
	}

	if `i'==2{
	    replace team2=(hid==`team' | aid==`team')
	}
}

keep if team1==1 & team2==1
keep hid aid pr*

*keep top ranked teams in local 
sum hid
local t1=r(min)
local t2=r(max)

*put list of pr?_? variables in a local for reshaping
local pr_list "pr0_"
forval g=1/9{
local pr_list "`pr_list' pr`g'_"
}

*reshape for table
reshape long `pr_list', i(hid) j(ag)

forval g=0/`g_max'{
    rename pr`g'_ hg`g'
}

*drops entire goal possibility if max prob<=0.005
forval g1=`g_max'(-1)0{
	sum hg`g1'
	local drop=0

		*if hg never > 0.005, check ag
		if r(max)<0.005{
			local drop=1
			di "Checking away goals for ag=`g1'"
			forval g2=0/`g1'{
			sum hg`g2' if ag==`g1'
				*don't drop if there's a ag prob >= 0.005
				if r(max)>=0.005{
					local drop=0
				}
		}
	}

	*drop all hg/ag for that goal if never pr > 0.005
	if `drop'==1{
	drop hg`g1' 
	drop if ag==`g1'
	}

}


*convert data to matrix (display only 5 goals for readibility) 
*change to hg4 and ag<=4  to reproduce first chart in article
mkmat hg0-hg5 if hid==`t1' & ag<=5, matrix(M1) rownames(ag)
mkmat hg0-hg5 if hid==`t2' & ag<=5, matrix(M2) rownames(ag)

*change column names for heatmap
matrix colnames M1=0 1 2 3 4 5
matrix colnames M2=0 1 2 3 4 5

*transpose one so that the same teams are on the x/y-axis
matrix M2=M2'

*put labels of teams into local to label graphs
local vl1: label hid `t1'
local vl2: label hid `t2'


*Color choices taken from https://colorbrewer2.org/#type=sequential&scheme=YlGnBu&n=4
heatplot M1, levels(4) values(format(%9.2f) size(large)) colors(#1d91c0 #41b6c4  #a1dab4 #ffffcc ) legend(off) xlab(,nogrid) ylab(,nogrid) xtitle("`vl1'") ytitle("`vl2'") title("Outcome Probabilities" "(`vl2' at `vl1')")
graph export "$dir_output/`vl2' at `vl1'.jpg", as(jpg) name("Graph") quality(100) replace

heatplot M2, levels(4) values(format(%9.2f) size(large)) colors(#1d91c0 #41b6c4  #a1dab4 #ffffcc ) legend(off) xlab(,nogrid) ylab(,nogrid) xtitle("`vl1'") ytitle("`vl2'") title(  "Outcome Probabilities" "(`vl1' at `vl2')")
graph export "$dir_output/`vl1' at `vl2'.jpg", as(jpg) name("Graph") quality(100) replace
