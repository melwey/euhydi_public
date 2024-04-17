# euhydi_public
Selection of EU-HYDI data for publication and export to csv.

EU-HYDI stands for the **EUropean HYdrological Data Inventory**. It is a dataset of soil hydrological, physical and chemical properties assembled in 2013 in the context of EU FP7 project My Water. It contains data from more than 18000 soil samples contributed by 27 institutions in Europe. The compilation work was led by Mélanie Weynants at the Joint Research Centre of the European Commission (JRC).

We are working towards making the database available under CC-BY license, without success so far. 
Some but not all contributors have agreed to make their data publicly accessible through the [European Soil Data Centre (ESDAC)](https://esdac.jrc.ec.europa.eu) of the JRC. This repository contains the R code to filter the original dataset and extract the data that may be distributed publicly on ESDAC as a set of csv files.

Table: Status of EU-HYDI contributions

|Contributor                                                                                                                    |Access     |Source in HYDI   | N profiles| N samples|
|:------------------------------------------------------------------------------------------------------------------------------|:----------|:----------------|----------:|---------:|
|Belgium: Earth and Life Institute, UCLouvain                                                                                   |public     |Javaux           |         11|        44|
|Belgium: Ghent University                                                                                                      |public     |Cornelis         |        120|       241|
|Germany: ZALF Müncheberg                                                                                                       |public     |Schindler        |         32|       298|
|Germany: ZALF Müncheberg                                                                                                       |public     |Schindler_HYPRES |         52|       471|
|Hungary: University of Pannonia                                                                                                |public     |Mako             |        308|       900|
|Italy: University of Palermo                                                                                                   |public     |Iovino           |        375|       417|
|Netherlands: Wageningen University                                                                                             |public     |Wosten_HYPRES    |        102|       358|
|Poland: Institute of Agrophysics, Polish Academy of Sciences, Lublin                                                           |public     |Lamorski         |        281|       447|
|Portugal: Instituto Nacional de Investigação Agrária e Veterinária                                                             |public     |Goncalves        |        330|       697|
|Russian Federation: Moscow State University                                                                                    |public     |Shein            |         65|       304|
|Sweden: Swedish University of Agricultural Sciences                                                                            |public     |Katterer         |        185|      1744|
|Ukraine: National Scientific Center, Institute for Soil Science and Agrochemistry Research named after ON Sokolovskiy, Kharkiv |public     |Patyka           |         95|       529|
|United Kingdom: James Hutton Institute                                                                                         |public     |Lilly            |         43|       133|
|Austria: Federal Agency for Water Management                                                                                   |restricted |Strauss          |         68|       204|
|Czechia: Czech University of Life Science in Prague                                                                            |restricted |Matula           |         72|       174|
|France: INRA, Orléans                                                                                                          |restricted |Daroussin        |        123|       352|
|Germany: BGR                                                                                                                   |restricted |Hennings_HYPRES  |        518|      1527|
|Greece: Aristotle University of Thessaloniki                                                                                   |restricted |Bilas            |        883|      2588|
|Italy: University of Naples Federico II                                                                                        |restricted |Romano           |        451|       623|
|Italy: University of Naples Federico II                                                                                        |restricted |Romano_HYPRES    |        155|       216|
|Italy: University of Padova                                                                                                    |restricted |Morari           |          5|        14|
|Norway: Bioforsk Soil and Environment                                                                                          |restricted |Kvaerno          |        283|      1091|
|Norway: Norwegian Forest and Landscape Institute                                                                               |restricted |Kvaerno          |        109|       325|
|Norway: Norwegian University of Life Sciences                                                                                  |restricted |Kvaerno          |         87|       502|
|Norway: Nowegian Water Resources and Energy Directorate                                                                        |restricted |Kvaerno          |         25|       115|
|Slovakia: Soil Fertility Research Institute                                                                                    |restricted |Houskova_HYPRES  |         14|        58|
|Slovakia: Soil Science and Conservation Research Institute                                                                     |restricted |Houskova         |         22|        97|
|Spain: Evenor-Tech                                                                                                             |restricted |Anaya            |       1081|      3787|
|United Kingdom: Cranfield University                                                                                           |restricted |Cranfield        |        119|       426|

## Additional contributions

New data can be contributed to the database under CC-BY license. Please open an issue in this github repository or contact [ec-esdac@ec.europa.eu](mailto:ec-esdac@ec.europa.eu,panos.panagos@ec.europa.eu?subject=Dataset%20Help%20Desk%20-%20European%20Hydropedological%20Data%20Inventory%20(EU-HYDI)%20database).

## Reference
Weynants, M., Montanarella, L., Tóth, G., Arnoldussen, A., Anaya Romero, M., Bilas, G., Borresen T., Cornelis W., Daroussin J., Gonalves M., Hannam J., Haugen L.E., Hennings V., Houskova B., Iovino M., Javaux M., Keay C.A., Kätterer T., Kvaerno S., Laktinova T., Lamorski K., Lilly A., Mako A., Matula S., Morari F., Nemes A., Patyka N.V., Romano N., Schindler U., Shein E., Slawinski C., Strauss P, Tóth B., Wösten, H. (2013). European HYdropedological data inventory (EU-HYDI). EUR – Scientific and Technical Research series – vol. EUR 26053 EN. Publications Office of the European Union, Luxembourg, GD Luxembourg. https://doi.org/10.2788/5936
    
