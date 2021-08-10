* Based on /t/marek/gams/ex3.gms (Nov 23, 2015)
* Energiemodell GAMS

* ------------------------------------------------------------------------------
* Set Definitionen
* ------------------------------------------------------------------------------

* Definition von Indices (Sets in GAMS) fuer Technologien, Energieformen, Energieumwandlungsebenen und Perioden

SET technology          'Technologien'
    / coal_ppl          'coal power plant'
      gas_ppl           'natural gas combined cycle power plant'
      oil_ppl           'fuel oil power plant'
      bio_ppl           'biomass power plant'
      hydro_ppl         'hydroelectric power plant'
      wind_ppl          'wind turbine'
      solar_PV          'solar photovoltaics power plant'
      import            'net electricity imports'
      electricity_grid  'electricity grid'
      bulb              'incandescent light bulb'
      cfl               'compact fluorescent light bulb'
      appliances        'electric appliances (other electricity consumption)'
    /

    energy              'Energieformen'
    / electricity
      light
      other_electricity /

    level               'Energieumwandlungsebenen'
    / secondary
      final
      useful /

    energy_level(energy, level)    'auftretende Kombinationen aus Energieformen und Umwandlungsebenen'
    / electricity.secondary
      electricity.final
      other_electricity.useful
      light.useful /

    year                'Perioden'
    / 2010
      2020
      2030
      2040
      2050
      2060 /
;

ALIAS (year, year_alias) ;

* ------------------------------------------------------------------------------
* Parameter Definitionen
* ------------------------------------------------------------------------------

* Definition von numerischen Parametern, z.B. spezifische Kosten, spezifische Energieverbrauchs- und -erzeugungskoeffizienten,
* Emissionskoeffizienten, Nachfragen, Diskontrate und Einkommenselastizitaet

PARAMETERS

    input(technology, energy, level)         'spezifische Energieverbrauchskoeffizienten'
    / electricity_grid.electricity.secondary 1
      bulb.electricity.final                 1
      cfl.electricity.final                  0.2
      appliances.electricity.final           1
    /

    output(technology, energy, level)        'spezifische Energieerzeugungskoeffizienten'
    / import.electricity.secondary           1
      electricity_grid.electricity.final     0.873
      bulb.light.useful                      1
      cfl.light.useful                       1
      appliances.other_electricity.useful    1
      coal_ppl.electricity.secondary         1
      gas_ppl.electricity.secondary          1
      oil_ppl.electricity.secondary          1
      bio_ppl.electricity.secondary          1
      hydro_ppl.electricity.secondary        1
      wind_ppl.electricity.secondary         1
      solar_PV.electricity.final             1
    /

    CO2_emission(technology)                 'spezifische CO2 Emissionskoeffizienten [tCO2/GWh]'
    / gas_ppl      0.339
      coal_ppl     0.854
      oil_ppl      0.57
    /

    water(technology)                        'spezifischer Wasserverbrauch [1000 m3/GWh]'
    / gas_ppl      1
      coal_ppl     3
      oil_ppl      2
      bio_ppl      3.5
      hydro_ppl    10
      wind_ppl     0
      solar_PV     0.1
    /

    mpa(technology)                          'maximale jaehrliche Wachstumsrate der Technologien'
    / coal_ppl     0.05
      gas_ppl      0.05
      oil_ppl      0.05
      bio_ppl      0.05
      hydro_ppl    0.05
      wind_ppl     0.05
      solar_PV     0.05
      bulb         0.05
      cfl          0.05 /

    demand(energy, level)                    'Nachfrage im Basisjahr [GWh]'
    / other_electricity.useful  55209
      light.useful               6134 /

    gdp(year)                                'Bruttoinlandsprodukt [Mrd. Euro]'
    / 2010  286.4
      2020  332.4
      2030  385.7
      2040  447.7
      2050  519.5
      2060  602.9 /

    discount_rate                            'Diskontrate'
    / 0.05 /

    beta                                     'Einkommenselastizitaet'
    / 0.7 /
;

TABLE
    inv(technology, year)
                            2010    2020    2030    2040    2050    2060
    coal_ppl                1500    1500    1500    1500    1500    1500
    gas_ppl                  870     870     870     870     870     870
    oil_ppl                  950     950     950     950     950     950
    hydro_ppl               3000    3000    3000    3000    3000    3000
    bio_ppl                 1600    1600    1600    1600    1600    1600
    wind_ppl                1100    1100    1100    1100    1100    1100
    solar_PV                4000    4000    4000    4000    4000    4000
    bulb                       9       9       9       9       9       9
    cfl                      100     100     100     100     100     100
