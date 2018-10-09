/*
Data from https://ope.ed.gov/campussafety/#/datafile/list
Download all excel files and put them in same folder as this file, then set working directory to that folder
*/

* 2008
clear
import excel "Crime2008EXCEL/oncampuscrime050607.xls", sheet("Oncampuscrime050607") firstrow

* Need to add a 0 to middle of id's, was done in 2010, annoying!
tostring UNITID_P, gen(strid)
gen newst = substr(strid, 1, 6) + "0" + substr(strid, 7, 8)
destring newst, gen(newint)
drop UNITID_P
rename newint UNITID_P
drop newst strid

* Make zip string and change name
tostring Zip, gen(ZIP)
drop Zip
* Rename to fit 2009/2010 naming changes
rename sector_desc Sector_desc
rename total Total

save 2008, replace


* 2009
clear
import excel "Crime2009EXCEL/oncampuscrime060708.xls", sheet("Oncampuscrime060708") firstrow

* As above
tostring UNITID_P, gen(strid)
gen newst = substr(strid, 1, 6) + "0" + substr(strid, 7, 8)
destring newst, gen(newint)
drop UNITID_P
rename newint UNITID_P
drop newst strid

tostring Zip, gen(ZIP)
drop Zip

rename sector_desc Sector_desc

save 2009, replace


* 2010
clear
import excel "Crime2010EXCEL/oncampuscrime070809.xls", sheet("Oncampuscrime070809") firstrow
save 2010, replace


* 2011
clear
import excel "Crime2011EXCEL/oncampuscrime080910.xls", sheet("Oncampuscrime080910") firstrow
save 2011, replace


* 2012
clear
import excel "Crime2012EXCEL/oncampuscrime091011.xls", sheet("Sheet1") firstrow
save 2012, replace


* 2013
clear
import excel "Crime2013EXCEL/oncampuscrime101112.xls", sheet("oncampuscrime101112") firstrow
save 2013, replace


* 2014
clear
import excel "Crime2014EXCEL/oncampuscrime111213.xls", sheet("CO_OC") firstrow
save 2014, replace


* 2015
clear
import excel "Crime2015EXCEL/oncampuscrime121314.xls", sheet("CO_OC") firstrow
save 2015, replace


* 2016
clear
import excel "Crime2016EXCEL/oncampuscrime131415.xls", sheet("Query") firstrow
save 2016, replace


* 2017
clear
import excel "Crime2017EXCEL/oncampuscrime141516.xls", sheet("Query") firstrow
save 2017, replace

* Merge all together. In this order so later reports take precedent, eg any revisions made in 2017 numbers will stay
merge 1:1 UNITID_P using 2008, nogen
merge 1:1 UNITID_P using 2009, nogen
merge 1:1 UNITID_P using 2010, nogen
merge 1:1 UNITID_P using 2011, nogen
merge 1:1 UNITID_P using 2012, nogen
merge 1:1 UNITID_P using 2013, nogen
merge 1:1 UNITID_P using 2014, nogen
merge 1:1 UNITID_P using 2015, nogen
merge 1:1 UNITID_P using 2016, nogen

* Reshape to use in panel
reshape long RAPE FONDL INCES STATR FORCIB NONFOR MURD NEG_M ROBBE AGG_A BURGLA VEHIC ARSON FILTER, i(UNITID_P) j(year)

* Drop non-used vars
drop MURD NEG_M ROBBE AGG_A BURGLA VEHIC ARSON FILTER FILTER05 FILTER06 FILTER07 FILTER08 FILTER09 Address

* Rename nicer
rename UNITID_P id
rename INSTNM school
rename BRANCH branch
rename City city
rename State state
rename ZIP zip
rename Sector_desc sector_desc
rename Total total
rename RAPE rape
rename FONDL fondl
rename INCES inces
rename STATR statr
rename FORCIB forcib
rename NONFOR nonforcib

* Sum schools with same year, same name, i.e. different branches of same school
* These create issues as the student count is for entire system, this summing reports makes sense
bysort school year: replace rape = sum(rape) 
bysort school year: replace fondl = sum(fondl) 
bysort school year: replace inces = sum(inces)
bysort school year: replace statr = sum(statr)  
bysort school year: replace forcib = sum(forcib) 
bysort school year: replace nonforcib = sum(nonforcib) 
by school year: keep if _n == _N 

* Create combined var for all reports, incl different classifications before/after 2014
gen comb = rape + fondl + inces + statr
replace comb = forcib + nonforcib if year < 14

* Create dummy for after 2011 
gen after_2011 = 0
replace after_2011 = 1 if year > 11

* Drop if no student count
drop if total == .

* Create reports per student var
gen percap = comb/total

save full, replace
