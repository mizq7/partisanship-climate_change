********************************************************************************
*   Are left-leaning governments better at reducing climate change             *
*                   than right-leaning governments?                            *
*-------------------------- Muhammad Muinul Islam -----------------------------*
*-------------Data Analysis for Partisanship Chapter, Oct 13, 2019----------------*
********************************************************************************
clear all
set more off
pause on

*setting working directory

*cd "/LOCAL ADDRESS WHERE THE FILE "muinul.partisanship.dta" IS STORED"
use "muinul.partisanship.dta", clear

********************************************************************************
***********             SETTING THE DATA AS PANEL DATA                 *********
********************************************************************************
encode countrycode, gen(c_code)
global id c_code
global t year
sort $id $t
xtset $id $t, yearly
xtdescribe
xtsum

********************************************************************************
***********                     RESCALING SWANK DATA                   *********
********************************************************************************
gen left_sum= (leftc + leftgs + lefts)
gen lib_sum= (llc + llgs + llseat)
gen left_sum_mean = (left_sum/3)
gen lib_sum_mean = (lib_sum/3)
gen swank_left = (left_sum_mean+lib_sum_mean)

********************************************************************************
*****    GENERATING NEW VARIABLES (log, lag and first differences etc)    ******
********************************************************************************
* ln CO2 per capita
gen lnco2pc = log(co2pc)

* ln GDP per capita
gen lngdppc = log(gdppc)

* GDP per capita squared
gen lngdppc2 = lngdppc*lngdppc

* ln Population, Total
gen lnpop = log(pop_wdi)


********************************************************************************
***********               DATA PREPARATION & MODEL CHECK               *********
********************************************************************************

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
	drop if missing(fedfof)

	drop if missing(swank_left)



* residuals check for the final model:

xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, re vce (cluster c_code)

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

* the plot does not show any country to be an outlier

********************************************************************************
***********                     Figure 1                               *********
********************************************************************************

xtline co2pc if swank_left>=50, overlay

********************************************************************************
***************                     ANALYSIS                        ************
********************************************************************************
* MODEL 1

*Pooled OLS with Heteroskedasticity Robust Standard Error

reg co2pc swank_left lngdppc trade, robust
outreg2 using output_co2SW1, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, No) ctitle(Model 1: OLS) drop(i.year) replace

*Random-effects GLS regression

xtreg co2pc swank_left lngdppc trade i.year, vce(cluster c_code)
outreg2 using output_co2SW1, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1: GLS, Random) drop(i.year) append

*Panel corrrected standard errors (XTPCSE)

xtpcse co2pc swank_left lngdppc trade i.year, corr(ar1) pairwise
outreg2 using output_co2SW1, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) ctitle(Model 1: PCSE) drop(i.year) append

*GLS random-effects regression with Driscoll and Kraay standard errors (XTSCC)

xtscc co2pc swank_left lngdppc trade i.year, re lag(4)
outreg2 using output_co2SW1, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1: XTSCC) drop(i.year) append

* MODEL 2

*Pooled OLS with Heteroskedasticity Robust Standard Error

reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, robust
outreg2 using output_co2SW2, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, No) ctitle(Model 2: OLS) drop(i.year) replace

*Random-effects GLS regression

xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude i.year, vce(cluster c_code)
outreg2 using output_co2SW2, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 2: GLS, Random) drop(i.year) append


*Panel corrrected standard errors (XTPCSE)

xtpcse co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude i.year, corr(ar1) pairwise
outreg2 using output_co2SW2, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 2: PCSE) drop(i.year) append

*GLS random-effects regression with Driscoll and Kraay standard errors (XTSCC)

xtscc co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude i.year, re lag(4)
outreg2 using output_co2SW2, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 2: XTSCC) drop(i.year) append


********************************************************************************
********            DIAGNOSTIC TESTS OF EMPIRICAL MODELS               **********
********************************************************************************

*CORRELATIONS MATRIX (Annex C)

*Model 1
pwcorr co2pc swank_left lngdppc trade, star(0.05) sig

*Model 2
pwcorr co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, star(0.05) sig

*GRAPH CORRELATIONS MATRIX (Annex D)

*Model 1
graph matrix co2pc swank_left lngdppc trade, half maxis(ylabel(none) xlabel(none))

*Model 2
graph matrix co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, half maxis(ylabel(none) xlabel(none))

* CHECKING FOR HETEROGENEITY ACROSS COUNTRIES (Annex E)
encode countryname, gen(country1)
twoway scatter co2pc country1, msymbol(circle_hollow) || connected co2pc_mean country1, msymbol(diamond)

*CHECKING FOR HETEROGENEITY ACROSS YEARS (Annex F)
twoway scatter co2pc year, msymbol(circle_hollow) || connected co2pc_mean year, msymbol(diamond) || , xlabel(1990(1)2014)

*HETEROSKEDASTICITY TEST (Appendix G & H)

*Model 1
reg co2pc swank_left lngdppc trade
avplots
estat hettest
hettest, rhs fstat

*Model 2
reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude
avplots
estat hettest
hettest, rhs fstat

*HAUSMAN TEST (Appendix I)

*Model 1
xtreg co2pc swank_left lngdppc trade, fe
estimates store fixed
xtreg co2pc swank_left lngdppc trade, re
estimates store random
hausman fixed random, sigmamore

