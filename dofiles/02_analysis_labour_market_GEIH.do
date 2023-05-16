********************************************************************************
*******    Analysis GEIH - Migrant labour data GEIH-DANE  step 2   *************
/*******************************************************************************
																			   
 TITLE: 				Migrant labour data GEIH-DANE analysis
  PROJECT: 				PEPFF							   
 AUTHOR:				Jorge Gómez  (jgomez@poverty-action.org)	  	   
 LAST MODIFIED BY:		Jorge Gómez  (jgomez@poverty-action.org)			
 Version:   Stata 17

 DESCRIPTION: Having created a single dtabase now proceed with the analysis
  
 *******************************************************************************
* PART 0: Set up
*******************************************************************************/

	cls
	clear all
	set more off 
	set scheme ipaplots
    *---------------------------------------
	* 0.1 Setting path files
	*---------------------------------------
			
		/*Jorge Gomez*/
		if "`c(username)'" == "jorge_j24fcle" {
		global master 			"C:\Users\jorge_j24fcle\OneDrive\Documentos\STATA\GEIH"
		}
		
		
		/*Global paths*/
		global input "${master}\raw"
		global output "${master}\outputs"
		global dofiles "${master}\dofiles"
	*---------------------------------------
	* 0.2 Locals for dates
	*---------------------------------------
	
		local date : di %tdCY_N_D date("$S_DATE", "DMY") 
		display "`date'"

		local yesterday : display %tdCY_N_D date("`c(current_date)'", "DMY") - 1
		display "`yesterday'"
		
		local beforeyesterday : display %tdCY_N_D date("`c(current_date)'", "DMY") - 2
		display "`beforeyesterday'"
		
**************************************************************************************
* PART 1: Defining important variables
**************************************************************************************

		use "${output}\GEIH2022.dta", clear

	*algunos renames para ubicarme, no es necesario.
	rename (p3271	p6040	p6090	p6100	p6240	p6250	p6260	p6260s1	p6260s2	p6270	p6280	p3362s1	p3362s2	p3362s3	p3362s4	p3362s5	p3362s6	p3362s7	p3362s8	p6300	p6310	p6320	p6330	p6340	p6350	p6351	p6440	p6450	p6460	p6460s1	p6422	p6424s1	p6424s2	p6424s3	p6424s5	p6426	p6430	p3363	p9440	p6510	p6640	p3047	p6765	p6780	p1879	p1805	p6790	p6810	p6850	p6830	p3069	p6915	p6920	p6930	p6940	p6960	p6990	p9450	p7020	p760	p7028	p1880	p7040	p7090	p7100	p7110	p7120	p7130	p7140s1	p7140s2	p7140s3	p7140s4	p7140s5	p7140s6	p7140s7	p7140s8	p7140s9	p7150	p7160	p7170s1	p7170s5	p7170s6	p514	p515	p7240	p7250	p7280	p744	p3074	p7260	p1806	p9460	p1519) (sexo	edad	salud	cual_salud	actividad_mes	actividad_paga	ingreso_no_actividad	razon_no_trabajo	tiempo_ausente	no_remunerado	dileginecia_trabajo	ayuda_familiar	hojas_de_vida	bolsa_empleo	clasificados	convocatorias	prep_negocio	oto_diligencia	nsnr_diligencia	desea_trabajo	desea_no_diligencia	trabajo_2w_12m	diligencia_ultimo_trabajo	diligencia_12m	meses_sin_buscar	disponible	contrato	verbal_escrito	termino_contrrato	meses_contrato	conforme_contrato	vacaciones_pagas	prima_xmas	cesantias	licencia_enfermedad	tiempo_trabajando	tipo_trabajo	consiguio_trabajo_medio	pag_internet	horas_extra	hizo_horas_extra	quien_horario	formas_trabajo	estacional_trabajo	razon_indep	cambio_a_asalariado	meses_trabajo_12m	razon_menos_40h	cuantas_horas_semana	razon_menos_h_semana	num_empleados	cubrir_medicamentos	cotiza_pension	fondo_pension	pago_fondo	yr_cotizando	arl	caja_comp	tuvo_trabajo	frict_trabajo	tipo_trabajo_anterior	razon_dejar_trabajo	otro_trabajo	desea_extra	cuantas_extra	diligencia_extra	disponible_extra	cambio_trabajo	utilizar_capacidades	mejor_ingreso	trabajar_menos	trabajo_temporal	problemas	no_gusta	mucho_esfuerzo	ambientales	otro_dejar_trabajo	diligecia_cambio_trabajo	empezar_antes_1m	satisfecho_trabajo_act	satisfecho_prestaciones	satisfecho_jornada_act	trabajo_estable	familia_trabajo	recursos_no_trabaja	semana_buscando_trabajo	tipo_buscado	disponible_semana	cuando_disponible	disponible_horas	salario_minimo	recibe_subsidio_desem	pension_desoc)
		
		
		*Generamos algunos indicadores de mercado laboral
		*Poblacion en edad de trabajar, será la gente a la que se le hicieron la spreguntas del modulo de fuerza de trabajo
		gen PET=fuerza_trabajo==3
		
		*La pregunta de si buscó trabajo se le hace a los desocupaso así que si la respondieron aplican a desempleo
		gen desocupados=p7280!=.
		
		*El modulo de ocupados solo es solo para los que trabajan por ende si están incluidos son ocupados
		recode ocupados (1=0) (3=1) 
		
		*Los economicamente activos son ocupados + desocupados
		gen PEA=desocupados==1 | ocupados==1
		
		*Se  genera missing pues sino esta en edad de trqabajar no podrá por definición ser economicamente activo
		replace PEA=. if PET==0
		
		*tasa de desempleo se calcula sobre los economicamente activos
		replace desocupados=. if PEA!=1 
		
		* los ocupados se calculan sobre edad de trabajar
		replace ocupados=. if PEA!=1 
		
		*gente sin trabajo que no está buscando son inactivos
		gen inactivos=no_ocupados==3 & desocupados!=1
		
		*generamos variable de venezolano para el análisis de mercado laboral de migrantes
		gen venezolano=(p3373S3==862) //862 es el codigo pais de venezuela
		replace venezolano=. if p3373S3!=862 & p3373==3 // sacamos a los de doble nacinalidad
		
		gen FEX_FINAL=fex_c18/12 // los factores de expansion vienen mensuales por lo que al dividirlos entre 12 nos dará los factores anuales.
		
		
		
