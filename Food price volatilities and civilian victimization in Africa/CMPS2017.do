*****Replication material for "Food Price Volatilities and Civilian Victimization in Africa"
**CMPS 2017
**Authors: RezaeeDaryakenari, Steven Landis, and Cameron Thies

*****************Note********************
*****************************************
**There are two dofiles which replicate this study. The first one which takes a longer time to run,///
* refine datasets, merge them, and do time-consuming calculations. It is named data-preparation. ///
*This process lead to a stata datd file, named MainDataAllMergedWeight. To replicate the results reported///
* in the paper, you just need this stata data file and the dofile named CMPS2017
*If you had any questions regarding replicating this study, you may contact Babak RezaeeDaryaeknari via srezaeed@ASU.edu
*****************************************************
*****************************************************


*set the directory
cd "c:\~"

clear
set cformat %5.3f
set pformat %5.3f
*************************************************
use "MainDataAllMergedWeight.dta", clear
xtset objectid modate

collapse (sum) Violence (mean) FoodPI comm1, by(modate Year sname iso)

egen isoCode = group(iso)
 
xtset isoCode modate
 
 
egen comm1_max = max(comm1), by(isoCode)
gen comm1_unit=(comm1/comm1_max)*100
 
egen Violence_max = max(Violence), by(isoCode)
gen Violence_unit=(Violence/Violence_max)*100
 
egen FoodPI_max = max(FoodPI), by(isoCode)
gen FoodPI_unit=(FoodPI/FoodPI_max)*100
 
 
 drop if Year>2011
 
 label variable comm1_unit "Local food price"
 label variable FoodPI_unit "IMF food price"
 label variable Violence_unit "Violence against civilians"
 
 twoway (tsline Violence_unit) (tsline comm1_unit) (tsline FoodPI_unit) if ///
 iso=="BDI" | iso=="COD" | iso=="GHA"| iso=="RWA" | iso=="SOM" | iso=="ZWE" , ///
 by(sname, note("")) tlabel(, angle(vertical)) scheme(plotplainblind) legend(col(3)) xtitle("")
 
graph export ViolenceFoodPrice.tif, replace

*************************************************

use "MainDataAllMergedWeight.dta", replace


label variable cultivated "Cultivated land"

***
gen FoodPI_3=FoodPI^(1/3)
gen FoodPI_log=log(1+FoodPI)

label variable FoodPI_3 "IMF food price index"
label variable FoodPI_log "IMF food price index"

 xtset objectid modate
 
 
 
*tsfilter hp Precip_shock=Precip_mean, smooth(129600) trend(Precip_trend) 

gen FoodPI_log_1=l.FoodPI_log
label variable FoodPI_log_1 "IMF food price index"

gen FoodPIChange=D.FoodPI
gen FoodPIChange_1=l.FoodPIChange
label variable FoodPIChange_1 "IMF food price index (Change)"

 egen comm1_max = max(comm1), by(objectid)
 gen comm1_unit=(comm1/comm1_max)*100
 
 egen Violence_max = max(Violence), by(objectid)
 gen Violence_unit=(Violence/Violence_max)*100
 
 egen FoodPI_max = max(FoodPI), by(objectid)
 gen FoodPI_unit=(FoodPI/FoodPI_max)*100
***

 **Local price
gen comm1_3=comm1^(1/3)

gen comm1_log=log(comm1)

gen Violence_dum=0
replace Violence_dum=1 if Violence>0

replace area=area/1000000


label variable comm1_log "Local food price"
label variable Violence_dum "Violence(dummy)"
label variable Violence "Violence"
label variable wy_Violence_1 "Spatially weighted lag violence"
label variable polity2 "Polity"
label variable Nightlight_mean "Stable nightlight"
label variable RoadDensity_mean "Road density"
label variable Diamond "Diamond mines"
label variable InfantMortality_mean "Infant mortality"
label variable Mineral "Mineral mines"
label variable Petroleum "Petroleum fields"
label variable Population_mean_ipolate "Population"
label variable area "District size"


gen comm1_log_1=l.comm1_log
label variable comm1_log_1 "Local food price"



tssmooth ma precip_mean_12 = Precip_mean, window(12 0 0)
tssmooth ma precip_mean_6 = Precip_mean, window(6 0 0)
*****

replace cultivated=cultivated/100
       
****
gen cultivated_dum=0
replace cultivated_dum=1 if cultivated>.4349704

******
gen Cult_Globe_mean=.

replace Cult_Globe_mean=Cult_Globe2009_mean if Year==2009
replace Cult_Globe_mean=Cult_Globe2009_mean if Year>2009
replace Cult_Globe_mean=Cult_Globe2006_mean if Year==2006
replace Cult_Globe_mean=Cult_Globe2006_mean if Year<2006


