********************************************************************************
*   Are left-leaning governments better at reducing climate change             *
*                 than right-leaning governments?                              *
*-------------------------- Muhammad Muinul Islam -----------------------------*
*-------------Data Analysis for Democracy Chapter, Oct 16, 2019----------------*
********************************************************************************
clear all
set more off
pause on

*setting working directory

*cd "/LOCAL ADDRESS WHERE THE FILE "muinul.democracy.dta" IS STORED"
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
*****    GENERATING NEW VARIABLES (log, lag and first differences etc)    ******
********************************************************************************
* ln CO2 per capita
gen lnco2pc = log(co2pc)

* ln GDP per capita
gen lngdppc = log(gdppc)

* GDP per capita squared
gen lngdppc2 = lngdppc*lngdppc

* ln Population, Total
gen lnpop = log(pop)


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

	drop if missing(execrlc)



* residuals check for the final model:

xtreg co2pc execrlc lngdppc trade pop_wdi urban renew forest annexI system v2x_polyarchy island latitude, re vce (cluster c_code)

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

* the plot shows Qatar could be an outlier

* residuals without Qatar

predict e1 if countryname!="Qatar", e
predict u1 if countryname!="Qatar", u
predict ue1 if countryname!="Qatar", ue

kdensity e1 if countryname!="Qatar", norm
kdensity u1 if countryname!="Qatar", norm
kdensity ue1 if countryname!="Qatar", norm

pnorm e1 if countryname!="Qatar"
pnorm u1 if countryname!="Qatar"
pnorm ue1 if countryname!="Qatar"

qnorm e1 if countryname!="Qatar"
qnorm u1 if countryname!="Qatar"
qnorm ue1 if countryname!="Qatar", mlabel(countryname)

*Residuals improved

*Checking if Qatar shows as an outlier in the leverage plot:

*Final model:

*Model 1: reg co2pc execrlc lngdppc trade

*Model 2: reg co2pc execrlc lngdppc trade pop_wdi urban renew forest annexI system v2x_polyarchy island latitude

* Leverage vs residual plot

lvr2plot, mlabel(countryname)

*Qatar is a residual outlier

********************************************************************************
***********                     Figure 1                               *********
********************************************************************************

xtline co2pc if execrlc==3, overlay

********************************************************************************
********                     ANALYSIS (Table 3)                        *********
********************************************************************************
* MODEL 1

*Pooled OLS with Heteroskedasticity Robust Standard Error

reg co2pc execrlc lngdppc trade if countryname!="Qatar", robust
outreg2 using output_co2left1, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, No) ctitle(Model 1: OLS) drop(i.year) replace

*Random-effects GLS regression

xtreg co2pc execrlc lngdppc trade i.year if countryname!="Qatar", vce(cluster c_code)
outreg2 using output_co2left1, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1: GLS, Random) drop(i.year) append

*Panel corrrected standard errors (XTPCSE)

xtpcse co2pc execrlc lngdppc trade i.year if countryname!="Qatar", corr(ar1) pairwise
outreg2 using output_co2left1, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) ctitle(Model 1: PCSE) drop(i.year) append

*GLS random-effects regression with Driscoll and Kraay standard errors (XTSCC)

xtscc co2pc execrlc lngdppc trade i.year if countryname!="Qatar", lag(4)
outreg2 using output_co2left1, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1: XTSCC) drop(i.year) append

* MODEL 2

*Pooled OLS with Heteroskedasticity Robust Standard Error

reg co2pc execrlc lngdppc trade pop_wdi urban renew forest annexI island latitude if countryname!="Qatar", robust
outreg2 using output_co2left2, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, No) ctitle(Model 2: OLS) drop(i.year) replace

*Random-effects GLS regression

xtreg co2pc execrlc lngdppc trade pop_wdi urban renew forest annexI island latitude i.year if countryname!="Qatar", vce(cluster c_code)
outreg2 using output_co2left2, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 2: GLS, Random) drop(i.year) append


