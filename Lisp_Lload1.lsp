(defun c:lload1 (/ opci)
	;FUNCIONES DE ENTRADA
	;;;;;;**********
;	(load "C:\\Users\\Joserra\\Dropbox\\00_SOLUCIONESCAD\\CADDapps\\FuncionesLisp\\LispDEP_BRKSTEP1.lsp")
;	(load "C:\\Users\\Joserra\\Dropbox\\00_SOLUCIONESCAD\\CADDapps\\FuncionesLisp\\LispTXT_SUTX.lsp")
;	(load "C:\\Users\\Joserra\\Dropbox\\00_SOLUCIONESCAD\\CADDapps\\FuncionesLisp\\LispPH_Vere02.lsp")
;	(alert "lload1")
	(setq llrut
		(vere01
			(list
				(list "FUNCIONES" "SELECCIONE LA RUTA DE FUNCIONES")
				(list "BDATOS" "SELECCIONE LA RUTA DE DATOS")
				(list "BLOQUES" "SELECCIONE LA RUTA DE BLOQUES")
				(list "CODIGO_NR" "SELECCIONE LA RUTA DE CODIGO_NR")
				(list "LISP_PRINCIPAL" "SELECCIONE LA RUTA LISP_PRINCIPAL")
				(list "FOO_LISP" "SELECCIONE EL ARCHIVO FOO_LISP")
				(list "IBS_OBJETOS" "SELECCIONES LA RUTA IBS_OBJETOS DE AUTODESK")
				(list "IBS_DCL" "SELECCIONE LA RUTA IBS_DCL DE AUTODESK")
				(list "CIVIL_V4" "SELECCIONE LA RUTA DE CIVIL VERSION 4")
				(list "LISP_ORIGINAL" "SELECCIONE LA RUTA LISP_ORIGINAL")
				(list "IDESA_PRINCIPAL" "SELECCIONE LA RUTA IDESA PRINCIPAL")
				(list "IDESA_DCL" "SELECCIONE LA RUTA IDESA DCL")
				(list "LISP_LABS" "SELECCIONE LA RUTA LISP LABS")
				(list "LISP_ESTRUCTURA/ORIGINAL RECIBIDO"
					"SELECCIONE LA RUTA LISP_ESTRUCTURA/ORIGINAL RECIBIDO"
				)
				(list "LISP_ESTRUCTURA" "SELECCIONE LA RUTA LISP_ESTRUCTURA")
				(list "LISP_PROGRAMADOR" "SELECCIONE LA RUTA LISP_PROGRAMADOR")
				(list "ADICIONALES" "SELECCIONE LA RUTA FUNCIONES_LISP/ADICIONALES" )
				(list "BDATOS_GSP" "SELECCIONE LA RUTA BDATOS_GSP")
				(list "APLICACIONES_LISP" "SELECCIONE LA RUTA APLICACIONES_LISP")
			)
		)
	)
	;br 
	(brkstep1
		'("llrut") (list llrut)
		"lload1:0000" "00001a"
	)
	;br..
	(load
		(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "LispDEP_LOADF.lsp")
	)
	(setq opci "pas")
	;br 
;	(brkstep1
;		'("opci") (list opci)
;		"LLOAD1:0000" "0000"
;	)
	;br..
	(while (not (= opci nil))
		(setq opci
			(getint
				"0.CARGA DE EJECUTABLES\n1.DEP(LISP)\n2.EXEFOO\n3.FOO\n4.OBJ(LISP)\n5.CIVIL\n6.IDESA\n7.IBS\n8.IBS(C)\n9.CADENA\n10.IBC(DROP)\n11.COPY2PODIO\n12.DITAPSA\n13.Funcion_GStar\n14.Funcion_ACAD\n15.Funcion_BricsCAD\n16 COMPILADOR\n17.IDESA DropBox\n18.Objetos5 (IBS)\n19.PRONTOFOO\n20.LispSOP_OBJETOS: "
			)
		)
		;br
		(brkstep1
			'("opci") (list opci)
			"Lload:00" "00"
		)
		;br..
		(cond
			(
				(= opci 1)
				(setq opNr (qnth02 "CODIGO_NR" "RUTAS"))
				
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Lisp_Principal/Codigo_NR/Lisp_DEPURACION.lsp")
				(alert "Lisp_DEPURACION\nDE LISP_PRINCIPAL\nCARGADO...")
			)
			(
				(= opci 2)
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Lisp_Principal/EXEFOO.lsp")
				(alert "EXEFOO\nCARGADO...")
			)
			(
				(= opci 3)
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Lisp_Principal/FOO.lsp")
				(alert "FOO\nCARGADO...")
			)
			(
				(= opci 4)
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Lisp_Principal/Lisp_Objetos.lsp")
				;(load "C:/Cuantificador/Lisp_Principal/Lisp_Objetos.lsp")
				;(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/CI_Principal/DWG_Principal/Lisp_Objetos.LSP")
				(alert "Lisp_Objetos\nDE LISP_PRINCIPAL\nCARGADO...")
			)
			(
				(= opci 5)
				;(load 	"C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/CI_Principal/DWG_Principal/Lisp_Objetos.LSP")
				;(load ;"C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/CI_Principal/DWG_Principal/CADENA.LSP")
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/CI_Principal/DWG_Principal/Version10/Civil.lsp")
				(alert "Civil.lsp\nDE VERSION 10\nCARGADO...")
			)
			(
				(= opci 6)
				
				(load "C:/Cuantificador/Lisp_Principal/Lisp_Objetos.lsp")
				(load "C:/Cuantificador/Lisp_Principal/Lisp_DEPURACION.lsp")
				(load "C:/Cuantificador/DCL_IDESA/DCL_OBJETOS.lsp")
				(load "C:/Cuantificador/DCL_IDESA/apoy.lsp")
				(alert "APOY\nLisp_Objetos\nLisp_DEPURACION\nDCL_OBJETOS\nDE C:CUANTIFICADOR\nCARGADO...")
				
			)
			(
				(= opci 7)
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/IBS_Objetos/IBS_Objetos.lsp")
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/IBS_Objetos/IBS_Objetos2.lsp")
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/IBS_Objetos/IBS_Objetos3.lsp")
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/IBS_Objetos/IBS_Objetos4.lsp")
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/Lisp_DEPURACION.lsp")
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/IBS_DCL/DCL_OBJETOS.lsp")
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/IBS_DCL/apoy.lsp")
				(alert "APOY\nLisp_Objetos\nLisp_DEPURACION\nDCL_OBJETOS\nDE ProyectoIBS\nCARGADO...")
				
			)
			(
				(= opci 8)
				;(load "C:/Proyecto_IBS/IBS_Objetos.lsp")
				;(load "C:/Proyecto_IBS/IBS_Objetos2.lsp")
				;(load "C:/Proyecto_IBS/IBS_Objetos3.lsp")
				;(load "C:/Proyecto_IBS/IBS_Objetos4.lsp")
				(load "C:/Proyecto_IBS/IBS_Objetos5.fas")
				;(load "C:/Proyecto_IBS/Lisp_DEPURACION.lsp")
				(load "C:/Proyecto_IBS/IBS_DCL/DCL_OBJETOS.lsp")
				(load "C:/Proyecto_IBS/IBS_DCL/apoy.lsp")
				(alert "APOY\nIBS_Objetos5.fas\nDCL_OBJETOS\nDE C:/ProyectoIBS\nCARGADO...")
				
			)
			(
				(= opci 9)
				;(load
			;	"C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/CI_Principal/DWG_Principal/Cadena/CADENA.lsp"
			;	)
				(load
				"C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/CI_Principal/DWG_Principal/Version4/Civil.lsp"
				)
				(alert
					"Civil.lsp\nde C:...\Dropbox\...\Version4\nCARGADO...")
			)
			(
				(= opci 10)
					(load
						"C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/IBS_Objetos/IBS_Objetos5.lsp"
					)
				(load "C:/Proyecto_IBS/IBS_DCL/DCL_OBJETOS.lsp")
				(load "C:/Proyecto_IBS/IBS_DCL/apoy.lsp")
				(alert "APOY\nIBS_Objetos5.lsp (INTELLIGRAM)\nDCL_OBJETOS.lsp APOY.lsp\nDE C:/ProyectoIBS\nCARGADO...")
				
			)
			(
				(= opci 11)
				(load
					(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "copy2podio.lsp")
				)
				(alert "COPY2PODIO CARGADO")
			)
			(
				(= opci 12)
				(load
					"C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Lisp_Original/DITAPSA.lsp"
				)
				(alert "DITAPSA CARGADO")
			)
			(
				(= opci 13)
				(load
					"C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FuncionesLisp/Lisp_GStarFuncion.lsp"
				)
				(alert "FUNCIONES GSTARCAD CARGADO...")
			)
			(
				(= opci 14)
				(load
					"C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FuncionesLisp/Lisp_AcadFuncion.lsp"
				)
				(alert "FUNCIONES AUTOCAD CARGADO...")
			)
			(
				(= opci 15)
				(load
					"C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FuncionesLisp/Lisp_BricsCadFuncion.lsp"
				)
				(alert "FUNCIONES BRICSCAD CARGADO...")
			)
			(
				(= opci 16)
				(load
					"C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FuncionesLisp/LispFUN_Compila.lsp"
				)
				(alert "COMPILADOR CARGADO...")
			)
			(
				(= opci 17)
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/IDESA_Principal/Lisp_Principal/Lisp_Test/Lisp_Objetos.lsp")
				(load "C:/Cuantificador/Lisp_Principal/Lisp_DEPURACION.lsp")
				(load "C:/Cuantificador/DCL_IDESA/DCL_OBJETOS.lsp")
				(load "C:/Cuantificador/DCL_IDESA/apoy.lsp")
				(alert "APOY\nLisp_Objetos\nLisp_DEPURACION\nDCL_OBJETOS\nDE C:CUANTIFICADOR\nCARGADO...\nLisp_OBJETOS.lsp DE DROPBOX...Lisp_TEST")
				
			)
			(
				(= opci 18)
				(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Proyecto_IBS/Autodesk/IBS_Objetos/IBS_Objetos5.lsp")
				(load "C:/Proyecto_IBS/IBS_DCL/DCL_OBJETOS.lsp")
				(load "C:/Proyecto_IBS/IBS_DCL/apoy.lsp")
				(alert "APOY\nIBS_Objetos5.lsp (INTELLIGRAM)\nDCL_OBJETOS.lsp APOY.lsp\nDE C:/ProyectoIBS\nIBS_Objetos5.lsp de DROPBOX\nCARGADO...")
			)
			(
				(= opci 19)
				(load "C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FooLisp/ProntoFoo.lsp")
			)
			(
				(= opci 20)
				(load "C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FuncionesLisp/LispSOP_OBJETOS.lsp")
			)
			(
				(= opci 0)
				(load
					(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "LispPH_Term.lsp")
				)
				(load
					(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "LispTXT_SUTX.lsp")
				)
				(load
					(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "LispMain_Ini.lsp")
				)
				(load
					(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "LispMDAT_Lec.lsp")
				)
				(load
					(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "LispMain_Ini.lsp")
				)
				;;***COMANDO DE CARGA DE EXEFOO***
				(defun c:xs ()	
					(load
						(strcat	(qnth02 llrut "FOO_LISP" "RUTA" 0.01)  "EXEFOO.lsp")
					)
				)
				(prompt "XS CARGADO...")
				(print)
				;
				;;
				;;;
				;;;;
				;;***COMANDO DE CARGA DE FOO***
				(defun c:foo ()
					(load
						(strcat (qnth02 llrut "FOO_LISP" "RUTA" 0.01) "FOO.lsp")
					)
				)
				(prompt "foo cargado...")
				(print)
				;
				;;
				;;;
				;;***COMANDO DE CARGA DE PRONTOFOO***AQUI
				(defun c:as ()
					(load
						(strcat (qnth02 llrut "FOO_LISP" "RUTA" 0.010) "ProntoFoo.lsp")
					)
				)
				(prompt "as cargado...")
				(print)
				;
				;;
				;;;;
				;;;;;
				;;****************COMANDO DE CARGA DE IPHONE*************
				(defun c:ias ()
					(load
						(strcat (qnth02 llrut "FOO_LISP" "RUTA" 0.010) "IphoneFoo.lsp")
					)
				)
				(prompt "ias cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				;;****************COMANDO DE CARGA DE IPHONEII*************
				(defun c:ias2 ()
					(strcat (qnth02 llrut "FOO_LISP"))
					(load "C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FooLisp/IphoneFOOII.lsp")
				)
				(prompt "ias2 cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				;;*****************COMANDO DE CARGA FOOII**********************
				(defun c:foo2 ()
					(load "C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FooLisp/FOOII.lsp")
				)
				(prompt "foo2 cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				;;*****************COMANDO DE CARGA PRONTOFOOII**********************
				(defun c:pfoo ()
					(load "C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FooLisp/ProntoFooII.lsp"
					)
				)
				(prompt "pfoo cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				;;*****************COMANDO DE CARGA PRONTOFOOIII**********************
				(defun c:ssa ()
					(load "C:/Users/Joserra/Dropbox/00_SOLUCIONESCAD/CADDapps/FooLisp/ProntoFooIII.lsp"
					)
				)
				(prompt "ssa cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				;;*****CARGA DE APOY: LISP DE APOYO PARA DCL**************
				(defun c:appo ()
					(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/IDESA_Principal/DCL_IDESA/apoy.lsp")
				)
				(prompt "appo cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				;;******CARGA DE PRE APLICACION DE LEVANTAMIENTO DE TELMEX****
				(defun c:carso ()
					(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Lisp_Carso/Recolector/Carso_PUNTOS/APLICACIONES/Objetos5.lsp"
					)
					(load "C:/Users/Joserra/Dropbox/001_INTELLIGRAM/Aplicaciones_Lisp/Lisp_Carso/Recolector/Carso_PUNTOS/APLICACIONES/Levantamiento.lsp")
					(prompt "carso cargado...")
					(print)
				)
				;
				;;
				;;;
				;;;;
				;;************CARGA DE ARCHIVOS MEDIANTE UN CSV*****
				(defun c:cl ()
					(load
						(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "LispLIST_LNPO2.lsp")
					)
					(load
						(strcat (qnth02 llrut "FUNCIONES" "RUTA" 0.01) "LispPH_DEFR01.lsp")
					)
					(load
						(strcat (qnth02 llrut "FUNCIONES" "RUTA" 0.01) "LispMDAT_Dat.lsp")
					)
					(loadf
						(qnth02 llrut "FUNCIONES" "RUTA" 0.01)
						(strcat
							(qnth02 llrut "APLICACIONES_LISP" "RUTA" 0.01)
							"Carga de archivos.csv"
						)
					)
					(prompt "cl cargado...")
					(print)
				)
				;
				;;
				;;;
				;;;;
				;;************CARGA DE ARCHIVOS MEDIANTE UN CSV*****
				(defun c:clg ()
					(load
						(strcat	(qnth02 llrut "FUNCIONES" "RUTA" 0.01)  "LispLIST_LNPO2.lsp")
					)
					(load
						(strcat (qnth02 llrut "FUNCIONES" "RUTA" 0.01) "LispPH_DEFR01.lsp")
					)
					(load
						(strcat (qnth02 llrut "FUNCIONES" "RUTA" 0.01) "LispMDAT_Dat.lsp")
					)
					(loadf
						(qnth02 llrut "FUNCIONES" "RUTA" 0.01)
						(strcat
							(qnth02 llrut "BDATOS_GSP" "RUTA" 0.01)
							"Carga de archivos.csv"
						)
					)
					(prompt "cl cargado...")
					(print)
				)
				;
				;;
				;;;
				;;;;
				;;************CARGA DE ARCHIVOS MEDIANTE UN CSV*****
				(defun c:cll ()
					(loadf
						(qnth02 llrut "LISP_LABS" "RUTA"  0.001)
						(strcat (qnth02 llrut "LISP_LABS" "RUTA" 0.001) "CargaWO.csv")
					)
				)
				(prompt "cll cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				(defun c:fix ()
					(fx
						(qnth02 llrut "LISP_LABS" "RUTA" 0.001)
					)
				)
				(prompt "fix cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				(defun c:fixr ()
					(fxr
						(qnth02 llrut "FUNCIONES" "RUTA" 0.001)
					)
				)
				(prompt "fixr cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				;;************CARGA DE ARCHIVOS MEDIANTE UN CSV*****
				(defun c:cl1 ()
					(loadf
						(qnth02 llrut "LISP_ESTRUCTURA/ORIGINAL" "RUTA")
						(strcat (qnth02 "LISP_LABS" "RUTA" 0.001) "CargaWO.csv" )
					)
				)
				(prompt "cl1 cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				;;**********TEMPORAL CARGA PRUEBA DCL********
				(defun c:dcl ()
					(load
						(strcat
							(qnth02 llrut "LISP_ESTRUCTURA" "RUTA" 0.001)
							"estructura_dcl.dcl"
						)
					)
					(prompt "dcl cargado...")
					(print)
				)
				;
				;;
				;;;
				;;;;
				;;*****************TEMPORAL DE PROGRAMADOR*********
				(defun c:prg ()
					(load 
						(strcat (qnth02 llrut "FUNCIONES" "RUTA" 0.001) "LipDEP_loadf.lsp")
					)
					(loadf
						(qnth02 llrut "FUNCIONES" "RUTA" 0.001)
						(strcat (qnth02 llrut "LISP_PROGRAMADOR" "RUTA" 0.001)
							"Carga de archivo.csv"
						)
					)
				)
				(prompt "prg cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				(defun c:popc ()
					(load 
						(strcat
							(qnth02 llrut "LISP_PROGRAMADOR" "RUTA" 0.001) "PrgDEP_Popc.lsp"
						)
					)
				)
				(prompt "popc cargado...")
				(print)
				;
				;;
				;;;
				;;;;
				(defun c:popc2 ()
					(load (strcat (qnth02 llrut "ADICIONALES" "RUTA" 0.001) 		
						"GspDEP_Popc02.lsp")
					)
				)
				(defun c:parm ()
					(load
						(strcat (qnth02 llrut "LISP_PROGRAMADOR" "RUTA" 0.001)
							"PrgDEP_Parm.lsp"
						)
					)
					(prompt "parm cargado...")
				)
				;
				;;
				;;;
				;;;;
				(defun c:popg ()
					(load
						(strcat (qnth02 llrut "ADICIONALES" "RUTA"  0.001)
							"GspDEP_Popc.lsp"
						)
					)
					(pompt "GspDEP_Popc cargado...")
				)
				
				
				(print)
				(alert "..xs  foo  as\nias  ias2  foo2\npfoo  ssa  appo\ncarso  cl  cll\ndcl  prg  popc\nparm Ini")
			);;opci 0..
		);;cond..
	);;whle..
);defun..
;
;;
;;;
;;;;
;;FUNCIONES DE INICIO
(defun ruta (ext tx11 / txx rut)
  (setq txx (strcat "SELECCIONA EL ARCHIVO " tx11)
	rut (getfiled txx "" ext 128))
)
;**********************
(defun Vere01 ; Extrae los datos del archivo principal de rutas (verificacion)>
	(v1Ls0 /
		v1Ls
		v1Res v1con v1El
	)
;	(setq v1Ls nil
;		v1Res nil v1con nil v1El nil
;	)
	;br
;	(brkstep1
;		'("v1Ls0") (list v1Ls0)
;		"Vere01:00" "00"
;	)
	;br..
	(cond
		(;cond type T
			(equal (LsType v1Ls0) 'LIST)
			(setq v1Ls v1Ls0
				v1Con 0
			)
			;br
;			(brkstep1
;				'("v1Ls") (list v1Ls)
;				"Vere01:01" "01"
;			)
			;br..
			(if
				(vere (strcat (term (getvar "savefilePath")) "RUTAS.csv"))
				(progn
					(setq v1Res
						(lec01
							2
							(strcat
								(term (getvar "savefilePath"))
								"RUTAS.csv"
							)
							"non"
						)
					)
					;br
;					(brkstep1
;						'("v1Res") (list v1Res)
;						"VERE01:02" "02"
;					)
					;br..
					(setq v1con 0)
					(while (< v1con (length v1Ls))
						;br
;						(brkstep1
;							'("Elemento") (list (nthx (list v1con 0) v1ls))
;							"VERE01:03" "03"
;						)
						;br..
						(setq v1El
							(lnpo4
								(nthx (list v1con 0) v1Ls)
								v1Res
								0 1 0.001
							)
						)
						;br
;						(brkstep1
;							'("v1El") (list v1El)
;							"Vere01:02" "02"
;						)
						;br..
						(cond
							(
								(= v1El nil)
								(setq v1Res
									(grab01 () "RUTAS" "csv" "RUTA"
											V1Ls
											()
									)
								)
								;br
;								(brkstep1
;									'("v1Res") (list v1Rs)
;									"VERE01:03" "03"
;								)
								;br..
							)
						)
						(setq v1con (+ 1 v1con))
					)
				)
				(progn
					(setq v1Res
						(grab01
							() "RUTAS" "csv" "RUTA"
							v1Ls
							()
						)
					)
				)
			)
			;br
;			(brkstep1
;				'("v1Res") (list v1Res)
;				"VERE01:02" "02"
;			)
			;br..
		);cond type T..
	);Cond..
	(setq v1Res v1Res)
);Vere01..
;;
(defun LsType ;Define el tipo de datos en una lista
	(lsList0 /
		lsList lsT0 lsT1 lsCon lsT lsPass
	)
;	(setq lsList nil lsT0 nil lsT1 nil lsCon nil lsT nil lsPass nil)
	;;
;	(brkstep1
;		'("lsList0" "(type lsList0)")
;		(list LsList0 (type lsList0))
;		"00" "LsType"
;	)
	;;
	(cond
		(
			(= (type lsList0) 'LIST)
			(setq lsList lsList0
				lsPass 1
			)
			;;
;			(brkstep1 '("lsList" "lsPass") (list lsList lsPass) "01" "LsType")
			;;
			(cond
				(
					(and
						(not (= (type (cdr lsList)) 'LIST))
						(not (equal (cdr lsList) nil))
						(equal (cons (car lsList) (cdr lsList)) lsList)
						(= (numberp lsList) nil)
					)
					;;
;					(brkstep1
;						'("(type (cdr lsList))" "(cons (car lsList) (cdr lsList))")
;						(list (type (cdr lsList)) (cons (car lsList) (cdr lsList)))
;						"03" "LsType"
;					)
					;;
					(setq lsT "PAR"
						lsPass 0
					)
				)
				(
					(= lsPass 1)
					(setq lsCon 0
						lsT0 (type (nth lsCon lsList))
					)
					;;
;					(brkstep1
;						'("(type (nth lsCon lsList))")
;						(list (type (nth lsCon lsList)))
;						"04" "LsType"
;					)
					;;
					(cond
						(
							(or (= lsT0 'INT) (= lsT0 'REAL))
							(setq lsT0 "NUM")
						)
						(
							(= (type lsT0) 'STR)
							(setq lsT0 "STR")
						)
						(
							(= (type lsT0) 'LIST)
							(setq lsT0 "LIST")
						)
					)
					;;
;					(brkstep1 '("lsT0") (list lsT0) "05" "LsType")
					;;
					(while
						(< lsCon (length lsList))
						(setq lsT1 (type (nth lsCon lsList)))
						;;
;						(brkstep1 '("lsT1") (list lsT1) "06" "LsType")
						;;
						(cond
							(
								(or (= lsT1 'INT) (= lsT1 'REAL))
								(setq lsT1 "NUM")
							)
							(
								(= (type lsT1) 'STR)
								(setq lsT1 "STR")
							)
							(
								(= (type lsT1) 'LIST)
								(setq lsT1 "LIST")
							)
						)
						(cond
							(
								(= lsT0 lsT1)
								(setq lsCon (+ lsCon 1)
									lsT lsT1)
							)
							(
								(not (= lsT0 lsT1))
								(setq lsT "VAR"
									lsCon (length lsList)
								)
							)
						)
						;;
;						(brkstep1 '("lsT") (list lsT) "07" "LsType")
						;;
					)
				)
			)
		)
		(
			(not (= (type lsList0) 'LIST))
			(setq lsT nil)
		)
	)
	;;
;	(brkstep1 '("lsT") (list lsT) "03" "LsType")
	;;
	(setq lsT lsT)
)
;;
(defun term ;Arregla una ruta con la separacion de carpetas y termino en \\>
	(inRt0 /
		inRt
		inRes inTerm
	)
	;var
;	(setq inRt nil
;		inRes nil inTerm nil
;	)
	;var..
	;br
;	(brkstep1
;		'("inRt0") (list inRt0)
;		"INI:00" "00"
;	)
	;br..
	(cond
		(;CondType true
			(= (type inRt0) 'STR)
			(setq inRt inRt0)
			;br
;			(brkstep1
;				'("inRt") (list inRT)
;				"INI:01" "01"
;			)
			;br..
			(setq inRt (sutx inRt '(("/" "\\")))
				inTerm (substr inRt (strlen inRt) 1)
			)
			;br
;			(brkstep1
;				'("inRt" "inTerm") (list inRt inTerm)
;				"INI:02" "02"
;			)
			;br..
			(cond
				(
					(= inTerm "\\")
					(setq inRes inRt)
				)
				(
					(not (= inTerm "\\"))
					(setq inRes (strcat inRt "\\"))
				)
			)
			;br
;			(brkstep1
;				'("inRes") (list inRes)
;				"INI:03" "03"
;			)
			;br..
		);CondType true
	)
	(setq inRes inRes)
);Term..
;;
(defun ruta (ext tx11 / txx rut); Devuelve ruta y nombre de archivo
	(setq txx (strcat "SELECCIONA EL ARCHIVO " tx11)
		rut (getfiled txx "" ext 128)
	)
)