***change definition of occcupied=0 as it is calculated over PET not PEA

		replace ocupados=0 if ocupados==. & PET==1

***change values of health affiliation (salud)
		replace salud=0 if salud==2
		replace salud=. if salud==9


**** No double citizenship
replace venezolano=0 if nacionalidad==1




/*
	***************************************************************************
	****************Definicion informal ocupado Glosario GEIH******************
	***************************************************************************

	1. Los empleados particulares y los obreros que laboran en establecimientos, 
	negocios o empresas que ocupen hasta cinco personas en todas sus agencias y 
	sucursales, incluyendo al patrono y/o socio

	2. Los trabajadores familiares sin remuneración en empresas de cinco 
	trabajadores o menos

	3. Los trabajadores sin remuneración en empresas o negocios de otros hogares
 
	4. Los empleados domésticos en empresas de cinco trabajadores o menos

	5. Los jornaleros o peones en empresas de cinco trabajadores o menos
 
	6. Los trabajadores por cuenta propia que laboran en establecimientos hasta 
	cinco personas, excepto los independientes profesionales

	7. Los patrones o empleadores en empresas de cinco trabajadores o menos
 
	8. Se excluyen los obreros o empleados del gobierno.

*/

	*according to the definition two variables define informality

	*tipo de trabajo:define labels for answers

		label define tipo_trabajo ///
		1 "Obrero o empleado de empresa particular" 2 "Obrero o empleado del gobierno" ///
		3 "Empleado doméstico" 4 "cuenta propia" 5 "Patron o empleador" /// 
		6 "trabajador familiar sin remuneracion" /// 
		7 "Trabajador sin remuneración en empresas o negocios de otros hogares" ///
		8 "Jornalero o peon" 9 "otro"
		label values tipo_trabajo "tipo_trabajo"


	*numero de empleados establecimiento: define labels for answers

		label define num_empleados 1 "trabaja solo" 2 "2 a 3 personas" 3 "4 a 5 personas" ///
		4 "6 a 10 personas" 5 "11 a 19 personas" 6 "20 a 30 personas" 7 "31 a 50 personas" ///
		8 "51 a 100 personas" 9 "101 a 200 personas" 10 "201 o mas"
		label values num_empleados "num_empleados"


	*definiendo la variable
	
		gen informal_3=0
		replace informal_3=. if ocupados==.
		replace informal_3=1 if ((tipo_trabajo==1 | tipo_trabajo==6| tipo_trabajo==3| tipo_trabajo==8| tipo_trabajo==4|tipo_trabajo==5) & num_empleados<=3 ) | 		  tipo_trabajo==7 
		replace informal_3=0 if tipo_trabajo==4 & P3042>=10
		replace informal_3=. if ocupados!=1

	*dummy migrante reciente

		gen migrante_reciente= P3373S3A1>= 2020

	*variables de subempleo
	
		replace desea_extra=0 if desea_extra==2
		replace utilizar_capacidades=0 if utilizar_capacidades==2
		replace mejor_ingreso=0 if mejor_ingreso==2
		
	*subempleo general
	
		
		gen subempleo=(desea_extra==1 & P6800<48 & diligencia_extra==1 & disponible_extra==1) | (cambio_trabajo==1 & diligecia_cambio_trabajo==1 & 					empezar_antes_1m==1 )  
		replace subempleo=. if PEA!=1
		tab subempleo [iw=FEX_FINAL]
		
		
	*subempleo horas objetivo

		gen sub_empleo_h= desea_extra==1  & diligencia_extra==1 & disponible_extra==1 & P6800<48
		replace sub_empleo_h=. if PEA!=1 

	*subempleo ingresos
	
		gen sub_empleo_i= mejor_ingreso==1 & diligecia_cambio_trabajo==1 & empezar_antes_1m==1 
		replace sub_empleo_i=. if PEA!=1 
	
	*subempleo capacidades	
		gen sub_empleo_c= utilizar_capacidades==1 & diligecia_cambio_trabajo==1 & empezar_antes_1m==1
		replace sub_empleo_c=. if PEA!=1 
	

