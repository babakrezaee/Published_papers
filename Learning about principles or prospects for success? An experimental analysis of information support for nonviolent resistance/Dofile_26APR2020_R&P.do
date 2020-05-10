**********************************************************************************
**********************************************************************************
**********************************************************************************

* This STATA do file and "Spread the word_January 10, 2017_16.52.csv" replicate the below paper:

* Learning about principles or prospects for success? An experimental analysis of information support for nonviolent resistance

** Authors:
* Babak RezaeeDaryakenari and Peyman Asadzade

* The experiment was approved by Arizona State University’s Institutional Review Board (IRB): STUDY00004488 on 16 June 2016

**********************************************************************************
**********************************************************************************
**********************************************************************************

*Note:

*net install http://www.stata.com/users/kcrow/tab2xl, replace


cd "C:\~"

import delimited "Spread the word_January 10, 2017_16.52_R&P.csv", varnames(1) clear 


rename q5_1 DOB
label var DOB "Date of Birth"
destring DOB, replace
rename q6 Gender
label var Gender "Gender"
replace Gender="1" if Gender=="Male"
replace Gender="2" if Gender=="Female"
replace Gender="3" if Gender=="Prefer not to disclose"
destring Gender, replace

label define GenderLabel 1 "Male" 2 "Female" 3 "Prefer not to disclose"
label values Gender GenderLabel


rename q7 Marriage
label var Marriage "Marriage"
replace Marriage="1" if Marriage=="Single"
replace Marriage="2" if Marriage=="Married"
replace Marriage="3" if Marriage=="Prefer not to disclose"
destring Marriage, replace

label define MarriageLabel 1 "Single" 2 "Married" 3 "Prefer not to disclose"
label values Marriage MarriageLabel

rename q8 Ethnicity
label var Ethnicity "Ethnicity"
rename q9_1 Nationality
label var Nationality "Nationality"
rename q10_1 Religiosity
label var Religiosity "Religiosity"
destring Religiosity, replace
rename q11_1 Education_Col
label var Education_Col "Education(College)"
destring Education_Col, replace
rename q11_2 Education_Grad
label var Education_Grad "Education(Graduate)"
destring Education_Grad, replace
gen Education=Education_Col+Education_Grad
rename q12 Income
label var Income "Income"

rename q13_1 Gandhi
label var Gandhi "Gandhi"
destring Gandhi, replace
rename q13_2 Mandela
label var Mandela "Mandela"
destring Mandela, replace
rename q13_3 Che
label var Che "Che"
destring Che, replace
rename q13_4 MLK
label var MLK "MLK"
destring MLK, replace
rename q13_5 MalcomX
label var MalcomX "MalcomX"
destring MalcomX, replace

gen PastNonViolence=Gandhi+Mandela+MLK-Che-MalcomX

gen Pre_nonviolent = cond(missing(Gandhi), 0, Gandhi) + ///
 cond(missing(Mandela), 0, Mandela) + cond(missing(MLK), 0, MLK)- ///
 cond(missing(Che), 0, Che)- cond(missing(MalcomX), 0, MalcomX)
 
 egen n=rownonmiss(Gandhi Mandela Che MLK MalcomX)
 
 
 gen Pre_nonviolent_avg=Pre_nonviolent/n


rename q14_1 AshtonCarter
replace AshtonCarter="1" if strpos(lower(AshtonCarter),"defense")>0 ///
	| strpos(lower(AshtonCarter),"defense")>0 ///
	| strpos(lower(AshtonCarter),"def")>0 ///
	| strpos(lower(AshtonCarter),"sod")>0	///
	| strpos(lower(AshtonCarter),"denfense")>0
replace AshtonCarter="0" if AshtonCarter!="1"
destring AshtonCarter, replace

rename q14_2 Majority
replace Majority="1" if strpos(lower(Majority),"connel")>0 ///
	| strpos(lower(Majority),"conel")>0 ///
	| strpos(lower(Majority),"connal")>0 ///
	| strpos(lower(Majority),"conoll")>0
replace Majority="0" if Majority!="1"
destring Majority, replace

	
rename q14_3 Justice
replace Justice="1" if strpos(lower(Justice),"robert")>0
replace Justice="0" if Justice!="1"
destring Justice, replace


rename q14_4 House
replace House="1" if strpos(lower(House),"rep")>0 ///
| strpos(lower(House),"gop")>0 | House=="R" | House=="Rebulblican"
replace House="0" if House!="1"	
destring House, replace


