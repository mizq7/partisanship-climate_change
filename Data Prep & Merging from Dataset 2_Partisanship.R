#Data preprocessing

**Table of Contents, Partisanship Chapter**

*PHASE 1: RETRIEVING RELEVANT VARIABLES FROM WDI DATA
*PHASE 2: ALL 3 MEASURES OF PARTISANSHIP DATASET WERE PREPARED & SAVED IN THE COMPUTER DIRECTORY TO MERGE WITH WDI DATASET
*PHASE 3: MERGING WDI AND DPI2017 DATASET
*PHASE 4: MERGING WDI_DPI2017 DATASET WITH CPDS DATASET
*PHASE 5: MERGING WDI-DPI17-CPDS_MERGED DATASET WITH SWANK DATASET
*PHASE 6: CLEANING UNNCESSARY VARIABLES FROM WDI-DPI17-CPDS_SWANK_MERGED DATASET
*PHASE 7: MERGING FEDERALISM "FORUM OF FEDERALIM" (DUMMY) VARIABLE
*PHASE 8: MERGING ANNEX I DATA
*PHASE 9: MERGING ISLAND DUMMIES DATA. I HAVE TAKEN THIS DATASET FROM BETZ, COOK & HOLLENBACK (2018)
*PHASE 10: MERGING LOG OF LATITUDE DATA. I HAVE TAKEN THIS DATASET FROM BETZ, COOK & HOLLENBACK (2018)
*PHASE 11: DROPPING VARIABLES OF DIFFERENT REGIONS FROM THE MASTER 'partisanship5' DATASET
*PHASE 12: RENAMING SOME VARIABLES TAKEN FROM WDI DATASET
*PHASE 13: MERGING POLITYIV DATASET
*PHASE 14: MERGING V-DEM DATASET
*PHASE 15: DROPPING UNNECESSARY VARIABLES FROM POLITYIV AND V-DEM DATASET
*PHASE 16: REPLACING MISSING OBSERVATION WITH DOT (.) FROM MASTER 'partisanship10' DATASET
*PHASE 17: CHECKING & REMOVING DUPLICATES TO PREPARE THE DATA FOR ANALYSIS OF TIME SERIES CROSS-SECTIONAL DATA
*PHASE 18: CREATING COUNTRY AS GROUP IDENTIFIER
*PHASE 19: LABELING THE VARIABLE


clear all
set more off

*PHASE 1: RETRIEVING RELEVANT VARIABLES FROM WDI DATA

wbopendata, language(en - English) indicator(EN.ATM.CO2E.KT; EN.ATM.CO2E.PC; EN.ATM.CO2E.EG.ZS; SP.URB.TOTL.IN.ZS; AG.LND.FRST.ZS; NY.GDP.PCAP.PP.KD; SP.POP.TOTL; EG.FEC.RNEW.ZS; NE.TRD.GNFS.ZS; SP.URB.TOTL.IN.ZS; EG.USE.COMM.FO.ZS; NE.EXP.GNFS.ZS; NV.IND.TOTL.ZS; AG.LND.AGRI.K2; ER.PTD.TOTL.ZS; NY.GDP.PETR.RT.ZS; EG.CFT.ACCS.ZS; NY.GDP.COAL.RT.ZS; EN.ATM.GHGT.KT.CE) long clear
sort countrycode year
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\wdi.dta", replace

*PHASE 2: ALL 3 MEASURES OF PARTISANSHIP DATASET WERE PREPARED & SAVED IN THE COMPUTER DIRECTORY TO MERGE WITH WDI DATASET

*Partisanship data were merged with country code and year variables. Country code variables are///
different in 3 partisanship datasets (DPI2017, Swank Dataset and Comparative Political Data Set (CPDS)).

They are made common with "countrycode" with following command:

gen countrycode = scode/ifs/etc..
sort countrycode year
duplicates list countrycode year
drop in 1/2

*PHASE 3: MERGING WDI AND DPI2017 DATASET

merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Data_All_Partisanship Chapter\IV_Partisanship\Database of Political Institutions\Database DPI2017\dpi2017_muinul.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\wdi_dpi17_merged.dta", replace

*PHASE 4: MERGING WDI_DPI2017 DATASET WITH CPDS DATASET

drop _merge
merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Data_All_Partisanship Chapter\IV_Partisanship\Comparative Political Data Set\cpds_muinul.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\wdi_dpi17_cpds_merged.dta", replace

*PHASE 5: MERGING WDI-DPI17-CPDS_MERGED DATASET WITH SWANK DATASET

drop _merge
merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Data_All_Partisanship Chapter\IV_Partisanship\Swank\swank_muinul.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\wdi_dpi17_cpds_swank_merged.dta", replace

*PHASE 6: CLEANING UNNCESSARY VARIABLES FROM WDI-DPI17-CPDS_SWANK_MERGED DATASET