********************************************************************************
* PART 2: ttesting the labour market variables Col vs Ven
********************************************************************************



*Select labour market variables that are relevant for comparisons between migrants and colombian nationals

		global Y PEA ocupados desocupados salud informal_3 subempleo sub_empleo_h sub_empleo_i sub_empleo_c


quietly {
	
local i=1

putexcel set "${output}\ttests\ttest2.xlsx", sheet("Sheet1") replace

	putexcel A1="Variables" , bold border(bottom)
	putexcel B1= "N Col", bold border(bottom)
	putexcel C1="Mean Col" , bold border(bottom)
	putexcel D1="N Ven", bold border(bottom)
	putexcel E1="Mean Ven" , bold border(bottom)           
	putexcel F1="Diff" , bold border(bottom)
	putexcel G1="p-value", bold border(bottom)
	putexcel H1="Sig", bold border(bottom)
	
	foreach x of varlist $Y {
		local ++i
		putexcel A`i'="`x'"
		sum `x' if venezolano==0 [iw=FEX_FINAL]	
		putexcel B`i'=`r(sum_w)' 
		putexcel C`i'=`r(mean)'
		sum `x' if venezolano==1 [iw=FEX_FINAL]
		putexcel D`i'=`r(sum_w)'
		putexcel E`i'=`r(mean)'
		reg `x' venezolano	[iw=FEX_FINAL] 
		local diff=e(b)[1,1]
		putexcel F`i'= `diff'
		local pv=r(table)[4,1]
		putexcel G`i'=`pv', nformat(number_d2)
		
		if `pv'>=0.1 {
			local sig 
					}
		if `pv'<0.1 & `pv'>=0.05 {
			local sig *
					}
		if `pv'<0.05 & `pv'>=0.01 {
			local sig **
					}
		if `pv'<=0.01 & `pv'>=0 {
			local sig ***
					}
		else		{
			local sig error
					}
		putexcel H`i'="`sig'"
		}

}