;

TABLE
    fom(technology, year)
                            2010    2020    2030    2040    2050    2060
    coal_ppl                  40      40      40      40      40      40
    gas_ppl                   25      25      25      25      25      25
    oil_ppl                   25      25      25      25      25      25
    bio_ppl                   60      60      60      60      60      60
    hydro_ppl                 30      30      30      30      30      30
    wind_ppl                  40      40      40      40      40      40
    solar_PV                  25      25      25      25      25      25
;

TABLE
    vom(technology, year)
                            2010    2020    2030    2040    2050    2060
    coal_ppl                24.4    24.4    24.4    24.4    24.4    24.4
    gas_ppl                 42.4    42.4    42.4    42.4    42.4    42.4
    oil_ppl                 77.8    77.8    77.8    77.8    77.8    77.8
    bio_ppl                 48.2    48.2    48.2    48.2    48.2    48.2
    electricity_grid        47.8    47.8    47.8    47.8    47.8    47.8
;

PARAMETER lifetime(technology)
    /
    coal_ppl     20
    gas_ppl      20
    oil_ppl      20
    bio_ppl      20
    hydro_ppl    40
    wind_ppl     15
    solar_PV     20
    bulb         1
    cfl          10
/ ;

PARAMETER hours(technology)
    /
    coal_ppl     7000
    gas_ppl      6000
    oil_ppl      6000
    bio_ppl      6000
    hydro_ppl    4500
    wind_ppl     2000
    solar_PV     1200
    bulb         1000
    cfl          1000
/ ;

PARAMETER cost(technology, year)                 'Gesamttechnologiekosten [Euro/MWh]'
          cost_capacity(technology, year)        'Annuisierte kapazitaetsbezogene Technologiekosten [Euro/MW]'
          cost_activity(technology, year)        'Aktivitatesbezogene Technologiekosten [Euro/MWh]'
;

cost_capacity(technology, year) =  ((inv(technology, year) * ((1 + discount_rate)**(lifetime(technology)) * discount_rate) / ((1 + discount_rate)**(lifetime(technology)) - 1)
                         + fom(technology, year))) * 1000 $ (lifetime(technology) > 0) ;

cost_activity(technology, year) =  vom(technology, year) ;

cost(technology, year) =  ((inv(technology, year) * ((1 + discount_rate)**(lifetime(technology)) * discount_rate) / ((1 + discount_rate)**(lifetime(technology)) - 1)
                         + fom(technology, year)) / (hours(technology)/1000)) $ (lifetime(technology) > 0)
                         + vom(technology, year) ;


DISPLAY cost, cost_capacity, cost_activity ;

* ------------------------------------------------------------------------------
* Variablen und Gleichungen
* ------------------------------------------------------------------------------

* Definition von Variablen, die Gegenstand der Optimierung sind

VARIABLES
    X(technology, year)   'Technologieaktivitaet in Periode year'
    Y(technology, year)   'neue Technologiekapazitaet gebaut in Periode year'
    CO2_TOTAL(year)       'CO2 Emissionen in Periode year'
    CO2_CUM        'kumulative CO2 Emissionen'
    WATER_TOTAL(year)     'Wasserverbrauch in Periode year'
    WAT_CUM      'kumulativer Wasserverbrauch'
    TOT_COST            'Gesamtkosten'
;

* Deklaration von Gleichungen

EQUATIONS
    EQ_ENERGY_BALANCE          'Angebot > Nachfrage Gleichung fuer alle Energietraeger/-ebenen'
    EQ_CAPACITY_BALANCE        'Kapazitaetsgleichungen fuer alle Technologien'
    EQ_CO2_EMISSION            'Summe der jaehrlichen CO2 Emissionen'
    EQ_CO2_EMISSION_CUMULATIVE 'Summe der kumulativen CO2 Emissionen'
    EQ_WATER                   'Summe des jaehrlichen Wasserverbrauchs'
    EQ_WATER_CUMULATIVE        'Summe des kumulativen Wasserverbrauchs'
    EQ_MARKET_PENETRATION_UP   'obere Technologiediffusionsbeschraenkung (market penetration constraint)'
    EQ_COST                    'Aufsummierung der Gesamtkosten'
;

* Definition von Gleichungen

EQ_ENERGY_BALANCE(energy, level, year) $ energy_level(energy, level)..
    SUM(technology, X(technology, year) * (output(technology, energy, level) - input(technology, energy, level)))
  - demand(energy, level) * (gdp(year)/gdp('2010'))**beta =G= 0 ;

