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
   
   gl caracteristicas    1
   gl hogar              1
   gl fuerza_trabajo     1
   gl migracion          1
   gl no_ocupados        1
   gl ocupados           1
   gl otros_trabajos     0
   gl otros_ingresos     0
   gl tipo               0
   
   ***Seleccionar las variabes para cada modulo   
   gl var_caracteristicas ""
   gl var_hogar ""
   gl var_fuerza_trabajo ""
   gl var_migracion ""
   gl var_no_ocupados ""
   gl var_ocupados ""
   gl var_otros_trabajos ""
   gl var_otros_ingresos ""
   gl var_tipo    ""

   gl firs_time 1
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
	local i=0
	if $caracteristicas == 1{
		local i=0
		foreach x of global meses{
	
		
			import delimited using "${input}\mes_`x'\Características generales, seguridad social en salud y educación.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p orden $var_caracteristicas
		
			tempfile base_`i'
			save `base_`i''
		 
	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}
	
	if $hogar == 1{ 
		local i=0
		foreach x of global meses{
	
		
			import delimited using "${input}\mes_`x'\Datos del hogar y la vivienda.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p $var_hogar
		
			tempfile base_`i'
			save `base_`i''
		 
	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}

	if $fuerza_trabajo == 1{ 
		local i=0
		foreach x of global meses{
			
			import delimited using "${input}\mes_`x'\Fuerza de trabajo.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p orden $var_fuerza_trabajo
		
			tempfile base_`i' 
			save `base_`i''
		 	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}

	if $migracion == 1{ 
		local i=0
		foreach x of global meses{
			
			import delimited using "${input}\mes_`x'\Migración.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p orden $var_migracion
		
			tempfile base_`i' 
			save `base_`i''
		 	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}

	if $no_ocupados == 1{ 
		local i=0
		foreach x of global meses{
			
			import delimited using "${input}\mes_`x'\No ocupados.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p orden $var_no_ocupados
		
			tempfile base_`i' 
			save `base_`i''
		 	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}

	if $ocupados == 1{ 
		local i=0
		foreach x of global meses{
			
			import delimited using "${input}\mes_`x'\Ocupados.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p orden $var_ocupados
		
			tempfile base_`i' 
			save `base_`i''
		 	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}

	if $otros_trabajos == 1{ 
		local i=0
		foreach x of global meses{
			
			import delimited using "${input}\mes_`x'\Otras formas de trabajo.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p orden $var_otros_trabajos
		
			tempfile base_`i' 
			save `base_`i''
		 	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}

	if $otros_ingresos == 1{ 
		local i=0
		foreach x of global meses{
			
			import delimited using "${input}\mes_`x'\Otros ingresos e impuestos.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p orden $var_otros_ingresos
		
			tempfile base_`i' 
			save `base_`i''
		 	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}
        
	if $tipo == 1{ 
		local i=0
		foreach x of global meses{
			
			import delimited using "${input}\mes_`x'\Tipo de investigación.csv", clear
			local ++i
			*keep the identifier variables:
			keep directorio secuencia_p orden $var_tipo
		
			tempfile base_`i' 
			save `base_`i''
		 	
					}

	*append all months
	
	use `base_1', clear
	
	forvalues n=2/12{
		append using `base_`n''
		
	}
		
		merge 1:m directorio secuencia_p orden using "${output}\GEIH2022.dta"
		save "${output}\GEIH2022.dta", replace
	
	}
        

}
