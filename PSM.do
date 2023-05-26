

global $ruta "D:\PEA UNI\Modulo 4\EVALUACION DE IMPACTO\Nueva carpeta"
cd $ruta
*------

* Consideramos a los hogares que respondieron 2019 y 2021

* 100
use enaho01-2017-2021-100-panel.dta ,clear

rename a*o_19 anio_19
rename a*o_21 anio_21

destring anio_19 , replace
destring anio_21 , replace 

** Pared noble

g pared_noble = 0 if p102_19!=.
replace pared_noble=1 if p102_19==1 | p102_19==2


*** Piso no precario
g piso = 0 if p103_19!=.
replace piso=1 if p103_19==1 | p103_19==2 | p103_19==3



*** Techo no precario 
g techo = 0 if p103a_19!=.
replace techo=1 if p103a_19==1 | p103a_19==2 | p103a_19==3

** Electricidad

tab p1121_19

clonevar electricidad = p1121_19

** Agua potable

g agua = 0 if p110_19!=.
replace agua=1 if p110_19==1 | p110_19==2 
	

** Serv higineicos red publica
g serv_higienico = 0 if p111a_19!=.
replace serv_higienico=1 if p111a_19==1 | p111a_19==2 
	
	


keep if anio_19!=. & anio_21!=.
keep if hpanel_1921==1
save "enaho_100.dta",replace



* Modulo 200
*----------------


use enaho01-2017-2021-200-panel.dta ,clear

rename a*o_19 anio_19
rename a*o_21 anio_21

destring anio_19 , replace
destring anio_21 , replace 

keep if anio_19!=. & anio_21!=.

** Niños de 0 a 10 años

gen nino_0_10 = 0 if p208a_19 !=.
replace nino_0_10=1 if p208a_19>=0 & p208a_19<=10 

egen nino_0a10 = total(nino_0_10),  by(numpanh21)


 ** 18 a 25 años 
 
gen adoc_18_25 = 0 if p208a_19 !=.
replace adoc_18_25=1 if p208a_19>=18 & p208a_19<=25

egen adoc_18a25 = total(adoc_18_25),  by(numpanh21)

*** Adultos mayores
gen adult_60 = 0 if p208a_19 !=.
replace adult_60=1 if p208a_19>=60

egen adulto_mayor = total(adult_60),  by(numpanh21)

*** Jh mujer 
g jh_hombre = 0 if p203_19!=.
replace jh_hombre=1 if p207_19==1 & p203_19==1


*** AREA
gen             area=estrato_21
recode        area (1/5=1) (6/8=0)
lab def        area 1 "Urbana"  0 "Rural", modify
lab val        area area
lab var        area "Area de residencia"


** Casados
gen est_civil = 0 if p209_19!=.
replace est_civil=1 if p209_19==2

egen casado = total(est_civil),  by(numpanh21)


*** Trabajo: Cantidad de miembros del hogar que trabajan

g work = 0 if p210_19!=.
replace work=1 if p210_19==1

egen trabajo = total(work),  by(numpanh21)
	
keep if p203_21==1 & p203_19==1
keep if perpanel1921==1

save "enaho_200.dta",replace





** Modulo 300
*------------------

use enaho01a-2017-2021-300-panel.dta ,clear

rename a*o_19 anio_19
rename a*o_21 anio_21

destring anio_19 , replace
destring anio_21 , replace 

keep if anio_19!=. & anio_21!=.


** Jefe de hogar con educ secundaria

g jh_secundaria=0 if p301a_19!=.
replace jh_secundaria=1 if p301a_19==6

** Jefe de hogar con educ superior

g jh_superior=0 if p301a_19!=.
replace jh_superior=1 if p301a_19>=7 & p301a_19<=11

keep if p203_21==1 & p203_19==1
keep if perpanel1921==1

save "enaho_300.dta",replace


* Sumaria
use sumaria-2017-2021-panel.dta , clear
rename a*o_19 anio_19
rename a*o_21 anio_21

destring anio_19 , replace
destring anio_21 , replace 


** Ingreso percapita mensual.
foreach x in 19 21 {
    
	g ing_per_mensual_`x'= ingmo1hd_`x'/mieperho_`x'
	
	
}


** Ingreso percapita mensual periodo anterior.
	
	g ing_per_mensual_ant_21= ingmo1hd_20/mieperho_20
	
	g ing_per_mensual_ant_19= ingmo1hd_18/mieperho_18


keep if anio_19!=. & anio_21!=.
keep if hpanel_1921==1
save "sumaria.dta",replace


******* Merge 

use enaho_100.dta , clear
clonevar numpanh21= numpanh
merge 1:1  numpanh21 conglome vivienda using enaho_200.dta

drop _merge

merge 1:1  numpanh21 conglome vivienda using enaho_300.dta

drop _merge

drop *17
drop *18
drop *20

merge 1:1  numpanh conglome vivienda using sumaria.dta

keep if _merge==3


** Acceso a Internet

recode p1144_19 (0 = 0 "Control") (1=1 "Tratamiento"), g(internet_19)

save "base_impacto.dta" , replace
use base_impacto.dta , clear

keep numpanh conglome vivienda pared_noble piso techo electricidad agua serv_higienico nino_0a10 adoc_18a25 adulto_mayor jh_hombre area casado trabajo jh_secundaria jh_superior ing_per_mensual_19 ing_per_mensual_21  ing_per_mensual_ant_21 ing_per_mensual_ant_19 internet_19