rename q16 Constitutional
replace Constitutional="1" if Constitutional=="The Supreme Court"
replace Constitutional="0" if Constitutional!="1"	
destring Constitutional, replace 

gen Poli_Knowledge=((AshtonCarter+Majority+Justice+House+Constitutional)/5)*100

label var Poli_Knowledge "Political Knowledge"


gen Treatment=.
replace Treatment=0 if q22_pagesubmit!=.
replace Treatment=1 if q24_pagesubmit!=.
replace Treatment=2 if q23_pagesubmit!=.

drop if Treatment==.

label define TreatmentLabel 0 "Control" 1 "Principles" 2 "Success"
label values Treatment TreatmentLabel


rename q25_1 Violent_method
label var Violent_method "Violent method"
destring Violent_method, replace

gen Violent_method_dum=0
replace Violent_method_dum=1 if Violent_method>5


rename q26_1 Nonviolent_effective
label var Nonviolent_effective "Nonviolent Success"
destring Nonviolent_effective, replace

rename q27_1 Nonviolent_moral
label var Nonviolent_moral "Nonviolent moral"
destring Nonviolent_moral, replace

rename q28_1 Nonviolent_time
label var Nonviolent_time "Nonviolent time-consuming"
destring Nonviolent_time, replace

rename q29_1 Violent_allocation
label var Violent_allocation "Violent allocation"
destring Violent_allocation, replace




replace Ethnicity="Middle Eastern" if Ethnicity=="Arab Middle Eastern or Arab American"
replace Ethnicity="Black" if Ethnicity=="Black, Afro-Caribbean, or African American"
replace Ethnicity="Asian" if Ethnicity=="East Asian or Asian American"
replace Ethnicity="Latino" if Ethnicity=="Latino or Hispanic American"
replace Ethnicity="Non-Hispanic White" if Ethnicity=="Non-Hispanic White or Euro-American"
replace Ethnicity="Other" if Ethnicity=="Prefer not to disclose"
replace Ethnicity="Asian" if Ethnicity=="South Asian or Indian American"
replace Ethnicity="Other" if Ethnicity=="Native American or Alaskan Native"
replace Ethnicity="Middle Eastern" if Ethnicity=="Non-Arab Middle Eastern or Non-Arab Middle Eastern-American"


replace Income="$1501-$2500" if Income=="$1501-$2000" 
replace Income="$1501-$2500" if Income=="$2001-$2500" 
replace Income="$2501 and more" if Income=="$2501-$3000"
replace Income="$2501 and more" if Income=="$3001 and more" 

replace Nationality="United States" if Nationality=="USA Government"
replace Nationality="United States" if Nationality=="Guam (USA)"

gen Age=2016-DOB

egen Income_ID = group(Income)
egen Ethnicity_ID = group(Ethnicity)
egen Nationality_ID = group(Nationality)

gen Month = substr(startdate, 6, 2)
destring Month, replace
gen Month_ID=0
replace Month_ID=1 if Month>6

export delimited using "ExperimentDataRefined_STATA", replace

***
* Re-sclae violent based outcomes to make the comparison easier.
gen Violent_method_rescaled=11-Violent_method
gen Violent_alloc_rescaled=11-Violent_allocation
***


foreach var of varlist Gender Marriage  ///
   {

*tabplot `var' Treatment , percent(Treatment) showval subtitle(% of Treatment) xtitle("") bfcolor(none) scheme(burd)

catplot `var' Treatment , percent(Treatment) asyvars ///
 stack subtitle(% of Treatment) legend(size(small) position(6) cols(3)) scheme(538)

gr export "Graphs\catplot_`var'.tif", replace
}


foreach var of varlist Ethnicity Nationality Income ///
   {

*tabplot `var' Treatment , percent(Treatment) showval subtitle(% of Treatment) xtitle("") bfcolor(none) scheme(burd)

catplot `var' Treatment , percent(Treatment) asyvars ///
 stack subtitle(% of Treatment) legend(size(small) position(6) cols(4)) scheme(538)

gr export "Graphs\catplot_`var'.tif", replace
}

foreach var of varlist Age Religiosity Education Gandhi Mandela Che MLK MalcomX Poli_Knowledge {
graph hbox `var', over(Treatment) ///
  scheme(538) box(1, bfcolor(maroon%90) blcolor(black) lwidth(medium)) ///
   saving("Graphs\boxplot_`var'", replace)
*gr export "Figures\boxplot_`var'.pdf", replace
}

