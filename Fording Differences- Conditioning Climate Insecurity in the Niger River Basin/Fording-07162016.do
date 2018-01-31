***Fording differences? Conditions mitigating water insecurity in the Niger River Basin

*Last Updated on December 1th, 2016
cd "C:\Data&code" #set the working directory 



***Open and save agro data as a stata data file
import delimited "cultivated_argo.csv", clear 

rename sum land_sum
rename mean land_mean
rename min land_min
rename max land_max

save "cultivated_argo.dta", replace



***Open and save growing season data from http://harvestchoice.org/labs/measuring-growing-seasons#startA
**AEZ tropical 5-class,2009)

import delimited "West_Africa_growing_category.csv", clear 

gen Gro_dum=mean
replace Gro_dum=0 if Gro_dum<.5
replace Gro_dum=1 if Gro_dum<1.5 & Gro_dum>=.5
replace Gro_dum=2 if Gro_dum<2.5 & Gro_dum>=1.5
replace Gro_dum=3 if Gro_dum<3.5 & Gro_dum>=2.5
replace Gro_dum=4 if Gro_dum<4.5 & Gro_dum>=3.5
replace Gro_dum=5 if Gro_dum>=4.5
replace Gro_dum=. if mean==.

rename mean Gro_season_mean

save "West_Africa_growing_category.dta", replace


***Open main fording dataset***

use "Fording Differences V2 6 15 2015.dta", clear


joinby fid using cultivated_argo.dta , unmatched(master) 
drop _merge
joinby fid using West_Africa_growing_category.dta , unmatched(master) 

*****Descriptive statistics table***
set matsize 11000

*outreg2 using SummaryTable.doc, replace sum(log) 

*Hypothesis 1a & 1b Roads Interaction

*Aggregate Conflict Dependent Variables (Models 1, 2, 3 respectively)
keep if nrb_id==1 & newsat==0|newsat==1
drop tm
gen tm=ym( year, month)

**Changeing precipitation unit of analysis from millimeter to decimeter
replace trend_pre=trend_pre/100

replace ppshock=ppshock/100

replace npshock=npshock/100

replace riv_dis=riv_dis/100
label variable riv_dis "Distance to Niger River (100km)"
label variable road_normal "Normalized road value"
label variable cap_dis "Distance to national capital"
label variable bor_dis "Distance to national border"
label variable xpolity "X-Polity"
label variable population "Population (logged)"
label variable night_log "Luminosity (logged)"
label variable ldr_match1 "Shared ethnicity"
label variable land_mean "Cultivated land"

label variable ptshock "Positive Temperature Shock"
label variable trend_tmp "Temperature Trend"
label variable trend_pre "Precipitation Trend"

 label variable ptshock "+ Temperature Variability"
 label variable ntshock "- Temperature Variability"
 label variable ppshock "+ Precipitation Variability"
 label variable npshock "- Precipitation Variability"


xtset fid tm

***
set cformat %5.4f
set pformat %5.3f

***Calculating growing season using precipitation data

gen Preci=trend_pre+ppshock+npshock

bysort fid year: egen Preci_max=max(Preci)
bysort fid year: egen Preci_sd=sd(Preci)

gen Gro_season=.
replace Gro_season=1 if Preci>=Preci_max-(2*Preci_sd) & land_mean>0
replace Gro_season=0 if Preci<Preci_max-(2*Preci_sd)
replace Gro_season=0 if land_mean==0

replace land_mean=land_mean/80.09467

replace Gro_season_mean=0 if land_mean==0 

xtset fid tm
*****************
**Baseline models
*****************

**ACLED all
zinb ACLED_all acled_allw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 if nrb_id==1 & newsat==0|newsat==1, ///
 inflate(acled_allw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r

*estat ic
*matrix es_ic=r(S)
*local AIC=es_ic[1,5]
*local BIC=es_ic[1,6]
*display `AIC'
*display `BIC' 

outreg2 using Table1.doc, replace ctitle(All-ZI) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 
 
outreg2 using Table1A.xls, replace ctitle(All-ZI) symbol(**,*,+) addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))   label 

