*set the directory
cd "E:\"
clear
set cformat %5.4f
set pformat %5.3f
***Open ACLED Version 6 All Africa 1997-2015_csv_monadic.csv

import delimited "ACLED Version 6 All Africa 1997-2015_csv_dyadic.csv", clear

**limiting data to violence aganist civilians
keep if event_typ=="Violence against civilians"
keep if inter1==2 | inter1==3 | inter1==4

export delimited using "ACLED_ViolenceCivilians.csv" , replace

********

split event_date, p(/)
gen Day=real(event_date1)
gen Month=real(event_date2)
gen Year=real(event_date3)


rename latitude Y
rename longitude X


***

foreach x in food agricultur livestock cattle good {
gen is_`x'=strpos(note,"`x'")
replace is_`x'=1 if is_`x'>0

}




foreach x in loot take taking steal stole rob target seiz get raid contribut pilag demand give provide scaveng collect look {
gen is_`x'=strpos(note,"`x'")
replace is_`x'=1 if is_`x'>0
}

gen is_make=strpos(note,"make off")
replace is_make=1 if is_make>0

gen is_hand=strpos(note,"hand over")
replace is_hand=1 if is_hand>0

gen is_carting=strpos(note,"carting away")
replace is_carting=1 if is_carting>0




foreach x in farm land field farmer village villager house boundary yard location water {
gen is_`x'=strpos(note,"`x'")
replace is_`x'=1 if is_`x'>0
}



foreach x in dispute conflict issue {
gen is_`x'=strpos(note,"`x'")
replace is_`x'=1 if is_`x'>0
}


foreach x in UN ship convey base aid transfer FAO distribut camp bring Gorfood WFP protest {
gen is_`x'=strpos(note,"`x'")
replace is_`x'=1 if is_`x'>0
}



replace is_food=0 if is_Gorfood==1


gen Land=0
replace Land=1 if is_farm==1 | is_land==1 | is_field==1 | is_house==1 | is_boundary==1 | is_yard==1 | is_location==1 | is_water==1

gen Dispute=0
replace Dispute=1 if is_dispute==1 | is_conflict==1 | is_issue==1


gen LandDispute=0
replace LandDispute=1 if Land==1 & Dispute==1




gen Food=0
replace Food=1 if is_food==1 | is_agricultur==1 | is_livestock==1 | is_cattle==1 | is_good==1

gen Loot=0
replace Loot=1 if  is_loot==1 | is_take==1 | is_taking==1 | is_steal==1 | is_stole==1 | is_rob==1 | is_target==1 | is_seiz==1 | is_get==1 | is_raid==1 | ///
 is_contribut==1 | is_pilag==1 | is_demand==1 | is_give==1 | is_provide==1 | is_scaveng==1 | is_collect==1 | is_look==1 | is_make==1 | is_hand==1 | is_carting==1

gen FoodLoot=0
replace FoodLoot=1 if Food==1 & Loot==1




 
forvalues i=1997(1)2015 {
	forvalues j=1(1)12 {
	  export delimited using "ACLED_ViolenceCivilians_`i'_`j'.csv" if Year==`i' & Month==`j', replace
	}
		
}


forvalues i=1997(1)2015 {
	forvalues j=1(1)12 {
	  export delimited using "ACLED_ViolenceCivilians_FoodLoot_`i'_`j'.csv" if Year==`i' & Month==`j' & FoodLoot==1, replace
	}
		
}

export delimited using "ACLED_ViolenceCivilians_FoodLoot.csv" if FoodLoot==1, replace

forvalues i=1997(1)2015 {
	forvalues j=1(1)12 {
	  export delimited using "ACLED_ViolenceCivilians_LandDispute_`i'_`j'.csv" if Year==`i' & Month==`j' & LandDispute==1, replace
	}
		
}

export delimited using "ACLED_ViolenceCivilians_LandDispute.csv" if LandDispute==1, replace
** We now use "https://www.dropbox.com/s/1htq2l6vxvzl5nx/Python%20code%20for%20converting%20ACLEDCVS%20to%20Layer.py?dl=0" python code to convert these CSV files to QGIS layer
*Then we use batch processing under "vector analysis tools -> Count points in polygon" to generate counted conflict monthly events per first adminstration level
**Then, we need to convert processed shape file, i.e. conflict aggregated to 1sth admin level, to CSV files to merge them in STATA. For converting layers to CSV format, we use batch save layers plugin. 


**Now we need to prepare spatially aggregated data for merging in STATA format

*********Appending ACLED violence against civilians data

forvalues i=1997(1)2015 {
	forvalues j=1(1)12 {
	import delimited "CSV\Count_ACLED_ViolenceCivilians_`i'_`j'.csv", clear 

    keep if iso==iso_2
	rename numpoints Violence
	gen Year=`i'
    gen Month=`j'
	gen modate = ym(Year, Month) 
    format  modate %tm
	keep objectid modate Violence Year Month
	save "Africa_admin1_ViolenceACLED_`i'_`j'.dta", replace
	}
}