by objectid: ipolate Cult_Globe_mean Year, gen(Cult_Globe_mean_ipolate)


xtile cultivated_quart = cultivated, nq(4)
xtile Cult_Globe_mean_quart = Cult_Globe_mean, nq(4)


***Summary table
set matsize 11000
outreg2 using Table1.doc if comm1_log_1!=., replace sum(log) label ///
keep(Violence_dum Violence comm1_log_1 wy_Violence_1 cultivated polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)


xtlogit Violence_dum Violence_1 c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area, re vce(cluster objectid)

outreg2 using Table2.doc, replace ctitle(RE)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

margins, at(c.comm1_log_1=(-3(.5)11)) atmeans predict(pu0)

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(xtlogit, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


 
xtlogit Violence_dum Violence_1 c.cultivated##c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area, re vce(cluster objectid)

outreg2 using Table2.doc, append ctitle(RE)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes ) addstat(Loglikelihood, e(ll))  label 

margins, dydx(comm1_log_1) at(cultivated=(0(.1)1)) atmeans predict(pu0)

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Cultivated land) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1) yline(0)  saving(xtlogitConditional, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


xtlogit Violence_dum Violence_1 c.comm1_log_1##cultivated_quart ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area, re vce(cluster objectid)

outreg2 using Table2.doc, append ctitle(RE)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes ) addstat(Loglikelihood, e(ll))  label 

margins cultivated_quart, at(c.comm1_log_1=(-3(.5)11)) atmeans predict(pu0) 

marginsplot, by(cultivated_quart) saving(xtlogitConditionalQuar, replace) ///
recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)   ///
 graphregion(color(white)) bgcolor(white) scheme(plotplainblind)
 
 
**

melogit Violence_dum Violence_1 c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area || objectid:, vce(cluster objectid)

outreg2 using Table2.doc, append ctitle(ML)  symbol(**,*,+) addtext(Clustered errors, Yes, Robust errors, No, Multilevel, 1st Admin) addstat(Loglikelihood, e(ll))  label 

margins, at(c.comm1_log_1=(-3(.5)11)) atmeans predict(mu fixed)

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(melogit, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


melogit Violence_dum  c.cultivated##c.comm1_log_1 ///
 Violence_1 wy_Violence_1 Nightlight_mean RoadDensity_mean polity2 c.polity2#c.polity2 Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area || objectid:, vce(cluster objectid)

outreg2 using Table2.doc, append ctitle(ML)  symbol(**,*,+) addtext(Clustered errors, Yes, Robust errors, No, Multilevel, 1st Admin) addstat(Loglikelihood, e(ll))  label  

margins, dydx(comm1_log_1) at(cultivated=(0(.1)1)) atmeans predict(mu fixed)

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Cultivated land) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1) yline(0)  saving(melogitConditional, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


 
melogit Violence_dum  c.comm1_log_1##cultivated_quart  ///
 Violence_1 wy_Violence_1 Nightlight_mean RoadDensity_mean polity2 c.polity2#c.polity2 Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area || objectid:, vce(cluster objectid)

outreg2 using Table2.doc, append ctitle(ML)  symbol(**,*,+) addtext(Clustered errors, Yes, Robust errors, No, Multilevel, 1st Admin) addstat(Loglikelihood, e(ll))  label  

margins cultivated_quart, at(c.comm1_log_1=(-3(.5)11)) atmeans predict(mu fixed) 

marginsplot, by(cultivated_quart) ///
recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(melogitConditionalQuar, replace) ///
 graphregion(color(white)) bgcolor(white) scheme(plotplainblind)

 
**poisson vs nbreg

poisson Violence Violence_1 c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area

estat gof 
**For a manual for interpreting these results, you may check STATA nbreg
nbreg Violence Violence_1 c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area

**\alpha is significantly different from 0. Check STATA nbreg manual for analyzing these results

**

menbreg Violence Violence_1 c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area || objectid:, vce(cluster objectid)

outreg2 using Table2.doc, append ctitle(ML-Count)  symbol(**,*,+) addtext(Clustered errors, Yes, Robust errors, No, Multilevel, 1st Admin) addstat(Loglikelihood, e(ll))  label  

margins, at(c.comm1_log_1=(-3(.5)11)) atmeans predict(mu fixed)

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(menbreg, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


menbreg Violence Violence_1 c.cultivated##c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area || objectid:, vce(cluster objectid)

outreg2 using Table2.doc, append ctitle(ML-Count)  symbol(**,*,+) addtext(Clustered errors, Yes, Robust errors, No, Multilevel, 1st Admin) addstat(Loglikelihood, e(ll))  label  

margins, dydx(comm1_log_1) at(cultivated=(0(.1)1)) atmeans predict(mu fixed)

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Cultivated land) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1) yline(0)  saving(menbregConditional, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


menbreg Violence Violence_1 c.comm1_log_1##cultivated_quart ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area || objectid:, vce(cluster objectid)

outreg2 using Table2.doc, append ctitle(ML-Count)  symbol(**,*,+) addtext(Clustered errors, Yes, Robust errors, No, Multilevel, 1st Admin) addstat(Loglikelihood, e(ll))  label  


margins cultivated_quart, at(c.comm1_log_1=(-3(.5)11)) atmeans predict(mu fixed)  
 
marginsplot, by(cultivated_quart) ///
recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(menbregConditionalQuar, replace) ///
 graphregion(color(white)) bgcolor(white) scheme(plotplainblind)

 
 **
ivprobit Violence_dum Violence_1  ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area ///
(c.comm1_log_1=l2.precip_mean_6 l2.FoodPI),  vce(r) first 

outreg2 using Table2.doc, append ctitle(IV-incident)  symbol(**,*,+) addtext(Clustered errors, No, Robust errors, No, Multilevel, 1st Admin) addstat(Loglikelihood, e(ll))  label  

ivpoisson cfunction Violence Violence_1  ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area ///
(c.comm1_log_1=l2.precip_mean_6 l2.FoodPI), vce(r) 

outreg2 using Table2.doc, append ctitle(IV-count)  symbol(**,*,+) addtext(Clustered errors, No, Robust errors, No, Multilevel, 1st Admin)  label  

gr combine xtlogit.gph melogit.gph menbreg.gph
gr combine xtlogitConditional.gph melogitConditional.gph menbregConditional.gph

*********
***********
*********

***Appendix

reg Violence_dum Violence_1 c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month ,  vce(r)

outreg2 using TableA1.doc, replace ctitle(OLS)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1 wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)

