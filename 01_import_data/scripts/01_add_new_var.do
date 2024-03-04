********************************************************************************
*******    Analysis GEIH - Migrant labour data GEIH-DANE  variable management **
/*******************************************************************************
																			   
 TITLE: 				Migrant labour data GEIH-DANE Database management
 PROJECT: 											   
 AUTHOR:				Jorge Gómez  (jgomez@poverty-action.org)	  	   
 LAST MODIFIED BY:		Jorge Gómez  (jgomez@poverty-action.org)			
 Version:   Stata 17

 DESCRIPTION: This do adds a new variable from the GEIH to your
              analysis database without opening the computationally taxing 
			  whole data.
 *******************************************************************************
* PART 0: Set up
*******************************************************************************/

	cls
	clear all
	set more off 
	
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
		

*************************************************************
**        Part 1: set up of directories               **
*************************************************************
/* Cada mes contiene 9 archivos con los modulos de la encuesta,
   estos corresponden con los que se encuentran en el diccionario de datos
   
   1. Características generales, seguridad social en salud y educación
   2. Datos del hogar y la vivienda
   3. Fuerza de trabajo
   4. Migración
   5. No ocupados
   6. Ocupados
   7. Otras formas de trabajo
   8. Otros ingresos e impuestos
   9. Tipo de investigación

   */
   
   ***Seleccionar los modulos relevantes donde estén las variables que queremos
   
   global myglobals caracteristicas hogar fuerza_trabajo migracion no_ocupados ocupados otros_trabajos otros_ingresos tipo


   gl caracteristicas    1
   gl hogar              0
   gl fuerza_trabajo     1
   gl migracion          1
   gl no_ocupados        1
   gl ocupados           1
   gl otros_trabajos     0
   gl otros_ingresos     0
   gl tipo               0
   
   ***Seleccionar las variabes para cada modulo   
	gl var_caracteristicas p3271 p6040 p2057 p2059 p2061 p6080 p6070 p6090 p6100 p6160 p6170 p3042 p3043 fex_c18 MES
	gl var_hogar p4000 p70 p5020 p5030 p5040 p5090
	gl var_fuerza_trabajo p6240 p6240s2 p6250 p6260 p6260s1 p6260s2 p6270 p6280 p3362s1 p3362s2 p3362s3 p3362s4 p3362s5 p3362s6 p3362s7 p3362s8 p6300 p6310 	p6320 p6330 p6340 p6351
	gl var_migracion p3373 p3373s1 p3373s2 p3373s3 p3373s3a1 p3373s3a2 p3374 p3374s1 p3374s2 p3374s3 p3375 p3382 p3386
	gl var_no_ocupados p7250 p7280 p744 p3074 p7260 p1806 p7440s1 p7440s2 p7450 p7350 p7360 p9460 p1519 p7422
	gl var_ocupados  p6440 p6450 p6460 p6400 p6410 p6422 p6424s1 p6424s2 p6424s3 p6424s5 p6430 p3045s1 p3045s2 p3045s3 p3046 p3363 p9440 p6510 p6640 p1800 p1802 p3047 p6765 p3052s1 p3069 p6880 p6915 p6920 p6930 p6940 p6990 p9450 p7020 p760 p7026 p1880 p7090 p7110 p7120 p7130 p7140s1 p7140s2 p7140s3 p7140s4 p7140s5 p7140s6 p7140s7 p7140s8 p7140s9 p7150 p7160 p7170s1 p7170s5 p7170s6 p7180 p514 p515 p7240 oficio_c8 rama2d_r4 rama4d_r4
	gl var_otros_trabajos 
	gl var_otros_ingresos 
	gl var_tipo

    ***El archvio que contiene cada modulo
   gl dir_caracteristicas "Características generales, seguridad social en salud y educación"
   gl dir_hogar "Datos del hogar y la vivienda"
   gl dir_fuerza_trabajo "Fuerza de trabajo"
   gl dir_migracion "Migración"
   gl dir_no_ocupados "No ocupados" 
   gl dir_ocupados "Ocupados"
   gl dir_otros_trabajos "Otras formas de trabajo"
   gl dir_otros_ingresos "Otros ingresos e impuestos"
   gl dir_tipo "Tipo de investigación"
   
   
   gl firs_time 0
*************************************************************
**        Part 2: adding the variable                      **
*************************************************************

*global with the months
	global meses enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre

if $firs_time ==0 {
	
	*create datbase of unique identifiers
 	
	
	*loops to extract the variable with the ID variables from the monthly data 

	local i=0
	foreach x of global meses{
	
		import delimited using "${input}\mes_`x'\Características generales, seguridad social en salud y educación.csv", clear
		local ++i
		*keep the identifier variables:
		keep directorio secuencia_p orden
		
		tempfile base_`i'
		save `base_`i''
		 
	
	}

	*append all months
	
	use `base_1', clear
	
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
	
		save "${output}\GEIH2022.dta", replace
	
	gl firs_time=1
	*N=919459	
	
}
 
	
	******* TRACK ALL VARIABLE ADDITIONS ******
	*added variables since last save: 
qui{
	foreach x of global myglobals{
	         
			 if $`x' ==1{
			 	local w=0
			 	*contador de mes
				local i=0
				foreach z of global meses{
						local variables ${var_`x'}
						local dir_name ${dir_`x'}
						import delimited using "${input}\mes_`z'/`dir_name'.csv", clear
						
						local ++i
						if `w'==0 {
							gen MES_J=`i'
						}
						*keep the identifier variables:
						keep directorio secuencia_p orden `variables'
						
						tempfile base_`i'
						save `base_`i''
						
					}

				*append all months
	
				use `base_1', clear
	
				forvalues n=2/12{
					append using `base_`n''
		
							}
			
			merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta", gen(`x')
			
			save "${output}\GEIH2022.dta", replace
			export delimited using  "${output}\GEIH2022.csv", replace 
			local ++w
	}	
							
	
			 }
		
}
	
	