********************************************************************************
* PART 3: other analysis
********************************************************************************
	
	
	***Actividad del ultimo mes

		gen actividad_comp= actividad_mes
		recode actividad_comp (3 4 5 6 =3)
		*replace actividad_comp=1 if actividad_mes==1
		*replace actividad_comp=2 if actividad_mes==2
		*replace actividad_comp=3 if actividad_mes>=3
		label define actividad_comp 1 "trabajando" 2 "buscando trabajo" ///
		3 "No tiene trabajo y no esta buscando"
		label var actividad_comp ///
		"¿En que actividad ocupó la mayor parte del tiempo la semana pasada?"
		label values actividad_comp "actividad_comp"
		tab actividad_comp if venezolano==1 [iw=FEX_FINAL]
		tab actividad_comp if venezolano==1 & edad>=18 [iw=FEX_FINAL]




	***Ocupaciones

		gen oficio_gen= substr(oficio_c8, 1, 1)
		destring oficio_gen, replace
		label define oficios 0 "Fuerzas militares" 1 "Directores y gerentes" ///
		2 "Profesionales, científicos e intelectuales" ///
		3 "Técnicos y profesionales del nivel medio" ///
		4 "Personal de apoyo administrativo" ///
		5 "Trabajadores de los servicios y vendedores de comercios y mercados" ///
		6 "Agricultores y trabajadores calificados agropecuarios, forestales y pesqueros" ///
		7 "Oficiales, operarios, artesanos y oficios relacionados" ///
		8 "Operadores de instalaciones y máquinas y ensambladores" ///
		9 "Ocupaciones elementales"


		label values oficio_gen "oficios"
		tab oficio_gen [iw=FEX_FINAL]   if venezolano==1
		/*
		
		                     oficio_gen |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                      Fuerzas militares | 127.891798        0.01        0.01
                  Directores y gerentes | 30,018.686        3.13        3.15
Profesionales, científicos e intelectua | 28,640.269        2.99        6.14
Técnicos y profesionales del nivel medi | 30,788.322        3.22        9.35
       Personal de apoyo administrativo |22,865.0389        2.39       11.74
Trabajadores de los servicios y vendedo | 306,863.48       32.04       43.79
Agricultores y trabajadores calificados | 17,990.281        1.88       45.67
Oficiales, operarios, artesanos y ofici | 147,030.26       15.35       61.02
Operadores de instalaciones y máquinas  | 56,276.271        5.88       66.90
                Ocupaciones elementales | 317,008.79       33.10      100.00
----------------------------------------+-----------------------------------
                                  Total |  957,609.3      100.00

		
		
		
		
		
		*/
		tab oficio_gen [iw=FEX_FINAL]   if venezolano==1 & sexo==1
		/*
		
		
.                 tab oficio_gen [iw=FEX_FINAL]   if venezolano==1 & sexo==1

                             oficio_gen |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                      Fuerzas militares | 127.891798        0.02        0.02
                  Directores y gerentes |   18,848.1        3.28        3.30
Profesionales, científicos e intelectua | 17,345.367        3.02        6.32
Técnicos y profesionales del nivel medi | 20,439.772        3.56        9.88
       Personal de apoyo administrativo | 13,582.683        2.36       12.24
Trabajadores de los servicios y vendedo | 113,477.36       19.74       31.98
Agricultores y trabajadores calificados | 15,132.427        2.63       34.62
Oficiales, operarios, artesanos y ofici |126,789.555       22.06       56.68
Operadores de instalaciones y máquinas  |   47,546.9        8.27       64.95
                Ocupaciones elementales | 201,446.11       35.05      100.00
----------------------------------------+-----------------------------------
                                  Total | 574,736.17      100.00

		
		
		
		
		
		*/
		
		tab oficio_gen [iw=FEX_FINAL]   if venezolano==1 & sexo==2
		/*
		
	   tab oficio_gen [iw=FEX_FINAL]   if venezolano==1 & sexo==2

                             oficio_gen |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                  Directores y gerentes | 11,170.586        2.92        2.92
Profesionales, científicos e intelectua | 11,294.902        2.95        5.87
Técnicos y profesionales del nivel medi |  10,348.55        2.70        8.57
       Personal de apoyo administrativo |9,282.35587        2.42       10.99
Trabajadores de los servicios y vendedo | 193,386.12       50.51       61.50
Agricultores y trabajadores calificados |2,857.85412        0.75       62.25
Oficiales, operarios, artesanos y ofici | 20,240.707        5.29       67.54
Operadores de instalaciones y máquinas  | 8,729.3708        2.28       69.82
                Ocupaciones elementales | 115,562.68       30.18      100.00
----------------------------------------+-----------------------------------
                                  Total | 382,873.13      100.00
	
		
		
		
		
		
		*/
		
		tab oficio_gen [iw=FEX_FINAL]  if venezolano==0
		/*
		
		                     oficio_gen |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                      Fuerzas militares | 30,004.746        0.14        0.14
                  Directores y gerentes |  1,387,685        6.60        6.75
Profesionales, científicos e intelectua |2,396,497.2       11.40       18.15
Técnicos y profesionales del nivel medi |  1,417,807        6.75       24.89
       Personal de apoyo administrativo |  1,219,012        5.80       30.69
Trabajadores de los servicios y vendedo |  4,340,920       20.65       51.35
Agricultores y trabajadores calificados |  1,412,623        6.72       58.07
Oficiales, operarios, artesanos y ofici |  2,221,900       10.57       68.64
Operadores de instalaciones y máquinas  |  1,763,411        8.39       77.03
                Ocupaciones elementales |  4,826,749       22.97      100.00
----------------------------------------+-----------------------------------
                                  Total | 21016610.4      100.00

		
		
		
		
		
		*/
		
		tab oficio_gen [iw=FEX_FINAL]  if venezolano==0 & sexo==1
		/*
		
		   


                             oficio_gen |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                      Fuerzas militares | 25,499.248        0.21        0.21
                  Directores y gerentes |780,202.852        6.28        6.49
Profesionales, científicos e intelectua |  1,167,257        9.40       15.88
Técnicos y profesionales del nivel medi |  757,512.1        6.10       21.98
       Personal de apoyo administrativo | 496,382.39        4.00       25.97
Trabajadores de los servicios y vendedo |  1,770,311       14.25       40.23
Agricultores y trabajadores calificados |  1,178,338        9.49       49.71
Oficiales, operarios, artesanos y ofici |  1,711,159       13.77       63.48
Operadores de instalaciones y máquinas  |  1,538,793       12.39       75.87
                Ocupaciones elementales |  2,997,537       24.13      100.00
----------------------------------------+-----------------------------------
                                  Total | 12422991.6      100.00

		
		
		
		
		
		*/
		
		tab oficio_gen [iw=FEX_FINAL]  if venezolano==0 & sexo==2
		/*
		
                           oficio_gen |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                      Fuerzas militares |4,505.49835        0.05        0.05
                  Directores y gerentes | 607,482.51        7.07        7.12
Profesionales, científicos e intelectua |  1,229,240       14.30       21.43
Técnicos y profesionales del nivel medi | 660,295.19        7.68       29.11
       Personal de apoyo administrativo | 722,629.58        8.41       37.52
Trabajadores de los servicios y vendedo |  2,570,609       29.91       67.43
Agricultores y trabajadores calificados | 234,285.05        2.73       70.16
Oficiales, operarios, artesanos y ofici | 510,741.29        5.94       76.10
Operadores de instalaciones y máquinas  | 224,617.68        2.61       78.71
                Ocupaciones elementales |  1,829,213       21.29      100.00
----------------------------------------+-----------------------------------
                                  Total |  8,593,619      100.00
		
		
		
		
		
		
		*/
		
		
	***Razones para dejar trabajo anterior
	
		*create analogy to pilot categories
 
		recode razon_dejar_trabajo (4 6 7 11 12 13=8) (5=4) (8=5) (9=6) (10=7), gen(dejar_trabajo_pilot)

		label define razones_dejar 1 "Terminó contrato" ///
		2 "Por quiebra o cierre de la empresa" ///
		3 "condiciones laborales insatisfactorias" 4  "Lo despidieron" ///
		5 "Deseaba un empleo con mejores condiciones" 6 "Razones personales" ///
		7 "Renunció para empezar negocio propio" 8 "Otro"
		label values dejar_trabajo_pilot "razones_dejar"
		replace dejar_trabajo_pilot=. if tuvo_trabajo!=1
		tab dejar_trabajo_pilot [iw=FEX_FINAL]

		tab2xl dejar_trabajo_pilot if venezolano==1 [iw=FEX_FINAL] ///
		using "${output}\razon_ven.xlsx", row(1) col(1)
		tab2xl dejar_trabajo_pilot if venezolano==0 [iw=FEX_FINAL] ///
		using "${output}\razon_col.xlsx", row(1) col(1)


	***distribucion entry migrants

		replace migrante_reciente =. if venezolano !=1

		gen entry_year=.
		replace entry_year=1 if P3373S3A1<2000
		replace entry_year=2 if P3373S3A1 <=2010 & P3373S3A1>=2000
		
		
		forvalues x=3/14{
	
			local yr=2008+`x'
			replace entry_year=`x' if P3373S3A1==`yr'	
	
	
		}

		label define entry 1 "antes de 2000" 2 "2000-2010" 3 "2011" 4 "2012" 5 "2013" 6 "2014" 7 "2015" 8 "2016" 9 "2017" 10 "2018" 11 "2019" 12 "2020" 13 "2021" 14 "2022"
		label values entry_year "entry"
		replace entry_year=. if venezolano!=1
		
		tab entry_year if venezolano==1 [iweight=FEX_FINAL]

	*****Variables de mercado laboral en entry year*********
		
		***desempleo
		sort entry_year
		by entry_year: tab desocupados if venezolano==1 [iw=FEX_FINAL]
		tabstat desocupados , sta(sum) by(entry_year )
		***participacion
		by entry_year: tab PEA if venezolano==1 [iw=FEX_FINAL]
		tabstat PEA, sta(sum) by(entry_year )
		***informalidad
		by entry_year: tab informal_3 if venezolano==1 [iw=FEX_FINAL]
		tabstat informal_3 , sta(sum) by(entry_year )
		***ocupacion
		by entry_year: tab ocupados if venezolano==1 [iw=FEX_FINAL]
		tabstat ocupados, sta(sum) by(entry_year )
		
		
		
		
	******Análisis género
		
		tab sexo if venezolano==1 [iw=FEX_FINAL]
		tab sexo if venezolano==1 & edad>=18 [iw=FEX_FINAL]
		tab sexo if venezolano ==1 & edad>=18 & PEA==1 [iw=FEX_FINAL]
		tab sexo if venezolano ==1 & edad>=18 & ocupados==1 [iw=FEX_FINAL]
		
		global Y PEA ocupados desocupados salud informal_3 subempleo sub_empleo_h sub_empleo_i sub_empleo_c

		
		
		

		quietly {
	
local i=1

putexcel set "${output}\ttests\ttest_gen.xlsx", sheet("Sheet1") replace

	putexcel A1="Variables" , bold border(bottom)
	*Hombres migrantes
	putexcel B1= "N mig_h", bold border(bottom)
	putexcel C1="Mean mig_h" , bold border(bottom)
	*mujeres migrantes
	putexcel D1="N mig_m", bold border(bottom)
	putexcel E1="Mean mig_m" , bold border(bottom)           
	*mujeres migrantes>18
	putexcel F1="N mig_m_18", bold border(bottom)
	putexcel G1="Mean mig_m_18" , bold border(bottom)
    *mujeres migrantes activas >18
	putexcel H1="N mig_m_18_A", bold border(bottom)
	putexcel I1="Mean mig_m_18_A" , bold border(bottom)
	*mujeres colombianas
	putexcel J1="N Col_m_18", bold border(bottom)
	putexcel K1="Mean Col_m_18" , bold border(bottom)
	*hombres colombianos
	putexcel L1= "N col_h", bold border(bottom)
	putexcel M1="Mean col_h" , bold border(bottom)
	
	
	foreach x of varlist $Y {
		local ++i
		putexcel A`i'="`x'"
		
		*Hombres migrantes
		sum `x' if venezolano==1 & sexo==1 [iw=FEX_FINAL]	
		putexcel B`i'=`r(sum_w)' 
		putexcel C`i'=`r(mean)'
		
		*mujeres migrantes Total
		sum `x' if venezolano==1 & sexo==2 [iw=FEX_FINAL]
		putexcel D`i'=`r(sum_w)'
		putexcel E`i'=`r(mean)'
		
		*mujeres migrantes >18 años
		sum `x' if venezolano==1 & sexo==2 & edad>=18 [iw=FEX_FINAL]
		putexcel F`i'=`r(sum_w)'
		putexcel G`i'=`r(mean)'
		
		
		*mujeres migrantes >18 años y activas
		sum `x' if venezolano==1 & sexo==2 & edad>=18 & PEA==1 [iw=FEX_FINAL]
		putexcel H`i'=`r(sum_w)'
		putexcel I`i'=`r(mean)'
		
		*mujeres colombianas
			sum `x' if venezolano==0 & sexo==2 [iw=FEX_FINAL]
		putexcel J`i'=`r(sum_w)'
		putexcel K`i'=`r(mean)'
			
		*Hombres colombianos
		sum `x' if venezolano==0 & sexo==1 [iw=FEX_FINAL]
		putexcel L`i'=`r(sum_w)'
		putexcel M`i'=`r(mean)'
		
		
		}

}


