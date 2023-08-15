*(1) data prep.do <-- you are here
*(2) bivariate Poisson.do
*(3) bar chart.R

*!!!CHANGE THESE FILE PATHS TO MATCH WHERE YOU PUT DATA FOLDER!!!
global dir_raw="C:\Users...\data\raw"
global dir_output="C:\Users...\data\output"

*****
*MLS*
*****

*data from https://fbref.com/en/comps/22/schedule/Major-League-Soccer-Scores-and-Fixtures
use "$dir_raw\MLS games.dta", replace
gen home_league="MLS"
gen away_league="MLS"
gen competition="MLS"

*convert string score to 2 numeric variables for home/away
split score, p("–")
drop score
rename (score1 score2) (home_score away_score)

*rename Montreal to match other data sets
foreach v of varlist home away{
    replace `v'="Montréal" if `v'=="CF Montréal"
}

tempfile data
save `data'


*data from https://fbref.com/en/comps/31/2022-2023/schedule/2022-2023-Liga-MX-Scores-and-Fixtures
use "$dir_raw\Liga MX.dta", replace
gen home_league="MX" 
gen away_league="MX"
gen competition="MX"

*drop playoff matches & make score variables numeric
drop if inlist(round, "Finals","Quarter-finals","Reclassification","Semi-finals")
split score, p("–")
rename (score1 score2) (home_score away_score)
 
*add to MLS matches
append using `data'
destring home_score away_score, replace
gen date2=date(date,"MD20Y")
drop date
rename date2 date

*data is now all regular season MLS & Liga MX matches in 2023 pre-Leagues Cup
save `data', replace
  
  
*data from https://www.leaguescup.com/schedule/#club=all&date=2023-08-15
import excel "$dir_raw\Leagues Cup.xlsx", sheet("Sheet5") firstrow clear

gen competition="League's Cup"
gen home_league="" 
gen away_league=""

*assign league to teams
foreach team in "Atlanta" "Austin" "Charlotte"	"Chicago"	"Colorado"	"D.C."	"Houston"	"Kansas City"	"LAFC" "New England"	"San Jose"	"Seattle"	"St. Louis"	"Toronto"	"Vancouver" "Cincinnati" "Columbus" "Dallas" "LA" "Miami" "Minnesota" "Montréal" "Nashville" "New York" "New York City" "Orlando" "Philadelphia" "Portland" "Salt Lake"{
	replace home_league="MLS" if home=="`team'"
	replace away_league="MLS" if away=="`team'"
}

replace home_league="MX" if missing(home_league)
replace away_league="MX" if missing(away_league)

*fix home/away when MX team called home
gen team1=home
gen team2=away
gen league1=home_league
gen league2=away_league
gen home_score_original=home_score
gen away_score_original=away_score


*replace home w/ MLS team if listed as away and playing MX team
replace home=team2 if league1=="MX" & league2=="MLS"
replace home_league=league2 if league1=="MX" & league2=="MLS"
replace away=team1 if league1=="MX" & league2=="MLS"
replace away_league=league1 if league1=="MX" & league2=="MLS"
replace home_score=away_score_original if league1=="MX" & league2=="MLS"
replace away_score=home_score_original if league1=="MX" & league2=="MLS"

drop team? *league? *_original

*data is now all regular season MLS & Liga MX matches and all League Cup matches.
append using `data'

*change names to be consistent
foreach v of varlist home away{
    replace `v'="Atlanta" if `v'=="Atlanta Utd"
    replace `v'="Guadalajara" if `v'=="Chivas"
	replace `v'="Juárez" if `v'=="FC Juárez"
	replace `v'="Toronto" if `v'=="Toronto FC"
	replace `v'="Chicago" if `v'=="Chicago Fire"
	replace `v'="Cincinnati" if `v'=="FC Cincinnati"
	replace `v'="Colorado" if `v'=="Colorado Rapids"
	replace `v'="Columbus" if `v'=="Columbus Crew"
	replace `v'="D.C." if `v'=="D.C. United"
	replace `v'="Dallas" if `v'=="FC Dallas"
	replace `v'="Kansas City" if `v'=="Sporting KC"
	replace `v'="LA" if `v'=="LA Galaxy"
	replace `v'="LAFC" if `v'=="Los Angeles FC"
	replace `v'="Miami" if `v'=="Inter Miami"
	replace `v'="Minnesota" if `v'=="Minnesota Utd"
	replace `v'="NY Red Bulls" if `v'=="New York"
	replace `v'="NYCFC" if `v'=="New York City"
	replace `v'="Orlando" if `v'=="Orlando City"
	replace `v'="Portland" if `v'=="Portland Timbers"
	replace `v'="Salt Lake" if `v'=="Real Salt Lake"
	replace `v'="Houston" if `v'=="Dynamo FC"
	replace `v'="Santos" if `v'=="Santos Laguna"
	replace `v'="Tigres" if `v'=="UANL"
	replace `v'="Pumas" if `v'=="UNAM"
    replace `v'="San Luis" if `v'=="Atlético"
	replace `v'=subinstr(`v',"é","e",.)
	replace `v'=subinstr(`v',"á","a",.)
	replace `v'=subinstr(`v',"ó","o",.)
}

*can't use string varaibles as factors
encode home, gen(hid)
encode away, gen(aid)
rename (home_score away_score) (hg ag)

*data set for analysis
save "$dir_output/game data.dta", replace