*Panel corrrected standard errors (XTPCSE)

xtpcse co2pc execrlc lngdppc trade pop_wdi urban renew forest annexI island latitude i.year if countryname!="Qatar", corr(ar1) pairwise
outreg2 using output_co2left2, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 2: PCSE) drop(i.year) append

*GLS random-effects regression with Driscoll and Kraay standard errors (XTSCC)

xtscc co2pc execrlc lngdppc trade pop_wdi urban renew forest annexI island latitude i.year if countryname!="Qatar", lag(4)
outreg2 using output_co2left2, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 2: XTSCC) drop(i.year) append








********************************************************************************
***     ROBUSTNESS CHECK (Table 5 and Annex XXIII, Table A and Table B)      ***
********************************************************************************
*With Lijphart's Index of Federalism Variable

* MODEL 1

*Pooled OLS with Heteroskedasticity Robust Standard Error

reg co2pc fed_lij lngdppc trade if countryname!="Qatar", robust
outreg2 using output_co2fed, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) ctitle(Model 1) drop(i.year) replace

*Random-effects GLS regression

xtreg co2pc fed_lij lngdppc trade i.year if countryname!="Qatar", vce(cluster c_code)
outreg2 using output_co2fed, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1) drop(i.year) append

*Panel corrrected standard errors (XTPCSE)

xtpcse co2pc fed_lij lngdppc trade i.year if countryname!="Qatar", corr(ar1) pairwise
outreg2 using output_co2fed, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) ctitle(Model 1) drop(i.year) append

*GLS random-effects regression with Driscoll and Kraay standard errors (XTSCC)

xtscc co2pc fed_lij lngdppc trade i.year if countryname!="Qatar", lag(4)
outreg2 using output_co2fed, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1) drop(i.year) append

* MODEL 2

*Pooled OLS with Heteroskedasticity Robust Standard Error

reg co2pc fed_lij lngdppc trade pop urban renew forest annexI island latitude if countryname!="Qatar", robust
outreg2 using output_co2fed, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1) drop(i.year) replace

*Random-effects GLS regression

xtreg co2pc fed_lij lngdppc trade pop urban renew forest annexI island latitude i.year if countryname!="Qatar", vce(cluster c_code)
outreg2 using output_co2fed, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1) drop(i.year) append


*Panel corrrected standard errors (XTPCSE)

xtpcse co2pc fed_lij lngdppc trade pop urban renew forest annexI island latitude i.year if countryname!="Qatar", corr(ar1) pairwise
outreg2 using output_co2fed, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^) addtext(Year FE, Yes) ctitle(Model 1) drop(i.year) append

*GLS random-effects regression with Driscoll and Kraay standard errors (XTSCC)

xtscc co2pc fed_lij lngdppc trade pop urban renew forest annexI island latitude i.year if countryname!="Qatar", lag(4)
outreg2 using output_co2fed, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, ^ ) addtext(Year FE, Yes) ctitle(Model 1) drop(i.year) append

*Table 00. Countries included in the analysis
list country if year==2013
********************************************************************************
*****                    FURTHER ROBUSTNESS CHECK                          *****
********************************************************************************
*FGLS
xtgls $ylist $xlist, panel (hetero) corr(ar1 or psar1)

////////////////////////////////////////////////////////////////////////////////////
*Model 1
xtreg fco2pc fedfof_devm lngdppc_devm trade_devm i.year fedfof_m lngdppc_m trade_m if countryname!="Qatar", re vce (cluster country)
outreg2 using output_co2demcorr, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, â€ ) addtext(Year FE, Yes) ctitle(Model 1) drop(i.year) replace

*Model 2
xtreg fco2pc fedfof_devm lngdppc_devm trade_devm  pop_devm urban_devm renew_devm forest_devm latitude_devm i.year fedfof_m lngdppc_m trade_m  pop_m urban_m renew_m forest_m  latitude_m annexI island if countryname!="Qatar", re vce (cluster country)
outreg2 using output_co2demcorr, dec(3) excel label alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, â€ ) addtext(Year FE, Yes) ctitle(Model 2) drop(i.year) append