gr combine "Graphs\boxplot_Age.gph" "Graphs\boxplot_Religiosity.gph"  ///
			"Graphs\boxplot_Education.gph" "Graphs\boxplot_Poli_Knowledge.gph",  scheme(538)

gr export "Graphs\boxplots_SocioEcon.tif", replace			
		
gr combine "Graphs\boxplot_Gandhi.gph" "Graphs\boxplot_Mandela.gph" ///
			"Graphs\boxplot_Che.gph" "Graphs\boxplot_MalcomX.gph" ///
			"Graphs\boxplot_MLK.gph" , scheme(538) title("Favorite political figures")
			 

gr export "Graphs\boxplots_FavoritePoliticalFigures.tif", replace
   
   
   
foreach y of varlist Age Religiosity Education Gandhi Mandela Che MLK MalcomX Poli_Knowledge {
 
rm "Graphs/boxplot_`y'.gph"

}  


hist Violent_method_rescaled, percent  xtitle("Preference for nonviolent resistance") ///
		lcolor(black%50) fcolor(cranberry%100) lwidth(medium) scheme(538)  xlabel(1(1)10) 
		
hist Violent_alloc_rescaled,  percent xtitle("Resource allocation to nonviolent methods") ///
		lcolor(black%50) fcolor(cranberry%100) lwidth(medium) scheme(538) xlabel(1(1)10) 

		


foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time {
	
		
		egen mean_`y' = mean(`y'), by(Treatment)
		egen SD_`y' = sd(`y'), by(Treatment)
		
}

foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time {
	
		stripplot `y' , box center vertical cumul cumprob over(Treatment) ysc(log) ///
		addplot(scatter mean_`y' Treatment,  msize(*1)) xla(, noticks) yla(, ang(h)) xtitle("") ytitle("") title(`y') ///
		saving("Graphs/stripplot_`y'.gph", replace) scheme(538)
		
}

gr combine "Graphs\stripplot_Violent_method_rescaled.gph" "Graphs\stripplot_Violent_alloc_rescaled.gph" "Graphs\stripplot_Nonviolent_effective.gph" "Graphs\stripplot_Nonviolent_moral.gph"  ///
		   "Graphs\stripplot_Nonviolent_time.gph" ///
		   , scheme(538) col(3) imargin(2 3 1.5 1.5) b1(Treatment) l1() ///
		   saving("Graphs/stripplot", replace)
		   

		   
***************** Regression analysis **********************************

eststo clear 

foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time {

eststo: reg `y' i.Treatment , r cluster(Nationality_ID )

estimates store OLS_`y'

margins Treatment, level(90) 

mat Results_tbl=r(table)
scalar CI_l=Results_tbl[5,1]
scalar CI_u=Results_tbl[6,1]   


marginsplot, level(90) yline(`=scalar(CI_l)' `=scalar(CI_u)',lcolor(cranberry) lwidth(medthick)) ///
				scheme(538) recast(scatter) ciopts(lwidth(thick) lcolor(dknavy)) title("`y'", size(small))  ///
				saving("Graphs/`y'.gph", replace) xtitle("") ytitle("")
				*horizontal

}


** Coefplots

coefplot (OLS_Violent_method_rescaled,  ciopts(lwidth(vthick) lcolor(dknavy))  keep(_cons *.Treatment) ) || ///
		 (OLS_Violent_alloc_rescaled,   ciopts(lwidth(vthick) lcolor(dknavy)) keep(_cons *.Treatment) ) || ///
		 (OLS_Nonviolent_effective,  ciopts(lwidth(vthick) lcolor(dknavy)) keep(_cons *.Treatment) ) || ///
		 (OLS_Nonviolent_moral,  ciopts(lwidth(vthick) lcolor(dknavy)) keep(_cons *.Treatment) ) || ///
		 (OLS_Nonviolent_time,  ciopts(lwidth(vthick) lcolor(dknavy)) keep(_cons *.Treatment) ) ///
			, drop(_cons) xline(0, lcolor(cranberry) lwidth(medthick)) level(95) scheme(538) legend(position(6) row(1)) ///
			msymbol(d) mcolor(white) msize(large) ///
			byopts(compact cols(1)) subtitle(, size(small) margin(small) justification(left) color(white) bcolor(black) ) ///
			saving("Graphs\CoefPlot_noControl_All.gph", replace)
			
** marginal plots

gr combine "Graphs\Violent_method_rescaled.gph" "Graphs\Violent_alloc_rescaled.gph" ///
		"Graphs\Nonviolent_effective.gph" "Graphs\Nonviolent_moral.gph"  ///
		   "Graphs\Nonviolent_time.gph" ///
		   , scheme(538) col(3) imargin(2 3 1.5 1.5) b1(Treatment) l1(Linear prediction) ycommon ///
		   saving("Graphs/Marginsplot_noControl", replace)

 
eststo clear 

foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time {

eststo: reg `y' i.Treatment Education Poli_Knowledge Age Religiosity i.Gender i.Marriage i.Income_ID i.Ethnicity_ID i.Month_ID  Pre_nonviolent_avg, r cluster(Nationality_ID )

estimates store OLS_`y'

predict `y'_resHat, res

margins Treatment, level(90) 

mat Results_tbl=r(table)
scalar CI_l=Results_tbl[5,1]
scalar CI_u=Results_tbl[6,1]   


marginsplot, level(90) yline(`=scalar(CI_l)' `=scalar(CI_u)',lcolor(cranberry) lwidth(medthick)) ///
				scheme(538) recast(scatter) ciopts(lwidth(thick) lcolor(dknavy)) title("`y'", size(small))  ///
				saving("Graphs/`y'.gph", replace) xtitle("") ytitle("")
				*horizontal

}


