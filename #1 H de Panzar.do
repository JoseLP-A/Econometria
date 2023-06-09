
/*
Comparto mi sintaxis utilizada en el documento de trabajo
"Competencia en el mercado de servicios móviles en el Perú: Una aplicación del estadístico H de Panzar y Rose" -
Mg Manuel Gavilano
*/
global ruta "C:\Users\JOSE\Desktop\Manuel"
cd $ruta


* Impoortamos la base de datos
import excel "C:\Users\jleiva\Desktop\Jose\Trabajo\Manuel\25-01-23\base_data.xlsx", sheet("Base de datos") firstrow clear


** Limpieza de la data

foreach x in ingresos_operativos trabajadores /*
*/ i_o_pt suel_sal_todos_anualmiles suel_sal_todos_anualsoles /*
*/ suel_sal_moviles_anualmiles part_movil_total suel_sal_moviles_anualsoles /*
*/ suel_sal_moviles_trimes suel_sal_moviles_mens suel_sal_moviles_mes15 salario_minimo /*
*/ gastos_admin_anual_miles gastos_admin_trim_miles waccanual_percentage wacctrimestral cargos_ixCent_dólar costos_equipos usuarios portabilidad  {

replace `x'="" if `x'=="-"
destring `x' , replace
format `x' %15.0f

}

drop if trimestre==.
drop X Y Z AA AB AC


encode empresa , g(eempresa)
drop empresa
rename eempresa empresa
order empresa, before(trimestre)


***************

tostring trimestre, gen(strimestre)
split strimestre, p(.)

order strimestre1 strimestre2, b(trimestre)

rename strimestre1 año
rename strimestre2 trim
generate qdate1 = año+"q"+ trim

destring año, replace
destring trim, replace

*destring qdate1,replace
*format qdate1 %tq

*generate date=tq(2010q1)+n_1

*format


*---------- Creamos la variable dummy

g du_port=0
replace du_port=1 if trimestre>=2017.3

g du_viettel=0
replace du_viettel=1 if trimestre>=2014.3



*---------- Logaritmos

g ln_ingresos = ln(ingresos_operativos)

g ln_sueldos = ln(suel_sal_moviles_mens)

g ln_costo_equipo = ln(costos_equipos)

g ln_wacc= ln(waccanual_percentage/100)

g ln_cargoix= ln(cargos_ixCent_dólar/100)

g ln_usuarios = ln(usuarios)

* Guardamos la base
save base.dta, replace



*=================
*=================
* REGRESIONES
*=================
*=================

use base.dta, clear


*------------- Regresiones:

global yvar ln_ingresos
global xvar ln_sueldos ln_costo_equipo ln_wacc ln_cargoix


// Paquete para exportar resultado de las regresiones en Latex
*ssc install outreg2

*================
* POOLED
*================


* regresion 1

reg  $yvar $xvar, r
outreg2 using regresiones, tex replace ctitle(Modelo 1) addstat("R2 ajustada", e(r2_a), "F",e(F),"Prob > F",e(p))

* regresion 2

reg  $yvar $xvar ln_usuarios, r
outreg2 using regresiones, tex append ctitle(Modelo 2) addstat("R2 ajustada", e(r2_a), "F",e(F),"Prob > F",e(p))

* regresion 3

reg  $yvar $xvar ln_usuarios du_port, r
outreg2 using regresiones, tex append ctitle(Modelo 3) addstat("R2 ajustada", e(r2_a), "F",e(F),"Prob > F",e(p))

* regresion 4

reg  $yvar $xvar ln_usuarios du_port du_viettel, r
outreg2 using regresiones, tex append ctitle(Modelo 4) addstat("R2 ajustada", e(r2_a), "F",e(F),"Prob > F",e(p))

* regresion 5

reg  $yvar $xvar ln_usuarios du_port du_viettel du2, r
outreg2 using regresiones, tex append ctitle(Modelo 5) addstat("R2 ajustada", e(r2_a), "F",e(F),"Prob > F",e(p))

* regresion 6

reg  $yvar $xvar ln_usuarios du_port du_viettel du2 du3, r
outreg2 using regresiones, tex append ctitle(Modelo 6) addstat("R2 ajustada", e(r2_a), "F",e(F),"Prob > F",e(p))

* regresion 7