use "Africa_admin1_ViolenceACLED_1997_1.dta", clear
    forvalues j=2(1)12 {
	  append using Africa_admin1_ViolenceACLED_1997_`j'.dta
      }

	  forvalues i=1998(1)2015 {
		forvalues j=1(1)12 {
		   append using Africa_admin1_ViolenceACLED_`i'_`j'.dta 
		   }
	  }
	  
	  save "Africa_admin1_ViolenceACLED.dta", replace

	  *************

forvalues i=1997(1)2015 {
	forvalues j=1(1)12 {
		 capture noisily import delimited "CSV\Count_ACLED_ViolenceCivilians_FoodLoot_`i'_`j'.csv", clear 
		 if _rc!=0 {
	  	display "‘i’ & `j' does not exists"
		continue
		 }
		 keep if iso==iso_2
		 rename numpoints FoodLoot
		 gen Year=`i'
		 gen Month=`j'
		 gen modate = ym(Year, Month) 
		 format  modate %tm
		 keep objectid modate FoodLoot Year Month
		 save "Africa_admin1_ViolenceACLED_FoodLoot_`i'_`j'.dta", replace
	}
}

use "Africa_admin1_ViolenceACLED_FoodLoot_1997_1.dta", clear
    forvalues j=2(1)12 {
	  capture noisily append using Africa_admin1_ViolenceACLED_FoodLoot_1997_`j'.dta
      if _rc!=0 {
	  	display "`j' does not exists"
		continue
		 }
	   
	  }

	  forvalues i=1998(1)2015 {
		forvalues j=1(1)12 {
		  capture noisily append using Africa_admin1_ViolenceACLED_FoodLoot_`i'_`j'.dta 
		  if _rc!=0 {
	  	display "‘i’ & `j' does not exists"
		continue
		 }
		  
		  }
	  }
	  
	  save "Africa_admin1_ViolenceACLED_FoodLoot.dta", replace

********************

forvalues i=1997(1)2015 {
	forvalues j=1(1)12 {
	capture noisily import delimited "CSV\Count_ACLED_ViolenceCivilians_LandDispute_`i'_`j'.csv", clear 
		if _rc!=0 {
	  	display "‘i’ & `j' does not exists"
		continue
		 }
    keep if iso==iso_2
	rename numpoints LandDispute
	gen Year=`i'
    gen Month=`j'
	gen modate = ym(Year, Month) 
    format  modate %tm
	keep objectid modate LandDispute Year Month
	save "Africa_admin1_ViolenceACLED_LandDispute_`i'_`j'.dta", replace
	}
}

use "Africa_admin1_ViolenceACLED_LandDispute_1997_12.dta", clear


	  forvalues i=1998(1)2015 {
		forvalues j=1(1)12 {
		  capture noisily append using Africa_admin1_ViolenceACLED_LandDispute_`i'_`j'.dta 
		   if _rc!=0 {
	  	display "‘i’ & `j' does not exists"
		continue
		 }
		   
		   }
	  }
	  
	  save "Africa_admin1_ViolenceACLED_LandDispute.dta", replace



*****Appending precipitation data

forvalues i=1(1)18 {
	forvalues j=1(1)12 {
	local N=`i'*`j'
	import delimited "CSV\Africa_admin1_precipitation`N'.csv", clear 
	keep if iso==iso_2
	gen Year=1996+`i'
	gen Month=`j'
	gen modate = ym(Year, Month) 
    format  modate %tm
	rename _mean Precip_mean
	keep objectid modate Precip_mean Year Month
	save "Africa_admin1_Precip_`i'_`j'.dta", replace
	}
}


use "Africa_admin1_Precip_1_1.dta", clear
    forvalues j=2(1)12 {
	  append using Africa_admin1_Precip_1_`j'.dta
      }

	  forvalues i=2(1)18 {
		forvalues j=1(1)12 {
		   append using Africa_admin1_Precip_`i'_`j'.dta 
		   }
	  }
	  
	  save "Africa_admin1_precipitation.dta", replace
*******

*******
**Appending nighlight data

forvalues i=1997(1)2013 {
	
	import delimited "CSV\Nightlight`i'.csv", clear 

    keep if iso==iso_2
	rename _mean Nightlight_mean
	gen Year=`i'
	
	keep objectid Nightlight_mean Year
	save "Africa_admin1_Nightlight`i'.dta", replace
	
}

use "Africa_admin1_Nightlight1997.dta", clear

    forvalues j=1998(1)2013 {
	  append using Africa_admin1_Nightlight`j'.dta
	  	}
	  
	  save "Africa_admin1_Nightlight.dta", replace

*******
**Appending population data

forvalues i=2000(5)2015 {
	
	import delimited "CSV\PopulationDensitygpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_`i'.csv", clear 

    keep if iso==iso_2
	rename _mean Population_mean
	gen Year=`i'
	
	keep objectid Population_mean Year
	save "Africa_admin1_Population`i'.dta", replace
	
}