///////////////////////////////////////////////////////////////////////////////////

*Cross-sectional time-series FGLS regression wtih xtgls
*Model 1
xtgls $ylist $xlist, igls panels(heteroskedastic)
estimates store hetero
xtgls $ylist $xlist, igls
local df = e(N_g) - 1
lrtest hetero . , df(`df')

*Cross-sectional time-series FGLS regression wtih xtgls
*Model 2
xtgls co2pc fedfof lngdppc trade pop urban renew forest fossil annexI island///
latitude, igls panels(heteroskedastic)
estimates store hetero
xtgls co2pc fedfof lngdppc trade pop urban renew forest fossil annexI island///
latitude, igls
local df = e(N_g) - 1
lrtest hetero . , df(`df')

********************************************************************************
********            DIAGNOSTIC TESTS OF EMPIRICAL MODELS               **********
********************************************************************************

*OBSERVED VS. PREDICTED VALUES OF DV: CO2 PER CAPITA (Appendix 9)

xtreg co2pc fedfof lngdppc trade, vce(cluster country)
predict co2pc_predict
label variable co2pc_predict "co2pc predicted"
scatter co2pc co2pc_predict


*CHECKING LINEARITY OF MAJOR CONTINUOUS VARIABLS (Appendix 10)

reg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, vce(cluster country)
acprplot lngdppc, lowess
acprplot trade, lowess
acprplot pop, lowess
acprplot urban, lowess
acprplot renew, lowess
acprplot forest, lowess
acprplot latitude, lowess


*Ramsey RESET test (Appendix 11)

*MODEL 1
reg co2pc fedfof lngdppc trade, vce (cluster country)
ovtest


*MODEL 2
reg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, vce (cluster country)
ovtest

*SPECIFICATION ERROR TEST (Appendix 12)

MODEL 1
reg co2pc fedfof lngdppc trade, vce(cluster country)
linktest

??????????????  xtreg co2pc fedfof lngdppc trade i.country i.year, vce (cluster country)    ???????? *This specification is good*

*MODEL 2*
reg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, vce (cluster country)
linktest

*MULTICOLLINEARITY TEST (Appendix 13)

*Model 1

reg co2pc fedfof lngdppc trade, vce(cluster country)
estat vif

*Model 2
reg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, vce (cluster country)
estat vif

*HETEROSKEDASTICITY TEST (Appendix 14A & 14B)

*Model 1
reg co2pc fedfof lngdppc trade
avplots
estat hettest
hettest, rhs fstat

*Model 2
reg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude
avplots
estat hettest
hettest, rhs fstat

*HAUSMAN TEST (Appendix 15)

*Model 1
xtreg co2pc fedfof lngdppc trade, fe
estimates store fixed
xtreg co2pc fedfof lngdppc trade, re
estimates store random
hausman fixed random

*Model 2
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, fe
estimates store fixed
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, re
estimates store random
hausman fixed random


*TESTING FOR TIME-FIXED EFFECT (Appendix 16)
*Model 1
xtreg co2pc fedfof lngdppc trade i.year, fe
testparm i.year

*Model 2
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude i.year, fe
testparm i.year


*TESTING FOR RANDOM EFFECTS (BREUSCH-PAGAN LAGRANGE MULTIPLIER (LM)) (Appendix 17)

*Model 1
xtreg co2pc fedfof lngdppc trade, re
xttest0

*Model 2
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, re
xttest0

*TESTING FOR CROSS-SECTIONAL DEPENDENCE/CONTEMPORANEOUS CORRELATIONS:
USING BREUSCH-PAGAN LM TEST OF INDEPENDENCE (Appendix 18A)

*Model 1
xtreg co2pc fedfof lngdppc trade, fe
xttest2

?????????????????????????????????
Error: too few common observations across panel.
no observations
r(2000);
???????????????????????????????????

*Model 2
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, fe
xttest2

*TESTING FOR CROSS-SECTIONAL DEPENDENCE/CONTEMPORANEOUS CORRELATIONS:
USING PASARAN CD TEST (Appendix 18B)

*Model 1
xtreg co2pc fedfof lngdppc trade, fe
xtcsd, pesaran abs

?????????????????????????????????????
Error: The panel is highly unbalanced.
Not enough common observations across panel to perform Pesaran's test.
insufficient observations
r(2001);
??????????????????????????????????????????

*Model 2
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, fe
xtcsd, pesaran abs

*TESTING FOR HETEROSKEDASTICITY IN FIXED EFFECT:
Modified Wald test for groupwise heteroskedasticity (Appendix 19)

*Model 1
xtreg co2pc fedfof lngdppc trade, fe
xttest3

*with robust option

xtreg co2pc fedfof lngdppc trade, fe robust
xttest3

*Model 2
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, fe
xttest3

*with robust option

xtreg co2pc fedfof lngdppc trade, fe robust
xttest3

*AUTOCORRELATION OR SERIAL CORRELATION (Appendix 20)

*Model 1

*In Graph
xtreg co2pc fedfof lngdppc trade, vce(cluster country)
predict uhat, resid
tsline uhat

*In Table
xtreg co2pc fedfof lngdppc trade, vce(cluster country)
xtserial co2pc fedfof lngdppc trade

*Model 2

*In Graph
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, vce(cluster country)
predict uhat, resid
tsline uhat

*in Table
xtreg co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, vce(cluster country)
xtserial co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude

*TESTING FOR UNIT ROOTS/STATIONARITY (Appendix 21)

xtunitroot fisher co2pc, dfuller lags(1)
xtunitroot fisher co2pc, dfuller trend demean lags(1)
xtunitroot fisher co2pc, pperron trend demean lags(1)

*CHECKING IF RESIDUALS ARE STATIONARY*
predict yhat
xtfisher yhat if yhat==1
xtfisher yhat if yhat==1, lag(2)

*CORRELATIONS MATRIX (Appendix 22)

*Model 1
pwcorr co2pc fedfof lngdppc trade, star(0.05) sig

*Model 2
pwcorr co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, star(0.05) sig

*GRAPH CORRELATIONS MATRIX (Appendix 23)

*Model 1
graph matrix co2pc fedfof lngdppc trade, half maxis(ylabel(none) xlabel(none))

*Model 2
graph matrix co2pc fedfof lngdppc trade pop urban renew forest annexI island latitude, half maxis(ylabel(none) xlabel(none))

********************************************************************************
********                   SUPPLEMENTARAY MATERIALS                    *********
********************************************************************************
*Description of data (Appendix 1)
desc

*summary statistics
summ co2pc fedfof gdppc trade pop urban renew forest annexI island latitude
outreg2 using x.doc, replace sum(log)

*Missing Observations in the Data (Appendix 2)
misstable sum

*Histogram of the Dependent Variable (CO2 per capita) (Appendix 3)
hist co2pc, kdensity scheme(s1mono) title(Per Capita CO2 Emission) xtitle(CO2 per capita) caption(Source: World Bank, span)

*Scatterplot between CO2 per capita and Year (Appendix 4)
graph twoway scatter co2pc year

*Status of CO2 emission per capita by all countries (xtline, overlay) (Appendix 5)
xtline co2pc
xtline co2pc, overlay

*Checking for Heterogeneity across countries (Appendix 6)
twoway scatter co2pc country, msymbol(circle_hollow) || connected co2pc_mean country, msymbol(diamond)

*Checking for Heterogeneity across countries (Appendix 7)
twoway scatter co2pc year, msymbol(circle_hollow) || connected co2pc_mean year, msymbol(diamond) || , xlabel(1960(1)2018)