** Coefplots

coefplot (OLS_Violent_method_rescaled,  ciopts(lwidth(vthick) lcolor(dknavy))  keep(_cons *.Treatment) ) || ///
		 (OLS_Violent_alloc_rescaled,   ciopts(lwidth(vthick) lcolor(dknavy)) keep(_cons *.Treatment) ) || ///
		 (OLS_Nonviolent_effective,  ciopts(lwidth(vthick) lcolor(dknavy)) keep(_cons *.Treatment) ) || ///
		 (OLS_Nonviolent_moral,  ciopts(lwidth(vthick) lcolor(dknavy)) keep(_cons *.Treatment) ) || ///
		 (OLS_Nonviolent_time,  ciopts(lwidth(vthick) lcolor(dknavy)) keep(_cons *.Treatment) ) ///
			, drop(_cons) xline(0, lcolor(cranberry) lwidth(medthick)) level(95) scheme(538) legend(position(6) row(1)) ///
			msymbol(d) mcolor(white) msize(large) ///
			byopts(compact cols(1)) subtitle(, size(small) margin(small) justification(left) color(white) bcolor(black) ) ///
			saving("Graphs\CoefPlot_All.gph", replace)
			
** marginal plots

gr combine "Graphs\Violent_method_rescaled.gph" "Graphs\Violent_alloc_rescaled.gph" ///
		"Graphs\Nonviolent_effective.gph" "Graphs\Nonviolent_moral.gph"  ///
		   "Graphs\Nonviolent_time.gph" ///
		   , scheme(538) col(3) imargin(2 3 1.5 1.5) b1(Treatment) l1(Linear prediction) ycommon ///
		   saving("Graphs/Marginsplot_AllControl", replace)

		   
foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time  {
 
rm "Graphs/`y'.gph"

}

foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time  {
 
kdensity `y'_resHat, normal scheme(538) note("") title(`y') xtitle("") ytitle("") ///
		saving("Graphs/kdensity_`y'", replace)

}

grc1leg "Graphs\kdensity_Violent_method_rescaled.gph" "Graphs\kdensity_Violent_alloc_rescaled.gph" ///
			"Graphs\kdensity_Nonviolent_effective.gph" "Graphs\kdensity_Nonviolent_moral.gph"  ///
			"Graphs\kdensity_Nonviolent_time.gph" ///
		   , b2(OLS residuals) l1(Density) imargin(2 3 1.5 1.5) ///
		   legendfrom("Graphs\kdensity_Violent_method_rescaled.gph") col(2) scheme(538) ///
		   saving("Graphs/kdensity_all", replace)
		 
			 