margins, at(c.comm1_log_1=(-3(.5)11)) atmeans 

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(OLS-dum, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)



reg Violence_dum Violence_1 c.cultivated##c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month,  vce(r)

outreg2 using TableA1.doc, append ctitle(OLS)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.cultivated##c.comm1_log_1 wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)

margins, dydx(comm1_log_1) at(cultivated=(0(.1)1)) atmeans 

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Cultivated land) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1) yline(0)  saving(OLS-Dum-Cond1, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)

reg Violence_dum Violence_1 c.comm1_log_1##i.cultivated_quart ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month,  vce(r)
 
outreg2 using TableA1.doc, append ctitle(OLS)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1##i.cultivated_quart wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)


margins i.cultivated_quart, at(c.comm1_log_1=(-3(.5)11)) atmeans


marginsplot,  by(cultivated_quart) ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash))  saving(OLS-Dum-Cond2, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


reg Violence Violence_1 c.comm1_log_1  ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month,  vce(r)

outreg2 using TableA1.doc, append ctitle(OLS-Count)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1 wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)

margins, at(c.comm1_log_1=(-3(.5)11)) atmeans 

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(OLS-count, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


reg Violence Violence_1 c.comm1_log_1 c.cultivated##c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month,  vce(r)

outreg2 using TableA1.doc, append ctitle(OLS-Count)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1 c.cultivated##c.comm1_log_1 wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)

margins, dydx(comm1_log_1) at(cultivated=(0(.1)1)) atmeans 

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Cultivated land) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1) yline(0)  saving(OLS-count-Cond1, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)

reg Violence Violence_1 c.comm1_log_1##cultivated_quart ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month,  vce(r)

outreg2 using TableA1.doc, append ctitle(OLS-Count)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1 c.comm1_log_1##cultivated_quart wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)

margins i.cultivated_quart, at(c.comm1_log_1=(-3(.5)11)) atmeans


marginsplot,  by(cultivated_quart) ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash))  saving(OLS-count-Cond2, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)



*******Fixed-Effect models

xtreg Violence_dum Violence_1 c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month, fe vce(r)

outreg2 using TableA1.doc, append ctitle(FE)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label  ///
keep(Violence_1 c.comm1_log_1 c.comm1_log_1 wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)