save "base_final.dta" , replace
use base_final.dta, clear



* Instalamos programas necesarios para hacer el Pscore

ssc install psmatch2, replace

net from http://www.stata-journal.com/software/sj5-3
net install st0026_2


**************************************
* Características de la base de datos
**************************************

/* La variable ingreso se encuentra en dos valores, pre o post tratamiento

ing_per_mensual_19 
ing_per_mensual_21

* El resto de variables muestra información de la línea de base
*/

**************************************
* Probabilidad de participación
**************************************

use base_final.dta, clear
global X pared_noble piso techo electricidad agua serv_higienico nino_0a10 adoc_18a25 adulto_mayor jh_hombre area casado trabajo jh_secundaria jh_superior ing_per_mensual_19 ing_per_mensual_ant_19 




dprobit internet_19  $X // Agregar al trabajo
 
* Paso 2: Generamos las probabilidades predichas en el probit
predict pscore
 
* Paso 3: Observamos los resultados en histogramas
histogram pscore, by(internet_19) 
// Tratados y No tratados


	* Caso: Tratados // Agregar al trabago
histogram pscore if internet_19==1, bin(100) color(blue) addplot(kdensity pscore if internet==1)
kdensity pscore if internet_19==1, epanechnikov generate(x1 y1)

	* Caso: No tratados
histogram pscore if internet_19==0, bin(100) color(blue) addplot(kdensity pscore if internet_19==0)
kdensity pscore if internet_19==0, epanechnikov generate(x0 y0)


twoway (line y1 x1) (line y0 x0, lpattern(dash)), ytitle(Densidad) xtitle(Probabilidad de ser tratado) ///
 title(Propensity Score ) legend(order(1 "Tratados" 2 "No tratados"))



/* Paso 4: Estimamos el área de soporte común

* Definimos un máximo y un mínimo para la probabilidad de emparejamiento considerando los extremos de los histogramas de los tratados (mínimo de emparejamiento) y no tratados (máximo de emparejamiento)
*/
gen pscore_sc=pscore

* Máxima probabilidad
sum pscore_sc if internet_19==0
scalar max_D=r(max)
display max_D

* Mínima probabilidad
sum pscore_sc if internet==1
scalar min_D=r(min)
display min_D

**** Empleamos solamente la probabilidad predicha para un área de soporte
replace pscore_sc=. if pscore_sc > max_D
replace pscore_sc=. if pscore_sc < min_D

**** Analizamos el número de datos perdidos en relación al total original de pscore:
count if pscore!=. & pscore_sc==.

**** Graficamos la distribuciones en el área de soporte:

drop x1 y1 x0 y0

quiet kdensity pscore_sc if internet_19==1, epanechnikov generate(x1 y1)
quiet kdensity pscore_sc if internet_19==0, epanechnikov generate(x0 y0)

twoway (line y1 x1) (line y0 x0, lpattern(dash)), ytitle(Densidad) xtitle(Probabilidad de ser tratado) ///
 title(Propensity Score con Soporte Común ) legend(order(1 "Participante=1" 2 "No participante=0"))


/* Paso 5: Evaluar la calidad del emparejamiento


a) Se generan tres bloques de información buscando que dentro de los mismos la probabilidad de emparejamiento sea casi la misma entre tratados
y no tratados.

b) Si en algunos de los bloques (generalmente pasa en el central) no se comple que ambas probabilidades son estadísticamente iguales, el bloque se parte
y se ejecuta nuevamente el test de diferencia en medias.

c) Luego de estimar de manera eficiente todos los bloques, se evalúa que todos los regresores se encuentren balanceados (que no difieran entre tratados
y no tratados considerando que son variables pre tratamiento.


comsup : Considera para el análisis a todos los tratados, excluyendo a los no tratados que se encuentren fuera del área de soporte común
		 (con probabilidad debajo de la mínima observada en los tratados). No se excluyen del análisis a los tratados que
		 tienen probabilidades de participación por encima del máximo obervado en los no tratados, esto es, tratados que tenía altas 
		 probabilidades de recibir tratamiento.
	 
*/		 

pscore internet_19 $X , pscore(pscore_b) blockid(id) comsup det 

* Nota, podemos evaluar las diferencias entre el valor estimado de manera manual y el estimado de manera automática

sum pscore_sc pscore_b if comsup==1




*-------------------------------------------------
*Selección de un algoritmo de emparejamiento 
*-------------------------------------------------


**** Emparejamiento
psmatch2 internet_19 $X , outcome(ing_per_mensual_21) n(10) com

psmatch2 internet_19 $X , outcome(ing_per_mensual_21) com kernel  


// Unmatched : respecto al total de la muestra
// ATT:Hacemos emparejamiento  t > 2 , p value es cero rechazo la hipotesis nula 

// Impacto positivo  2570.6584  para los individuos que son parte del programa 


*-----------------------------------* 
* Dobles diferencias emparejadas *
*-----------------------------------*

**** la evolución de la variable "ingreso" de los individuos en dos periodos.


gen delta_ingreso=ing_per_mensual_21-ing_per_mensual_19

**** Ahora utilizamos propensity score matching para evaluar la diferencia en la evolución del ingreso entre hogares tratados y no tratados

**** Matching con 10 vecinos
psmatch2 internet_19 $X, outcome(delta_ingreso) n(10) com


**** Emparejamiento por kernel, soporte común 

psmatch2 internet_19 $X, outcome(delta_ingreso) com kernel


******************************** FIN :D