esttab using "Tables\MainTable.rtf", replace  varwidth(30) ///
				s(N ll chi2, label("N" "Log-likelihood" "chi2")) ///
		nobaselevels interaction(" X ") noomitted label ///
		nonumbers  ///
		compress nogap	star(* 0.10 ** 0.05 *** 0.01) ///
		b(%5.3f) se  ///
		coeflabels(_cons "Intercept" 5.Income_ID "$501-$1000" 2.Income_ID "$1001-$1500" 3.Income_ID "$1501-$2500" 4.Income_ID "$2501 and more" 6.Income_ID "Prefer not to disclose"  ///
					2.Ethnicity_ID "Black" 3.Ethnicity_ID "Latino"  4.Ethnicity_ID "Middle Eastern" 5.Ethnicity_ID "Non-Hispanic White" 6.Ethnicity_ID "Other"  ) ///
					order(1.Treatment 2.Treatment Education Poli_Knowledge Age Religiosity  ///
					2.Gender 3.Gender 2.Marriage 3.Marriage Pre_nonviolent_avg 5.Income_ID 2.Income_ID 3.Income_ID 4.Income_ID 6.Income_ID)
					
		
eststo clear 

foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time {

eststo:  reg `y' i.Treatment##i.Gender Education Poli_Knowledge Age Religiosity  i.Marriage i.Income_ID i.Ethnicity_ID i.Month_ID  Pre_nonviolent_avg if Gender!=3, r cluster(Nationality_ID)
 
margins Treatment#Gender if Gender!=3 , level(90) 

mat Results_tbl=r(table)
scalar CI_l=Results_tbl[5,1]
scalar CI_u=Results_tbl[6,1]   


mplotoffset, level(90) yline(`=scalar(CI_l)' `=scalar(CI_u)',lcolor(cranberry) lwidth(medthick)) ///
				legend(row(1) position(6)) scheme(538) recast(scatter) ciopts(lwidth(thick) ) offset(0.1) title("`y'", size(small)) ///
				plot1opts(msymbol(d) mcolor(dknavy) mlwidth(thick)  lcolor(dknavy) lwidth(thick) ) ///
				plot2opts(msymbol(c) mcolor(dknavy) mlwidth(thick)  lcolor(blue) lwidth(thick) ) ///
				ci1opts(lcolor("0 75 135") lwidth(thick) ) xtitle("") ytitle("") ///
				saving("Graphs/`y'_gender.gph", replace) 
				*horizontal

}

		   

grc1leg "Graphs\Violent_method_rescaled_gender.gph" "Graphs\Violent_alloc_rescaled_gender.gph" ///
		"Graphs\Nonviolent_effective_gender.gph" "Graphs\Nonviolent_moral_gender.gph" ///
		    "Graphs\Nonviolent_time_gender.gph" ///
		     , legendfrom("Graphs\Violent_method_rescaled_gender.gph") ///
			 scheme(538) col(2) imargin(2 3 1.5 1.5) b1(Treatment) l1(Linear prediction) ycommon ///
			 saving("Graphs/Marginsplot_All_gender", replace)
		   
	
foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time {
 
rm "Graphs/`y'_gender.gph"

}

****** Prior knowledge	
	
eststo clear 

foreach y of varlist Violent_method_rescaled Violent_alloc_rescaled Nonviolent_effective Nonviolent_moral Nonviolent_time {

eststo:  reg `y' i.Treatment##c.Pre_nonviolent_avg   i.Gender Education Poli_Knowledge Age Religiosity  i.Marriage i.Income_ID i.Ethnicity_ID i.Month_ID  Pre_nonviolent_avg, r cluster(Nationality_ID)
 
margins Treatment, at(Pre_nonviolent_avg=(0(1)10)) level(90) 

mat Results_tbl=r(table)
scalar CI_l=Results_tbl[5,1]
scalar CI_u=Results_tbl[6,1]   


marginsplot, level(90)  ///
				legend(row(1) position(6)) scheme(538)  title("`y'", size(small)) ///
				 xtitle("") ytitle("") ///
				saving("Graphs/`y'_Pre_nonviolent.gph", replace) 
				*horizontal

}


grc1leg "Graphs\Violent_method_rescaled_Pre_nonviolent.gph" "Graphs\Violent_alloc_rescaled_Pre_nonviolent.gph"   ///
		"Graphs\Nonviolent_effective_Pre_nonviolent.gph" "Graphs\Nonviolent_moral_Pre_nonviolent.gph"  ///
		   "Graphs\Nonviolent_time_Pre_nonviolent.gph" ///
		   , legendfrom("Graphs\Violent_method_rescaled_Pre_nonviolent.gph") col(2) scheme(538) ///
		   saving("Graphs/Marginsplot_All_PreNonViolent.gph", replace) 
		    