xtreg ACLED_all acled_allw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 if nrb_id==1 & newsat==0|newsat==1, fe r

 outreg2 using Table1.doc, append ctitle(All-FE) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(All-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


meqrpoisson ACLED_all acled_allw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 || ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

estimate store AllML

outreg2 using Table1.doc, append ctitle(All-ML) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(All-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 



**ACLED battles  

 zinb ACLED_battles acled_batw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 if nrb_id==1 & newsat==0|newsat==1, ///
 inflate(acled_batw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r
 
 
 outreg2 using Table1.doc, append ctitle(Battles-ZI) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(Battles-ZI) symbol(**,*,+) addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 

xtreg ACLED_battles acled_batw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 if nrb_id==1 & newsat==0|newsat==1, fe r

 
outreg2 using Table1.doc, append ctitle(Battles-FE) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(Battles-FE) symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


meqrpoisson ACLED_battles acled_batw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 || ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

estimate store BattlesML

 outreg2 using Table1.doc, append ctitle(Battles-ML) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, NO) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(Battles-ML) symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 


 

***ACLED riots

zinb ACLED_riots acled_riow c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 if nrb_id==1 & newsat==0|newsat==1, ///
 inflate(acled_riow c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r
 
  
outreg2 using Table1.doc, append ctitle(Riots-ZI) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(Riots-ZI) symbol(**,*,+) addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 

xtreg ACLED_riots acled_riow c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 if nrb_id==1 & newsat==0|newsat==1, fe r

 outreg2 using Table1.doc, append ctitle(Riots-FE) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

outreg2 using Table1A.xls, append ctitle(Riots-FE) symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

meqrpoisson ACLED_riots acled_riow c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 || ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

estimate store RiotsML

outreg2 using Table1.doc, append ctitle(Riots-ML) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 

outreg2 using Table1A.xls, append ctitle(Riots-ML) symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 




***ACLED remote

zinb ACLED_other acled_othw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 if nrb_id==1 & newsat==0|newsat==1, ///
 inflate(acled_othw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r
 
 
 outreg2 using Table1.doc, append ctitle(Remote-ZI) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(Remote-ZI) symbol(**,*,+) addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 

xtreg ACLED_other acled_othw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 if nrb_id==1 & newsat==0|newsat==1, fe r
 
 
 outreg2 using Table1.doc, append ctitle(Remote-FE) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(Remote-FE) symbol(**,*,+) addtext(Year & month dummy, Yes,Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 
 

meqrpoisson ACLED_other acled_othw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock i.month i.year ///
 || ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

 outreg2 using Table1.doc, append ctitle(Remote-ML) keep(c.riv_dis c.road_normal i.ldr_match1 c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock) ///
 symbol(**,*,+) addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using Table1A.xls, append ctitle(Remote-ML) symbol(**,*,+) addtext(Year & month dummy, Yes,Robust errors, No) addstat(Loglikelihood, e(ll))  label 
 
 

*********************
***Interaction models
*********************
 
 ***ACLED all
 
zinb ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, ///
inflate(acled_allw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r


outreg2 using Table2.doc, replace ctitle(All-ZI) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


outreg2 using TableA2.xls, replace ctitle(All-ZI) symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


xtreg ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
 c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

 estimates store AllFE

outreg2 using Table2.doc, append ctitle(All-FE) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


 outreg2 using TableA2.xls, append ctitle(All-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 
estimates restore AllFE
eststo All_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot All_road_trend, at ytitle(Change in conflict incidents-All) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(All_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllFE
eststo All_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot All_road_shock, at ytitle(Change in conflict incidents-All) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(All_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore AllFE
eststo All_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot All_river_trend, at ytitle(Change in conflict incidents-All) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(All_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllFE
eststo All_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot All_river_shock, at ytitle(Change in conflict incidents-All) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(All_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore AllFE
eststo All_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot All_ethnicity_trend, at ytitle(Change in conflict incidents-All) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev) ///
saving(All_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllFE
eststo All_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot All_ethnicity_shock, at ytitle(Change in conflict incidents-All) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev) ///
saving(All_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

 

meqrpoisson ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
 c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year ///
 || ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1
 
 
 estimate store AllIntML
 
outreg2 using Table2.doc, append ctitle(All-ML) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 


 outreg2 using TableA2.xls, append ctitle(All-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 

 

***ACLED battles

zinb ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, ///
inflate(acled_batw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r


outreg2 using Table2.doc, append ctitle(Battles-ZI) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

outreg2 using TableA2.xls, append ctitle(Battles-ZI) symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


xtreg ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

estimates store BattlesFE

outreg2 using Table2.doc, append ctitle(Battles-FE) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


outreg2 using TableA2.xls, append ctitle(Battles-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


estimates restore BattlesFE
eststo Battles_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Battles_road_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Battles_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesFE
eststo Battles_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Battles_road_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Battles_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore BattlesFE
eststo Battles_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Battles_river_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)   ///
saving(Battles_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesFE
eststo Battles_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Battles_river_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Battles_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore BattlesFE
eststo Battles_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Battles_ethnicity_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Battles_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesFE
eststo Battles_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Battles_ethnicity_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Battles_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)


meqrpoisson ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year  ///
|| ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

 estimate store BattlesIntML

outreg2 using Table2.doc, append ctitle(Battles-ML) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 


outreg2 using TableA2.xls, append ctitle(Battles-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 


***ACLED riots

zinb ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, ///
inflate(acled_riow c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r

outreg2 using Table2.doc, append ctitle(Riots-ZI) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


outreg2 using TableA2.xls, append ctitle(Riots-ZI) symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


xtreg ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

estimates store RiotsFE

outreg2 using Table2.doc, append ctitle(Riots-FE) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

outreg2 using TableA2.xls, append ctitle(Riots-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

estimates restore RiotsFE
eststo Riots_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Riots_road_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Riots_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsFE
eststo Riots_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot Riots_road_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
 saving(Riots_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RiotsFE
eststo Riots_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Riots_river_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Riots_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsFE
eststo Riots_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Riots_river_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Riots_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RiotsFE
eststo Riots_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Riots_ethnicity_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Riots_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsFE
eststo Riots_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Riots_ethnicity_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Riots_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)


meqrpoisson ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year ///
|| ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

 estimate store RiotsIntML

outreg2 using Table2.doc, append ctitle(Riots-ML) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 

outreg2 using TableA2.xls, append ctitle(Riots-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 



***ACLED remotes

zinb ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, ///
inflate(acled_riow c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r


outreg2 using Table2.doc, append ctitle(Remotes-ZI) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


outreg2 using TableA2.xls, append ctitle(Remotes-ZI) symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


xtreg ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

estimates store RemotesFE

outreg2 using Table2.doc, append ctitle(Remotes-FE) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.npshock#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.npshock#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.npshock#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

outreg2 using TableA2.xls, append ctitle(Remotes-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


estimates restore RemotesFE
eststo Remotes_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Remotes_road_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Remotes_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesFE
eststo Remotes_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot Remotes_road_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Remotes_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RemotesFE
eststo Remotes_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Remotes_river_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22) ///
saving(Remotes_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesFE
eststo Remotes_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Remotes_river_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Remotes_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RemotesFE
eststo Remotes_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Remotes_ethnicity_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Remotes_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesFE
eststo Remotes_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Remotes_ethnicity_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Remotes_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)


meqrpoisson ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year ///
|| ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

 estimate store RemotesIntML

outreg2 using Table2.doc, append ctitle(Remotes-ML) keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.npshock#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.npshock#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.npshock#c.npshock) ///
 symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 

outreg2 using TableA2.xls, append ctitle(Remotes-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 




graph combine All_road_trend.gph Battles_road_trend.gph Riots_road_trend.gph Remotes_road_trend.gph   ///
               All_road_shock.gph Battles_road_shock.gph Riots_road_shock.gph Remotes_road_shock.gph, ///
			  col(4) imargin(0 0 0 0) graphregion(color(white)) ///
			  title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Normalized Road Value", size(small))

graph save Road, replace

graph combine All_river_trend.gph  Battles_river_trend.gph  Riots_river_trend.gph  Remotes_river_trend.gph /// 
              All_river_shock.gph Battles_river_shock.gph Riots_river_shock.gph Remotes_river_shock.gph,  ///
              col(4) imargin(0 0 0 0) graphregion(color(white)) ///
 title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Distance to Niger River ", size(small))

graph save River, replace

graph combine All_ethnicity_trend.gph  Battles_ethnicity_trend.gph  Riots_ethnicity_trend.gph  Remotes_ethnicity_trend.gph ///
			  All_ethnicity_shock.gph Battles_ethnicity_shock.gph Riots_ethnicity_shock.gph Remotes_ethnicity_shock.gph, ///
			  col(4) imargin(0 0 0 0) graphregion(color(white)) ///
 title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Shared Ethnicity  ", size(small))


graph save Ethnicity, replace



******Interaction with cultivated land

***ACLED all

xtreg ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.land_mean c.road_normal#c.npshock#c.land_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.land_mean c.riv_dis#c.npshock#c.land_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.land_mean i.ldr_match1#c.npshock#c.land_mean ///
 i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

outreg2 using Table3.doc, replace keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.land_mean c.road_normal#c.npshock#c.land_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.land_mean c.riv_dis#c.npshock#c.land_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.land_mean i.ldr_match1#c.npshock#c.land_mean) ///
ctitle(All-Land) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

outreg2 using TableA3.xls, replace ctitle(All-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


***ACLED battles

xtreg ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.land_mean c.road_normal#c.npshock#c.land_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.land_mean c.riv_dis#c.npshock#c.land_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.land_mean i.ldr_match1#c.npshock#c.land_mean ///
 i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

 outreg2 using Table3.doc, append keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.land_mean c.road_normal#c.npshock#c.land_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.land_mean c.riv_dis#c.npshock#c.land_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.land_mean i.ldr_match1#c.npshock#c.land_mean) ///
ctitle(Battles-Land) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

outreg2 using TableA3.xls, append ctitle(Battles-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 



***ACLED riots

xtreg ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.land_mean c.road_normal#c.npshock#c.land_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.land_mean c.riv_dis#c.npshock#c.land_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.land_mean i.ldr_match1#c.npshock#c.land_mean ///
 i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

 outreg2 using Table3.doc, append keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.land_mean c.road_normal#c.npshock#c.land_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.land_mean c.riv_dis#c.npshock#c.land_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.land_mean i.ldr_match1#c.npshock#c.land_mean) ///
ctitle(Riots-Land) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 outreg2 using TableA3.xls, append ctitle(Riots-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


***ACLED remotes

xtreg ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.land_mean c.road_normal#c.npshock#c.land_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.land_mean c.riv_dis#c.npshock#c.land_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.land_mean i.ldr_match1#c.npshock#c.land_mean ///
 i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

 
 outreg2 using Table3.doc, append keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.land_mean c.road_normal#c.npshock#c.land_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.land_mean c.riv_dis#c.npshock#c.land_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.land_mean i.ldr_match1#c.npshock#c.land_mean) ///
ctitle(Remotes-Land) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

outreg2 using TableA3.xls, append ctitle(Remotes-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 



*********Interaction with growing season


***ACLED all

xtreg ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.Gro_season_mean c.road_normal#c.npshock#c.Gro_season_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.Gro_season_mean c.riv_dis#c.npshock#c.Gro_season_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.Gro_season_mean i.ldr_match1#c.npshock#c.Gro_season_mean ///
 i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

 
outreg2 using Table4.doc, replace keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.Gro_season_mean c.road_normal#c.npshock#c.Gro_season_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.Gro_season_mean c.riv_dis#c.npshock#c.Gro_season_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.Gro_season_mean i.ldr_match1#c.npshock#c.Gro_season_mean) ///
ctitle(All-Season) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


outreg2 using TableA4.xls, replace ctitle(All-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


***ACLED battles

xtreg ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.Gro_season_mean c.road_normal#c.npshock#c.Gro_season_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.Gro_season_mean c.riv_dis#c.npshock#c.Gro_season_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.Gro_season_mean i.ldr_match1#c.npshock#c.Gro_season_mean ///
 i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

outreg2 using Table4.doc, append keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.Gro_season_mean c.road_normal#c.npshock#c.Gro_season_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.Gro_season_mean c.riv_dis#c.npshock#c.Gro_season_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.Gro_season_mean i.ldr_match1#c.npshock#c.Gro_season_mean) ///
ctitle(Battles-Season) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


outreg2 using TableA4.xls, append ctitle(Battles-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 



***ACLED riots

xtreg ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.Gro_season_mean c.road_normal#c.npshock#c.Gro_season_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.Gro_season_mean c.riv_dis#c.npshock#c.Gro_season_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.Gro_season_mean i.ldr_match1#c.npshock#c.Gro_season_mean ///
 i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

outreg2 using Table4.doc, append keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.Gro_season_mean c.road_normal#c.npshock#c.Gro_season_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.Gro_season_mean c.riv_dis#c.npshock#c.Gro_season_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.Gro_season_mean i.ldr_match1#c.npshock#c.Gro_season_mean) ///
ctitle(Riots-Season) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 
outreg2 using TableA4.xls, append ctitle(Riots-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


***ACLED remotes

xtreg ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.Gro_season_mean c.road_normal#c.npshock#c.Gro_season_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.Gro_season_mean c.riv_dis#c.npshock#c.Gro_season_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.Gro_season_mean i.ldr_match1#c.npshock#c.Gro_season_mean ///
 i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r

 outreg2 using Table4.doc, append keep(c.road_normal#c.trend_pre c.road_normal#c.npshock c.road_normal#c.trend_pre#c.Gro_season_mean c.road_normal#c.npshock#c.Gro_season_mean ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock c.riv_dis#c.trend_pre#c.Gro_season_mean c.riv_dis#c.npshock#c.Gro_season_mean ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.ldr_match1#c.trend_pre#c.Gro_season_mean i.ldr_match1#c.npshock#c.Gro_season_mean) ///
ctitle(Remotes-Season) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label  

outreg2 using TableA4.xls, append ctitle(Remotes-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 



*************Road-Endogeneity****

gen road_normalXtrend_pre=c.road_normal*c.trend_pre
gen road_normalXnpshock=c.road_normal*c.npshock


***ACLED all

xtivreg ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
  ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock  ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock ///
 i.month i.year (road_normalXtrend_pre road_normalXnpshock= l.night_log l.population) if nrb_id==1 & newsat==0|newsat==1, first fe


outreg2 using Table3.doc, append keep(road_normalXtrend_pre road_normalXnpshock ///
 c.riv_dis#c.trend_pre c.riv_dis#c.npshock  ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
ctitle(All-RoadIV) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes)  label 

outreg2 using TableA5.xls, replace ctitle(All-IV) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes, Cluster, Grid Cell)   label 


***ACLED battles

xtivreg  ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
  ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock  ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock ///
 i.month i.year (road_normalXtrend_pre road_normalXnpshock= l.night_log l.population) if nrb_id==1 & newsat==0|newsat==1, first fe


outreg2 using Table3.doc, append keep(road_normalXtrend_pre road_normalXnpshock ///
 c.riv_dis#c.trend_pre c.riv_dis#c.npshock  ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
ctitle(Battles-RoadIV) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes)   label 


outreg2 using TableA5.xls, append ctitle(Battles-IV) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes, Cluster, Grid Cell) label 


***ACLED riots

xtivreg ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
  ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock  ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock ///
 i.month i.year (road_normalXtrend_pre road_normalXnpshock= l.night_log l.population) if nrb_id==1 & newsat==0|newsat==1, first fe


 outreg2 using Table3.doc, append keep(road_normalXtrend_pre road_normalXnpshock ///
 c.riv_dis#c.trend_pre c.riv_dis#c.npshock  ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
ctitle(Riots-RoadIV) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes)  label 

 
outreg2 using TableA5.xls, append ctitle(Riots-IV) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes, Cluster, Grid Cell)  label 


***ACLED remotes

xtivreg ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
  ///
c.riv_dis#c.trend_pre c.riv_dis#c.npshock  ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock ///
 i.month i.year (road_normalXtrend_pre road_normalXnpshock= l.night_log l.population) if nrb_id==1 & newsat==0|newsat==1, first fe


 outreg2 using Table3.doc, append keep(road_normalXtrend_pre road_normalXnpshock ///
 c.riv_dis#c.trend_pre c.riv_dis#c.npshock  ///
 i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock) ///
ctitle(Remotes-RoadIV) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes)   label 


 
outreg2 using TableA5.xls, append ctitle(Remotes-IV) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes, Cluster, Grid Cell)  label 

 * graph combine All_road_trendIV.gph Battles_road_trendIV.gph Riots_road_trendIV.gph Remotes_road_trendIV.gph   ///
   *            All_road_shockIV.gph Battles_road_shockIV.gph Riots_road_shockIV.gph Remotes_road_shockIV.gph, ///
	*		  col(4) imargin(0 0 0 0) graphregion(color(white)) ///
	*		  title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Normalized Road Value(IV)", size(small))

*graph save RoadIV, replace

 *****ML graphs
 

*********************
***Interaction models
*********************
 
 ***ACLED all
 
 
estimates restore AllIntML
eststo All_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot All_road_trend, at ytitle(Change in conflict incidents-All) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(All_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllIntML
eststo All_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot All_road_shock, at ytitle(Change in conflict incidents-All) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(All_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore AllIntML
eststo All_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot All_river_trend, at ytitle(Change in conflict incidents-All) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(All_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllIntML
eststo All_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot All_river_shock, at ytitle(Change in conflict incidents-All) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(All_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore AllIntML
eststo All_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot All_ethnicity_trend, at ytitle(Change in conflict incidents-All) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev) ///
saving(All_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllIntML
eststo All_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot All_ethnicity_shock, at ytitle(Change in conflict incidents-All) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev) ///
saving(All_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

 
 
***ACLED battles***

estimates restore BattlesIntML
eststo Battles_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Battles_road_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Battles_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesIntML
eststo Battles_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Battles_road_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Battles_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore BattlesIntML
eststo Battles_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Battles_river_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)   ///
saving(Battles_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesIntML
eststo Battles_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Battles_river_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Battles_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore BattlesIntML
eststo Battles_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Battles_ethnicity_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Battles_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesIntML
eststo Battles_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Battles_ethnicity_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Battles_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)


***ACLED riots

estimates restore RiotsIntML
eststo Riots_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Riots_road_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Riots_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsIntML
eststo Riots_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot Riots_road_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
 saving(Riots_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RiotsIntML
eststo Riots_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Riots_river_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Riots_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsIntML
eststo Riots_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Riots_river_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Riots_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RiotsIntML
eststo Riots_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Riots_ethnicity_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Riots_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsIntML
eststo Riots_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Riots_ethnicity_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Riots_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)




***ACLED remotes

estimates restore RemotesIntML
eststo Remotes_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Remotes_road_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Remotes_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesIntML
eststo Remotes_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot Remotes_road_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Remotes_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RemotesIntML
eststo Remotes_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Remotes_river_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22) ///
saving(Remotes_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesIntML
eststo Remotes_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Remotes_river_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Remotes_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RemotesIntML
eststo Remotes_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Remotes_ethnicity_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Remotes_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesIntML
eststo Remotes_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Remotes_ethnicity_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Remotes_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)


graph combine All_road_trend.gph Battles_road_trend.gph Riots_road_trend.gph Remotes_road_trend.gph   ///
               All_road_shock.gph Battles_road_shock.gph Riots_road_shock.gph Remotes_road_shock.gph, ///
			  col(4) imargin(0 0 0 0) graphregion(color(white)) ///
			  title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Normalized Road Value", size(small))

graph save RoadML, replace version(13)

graph combine All_river_trend.gph  Battles_river_trend.gph  Riots_river_trend.gph  Remotes_river_trend.gph /// 
              All_river_shock.gph Battles_river_shock.gph Riots_river_shock.gph Remotes_river_shock.gph,  ///
              col(4) imargin(0 0 0 0) graphregion(color(white)) ///
 title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Distance to Niger River ", size(small))

graph save RiverML, replace

graph combine All_ethnicity_trend.gph  Battles_ethnicity_trend.gph  Riots_ethnicity_trend.gph  Remotes_ethnicity_trend.gph ///
			  All_ethnicity_shock.gph Battles_ethnicity_shock.gph Riots_ethnicity_shock.gph Remotes_ethnicity_shock.gph, ///
			  col(4) imargin(0 0 0 0) graphregion(color(white)) ///
 title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Shared Ethnicity  ", size(small))


graph save EthnicityML, replace


******************
 

 
*********************
*Anamoly
*********************


bysort fid: egen precip_mean=mean(Preci)
bysort fid: egen precip_SD=sd(Preci)

gen Preci_anomly=(Preci-precip_mean)/(.01+precip_SD)

gen Preci_anomly_P=0
replace Preci_anomly_P=Preci_anomly if Preci_anomly>0

label variable Preci_anomly_P "Positive precipitation anomaly"

gen Preci_anomly_N=0
replace Preci_anomly_N=Preci_anomly if Preci_anomly<0
 
label variable Preci_anomly_N "Negative precipitation anomaly"
 
***ACLED all
 
*zinb ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.precip_mean c.ptshock c.ntshock c.ppshock c.npshock c.Preci_anomly_P#c.Preci_anomly_P c.Preci_anomly_N#c.Preci_anomly_N ///
*c.road_normal#c.precip_mean c.road_normal#c.Preci_anomly_N c.riv_dis#c.precip_mean c.riv_dis#c.Preci_anomly_N i.ldr_match1#c.precip_mean i.ldr_match1#c.Preci_anomly_N i.month i.year if nrb_id==1 & newsat==0|newsat==1, ///
*inflate(acled_allw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r


*outreg2 using TableA6.xls, replace ctitle(All-ZI) symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


xtreg ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.precip_mean c.ptshock c.ntshock c.Preci_anomly_P c.Preci_anomly_N c.Preci_anomly_P#c.Preci_anomly_P c.Preci_anomly_N#c.Preci_anomly_N ///
c.road_normal#c.precip_mean c.road_normal#c.Preci_anomly_N c.riv_dis#c.precip_mean c.riv_dis#c.Preci_anomly_N i.ldr_match1#c.precip_mean i.ldr_match1#c.Preci_anomly_N i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r


outreg2 using TableA6.xls, replace ctitle(All-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

 

*meqrpoisson ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
* c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year ///
* || ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1
 

*outreg2 using TableA6.xls, append ctitle(All-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 


***ACLED battles

*zinb ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
*c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, ///
*inflate(acled_batw c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r


*outreg2 using TableA6.xls, append ctitle(Battles-ZI) symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


xtreg ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.precip_mean c.ptshock c.ntshock c.Preci_anomly_P c.Preci_anomly_N c.Preci_anomly_P#c.Preci_anomly_P c.Preci_anomly_N#c.Preci_anomly_N ///
c.road_normal#c.precip_mean c.road_normal#c.Preci_anomly_N c.riv_dis#c.precip_mean c.riv_dis#c.Preci_anomly_N i.ldr_match1#c.precip_mean i.ldr_match1#c.Preci_anomly_N i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r



outreg2 using TableA6.xls, append ctitle(Battles-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 



*meqrpoisson ACLED_battles acled_batw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
*c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year  ///
*|| ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

*outreg2 using TableA6.xls, append ctitle(Battles-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 


***ACLED riots

*zinb ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
*c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, ///
*inflate(acled_riow c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r


*outreg2 using TableA6.xls, append ctitle(Riots-ZI) symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


xtreg ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.precip_mean c.ptshock c.ntshock c.Preci_anomly_P c.Preci_anomly_N c.Preci_anomly_P#c.Preci_anomly_P c.Preci_anomly_N#c.Preci_anomly_N ///
c.road_normal#c.precip_mean c.road_normal#c.Preci_anomly_N c.riv_dis#c.precip_mean c.riv_dis#c.Preci_anomly_N i.ldr_match1#c.precip_mean i.ldr_match1#c.Preci_anomly_N i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r




outreg2 using TableA6.xls, append ctitle(Riots-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

*meqrpoisson ACLED_riots acled_riow c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
*c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year ///
*|| ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

 
*outreg2 using TableA6.xls, append ctitle(Riots-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 



***ACLED remotes

*zinb ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
*c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, ///
*inflate(acled_riow c.bor_dis c.cap_dis c.riv_dis c.road_normal xpolity c.population c.night_log i.ldr_match1 land_mean) cluster(fid) r


*outreg2 using TableA6.xls, append ctitle(Remotes-ZI) symbol(**,*,+)  addtext(Year & month dummy, Yes, Clustered errors, 1st Admin., Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

xtreg ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.precip_mean c.ptshock c.ntshock c.Preci_anomly_P c.Preci_anomly_N c.Preci_anomly_P#c.Preci_anomly_P c.Preci_anomly_N#c.Preci_anomly_N ///
c.road_normal#c.precip_mean c.road_normal#c.Preci_anomly_N c.riv_dis#c.precip_mean c.riv_dis#c.Preci_anomly_N i.ldr_match1#c.precip_mean i.ldr_match1#c.Preci_anomly_N i.month i.year if nrb_id==1 & newsat==0|newsat==1, fe r


estimates store RemotesFE

outreg2 using TableA6.xls, append ctitle(Remotes-FE) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 


*meqrpoisson ACLED_other acled_othw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
*c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year ///
*|| ccode: || admin1_id: if nrb_id==1 & newsat==0|newsat==1

*outreg2 using TableA6.xls, append ctitle(Remotes-ML) symbol(**,*,+)  addtext(Year & month dummy, Yes, Robust errors, No) addstat(Loglikelihood, e(ll))  label 


*********************
***Interaction models
*********************
 
 ***ACLED all
 
 
estimates restore AllIntML
eststo All_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot All_road_trend, at ytitle(Change in conflict incidents-All) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(All_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllIntML
eststo All_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot All_road_shock, at ytitle(Change in conflict incidents-All) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(All_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore AllIntML
eststo All_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot All_river_trend, at ytitle(Change in conflict incidents-All) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(All_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllIntML
eststo All_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot All_river_shock, at ytitle(Change in conflict incidents-All) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(All_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore AllIntML
eststo All_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot All_ethnicity_trend, at ytitle(Change in conflict incidents-All) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev) ///
saving(All_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore AllIntML
eststo All_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot All_ethnicity_shock, at ytitle(Change in conflict incidents-All) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev) ///
saving(All_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

 
 
***ACLED battles***

estimates restore BattlesIntML
eststo Battles_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Battles_road_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Battles_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesIntML
eststo Battles_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Battles_road_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Battles_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore BattlesIntML
eststo Battles_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Battles_river_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)   ///
saving(Battles_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesIntML
eststo Battles_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Battles_river_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Battles_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore BattlesIntML
eststo Battles_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Battles_ethnicity_trend, at ytitle(Change in conflict incidents-Battles) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Battles_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore BattlesIntML
eststo Battles_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Battles_ethnicity_shock, at ytitle(Change in conflict incidents-Battles) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Battles_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)


***ACLED riots

estimates restore RiotsIntML
eststo Riots_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Riots_road_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Riots_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsIntML
eststo Riots_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot Riots_road_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
 saving(Riots_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RiotsIntML
eststo Riots_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Riots_river_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Riots_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsIntML
eststo Riots_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Riots_river_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Riots_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RiotsIntML
eststo Riots_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Riots_ethnicity_trend, at ytitle(Change in conflict incidents-Riots) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Riots_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RiotsIntML
eststo Riots_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Riots_ethnicity_shock, at ytitle(Change in conflict incidents-Riots) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Riots_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)




***ACLED remotes

estimates restore RemotesIntML
eststo Remotes_road_trend: margins, dydx(trend_pre) at(road_normal=(0(.1)1)) post atmeans noestimcheck

coefplot Remotes_road_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Remotes_road_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesIntML
eststo Remotes_road_shock: margins, dydx(npshock) at(road_normal=(0(.1)1)) post atmeans noestimcheck


coefplot Remotes_road_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Road density) ///
 recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1)  ///
   saving(Remotes_road_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RemotesIntML
eststo Remotes_river_trend: margins, dydx(trend_pre) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Remotes_river_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22) ///
saving(Remotes_river_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesIntML
eststo Remotes_river_shock: margins, dydx(npshock) at(riv_dis=(0(1)22)) post atmeans noestimcheck

coefplot Remotes_river_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Distance to Niger River (100km)) ///
recast(line) lwidth(*2) ciopts(recast(rline) lpattern(dash)) xlabel(0(2)22) xmtick(0(1)22)  ///
saving(Remotes_river_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

***
estimates restore RemotesIntML
eststo Remotes_ethnicity_trend: margins, dydx(trend_pre) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Remotes_ethnicity_trend, at ytitle(Change in conflict incidents-Remotes) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2)  xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Remotes_ethnicity_trend, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)

estimates restore RemotesIntML
eststo Remotes_ethnicity_shock: margins, dydx(npshock) at(ldr_match1=(0 1)) post atmeans noestimcheck

coefplot Remotes_ethnicity_shock, at ytitle(Change in conflict incidents-Remotes) xtitle(Shared ethnicity) ///
recast(line) lwidth(*2) xlabel(1 "0" 0 "1")  xscale(rev)  ///
saving(Remotes_ethnicity_shock, replace) graphregion(color(white)) bgcolor(white) lcolor(black) level(90)


graph combine All_road_trend.gph Battles_road_trend.gph Riots_road_trend.gph Remotes_road_trend.gph   ///
               All_road_shock.gph Battles_road_shock.gph Riots_road_shock.gph Remotes_road_shock.gph, ///
			  col(4) imargin(0 0 0 0) graphregion(color(white)) ///
			  title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Normalized Road Value", size(small))

graph save RoadML, replace version(13)

graph combine All_river_trend.gph  Battles_river_trend.gph  Riots_river_trend.gph  Remotes_river_trend.gph /// 
              All_river_shock.gph Battles_river_shock.gph Riots_river_shock.gph Remotes_river_shock.gph,  ///
              col(4) imargin(0 0 0 0) graphregion(color(white)) ///
 title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Distance to Niger River ", size(small))

graph save RiverML, replace

graph combine All_ethnicity_trend.gph  Battles_ethnicity_trend.gph  Riots_ethnicity_trend.gph  Remotes_ethnicity_trend.gph ///
			  All_ethnicity_shock.gph Battles_ethnicity_shock.gph Riots_ethnicity_shock.gph Remotes_ethnicity_shock.gph, ///
			  col(4) imargin(0 0 0 0) graphregion(color(white)) ///
 title("Marginal effects of Temperature Trend (top)" "and Negative Precipitation Variability (down) on conflict incidents conditional on Shared Ethnicity  ", size(small))


graph save EthnicityML, replace








*****Multicolinearity
gen  ppshock_2=ppshock*ppshock
gen npshock_2=npshock*npshock
gen road_normalXtrend_pre=road_normal*trend_pre
gen road_normalXnpshock=road_normal*npshock
gen riv_disXtrend_pre=riv_dis*trend_pre
gen riv_disXnpshock=riv_dis*npshock  
gen ldr_match1Xtrend_pre=ldr_match1*trend_pre  
gen ldr_match1Xnpshock=ldr_match1*npshock



collin acled_allw trend_pre  ///
npshock ppshock ppshock_2 npshock_2 ///
 road_normalXtrend_pre road_normalXnpshock ///
 riv_disXtrend_pre riv_disXnpshock ///
 ldr_match1Xtrend_pre ldr_match1Xnpshock ///
 bor_dis cap_dis xpolity population night_log land_mean month year if nrb_id==1 & newsat==0|newsat==1

reg ACLED_all acled_allw c.bor_dis c.cap_dis xpolity c.population c.night_log land_mean c.trend_tmp c.trend_pre c.ptshock c.ntshock c.ppshock c.npshock c.ppshock#c.ppshock c.npshock#c.npshock ///
 c.road_normal#c.trend_pre c.road_normal#c.npshock c.riv_dis#c.trend_pre c.riv_dis#c.npshock i.ldr_match1#c.trend_pre i.ldr_match1#c.npshock i.month i.year if nrb_id==1 & newsat==0|newsat==1, r

estat vif