EQ_CAPACITY_BALANCE(technology, year) $ hours(technology)..
    SUM(year_alias $ ((ORD(year_alias) LE ORD(year)) AND ((ORD(year) - ORD(year_alias)) * 10) LE lifetime(technology)), Y(technology, year_alias) * MIN((lifetime(technology) - (ORD(year) - ORD(year_alias)) * 10) / 10, 1)) * hours(technology) =G= X(technology, year) ;

EQ_CO2_EMISSION(year)..
    SUM(technology, X(technology, year) * CO2_emission(technology)) =E= CO2_TOTAL(year) ;

EQ_CO2_EMISSION_CUMULATIVE..
    SUM(year, CO2_TOTAL(year)) * 10 =E= CO2_CUM ;

EQ_WATER(year)..
    SUM(technology, X(technology, year) * water(technology)) =E= WATER_TOTAL(year) ;

EQ_WATER_CUMULATIVE..
    SUM(year, WATER_TOTAL(year)) * 10 =E= WAT_CUM ;

EQ_MARKET_PENETRATION_UP(technology, year) $ ((NOT ORD(year) = 1) AND mpa(technology))..
    X(technology, year) =L= X(technology, year - 1) * (1 + mpa(technology))**10 + SUM((energy, level), demand(energy, level)) * (gdp(year)/gdp('2010'))**beta * 0.05 ;

EQ_COST..
    SUM((technology, year), cost_activity(technology, year) * X(technology, year) * 10 * (1 - discount_rate)**(10 * (ORD(year) - 1)))
  + SUM((technology, year), cost_capacity(technology, year) * Y(technology, year) * SUM(year_alias $ ((ORD(year_alias) GE ORD(year)) AND ((ORD(year_alias) - ORD(year)) * 10) LE lifetime(technology)), MIN((lifetime(technology) - (ORD(year_alias) - ORD(year)) * 10), 10) * (1 - discount_rate)**(10 * (ORD(year_alias) - 1))))
=E= TOT_COST ;

* Beschraenkungen individueller Variablen

X.LO(technology, year) = 0 ;
Y.LO(technology, year) = 0 ;

* ------------------------------------------------------------------------------
* Modellkalibrierung und Ressourcenbeschraenkungen fuer erneuerbare Energien
* ------------------------------------------------------------------------------

* Beschraenkung des Wasserkraftpotenzials auf 2010 Produktion
X.UP('hydro_ppl', year) = 38406 ;
* Beschraenkung des Biomassepotenzials auf gegenwaertige Gesamtproduktion (Primaerenergie * Umwandlungseffizienz des Biomassekraftwerks)
X.UP('bio_ppl', year) = 20667 ;

* Kalibrierung der Technologieaktivitaet fuer 2010
X.FX('coal_ppl', '2010') = 7184 ;
X.FX('oil_ppl', '2010') = 1275 ;
X.FX('gas_ppl', '2010') = 14346 ;
X.FX('bio_ppl', '2010') = 4554 ;
X.FX('hydro_ppl', '2010') = 38406 ;
X.FX('wind_ppl', '2010') = 2064 ;
X.FX('solar_PV', '2010') = 89 ;
X.FX('import', year) = 2340 ;

X.FX('bulb', '2010') = 6134 ;
X.FX('cfl', '2010') = 0 ;

* Kalibrierung der Technologiekapazitaet fuer 2010
Y.FX('coal_ppl', '2010') = 1.027 ;
Y.FX('oil_ppl', '2010') = 0.213 ;
Y.FX('gas_ppl', '2010') = 2.391 ;
Y.FX('bio_ppl', '2010') = 0.759 ;
Y.FX('hydro_ppl', '2010') = 8.535 ;
Y.FX('wind_ppl', '2010') = 1.032 ;
Y.FX('solar_PV', '2010') = 0.075 ;

Y.FX('bulb', '2010') = 61.340 ;
Y.FX('cfl', '2010') = 0 ;

* optionale Beschraenkungen
*CO2_TOTAL.UP(year) $ (NOT SAMEAS(year, '2010')) = 12900 ;
*CO2_CUMULATIVE.UP = 1.5E6 ;
*WATER_CUMULATIVE.UP = 2.0E7 ;

* ------------------------------------------------------------------------------
* Aufruf des Loesungsalgorithmus
* ------------------------------------------------------------------------------

* Wahl des Loesungsalgorithmus (nur notwendig falls nicht nicht unter File/Options/Solvers gewaehlt)

OPTION LP = BDMLP ;