*Using <keep> syntax, from a total of 1920 variables, I have kept only 76 variables for my empirical analysis,///
the name of datafile is changed to partisanship1 containing only 76 variables*

keep countryname countrycode iso2code region regioncode year en_atm_co2e_kt en_atm_co2e_pc en_atm_co2e_eg_zs sp_urb_totl_in_zs ag_lnd_frst_zs ny_gdp_pcap_pp_kd sp_pop_totl eg_fec_rnew_zs ne_trd_gnfs_zs eg_use_comm_fo_zs ne_exp_gnfs_zs nv_ind_totl_zs ag_lnd_agri_k2 er_ptd_totl_zs ny_gdp_petr_rt_zs eg_cft_accs_zs ny_gdp_coal_rt_zs en_atm_ghgt_kt_ce ifs system execrlc totalseats polariz country countryn iso iso3n cpds1 year_01 country_01 year_03 country_03 year_04 country_04 year_13 country_13 pop gov_right1 gov_cent1 gov_left1 gov_party gov_left2 gov_left3 leftc leftgs lefts leftv rightc rights rightv tcdemc tcdemgs tcdems tcdemv mcdemc mcdemgs mcdems mcdemv centc centgs  cents centv rwpc rwpgs rwpseat rwpvote llc llgs llseat llvote

*Saving this version of datafile with filename "dem1"*
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship1.dta", replace

**MERGING CONTROL VARIABLES**

*PHASE 7: MERGING FEDERALISM "FORUM OF FEDERALIM" (DUMMY) VARIABLE

merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\02_Federalism\Data_All_Federalism Chapter\IV_federal\fedfof.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship2.dta", replace

*PHASE 8: MERGING ANNEX I DATA

*This time I will merge Annex I data. First, I've created this variable in excel file and then converted to STATA file and then I will merge.

drop _merge
merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\CONTROL VARIABLES\Annex I\annexI.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship3.dta", replace

*PHASE 9: MERGING ISLAND DUMMIES DATA. I HAVE TAKEN THIS DATASET FROM BETZ, COOK & HOLLENBACK (2018)

*In this dataset, I could include a total of 51 countries. Two countries Netherlands Antilles and Hong Kong, SAR, China) were not available in WDI or my master dataset.*

drop _merge
merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\CONTROL VARIABLES\Island Dummies\island.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship4.dta", replace

*PHASE 10: MERGING LOG OF LATITUDE DATA. I HAVE TAKEN THIS DATASET FROM BETZ, COOK & HOLLENBACK (2018)

drop _merge
merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\CONTROL VARIABLES\Latitude\latitude.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship5.dta", replace

*PHASE 11: DROPPING VARIABLES OF DIFFERENT REGIONS FROM THE MASTER 'partisanship5' DATASET

clear
use "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship5.dta", clear
drop if countryname == "Arab World"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "Caribbean small states"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Euro area"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "High income"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "IBRD only"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "Isle of Man"
drop if countryname == "Not classified"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Low & middle income"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle income"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "North America"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "French Polynesia"
drop if countryname == "South Asia"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Small states"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"
drop if countryname == "Sint Maarten (Dutch part)"
drop if countryname == "Turks and Caicos Islands"
drop if countryname == "British Virgin Islands"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"

*Saving this version of datafile named as dem6*
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship6.dta", replace

*PHASE 12: RENAMING SOME VARIABLES TAKEN FROM WDI DATASET

*Data for CO2 emissions (kt)*
rename en_atm_co2e_kt co2
*Data for CO2 emissions (metric tons per capita)*
rename en_atm_co2e_pc co2pc
*Data for CO2 intensity (kg per kg of oil equivalent energy use)*
rename en_atm_co2e_eg_zs co2int
*Data for Urban population (% of total)*
rename sp_urb_totl_in_zs urban
*Data for Forest area (% of land area)*
rename ag_lnd_frst_zs forest
*Data for GDP per capita, PPP (constant 2011 international $)*
rename ny_gdp_pcap_pp_kd gdppc
*Data for Population, Total*
rename sp_pop_totl pop
*Data for Renewable energy consumption (% of total final energy consumption)*
rename eg_fec_rnew_zs renew
*Data for Trade (% of GDP)*
rename ne_trd_gnfs_zs trade
*Data for Fossil fuel energy consumption (% of total)*
rename eg_use_comm_fo_zs fossil
*Data for Exports of goods and services (% of GDP)*
rename ne_exp_gnfs_zs export
*Data for Industry (including construction), value added (% of GDP)*
rename nv_ind_totl_zs industry
*Data for Agricultural land (sq. km)*
rename ag_lnd_agri_k2 agriland
*Data for Terrestrial and marine protected areas (% of total territorial area)*
rename er_ptd_totl_zs protect
*Data for Oil rents (% of GDP)*
rename ny_gdp_petr_rt_zs oil
*Data for Access to clean fuels and technologies for cooking (% of population)*
rename eg_cft_accs_zs cleancook
*Data for Coal rents (% of GDP)*
rename ny_gdp_coal_rt_zs coal
*Data for Total greenhouse gas emissions (kt of CO2 equivalent)*
rename en_atm_ghgt_kt_ce ghg