*** power analysis ****
tab Treatment, sum(Violent_method_rescaled)

power twomeans 7 (7.28 7.42 7.56), sd(2.463) n(100 200 300 400 500 )  alpha(.1) onesided ///
		graph(scheme(538) saving("Graphs/PowerAnalysis", replace) ///
		legend(label(1 "Males") label(2 "Females") position(6) row(1) ) ///
		note("") title(""))

  
***************** Checking the balance *************************************************
	
putexcel set "T-test_principles.xlsx", sheet("t_test") replace
putexcel A1=("Variable") B1=("Control (Mean)") C1=("Control (SD)") D1=("Treatment (Mean)") E1=("Treatment(SD)") F1=("p value")

local row=2
foreach var of varlist Education Poli_Knowledge Age Religiosity Pre_nonviolent_avg{

   qui ttest `var' if Treatment!=2, by(Treatment)
   
putexcel A`row' = ("`var'")
putexcel B`row' = (r(mu_1))
putexcel C`row' = (r(sd_1))
putexcel D`row' = (r(mu_2))
putexcel E`row' = (r(sd_2))
putexcel F`row' = (r(p))
local ++row
}
	

putexcel set "T-test_success.xlsx", sheet("t_test") replace
putexcel A1=("Variable") B1=("Control (Mean)") C1=("Control (SD)") D1=("Treatment (Mean)") E1=("Treatment(SD)") F1=("p value")

local row=2
foreach var of varlist Education Poli_Knowledge Age Religiosity Pre_nonviolent_avg{

   qui ttest `var' if Treatment!=1, by(Treatment)
   
putexcel A`row' = ("`var'")
putexcel B`row' = (r(mu_1))
putexcel C`row' = (r(sd_1))
putexcel D`row' = (r(mu_2))
putexcel E`row' = (r(sd_2))
putexcel F`row' = (r(p))
local ++row
}


***

tab Gender Treatment

tab Marriage Treatment

tab Income_ID Treatment

tab Ethnicity_ID Treatment

tab Month_ID Treatment

tab2xl Gender Treatment using TabGender, col(1) row(1)

tab2xl  Marriage Treatment using TabMarriage, col(1) row(1)

tab2xl Income_ID Treatment using TabIncome_ID, col(1) row(1)

tab2xl Ethnicity_ID Treatment using TabEthnicity_ID, col(1) row(1)

tab2xl Month_ID Treatment using TabMonth_ID, col(1) row(1)

************************************************

teffects ipw   (Violent_method) ///
(Treatment Education Poli_Knowledge Age Religiosity i.Gender i.Marriage i.Income_ID i.Ethnicity_ID i.Month_ID  Pre_nonviolent_avg) if Treatment!=2 & Gender!=3 , ///
  vce(r) level(90)
  
  tebalance overid 
tebalance summarize
  
 teffects ipw   (Violent_allocation) ///
(Treatment Education Poli_Knowledge Age Religiosity i.Gender i.Marriage i.Income_ID i.Ethnicity_ID i.Month_ID  Pre_nonviolent_avg) if Treatment!=1 & Gender!=3 , ///
  vce(r) level(90)

   tebalance overid 
   tebalance summarize

  
eststo clear 
foreach y of varlist Violent_method Nonviolent_effective Nonviolent_moral Nonviolent_time Violent_allocation {

 
eststo: teffects ipw   (`y') ///
(Treatment Education Poli_Knowledge Age Religiosity i.Gender  i.Marriage i.Income_ID  i.Ethnicity_ID i.Month_ID Pre_nonviolent_avg)  if Treatment!=2 & Gender!=3 , ///
  vce(r) level(90)

estimates store `y'_prin

tebalance overid 
tebalance summarize 
 mat A1 = r(table)
 mat list r(table)

eststo: teffects ipw   (`y') ///
(Treatment Education Poli_Knowledge Age Religiosity i.Gender  i.Marriage i.Income_ID  i.Ethnicity_ID  i.Month_ID Pre_nonviolent_avg)  if Treatment!=1 & Gender!=3  , ///
 vce(r) level(90)
 
tebalance overid 
tebalance summarize

estimates store `y'_succ
}

