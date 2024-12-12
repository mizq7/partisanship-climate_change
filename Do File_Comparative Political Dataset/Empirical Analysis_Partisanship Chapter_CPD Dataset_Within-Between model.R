********************************************************************************
*--------Bell and Jone's Within-Between Model for Partisanship Chapter ----------*
*-------------------------- Muhammad Muinul Islam -----------------------------*
********************************************************************************
	clear all
	set more off
	pause on

	ssc install runmlwin, replace
	global MLwiN_path "C:\Program Files\MLwiN v3.04\mlwin.exe"

*setting working directory

*cd "/LOCAL ADDRESS WHERE THE FILE "muinul.partisanship.dta" IS STORED"
use "muinul.partisanship.dta", clear

********************************************************************************
***********  RESCALING Comparative Political Dataset (CPD) DATA        *********
********************************************************************************
gen cpdleft_agg= (gov_left1 + gov_left2 + gov_left3)
gen cpdleft_mean = (cpdleft_agg/3)

********************************************************************************
*****    GENERATING NEW VARIABLES (log, lag and first differences etc)    ******
********************************************************************************
* ln CO2 per capita
	gen lnco2pc = log(co2pc)

* ln GDP per capita
	gen lngdppc = log(gdppc)

* GDP per capita squared
	gen lngdppc2 = lngdppc*lngdppc

*ln Population, Total
	gen lnpop = log(pop_wdi)

	encode countrycode, gen(c_code)

*Creating constant variable
	gen cons=1

*generate mean variables

egen cpdleft_agg_mean = mean(cpdleft_agg), by(c_code)
egen lngdppc_mean = mean(lngdppc), by(c_code)
egen trade_mean = mean(trade), by(c_code)
egen pop_mean = mean(pop_wdi), by(c_code)
egen urban_mean = mean(urban), by(c_code)
egen renew_mean = mean(renew), by(c_code)
egen forest_mean = mean(forest), by(c_code)
egen annexI_mean = mean(annexI), by(c_code)
egen island_mean = mean(island), by(c_code)
egen latitude_mean = mean(latitude), by(c_code)

*remove missing values

drop if missing(co2pc)
drop if missing(lngdppc)
drop if missing(trade)
drop if missing(pop_wdi)
drop if missing(urban)
drop if missing(renew)
drop if missing(forest)
drop if missing(annexI)
drop if missing(island)
drop if missing(latitude)

drop if missing(cpdleft_agg)

*generate within variables

egen cpdleft_agg_mean_new = mean(cpdleft_agg), by(c_code)
egen year_mean_new = mean(year), by(c_code)
egen lngdppc_mean_new = mean(lngdppc), by(c_code)
egen trade_mean_new = mean(trade), by(c_code)
egen pop_mean_new = mean(pop_wdi), by(c_code)
egen urban_mean_new = mean(urban), by(c_code)
egen renew_mean_new = mean(renew), by(c_code)
egen forest_mean_new = mean(forest), by(c_code)
egen annexI_mean_new = mean(annexI), by(c_code)
egen island_mean_new = mean(island), by(c_code)
egen latitude_mean_new = mean(latitude), by(c_code)


gen cpdleft_aggw = cpdleft_agg - cpdleft_agg_mean_new
gen yearw = year - year_mean_new
gen lngdppcw = lngdppc - lngdppc_mean_new
gen tradew = trade - trade_mean_new
gen popw = pop - pop_mean_new
gen urbanw = urban - urban_mean_new
gen reneww = renew - renew_mean_new
gen forestw = forest - forest_mean_new
gen annexIw = annexI - annexI_mean_new
gen islandw = island - island_mean_new
gen latitudew = latitude - latitude_mean_new


drop cpdleft_agg_mean_new
drop lngdppc_mean_new
drop trade_mean_new
drop pop_mean_new
drop urban_mean_new
drop renew_mean_new
drop forest_mean_new
drop annexI_mean_new
drop island_mean_new
drop latitude_mean_new


*center variables

sum lngdppc, meanonly
gen clngdppc = lngdppc - r(mean)
sum year, meanonly
gen c_year = year - r(mean)
sum trade, meanonly
gen ctrade = trade - r(mean)
sum pop_wdi, meanonly
gen cpop = pop - r(mean)
sum urban, meanonly
gen curban = urban - r(mean)
sum renew, meanonly
gen crenew = renew - r(mean)
sum forest, meanonly
gen cforest = forest - r(mean)
sum annexI, meanonly
gen cannexI = annexI - r(mean)
sum island, meanonly
gen cisland = island - r(mean)
sum latitude, meanonly
gen clatitude = latitude - r(mean)

sum lngdppc_mean, meanonly
gen clngdppc_mean = lngdppc_mean - r(mean)
sum trade_mean, meanonly
gen ctrade_mean = trade_mean - r(mean)
sum pop_mean, meanonly
gen cpop_mean = pop_mean - r(mean)
sum urban_mean, meanonly
gen curban_mean = urban_mean - r(mean)
sum renew_mean, meanonly
gen crenew_mean = renew_mean - r(mean)
sum forest_mean, meanonly
gen cforest_mean = forest_mean - r(mean)
sum annexI_mean, meanonly
gen cannexI_mean = annexI_mean - r(mean)
sum island_mean, meanonly
gen cisland_mean = island_mean - r(mean)
sum latitude_mean, meanonly
gen clatitude_mean = latitude_mean - r(mean)

*Regression model for Within-between estimates following Bell and Jones (Povitkina code)

* Preparation for the within-between estimation

order co2pc year cpdleft_agg lngdppc trade pop urban renew forest annexI island latitude, last

foreach v of varlist co2pc-latitude{
    egen `v'_m=mean(`v'), by(country)
}