*Model 2
xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, fe
estimates store fixed
xtreg co2pc v2x_polyarchy lngdppc trade pop urban renew forest annexI island latitude, re
estimates store random
hausman fixed random, sigmamore

* TESTING FOR RANDOM EFFECTS (BREUSCH-PAGAN LAGRANGE MULTIPLIER (LM)) (Appendix J)

*Model 1
xtreg co2pc swank_left lngdppc trade, re
xttest0

*Model 2
xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, re
xttest0

* PESARAN'S TEST OF CROSS-SECTIONAL INDEPENDENCE (Annex K)
Pesaran’s test of cross-sectional independence

*Model 1
xtreg co2pc swank_left lngdppc trade, fe
xtcsd, pesaran abs

*Model 2
xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, fe
xtcsd, pesaran abs

*TESTING FOR CROSS-SECTIONAL DEPENDENCE/CONTEMPORANEOUS CORRELATIONS (Annex L)
USING Pesaran (2015) test for weak cross-sectional dependence

*Model 1
xtreg co2pc swank_left lngdppc trade i.year, fe
xtcd2

*Model 2
xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude i.year, fe
xtcd2

*TESTING FOR CROSS-SECTIONAL DEPENDENCE/CONTEMPORANEOUS CORRELATIONS (Annex M)
USING Test of Cross-sectional Independence with the command ‘xtcdf’

*Model 1
xtcdf co2pc swank_left lngdppc trade

*Model 2
xtcdf co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude

*AUTOCORRELATION OR SERIAL CORRELATION (Annex N & Annex O)

*Model 1

*In Graph
reg co2pc swank_left lngdppc trade, vce(cluster c_code)
predict uhat, resid
tsline uhat

*In Table
xtreg co2pc swank_left lngdppc trade, vce(cluster c_code)
xtserial co2pc swank_left lngdppc trade

*Model 2

*In Graph
reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, vce(cluster c_code)
predict uhat, resid
tsline uhat

*in Table
xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, vce(cluster c_code)
xtserial co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude

*TESTING FOR HETEROSKEDASTICITY IN FIXED EFFECT:
Modified Wald test for groupwise heteroskedasticity (Annex P & Annex Q)

*Model 1
xtreg co2pc swank_left lngdppc trade i.year, fe
xttest3

*with robust option

xtreg co2pc swank_left lngdppc trade i.year, fe robust
xttest3

*Model 2
xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude i.year, fe
xttest3

*with robust option

xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude i.year, fe robust
xttest3

*TESTING FOR TIME-FIXED EFFECT (Annex R)
*Model 1
xtreg co2pc swank_left lngdppc trade i.year, fe
testparm i.year

*Model 2
xtreg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude i.year, fe
testparm i.year

*Ramsey RESET test (Annex S)

*MODEL 1

reg co2pc swank_left lngdppc trade if countryname!="Qatar", vce (cluster c_code)
ovtest

*MODEL 2

reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude if countryname!="Qatar", vce (cluster c_code)
ovtest

*SPECIFICATION ERROR TEST (Annex T)

MODEL 1
reg co2pc swank_left lngdppc trade, vce (cluster c_code)
linktest

*MODEL 2*
reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, vce (cluster c_code)
linktest

*TESTING FOR UNIT ROOTS/STATIONARITY (Annex U)

xtunitroot fisher co2pc, dfuller lags(1)
xtunitroot fisher co2pc, dfuller trend demean lags(1)
xtunitroot fisher co2pc, pperron trend demean lags(1)

* MULTICOLLINEARITY TEST (Annex V)

*Model 1

reg co2pc swank_left lngdppc trade if countryname!="Qatar", vce (cluster c_code)
estat vif

*Model 2
reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude if countryname!="Qatar", vce (cluster c_code)
estat vif

* REGRESSION RESULTS WITH AND WITHOUT 'ROBUST' OPTION (Annex W & Annex X)

*Model 1
reg co2pc swank_left lngdppc trade
reg co2pc swank_left lngdppc trade, robust

*Model 2
reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude
reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, robust

********************************************************************************
********                   SUPPLEMENTARAY MATERIALS                    *********
********************************************************************************

*Missing Observations in the Data (Annex Y)
misstable sum

*Histogram of the Dependent Variable (CO2 per capita) (Annex Z)
hist co2pc, kdensity scheme(s1mono) title(Per Capita CO2 Emission) xtitle(CO2 per capita) caption(Source: World Bank, span)

*Scatterplot between CO2 per capita and Year (Annex AA)
graph twoway scatter co2pc year

*Status of CO2 emission per capita by all countries (xtline, overlay) (Annex AB)
xtline co2pc
xtline co2pc, overlay

*OBSERVED VS. PREDICTED VALUES OF DV: CO2 PER CAPITA (Annex AC)

xtreg co2pc swank_left lngdppc trade, vce(cluster c_code)
predict co2pc_predict
label variable co2pc_predict "co2pc predicted"
scatter co2pc co2pc_predict

*CHECKING LINEARITY OF MAJOR CONTINUOUS VARIABLS (Annex AD)

reg co2pc swank_left lngdppc trade pop urban renew forest annexI island latitude, vce(cluster c_code)
acprplot lngdppc, lowess
acprplot trade, lowess
acprplot pop, lowess
acprplot urban, lowess
acprplot renew, lowess
acprplot forest, lowess