* mc-file name defined as the mca-arg on the cmd line
$If set mcma $INCLUDE %mcma%
$If set mcma $GOTO post_solve

* Definition des Modells (Schluesselwort 'all' bedeutet, dass alle oben deklarierten Gleichungen Bestandteil des Modells sind)

MODEL simple / all / ;

* Wahl des Modellnames, -typs und Aufruf des Loesungsalgorithmus

SOLVE simple using LP minimize TOT_COST ;

$LABEL post_solve

* ------------------------------------------------------------------------------
* Exportieren der Modellergebisse im csv Format
* ------------------------------------------------------------------------------

* Dateiname
FILE model_output / "model_results.csv" / ;

* options for output format
model_output.lw = 0 ;
model_output.sw = 0 ;
* numeric field width
model_output.nw = 12 ;
* scientific notation
model_output.nr = 2 ;
* number of decimals
model_output.nd = 4 ;
* page control
model_output.pc = 2 ;

PUT model_output ;

* File Header contains name of scenario and execution date and time
model_output.pc = 2 ;
PUT system.title/ system.date, ' ', system.time/ ;

* data output mode for csv-type file
model_output.pc = 5 ;

PUT model_output ;

* ------------------------------------------------------------------------------
* Elektrizitaetserzeugung
* ------------------------------------------------------------------------------

* Nach Einfuehrung zusaetzlicher Technologien (z.B. nuclear_ppl oder geo_ppl) muss die Tabelle ergaenzt werden.
* Dazu ist der entsprechende Spaltentitel in der 2. PUT Anweisung hinzugefuegt werden und am Ende der PUT
* Anweisung im LOOP die Aktivitaet der entsprechenden Technologie angehaengt werden.

PUT / 'electricity generation', 'GWh'/ ;

PUT '', 'Import', 'Coal', 'Gas', 'Oil', 'Biomass', 'Hydro', 'Wind', 'Solar' / ;
LOOP(year,
        PUT year.tl,
            (X.L('import', year)),
            (X.L('coal_ppl', year)),
            (X.L('gas_ppl', year)),
            (X.L('oil_ppl', year)),
            (X.L('bio_ppl', year)),
            (X.L('hydro_ppl', year)),
            (X.L('wind_ppl', year)),
            (X.L('solar_PV', year)) /
) ;

* ------------------------------------------------------------------------------
* neu gebaute Kapazitaet
* ------------------------------------------------------------------------------

* Nach Einfuehrung zusaetzlicher Technologien (z.B. nuclear_ppl oder geo_ppl) muss die Tabelle ergaenzt werden.
* Dazu ist der entsprechende Spaltentitel in der 2. PUT Anweisung hinzugefuegt werden und am Ende der PUT
* Anweisung im LOOP die Aktivitaet der entsprechenden Technologie angehaengt werden.

PUT / 'new capacity', 'GW'/ ;

PUT '', 'Coal', 'Gas', 'Oil', 'Biomass', 'Hydro', 'Wind', 'Solar' / ;
LOOP(year,
        PUT year.tl,
            (Y.L('coal_ppl', year)),
            (Y.L('gas_ppl', year)),
            (Y.L('oil_ppl', year)),
            (Y.L('bio_ppl', year)),
            (Y.L('hydro_ppl', year)),
            (Y.L('wind_ppl', year)),
            (Y.L('solar_PV', year)) /
) ;

* ------------------------------------------------------------------------------
* Endenergieverbrauch (Elektrizitaet)
* ------------------------------------------------------------------------------

PUT / 'final energy consumption', 'GWh'/ ;

PUT '', 'electricity' / ;
LOOP(year,
        PUT year.tl,
            (X.L('bulb', year) * input('bulb', 'electricity', 'final')
           + X.L('cfl', year) * input('cfl', 'electricity', 'final')
           + X.L('appliances', year) * input('appliances', 'electricity', 'final')) /
) ;

* ------------------------------------------------------------------------------
* Emissionen
* ------------------------------------------------------------------------------

PUT / 'emissions', 'kt CO2'/ ;

PUT '', 'CO2 (electricity generation only)' / ;
LOOP(year,
        PUT year.tl,
            CO2_TOTAL.L(year) /
) ;

* ------------------------------------------------------------------------------
* Endenergietechnologien
* ------------------------------------------------------------------------------

PUT / 'lighting output (incandescent equivalent)', 'GWh'/ ;

PUT '', 'incandescent light bulb', 'compact fluorescent light bulb' / ;
LOOP(year,
        PUT year.tl,
            (X.L('bulb', year)),
            (X.L('cfl',year)) /
) ;