* mean-centering time-varying independent variables
foreach v of varlist year-latitude {
    gen `v'_devm=`v'-`v'_m
}

*generate the matrix for the linear variance function at level 1

matrix A = (1,1,0)


********************************************************************************
***********             SETTING THE DATA AS PANEL DATA                 *********
********************************************************************************
	global id c_code
	global t year
	sort $id $t
	xtset $id $t, yearly
	xtdescribe
	xtsum

*Model Check

* residuals check for the final model:

	xtreg co2pc cons cpdleft_aggw lngdppcw tradew yearw popw urbanw reneww///
	forestw annexIw islandw latitudew i.year cpdleft_agg_mean clngdppc_mean///
	ctrade_mean cpop_mean curban_mean crenew_mean cforest_mean cannexI_mean///
	cisland_mean clatitude_mean, vce (cluster c_code)

*Residuals

	predict e, e
	predict u, u
	predict ue, ue

	kdensity e, norm
	kdensity u, norm
	kdensity ue, norm

	pnorm e
	pnorm u
	pnorm ue

	qnorm e
	qnorm u
	qnorm ue, mlabel(countryname)

* the plot shows Australia may slightly be an outlier

* Checking residuals without Australia

	predict e1 if countryname!="Australia", e
	predict u1 if countryname!="Australia", u
	predict ue1 if countryname!="Australia", ue

	kdensity e1 if countryname!="Australia", norm
	kdensity u1 if countryname!="Australia", norm
	kdensity ue1 if countryname!="Australia", norm

	pnorm e1 if countryname!="Australia"
	pnorm u1 if countryname!="Australia"
	pnorm ue1 if countryname!="Australia"

	qnorm e1 if countryname!="Australia"
	qnorm u1 if countryname!="Australia"
	qnorm ue1 if countryname!="Australia", mlabel(countryname)

*Residuals improved

*Checking if Australia shows as an outlier in the leverage plot:

*Final model:

	reg co2pc cons cpdleft_aggw lngdppcw tradew yearw popw urbanw reneww forestw///
	annexIw islandw latitudew i.year cpdleft_agg_mean clngdppc_mean ctrade_mean///
	cpop_mean curban_mean crenew_mean cforest_mean cannexI_mean cisland_mean///
	clatitude_mean

* Leverage vs residual plot

	lvr2plot, mlabel(countryname)

*No residual outlier is detected

*run the models

********************************************************************************
***********                   ANALYSIS (TABLE 4)                       *********
********************************************************************************

*Model 1

*Null Model

	runmlwin co2pc cons, level2(c_code: cons) level1(year: cons) nopause rigls

	estimates store Mod1_REnull

	outreg2 using output_co2cpd1, dec(3) excel label///
	alpha (0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^)///
	ctitle(Model 1:Null) drop(i.year) replace

*Fixed Effect Model

	xtreg co2pc cpdleft_agg clngdppc ctrade c_year i.year, fe

	estimates store Mod1_FE

	outreg2 using output_co2cpd1, dec(3) excel label///
	alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^)///
	addtext(Year FE, Yes) ctitle(Model 1:FE) drop(i.year) append

*Random Effect Model

	runmlwin co2pc cons cpdleft_agg clngdppc ctrade c_year///
	i.year, level2(c_code: cons) level1(year: cons) nopause rigls

	estimates store Mod1_RE

	outreg2 using output_co2cpd1, dec(3) excel label///
	alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^)///
	addtext(Year FE, Yes) ctitle(Model 1:RE) drop(i.year) append

*Random Effect Within-Between Model

	runmlwin co2pc cons cpdleft_aggw lngdppcw tradew yearw cpdleft_agg_mean///
	clngdppc_mean ctrade_mean i.year,///
	level2(c_code: cons) level1(year: cons) nopause rigls

	estimates store Mod1_REwb

	outreg2 using output_co2cpd1, dec(3) excel label///
	alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^)///
	addtext(Year FE, Yes) ctitle(Model 1:REWB) drop(i.year) append


*Model 2

*Fixed Effect Model

	xtreg co2pc cpdleft_agg clngdppc ctrade c_year cpop curban crenew cforest///
	cannexI cisland clatitude i.year, fe

	estimates store Mod2_FE

	outreg2 using output_co2cpd2, dec(3) excel label///
	alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^)///
	addtext(Year FE, Yes) ctitle(Model 2:FE) drop(i.year) append

*Random Effect Model

	runmlwin co2pc cons cpdleft_agg clngdppc ctrade c_year cpop curban crenew///
	cforest cannexI cisland clatitude i.year,///
	level2(c_code: cons) level1(year: cons) nopause rigls

	estimates store Mod2_RE

	outreg2 using output_co2cpd2, dec(3) excel label///
	alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^)///
	addtext(Year FE, Yes) ctitle(Model 2:RE) drop(i.year) append

**Random Effect Within-Between Model

	runmlwin co2pc cons cpdleft_aggw lngdppcw tradew yearw popw urbanw reneww///
	forestw annexIw islandw latitudew i.year cpdleft_agg_mean clngdppc_mean///
	ctrade_mean cpop_mean curban_mean crenew_mean cforest_mean cannexI_mean///
	cisland_mean clatitude_mean, level2(c_code: cons)///
	level1(year: cons) nopause rigls

	estimates store Mod2_REwb

	outreg2 using output_co2cpd2, dec(3) excel label///
	alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^)///
	addtext(Year FE, Yes) ctitle(Model 2:REWB) drop(i.year) append

	estimates table Mod1_REnull Mod1_FE Mod1_RE Mod1_REwb Mod2_FE///
	Mod2_RE Mod2_REwb, se stats(deviance)