margins, at(c.comm1_log_1=(-3(.5)11)) atmeans

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(FE-dum, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


xtreg Violence_dum Violence_1  c.cultivated##c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month, fe vce(r)

outreg2 using TableA1.doc, append ctitle(FE)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label  ///
keep(Violence_1 c.comm1_log_1 c.cultivated##c.comm1_log_1 wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)

margins, dydx(comm1_log_1) at(cultivated=(0(.1)1)) atmeans 

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Cultivated land) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1) yline(0)  saving(FE-Dum-Cond1, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


xtreg Violence_dum Violence_1 c.comm1_log_1##cultivated_quart ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month, fe vce(r)

outreg2 using TableA1.doc, append ctitle(FE)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1 c.comm1_log_1##cultivated_quart wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)


margins i.cultivated_quart, at(c.comm1_log_1=(-3(.5)11)) atmeans

marginsplot,  by(cultivated_quart) ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash))  saving(FE-dum-Cond2, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


xtreg Violence Violence_1 c.comm1_log_1  ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month, fe vce(r)

outreg2 using TableA1.doc, append ctitle(FE-Count)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1 c.comm1_log_1 wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)

margins, at(c.comm1_log_1=(-3(.5)11)) atmeans 

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(-3(2)11) xmtick(-3(1)11) yline(0)  saving(FE-count, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)


xtreg Violence Violence_1 c.cultivated##c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month, fe vce(r)


outreg2 using TableA1.doc, append ctitle(FE-Count)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1 c.cultivated##c.comm1_log_1 wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)


margins, dydx(comm1_log_1) at(cultivated=(0(.1)1)) atmeans 

marginsplot, ytitle(Pr(Violence against civilians)) xtitle(Cultivated land) ///
 recast(line)  ciopts(recast(rline) lpattern(dash)) xlabel(0(.2)1) xmtick(0(.1)1) yline(0)  saving(FE-count-Cond1, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)



xtreg Violence Violence_1 c.comm1_log_1##cultivated_quart ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month, fe vce(r)

outreg2 using TableA1.doc, append ctitle(FE-Count)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
keep(Violence_1 c.comm1_log_1 c.comm1_log_1##cultivated_quart wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area)


margins i.cultivated_quart, at(c.comm1_log_1=(-3(.5)11)) force


marginsplot,  by(cultivated_quart) ytitle(Pr(Violence against civilians)) xtitle(Local food price(log)) ///
 recast(line)  ciopts(recast(rline) lpattern(dash))  saving(FE-count-Cond2, replace) ///
 graphregion(color(white)) bgcolor(white) level(90) scheme(plotplainblind)

 
**Checking multicollinearity
reg Violence_dum Violence_1 c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month ,  vce(r)

estat vif

reg Violence_dum Violence_1 c.comm1_log_1 c.cultivated##c.comm1_log_1 ///
wy_Violence_1 polity2 c.polity2#c.polity2 Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month,  vce(r)

estat vif 

*************************************************
xtreg Violence_dum c.comm1_log_1  ///
i.Month, fe vce(r)

outreg2 using TableA2.doc, replace ctitle(Binary) keep(comm1_log_1) symbol(**,*,+) addtext(Month FE, Yes, Year FE, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

xtreg Violence c.comm1_log_1  ///
i.Month, fe vce(r)

outreg2 using TableA2.doc, append ctitle(Count) keep(comm1_log_1) symbol(**,*,+) addtext(Month FE, Yes, Year FE, Yes, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label 

xtlogit Violence_dum c.comm1_log_1   ///
i.Month , fe

outreg2 using TableA2.doc, append ctitle(Binary) keep(comm1_log_1) symbol(**,*,+) addtext(Month FE, Yes, Year FE, Yes, Robust errors, ) addstat(Loglikelihood, e(ll))  label 

xtnbreg Violence c.comm1_log_1 ///
i.Month, fe 

outreg2 using TableA2.doc, append ctitle(Count) keep(comm1_log_1) symbol(**,*,+) addtext(Month FE, Yes, Year FE, Yes, Robust errors, ) addstat(Loglikelihood, e(ll))  label 

******


xtreg Violence_dum Violence_1 c.comm1_log_1##c.polity2 ///
wy_Violence_1 cultivated Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month, fe vce(r)

outreg2 using TableA3.doc, replace ctitle(FE)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label  ///
drop(i.Month)


xtreg Violence Violence_1 c.comm1_log_1##c.polity2  ///
wy_Violence_1 cultivated Nightlight_mean RoadDensity_mean Diamond InfantMortality_mean Mineral Petroleum Population_mean_ipolate area i.Month, fe vce(r)

outreg2 using TableA3.doc, append ctitle(FE-Count)  symbol(**,*,+) addtext(Clustered errors, 1st Admin, Robust errors, Yes) addstat(Loglikelihood, e(ll))  label ///
drop(i.Month)