use "Africa_admin1_Population2000.dta", clear

    forvalues j=2005(5)2015 {
	  append using Africa_admin1_Population`j'.dta
	  	}
	  
	  save "Africa_admin1_Population.dta", replace

*****Other time invariant datsets
**Road density
import delimited "CSV\RoadDensity.csv", clear 
keep if iso==iso_2
rename roaddensit RoadDensity_mean
keep objectid RoadDensity_mean
save "Africa_admin1_RoadDensity.dta", replace

**Diamond
import delimited "CSV\Africa_admin1_Diamond.csv", clear 
keep if iso==iso_2
rename numpoints Diamond
keep objectid Diamond
save "Africa_admin1_Diamond.dta", replace


**InfantMortality
import delimited "CSV\Africa_admin1_InfantMR.csv", clear 
keep if iso==iso_2
rename meanimr InfantMortality_mean
keep objectid InfantMortality_mean
save "Africa_admin1_InfantMR.dta", replace


**Mineral sources

import delimited "CSV\Africa_admin1_MineralSources.csv", clear 
keep if iso==iso_2
rename numpoints Mineral
keep objectid Mineral
save "Africa_admin1_MineralSources.dta", replace

***Petroleum
import delimited "CSV\Africa_admin1_Petroleum.csv", clear 
keep if iso==iso_2
rename count Petroleum
keep objectid Petroleum
save "Africa_admin1_Petroleum.dta", replace

*****************************************************
**Raleigh_Choi_Kniveton_2015 local food price

use "Raleigh_Choi_Kniveton_2015_replication.dta", clear

***There are some discrepancies in naming distrcits between Raleigh_Choi_Kniveton_2015 and GADM database of Global Administrative Areas
* These are fixed below

replace adm1="Boucle du Mouhoun" if adm1=="Banwa"
replace adm1="Centre-Ouest" if adm1=="Boulkiemd_"
replace adm1="Haut-Bassins" if adm1=="Houet"
replace adm1="Centre" if adm1=="Kadiogo"
replace adm1="Centre-Est" if adm1=="Kouritenga"
replace adm1="Sahel" if adm1=="Soum"

replace adm1="Amajyaruguru" if adm1=="Ruhengeri"

replace adm1="Mbarara" if adm1=="Kabingo"


*********************************

**We drop Kenya due to the change in the subnational adminsitrations, which may cause problem in comparing collected data in///
/// adminstratiuon by Raleigh_Choi_Kniveton_2015 and GADM database of Global Administrative Areas
*drop if country=="Kenya"

rename adm1 admin_1

gen m=substr(date, 1, 2)

gen Month=real(m)

rename year Year

rename lat y
rename long x

forvalues i=1997(1)2009 {
	forvalues j=1(1)12 {
	  export delimited using "FoodPriceRCK\RCK2015_`i'_`j'.csv" if Year==`i' & Month==`j', replace
	}
		
}


forvalues i=2010(1)2010 {
	forvalues j=1(1)4 {
	  export delimited using "FoodPriceRCK\RCK2015_`i'_`j'.csv" if Year==`i' & Month==`j', replace
	}
		
}


***Use these CSV files, and then change their format in QGIS to layer using https://www.dropbox.com/s/5grzrkwj1xck0xa/Python%20code%20for%20converting%20FoodPrice%20to%20Layer.py?dl=0
*and then aggregate them using batch processing to get average food price in each administration.


forvalues i=1997(1)2009 {
	forvalues j=1(1)12 {
	  import delimited "CSV\Africa_Admin1_LocalFoodPriceRCK2015_`i'_`j'.csv", clear 

      keep if iso==iso_2
	  gen Year=`i'
	  gen Month=`j'
	
	  keep objectid Year Month comm1 comm2 comm3
	  save "Africa_Admin1_LocalFoodPriceRCK2015_`i'_`j'.dta", replace
	}
	
}



forvalues i=2010(1)2010{
	forvalues j=1(1)4 {
	import delimited "CSV\Africa_Admin1_LocalFoodPriceRCK2015_`i'_`j'.csv", clear 

    keep if iso==iso_2
	gen Year=`i'
	gen Month=`j'
	
	keep objectid Year Month comm1 comm2 comm3
	save "Africa_Admin1_LocalFoodPriceRCK2015_`i'_`j'.dta", replace
	}
	
}

use "Africa_Admin1_LocalFoodPriceRCK2015_1997_1.dta", clear

  forvalues i=1997(1)2009 {
  forvalues j=1(1)12 {
	  append using Africa_Admin1_LocalFoodPriceRCK2015_`i'_`j'.dta
	  	}
	  
	} 

  forvalues i=2010(1)2010{
  forvalues j=1(1)4 {
	  append using Africa_Admin1_LocalFoodPriceRCK2015_`i'_`j'.dta
	  	}
	  
	} 

sort Year Month objectid