*Saving this version of datafile as dem7*
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship7.dta", replace

*PHASE 13: MERGING POLITYIV DATASET

drop _merge
merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\01_Democracy\Data_All_Democracy Chapter\IV_Democracy\Polity IV\PolityIV_muinul.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship8.dta", replace

*PHASE 14: MERGING V-DEM DATASET

drop _merge
merge 1:1 countrycode year using "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\01_Democracy\Data_All_Democracy Chapter\IV_Democracy\V-Dem\vdem_muinul.dta"
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship9.dta", replace

*PHASE 15: DROPPING UNNECESSARY VARIABLES FROM POLITYIV AND V-DEM DATASET

drop ................................
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship10.dta", replace

*PHASE 16: REPLACING MISSING OBSERVATION WITH DOT (.) FROM MASTER 'partisanship10' DATASET

clear
use "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship10.dta"

mvdecode system, mv(-999)
mvdecode execrlc, mv(-999)
mvdecode totalseats, mv(-999)
mvdecode polariz, mv(-999)

mvdecode leftc, mv(-999)
mvdecode leftgs, mv(-999)
mvdecode lefts, mv(-999)
mvdecode leftv, mv(-999)
mvdecode rightc, mv(-999)
mvdecode rights, mv(-999)
mvdecode rightv, mv(-999)
mvdecode tcdemc, mv(-999)
mvdecode tcdemgs, mv(-999)
mvdecode tcdems, mv(-999)
mvdecode tcdemv, mv(-999)
mvdecode mcdemc, mv(-999)
mvdecode mcdemgs, mv(-999)
mvdecode mcdems, mv(-999)
mvdecode mcdemv, mv(-999)
mvdecode centc, mv(-999)
mvdecode centgs, mv(-999)
mvdecode cents, mv(-999)
mvdecode centv, mv(-999)
mvdecode rwpc, mv(-999)
mvdecode rwpgs, mv(-999)
mvdecode rwpseat, mv(-999)
mvdecode rwpvote, mv(-999)
mvdecode llc, mv(-999)
mvdecode llgs, mv(-999)
mvdecode llseat, mv(-999)
mvdecode llvote, mv(-999)

mvdecode polity2, mv(-66)
mvdecode polity2, mv(-77)
mvdecode polity2, mv(-88)

*Saving this version of datafile as dem7 just like previous, not a new file*
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship11.dta", replace

*PHASE 17: CHECKING & REMOVING DUPLICATES TO PREPARE THE DATA FOR ANALYSIS OF TIME SERIES CROSS-SECTIONAL DATA

use "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\01_Democracy\Dataset 2\dem7.dta"
duplicates report countrycode year
*No duplicates are observed

*PHASE 18: CREATING COUNTRY AS GROUP IDENTIFIER

sort countrycode
by countrycode: gen ctynum = 1 if _n==1
replace ctynum = sum(ctynum)
replace ctynum = . if missing(ctynum)

*PHASE 19: LABELING THE VARIABLE

lab var co2 "CO2 emissions (kt)"
lab var co2pc "CO2 Emission (per capita)"
lab var co2int "CO2 intensity (kg per kg of oil equivalent energy use)"
lab var urban "Urban population (% of total population)"
lab var forest "Forest area (% of land area)"
lab var gdppc "GDP per capita, PPP (constant 2011 international $)"
lab var pop "Population, total"
lab var renew  "Renewable energy consumption (% of total final energy consumption)"
lab var trade  "Trade (% of GDP)"
lab var fossil  "Fossil fuel energy consumption (% of total)"
lab var export  "Exports of goods and services (% of GDP)"
lab var agriland  "Agricultural land (sq. km)"
lab var oil  "Oil rents (% of GDP)"
lab var cleancook  "Access to clean fuels and technologies for cooking (% of population)"
lab var coal  "Coal rents (% of GDP)"
lab var annexI  "Parties to the Kyoto Protocol"
lab var fedfof  "Forum of Federation"
lab var island  "Island dummies"
lab var industry "Industry (including construction), value added (% of GDP)"
lab var protect "Terrestrial and marine protected areas (% of total territorial area)"
lab var ghg "Total greenhouse gas emissions (kt of CO2 equivalent)"


*Saving this version of datafile as fed12*
save "C:\Users\Muinul\Google Drive\Muinul\00_DISSERTATION\03_Partisanship\Dataset\partisanship12.dta", replace

*PREPARING COUNTRYCODE VARIABLE FROM STIRNG FORMAT TO LONG FORMAT
encode countrycode, gen(ccode)