*Niveles educativos
		recode P3042 (3=4) (8=9) (11 12=13) (99=.) , gen(educ_a)
		label define niveles_educ 1 "Ninguno" ///
		2 "Preescolar" ///
		4 "Basica" ///
		5 "Media academica" 6 "Media técnica" ///
		7 "Normalista"  ///
		9 "Técnica/Teconologica" 10 "Universitaria" ///
		13 "Postgrado"  
		label values educ_a "niveles_educ"
		
	tab2xl educ_a if venezolano==0 & sexo==1 [iw=FEX_FINAL] ///
	using "${output}\educ_col_h.xlsx", row(1) col(1)
	
	tab2xl educ_a if venezolano==0 & sexo==2 [iw=FEX_FINAL] ///
	using "${output}\educ_col_m.xlsx", row(1) col(1)
	
	tab2xl educ_a if venezolano==1 & sexo==1 [iw=FEX_FINAL] ///
	using "${output}\educ_ven_h.xlsx", row(1) col(1)
	
	tab2xl educ_a if venezolano==1 & sexo==2 [iw=FEX_FINAL] ///
	using "${output}\educ_ven_m.xlsx", row(1) col(1)
		
	
	*Solo para los activos laboralmente
	
	* col h
	tab educ_a if venezolano==0 & sexo==1 & PEA==1 [iw=FEX_FINAL] 
	
	*col m
	tab educ_a if venezolano==0 & sexo==2 & PEA==1 [iw=FEX_FINAL] 
	
	*ven h
	tab educ_a if venezolano==1 & sexo==1 & PEA==1 [iw=FEX_FINAL] 
	
	*ven m
	tab educ_a if venezolano==1 & sexo==2 & PEA==1 [iw=FEX_FINAL] 
	
	
	*Analysis for househod financial products
	
	**Create variable that indicates if theres i a venezuelan in the household
	
	egen household_ven = max(venezolano), by(DIRECTORIO SECUENCIA_P)
	
	*now analyze each variable for finacial product, people may have more than 1
	
	mat res=J(10, 2, .)
		mat rownames res = "CC" "CA" "CDT" "prest_v" "prest_ve" "prest_li" "TC" "Otro" "Ninguno" "NS/NR"
		mat colnames res= "Ven" "Col"
	local i=0
	forvalues x=1(1)10 {
		
		*create household level variable
		bys DIRECTORIO SECUENCIA_P: egen product_`x'=min(P5222S`x')
		
		local i=`i' + 1
		preserve 
		
		collapse (mean) product_`x' household_ven FEX_FINAL, by(DIRECTORIO SECUENCIA_P)
		
		qui fre product_`x' if household_ven==1 [iw=FEX_FINAL]
		mat res[`i',1]=r(valid)[1,1]
		qui fre product_`x' if household_ven==0 [iw=FEX_FINAL]
		mat res[`i',2]=r(valid)[1,1]
				
		restore
		
		
		
		
		
	}
	
	matlist res
	forvalues i = 1/10 {
    matrix res[`i',1] = res[`i',1] / 797232.95 
	matrix res[`i',1] = res[`i',1] * 100
    matrix res[`i',2] = res[`i',2] / 16159026.7
	matrix res[`i',2] = res[`i',2] * 100
}
	

	matlist res
	
	/*
	putexcel set "${output}\ttests\i_fin.xlsx", sheet("Sheet1") replace
	putexcel B1="Venezolanos"
	putexcel C1="Colombianos"
	local z=1
	local products CC CA CDT prest_v prest_ve prest_li TC Otro Ninguno NS/NR
	
	foreach x of local products{
	local z=`z'+1
	putexcel A`z'="`x'"	
		
	}
	
	local z=1
	

forvalues i = 1/10 {
	local z=`z'+1
	putexcel B`z'= (res[`i', 1])
	putexcel C`z'= (res[`i', 2])
}
*/