gen modate = ym(Year, Month) 
format  modate %tm

save "RCK2015_Price.dta", replace 


***IMF food price

import excel "External_Data_monthly-StataPrepared.xls", sheet("External") firstrow clear

split Date, p(M)

gen Year=real(Date1)
gen Month=real(Date2)
rename FoodPriceIndex2005100in FoodPI
egen  Avg_agri=rowmean( BananasCentralAmericanandEc BarleyCanadianno1WesternBa CoffeeOtherMildArabicasInt CoffeeRobustaInternationalC RapeseedoilcrudefobRotterd CottonCottonOutlookAIndex Groundnutspeanuts405040 MaizecornUSNo2Yellow PalmoilMalaysiaPalmOilFutu Rice5percentbrokenmilledwh SoybeanMealChicagoSoybeanMe SoybeanOilChicagoSoybeanOil SoybeansUSsoybeansChicago SugarEuropeanimportpriceCI SugarFreeMarketCoffeeSugar SugarUSimportpricecontra SunfloweroilSunflowerOilUS TeaMombasaKenyaAuctionPri WheatNo1HardRedWinterord)
save "IMFCommodityPrice", replace

******PolityIV2015
import excel "p4v2015.xls", sheet("p4v2015") firstrow clear

rename year Year
save "p4v2015", replace



*****Growing season
import delimited "CSV\Africa_admin1_GrowingSeason.csv", varnames(1)  clear

save "Africa_admin1_GrowingSeason", replace

************************************
*****Base dataset for merging data,
************************************
import delimited "CSV\Africa_admin1XY.csv", clear

gen year=1997
gen month=1

replace year=2015 if objectid==65 
replace month=12 if objectid==65

gen modate = ym(year, month) 
format  modate %tm

keep if iso==iso_2

xtset objectid modate

tsfill, full

xtset objectid modate