reg  $yvar $xvar ln_usuarios du_port du_viettel du2 du3 du4, r
outreg2 using regresiones, tex append ctitle(Modelo 7)  addstat("R2 ajustada", e(r2_a), "F",e(F),"Prob > F",e(p))


*********** Datos panel

* Declaramos como panel nuestra base

gen time = yq(año,trim)
format time %tq

xtset empresa time, quarterly


* Efectos fijos
*-------------------

* regresion 1
xtreg  $yvar $xvar , fe 
outreg2 using regresiones_fe, tex replace ctitle(Modelo 1)  addstat("Whitin", e(r2), "Between", e(r2_b), "Overall", e(r2_o), "F",e(F),"Prob > F",e(p))

* regresion 2
xtreg  $yvar $xvar ln_usuarios, fe
outreg2 using regresiones_fe, tex append ctitle(Modelo 2) addstat("Whitin", e(r2), "Between", e(r2_b), "Overall", e(r2_o), "F",e(F),"Prob > F",e(p))

* regresion 3
xtreg  $yvar $xvar ln_usuarios du_port, fe 
outreg2 using regresiones_fe.doc,tex append ctitle(Modelo 3) addstat("Whitin", e(r2), "Between", e(r2_b), "Overall", e(r2_o), "F",e(F),"Prob > F",e(p))

* regresion 4
xtreg  $yvar $xvar ln_usuarios du_port du_viettel, fe 
outreg2 using regresiones_fe.doc, tex append ctitle(Modelo 4) addstat("Whitin", e(r2), "Between", e(r2_b), "Overall", e(r2_o), "F",e(F),"Prob > F",e(p))

* regresion 5 
xtreg  $yvar $xvar ln_usuarios du_port du_viettel du2 , fe 
outreg2 using regresiones_fe.doc, tex append ctitle(Modelo 5) addstat("Whitin", e(r2), "Between", e(r2_b), "Overall", e(r2_o), "F",e(F),"Prob > F",e(p))

* regresion 6
xtreg  $yvar $xvar ln_usuarios du_port du_viettel du2 du3, fe 
outreg2 using regresiones_fe.doc, tex append ctitle(Modelo 6) addstat("Whitin", e(r2), "Between", e(r2_b), "Overall", e(r2_o), "F",e(F),"Prob > F",e(p))

* regresion 7
xtreg  $yvar $xvar ln_usuarios du_port du_viettel du2 du3 du4, fe 
outreg2 using regresiones_fe.doc, tex append ctitle(Modelo 7) addstat("Whitin", e(r2), "Between", e(r2_b), "Overall", e(r2_o), "F",e(F),"Prob > F",e(p))



* Efectos aleatorios
*--------------------


global yvar lningresos
global xvar lnsueldos lnwacc lncargo_ix lncostos_equipos


* regresion 1
xtreg  $yvar $xvar , re 
outreg2 using regresiones_re, tex replace ctitle(Modelo 1)  addstat("Whitin", e(r2_w), "Between", e(r2_b), "Overall", e(r2_o), "Wald chi2",e(rank),"Prob > chi2",e(p))

* regresion 2
xtreg  $yvar $xvar lnusuarios, re
outreg2 using regresiones_re, tex append ctitle(Modelo 2) addstat("Whitin", e(r2_w), "Between", e(r2_b), "Overall", e(r2_o), "Wald chi2",e(rank),"Prob > chi2",e(p))

* regresion 3
xtreg  $yvar $xvar lnusuarios du_port , re 
outreg2 using regresiones_re ,tex append ctitle(Modelo 3) addstat("Whitin", e(r2_w), "Between", e(r2_b), "Overall", e(r2_o), "Wald chi2",e(rank),"Prob > chi2",e(p))

* regresion 4
xtreg  $yvar $xvar lnusuarios du_port du_viettel, re 
outreg2 using regresiones_re, tex append ctitle(Modelo 4) addstat("Whitin", e(r2_w), "Between", e(r2_b), "Overall", e(r2_o), "Wald chi2",e(rank),"Prob > chi2",e(p))

* regresion 5
xtreg  $yvar $xvar lnusuarios du_port du_viettel du2, re 
outreg2 using regresiones_re, tex append ctitle(Modelo 5) addstat("Whitin", e(r2_w), "Between", e(r2_b), "Overall", e(r2_o), "Wald chi2",e(rank),"Prob > chi2",e(p))