forvalues i=-50(1)50 {
replace iso=iso[_n+`i'] if objectid[_n]==objectid[_n+`i'] & iso==""
replace name_0=name_0[_n+`i'] if objectid[_n]==objectid[_n+`i'] & name_0==""
replace type_1=type_1[_n+`i'] if objectid[_n]==objectid[_n+`i'] & type_1==""
replace engtype_1=engtype_1[_n+`i'] if objectid[_n]==objectid[_n+`i'] & engtype_1==""
replace iso_2=iso_2[_n+`i'] if objectid[_n]==objectid[_n+`i'] & iso_2==""
replace cultivated=cultivated[_n+`i'] if objectid[_n]==objectid[_n+`i'] & cultivated==.
replace area=area[_n+`i'] if objectid[_n]==objectid[_n+`i'] & area==.
replace x=x[_n+`i'] if objectid[_n]==objectid[_n+`i'] & x==.
replace y=y[_n+`i'] if objectid[_n]==objectid[_n+`i'] & y==.
}




***Now merge the prepared datasets with main dataset


joinby objectid modate using "Africa_admin1_ViolenceACLED.dta", unmatched(master)

*sum _merge if _merge!=3
drop _merge


joinby objectid modate using "Africa_admin1_ViolenceACLED_FoodLoot.dta", unmatched(master)

drop _merge

replace FoodLoot=0 if FoodLoot==.



***
joinby objectid modate using "Africa_admin1_ViolenceACLED_LandDispute.dta", unmatched(master)

drop _merge

replace LandDispute=0 if LandDispute==.


***


joinby objectid modate using "Africa_admin1_precipitation.dta", unmatched(master)

*sum _merge if _merge!=3 & Year<=2014
drop _merge

joinby objectid Year using "Africa_admin1_Nightlight.dta", unmatched(master)

drop _merge


joinby objectid Year using "Africa_admin1_Population.dta", unmatched(master)

drop _merge


by objectid: ipolate Population_mean Year, gen(Population_mean_ipolate)


joinby objectid using "Africa_admin1_RoadDensity.dta", unmatched(master)

drop _merge


joinby objectid using "Africa_admin1_Diamond.dta", unmatched(master)

drop _merge


joinby objectid using "Africa_admin1_InfantMR.dta", unmatched(master)

drop _merge


joinby objectid using "Africa_admin1_MineralSources.dta", unmatched(master)

drop _merge

joinby objectid using "Africa_admin1_Petroleum.dta", unmatched(master)

drop _merge

replace Petroleum=0 if Petroleum==.


xtset objectid modate

gen Violence_1=l.Violence

export delimited using "MainDataAllMerged.csv", replace

save "MainDataAllMerged.dta", replace

*******
**Using https://www.dropbox.com/s/317jmywh4lp7iy0/Africa_admin1.shp?dl=0 we calculated the centroid of these polygon, named X and Y,
*now we use these geographic cordinations to calculate matrix and then calculate splagvar


*ssc install sppack, replace
*ssc install  spwmatrix, replace
*ssc install splagvar, replace 

use "MainDataAllMerged.dta", clear

spwmatrix gecon x y if Year==1997 & Month==1, wname(W) wtype(inv) cart row

use "MainDataAllMerged.dta", clear
keep if Year==1997 & Month==1
quietly splagvar Violence if Year==1997 & Month==1, wname(W) wfrom(Stata) moran(Violence) 
save "MainDataAllMergedWeight_1997_1.dta", replace



forvalues i=1997(1)1997 {
	forvalues j=2(1)12 {
	use "MainDataAllMerged.dta", clear
	keep if Year==`i' & Month==`j'
	quietly splagvar Violence if Year==`i' & Month==`j', wname(W) wfrom(Stata) moran(Violence) 
	quietly splagvar Violence_1 if Year==`i' & Month==`j', wname(W) wfrom(Stata) moran(Violence_1)
	save "MainDataAllMergedWeight_`i'_`j'.dta", replace
	}
}



forvalues i=1998(1)2015 {
	forvalues j=1(1)12 {
	use "MainDataAllMerged.dta", clear
	keep if Year==`i' & Month==`j'
	quietly splagvar Violence if Year==`i' & Month==`j', wname(W) wfrom(Stata) moran(Violence) 
	quietly splagvar Violence_1 if Year==`i' & Month==`j', wname(W) wfrom(Stata) moran(Violence_1)
	save "MainDataAllMergedWeight_`i'_`j'.dta", replace
	}
}


spmat drop W


import excel "CultivatedGlobcover2009.xls", sheet("Qgis Attributes") firstrow clear

rename OBJECTID objectid

gen Cult_GlobeCover2009_mean=real(mean)
replace Cult_GlobeCover2009_mean=0 if Cult_GlobeCover2009_mean==.

egen max_Cult2009 = max(Cult_GlobeCover2009_mean)

gen Cult_Globe2009_mean=Cult_GlobeCover2009_mean/max_Cult

save Cult_Globe2009.dta, replace

import excel "CultivatedGlobcover2006.xls", sheet("Qgis Attributes") firstrow clear

rename OBJECTID objectid

gen Cult_GlobeCover2006_mean=real(mean)
replace Cult_GlobeCover2006_mean=0 if Cult_GlobeCover2006_mean==.

egen max_Cult2006 = max(Cult_GlobeCover2006_mean)

gen Cult_Globe2006_mean=Cult_GlobeCover2006_mean/max_Cult

save Cult_Globe2006.dta, replace


*****

use "MainDataAllMergedWeight_1997_1.dta", clear


 forvalues i=1997(1)1997 {
		forvalues j=2(1)12 {
		   append using MainDataAllMergedWeight_`i'_`j'.dta
		   }
	  }




 forvalues i=1998(1)2015 {
		forvalues j=1(1)12 {
		   append using MainDataAllMergedWeight_`i'_`j'.dta
		   }
	  }
	  

	  xtset objectid modate

forvalues i=-50(1)50 {

replace name_1=name_1[_n+`i'] if objectid[_n]==objectid[_n+`i'] & name_1==""
}
	  
	  
	  
rename name_1 admin_1

joinby Year Month using "IMFCommodityPrice.dta", unmatched(master)

drop _merge

joinby objectid modate using "RCK2015_Price.dta", unmatched(master)

drop _merge
sort  objectid Year Month
quietly by objectid Year Month :  gen dup = cond(_N==1,0,_n)
drop if dup>0




gen scode=.
rename name_0 sname

* replace scode= if sname=="";                                                  *;

replace scode=  2 if sname=="United States of America";
replace scode=  2 if sname=="United States";
replace scode=  2 if sname=="USA";
replace scode= 20 if sname=="Canada";
replace scode= 31 if sname=="Bahamas";
replace scode= 31 if sname=="Bahamas, The";
replace scode= 40 if sname=="Cuba";
replace scode= 41 if sname=="Haiti";
replace scode= 42 if sname=="Dominican Republic";
**Babak added
replace scode= 42 if sname=="Dominican Rp";
replace scode= 51 if sname=="Jamaica";
replace scode= 52 if sname=="Trinidad and Tobago";
replace scode= 52 if sname=="Trinidad & Tobago";
replace scode= 52 if sname=="Trinidad &Tobago";
**Babak added
replace scode= 52 if sname=="Trinidad Tbg";
replace scode= 53 if sname=="Barbados";
replace scode= 54 if sname=="Dominica";
replace scode= 55 if sname=="Grenada";
replace scode= 56 if sname=="St. Lucia";
replace scode= 57 if sname=="St. Vincent and the Grenadines";
replace scode= 57 if sname=="St. Vincent & Grens.";
replace scode= 57 if sname=="St. Vincent & Grenadines";
replace scode= 57 if sname=="St.Vincent & Grenadines";
replace scode= 58 if sname=="Antigua & Barbuda";
replace scode= 58 if sname=="Antigua and Barbuda";
replace scode= 58 if sname=="Antigua";
replace scode= 60 if sname=="St. Kitts and Nevis";
replace scode= 60 if sname=="St. Kitts & Nevis";
replace scode= 70 if sname=="Mexico";
replace scode= 80 if sname=="Belize";
replace scode= 90 if sname=="Guatemala";
replace scode= 91 if sname=="Honduras";
replace scode= 92 if sname=="El Salvador";
replace scode= 93 if sname=="Nicaragua";
replace scode= 94 if sname=="Costa Rica";
replace scode= 95 if sname=="Panama";
replace scode=100 if sname=="Colombia";
replace scode=101 if sname=="Venezuela";
replace scode=101 if sname=="Venezuela, Rep. Bol.";
**Babak added
replace scode=101 if sname=="Venezuela, RB";
replace scode=110 if sname=="Guyana";
replace scode=115 if sname=="Suriname";
replace scode=130 if sname=="Ecuador";
replace scode=135 if sname=="Peru";
replace scode=140 if sname=="Brazil";
replace scode=145 if sname=="Bolivia";
replace scode=150 if sname=="Paraguay";
replace scode=155 if sname=="Chile";
replace scode=160 if sname=="Argentina";
replace scode=165 if sname=="Uruguay";
replace scode=200 if sname=="United Kingdom";
*Babak added
replace scode=200 if sname=="UK";
replace scode=205 if sname=="Ireland";
replace scode=210 if sname=="Netherlands";
replace scode=211 if sname=="Belgium";
**Babak added
replace scode=212 if sname=="Luxembourg";
replace scode=212 if sname=="Belgium-Lux";
replace scode=220 if sname=="France";
replace scode=221 if sname=="Monaco";
**Babak added
replace scode=220 if sname=="France,Monac";
replace scode=223 if sname=="Liechtenstein";
replace scode=225 if sname=="Switzerland";
*Babak added
replace scode=225 if sname=="Switz.Liecht";
replace scode=230 if sname=="Spain";
replace scode=232 if sname=="Andorra";
replace scode=235 if sname=="Portugal";
replace scode=255 if sname=="Germany";
replace scode=260 if sname=="German Federal Republic";
**Babak added
replace scode=260 if sname=="Fm German FR";
replace scode=265 if sname=="German Democratic Republic";
*Babak added
replace scode=265 if sname=="Fm German DR";
replace scode=290 if sname=="Poland";
replace scode=305 if sname=="Austria";
replace scode=310 if sname=="Hungary";
replace scode=315 if sname=="Czechoslovakia";
**Babak added
replace scode=315 if sname=="Czechoslovak";
replace scode=316 if sname=="Czech Republic";
replace scode=317 if sname=="Slovakia";
replace scode=317 if sname=="Slovak Republic";
replace scode=325 if sname=="Italy";
replace scode=331 if sname=="San Marino";
replace scode=338 if sname=="Malta";
replace scode=339 if sname=="Albania";
replace scode=343 if sname=="Macedonia";
***Babak added**
replace scode=343 if sname=="Macedonia, F.Y.R. of";
replace scode=344 if sname=="Croatia";
replace scode=345 if sname=="Yugoslavia";
*Babak added
replace scode=345 if sname=="Fm Yugoslav";
replace scode=345 if sname=="Serbia and Montenegro";
**Babak added
replace scode=345 if sname=="Serbia, Republic of";
**Babak added
replace scode=345 if sname=="Serbia";
replace scode=346 if sname=="Bosnia and Herzegovina";
replace scode=349 if sname=="Slovenia";
replace scode=350 if sname=="Greece";
replace scode=352 if sname=="Cyprus";
replace scode=355 if sname=="Bulgaria";
replace scode=359 if sname=="Moldova";
replace scode=360 if sname=="Romania";
replace scode=365 if sname=="Russia";
**Babak added
replace scode=365 if sname=="Russian Federation";
**Babak added
replace scode=365 if sname=="Russia (Soviet Union)";
**Babak added
replace scode=365 if sname=="Fm USSR";
**Babak added
replace scode=365 if sname=="Russian Fed";
**Babak added
replace scode=347 if sname=="Kosovo";
replace scode=366 if sname=="Estonia";
replace scode=367 if sname=="Latvia";
replace scode=368 if sname=="Lithuania";
replace scode=369 if sname=="Ukraine";
replace scode=370 if sname=="Belarus";
replace scode=371 if sname=="Armenia";
replace scode=372 if sname=="Georgia";
replace scode=373 if sname=="Azerbaijan";
replace scode=375 if sname=="Finland";
replace scode=380 if sname=="Sweden";
replace scode=385 if sname=="Norway";
replace scode=390 if sname=="Denmark";
replace scode=390 if sname=="Denmark";
replace scode=395 if sname=="Iceland";
replace scode=402 if sname=="Cape Verde";
replace scode=403 if sname=="Sao Tome and Principe";
replace scode=404 if sname=="Guinea-Bissau";
**Babak added
replace scode=404 if sname=="GuineaBissau";
replace scode=411 if sname=="Equatorial Guinea";
**Babak added
replace scode=411 if sname=="Eq.Guinea";
replace scode=420 if sname=="Gambia";
replace scode=420 if sname=="Gambia, The";
replace scode=432 if sname=="Mali";
replace scode=433 if sname=="Senegal";
replace scode=434 if sname=="Benin";
replace scode=435 if sname=="Mauritania";
replace scode=436 if sname=="Niger";
replace scode=437 if sname=="Ivory Coast";
replace scode=437 if sname=="Côte d'Ivoire";
replace scode=437 if sname=="Cote d'Ivoire";
replace scode=437 if sname=="Cote d`Ivoire";
*Babak added 
replace scode=437 if sname=="Cote Divoire";
replace scode=438 if sname=="Guinea";
replace scode=439 if sname=="Burkina Faso";
replace scode=450 if sname=="Liberia";
replace scode=451 if sname=="Sierra Leone";
replace scode=452 if sname=="Ghana";
replace scode=461 if sname=="Togo";
replace scode=471 if sname=="Cameroon";
replace scode=475 if sname=="Nigeria";
replace scode=481 if sname=="Gabon";
replace scode=482 if sname=="Central African Republic";
replace scode=482 if sname=="Central African Rep.";
replace scode=482 if sname=="Central African Rep";
*Babak added
replace scode=482 if sname=="Cent.Afr.Rep";
replace scode=483 if sname=="Chad";
replace scode=484 if sname=="Congo";
replace scode=484 if sname=="Congo, Republic of the";
replace scode=484 if sname=="Congo, Republic of";
replace scode=484 if sname=="Congo, Rep.";
replace scode=484 if sname=="Congo, Rep";
replace scode=484 if sname=="Congo-Brazzaville";
replace scode=484 if sname=="Congo, Brazzaville";
replace scode=490 if sname=="Democratic Republic of the Congo";
*Babak added
replace scode=490 if sname=="Dem.Rp.Congo";
replace scode=490 if sname=="Congo, Democratic Republic of the";
replace scode=490 if sname=="Congo, Democratic Republic";
replace scode=490 if sname=="Congo, Dem. Rep. of";
replace scode=490 if sname=="Congo, Dem. Rep.";
replace scode=490 if sname=="Congo-Kinshasa";
replace scode=490 if sname=="Congo, DR";
replace scode=490 if sname=="Zaire";
*Babak added
replace scode=490 if sname=="DR Congo (Zaire)";
replace scode=500 if sname=="Uganda";
replace scode=501 if sname=="Kenya";
replace scode=510 if sname=="Tanzania";
replace scode=511 if sname=="Zanzibar";
replace scode=516 if sname=="Burundi";
replace scode=517 if sname=="Rwanda";
replace scode=520 if sname=="Somalia";
replace scode=522 if sname=="Djibouti";
replace scode=530 if sname=="Ethiopia";
replace scode=531 if sname=="Eritrea";
replace scode=540 if sname=="Angola";
replace scode=541 if sname=="Mozambique";
replace scode=551 if sname=="Zambia";
replace scode=552 if sname=="Zimbabwe";
**Babak added
replace scode=552 if sname=="Zimbabwe (Rhodesia)";
replace scode=553 if sname=="Malawi";
replace scode=560 if sname=="South Africa";
replace scode=565 if sname=="Namibia";
replace scode=570 if sname=="Lesotho";
replace scode=571 if sname=="Botswana";
replace scode=572 if sname=="Swaziland";
replace scode=580 if sname=="Madagascar";
**Babak added
replace scode=580 if sname=="Madagascar (Malagasy)";
replace scode=581 if sname=="Comoros";
**Babak added
replace scode=581 if sname=="Fr Ind O";
replace scode=590 if sname=="Mauritius";
replace scode=591 if sname=="Seychelles";
replace scode=600 if sname=="Morocco";
replace scode=615 if sname=="Algeria";
replace scode=616 if sname=="Tunisia";
replace scode=620 if sname=="Libya";
replace scode=625 if sname=="Sudan";
replace scode=630 if sname=="Iran";
replace scode=630 if sname=="Iran, Islamic Republic";
replace scode=630 if sname=="Iran, Ismalic Rep.";
replace scode=630 if sname=="Iran, Ismalic Rep";
**Babak added
replace scode=630 if sname=="Iran, Islamic Rep.";
replace scode=640 if sname=="Turkey";
replace scode=645 if sname=="Iraq";
replace scode=651 if sname=="Egypt";
replace scode=651 if sname=="Egypt, Arab Republic";
replace scode=651 if sname=="Egypt, Arab Rep.";
replace scode=652 if sname=="Syria";
replace scode=652 if sname=="Syrian Arab Republic";
replace scode=660 if sname=="Lebanon";
replace scode=663 if sname=="Jordan";
replace scode=666 if sname=="Israel";
replace scode=670 if sname=="Saudi Arabia";
**Babak (I code Yemen 678 for all years as Gleditsch did in his coding of GDP, trade, ect  )
replace scode=678 if sname=="Yemen Arab Republic";
replace scode=678 if sname=="Yemen";
replace scode=678 if sname=="Yemen, Rep.";
replace scode=678 if sname=="Yemen, Republic of";
replace scode=678 if sname=="Yemen People's Republic";
**Babak added
replace scode=678 if sname=="Fm Yemen AR";

**Babak added
replace scode=678 if sname=="Fm Yemen Dm";
**Babak added
replace scode=678 if sname=="Yemen (North Yemen)";
replace scode=690 if sname=="Kuwait";
replace scode=692 if sname=="Bahrain";
replace scode=694 if sname=="Qatar";
replace scode=696 if sname=="United Arab Emirates";
**Babak added
replace scode=696 if sname=="Untd Arab Em";
replace scode=698 if sname=="Oman";
replace scode=700 if sname=="Afghanistan";
replace scode=701 if sname=="Turkmenistan";
replace scode=702 if sname=="Tajikistan";
replace scode=703 if sname=="Kyrgyzstan";
replace scode=703 if sname=="Kyrgyz Republic";
replace scode=704 if sname=="Uzbekistan";
replace scode=705 if sname=="Kazakhstan";
replace scode=710 if sname=="China";
replace scode=710 if sname=="China, People's Republic";
replace scode=710 if sname=="China, People's Rep.";
replace scode=710 if sname=="China, People's Rep";
replace scode=710 if sname=="China, PRC";
replace scode=710 if sname=="China,P.R.: Mainland";
*Babak added
replace scode=710 if sname=="China HK SAR";
replace scode=712 if sname=="Mongolia";
replace scode=713 if sname=="Taiwan";
replace scode=713 if sname=="Taiwan, China";
replace scode=730 if sname=="Korea";
replace scode=731 if sname=="North Korea";
replace scode=731 if sname=="Korea, Democratic Republic";
replace scode=731 if sname=="Korea, Dem. Rep.";
replace scode=732 if sname=="South Korea";
replace scode=732 if sname=="Korea";
replace scode=732 if sname=="Korea, Republic of";
replace scode=732 if sname=="Republic of Korea";
replace scode=732 if sname=="Korea, Rep.";
*Babak added
replace scode=732 if sname=="Korea Rep.";
replace scode=740 if sname=="Japan";
replace scode=750 if sname=="India";
replace scode=760 if sname=="Bhutan";
replace scode=770 if sname=="Pakistan";
replace scode=771 if sname=="Bangladesh";
replace scode=775 if sname=="Myanmar";
**Babak added
replace scode=775 if sname=="Myanmar (Burma)";
replace scode=780 if sname=="Sri Lanka";
replace scode=781 if sname=="Maldives";
replace scode=790 if sname=="Nepal";
replace scode=800 if sname=="Thailand";
replace scode=811 if sname=="Cambodia";
**Babak added
replace scode=811 if sname=="Cambodia (Kampuchea)";
replace scode=812 if sname=="Laos";
replace scode=812 if sname=="Lao People's Dem.Rep";
**Babak added
replace scode=812 if sname=="Lao P.Dem.R";
replace scode=816 if sname=="Vietnam";
**Babak added
replace scode=816 if sname=="Viet Nam";
replace scode=817 if sname=="Republic of Vietnam";
replace scode=817 if sname=="Vietnam, Republic of";
replace scode=820 if sname=="Malaysia";
replace scode=830 if sname=="Singapore";
replace scode=835 if sname=="Brunei";
replace scode=840 if sname=="Philippines";
replace scode=850 if sname=="Indonesia";
replace scode=860 if sname=="East Timor";
**Babak added
replace scode=860 if sname=="Timor-Leste";
replace scode=900 if sname=="Australia";
replace scode=910 if sname=="Papua New Guinea";
replace scode=920 if sname=="New Zealand";
replace scode=935 if sname=="Vanuatu";
replace scode=940 if sname=="Solomon Islands";
replace scode=946 if sname=="Kiribati";
replace scode=947 if sname=="Tuvalu";
replace scode=950 if sname=="Fiji";
replace scode=955 if sname=="Tonga";
replace scode=970 if sname=="Nauru";
replace scode=983 if sname=="Marshall Islands";
replace scode=986 if sname=="Palau";
replace scode=987 if sname=="Federated States of Micronesia";
replace scode=987 if sname=="Micronesia, Fed. Sts.";
replace scode=990 if sname=="Samoa";


rename scode ccode


joinby ccode Year using "p4v2015.dta", unmatched(master)

drop _merge

joinby objectid using "Africa_admin1_GrowingSeason.dta", unmatched(master)

drop _merge

joinby objectid using "Cult_Globe2009.dta", unmatched(master)
drop _merge

joinby objectid using "Cult_Globe2006.dta", unmatched(master)
drop _merge

save "MainDataAllMergedWeight.dta", replace