* regresion 6
xtreg  $yvar $xvar lnusuarios du_port du_viettel du2 du3, re  
outreg2 using regresiones_re, tex append ctitle(Modelo 6) addstat("Whitin", e(r2_w), "Between", e(r2_b), "Overall", e(r2_o), "Wald chi2",e(rank),"Prob > chi2",e(p))

* regresion 7
xtreg  $yvar $xvar lnusuarios du_port du_viettel du2 du3 du4, re  
outreg2 using regresiones_re, tex append ctitle(Modelo 7) addstat("Whitin", e(r2_w), "Between", e(r2_b), "Overall", e(r2_o), "Wald chi2",e(rank),"Prob > chi2",e(p))


*-----------------------------

* Test de Hausman
*======================

xtreg  $yvar $xvar lnusuarios du_port du_viettel du2 du3 du4, fe 
estimates store fe
xtreg  $yvar $xvar lnusuarios du_port du_viettel du2 du3 du4, re  
estimates store re

hausman fe re // se rechaza Ho, debemos seleccionar efectos fijos



* Test Breuch - Pagan
*======================
xtreg  $yvar $xvar lnusuarios du_port du_viettel du2 du3 du4, re   
xttest0

* Test Lambda
*===================
* T>N
xtreg  $yvar $xvar lnusuarios du_port du_viettel du2 du3 du4, fe 
xttest2

* Test de pesaran 
*===================
* N>T
xtreg  $yvar $xvar lnusuarios du_port du_viettel du2 du3 du4, fe 
xtcsd, pesaran abs



*****************************************
*****************************************
*****************************************

* TEST DE CHOW (Quiebre estructural)
*======================================

*2010-2014
import excel "C:\Users\jleiva\Downloads\Lineas Portadas 2010-2014.xlsx", sheet("Portabilidad") firstrow clear

keep Mes TotalLíneasPortadas 

drop if _n>60
g tiempo = m(2010m1) + _n-1
format tiempo %tm
keep tiempo TotalLíneasPortadas

rename TotalLíneasPortadas lineas
drop if _n >54
save base2014.dta ,replace
use base2014.dta ,clear


*2014-2022
import excel "C:\Users\jleiva\Downloads\Datasets-PUNKU-OSIPTEL\8. PORTABILIDAD NUMÉRICA\8.1. PORTABILIDAD MÓVIL.xlsx", sheet("Dataset (2)") firstrow clear

keep Mes Líneas
drop if Mes==.

collapse (sum) Líneas, by(Mes)
g tiempo = m(2014m7) + _n-1
format tiempo %tm
replace tiempo= m(2014m8) + _n-1 if tiempo>722

keep Líneas tiempo
rename Líneas lineas
save base2021.dta ,replace

use base2021.dta ,clear

** APPEND
use base2014.dta ,clear
append using base2021.dta

save data_portabilidad.dta , replace

use data_portabilidad.dta ,clear
gen n=_n

reg lineas tiempo
estat sbsingle
*------------------------------




** Calculando el H de panzar a lo largo del tiempo con el modelo de efectos fijos debido a que fue el modelo ganador
*===================================================================================================================

/*
<= 0 -> Monopolio
< 1  -> Competencia monopolistica
= 1 -> Compe perfecta
*/


foreach x in 10 11 12 13 14 15 16 17 18 19 20 21 {
	
	foreach y in 1 2 3 4 {
	
	use base.dta, clear

	xtset empresa time, quarterly

	gen du_`x'_`y' = 0 if año!=.
	replace du_`x'_`y'=1 if año==20`x' & trim==`y'
	
	di "============================="
  
	di "AÑO 20`x' **----------------"
	
	di "Trimestre `y' *-**********"
	
	di "============================="
	
	xtreg  $yvar $xvar lnusuarios du_port du_viettel du2 du3 du4 du_`x'_`y'##(c.ln_sueldos c.ln_costo_equipo c.ln_wacc c.ln_cargoix), fe
	
	mat a_`x'_`y' = e(b)
	mat coef_`x'_`y'= a_`x'_`y'[1, 1..4]
	
}
}


*** Extraemos los resultados del H de Panzar para cada periodo y exportarlo a un excel
*--------------------------------------------------------------------------------------

mat result = coef_10_1
mat li result 

foreach x in 10 11 12 13 14 15 16 17 18 19 20 21 {
	
	foreach y in 1 2 3 4 {
	
	mat result = result \ coef_`x'_`y'

}
}



************************* FIN :D



