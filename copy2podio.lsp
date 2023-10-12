;1 2






;;PROYECTO: NV (NOVIDESA)
;;CLASIFICACION: PAN (PANELIZACION)
;;OBJETO: MAT4
;;	> A partir de la definicion de la lista base de lineas y la dimension
;;	de los puntos de verificacion devuelve la lista de coordenadas de la matriz
;;	de la retícula con valor de conexión = 0
;;DEVUELVE:
;;	> [ (pend ordenada (conx xy1) (conx xyint) (conx xyint) ... (conx xyfin)]
;;ARGUMENTOS
;;	1.COB: Lista de coordenadas
;;	> [ ((pendiente ordenada ID (XY1) (XY2) (...) ...) (...)]
;;	2.PDIM: Dimension de puntos de verificacion
;;	3.MM0: Borrado de matriz: 
;;	> 1: Borra matriz
;;	> 0 / () : Lo conserva
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>PR...
(defun mat4
	(cob pdim mm0 /
		con1 con2
		grt grt1 grf grtl
		p1 p2
		crocf
		ppl
		ssp ssl
		lco1
		plname
		ssn
		lpse lpse0
		pvt pvt1 pvt0 pvtd pvres pvsel
		spa mios mipase7 vv
	)
	;(setq con1 nil con2 nil
	;	grt nil grt1 nil grf nil grtl nil
	;	p1 nil p2 nil crocf nil ppl nil ssp nil ssl nil lco1 nil plname nil
	;	ssn nil lpse nil lpse0 nil
	;	pvt nil pvt1 nil pvt0 nil pvtd nil pvres nil pvsel nil
	;	spa nil mios nil mipase7 nil vv nil
	;)
	(setq mios (getvar "osmode"))
	(setvar "osmode" 0)
	(setq vv (getvar "luprec"))
	(setvar "luprec" 8)
	;(brkstep
	;	'("cob"
	;		"(length cob)"
	;		"(nth 0 cob)"
	;		"(length (nth 0 cob))"
	;		"(nth 1 cob)"
	;		"(length (nth 1 cob))"
	;		"Pdim" "mm0"
	;	)
	;	"00" "MAT4"
	;)
	(cond
		(
			(and
				(not (= cob nil))
				(= (type cob) 'LIST)
				(= (length cob) 2)
			)
			(setq
				p1 (nth 0 (nth 0 (nth 0 cob)))
				p2 (nth 0 (nth 0 (nth 1 cob)))
				grt (nth 0 cob)
			)
			;**p1 #.# / -#.# / "nop". Pendiente primer grupo
			;**p2 #.# / -#.# / "nop". Pendiente segundo grupo
			;**gtr ((p o hd (xy) (xy)) (...)...) Primer grupo
			;(brkstep '("p1" "p2" "grt") "01" "MAT4")
			(cond
				(
					(or
						(= p1 "nop")
						(= p2 "nop")
					)
					(setq ppl (mat4a1 cob 3 8))
					;(brkstep '("ppl") "02A" "MAT4")
					;** ppl ((XY)(XY)(XY)(XY))
					;**Puntos Perimetral (0/90 grados)
				)
				(
					(and
						(= (numberp p1) T)
						(= (numberp p2) T)
					)
					(setq ppl (mat4b cob pdim))
					;(brkstep '("ppl") "02B" "MAT4")
					;** ppl ((XY)(XY)(XY)(XY))
					;**Puntos Perimetral pendientes inclinadas
				)
			)
			(setq ssp (ssadd)
				ssl (ssadd)
			)
			;**SSP. Seleccion de polilinea
			;**SSL. Seleccion de linea
			(command "pline"
				(nth 0 ppl)
				(nth 1 ppl)
				(nth 2 ppl)
				(nth 3 ppl)
				"c"
			)
			(setq ssp (ssadd (entlast) ssp)
				crocf (list ppl)
			)
			(setq plname (ssname ssp 0))
			;**CROCF (((xy) (xy) (xy) (xy)))
			;**Lista con coordenadas de perimetral
			;**PLNAME. ENAME polilinea
			;(brkstep '("crocf" "plname") "03" "MAT4")
			(repeat
				2
				(setq grtl (lva0 grt 2 1 3))
				;(brkstep '("grtl" "(length grtl)") "03a" "MAT4")
				(setq grtl (ordvar0 grtl 0))
				;(brkstep '("grtl" "(length grtl)") "03b" "MAT4")
				(setq grtl (cut 1 (- (length grtl) 2) grtl))
				(setq con1 0)
				;(brkstep 
				;	'("grt" "(length grt)"
				;		"grtl" "(length grtl)"
				;		"(lnpo4 (nth con1 grtl) grt 1 1 0.0001)"
				;		"con1"
				;	)
				;	"04" "MAT4"
				;)
				;**GRTL (#.# ...) Lista de pendientes del grupo (GRT)
				;** excluyendo la primera y la ultima (para reticula)
				(while
					(< con1 (length grtl))
					(setq grt1 (lnpo4 (nth con1 grtl) grt 1 1 0.001))
					;(brkstep '("grt1") "04A" "MAT4")
					(setq grt1 (nth 0 grt1))
					;(brkstep '("grt1") "05" "MAT4")
					;**GRT1. (P O HD (XY) (XY));
					;** Primer Elemento de la pendiente (con1)
					(setq grf
						(append grf
							(list
								(list
									(nth 3 grt1)
									(round1
										(angle (nth 3 grt1) (nth 4 grt1))
										7
									)
								)
							)
						)
					)
					(setq con1 (+ con1 1))
					;(brkstep '("grf" "con1") "06" "MAT4")
					;**GRF ( ((XY) ANGULO) (...) ...)
					;** Lista de coordenadas y angulo por cada pendiente
				)
				(setq grt (nth 1 cob))
				;**GRT ((P O HD (xy) (xy)) (...)...)
				;** Segundo grupo (ciclo)
				;(brkstep '("grt" "grf") "07" "MAT4")
			)
			;(brkstep '("grf" "(length grf)") "08" "MAT4")
			;**GRF ( ((XY) ANGULO) (...) ...); Lista final de coordenada y angulo
			(setq con1 0
				grf grf
			)
			(while
				(< con1 (length grf))
				(setq croc1
					(ret0a (nth 0 (nth con1 grf))
						(nth 1 (nth con1 grf))
						(list plname)
					)
				)
				(command "line" (nth 0 croc1) (nth 1 croc1) "")
				(setq ssl (ssadd (entlast) ssl))
				(command "zoom" "o" ssl "")
				(setq crocf (append crocf (list croc1)))
				;(brkstep '("croc1" "crocf") "09" "MAT4")
				;**CROC1 ((XY) (XY)); Lista de coordenadas de reticula
				;**CROCF (((XY)(XY)(XY)(XY)) ((XY)(XY)) (...)...)
				;**Lista de coordenadas de linea de reticula
				;	el primer elemento corresponde a las 4 coordenadas de la
				;	polilinea
				(setq con1 (+ con1 1 ))
			)
			(setq crocf crocf)
			(command "erase" ssp "")
			(command "redrawall")
			;(brkstep '("crocf" "ppl" "(length crocf)") "10" "MAT4")
			;**PPL ((XY)(XY)(XY)(XY)); Coordenadas de perimetral
			(command "line" (nth 0 ppl) (nth 1 ppl) "")
			(setq ssl (ssadd (entlast) ssl))
			(command "zoom" "o" ssl "")
			(command "line" (nth 1 ppl) (nth 2 ppl) "")
			(setq ssl (ssadd (entlast) ssl))
			(command "zoom" "o" ssl "")
			(command "line" (nth 2 ppl) (nth 3 ppl) "")
			(setq ssl (ssadd (entlast) ssl))
			(command "zoom" "o" ssl "")
			(command "line" (nth 3 ppl) (nth 0 ppl) "")
			(setq ssl (ssadd (entlast) ssl))
			(command "zoom" "o" ssl "")
			(setq ssn (noment ssl))
			;(brkstep '("ssn" "(length ssn)" "crocf" "(length crocf)")
			;	"11" "MAT4"
			;)
			;**SSN (ENAME ...)
			;**Lista de nombre de entidades de lineas
			;	matriz
			(setq lpse (mat1 ssn)
				spa 0
			)
			(setq lpse
				(list
					(corden (nth 0 lpse) 0 8)
					(corden (nth 1 lpse) 0 8)
				)
			)
			;(brkstep
			;	'("(nthx '(0 0) (nth 1 lpse))"
			;		"(nth 0 lpse)"
			;		"(length (nth 0 lpse))"
			;		"(nth 1 lpse)"
			;		"(length (nth 1 lpse))"
			;	)
			;	"12" "MAT4"
			;)
			(setq lpse
				(list
					(dualno (nth 0 lpse) 4)
					(dualno (nth 1 lpse) 4)
				)
			)
			(cond
				(
					(not (equal (nthx '(0 0) (nth 1 lpse)) "nop"))
					(cond
						(
							(or
								(< 0 (nthx '(0 0) (nth 1 lpse)))
								(equal (nthx '(0 0) (nth 1 lpse)) 0 0.0001)
							)
							(setq lpse
								(list (nth 1 lpse) (nth 0 lpse))
							)
						)
					)
				)
			)
			;**LPSE (((P O H (XY) (XY))(....)...) (...))
			;		Lista base de lineas de matriz
			;(brkstep
			;	'("lpse"
			;		"(length lpse)"
			;		"(length (nth 0 lpse))"
			;		"(length (nth 1 lpse))"
			;	)
			;	"13" "MAT4"
			;)
			(setq lpse0 (mat3 lpse 0))
			;**LPSE0. ((P O H (Conex0 XY) (Conex0 XY) ...) (....)...)
			;		Lista de conexiones de matriz en 0
			;(brkstep '("(length lpse0)" "lpse0") "14" "MAT4")
			(setq lpse0 lpse0)
		)
	)
	(cond
		(
			(= mm0 1)
			(command "erase" ssl "")
		)
	)
	(setvar "luprec" vv)
	(setvar "osmode" mios)
	(setq lpse0 lpse0)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: Manipulacion de entidades ENT
;;OBJETO: CLY
;;	Crea nuevos layer apartir de una lista de nombres definida
;;	en el argumento
;;DEVUELVE:
;;	Metodo; numero de layers
;;ARGUMENTOS:
;;	Lista de nombres de layers para crear
;;	("xxx" xxx ...)
;;DEPENDIENTES:
;;	Ninguno
;;ANOTACIONES:
;;	Si existe algun nombre de layer ya existente en la lista
;;	lo ignora, admite textos y valores númericos
;;PR...
(defun cly (lst / con nly)
  (setq con 0)
  (while (< con (length lst))
    (setq nly (nth con lst)
	  )
    (command "layer" "n" nly "")
    (setq con (+ con 1)
	  )
    )
  )
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:PAN
;;OBJETO: MAT5A
;;	>Recorta los elementos de una lista
;;	para unirlas en una sola lista estructurada
;;DEVUELVE:
;;	> en modo 0: Fusiona los elementos devolviendo
;;	una sola lista estructurada
;;	>en modo 1: Devuelve los elementos agrupados
;;ARGUMENTOS
;;	1.LSREC: Lista estructurada para recortar
;;	> ( (xx xx) (...) ...)
;;	2. LASTP: Limite de posicion del ultimo
;;	elemento de recorte
;;> Numero entero
;;	3:MOM1: Modo de resultado
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Trabaja con la funcion de ORG, cuidado con el limite recorte
;;	la posicion del limite del ultimo elemento se cuenta desde el 1
;;	y revisar como trabaja
;;PR....
(defun mat5a (lsrec lastp mom1 / con1 lsrec1 lsrecf)
	;(brkstep '("lsrec" "lastp" "mom1") "MAT5A: ENTRADA" "0")
	(setq con1 0)
	(while
		(< con1 (length lsrec))
		(setq lsrec1 (nth con1 lsrec))
		(setq lsrec1 
			(org lsrec1
				(list lastp
					(- (length lsrec1) lastp)
				)
				0
			)
		)
		;(brkstep '("lsrec1") "MAT5A" "1")
		(setq lsrec1 (nth 1 lsrec1))
		;(brkstep '("lsrec1") "MAT5A" "1")
		(cond
			(
				(= mom1 0)
				(setq lsrecf (append lsrecf lsrec1))
			)
			(
				(= mom1 1)
				(setq lsrecf
					(append lsrecf
						(list lsrec1)
					)
				)
			)
		)
		(setq con1 (+ con1 1))
		;(brkstep '("lsrecf" "con1") "MAT5A" "2")
	)
	;(brkstep '("lsrecf") "MAT5A" "3")
	(setq lsrecf lsrecf)
)

;;
;;;
;;;;
;;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: List 
;;OBJETO: LNPO3
;;	> Ejecuta LNPO3 el numero de veces y con las posiciones
;;	 indicadas en el argumento
;;DEVUELVE:
;;	> En modo 0: Devuelve todos los elementos que NO coincidan
;;	con el elemento indice (en las posiciones coincidentes)
;;	> En modo 1: Devuelve todos los elementos que SI coincidan
;;	con el elemento indice (en las posiciones coincidentes)
;;ARGUMENTOS
;;	1.INDE: Elemento indice de busqueda
;;	> (x x x)
;;	2.INSE: Lista de trabajo con los elementos
;;	iguales en estructura a el primer argumento
;;	3.POSI1: Lista de posiciones que coinciden con cada uno
;;	de los elementos y el elemento indice.
;;	4.MOM: Modo de resutltado
;; > 0 / 1 
;;	5. TREN: Presicion de coincidencia
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>PR...
(defun lnpo3 (inde inse posi1 mom tren / con1 ele1 intra)
	;(brkstep '("inde" "inse" "posi1" "mom" "tren") "LNPO3: Entrada (0)" "0")
	(setq con1 0)
	(setq intra inse)
	(while
		(< con1 (length posi1))
		(setq ele1 (nth (nth con1 posi1) inde))
		;(brkstep '("intra" "ele1") "LNPO3" "1")
		(cond
			(
				(not (= intra nil))
				(setq intra
					(lnpo2 
						ele1
						intra
						(nth con1 posi1)
						mom
						tren
					)
				)
			)
		)
		(setq con1 (+ con1 1))
		;(brkstep '("intra" "con1") "1" "LNPO3")
	)
	(setq intra intra)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: PAN
;;OBJETO: MAT6
;;	> Suma los valores de conexiones para la reticula de panel
;;DEVUELVE: Lista de lineas de una pendiente con el valor total de las conexiones
;;	>( (PEND ORD (VAL XY1) ( VAL XYINT) (...) ... (VAL XYFIN) ) (...) ...)
;;ARGUMENTOS
;;	1.LRET: Lista lineas de reticula con valor por pendiente de conexion
;;	> ( (PEND ORD (VAL XY1) ( VAL XYINT) (...) ... (VAL XYFIN) ) (...) ...)
;;	2.TIPEN: Grupo de lista de trabajo seleccionado por su pendiente
;; > (): NIL Selecciona el primer grupo de lineas
;; > 0 : Pendiente igual a 0
;;	> 1 : Pendiente positiva
;;	> 2 : Pendiente negativa
;;	> 3 : Pendiente indeterminada ("NOP")
;;	3.PPD : Dimension de punto de verificacion
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>PR...
(defun mat6
	(lret tipen ppd /
		con1 con2
		lfinal
		lretc
		ret1
		lret0 lret0a lret0b lret0c lret0f
		lretco lretco1 lretco2
		sim1 sim2 selepo lrtxt
	)
	;(brkstep '("lret" "tipen") "0:ENTRADA" "MAT6")
	(cond
		(
			(not (= lret nil))
			(setq lret1 (agru1 lret () 0 0.001)
				sim1 (nth 0 (nth 0 (nth 0 lret1)))
				sim2 (nth 0 (nth 0 (nth 1 lret1)))
				selepo (ssadd)
			)
			;(brkstep '("lret1" "sim1" "sim2") "00" "MAT6")
			;**LRET1. Lista de elementos agrupados por su pendiente
			;**(((p o h val x y) (...) ...) (...))
			;**SIM1 Pend1
			;**SIM2	Pend2
			(cond
				(
					(and (= tipen 3) (= sim1 "nop"))
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 3) (= sim2 "nop"))
					(setq lret1 (nth 1 lret1))
				)
				(
					(= tipen nil)
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 0) (equal sim1 0 0.001))
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 0) (equal sim2 0 0.001))
					(setq lret1 (nth 1 lret1))
				)
				(
					(and (= tipen 1) (< 0 sim1))
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 1) (< 0 sim2))
					(setq lret1 (nth 1 lret1))
				)
				(
					(and (= tipen 2) (< sim1 0))
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 2) (< sim2 0))
					(setq lret1 (nth 1 lret1))
				)
			)
			(cond
				(
					(not (= lret1 nil))
					(setq con1 0)
					(setq lretc (mat5a lret 3 0))
					(setq lfinal '())
					;(brkstep '("lretc" "(length lretc)" "lret1" "con1" "lfinal")
					;	"1" "MAT6"
					;)
					(while (< con1 (length lret1))
						(setq lret0 (nth con1 lret1))
						(setq lret0
							(org lret0
								(list 3
									(- (length lret0) 3)
								)
								0
							)
						)
						(setq
							lret0a (nth 0 lret0)
							lret0b (nth 1 lret0)
							lret0c '()
							con2  0
						)
						;(brkstep '("con2" "lret0" "lret0a" "lret0b" "lret0c")
						;	"2" "MAT6"
						;)
						(while
							(< con2 (length lret0b))
							(setq lretco (nth con2 lret0b)
								lretco1 (lnpo3 lretco lretc (list 1 2) 1 0.001)
								lretco2 (lss lretco1 1)
							)
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
							(command "donut" 0.0 ppd (cdr lretco) "")
							(setq selepo (ssadd (entlast) selepo))
							;(brkstep '("(cdr lretco)") "001T" "002T")
							(setq lrtxt (cortxt (cdr lretco)))
							(command "zoom" "c" lrtxt "7")
							;(brkstep '("lretco" "lretco1" "lretco2")
							;	"3" "MAT6"
							;)
							(setq lretco2 (apply '+ lretco2))
							(setq lretco
								(list lretco2
									(nth 1 lretco)
									(nth 2 lretco)
								)
							)
							(setq lret0c (append lret0c (list lretco)))
							;(brkstep '("lretco" "lretco2" "lret0c")
							;	"4" "MAT6"
							;)
							(setq con2  (+ con2 1))
						)
						;(brkstep '("lret0c") "5" "MAT6")
						(setq lret0a (append lret0a lret0c))
						(setq lfinal (append lfinal (list lret0a))
							con1 (+ con1 1)
						)
						;(brkstep '("(cdr lretco)") "003T" "004T")
						(command "zoom" "o" selepo "")
						;(brkstep '("lret0a" "lfinal" "con1")
						;	"6" "MAT6"
						;)
					)
				)
			)
		)
	)
	(command "erase" selepo "")
	;(brkstep '("lfinal") "7" "MAT6")
	(setq lfinal lfinal)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: PAN
;;OBJETO: MATCONECT 
;;	> Vacia los valores de conexiones totales en una matriz cuadrada
;;	de puntos con valores vacios.
;;DEVUELVE: Lista de lineas de una pendiente con el valor total de las conexiones
;;	>( (PEND ORD (VAL XY1) ( VAL XYINT) (...) ... (VAL XYFIN) ) (...) ...)
;;ARGUMENTOS
;;	1.RTCONEX: Lista de reticula de una pendiente de diseño de panelizacion
;;	con valor total de conexiones.
;;	> ( (PEND ORD (VAL XY1) ( VAL XYINT) (...) ... (VAL XYFIN) ) (...) ...)
;;	2.VLT: Lista de reticula (dos pendientes)
;;	con valor de conexiones en 0
;;	> [ ( (PEND1 ORD (0 XY1) ( 0 XYINT) (...) ... (0 XYFIN) ) (...) ...)
;; >	 ( (PEND2 ORD (0 XY1) ( 0 XYINT) (...) ... (0 XYFIN) ) (...) ...) ]
;;	3.TIPEN: Grupo de lista de trabajo seleccionado por su pendiente
;; > (): NIL Selecciona el primer grupo de lineas
;; > 0 : Pendiente igual a 0
;;	> 1 : Pendiente positiva
;;	> 2 : Pendiente negativa
;;	> 3 : Pendiente indeterminada ("NOP")
;;	4.PP: Dimension de los puntos de verificacion
;;	> Numero real
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>PR...
(defun matconect
	(rtconex vlt tipen ppd /
		con1 con2
		lfinal
		lretc
		ret1
		lret0 lret0a lret0b lret0c lret0f
		lretco lretco1 lretco2
		sim1 sim2 mimos doinstxt
	)
	;(setq con1 nil con2 nil lfinal nil lretc nil ret1 nil ret1 nil lret0 nil
	;	lret0a nil lret0b nil lret0c nil lretof nil lretco nil lretco1 nil lretco2 nil
	;	sim1 nil sim2 nil mimos nil doinstxt nil
	;)
	;(brkstep '("rtconex" "vlt" "tipen" "ppd") "00" "matconect")
	(setq mimos (getvar "osmode"))
	(setvar "osmode" 0)
	;(brkstep '("rtconex" "vlt" "tipen" "ppd" "(length vlt)" "(length rtconex)") "0:ENTRADA" "0: MATCONECT")
	;(brkstep '("lretco1") "001TEMP" "ENTRO EN INTERSECCION")
	(cond
		(
			(and
				(not (= vlt nil))
				(not (= rtconex nil))
			)
			(setq lret1 (agru1 vlt () 0 0.001)
				sim1 (nth 0 (nth 0 (nth 0 lret1)))
				sim2 (nth 0 (nth 0 (nth 1 lret1)))
				selepo (ssadd)
			)
			;(brkstep '("lret1" "sim1" "sim2" "selepo") "00" "00: MATCONECT")
			(cond
				(
					(= tipen nil)
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 3) (= sim1 "nop"))
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 3) (= sim2 "nop"))
					(setq lret1 (nth 1 lret1))
				)
				(
					(and (= tipen 0) (equal sim1 0 0.001))
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 0) (equal sim2 0 0.001))
					(setq lret1 (nth 1 lret1))
				)
				(
					(and (= tipen 1) (< 0 sim1))
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 1) (< 0 sim2))
					(setq lret1 (nth 1 lret1))
				)
				(
					(and (= tipen 2) (< sim1 0))
					(setq lret1 (nth 0 lret1))
				)
				(
					(and (= tipen 2) (< sim2 0))
					(setq lret1 (nth 1 lret1))
				)
			)
			(cond
				(
					(not (= lret1 nil))
					(setq con1 0)
					(setq lretc (mat5a rtconex 3 0))
					(setq lfinal '())
					;(brkstep '("lretc" "(length lretc)" "lret1" "con1" "lfinal")
					;	"1" "MATCONECT"
					;)
					(while (< con1 (length lret1))
						(setq lret0 (nth con1 lret1)
							lret0
							(org lret0
								(list 3
									(- (length lret0) 3)
								)
								0
							)
							lret0a (nth 0 lret0)
							lret0b (nth 1 lret0)
							lret0c '()
							con2 0
						)
						;(brkstep '("con2" "lret0" "lret0a" "lret0b" "lret0c")
						;	"2" "MATCONECT"
						;)
						(while
							(< con2 (length lret0b))
							(setq lretco (nth con2 lret0b)
								doins (cdr lretco)
							)
							(setq doinstxt (cortxt doins))
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
							(command "zoom" "c" doinstxt "7")
							(command "donut" 0.0 ppd doins "")
							(setq selepo (ssadd (entlast) selepo))
							(setq lretco1
								(lnpo3
									lretco
									lretc
									(list 1 2)
									1
									0.001
								);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							)
							;(brkstep '("lretco" "lretco1" "selepo") "3" "MATCONECT")
							(cond
								(
									(not (= lretco1 nil))
									(setq
										lretco2 (lss lretco1 1)
									)
									(setq lretco
										(list
											(nth 0 lretco2)
											(nth 1 lretco)
											(nth 2 lretco)
										)
									)
									;(brkstep '("lretco2" "lretco") "3A" "MATCONECT")
								)
							)
							(setq lret0c (append lret0c (list lretco)))
							;(brkstep '("lret0c" "con2" "lretco") "4" "MATCONECT")
							(setq con2 (+ con2 1))
						);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						;(brkstep '("lret0c") "5" "MATCONECT")
						(setq lret0a (append lret0a lret0c)
							lfinal (append lfinal (list lret0a))
							con1 (+ con1 1)
						)
						(command  "zoom" "o" selepo "")
						;(brkstep
						;	'("lret0a"
						;		"lfinal"
						;		"con1"
						;		"(length lfinal)"
						;		"(length lret0a)"
						;	)
						;	"6" "MATCONECT"
						;)
					)
				)
			)
		)
	)
	(command "erase" selepo "")
	(setvar "osmode" mimos)
	(setq lfinal lfinal)
)

;
;;
;;;
;;;;
;;PROYECTO: NV (NOVIDESA)
;;CLASIFICACION: PAN (PANELIZACION)
;;OBJETO: MAT3
;;	> Define una lista de todas las lineas con todas las intersecciones posibles,
;; segun el modo de agregado de conexiones,agrega valor de conexion para cada coordenada.
;; (funciona con dos listas de linas de diferentes pendientes)
;;DEVUELVE: Lista de lineas con intersecciones incluidas
;;	>[(Pendiente Ordenada (#Conect XYIni) (#Conet XYInt) (...)...(#Conect XYFin)) ... (...)]
;;ARGUMENTOS
;;	1.LPEN: Lista de coordenadas agrupadas por pendientes extraidas con MAT1 con el formato:
;;	> [ ( ( Pendiente1 Oredada ID (XYinicial) (XYFinal) ) (...))
;;		( ( Pendiente2 Oredada ID (XYinicial) (XYFinal) ) (...))...]
;; 2.MIMO: Modo de valor de conexiones:
;;	>	0: Valor de conexiones en 0
;;	>	1: Valor de conexiones reales
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>PR...
(defun mat3
	(lpen mimo /
		con2 con1 pmas pmenos pimenos pimas coo tip
		pg pg1 pgf coo1 tx1 msj1 mimos primas primenos matprec
	 )
	;(setq con2 nil con1 nil pmas nil pmenos nil pimas nil pimenos nil
	;	primas nil primenos nil coo nil tip nil pg nil pg1 nil pgf nil coo1 nil
	;	tx1 nil msj1 nil mimos nil matprec nil
	;)
	;(brkstep
	;	'("lpen" "(length (nth 0 lpen))" "(length (nth 1 lpen))" "mimo")
	;	"00" "MAT3"
	;)
	(setq mimos (getvar "osmode"))
	(setvar "osmode" 0)
	(cond
		(
			(and 
				(not (= lpen nil))
				(= (type lpen) 'LIST)
				(= (length lpen) 2)
			)
			(setq matprec (getvar "luprec" ))
			(setvar "luprec" 8)
			(setq lpen
				(list
					(corden (nth 0 lpen) 0 4)
					(corden (nth 1 lpen) 0 4)
				)
			)
			;(brkstep '("(length (nth 0 lpen))" "(length (nth 1 lpen))")
			;	"00a" "PANEW"
			;)
			(cond
				(
					(not (equal (nthx '(0 0) (nth 1 lpen)) "nop"))
					(cond
						(
							(or
								(< 0 (nthx '(0 0) (nth 1 lpen)))
								(equal (nthx '(0 0) (nth 1 lpen)) 0 0.0001)
							)
							(setq lpen
								(list (nth 1 lpen)
									(nth 0 lpen)
								)
							)
						)
					)
				)
			)
			;(brkstep '("(nth 0 (nth 0 (nth 0 lpen)))") "01" "MAT3")
			(cond
				(
					(= (numberp (nth 0 (nth 0 (nth 0 lpen)))) nil)
					(setq pmenos (nth 0 lpen)
						pmas (nth 1 lpen)
					)
				)
				(
					(= (numberp (nth 0 (nth 0 (nth 0 lpen)))) t)
					(cond
						(
							(< (nth 0 (nth 0 (nth 0 lpen))) 0)
							(setq pmenos (nth 0 lpen)
								pmas (nth 1 lpen)
							)
						)
						(
							(<= 0 (nth 0 (nth 0 (nth 0 lpen))))
							(setq pmas (nth 0 lpen)
								pmenos (nth 1 lpen)
							)
						)
					)
				)
			)
			;(brkstep '("pmenos" "pmas") "1" "MAT3: lista de pendientes")
			(setq pimenos (mat2 pmenos pmas '(3 4) 4))
			(setq pimas (mat2 pmas pmenos '(3 4) 4))
			;(brkstep
			;	'("pimas" "(length pimas)"
			;		"pimenos" "(length pimenos)"
			;	)
			;	"XX" "MAT3"
			;)
			(setq pimenos (corden pimenos 0 4))
			;(cam1 (noment psmenos)'(0 . "psmenos"))
			(setq pimas (corden pimas 0 4))
			;(cam1 (noment psmas) '(0 . "psmas"))
			;(brkstep '("pimas" "pimenos") "XXX" "MAT3")
			(setq primas pimas primenos pimenos)
			(setq pg pimas)
			(cond
				(
					(= mimo 1)
					(setq tip
						(list 1 3 2)
					)
				)
				(
					(= mimo 0)
					(setq tip
						(list 0 0 0)
					)
				)
			)
			;(brkstep 
			;	'("pg" "(length pg)"
			;		"pimas" "(length pimas)"
			;		"pimenos" "(length pimenos)"
			;		"tip"
			;	)
			;	"2" "MAT3"
			;)
			(repeat
				2
				;(brkstep '("pg" "pimas" "pimenos" "tip") "2a" "MAT3")
				(setq con1 0)
				(while
					(< con1 (length pg))
					(setq pg1 (nth con1 pg)
						coo (org pg1 (list 3 (- (length pg1) 3)) 0)
					)
					;(brkstep '("pg1" "coo" "con1") "2a1" "MAT3")
					(setq coo (nth 1 coo))
					;(brkstep '("(nth 0 pg1)" "coo" "pg1" "con1") "2b" "MAT3")
					(cond
						(
							(= (nth 0 pg1) "nop")
							(setq coo (orden4 coo 0 1 5))
						)
						(
							(= (numberp (nth 0 pg1)) t)
							(cond;;;;;;;;;;;;;;;;;;;reparacion de orden
								(
									(<= 0 (nth 0 pg1))
									(setq coo (orden4 coo 0 0 5))
								)
								(
									(< (nth 0 pg1) 0)
									(setq coo (orden4 coo 1 0 5))
								)
							)
						)
					)
					(setq coo (lva0 coo () 0 5))
					;(brkstep '("coo") "3C" "MAT3")
					(setq con2 1
						coo1 nil
					)
					(setq coo1
						(append coo1
							(list
								(append
									(list (nth 0 tip))
									(nth 0 coo)
								)
							)
						)
					)
					;(brkstep '("coo1" "pg1" "coo" "con2") "3" "MAT3")
					(while
						(< con2 (- (length coo) 1))
						(setq coo1
							(append coo1
								(list
									(append
										(list (nth 1 tip))
										(nth con2 coo)
									)
								)
							)
						)
						(setq con2 (+ con2 1))
						;(brkstep '("coo1" "con2") "4" "MAT3")
					)
					(setq coo1
						(append coo1
							(list
								(append
									(list (nth 2 tip))
									(nth con2 coo)
								)
							)
						)
					)
					(setq pg1
						(append
							(ert pg1 '(0 1 2))
							coo1
						)
					)
					(setq pgf
						(append pgf
							(list pg1)
						)
					)
					;(brkstep '("pg" "coo1" "pgf" "con1") "5" "MAT3")
					(setq con1 (+ con1 1))
				)
				(setq pg pimenos)
				(setq tx1 "Grupo 2")
				;(brkstep '("mimo") "5A" "MAT3")
				(cond
					(
						(= mimo 1)
						(setq tip (list 4 12 8))
					)
					(
						(= mimo 0)
						(setq tip (list 0 0 0))
					)
				)
				;(brkstep '("pg" "pgf" "tip") "6" "MAT3")
			)
		)
	)
	;(brkstep '("pgf") "7" "MAT3")
	(setvar "osmode" mimos)
	(setvar "luprec" matprec)
	(setq pgf pgf)
)
;
;;
;;;
;;;;************OBJ_LY***********

  ;;;;;;;;;;MODIFICA Y EXTRAE EL VALOR DE UN ELEMENTO INDICADO EN DATOS DE MANIPULACIÓN;;;;;;;;;;;;;;;;;;
  ;;PR...

  ;;;;;;Programa
;;; CARGA DE OBJETOS
;;; Elimina las listas que en su primer elemento contengan "non"
;;PR...
(defun lec (mod mi / miru dat1 long1 con1 pas3 fdat)
	;(brkstep '("mod" "mi") "LEC" "00")
  (cond (
	 (= mi nil)
	 (setq miru (ruta "csv" "DE LECTURA")
	       )
	 )
	(
	 (not (= mi nil))
	 (setq miru mi)
	 )
	)
  (setq
    dat1 (dat miru)
    long1 (length dat1)
    con1 1
    pas3 0
    )
	 ;(brkstep '("dat1") "01" "lec")
  (cond (
	 (not (= dat1 nil))
	 (while (<= con1 long1)
	   (setq dat2 (exl dat1 con1 mod)
		 )
	   (cond (
		  (= pas3 0)
		  (setq fdat (list dat2)
			pas3 1)
		  )
		 (
		  (= pas3 1)
		  (setq fdat (append fdat (list dat2))
			)
		  )
		 )
	   (setq con1 (+ con1 1))
	   )
		(setq fdat (lnpo2 "non" fdat 0 0 0.001))
		;(brkstep '("fdat") "01" "lec")
	 )
	)
  (setq fdat fdat)
  )
  ;
  ;;
  ;;;
  ;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Seleccion de entidades comunes existentes
;;PR....
(defun elem (sele cod / con1 lcod lcod1 fcod pas3 fcod1)
  (setq pas3 0
       con1 0
	sel sele
       )
  (while (and (< con1 (sslength sel))
	      (not (= sel nil))
	      )
    (setq lcod (cdr (assoc cod (entget (ssname sel con1))))
	  )
  (ssdel (ssname sel con1) sel)
    (cond
      (
       (= pas3 0)
       (setq fcod (list lcod)
	     pas3 1)
       )
      (
       (not
	 (= pas3 0)
	 )
       (setq fcod (append fcod (list lcod)))
       )
      )
    (while (and
	     (< con1 (sslength sel))
	     (not (= sel nil))
	     )
      (setq lcod1 (cdr (assoc cod (entget (ssname sel con1))))
	    )
      (cond
	(
	 (equal lcod lcod1)
	 (ssdel (ssname sel con1) sel)
	 )
	(
	 (not (equal lcod lcod1))
	 (setq con1 (+ con1 1)
	       )
	 )
	)
      )
    (setq con1 0)
    )
  (setq fcod1 fcod)
  )
  ;;
  ;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; COMPA.-    Compara una cadena de texto contra una lista de cadena de texto
;; SYNTAXIS.-  (compa texto lista)
;;PR...
(defun compa (str ltt / conn pasi pq)
  (setq pasi 0
	conn 0
	)
  (while (< conn (length ltt))
    (cond
      (
       (= (strcase str) (strcase (nth conn ltt)))
       (setq conn (length ltt)
	     pasi 1)
       )
      (
       (not (= (strcase str) (strcase (nth conn ltt))))
       (setq conn (+ conn 1))
       )
      )
    )
  (cond (
	 (= pasi 0)
	 (setq pq nil)
	 )
	(
	 (= pasi 1)
	 (setq pq t)
	 )
	)
  )
;
;;;
;;;;;
;;;;;;; FUNCION LTI CREA LISTA DE ENTIDADES APARTIR DE UN PAR COMUN DE UNA SELECCION TOMADA
;;;;;;;; AGRUMENTOS: PAR- (par punteado)
;;;;;;;;;;;;;;;;;;;; LTS- SELECCION
;;PR...
(defun lti (par lts / con1 pass)
  (setq con1 0
	pass 0
	)
  (cond
    (
     (= lts nil)
     (alert "ESTA SELECCION NO TIENE ENTIDADES")
     )
    (
     (not
       (= lts nil))
     (while (< con1 (sslength lts))
       (setq lem (ssname lts con1)
	     )
       (cond (
	      (equal (assoc (car par) (entget lem))
		 par)
	      (cond
		(
		 (= pass 0)
		 (setq pass 1
		       flst (list lem)
		       )
		 )
		(
		 (= pass 1)
		 (setq flst (append flst (list lem)))
		)
	      )
	     )
	     )
       (setq con1 (+ con1 1))
       )
     )
    )
  (setq flst flst)
  )
  ;
  ;;;
  ;;;;
  ;;;;;;;;  FUNCION CAMB.- REDIDUJA UNA LISTA DE NOMBRES DE ENTIDADES EN EL MODO INDICADO
;;;;;; ARGUMENTOS: LISTA DE NOMBRES /  MODO
;;;;;;;;;; SYNTAXIS: (CAMB LISTA MODO)
;;;;; HEREDADO DE FUNCION LTI
;; Modo igual a la funcion redraw
;; Modo 1 Enseña las entidades
;;	Modo 2 Oculta las entidades
;;	Modo 3 Marca entidades como seleccionadas
;;	Modo 4 Marca entidades como no seleccionadas.
;;PR...
(defun camb (lft mod / con1 nom)
  (setq con1 0)
  (cond (
	 (not
	   (= lft nil))
	 (while (< con1 (length lft))
	   (redraw (nth con1 lft) mod)
	   (setq con1 (+ con1 1))
	   )
	 )
	(
	 (= lft nil)
	 (alert "LISTA NO VALIDA")
	 )
	)
  )
  ;
  ;;
  ;;;;
  ;;;;;;;;;;;;;verificación de archivo existente
  ;;PR...
(defun archi (rta ext / ar)
  (setq ar (getfiled "SELECCION DE ARCHIVO PREDETERMINADO" rta ext 32)
	arop (open ar "r")
	pass 0
	)
  (cond (
	 (not (= arop nil))
	 (close arop)
	 (setq pass 1)
	 )
	(
	 (= arop nil)
	 (setq pass 0)
	)
	)
  (cond (
	 (= pass 0)
	 (setq pass nil)
	 )
	(
	 (= pass 1)
	 (close arop)
	 (setq pass t)
	 )
	)
  )
;
;;
;;;;
;;;;;;;;;;;;;;;Obtiene lista de nombres de entidades no graficas segun lista de textos y caracteristica
;;;;;o crea lista de entidades no gráficas no existentes
;;PR...
(defun onam ( ltxt cca mod / con passe ele eln elf)
  (setq con 0 
	passe 0
	)
  (while (< con (length ltxt))
    (setq ele (nth con ltxt)
	  eln (tblobjname cca ele)
	  )
    (cond (
	   (and (= mod 0)
		(= eln nil)
		)
	   (cond (
		  (= passe 0)
		  (setq elf (list ele)
			passe 1)
		  )
		 (
		  (= passe 1)
		  (setq elf (append elf (list ele))
			)
		  )
		 )
	   )
	  (
	   (and (= mod 1)
		(not (= eln nil))
		)
	   (cond
	     (
	      (= passe 0)
	      (setq elf (list (cons ele eln))
		    passe 1)
	      )
	     (
	      (= passe 1)
	      (setq elf (append elf (list (cons ele eln)))
		    )
	      )
	     )
	   )
	  )
    (setq con (+ con 1))
    )
  (setq elf elf)
  )
  ;
  ;;
  ;;;
  ;
  ;;
  ;;;
  ;;; Funcion vly: Vacia las caracteristicas de layers
;;; argumentos lista de nombres
;;; lista de caracteristicas
;;PR...
(defun vly (lscr lsnm / con minb lcr cl tl lw pl vs tl1)
  (setq con 0)
  (while (< con (length lsnm))
    (cond
      (
       (= (compa (nth 0 (nth con lsnm)) (lss lscr 1)) t)
       (setq minb (list (cdr (nth con lsnm)))
	     lcr (nth 0 (exid lscr (nth 0 (nth con lsnm))))
	     cl (cons 62 (nth 1 lcr))
	     tl (cons 6 (nth 2 lcr))
	     lw (cons 370 (nth 3 lcr))
	     pl (cons 290 (nth 4 lcr))
	     vs (cons 70 (nth 5 lcr))
	     tl1 (cdr tl)
	     )
       (command "linetype" "load" tl1 "" "" "")
       (cam1 minb cl)
       (cam1 minb tl)
       (cam1 minb lw)
       (cam1 minb pl)
       (cam1 minb vs)
       )
      ;y si no?!
      )
    (setq con (+ con 1))
    )
  )
  ;
  ;;
  ;;;
  ;;;;
  ;;;;Función, obtiene todos los elementos que coincidan con un id (assoc) apartir de una lista
;;;estructurada o una lista de par punteado modo 0=Lista estructurada solo para Autocad
;;PR...
(defun exid1 (les eid / mod con1 con2 pas1 pas2 elc finl)
  (setq con1 0
	pas1 0
	finl nil
	mod nil
	)
  (while (< con1 (length les))
    (setq elc (nth con1 les)
	  con2 0
	  pas2 0)
    (cond
      (
       (= (vl-list-length elc) nil)
       (setq mod 1)
       )
      (
       (not (= (vl-list-length elc) nil))
       (setq mod 0)
       )
      )
    (cond (
	   (= mod 0)
	   (while (< con2 (length elc))
	     (cond (
		    (= (nth con2 elc) eid)
		    (setq con2 (length elc)
			  pas2 1
			  )
		    )
		   (
		    (not (= (nth con2 elc) eid))
		    (setq con2 (+ con2 1))
		    )
		   )
	     )
	   )
	  (
	   (= mod 1)
	   (cond
	     (
	      (= (cdr elc) eid)
	      (setq pas2 1
		    )
	      )
	     
	     )
	   )
	  )
    (cond
      (
       (= pas2 1)
       (cond
	 (
	  (= pas1 0)
	  (setq finl (list elc)
		pas1 1)
	  )
	 (
	  (= pas1 1)
	  (setq finl (append finl (list elc)))
	  )
	 )
       )
      )
    (setq con1 (+ con1 1))
    )
  (setq finl finl)
  )
  ;
  ;;
  ;;;
  ;;;;
  ;;;;;;;;;;;;,nxx obtiene lista de estructurada de valores segun
;;;LISTA DE CODIGOS de todos los atributos existentes en un block
;;;; (<nombre> (par 1) (par 2) (par...)) ((...) (...)))
;;;; ARGUMENTOS:
;;;NB= nombre de atributo
;;;LS= lista de codigos
;;PR...
(defun nxx (nb ls / lsf lfin cnt nb1 pss)
  (setq lsf (list nb)
	nb1 nb
	pss 0
	)
  (while
    (not (= nb1 nil))
    (setq nb1 (entnext nb1))
    (cond (
	   (not (= nb1 nil))
	   (cond
	     (
	      (= (cdr (assoc 0 (entget nb1))) "SEQEND")
	      (setq nb1 nil)
	      )
	     )
	   )
	  )
    (cond (
	   (not (= nb1 nil))
	   (cond
	     (
	      (= (cdr (assoc 0 (entget nb1))) "ATTRIB")
	      (setq cnt 0
		    lsf (list nb1)
		    )
	      (while (< cnt (length ls))
		(setq lsf (append lsf (list (assoc (nth cnt ls) (entget nb1))))
		      cnt (+ cnt 1)
		      )
		)
	      (cond (
		  (= pss 0)
		  (setq lfin (list lsf)
			pss 1)
		  )
		 (
		  (= pss 1)
		  (setq lfin (append lfin (list lsf)))
		  )
		 )
	      )
	     )
	   
	   )
	  )
    
    )
  (setq lfin lfin)
  )

  ;
  ;;
  ;;;;
  ;;;lyx DEVUELVE LISTA DE TEXTOS CON LAYER EXISTENTES
  ;;PR...
(defun lyx (/ ly ly1 pss)
  (tblnext "layer" "0")
  (setq ly1 0
	pss 0)
  (while (not (= ly1 nil))
    (setq ly1 (cdr (assoc 2 (tblnext "layer"))))
    (cond (
	   (and (= pss 0)
		(not (= ly1 nil))
		  )
	   (setq ly (list ly1)
		 pss 1)
	   )
	  (
	   (and 
		 (= pss 1)
		  (not (= ly1 nil))
		  )
	   (setq ly (append ly (list ly1)
			    )
		 )
	   )
	  )
    )
  (setq ly ly)
  )
  ;
  ;;
  ;;;
  ;;;;
;;;;ACC ACUALIZA COTAS Y TEXTOS
;;ARGUMENTOS SAC= ESCALA
;;;          DM= MODO
;;1= COTAS_P
;;;2= COTAS_C
;;; 3= AREAS TXT
;;;4=ANOTACION TXT
;;; 5 =TITULOS TXT
;;PR...
(defun acc (sac dm / psl ssl mis1 rtt ess ssc mis f1 ve)
	(setq rtt (impdat "rutas.csv" "ESTILOS" "RUTA" "ESTILO.dwg")
		psl (cons 2 (strcat "ESTILO_" (rtos sac 2 0)))
		psl (list '(-4 . "<and") '(0 . "insert") psl '(-4 . "and>"))
	)
  (command "insert" rtt "0,0" "" "" "")
  (setq ssl (ssget "x" psl))
  (command "erase" ssl "")
  (setq rryr (impdat "rutas.csv" "ESTILOS" "RUTA" "ESTILO.csv"))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;objeto de ruta;;;;;;;;;;;;;;;;;;;;;;;;;;
	(setq ess (lec 2 rryr)
		ess (nth 0 (exid ess sac))
	)	
  (cond
    (
     (= dm 1)
     (setq f1 (onam (list (nth 16 ess)) "dimstyle" 1)
	   )
     (cam1 (list (cdr (nth 0 f1)))
	   (cons 40 (nth 1 ess))
	   )
     (command "dimoverride" "c" "all" "")
     (command "dimstyle" "r" (nth 16 ess) "")
     (setq tal (strcat "SELECCIONA LAS COTAS DE ESTILO " (nth 16 ess)))
     (alert tal)
     (setq coss (ssget '((0 . "DIMENSION"))))
     (command "dim" "update" coss "" "exit")
     )
    (
     (= dm 2)
     (setq f1 (onam (list (nth 14 ess)) "dimstyle" 1)
	   )
     (cam1 (list (cdr (nth 0 f1)))
	   (cons 40 (nth 1 ess))
	   )
     (command "dimoverride" "c" "all" "")
     (command "dimstyle" "r" (nth 14 ess) "")
     (setq tal (strcat "SELECCIONA LAS COTAS DE ESTILO " (nth 14 ess)))
     (alert tal)
     (setq coss (ssget '((0 . "DIMENSION"))))
     (command "dim" "update" coss "" "exit")
     )
    (
     (= dm 3)
     (setq f1 (onam (list (nth 5 ess)) "style" 1)
	   )
     (cam1 (list (cdr (nth 0 f1)))
	   (cons 40 (nth 6 ess))
	   )
     (cam1 (list (cdr (nth 0 f1)))
	   (cons 41 (nth 7 ess))
	   )
     (alert "SELECCIONA LOS TEXTOS DEL ESTILO AREAS")
     (setq mis (ssget '((0 . "TEXT")))
	   mis1 (lti (cons 0 "TEXT") mis)
	   )
     (cam1 mis1 (cons 7 (nth 5 ess)))
     (cam1 mis1 (cons 40 (nth 6 ess)))
     (cam1 mis1 (cons 41 (nth 7 ess)))
     )
    (
     (= dm 4)
     (setq f1 (onam (list (nth 2 ess)) "style" 1)
	   )
     (cam1 (list (cdr (nth 0 f1)))
	   (cons 40 (nth 3 ess))
	   )
     (cam1 (list (cdr (nth 0 f1)))
	   (cons 41 (nth 4 ess))
	   )
     (alert "SELECCIONA LOS TEXTOS DEL ESTILO ANOTACION")
     (setq mis (ssget '((0 . "TEXT")))
	   mis1 (lti (cons 0 "TEXT") mis)
	   )
     (cam1 mis1 (cons 7 (nth 2 ess)))
     (cam1 mis1 (cons 40 (nth 3 ess)))
     (cam1 mis1 (cons 41 (nth 4 ess)))
     )
    (
     (= dm 5)
     (setq f1 (onam (list (nth 11 ess)) "style" 1)
	   )
     (cam1 (list (cdr (nth 0 f1)))
	   (cons 40 (nth 12 ess))
	   )
     (cam1 (list (cdr (nth 0 f1)))
	   (cons 41 (nth 13 ess))
	   )
     (alert "SELECCIONA LOS TEXTOS DEL ESTILO TITULO")
     (setq mis (ssget '((0 . "TEXT")))
	   mis1 (lti (cons 0 "TEXT") mis)
	   )
     (cam1 mis1 (cons 7 (nth 11 ess)))
     (cam1 mis1 (cons 40 (nth 12 ess)))
     (cam1 mis1 (cons 41 (nth 13 ess)))
     )
    )
  )
  ;
  ;;
  ;;;;
  ;;PR...
 
  ;
  ;;
  ;;;;
  ;;;;;;
  ;;;;;;;;;****************TERMINA OBJETOS O *******************************
  ;;;;;;;;;*****************************************************************
;;PROYECTO: NOVIDESA (NV)
;;CLASIFICACION: PANELIZACION (PAN)
;;OBJETO: PANEL1
;;	>A partir de la matriz principal de coordenadas con valores totales
;;	de conexion, define las coordenadas (4) del rectangulo mas cercano a
;;	ls posicion definida en el argumento.
;;DEVUELVE: Lista de coordenadas de rectangulos de la red agrupada por renglones
;;	>( {{ [ (xy1) (xy2) (xy3) (xy4) ] [...] } {...} ...)
;;ARGUMENTOS
;;	1.MTZ2: Lista de coordenadas en matriz cuadrada con valores
;;	totales de conexion, en orden ascendente en ambas direciones
;;	> [ ( (val xy) (...) ...) (...) ...]
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun panel1 
	(mtz2 / 
		posi2 posi3
		past pto lsd ptove
		llc llc1 llc2
		past2 pol pol1
	)
	(setq pol (ssadd))
	(setq pol1 (ssadd))
	;(brkstep '("MTZ2" "(length mtz2)") "ENTRADA: 00" "PANEL1" )
	(cond	
		(
			(not (= mtz2 nil))
			(cond
				(
					(< 1 (length mtz2))
					(setq posi2 (list 0 0))
					(while
						(< (nth 0 posi2) (length mtz2))
						(setq posi2 (list (nth 0 posi2) 0)
							llc1 nil
							past 5
						)
						;(brkstep
						;	'("posi2" "llc2" "(length mtz2)" "past" "past2")
						;	"1" "PANEL1"
						;)
						(while
							(and
								(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
								(= past 5)
							)
							;(brkstep '("posi2" "llc1") "2" "PANEL1")
							(setq past 0
								lsd (list 5 7 13 15)
								posi3 nil
								past2 0
								llc nil
							);;;;;;;;;;;;;;;;;;COMIENZA PUNTO1
							;(brkstep
							;	'("past" "lsd" "posi2" "posi3" "past2" "llc")
							;	"3" "PANEL1"
							;)
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2));;;;;Cambio
										(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									)
									(setq past 1)
									;(brkstep
									;	'("past"
									;		"(length mtz2)"
									;		"(length (nth (nth 0 posi2) mtz2))"
									;	)
									;	"3A"
									;	"PANEL1"
									;)
								)
							)
							(while
								(and
									(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									(= past 1)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;(brkstep '("pto" "ptove" "posi2") "4" "PANEL1")
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(cond
									;(
									;	(< 19 (nth 0 posi2))
									;	(brkstep '("pto" "ptove" "posi2" "lsd") "XX" "TARGET")
									;)
								)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(command "zoom" "c" (cdr pto) 7)
								(command "donut" 0.0 0.30 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto" "ptove" "posi2" "lsd"
								;				"(not (= ptove nil))"
								;			) 
								;		"XX2" "TARGET2")
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										;(cond
										;	(
										;		(< 19 (nth 0 posi2))
										;		(brkstep
										;			'("pto" "ptove"
										;				"posi2" "lsd" "llc"
										;				"past2"
										;				"(length (nth (nth 0 posi2) mtz2))"
										;				"past"
										;			)
										;			"XX3"
										;			"TARGET3"
										;		)
										;	)
										;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										;(brkstep '("past" "llc" "past2") "4A" "PANEL1")
									)
									(
										(= ptove nil)
										(setq posi2 (list (nth 0 posi2) (+ (nth 1 posi2) 1)))
										;(brkstep '("posi2") "4B" "PANEL1")
									)
								)
							);;;;;;;;;;;;;;;;;;;;;;;TERMINA PUNTO 1
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto"
								;				"ptove"
								;				"posi2"
								;				"lsd"
								;				"llc"
								;				"past"
								;				"past2"
								;				"(< (nth 1 posi2)
								;					(length (nth (nth 0 posi2) mtz2))
								;				)"
								;			)
								;			"XX4" "TARGET4"
								;		)
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							(setq lsd (list 6 7 14 15));;;;;;;;;;;;;COMIENZA PUNTO2
							;(brkstep '("lsd" "past" "past2") "5" "PANEL1")
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2));;CAMBIO(2)
										(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)));;
										(= past2 1)
									)
									(setq posi2
										(list
											(nth 0 posi2)
											(+ (nth 1 posi2) 1)
										)
										past 2
									)
								)
							)
							;(brkstep
							;	'("posi2"
							;		"past"
							;		"(length mtz2)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;	)
							;	"6" "PANEL1"
							;)
							(while
								(and
									(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									(= past 2)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(command "zoom" "c" (cdr pto) 7)
								(command "donut" 0.0 0.30 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto" "ptove" "posi2" "lsd"
								;				"(not (= ptove nil))"
								;			) 
								;		"XX5" "TARGET5")
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(brkstep '("pto" "ptove" "posi2") "7" "PANEL1")
								(cond
									(
										(not (= ptove nil))
										(setq posi3 posi2
											past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep
										;	'("past" "llc" "posi2" "posi3" "past2")
										;	"7A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 10)
												(setq posi3 posi2
													past2 5
													past 0
												)
												;(brkstep '("posi3" "past2" "past")
												;	"7B"
												;	"PANEL1"
												;)
											)
											(
												(not (= (nth 0 pto) 10))
												(setq posi2
													(list
														(nth 0 posi2)
														(+ (nth 1 posi2) 1)
													)
												)
												;(brkstep '("posi2") "7C" "PANEL1")
											)
										)
									)
								)
							)
							(setq lsd (list 10 11 14 15))
							;(brkstep '("lsd" "past2") "8" "PANEL1")
							(cond
								(
									(and
										(< 0 (nth 1 posi2))
										(< (nth 0 posi2) (length mtz2));;CAMBIO(3)
										(= past2 2)
									)
									(setq posi2 (list (+ (nth 0  posi2) 1) (nth 1 posi2))
										past 3
									)
								)
							)
							;(brkstep
							;	'("past"
							;		"(length mtz2)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;		"posi2"
							;	)
							;	"9"
							;	"PANEL1"
							;)
							(while
								(and
									(< (nth 0 posi2) (length mtz2))
									(= past 3)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(command "zoom" "c" (cdr pto) 7)
								(command "donut" 0.0 0.30 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(brkstep '("pto" "ptove" "posi2") "10" "PANEL1")
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep 
										;	'("past" "llc" "posi2" "past2")
										;	"10A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 9)
												(setq past 0
													past2 5
												)
												;(brkstep '("past2" "past") "10B" "PANEL1")
											)
											(
												(not (= (nth 0 pto) 9))
												(setq posi2
													(list (+ (nth 0 posi2) 1)
														(nth 1 posi2)
													)
												)
												;(brkstep '("posi2") "10C" "PANEL1")
											)
										)
									)
								)
							)
							(setq lsd (list 9 11 13 15))
							;(brkstep '("lsd" "past2") "11" "lsd")
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2))
										(<= 0 (nth 1 posi2))
										(= past2 3)
									)
									(setq posi2
										(list
											(nth 0 posi2)
											(- (nth 1 posi2) 1)
										)
									)
									(setq past 4)
								)
							)
							;(brkstep
							;	'("past"
							;		"(length mtz)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;		"posi2"
							;	)
							;	"12"
							;	"PANEL1"
							;)
							(while
								(and
									(<= 0 (nth 1 posi2))
									(= past 4)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;(brkstep '("pto" "ptove" "posi2") "13" "PANEL1")
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(command "zoom" "c" (cdr pto) 7)
								(command "donut" 0.0 0.30 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep
										;	'("past" "llc" "posi3" "past2")
										;	"13A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 5)
												(setq past 0
													past2 5
												)
												;(brkstep '("past" "past2")
												;	"13B" "PANEL1"
												;)
											)
											(
												(not (= (nth 0 pto) 5))
												(setq posi2
													(list
														(nth 0 posi2)
														(- (nth 1 posi2) 1)
													)
												)
												;(brkstep '("posi2") "13C" "PANEL1")
											)
										)
									)
								)
							)
							(cond
								(
									(and
										(not (= posi3 nil))
										(< 1 past2)
									)
									(setq past 5
										posi2 posi3
									)
								)
							)
							;(brkstep '("posi2" "past") "14" "PANEL1")
							(cond
								(
									(and
										(= (length llc) 4)
										(= past2 4)
									)
									(setq llc1 (append llc1 (list llc)))
									(command "pline"
										(nth 0 llc)
										(nth 1 llc)
										(nth 2 llc)
										(nth 3 llc)
										"c"
									)
									(setq pol1 (ssadd (entlast) pol1))
									(command "zoom" "o" pol1 "");;;;;;;;;;;;;;;;;;;;;;;;
								)
							);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							;(brkstep '("llc1" "llc" "(sslength pol)" "past2") "15" "PANEL1")
							(cond
								(
									(= past2 0)
									(setq posi2
										(list
											(nth 0 posi2)
											(length (nth (nth 0 posi2) mtz2))
										)
									)
								)
							)
							;(brkstep '("posi2" "past2") "16" "PANEL1")
						)
						;(brkstep '("llc1") "17" "PANEL1")
						(setq posi2 (list (+ (nth 0 posi2) 1) (nth 1 posi2)))
						(cond
							(
								(not (= llc1 nil))
								(setq llc2 (append llc2 (list llc1)))
							)
						)
						;(brkstep '("llc2" "posi2" "(length llc2)") "18" "PANEL1")
					)
					(command "erase" pol "")
					(command "zoom" "o" pol1 "")
				)
			)
		)
	)
	;(brkstep '("llc2") "19" "PANEL1")
	(setq llc2 llc2)
)
;
;;
;;;
;;;;
;;;;;

;;PROYECTO: Lisp
;;CLASIFICACION:TBL
;;OBJETO:QNTH1
;;	>Devuelve las posiciones (en una lista de segundo nivel)
;;	de un elemento definido en el argumento.
;;DEVUELVE: lista de lista de posiciones en las que se 
;;	encuentra el elemento indicado con la siguiente estructura
;;	> ( (PosicionVertical (PosicionHorizontal ...)) (...) ,,,)
;;ARGUMENTOS
;;	1.Ql: Lista de trabajo; donde se va a buscar el elemento
;;	> ( (XXX XX …) (…) …)
;;	2.QE: Elemento de busqueda
;;	> Cualquier elemento
;;	3.QP: Define la tolerancia de comparacion numerica
;;	>Numero real
;;DEPENDIENTES
;;	>QNTH
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;**************************************************
(defun qnth1 (ql qe qp / con1 phz pf)
	;(brkstep '("ql" "qe" "qp") "00; ENTRADA" "QNTH1")
	(cond
		(
			(and
				(= (type ql) 'LIST)
				(= (type qp) 'REAL)
			)
			(cond
				(
					(= (type (nth 0 ql)) 'LIST)
					(setq con1 0)
					(while (< con1 (length ql))
						(setq phz
							(qnth 
								(nth con1 ql)
								qe
								qp
							)
						)
						(cond
							(
								(not (= phz nil))
								(setq pf
									(append
										pf
										(list
											(list
												con1
												phz
											)
										)
									)
								)
							)
						)
						(setq con1 (+ con1 1))
						;(brkstep '("pf" "phz" "con1") "0" "QNTH1")
					)
					;(brkstep '("pf") "01" "QNTH1")
				)
			)
		)
	)
	(setq pf pf)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:TBL2
;;OBJETO:QNTH2
;;	>A partir de la definicion del valor indice
;;	horizontal y el valor indice vertical, extrae
;;	el valor indicado de una lista tipo tabla
;;	( estructurada )
;;	DEVUELVE: Valor que coincida con el valor
;;	horizontal y vertical
;;ARGUMENTOS
;;	1. TBL: lista estruturada (tipo tabla)
;;	> ( ( X X …) (…) …)
;;	2.VALHZ: Valor buscado en renglones
;;	> XX
;;	3. VALVER: Valor buscado en columnas
;;	4. POS: Valor de tolerancia numerica
;;	> Numero real
;;DEPENDIENTES
;;	>QNTH; QNTH1
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;**************************************************
(defun qnth2 (tbl valhz valver pos / posver poshz valf)
	;(brkstep '("tbl" "valhz" "valver" "pos") "00: ENTRADA" "QNTH2")
	(cond
		(
			(and
				(= (type tbl) 'LIST)
				(= (type pos) 'REAL)
			)
			(cond
				(
					(= (type (nth 0 tbl)) 'LIST)
					(setq posver (qnth1 tbl valver pos))
					;(brkstep '("posver") "01" "QNTH2")
					(setq posver (nthx '(0 1 0) posver))
					;(brkstep '("posver") "02" "QNTH2")
					(setq poshz (qnth1 tbl valhz pos))
					;(brkstep '("poshz") "03" "QNTH2")
					(setq poshz (nthx '(0 0) poshz))
					;(brkstep '("poshz") "04" "QNTH2")
					(setq varf (nthx (list poshz posver) tbl))
				)
			)
		)
	)
	;(brkstep '("varf") "05" "QNTH2")
	(setq varf varf)
	
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:TBL
;;OBJETO:COLUMN
;;	>A partir de la definicion de un valor indice, devuelve las columnas donde
;;	se encuentra.
;; ( (xx) (xx) (xx) (...) ...)
;;DEVUELVE: Lista de columnas que coinciden con el valor indice.
;;	>( (xx) (xx) (xx) (...) ...)
;;ARGUMENTOS
;;	1. LTBL: Lista de trabajo donde se encuentra el valor indice
;;	>( (X X X ..) (...) ...)
;;	2. EL: Elemento indice que se va a buscar
;;	XX 
;;	3. LPR: Presicion
;;	Numero real
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;***********************************************************************************
(defun column (ltbl el lpr / con1 con2 pscol pscol1 col colf cona)
	;(brkstep '("ltbl" "el" "lpr") "00: ENTRADA" "COLUMN")
	(cond
		(
			(and
				(= (type ltbl) 'LIST)
				(= (type lpr) 'REAL)
			)
			(cond
				(
					(= (type (nth 0 ltbl)) 'LIST)
					(setq pscol (qnth1 ltbl el lpr))
					(cond
						(
							(not (= pscol nil))
							(setq pscol (mat5a pscol 1 0))
							(setq cona 0)
							(repeat (length pscol)
								(setq pscol1 (append pscol1 (nth cona pscol)))
								(setq cona (+ cona 1))
							)
							;(brkstep '("PSCOL1") "1" "COLUMN")
							(setq pscol1 (lva pscol1 () 0)
								con1 0
							)
							;(brkstep '("pscol1" "con1") "2" "COLUMN")
							(while (< con1 (length pscol1))
								(setq col (lss ltbl (+ (nth con1 pscol1) 1))
									colf (append colf (list col))
								)
								;(brkstep '("col" "colf") "3" "COLUMN")
								(setq con1 (+ con1 1))
								;(brkstep '("colf" "con1") "4" "COLUMN")
							)
						)
					)
				)
			)
		)
	)
	(setq colf colf)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:TBL
;;OBJETO:ROW; A partir de la definicion de un valor indice devuelve
;;	la(s) fila(s) donde se encuentra dicho elemento
;;	> ( (X X …) (…) …)
;;DEVUELVE: Lista de las filas que contienen el elemento indice
;;	>( (xx) (xx) (xx) (...) ...)
;;ARGUMENTOS
;;	1. LTBL: Lista de trabajo donde se encuentra el valor indice
;;	>( (X X X ..) (...) ...)
;;	2. EL: Elemento indice que se va a buscar
;;	XX 
;;	3. LPR: Presicion
;;	Numero real
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;***********************************************************************************
(defun row (ltbl el lpr / con1 pscol colf)
	;(brkstep '("ltbl" "el" "lpr") "00: ENTRADA" "ROW")
	(cond
		(
			(and
				(= (type ltbl) 'LIST)
				(= (type lpr) 'REAL)
			)
			(cond
				(
					(= (type (nth 0 ltbl)) 'LIST)
					(setq pscol (qnth1 ltbl el lpr))
					;(brkstep '("pscol") "1" "ROW")
					(cond
						(
							(not (= pscol nil))
							(setq pscol (ert1 pscol '(0))
								con1 0
							)
							;(brkstep '("pscol") "2" "ROW")
							(while (< con1 (length pscol))
								(setq colf 
									(append colf
										(list 
											(nth 
												(nthx
													(list con1 0)
													pscol
												)
												ltbl
											)
										)
									)
								)
								(setq con1 (+ con1 1))
								;(brkstep '("colf") "3" "ROW")
							)
						)
					)
				)
			)
		)
	)
	;(brkstep '("colf") "4" "ROW")
	(setq colf colf)
)
;
;;
;;;
;;;;
;;PROYECTO: NV (NOVIDESA)
;;CLASIFICACION: CUAN
;;OBJETO: LBASE
;;	>	A partir  de la recepcion de la tabla de salida de cuantificacion
;;	devuelve la lista de cantidades por detalle y unitaria
;;	(argumentos para la ejecucion).
;;DEVUELVE: Lista de cantidades de cuantificacion
;;	(argumentos de modulos de cuantificacion).
;;	>[ [(material Formula) (Unitaria N) ("D..." N) (...) ...] [...] ]
;;ARGUMENTOS
;;	1.LCUAN: Plantilla de cuantificacion extraida del archivo .csv
;;	> [ ("CLAVE" "FORMULA" "UNITARIA" "D..." "..." ...)
;;	>		(XXCLAVE XXFORMULA NND.. ...)
;;	>		(...)
;;	>		...]
;;DEPENDIENTES
;;	>CUT (); COLUMN (); QNTH2 (); 
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;;;*******************************************************************
(defun lbase (lcuan / lfmat lfcuan lmat ldet con1 con2 m1 ele1 nomf nomcl)
	;(brkstep '("lcuan") "00 ENTRADA" "LBASE")
	(cond
		(
			(not (= lcuan nil))
			(setq nomf (nth 1 (nth 0 lcuan))
				nomcl (nth 0 (nth 0 lcuan))
			)
			(setq ldet
				(cut
					2
					(- (length (nth 0 lcuan)) 1)
					(nth 0 lcuan)
				)
				lmat
				(cdr
					(nth 0
						(column lcuan nomcl 0.001)
					)
				)
			)
			(setq con1 0)
			;(brkstep '("ldet" "lmat" "(length lmat)") "01" "LBASE")
			(while
				(< con1 (length lmat))
				(setq m1 (nth con1 lmat))
				(textscr)
				(princ)
				(prin1)
				(princ (strcat "\n EXTRAYENDO " m1))
				(princ)
				(prin1)
				(setq lfmat
					(list
						(list
							m1
							(qnth2 lcuan m1 nomf 0.001)
						)
					)
					con2 0
				)
				;(brkstep '("m1" "lfmat") "02" "LBASE")
				(while
					(< con2 (length ldet))
					(setq ele1 (nth con2 ldet))
					(graphscr)
					(princ)
					(prin1)
					(princ (strcat "EXTRAYENDO " ele1 " DE " m1))
					(princ)
					(prin1)
					(setq ele1
						(list
							ele1
							(qnth2 lcuan m1 ele1 0.001)
						)
					)
					;(brkstep '("ele1") "03" "LBASE")
					(setq lfmat (append lfmat (list ele1))
						con2 (+ con2 1)
					)
					;(brkstep '("lfmat") "04" "LBASE")
				)
				(setq lfcuan (append lfcuan (list lfmat))
					lfmat nil
					con1 (+ con1 1)
				)
				;(brkstep '("lfcuan" "lfmat" "con1") "05" "LBASE")
			)
		)
	)
	;(brkstep '("lfcuan") "06" "LBASE")
	(setq lfcuan lfcuan)
)

;
;;
;;;
;;;;

;;PROYECTO: Lisp
;;CLASIFICACION: DCL
;;OBJETO: CARGAD; Carga el cuadro de dialogo indicado en el argumento
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. RUDIAL; Ruta y nombre del archivo
;;	>"C:/ ... xx.dcl" (cadena de texto)
;;	2. NOMD; Nombre del cuadro de dialogo
;;	Cadena de texto
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;*****************************************************************
(defun cargad (rudial nomd / numload)
	(setq numload
		(load_dialog rudial)
	)
		(if
			(not (new_dialog nomd numload))
			(exit)
			(setq numload numload)
		)
	;(start_dialog)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: VERE
;;OBJETO: MILNE; Verifica si existe un estilo de multilinea determinado
;;	en caso de no encontrarlo, inserta el block con los estilos de multilinea
;;	>
;;DEVUELVE:
;;	> NIL; En caso de existir el estilo
;;	> ENAME del block (eliminado) que contiene los estilos de multilinea
;;ARGUMENTOS
;;	1. NOMES. Nombre del estilo
;;	> "Nombre" (sin importar mayusculas)
;; 2. NOMBL.  Nombre del block que contenga el estilo de multilineas
;; > "xxx.dwg"
;;	3. NOMRU. Ruta donde se localiza el block de estilo de multilineas
;;	> "c:/xx/xx.."
;;DEPENDIENTES
;;	> EXPAT (); LNPO (); NTHX ();
;;ANOTACIONES
;;	> Junta con STRCAT la ruta y el nombre... cuidar que el ultimo caracter de
;;	la ruta sea diagonal
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun milne (nomes nombl nomru / dicta verem1 verem2 verem4)
	(setq dicta (expat '((3 350)) (entget (namedobjdict))))
	(setq vereml (lnpo '(3 . "ACAD_MLINESTYLE") dicta 1 1)
		verem2 (entget (cdr (nthx '(0 2) vereml)))
	)
	(setq verem3
		(expat '((3 350))
		verem2
		)
	)
	;(brkstep '("verem3") "00" "00")
	(setq verem4
		(lnpo
			(cons
				3
				(strcase nomes)
			)
			verem3
			1
			1
		)
	)
	(if
		(not verem4)
		(progn
			(command "insert"
				(strcat nomru nombl)
				"0,0,0"
				""
				""
				""
			)
			(entdel (entlast))
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: NOVIDESA (NV)
;;CLASIFICACION: PANELIZACION (PAN)
;;OBJETO: PANEL2
;;	>A partir de la matriz principal de coordenadas con valores totales
;;	de conexion, define las coordenadas (4) de cada panel y dibuja la multilinea
;;	correspondiente
;;DEVUELVE: Lista de las 4 coordenadas correspondiente a cada panel
;;	agrupado por renglones
;;	>( ((xy1 xy2 xy3 xy4) (...) ...) (...) )
;;ARGUMENTOS
;;	1.MTZ2: Lista de coordenadas en matriz cuadrada con valores
;;	totales de conexion, en orden ascendente en ambas direcciones
;;	> [ ( (val xy) (...) ...) (...) ...]
;;	2.PPD: Factor de pendiente (base)
;;	> 2 1 0 "nop"
;; 3. SISTE. Sistema constructivo
;;	> 0. IKOS
;;	> 1. MAKROS
;;	> 2. HOLMAK
;;	4. NOMBLK. Nombre del block de estilo de multilinea
;;	> "xxx.dwg"
;;	5. NOMRUT. Nombre de ruta de localizacion
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun panel2
	(mtz2 ppd siste nomblk nomrut / 
		posi2 posi3
		past pto lsd ptove
		llc llc1 llc2 ancho
		past2 pol pol1 sty
		scml scml1 panel ptotxt
	)
	(cond
		(
			(= siste 0)
			(setq sty "Ikos_alz")
		)
		(
			(= siste 1)
			(setq sty "Makros_pl")
		)
		(
			(= siste 2)
			(setq sty "Holmak_alz")
		)
	)
	(milne sty nomblk	nomrut)
	(setq pol (ssadd))
	(setq pol1 (ssadd))
	;(brkstep '("MTZ2" "(length mtz2)") "ENTRADA: 00" "PANEL1" )
	(cond	
		(
			(not (= mtz2 nil))
			(cond
				(
					(< 1 (length mtz2))
					(setq posi2 (list 0 0))
					(while
						(< (nth 0 posi2) (length mtz2))
						(setq posi2 (list (nth 0 posi2) 0)
							llc1 nil
							past 5
						)
						;(brkstep
						;	'("posi2" "llc2" "(length mtz2)" "past" "past2")
						;	"1" "PANEL1"
						;)
						(while
							(and
								(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
								(= past 5)
							)
							;(brkstep '("posi2" "llc1") "2" "PANEL1")
							(setq past 0
								lsd (list 5 7 13 15)
								posi3 nil
								past2 0
								llc nil
							);;;;;;;;;;;;;;;;;;COMIENZA PUNTO1
							;(brkstep
							;	'("past" "lsd" "posi2" "posi3" "past2" "llc")
							;	"3" "PANEL1"
							;)
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2));;;;;Cambio
										(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									)
									(setq past 1)
									;(brkstep
									;	'("past"
									;		"(length mtz2)"
									;		"(length (nth (nth 0 posi2) mtz2))"
									;	)
									;	"3A"
									;	"PANEL1"
									;)
								)
							)
							(while
								(and
									(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									(= past 1)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;(brkstep '("pto" "ptove" "posi2") "4" "PANEL1")
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
									;(
									;	(< 19 (nth 0 posi2))
									;	(brkstep '("pto" "ptove" "posi2" "lsd") "XX" "TARGET")
									;)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(brkstep '("(cortxt (cdr pto))") "00TTEMP" "01TTEMP")
								(setq ptotxt (cortxt (cdr pto)))
								(command "zoom" "c" ptotxt "7")
								(command "donut" 0.0 0.01 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto" "ptove" "posi2" "lsd"
								;				"(not (= ptove nil))"
								;			) 
								;		"XX2" "TARGET2")
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										;(cond
										;	(
										;		(< 19 (nth 0 posi2))
										;		(brkstep
										;			'("pto" "ptove"
										;				"posi2" "lsd" "llc"
										;				"past2"
										;				"(length (nth (nth 0 posi2) mtz2))"
										;				"past"
										;			)
										;			"XX3"
										;			"TARGET3"
										;		)
										;	)
										;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										;(brkstep '("past" "llc" "past2") "4A" "PANEL1")
									)
									(
										(= ptove nil)
										(setq posi2 (list (nth 0 posi2) (+ (nth 1 posi2) 1)))
										;(brkstep '("posi2") "4B" "PANEL1")
									)
								)
							);;;;;;;;;;;;;;;;;;;;;;;TERMINA PUNTO 1
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto"
								;				"ptove"
								;				"posi2"
								;				"lsd"
								;				"llc"
								;				"past"
								;				"past2"
								;				"(< (nth 1 posi2)
								;					(length (nth (nth 0 posi2) mtz2))
								;				)"
								;			)
								;			"XX4" "TARGET4"
								;		)
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							(setq lsd (list 6 7 14 15));;;;;;;;;;;;;COMIENZA PUNTO2
							;(brkstep '("lsd" "past" "past2") "5" "PANEL1")
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2));;CAMBIO(2)
										(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)));;
										(= past2 1)
									)
									(setq posi2
										(list
											(nth 0 posi2)
											(+ (nth 1 posi2) 1)
										)
										past 2
									)
								)
							)
							;(brkstep
							;	'("posi2"
							;		"past"
							;		"(length mtz2)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;	)
							;	"6" "PANEL1"
							;)
							(while
								(and
									(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									(= past 2)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(setq ptotxt (cortxt (cdr pto)))
								(command "zoom" "c" ptotxt "7")
								(command "donut" 0.0 0.30 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto" "ptove" "posi2" "lsd"
								;				"(not (= ptove nil))"
								;			) 
								;		"XX5" "TARGET5")
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(brkstep '("pto" "ptove" "posi2") "7" "PANEL1")
								(cond
									(
										(not (= ptove nil))
										(setq posi3 posi2
											past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep
										;	'("past" "llc" "posi2" "posi3" "past2")
										;	"7A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 10)
												(setq posi3 posi2
													past2 5
													past 0
												)
												;(brkstep '("posi3" "past2" "past")
												;	"7B"
												;	"PANEL1"
												;)
											)
											(
												(not (= (nth 0 pto) 10))
												(setq posi2
													(list
														(nth 0 posi2)
														(+ (nth 1 posi2) 1)
													)
												)
												;(brkstep '("posi2") "7C" "PANEL1")
											)
										)
									)
								)
							)
							(setq lsd (list 10 11 14 15))
							;(brkstep '("lsd" "past2") "8" "PANEL1")
							(cond
								(
									(and
										(< 0 (nth 1 posi2))
										(< (nth 0 posi2) (length mtz2));;CAMBIO(3)
										(= past2 2)
									)
									(setq posi2 (list (+ (nth 0  posi2) 1) (nth 1 posi2))
										past 3
									)
								)
							)
							;(brkstep
							;	'("past"
							;		"(length mtz2)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;		"posi2"
							;	)
							;	"9"
							;	"PANEL1"
							;)
							(while
								(and
									(< (nth 0 posi2) (length mtz2))
									(= past 3)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(setq ptotxt (cortxt (cdr pto)))
								(command "zoom" "c" ptotxt "7")
								(command "donut" 0.0 0.30 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(brkstep '("pto" "ptove" "posi2") "10" "PANEL1")
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep 
										;	'("past" "llc" "posi2" "past2")
										;	"10A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 9)
												(setq past 0
													past2 5
												)
												;(brkstep '("past2" "past") "10B" "PANEL1")
											)
											(
												(not (= (nth 0 pto) 9))
												(setq posi2
													(list (+ (nth 0 posi2) 1)
														(nth 1 posi2)
													)
												)
												;(brkstep '("posi2") "10C" "PANEL1")
											)
										)
									)
								)
							)
							(setq lsd (list 9 11 13 15))
							;(brkstep '("lsd" "past2") "11" "lsd")
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2))
										(<= 0 (nth 1 posi2))
										(= past2 3)
									)
									(setq posi2
										(list
											(nth 0 posi2)
											(- (nth 1 posi2) 1)
										)
									)
									(setq past 4)
								)
							)
							;(brkstep
							;	'("past"
							;		"(length mtz)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;		"posi2"
							;	)
							;	"12"
							;	"PANEL1"
							;)
							(while
								(and
									(<= 0 (nth 1 posi2))
									(= past 4)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;(brkstep '("pto" "ptove" "posi2") "13" "PANEL1")
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(setq ptotxt (cortxt (cdr pto)))
								(command "zoom" "c" ptotxt "7")
								(command "donut" 0.0 0.30 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep
										;	'("past" "llc" "posi3" "past2")
										;	"13A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 5)
												(setq past 0
													past2 5
												)
												;(brkstep '("past" "past2")
												;	"13B" "PANEL1"
												;)
											)
											(
												(not (= (nth 0 pto) 5))
												(setq posi2
													(list
														(nth 0 posi2)
														(- (nth 1 posi2) 1)
													)
												)
												;(brkstep '("posi2") "13C" "PANEL1")
											)
										)
									)
								)
							)
							(cond
								(
									(and
										(not (= posi3 nil))
										(< 1 past2)
									)
									(setq past 5
										posi2 posi3
									)
								)
							)
							;(brkstep '("posi2" "past") "14" "PANEL1")
							(cond
								(
									(and
										(= (length llc) 4)
										(= past2 4)
									)
									(setq llc1 (append llc1 (list llc)))
									;(command "pline"
									;	(nth 0 llc)
									;	(nth 1 llc)
									;	(nth 2 llc)
									;	(nth 3 llc)
									;	"c"
									;)
									;(setq pol1 (ssadd (entlast) pol1))
									(command "zoom" "o" pol1 "");;;;;;;;;;;;;;;;;;;;;;;;
									(cond
										(
											(or
												(= ppd 0)
												(= ppd 1)
											)
											(setq ancho (distance (nth 0 llc) (nth 1 llc)))
										)
										(
											(or
												(= ppd 2)
												(= ppd "nop")
											)
											(setq ancho (distance (nth 0 llc) (nth 3 llc)))
										)
									);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,tr
									(cond
										(
											(or
												(= sty "Ikos_alz")
												(= sty "Makros_pl")
											)
											(setq scml (/ ancho 0.60))
										)
										(
											(= sty "Holmak_alz")
											(setq scml (/ ancho 1.20))
										)
									)
									(cond
										(
											(or
												(= ppd 0)
												(= ppd 1)
											)
											(command
												"mline"
												"j"
												"top"
												"style"
												sty
												"sc"
												scml
												(nth 0 llc)
												(nth 3 llc)
												""
											)
										)
										(
											(or
												(= ppd 2)
												(= ppd "nop")
											)
											(command
												"mline"
												"j"
												"B"
												"style"
												sty
												"sc"
												scml
												(nth 0 llc)
												(nth 1 llc)
												""
											)
										)
									)
									
									;(setq scml1 (cam1 (list (entlast)) (cons 40 scml)))
								)
							);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							;(brkstep '("llc1" "llc" "(sslength pol)" "past2") "15" "PANEL1")
							(cond
								(
									(= past2 0)
									(setq posi2
										(list
											(nth 0 posi2)
											(length (nth (nth 0 posi2) mtz2))
										)
									)
								)
							)
							;(brkstep '("posi2" "past2") "16" "PANEL1")
						)
						;(brkstep '("llc1") "17" "PANEL1")
						(setq posi2 (list (+ (nth 0 posi2) 1) (nth 1 posi2)))
						(cond
							(
								(not (= llc1 nil))
								(setq llc2 (append llc2 (list llc1)))
							)
						)
						;(brkstep '("llc2" "posi2" "(length llc2)") "18" "PANEL1")
					)
					(command "erase" pol "")
					(command "zoom" "o" pol1 "")
				)
			)
		)
	)
	;(brkstep '("llc2") "19" "PANEL1")
	(setq llc2 llc2)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;;;EXTENDED DATA**************************************************
;;PROYECTO: Lisp
;;CLASIFICACION:BDATA
;;OBJETO:XIN. A partir de la definicion de la lista de 
;;datos, vincula XDATA a un objeto
;;	>((x.x)(...)...(-3("MIAPP"(1000."enc1,enc2,...")(1000.xx)(...)...)))
;;DEVUELVE: 
;;	>
;;ARGUMENTOS
;;	1. MINAME: Nombre de la entidad
;;	>	ENAME
;;	2. MIAPP: Nombre de la aplicacion
;;	"XX" 
;;	3. INDL: Lista de encabezados de cada columna
;;	("xx" ".." ...)
;;	4. VAL: Lista de valores donde cada elemento corresponde
;;	a un encabezado de la lista INDL; es decir que lleva el
;; mismo numero de elementos que el numero de encabezados.
;;DEPENDIENTES
;;	>TX ()
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;**********************************************************************
(defun xin (miname miapp indl val / con1 ind lins obj1)
	;(brkstep '("miname" "miapp" "indl" "val") "00" "XIN")
	(if
		(not (tblsearch "APPID" miapp))
		(regapp miapp)
	)
	(setq ind (tx indl "," 2)
		con1 0
		lins
		(list
			(cons 1000 (nth 0 ind))
		)
	)
	(while
		(< con1 (length val))
		(setq lins
			(append
				lins
				(list
					(cons 1000 (nth con1 val))
				)
			)
			con1 (+ con1 1)
		)
	)
	;(brkstep '("ind" "lins") "01" "XIN")
	(setq lins
		(list -3
			(append
				(list miapp)
				lins
			)
		)
		obj1
		(append (entget miname) (list lins))
	)
	;(brkstep '("obj1") "02" "XIN")
	(entmod obj1)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: PH 
;;OBJETO: OBTEN. Obtiene la ruta del archivo csv de rutas
;;	> 
;;DEVUELVE: La ruta del indice deseado en cadena de texto
;;	> "C:/xxx/xx/../"
;;ARGUMENTOS
;;	1. NOMAR. Nombre de archivo de rutas
;;	> "xxx.csv"
;;	2. INDIC. Nombre indice de la ruta
;;	>"xxx"
;; 3. COL. Nombre de la columna que contiene la ruta
;;	>"xx"
;;DEPENDIENTES
;;	> mrr4 (localizacion predefinida de localizacion de
;;	archivo de rutas) -temporal-
;;ANOTACIONES
;;	> El archivo de rutas es de tipo tabla donde el primer elemento
;;	de la lista corresponde a los valores de cabecera (titulos)
;; y, sucesivamente, el primer elemento de cada subelemento corresponde
;; al nombre(indice) de cada ruta.
;; 1
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;***********************************************************
(defun obten (nomar indic col / mi1 midato rutt)
;(brkstep '("nomar" "indic" "col") "00:ENTRADA" "OBTEN")
	(setq mi1 (mrr4);obtiene la localizacion del archivo de ruta
		mi1 (strcat mi1 nomar)
	)
	;(brkstep '("mi1") "XSS" "00")
	(setq midato (lec 0 mi1))
	;(brkstep '("midato") "01" "obten")
	(setq rutt (qnth2 midato indic col 0.01))
)
;
;;
;;;
;;;;


;
;;
;;;
;;;;

;;PROYECTO: NV
;;CLASIFICACION: BDATA
;;OBJETO: LISTAB. Apartir de la definicion del nombre (simbolo)
;;	del diccionario, devuelve la lista de nombre (simbolo) de todos
;; los Xrecords
;;	>
;;DEVUELVE: Lista de nombre (simbolo) de todos los Xrecords
;;	> ("xxx" "xxx" ....)
;;ARGUMENTOS
;;	1. Nombre de simbolo del diccionario
;;	> "xxxx"
;;DEPENDIENTES
;;	> GOCDICT ( )
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;
(defun listab (mindi / tname lstab ltab1)
	(setq tname (gocdict mindi))
	;(brkstep '("tname") "01" "LISTAB")
	(setq lstab
		(expat '((3 350))
			(entget tname)
		)
	)
	;(brkstep '("tname" "lstab") "02" "LISTAB")
	(cond
		(
			(not (= lstab nil))
			(setq ltab1 (mapcar 'cdr (nthz (list 1) lstab)))
		)
	)
	;(brkstep '("ltab1") "03" "LISTAB")
	(setq ltab1 ltab1)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: BDATA
;;OBJETO: LISTAB1. A partir de la definicion del nombre (simbolo)
;; del diccionario, la lista de nombres (simbolo) de Xrecords
;;	correspondientes y el codigo de datos, devuelve la lista
;; valores de cada codigo.
;;	> ( ("SimXRecord" val1 val2 ...) (...) ...)
;;DEVUELVE: Lista de valores correspondientes a el codigo
;;	de extraccion de cada Xrecord; donde el primer elemento de cada
;;	elemento corresponde al nombre (simbolo) de Xrecord.
;;	> ( ("SimXRecord" val1 val2 ...) (...) ...)
;;ARGUMENTOS
;;	1. NAMDIC Nombre (simbolo) de diccionario
;;	> "xxx"
;;	2. LNR. Lista de nombres (simbolo) de Xrecord
;;	> ("xxx" "xxx" ....)
;;	3. CDAT. Codigo de extraccion
;;	> NN
;;DEPENDIENTES
;;	> EXPAT(); NTHZ (NTHX); BRKSTEP ()
;;ANOTACIONES{}
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun listab1 (namdic lnr cdat / con1 lsb lsb1 lsbf lsexpat)
	;(brkstep '("namdic" "lnr" "cdat") "00: Entrada" "LISTAB1")
	(setq con1 0
		cdat (list (list cdat))
	)
	;(brkstep '("con1" "cdat") "01" "LISTAB1")
	(while
		(< con1 (length lnr))
		(setq lsb
			(expat cdat
				(dictsearch
					(exname (entget (namedobjdict)) namdic)
					(nth con1 lnr)
				)
			)
		)
		;(brkstep '("lsb" "(nth con1 lnr)") "02" "LISTAB1") 
		(cond
			(
				(not (= lsb nil))
				(setq lsb1 (mapcar 'cdr (nthz '(1) lsb)))
				;(brkstep  '("lsb1") "03" "LISTAB1")
				(setq lsbf
					(append lsbf
						(list
							(append
								(list (nth con1 lnr))
								lsb1
							)
						)
					)
				)
			)
		)
		;(brkstep '("lsbf") "03" "LISTAB1")
		(setq con1 (+ con1 1))
	)
	(setq lsbf lsbf)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:BDATA
;;OBJETO: QCODLS;(Quick code list). A partir de la definicion del nombre
;;	(simbolo) de diccionario y el codigo de datos, devuelve la lista de
;;	los valores del codigo de cada Xrecord correspondientes al diccionario.
;;	> 
;;DEVUELVE: Lista de valores del codigo de cada uno de los Xrecords
;;	> ("valorCodigo" ...)
;;ARGUMENTOS
;;	1.SIMNAME. Nombre (simbolo) de diccionario
;;	> "NomSimDict"
;; 2. COD. Codigo de datos
;; > NN
;;DEPENDIENTES
;;	> LISTAB (); LISTAB1 (); BINDLS ();
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun qcodls (simname cod / jj)
	(setq jj (bindls (mapcar 'cdr (listab1 simname (listab simname) cod))))
	(setq jj jj)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:BDATA
;;OBJETO: QCODLS0;(Quick code list ver.0). A partir de la definicion
;;	del nombre (simbolo) de diccionario y el codigo de datos, devuelve
;;	la lista de Xrecord con sus valores del codigo correspondientes
;; al diccionario donde el primer elemento de cada lista corresponde
;;	al Xrecord y los demas elementos al valor de codigo.
;;	> ( (Xrecord Val ...) (...) ...)
;;DEVUELVE: Lista de Xrecord y valores del codigo del diccionario
;;	indicado.
;;	> ( (Xrecord Val ...) (...) ...)
;;ARGUMENTOS
;;	1.NOMSDICT. Nombre (simbolo) de diccionario
;;	> "NomSimDict"
;; 2. CODI. Codigo de datos
;; > NN
;;DEPENDIENTES
;;	> LISTAB (); LISTAB1 (); BINDLS ();
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun qcodls0 (nomsdict codi / jj1)
	(setq jj1 (listab1 nomsdict (listab nomsdict) codi))
	(setq jj1 jj1)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: BDATA
;;OBJETO: NUVITAB. (Nuevo Tablero); A partir de la definicion de 
;; el nombre de entidad de una polilinea, nombre (simbolo) de diccionario
;; y el codigo de datos; Agrega el dato correspondiente a la lista del
;; diccionario.
;;	> (diccionario >Xrec = Handlet > Codigo)
;;DEVUELVE:
;;	> T si el elemento es nuevo
;;	> NIL si el elemento ya existia dentro de la lista
;;ARGUMENTOS
;;	1. NAMELE; Nombre de entidad
;;	> ENAME
;; 2. DIXIO; Nombre (simbolo) del diccionario
;; 3. CODD; Codigo de dato
;;DEPENDIENTES
;;	>BINDLS (); GOCXR (); 
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;INSERCION DE VALORES XRECORD
;;PR....
(defun nuvitab 
	(namele dixio codd / nix nixn nixl ldixio resul nvtablero)
	(princ)
	(setq resul T)
	(setq nix 
		(cdr
			(assoc 5 
				(entget namele)
			)
		)
	)
	(setq ldixio
		(bindls
			(mapcar 'car (qcodls0 dixio codd))
		)
	)
	(cond
		(
			(= (compa nix ldixio) t)
			(alert "EL TABLERO YA EXISTE")
			(setq resul nil)
		)
		(
			(not (= (compa nix ldixio) t))
			(setq nixn
				(getstring "Defina el nombre del tablero <predeterminado>: ")
			)
			(princ)
			(cond
				(
					(= nixn "")
					;(brkstep '("nix" "nixn") "01" "NUVITAB")
					(princ)
					(print
						(strcat "NOMBRE DE TABLERO : " nix "...")
					)
					(princ)
					(setq nixl (list (cons 1005 nix)))
				)
				(
					(not (= nixn ""))
					(setq nixl (list (cons 1005 nixn)))
				)
			)
			;(brkstep '("nix" "nixl") "02" "NUVITAB")
			(setq nvtablero (gocxr dixio nix nixl))
		)
	)
	(setq resul resul)
 )
 ;
 ;;
 ;;;
 ;;;;
 ;;PROYECTO: NV
;;CLASIFICACION: BDATA
;;OBJETO:RENOM. A partir de la definicion del valor actual
;; contenido en un Xrecord, el valor nuevo de sustitucion
;; y el codigo de datos; renombra dicho valor.
;;	> Encuentra el Xrecord al que corresponde el valor actual, si no lo
;; encuentra devuelve nil.
;;DEVUELVE:
;;	> T Si encontro el Xrecord correspondiente para realizar
;;	la sustitucion de datos.
;;	> NIL. Si no encontro el Xrecord correspondiente y, por tanto
;;	no realiza ninguna accion.
;;ARGUMENTOS
;;	1. VJONOM. Valor Actual que va a ser cambiado
;;	> "xxx"
;;	2. NVONOM. Valor nuevo que va a sustituir el valor actual.
;;	> "xxxx"
;;	3. DICT1. Nombre (simbolo del diccionario)
;; 4. COD1. Codigo de valor a cambiar.
;;DEPENDIENTES
;;	> EXNAME ()
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun renom (vjonom nvonom  dict1 cod1 / mxr mxrl0 pass2)
	(setq mxr
		(lnpo vjonom
			(qcodls0 dict1 cod1)
			1
			1
		)
		pass2 nil
	)
	;(brkstep '("mxr") "01" "RENOM")
	(cond
		(
			(not (= mxr nil))
			(setq mxr (nth 0 (nth 0 mxr)))
			;(brkstep '("mxr") "02" "RENOM")
			(setq pass2 t)
			(setq mxrl
				(entget
					(exname (entget (namedobjdict)) dict1)
				)
			)
			;(brkstep '("mxrl") "03" "RENOM")
			(setq mxrl (entget (exname mxrl mxr)))
			;(brkstep '("mxrl") "04" "RENOM")
			(setq mxrl (subst (cons cod1 nvonom) (cons cod1 vjonom) mxrl))
			(entmod mxrl)
		)
	)
	(setq pass2 pass2)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: BDATA
;;OBJETO: XRORIG. Apartir del nombre (simbolo) de un diccionario,
;;	valor guardado en dicho diccionario y codigo de dicho valor,
;;	encuentra el nombre del Xrecord al que pertenece.
;;	> XRECOR = 1 valor
;;DEVUELVE: Nombre del XRECORD
;;	> "XXX"
;;ARGUMENTOS
;;	1. LSDIC. Nombre (simbolo) del diccionario
;;	> "XXX"
;;	2. MIN1. Nombre del valor al que pertenece el Xrecord buscado
;;	> "XXX"
;;	3. CDG. Codigo del valor.
;;	> NN
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>1. Solo admite un solo valor como resultado si dos
;; valores toma el primero.
;;;(brkstep '("") "001TEMP" "")
;;******************************************
;;PR...
(defun xrorig (lsdic min1 cdg / nomx)
	(setq nomx
		(lnpo min1 (qcodls0 lsdic cdg) 1 1)
	)
	;(brkstep '("nomx") "01" "XORIG")
	(cond
		(
			(not (= nomx nil))
			(setq nomx
				(car
					(nth 0 nomx)
				)
			)
		)
	)
	(setq nomx nomx)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:BDATA
;;OBJETO: IMPDAT
;;	> Apartir de la definicion de:
;;	Nombre de archivo de rutas; Nombre de renglon; Nombre de columna
;;	Nombre de archivo de datos ;Modo de importacion.
;;	Obtiene la tabla de datos del archivo externo
;;DEVUELVE:
;;	> Tabla de arvchivo externo 
;;ARGUMENTOS
;;	1.NOMRU; Nombre del archivo que contiene las rutas (.csv)
;;	> "xxx.csv"
;;	2.NOMROW; Nombre del renglon del archivo de rutas
;;	>"xxx"
;;	3.NOMCOL; Nombre de la columna del archivo de rutas
;;	> "xxx"
;;	4.NOMAR; Nombre del archivo que contiene la tabla (.csv)
;;	> "xxx.csv"
;;	5.MODO; Modo de importacion;
;;	> () nil Importacion textual: cadena de texto
;;	> 1.- Datos numericos = enteros
;;	> 2.- Datos datos numericos = reales
;;DEPENDIENTES
;;	> OBTEN (); LEC ();
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun impdat (nomru nomrow nomcol nomar modo / miruta1 mitabla) 
	;(brkstep '("nomru" "nomrow" "nomcol" "nomar" "modo") "00" "IMPDAT")
	(setq miruta1
		(strcat 
			(obten nomru nomrow nomcol)
			nomar
		)
	)
	;(brkstep '("miruta1") "01" "IMPDAT")
	(cond
		(
			(= modo nil)
			(setq mitabla (lec () miruta1))
		)
		(
			(not (= modo nil))
			(setq mitabla (lec modo miruta1))
		)
	)
	;(brkstep '("mitabla") "01" "ASA")
	(setq mitabla mitabla)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: DCL
;;OBJETO: DEFPEN: Con la seleccion de una
;;	linea o la definicion de puntos (2) se define
;;	el indice de pendiente (ver amotaciines)
;;	>
;;DEVUELVE:
;;	> 
;;ARGUMENTOS
;;	1. Seleccion de usuario
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;; !!Verificar pendientes!!
;;	> Pendiente indeterminada = "non"
;;	> Pendienre 0 = 0
;;	> Pendiente positiva = 1
;;	> Pendiente negativa = 2
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;******************************
(defun defpen ( / points p1 p2 ngl mipen pend0)
	(setq points (ssget '((0 . "line"))))
	(cond
		(
			(= points nil)
			(setq p1 (getpoint "SELECCIONE EL PRIMER PUNTO: ")
				P2 (getpoint p1 "SELECCIONE EL SEGUNDO PUNTO: ")
			)
		)
		(
			(not (= points nil))
			(setq p1 (cdr (assoc 10 (entget (ssname points 0) )))
				p2 (cdr (assoc 11 (entget (ssname points 0))))
			)
		)
	)
	(setq ngl (angle p1 p2)
		ngl (round1 ngl 4)
	)
	(cond 
		(
			(or (equal ngl 4.71239 0.0001)
				(equal ngl 1.5708 0.0001)
			)
			(setq mipen "non")
		)
		(
			(and
				(not (equal ngl 4.71239 0.0001))
				(not (equal ngl 1.5708 0.0001))
			)
			(setq pend0
				(ppnd2 p1 p2)
			)
			(cond
				(
					(equal pend0 0 0.0001)
					(setq mipen "0")
				)
				(
					(< 0 pend0)
					(setq mipen "1")
				)
				(
					(> 0 pend0)
					(setq mipen "2")
				)
			)
		)
	)
	(setq mipen mipen)
) 

;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:BDATA
;;OBJETO:XIN2. Compara los atributos accesibles del layout (IDE_SALIDA.CSV)
;; y escribe los valores introducidos por el usuario
;; en la entidad definida con la siguiente
;;	estructura.
;;	>((x.x)(...)...(-3("MIAPP"(1000."Indice , Valor ")(...)...)))
;;DEVUELVE: 
;;	> 0. Si no se realizo la insercion de datos
;;		no encontro nombre de elemento
;;	> 1. Si se realizo la insersion de datos
;;		si encontro nombre de elemento
;;ARGUMENTOS
;;	1.MMIAP Nombre de la aplicacion
;;	> "XXX"
;;	2. MMIENTI: Nombre de la entidad
;;	ENAME
;;	3. ELENAM: Nombre de elemento de cuantificacion
;;	"XXX" (si el nombre de se omite se toma el nombre de la lista)
;;	4. LVATT: Lista de atributos y valores introducidos por el usuario.
;;	( ("atributo" "valor") (...) ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;; *1. El nombre de los atributos deben de coincidir con los nombres
;;	del archivo (layout)
;;	*2. El primer elemento de ambas listas (atributo y valor)
;; siempre sera el tipo de elemento de cuantificacion.
;;	*3. Los valores siempre se almacenan en cadenas de texto.
;; *4. Si se omite el nombre de elemento se toma el nombre de elemento 
;;	de la lista de atributos y valores introducidos por el usuario.
;;	*5. Si se omite la variable de lista de datos de la entidad
;;	se aplica "-"
;;	*6. La ubicacion del archivo LAYOUT de atributos se encuentra
;;	definido en el archivo de rutas.csv en el renglon (ID_BDATOS).
;;	*7. Toma el nombre del atributo del layout y el valor de los datos
;;	introducidos por el usuario, en caso de no encontrar el dato definido
;;	por el usuario, toma el valor actual de la entidad, y en el caso
;;	que tampoco exista en la entidad el valor es = "-".
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;**********************************************************************
(defun xin2
	(mmiap  mmienti elenam lvatt  / obj1
		attrib mimi insele insele1 lins
		con1 elelo elenam miatt miattv  miattvx compro
		entidat 
	)
	;(brkstep '("mmiap" "mmienti" "elenam" "lvatt" "(camb (list mmienti) 3)") "00" "XIN2")
	(setq compro 0)
	(cond
		(
			(and
				(not (= mmiap nil))
				(not (= mmienti nil))
			)
			;(brkstep '("mmiap" "mmienti" "lvatt") "01" "XIN2")
			(if
				(not (tblsearch "APPID" mmiap))
				(regapp mmiap)
			)
			(cond
				(
					(and
						(= elenam nil)
						(not (= (lnpo "ELEMENTO" lvatt 0 1) nil))
					)
					(setq elenam
						(nth 1(nth 0 (lnpo "ELEMENTO" lvatt 0 1)))
					)
					;(brkstep '("elenam") "01A" "XIN2")
				)
			)
			(setq entidat (extraxr mmienti mmiap))
			;(brkstep '("entidat" "elenam") "01B" "XIN2")
			(cond
				(
					(and
						(not (= entidat nil))
						(= elenam nil)
					)
					;(brkstep '("(lnpo \"ELEMENTO\" entidat 0 1)") "01C" "XIN2")
					(cond
						(
							(lnpo "ELEMENTO" entidat 0 1)
							(setq elenam
								(nth 1
									(nth 0 (lnpo "ELEMENTO" entidat 0 1))
								)
							)
							;(brkstep '("elenam") "01D" "XIN2")
						)
					)
				)
			)
			;(brkstep '("elenam" "entidat") "02" "XIN2")
			(cond
				(
					(not (= elenam nil))
					(setq con1 0)
					;;;;Importacion de datos o Creacion de directorio;;;;(0)
					(setq attrib 
						(impdat "rutas.csv" "ID_BDATOS" "RUTA" "IDE_SALIDA.csv" ())
					)
					;;;;Importacion de datos o Creacion de directorio;;;;;(1)
					;(brkstep 
					;'("attrib" "elenam"
					;"(nthx (list 0 con1) attrib)") "03" "XIN2")
					(while (< con1 (length (nth 0 attrib)))
						;(brkstep 
						;'("(nthx (list 0 con1) attrib)"
						;	"con1" "(length (nth 0 attrib))") "03A" "XIN2")
						(setq mimi 
							(qnth2
								attrib
								elenam
								(nthx (list 0 con1) attrib)
								0.001
							)
						)
						;(brkstep '("mimi") "04" "XIN2")
						(cond 
							(	
								(and
									(not (= (strcase mimi t) "no"))
									(not (= (strcase mimi t) "non"))
								)
								(setq miatt (nthx (list 0 con1) attrib))
								;(brkstep '("miatt") "05" "XIN2")
								(setq miattv (lnpo miatt lvatt 0 1))
								(setq miattvx (lnpo miatt entidat 0 1))
								;(brkstep '("miattv" "miattvx") "06" "XIN2");;;;;;;;;;;;;;
								(cond
									(
										(not (= miattvx nil))
										(setq miattvx (nth 1 (nth 0 (lnpo miatt entidat 0 1))))
									)
								)
								;(brkstep '("miattv" "miattvx") "07" "XIN2")
								(cond
									(
										(not (= miattv nil))
										(setq miattv (nth 1 (nth 0 (lnpo miatt lvatt 0 1))))
										;(brkstep '("miattv") "07A" "XIN2")
									)
									(
										(and
											(= miattv nil)
											(not (= miattvx nil))
										)
										(setq miattv miattvx)
										;(brkstep '("miattv") "07B" "XIN2")
									)
									(
										(and
											(= miattv nil)
											(= miattvx nil)
											(setq miattv "-")
											;(brkstep '("miattv") "07C" "XIN2")
										)
									)
								)
								(setq insele
									(cons 1000
										(strcat
											miatt
											","
											miattv
										)
									)	
								)
								(setq insele1
									(append insele1 (list insele))
								)
								;(brkstep '("insele" "insele1") "08" "XIN2")
							)
						)
						(setq con1 (+ con1 1))
					)
					(cond
						(
							(not (= insele1 nil))
							(setq insele1
								(list -3
									(append
										(list mmiap)
										insele1
									)
								)
							)
							;(brkstep '("insele1") "09" "XIN2")
							(setq obj1
								(append (entget mmienti) (list insele1))
							)
							;(brkstep '("obj1") "10" "XIN2")
							(entmod obj1)
							(setq compro 1)
						)
					)
				)
			)
			(setq compro compro)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:BDATA
;;OBJETO:XIN3. A partir de la definicion de la lista de 
;;datos, vincula XDATA a un objeto
;;	>((x.x)(...)...(-3("MIAPP"(1000."Indice , Valor ")(...)...)))
;;DEVUELVE: 
;;	>
;;ARGUMENTOS
;;	1.MMIAP Nompbre de la aplicacion
;;	>
;;	2. MMIENTI: Nombre de la entidad
;;	"XX" 
;;	3. LS1: lista de datos para insertar en el elemento
;;	(("xx,xx") (...) ...)
;;	4. 
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Crea la lista Xdata con el codigo 1000 donde el valor se compone de
;;	del Indice (tipo o nombre del valor) y el valor, separados por un caracter
;; (","); cada elemento es un par punteado de codigo (1000) . Cadena de texto.
;;	> Inserta los datos con el codigo 1000
;;;(brkstep '("") "001TEMP" "")
;;PR...
;;**********************************************************************
(defun xin3
	(mmiap  mmienti ls1 / obj1 linsf con1 lin1)
	(if
		(not (tblsearch "APPID" mmiap))
		(regapp mmiap)
	)
	(setq con1 0)
	(while 
		(< con1 (length ls1))
		(setq lin1 (nth 0 (nth con1 ls1)))
		;(brkstep '("lin1") "01" "XIN3")
		(setq linsf
			(append linsf
				(list
					(cons 1000 lin1)
				)
			)
		)
		;(brkstep '("linsf") "02" "XIN3")
		(setq con1 (+ con1 1))
	)
	;(brkstep '("linsf") "03" "XIN3")
	(cond
		(
			(not (= linsf nil))
			(setq linsf
				(list -3
					(append
						(list mmiap)
						linsf
					)
				)
				obj1
				(append (entget mmienti) (list linsf))
			)
			;(brkstep '("obj1") "04" "XIN3")
			(entmod obj1)
		)
	)
)

;
;;
;;;
;;;;
;;PROYECTO: NV (NOVIDESA)
;;CLASIFICACION: MAIN (EJECUTABLE)
;;OBJETO: PANEL10. A partir de la definicion del indice de pendiente e
;;	indice de sistema constructivo; Selecciona las lineas que forman
;;	la reticula de un tablero y dibuja los paneles (multilineas).
;;	> Indice de pendiente:
;;	"nop": Seccion transversal en sentido vertical (pendiente indeterminada)
;;	0: Seccion transversal en sentido horizontal (pendiente 0)
;;	1: Seccion transversal en pendiente positiva
;;	2: Seccion transversal en pendiente negativa
;;	>	Indice de sistema constructivo:
;;	0. IKOS
;;	1. MAKROS
;;	2. HOLMAK
;;DEVUELVE: Lista de coordenadas (4) de cada panel, agrupadas en filas.
;;	> ((((x1 y1) (x2 y2) (x3 y3) (x4 y4)) (...) ...) (...) ...)
;; > Primer nivel de lista = Coordenadas X Y de punto
;;	> Segundo nivel de lista = 4 coordenadas de cada panel
;;	> Tercer nivel de lista = fila de panel.
;;ARGUMENTOS
;;	1.	NOMEPEN. Indice de pendiente en seccion transversal del panel
;;	>	"nop": 	Linea vertical (pendiente indeterminada)
;;	>	0. Linea horizontal (pendiente 0)
;;	>	1. Pendiente positiva
;;	>	2. Pendiente negativa
;; 2. SISTE. Sistema constructivo:
;;	>	0. IKOS
;;	>	1. MAKROS
;;	>	2.	HOLMAK
;;DEPENDIENTES
;;	> PANEL2
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun panel10 
	(nomepen siste /
		msil rrut1 bb1 mpp ffa paqm paqr conex rectangulo recs mprecc
		orto os1 os2
	)
	;(setq msil nil rrut1 nil bb1 nil mpp nil ffa nil paqm nil paqr nil conex nil rectangulo nil
	;	recs nil mprecc nil orto nil os1 nil os2 nil
	;)
	(setq msil (ssget '((0 . "LINE")))
		msil (noment msil)
	)
	(setq mprecc (getvar "luprec"))
	(setq orto (getvar "orthomode"))
	(setq os1 (getvar "osmode"))
	;;(setq os2 (getvar "osmode2"))
	(setvar "luprec" 5)
	(setvar "orthomode" 0)
	(setvar "osmode" 0)
	;(setvar "osmode2" 0)
	(setq rrut1 (obten "rutas.csv" "MLINE" "RUTA"))
	(setq bb1 (mat1 msil))
	(setq mpp (nth 0 (nth 0 (nth 0 bb1))))
	(setq ffa 1)
	(cond
		(
			(or
				(= mpp "nop")
				(equal mpp 0 0.001)
			)
			(setq ffa 0)
		)
	)
	;(brkstep '("bb1" "mpp" "(length (nth 0 bb1))" "(length (nth 1 bb1))") "EXEFOO: MAT1" "...")
	;(xdat2 (append (nth 0 bb1) (nth 1 bb1)) "," 3)
	(setq paqm (mat4 bb1 0.1 1))
	;(brkstep '("bb1" "paqm" "(length paqm)") "EXEFOO : 1 Lista matriz" "PAQM1")
	;(xdat2 paqm "," 3)
	(setq paqr (mat3 bb1 1))
	;(brkstep '("paqr" "(length paqr)") "EXEFOO: 3" "PAQR")
	;(xdat2 paqr "," 3)
	(setq conex (mat6 paqr ffa 0.1));;;;;;;;;;seleccion de tipo de pendiente
	;(brkstep '("conex" "(length conex)") "EXEFOO: 4" "Lista reticula")
	;(xdat2 conex "," 3)
	(setq rectangulo (matconect conex paqm ffa 0.1));;;;seleccion de tipo de pendiente
	(brkstep '("rectangulo" "(length rectangulo)") "EXEFOO: 5" "MATCONECT")
	;(xdat2 rectangulo "," 3)
	;;;;;;;;;;;;;PREPARACION DE LISTA PARA RECTANGULAR;;;;;;;;;;;;;;;;,
	(setq rectangulo (orden3 rectangulo 0 1))
	;(brkstep '("rectangulo") "EXEFOO: 6" "Matriz ordenada")
	(setq rectangulo (mat5a rectangulo 3 1))
	;(xdat2 rectangulo "," 3)
	(setq recs (panel2 rectangulo nomepen siste "Mlines.dwg" rrut1))
	;(brkstep '("recs") "CoordenadasRectangulo" "...")
	;(xdat2 recs "," 3)
	
	(setvar "luprec" mprecc)
	(setvar "orthomode" orto)
	(setvar "osmode" os1)
	;(setvar "osmode2" os1)
	(setq recs recs)
)
;
;;
;;;

;
;;
;;;
;;;;
;;;********************ACTUAL***************************************
;;;********************COMPLETANDO EN FOO**************************
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: List
;;OBJETO:SUS1
;;	Sustituye uno o varios de elementos en otra lista
;;DEVUELVE:
;;	Lista modificada (sustituida)
;;	( xx () ## ...)
;;ARGUMENTOS:
;;	1. LSUS: Lista de elementos para instertar compuesta por
;;	listas de dos elementos: Posicion (NTH), elemento de sustitucion
;;	( (posicion ElementoSustitucion) (...) ...)
;;	2. TRAB: Lista de elementos donde se van a sustituir los elementos
;;	del argumento 1 (LSUS)
;;DEPENDIENTES:
;;	CUT.
;;PR...
(defun sus1 (slus ltrab / cn1 fls lm0 psl1 trins pase)
  (setq cn1 0
	lm0 0
	pase 0)
  (while (< cn1 (length slus))
    (setq psl1 (nth 0 (nth cn1 slus)))
    (cond
      (
       (/= lm0 psl1)
       (setq trins (cut lm0 (- psl1 1) ltrab)
	     trins (append trins
			   (list
			     (nth 1 (nth cn1 slus))
			     )
			   )
	     )
       (setq lm0 (+ psl1 1))
       )
      (
       (= psl1 lm0)
       (setq trins (list (nth 1 (nth cn1 slus)))
	     lm0 (+ lm0 1)
	     )
       )
      )
    (cond
      (
       (= pase 0)
       (setq pase 1
	     fls trins)
	     )
      (
       (= pase 1)
       (setq fls (append fls trins))
       )
      )
    (setq cn1 (+ cn1 1))
    )
  (cond
    (
     (< lm0 (length ltrab))
     (setq trins (cut lm0 (- (length ltrab) 1) ltrab)
	   fls (append fls trins)
	   )
     )
    )
  (setq fls fls)
  )
 ;
 ;;
 ;;;
 ;;;;
;;;*********
;;PROYECTO:NV
;;CLASIFICACION: BDATA
;;OBJETO: SUSAT. Sustituye un conjunto de atributos y valores (XDATA)
;;	una lista de elementos (entidades) 
;;	> 
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. LNOR. Lista de nombre de la entidades
;;	> (ENAME ...)
;;	2. LSATT. Lista de atributos nuevos
;;	> ( (NomATT ValATT) (...)...)
;;	3. NPAP. Nombre de la aplicacion XDATA
;;	4. NN0M. Nombre de Elemento
;; 5. MOD. Modo de inclusion de entidades nuevas
;;	>	0. Ignora las endidades que no contengan atributos de cuantificacion
;;	>	1. Incluye entidades nuevas
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;*********************
;;;;	(setq ww '(("TABLERO" "XXX") ("MATERIAL" "IKOS") ("UTILFACT" "_")))
;;;;	(setq ww1 (extraxr (car (entsel)) "XD_NOVIDESA"))
;;;;	(setq wwn (qnth1 ww1 (nthx '(2 0) ww) 0.01))
;;PR...
;;;;*********************
(defun susat (lnor lsatt npap nnom mod / nor1 con1 con2 da1 ind1 ind2 lfina)
	(cond
		(
			(and
				(not (= lnor nil))
				(not (= lsatt nil))
				(not (= npap nil))
				(not (= nnom nil))
			)
			(setq con1 0)
			(while
				(< con1 (length lnor))
				(setq nor1 (nth con1 lnor))
				;(brkstep '("nor1") "01" "SUSAT")
				(setq da1 (extraxr nor1  npap))
				;(brkstep '("da1") "02" "SUSAT")
				(cond
					(
						(not (= da1 nil))
						(setq con2 0)
						(while 
							(< con2 (length lsatt))
							(setq ind1
								(qnth1
									da1
									(nthx (list con2 0) lsatt)
									0.001
								)
								ind1 (nthx '(0 0) ind1)
							)
							;(brkstep '("da1" "ind1") "03" "SUSAT")
							(setq ind2
								(list
									(list ind1
										(nth con2 lsatt)
									)
								)
							)
							;(brkstep '("ind2" "da1") "04" "SUSAT")
							(setq da1 (sus1 ind2 da1))
							(setq con2 (+ con2 1))
							;(brkstep '("da1" "con2" "lsatt") "04" "SUSAT")
						)
						;(brkstep '("npap" "nor1" "nnom" "da1") "05" "SUSAT")
						(xin2 npap nor1 nnom da1)
					)
					(
						(and
							(= da1 nil)
							(= mod 1)
						)
						(xin2 npap nor1 nnom lsatt)
					)
				)
				(setq con1 (+ con1 1))
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: BDATA
;;OBJETO: SACLS
;;	> A partir de la definicion de la lista de nombre de entidades
;;	que contengan atributos (XDATA) con la estructura:
;;	>  ((1000 . "NomATT,ValAtt") (...) ...)
;;	define una lista de:
;;	Nombre de entidad y Valor del Atributo definido por el
;; nombre de atributo en el argumnento
;;	Dicho valor es agrupado por su valor
;;	DEVUELVE: Lista de nombre de entidad y valor del atributo
;;	La lista se agrupa en cada variante del valor del resultado.
;;	>( ( (ENMAME "TIPO_ELEMENTO") (...) ...) (...) (...) ...)
;;ARGUMENTOS
;;	1.Lista de nombre de endidades
;;	> (ENAME ....)
;;	2.NAP: Nombre de aplicacion
;;	>	"XXX"
;;	3.NOMATT: Nombre del atributo
;;
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Si el nombre de atributo no existe, devuelve el nombre
;; de la entidad y nil como valor del atributo.
;;;(brkstep '("") "001TEMP" "")
(defun sacls (lscnj nap nomatt / exdd exdd1 exddf con1 mipar0 mipar1)
	(cond	
		(
			(not (= lscnj nil))
			;(brkstep '("lscnj") "00" "SACLS")
			(setq con1 0)
			(while
				(< con1 (length lscnj))
				(setq exdd (extraxr (nth con1 lscnj) nap))
				;(brkstep '("exdd") "01" "SACLS")
				(cond
					(
						(not (= exdd nil))
						(setq exdd1 (lnpo nomatt exdd 0 1)
							exdd1 (nthx '(0 1) exdd1)
						)
						;(brkstep '("exdd1") "02" "SACLS")
						(setq exddf
							(append exddf
								(list
									(list
										(nth con1 lscnj)
										exdd1
									)
								)
							)
						)
						;(brkstep '("exddf" "lscnj" "con1") "03" "SACLS")
					)
				)
				(setq con1 (+ con1 1))
			)
			(cond
				(
					(not (= exddf nil))
					(setq exddf (agru1 exddf () 1 0.01))
					;(brkstep '("exddf") "04" "SACLS")
				)
			)
		)
	)
	(setq exddf exddf)
)
;
;;
;;;
;;;;
;;PROYECTO:NV
;;CLASIFICACION: BDATA
;;OBJETO: ACTUAL. Elimina elementos del Xrecord de "nvtablero" con
;;	con el codigo 1005 de tableros (entidades) que no existan.
;;DATOS: Diccionario: nvtablero
;;		> (3 . "handlet) > (1005 . "nombre")
;;DEVUELVE: 
;;	> 
;;ARGUMENTOS
;;	1. 
;;	> 
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;; >>
;;PR...
(defun actual
	(/ lispa lispa1
		ssell mename
		misel1 menti1
		toten cdig
		mmval mmval0
		ww1 ww2
	)
	(setq lispa 
		(listab "nvtablero")
		mename (exname (entget (namedobjdict)) "nvtablero")
	)
	;;>>LISPA: ("HANDLET" ...) Lista XRECORD
	;;>>MENAME: ENAME Nombre de diccionario "nvtablero"
	(setq totem
		(ssget "x" '((-3 ("XD_NOVIDESA"))))
	)
	;;>> SelectionSET
	;(brkstep '("mename" "lispa" "totem") "01" "ACTUAL")
	(cond
		(
			(not (= lispa nil))
			(setq lispa
				(listab1 "nvtablero" lispa 1005)
			)
			;(brkstep '("lispa") "02" "ACTUAL")
			;;>> ( ("HANDLET" "ValUsuario") (...) ...)
			(setq lispa1
				(bindls (mapcar 'car lispa))
			)
			;;>> LISPA1: ("HANDLET"  "HANDLET" ....)
			;(brkstep '("lispa1" "lispa") "03" "ACTUAL")
			(setq con1 0)
			(while
				(< con1 (length lispa1))
				(setq misel1
					(ssget "x"
						(list
							(cons 5 (nth con1 lispa1))
						)
					)
				)
				;;>> SelectionSeet / nil
				;(brkstep '("misel1" "con1") "04" "ACTUAL")
				(cond 
					(
						(= misel1 nil)
						(setq cdig
							(cons 1000
								(strcat "TABLERO,"
									(nth 0
										(cdr
											(nth 0
												(lnpo (nth con1 lispa1) lispa 0 1)
											)
										)
									)
								)
							)
						)
						;(brkstep '("cdig1") "05" "ACTUAL")
						;;>> cdig: (1000 . "TABLERO,[NomXR]")
						(cond
							(
								(not (= totem nil))
								(setq cdig1
									(exnoma
										"XD_NOVIDESA"
										(list cdig)
										(noment totem)
									)
								)
							)
						)
						;(brkstep
						;	'("cdig1" "(length cdig1)")
						;	"06"
						;	"ACTUAL"
						;)
						;;>>	CDIG1: (ENAME ...)
						(cond
							(
								(not (= cdig1 nil))
								(susat
									cdig1
									'(("TABLERO" "-"))
									"XD_NOVIDESA"
									"GUIA"
									0
								)
								;(brkstep '("cdig" "cdig1") "07" "ACTUAL")
							)
						)
						(delrcod
							mename
							(list (nth con1 lispa1))
							()
						)
					)
					(
						(not (= misel1 nil))
						;(brkstep
						;	'("misel1"
						;		"(sslength misel1)"
						;		"lispa"
						;		"lispa1"
						;		"(ssname misel1 0)"
						;	)
						;	"000" "ACTUAL"
						;)
						(setq mmval0 (ssname misel1 0))
						(setq mmval
							(nth 0
								(cdr
									(nth 0
										(lnpo
											(cdr
												(assoc 5
													(entget mmval0)
												)
											)
											lispa
											0 1
										)
									)
								)
							)
						)
						;(brkstep '("mmval0" "mmval") "01TEMP" "ACTUAL")
						(setq ww1
							(nth 0
								(cdr
									(nth 0
										(lnpo
											"ELEMENTO"
											(extraxr mmval0 "XD_NOVIDESA")
											0 1
										)
									)
								)
							)
						)
						(cond
							(
								(= ww1 "-")
								(setq ww1 "POLIGONAL")
								(setq ww2
									(susat
										(list mmval0)
										(list
											(list "ELEMENTO" "POLIGONAL")
										)
										"XD_NOVIDESA"
										ww1
										0
									)
								)
							)
						)
						;(brkstep '("(ssname misel1 0)" "misel1" "mmval0" "mmval") "001" "ACTUAL")
						(xin2 "XD_NOVIDESA"
							(ssname misel1 0) 
							"POLIGONAL"
							(list
								(list "ELEMENTO" "POLIGONAL")
								(list "ID"  mmval)
							)
						)
						(setq misel1 nil)
					)
				)
				(setq con1 (+ con1 1))
			)
		)
	)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;


;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: BDATA
;;OBJETO: XINAT1. Introduce atributos de una entidad
;;	considerando los atributos del LAYOUT respetando aquellos
;;	que no sean incluidos en el argumento de nuevos valores.
;;	Formato:
;;	((1000 . "NomAtt,ValAtt") (...) ...)
;;DEVUELVE: 
;;	>
;;ARGUMENTOS
;;	1. LISNOM1 Lista de nombre de atributos o primer valor
;;	de cada elemento "XXX,..."
;;	> ("xxx" "xxx" ...)
;;	2.	LISNOM2. Lista de valor de atributos o segundo elemento
;;	de cada elemento "...,XXX"
;;	> ("xxx" "xxx" ...)
;;	3. NOMAPP. Nombre de la aplicacion
;;	>	"xxx"
;;	4. NOMELE. Nombre del elemento
;;	5. NOMBENT. Nombre de entidad
;;DEPENDIENTES
;;	> XIN2 ();
;;ANOTACIONES
;;	>	1. El orden de la lista1 (NomAtt) debe corresponder
;;	> con el orden de la lista2 (ValAtt).
;;	> 2. Introduce los datos con el codigo 1000
;;	> 3. Cuando el atributo del elemento no se especifica
;;	se conserva el existente y si aun no se encuentra
;;	en el elemento, se define con valor "-".
;; > 4. El numero de elementos de la primera lista
;;	(NomAtt) nunca puede ser menor a la segunda lista
;;	(ValAtt).
;;;(brkstep '("") "001TEMP" "")
;;;;****************************************
;;PR...
(defun  xinat1
	(lisnom1 lisnom2 nomapp 
		nomele nombent	/ elemenf
	)
	;(brkstep
	;	'("lisnom1" "lisnom2" "nomapp" "nomele" "nombent")
	;	"00" "XINAT1"
	;)
	(cond
		(
			(>= (length lisnom1) (length lisnom2))
			(setq elemfn
				(jo2 (list lisnom1 lisnom2) "-")
			)
			;(brkstep '("elemfn" "lisnom1" "lisnom2") "01" "XINAT1")
			(cond
				(
					(not (= elemfn nil))
					(xin2 nomapp nombent nomele elemfn)
				)
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:BDATA
;;OBJETO: PLPANEL
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.NNEE. Lista de nombre de entidades
;;	>
;;	2.LLAA. Lista de atributos en orden:
;;		1.ELEMENTO
;;		2.TABLERO
;;		3.MATERIAL
;;		4.DESPLANTE
;;		5.CERRAMIENTO
;;		6.TOTAL
;;		7.REPETICION
;;		8.CADA
;;		9.CUAN
;;		10.SISTEMA
;;		11.COLOR
;;		12.UTILFACT
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun plpanel (nnee llaa / con1)
	;(brkstep '("nnee" "llaa") "00" "PLPANEL")
	(cond
		(
			(and
				(not (= nnee nil))
				(not (= llaa nil))
			)
			(setq con1 0)
			(while (< con1 (length nnee))
				;(brkstep '("nnee") "01" "plpanel")
				(xinat0
					(list
						"ELEMENTO"
						"TABLERO"
						"MATERIAL"
						"DESPLANTE"
						"CERRAMIENTO"
						"TOTAL"
						"REPETICION"
						"CADA"
						"CUAN"
						"SISTEMA"
						"COLOR"
						"UTILFACT"
					)
					llaa
					"-"
					"XD_NOVIDESA"
					(nth con1 nnee)
				)
				(setq con1 (+ con1 1))
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:BDATA
;;OBJETO: ALZPANEL
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.NNEE. Lista de nombre de entidades
;;	>
;;	2.LLAA. Lista de atributos en orden:
;;		1.ELEMENTO
;;		2.TABLERO
;;		3.MATERIAL
;;		4.SISTEMA
;;		5.COLOR
;;		6.IDREFPL
;;		7.UTILFACT
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun alzpanel (nnee llaa / con1)
	;(brkstep '("nnee" "llaa") "00" "ALZPANEL")
	(cond
		(
			(and
				(not (= nnee nil))
				(not (= llaa nil))
			)
			(setq con1 0)
			(while (< con1 (length nnee))
				;(brkstep '("nnee") "01" "ALZPANEL")
				(xinat0
					(list
						"ELEMENTO"
						"TABLERO"
						"MATERIAL"
						"SISTEMA"
						"COLOR"
						"IDREFPL"
						"UTILFACT"
					)
					llaa
					"-"
					"XD_NOVIDESA"
					(nth con1 nnee)
				)
				(setq con1 (+ con1 1))
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:BDATA
;;OBJETO: SELDATA
;;	> Apartir de una seleccion dada y dos listas:
;;	1a Nombre de atributos
;;	2a Valor de atributos correspondiente a la lista anterior
;; Devuelve el nombre de entidad que corresponde a los atributos
;;	en la aplicacion "XD_NOVIDESA" Y codigo 1000 
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.SS2. Seleccion 
;;	> SelectionSet
;;	2.LLAA. Lista de nombre de atributos
;;	3.VVAA. Lista de valores de atributos correspondiente
;;		la lista anterior.
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun seldata
	(ss2 llaa vvaa / con1 nomsel licoma lico1 licof fnum)
	(setq con1 0)
	(cond
		(
			(and
				(not (= ss2 nil))
				(not (= llaa nil))
				(not (= vvaa nil))
			)
			(setq nomsel (noment ss2))
			(cond
				(
					(not (= nomsel nil))
					(setq licoma
						(txl
							(jo2 (list llaa vvaa) "-")
							3
							","
						)
					)
					;(brkstep '("licoma") "01" "SELDATA")
					(while (< con1 (length licoma))
						(setq lico1 (cons 1000 (nth con1 licoma))
							licof (append licof (list lico1))
						)
						(setq con1 (+ con1 1))
					)
					;(brkstep '("licof") "02" "SELDATA")
					(setq fnum
						(exnoma "XD_NOVIDESA" licof nomsel)
					)
				)
			)
		)
	)
	;(brkstep '("fnum") "03" "SELDATA")
	(setq fnum fnum)
)
;
;;
;;;
;;;;


;
;;
;;;
;;;;
;;PROYECTO:NV
;;CLASIFICACION: HCL (herramientas de cerramiento)
;;OBJETO:NEAPTO: A partir de una lista de coordenadas y un punto de referencia
;;	selecciona la coordenada mas cercana o mas lejana segun el modo
;;	de resultado.
;;	> (XYZ)
;;DEVUELVE: Coordenada mas cercana o lejana segun modo de resultado
;;	> En modo 0: Devuelve el punto mas cercano
;;	> En modo 1: Devuelve el punto mas lejano
;;ARGUMENTOS
;;	1.LS1: Lista de coordenadas de trabajo
;;	>((XYZ) (…) …)
;;	2.COO: Coordenada de comparacion
;;	> (X Y Z)
;;	3.Modo de resultado
;;	>0. Devuelve el punto mas cercano
;;	>1. Devuelve el punto mas lejano
;;DEPENDIENTES
;;	> ORDEN3 ()
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun neapto (ls1 coo mmr / con1 plider lside ptof)
	;;(brkstep '("ls1" "coo" "mmr") "00" "NEAPTO")
	(cond
		(
			(and 
				(= (type ls1) 'LIST)
				(= (type coo) 'LIST)
				(= (type mmr) 'INT)
			)
			(setq con1 0)
			(while
				(< con1 (length ls1))
				(setq plider
					(list
						(distance coo (nth con1 ls1))
						(nth con1 ls1)
					)
					lside
					(append lside
						(list plider)
					)
					con1 (+ con1 1)
				)
			)
			;;(brkstep '("plider" "lside") "01" "NEAPTO")
			(setq lside (orden3 lside 0 0))
			;;(brkstep '("lside") "02" "NEPTO")
			(cond
				(
					(= mmr 0)
					(setq ptof (nthx '(0 1) lside))
					;;(brkstep '("ptof") "02A" "NEAPTO")
				)
				(
					(= mmr 1)
					(setq ptof
						(nthx
							(list 
								(- (length lside) 1)
								1
							)
							lside
						)
					)
					;;(brkstep '("ptof") "02B" "NEAPTO")
				)
			)
		)
	)
	(setq ptof ptof)
)
;
;;
;;;;
;;OBJETO.PAN10
;;	A partir de la definicion del indice de pendiente y el sistema constructivo;
;; genera la panelizacion por seleccion manual
;;	1. VALPEND: Valor del componente que guarda el indice de pendiente de
;;	seccion transversal.
;;		"nop": Penidente indefinida (linea Vertical)
;;		"0" Pendiente 0 (linea horizontal)
;;		"1" Pendiente positiva
;;		"2" Pendiente negativa
;; 2.- VALSIS: 
;;	"0" Valor del componente del sistema "IKOS".
;;	"1" Valor del componente del sistema "MAKROS".
;;	"2" Valor del componente del sistema "HOLMAK".
;;PR...
(defun pan10 (valpend valsis / iss pend)
	(setq iss 0)
	(cond 
		(
			(= valsis "0")
			(setq iss 0)
		)
		(
			(= valsis "1")
			(setq iss 1)
		)
		(
			(= valsis "2")
			(setq iss 2)
		)
	)
	(setq pend 0)
	(cond
		(
			(= valpend "0")
			(setq pend 0)
		)
		(
			(= valpend "non")
			(setq pend "nop")
		)
		(
			(= valpend "1")
			(setq pend 1)
		)
		(
			(= valpend "2")
			(setq pend 2)
		)
	)
	(panel10 pend iss)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: DEP
;;OBJETO: BOLI
;;	> > Inserta circulos en las coordenadas definidas en la lista
;;	de argumentos.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. BIP: Lista de coordenadas
;;	> ( (x y z) (x y z) (...) ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;  boli :inserta bolitas
;; Argumento:bip Lista de coordenadas
;;PR...
(defun boli (bip / con)
	(setq con 0)
	(while (< con (length bip))
		(command "circle" (nth con bip) 0.01)
		(setq con (+ con 1))
    )
)
;
;;
;;;
;;;;
;;PROYECTO:NV
;;CLASIFICACION: HCL
;;OBJETO:CLDV; Define las coordenadas de cerramiento
;;	de lineas divergentes
;;	> ((XYZ) (XYZ) (XYZ) )
;;DEVUELVE: Coordenadas de conexion en el siguiente orden
;;	>1. coordenada mas cercana al punto de seleccion a la primera linea
;;	2. coordenada de interseccion entre las dos perpendiculares
;;	3. coordenada mas cercana al punto de aplicacion de la segunda linea
;;ARGUMENTOS
;;	1.VLIS.Lista de nombre de entidad y coordenada de seleccion
;; de cada entidad.
;;	> ( (ENAME (XYZ)) (…) …)
;;	2. POSL. Par de posiciones (nth) de elementos en lista del argumento anterior
;;	 para trabajar
;;	> (N N)
;;DEPENDIENTES
;;	>NTHX (); SUMANG (); NEAPTO (); LSCOD ()
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun cldv
	(vlis posl / coor1 coor2 pin1 pin3 ptfin
		angi1 angi2 pin1a pin2a variprec)
	;(brkstep '("vlis" "posl") "00" "CLDV")
	(setq variprec (getvar "luprec"))
	(setvar "luprec" 8)
	(cond
		(
			(and
				(= (type vlis) 'LIST)
				(= (type posl) 'LIST)
			)
			(setq coor1
				(lscod
					(nthx (list (nth 0 posl) 0) vlis)
					(list 10 11)
				)
				coor1
				(mapcar 'cdr coor1)
			)
			;;*coor1 ( (XYZ) (XYZ) )
			;(brkstep '("coor1") "00" "CLDV")
			(setq coor2
				(lscod
					(nthx (list (nth 1 posl) 0) vlis)
					(list 10 11)
				)
				coor2
				(mapcar 'cdr coor2)
			)	
			;;*coor2 ( (XYZ) (XYZ) )
			;(brkstep '("coor2") "01" "CLDV")
			(setq pin1
				(neapto
					coor1
					(nthx (list (nth 0 posl) 1) vlis)
					0
				)
			)
			;;pin1 (X Y Z)
			(setq pin2
				(neapto
					coor2
					(nthx (list (nth 1 posl) 1) vlis)
					0
				)
			)
			;;pin2 (X Y Z)
			;(brkstep '("pin1" "pin2") "02" "CLDV")
			(setq angi1 (angle (nth 0 coor1) (nth 1 coor1))
				angi1 (sumang angi1 1.5708)
			)
			;(brkstep '("angi1") "03" "CLDV")
			(setq pin1a
				(polar  pin1 angi1 1)
			)
			;(brkstep '("pin1a") "04" "CLDV")
			(setq angi2 (angle (nth 0 coor2) (nth 1 coor2))
				angi2 (sumang angi2 1.5708)
			)
			;(brkstep '("angi2") "05" "CLDV")
			(setq pin2a
				(polar pin2 angi2 1)
			)
			;(brkstep '("pin2a") "06" "CLDV")
			(setq pin3
				(inter
					pin1
					pin1a
					pin2
					pin2a
					8
				)
			)
			;(brkstep '("pin3") "07" "CLDV")
			(cond
				(
					(not (= pin3 nil))
					;;*Pin3 (X Y Z)
					(setq  ptfin (list pin1 pin3 pin2))
					;(brkstep '("ptfin") "08" "CLDV")
				)
			)
		)
	)
	(setvar "luprec" variprec)
	(setq ptfin ptfin)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: MAT
;;OBJETO: CORIN. Verifica si un punto se encuentra dentro de una recta
;;	>
;;DEVUELVE: 0 Si el punto no se encuentra dentro de la recta; 1 Si el punto
;;		se encuentra dentro de la recta.
;;	> 
;;ARGUMENTOS
;;	1.LCOR0. Lista de coordenadas de la recta
;;	> ((XYZ) (XYZ))
;;	2.pto10. Punto de comparacion
;; > (XYZ)
;;	3.PREC0. Numero de decimales de precision predeterminado 3
;;	maximo 5
;;	> Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Distancia (P1 Pc) + (Pc P2) = P1 P2
;;	> Tiene un factor de error de 0.0005
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun corin
	(lcoor0 pto10 prec0 / 
	;	resa ds1 ds2 ds3 prec numr varpre
	)
	(setq resa nil ds1 nil ds3 nil prec nil numr nil varpre nil
		lcoor nil pto1 nil prec nil
	)
	;(brkstep '("lcoor0" "pto10" "prec0") "00" "CORIN")
	(setq varpre (getvar "luprec"))
	(setvar "luprec" 8)
	(setq resa 0)
	(cond
		(
			(= prec nil)
			(setq numr 0.00002)
			(setq prec 5)
		)
		(
			(= prec 1)
			(setq numr 0.1)
		)
		(
			(= prec 2)
			(setq numr 0.01)
		)
		(
			(= prec 3)
			(setq numr 0.001)
		)
		(
			(= prec 4)
			(setq numr 0.0002)
		)
		(
			(= prec 5)
			(setq numr 0.00002)
		)
		(
			(= prec 6)
			(setq numr 0.000002)
		)
		(
			(= prec 7)
			(setq numr 0.0000002)
		)
		(
			(= prec 8)
			(setq numr 0.00000002)
		)
	)
	(cond
		(
			(and
				(< 1 (length lcoor0))
				(< 1 (length pto10))
			)
			(setq prec prec0
				lcoor lcoor0
				pto1 pto10)
			;(brkstep '("prec" "lcoor" "pto1") "00A" "CORIN")
			(setq ds1
				(distance
					(roundcor (nth 0 lcoor) prec)
					(roundcor pto1 prec)
				)
				ds2
				(distance
					(roundcor (nth 1 lcoor) prec)
					(roundcor pto1 prec)
				)
				ds3
				(distance 
					(roundcor (nth 0 lcoor) prec)
					(roundcor (nth 1 lcoor) prec)
				)
			)
			;(brkstep '("ds1" "ds2" "ds3" "(+ ds1 ds2)") "01" "CORIN")
			(cond
				(
					(equal (+ ds1 ds2) ds3 numr)
					(setq resa 1)
				)
			)
		)
	)
	(setvar "luprec" varpre)
	(setq resa resa)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: HCL (Herramientas de cerramiento)
;;OBJETO: CPL. Metodo de conexion de lineas paralelas por
;;	metodo de seleccion o fence.
;;	> 
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. APPNOM. Nombre de aplicacion
;;	> "XXX" O ()
;;	2. LISCODI. Lista de codigos para filtra la seleccion.
;;	> '((codigo . valor) (...) ...) 0 ()
;;	3. PRECI. Numero entero para definir la precision
;;	> Numero de decimales.
;;DEPENDIENTES
;;	> FSEL (); LSCOD (); LININ (); PARC (); CORIN (); NEAPTO (); LNPO3 ()
;;ANOTACIONES
;;	> Los filtros de seleccion solamente aplica al metodo de seleccion "Fence"
;;	> La precision de trabajo es de 0.00002 (5)
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun cpl
	(appnom  liscodi preci /
		indsel ppaa pp0 ppr pp1a
		ccon1 ccon2 corcon nnom
		coor1 pton pton0 indcod
		indcoor codcam newenti
		c1 c2 an1 an2 an2a p1 test1 idcor
		miprec parpas appfil
		selection ppas coor1a
		numdec
	)
	(cond
		((= peci nil)(setq numdec 0.00002))
		((= preci 1)(setq numdec 0.1))
		((= preci 2)(setq numdec 0.01))
		((= preci 3)(setq numdec 0.001))
		((= preci 4)(setq numdec 0.0002))
		((= preci 5)(setq numdec 0.00002))
		((= preci 6)(setq numdec 0.000002))
		((= preci 7)(setq numdec 0.0000002))
		((= preci 8)(setq numdec 0.00000002))
	)
	;(brkstep '("appnom" "liscodi" "preci") "00" "CPL")
	(setq miprec (getvar "luprec"))
	(setvar "luprec" 8)
	(setq ppas 1)
	(while (= ppas 1)
		(setq pp1a nil)
		(cond
			(
				(and
					(not (= appnom nil))
					(not (= liscodi nil))
				)
				(setq appfil
					(append
						(list 
							(list -3 (list appnom))
						)
						liscodi
					)
				)
				;(brkstep '("appfil") "01A" "CPL")
			)
			(
				(and
					(not (= appnom nil))
					(= liscodi nil)
				)
				(setq appfil
					(list
						(list -3 (list appnom))
					)
				)
				;(brkstep '("appfil") "O1B" "CPL")
			)
			(
				(and
					(= appnom nil)
					(not (= liscodi nil))
				)
				(setq appfil liscodi)
				;(brkstep '("appfil") "O1C" "CPL")
			)
			(
				(and
					(= appnom nil)
					(= liscodi nil)
				)
				(setq appfil nil)
				;(brkstep '("appfil") "O1D" "CPL")
			)
		)
		(initget 128 "Fence Seleccion")
		(setq indsel
			(getkword "SELECCIONE EL MODO DE SELECCION [Fence / Seleccion]: \n")
		)
		;**INDSEL "Fence" / "Seleccion"
		;(brkstep '("INDSEL") "02" "CPL")
		(cond
			(
				(= indsel "Fence")
				(setq pp1a (fsel "LINE" preci appfil))
				;(brkstep '("PP1A" "(length pp1a)") "03A" "CPL")
			) ;;PP1A  ((ENAME(XYZ)) (...) ...)
			(
				(= indsel "Seleccion")
				(setq pp0 1
					selection (ssadd)
				)
				(while
					(not (= pp0 nil))
					(setq pp0 (nentsel "SELECCIONE EL LA LINEA DE CERRAMIENTO: \n"))
					;**PP0 (ENAME (X Y Z))
					;(brkstep '("PP0") "3B" "CPL")
					(cond
						(
							(not (= pp0 nil))
							(setq selection (ssadd (car pp0) selection))
							(camb (list (car pp0)) 3)
							(setq pp1a (append pp1a  (list pp0)))
							;**PP1A ((ENAME (X Y Z)) (...) ...)
							;(brkstep '("PP0" "PP1A") "3C" "CPL")
						)
					)
				)
				(cond
					(
						(not (= selection nil))
						(cond
							(
								(< 0 (sslength selection))
								(camb (noment selection) 4)
							)
						)
					)
				)
				;**selection... SelectionSet 
				;**PP1A ((ENAME (X Y Z)) (...) ...)
				;(brkstep '("pp1a" "selection" "(length pp1a)") "04" "CPL")
			)
		)
		;**PP1A. ((ENAME (XYZ)) (...) )
		;(brkstep '("pp1a" "(length pp1a)") "05" "CPL")
		(cond
			(
				(not (= pp1a nil))
				(setq ccon1 0)
				(setq ccon2 1)
				(while (< ccon2 (length pp1a))
					(setq parpas 1)
				;;VERIFICACION DE LINEAS PARALELAS (0)
					(while
						(and (= parpas 1) (< ccon2 (length pp1a)))
						(setq c1
							(lscod (nthx (list ccon1 0) pp1a) '(10 11))
							c1 (mapcar 'cdr c1)
						)
						;**C1. ((XYZ) (XYZ))
						(setq c1
							(list
								(roundcor (nth 0 c1) preci)
								(roundcor (nth 1 c1) preci)
							)
						)
						;**C1 ( (X1 Y1 Z1) (X2 Y2 Z2) );Control de decimales
						;(brkstep '("c1") "05A" "CPL")
						(setq c2
							(lscod (nthx (list ccon2 0) pp1a) '(10 11))
							c2 (mapcar 'cdr c2)
						)
						;(brkstep '("c2") "05B" "CPL")
						;**C2 ( (XYZ) (XYZ) )
						(setq c2
							(list
								(roundcor (nth 0 c2) preci)
								(roundcor (nth 1 c2) preci)
							)
						)
						;;C2 ( (X1 Y1 Z1) (X2 Y2 Z2) ) LINEA 2. Control de decimales
						;(brkstep '("C1" "C2") "06" "CPL")
						(setq an1
							(round1
								(angle (nth 0 c1) (nth 1 c1))
								preci
							)
						);**AN1 XX.XX Angulo linea 1
						(setq an2
							(round1
								(angle (nth 0 c2) (nth 1 c2))
								preci
							)
						);**AN1 XX.XX Angulo linea 2
						(setq an2a
							(round1
								(angle (nth 1 c2) (nth 0 c2))
								preci
							)
						);**AN1 XX.XX Angulo linea 2 (inverso)
						;(brkstep '("an1" "an2" "an2a") "07" "CPL")
						(setq test1 nil)
						(cond
							(
								(or
									(equal an1 an2 numdec)
									(equal an1 an2a numdec)
								)
								(setq test1 T)
							)
						)
						;(brkstep '("test1") "08" "CPL")
						;**TEST1 NIL = Linea convergente (NO HAY INTERSECCION)
						;**TEST1 T = Linea paralela
						(cond
							(
								(not (= test1 nil))
								(setq parpas 0)
							)
							(
								(= test1 nil)
								(setq ccon2 (+ ccon2 1))
							)
						)
						;**PARPAS = PASE DE SALIDA PARA ENCONTRAR LINEA PARALELA
					)
					;;VERIFICACIN DE LINEAS PARALELAS (1)
					(cond
						(
							(not (= test1 nil))
							(setq corcon
								(parc
									(list
										(nth ccon1 pp1a)
										(nth ccon2 pp1a)
									)
									'(0 1)
									preci ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,,
								)
							)
							(setq corcon
								(list
									(roundcor (nth 0 corcon) preci)
									(roundcor (nth 1 corcon) preci)
								)
							)
							;;CORCON. ((XYZ)(XYZ)).. coordenadas de conexion
							;(brkstep '("corcon") "09" "CPL")
							(setq nnom
								(nthx
									(list ccon2 0)
									pp1a
								)
							)
							;(brkstep '("nnom") "10" "CPL")
							;;(NTH CCON1 PP1A). (ENAME (XYZ)) LINEA1
							;;(NTH (+ CCON1 1) PP1A). (ENAME (XYZ)) LINEA2
							;;NNOM. ENAME... LINEA2
							;;CORCON ((XYZ) (XYZ)) 
							(setq coor1
								(lscod nnom (list 10 11))
							)
							;(brkstep
							;	'("coor1"
							;		"CORCON"
							;		"(corin (mapcar 'cdr coor1) (nth 1 corcon) preci)"
							;	)
							;	"10A" "CPL"
							;)
							(setq idcor
								(corin
									(mapcar 'cdr coor1)
									(nth 1 corcon)
									preci
								)
							)
							;(brkstep
							;	'("coor1" "idcor")
							;	"11" "CPL"
							;)
							;; COOR1 ((10 (XYZ)) (11 (XYZ))) LINEA 2
							;**IDCOR 0
							(cond
								(
									(= idcor 0)
									(setq coor1a (mapcar 'cdr coor1)
										coor1a
										(list
											(roundcor (nth 0 coor1a) preci)
											(roundcor (nth 1 coor1a) preci)
										)
									)
									;;COOR1A ((XYZ) (XYZ)). Control de decimales
									;;DEFINICION DE PUNTO CERCANO (0)
									(setq pton
										(neapto
											coor1a
											(nth 1 corcon)
											0
										)
									)
									;;PTON: (X Y Z) Punto cercano LINEA2
									(setq pton0
										(append (list 0) pton)
									)
									;;PTON0 (0 X Y Z) Punto cercano de comparacion
									;(brkstep '("PTON" "PTON0") "12" "CPL")
									(setq indcoor
										(lnpo3 pton0 coor1 '(1 2 3) 1 numdec)
									);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*************
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*************
									;**INDCOOR ((NUMCOD X Y Z)) Punto cercano con codigo
									(setq codcam (nthx '(0 0) indcoor)
										newenti (cons codcam (nth 1 corcon))
									)
									;(brkstep '("CODCAM" "NEWENTI") "13" "CPL")
									;**CODCAM NUMCOD
									;**NEWENTI (NUMCOD . (XYZ))
									;;DEFINICION DE PUNTO CERCANO (1)
									(cam1 (list nnom) newenti)
								)
							)
							(command "line"
								(cortxt (nth 0 corcon))
								(cortxt (nth 1 corcon))
								""
							);;;;;;;;;;;;;;;;OJOO
							;(command "line"
							;	(nth 0 corcon)
							;	(nth 1 corcon)
							;	""
							;)
						)
					)
					(setq ccon1 ccon2)
					(setq ccon2 (+ ccon2 1))
				)
			)
			(
				(= pp1a nil)
				(setq ppas 0)
			)
		)
	)
	(setvar "luprec" miprec)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: HCL
;;OBJETO: FSEL. Selecciona por el metodo "Fence" los elementos
;;	que correspondan al filtro de seleccion (en su caso).
;;	> ((ENAME (xyz)) (...) ...)
;;DEVUELVE: Lista de entidades (ename) con el punto de interseccion
;;	por donde pasa la trayectoria de seleccion con la entidad
;;	(por ahora linea).
;;	Devuelve la lista en orden de seleccion de la trayectoria.
;;ARGUMENTOS
;;	1.TY: Tipo de entidad (por ahora solo se acepta "LINE")
;;	> "LINE" "INSERT" "LWPOLYLINE" "ARC" "CIRCLE"
;;	2.PPS1: Precision de comparacion numerica
;;	> NNN Numero entero que indica el numero de decimales
;;	3. FILTER: Filtro de seleccion expresado en lista
;;	de pares punteados (DXF)
;;	> ( (cod . Valor) (...) ...)
;;	> Para el filtro de seleccion de una aplicacion Xdata se define:
;;	>(-3 ("app"))
;; Se puede omitir
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Por ahora solo puede aplicar la seleccion a lineas
;;	> 
;;;(brkstep '("") "001TEMP" "")
;;*****************************************************
;;PR...
(defun fsel
	(ty pps1 filter /
		get1 get2 pass seleci
		con1 anni p1 p2 P3
		ele1 ele2 ele3
		selfie seleci addf
	)
	;(brkstep '("ty" "pps1" "filter") "00" "FSEL")
	(cond
		(
			(not (= filter nil))
			(cond
				(
					(= (type filter) 'LIST)
					(cond
						(
							(= (type (nth 0 filter)) 'LIST)
							(setq addf
								(append
									filter
									(list (cons 0 ty))
								)
							)
							;**ADDRF ((N . XX) ( 0 . XX))
							;(brkstep '("ADDF") "01A" "FSEL")
						)
						(
							(not (= (type (nth 0 filter)) 'LIST))
							(setq addf
								(list
									filter
									(cons 0 ty)
								)
							)
							;**ADDRF ((N . XX) ( 0 . XX))
							;(brkstep '("ADDF") "01B" "FSEL")
						)
					)
				)
			)
		)
		(
			(not (= (type filter) 'LIST))
			(setq addf (list (cons 0 ty)))
			;**ADDF ( (0 . XX) )
			;(brkstep '("ADDF") "01C" "FSEL")
		)
	)
	;(brkstep '("ADDF") "02" "FSEL")
	(setq selfie (ssadd))
	(setq
		pass 1
		get1
		(getpoint "Seleccione el pimer punto de la linea de seleccion :")
	)
	;(brkstep '("get1") "03" "FSEL")
	(cond
		(
			(not (= get1 nil))
			(while
				(= pass 1)
				(setq con1 0)
				(setq get2
					(getpoint
						get1
						"seleccione el siguiente punto (enter para terminar) :"
					)
				)
				;(brkstep '("get2") "04" "FSEL")
				(cond
					(
						(not (= get2 nil))
						(setq seleci (ssget "_F" (list get1 get2) addf))
						;(brkstep '("seleci" "(sslength seleci)") "05" "FSEL")
						;**SELECI SelectionSet
						(cond
							(
								(not (= seleci nil))
								(foreach i (noment seleci) (ssadd i selfie))
								(while
									(< con1 (sslength seleci))
									(camb (noment seleci) 3)
									(setq p1 (cdr (assoc 10 (entget (ssname seleci con1)))))
									(setq p2 (cdr (assoc 11 (entget (ssname seleci con1)))))
									;(brkstep '("p1" "p2") "06" "FSEL")
									;**p1 p2 (xyz)
									(setq p3 (inters get1 get2 p1 p2))
									;(brkstep '("p1" "p2" "p3") "07" "FSEL")	
									;**P3 (XYZ)
									(setq ele1 (list (ssname seleci con1) p3))
									;**ELE1 (ename (XYZ))
									;(brkstep '("ELE1") "08" "FSEL")
									(setq ele1
										(list (distance get1 p3) ele1)
									)
									;** ELE1 (## (ename (XYZ)))
									(setq ele2 (append ele2 (list  ele1)))
									(setq ttemp ele2)
									;** ELE2 ((## (ename (XYZ))) (...) ...)
									(setq con1 (+ con1 1))
									;(brkstep
									;	'("ele1" "ele2" "(length ele2)" "con1") "09" "FSEL")
								)
								;(brkstep '("ele2" "(length ele2)") "10" "FSEL")
								(setq ele2 (orden4 ele2 0 0 pps1))
								;(brkstep '("ele2" "(length ele2)") "11" "FSEL");;TEST1
								(setq ele2 (mapcar 'cdr  ele2))
								(setq ele2 (mapcar 'car ele2))
								;**ELE2 ((ename (XYZ)) (...) ...)
								;(brkstep '("ele2") "12" "FSEL")
								(setq ele3 (append ele3 ele2))
								;(brkstep '("ele3") "13" "FSEL")
								(setq ele2 nil)
							)
						)
						(setq get1 get2)
					)	
					(
						(= get2 nil)
						(setq pass 0)
					)
				)
			)
			;(brkstep '("ele2" "(sslength selfie)") "14" "FSL")
			(if (< 0 (sslength selfie))
				(progn
					(camb (noment selfie) 4)
				)
			)
			(setq ele3 ele3)
			;**((ENAME (XYZ)) (...) ....)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: HCL
;;OBJETO: PARC. A partir de la lista de nombre
;;	de entidad y coordenada de seleccion devuelve
;;	el par de coordenadas que conecta las dos lineas
;;	paralelas
;;	>( (XYZ) (XYZ) )
;;DEVUELVE:
;;	>Par de coordenas que conecta perpendicularmente
;;	dos lineas paralelas que inica desde el punto
;;	final de la primera posicion de la lista
;;	(primera linea) y termina con la interseccion
;;	perpendicular de la linea de la segunda posicion
;;(segunda linea).
;;ARGUMENTOS
;;	1.ELE00. Lista de nombre de entidad y coordenada
;;	de aplicacion
;;	> ( (ename (XYZ)) (ename (XYZ)) (...) ...)
;;	2.ELEP0: Lista de par de posiciones de las lineas
;;	de conexion.
;;	>(N N)
;;	3.preci10: Numero de decimales de precision.
;;	> NN Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun parc
	(ele00 elep0 preci10 /
		prim sec angper pper0 pper1 ppfin mppi ele0 elep preci1
	)
	;(brkstep '("ele00" "elep0" "preci10") "00" "PARC")
	;(setq prim nil sec nil pper0 nil pper1 nil ppfin nil mppi nil
	;	ele0 nil elep nil preci1 nil angper nil)
	(setq mppi (getvar "luprec"))
	(setvar "luprec" preci10)
	(cond
		(
			(and
				(= (type ele00) 'LIST)
				(= (type elep0) 'LIST)
			)
			(setq ele0 ele00
				elep elep0
				preci1 preci10
			)
			(setq prim
				(lscod
					(nthx (list (nth 0 elep) 0) ele0)
					(list 10 11)
				)
			)
			;**PRIM ((10 XYZ) (11 XYZ))
			;(brkstep '("PRIM") "01" "PARC")
			(cond
				(
					(not (= prim nil))
					(setq prim (mapcar 'cdr prim))
					(setq prim
						(list
							(roundcor (nth 0 prim) preci1);;InsercionTest
							(roundcor (nth 1 prim) preci1);;InsercionTest
						)
					)
				)
			)
			;(brkstep '("PRIM") "02" "PARC")
			;**PRIM ((XYZ) (XYZ))
			(setq sec
				(lscod
					(nthx (list (nth 1 elep) 0) ele0)
					(list 10 11)
				)
			)
			;**SEC ((10 XYZ) (11 XYZ))
			;(brkstep '("sec") "03" "PARC")
			(cond
				(
					(not (= sec nil))
					(setq sec (mapcar 'cdr sec))
					;(brkstep '("sec") "03TEMP" "PARC")
					(setq sec
						(list
							(roundcor (nth 0 sec) preci1);;InsercionTest
							(roundcor (nth 1 sec) preci1);;InsercionTest
						)
					)
				)
			)
			;**SEC ((XYZ) (XYZ))
			;(brkstep '("sec" "prim") "04" "PARC")
			(cond
				(
					(and
						(not (= prim nil))
						(not (= sec nil))
					)
					(setq angper
						(round1
							(angle (nth 0 prim) (nth 1 prim))
							preci1
						)
					)
					(setq angper
						(round1
							(sumang
								angper
								1.5708
							)
							preci1
						)
					)
					;(brkstep '("angper" "elep" "ele0") "05" "PARC")
					;**ANGPER ##.## angulo perpendicular LINEA1
					(setq pper0
						(neapto
							prim
							(nthx (list (nth 0 elep) 1) ele0)
							0
						)
					)
					;(brkstep
					;	'("pper0" "angper" "(nth 0 sec)" "(nth 1 sec)")
					;	"05Atemp" "PARC")
					;**PPER0 
					;(setq pper1
					;	(inters pper0
					;		(polar pper0 angper 1)
					;		(nth 0 sec)
					;		(nth 1 sec)
					;		nil
					;	)
					;)
					(setq pper1
						(inter pper0 (polar pper0 angper 1) (nth  0 sec) (nth 1 sec) preci1)
					)
					(setq pper1 (roundcor pper1 preci1))
					;**PPER1 (XYZ) Segundo punto de conexion
					;(brkstep '("angper" "pper0" "pper1") "06" "PARC")
					(setq ppfin (list pper0 pper1))
				)
			)
		)
	)
	(setvar "luprec" mppi)
	;(brkstep '("ppfin") "XX" "PARC")
	(setq ppfin ppfin)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: MAT
;;OBJETO: ROUNDCOR. Redondea las cantidades de una coordenada
;;	de acuerdo al numero de decimales definido en el argumento.
;;	>
;;DEVUELVE:
;;	> (x y z) o (x y)
;;ARGUMENTOS
;;	1. COOR0. Coordenada 
;;	> (X Y Z) o (X Y)
;;	2. PRE. Precision... Numero de decimales
;; >	NN
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun roundcor (coor0 pre / coor1)
	(cond
		(
			(not (= coor0 nil))
			(cond
				(
					(and
						(= (type coor0) 'LIST)
						(= (type pre) 'INT)
					)
					(setq coor1 (mapcar '(lambda (i) (rtos i 2 pre)) coor0))
					(setq coor1 (mapcar 'atof coor1))
				)
			)
		)
	)
	(setq coor1 coor1)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:HCL
;;OBJETO: CPL1. Metodo de cerramiento para las lineas divergentes.
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Cierra lineas con su extension a 90 grados de cada una de las lineas.
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun cpl1 ( / pass1)
	(while (= pass1 nil)
		(setq pp (fsel "LINE" 5 ()))
		(cond
			(
				(not (= pp nil))
				(setq pp1 (cldv pp '(0 1)))
				;(brkstep '("pp1") "00" "PRONTOFOO")
				(command "line"
					(cortxt (nth 0 pp1))
					(cortxt (nth 1 pp1))
					(cortxt (nth 2 pp1))
					""
				)
			)
			(
				(= pp nil)
				(setq pass1 1)
			)
		)
	)
)
;
;;
;;;
;;;;

;;************************************************************
;;ACTUALIZADO************************************************
;;PROYECTO: CI
;;CLASIFICACION: LIST
;;OBJETO: PREPOL
;;	> A partir de la definicion del nombre de entidad de una polilinea
;;	 genera la lista de coordenadas de la misma ordenada en ascendente
;;	con la coordenada X de cada punto.
;;DEVUELVE: Lista de coordenadas
;;	> ((X Y) (X Y) ...)
;;ARGUMENTOS
;;	1.PREPOL. Nombre de entidad
;;	> ENAME
;;	2.MIGENPREC. Precision
;;	> Numero entero (numero de decimales).
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun prepol (entpol migenprec / mipos milprec mianprec mi)
	;(brkstep1 '("entpol" "migenprec")
	;	(list entpol migenprec)
	;	"00" "PREPOL"
	;)
	(setq milprec (getvar "luprec")
		mianprec (getvar "auprec")
	)
	(setvar "luprec" migenprec)
	(setvar "auprec" migenprec)
	(cond
		(
			(not (= entpol nil))
			(setq mi entpol)
			(cond
				(
					(and
						(= (type mi) 'ENAME)
						(= (cdr (assoc 0 (entget mi))) "LWPOLYLINE")
					)
					(setq mi (lscod mi '(10))
						mi (mapcar 'cdr mi)
						mi (lva0 mi () 0 migenprec)
					)
					(setq mi (orden4  mi 0 0 migenprec))
					;(brkstep1 '("mi" "Longitud de lista")
					;	(list mi (length mi))
					;	"01" "PREPOL"
					;)
				)
			)
		)
	)
	(setvar "luprec" milprec)
	(setvar "auprec" mianprec)
	;(brkstep1 '("mi")
	;	(list mi)
	;	"01" "PREPOL" 
	;)
	(setq mi mi)
)
;
;;
;;;
;;PROYECTO: CI (CIVIL)
;;CLASIFICACION:LIST. Funciones de trabajo de coordenadas
;;OBJETO: LCOOR1. Apartir de la definicion de una lista de coordenadas,
;;		devuelve la ubicacion (nth) de la coordenada anterior mas proxima
;;		a la coordenada del argumento
;;	>
;;DEVUELVE:
;;	> Numero (nth) de coordenada proxima anterior a la coordenada
;;	de argumento o nil si la coordenada no coincide con la trayectoria.
;;ARGUMENTOS
;;	1. ENE. Nombre de entidad de polilinea
;;	>	ENAME
;;	2. COCO1. Coordenada de punto de localizacion
;;	>	(X X Z) o (X Y)
;;	3. PP1. Precision (numero de decimales)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;***************************
;;PR...
(defun lcoor1
	(ene coco1 pp1 /
		con1 posf try p1 p2
		auvar luvar numr
		indif lsc1
	)
	;(brkstep1 '("ene" "coco1" "pp1")
	;	(list ene coco1 pp1)
	;	"00" "LSCOR1"
	;)
	(cond
		(
			(and
				(not (= ene nil))
				(not (= coco1 nil))
				(not (= pp1 nil))
			)
			(cond
				(
					(= (type ene) 'ENAME)
					(setq lsc1 (prepol ene pp1))
				)
			)
			;(brkstep1 '("lsc1" "coco1" "pp1") (list lsc1 coco1 pp1) "01" "LSCOR1")
			(cond
				(
					(and
						(= (type lsc1) 'LIST)
						(= (type coco1) 'LIST)
						(= (type pp1) 'INT)
					)
					(setq auvar (getvar "auprec"))
					(setq luvar (getvar "luprec"))
					;(brkstep1 '("auvar" "luvar" "pp1")
					;(list auvar luvar pp1)
					;"02" "LSCOR1")
					(cond
						(
							(= pp1 nil)
							(setq numr 0.00002)
							(setq prec 5)
						)
						(
							(= pp1 1)
							(setq numr 0.1)
						)
						(
							(= pp1 2)
							(setq numr 0.01)
						)
						(
							(= pp1 3)
							(setq numr 0.001)
						)
						(
							(= pp1 4)
							(setq numr 0.0002)
						)
						(
							(= pp1 5)
							(setq numr 0.00002)
						)
						(
							(= pp1 6)
							(setq numr 0.000002)
						)
						(
							(= pp1 7)
							(setq numr 0.0000002)
						)
						(
							(= pp1 8)
							(setq numr 0.00000002)
						)
					)
					(setvar "luprec" pp1)
					(setvar "auprec" pp1)
					(setq con1 0)
					;(brkstep1 '("pp1" "numr" "con1") (list pp1 numr con1) "03" "LSCOR1") 
					(cond
						(
							(and
								(not (= lsc1 nil))
								(not (= coco1  nil))
							)
							(setq coco1 (list (nth 0 coco1) (nth 1 coco1)))
							;**COCO1 (XY)
							(while
								(< con1 (- (length lsc1) 1))
								(setq p1 (nth con1 lsc1)
									p2 (nth (+ con1 1) lsc1)
								)
								(cond
									(
										(and
											(not (= p1 nil))
											(not (= p2 nil))
										)
										(setq p1 (list (nth 0 p1) (nth 1 p1))
											p2 (list (nth 0 p2) (nth 1 p2))
										)
									)
								)
								;**P1 (XY)
								;**P2 (XY)
								;(brkstep1 '("lsc1" "P1" "P2" "coco1" "con1")
								;(list lsc1 p1 p2 coco1 con1)
								;"LCOOR1" "02")
								(cond
									(
										(equal p1 coco1 numr)
										(setq indif con1)
										(setq con1 (length lsc1))
										;(brkstep1 '("indif" "con1")
										;(list indif con1)
										;"LCOOR1" "02A")
									)
									(
										(equal p2 coco1 numr)
										(setq indif (+ con1 1))
										(setq con1 (length lsc1))
										;(brkstep '("indif" "con1")
										;(list indif con1)
										;"LCOOR1" "02B")
									)
									(
										(= (corin4 (list p1 p2) coco1 5) 1)
										(setq indif con1)
										(setq con1 (length lsc1))
										;(brkstep1
											;'("indif" "con1" "(corin4 (list p1 p2) coco1 5)")
											;(list indif con1 (corin4 (list p1 p2) coco1 5))
											;"LCOOR1" "02C"
										;)
									)
									(
										(= (corin4 (list p1 p2) coco1 5) 0)
										(setq con1 (+ con1 1))
										;(brkstep1
										;'("indif" "con1" "(corin4 (list p1 p2) coco1 5)")
										;(list indif con1 (corin4 (list p1 p2) coco1 5))
										;"LCOOR1" "02D"
										;)
									)
								)
							)
						)
					)
				)
			)
			(setvar "luprec" luvar)
			(setvar "auprec" auvar)
		)
	)
	;(brkstep1 '("indif")
	;	(list indif)
	;	"LCOOR1" "03"
	;)
	(setq indif indif)
)


;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: PAN (Definiciones de panelizacion)
;;OBJETO: RET0A
;;	> Define las coordenadas que atraviesan un conjunto de entidades
;; definido sus nombres (ename)
;;DEVUELVE:
;;	>((x1 y1 z1) (x2 y2 z2))
;;ARGUMENTOS
;;	1.MIPUN: Punto de inicio
;;	> (X Y Z)
;;	2.MIANG: Angulo de alineacion
;;	> En radianes
;;	3.CPLIN: (lista de nombre de entidades de Polilinea o lineas de area
;;	> (ENAME ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> ATENDER SI EL PUNTO SALE DE UN VERTICE DE LA POLIGONAL
;;PR...
(defun ret0a (mipun miang cplin /
	con0 seg1 con1 miscoo  lpto
	bugg pprob lptoang interpt
	cplin1)
	;(brkstep '("mipun" "miang" "cplin") "00" "RET0A")
	(setq con0 0)
	(while (< con0 (length cplin))
		(setq cplin1 (nth con0 cplin)) ;**CPLIN1 ENAME
		;(brkstep '("CPLIN1" "(cdr (assoc 0 (entget cplin1)))") "01" "RET0A")
		(cond
			(
				(= (cdr (assoc 0 (entget cplin1))) "LINE")
				(setq seg1
					(append seg1
						(list
							(list
								(cdr (assoc 10 (entget cplin1)))
								0
								(cdr (assoc 11 (entget cplin1)))
							)
						)
					)
				)
				;(brkstep '("seg1") "01A" "RET0A")
			)
			(
				(= (cdr (assoc 0 (entget cplin1))) "LWPOLYLINE")
				(setq seg1
					(append seg1
						(seg (lscod cplin1 '(70 10 42)) 1);(((XY) BGL (XY)) (...)...)
					)
				)
				;(brkstep '("seg1") "01B" "RET0A")
			)
		)
		(setq con0 (+ con0 1))
	)
	(setq lpto '()
		con1 0
		mipun
		(list
			(nth 0 mipun)
			(nth 1 mipun)
		) ;;(X Y) *Elimina Z*
	)
	;(brkstep '("seg1") "02" "RET0A")
	(while (< con1 (length seg1))
		(setq miscoo
			(append
				(nth 0 (nth con1 seg1))
				(nth 2 (nth con1 seg1))
			)
		)
		(setq bugg (nth 1 (nth con1 seg1))
			pprob (linin mipun miang miscoo)
			interpt nil
		)
		;(brkstep '("miscoo" "bugg" "pprob" "interpt") "03" "RETOA")
		(cond
			(
				(not (equal bugg 0 0.0000001))
				(setq interpt (curin1 mipun miang () (nth con1 seg1)))
				;(brkstep '("interpt") "04A" "RET0A")
			)
			(
				(and
					(equal bugg 0 0.0000001)
					(not (= pprob nil))
				)
				(cond
					(
						(not (= (nth 0 pprob) nil))
						(setq interpt
							(append
								(list (nth 1 pprob))
							)
						)
						;(brkstep '("interpt") "04B" "RETOA")
					)
				)
			)
		)
		(cond
			(
				(not (= interpt nil))
				(setq lpto
					(append 
						lpto
						interpt
					)
				)
			)
		)
		;(brkstep '("lpto") "05" "RET0A")
		(setq con1 (+ con1 1))
	)
	(cond
		(
			(not (= lpto nil))
			(setq lpto (lva lpto 0 0))
			(cond
				(
					(< 1 (length lpto))
					(setq lptoang
						(angle
							(nth 0 lpto)
							(nth (- (length lpto) 1) lpto)
						)
					)
					(cond
						(
							( or
								(equal
									lptoang
									1.5708
									0.0001
								)
								(equal
									lptoang
									4.71239
									0.0001
								)
							)
							(setq lpto (orden2 lpto 0 1))
						)
						(
							(= 0 0)
							(setq lpto (orden2 lpto 0 0))
						)
					)
				)
			)
		)
	)
	;(brkstep '("lpto" "lptoang") "06" "RETOA")
	(setq lpto lpto)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:DYN
;;OBJETO:GETPROPDYN
;;	> Obtiene el valor del parametro definido en el argumento
;;DEVUELVE:
;;	> Valor de parametro
;;ARGUMENTOS
;;	1.NOMEN. Nombre de entidad
;;	>
;;	2.NOMATT. Nombre del parametro
;;	"xxx"
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun getpropdyn (nomen nomatt / prp blk testip)
	(setq testip (cdr (assoc 0 (entget nomen))))
	(cond
		(
			(= testip "INSERT")
			(setq prp (strcase nomatt))
			(setq blk (vlax-ename->vla-object nomen))
			;(setq dynProp (vlax-invoke dynBlock 'getDynamicBlockProperties))
			(vl-some
				'(lambda ( x )
					(if
						(= prp (strcase (vla-get-propertyname x)))
						(vlax-get x 'value)
					)
				)
				(vlax-invoke blk 'getdynamicblockproperties)
			)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION:DYN
;;OBJETO:SETPROPDYN
;;	> Cambia el parametro de un block dinamico apartir de la definicion
;;	del nombre de entidiad, nombre de parametro y nuevo valor.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.NOMEN. Nombre de entidad
;;	> ENAME
;;	2.NOMATT. Nombre de atributo
;;	> "xxxx"
;;	3. NEWDAT. Nuevo valor de parametro
;;	> Valor
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun setpropdyn (nomen nomatt newdat / prp blk tesitip)
	(setq tesitip (cdr (assoc 0 (entget nomen))))
	(cond
		(
			(= tesitip "INSERT")
			(setq prp (strcase nomatt))
			(setq blk (vlax-ename->vla-object nomen))
			;(setq dynProp (vlax-invoke dynBlock 'getDynamicBlockProperties))
			(vl-some
				'(lambda ( x )
					(if
						(= prp (strcase (vla-get-propertyname x)))
						(progn 
							(vla-put-value x
								(vlax-make-variant
									newdat
									(vlax-variant-type
										(vla-get-value x);;;;;;distinto
									)
								)
							)
							(cond
								(newdat)
								(t)
							)
						)
					)
				)
				(vlax-invoke blk 'getdynamicblockproperties)
			)
		)
	)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;


;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:BDATA
;;OBJETO: METEDAT1
;;	> Actualiza
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. LSNOME. Lista de nombre de entidades
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun metedat1
	(lsnome /
		tabla con1 nuevos nue1 con0
		nome0 lsatt latt0 nomval lsattv
		elein lsattv0 listeles mati tpele idName elein1 elein0
		metAncho metLong metAnchoR metLongR metHand nomOrig
	)
	(setq tabla0 (impdat "rutas.csv"  "ID_BDATOS" "RUTA" "IDE_SALIDA.csv" ())
		tabla (nth 0 tabla0)
		listeles (nth 0 (column tabla0 "ELEMENTO" 0.0001))
	)
	;(brkstep '("tabla" "tabla0" "listeles" "lsnome") "00" "METEDAT1")
	;**Tabla0. Lista de atributos por elemento de cuantificacion
	;** ((ELEMENTO TABLERO MATERIAL DESPLANTE CERRAMIENTO TOTAL CADA ... ANGULO)
	;**	(NomElemento si no ...) (...) ...)
	;** )
	;** TABLA. Lista (encabezado) de elementos.
	;**	("ELEMENTO" "TABLERO" "MATERIAL" ... "ANGULO")
	;**ListEles Lista de todos los elementos (incluyendo el nombre de cabecera))
	(setq con0 0)
	(while  (< con0 (length lsnome))
		(setq nome0 (nth con0 lsnome));**ENAME
		(setq nomOrig nome0);**Transpasa ENAME
		(camb (list nome0) 3)
		(setq nuevos (nxx1 nome0 '(1 2)))
		(setq elein (lnpo '(2 . "VALATT1") nuevos 2 1)
			elein (cdr (nthx '(0 1) elein))
		)
		;**ELEIN. NombreElemento
		;**NUEVO. Lista de atributos del block (con atributos)
		;**		((ENAME (1 . "XXX") (2 . "VALATTXX")) (...) ...)
		;(brkstep '("nome0" "listeles" "elein" "nuevos") "01" "METEDAT1")
		(cond
			(;**condicion. Es un block con atributos de NOVIDESA.
				(= (type elein) 'STR)
				(setq tpele
					(lnpo '(2 . "VALATT12") nuevos 2 1)
					tpele
					(cdr (nthx '(0 1) tpele))
				)
				(setq elein1
					(exl
						(list
							(list
								(sutx elein '(("_" ",")))
							)
						)
						1 0
					)
				)
				;(brkstep '("elein1") "01a" "METEDAT1")
				(cond ;*Rectificación de entidad
					(
						(or
							(= elein "PL_ACCESORIO")
							(= elein "AL_ACCESORIO")
							(= (nth 2 elein1) "INS")
						)
						(setq idName (lnpo '(2 . "VALATT12") nuevos 2 1)
							idName (cdr (nthx '(0 1) idName))
						);**Extraccion de ID
						;**idName. "xxx" ID. de elemento
						;(brkstep '("idName") "01b" "METEDA1")
						(cond
							(;**sin ID
								(or
									(= idName "")
									(= idName " ")
									(= idName "-")
								)
								;(brkstep
								;	'("(list nome0)"
								;		"(cdr (assoc 10 (entget nome0)))"
								;	) "01b1" "METEDAT1"
								;)
								(camb (list nome0) 3)
								(command
									"zoom"
									"C"
									(cortxt (cdr (assoc 10 (entget nome0))))
									0.75
								)
								(princ)
								(prin1)
								(setq elein0 nil)
								(while (= elein0 nil)
									(princ) (prin1)
									(setq elein0
										(car (entsel "Seleccione la entidad referida: "))
									)
								)
								(camb (list nome0) 4)
								(setq nome0 elein0)
								;**nome0. ID de la verdadera entidad
								;**<ENAME>
							)
							(;**con ID <handlet>
								(and
									(not (= idName nil))
									(not (= idName ""))
									(not (= idName " "))
									(not (= idName "-"))
								)
								(setq nome0 (handent idName))
								;** Extraccion de nombre de entidad apartir de idName
								;** nome0 <ENAME>
							)
						)
						;(brkstep '("nome0") "01c" "METEDAT1")
						;** elein. Nombre de entidad rectificado en entidades INS
						;**		ENAME
					)
				)
				(cond
					(;**Definicion de dimensiones largo y ancho
						;**Escritura de ID. en atributos de block
						;**Condicion. Existe nombre de entidad <nome0>
						(not (= nome0 nil))
						(setq metAncho
							(getpropdyn nome0 "DISTANCE1")
						)
						(setq metLong
							(getpropdyn  nome0 "DISTANCE2")
						)
						(cond ;**Escritura de ancho en entidad
							(;**Existe ancho
								(not (= metAncho nil))
								(setq metAnchoR (rtos metAncho 2 2))
								;(brkstep '("metAnchor") "01c1" "METEDAT1")
								(xinat1
									'("ANCHO")
									(list metAnchoR)
									"XD_NOVIDESA" elein nome0
								)
							)
						)
						(cond ;**Escritura de longitud en entidad
							(;**Existe longitud
								(not (= metLong nil))
								(setq metLongR (rtos metLong 2 2))
								(xinat1
									'("LARGO")
									(list metLongR)
									"XD_NOVIDESA"
									elein
									nome0
								)
							)
						)
						;**Ecritura de ID. en atributos de block
						
						(setq metHand (cdr (assoc 5 (entget nome0))))
						;(brkstep '("nomOrig" "nome0" "metHand") "01c2" "METEDAT1")
						(camtag (list nomOrig) "VALATT12" metHand)
						(setq nuevos (nxx1 nomOrig '(1 2)))
						(xinat1
							'("ID")
							(list metHand)
							"XD_NOVIDESA"
							elein
							nome0
						)
					)
				)
				(cond
					(
						(and
							(not (= (compa elein listeles) nil))
							(not (= nome0 nil))
						)
						;(brkstep '("listeles" "elein") "02" "METEDAT1")
						(setq con1 0)
						(setq lsatt (list "ELEMENTO")
							lsattv (list elein)
						)
						;**lsAtt. Lista de nombre de atributos (empieza con "ELEMENTO")
						;** 	("ELEMENTO" nomAtributo ...)
						;**lsAttV. Lista de valor correspondiente en orden con el
						;** nombre del atributo de la lista lsAtt
						;**		(nomElemento si no ....)
						(while (< con1 (length nuevos))
							(setq latt0 (cdr (nthx (list con1 2) nuevos)))
							;**latt0. Tag del atributo numero (con1) de Nuevos
							;**		"VATATTXXX"
							;(brkstep '("latt0") "03" "METEDAT1")
							(cond
								(
									(= (strcase (substr latt0 1 1)) "V")
									(setq nomval (- (atoi (substr latt0 7 (strlen latt0))) 1))
									;(brkstep '("nomval") "04" "METEDAT1")
									;**NOvMVAL. Numero de atributo de block relacionado
									;** con la lista de atributos.
									(cond
										(
											(not (= nomval 0))
											(setq lsatt
												(append lsatt (list (nth nomval tabla)))
											)
											(setq lsattv0 (cdr (nthx (list con1 1) nuevos)))
											(cond
												(
													(or
														(= lsattv0 "")
														(= lsattv0 " ")
													)
													(setq lsattv0 "-")
												)
											)
											(setq lsattv (append lsattv (list lsattv0)))
											;(brkstep '("lsatt" "lsattv") "05" "METEDAT1")
										)
									)
								)
							)
							(setq con1 (+ con1 1))
						)
						;(brkstep '("lsatt" "lsattv" "elein" "nome0") "05" "METEDAT1")
						(xinat1 lsatt lsattv "XD_NOVIDESA" elein nome0)
					)
				)
				(camb (list nomOrig) 4)	
			)
		)
		(setq con0 (+ con0 1))
	)
)
;
;;
;;;
;;;;

;
;;
;;;VA_APR_WALKFRONT
;;;;
;;Metodo CAMTAG Cambia el valor de un atributo a una lista de nombres de blocks
;;Argumentos
;;          1. LSNB Lista sencilla de nombres de blocks
;;          2. TGA TAG del atributo que de desea cambiar
;;          3. VTGA Valor del tag que se desea cambiar
(defun camtag (lsnb tga vtga / cnna tga1 vtga nnb1 attn attn1)
  (setq cnna 0
	tga1 (cons 2 tga)
	vtga (cons 1 vtga)
	)
	;(brkstep1 '("cnna" "tga1" "vtga") (list ccna tga1 vtga) "01" "CAMTAG")
  (while (< cnna (length lsnb))
    (setq nnb1 (nth cnna lsnb)
	  attn (nxx1 nnb1 '(1 2))
	  attn1 (exid attn tga1)
	  )
	  ;(brkstep1 '("nnb1" "attn" "attn1") (list nnb1 attn attn1) "02" "CAMTAG")
    (cond
      (
       (not (= attn1 nil))
       (setq attn1 (nth 0 (nth 0 attn1)))
       (cam1 (list attn1) vtga)
       )
      )
    (setq cnna (+ cnna 1))
    )
  )
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: EXID3
;;	> Exid con precision  de .001 y modificando el nombre de las variables:
;;	A partir de una lista estructurada (lista de listas) obtiene las listas
;;	que contengan el elemento ID definido en el segundo argumento.
;;DEVUELVE: Lista estructurada de elementos que contengan el elemento "ID"
;;	indicado en el segundo argumento
;;	> ( (xx ...) (xx ...) (...) )
;;ARGUMENTOS
;;	1.LERS: Lista estructurada de elementos
;;	> (("uno" 1 2 3) ("dos" 2 3 4))
;;	2.EIDT: Elemento ID
;;	Cualquier valor
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Solamente trabaja con listas estructuradas, con las listas sencillas
;;	genera error.
;;PR...
(defun exid3 (lers eidt / mood cotn1 cotn2 ptas1 ptas2 ellc finll)
  (setq cotn1 0
	ptas1 0
	finll nil
	mood 0
	)
  (while (< cotn1 (length lers))
    (setq ellc (nth cotn1 lers)
	  cotn2 0
	  ptas2 0)
    (cond (
	   (= mood 0)
	   (while (< cotn2 (length ellc))
	     (cond (
		    (equal (nth cotn2 ellc) eidt 0.001)
		    (setq cotn2 (length ellc)
			  ptas2 1
			  )
		    )
		   (
		    (not (equal (nth cotn2 ellc) eidt 0.001))
		    (setq cotn2 (+ cotn2 1))
		    )
		   )
	     )
	   )
	  
	  )
    (cond
      (
       (= ptas2 1)
       (cond
	 (
	  (= ptas1 0)
	  (setq finll (list ellc)
		ptas1 1)
	  )
	 (
	  (= ptas1 1)
	  (setq finll (append finll (list ellc)))
	  )
	 )
       )
      )
    (setq cotn1 (+ cotn1 1))
    )
  (setq finll finll)
  )
  ;
  ;;
  ;;;
  ;;;;
  ;;PROYECTO: NV
;;CLASIFICACION: TRZ
;;OBJETO: DIVMUL. Apartir de la seleccion (nentsel) y definicion de
;;	Modo de division (divmu), distancia de division; define las coordenadas
;;	de division sobre la linea. (ejecuta divmu)
;;	>
;;DEVUELVE:
;;	> ((XYZ) Distancia) (...) ...)
;;ARGUMENTOS
;;	1. DISTI. Distancia de segmentacion
;;	> Numero real
;;	2. MODIV. Modo de distribucion de segmentos
;;		0. Distribucion al centro
;;		1. Distribucion en el primer punto
;;		2. Distribucion en el segundo punto
;;	3. PPRE. Precision numerica
;;	> Numero entero (numero de decimales)
;;	4. DISTIM. Distancia minima de division
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun divmul (disti modiv ppre distim  / misile selcor concoor punto)
	;(setq misile nil selcor nil concoor nil  punto nil)
	;(brkstep '("disti" "modiv" "ppre" "distim") "00" "DIVMUL")
	(setq misile (nentsel))
	(cond
		(
			(not (= misile nil))
			(setq selcor (nth 1 misile)
				concoor (mapcar 'cdr (lscod (nth 0 misile) (list 10 11)))
				punto (neapto concoor selcor 0)
			)
			;(brkstep '("selcor" "concoor" "punto") "01" "DIVMUL")
		)
	)
	(cond
		(
			(equal punto (nth 1 concoor))
			(setq concoor (list (nth 1 concoor) (nth 0 concoor)))
		)
	)
	(setq concoor concoor)
	;(brkstep '("concoor" "disti" "modiv" "ppre" "distim") "02" "DIVMUL")
	(divmu (nth 0 concoor) (nth 1 concoor) disti modiv ppre distim)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: TRZ
;;OBJETO: BLARRAY. A partir de la definicion de block dinamico
;;		nombre del parametro de ajuste sobre la linea de insersion,
;;		nombre de parametro de ajuste perpendicular,
;;		distancia (valor) de segundo parametro,
;;		lista de posiciones y distancias
;;		inserta el grupo de blocks 
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.NOMBL. Nombre de block dinamico
;;	> "XXX" (nombre dwg)
;;	3.NOMDIS. Nombre del parametro que modifica la distancia de ajuste sobre la linea
;;	> "xxx"
;;	4.NOMDISP. Nombre del parametro que modifica la distancia perpendicular (opcional)
;;	> "XXXX"
;;	5.DISPER. Distancia perpendicular a la linea (opcional)
;;	> #.#
;;	4.LSINS. Lista de distancia de insercion
;;	>	((XYZ) DIST) (...) ...)
;;	5.LSATT. Lista de atributos
;;	>	((NOMATT VALATT) (...) ...)
;;	6.PPREDI. Precision numerica.
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> La ruta de insercion de blocks la busca en el archivo de rutas.csv
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun blarray
	(nombl nomdis nomdisp disper lsins lsatt pprezi /
		conta mitram anglins nomins midia lsvalats conta0 valnom
		ppredi lsatt1 coorins entiblock datt1 conta2)
	;(setq conta nil mitram nil anglins nil nomins nil midia nil
	;	lsvalats nil conta0 nil valnom nil ppredi nil lsatt1 nil
	;	coorins nil entiblock nil datt1 nil conta2 nil
	;)
	;(brkstep
	;	'("nombl" "nomdis" "nomdisp" "disper"
	;		"lsins" "lsatt" "pprezi" "conta"
	;	)
	;	"00" "blarray"
	;)
	(cond
		((= pprezi 1)(setq ppredi 0.1))
		((= pprezi 2)(setq ppredi 0.01))
		((= pprezi 3)(setq ppredi 0.001))
		((= pprezi 4)(setq ppredi 0.0001))
		((= pprezi 5)(setq ppredi 0.00001))
		((= pprezi 6)(setq ppredi 0.000001))
		((= pprezi 7)(setq predi 0.0000002))
		((= pprezi 8)(setq ppredi 0.00000002))
	)
	(setq midia (getvar "attdia"))
	(setvar "attdia" 0)
	(setq conta0 0
		anglins
		(angle
			(nthx '(0 0) lsins)
			(nthx (list (- (length lsins) 1) 0) lsins)
		)
	)
	;;DEFINICION DE LISTA DE ATRIBUTOS (NOMBRE TAG) (0)
	(setq lsvalats (nth 0 (impdat "rutas.csv" "ID_BDATOS" "RUTA" "IDE_SALIDA.csv" ())))
	;(brkstep '("conta" "anglins" "lsvalats" "lsatt" "(length lsatt)") "01" "BLARRAY")
	(while (< conta0 (length lsatt))
		;(brkstep
		;	'("(qnth lsvalats (nthx (list conta0 0) lsatt) ppredi)"
		;		"conta0"
		;	)
		;	"01a" "BLARRAY"
		;)
		(setq valnom (qnth lsvalats (nthx (list conta0 0) lsatt) ppredi))
		;(brkstep '("valnom" "lsatt") "02" "BLARRAY")
		(cond
			(
				(not (= valnom nil))
				(setq valnom (strcat "VALATT" (itoa (+ (nth 0 valnom) 1))))
				(setq lsatt1
					(append lsatt1
						(list
							(list valnom
								(nthx (list conta0 1) lsatt)
							)
						)
					)
				)
			)
		)
		(setq conta0 (+ conta0 1))
		;(brkstep '("lsatt1") "03" "BLARRAY")
	)
	;** LSATT1. (("VALATTXX" "XXX") (...) ...)
	;;DEFINICION DE LISTA DE ATRIBUTOS (NOMBRETAG VALTAG) (1)
	(setq conta 0)
	;(brkstep
	;	'("conta" "lsins" "(length lsins)") 
	;	"04" "BLARRAY"
	;)
	(while
		(< conta (length lsins))
		;(brkstep '("(onam (list nombl) \"BLOCK\" 0)") "04a" "BLARRAY")
		(cond
			(
				(= (onam (list nombl) "BLOCK" 0) nil)
				(setq nomins nombl)
			)
			(
				(not (= (onam (list nombl) "BLOCK" 0) nil))
				(setq nomins
					(strcat
						(obten "rutas.csv" "BLOCKS" "RUTA")
						nombl
						".dwg"
					)
				)
			)
		)
		(setq mitram (nth conta lsins))
		(setq coorins (cortxt (nth 0 mitram)))
		;(brkstep '("mitram" "coorins" "nomins") "05" "BLARRAY")
		(command "insert" nomins coorins 1 1 (round1 (dtr2 anglins) 3))
		(setq entiblock (entlast))
		;(brkstep
		;	'("entiblock" "nomdis" "nomdisp" "disper" "(nth 1 mitram)")
		;	"06" "BLARRAY"
		;)
		(setpropdyn  entiblock nomdis (nth 1 mitram))
		(cond
			(
				(and (not (= disper nil))
					(not (= nomdisp nil))
				)
				(setpropdyn entiblock nomdisp disper)
			)
		)
		(setq conta2 0)
		;(brkstep '("conta2" "lsatt1") "07" "BLARRAY")
		(while (< conta2 (length lsatt1))
			(camtag
				(list entiblock)
				(nth 0 (nth conta2 lsatt1))
				(nth 1 (nth conta2 lsatt1))
			)
			(setq conta2 (+ conta2 1))
			;(brkstep '("conta2") "08" "BLARRAY")
		)
		(setq conta (+ conta 1))
		;(brkstep '("conta") "09" "BLARRAY")
	)
)


;;PROYECTO: NV
;;CLASIFICACION:CUAN
;;OBJETO: LSTELEM. Extrae la lista de elementos y material para
;;		la seleccion en su cuantificacion
;;	>
;;DEVUELVE: Lista de elementos cuantificables en con su respectivo material
;;		y cantidad unitaria
;;	>((MatNat CU EleNat1 ...) (MatDetalle CU EleNat1 ... EleDet1 ...) ...)
;;ARGUMENTOS
;;	1.LSMAT1. Lista de material y elementos de cuantificacion
;;		Solo de un material (extraido de Salida.csv)
;;	> ((MAT FORMULA)
;;		(CU CANTIDAD)
;;		(D-XX CANTIDAD) ... (D-XX- CANTIDAD)
;;		(BLOCK_PL XXX) (PLINE_PL XXX) (MLINE_PL XXX) (ENTIDAD_PL XXX)
;;		(BLOCK_AL XXX) (PLINE_AL XXX) (MLINE_AL XXX) (ENTIDAD_AL XXX)
;;		)
;;	2. LSDET1. Lista de representacion de detalles.
;;	> (
;;			(CLAVE BLOCK_PL PLINE_PL MLINE_PL ENTIDAD_PL
;;				BLOCK_AL PLINE_AL MLINE_AL ENTIDAD_AL
;;			)
;;			("DXXX" "XX" "XX" "XX" "XX" "XX" "XX" "XX" "XX")
;;			(...) ...
;;		)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun lstelem
	(lsmat1 lsdet1 /
		contad lisin lisel1 limadet lisel0 contad1 lselemdet lisdat1 lisdet
	)
;	(setq contad nil lisin nil
;		lisel1 nil limadet nil lisel0 nil contad1 nil lselemdet nil
;	)
;;;;Argumentos;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	(setq format nil lisdat nil lisdat1 nil lisdet nil)
;	(setq format
;		(list "MatArea" "Area" "LongdArea" "TransArea"
;			"PzaArea" "MatProd" "LongProd" "TransProd" "PzaProd"
;		)
;	)
;	(setq lisdat1 (lbase (impdat "rutas.csv" "ID_BDATOS" "RUTA" "SALIDA.csv" ())))
;	(setq lisdat1 (nth 13 lisdat1))
;	(setq lisdet (impdat "rutas.csv" "ID_BDATOS" "RUTA" "SALIDA_DET.csv" ()))
	(setq lisdat1 lsmat1
		lisdet lsdet1
	)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;(brkstep '("lisdat1" "lisdet") "01" "APPOY")
	(setq
		limadet
		(lnpo4 "0"
			(cut 2 21 lisdat1)
				1 0 0.0001
		);** Lista de detalles en material
		lselenat (cut 22 (- (length lisdat1) 1) lisdat1)
		lselenat (lnpo4 "no" lselenat 1 0 0.0001);**Lista elementos nativos
		lisel0 (list (nthx '(0 0) lisdat1) (atof (nthx '(1 1) lisdat1)));** Elemento inicial
	)
	;(brkstep '("limadet" "lselenat" "lisel0") "02" "APOY")
	(cond
		(
			(not (= lselenat nil))
			(setq lselenat (bindls (mapcar 'cdr lselenat)))
			(setq lisel0 (append lisel0 lselenat)
				lisel1 (list lisel0)
			)
			;**LSELENAT. Lista de elementos nativos
			;**("XXX" ...)
			;**LISEL0. Elemento inicial de cuantificacion
			;** (mat cu ElementoNativo1 ....)
			;** ((mat cu ElementoNativo1 ...))
			;**LISEL1. Lista inicial de cuantificacion
			;**LIMADET. Lista de materiales en detalles
			;** (("D-1" "#.#") (...) ...) / nil
			;(brkstep '("limadet" "lisel0" "lisel1") "03" "APOY")
			(cond
				(
					(not (= limadet nil))
					(setq contad 0)
					(while (< contad (length limadet))
						(setq lisel0
							(list
								(nthx (list contad 0) limadet)
								(atof (nthx (list contad 1) limadet))
							)	
							lisel0 (append lisel0 lselenat)
							lselemdet
							(nth 0
								(lnpo4
									(nthx (list contad 0) limadet)
									lisdet
									0
									1
									0.0001
								)
							)
							lselemdet (txno (cdr lselemdet) "no")
						)
						;(brkstep '("lisel0" "lselemdet") "03" "APOY")
						(cond
							(
								(not (= lselemdet nil))
								(setq lisel0 (append lisel0 lselemdet))
								;(brkstep '("lisel0") "04" "APOY")
							)
						)
						(setq lisel0
							(append
								(list
									(nth 0 lisel0)
									(nth 1 lisel0)
								)
								(lva0 (cddr lisel0) 0 0 3)
							)
						)
						;(brkstep '("lisel0") "05" "APOY")
						(setq lisel1 (append lisel1 (list lisel0)))
						(setq contad (+ contad 1))
					)
				)
			)
		)
	)
	(setq lisel1 lisel1)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: CUAN
;;OBJETO: CUANELE. Apartir de la definicion de la Seleccion y la lista de 
;;		elementos y material para la seleccion en su cuantificacion
;;		(extraida de lstelem) devuelve la lista por cada entidad de cuantificacion
;;		con sus respectivos atributos
;;DEVUELVE: Lista de entidades con sus atributos
;;	> (
;;			(materialNativo cantidad ("NombreAtributo" "ValorAtributo") (...)
;;			...
;;		)
;;ARGUMENTOS
;;	1. SELEC. Seleccion de entidades para analizar
;;	> Seleccion Set
;;	2. LISBB. Lista de cuantificacion
;;	> ((MatNat CU EleNat1 ...) (MatDetalle CU EleNat1 ... EleDet1 ...) ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;;(brkstep '("") "001TEMP" "")
;;*******************************************************************
;;PR...
(defun cuanele
	(selec lisbb /
		;melecon melecon1 melecon2 sell lisb lisb0 mimat mimat0 cun misele1
		;miele0 typele eleval lseleval
	)
	(setq melecon nil melecon1 nil melecon2 nil sell nil lisb nil lisb0 nil mimat nil 
		mimat0 nil cun nil misele1 nil miele0 nil typele nil eleval nil lseleval nil)
	;(brkstep '("selec" "lisbb") "00" "CUANELE")
	(setq sell selec
		lisb lisbb
	)
	(cond
		(
			(and
				(= (type sell) 'PICKSET)
				(= (type lisb) 'LIST)
			)
			(setq melecon 0
				mimat0 (nthx '(0 0) lisb)
			)
			;**LISB ( (mat cu elem1 ....) (dxx cu elem1 ...) (...) ...)
			;(brkstep '("lisb" "(length lisb)" "mimat0") "01" "CUANELE")
			(while (< melecon (length lisb))
				(setq lisb0 (nth melecon lisb)
					mimat (nth 0 lisb0)
					cun (nth 1 lisb0)
					melecon1 2
				)
				;(brkstep
				;	'("melecon" "lisb0" "mimat" "cun" "melecon1")
				;	"02" "CUANELE"
				;)
				(cond
					(
						(< 0 cun)
						(while
							(< melecon1 (length lisb0))
							(setq miele0 (nth melecon1 lisb0)
								misele1
								(seldata selec
									'("MATERIAL" "ELEMENTO")
									(list mimat miele0)
								)
							)
							;(brkstep '("misele1" "(length misele1)" "miele0") "03" "CUANELE")
							(cond
								(
									(not (= misele1 nil))
									(setq melecon2 0)
									(while (< melecon2 (length misele1))
										(setq eleval (extraxr (nth melecon2 misele1) '"XD_NOVIDESA"))
										(cond
											(
												(not (= eleval nil))
												(setq lseleval
													(append lseleval
														(list
															(append
																(list mimat0 cun)
																eleval
															)
														)
													)
												)
												;(brkstep '("eleval"  "lseleval") "04" "CUANELE")
											)
										)
										(setq melecon2 (+ melecon2 1))
									)
								)
							)
							(setq melecon1 (+ melecon1 1))
							;(brkstep '("melecon1" "lisb0") "05" "CUANELE")
						)
					)
				)
				(setq melecon (+ melecon 1))
				;(brkstep '("melecon" "lisb") "06" "CUANELE")
			)
		)
	)
	(setq lseleval lseleval)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: CUAN
;;OBJETO: METEDAT2. Introduce los datos de cuantificacion (XData) y los escribe en los
;;		atributos del block
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. NOMBLOCK. Nombre de entidad de block.
;; 2. LSVALATT. Lista de valor de atributos. (solo el valor de los atributos)
;;	>	(VALATT VALATT ...)
;;	3. LSIDE. Lista de atributos extraida de IDE_SALIDA.csv
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Precision de comparacion en lnpo4 0.0001
;;;(brkstep '("") "001TEMP" "")
;;***************************************************************
;;PR....
(defun metedat2
	(blok lsvalatt1 lside /
		con11 lisf lis1 lis2 lis0 pos1 matti atbl con12 pos2 attr attele
		attnum attval insval nomblock lsvalatt
	)
	;(brkstep '("blok" "lsvalatt1" "lside") "00" "METEDAT2")
	;(setq con11 nil lisf nil lis1 nil lis2 nil
	;	lis0 nil pos1 nil matti nil atbl nil
	;	con12 nil pos2 nil attr nil attele nil
	;	attnum nil attval nil insval nil nomblock nil lsvalatt nil
	;)
	(cond
		(
			(and
				(not  (= blok  nil))
				(not (= lsvalatt1 nil))
				(not (= lside nil))
			)
			(setq con11 0)
			(setq nomblock blok)
			(setq lsvalatt lsvalatt1)
			;(brkstep '("blok" "lsvatt1" "lside" "")
			(setq
				lis1 (lnpo4 (nth 0 lsvalatt) lside  0 1 0.0001)
				lis1 (nth 0 lis1)
				lis2 (nth 0 lside)
			)
			;(brkstep '("lis1" "(length lis1)" "lis2" "(length lis2)") "01" "METEDAT2")
			(while
				(< con11 (length lis2))
				(setq lisf
					(append lisf
						(list
							(list
								(nth con11 lis2)
								(nth con11 lis1)
							)
						)
					)
				)
				(setq con11 (+ con11 1))
			)
			;(brkstep '("lisf") "02" "METEDAT2")
			;;**LISF
			;;	(("ELEMENTO" "NOMBRE DE ELEMENTO")
			;;		(NomAtt No/si) (...) ...)
			(setq lisf (lnpo4 "non" lisf 1 0 0.001)
				lisf (lnpo4 "no" lisf 1 0 0.001)
			)
			;(brkstep '("lisf") "03" "METEDAT2")
			;**LISF (("ELEMENTO" "NOMBRE DE ELEMENTO") (NomAtt si) (...) (...))
			(setq lis0 (bindls (mapcar 'car lisf)))
			;**lis0 ("ELEMENTO" "NOMBRE DE ATRIBUTO" ...)
			;(brkstep '("lis0" "lsvalatt") "04" "METEDAT2")
			(xinat1 
				lis0 lsvalatt "XD_NOVIDESA"
				(nth 0 lsvalatt)
				nomblock
			)
			;(brkstep '("nomblock") "04a" "METEDAT2")
			(setq atbl (nxx1 nomblock '(1 2)))
			;(brkstep '("atbl") "04b" "METEDAT2")
			(cond
				(
					(not (= atbl nil))
					(setq con12 0)
					(while
						(< con12 (length atbl))
						(setq attr (nth con12 atbl)
							attele (nth 0 attr)
							Attnum (cdr (nth 2 attr))
						)
						;(brkstep '("attnum" "attele" "attr") "04c" "METEDAT2")
						(cond
							(
								(= (substr attnum 1 6 ) "VALATT")
								(setq
									attnum (substr attnum 7 (strlen attnum))
									attnum (atof attnum)
									attnum (round1 (- attnum 1) 0)
									attval (nth attnum lis2)
								)
								;(brkstep '("attval" "lis0" "attnum") "05" "METEDAT2")
								(setq attval (nth 0 (qnth lis0 attval 0.0001)))
								(setq insval (nth attval lsvalatt))
								;(brkstep
								;	'("attval" "insval")
								;	"06" "METEDAT2"
								;)
								(camtag (list nomblock) (cdr (nth 2 attr)) insval)
							)
						)
						(setq  con12 (+ con12 1))
					)
				)
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: TRZ
;;OBJETO: BLARRAY2. A partir de la definicion de block dinamico
;;		nombre del parametro de ajuste sobre la linea de insersion,
;;		nombre de parametro de ajuste perpendicular,
;;		distancia (valor) de segundo parametro,
;;		lista de posiciones y distancias
;;		inserta el grupo de blocks 
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.NOMBL. Nombre de block dinamico
;;	> "XXX" (nombre dwg)
;;	2.NOMDIS. Nombre del parametro que modifica la distancia de ajuste sobre la linea
;;	> "xxx"
;;	3.NOMDISP. Nombre del parametro que modifica la distancia perpendicular (opcional)
;;	> "XXXX"
;;	4.DISPER. Distancia perpendicular a la linea (opcional)
;;	> #.#
;;	5.LSINS. Lista de distancia de insercion
;;	>	(((XYZ) DIST) (...) ...)
;;	6.LSATT. Lista de valor de atributos
;;	>	((NOMATT VALATT) (...) ...)
;;	7.PPREZI. Precision numerica
;; 8.POSIN. Lista de posicion de longitudes ancho y largo para introducir
;;	en la lista de valores (si se omite una tomara solamente 'DISPER')
;;	(postrans poslong)
;;	9.LSGENAT. Lista generada por "SALIDA_IDE.csv"
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> La ruta de insercion de blocks la busca en el archivo de rutas.csv
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun blarray2
	(nombl nomdis nomdisp disper lsins lsatt pprezi posin lsgenat / 
		conta mitram anglins nomins midia lsvalats conta0 valnom
		ppredi lsatt1 coorins entiblock datt1 conta2 lilins
	)
	;(setq conta nil mitram nil anglins nil nomins nil midia nil
	;	lsvalats nil conta0 nil valnom nil ppredi nil lsatt1 nil
	;	coorins nil entiblock nil datt1 nil conta2 nil lilins nil
	;)
	;(brkstep
	;	'("nombl" "nomdis" "nomdisp" "disper"
	;		"lsins" "lsatt" "pprezi" "conta"
	;	)
	;	"00" "blarray"
	;)
	(cond
		((= pprezi 1)(setq ppredi 0.1))
		((= pprezi 2)(setq ppredi 0.01))
		((= pprezi 3)(setq ppredi 0.001))
		((= pprezi 4)(setq ppredi 0.0001))
		((= pprezi 5)(setq ppredi 0.00001))
		((= pprezi 6)(setq ppredi 0.000001))
		((= pprezi 7)(setq ppredi 0.0000002))
		((= pprezi 8)(setq ppredi 0.00000002))
	)
	(setq midia (getvar "attdia"))
	(setvar "attdia" 0)
	(setq anglins
		(angle
			(nthx '(0 0) lsins)
			(nthx (list (- (length lsins) 1) 0) lsins)
		)
	)
	(setq conta 0)
	;(brkstep
	;	'("conta" "lsins" "(length lsins)") 
	;	"04" "BLARRAY"
	;)
	(while
		(< conta (length lsins))
		;(brkstep '("(onam (list nombl) \"BLOCK\" 0)") "04a" "BLARRAY")
		(cond
			(
				(= (onam (list nombl) "BLOCK" 0) nil)
				(setq nomins nombl)
			)
			(
				(not (= (onam (list nombl) "BLOCK" 0) nil))
				(setq nomins
					(strcat
						(obten "rutas.csv" "BLOCKS" "RUTA")
						nombl
						".dwg"
					)
				)
			)
		)
		(setq mitram (nth conta lsins))
		(setq coorins (cortxt (nth 0 mitram)))
		;(brkstep '("mitram" "coorins" "nomins") "05" "BLARRAY")
		;(brkstep1 '("Angulo") (list (round1 (dtr2 anglins) 3)) "04" "BLARRAY2")
		(command "insert" nomins coorins 1 1 (round1 (dtr2 anglins) 3))
		(setq entiblock (entlast))
		;(brkstep
		;	'("entiblock" "nomdis" "nomdisp" "disper" "(nth 1 mitram)")
		;	"06" "BLARRAY"
		;)
		(setpropdyn  entiblock nomdis (nth 1 mitram))
		(cond 
			(
				(= (length posin) 1)
				(setq lsatt
					(sus1
						(list
							(list (nth 0 posin) (rtos (nth 1 mitram) 2 2))
						)
						lsatt
					)
				)
			)
			(
				(and (= (length posin) 2) (not (= disper nil)))
				(setq lsatt
					(sus1
						(list
							(list (nth 0 posin) (rtos (nth 1 mitram) 2 2))
							(list (nth 1 posin) (rtos disper 2 2))
						)
					)
				)
			)
		)
		;(brkstep1 '("entiblock" "lsatt" "lsgenat") (list entiblock lsatt lsgenat)
		;	"06a" "BLARRAY2")
		(metedat2 entiblock lsatt lsgenat)
		(cond
			(
				(and (not (= disper nil))
					(not (= nomdisp nil))
				)
				(setpropdyn entiblock nomdisp disper)
			)
		)
		(setq conta2 0)
		;(brkstep '("conta2" "lsatt1") "07" "BLARRAY")
		(setq conta (+ conta 1))
		;(brkstep '("conta") "09" "BLARRAY")
	)
)
;
;;
;;;
;;;;

;
;;
;;;
;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: ORDEN5
;; > Ordena una lista estructurada de acuerdo a la posicion interna
;; definida con una lista de posiciones (NTHX) en orden
;;	(ascendente o descendente) definido y con
;;	precision de comparacion numerica definido por el numero de decimales.
;;DEVUELVE:
;;	Misma lista estructurada y ordenada de acuerdo a la posicion y modo
;;	> ( (N N ..) (...) ...)
;;ARGUMENTOS:
;;	1. LT1: Lista estructurada de numeros
;;	( (N (NNN NNN)..) (...) ...)
;;	2. MOD: Modo de orden
;;		En modo 0: Ordena las listas de manera ascendente
;;		En modo 1: Ordena las listas de manera descendente
;; 3. LPOS: Lista de posiciones NTHX del elemento de referencia para ordenar
;;	> (N N ...)
;;	4. P3:	Precision de comparacion numerica (numero de decimales)
;;	>Numero entero
;;ANOTACIONES:
;;
;;DEPENDIENTES:
;; LSS; LVA; ORDVAR0 (TXNO);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;PR...
(defun orden5
	(lt10 mod lpos0 p30 /
		conta0 lorig lisfin lt1 lpos p3
	)
	;(setq conta0 nil lorig nil lisfin nil lt1 nil lpos nil p3 nil)
	;(brkstep '("lt10" "mod" "lpos0" "p30") "00" "ORDEN5")
	(setq
		lt1 lt10
		lpos lpos0
		p3 p30
	)
	(cond
		(
			(= p3 nil)
			(setq nn1 0.00002)
			(setq prec 5)
		)
		(
			(= p3 1)
			(setq nn1 0.1)
		)
		(
			(= p3 2)
			(setq nn1 0.01)
		)
		(
			(= p3 3)
			(setq nn1 0.001)
		)
		(
			(= p3 4)
			(setq nn1 0.0002)
		)
		(
			(= p3 5)
			(setq nn1 0.00002)
		)
		(
			(= p3 6)
			(setq nn1 0.000002)
		)
		(
			(= p3 7)
			(setq nn1 0.0000002)
		)
		(
			(= p3 8)
			(setq nn1 0.00000002)
		)
	)
	(setq conta0 0)
	(while
		(< conta0 (length lt1))
		;(brkstep
		;	'("(nthx (append (list conta0) lpos) lt1)") "00a" "ORDEN5"
		;)
		(setq lorig
			(append lorig
				(list
					(list conta0 (nthx (append (list conta0) lpos) lt1))
				)
			)
		)
		(setq conta0 (+ conta0 1))
		;(brkstep '("conta0" "lorig") "00b" "ORDEN5")
	)
	;(brkstep '("lorig") "01" "ORDEN5")
	(setq lorig (orden4 lorig mod 1 p3))
	;(brkstep '("lorig") "02" "ORDEN5")
	(setq conta0 0)
	(while (< conta0 (length lorig))
		(setq lisfin
			(append lisfin
				(list
					(nth 
						(nthx
							(list conta0 0)
							lorig
						)
						lt1
					)
				)
			)
		)
		(setq conta0 (+ conta0 1))
	)
	;(brkstep '("lisfin") "03" "ORDEN5")
	(setq lisfin lisfin)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO:** MBPEND. A partir de la definición de las dos coordenadas (xy)
;;		y la precision, devuelve la pendiente (M) y el termino
;		independiente (B) para la ecuacion (Y=Mx+B).
;;	>
;;DEVUELVE: Lista de pendiente (M) y el termino independiente. (B)
;;	> (M B)
;;ARGUMENTOS
;;	1.C10. Coordenada1 (XY) lista (XY)
;;	> (X Y)
;;	2. C20. Coordenada2 (XY) lista (XY)
;;	3.PZ0. Precision de comparacion numerica (numero de decimaless)
;;		Numero entero
;;DEPENDIENTES
;;	> PPND2 
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun mbpend
	(c10  c20 pz0 /
		c1 c2 pz predis con11 facx1 facy1 varpr facx2 facy2 m1 facb fin fin1
	)
	;(setq c1 nil c2 nil pz nil predis nil con11 nil facx1 nil facy1 nil varpr nil
	;	facx2 nil facy2 nil m1 nil facb nil fin nil fin1 nil
	;)
	;(brkstep '("c10" "c20" "pz0") "00" "MBPEND")
	(cond
		(
			(and
				(not (= c10 nil))
				(not (= c20 nil))
				(not (= pz0 nil))
			)
			(setq pz pz0
				c1 c10
				c2 c20
			)
			(cond
				((= pz 0) (setq predis 1))
				((= pz 1)(setq predis 0.1))
				((= pz 2)(setq predis 0.01))
				((= pz 3)(setq predis 0.001))
				((= pz 4)(setq predis 0.0001))
				((= pz 5)(setq predis 0.00001))
				((= pz 6)(setq predis 0.000001))
				((= pz 7)(setq predis 0.0000002))
				((= pz 8)(setq predis 0.00000002))
			)
			(setq varpr (getvar "luprec"))
			(setvar "luprec" 8)
			(setq facx1 (nth 0 c1)
				facy1 (nth 1 c1)
				facx2 (nth 0 c2)
				facy2 (nth 1 c2)
			)
			;(brkstep '("facx1" "facy1" "facx2" "facy2") "01" "MBPEND")
			(setq m1 (ppnd3 c1 c2 7))
			(cond
				(
					(not (equal m1 nil))
					(setq facb (* m1 facx1)
						facb (* (- 1 2) facb)
						facb (+ facy1 facb)
					)
					;(brkstep '("m1" "facb" "c1" "c2" "pz") "02" "MBPEND")
					(setq m1 (round1 m1 pz))
					(setq facb (round1 facb pz))
					(setq fin1 (list m1 facb))
				)
			)
			(setvar "luprec" varpr)
		)
	)
	(setq fin1 fin1)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: (MAT) Definiciones matematicas
;;OBJETO: INTER. A partir de la definicion de cuatro coordenadas,
;;		donde las dos primeras corresponden a la primera recta y las dos
;;		ultimas corresponden a la segunda linea; define la coordenada de
;;		interseccion.
;;	> Con precision de numero entero que define el numero de decimales.
;;DEVUELVE:
;;	> Lista (XY) de coordenada de interseccion.
;;ARGUMENTOS
;;	1. P1L10. Coordenada1 de linea1
;;	> (XY) o (XYZ)
;;	2.	P2LL10. Coordenada2 de linea1
;;	>	(XY) o (XYZ)
;;	3. P1L20. Coordenada1 de linea2
;;	>	(XY) o (XYZ)
;;	4.	P2L20. Coordenada2 de linea2
;;	> (XY) o (XYZ)
;;	5. PREZI0. Numero de decimales de precision numerica
;;	> Numero entero.
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;
;;PR...
(defun inter
	(p1l10 p2l10 p1l20 p2l20 prezi0 /
		p1l1 p2l1 p1l2 p2l2 prezi pedis facmb1 facmb2 varmb m01 m02
		b01 b02 nomin denom resul resulx resuly
	)
	;(brkstep '("p1l10" "p2l10" "p1l20" "p2l20" "prezi0") "00" "inter")
	;(setq p1l1 nil p2l1 nil p1l2 nil p2l2 nil prezi nil facmb1 nil
	;	facmb2 nil pedis nil varmb nil m01 nil m02 nil b01 nil b02 nil nomin nil
	;	denom nil resul nil resulx nil resuly nil
	;)
	(cond
		(
			(and
				(equal (type p1l10) 'LIST)
				(equal (type p2l10) 'LIST)
				(equal (type p1l20) 'LIST)
				(equal (type p2l20) 'LIST)
				(equal (type prezi0) 'INT)
			)
			(setq p1l1 (list (nth 0 p1l10) (nth 1  p1l10))
				p2l1 (list (nth 0 p2l10) (nth 1 p2l10))
				p1l2 (list (nth 0 p1l20) (nth 1 p1l20))
				p2l2 (list (nth 0 p2l20) (nth 1 p2l20))
				prezi prezi0
			)
			;(brkstep '("p1l1" "p2l1" "p1l2" "p2l2" "prezi") "01" "INTER")
			(cond
				((= prezi 0) (setq pedis 1))
				((= prezi 1)(setq pedis 0.1))
				((= prezi 2)(setq pedis 0.01))
				((= prezi 3)(setq pedis 0.001))
				((= prezi 4)(setq pedis 0.0001))
				((= prezi 5)(setq pedis 0.00001))
				((= prezi 6)(setq pedis 0.000001))
				((= prezi 7)(setq pedis 0.0000002))
				((= prezi 8)(setq pedis 0.00000002))
			)
			(setq varmb (getvar "luprec"))
			(setvar "luprec" 8)
			(setq facmb1 (mbpend p1l1 p2l1 prezi)
				facmb2 (mbpend p1l2 p2l2 prezi)
			)
			;(brkstep '("facmb1" "facmb2") "02" "INTER")
			(cond
				(
					(and (not (= facmb1 nil))
						(not (= facmb2 nil))
					)
					(setq b01 (nth 1 facmb1)
						m01 (nth 0 facmb1)
					)
					(setq b02 (nth 1 facmb2)
						m02 (nth 0 facmb2)
					)
					(setq  nomin  (- b02 b01)
						denom (- m01 m02)
						resulx (/ nomin denom)
					)
					(setq resuly (+ (* resulx m01) b01))
					;(brkstep '("resulx" "resuly") "03a" "INTER")
				)
				(
					(= facmb1 nil)
					(setq resulx (nth 0 p1l1))
					(setq m02 (nth 0 facmb2))
					(setq b02 (nth 1 facmb2))
					(setq resuly (+ (* m02 resulx) b02))
					;(brkstep '("resulx" "resuly") "03b" "INTER")
				)
				(
					(= facmb2 nil)
					(setq resulx (nth 0 p1l2))
					(setq m01 (nth 0 facmb1))
					(setq b01 (nth 1 facmb1))
					(setq resuly (+ (* m01 resulx) b01))
					;(brkstep '("resulx" "resuly") "03c" "INTER")
				)
			)
			;(brkstep '("b01" "b02" "m01" "m02") "03" "INTER")
			(setq resulx (round1 resulx prezi))
			(setq resuly (round1 resuly prezi))
			(setvar "luprec" varmb)
			(setq resul (list resulx resuly))
		)
	)
	(setq resul resul)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: PAN 
;;OBJETO:DUALNO. A partir de la definicion de la lista Base de panelizacion
;;		(de una sola pendiente), elimina las lineas dobles con
;;		un rango de precision determinado.
;;	> ((P O H (X1 Y1) (X2 Y2)) (...) ...)
;;DEVUELVE: Misma lista con elementos eliminados
;;	> ((P O H (X1 Y1) (X2 Y2)) (...) ...)
;;ARGUMENTOS
;;	1. LBPAN10. Lista base de panelizacion de una sola pendiente
;;	> ((P O H (X1 Y1) (X2 Y2)) (...) ...)
;;	2. PRE10. Precision, numero de decimales.
;;	> Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun dualno
	(lbpan10 pre10 /
		lbpan1 pre1 con11 lsfinal  vvar pdis lb1 era1 lbpan2 ques lbpanf
		lbpan3
	)
;	(setq lbpan1 nil pre1 nil con11 nil lsfinal nil vvar nil pdis nil
;		lb1 nil era1 nil lbpan2 nil ques nil lbpanf nil lbpan3 nil
;	)
	;(brkstep '("lbpan10" "(length lbpan10)" "pre10") "00" "dualno")
	(cond
		(
			(and
				(equal (type lbpan10) 'LIST)
				(equal (type pre10) 'INT)
			)
			(setq lbpan1 lbpan10 pre1 pre10)
			(setq vvar (getvar "luprec"))
			(setvar "luprec" 8)
			(cond
				((= pre1 0) (setq pdis 1))
				((= pre1 1)(setq pdis 0.1))
				((= pre1 2)(setq pdis 0.01))
				((= pre1 3)(setq pdis 0.001))
				((= pre1 4)(setq pdis 0.0001))
				((= pre1 5)(setq pdis 0.00001))
				((= pre1 6)(setq pdis 0.000001))
				((= pre1 7)(setq pdis 0.0000002))
				((= pre1 8)(setq pdis 0.00000002))
			)
			(setq lbpan2 lbpan1)
			;(brkstep '("lbpan2") "01" "DUALNO")
			(while  (not (equal lbpan2 nil))
				;(brkstep '("lbpan2" "(length lbpan2)") "02" "DUALNO")
				(setq con11 0
					lb1 (nth 0 lbpan2)
					ques 1
				)
				;(brkstep '("lbpan2" "(length lbpan2)" "(length (lsno lbpan2 0))")
				;	"02a1" "DUALNO"
				;)
				(setq lbpan3 (lsno lbpan2 0))
				(setq lbpan2 lbpan3)
				;(brkstep '("lbpan2" "(length lbpan2)" "lb1") "02a" "DUALNO")
				(while
					(< con11 (length lbpan2))
					;(brkstep
					;	'("lb1" "lbpan2" "(nth con11 lbpan2)")
					;	"03" "DUALNO"
					;)
					(cond
						(
							(or
								(and (equal (nth 3 lb1) (nthx (list con11 3) lbpan2) pdis)
									(equal (nth 4 lb1) (nthx (list con11 4) lbpan2) pdis)
								)
								(and (equal (nth 4 lb1) (nthx (list con11 3) lbpan2) pdis)
									(equal (nth 3 lb1) (nthx (list con11 4) lbpan2) pdis)
								)
							)
							;(brkstep
							;	'( "lbpan2"
							;		"(length lbpan2)"
							;		"(nth con11 lbpan2)"
							;		"lb1"
							;		"con11"
							;	)
							;	"03A" "DUALNO"
							;)
							(setq con11 (length lbpan2)
								ques 0
							)
							(cam1 (list (handent (nth 2 lb1))) '(62 . 5))
							;(brkstep '("(nth 2 lb1)") "03A1" "DUALNO")
							(entdel (handent (nth 2 lb1)))
						)
					)
					(cond
						(
							(= ques 1)
							(setq con11 (+ con11 1))
							;(brkstep '("lb1" "(nth con11 lbpan2)" "con11") "03B" "DUALNO")
						)
					)
				)
				(cond
					(
						(= ques 1 )
						(setq lbpanf (append lbpanf (list lb1)))
						;(brkstep '("lbpanf") "04" "DUALNO")
					)
				)
			)
			(setvar "luprec" vvar)
		)
	)
	(setq lbpanf lbpanf)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: AGRU2
;;	> Agrupación de una lista estructurada de acuerdo a algún elemento
;;	común en la lista (definido por su posición)
;;DEVUELVE: Misma lista agrupada
;;	> { [ ( x x x ) (...) ...] [...] ...}
;;ARGUMENTOS
;;	1. LST1 Lista de trabajo
;;	> ( (..) (..) (...) ... ))
;;	2. VVAL: Valor especifico
;;	Valor tomado para agrupar solo los elementos que coincidan en la posicion
;;	del tercer argumento
;;	NOTA: Si éste argumento se omite () se agrupara con todas las variantes
;;	localizadas en la posición indicada en el tercer argumento.
;;	3. PPS1: Posición (nth) donde se encuentra el elemento para agrupar
;;	> Numero entero
;;	4. PRSC: Presicion de comparación numerica numero real
;;	Numero real
;;EJEMPLO
;;	( (1 2 3) (2 2 3) (1 W E ) (2 R R E) (5 T T) (5 W W) )
;;	pps1 = 0 / VVAL = nil
;; >( (1 2 3) (1 W E) ) ( (2 2 3) (2 R R E) ) ( (5 W W) (5 T T) )
;;	pps1 = 0 / VVAL 1
;;	( (1 2 3) (1 W E) ) ( (2 2 3) (2 R R E) (5 T T) (5 W W) )
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> 1. Si no existe coincidencia (cuando el valor especifico es definido)
;;	devuelve nil
;;PR...
(defun agru2
	(lst1 vval pps1 prsc /
		lind con1 elecon finl elecon0 pz agruprec
	)
	;(setq lind nil con1 nil elecon nil finl nil elecon0 nil pz nil agruprec nil)
	;(brkstep '("lst1" "vval" "pps1" "prsc" "(length lst1)") "00" "AGRU2")
	(setq agruprec (getvar "luprec"))
	(setvar "luprec" 8)
	(cond
		((= prsc 1) (setq pz 0))
		((= prsc 0.15) (setq pz 1))
		((= prsc 0.015) (setq pz 2))
		((= prsc 0.0015) (setq pz 3))
		((= prsc 0.00015) (setq pz 4))
		((= prsc 0.000015) (setq pz 5))
		((= prsc 0.0000015) (setq pz 6))
		((= prsc 0.0000002) (setq pz 7))
		((= prsc 0.00000002) (setq pz 8))
	)
	(setq con1 0)
	(cond
		(
			(not (= vval nil))
			(setq lind (list vval))
		)
		(
			(setq lind (lva0 lst1 (+ pps1 1) 1 pz))
		)
	)
	;(brkstep '("lind" "(length lind)" "prsc") "01" "AGRU2")
	(while
		(< con1 (length lind))
		(setq elecon
			(lnpo4
				(nth con1 lind)
				lst1
				pps1
				1
				prsc
			)
		)
		;(brkstep '("elecon" "(length elecon)") "03" "AGRU2")
		(cond
			(
				(not (= elecon nil))
				(setq finl
					(append finl (list elecon))
				)
			)
		)
		;(brkstep '("finl") "04" "AGRU2")
		(setq
			con1 (+ con1 1)
		)
	)
	;(brkstep '("finl" "(length finl)") "05" "AGRU2")
	(cond
		(
			(and
				(not (= finl nil))
				(not (= vval nil))
			)
			(setq elecon0
				(lnpo4 vval lst1 pps1 0 prsc)
				finl
				(append finl (list elecon0))
			)
			;(brkstep '("finl" "elecon0") "06" "AGRU2")
		)
	)
	(setvar "luprec" agruprec)
	(setq finl finl)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: NOVIDESA (NV) *********TERMINO*******
;;CLASIFICACION: PANELIZACION (PAN)
;;OBJETO: PANEL8
;;	>A partir de la matriz principal de coordenadas con valores totales
;;	de conexion, define las coordenadas (4) de cada panel y dibuja la multilinea
;;	correspondiente
;;DEVUELVE: Lista de las 4 coordenadas correspondiente a cada panel
;;	agrupado por renglones
;;	>( ((xy1 xy2 xy3 xy4) (...) ...) (...) )
;;ARGUMENTOS
;;	1.MTZ2: Lista de coordenadas en matriz cuadrada con valores
;;	totales de conexion, en orden ascendente en ambas direcciones
;;	> [ ( (val xy) (...) ...) (...) ...]
;;	2.PPD: Factor de pendiente (base)
;;	> 2 1 0 "nop"
;; 3. SISTE. Sistema constructivo
;;	> 0. IKOS
;;	> 1. MAKROS
;;	> 2. HOLMAK
;;	5. pa8Ls lista de atributos
;;	1. Elemento*
;;	2. Tablero "-"
;;	3. Material*
;;	4. Cuan "SI"
;;	5. Sistema*
;;	6. Color*
;;	7. ID "-"
;;	8. UtilFact*
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun panel8
	(mtz2 ppd siste pa8Ls / 
		posi2 posi3
		past pto lsd ptove
		llc llc1 llc2 ancho
		past2 pol pol1 sty
		scml scml1 panel ptotxt anglein altoin
		lastin atancho atalto imru pa8Lsins atancho1 atalto1 insRuta sty1
	)
	;(brkstep '("mtz2" "ppd" "siste" "pa8Ls") "00" "pa8Ls")
	(setq imru (impdat "rutas.csv" "ID_BDATOS" "RUTA" "IDE_SALIDA.csv" ()))
	(setq insRuta (obten "rutas.csv" "BLOCKS" "RUTA"))
	(cond
		(
			(= siste 0)
			(setq sty "AL_IKOS")
			(setq atancho "DISTANCE1")
			(setq atalto "DISTANCE2")
		)
		(
			(= siste 1)
			(setq sty "AL_MAKROS")
			(setq atancho "DISTANCE1")
			(setq atalto "DISTANCE2")
		)
		(
			(= siste 2)
			(setq sty "AL_HOLMAK")
			(setq atancho "DISTANCE1")
			(setq atalto "DISTANCE2")
		)
	)
	;(milne sty nomblk nomrut)
	(setq pol (ssadd))
	(setq pol1 (ssadd))
	;(brkstep '("MTZ2" "(length mtz2)") "ENTRADA: 00" "PANEL8" )
	(cond	
		(
			(not (= mtz2 nil))
			(cond
				(
					(< 1 (length mtz2))
					(setq posi2 (list 0 0))
					(while
						(< (nth 0 posi2) (length mtz2))
						(setq posi2 (list (nth 0 posi2) 0)
							llc1 nil
							past 5
						)
						;(brkstep
						;	'("posi2" "llc2" "(length mtz2)" "past" "past2")
						;	"1" "PANEL1"
						;)
						(while
							(and
								(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
								(= past 5)
							)
							;(brkstep '("posi2" "llc1") "2" "PANEL1")
							(setq past 0
								lsd (list 5 7 13 15)
								posi3 nil
								past2 0
								llc nil
							);;;;;;;;;;;;;;;;;;COMIENZA PUNTO1
							;(brkstep
							;	'("past" "lsd" "posi2" "posi3" "past2" "llc")
							;	"3" "PANEL1"
							;)
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2));;;;;Cambio
										(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									)
									(setq past 1)
									;(brkstep
									;	'("past"
									;		"(length mtz2)"
									;		"(length (nth (nth 0 posi2) mtz2))"
									;	)
									;	"3A"
									;	"PANEL1"
									;)
								)
							)
							(while
								(and
									(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									(= past 1)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;(brkstep '("pto" "ptove" "posi2") "4" "PANEL1")
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
									;(
									;	(< 19 (nth 0 posi2))
									;	(brkstep '("pto" "ptove" "posi2" "lsd") "XX" "TARGET")
									;)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(brkstep '("(cortxt (cdr pto))") "00TTEMP" "01TTEMP")
								(setq ptotxt (cortxt (cdr pto)))
								(command "zoom" "c" ptotxt "7")
								(command "donut" 0.0 0.01 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto" "ptove" "posi2" "lsd"
								;				"(not (= ptove nil))"
								;			) 
								;		"XX2" "TARGET2")
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										;(cond
										;	(
										;		(< 19 (nth 0 posi2))
										;		(brkstep
										;			'("pto" "ptove"
										;				"posi2" "lsd" "llc"
										;				"past2"
										;				"(length (nth (nth 0 posi2) mtz2))"
										;				"past"
										;			)
										;			"XX3"
										;			"TARGET3"
										;		)
										;	)
										;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										;(brkstep '("past" "llc" "past2") "4A" "PANEL1")
									)
									(
										(= ptove nil)
										(setq posi2 (list (nth 0 posi2) (+ (nth 1 posi2) 1)))
										;(brkstep '("posi2") "4B" "PANEL1")
									)
								)
							);;;;;;;;;;;;;;;;;;;;;;;TERMINA PUNTO 1
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto"
								;				"ptove"
								;				"posi2"
								;				"lsd"
								;				"llc"
								;				"past"
								;				"past2"
								;				"(< (nth 1 posi2)
								;					(length (nth (nth 0 posi2) mtz2))
								;				)"
								;			)
								;			"XX4" "TARGET4"
								;		)
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							(setq lsd (list 6 7 14 15));;;;;;;;;;;;;COMIENZA PUNTO2
							;(brkstep '("lsd" "past" "past2") "5" "PANEL1")
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2));;CAMBIO(2)
										(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)));;
										(= past2 1)
									)
									(setq posi2
										(list
											(nth 0 posi2)
											(+ (nth 1 posi2) 1)
										)
										past 2
									)
								)
							)
							;(brkstep
							;	'("posi2"
							;		"past"
							;		"(length mtz2)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;	)
							;	"6" "PANEL1"
							;)
							(while
								(and
									(< (nth 1 posi2) (length (nth (nth 0 posi2) mtz2)))
									(= past 2)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(setq ptotxt (cortxt (cdr pto)))
								(command "zoom" "c" ptotxt "7")
								(command "donut" 0.0 0.01 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(cond
								;	(
								;		(< 19 (nth 0 posi2))
								;		(brkstep
								;			'("pto" "ptove" "posi2" "lsd"
								;				"(not (= ptove nil))"
								;			) 
								;		"XX5" "TARGET5")
								;	)
								;)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(brkstep '("pto" "ptove" "posi2") "7" "PANEL1")
								(cond
									(
										(not (= ptove nil))
										(setq posi3 posi2
											past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep
										;	'("past" "llc" "posi2" "posi3" "past2")
										;	"7A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 10)
												(setq posi3 posi2
													past2 5
													past 0
												)
												;(brkstep '("posi3" "past2" "past")
												;	"7B"
												;	"PANEL1"
												;)
											)
											(
												(not (= (nth 0 pto) 10))
												(setq posi2
													(list
														(nth 0 posi2)
														(+ (nth 1 posi2) 1)
													)
												)
												;(brkstep '("posi2") "7C" "PANEL1")
											)
										)
									)
								)
							)
							(setq lsd (list 10 11 14 15))
							;(brkstep '("lsd" "past2") "8" "PANEL1")
							(cond
								(
									(and
										(< 0 (nth 1 posi2))
										(< (nth 0 posi2) (length mtz2));;CAMBIO(3)
										(= past2 2)
									)
									(setq posi2 (list (+ (nth 0  posi2) 1) (nth 1 posi2))
										past 3
									)
								)
							)
							;(brkstep
							;	'("past"
							;		"(length mtz2)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;		"posi2"
							;	)
							;	"9"
							;	"PANEL1"
							;)
							(while
								(and
									(< (nth 0 posi2) (length mtz2))
									(= past 3)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(setq ptotxt (cortxt (cdr pto)))
								(command "zoom" "c" ptotxt "7")
								(command "donut" 0.0 0.01 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;(brkstep '("pto" "ptove" "posi2") "10" "PANEL1")
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep 
										;	'("past" "llc" "posi2" "past2")
										;	"10A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 9)
												(setq past 0
													past2 5
												)
												;(brkstep '("past2" "past") "10B" "PANEL1")
											)
											(
												(not (= (nth 0 pto) 9))
												(setq posi2
													(list (+ (nth 0 posi2) 1)
														(nth 1 posi2)
													)
												)
												;(brkstep '("posi2") "10C" "PANEL1")
											)
										)
									)
								)
							)
							(setq lsd (list 9 11 13 15))
							;(brkstep '("lsd" "past2") "11" "lsd")
							(cond
								(
									(and
										(< (nth 0 posi2) (length mtz2))
										(<= 0 (nth 1 posi2))
										(= past2 3)
									)
									(setq posi2
										(list
											(nth 0 posi2)
											(- (nth 1 posi2) 1)
										)
									)
									(setq past 4)
								)
							)
							;(brkstep
							;	'("past"
							;		"(length mtz)"
							;		"(length (nth (nth 0 posi2) mtz2))"
							;		"posi2"
							;	)
							;	"12"
							;	"PANEL1"
							;)
							(while
								(and
									(<= 0 (nth 1 posi2))
									(= past 4)
								)
								(setq pto (nthx posi2 mtz2)
									ptove (bc lsd (nth 0 pto))
								)
								;(brkstep '("pto" "ptove" "posi2") "13" "PANEL1")
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(setq ptotxt (cortxt (cdr pto)))
								(command "zoom" "c" ptotxt "7")
								(command "donut" 0.0 0.01 (cdr pto) "")
								(setq pol (ssadd (entlast) pol))
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								(cond
									(
										(not (= ptove nil))
										(setq past 0
											llc (append llc (list (cdr pto)))
											past2 (+ past2 1)
										)
										;(brkstep
										;	'("past" "llc" "posi3" "past2")
										;	"13A" "PANEL1"
										;)
									)
									(
										(= ptove nil)
										(cond
											(
												(= (nth 0 pto) 5)
												(setq past 0
													past2 5
												)
												;(brkstep '("past" "past2")
												;	"13B" "PANEL1"
												;)
											)
											(
												(not (= (nth 0 pto) 5))
												(setq posi2
													(list
														(nth 0 posi2)
														(- (nth 1 posi2) 1)
													)
												)
												;(brkstep '("posi2") "13C" "PANEL1")
											)
										)
									)
								)
							)
							(cond
								(
									(and
										(not (= posi3 nil))
										(< 1 past2)
									)
									(setq past 5
										posi2 posi3
									)
								)
							)
							;(brkstep '("posi2" "past") "14" "PANEL1")
							(cond
								(
									(and
										(= (length llc) 4)
										(= past2 4)
									)
									(setq llc1 (append llc1 (list llc)))
									;(command "pline"
									;	(nth 0 llc)
									;	(nth 1 llc)
									;	(nth 2 llc)
									;	(nth 3 llc)
									;	"c"
									;)
									;(setq pol1 (ssadd (entlast) pol1))
									(command "zoom" "o" pol1 "");;;;;;;;;;;;;;;;;;;;;;;;
									(cond
										(
											(= ppd 0)
											(setq ancho (distance (nth 0 llc) (nth 1 llc)))
											(setq anglein (angle (nth 0 llc) (nth 1 llc)))
											(setq altoin (distance (nth 1 llc) (nth 2 llc)))
										)
										(
											(= ppd 1)
											(setq ancho (distance (nth 0 llc) (nth 1 llc)))
											(setq anglein (angle (nth 2 llc) (nth 3 llc)))
											(setq altoin (distance (nth 1 llc) (nth 2 llc)))
										)
										(
											(= ppd 2)
											(setq ancho (distance (nth 3 llc) (nth 0 llc)))
											(setq anglein (angle (nth 3 llc) (nth 0 llc)))
											(setq altoin (distance (nth 0 llc) (nth 1 llc)))
										)
										(;;;;;;;;;CORRECCION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(= ppd "nop")
											(setq ancho (distance (nth 1 llc) (nth 2 llc)))
											(setq anglein (angle (nth 2 llc) (nth 1 llc)))
											(setq altoin (distance (nth 2 llc) (nth 3 llc)))
										)
									);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,tr
									;(cond
									;	(
									;		(or
									;			(= sty "Ikos_alz")
									;			(= sty "Makros_pl")
									;		)
									;		(setq scml (/ ancho 0.60))
									;	)
									;	(
									;		(= sty "Holmak_alz")
									;		(setq scml (/ ancho 1.20))
									;	)
									;)
									(cond
										(
											(= (onam (list sty) "BLOCK" 0) nil)
											(setq sty1 sty)
										)
										(
											(not (= (onam (list sty) "BLOCK" 0) nil))
											(setq sty1
												(strcat
													insRuta
													sty
													".dwg"
												)
											)
										)
									)
									(cond
										(
											(= ppd 0)
											(command "insert" sty1
												(nth 0 llc) 1 "" (dtr2 anglein)
											)
										)
										(
											(= ppd 1)
											(command "insert" sty1
												(nth 2 llc) 1 "" (dtr2 anglein)
											)
										)
										(
											(or
												(= ppd "nop")
												(= ppd "no")
												(= ppd "non")
											)
											(command "insert" sty1
												(nth 3 llc) 1 "" (dtr2 anglein)
											)
										);;;;;;;;;;;;;;;;;;;;;;CORRECCION;;;;;;;;;;;;;;;;;;;
										(
											(= ppd 2)
											(command "insert" sty1
												(nth 3 llc) 1 "" (dtr2 anglein)
											)
										)
									)
									(setq lastin (entlast))
									(setpropdyn lastin atancho ancho)
									(setpropdyn lastin atalto altoin)
									(setq atancho1 (getpropdyn lastin "DISTANCE1"))
									(setq atalto1 (getpropdyn lastin "DISTANCE2"))
									(setq pa8Lsins
										(append
											(list sty)
											pa8Ls
											(list (rtos atancho1 2 2) (rtos atalto1 2 2))
										)
									)
									;(brkstep
									;	'("lastin" "pa8Ls" "imru" "pa8Lsins")
									;	"14a" "panel8"
									;)
									(metedat2 lastin pa8Lsins imru)
									;(setq scml1 (cam1 (list (entlast)) (cons 40 scml)))
								)
							);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							;(brkstep '("llc1" "llc" "(sslength pol)" "past2") "15" "PANEL1")
							(cond
								(
									(= past2 0)
									(setq posi2
										(list
											(nth 0 posi2)
											(length (nth (nth 0 posi2) mtz2))
										)
									)
								)
							)
							;(brkstep '("posi2" "past2") "16" "PANEL1")
						)
						;(brkstep '("llc1") "17" "PANEL1")
						(setq posi2 (list (+ (nth 0 posi2) 1) (nth 1 posi2)))
						(cond
							(
								(not (= llc1 nil))
								(setq llc2 (append llc2 (list llc1)))
							)
						)
						;(brkstep '("llc2" "posi2" "(length llc2)") "18" "PANEL1")
					)
					(command "erase" pol "")
					(command "zoom" "o" pol1 "")
				)
			)
		)
	)
	;(brkstep '("llc2") "19" "PANEL1")
	(setq llc2 llc2)
):
;
;;
;;;
;;;;
;;PROYECTO: NV (NOVIDESA)
;;CLASIFICACION: MAIN (EJECUTABLE)
;;OBJETO: PANEW. A partir de la definicion del indice de pendiente e
;;	indice de sistema constructivo; Selecciona las lineas que forman
;;	la reticula de un tablero y dibuja los paneles (multilineas).
;;	> Indice de pendiente:
;;	"nop": Seccion transversal en sentido vertical (pendiente indeterminada)
;;	0: Seccion transversal en sentido horizontal (pendiente 0)
;;	1: Seccion transversal en pendiente positiva
;;	2: Seccion transversal en pendiente negativa
;;	>	Indice de sistema constructivo:
;;	0. IKOS
;;	1. MAKROS
;;	2. HOLMAK
;;DEVUELVE: Lista de coordenadas (4) de cada panel, agrupadas en filas.
;;	> ((((x1 y1) (x2 y2) (x3 y3) (x4 y4)) (...) ...) (...) ...)
;; > Primer nivel de lista = Coordenadas X Y de punto
;;	> Segundo nivel de lista = 4 coordenadas de cada panel
;;	> Tercer nivel de lista = fila de panel.
;;ARGUMENTOS
;;	1.	NOMEPEN. Indice de pendiente en seccion transversal del panel
;;	>	"nop": 	Linea vertical (pendiente indeterminada)
;;	>	0. Linea horizontal (pendiente 0)
;;	>	1. Pendiente positiva
;;	>	2. Pendiente negativa
;; 2. SISTE. Sistema constructivo:
;;	>	0. IKOS
;;	>	1. MAKROS
;;	>	2.	HOLMAK
;; 3. PREZZI. Precicion de comparación  numerica (numero de decimales)
;;	> Numero Entero
;;	4. paLs. Lista de atributos
;;	2. Tablero "-"
;;	3. Material*
;;	4. Cuan "SI"
;;	5. Sistema*
;;	6. Color*
;;	7. ID "-"
;;	8. UtilFact*
;;DEPENDIENTES
;;	> PANEL2
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun panew
	(nomepen siste prezzi paLs /
		msil rrut1 bb1 mpp ffa paqm paqr conex rectangulo recs mprecc
		orto os1 os2 decci
	)
	;(setq msil nil rrut1 nil bb1 nil mpp nil ffa nil paqm nil paqr nil conex nil rectangulo nil
	;	recs nil mprecc nil orto nil os1 nil os2 nil decci nil
	;)
	;;;;;;;;;;ARGUMENTOS;;;;;;;;;;;;(0)
	(setq msil (ssget '((0 . "LINE")))
		msil (noment msil)
	)
	;(brkstep '("(length msil)" "nomepen" "siste" "prezzi" "paLs") "00" "PANEW")
	;;;;;;;;;;ARGUMENTOS;;;;;;;;;;;;(1)
	;;***
	;;;;;;;;;;VARIABLES;;;;;;;;;;;;;(0)
	(setq mprecc (getvar "luprec"))
	(setq orto (getvar "orthomode"))
	(setq os1 (getvar "osmode"))
	(setvar "orthomode" 0)
	(setvar "osmode" 0)
	;;;;;;;;;;VARIABLES;;;;;;;;;;;;;(1)
	;;***
	;;;;;;;;;;;PRECISION;;;;;;;;;;;;(0)
	(cond
		((= prezzi 1)(setq decci 0.15))
		((= prezzi 2)(setq decci 0.015))
		((= prezzi 3)(setq decci 0.0015))
		((= prezzi 4)(setq decci 0.00015))
		((= prezzi 5)(setq decci 0.000015))
		((= prezzi 6)(setq decci 0.0000015))
		((= prezzi 7)(setq decci 0.0000002))
		((= prezzi 8)(setq decci 0.00000002))
	)
	(setvar "luprec" 8)
	;;;;;;;;;;;PRECISION;;;;;;;;;;;;(1)
	;;***
	;;;;;;;;;;RUTAS DE APOYO ;;;;;;;;;;;;;(0)
	(setq rrut1 (obten "rutas.csv" "MLINE" "RUTA"))
	;;;;;;;;;;RUTAS DE APOYO ;;;;;;;;;;;;;(0)
	;;***
	;(brkstep '("msil" "rrut1" "prezzi" "decci" "orto" "os1" "mprecc") "01A" "PANEW")
	(setq bb1 (mat1 msil))
	;(brkstep
	;	'("bb1" "(length bb1)"
	;		"(length (nth 0 bb1))"
	;		"(length (nth 1 bb1))"
	;	)
	;	"02" "PANEW"
	;)
	(setq bb1
		(list
			(corden (nth 0 bb1) 0 4)
			(corden (nth 1 bb1) 0 4)
		)
	)
	;(brkstep '("bb1") "02a1" "PANEW")
	(cond
		(
			(not (equal (nthx '(0 0) (nth 1 bb1)) "nop"))
			(cond
				(
					(or
						(< 0 (nthx '(0 0) (nth 1 bb1)))
						(equal (nthx '(0 0) (nth 1 bb1)) 0 0.0001)
					)
					(setq bb1
						(list (nth 1 bb1)
							(nth 0 bb1)
						)
					)
				)
			)
		)
	)
	;(brkstep
	;	'("bb1" "(length bb1)" "(length (nth 0 bb1))"
	;		"(length (nth 1 bb1))"
	;	)
	;	"03" "PANEW"
	;)
	(setq mpp (nthx '(0 0 0) bb1))
	(setq ffa 1)
	(cond
		(
			(or
				(equal mpp "nop")
				(equal (round1 mpp 3) 0 decci)
			)
			(setq ffa 0)
		)
	)
	;(brkstep
	;	'("bb1"
	;		"mpp"
	;		"(length (nth 0 bb1))"
	;		"(length (nth 1 bb1))"
	;	)
	;	"04" "PANEW"
	;)
	(setq paqm (mat4 bb1 0.05 1))
	;(brkstep '("bb1" "paqm" "(length paqm)") "04" "PANEW")
	;(xdat2 paqm "," 3)
	(setq paqr (mat3 bb1 1))
	;(brkstep '("paqr" "(length paqr)") "EXEFOO: 3" "PAQR")
	;(xdat2 paqr "," 3)
	(setq conex (mat6 paqr ffa 0.01));;;;;;;;;;seleccion de tipo de pendiente
	;(brkstep '("conex" "(length conex)") "EXEFOO: 4" "Lista reticula")
	;(xdat2 conex "," 3)
	(setq rectangulo (matconect conex paqm ffa 0.01));;;;seleccion de tipo de pendiente
	;(brkstep '("rectangulo" "(length rectangulo)") "EXEFOO: 5" "MATCONECT")
	;(xdat2 rectangulo "," 3)
	;;;;;;;;;;;;;PREPARACION DE LISTA PARA RECTANGULAR;;;;;;;;;;;;;;;;,
	;;;;;;;;;;;;;;;;;;;;;;;;;;;(setq rectangulo (orden3 rectangulo 0 1))
	;(brkstep '("rectangulo") "EXEFOO: 6" "Matriz ordenada")
	(setq rectangulo (mat5a rectangulo 3 1))
	;(xdat2 rectangulo "," 3)
	;(brkstep '("rectangulo" "nomepen" "siste" "paLs") "08" "PANEW")
	(setq recs (panel8 rectangulo nomepen siste paLs))
	;(brkstep '("recs") "CoordenadasRectangulo" "...")
	;(xdat2 recs "," 3)
	
	(setvar "luprec" mprecc)
	(setvar "orthomode" orto)
	(setvar "osmode" os1)
	;(setvar "osmode2" os1)
	(setq recs recs)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:PAN
;;OBJETO: MAT4A1. A partir de la definicion de la lista de lineas
;;	define las cuatro coordenadas de la poligonal envolvente en reticula recta (0 y 90 grados)
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. LISBAS. Lista base de lineas de reticula  (dos pendientes)
;;	> (((P O H (X Y) (X Y)) (...) ...) (...))
;;	2. PPRC0. Numero de decimales para la comparacion numerica
;;	>	Numero entero
;;	3. PPRN0. Numero de decimales para la definicion de numeros
;;	>	Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun mat4a1
	(lisbas0 pprc0 pprn0 /
		lisbas pprc pprn lisbas12 lisx polf vvpre lisx1 lisx2
		lisy1 lisy2
	)
	;(setq lisbas nil pprc nil pprn nil lisbas12 nil lisx nil polf nil vvpre nil
	;	lisx1 nil lisx2 nil lisy1 nil lisy2 nil)
	(setq lisbas lisbas0
		pprc pprc0
		pprn pprn0)
	;(brkstep '("lisbas" "pprc" "pprn") "00" "MAT4A1")
	(setq vvpre (getvar "luprec"))
	(setvar "luprec" pprn)
	(setq lisbas12 (append (nth 0 lisbas) (nth 1 lisbas))
		lisbas12 (mapcar 'cdddr lisbas12)
	)
	(setq lisx (append (nthz '(0 0) lisbas12)  (nthz '(1 0) lisbas12))
		lisx (lva0 lisx 0 0 pprc)
		lisx (ordvar0 lisx 0)
	)
	;(brkstep '("lisx") "01" "MAT4A1")
	(setq lisy (append (nthz '(0 1) lisbas12) (nthz '(1 1) lisbas12))
		lisy (lva0 lisy 0 0 pprc)
		lisy (ordvar0 lisy 0)
	)
	;(brkstep '("lisy") "02" "MAT4A1");;;;;;;;;;;;;ROUNDCHECK;;;;;;;;;;;;;;;;;;;;;
	(setq lisx1 (round1 (nth 0 lisx) pprn)
		lisx2 (round1 (nth (- (length lisx) 1) lisx) pprn)
	)
	(setq lisy1 (round1 (nth 0 lisy) pprn)
		lisy2 (round1 (nth (- (length lisy) 1) lisy) pprn)
	)
	(setq polf
		(list
			(list lisx1 lisy1)
			(list lisx2 lisy1);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
			(list (nth (- (length lisx) 1) lisx) (nth (- (length lisy) 1) lisy))
			(list (nth 0 lisx) (nth (- (length lisy) 1) lisy))
		)
	)
	;(brkstep '("polf") "03" "MAT4A1")
	(setvar "luprec" vvpre)
	(setq polf polf)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;FOO ;;;;;;;;;;;;;;;;(0)
;;PROYECTO: NV
;;CLASIFICACION: HCL (Herramientas de cerramiento)
;;OBJETO: FACPA. Metodo de conexion de lineas paralelas por
;;	metodo de seleccion con fence. Une paralelas por par de lineas o grupo
;;	de tres lineas dependiendo de la definicion del tercer argumento.
;;	> 
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. APPNOM0. Nombre de aplicacion
;;	> "XXX" O ()
;;	2. LISCODI0. Lista de codigos para filtra la seleccion.
;;	> '((codigo . valor) (...) ...) 0 ()
;;	3. PRECI0. Numero entero para definir la precision
;;	> Numero de decimales.
;;	4. NUMII0. Numero de lineas de agrupacion.
;;	> 1 . Agrupacion de par de lineas (conexion paralela de uno a uno)
;;	> 2. Agrupacion de tres lineas (conexion paralela para dos paneles)
;;DEPENDIENTES
;;	> FSEL (); LSCOD (); LININ (); PARC (); CORIN (); NEAPTO (); LNPO3 ()
;;ANOTACIONES
;;	> Los filtros de seleccion solamente aplica al metodo de seleccion "Fence"
;;	> La precision de trabajo es de 0.00002 (5)
;;	> Arreglar terminacion de comando con nil, revisar filtros de seleccion.
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun facpa
	(appnom0  liscodi0 preci0 numii0 /
		indsel ppaa pp0 ppr pp1a
		ccon1 ccon2 corcon nnom
		coor1 pton pton0 indcod
		indcoor codcam newenti
		c1 c2 an1 an2 an2a p1 test1 idcor
		miprec parpas appfil
		selection ppas coor1a
		numdec parCon1 pp2a ppcon1 appnom
		liscodi preci numii
	)
	;(setq indsel nil ppaa nil pp0 nil ppr nil pp1a nil
	;	ccon1 nil ccon2 nil corcon nil nnom nil coor1 nil pton nil
	;	pton0 nil indcod nil indcoor nil codcam nil newenti nil c1 nil c2 nil
	;	an1 nil an2 nil an2a nil p1 nil test1 nil idcor nil miprec nil parpas nil appfil nil
	;	selection nil ppas nil coor1a nil  numdec nil parCon1 nil pp2a nil ppcon1 nil
	;	appnom nil liscodi nil preci nil numii nil
	;)
	;(brkstep '("appnom0" "liscodi0" "preci0" "numii0") "00" "FACPA")
	(cond
		((= preci0 nil)(setq numdec 0.00002))
		((= preci0 1)(setq numdec 0.1))
		((= preci0 2)(setq numdec 0.01))
		((= preci0 3)(setq numdec 0.001))
		((= preci0 4)(setq numdec 0.0002))
		((= preci0 5)(setq numdec 0.00002))
		((= preci0 6)(setq numdec 0.000002))
		((= preci0 7)(setq numdec 0.0000002))
		((= preci0 8)(setq numdec 0.00000002))
	)
	(setq appnom appnom0 liscodi liscodi0 preci preci0 numii numii0)
	(setq miprec (getvar "luprec"))
	(setvar "luprec" 8)
	(setq ppas 1)
	(while (= ppas 1)
		;(initget 128 "Fence Seleccion")
		(setq pp1a nil)
		(cond
			(
				(and
					(not (= appnom0 nil))
					(not (= liscodi0 nil))
				)
				(setq appfil
					(append
						(list 
							(list -3 (list appnom))
						)
						liscodi
					)
				)
				;(brkstep '("appfil") "01A" "FACPA")
			)
			(
				(and
					(not (= appnom nil))
					(= liscodi nil)
				)
				(setq appfil
					(list
						(list -3 (list appnom))
					)
				)
				;(brkstep '("appfil") "O1B" "FACPA")
			)
			(
				(and
					(= appnom nil)
					(not (= liscodi nil))
				)
				(setq appfil liscodi)
				;(brkstep '("appfil") "O1C" "FACPA")
			)
			(
				(and
					(= appnom nil)
					(= liscodi nil)
				)
				(setq appfil nil)
				;(brkstep '("appfil") "O1D" "FACPA")
			)
		)
		;(brkstep '("INDSEL" "numii" "pp1a") "02" "FACPA")
		(setq pp1a (fsel "LINE" preci appfil))
		(setq pp2a (parc2 numii pp1a)
			ppcon1 0
		)
		;(brkstep '("PP1A" "(length pp1a)" "pp2a") "03A" "FACPA")
		;;PP1A  ((ENAME(XYZ)) (...) ...)
		;**PP1A. ((ENAME (XYZ)) (...) )
		;(brkstep '("pp1a" "(length pp1a)" "(< ppcon1 (length pp2a))" "pp2a" "ppcon1") "05" "FACPA")
		(cond
			(
				(= (< ppcon1 (length pp2a)) nil)
				(setq ppas 0)
			)
		)
		(while (< ppcon1 (length pp2a))
			(setq pp1a (nth ppcon1 pp2a))
			(cond
				(
					(not (= pp1a nil))
					(setq ccon1 0)
					(setq ccon2 1)
					(while (< ccon2 (length pp1a))
						(setq parpas 1)
					;;VERIFICACION DE LINEAS PARALELAS (0)
						(while
							(and (= parpas 1) (< ccon2 (length pp1a)))
							(setq c1
								(lscod (nthx (list ccon1 0) pp1a) '(10 11))
								c1 (mapcar 'cdr c1)
							)
							;**C1. ((XYZ) (XYZ))
							(setq c1
								(list
									(roundcor (nth 0 c1) preci)
									(roundcor (nth 1 c1) preci)
								)
							)
							;**C1 ( (X1 Y1 Z1) (X2 Y2 Z2) );Control de decimales
							;(brkstep '("c1") "05A" "FACPA")
							(setq c2
								(lscod (nthx (list ccon2 0) pp1a) '(10 11))
								c2 (mapcar 'cdr c2)
							)
							;**C2 ( (XYZ) (XYZ) )
							(setq c2
								(list
									(roundcor (nth 0 c2) preci)
									(roundcor (nth 1 c2) preci)
								)
							)
							;;C2 ( (X1 Y1 Z1) (X2 Y2 Z2) ) LINEA 2. Control de decimales
							;(brkstep '("C1" "C2") "06" "FACPA")
							(setq an1
								(round1
									(angle (nth 0 c1) (nth 1 c1))
									preci
								)
							);**AN1 XX.XX Angulo linea 1
							(setq an2
								(round1
									(angle (nth 0 c2) (nth 1 c2))
									preci
								)
							);**AN1 XX.XX Angulo linea 2
							(setq an2a
								(round1
									(angle (nth 1 c2) (nth 0 c2))
										preci
								)
							);**AN1 XX.XX Angulo linea 2 (inverso)
							;(brkstep '("an1" "an2" "an2a") "07" "FACPA")
							(setq test1 nil)
							(cond
								(
									(or
										(equal an1 an2 numdec)
										(equal an1 an2a numdec)
									)
									(setq test1 T)
								)
							)
							;(brkstep '("test1") "08" "FACPA")
							;**TEST1 NIL = Linea convergente (NO HAY INTERSECCION)
							;**TEST1 T = Linea paralela
							(cond
								(
									(not (= test1 nil))
									(setq parpas 0)
								)
								(
									(= test1 nil)
									(setq ccon2 (+ ccon2 1))
								)
							)
							;**PARPAS = PASE DE SALIDA PARA ENCONTRAR LINEA PARALELA
							;(brkstep '("parpas" "ccon2") "08A" "FACPA")
						)
						;;VERIFICACIN DE LINEAS PARALELAS (1)
						(cond
							(
								(not (= test1 nil))
								;(brkstep '("ccon1" "ccon2" "pp1a") "08B" "FACPA")
								(setq corcon
									(parc
										(list
											(nth ccon1 pp1a)
											(nth ccon2 pp1a)
										)
										'(0 1)
										preci ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,,
									)
								)
								;(brkstep '("corcon") "08C" "FACPA")
								(setq corcon
									(list
										(roundcor (nth 0 corcon) preci)
										(roundcor (nth 1 corcon) preci)
									)
								)
								;;CORCON. ((XYZ)(XYZ)).. coordenadas de conexion
								;(brkstep '("corcon") "09" "FACPA")
								(setq nnom
									(nthx
										(list ccon2 0)
										pp1a
									)
								)
								;(brkstep '("nnom") "10" "FACPA")
								;;(NTH CCON1 PP1A). (ENAME (XYZ)) LINEA1
								;;(NTH (+ CCON1 1) PP1A). (ENAME (XYZ)) LINEA2
								;;NNOM. ENAME... LINEA2
								;;CORCON ((XYZ) (XYZ)) 
								(setq coor1
									(lscod nnom (list 10 11))
								)
								(setq idcor
									(corin
										(mapcar 'cdr coor1)
										(nth 1 corcon)
										preci
									)	
								)
								;(brkstep
								;	'("coor1" "idcor")
								;	"11" "CPL"
								;)
								;; COOR1 ((10 (XYZ)) (11 (XYZ))) LINEA 2
								;**IDCOR 0
								(cond
									(
										(= idcor 0)
										(setq coor1a (mapcar 'cdr coor1)
											coor1a
											(list
												(roundcor (nth 0 coor1a) preci)
												(roundcor (nth 1 coor1a) preci)
											)
										)
										;;COOR1A ((XYZ) (XYZ)). Control de decimales
										;;DEFINICION DE PUNTO CERCANO (0)
										(setq pton
											(neapto
												coor1a
												(nth 1 corcon)
												0
											)
										)
										;;PTON: (X Y Z) Punto cercano LINEA2
										(setq pton0
											(append (list 0) pton)
										)
										;;PTON0 (0 X Y Z) Punto cercano de comparacion
										;(brkstep '("PTON" "PTON0") "12" "FACPA")
										(setq indcoor
											(lnpo3 pton0 coor1 '(1 2 3) 1 numdec)
										);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*************
										;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*************
										;**INDCOOR ((NUMCOD X Y Z)) Punto cercano con codigo
										(setq codcam (nthx '(0 0) indcoor)
											newenti (cons codcam (nth 1 corcon))
										)
										;(brkstep '("CODCAM" "NEWENTI") "13" "FACPA")
										;**CODCAM NUMCOD
										;**NEWENTI (NUMCOD . (XYZ))
										;;DEFINICION DE PUNTO CERCANO (1)
										(cam1 (list nnom) newenti)
									)
								)
								(command "line"
									(cortxt (nth 0 corcon))
									(cortxt (nth 1 corcon))
									""
								);;;;;;;;;;;;;;;;OJOO
								;(command "line"
								;	(nth 0 corcon)
								;	(nth 1 corcon)
								;	""
								;)
							)
						)
						(setq ccon1 ccon2)
						(setq ccon2 (+ ccon2 1))
					)
				)
				(
					(= pp1a nil)
					(setq ppas 0)
				)
			)
			(setq ppcon1 (+ ppcon1 1))
		)
	)
	(setvar "luprec" miprec)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;;;;

;
;;
;;;
;;;;
;;PROYECTO:(NV) NOVIDESA
;;CLASIFICACION: TRZ
;;OBJETO: IDETIN
;;	> Trazo de linea (1) de extremo a extremo en un conjunto de limitantes
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.IDPTO0. Coordenada de aplicacion de linea
;;	> (XY) o (XYZ)
;;	2.IDANG0. Angulo de desplazamiento
;;	> Radianes (numero real)
;;	3.IDLIM0. Lista de nombre de entidades limitantes
;;	>(ENAME ...) 
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;PR...
(defun idetin
	(idpto0 idang0 idlim0 /
		idpto idang idlim
		midett loc1 angloc1 mpil mispp mipast mispp1 con1 pase1 mimod 
		idlsline idLineName
	)
	;(setq idpto nil idang nil idlim nil
	;	midett nil loc1 nil angloc1 nil mpil nil mispp1 nil mipast nil
	;	con1 nil pase1 nil mimod nil idlsline nil idLineName nil
	;)
	(setq idpto idpto0 idang idang0 idlim idlim0)
	;(brkstep '("idpto" "idang" "idlim") "00" "IDETIN")
	(cond
		(
			(and
				(< 1 (length idpto))
				(numberp idang)
				(< 0 (length idlim))
			)
			(setq mpil idlim)
			(setq loc1 idpto)
			(setq midett nil)
			(cond
				(
					(not (= loc1 nil))
					(setq angloc1 idang)
					(setq mispp (ret0a loc1 angloc1 mpil))
					;(setq midett (c:selmat))
					(if
						(= midett nil)
						(setq midett "0")
					)
					;(brkstep '("mispp" "midett") "01" "IDETIN")
					(cond
						(
							(and
								(not (= mispp nil))
								(= (length mispp) 2)
							)
							(setq mimod (getvar "osmode"))
							(setvar "osmode" 0)
							(command "line" (nth 0 mispp) (nth 1 mispp) "")
							(setq idlinename (entlast))
							(cam1 (list idlinename) (cons 8 midett))
							(setq idlsline (append idlsline (list idlinename)))
							(setvar "osmode" mimod)
							;(brkstep
							;	'("mimod" "midett" "idLsLine" "idLineName")
							;	"01A" "IDETIN"
							;)
						)
						(
							(and
								(not (= mispp nil))
								(< 2 (length mispp))
							)
							(setq mispp1 (seg1v mispp))
							;(brkstep '("mispp1") "02" "IDETIN")
							(setq pase1 t
								con1 0)
							(while
								(and (not (= mispp1 nil))
									(not (= pase1 nil))
								)
								;(brkstep '("con1" "(length mispp1)") "03" "IDETIN")
								(grvecs
									(append
										(list 2)
										(nth con1 mispp1)
									)
								)
								;(brkstep '("pase1") "04" "IDETIN")
								(initget 2 "Si No")
								(setq pase1
									(getkword
										"\nDeseas incluir esta guia Si/No <enter para salir>?: "
									)
								)
								(princ)
								(command "redrawall")
								(cond
									(
										(= pase1 "Si")
										(setq mimod (getvar "osmode"))
										(setvar "osmode" 0)
										(command
											"line"
											(nth 0 (nth con1 mispp1))
											(nth 1 (nth con1 mispp1))
											""
										)
										(setq idLineName (entlast))
										(setvar "osmode" mimod)
										(setq mispp1 (txno mispp1 (nth con1 mispp1)))
										(cam1 (list (entlast)) (cons 8 midett))
										(setq idLsLine (append idLsLine (list idLineName)))
									)
								)
								(cond
									(
										(and
											(= pase1 "No")
											(< con1 (- (length mispp1) 1))
										)
										(setq con1 (+ con1 1))
									)
									(
										(<= (- (length mispp1) 1) con1)
										(setq con1 0)
									)
								)
							)
						)
					)
				)
			)
		)
	)
	(setq idLsLine idLsLine)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:TRZ
;;OBJETO: DISTPER. Traza lineas (guia) de extremo a extremo
;;		de una polilinea distribuidas a una distancia determinada
;;	> A partir de la definicion de dos puntos, un angulo,
;;		conjunto de limitantes (polilinea y/o linea), distancia de distribucion,
;;		modo distribucion, precision numerica, distancia minima de distribucion
;;DEVUELVE: Conjunto de nombre de entidades de lineas trazadas
;;	> (ENAME ...)
;;ARGUMENTOS
;;	1. DIPTO10. Coordenada 1
;;	> (XY) o (XYZ)
;;	2. DIPTO20. Coordenada 2
;;	> (XYZ) o (XY)
;; 3. DIANG0. Angulo de trazo
;; > Numero real (radianes)
;;	4. DILIM0 Conjunto de limitantes
;;	> (ENAME ...)
;;	5. DIDIV0. Distancia de distribucion
;;	> Numero Real
;;	6. DIMOD0. Modo de distribucion
;;	> 0. Distribucion al centro
;;	> 1. Distribucion en el primer punto
;;	> 2. Distribucion en el segundo punto
;;	7. DIPREC0. Precision numerica
;;	> Numero de decimales [Numero entero]
;;	8. DIMIN0. Distancia minima de distribucion
;;	> Numero real
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun distper
	(dipto10 dipto20 diang0 dilim0 didiv0 dimod0 diprec0 dimin0 /
		dipto1 dipto2 diang dilim didiv dimod diprec dimin divi1 diCon1 diLsLine
		diLsLineFn
	)
	;(setq dipto1 nil dipto2 nil diang nil dilim nil didiv nil
	;	dimod nil diprec nil dimin nil divi1 nil diCon1 nil diLsLine
	;	nil diLsLineFn nil
	;)
	(setq dipto1 dipto10 dipto2 dipto20 diang diang0 dilim dilim0 didiv didiv0 dimod dimod0
		diprec diprec0 dimin dimin0
	)
	;(brkstep
	;	'("dipto1" "dipto2" "diang" "dilim"
	;		"didiv" "dimod" "diprec" "dimin"
	;	)
	;	"00" "DISTPER"
	;)
	(cond
		(
			(and
				(< 1 (length dipto1))
				(< 1 (length dipto2))
				(numberp diang)
				(< 0 (length dilim))
				(numberp didiv)
				(= (type dimod) 'INT)
				(= (type diprec) 'INT)
				(numberp dimin)
			)
			(setq divi1
				(divmu
					dipto1 dipto2 didiv
					dimod diprec dimin
				)
			)
			;(brkstep '("divi1") "01" "DISTPER")
			(cond
				(
					(not (= divi1 nil))
					(setq diCon1 0)
					;(brkstep 
					;	'("diCon1" "(length divi1)" "(< diCon1 (length divi1))")
					;	"01TEMP" "DISPER"
					;)
					(while
						(< diCon1 (length divi1))
						(setq diLsLine
							(idetin (nthx (list diCon1 0) divi1) diang dilim)
						)
						;(brkstep '("diLsLine") "02" "DISTPER")
						(setq diLsLineFn (append diLsLineFn diLsLine))
						(setq diCon1 (+ diCon1 1))
					)
				)
			)
		)
	)
	;(brkstep '("diLsLineFn") "DISTPER")
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: LIST
;;OBJETO: NVPORG.Divide el numero de elementos de una lista y crea una lista
;;			de numeros enteros que define el numero de elementos del grupo divididos
;;			en partes iguales. Si en la division de elementos queda un grupo
;;			desigual, lo coloca al final
;;	> En una lista (1 2 3 4 5 6 7 8 10 11) y argumento de division 2
;;			devolveria. ( 2 2 2 2 2 1), 5 grupos de dos elementos
;;			y un grupo de 1 elemento.
;;	> La funcion se utiliza para otra funcion ORG. donde se define la lista agrupada.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.OG. Lista de elementos
;;	> (xxx xx xxx xxx xxx ...) 0 ( (xxx) (...) ...)
;;	2.DI. Numero de elementos en cada grupo (divide entre el total de elementos)
;; > Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Coloca la parte desigual al final de la lista.
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun nvporg (og di / tdf nr ogf)
	(setq poNumInt (fix (/ (length og) di)))
	(setq poNumRes (- (length og) (* poNumInt di)))
	(cond
		(
			(< 0 poNumRes)
			(setq poNumRes (list poNumRes))
		)
	)
	(setq ndf poNumRes)
	(setq ifi 1)
	;(brkstep '("og" "di" "ndf" "ifi") "00" "nvporg")
	(cond
    (
     (= ndf 0)
     (setq tdf ndf)
     )
    (
     (not (= ndf 0))
     (setq tdf (apply '+ ndf)
	   ogf nil
	   )
     )
    )
  (cond (
	 (<= di (- (length og) tdf))
	 (setq nr (/
		    (- (length og) tdf)
		    di)
	       )
	 (cond
	   (
	    (= (- nr (fix nr)) 0)
	    (cond
	      (
	       (= ndf 0)
	       (repeat (fix nr)
		 (setq ogf (append ogf (list (fix di))))
		 )
	       )
	      (
	       (= ifi 1)
	       (setq ogf ndf)
	       (repeat (fix nr)
		 (setq ogf (append (list (fix di)) ogf))
		 )
	       )
	      (
	       (= ifi 0)
	       (repeat (fix nr)
		 (setq ogf (append ogf (list (fix di)))
		       )
		 )
	       (setq ogf (append ndf ogf))
	       )
	      )
	    )
	   (
	    (not (= (- nr (fix nr)) 0))
	    (alert "PROG:EL NUMERO DE ELEMENTOS POR GRUPO NO CORRESPONDE")
	    )
	   )
		       
	 )
	(
	 (>= di (- (length og) tdf))
	 (alert "PORG:EL NUMERO DE GRUPOS ES DEMASIADO GRANDE")
	 )
	)
  (setq ogf ogf)
  )
 ;
 ;;
 ;;;
 ;;;;
 ;;PROYECTO: NV
;;CLASIFICACION:TRZ
;;OBJETO:PARC2. CERRAMIENTO PARALELO CON GRUPO. Crea la lista de elementos
;;			Agrupados y ordenados para ejecutar el cerramiento de lineas paralelas
;;			en grupo (en pares o cada tres lineas).
;;	> Formato de lista de trabajo
;;		((ENAME (XY)) (...) ...)
;;DEVUELVE:
;;	> Lista de elementos agrupados
;;		(((ENAME (XY)) (...) ...) (...) ...)
;;ARGUMENTOS
;;	1.paNumGrupo0. Numero de elementos de agrupacion
;;	>Numero entero
;;	2.paFsel0. Lista de seleccion hecha con FSEL
;;		((ENAME (XY)) (...) ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun parc2
	(paNumGrupo0 paFsel0 /
		paCon1 paCon2 paLsGrupo paFsel1 paLim paFselFin
	)
	;(setq paCon1 nil paCon2 nil paLsGrupo nil paFsel1 nil paLim nil paFselFin nil
	;	paNumGrupo nil paFsel nil
	;)
	;(brkstep '("paNumGrupo0" "paFsel0" "(length paFsel0)") "00" "PARC2")
	(cond
		(
			(and
				(= (type paNumGrupo0 ) 'INT)
				(= (type paFsel0) 'LIST)
			)
			(setq paNumGrupo paNumGrupo0
				paFsel paFsel0
			)
			(setq paCon1 0
				paCon2 1
				paFsel (reverse paFsel)
			)
			(cond
				(
					(= paNumGrupo 1)
					(setq paLim (length paFsel))
				)
				(
					(= paNumGrupo 2)
					(setq paLim (- (length paFsel) 1))
				)
			)
			;(brkstep '("paLim" "(length paLim)") "01" "PARC2")
			(while (< paCon2 paLim)
				(cond
					(
						(= paNumGrupo 1)
						(setq paFsel1
							(reverse
								(list (nth paCon1 paFsel)
									(nth paCon2 paFsel)
								)
							)
						)
						(setq paCon1 (+ paCon1 1)
							paCon2 (+ paCon2 1)
						)
						;(brkstep '("paFsel1" "PaCon1" "PaCon2") "02A" "PARC2")
					)
					(
						(= paNumGrupo 2)
						(setq paFsel1
							(reverse
								(list (nth paCon1 paFsel)
									(nth paCon2 paFsel)
									(nth (+ paCon2 1) paFsel)
								)
							)
						)
						(setq paCon1 (+ paCon1 2)
							paCon2 (+ paCon2 2)
						)
						;(brkstep '("paFsel1" "PaCon1" "PaCon2") "02B" "PARC2")
					)
				)
				(setq paFselFin (append paFselFin (list paFsel1)))
				;(brkstep '("paFselFin") "03" "PARC2")
			)
		)
	)
	;(brkstep '("PAFSELFIN") "04" "PARC2")
	(setq paFselFin paFselFin)
)
;;;;FOO ;;;;;;;;;;;;;;;;(1)
;
;;
;;;
;;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:MAT
;;OBJETO:SUMLS. Suma una lista sencilla de numeros entre si
;;	> Numero Sumado
;;DEVUELVE: Numero Sumado
;;	>
;;ARGUMENTOS
;;	1.suLs. Lista numerica
;;	>(#.# ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun sumLs (suLs / suCon1 suTot)
	;(brkstep '("suLs") "00" "SUMLS")
	(setq suCon1 0
		suTot 0)
	(while
		(< suCon1 (length suLs))
		(cond 
			(
				(= (numberp (nth suCon1 suLs)) t)
				(setq suTot (+ suTot (nth suCon1 suLs)))
			)
		)
		(setq suCon1 (+ suCon1 1))
	)
	(setq suTot suTot)
)
;
;;
;;;
;;;;

;;
;;;
;;PROYECTO: Lisp
;;CLASIFICACION: ATT
;;OBJETO: GNT1
;;	> Extrae el nombre de entidades de una selección que correspondan
;;	un valor comun en un tag comun
;;DEVUELVE:
;;	> Lista de nombre de entidades o nil si ningun nombre corresponde
;;	> (ENAME ...)
;;ARGUMENTOS
;;	1.LOU0: Lista de selección
;;	> SelectionSet
;;	2.LOUT0: NOMBRE DE TAG DE BUSQUEDA
;;	> "XXX"
;; 3.VLOUT0: Valor de tag buscado
;;	> "XXXX"
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;PR...
(defun gnt1
	(lou0 lout0 vlout0 /
		;lou1 llo cnl psl mlo cnl1 psl1
		;ind fnl lou lout vlout fnl1
	)
	(setq lou1 nil llo nil cnl nil psl nil mlo nil cnl1 nil
		psl1 nil fnl nil lou nil lout nil vlout nil fnl1 nil
	)
	(setq lou lou0
		lout lout0
		vlout vlout0
	)
	(brkstep '("lou" "lout" "vlout") "00" "GNT1")
	(setq lou1 (tgb1 lou lout 2))
	(brkstep '("lou1" "(length lou1)") "01" "GNT1")
	(cond
		(
			(not (= lou1 nil))
			(setq fnl (lnpo vlout lou1 1 1))
			(brkstep '("fnl") "01A" "GNT1")
			(cond
				(
					(not (= fnl nil))
					(setq fnl1 (mapcar 'car fnl))
				)
			)
		)
	)
	(brkstep '("fnl1") "01A" "GNT1")
	(setq fnl1 fnl1)
)
;
;;
;;;
;;PROYECTO: Lisp
;;CLASIFICACION: ATT
;;OBJETO: TGB1
;;	> A partir de una selección, extrae el valor del TAG O VALOR TAG
;;	indicado devolviendo el nombre de cabecera y su valor.
;;DEVUELVE: Lista de pares (nombre de cabecera) + Valor TAG
;;	> [ (nombreCabecera1 valor1) (nombreCabecera2 valor2)...]
;;ARGUMENTOS
;;	1.LIS0: Selección de entidades
;;	> SelectionSet
;;	2. VTAG0: Nombre del TAG O VALOR DEL TAG
;;	3. COTAG0: Codigo buscado
;;	> 1 Para buscar el valor del TAG
;;	> 2 Para buscar el nombre del TAG
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> No debe de haber dos tags iguales dentro del mismo block
;;PR...
(defun tgb1
	(lis0 tg0 cotag0 /
		;can pos can1 pss lis1 lisf lis tg cotag
	)
	(setq can nil pos nil pss nil lis1 nil lisf nil lis nil tg nil cotag nil)
	(setq tg tg0
		lis lis0
		cotag cotag0)
	(brkstep '("lis" "tg" "cotag") "00" "TGB")
	(setq can 0)
	(cond
		(
			(= cotag 1)
			(setq pos 2)
		)
		(
			(= cotag 2)
			(setq pos 1)
		)
	)
	(while (< can (sslength lis))
		(setq lis1 (nxx1 (ssname lis can) '(2 1)))
		(brkstep
			'("lis1"
			"(lnpo (cons cotag tg) lis1 pos 1)"
			)
			"01" "TGB"
		)
		(cond
			(
				(lnpo (cons cotag tg) lis1 pos 1)
				(setq lisf
					(append lisf
						(list
							(list
								(ssname lis can)
								(cdr (nthx '(0 2) (lnpo (cons cotag tg) lis1 pos 1)))
							)
						)
					)
				)
			)
		)
		(setq can (+ can 1))
    )
	 (brkstep '("lisf") "02" "TGB")
	 (setq lisf lisf)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO / TITULO:QUATT1. Consulta de atributos
;;DESCRIPCION:
;;	> QATT. Muestra los valores de los atributos de un elemento seleccionado
;;	registrado en la aplicacion "AZ-CIVIL"
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:qatt1 ( / nomiap miele conta speach pas1)
	(setq nomiap "AZ-CIVIL")
	(setq miele (noment (ssget)))
	(setq miele (nth 0 miele))
	;(brkstep '("miele") "01" "MSJ")
	(setq miele (extraxr miele nomiap))
	;(brkstep '("miele") "02" "MSJ")
	(setq conta 0
		pas1 0
	)
	;(brkstep '("miele" ) "01" "QATT")
	(cond
		(
			(not (= miele nil))
			(while 
				(< conta (length miele))
				(cond
					(
						(= pas1 0)
						(setq pas1 1
							speach
							(strcat
								(nth 0 (nth conta miele)) ": "
								(nth 1 (nth conta miele)) "\n"
							)
						)
						;(brkstep '("speach") "02a" "QATT")
					)
					(
						(= pas1 1)
						(setq speach
							(strcat
								speach
								(nth 0 (nth conta miele)) ": "
								(nth 1 (nth conta miele)) "\n"
							)
						)
					)
				)
				(setq conta (+ conta 1))
			)
			;(brkstep '("speach") "03" "QATT")
		)
		(
			(= miele nil)
			(setq speach "LA ENTIDAD NO CONTIENE\nINFORMACION DE CUANTIFICACION")
			;(brkstep '("speach") "04B" "QATT")
		)
	)
	(alert speach)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BDATA
;;OBJETO: SELDATA2. A partir de la selección, dos listas
;;	(nombre de atributos y valor de atributos)  y nombre de aplicación
;; devuelve la lista de nombre de entidades que correspondan con los atributos
;;DEVUELVE:
;;	> Lista de nombres de entidades filtrados
;;ARGUMENTOS
;;1. SS2. Lista de nombre de entidades
;;2. LLAA. Lista de Nombres de Atributos Xdata
;;3. VVAA. Lista de Valores correspondientes a la lista (anterior)
;;		de Atributos.
;;4. seNomAp. Nombre de aplicación
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> El nombre de la aplicación 
;(seldata2
;				(list anEnti)
;				(list "ID_POL")
;				(list (cdr (assoc 5 (entget anEnti))))
;			)
;;;(brkstep '("") "001TEMP" "")
;;Argumentos:
(defun seldata2
	(ss2 llaa vvaa seNomAp / con1 nomsel licoma lico1 licof fnum)
	(setq con1 0)
	(cond
		(
			(and
				(= (type ss2)'LIST)
				(= (type llaa)'LIST)
				(= (type vvaa) 'LIST)
				(= (type seNomAp) 'STR)
			)
			(setq nomsel ss2)
			(cond
				(
					(not (= nomsel nil))
					(setq licoma
						(txl
							(jo2 (list llaa vvaa) "-")
							3
							","
						)
					)
					;(brkstep1 '("licoma") (list licoma) "01" "SELDATA2")
					(while (< con1 (length licoma))
						(setq lico1 (cons 1000 (nth con1 licoma))
							licof (append licof (list lico1))
						)
						(setq con1 (+ con1 1))
					)
					;(brkstep1 '("licof") (list licof) "02" "SELDATA2")
					(setq fnum
						(exnoma seNomAp licof nomsel)
					)
				)
			)
		)
	)
	;(brkstep1 '("fnum") (list fnum) "03" "SELDATA2")
	(setq fnum fnum)
)
;
;;
;;;
;;;;
(defun dimet
	(lspr / con1 con2 cor1 cor2
		nno lspr1 lspr2
		disdin anbl var midi1 comeco
	)
	(setq midi1 (getvar "attdia"))
	(setvar "attdia" 0)
	(setq comeco (getvar "cmdecho"))
	(setvar "cmdecho" 0)
	
	;(brkstep1
	;	'("lspr") (list lspr) "00" "DIMET"
	;)
	(setq con1 0)
	(while (< con1 (length lspr))
		(setq lspr1 (nth con1 lspr)
			lspr1 (nth 3 lspr1)
			con2 0
		)
		(while (< con2 (length lspr1))
			(setq lspr2 (nth con2 lspr1))
			;(brkstep1 '("lspr2") (list lspr2) "01" "DIMET")
			(setq cor1 (nth 3 lspr2)
				cor2 (nth 4 lspr2)
				disdin (distance cor1 cor2)
				anbl (angle cor1 cor2)
				var (nth 0 lspr2)
			)
			;(brkstep1
			;	'("lspr2" "cor1" "cor2" "disdin" "anbl" "var")
			;	(list lspr2 cor1 cor2 disdin anbl var)
			;	"01" "DIMET"
			;)
			(cond
				(
					(< 0.0 var)
					(princ)
					(command "zoom" "C" (cortxt cor1) 20)
					(command
						"insert" "Angulo" cor1 1 1
						(dtr2 anbl) (rtos var 2 2)
					)
					(setq nno (entlast))
					;(setpropdyn1 nno "Distance1" disdin)
				)
			)
			(setq con2 (+ con2 1))
		)
		(setq con1 (+ con1 1))
	)
	(setvar "attdia" midi1)
	(setvar "cmdecho" comeco)
)
;
;;
;;;
;;;;
(defun setpropdyn1 (nenti nomatt newdat / prp blk)
	(setq prp (strcase nomatt))
	(setq blk (vlax-ename->vla-object nenti))
		;(setq dynProp (vlax-invoke dynBlock 'getDynamicBlockProperties))
	(vl-some
		'(lambda ( x )
			(if
				(= prp (strcase (vla-get-propertyname x)))
				(progn 
					(vla-put-value x
						(vlax-make-variant
							newdat
							(vlax-variant-type
								(vla-get-value x)
							)
						)
					)
					(cond
						(newdat)
						(t)
					)
				)
			)
		)
		(vlax-invoke blk 'getdynamicblockproperties)
	)
)
;
;;
;;;
;;;;
(defun jtubo (listub ppe / con1 con2 
		listub1 listub1a listub1n
		listub2 listub2a listub2n
		coco1 coco2 dds pps
		varini varini1 ang1)
	;(brkstep1
		;'("listub" "ppe" "LongLista")
		;(list listub ppe (length listub))
		;"00" "JTUBO"
	;)
	(setq con1 0)
	(while
		(< con1 (length listub))
		(setq listub1 (nth con1 listub)
			listub2 (nth 3 listub1)
			listub2n nil
			con2 0
		)
		;(brkstep1
		;'("listub1" "listub2" "con2")
		;(list listub1 listub2 con2)
		;"01" "JTUBO"
		;)
		(while
			(< con2 (length listub2))
			(setq varini (nthx (list con2 0) listub2)
				dds (nthx (list con2 1) listub2)
				ang1 (nthx (list con2 2) listub2)
				coco1 (nthx (list con2 3) listub2)
				coco2 (nthx (list con2 4) listub2)
				pps 0
			)
			(setq con2 (+ con2 1))
			;(brkstep1
				;'("varini" "dds" "ang1" "coco1" "coco2" "pps" "con2")
				;(list varini dds ang1 coco1 coco2 pps con2)
				;"02" "JTUBO"
			;)
			(while
				(and
					(< con2 (length listub2))
					(= pps 0)
				)
				(setq varini1 (nthx (list con2 0) listub2))
				(cond
					(
						(equal 0 varini1 ppe)
						(setq coco2 (nthx (list con2 4) listub2))
						(setq dds (+ dds (nthx (list con2 1) listub2)))
						(setq con2 (+ con2 1))
					)
					(
						(/= varini1 0)
						(setq pps 1)
					)
				)
				;(brkstep1
				;'("coco2" "dds" "con2" "pps")
				;(list coco2 dds con2 pps)
				;"03" "JTUBO"
				;)
			)
			(setq listub2a (list varini dds ang1 coco1 coco2))
			(setq listub2n (append listub2n (list listub2a)))
			;(brkstep1
			;'("listub2a" "listub2n")
			;(list listub2a listub2n)
			;"04" "JTUBO"
			;)
		)
		(setq listub1a
			(list (nth 0 listub1)
				(nth 1 listub1)
				(nth 2 listub1)
				listub2n
			)
		)
		(setq listub1n (append listub1n (list listub1a)))
		(setq con1 (+ con1 1))
		;(brkstep1
			;'("listub1a" "listub1n" "con1")
			;(list listub1a listub1n con1)
			;"05" "JTUBO"
		;)
	)
	(setq listub1n listub1n)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO / TITULO: ANGRES5. Apartir de la definicion de un angulo destino
;; y dos puntos, calcula el angulo entre la recta formada por los dos puntos
;;	y el angulo destino. Aplicada a la horizontal para perfiles topograficos.
;;DESCRIPCION:
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun angres5 (angbase1 cco1 cco2 mod preci / anires0 cco1 cco2 )
	(setq anires0 (angres4 angbase1 cco1 cco2 0 preci))
;	(brkstep1
;		'("angbase1" "cco1" "cco2" "anires0")
;		(list angbase1 cco1 cco2)
;		"00" "ANGRES5"
;	)
	(cond
		(
			(< 3.1459 anires0)
			(setq  anires0 (- 6.28319 anires0))
		)
	)
	(cond
		(
			(= mod 1)
			(setq anires0 (dtr2 anires0))
		)
	)
	;(brkstep1
	;	'("anires1" "cco1" "cco2" "anires0")
	;	(list anires1 cco1 cco2 anires0)
	;	"01" "ANGRES5"
	;)
	(setq anires0 anires0)
)
;
;;
;;;
;;;;
(defun boli2 (point sc / con1 lisboli)
	(setq con1 0)
	(setq lisboli (ssadd))
	(while (< con1 (length point))
		(command "insert" "boli" (nth con1 point) sc "" 0)
		;(brkstep1 '("point" "(nth con1 point)") (list point (nth con1 point)) "00" "BOLI2")
		(setq lisboli (ssadd (entlast) lisboli))
		(setq con1 (+ con1 1))
	)
	(setq lisboli lisboli)
)
;
;;
;;;
;;;;
(defun angres4 (angdes pivi px mdd ppk / angor angfn numr)
	;(brkstep1
	;	'("angdes" "pivi" "mdd" "ppk")
	;	(list angdes pivi px mdd ppk)
	;	"00" "ANGRES4"
	;)
	(cond
		(
			(= ppk nil)
			(setq numr 0.00002)
			(setq prec 5)
		)
		(
			(= ppk 1)
			(setq numr 0.1)
		)
		(
			(= ppk 2)
			(setq numr 0.01)
		)
		(
			(= ppk 3)
			(setq numr 0.001)
		)
		(
			(= ppk 4)
			(setq numr 0.0002)
		)
		(
			(= ppk 5)
			(setq numr 0.00002)
		)
		(
			(= ppk 6)
			(setq numr 0.000002)
		)
		(
			(= ppk 7)
			(setq numr 0.0000002)
		)
		(
			(= ppk 8)
			(setq numr 0.00000002)
		)
	)
	(setq angor (angle pivi px)
		angor (round1 angor ppk)
	)
	;(brkstep1 '("angdes" "pivi" "px" "mdd" "angor")
	;	(list angdes pivi px mdd angor)
	;	"00"
	;	"ANGRES4"
	;)
	(cond
		(
			(< angor angdes)
			(setq angfn (- angdes angor))
		)
		(
			(> angor angdes)
			(setq angfn (- angor angdes))
		)
		(
			(equal angor angdes numr)
			(setq angfn angor)
		)
	)
	(cond
		(
			(= mdd 0)
			(setq angfn angfn)
		)
		(
			(= mdd 1)
			(setq angfn (dtr2 angfn))
		)
	)
	;(brkstep1 '("angfn") (list angfn) "01" "ANGRES4")
	(setq angfn angfn)
)
;
;;
;;;
;;;;
;;;;inserta block de cadenamiento (blktic)
;;inserta block de numeracion de tubo
(defun insercad (llisi blktic blcnum /
	con1 msele pin pin1 numtub numtub1
	anin din mimi diatt ecov)
	(setq lastpoint nil lastram nil
		lastcoor1 nil lastcoor2 nil
		lastang nil anin1 nil
	)
	;(brkstep1 '("llisi" "blktic" "blcnum")
	;	(list llisi blktic blcnum)
	;	"00" "INSERCAD"
	;)
	(setq con1 0
		msele (ssadd)
		diatt (getvar "attdia")
		ecov (getvar "cmdecho")
	)
	(setvar "attdia" 0)
	(setvar "cmdecho" 1)
	(while
		(< con1 (- (length llisi) 1))
		(setq pin (car (cdr (nth con1 llisi))))
		(setq pin1 (car (cdr (nth (+ con1 1) llisi))))
		(setq numtub (nth 0 (nth con1 llisi)))
		(setq numtub1 (nth 0 (nth (+ con1 1) llisi)))
		(setq anin (angle pin pin1))
		(setq anin1 (nth 2 (nth con1 llisi)))
		(setq din (polar pin anin (/ (distance pin pin1) 2))
			din (polar din (sumang anin 1.5708) 2)
		)
		(command "Zoom" "C" din "36")
		;(brkstep1 '( "con1" "pin" "pin1" "numtub" "numtub1" "con1" "(length llisi)" "din" "anin")
		;	(list con1 pin pin1 numtub numtub1 con1 (length llisi) din anin)
		;	"01" "INSERCAD"
		;)
		(command "insert" "NumeroTubo" din 1 1 (dtr2 anin) (itoa numtub))
		(setq mimi (entlast))
		(setq mimi (cdr (assoc 5 (entget mimi))))	
		(command "insert" "punta1" pin 1 1 (dtr2 anin1) (itoa numtub) mimi (itoa numtub1))
		(setq con1 (+ con1 1))
		;(brkstep1 '("con1") (list con1) "02" "INSERCAD")
	)
	(setq lastpoint (nth 3 (nth (- (length llisi) 1) llisi)))
	(setq lastram (nth (- (length lastpoint) 1) lastpoint))
	(setq lastcoor1 (nth 3 lastram))
	(setq lastcoor2 (nth 4 lastram))
	(setq lastang (dtr2 (angle lastcoor1 lastcoor2)))
	;(brkstep1 '("lastpoint" "lastram" "lastcoor1" "lastcoor2" "lastang")
	;	(list lastpoint lastram lastcoor1 lastcoor2 lastang)
	;	"03" "INSERCAD"
	;)
	(setq pin (car (cdr (nth con1 llisi))))
	(setq pin1 lastcoor2)
	(setq numtub (nth 0 (nth con1 llisi)))
	(setq numtub1 "NIPLE")
	(setq anin (angle pin pin1))
	(setq din (polar pin anin (/ (distance pin pin1) 2))
		din (polar din (sumang anin 1.5708) 2)
	)
	(command "insert" "NumeroTubo" din 1 1 (dtr2 anin) (itoa numtub))
	(setq mimi (entlast))
	(setq mimi (cdr (assoc 5 (entget mimi))))
	;(brkstep1 
	;	'("pin" "Angulo" "numtub" "numtub1")
	;	(list pin (dtr2 anin) numtub numtub1)
	;	"04" "INSERCAD"
	;)
	(command "insert" "punta1" pin 1 1 (dtr2 anin) (itoa numtub) mimi numtub1)
	(command
		"insert"
		"punta1"
		lastcoor2
		1 ""
		lastang
		"niple"
		"-"
		"-"
		"")
	(setvar "attdia" diatt)
	(setvar "cmdecho" ecov)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;Clasificacion: LIST
;;OBJETO : DisMod1
;; Distibucion de correas o portacorreas en
;; una distancia determinada
;; DEVUELVE:
;; diLsAlt: Lista numerica de distancias
;;> (#.# #.# ...)
;; ARGUMENTOS
;; 1. diLsMod00: Lista de modulos ordenada de
;;	de mayor a menor segun el factor de
;;	utilizacion, este argumento esde formato
;;	simple, es decir, una lista sencilla de los
;;	modulos disponibles.
;;	cada elemento de la lista es un numero que
;;	representa la distancia de dicho modulo.
;;> (mod1 mod2 ...)
;; 2. diDstr0: Distancia de trabajo
;;> #.#
;; ANOTACIONES:
;;	Segunda version de DisMod1 analiza y selecciona la minima distancia sobrante.
(defun DisMod1
	       (diLsMod0   diDsTr0    /		 diCon	    diDs
		diLsMod	   diDsTr     diLsFn	 diDsDivInt diLsModRv
		diDsDivDec diLsTr     diModDif	 diLsAlt
	       )
					;(setq diCon nil diDs nil diLsMod nil diDsTr nil diDsDivInt nil diLsModRv nil diDsDivDec nil
					;	diLsTr nil diLsFn nil diModDif nil diLsAlt nil
					;)
					;(brkstep1 '("diLsMod0" "diDsTr0")(list diLsMod0 diDsTr0) "00" "disMod")
  (cond
    (
     (and
       (= (type diLsMod0) 'LIST)
       (= (numberp diDsTr0) t)
     )
     (setq diLsMod diLsMod0
	   diDsTr  diDsTr0
     )
     (setq diDs	 (float diDsTr)
	   diCon 0
     )
					;diDs. Distancia de trabajo <real>
     (while
       (< diCon (length diLsMod))
					;(brkstep1 '("diCon" "diLsMod" "diDs") (list diCon diLsMod) "01" "DISMOD")
	(setq diDsDivInt (fix (/ diDs (nth diCon diLsMod)))
	      diDsDivDec (- (/ diDs (nth diCon diLsMod)) diDsDivInt)
	      diDs	 (* diDsDivDec (nth diCon diLsMod))
					; distancia restante
	)
	(cond
	  (
	   (= diDs 0)
	   (setq diMoDif 0)
	  )
	  (
	   (< 0 diDs)
	   (setq diMoDif (- (nth diCon diLsMod) diDs))
	  )
	)
					;(brkstep1 '("diDsDivInt" "diDsDivDec" "diDs" "diMoDif") (list diDsDivInt diDsDivDec diDs diMoDif) "02" "DISMOD")
					;diDsDivInt. Entero de division <int>
					;diDsDivDec. Decimal de division <real>
					;diDs. Distancia restante <real>
					;diModDif. Diferencia sobrante de modulo <real>
	(cond
	  (
	   (< 0 diDsDivInt)
	   (repeat diDsDivInt
	     (setq diLsFn
		    (append diLsFn (list (nth diCon diLsMod)))
	     )
	   )
	   (cond
	     (
	      (< 0 diDs)
	      (setq diLsAlt
		     (append diLsAlt
			     (list
			       (list diMoDif
				     (append diLsFn (list (nth diCon diLsMod)))
			       )
			     )
		     )
	      )
	     )
	     (
	      (= diDs 0)
	      (setq diLsAlt
		     (append diLsAlt
			     (list
			       (list diMoDif diLsFn)
			     )
		     )
	      )
	     )
	   )
					;(brkstep1 '("diLsAlt") (list diLsAlt) "03" "DisMod1")
	  )
	  (
	   (= diDsDivInt 0)
	   (cond
	     (
	      (< 0 diDs)
	      (setq diLsAlt
		     (append diLsAlt
			     (list
			       (list diMoDif
				     (append diLsFn
					     (list (nth diCon diLsMod))
				     )
			       )
			     )
		     )
	      )
					;(brkstep1 '("diLsAlt") (list diLsAlt)
					;	"04" "DisMod1"
					;)
	     )
	   )
	  )
	)
	(setq diCon (+ diCon 1))
					;(brkstep1 '("diLsFn" "diDs" "diCon" "diLsMod" "diLsAlt") (list diLsFn diDs diCon diLsMod diLsAlt) "05" "DisMod1")
     )
     (cond
       (
	(not (= diLsAlt nil))
	(setq diLsAlt (orden3 diLsAlt 0 0))
					;(brkstep1 '("diLsAlt") (list diLsAlt) "06" "DisMod1")
	(setq diLsAlt (nthx '(0 1) diLsAlt))
       )
     )
    )
  )
					;(brkstep1 '("diLsFn" "diLsAlt") (list diLsFn diLsAlt) "09" "DisMod1")
  (setq diLsAlt diLsAlt)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;CALCULO DE AREA
(defun carea (en / ar)
  (setq	objnam (vlax-ename->vla-object en)
	ar     (vla-get-area objnam)
  )
  (setq ar ar)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: TRZ
;;OBJETO: Orto. Definicion de angulos ortogonales por medio de la definicion
;;	por medio de la definicion de dos punto.
;;	>
;;DEVUELVE: orParFn. Par de angulos en radianes que define el angulo
;;		perpendicular entre ellos
;;	>(ang1Rad ang2Rad)
;;ARGUMENTOS
;;	1. orCoo10. Coordenada1 (XY) o (XYZ)
;;	> (XY) (XYZ)
;;	2. orCoo20. Coordenada2 (XY) o (XYZ)
;;	> > (XY) (XYZ)
;;	2. orPrec. Precision numerica definida por numero de decimales
;;	>	Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>El primer angulo corresponde al definido por las coordenadas definidas
;;		en el argumento.
;;	>La configuracion minima de la precision es 2
;;;(brkstep '("") "001TEMP" "")
(defun Orto
	    (orCoo10   orCoo20	 orPrec0   /	     orCoo1
	     orCoo2    orPrec	 orParFn   orPreDec  orLPrec
	     orAPrec   orSnap	 orAng1	   orAng2    orPass
	    )
					;	(setq orCoo1 nil  orCoo2 nil orParFn nil
					;		orPrec nil orPreDec nil orSnap nil
					;		orAng1 nil orAng2  nil orPass nil
					;	)
					;	(brkstep '("orCoo10" "orCoo20" "orPrec0") "00" "ORTO")
  (cond
    (
     (and
       (= (type orCoo10) 'LIST)
       (= (type orCoo20) 'LIST)
       (= (type orPrec0) 'INT)
     )
     (cond
       (
	(< orPrec0 2)
	(setq orPrec0 2)
       )
     )
     (setq orLPrec (getvar "luprec")
	   orAPrec (getvar "auprec")
	   orSnap  (getvar "osmode")
	   orPass  0
     )
     (setvar "luprec" 8)
     (setvar "auprec" 8)
     (setvar "osmode" 0)
     (cond
       ((= orPrec nil) (setq orPreDec 0.000015))
       ((= orPrec 1) (setq orPreDec 0.15))
       ((= orPrec 2) (setq orPreDec 0.015))
       ((= orPrec 3) (setq orPreDec 0.0015))
       ((= orPrec 4) (setq orPreDec 0.00015))
       ((= orPrec 5) (setq orPreDec 0.000015))
       ((= orPrec 6) (setq orPreDec 0.0000015))
       ((= orPrec 7) (setq orPreDec 0.00000015))
       ((= orPrec 8) (setq orPreDec 0.00000002))
     )
     (setq orCoo1 orCoo10
	   orCoo2 orCoo20
	   orPrec orPrec0
     )
     (setq orCoo1 (list (nth 0 orCoo1) (nth 1 orCoo1))
	   orCoo2 (list (nth 0 orCoo2) (nth 1 orCoo2))
     )
					;			(brkstep '("orCoo1" "orCoo2") "01" "ORTO")
     (setq orAng1 (angle orCoo1 orCoo2))
					;(brkstep '("orAng1") "02" "ORTO")
     (cond
       (
	(or
	  (equal (round1 orAng1 (- orPrec 1)) 0.0 orPreDec)
	  (equal (round1 orAng1 (- orPrec 1)) pi orPreDec)
	)
	(setq orParFn (list 0.00 (/ pi 2))
	      orPass  1
	)
       )
       (
	(or
	  (equal (round1 orAng1 (- orPrec 1)) (/ pi 2) orPreDec)
	  (equal (round1 orAng1 (- orPrec 1)) (* 1.5 pi) orPreDec)
	)
	(setq orParFn (list (/ pi 2) 0.00)
	      orPass  1
	)
       )
     )
     (cond
       (
	(= orPass 0)
	(setq orParFn
	       (list orAng1 (round1 (sumang orAng1 1.5707963267949) orPrec))
	)
       )
     )
					;			(brkstep '("orParFn") "03" "ORTO")
    )
  )
  (setvar "luprec" orLPrec)
  (setvar "auprec" orAPrec)
  (setvar "osmode" orSnap)
  (setq orParFn orParFn)
)
;
;;
;;;
;;;;
;;PROYECTO: IBS
;;CLASIFICACION:TRZ
;;OBJETO:INSPZA
;;	> Apartir de la lista de blocks y distancias
;;	y par de coordenadas, inserta en serie los
;;	los blocks en su mejor distribucion
;;DEVUELVE:
;;	> metodo 
;;ARGUMENTOS
;;	1.inLsBl0. Lista de pares de blocks y
;;	dimensiones
;;	>( (blockName blDim) ...)
;;	2.inLsCoor0. Lista de coordenadas 2 de trazo
;;	donde se distribuyen los bloques
;;	>((XYZ)(XYZ)) o  ((XY) (XY)
;;	3.inPrec0. Numero entero que determina el numero de
;;	decimales en la precision.
;;	<##>
;;	4. inResp 0. no acomoda 1 si acomoda la ultima pieza
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> calcula los modulos de diferentes medidas
;;	> la lista de dimensiones tiene que estar
;;	ordenada de mayor a menor en dimensiones
;;	dimensiones
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
	  insPza
		(inLsBl0    inLsCoor0  inPrec0	  inResp0     /
		 inLsBl	    inLsCoor   inPrec	  inLsDim    inDist
		 inCon	    InCoOrig   inCoDes	  inDisAc    inAng
		 inNomBl    inResp     inPas	  inFnLs     inNomOut inDist2 inDistMin
		 inDsCon inLsBl00
		)
		;(setq inLsBl nil inLsCoor nil inPrec nil inLsDim nil inDist nil
		;		inCon nil inCoOrig nil inCoDes nil
		;		inDisAc nil inAng nil inNomBl nil inResp nil inPas nil inFnLs nil
		;		inNomOut nil inDist2 nil inDistMin nil inDsCon nil inLsBl00 nil
		;)
			;(brkstep1
			;	'("inLsBl0" "inLsCoor0" "inPrec0")
			;	(list inLsBl0 inLsCoor0 inPrec0)
			;	"00"
			;	"INPZA"
			;)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	(cond
		((= inPrec0 nil) (setq inDecPrec 0.000015))
		((= inPrec0 1) (setq inDecPrec 0.15))
		((= inPrec0 2) (setq inDecPrec 0.015))
		((= inPrec0 3) (setq inDecPrec 0.0015))
		((= inPrec0 4) (setq inDecPrec 0.00015))
		((= inPrec0 5) (setq inDecPrec 0.000015))
		((= inPrec0 6) (setq inDecPrec 0.0000015))
		((= inPrec0 7) (setq inDecPrec 0.00000015))
		((= inPrec0 8) (setq inDecPrec 0.00000002))
	)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (cond
    (
     (and
       (= (type inLsBl0) 'LIST)
       (= (type inLsCoor0) 'LIST)
       (= (type inPrec0) 'INT)
     )
     ;;Variables de entorno (0)******
     (setq inLsBl   inLsBl0
	   inLsCoor inLsCoor0
	   inPrec   inPrec0
		inResp inResp0
     )
     ;;Variables de entorno (1)*******
	(setq inDist2
		(distance
			(nth 0 inLsCoor)
			(nth 1 inLsCoor)
		)
		inDistMin (nth 0 (cdr (nth 0 (orden3 inLsBL 0 1))))
	)
	;(brkstep1 '("inDist2" "inDistMin")
	;	(list inDist2 inDistMin)
	;	"01" "InzPza"
	;)
	;inDist2. Lista de trabajo
	;	< ##.##
	;inDistMin. Distancia de distribucion minima de pieza
	; < ##.##
	(setq inDsCon 0)
	(while
		(< inDsCon (length inLsBl))
		;(brkstep1 '("Distancia" "inDistMin" "Distancia menor o igual")
		;	(list (nthx (list inDsCon 1) inLsBl)
		;		inDistMin
		;		(<= (nthx (list inDsCon 1) inLsBl) inDist2)
		;	)
		;	"02" "InsPza"
		;)
		(cond
			(
				(or
					(equal (nthx (list inDsCon 1) inLsBl) inDistMin inDecPrec)
					(<= (nthx (list inDsCon 1) inLsBl) inDist2)
				)
				(setq inLsBl00 (append inLsBl00 (list (nth inDsCon inLsBL))))
				;(brkstep1 '("inLsBl00") (list inLsBl00) "03" "InsPza")
			)
		)
		(setq inDsCon (+ inDsCon 1))
	)
	;(brkstep1 '("inLsBl00") (list inLsBl00) "04" "InsPza")
	(if
		(not (= inLsBl00 nil))
		(setq inLsBl inLsBl00)
	)
	;(brkstep1 '("inLsBl") (list inLsBl) "05" "InsPza")
     (setq inLsDim
	    (bindls (mapcar 'cdr inLsBl))
     )
	(setq inDist
		(DisMod1 inLsDim
			(distance
				(nth 0 inLsCoor)
				(nth 1 inLsCoor)
			)
		)
	)
	;(brkstep1
	;	'("inLsDim" "inDist" "inDist2" "inLsBL" "inDistMin") 
	;	(list inLsDim inDist inDist2 inLsBl inDistMin)
	;	"05" "INSPZA"
	;)
	;inLsDim.lista de dimensiones en lista sencilla
	;<(## ...)
	;inDist. Lista de distancia de distribucion
	;<(#a #a ... #b... ...)
	(setq inCon 0
		inCoOrig (nth 0 inLsCoor)
	)
	;(brkstep '("inCon" "inCoOrig" "inDist") "02" "INSPZA")
     (while
		(< inCon (length inDist))
		(setq inPas 0)
		(setq inDisAc
			(distance inCoOrig
				(nth 1 inLsCoor)
			)
		)
		;inDisAc. Distancia restantes del total
		; <##.##>
	(setq inAng
		(angle inCoOrig
			(nth 1 inLsCoor)
		)
		inNomBl
		(nthx '(0 0)
		(lnpo
			(nth inCon inDist)
			inLsBl
			1
			1
		)
		      )
	      inCoDes
		      (polar inCoOrig inAng (nth inCon inDist))
	)
					;**inAng. Angulo en radianes de linea
					;<#.##>
					;**inNomBl. Nombre de block
					;<xxx>
					;**inCoDes. Coordenada Destino (siguiente coordenada)
					;<(XY)>
					;				(brkstep
					;					'("(corin4 inLsCoor inCoDes inPrec)"
					;						"inAng"
					;						"inNomBl"
					;						"inCoDes"
					;					)
					;					"03" "INSPZA"
					;				)
	;(brkstep1 '("Cordenada dentro")
	;	(list (corin4 inLsCoor inCoDes inPrec))
	;	"2A" "INZPZA"
	;)
	(cond
	  (
	   (or
	     (= (corin4 inLsCoor inCoDes inPrec) 0)
	     (equal inCoDes (nth 1 inLsCoor) inDecPrec)
	   )
					;(initget 128 "Si No")
					;(setq inResp
					;	(getkword "Desea ajustar la ultima colocacion: ")
					;)
	   (cond
	     (
	      (= inResp 1)
					;(brkstep '("(nth 1 inLsCoor)") "03A" "INSPZA")
	      (setq inCoDes  (nth 1 inLsCoor)
		    inCoOrig
			     (polar (nth 1 inLsCoor)
				    (round1 (angle inCoDes (nth 0 inLsCoor)) inPrec)
				    (nth inCon inDist)
			     )
	      )
					;(brkstep '("inCoDes" "inCoOrig") "04A" "INSPZA")
	     )
	   )
	   (setq inCon (length inDist))
	  )
	  (
	   (= (corin4 inLsCoor inCoDes inPrec) 1)
	   (setq inPas 1)
	  )
	)
	(setq inNomOut inNomBl)
	(cond
	  (
	   (not (= (onam (list inNomBl) "BLOCK" 0) nil))
	   (setq inNomBl
		  (strcat (obten "rutas.csv" "BLOCKS" "RUTA") inNomBl ".dwg")
	   )
	  )
	)
					;				(brkstep '("inNomBl") "05" "INSPZA")
	(command
	  "_insert"
	  inNombl
	  inCoOrig
	  1
	  1
	  (dtr2 inAng)
	)
	(setq inFnLs
	       (append inFnLs
		       (list
			 (list (entlast) inNomOut)
		       )
	       )
	)
					;(brkstep '("inFnLs") "05a" "INSPZA")
	(cond
	  (
	   (= inPas 1)
	   (setq inCon (+ inCon 1))
	   (setq inCoOrig inCoDes)
					;						(brkstep '("inCoOrig" "inCoDes") "06" "INSPZA")
	  )
	)
     )
    )
  )
  (setq inFnLs inFnLs)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;Clasificacion: LIST
;;OBJETO : DisMod
;; Distibucion de correas o portacorreas en
;; una distancia determinada
;; DEVUELVE:
;; diLsFn: Lista numerica de distancias
;;> (#.# #.# ...)
;; ARGUMENTOS
;; 1. diLsMod00: Lista de modulos ordenada de
;;	de mayor a menor segun el factor de
;;	utilizacion, este argumento esde formato
;;	simple, es decir, una lista sencilla de los
;;	modulos disponibles.
;;	cada elemento de la lista es un numero que
;;	representa la distancia de dicho modulo.
;;> (mod1 mod2 ...)
;; 2. diDstr0: Distancia de trabajo
;;> #.#
;;
(defun DisMod
	      (diLsMod0	  diDsTr0    /		diCon	   diDs
	       diLsMod	  diDsTr     diLsFn	diDsDivInt diLsModRv
	       diDsDivDec diLsTr
	      )
					;(setq diCon nil diDs nil diLsMod nil diDsTr nil diDsDivInt nil diLsModRv nil diDsDivDec nil
					;	diLsTr nil diLsFn nil
					;)
					;(brkstep '("diLsMod0" "diDsTr0") "00" "disMod")
  (cond
    (
     (and
       (= (type diLsMod0) 'LIST)
       (= (numberp diDsTr0) t)
     )
     (setq diLsMod diLsMod0
	   diDsTr  diDsTr0
     )
     (setq diDs	 (float diDsTr)
	   diCon 0
     )
					;diDs. Distancia de trabajo <real>
     (while
       (< diCon (length diLsMod))
					;(brkstep '("diCon" "diLsMod" "diDs") "01" "DISMOD")
	(setq diDsDivInt (fix (/ diDs (nth diCon diLsMod)))
	      diDsDivDec (- (/ diDs (nth diCon diLsMod)) diDsDivInt)
	      diDs	 (* diDsDivDec (nth diCon diLsMod))
					; distancia restante
	)
					;(brkstep '("diDsDivInt" "diDs") "02" "DISMOD")
	(cond
	  (
	   (< 0 diDsDivInt)
	   (repeat diDsDivInt
	     (setq diLsFn
		    (append diLsFn (list (nth diCon diLsMod)))
	     )
	   )
	  )
	)
	(setq diCon (+ diCon 1))
					;(brkstep '("diLsFn" "diDs" "diCon" "diLsMod") "03" "DISMOD")
     )
     (cond
       (
	(< 0 diDs)
	(setq diCon 0)
	(setq diLsModRv (reverse diLsMod))
					;(brkstep '("diLsModRv" "diDs") "04" "DISMOD")
	(cond
	  (
	   (<= diDs (nth 0 diLsModRv))
	   (setq diLsFn (append diLsFn (list (nth 0 diLsModRv))))
	  )
	  (
	   (< (nth 0 diLsModRv) diDs)
	   (setq diCon 1)
	   (while
	     (< diCon (length diLsModRv))
					;(brkstep '("diLsFn" "diCon" "diLsModRv") "05" "DISMOD")
	      (cond
		(
		 (and
		   (< (nth (- diCon 1) diLsModRv) diDs)
		   (<= diDs (nth diCon diLsModRv))
		 )
		 (setq diLsFn
			      (append diLsFn (list (nth diCon diLsModRv)))
		       diCon  (length diLsModRv)
		 )
		)
	      )
	      (setq diCon (+ diCon 1))
					;(brkstep '("diLsFn" "diCon" "diLsModRv") "06" "DISMOD") 
	   )
	  )
	)
       )
     )
    )
  )
					;(brkstep '("diLsFn") "07" "DISMOD")
  (setq diLsFn diLsFn)
)
;
;;
;;;
;;;;

;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: DCL
;;OBJETO: DEFPEN1: Con la seleccion de una
;;	linea o la definicion de puntos (2) se define
;;	los angulos ortogonales 
;;	>
;;DEVUELVE:
;;	> 
;;ARGUMENTOS
;;	1. Seleccion de usuario
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;; !!Verificar pendientes!!
;;	> Pendiente indeterminada = "non"
;;	> Pendienre 0 = 0
;;	> Pendiente positiva = 1
;;	> Pendiente negativa = 2
;;;(brkstep '("") "001TEMP" "")
;;******************************
(defun defpen1
	       (/ points p1 p2 ngl mipen pend0 LsAngFn)
					;(setq points nil p1 nil p2 nil ngl nil mipen nil pend0 nil LsAngFn nil)
  (setq points (ssget '((0 . "line"))))
  (cond
    (
     (= points nil)
     (setq p1 (getpoint "SELECCIONE EL PRIMER PUNTO: ")
	   P2 (getpoint p1 "SELECCIONE EL SEGUNDO PUNTO: ")
     )
    )
    (
     (not (= points nil))
     (setq p1 (cdr (assoc 10 (entget (ssname points 0))))
	   p2 (cdr (assoc 11 (entget (ssname points 0))))
     )
    )
  )
  (setq	ngl (angle p1 p2)
					;ngl (round1 ngl 4)
  )
  (cond
    (
     (or (equal (round1 ngl 4) 4.71238898038469 0.0001)
	 (equal (round1 ngl 4) 1.5707963267949 0.0001)
     )
     (setq mipen "non")
     (setq LsAngFn (list 0 ngl "non"))
    )
    (
     (and
       (not (equal ngl 4.71238898038469 0.0001))
       (not (equal ngl 1.5707963267949 0.0001))
     )
     (setq pend0
	    (ppnd2 p1 p2)
     )
     (cond
       (
	(equal pend0 0 0.0001)
	(setq mipen "0")
	(setq LsAngFn (list 0 1.5707963267949))
       )
       (
	(< 0 pend0)
	(setq mipen "1")
	(setq LsAngFn (list ngl (sumang ngl (/ pi 2))))
       )
       (
	(> 0 pend0)
	(setq mipen "2")
	(setq LsAngFn (list (sumang ngl (/ pi 2)) ngl))
       )
     )
    )
  )
					;(brkstep '("LsAngFn") "01" "defpen1")
  (setq LsAngFn LsAngFn)
)
;
;;
;;;
;;;;

;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: DLG (Ejecutable de cuadro de dialogo)
;;OBJETO: TB: Ejecucion del cuadro de dialogo del cuadro de dialogo 
;;	de creacion de tableros
;;	>  Nombre del dialogo: tablero
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	> PASVAL(); PASVAL1 (); LISCAJA ()
;;	RENOM0 (); BORRTAB (); MIRA1 (); MIRA2 () CILCO
;;ANOTACIONES
;;	> paction pval
;;;(brkstep '("") "001TEMP" "")
(defun c:tb
	    (/	      mdcl     nomustab	opendial miarch	  flag
			midial   dcl_id   mipoli	pp1	 pp7	  pas
			sal      v1       nomac	nomnv	 melref	  mmll
			hdlt     colatt   w	h	 rfpl	  coltxt
			nn1      mmll     mmll0	mmll1	 mmll2	  mmll3
			mmll4    mmll5    mmll6	val2	 why2	  val3
			why3     val4     why4	val9	 why9	  val10
			why10    val11    why11	val12	 why12	  val13
			why13    valtab0a valtab0b	ssval	 hdd	  colatt
			pascolor valp1    paspend	passis	 nome2	  pashd
			miEje    miEjeD   ttcon	ttcon1	 LsCorrea selCorrea
			FnCorrea LsPorta  selPorta	FnPorta	 FnPortaLs
			tTab     tArea    auTab	auNomTab auClr	  auLsTab
			auTotEle auTotCo  auTotPo
;;;;;;;;;;;;;;;;;;
			;;Variables de evaluacion (0)
			;lstCorrea lstPorta
			;;Variables de evaluacion (1)
;;;;;;;;;;;;;;;;;;
					;vcorrea whycorrea
					;vporta whyporta
	    )
  ;;Variables temporales (0)******
  (setq	lsustab	nil
	valtab nil
	valtab1	nil
	valtab0	nil
	valineacion
	 nil
	walineacion
	 nil
	vcorrea	nil
	wcorrea	nil
	vporta nil
	wporta nil
	tipo nil
	alinang0 nil
	anCorrea nil
	anPorta	nil
	wcorrea_an
	 nil
	vcorrea_an
	 nil
	wporta_an nil
	vporta_an nil
	wdist_eje nil
	vdist_eje nil
	dist_eje nil
	vdist_correa
	 nil
	wdist_correa
	 nil
	vdist_portacorrea
	 nil
	wportacorrea
	 nil
	miCorrea nil
	miPorta	nil
	vniveles nil
	wniveles nil
	vambos nil
	vdividido nil
  )
  ;;Variables de Trabajo (0)******
  (setq 
	lstCorrea nil
	lstPorta nil
	)
  ;;Variables de Trabajo (1)******
  ;;Variables locales (1)*********
  ;;******************************
  ;;RUTA de archivos (0)*******************
  (setq	miarch
	       (strcat
		 (obten "rutas.csv" "DCL_LISP" "RUTA")
		 "DCL_TTB1.dcl"
	       )
	midial "tablero1"
	mdcl
	       (strcat
		 (obten "rutas.csv" "DCL_LISP" "RUTA")
		 "DCL_OBJETOS.lsp"
	       )
  )
  ;;RUTA de archivos (1)*******************
					;(brkstep '("miarch" "midial" "mdcl") "01" "tb")
  (load mdcl)
  ;;Carga de archivo (1)*******************
  ;;Definicion de tableros existentes (0)***
					;(actual)
  (if
    (qcodls "nvtablero" 1000)
     (setq lsustab (qcodls "nvtablero" 1000))
					;(setq lsustab (list "Nombre Tablero"))
  )
  (setq lsustab lsustab)
  ;;Definicion de tableros existentes (1)***
  ;;Definicion de variables publicas = nil******(0)
  (setq pval nil)
  (setq paction nil)
  ;;Definicion de variables publicas = nil******(1)
					;(brkstep '("pval" "paction") "00" "TTB")
  ;;Carga dialogo y flag (0)****************
  (setq flag 4)
  (setq dcl_id (load_dialog miarch))
  ;;Carga dialogo y flag (1)****************
  (while
    (> flag 2)
     ;;Abre dialogo (0)*********************
     (if
       (not (new_dialog midial dcl_id))
	(exit)
     )
     ;;Abre dialogo (1)*********************
     ;;Definicion de controles iniciales(0)**
     (cond
       (
	(= vcorrea_4 nil)
	(setq vcorrea_4 "1")
	(set_tile "correa_4" "1")
       )
       (
	(not (= vcorrea_4 nil))
	(set_tile "correa_4" vcorrea_4)
       )
     )
     (cond
       (
	(= vcorrea_3 nil)
	(setq vcorrea_3 "2")
	(set_tile "correa_3" "2")
       )
       (
	(not (= vcorrea_3 nil))
	(set_tile "correa_3" vcorrea_3)
       )
     )
     (cond
       (
	(= vcorrea_2 nil)
	(setq vcorrea_2 "3")
	(set_tile "correa_2" "3")
       )
       (
	(not (= vcorrea_2 nil))
	(set_tile "correa_2" vcorrea_2)
       )
     )
     (cond
       (
	(= vcorrea_1 nil)
	(setq vcorrea_1 "4")
	(set_tile "correa_1" "4")
       )
       (
	(not (= vcorrea_1 nil))
	(set_tile "correa_1" vcorrea_1)
       )
     )
     (cond
       (
	(= vcorrea_085 nil)
	(setq vcorrea_085 "0")
	(set_tile "correa_085" "0")
       )
       (
	(not (= vcorrea_085 nil))
	(set_tile "correa_085" vcorrea_085)
       )
     )
     (cond
       (
	(= vportacorrea_4 nil)
	(setq vportacorrea_4 "1")
	(set_tile "portacorrea_4" "1")
       )
       (
	(not (= vportacorrea_4 nil))
	(set_tile "portacorrea_4" vportacorrea_4)
       )
     )
     (cond
       (
	(= vportacorrea_3 nil)
	(setq vportacorrea_3 "2")
	(set_tile "portacorrea_3" "2")
       )
       (
	(not (= vportacorrea_3 nil))
	(set_tile "portacorrea_3" vportacorrea_3)
       )
     )
     (cond
       (
	(= vportacorrea_2 nil)
	(setq vportacorrea_2 "3")
	(set_tile "portacorrea_2" "3")
       )
       (
	(not (= vportacorrea_2 nil))
	(set_tile "portacorrea_2" vportacorrea_2)
       )
     )
     (cond
       (
	(= vportacorrea_1 nil)
	(setq vportacorrea_1 "4")
	(set_tile "portacorrea_1" "4")
       )
       (
	(not (= vportacorrea_1 nil))
	(set_tile "portacorrea_1" vportacorrea_1)
       )
     )
     (cond
       (
	(= vportacorrea_616 nil)
	(setq vportacorrea_616 "0")
	(set_tile "portacorrea_616" "0")
       )
       (
	(not (= vportacorrea_616 nil))
	(set_tile "portacorrea_616" vportacorrea_616)
       )
     )
     (cond
       (
	(= vdist_eje nil)
	(set_tile "distancia_eje" "0.20")
	(setq vdist_eje "0.20")
	(set_tile "distancia_eje" "0.20")
       )
       (
	(not (= vdist_eje nil))
	(set_tile "distancia_eje" vdist_eje)
       )
     )
     (cond
       (
	(= tipo nil)
	(mode_tile "alineacion_button" 1)
       )
       (
	(= tipo "CORREA")
	(set_tile "correa_radio" "1")
       )
       (
	(= tipo "PORTACORREA")
	(set_tile "portacorrea_radio" "1")
       )
     )
     (mode_tile "correa_angulo" 1)
     (mode_tile "porta_angulo" 1)
     (liscaja "existentes" lsustab)
     (cond
       (
	(not (= anCorrea nil))
	(mode_tile "correa_angulo" 0)
	(set_tile "correa_angulo"
		  (rtos (round1 (dtr2 anCorrea) 2))
	)
	(mode_tile "correa_angulo" 1)
       )
     )
     (cond
       (
	(not (= anPorta nil))
	(mode_tile "porta_angulo" 0)
	(set_tile "porta_angulo"
		  (rtos (round1 (dtr2 anPorta) 2))
	)
	(mode_tile "porta_angulo" 1)
       )
     )
     (cond
       (
	(not (= colatt nil))
	(setq w	(dimx_tile "color_image")
	      h	(dimy_tile "color_image")
	)
	(start_image "color_image")
	(fill_image 0 0 w h colatt)
	(end_image)
       )
       (
	(= colatt nil)
	(setq colatt 256
	      coltxt "256"
	)
	(setq w	(dimx_tile "color_image")
	      h	(dimy_tile "color_image")
	)
	(start_image "color_image")
	(fill_image 0 0 w h colatt)
	(end_image)
       )
     )
     (cond
       (
	(or (= vambos nil)
	    (= vambos "0")
	)
	(set_tile "ambos" "0")
	(setq vambos "0")
       )
       (
	(= vambos "1")
	(set_tile "ambos" "1")
       )
     )
     (cond
       (
	(or (= vdividido nil)
	    (= vdividido "0")
	)
	(set_tile "dividido" "0")
	(setq vdividido "0")
       )
       (
	(= vdividido "1")
	(set_tile "dividido" "1")
       )
     )
     (cond
       (
	(= vniveles nil)
	(setq vniveles "1")
	(set_tile "niveles_box" "1")
       )
       (
	(not (= vniveles nil))
	(set_tile "niveles_box" vniveles)
       )
     )
     (cond
       (
	(= vdist_correa nil)
	(setq vdist_correa "0.515")
	(set_tile "dist_correa" "0.515")
       )
       (
	(not (= vdist_correa nil))
	(set_tile "dist_correa" vdist_correa)
       )
     )
     (cond
       (
	(= vdist_portacorrea nil)
	(setq vdist_portacorrea "1.00")
	(set_tile "dist_portacorrea" "1.00")
       )
       (
	(not (= vdist_portacorrea nil))
	(set_tile "dist_portacorrea" vdist_portacorrea)
       )
     )
     ;;Definicion de controles iniciales(1)**
     ;;************************
     ;;Definicion de controles en accion (0)***********************
     ;;Distancia_Eje********(0)
     (action_tile
       "distancia_eje"
       "(setq vdist_eje $value)
			(setq wdist_eje $reason)
			"
     )
     ;;Distancia_Eje********(1)
     ;;************************
     ;;Definicion_Eje*******(0)
     (action_tile
       "def_eje"
       "(setq pas \"EjeDef\")
			(done_dialog 4)"
     )
     ;;Definicion_Eje*******(1)
     ;;*********************************
     ;;"table" Definicion de tablero (0)
     (action_tile
       "table"
       "(setq pas \"table\")
			(done_dialog 4)"
     )
     ;;"Table" Definicion de tablero (1)
     ;;**********************************
     ;;"auto" Definicion de Trazo e insersion automatica (0)
     (action_tile
       "auto"
       "(setq pas \"auto\")
			(done_dialog 4)"
     )
     ;;"auto" Definicion de Trazo e insersion automatica (1)
     ;;*********************************
     ;;"def_guia" Trazo de guias(0)
     (action_tile
       "def_guia"
       "(setq pas \"def_guia\")
			(done_dialog 4)"
     )
     ;;"def_guia" Trazo de guias(1)
     ;;*********************************
     ;;"ambos" Opcion de trazo de ejes por ambos lados (0)
     (action_tile
       "ambos"
       "(setq Vambos $value)"
     )
     ;;"ambos" Opcion de trazo de ejes por ambos lados (1)
     ;;*********************************
     ;;"dividido" Opion de division de distancia establecida (0)
     (action_tile
       "dividido"
       "(setq Vdividido $value)"
     )
     ;;"dividido" Opion de division de distancia establecida (1)
     ;;*********************************
     ;; "ins_pza" "Inserta correas y portaCorreas" (0)
     (action_tile
       "ins_pza"
       "(setq pas \"ins_pza\")
			(done_dialog 4)
			"
     )
     ;; "ins_pza" "Inserta correas y portaCorreas" (1)
     ;;*********************************
     ;;action_tile OK*******
     (action_tile
       "accept"
       "(done_dialog)
			(setq salida (pasval1 paction pval lsustab))"
     )
     ;;action_tile OK*******
;;;*************************************
     ;; "correa_radio" "Definicion sobre correas" (0)
     (action_tile
       "correa_radio"
       "(setq vcorrea $value)
			(setq whycorrea $reason)
			(setq tipo \"CORREA\")
			(setq passis \"CORREA\")
			(mode_tile \"alineacion_button\" 0)
			"
     )
     ;; "correa_radio" Definicion sobre correa (1)
;;;*************************************
     ;; "portacorrea_radio" Definicion sobre portacorrea(0)
     (action_tile
       "portacorrea_radio"
       "(setq vporta $value)
			(setq whyporta $reason)
			(setq tipo \"PORTACORREA\")
			(setq passis \"PORTACORREA\")
			(mode_tile \"alineacion_button\" 0)"
     )
     ;; "portacorrea_radio" Definicion sobre portacorrea (1)
;;;*************************************
     ;; "alineacion_button" Comando de definicion (0)
     (action_tile
       "alineacion_button"
       "(setq valineacion $value)
			(setq walineacion $reason)
			(setq pas \"alineacion\")
			(done_dialog 4)"
     )
     ;; "alineacion_button" Comando de definicion (1)
;;;**************************************
     ;; "correa_angulo" Definicion de angulo de correa (0)
     (action_tile
       "correa_angulo"
       "(setq vcorrea_an $value)
			(setq wcorrea_an $reason)"
     )
     ;; "9" "corrrea_angulo" Definicion de angulo de correa (1)
;;;**************************************
     ;; "porta_angulo" Definicion de angulos de portacorreas (0)
     (action_tile
       "porta_angulo"
       "(setq vporta_an $value)
			(setq wporta_an $reason)"
     )
     ;; "porta_angulo" Definicion de angulos de portacorreas (1)
;;;**************************************
     ;;"dist_correa" "Definicion de distancia entre correa" (0)
     (action_tile
       "dist_correa"
       "(setq vdist_correa $value)
			(setq wdist_correa $reason)
			"
     )
     ;;"dist_correa" "Definicion de distancia entre correa" (1)
;;;*************************************
     ;;"dist_portacorrea" "Definicion de distancia entre portacorrea" (0)
     (action_tile
       "dist_portacorrea"
       "(setq vdist_portacorrea $value)
			(setq wdist_portacorrea $reason)
			"
     )
     ;;"dist_correa" "Definicion de distancia entre correa" (1)
;;;**************************************
     ;;	"color_button" "COLOR" (0)
     (action_tile
       "color_button"
       "(setq val5 $value)
			(setq why5 $reason)
			(setq pas \"color\")
			(done_dialog 4)"
     )
     ;;	"color_button" "COLOR" (1)
;;;****************************************
     ;;	"niveles_box" "NIVELES" (0)
     (action_tile
       "niveles_box"
       "(setq vniveles $value)
			(setq wniveles $reason)
			(setq pas \"niveles\")
			(done_dialog 4)"
     )
     ;;	"niveles_box" "NIVELES" (1)
     ;;******************************************
     ;;"correa_4" (0)
     (action_tile
       "correa_4"
       "(setq vcorrea_4 $value)"
     )
     ;;"correa_4" (1)
     ;;******************************************
     ;;******************************************
     ;;"correa_3" (0)
     (action_tile
       "correa_3"
       "(setq vcorrea_3 $value)"
     )
     ;;"correa_3" (1)
     ;;******************************************
     ;;******************************************
     ;;"correa_2" (0)
     (action_tile
       "correa_2"
       "(setq vcorrea_2 $value)"
     )
     ;;"correa_2" (1)
     ;;******************************************
     ;;******************************************
     ;;"correa_1" (0)
     (action_tile
       "correa_1"
       "(setq vcorrea_1 $value)"
     )
     ;;"correa_1" (1)
     ;;******************************************
     ;;******************************************
     ;;"correa_085" (0)
     (action_tile
       "correa_085"
       "(setq vcorrea_085 $value)"
     )
     ;;"correa_085" (1)
     ;;******************************************
     ;;******************************************
     ;;"portacorrea_4" (0)
     (action_tile
       "portacorrea_4"
       "(setq vportacorrea_4 $value)"
     )
     ;;"portacorrea_4" (1)
     ;;******************************************
     ;;******************************************
     ;;"portacorrea_3" (0)
     (action_tile
       "portacorrea_3"
       "(setq vportacorrea_3 $value)"
     )
     ;;"portacorrea_3" (1)
     ;;******************************************
     ;;******************************************
     ;;"portacorrea_2" (0)
     (action_tile
       "portacorrea_2"
       "(setq vportacorrea_2 $value)"
     )
     ;;"portacorrea_2" (1)
     ;;******************************************
     ;;******************************************
     ;;"portacorrea_1" (0)
     (action_tile
       "portacorrea_1"
       "(setq vportacorrea_1 $value)"
     )
     ;;"portacorrea_1" (1)
     ;;******************************************
     ;;******************************************
     ;;"portacorrea_616" (0)
     (action_tile
       "portacorrea_616"
       "(setq vportacorrea_616 $value)"
     )
     ;;"portacorrea_616" (1)
     ;;******************************************
     ;;Definicion de controles en accion (1)****
;;;****************************************
     ;;inicia accion FLAG************(0)
     (setq flag (start_dialog))
     (cond
       (
	(and (= flag 4) (= pas "auto"))
	(cond
	  ((= coltxt nil) (setq auClr "256"))
	  ((not (= coltxt nil)) (setq auClr coltxt))
	)
					;(alert "auto")
	(cond
	  ((= vniveles nil) (setq vniveles "1"))
	)
	(setq auTab (TabTar1))
					;(brkstep '("auTab" "auClr" "vniveles") "01" "auto")
	(cond
	  (
	   (not (= auTab nil))
	   (setq auNomTab (cdr (assoc 5 (entget (nth 0 auTab)))))
	   (setq auLsTab
		  (list
		    (list "ELEMENTO" "PL_poligonal")
		    (list "MATERIAL" "PL_Panel")
		    (list "NIVELES" vniveles)
		    (list "CORREA" (rtos (round1 (dtr2 (nthx '(1 0) auTab)) 1)))
		    (list "PORTACORREA"
			  (rtos (round1 (dtr2 (nthx '(2 0) auTab)) 1))
		    )
		    (list "COLOR" auClr)
		    (list "OCULTO" "1")
		    (list "ID" auNomTab)
		    (list "AREA" (rtos (Carea (nth 0 auTab))))
		  )
	   )
					;(brkstep '("auLsTab") "02" "auto")
	   (xin2
	     "XD_NOVIDESA"
	     (nth 0 auTab)
	     "PL_poligonal"
	     auLsTab
	   )
	   (cam1 (list (nth 0 auTab)) '(8 . "PL_Panel"))
	   ;;
;;;;;;;;;;;;;;;;;;;METODO AUTOMATICO*****(0)
	   (cond ((= vcorrea_4 nil) (setq vcorrea_4 "1")))
	   (cond ((= vcorrea_3 nil) (setq vcorrea_3 "2")))
	   (cond ((= vcorrea_2 nil) (setq vcorrea_2 "3")))
	   (cond ((= vcorrea_1 nil) (setq vcorrea_1 "4")))
	   (cond ((= vcorrea_085 nil) (setq vcorrea_085 "0")))
	   (cond ((= vportacorrea_4 nil) (setq vportacorrea_4 "1")))
	   (cond ((= vportacorrea_3 nil) (setq vportacorrea_3 "2")))
	   (cond ((= vportacorrea_2 nil) (setq vportacorrea_2 "3")))
	   (cond ((= vportacorrea_1 nil) (setq vportacorrea_1 "4")))
	   (cond ((= vportacorrea_616 nil) (setq vportacorrea_616 "0")))
	   (setq lstCorrea
		  (list
		    (list (atoi vcorrea_4) (list "PL_correa4" 4.00))
		    (list (atoi vcorrea_3) (list "PL_correa3" 3.00))
		    (list (atoi vcorrea_2) (list "PL_correa2" 2.00))
		    (list (atoi vcorrea_1) (list "PL_correa1" 1.00))
		    (list (atoi vcorrea_085) (list "PL_correa085" 0.85))
		  )
	   )
	   (setq lstPorta
		  (list
		    (list (atoi vportacorrea_4) (list "PL_portacorrea4" 4.11))
		    (list (atoi vportacorrea_3) (list "PL_portacorrea3" 3.08))
		    (list (atoi vportacorrea_2) (list "PL_portacorrea2" 2.05))
		    (list (atoi vportacorrea_1) (list "PL_portacorrea1" 1.114))
		    (list (atoi vportacorrea_616)
			  (list "PL_portacorrea616" 0.616)
		    )
		  )
	   )
	   (setq lstCorrea (lnpo 0 lstCorrea 0 0))
	   (setq lstPorta (lnpo 0 lstPorta 0 0))
		(setq lstCorrea (orden3 lstCorrea 0 0))
		(setq lstPorta (orden3 lstPorta 0 0))
	   (setq lstCorrea (mapcar 'cdr lstCorrea))
	   (setq lstPorta (mapcar 'cdr lstPorta))
	   (setq lstCorrea (mapcar 'car lstCorrea))
	   (setq lstPorta (mapcar 'car lstPorta))
		;(brkstep1 '("lstCorrea" "lstPorta") (list lstCorrea lstPorta) "03" "auto")
	   (setq auTotEle
		  (InCoPc
		    auTab
		    lstCorrea
		    lstPorta
		    (list
		      (list "ELEMENTO" "GUIA")
		      (list "TABLERO" auNomTab)
		      (list "COLOR" "256")
		      (list "OCULTO" "1")
		      (list "ID" "-")
		      (list "TIPO" "CORREA")
		    )
		    (list
		      (list "ELEMENTO" "GUIA")
		      (list "TABLERO" auNomTab)
		      (list "COLOR" "256")
		      (list "OCULTO" "1")
		      (list "ID" "-")
		      (list "TIPO" "PORTACORREA")
		    )
		    (list
		      (list "ELEMENTO" "-")
		      (list "TABLERO" auNomTab)
		      (list "MATERIAL" "-")
		      (list "NIVELES" vniveles)
		      (list "COLOR" "256")
		      (list "LARGO" "1")
		      (list "OCULTO" "1")
		      (list "ID" "-")
		    )
		    (list
		      (list "ELEMENTO" "-")
		      (list "TABLERO" auNomTab)
		      (list "MATERIAL" "-")
		      (list "NIVELES" vniveles)
		      (list "COLOR" "256")
		      (list "LARGO" "1")
		      (list "OCULTO" "1")
		      (list "ID" "-")
		    )
		    "TIPO"
		    "GUIA"
		    "XD_NOVIDESA"
		    0.515
		    1.00
		    0.040
		    0.50
		    "MATERIAL"
		    2
		    "ID"
		    7
		  )
	   )
;;;;;;;;;;;;;;;;;;;METODO AUTOMATICO*****(1)
	   (cond
	     (
	      (not (= auTotEle nil))
					;(brkstep '("auTotEle") "03" "auto")
	      (setq auTotCo
		     (exnoma "XD_NOVIDESA"
			     '((1000 . "ELEMENTO,GUIA") (1000 . "TIPO,CORREA"))
			     auTotEle
		     )
	      )
					;(brkstep '("auTotCo") "04" "auto")
	      (cond
		(
		 (not (= auTotCo nil))
		 (cam1 auTotCo (cons 8 "IBSGUIA_Correa"))
		)
	      )
	      (setq auTotPo
		     (exnoma
		       "XD_NOVIDESA"
		       '((1000 . "ELEMENTO,GUIA") (1000 . "TIPO,PORTACORREA"))
		       auTotEle
		     )
	      )
					;(brkstep '("auTotPo") "04" "auto")
	      (cond
		(
		 (not (= auTotPo nil))
		 (cam1 auTotPo (cons 8 "IBSGUIA_Portacorrea"))
		)
	      )
	     )
	   )
	  )
	)
       )
       (
	(and (= flag 4) (= pas "ins_pza"))
	(setq pas 0)
	(cond ((= vcorrea_4 nil) (setq vcorrea_4 "1")))
	(cond ((= vcorrea_3 nil) (setq vcorrea_3 "2")))
	(cond ((= vcorrea_2 nil) (setq vcorrea_2 "3")))
	(cond ((= vcorrea_1 nil) (setq vcorrea_1 "4")))
	(cond ((= vcorrea_085 nil) (setq vcorrea_085 "0")))
	(cond ((= vportacorrea_4 nil) (setq vportacorrea_4 "1")))
	(cond ((= vportacorrea_3 nil) (setq vportacorrea_3 "2")))
	(cond ((= vportacorrea_2 nil) (setq vportacorrea_2 "3")))
	(cond ((= vportacorrea_1 nil) (setq vportacorrea_1 "4")))
	(cond ((= vportacorrea_616 nil) (setq vportacorrea_616 "0")))
	(setq lstCorrea
	       (list
		 (list (atoi vcorrea_4) (list "PL_correa4" 4.00))
		 (list (atoi vcorrea_3) (list "PL_correa3" 3.00))
		 (list (atoi vcorrea_2) (list "PL_correa2" 2.00))
		 (list (atoi vcorrea_1) (list "PL_correa1" 1.00))
		 (list (atoi vcorrea_085) (list "PL_correa085" 0.85))
	       )
	)
	(setq lstPorta
	       (list
		 (list (atoi vportacorrea_4) (list "PL_portacorrea4" 4.11))
		 (list (atoi vportacorrea_3) (list "PL_portacorrea3" 3.08))
		 (list (atoi vportacorrea_2) (list "PL_portacorrea2" 2.05))
		 (list (atoi vportacorrea_1) (list "PL_portacorrea1" 1.114))
		 (list (atoi vportacorrea_616)
		       (list "PL_portacorrea616" 0.616)
		 )
	       )
	)
	(setq lstCorrea (lnpo 0 lstCorrea 0 0))
	(setq lstPorta (lnpo 0 lstPorta 0 0))
	(setq lstCorrea (orden3 lstCorrea 0 0))
	(setq lstPorta (orden3 lstPorta 0 0))
	;(brkstep1 '("lstCorrea" "lstPorta") (list lstCorrea lstPorta) "01" "ins_pza")
	(setq lstCorrea (mapcar 'cdr lstCorrea))
	(setq lstPorta (mapcar 'cdr lstPorta))
	(setq lstCorrea (mapcar 'car lstCorrea))
	(setq lstPorta (mapcar 'car lstPorta))
	;(brkstep1 '("lstCorrea" "lstPorta") (list lstCorrea lstPorta) "02" "ins_pza")
	(cond
	  (
	   (= tipo "CORREA")
	   (setq LsCorrea lstCorrea)
	   (setq selCorrea
		  (ssget '((-3 ("XD_NOVIDESA"))))
	   )
	   (cond
	     (
	      (not (= selCorrea nil))
	      (setq selCorrea (noment selCorrea))
	      (setq selCorrea
		     (exnoma
		       "XD_NOVIDESA"
		       (list (cons 1000 "ELEMENTO,GUIA")
			     (cons 1000 "TIPO,CORREA")
		       )
		       selCorrea
		     )
	      )
					;(brkstep '("selCorrea") "Ins_pza" "TTB")
	      (setq ttCon 0)
	      (while (< ttCon (length selCorrea))
		(setq FnCorrea
		       (insPza LsCorrea 
				 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;correccion
			       (list
				 (cdr
				   (assoc 10 (entget (nth ttCon SelCorrea)))
				 )
				 (cdr
				   (assoc 11 (entget (nth ttCon SelCorrea)))
				 )
			       )
			       4 ;;;;;;;;;;;;;;;;;;;;;;;CORIN4-4correccion
			       1
		       )
		)
		(cond
		  (
		   (not (= FnCorrea nil))
		   (setq ttcon1 0)
		   (while (< ttcon1 (length FnCorrea))
		     (xin2 "XD_NOVIDESA"
			   (nthx (list ttcon1 0) FnCorrea)
			   (nthx (list ttcon1 1) FnCorrea)
			   (list
			     (list "ELEMENTO"
				   (nthx (list ttcon1 1) FnCorrea)
			     )
			     (list "TABLERO" "-")
			     (list "MATERIAL"
				   (nthx (list ttcon1 1) FnCorrea)
			     )
			     (list "NIVELES" vniveles)
			     (list "COLOR" coltxt)
			     (list "LARGO" "1")
			     (list "OCULTO" "1")
			     (list "ID" "-")
			   )
		     )
		     (setq ttcon1 (+ ttcon1 1))
		   )
		   (setq ttcon1 0)
		  )
		)
		(setq ttcon (+ ttcon 1))
	      )
	      (setq ttCon 0)
	     )
	   )
	  )
	  (
	   (= tipo "PORTACORREA")
	   (setq LsPorta lstPorta)
	   (setq selPorta
		  (ssget '((-3 ("XD_NOVIDESA"))))
	   )
	   (cond
	     (
	      (not (= selPorta nil))
	      (setq selPorta (noment selPorta))
	      (setq selPorta
		     (exnoma
		       "XD_NOVIDESA"
		       (list (cons 1000 "ELEMENTO,GUIA")
			     (cons 1000 "TIPO,PORTACORREA")
		       )
		       selPorta
		     )
	      )
					;(brkstep '("selPorta") "Ins_pza" "TTB")
	      (setq ttCon 0)
	      (while (< ttCon (length selPorta))
		(setq FnPorta
		       (insPza LsPorta
			       (list
				 (cdr (assoc 10 (entget (nth ttCon SelPorta))))
				 (cdr (assoc 11 (entget (nth ttCon SelPorta))))
			       )
			       4 ;;;;;;;;;;;;;;;;;;;;;;;;CORIN4 CORRECCION
			       1
		       )
		)
		(cond
		  (
		   (not (= FnPorta nil))
		   (setq ttcon1 0)
		   (while (< ttcon1 (length FnPorta))
		     (xin2 "XD_NOVIDESA"
			   (nthx (list ttcon1 0) FnPorta)
			   (nthx (list ttcon1 1) FnPorta)
			   (list
			     (list "ELEMENTO"
				   (nthx (list ttcon1 1) FnPorta)
			     )
			     (list "TABLERO" "-")
			     (list "MATERIAL"
				   (nthx (list ttcon1 1) FnPorta)
			     )
			     (list "NIVELES" vniveles)
			     (list "COLOR" coltxt) 
			     (list "LARGO" "1")
			     (list "OCULTO" "1")
			     (list "ID" "-")
			   )
		     )
		     (setq ttcon1 (+ ttcon1 1))
		   )
		   (setq ttcon1 0)
		  )
		)
		(setq ttcon (+ ttcon 1))
	      )
	      (setq ttCon 0)
	     )
	   )
	  )
	)
       )
       (
	(and (= flag 4) (= pas "EjeDef"))
	(setq pas 0)
	(cond
	  (
	   (= colatt nil)
	   (setq coltxt "256")
	  )
	  (
	   (not (= colatt nil))
	   (setq coltxt (itoa colatt))
	  )
	)
	(cond
	  (
	   (not (= vdist_eje nil))
	   (setq miEjeD (atof vdist_eje))
	   (cond
	     (
	      (= vdividido "1")
	      (setq miEjeD (/ miEjeD 2))
					;(brkstep '("miEjeD") "01" "EjeDef")
	     )
	   )
	   (cond
	     (
	      (= vambos "1")
	      (setq miEje (EjePar miEjeD 1))
	     )
	     (
	      (not (= vambos "1"))
	      (setq miEje (EjePar miEjeD 0))
	     )
	   )
	   (cond
	     (
	      (not (= miEje nil))
	      (foreach m miEje
		(xin2 "XD_NOVIDESA"
		      m
		      "GUIA"
		      (list (list "ELEMENTO" "GUIA")
			    (list "TABLERO" "-")
			    (list "COLOR" coltxt)
			    (list "OCULTO" "1")
			    (list "ID" "-")
			    (list "TIPO" "EJE")
		      )
		)
	      )
	      (cam1 miEje (cons 62 (atoi coltxt)))
	      (cam1 miEje (cons 8 "IBSEJE"))
					;(brkstep '("miEje") "02" "EjeDef")
	     )
	   )
	  )
	)
       )
       (
	(and (= flag 4) (= pas "table"))
	(setq tTab (TabTar0))
	;;tTab. Nombre de entidad y angulos de alineacion
	;; del nuevo tablero
;;;;;;;;;;;;Definicion de Atributos
	;; ELEMENTO, MATERIAL, NIVELES, CORREA,
	;;	PORTACORREA, COLOR, OCULTO, ID, AREA
	(cond
	  (
	   (not (= tTab nil))
	   (cond
	     (
	      (= vniveles nil)
	      (setq vniveles "1")
	     )
	   )
	   (setq vcorrea_an (rtos (round1 (dtr2 (nthx '(1 0) tTab)) 1)))
	   (set_tile "correa_angulo" vcorrea_an)
	   (setq vporta_an (rtos (round1 (dtr2 (nthx '(1 1) tTab)) 1)))
	   (cond
	     (
	      (= colatt nil)
	      (setq coltxt "256")
	     )
	     (
	      (not (= colatt nil))
	      (setq coltxt (itoa colatt))
	     )
	   )
	   (setq tArea (rtos (Carea (nth 0 tTab))))
	   (xin2 "XD_NOVIDESA"
		 (nth 0 tTab)
		 "PL_poligonal"
		 (list
		   (list "ELEMENTO" "PL_poligonal")
		   (list "MATERIAL" "PL_Panel")
		   (list "NIVELES" vniveles)
		   (list "CORREA" vcorrea_an)
		   (list "PORTACORREA" vporta_an)
		   (list "COLOR" coltxt)
		   (list "OCULTO" "1")
		   (list "ID" "-")
		   (list "AREA" tArea)
		 )
	   )
	   (cam1 (list (nth 0 tTab)) (cons 62 (atoi coltxt)))
	   (cam1 (list (nth 0 tTab)) (cons 8 "PL_Panel"))
	  )
	)
       )
       (
	(and (= flag 4) (= pas "alineacion"))
	(setq pas 0)
	(setq alinang0 (TaDf))
					;(brkstep '("alinang0") "temp" "tb") 
	(cond
	  (
	   (not (= alinang0 nil))
	   (cond
	     (
	      (= tipo "CORREA")
	      (setq anCorrea (nth 0 alinang0)
		    anPorta  (nth 1 alinang0)
	      )
	     )
	     (
	      (= tipo "PORTACORREA")
	      (setq anPorta  (nth 0 alinang0)
		    anCorrea (nth 1 alinang0)
	      )
	     )
	   )
					;(alert (rtos (round1 (dtr2 anPorta) 2)))
	   (mode_tile "porta_angulo" 0)
	   (set_tile "porta_angulo"
		     (rtos (round1 (dtr2 anPorta) 2))
	   )
					;(alert (rtos (round1 (dtr2 anCorrea) 2)))
	   (mode_tile "correa_angulo" 0)
	   (set_tile "correa_angulo"
		     (rtos (round1 (dtr2 anCorrea) 2))
	   )
	  )
	)
       )
       (
	(and (= flag 4) (= pas "def_guia"))
	(setq pas 0)
	(cond
	  (
	   (= tipo "CORREA")
	   (cond
	     (
	      (and
		(not (= anCorrea nil))
		(not (= anPorta nil))
	      )
	      (setq miCorrea
		     (GuiTz (dtr2 anPorta) anCorrea (atof vdist_correa))
	      )
	      (cond
		(
		 (not (= miCorrea nil))
					;(brkstep '("miCorrea") "miCorrea0" "TTB")
		 (setq ttCon 0)
		 (while	(< ttCon (length miCorrea))
		   (xin2 "XD_NOVIDESA"
			 (nth ttCon miCorrea)
			 "GUIA"
			 (list (list "ELEMENTO" "GUIA")
			       (list "TABLERO" "-")
			       (list "COLOR" coltxt)
			       (list "OCULTO" "1")
			       (list "ID" "-")
			       (list "TIPO" "CORREA")
			 )
		   )
		   (setq ttCon (+ ttCon 1))
		 )
		 (setq ttCon 0)
		 (cam1 miCorrea (cons 62 (atoi coltxt)))
		 (cam1 miCorrea (cons 8 "IBSGUIA_Correa"))
		)
	      )
	     )
	   )
	  )
	  (
	   (= tipo "PORTACORREA")
	   (cond
	     (
	      (and
		(not (= anCorrea nil))
		(not (= anPorta nil))
	      )
	      (setq miPorta
		     (GuiTz (dtr2 anCorrea) anPorta (atof vdist_portacorrea))
	      )
	      (cond
		(
		 (not (= miPorta nil))
		 (setq ttCon 0)
		 (while	(< ttCon (length miPorta))
		   (xin2 "XD_NOVIDESA"
			 (nth ttCon miPorta)
			 "GUIA"
			 (list (list "ELEMENTO" "GUIA")
			       (list "TABLERO" "-")
			       (list "COLOR" coltxt)
			       (list "OCULTO" "1")
			       (list "ID" "-")
			       (list "TIPO" "PORTACORREA")
			 )
		   )
		   (setq ttCon (+ ttCon 1))
		 )
		 (setq ttCon 0)
		 (cam1 miPorta (cons 62 (atoi coltxt)))
		 (cam1 miPorta (cons 8 "IBSGUIA_Portacorrea"))
		)
	      )
	     )
	   )
	  )
	)
       )
       (
	(and (= flag 4) (= pas 1))
	(setq pp1 0
	      pas 0
	)
	(setq mipoli
	       (ssget '((0 . "LWPOLYLINE")))
	)
	(cond
	  (
	   (not (= mipoli nil))
	   (setq pp1	1
		 mipoli	(nth 0 (noment mipoli))
	   )
					;(brkstep '("mipoli") "000temp" "TTB")
	   (nuvitab mipoli "nvtablero" 1000)
					;(brkstep '("mipoli") "00tem" "TTB")
	   (setq lsustab (renom0 "nvtablero"))
	   (setq valtab1 (qcodls0 "nvtablero" 1000)
		 hdlt
			 (cdr (assoc 5 (entget mipoli)))
		 valtab0
			 (lnpo hdlt valtab1 0 1)
		 valtab0
			 (nthx '(0 1) valtab0)
	   )
					;(brkstep '("valtab0") "temp1" "TTB")
	   (admod mipoli valtab0)
	  )
	)
       )
       (
	(and (= flag 4) (= pas 2))
	(setq pas 0)
	(renom vjoval nomnv "nvtablero" 1000)
	(setq lsustab (renom0 "nvtablero"))
       )
       (
	(and (= flag 4) (= pas 3))
	(setq pas 0)
	(borrtab "nvtablero" vjoval)
	(setq lsustab (renom0 "nvtablero"))
	(liscaja "existentes" lsustab)
	(setq paction nil
	      pval nil
	)
       )
       (
	(and (= flag 4) (= pas 4))
	(setq pas 0)
	(camb
	  (list
	    (nthx '(0 1)
		  (lb217
		    (list (xrorig "nvtablero" vjoval 1000))
		  )
	    )
	  )
	  1
	)
	(ciclo "nvtablero" vjoval 1000)
	(cond
	  (
	   (= hdd "0")
	   (camb
	     (list
	       (nthx '(0 1)
		     (lb217
		       (list
			 (xrorig
			   "nvtablero"
			   vjoval
			   1000
			 )
		       )
		     )
	       )
	     )
	     2
	   )
	  )
	)
       )
       (
	(and (= flag 4) (= pas "color"))
	(setq pas 0)
	(setq pascolor 1)
	(setq colatt (clr))
	(cond
	  (
	   (not (= colatt nil))
	   (setq coltxt (itoa colatt))
	   (setq w (dimx_tile "color_image")
		 h (dimy_tile "color_image")
	   )
	   (start_image "color_image")
	   (fill_image 0 0 w h colatt)
	   (end_image)
	  )
	)
       )
       (
	(and (= flag 4) (= pas "pend1"))
	(setq pas 0
	      paspend 1
	)
	(setq valp1 (pasval2 why7 "8"))
	(action_tile
	  "8"
	  "(set_tile \"8\" valp1)"
	)
       )
       (
	(and (= flag 4) (= pas "ref"))
	(setq pasref 1)
	(setq rfpl (refhd "12"))
       )
       (
	(and
	  (= flag 4)
	  (= pas "mod")
	  (not (= nome2 nil))
	)
	(setq pas 0)
	(admod nome2 valtab0)
	(cond
	  (
	   (not (= colatt nil))
	   (cam1 (list nome2) (cons 62 colatt))
	  )
	)
	(cond
	  (
	   (= hdd "0")
	   (camb (list nome2) 2)
	  )
	  (
	   (= hdd "1")
	   (camb (list nome2) 1)
	  )
	)
       )
     )
  )
  ;;Termina accion FLAG************(1)
  (unload_dialog dcl_id)
  (princ)
)
;
;;
;;;
;;;;
;
;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;TITULO: ORDEN2. Ordena una lista de acuerdo a un elemento.
;;DESCRIPCION: ORDEN2
;;	Ordena una lista (generada por EXPAT) con base en el
;;	elemento (nth, definido en el argumento de cada lista
;;DEVUELVE:
;;	Misma lista generada por EXPAT ordenada
;;	( (No. val1 val2 val...) (...) ...)
;;ARGUMENTOS:
;;	1. LISTO: Lista de elementos para ordenar de acuerdo
;;	al primer numero de cada lista
;;	( (no. val1 val2 val...) (...) ...)
;;	2. MODOOR: Modo de orden
;;		En modo 0: Ordena las listas de manera ascendente
;;		En modo 1: Ordena las listas de manera descendente
;;	3. INPOR: Numero que indica la posicion del indice que se
;;		va a tomar como criterio para ordenar la lista.
;;ANOTACIONES:
;;
;;DEPENDIENTES:
;;	TXNO
(defun orden2 (listo modoor inpor / con1 nlid ps1 nflid)
  (setq ps1 0)
  (while
    (not (= listo nil))
    (setq con1 0
	  nlid (nth 0 listo))
    (cond
      (
       (= (length listo) 1)
       (setq listo nil)
       )
      )
    (while
      (< con1 (length listo))
      (cond
	(
	 (<= (nth inpor (nth con1 listo)) (nth inpor nlid))
	 (setq nlid (nth con1 listo))
	 )
	)
      (setq con1 (+ con1 1))
      )
    (setq listo (txno listo nlid))
    (cond
      (
       (= ps1 0)
       (setq ps1 1
	     nflid (list nlid))
       )
      (
       (= ps1 1)
       (cond
	 (
	  (= modoor 0)
	  (setq nflid (append nflid (list nlid)))
	  )
	 (
	  (= modoor 1)
	  (setq nflid (append (list nlid) nflid))
	  )
	 )
       )
      )
    )
  (setq nflid nflid)
  )
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO / TITULO:TXNO. Elimina los elementos de una lista que
;;		coincidan con el argumento
;;DESCRIPCION: LispLIST_TXNO
;;	> Apartir de una lista sencilla de datos elimina todos los elementos
;;		que sean iguales a todos los elementos definido en el argumento.
;;DEVUELVE: Misma lista sin los elementos coincidentes.
;;	> (Xx xxx ....)
;;ARGUMENTOS
;;	1.ta0. Lista sencilla de elementos
;;	>(xx xxx ...)
;;2.xx0.Elemento a eliminar
;;	>xxx
;;DEPENDIENTES
;;	>EqLs <Eq0>;
;;ANOTACIONES
;;	>La presicion de comparacion numerica es de 0.0001
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun TxNo
	(ta0 xx0 /
		ta xx taa cnn xp txVar
	)
;	(setq ta nil xx nil taa nil cnn nil xp nil txVar nil)
	(setq xp 0
		cnn 0
	)
	(setq txVar (getvar "luprec"))
	(setvar "luprec" 8)
	;;
;	(brkstep1 '("ta0" "xx0") (list ta0 xx0) "00" "TxNo")
	;;
	(cond
		(
			(and
				(equal (type ta0) 'LIST)
				(not (equal xx0 nil))
			)
			(setq ta ta0
				xx xx0
			)
			(while (< cnn (length ta))
				;;
;				(brkstep1 '("(nth cnn ta)" "xx")
;					(list (nth cnn ta) xx)
;					"01" "Txno"
;				)
				;;
				(cond
					(
						(not (EqLs (nth cnn ta) xx 0 0.0001))
						(setq taa (append taa (list (nth cnn ta))))
					)
				)
				(setq cnn (+ cnn 1))
			)
		)
	)
	(setvar "luprec" txVar)
	;;
;	(brkstep1 '("taa") (list taa) "02" "TxNo")
	;;
	(setq taa taa)
)
;
;;
;;;
;;;;

;; Objeto: ERT
;; Descripcion: Extrae de una lista estructurada  los elementos de la
;;              posicion que se pasa en una lista sencilla de números
;;              como argumento.
;; Argumentos;
;; YU: lista de estructurada
;;     ( (...) (...) (...) ...)
;; YOO : Lista de posiciones
;;      ( 1 2 x x ..)
;; Nota : Las posiciones empiezan con el 0 (trabaja con nth)
;;        El ultimo número de posicion tendrá que ser el mayor (Luego lo arreglo!!)
(defun ert (yu yoo / con pas ind lin lina)
  (cond
    (
     (< (nth (- (length yoo) 1) yoo) (length yu))
     (setq con 0
	   pas 0
     )
     (while
       (< con (length yoo))
	(setq ind (nth con yoo)
	      lin (nth ind yu)
	      con (+ con 1)
	)
	(cond
	  (
	   (= pas 0)
	   (setq lina (list lin)
		 pas  1
	   )
	  )
	  (
	   (= pas 1)
	   (setq lina (append lina (list lin)))
	  )
	)
     )
     (setq lina lina)
    )
    (
     (> (nth (- (length yoo) 1) yoo) (length yu))
     (alert "Objeto ert: La posicion maxima exede la longitud")
    )
  )
)
;;PROYECTO: Lisp
;;CLASIFICACION: (MAT) Definiciones matematicas
;;TITILO: PPND3.	Calcula la pendiente de una recta.
;;OBJETO: PPND3.  Apartir de la definicion de dos coordenadas se calcula la
;; pendiente de la recta formada, misma funcion que PPND2 pero con la
;;	definicion de numero de decimales.
;;	> Apartir de la definicion de dos puntos, calcula su pendiente
;;	con una precicion definida en el tercer argumento.
;;DEVUELVE:
;;	> PNDI. Pendiente
;;ARGUMENTOS
;;	1. PP10 (x y z) ó (x y)
;;	2. PP20 (x y z) ó (x y)
;;	3. PRZ0 Precision en numero de decimales.
;;	> Numero entero
;;DEPENDIENTES
;;	>	Ninguno
;;ANOTACIONES
;;	> Cuando la recta es vertical (x1 = x2) devuelve nil
;;	> Misma funcion que PPND2 + Precision
;; Toma los dos primero puntos de la coordenada (x y) normalmente.
(defun ppnd3
		(pp10 pp20 prz0 /
			pp1 pp2 prz pndi x1 x2 y1 y2 mpr1 przdec przdec2
		)
	;(setq pp1 nil pp2 nil prz nil pndi nil x1 nil x2 nil
	;	y1 nil y2 nil mpr1 nil przdec nil przdec2 nil
	;)
	;(brkstep '("pp10" "pp20" "prz0") "00" "PPND3")
	(cond
		(
			(and
				(equal (type pp10) 'LIST)
				(equal (type pp20) 'LIST)
				(equal (type prz0) 'INT)
			)
			(setq mpr1 (getvar "luprec"))
			(setvar "luprec" 8)
			(setq pp1 pp10
				pp2 pp20
				prz prz0
			)
			(cond
				((= prz 0) (setq przdec 1))
				((= prz 1)(setq przdec 0.1))
				((= prz 2)(setq przdec 0.01))
				((= prz 3)(setq przdec 0.001))
				((= prz 4)(setq przdec 0.0001))
				((= prz 5)(setq przdec 0.00001))
				((= prz 6)(setq przdec 0.000001))
				((= prz 7)(setq przdec 0.0000002))
				((= prz 8)(setq przdec 0.00000002))
			)
			(cond
				((< przdec 0.1) (setq przdec2 (* przdec 10)))
				((<= 0.1 przdec) (setq przdec2 przdec))
			)
			(cond
				(
					(not (equal (nth 0 pp1) (nth 0 pp2) przdec2))
					;(brkstep
					;	'("pp1"
					;		"pp2"
					;		"(- (nth 1 pp2) (nth 1 pp1))"
					;		"(- (nth 0 pp2) (nth 0 pp1))"
					;		"(/ (- (nth 1 pp2) (nth 1 pp1)) (- (nth 0 pp2) (nth 0 pp1)))"
					;	)
					;	"01" "PPND3"
					;)
					(setq x1 (nth 0 pp1)
						x2 (nth 0 pp2)
						y1 (nth 1 pp1)
						y2 (nth 1 pp2)
					)
					;(brkstep '("x1" "x2" "y1" "y2") "02" "PPND3")
					(setq pndi
						(/
							(- y2 y1)
							(- x2 x1)
						)
					)
					(setq pndi (round1 pndi prz))
				)
			)
			(if
				(equal  pndi 0.0 przdec2)
				(setq pndi 0)
				(setq pndi pndi)
			)
			;(brkstep '("pndi") "03" "PPND3")
		)
	)
	(setvar "luprec" mpr1)
	(setq pndi pndi)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;TITULO: ROUND1. Redondea un numero decimal
;;DESCRIPCION: ROUND1. Redondea un numero a el numero de decimales
;;	definido en el argumento
;;DEVUELVE: roNumFn. Numero redondeado
;;	>Numero real
;;ARGUMENTOS
;;	1. roNum0. Numero a redondear
;;	> Numero real
;;	2. roPrec0. Precisión de redondeo (numero de decimales)
;; > Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
(defun round1
	(roNum0 roPrec0 /
		roNumTx roNumFn roNum roPrec
	)
	;(setq roNum nil roPrec nil roNumTx nil roNumFn nil)
	;(brkstep1
		;'(
		;	"roNum0"
		;	"roPrec0"
		;	"(and
		;		(= (numberp roNum0) T)
		;		(= (type roPrec0) 'INT)
		;	)"
		;)
		;"00" "ROUND1"
	;)
	(cond
		(
			(and
				(= (numberp roNum0) T)
				(= (type roPrec0) 'INT)
			)
			(setq roNum roNum0
				roPrec roPrec0
			)
			(setq roNumTx (rtos roNum 2 roPrec))
			;(brkstep
			;	'(
			;		"roNumTx"
			;		"(and (= (substr roNumTx 1 1) \"-\") (= (substr roNumTx 2 1) \".\"))"
			;		"(= (substr roNumTx 1 1) \".\")"
			;		"(and (= (substr roNumTx 1 1) \"-\") (= (strlen roNumTx) 1))"
			;	)
			;	"01" "ROUND1"
			;)
			(cond
				(
					(and
						(= (substr roNumTx 1 1) "-")
						(= (substr roNumTx 2 1) ".")
					)
					(setq roNumTx
						(strcat (substr roNumTx 1 1)
							"0"
							(substr roNumTx 2 (strlen roNumTx))
						)
					)
				)
				(
					(= (substr roNumTx 1 1) ".")
					(setq roNumTx (strcat "0" roNumTx))
				)
				(
					(and
						(= (substr roNumTx 1 1) "-")
						(= (strlen roNumTx)  1)
					)
					(setq roNumTx "0")
					;(brkstep '("roNumTx") "01A" "ROUND1")
				)
			)
			;(brkstep '("roNumTx") "02" "ROUND1")
			(setq roNumFn (read roNumTx))
		)
	)
	;(brkstep '("roNumFn") "03" "ROUND1")
	(setq roNumFn roNumFn)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;TITULO: LVA0. Crea una lista de valores variantes.
;; Objeto: LVA0 Extrae los valores (variantes) de una lista estructurada
;; dependiendo de la posicion indicada <(x x x x x x x x)>:
;;Argumentos:
;;	1. IL0: lista estructurada
;;	2. PPS0: posicion de elemento a extraer (la posicion empieza
;;		en 1)
;;	3. DDN0: Modo:
;;		En modo 0 extrae las variantes evaluando todo el elemento:
;;		( (ab) (sd) (sd) (ab) (JJ) )
;;		En modo 0 = ( (ab) (sd) (JJ) )
;;		En modo 1  y posicion 0 = (a s j)
;;		Es decir devuelve todas las variantes de los elementos
;;		encontrados en la pocision 0
;;	4. PP20. Precision. Numero de decimales
;;		NN. numero entero.
;;	ANOTACIONES
;;		El modo 0 ignora la posicion; sin embargo ahi que escribirla con ()
;;		Nota solo para listas con el mismo numero de subelementos en cada elemento.
(defun
	lva0
	(il0 pps0 ddn0 pp20 /
		il pps ddn pp2
		tke ppos conn mil mmil npos
	)
;	(setq il nil pps nil ddn nil pp2 nil
;		tke nil ppos nil conn nil mil nil mmil nil npos nil
;	)
	;;
;	(brkstep1
;		'("il0" "pps0" "ddn0" "pp20")
;		(list il0 pps0 ddn0 pp20)
;		"00" "LVA0"
;	)
	;;
	(cond
		(
			(and (= (type il0) 'LIST)
				(= (type ddn0) 'INT)
				(= (type pp20) 'INT)
			)
			(setq il il0 pps pps0 ddn ddn0 pp2 pp20)
			(setq mil il
				tke 1
			)
			(cond
				(
					(and (= ddn 1) (<= pps (length (nth 0 il))))
					(setq mil (lss mil pps))
;					(brkstep1 '("mil") (list mil) "01" "LVA0")
				)
				(
					(and (= ddn 1) (> pps (length (nth 0 il))))
					(setq tke 0)
					(alert
						"LVA: LA POSICION ES MAYOR QUE EL NUMERO DE ELEMENTOS"
					)
				)
			)
			(setq	conn 0 ppos 0 npos 0)
			(setq	mmil (list (nth conn mil))
				conn (+ conn 1)
			)
;			(brkstep1
;				'("mmil" "conn""mil" )
;				(list mmil conn mil)
;				"02" "LVA0"
;			)
			(while (< conn (length mil))
;				(brkstep1
;				 '( "mil" "(length mil)" "conn" "mmil"
;						"(nth conn mil)"
;						"(bc1 mmil pp2 (nth conn mil))"
;					)
;					(list mil (length mil) conn mmil
;						(nth conn mil) (bc1 mmil pp2 (nth conn mil))
;					)
;					"03" "LVA0"
;				)
				(cond
					(
						(= (bc1 mmil (nth conn mil) pp2) nil)
						(setq mmil (append mmil (list (nth conn mil))))
					)
				)
;				(brkstep1 '("mmil") (list mmil) "04" "LVA0")
				(setq conn (+ conn 1))
			)
		)
	)
;	(brkstep1 '("mmil") (list mmil) "05" "LVA0")
	(setq mmil mmil)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: LNPO4
;;	Extrae o elmimina las listas que
;;	correspondan al elemento indice y
;;	posicion definidos en los argumentos con la precision definida en el
;;	utlimo argumento.
;;DEVUELVE:
;;	En modo 0:
;;	( (XX XX XX ...) (...) ...)
;;	Todos los elementos de la lista inicial, menos
;;	los que correspondan a los valores de los argumentos
;;	En modo 1:
;;	( (xx EleInd xx ...) (xx EleInd xx xx ...) (...) ...)
;;	Todos los elemenento de la lista inicial que correspondan
;;	a los valores de los argumentos
;;ARGUMENTOS:
;;	1. ELDI: Elemento indice: XXX
;;	Elemento que se va a buscar para la extraccion de la lista
;;	2. TRB: Lista de trabajo: ( (xx xx ...) (...)...)
;;	Lista donde se van a extraer los elementos
;;	3. PPOS: Posicion: Numero entero (NTH)
;;	(NTH) que debe de ocupar el elemento para extraerse o
;;	quitar de la lista
;;	4. MD: Modo de resultado:
;;	5. PRES: Presicion de comparacion (numero decimal)
;;DEPENDIENTES: Ninguno
(defun lnpo4
	(eldi trb pos md pres /
		ccn pps lmdin lmd lmf lprec
	)
	;(setq ccn nil pps nil lmdin nil lmd nil lmf nil lprec nil)
	;(brkstep '("eldi" "trb" "pos" "md" "pres" "(length trb)") "00" "lnpo4")
	;(alert (rtos eldi))
	;(xdat2 trb "," 8)
	(setq lprec (getvar "luprec"))
	(setvar "luprec" 8)
	(setq ccn 0)
	(while
		(< ccn (length trb))
		(setq lmd (nth ccn trb))
		;(brkstep
		;	'("pos" "eldi" "lmd" "pres" "(equal (nth pos lmd) eldi pres)")
		;	"01" "lnpo4"
		;)
		(cond
			(
				(or
					(and
						(EqLs (nth pos lmd) eldi  0 pres)
						(= md 1)
					)
					(and
						(not (EqLs (nth pos lmd) eldi 0 pres))
						(= md 0)
					)
				)
				(setq lmdin (append lmdin (list lmd)))
			)
		)
		(setq ccn (+ ccn 1))
		;(brkstep '("lmdin" "CCN") "03" "LNPO4")
	)
	(setvar "luprec" lprec)
	(setq lmdin lmdin)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO: ORDI
;;	> Calculo de ordenada al origen apartir de la definicion de
;;	un punto y pendiente.
;;DEVUELVE:
;;	> Valor de Y cuando X = 0 (ordenada al origen)
;;ARGUMENTOS
;;	1. PTO: Coordentada (punto de la recta)
;;	> (X Y) ó (X Y Z)
;;	2. MP: Pendiente
;;	> Número real
;;DEPENDIENTES
;;	> Ninguno
;;ANOTACIONES
;;	>
(defun ordi (pto mp / orig1 getor)
  (setq getor (getvar "luprec"))
  (setvar "luprec" 8)
  (setq orig1 (- (nth 1 pto) (* mp (nth 0 pto))))
					;(brkstep '("pto" "orig1") "01" "ORDI")
  (setq orig1 (round1 orig1 8))
  (setvar "luprec" getor)
  (setq orig1 orig1)
)
;
;;
;;;;
;;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: LSS
;;TITULO: LSS. Extrae el elemento numero X de cada una de las listas
;;DESCRIPCION: Apartir de la definicion de una lista de listas
;;	y un numero (NTH +1) de posicion, extrae todos los elementos
;;	que se encuentren en la posicion de cada una de las listas
;;	internas.
;;ARGUMENTO:
;;	1. LIS: Lista tipo ((xxx xx) (xx xx) (...) ...)
;;	2. CON: Número de extracción, (número entero, comenzando por el 1)
;;ANOTACIONES:
;; 1. Verifica la longitud del primer elemento para validar la ejecución
;; 2. Apartir de la segunda lista, si no encuentra el elemento No. (CON)
;;	devuelve nil en cada elemento no encontrado
;; 3. La posicion del argumento empieza desde el 1
;;OBJETOS DEPENDIENTES:
;;	0
(defun lss (lis con / ls lt ltf pas pas1 lian lydum pas2 conta)
	(setq pas2 0)
	(cond
		(
			(= lis nil)
			(alert "LSS:\nEL VALOR DE LA LISTA NO EXISTE")
		)
		(
			(<= con 0)
			(alert "LSS:\nEL INDICE DEBE SER MAYOR A 0")
		)
		(
			(< (length (nth 0 lis)) con)
			(alert "LSS:\nEL CONTADOR ESTA FUERA DE RANGO")
		)
		(
			(and (< 0 con) (<= con (length (nth 0 lis))))
			(setq pas2 1)
		)
	)
	(cond
		(
			(= pas2 1)
			(setq pas 0
				conta 0
			)
			(while
				(< conta (length lis))
				(setq lt (nth (- con 1) (nth conta lis)))
				(cond
					(
						(= pas 0)
						(setq	ltf (list lt)
							pas 1
						)
					)
					(
						(= pas 1)
						(setq ltf (append ltf (list lt)))
					)
				)
				(setq conta (+ conta 1))
			)
		)
	)
	(setq ltf ltf)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: BC1
;;	> Busca si una coordenada se encuentra en una lista de coordenadas
;; igual que BC + precision
;;DEVUELVE:
;;	> Devuelve el numero de repeticiones o nil si el punto no se
;;	encuentra en la lista de coordenadas.
;;ARGUMENTOS
;;	1.LBC: Lista de coordenadas
;;	> ( (x y) (...) ...)
;;	2.CBC: Coordenada
;;	> (x y)
;;	3. PP1: Numero de decimales de precision
;;DEPENDIENTES
;;	> EqLs <LsType;Eq0>; 
;;ANOTACIONES
;;	>
(defun bc1
	(lbc0 cbc0 pp10 /
		lbc cbc pp1
		ccon rs nmr
	)
;	(setq lbc nil cbc nil pp1 nil
;		ccon nil rs nil nmr nil
;	)
	;;
;	(brkstep1
;		'("lbc0" "cbc0" "pp10")
;		(list lbc0 cbc0 pp10)
;		"00" "BC1"
;	)
	;;
	(cond 
		(
			(and
				(= (type lbc0) 'LIST)
				(not (= cbc0 nil))
				(= (type pp10) 'INT)
			)
			(setq lbc lbc0
				cbc cbc0
				pp1 pp10
			)
			;;
;			(brkstep1 '("lbc" "cbc" "pp1") (list lbc cbc pp1) "01" "BC1")
			;;
			(cond
				(
					(=  pp1 nil)
					(setq nmr 0.00015)
				)
				(
					(< 0 pp1)
					(setq nmr
						(expt 10.0 (* -1 pp1))
					)
				)
				(
					(= pp1 0)
					(setq nmr 0.15)
				)
			)
			;;
;			(brkstep1 '("pp1" "nmr") (list pp1 nmr) "02" "BC1")
			;;
			(setq ccon 0
				rs 0
			)
			(while (< ccon (length lbc))
				;;
;				(brkstep1
;					'("(nth ccon lbc)" "cbc" "(EqLs (nth ccon lbc) cbc 0 nmr)")
;					(list (nth ccon lbc) cbc (EqLs (nth ccon lbc) cbc 0 nmr))
;					"03" "BC1"
;				)
				;;
				(cond
					(
						(EqLs (nth ccon lbc) cbc 0 nmr)
						(setq rs (+ rs 1))
					)
				)
				(setq ccon (+ ccon 1))
			)
			;;
;			(brkstep1 '("rs") (list rs) "04" "BC1")
			;;
			(cond
				(
					(= rs 0)
					(setq rs nil)
				)
			)
			(setq rs rs)
		)
	)
)
;
;;
;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIN
;;OBJETO: MAT30
;;	> Define una lista de todas las lineas con todas las intersecciones posibles,
;; segun el modo de agregado de conexiones,agrega valor de conexion para cada coordenada.
;; (funciona con dos listas de linas de diferentes pendientes)
;;DEVUELVE: Lista de lineas con intersecciones incluidas
;;	>[(Pendiente Ordenada (#Conect XYIni) (#Conet XYInt) (...)...(#Conect XYFin)) ... (...)]
;;ARGUMENTOS
;;	1.LPEN: Lista de coordenadas agrupadas por pendientes extraidas con MAT1 con el formato:
;;	> [ ( ( Pendiente1 Oredada ID (XYinicial) (XYFinal) ) (...))
;;		( ( Pendiente2 Oredada ID (XYinicial) (XYFinal) ) (...))...]
;; 2.MIMO: Modo de valor de conexiones:
;;	>	0: Valor de conexiones en 0
;;	>	1: Valor de conexiones reales
;;DEPENDIENTES
;;	> MAT2 <>; CORDEN <>; NTHX <>; ORG <>; ORDEN4 <>;
;;ANOTACIONES
;;	>
(defun mat30
	(lpen mimo /
		con2 con1 pmas pmenos pimenos pimas coo tip
		pg pg1 pgf coo1 tx1 msj1 mimos primas primenos matprec
	 )
	;(setq con2 nil con1 nil pmas nil pmenos nil pimas nil pimenos nil
	;	primas nil primenos nil coo nil tip nil pg nil pg1 nil pgf nil coo1 nil
	;	tx1 nil msj1 nil mimos nil matprec nil
	;)
	;(brkstep
	;	'("lpen" "(length (nth 0 lpen))" "(length (nth 1 lpen))" "mimo")
	;	"00" "MAT3"
	;)
	(setq mimos (getvar "osmode"))
	(setvar "osmode" 0)
	(cond
		(
			(and 
				(not (= lpen nil))
				(= (type lpen) 'LIST)
				(= (length lpen) 2)
			)
			(setq matprec (getvar "luprec" ))
			(setvar "luprec" 8)
			(setq lpen
				(list
					(corden (nth 0 lpen) 0 4)
					(corden (nth 1 lpen) 0 4)
				)
			)
			;(brkstep '("(length (nth 0 lpen))" "(length (nth 1 lpen))")
			;	"00a" "PANEW"
			;)
			(cond
				(
					(not (equal (nthx '(0 0) (nth 1 lpen)) "nop"))
					(cond
						(
							(or
								(< 0 (nthx '(0 0) (nth 1 lpen)))
								(equal (nthx '(0 0) (nth 1 lpen)) 0 0.0001)
							)
							(setq lpen
								(list (nth 1 lpen)
									(nth 0 lpen)
								)
							)
						)
					)
				)
			)
			;(brkstep '("(nth 0 (nth 0 (nth 0 lpen)))") "01" "MAT3")
			(cond
				(
					(= (numberp (nth 0 (nth 0 (nth 0 lpen)))) nil)
					(setq pmenos (nth 0 lpen)
						pmas (nth 1 lpen)
					)
				)
				(
					(= (numberp (nth 0 (nth 0 (nth 0 lpen)))) t)
					(cond
						(
							(< (nth 0 (nth 0 (nth 0 lpen))) 0)
							(setq pmenos (nth 0 lpen)
								pmas (nth 1 lpen)
							)
						)
						(
							(<= 0 (nth 0 (nth 0 (nth 0 lpen))))
							(setq pmas (nth 0 lpen)
								pmenos (nth 1 lpen)
							)
						)
					)
				)
			)
			;(brkstep '("pmenos" "pmas") "1" "MAT3: lista de pendientes")
			(setq pimenos (mat2 pmenos pmas '(3 4) 4))
			(setq pimas (mat2 pmas pmenos '(3 4) 4))
			;(brkstep
			;	'("pimas" "(length pimas)"
			;		"pimenos" "(length pimenos)"
			;	)
			;	"XX" "MAT3"
			;)
			(setq pimenos (corden pimenos 0 4))
			;(cam1 (noment psmenos)'(0 . "psmenos"))
			(setq pimas (corden pimas 0 4))
			;(cam1 (noment psmas) '(0 . "psmas"))
			;(brkstep '("pimas" "pimenos") "XXX" "MAT3")
			(setq primas pimas primenos pimenos)
			(setq pg pimas)
			(cond
				(
					(= mimo 1)
					(setq tip
						(list 1 3 2)
					)
				)
				(
					(= mimo 0)
					(setq tip
						(list 0 0 0)
					)
				)
			)
			;(brkstep 
			;	'("pg" "(length pg)"
			;		"pimas" "(length pimas)"
			;		"pimenos" "(length pimenos)"
			;		"tip"
			;	)
			;	"2" "MAT3"
			;)
			(repeat
				2
				;(brkstep '("pg" "pimas" "pimenos" "tip") "2a" "MAT3")
				(setq con1 0)
				(while
					(< con1 (length pg))
					(setq pg1 (nth con1 pg)
						coo (org pg1 (list 3 (- (length pg1) 3)) 0)
					)
					;(brkstep '("pg1" "coo" "con1") "2a1" "MAT3")
					(setq coo (nth 1 coo))
					;(brkstep '("(nth 0 pg1)" "coo" "pg1" "con1") "2b" "MAT3")
					(cond
						(
							(= (nth 0 pg1) "nop")
							(setq coo (orden4 coo 0 1 5))
						)
						(
							(= (numberp (nth 0 pg1)) t)
							(cond;;;;;;;;;;;;;;;;;;;reparacion de orden
								(
									(<= 0 (nth 0 pg1))
									(setq coo (orden4 coo 0 0 5))
								)
								(
									(< (nth 0 pg1) 0)
									(setq coo (orden4 coo 1 0 5))
								)
							)
						)
					)
					(setq coo (lva0 coo () 0 5))
					;(brkstep '("coo") "3C" "MAT3")
					(setq con2 1
						coo1 nil
					)
					(setq coo1
						(append coo1
							(list
								(append
									(list (nth 0 tip))
									(nth 0 coo)
								)
							)
						)
					)
					;(brkstep '("coo1" "pg1" "coo" "con2") "3" "MAT3")
					(while
						(< con2 (- (length coo) 1))
						(setq coo1
							(append coo1
								(list
									(append
										(list (nth 1 tip))
										(nth con2 coo)
									)
								)
							)
						)
						(setq con2 (+ con2 1))
						;(brkstep '("coo1" "con2") "4" "MAT3")
					)
					(setq coo1
						(append coo1
							(list
								(append
									(list (nth 2 tip))
									(nth con2 coo)
								)
							)
						)
					)
					(setq pg1
						(append
							(ert pg1 '(0 1 2))
							coo1
						)
					)
					(setq pgf
						(append pgf
							(list pg1)
						)
					)
					;(brkstep '("pg" "coo1" "pgf" "con1") "5" "MAT3")
					(setq con1 (+ con1 1))
				)
				(setq pg pimenos)
				(setq tx1 "Grupo 2")
				;(brkstep '("mimo") "5A" "MAT3")
				(cond
					(
						(= mimo 1)
						(setq tip (list 4 12 8))
					)
					(
						(= mimo 0)
						(setq tip (list 0 0 0))
					)
				)
				;(brkstep '("pg" "pgf" "tip") "6" "MAT3")
			)
		)
	)
	;(brkstep '("pgf") "7" "MAT3")
	(setvar "osmode" mimos)
	(setvar "luprec" matprec)
	(setq pgf pgf)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIN
;;OBJETO: MAT2
;;	> Apartir de dos listas de coordenadas, encuentra las intersecciones
;;	que existan en la primera lista tomando en cuenta la segunda.
;;DEVUELVE: La misma primera lista con la lista de intersecciones insertadas
;;		en cada elemento.
;;	> ( (? ? (XY) ((XYint1) (XYint2) (...)) (XY) ???) (...) ...)
;;ARGUMENTOS
;;	1.GPO10: Grupo de coordenadas donde se van a agregar
;;	las intersecciones
;;	> [(? ? (X1Y1) ?...(X2Y2)...) (...) ...]
;;	2.GPO20: Grupo de coordenadas que se van a tomar para
;;	las intersecciones
;;	3.POSI0: Lista de posicion donde se encuentran las coordenadas
;;	> [(PosCoordenada1 PosCoordenada2) ...]
;;	4.POSINS0: Posicion de inserscion de lista de intersecciones
;;	> Numero entero
;;DEPENDIENTES
;;	> CAM1 ()
;;ANOTACIONES
;;	>
(defun mat2
	(gpo10 gpo20 posi0 posins0 /
		gpo1 gpo2 posi posins
		con1 con2 lgpo1 cgpo1 lgpo2 cgpo2
		lgint lfint0 lfin mienti1 micolor1
		mienti2 micolor2 sseli vlgint lgpo1a lgPos
	)
;	(setq gpo1 nil gpo2 nil posi nil posins nil
;		con1 nil con2 nil lgpo1 nil cgpo1 nil
;		lgpo2 nil cgpo2 nil lgint nil lfint0 nil
;		lfin nil mienti1 nil micolor1 nil mienti2 nil
;		micolor2 nil sseli nil
;		vlgint nil lgpo1a nil lgPos nil
;	)
	;;
;	(brkstep1
;		'("gpo10" "gpo20" "posi0" "posins0")
;		(list gpo10 gpo20 posi0 posins0)
;		"00" "MAT2"
;	)
	;;
	(cond
		(
			(and (= (type gpo10) 'LIST)
				(= (type gpo20) 'LIST)
				(= (type posi0) 'LIST)
				(= (type posins0) 'INT)
			)
			(setq gpo1 gpo10
				gpo2 gpo20
				posi posi0
				posins posins0
			)
			(setq con1 0)
			;;
;			(brkstep1
;				'("gpo1" "gpo2" "posi" "posins")
;				(list gpo1 gpo2 posi posins)
;				"01" "MAT2"
;			)
			;;
			(while 
				(< con1 (length gpo1))
				(setq lgpo1 (nth con1 gpo1))
				;;
;				(brkstep1 '("lgpo1") (list lgpo1)  "02" "MAT2")
				;;lgpo1. Elemento de lista 1 <(poi (xy) (xy))>
				(setq
					cgpo1
					(append
						(list (nth (nth 0 posi) lgpo1))
						(list (nth (nth 1 posi) lgpo1))
					)
				)
				(setq lfint0 nil)
				;;;;;cambio de color;;;;
				(setq mienti1 (handent (nth 2 lgpo1)))
				;;
;				(brkstep1 '("mienti1") (list mienti1) "03" "MAT2")
				;;
				(setq micolor1 (assoc 62 (entget mienti1)))
				(cond
					(
						(= micolor1 nil)
						(setq micolor1 '(62 . 256))
					)
				)
				(cam1 (list mienti1) '(62 . 2))
				(command "zoom" "o" mienti1 "")
				;;;;;;;;;;;;;;;;;;;;;;
;				(brkstep1
;					'("micolor1" "lgpo1" "cgpo1")
;					(list miconor1 lgpo1 cgpo1)
;					"04" "MAT2"
;				)
				;;cgpo1. coordenadas de lgpo1 (elemento). <((xy)(xy)>
				(setq con2 0)
				(setq sseli (ssadd));;;Seleccion
				(while
					(< con2 (length gpo2))
					(setq lgpo2 (nth con2 gpo2))
					(setq cgpo2
						(append
							(list (nth (nth 0 posi) lgpo2))
							(list (nth (nth 1 posi) lgpo2))
						)
					)
					;;;;;cambio de color;;;;
					(setq mienti2 (handent (nth 2 lgpo2))
						micolor2 (assoc 62 (entget mienti2))
					)
					(cond
						(
							(= micolor2 nil)
							(setq micolor2 '(62 . 256))
						)
					)
					(cam1 (list mienti2) '(62 . 1))
					(command "zoom" "o" mienti1  mienti2 "")
					;;;;;;;;;;;;;;;;;;;;;;
;					(brkstep1
;						'("micolor2" "lgpo2" "cgpo2" "cgpo1" "Interseccion")
;						(list micolor2 lgpo2 cgpo2 cgpo1
;							(inters
;								(nth 0 cgpo1) (nth 1 cgpo1)
;								(nth 0 cgpo2) (nth 1 cgpo2)
;								T
;							)
;						)
;						"05" "MAT2"
;					)
					;;
					(setq vlgint nil)
					;;lgpo2. Elemento del segundo grupo <(poi (xy) (xy))>
					;cgpo2. Coordenadas del elemento lgpo2 <((xy) (xy)>
					;micolor2. Color de elemento (lgpo2)
					;vlgint. Verificador de interseccion = nil
					(setq lgint
						(inters
							(nth 0 cgpo1) (nth 1 cgpo1)
							(nth 0 cgpo2) (nth 1 cgpo2)
							T
						)
					)
					;;
;					(brkstep1 '("lgint" "con2") (list lgint con2) "06" "MAT2")
					;;lgint. Interseccion entre lgpo1 lgpo2
					;;;;VERIFICACION DE INTERSECCION
					(cond
						(
							(= lgint nil)
							(setq vlgint
								(bc1
									(append cgpo1 cgpo2)
									(inter
										(nth 0 cgpo1) (nth 1 cgpo1)
										(nth 0 cgpo2) (nth 1 cgpo2)
										7
									)
									3
								)
							)
							(cond
								(
									(not (= vlgint nil))
									(setq vlgint
										(corin cgpo1
											(inter
												(nth 0 cgpo1) (nth 1 cgpo1)
												(nth 0 cgpo2) (nth 1 cgpo2)
												7
											)
											3
										)
									)
									(if (= vlgint 0)
										(setq vlgint nil)
										(setq vlgint 1)
									)
								)
							)
						)
					)
					;;
;					(brkstep1 '("vlgint") (list vlgint) "07" "MAT2")
					;;
					(cond
						(
							(not (= vlgint nil))
							(setq lgint
								(inter
									(nth 0 cgpo1) (nth 1 cgpo1)
									(nth 0 cgpo2) (nth 1 cgpo2)
									7
								)
							)
						)
					)
					;;
;					(brkstep1 '("lgint") (list lgint) "08" "MAT2")
					;;
					(cond
						(
							(not (= lgint nil))
							;;;;;;;;;;;;;;;;;;Indica coordenada de insersión
							(command "donut" 0.0 0.001 lgint "")
							(ssadd (entlast) sseli)
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							(setq 
								lfint0
								(append lfint0
									(list lgint)
								)
							)
						)
					)
					(setq con2 (+ con2 1))
					;;
;					(brkstep1
;						'("lfint0" "micolor2")
;						(list lfint0 micolor2)
;						"09" "MAT2"
;					)
					;;lfint0. Lista de intersecciones de lgpo1 con todas las
					;	lineas del segundo grupo <(xy)...)>
					;;;;;;;;;;Regresa el color de linea de inteseccion;;;;;;;
					(cam1 (list mienti2) micolor2)
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				); Lista de intersecciones por elemento (con1)
				;; ( (xy) (xy) (xt) )
				;;*********Agregar orden de intersecciones**********
;				(brkstep1 '("lfint0" "lgpo1") (list lfint0 lgpo1)
;					"10" "MAT2"
;				)
				;;
				(command "erase" sseli "")
				(cond
					(
						(not (= lfint0 nil))
						(setq lgpo1
							(isl3 ;;;;Cambio
								lfint0
								lgpo1
								posins
							)
						)
					)
				)
				;;
;				(brkstep1 '("lgpo1") (list lgpo1) "11" "MAT2")
				;;lgpo1. Lista de elmenton con intersecciones integradas
				;;**orden de lgpo1 en sus coordenadas y elimina duplicados
				(setq lgpo1a (cut 3 (- (length lgpo1) 1) lgpo1)
					lgpo1a (lva0 lgpo1a 1 0 3)
				)
				;;
;				(brkstep1
;					'("lgpo1a" "lgpo1" "(length lgpo1a)" "(nth 0 lgpo1)")
;					(list lgpo1a lgpo1 (length lgpo1a) (nth 0 lgpo1))
;					"12" "MAT2"
;				)
				;;lgpo1a. Lista de coordenadas de lgpo1a sin repetidas
				(cond
					((= (nth 0 lgpo1) "nop") (setq lgPos 1))
					((EqLs (nth 0 lgpo1) 0.000 0 0.000001) (setq lgPos 0))
					((< (nth 0 lgpo1) 0) (setq lgPos 0))
					((> (nth 0 lgpo1) 0) (setq lgPos 0))
				)
				;;
;				(brkstep1 '("lgpo1a" "lgPos") (list lgpo1a lgPos) "12A" "MAT2")
				(setq lgpo1a (orden4 lgpo1a 0 lgPos 7))
				;;
;				(brkstep1 '("lgpo1a") (list lgpo1a) "13" "MAT2")
				;;lgpo1a. Lista de coordenadas ordenadas de menor a mayor
				;	<((xy)...)>
				(setq lgpo1 (append (cut 0 2 lgpo1) lgpo1a))
				;;
;				(brkstep1 '("lgpo1") (list lgpo1) "14" "MAT2")
				;;lgpo1. Lista de elemento <(poi (xy) (xtInt)...(xy))>
				(setq lfin
					(append
						lfin
						(list lgpo1)
					)
				)
				(setq con1 (+ con1 1))
				;;;ordena lista en sus coordenadas
				;;;;;;;;;;; Regresa el color de linea principal ;;;;
				(cam1 (list mienti1) micolor1)
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				(brkstep1 
;					'("lfin" "con1" "lgpo1")
;					(list lfin con1 lgpo1)
;					"15" "MAT2"
;				)
				;;lfin. Lista final <( (poi(xyini)(xyint)...(xyfin)) (...) ... )>
			)
			(setq lfin lfin)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: LISP
;;CLASIFICACION: LIST
;;OBJETO:NTHX Extrae un elemento de una lista
;;		compuesta de varias listas donde se requiere una repeticion
;;		del comando nth.
;;DEVUELVE: Elemento extraido la  posición (definida por la lista de contadores)
;;		definida en el argumento.
;;ARGUMENTOS
;;	1. LSCON: Lista de contadores (posición NTH) de extracción
;;		(#  #  #  #)
;;	2. MINI: Lista de trabajo de donde se extrae el elemento
;;		( (xx (xx (xx) x) xxx) (xx xx xx))
;;ANOTACIONES
;;		La extraccion de los elementos se hace por medio de una lista de posiciones,
;;		empezando de lo general a lo particular
;;		( (1 2 ) (3 (4 (5))) ) .- Lista para extraer 5 = (1 1 0)
(defun nthx
	(lscon mini /
		con1 mini1
		)
					;(brkstep '("lscon" "mini") "00" "nthx")
  (setq	con1  0
	mini1 mini
  )
  (while (and (< con1 (length lscon))
	      (not (= mini1 nil))
	 )
    (setq mini1 (nth (nth con1 lscon) mini1))
    (setq con1 (+ con1 1))
  )
  (setq mini1 mini1)
)
;
;;
;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;TITULO: ORG. Agrupa datos de una lista en una lista compuesta.
;;DESCRIPCION:ORG.- AGRUPA DATOS DE UNA LISTA SIMPLE DE ELEMENTOS EN UNA LISTA ESTURUCTURADA
;;; SIGUIENDO EL PATRON PASADO COMO ARGRUMENTO:
;;; DONDE
;;; EN MODO (MM) 1 EL PRIMER ARGUMENTO CORRESPONDE AL VALOR INDICE, EL SEGUNDO VALOR CORRESPONDE AL NUMERO
;;; EN MODO (MM) 0 SOLAMENTE ES UNA LISTA DE NUMEROS DE ARGUPACION
;;; DE ELEMENTOS CONSECUTIVO QUE SE INCLUYEN EN CADA GRUPO
;;; ARGUMENTOS
;;; LOOG = LISTA ORIGINAL PARA AGRUPAR; ESTRUCTURA=
;;; (valor1 valor2 valor3 valor4 valor5)
;;; LGP LISTA DE AGRUPACION DE PROTOTIPO
;;; ESTRUCTURA LGP en modo 1 (MM)=( (indice-valor1 numero-elementos1) (indice-valor2 numero-elementos2) (...) )
;;; ESRTUCTURA LGP en modo 0 (MM)=( numero-agrupcion1 numero-agrupacion2 numero-agrupcaion3 )
;;; DEVUELVE 
;;; [(indice-valor valor1 valor2) (indice-valor valor3 valor4 ...) (indice-valor valor consecutivo ...)]
;;;
;;DEPENDIENTES:
;;LSS <>; 
(defun org (loog lgp mm / nug cnt psso vg nlg lnn nlgf lim)
  (setq nlgf nil)
  (cond
    (
     (= mm 1)
     (setq lnn (lss lgp 2))
     )
    (
     (= mm 0)
     (setq lnn lgp)
     )
    )
  (setq vf (=
	     (apply '+ lnn)
	     (length loog)
	     )
	)
  (cond
    (
     (= vf t)
     (setq nlg lgp
	   nug 0
	   cnt 0
	   lim 0
	   )
     (while (< cnt (length nlg))
       (setq psso 0)
       (cond
	 (
	  (= mm 1)
	  (setq
	     vg (nth cnt nlg)
	     lim (+ lim (nth 1 vg))
	     )
	  )
	 (
	  (= mm 0)
	  (setq
	    vg (list (nth cnt nlg))
	    lim (+ lim (nth cnt nlg))
	    )
	  )
	 )
       (while
	 (< nug lim)
	 (cond
	   (
	    (= psso 0)
	    (cond
	      (
	       (= mm 1)
	       (setq ng (list (nth 0 vg)
			   (nth nug loog))
		     )
	       )
	      (
	       (= mm 0)
	       (setq ng (list (nth nug loog))
		     )
	       )
	      )
	    (setq psso 1)
	    )
	   (
	    (= psso 1)
	    (setq ng (append ng (list (nth nug loog)))
		  )
	    )
	   )
	 (setq nug (+ nug 1))
	 )
       (cond
	 (
	  (= mm 1)
	  (setq nlg (subst ng vg nlg)
		nlgf nlg)
	  )
	 (
	  (= mm 0)
	  (setq nlgf (append nlgf (list ng)))
	  )
	 )
       (setq
	 cnt (+ cnt 1))
       )
     )
    (
     (= vf nil)
     (alert "ORG:NO COINCIDEN LAS LISTAS DE GRUPACION")
     )
    )
  (setq nlgf nlgf)
  )
;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: ORDEN4
;; > Ordena una lista estructurada de acuerdo a la posicion indicada
;;	en argumento y en orden (ascendente o descendente) definido y con
;;	precision de comparacion numerica definido por el numero de decimales.
;;DEVUELVE:
;;	Misma lista estructurada y ordenada de acuerdo a la posicion y modo
;;	> ( (N N ..) (...) ...)
;;ARGUMENTOS:
;;	1. LiT1: Lista estructurada de numeros
;;	( (N N ..) (...) ...)
;;	2. MMOD: Modo de orden
;;		En modo 0: Ordena las listas de manera ascendente
;;		En modo 1: Ordena las listas de manera descendente
;; 3. MPOS: Posicion NTH del elemento de referencia para ordenar
;;	>Numero entero
;;	4. PP3:	Precision de comparacion numerica (numero de decimales)
;;	>Numero entero
;;ANOTACIONES:
;;
;;DEPENDIENTES:
;; LSS; LVA; ORDVAR0 (TXNO);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun orden4
	(lit1 mmod mpos pp3 /
		con1 lsvar1 elvar elvar1 flvar nn1
	)
	;(setq con1 nil lsvar1 nil elvar nil elvar1 nil flvar nil nn1 nil)
	;(brkstep '("lit1" "(length lit1)" "mmod" "mpos") "00" "ORDEN4")
	(cond
		(
			(= pp3 nil)
			(setq nn1 0.00002)
			(setq pp3 5)
		)
		(
			(= pp3 1)
			(setq nn1 0.1)
		)
		(
			(= pp3 2)
			(setq nn1 0.01)
		)
		(
			(= pp3 3)
			(setq nn1 0.001)
		)
		(
			(= pp3 4)
			(setq nn1 0.0002)
		)
		(
			(= pp3 5)
			(setq nn1 0.00002)
		)
		(
			(= pp3 6)
			(setq nn1 0.000002)
		)
		(
			(= pp3 7)
			(setq nn1 0.0000002)
		)
		(
			(= pp3 8)
			(setq nn1 0.00000002)
		)
	)
	;(brkstep '("pp3" "nn1") "01" "ORDEN4")
	(setq lsvar1 (lss lit1 (+ mpos 1)))
	;(brkstep '("lsvar1") "02" "ORDEN4")
	(setq  lsvar1 (lva0 lsvar1 1 0 pp3))
	;(brkstep '("lsvar1") "03" "ORDEN4")
	(setq
		lsvar1 (ordvar0 lsvar1 mmod)
		con1 0
	)
	;(brkstep '("lit1" "mmod" "mpos" "lsvar1" "con1") "04" "ORDEN4")
	(while
		(< con1 (length lsvar1))
		(setq elvar (nth con1 lsvar1)
			elvar1 (lnpo4 elvar lit1 mpos 1 nn1)
			con1 (+ con1 1)
			flvar (append flvar elvar1)
		)
		;(brkstep '("elvar" "elvar1" "flvar" "con1") "05" "ORDEN4")
	)
	(setq flvar flvar)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: Manipulacion de listas (LIST)
;;OBJETO: EXACO.- Extrae el numero de codigos de la lista
;;	de base de datos de una entidad (entget), o bien,
;;	de una lista de valores de patron (EXPAT).
;;DEVUELVE:
;;	Lista sencilla de número de codigos
;;	(No1 No2 ...)
;;ARGUMENTOS
;;	1. LSENT1: Lista de codigo y valor de base de datos
;;	de entidad extraida por entget
;;	( Cod.Val Cod.Val ...)
;;	2. LSENT2: Lista de valores de un patron donde el primer
;;	elemento es la posicion del patron dentro de la base de
;;	datos de la entidad
;;DEPENDIENTES: Ninguno
;;ANOTACIONES:
;;	Se define una u otra lista (LSENT1 o LSENT2),
;;	para omitir la opcion contraria a la deseada
;;	se define con (). 
(defun exaco (lsent1 lsent2 / lswk con1 pas1 nls nfl)
  (setq	con1 0
	pas1 0
  )
  (cond
    (
     (not (= lsent2 nil))
     (setq con1	1
	   lswk	lsent2
     )
    )
    (
     (= lsent2 nil)
     (setq con1	0
	   lswk	lsent1
     )
    )
  )
  (while (< con1 (length lswk))
    (setq nls (car (nth con1 lswk)))
    (cond
      (
       (= pas1 0)
       (setq pas1 1
	     nfl  (list nls)
       )
      )
      (
       (= pas1 1)
       (setq nfl (append nfl (list nls)))
      )
    )
    (setq con1 (+ con1 1))
  )
  (setq nfl nfl)
)
;;**Objeto: LVA Extrae los valores (variantes) de una lista estructurada dependiendo de
;;         la posicion indicada:
;;         (x x x x x x x x)
;;Argumentos:
;;           IL: lista estructurada
;;           PPS: posicion de elemento a extraer (la posicion empieza
;;				en 1)
;;           DDN: Modo:
;;           En modo 0 extrae las variantes evaluando todo el elemento:
;;           ( (ab) (sd) (sd) (ab) (JJ) )
;;           En modo 0 = ( (ab) (sd) (JJ) )
;;           En modo 1  y posicion 0 = (a s j)
;;           Es decir devuelve todas las variantes de los elementos
;;				encontrados en la pocision 0
;; El modo 0 ignora la posicion; sin embargo ahi que escribirla con ()
;; Nota solo para listas con el mismo numero de subelementos en cada elemento
(defun lva (il pps ddn / tke ppos conn mil mmil npos)
	;(brkstep '("il" "pps" "ddn") "00" "LVA")
	(setq	mil il
		tke 1
	)
	(cond
		(
			(and (= ddn 1) (<= pps (length (nth 0 il))))
			(setq mil (lss mil pps))
			;(brkstep '("mil") "01" "LVA")
		)
		(
			(and (= ddn 1) (> pps (length (nth 0 il))))
			(setq tke 0)
			(alert
				"LVA: LA POSICION ES MAYOR QUE EL NUMERO DE ELEMENTOS"
			)
		)
	)
	(setq	conn 0
		ppos 0
		npos 0
	)
	(setq	mmil (list (nth conn mil))
		conn (+ conn 1)
	)
	;(brkstep '("mmil" "conn""mil" ) "02" "LVA")
	(while (< conn (length mil))
;		(brkstep
;			'( "mil"
;				"(length mil)"
;				"conn"
;				"mmil"
;				"(nth conn mil)"
;				"(bc mmil (nth conn mil))"
;			)
;			"03" "LVA"
;		)
		(cond
			(
				(= (bc mmil (nth conn mil)) nil)
				(setq mmil (append mmil (list (nth conn mil))))
			)
		)
;		(brkstep '("mmil") "04" "LVA")
		(setq conn (+ conn 1))
	)
	(setq mmil mmil)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: BC
;;	> Busca si una coordenada se encuentra en una lista de coordenadas.
;;DEVUELVE:
;;	> Devuelve el numero de repeticiones o nil si el punto no se
;;	encuentra en la lista de coordenadas.
;;ARGUMENTOS
;;	1.LBC0: Lista de coordenadas
;;	> ( (x y) (...) ...)
;;	2.CBC0: Coordenada
;;	> (x y)
;;	> Precision de 0.0001
;;DEPENDIENTES
;;	> LsType; EqCo
;;ANOTACIONES
;;	> La presicion numerica es de 0.00001
(defun bc
	(lbc0 cbc0 /
		lbc cbc
		ccon rs
	)
;	(setq lbc nil cbc nil
;		ccon nil rs nil
;	)
;	(brkstep1 '("lbc0" "(lstype lbc0)" "cbc0") (list lbc0 (lsType lbc0) cbc0) "00" "BC")
	(cond
		(
			(and (= (type lbc0) 'LIST)
				(not (= cbc0  nil))
			)
			(setq lbc lbc0
				cbc cbc0
			)
			(setq	ccon 0
				rs 0
			)
			(while (< ccon (length lbc))
			;;
;				(brkstep1
;					'("(nth ccon lbc)" "cbc" "(EqLs (nth ccon lbc) cbc 1 0.00015)")
;					(list (nth ccon lbc) cbc (EqLs (nth ccon lbc) cbc 1 0.0001))
;					"01" "BC"
;				)
			;;
				(cond 
					(
						(= (LsType cbc) "NUM")
						(cond
							(
								(EqCo (nth ccon lbc) cbc 1 0.00001)
								;(command "point" (nth ccon lbc))
								(setq rs (+ rs 1))
							)
						)
					)
					(
						(not (= (LsType cbc) "NUM"))
						(cond
							(
								(EqLs (nth ccon lbc) cbc 0 0.00001)
								(setq rs (+ rs 1))
							)
						)
					)
				)
				(setq ccon (+ ccon 1))
			)
			(cond
				(
					(= rs 0)
					(setq rs nil)
				)
			)
		)
	)
	(setq rs rs)
)
;PROYECTO:(NV) Novidesa
;;CLASIFICACION: LIST
;;OBJETO: LISE
;;	Convierte una lista sencilla en una lista estructurada
;;DEVUELVE:
;;	Lista estructurada, lista de listas de cada uno de los
;;	elementos
;;	De: (xx xx xx ...)
;;	A: ( (xx) (xx) (...) ...)
;;ARGUMENTOS:
;;	1. TRALS: Lista de trabajo
;;DEPENDIENTES: Ninguno
;;ANOTACIONES:
(defun lise (trals / cn1 pps ftra)
  (setq	cn1 0
	pps 0
  )
  (while (< cn1 (length trals))
    (cond
      (
       (= pps 0)
       (setq pps  1
	     ftra (list (list (nth cn1 trals)))
       )
      )
      (
       (= pps 1)
       (setq ftra (append ftra (list (list (nth cn1 trals)))))
      )
    )
    (setq cn1 (+ cn1 1))
  )
  (setq ftra ftra)
)
;;PROYECTO: Lisp
;;CLASIFICACION: Manilpulacion de datos (MDAT)
;;OBJETO: EXPAT
;;	Apartir de una lista de patrones, extrae los valores de codigo
;;	y pocision de la base datos de entidad.
;;DEVUELVE:
;;	Lista estructurada de valores donde el primer elemento siempre
;;	es la posicion del patron en la lista de base de datos de
;;	donde se extrajo.
;;[(Posicion Cod.Val Cod.Val ...) (...)...]
;;ARGUMENTOS
;;	1. ARG0
;;	((# # ...) (...) ...)
;;	Lista de patrones, donde se busca en la lista de base de datos
;;	los codigos que correspondan en orden al patron del argumento,
;;	si el patron se repite en la lista de base de datos los extrae
;;	2. LARG0
;;	((Cod.Val) (Cod.Val) ...)
;;	Lista de base de datos de entidad
;;DEPENDIENTES
;;	LispLIST_EXACO
;;ANOTACIONES
;;	En los patrones unico (de un solo numero) se repiten
;;	los que pertenezcan a ortos patrones con ese numero
;;	ya que vuelve a empezar con cada patron.
(defun expat
	(arg0 larg0 /
		vlfpat conini con1 con2 con3 pat lm pas1 vlm
		Dvlpat llpat pver
	)
	;(brkstep1 '("arg0" "larg0") (list arg0 larg0) "00" "expat")
	;(setq arg nil larg nil vlfpat nil conini nil con2 nil con3 nil pat nil
	;	lm nil pas1 nil vlm nil Dvlpat nil llpat nil pver nil
	;)
	(cond
		(
			(and
				(= (type arg0) 'LIST)
				(= (type larg0) 'LIST)
			)
			(setq arg arg0
				larg larg0
			)
			(setq con1 0
				pas1 0
			)
			(while (< con1 (length arg))
			;;
				;(brkstep1 '("arg" "con1" "pas1" "(length arg)")
				;	(list arg con1 pas1 (length arg))
				;	"01" "EXPAT"
				;)
			;;
				(setq pat  (nth con1 arg)
					con3 0
				)
				(while (< con3 (length larg))
				;;
					;(brkstep1
					;	'("larg" "(length larg)" "con3" "pat") 
					;	(list larg (length larg) con3 pat)
					;	"02" "EXPAT"
					;)
				;;
 					(setq vlm	 (nth con3 larg)
						con2 0
						lm	 (nth con2 pat)
						pver nil
					)
					;;
					;(brkstep1
					;	'("vlm" "pat" "lm" "pver")
					;	(list vlm pat lm pver)
					;	"03" "EXPAT"
					;)
					;;
					;;VLM. Elemento codigo.valor <(cod.val)>
					;;LM. Codigo buscado de patron <#>
					;;PVER. Verificación
					(cond
						(
							(= lm (car vlm))
							(setq conini con3
								vlpat  (list conini (nth conini larg))
								con2   (+ con2 1)
								con3   (+ con3 1)
								pver   t
							)
						;;
							;(brkstep1 '("vlpat" "con2" "con3" "pver")
							;	(list vlpat con2 con3 pver)
							;	"04" "EXPAT"
							;)
						;;
							(while
								(and
									(< con2 (length pat))
									(< con3 (length larg))
								)
								(setq pver nil
									lm   (nth con2 pat)
									vlm  (nth con3 larg)
								)
							;;
								;(brkstep1
								;	'("lm" "vlm" "pver")
								;	(list lm vlm pver)
								;	"05" "EXPAT"
								;)
							;;
								(cond
									(
										(= lm (car vlm))
										(setq vlpat (append vlpat (list vlm)))
									;;
										;(brkstep1
										;	'("vlpat" "vlm")
										;	(list vlpat vlm)
										;	"05A" "EXPAT"
										;)
									;;
									)
								)
								(setq con2 (+ con2 1)
									con3 (+ con3 1)
								)
							;;
								;(brkstep1 '("vlpat") (list vlpat) "06" "EXPAT")
							;;
							)
							;(brkstep1 '("vlpat") (list vlpat) "07" "EXPAT")
							(setq llpat (exaco () vlpat))
							;(brkstep1 '("llpat" "pat") (list llpat pat) "08" "EXPAT")
							(cond
								(
									(equal llpat pat)
									(setq pver t)
								)
								(
									(not (equal llpat pat))
									(setq pver nil)
									(setq con3 (+ conini 1))
								)
							)
						)
						(
							(not (= lm (car vlm)))
							(setq con3 (+ con3 1))
						)
					)
					(cond
						(
							(= pver t)
							(cond
								(
									(= pas1 0)
									(setq pas1 1
											vlfpat (list vlpat)
									)
								)
								(
									(= pas1 1)
									(setq vlfpat (append vlfpat (list vlpat)))
									;(brkstep1 '("vlfpat") (list vlfpat) "09" "EXPAT")
								)
							)
						)
					)
				)
				;(brkstep1 '("vlfpat") (list vlfpat) "10" "EXPAT")
				(setq con1 (+ con1 1))
			)
			;(brkstep1 '("vlfpat") (list vlfpat) "11" "EXPAT")
			(setq vlfpat vlfpat)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: (MDAT) Manipulacion de datos
;;OBJETO: SEPI
;;	Separa los pares punteados de una lista creada
;;	con EXPAT donde el primer elemento de cada lista
;;	pertenece a la posicion que ocupa dentro de la
;;	base de datos
;;DEVUELVE:
;;	Lista de argumento con los pares punteados
;;	separados por elementos
;;	( (pos cod val) (pos cod val)
;;ARGUMENTOS: 1. LSPO: El primer elemento de cada lista
;;	pertenece a la posicion
;;	solamente un elemento por lista
;;	( (pos cod.val) (...) ...)
;;DEPENDIENTES: NINGUNO
;;ANOTACIONES
(defun sepi (lspo / cn pas trai traf)
  (setq	cn 0
	pas 0
  )
  (while
    (< cn (length lspo))
     (setq trai	(append
		  (list (nth 0 (nth cn lspo)))
		  (list (car (nth 1 (nth cn lspo))))
		  (list (cdr (nth 1 (nth cn lspo))))
		)
     )
     (cond
       (
	(= pas 0)
	(setq pas  1
	      traf (list trai)
	)
       )
       (
	(= pas 1)
	(setq traf (append traf (list trai)))
       )
     )
     (setq cn (+ cn 1))
  )
  (setq traf traf)
)
;;PROYECTO: LISP
;;CLASIFICACION: LIST
;;OBJETO: LSNO
;;		Elimina un elemento en la lista de
;;		trabajo que corresponde a la posición
;;		indicada en el segundo argumento.
;;DEVUELVE:
;;		La misma lista sin el elemento de
;;		la posición indicada en el segundo
;;		argumento.
;;ARGUMENTOS:
;;		1. LTBX: Lista de trabajo
;;		(XX XX XX XX ...)
;;		2. IPOS: Número de posición (nth)
;;		Numero entero
;;DEPENDIENTES: Ninguno
(defun lsno (ltbx ipos / conta ps ebx lisf)
	(setq conta 0
		ps 0
	)
	(while
		(< conta (length ltbx))
		(cond
			(
				(not (= conta ipos))
				(setq ebx (nth conta ltbx))
				(cond
					(
						(= ps 0)
						(setq ps 1
							lisf (list ebx)
						)
					)
					(
						(= ps 1)
						(setq lisf (append lisf (list ebx)))
					)
				)
			)
		)
		(setq conta (+ conta 1))
	)
	(setq lisf lisf)
)
;;PROYECTO: LISP
;;CLASIFICACION: LIST
;;OBJETO: SUMNTH
;;    Suma una cantidad definida
;;    a un elemento determinado de la lista
;;DEVUELVE:
;;    La misma lista pero con el elemnento sumado
;;		Lista sencilla (xx xx xx ## xx)
;;ARGUMENTOS
;;1. LISNM. Lista sencilla de elementos donde el elemento
;;    a trabajar tiene que ser numero.
;;		Lista sencilla (xx xx xx ## xx)
;;2. PSC. Numero de posición (nth) del elemento que se va a sumar
;;		Numero entero
;;3. SUMDO. Sumando, numero que se va a sumar al elemento.
;;DEPENDIENTES. Ninguno
;;ANOTACIONES.
(defun sumnth (lisnm psc sumdo / con pss ela ffnl)
	(setq con 0
		pss 0)
	(while
		(< con (length lisnm))
		(cond
			(
				(= psc con)
				(setq ela (+ (nth con lisnm) sumdo))
			)
			(
				(not (= psc con))
				(setq ela (nth con lisnm))
			)
		)
		(cond
			(
				(= pss 0)
				(setq pss 1
					ffnl (list ela)
				)
			)
			(
				(= pss 1)
				(setq ffnl (append ffnl (list ela)))
			)
		)
		(setq con (+ con 1))
	)
	(setq ffnl ffnl)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: SEPI0
;;	Apartir de una lista de pares punteados, separa todos los
;;	elementos punteados de la lista
;;DEVUELVE: Lista de pares (sin punto) proviniente de una lista
;;		pares punteados
;;		((x x) (x x) (x x) ...)
;;ARGUMENTOS
;;	1. LSPAR
;;		Lista de pares punteados
;;		( (xx.xx) (...) ...)
;;DEPENDIENTES: Ninguno
;;ANOTACIONES:
;;	Con una doble ejecución de sepi0 genera la lista con la siguiente estructura
;;	( (x (x)) (x (x)) (x (x)) ...)
(defun sepi0 (lspar / con1 pass spar lsep)
	(cond
		(
			(and (not (= lspar nil))
				(= (type lspar) 'LIST)
			)
			(setq con1 0
				pass 0)
			(while (< con1 (length lspar))
				(setq spar
					(append
						(list (car (nth con1 lspar)))
						(list (cdr (nth con1 lspar)))
					)
				)
				(cond
					(
						(= pass 0)
						(setq pass 1
							lsep (list spar))
					)
					(
						(= pass 1)
						(setq lsep
							(append lsep (list spar))
						)
					)
				)
				(setq con1 (+ con1 1))
			)
			(setq lsep lsep)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: Manipulación de rutas (PH)
;;OBJETO: RAP
;;	Devuelve nombre (sin extension) y ruta del dibujo activo
;;	"C:\\Users\\xxx\\XXX\\Drawing1"
;;ARGUMENTOS: NO
;;DEPENDIENTES: NO
(defun rap (/ rr rru)
	(setq rr (substr(getvar "dwgname") 1 (- (strlen (getvar "dwgname")) 4))
		rru (strcat (getvar "dwgprefix") rr)
	)
)
;;Proyecto: Lisp
;;Clasificacion: Path (PH)
;;Objeto: Ruta
;;Define la ruta y nombre de un archivo por medio
;;de un cuadro de dialogo
;;Argumentos:
;;1.EXT: Extension (tipo de archivo) tipo string "XXX" sin punto
;;2.TX: Tipo string complementario a la frase "SELECCIONE EL ARCHIVO"
;;Devuelve: Tipo string. Nombre y ruta del archivo
;;Esta hecho para seleccionar archivos existentes
;;Si se omite la extension (con "") admite la seleccion de
;;cualquier tipo
;;Si se cancela la operacion devuelve nil
(defun ruta (ext tx11 / txx rut)
  (setq txx (strcat "SELECCIONA EL ARCHIVO " tx11)
	rut (getfiled txx "" ext 128))
)
;:PROYECTO:
;;<Lisp>
;:CLASIFICACION:
;;<MDAT>
;:FUNCION / TITULO:
;;<ESCR. Ecribe una lista de datos (Cadenas de texto) en un archivo>
;:SINTAXIS:
;;<(ESCR [Lista] [NomArchivo] [Extension] [Ruta])
;:DESCRIPCION:
;;<<
;;	ESCR. A partir de una lista sencilla de datos
;;	(cadenas de texto), los exporta a un archivo externos
;;>>
;:EJEMPLO:
;;<<
;;	Lst: (list "1,2,3,4,5,6" "uno,dos,tres,cuatro,cinco,seis")
;;	nom: "EscrituraPrueba"
;;	ext: "csv"
;;	rtu: "C:\\Users\\jrsto\\Dropbox\\001_INTELLIGRAM\\Aplicaciones_Lisp\\"
;;	(setq res (escr lst nom ext rtu))
;;	esRes:(L-1 L-2)
;;>>
;:DEVUELVE:
;;<esRe. Lista de lineas numeradas (L-x) por cada linea escrita>
;:ARGUMENTOS:
;;<<
;;	1. LTA0: Lista sencilla de datos (cadenas de texto)
;;	<("el" "Primero" "de" "esto")>
;;	<("1,2,3,4,5,6" "uno,dos,tres,cuatro,cinco,seis")>
;;	2. NMBR0: Nombre del archivo externo (cadena de texto),
;;	"ARCHIVO"
;;	3. XTE0: Extension del archivo externo (tipo de archivo),
;;	<String>
;;	4. RTU0: Ruta de localizacion del archivo externo
;;	<"C:\\Users\\Joserra\\Documents\\">
;;>>
;:DEPENDIENTES:
;;<brkstep1 rutn sutx>
;:LOCALIZACION:
;;<C:\\...\\Dropbox\\FuncionesLisp\\
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>2022.06.30 Actualizacion
;:ANOTACIONES:
;;<<
;;	> La estructura de las cadenas en la lista
;;	depende del  tipo de archivo donde se vacie la
;;	informacion
;;	> Si el archivo no existe, lo crea; si el archivo ya existe,
;;	escribe los datos al final de este.
;;>>
;:ESTADO:
;;<Actualizado>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)

(defun escr
	(lta0 nmbr0 xte0 rtu0 /
		lta nmbr xte rtu
		cnn vr mrtu arr esRes
	)
	;var
;	(setq lta nil nmbr nil xte nil rtu nil
;		cnn nil vr nil mrtu nil arr nil esRes nil
;	)
	;var..
	;br
;	(brkstep1
;		'("lta0" "nmbr0" "xte0" "rtu0")
;		(list lta0 nmbr0 xte0 rtu0)
;		"ESCR:00" "00"
;	)
	;br..
	(cond
		(;CondType true
			(and
				(= (type lta0) 'LIST)
				(= (type nmbr0) 'STR)
				(= (type xte0) 'STR)
			)
			(setq	
				lta lta0
				nmbr nmbr0
				xte xte0
				rtu rtu0
			)
			;br
;			(brkstep1
;				'("lta" "nmbr" "xte" "rtu")
;				(list lta nmbr xte rtu)
;				"ESCR:01" "01"
;			)
			;br..
			(cond
				(
					(= rtu nil)
					(setq rtu (rutn nmbr xte "DE ESCRITURA"))
					(setq rtu (sutx rtu '(("/" "\\"))))
				)
				(
					(not (= rtu nil))
					(setq rtu (sutx rtu '(("/" "\\"))))
					(cond
						(
							(= (substr rtu (strlen rtu) 1) "\\")
							(setq rtu (strcat rtu nmbr "." xte))
						)
						(
							(not (= (substr rtu (strlen rtu) 1) "\\"))
							(setq rtu (strcat rtu "\\" nmbr "." xte))
						)
					)
					;br
;					(brkstep1
;						'("rtu") (list rtu)
;						"ESCR:02" "02"
;					)
					;br..
				)
			)
			;br
;			(brkstep1
;				'("rtu") (list rtu)
;				"ESCR:03" "03"
;			)
			;br..
			(cond
				(;CondRtu true
					(not (= rtu nil))
					(setq arr (open rtu "a")
						cnn 0
					)
					;br
;					(brkstep1
;						'("arr" "rtu") (list arr rtu)
;						"ESCR:04" "04"
;					)
					;br..
					(while (< cnn (length lta))
						(write-line (nth cnn lta) arr)
						;br
;						(brkstep1
;							'("lta1") (list (nth cnn lta))
;							"ESCR:05" "05"
;						)
						;br..
						(setq 
							esRes
							(append esRes
								(list
									(strcat "Ln-" (itoa (+ cnn 1)))
								)
							)
						)
						(setq cnn (+ cnn 1))
						;br
;						(brkstep1
;							'("esRes") (list esRes)
;							"ESCR:06" "06"
;						)
						;br..
					)
					(close arr)
				);CondRtu true..
			)
		);CondType true
	)
	(setq erRes esRes)
)
;;PROYECTO: Lisp
;;CLASIFICACION: Manipulacion de lista (LIST)
;;OBJETO:
;;	TXL1
;;	Multiple TX (variante), convierte una lista estructurada en cadenas de texto
;;	donde los elementos de cada cadena se encuentran separados por
;;	el tercer argumento.
;;	Acepta elementos independientes (que no sean listas)
;;DEVUELVE:
;;	Lista sencilla de cadenas de texto
;;	("xxx?xxx?xx" "xxx?xxx?xx" ...)
;;ARGUMENTOS:
;;	1. TLS: Lista estructurada (lista de listas)
;;	( (xx xx xx ...) (...) ...)
;;	2. PP: Precision de elementos numericos
;;	(tipo numero entero)
;;	3. SS: Separador (tipo string)
;;DEPENDIENTES:
;;	TX (TDAT)
;;ANOTACIONES:
;;	El segundo argumento (precision) tiene que ser numero entero,
;;	de lo contrario, generara un error
;;	En caso de existir elementos independientes (que no sean listas),
;;	las incluye en una cadena de texto.
(defun txl1 (tls pp ss / conn ps el tls1)
  (setq	conn 0
	ps 0
  )
  (cond
    (
     (and
       (= (tdat tls) 0)
       (= (type pp) 'INT)
       (= (tdat ss) 2)
     )
     (while (< conn (length tls))
       (setq el (nth conn tls))
       (cond
	 (
	  (or
	    (= (tdat el) 1)
	    (= (tdat el) 2)
	  )
	  (setq el (list el))
	 )
       )
       (setq el (tx el ss pp))
       (cond
	 (
	  (not (= el nil))
	  (cond	(
		 (= ps 0)
		 (setq tls1 el
		       ps 1
		 )
		)
		(
		 (= ps 1)
		 (setq tls1 (append tls1 el))
		)
	  )
	 )
       )
       (setq conn (+ conn 1))
     )
    )
  )
  (setq tls1 tls1)
)

;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO / TITULO: TXL
;;SINTAXIS: (TXL [ListaTrabajo] [PrecisionNumerica] [Separador])
;;DESCRIPCION:TXL. Convierte una lista estructurada en cadena de texto
;; con los elementos separadados por el argumento ss0
;;	>
;;DEVUELVE:tlsFn. Lista de cadenas de texto
;;	<(("xxx,xxx,...) (...) ...)]
;;ARGUMENTOS
;;	1. tls0. Lista estructurada de trabajo
;;	< ((xx xxx ...) ...)>
;;	2. pp0. Precision para la conversión de elementos numericos
;;	<INT>
;;3. ss0. Elemento separador
;;<STR/CHAR>
;;DEPENDIENTES
;;	< >
;;ANOTACIONES
;;	>Misma funcion que TXL1
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun txl
	(tls0 pp0 ss0 /
		tls pp ss
		txCon1 ps el tlsFn
	)
	;;
;	(setq tls nil pp nil ss nil
;		txCon1 nil ps nil el nil tlsFn nil
;	)
	;;
;	(brkstep1
;		'("tls0" "pp0" "ss0")
;		(list tls0 pp0 ss0)
;		"00" "TXL"
;	)
	;;
	(cond
		(
			(and
				(not (= tls0 nil))
				(not (= pp0 nil))
				(not (= ss0 nil))
			)
			(setq tls tls0
				pp pp0
				ss ss0
			)
			(setq txCon1 0
				ps 0
			)
			(while (< txCon1 (length tls))
				(setq el (nth txCon1 tls)
					el (tx el ss pp)
				)
				;;
;				(brkstep1 '("el") (list el) "01" "TXL")
				;;
				(setq tlsFn (append tlsFn el))
				(setq txCon1 (+ txCon1 1))
			)
		);..cond (and ltls0, pp0, ss0 not (= nil)
	);...Cond
	;;
;	(brkstep1 '("tlsFn") (list tlsFn) "02" "TXL")
	(setq tlsFn tlsFn)
)
;
;;
;;;
;;;;...TXL
;;PROYECTO: Lisp
;;CLASIFICACION: MDAT
;;OBJETO: TDAT
;;Verifica el tipo de datos de una variable
;;Devuelve
;;0. Si el tipo de dato es lista
;;1. Si el tipo de dato es numero
;;2. Si el tipo de dato es texto
;;3. Si el tipo de dato es Nombre de entidad (ENAME)
;;4. Si el tipo de dato es Seleccion de entidades
;;ARGUMENTO:
;;1. TD: Tipo de dato
(defun tdat (td / indi)
  (cond
    (
     (not (= td nil))
     (cond
       (
	(= (type td) 'LIST)
	(setq indi 0)
       )
       (
	(or (= (type td) 'INT)
	    (= (type td) 'REAL)
	)
	(setq indi 1)
       )
       (
	(= (type td) 'STR)
	(setq indi 2)
       )
       (
	(= (type td) 'ENAME)
	(setq indi 3)
       )
       (
	(= (type td) 'PICKSET)
	(setq indi 4)
	)
     )
    )
  )
  (setq indi indi)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: TX
;;	Convierte una lista sencilla  en una cadena de texto con
;;	los elementos separados por el caracter definido en
;;	segundo argumento
;;DEVUELVE:
;;	Lista sencilla de una sola cadena de texto donde todos los
;;	elementos se encuentran incluidos y separado por el argumento 2.
;;	("xxx,xxxx,...")
;;ARGUMENTOS:
;;	1. LSC:
;;	Lista sencilla con elementos de tipo numerico y/o string
;;	(xx xxx ...)
;;	2. SEP:
;;	Cadena de texto o caracter separador (tipo string)
;;	3. PSC: Numero entero que define la presicion de los elementos
;;	numericos.
;;DEPENDIENTES:
;;	TDAT
;;NOTA:
;;	La precision del argumento no.3 tiene que ser numero entero, de lo
;;	contrario generara un error.
(defun tx (lsc sep psc / cona pse ele lsc1)
;(brkstep '("lsc" "sep" "psc") "00" "TX")
  (setq	cona 0
	pse 0
  )
  (cond
    (
     (and (= (tdat lsc) 0)
	  (= (tdat sep) 2)
	  (= (tdat psc) 1)
     )
     (while (< cona (length lsc))
       (setq ele (nth cona lsc))
       (cond
	 (
	  (or (= (tdat ele) 1)
	      (= (tdat ele) 2)
	  )
	  (cond
	    (
	     (= (numberp ele) T)
	     (setq ele (rtos ele 2 psc))
	    )
	  )
	  (cond
	    (
	     (= pse 0)
	     (setq lsc1	ele
		   pse	1
	     )
	    )
	    (
	     (= pse 1)
	     (setq lsc1 (strcat lsc1 sep ele))
	    )
	  )
	 )
       )
       (setq cona (+ cona 1))
     )
     (setq lsc1 (list lsc1))
    )
  )
  (setq lsc1 lsc1)
)
;;PROYECTO: Lisp
;;CLASIFICACION: Manipulacion de rutas (PH)
;;OBJETO: RUTN
;;	Define nombre y ruta de un archivo externo inexistente
;;DEVUELVE: Cadena de texto con el nombre y ruta de la seleccion
;;	obtenida por el usuario
;;	"C:\\Users\\Joserra\\Documents\\MIPALO.txt"
;;ARGUMENTOS
;;	1. NOM: Cadena de texto, nombre del archivo
;;	2. EXT: cadena de texto, extension (sin punto) del archivo
;;	3. TX1: Mensaje de solicitud
;;DEPENDIENTES:
;;	RUTA
;;ANOTACIONES:
;;	Con el caracter "\\" antes del nombre del archivo, el cuadro
;;	de dialogo se coloca sobre C: raiz
(defun rutn (nom ext tx1 / txx rut rtta)
  (setq txx (strcat "SELECCIONA EL ARCHIVO " tx1)
	rtta (getfiled txx nom ext 1))
	(setq rtta rtta)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MDAT
;;TITULO: XDAT1. Exporta los datos de una entidad.
;;DESCRIPCION. XDAT1. Apartir de la definicion del nombre de una entidad
;;	exporta sus datos a un archivo externo (csv)
;;ARGUMENTOS:
;;1. ENTI1. Nombre de entidad <ENAME>
;;2. SP1. Separador <STR>
;;3. PR1. Precision <INT>
;;ANOTACIONES:
;;
(defun xdat1 (enti1 sp1 pr1 / con1 con2 pass1 pass2 lbase lbase1 lbase2 lf0 lf myprec mystr)
	(setq lbase (entget enti1)
        con1 0
        pass1 0
    )
	(cond
		(
			(not (= pr1 nil))
			(setq myprec (getvar "luprec"))
			(setvar "luprec" pr1)
		)
	)
	(setq lbase (sepi0 lbase))
    (while (< con1 (length lbase))
		(setq lbase1 (bindls (nth con1 lbase))
          con2 0
          pass2 0
		)
		(while (< con2 (length lbase1))
			(setq lbase2 (nth con2 lbase1))
			(cond
				(
					(= (type lbase2) 'INT)
					(setq lbase2 (itoa lbase2))
				)
				(
					(= (type lbase2) 'REAL)
					(setq lbase2 (rtos lbase2 2))
				)
				(
					(= (type lbase2) 'ENAME)
					(setq lbase2 "ENAME")
				)
			)
			(cond
				(
					(= pass2 0)
					(setq pass2 1
						lf0 (list lbase2)
					)
				)
				(
					(= pass2 1)
					(setq lf0 (append lf0 (list lbase2)))
				)
			)
			(setq con2 (+ con2 1))
		)
		(cond
			(
				(= pass1 0)
				(setq pass1 1
					lf (list lf0)
				)
			)
			(
				(= pass1 1)
				(setq lf (append lf (list lf0)))
			)
		)
		(setq con1 (+ con1 1))
	)
	(cond
		(
			(not (= pr1 nil))
			(setvar "luprec" myprec)
		)
	)
	(setq lf (txl1 lf 2 sp1))
	(setq mystr (getstring "ARCHIVO?: "))
	(escr lf mystr "csv" (getvar "dwgprexif"))
)
;;PROYECTO: LISP
;;CLASIFICACION: LIST
;;OBJETO:  BINDLS
;; 		Integra todos los elementos de una lista compuesta en
;;		una lista sencilla .
;;DEVUELVE:
;;		(X X X ....)
;;		Lista sencilla de todos los elemento que conforman la lista compuesta
;;ARGUMENTOS
;;		1. LTPPL: Lista principal de trabajo
;;		(xx (XX (xxx) x x .. (x) xx) x ...)
;;		Lista compuesta
;;DEPENDIENTE:
;;	NTHX
;;	LSNO
;;ANOTACIONES:
;;          

(defun bindls (ltppl / lscn lmcl eltr pase slf)
	(setq lscn (list 0)
		pase 0)
	(while
		(< (nth 0 lscn) (length ltppl))
		(cond 
			(
				(= (length lscn) 1)
				(setq lmcl (length ltppl))
			)
			(
				(< 1 (length lscn))
				(setq lmcl(length (nthx (lsno lscn (- (length lscn) 1)) ltppl)))
			)
		)
		(setq eltr (nthx lscn ltppl))
		(cond
			(
				(= (type eltr) 'LIST)
				(setq lscn (append lscn (list 0)))
			)
			(
				(not (= (type eltr) 'LIST))
				(cond
					(
						(not (= eltr nil))
						(cond
							(
								(= pase 0)
								(setq pase 1
									slf (list eltr)
								)
							)
							(
								(= pase 1)
								(setq slf (append slf (list eltr)))
							)
						)
					)
				)
				(cond
					(
						(< (nth (- (length lscn) 1) lscn) lmcl)
						(setq lscn (append
							(lsno lscn (- (length lscn) 1))
							(list (+ (nth (- (length lscn) 1) lscn) 1)))
						)
					)
					(
						(<= lmcl (nth (- (length lscn) 1) lscn))
						(setq lscn (lsno lscn (- (length lscn) 1)))
						(cond
							(
								(not (= lscn nil))
								(setq lscn (sumnth lscn (- (length lscn) 1) 1))
							)
						)
					)
				)
			)
		)

	)
	(setq slf slf)
)
;;PROYECTO: LISP
;;CLASIFICACION: DEP
;;RUTINA: SDS
;;	Exporta los datos de un elemento seleccionado a un archivo csv
;;DEVUELVE: NIL, Exporta los datos de la entidad
;;ARGUMENTOS:
;;	Ninguno
;;DEPENDIENTES
;;	XDAT1 (SEPI0, BINDLS (NTHX LSNO), TXL1 (TDAT), TDAT)
(defun c:sds ( / mil)
	(setq mil (car (entsel))
	)
	(xdat1 mil "," 4)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: LNPO
;;	Extrae o elmimina las listas que
;;	correspondan al elemento indice y
;;	posicion definidos en los argumentos
;;DEVUELVE:
;;	En modo 0:
;;	( (XX XX XX ...) (...) ...)
;;	Todos los elementos de la lista inicial, menos
;;	los que correspondan a los valores de los argumentos
;;	En modo 1:
;;	( (xx EleInd xx ...) (xx EleInd xx xx ...) (...) ...)
;;	Todos los elemenento de la lista inicial que correspondan
;;	a los valores de los argumentos
;;ARGUMENTOS:
;;	1. ELDI: Elemento indice: XXX
;;	Elemento que se va a buscar para la extraccion de la lista
;;	2. TRB: Lista de trabajo: ( (xx xx ...) (...)...)
;;	Lista donde se van a extraer los elementos
;;	3. PPOS: Posicion: Numero entero (NTH)
;;	(NTH) que debe de ocupar el elemento para extraerse o
;;	quitar de la lista
;;	4. MD: Modo de resultado:
;;DEPENDIENTES: Ninguno
(defun lnpo (eldi trb pos md / ccn pps lmdin lmd lmf)
  (setq ccn 0
	pps 0)
  (while
    (< ccn (length trb))
    (setq lmd (nth ccn trb)
		lmdin nil
	)
	;(brkstep '("lmd" "pos" "(and(equal (nth pos lmd) eldi)(= md 1))" "(and (not (equal (nth pos lmd) eldi)) (= md 0))") ".." ".." )
	(cond
		(
			(or
				(and
					(equal (nth pos lmd) eldi)
					(= md 1))
				(and
					(not (equal (nth pos lmd) eldi))
					(= md 0))
			)
			(setq lmdin lmd)
		)
      )
    (cond
      (
       (not (= lmdin nil))
       (cond
	 (
	  (= pps 0)
	  (setq pps 1
		lmf (list lmdin))
	  )
	 (
	  (= pps 1)
	  (setq lmf (append lmf (list lmdin)))
	  )
	 )
       )
      )
    (setq ccn (+ ccn 1))
	;(brkstep '("lmdin" "lmf") "." ".")
	)
  (setq lmf lmf)
  )
	;
	;;
	;;;
	;;;;
;; PROYECTO: Lisp
;; CLASIFICACION: DEPURACION (DEP)
;; OBJETO:
;;	XDAT2
;;	Extrae y exporta a un archivo '.csv' la lista de datos de entidad
;;	definida en el argumento.
;; DEVUELVE:
;;	Exporta datos al archivo csv:
;;	codigo	dato1 dato2 ....
;;	codigo	dato1 dato2 ....
;;	...		...   ...	....
;; ARGUMENTOS:
;;	1. LINTI
;;		Lista de datos (pares punteados)
;;	2. SP1
;;		Caracter de separación
;;	3. PR1
;;		Precisión de elementos númericos
;; DEPENDIENTES
;;	SEPI0 ()
;;	BINDLS (NTHX LSNO)
;;	TXL1 (TDAT)
;;	TDAT
;;
;;;
;;
(defun xdat2 (linti sp1 pr1 / con1 con2 pass1 pass2 lbase lbase1 lbase2 lf0 lf myprec mystr)
	(setq lbase linti
		con1 0
        pass1 0
    )
	(cond
		(
			(not (= pr1 nil))
			(setq myprec (getvar "luprec"))
			(setvar "luprec" pr1)
		)
	)
	(setq lbase (sepi0 lbase))
    (while (< con1 (length lbase))
		(setq lbase1 (bindls (nth con1 lbase))
          con2 0
          pass2 0
		)
		(while (< con2 (length lbase1))
			(setq lbase2 (nth con2 lbase1))
			(cond
				(
					(= (type lbase2) 'INT)
					(setq lbase2 (itoa lbase2))
				)
				(
					(= (type lbase2) 'REAL)
					(setq lbase2 (rtos lbase2 2))
				)
				(
					(= (type lbase2) 'ENAME)
					(setq lbase2 "ENAME")
				)
			)
			(cond
				(
					(= pass2 0)
					(setq pass2 1
						lf0 (list lbase2)
					)
				)
				(
					(= pass2 1)
					(setq lf0 (append lf0 (list lbase2)))
				)
			)
			(setq con2 (+ con2 1))
		)
		(cond
			(
				(= pass1 0)
				(setq pass1 1
					lf (list lf0)
				)
			)
			(
				(= pass1 1)
				(setq lf (append lf (list lf0)))
			)
		)
		(setq con1 (+ con1 1))
	)
	(cond
		(
			(not (= pr1 nil))
			(setvar "luprec" myprec)
		)
	)
	(setq lf (txl1 lf 2 sp1))
	(setq mystr (getstring "ARCHIVO?: "))
	(escr lf mystr "csv" (getvar "dwgprexif"))
)
;; PROYECTO: Lisp
;;	CLASIFICACION: LIST
;; TITULO: ERT1. Ejecuta ERT a una lista estructurada.
;;	DESCRIPCION: ERT1. Extrae de una lista estructurada  los elementos de la
;;              posicion que se pasa en una lista sencilla de números
;;              como argumento.
;; ARGUMENTOS
;; ka: lista de estructurada
;;     ( ((...) (...) (...)) ((...) (...) (...)) ...)
;; kar: Lista de posiciones
;;      ( 1 2 x x ..)
;; Nota : Las posiciones empiezan con el 0 (trabaja con nth)
;;        El ultimo número de posicion tendrá que ser el mayor (Luego lo arreglo!!)
(defun ert1 (ka kar / oni as ii lil)
	(setq oni 0
		as 0)
  (while (< oni (length ka))
		(setq ii (ert (nth oni ka) kar)
			oni (+ oni 1)
		)
		(cond
			(
				(= as 0)
				(Setq lil (list ii)
					as 1
				)
			)
			(
				(= as 1)
				(setq lil (append lil (list ii)))
			)
		)
	)
	(setq lil lil)
)
;;PROYECTO: LISP
;;CLASIFICACION: MAT
;;OBJETO: DTR
;;	Conversión de grados a radianes
(defun dtr (deg)
	(* pi (/ deg 180.0))
)
;;PROYECTO: Lisp
;;CLASIFICACION: ENT (manipulación de entidades)
;;OBJETO: LININ
;;	Apartir de la definicion de un angulo y una coordenada,
;;	encuentra el punto de intersección con otra recta definida
;;DEVUELVE:
;;	NIL / TRUE en el caso de encontrar o no interseccion entre el segmento
;;	de recta y la trayectoria definida en el argumento.
;;AGRUMENTOS:
;;	1. PTO1: Coordenada de punto de inicio de trayectoria
;; (x y) ó (x y z)
;;	2. ANG: Angulo de desplazamiento
;;	3. COLIN: Segmento de recta de interseccion con la trayectoria
;;	(X1 Y1 Z1 X2 Y2 Z2) ó (X1 Y1 X2 Y2)
(defun linin (pto1 ang colin / pto4 pto3 con mivar numvar pto2 ptoin lstfin)
	;(brkstep '("pto1" "ang" "colin") "00" "LININ")
	(setq pto2 (polar pto1 ang 1))
	(setq
		con 0
		numvar 3
	)
	;(brkstep '("pto2" "con" "numvar") "01" "LININ")
	(repeat
		2
		(setq mivar (read (strcat "pto" (itoa numvar))))
		(set mivar '())
		(repeat
			(/ (length colin) 2)
			(set mivar
				(append (eval mivar)
					(list (nth con colin))
				)
			)
			(setq con (+ con 1))
		)
		(setq numvar (+ numvar 1))
	)
	(setq ptoin (inters pto1 pto2 pto3 pto4 nil))
	;(brkstep '("ptoin") "02" "LININ")
	(cond
		(
			(not (= ptoin nil))
			(setq lstfin
				(list
					(eval
						(EqLs
							(+
								(distance pto3 ptoin)
								(distance pto4 ptoin)
							)
							(distance pto3 pto4)
							0
							0.001
						)
					)
					ptoin
				)
			)
		)
	)
	(setq lstfin lstfin)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;TITULO: DTR2. Conversion de radianes a grados
;;ARGUMENTOS:
;; 1.DEG. Radianes
(defun dtr2 (deg)
	(* 180 (/ deg pi))
)
;;PROYECTO: Lisp
;;CLASIFICACION: (MAT) Definiciones matematicas
;;OBJETOS: ANGRES
;;	Apartir de la definicion de tres puntos define el angulo entre las mismas
;;DEVUELVE:
;;	Angulo (real)
;;AGRUMENTOS:
;;	1. PE1.- Punto externo 1
;;		(x y z)
;;	2. PE2.- Punto externo 2
;;		(x y z)
;;	3. PIV.- Punto pivote (vertice)
;;	4. MOD.- Modo de resultado
;;		0 = Resultado de angulo en radianes
;;		1 = Resultado de angulo en grados
;;DEPENDIENTES:
;;	DTR2
(defun angres (pe1 pe2 piv mod / ang1 ang2 angr mod)
	(setq ang1 (angle piv pe1)
		ang2 (angle piv pe2)
	)
	(cond
		(
			(< ang1 ang2)
			(setq angr (- ang2 ang1))
		)
		(
			(> ang1 ang2)
			(setq angr (- ang1 ang2))
		)
	)
	(cond
		(
			(= mod 0)
			(setq angr angr)
		)
		(
			(= mod 1)
			(setq angr (dtr2 angr))
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: (MAT) Definiciones matematicas
;;OBJETO: ANGRES1
;;	Apartir de la definición de un angulo destino y dos puntos,
;;	calcula el angulo entre la recta formada por los dos puntos
;;	y el angulo  destinado
;;DEVUELVE
;;	0.- Angulo en radianes
;;	1.- Angulo en grados
;;DEPENDIENTES
;; DTR2 ()
;;ARGUMENTOS
;;	1.- ANGDES: Angulo destino
;;	 > Angulo expresado en radianes
;;	2.- PIVI: Punto inicial (pivote)
;;	 > (X Y Z)
;;	3.- PX: Segundo punto de recta de origen
;;	 > (X Y Z)
;;	4.- MDD: Modo de resultado
;;	 > 0.- Angulo en radianes
;;	 > 1.- Angulo en grados
(defun angres1 (angdes pivi px mdd / angor angfn)
	(setq angor (angle pivi px))
	(cond
		(
			(< angor angdes)
			(setq angfn (- angdes angor))
		)
		(
			(> angor angdes)
			(setq angfn (- angor angdes))
		)
	)
	(cond
		(
			(= mdd 0)
			(setq angfn angfn)
		)
		(
			(= mdd 1)
			(setq angfn (dtr2 angfn))
		)
	)
)
;; PROYECTO: Lisp
;; CLASIFICACION: (PTO) Manipulacion de coordenadas
;; OBJETO: PROT
;; 	Apartir de la definicion del angulo de movimiento
;;	y direccion, define el punto nuevo de rotacion.
;; DEVUELVE:
;; >	Nuevo punto rotado.
;;	(X Y Z)
;; ARGUMENTOS:
;; 1.- ANGMOV.- Angulo de movimento
;; >	Angulo en radianes
;; 2.- PIV.- Punto pivote
;; >	(X Y Z)
;; 3.- PTO2.- Segundo punto de rotación
;; >	(X Y Z)
;; 4.- PDIR.- Direccion de rotacion
;;	> 0: Direccion en sentido contrario a las manecillas del reloj (+)
;;	> 1: Direccion en sentido a las manecillas del reloj (-)
;; DEPENDIENTES:
;; > ()
;; ANOTACIONES:
(defun prot (angmov piv pto2 pdir / ang1 npto)
	(setq ang1 (angle piv pto2))
	(cond
		(
			(= pdir 0)
			(setq npto
				(polar piv
					(+ ang1 angmov)
					(distance piv pto2)
				)
			)
		)
		(
			(= pdir 1)
			(setq npto
				(polar piv
					(- ang1 angmov)
					(distance piv pto2)
				)
			)
		)
	)
	(setq npto npto)
)
;;;TITULO. CAM1. Cambia la el valor del un codigo en una lista
;;	de entidades.
;;OBJETO: CAM1
;;	Cambia el valor de un codigo indicado en el par punteado
;;	del argumento (2) de un grupo de entidades especificado
;;	en el argumento (1) por una lista de nombres.
;;CLASIFICACION: ENT. Manipulación de entidades.
;;ARGUMENTO:
;;1. LTF0: Lista de nombre de entidades a cambiar
;;	(<Entity name: 7ffffb05a40> ...)
;;2. PAR0: Par punteado de la nueva de nuevo valor para cambiar en las
;;	entidades
;;	(codigo . valor)
;;ANOTACIONES:
;;	En el caso de cambiar el layer de las entidades por uno inexistente
;;	lo crea.
(defun cam1
	(lft0 par0 /
		lft par
		con1 lget vjo lget1 getNam
	)
	;(setq lft nil par nil lft nil par nil
	;	con1 nil lget nil vjo nil lget1 nil getNam nil
	;)
	;(brkstep1 '("lft0" "par0") (list lft0  par0) "00" "CAM1")
	(cond
		(
			(and
				(= (type lft0) 'LIST)
				(= (type par0) 'LIST)
			)
			(setq lft lft0
				par par0
			)
			(setq con1 0)
			(cond
				(
					(not (= lft nil))
					(while (< con1 (length lft))
						(setq getNam (nth con1 lft))
						(setq lget (entget getNam)
							vjo (assoc (car par) lget)
						)
						;;
						;(brkstep1
						;	'("lft" "lget" "vjo" "con1")
						;	(list lft lget vjo con1)
						;	"01" "CAM1"
						;)
						;;
						(cond
							(
								(= vjo nil)
								(setq lget1 (append lget (list par)))
							)
							(
								(not (= vjo nil))
								(setq lget1 (subst par vjo lget))
							)
						)
						(entmod lget1)
						(entupd getNam)
						(setq con1 (+ con1 1))
						;(brkstep1 '("lget") (list lget) "02" "CAM1")
					)
				)
				(
					(= lft nil)
					(alert "CAM1:LISTA NO VALIDA")
				)
			)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: Interface de depuración (DEP)
;;OBJETO: BRKSTEP
;;	Pausa el programa y muestra el valor del las variables definidas
;; 	en el argumento, contiene dos argumentos mas para la descripcion de
;;	los pasos anteriores y posteriores.
;;DEVUELVE: Muestra en pantalla el valor de las variables
;;ARGUMENTOS
;;	1. LSCMD. Lista de comandos 
;;		Lista de cadenas de texto ("" "" "")
;;	2. BKSTP. Descripción de pasos anteriores
;;		Cadena de texto "  "
;;	3. FWRSTP. 	Descripción de texto de siguientes pasos
;;		Cadena de texto "  "
;;DEPENDIENTES:
;;	Ninguno
;;ANOTACIONES
(defun brkstep (lscmd bkstp fwrstp / conx ppx bkstp1 fwrstp1)
	(setq ppx "ss")
	(while
		(not (= ppx ""))
			(setq conx 0)
			(setq bkstp1 (strcat "***** " bkstp " *****"))
			(print	bkstp1)
			(princ "\n")
			(prin1)
			(while
				(< conx (length lscmd))
				(command (strcat "!!" (nth conx lscmd) " "))
				(setq conx (+ conx 1))
			)
			(setq fwrstp1 (strcat "***** " fwrstp " *****"))
			(print fwrstp1)
			(princ "\n")
		(setq ppx (getstring "*********ENTER PARA CONTINUAR**************  "))
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: (MDAT) Manipulacion de datos
;;OBJETO: SEPI
;;	Separa los pares punteados de una lista creada
;;	con EXPAT donde el primer elemento de cada lista
;;	pertenece a la posicion que ocupa dentro de la
;;	base de datos
;;DEVUELVE:
;;	Lista de argumento con los pares punteados
;;	separados por elementos
;;	( (pos cod val) (pos cod val)
;;ARGUMENTOS: 1. LSPO: El primer elemento de cada lista
;;	pertenece a la posicion
;;	solamente un elemento por lista
;;	( (pos cod.val) (...) ...)
;;DEPENDIENTES: NINGUNO
;;ANOTACIONES
(defun sepi (lspo / cn pas trai traf)
  (setq	cn 0
	pas 0
  )
  (while
    (< cn (length lspo))
     (setq trai	(append
		  (list (nth 0 (nth cn lspo)))
		  (list (car (nth 1 (nth cn lspo))))
		  (list (cdr (nth 1 (nth cn lspo))))
		)
     )
     (cond
       (
	(= pas 0)
	(setq pas  1
	      traf (list trai)
	)
       )
       (
	(= pas 1)
	(setq traf (append traf (list trai)))
       )
     )
     (setq cn (+ cn 1))
  )
  (setq traf traf)
)
;; PROYECTO: Lisp
;; CLASIFICACION: (PTO) Manipulacion de coordenadas
;; OBJETO: PTDIR
;; 	Apartir de la definicion de los puntos de la recta y el angulo
;;	destino, determina la direccion de rotacion
;; DEVUELVE:
;; >	0: Direccion de rotacion creciente (sentido contrario a las manecillas
;;		del reloj).
;; >	1: Direccion de rotacion decreciente (en sentido a las manecillas del reloj)
;;	(X Y Z)
;; ARGUMENTOS:
;; 1.- PTO1.- Punto inicial de recta (punto pivote)
;; >	(X Y Z)
;; 2.- PTO2
;; >	(X Y Z)
;; 4.- DDE.- Angulo destino
;;		(X Y Z)
;; DEPENDIENTES:
;; > ()
;; ANOTACIONES:
(defun  ptdir (pto1 pto2 dde / orig diro)
	(setq orig (angle pto1 pto2))
	(if
		(< dde orig)
		(setq diro 1)
		(setq diro 0)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: Manipulacion de datos (MDAT)
;;OBJETO: NOMENT
;;NomEnt: Devuelve una lista de nombre de entidades apartir
;;        de una selección dada como argumento
;;ARGUMENTO:
;;	1. MISE: Selección de entidades
;;	tipo: <selection set XX>
;;DEVUELVE:
;;	Lista de nombre de entidades:
;;	(<Entity name: 7ffffb05a80> <Entity name: 7ffffb05a70>...)
;;DEPENDIENTES:
;;	Ninguno
(defun NomEnt (mise / con pass nmise lmise)
  (cond
    (
     (= mise nil)
     (alert "Funcion NomEnt:\nSELECCION INVALIDA")
     )
    (
     (not (= mise nil))
     (cond
       (
	(= 0 (sslength mise))
	(alert "Funcion NomEnt\nNO EXISTEN ELEMENTOS EN LA SELECCION")
	)
       (
	(< 0 (sslength mise))
	(setq con 0
	      pass 0)
	(while (< con (sslength mise))
	  (setq nmise (ssname mise con))
	  (cond
	    (
	     (= pass 0)
	     (setq pass 1
		   lmise (list nmise)
		   )
	     )
	    (
	     (= pass 1)
	     (setq lmise (append lmise (list nmise)))
	     )
	    )
	  (setq con (1+ con))
	  )
	(setq lmise lmise)
	)
       )
     )
    )
  )
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO: SUMANG
;;	> Suma de dos angulos considerando un máximo de 360 grados.
;;DEVUELVE:
;;	> Angulo sumado en radianes
;;ARGUMENTOS
;;	1. ANGB: Angulo base
;;	> Angulo en radianes
;; 2. ANGS: Angulo de suma
;; > Angulo en radianes
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Trabaja angulos en radianes
(defun sumang (angb angs / r1 rs)
  (cond
    (
     (<
       (* 2 pi)
       (+ angb angs)
     )
     (setq r1 (- (* pi 2) angb)
	   rs (- angs r1)
     )
    )
    (
     (= 0 0)
     (setq rs (+ angb angs))
    )
  )
  (setq rs rs)
)
;;;;*
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: OrdVar0. Ordena una lista de numeros sin repetir
;; Ordena una lista sencilla segun el modo del argumento donde
;;	los elementos de la lista no se repiten
;;	argumento
;;DEVUELVE:
;;	Misma lista generada por EXPAT ordenada
;;	> (N N N N)
;;ARGUMENTOS:
;;	1. LN1: Lista sencilla de numeros
;;	(N N N N N)
;;	2. MMOD: Modos de orden
;;		En modo 0: Ordena las listas de manera ascendente
;;		En modo 1: Ordena las listas de manera descendente
;;ANOTACIONES:
;;
;;DEPENDIENTES:
;; TXNO, LsType
(defun OrdVar0
	(ln1 mmod / con1 eln fln)
	;(brkstep1 '("ln1" "mmod") (list lnl mmod) "00" "ORDVAR0")
	(cond
		(
			(= (LsType ln1) "NUM")
			(while (< 1 (length ln1))
				(setq eln (nth 0 ln1)
					con1 1
				)
				;(brkstep1 '("eln" "con1") (list eln con1) "01" "ORDVAR0")
				(while (< con1 (length ln1))
					(setq eln (min (nth con1 ln1) eln)
						con1 (+ con1 1)
					)
				)
				;(brkstep1 '("eln") (list eln) "02" "ORDVAR0")
				(setq fln (append fln (list eln))
					ln1 (txno ln1 eln)
				)
				;(brkstep1 '("fln" "ln1") (list fln lnl) "03" "ORDVAR0")
			)
			;(brkstep1 '("fln" "ln1") (list fln lnl) "04" "orden0")
			(setq fln (append fln ln1))
			(cond
				(
					(= mmod 0)
					(setq fln fln)
				)
				(
					(= mmod 1)
					(setq fln (reverse fln))
				)
			)
		)
	)
	(setq fln fln)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: ORDEN3
;; > Ordena una lista estructurada de acuerdo a la posicion indicada
;;	en argumento y en orden (ascendente o descendente) definido.
;;DEVUELVE:
;;	Misma lista estructurada y ordenada de acuerdo a la posicion y modo
;;	> ( (N N ..) (...) ...)
;;ARGUMENTOS:
;;	1. LiT1: Lista estructurada de numeros
;;	( (N N ..) (...) ...)
;;	2. MMOD: Modo de orden
;;		En modo 0: Ordena las listas de manera ascendente
;;		En modo 1: Ordena las listas de manera descendente
;; 3. MPOS: Posicion NTH del elemento de referencia para ordenar
;;ANOTACIONES:
;;
;;DEPENDIENTES:
;; LSS; LVA; ORDVAR0 (TXNO);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun orden3
	      (lit1 mmod mpos / con1 lsvar1 elvar elvar1 flvar)
					;(brkstep '("lit1" "mmod" "mpos") (list lit1 mmod mpos) "00" "ORDEN3")
  (setq lsvar1 (lss lit1 (+ mpos 1)))
					;(brkstep1 '("lsvar1") "01" "ORDEN3")
  (setq lsvar1 (lva lsvar1 1 0))
					;(brkstep '("lsvar1") "02" "ORDEN3")
  (setq
    lsvar1 (ordvar0 lsvar1 mmod)
    con1   0
  )
  ;;;
					;(brkstep1
						;'("lit1" "mmod" "mpos" "lsvar1" "con1")
						;(lit1 mmod mmpos lsvar1 con1)
						;"03" "ORDEN3"
					;)
	;;;
  (while
    (< con1 (length lsvar1))
     (setq elvar  (nth con1 lsvar1)
	   elvar1 (lnpo2 elvar lit1 mpos 1 0.001)
	   con1	  (+ con1 1)
	   flvar  (append flvar elvar1)
     )
  )
  (setq flvar flvar)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MDAT
;;OBJETO / TITULO: ASL. Extrae codigos de una lista de datos.
;;DESCRIPCION:
;;; Asl. Funcion extrae caracteristicas apartir de un codigo en una
;; lista estructurada (exid par punteado) en modo 0= para lista de atributos
;; donde el primer argumento no es un par puenteado
;; en modo 1 es para lista de codigo de datos
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. le. Lista de datos de trabajo
;;	> nxx {[(x.x) (y.y) (a.a)] [(...) (...) (...)]}
;;	2. dc. Codigo de extraccion.
;;	3. mdo. Modo de extraccion.
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun Asl (le dc mdo / lls cn pas)
	(setq cn 0
		pas 0
	)
	(while (< cn (length le))
		(cond
			(
				(= mdo 0)
				(cond
					(
						(= pas 0)
						(setq lls (list (cdr (assoc dc (cdr (nth cn le)))))
							pas 1
						)
					)
					(
						(= pas 1)
						(setq lls
							(append
								lls
								(list (cdr (assoc dc (cdr (nth cn le)))))
							)
						)
					)
				)
			)
			(
				(= mod 1)
				(cond
					(
						(= pas 0)
						(setq lls (list (cdr (assoc dc (nth cn le))))
							pas 1
						)
					)
					(
						(= pas 1)
						(setq lls (append lls (list (cdr (assoc dc (nth cn le))))))
					)
				)
			)
		)
		(setq cn (+ cn 1))
	)
	(setq lls lls)
)
;;PROYECTO: Lisp
;;CLASIFICACION: ATT. Manipulacion de atributos
;;OBJETO / TITULO: PSB. Pasa atributos de un block a otro.
;;DESCRIPCION:PSB. Apartir de la definicion del nombre de entidad
;;	de dos bloques, pasa el valor de los atributos del primer block
;;	sobre el segundo segun el modo definido en el tercer argumento.
;;	> MODO 0. Pasa los atributos en orden definido sin importar
;;	el nombre del atributo (TAG),es decir, el primero con el pirmero,
;;	el segundo con el segundo, etc. ....
;;	> MODO 1. Pasa los atributos tomando en cuenta el nombre de cada uno
;;	(TAG).
;;DEVUELVE:
;;	> -
;;ARGUMENTOS
;;	1. BLK10. Primer Block (origen)
;;	> <ENAME>
;;	2. BLK20. Segundo Block (destino)
;; > <ENAME>
;;	3. MM0. Modo de copiado de atributos
;;	> <0 / 1>
;;DEPENDIENTES
;;	>ASL<>;CAM1<>;NXX1<>;
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun psb
	(bk10 bk20 mm0 /
		bk1 bk2 mm
		txd txp ctn ctt ll ppr pst ctt1 lbk1 lbk2
	)
;	(setq bk1 nil bk2 nil mm nil
;		txd nil txp nil ctn nil ctt nil
;		ll nil ppr nil pst nil ctt1 nil lbk1 nil lbk2 nil
;	)
;	(brkstep1 '("bk10" "bk20" "mm0") (list bk10 bk20 mm0) "00" "PSB")
	(cond
		(
			(and
				(= (type bk10) 'ENAME)
				(= (type bk20) 'ENAME)
				(= (type mm0) 'INT)
			)
			;***
			(setq bk1 bk10
				bk2 bk20
				mm mm0
			)
			;***
			(setq
				ll (list 2 1)
				lbk1 (nxx1 bk1 ll)
				lbk2 (nxx1 bk2 ll)
				ctn 0
				pst 0
			)
			;;
;			(brkstep1 '("ll" "lbk1" "lbk2" "ctn" "pst")
;				(list ll lbk1 lbk2 ctn pst)
;				"01" "PSB"
;			)
			;;
			(cond
				(
					(= mm 0)
					;;
					;(brkstep1
					;	'("(length lbk1)" "(length lbk2)")
					;	(list (length lbk1) (length lbk2))
					;	"02"
					;	"PSB"
					;)
					;;
					(cond
						(
							(< (length lbk2) (length lbk1))
							(alert "LOS ATRIBUTOS DE ORIGEN SOBREPASAN A LOS DE DESTINO")
						)
						(
							(> (length lbk2) (length lbk1))
							(alert "LOS ATRIBUTOS DE ORIGEN SON MENORES A LOS DE DESTINO")
						)
					)
					(while (< ctn (length lbk2))
						(if (< ctn (length lbk1))
							(setq ppr (nth 2 (nth ctn lbk1)))
							(setq ppr nil)
						)
						(cond
							(
								(not (= ppr nil))
								(cam1 (list (nth 0 (nth ctn lbk2))) ppr)
							)
						)
						(setq ctn (+ ctn 1))
					)
				)
				(
					(= mm 1)
					(setq ctt 0)
					(while (< ctt (length lbk2))
						(setq txd (asl (list (nth ctt lbk2)) 2 0))
						(setq ctt1 0)
						(while (< ctt1 (length lbk1))
							(setq txp (asl (list (nth ctt1 lbk1)) 2 0))
							(cond
								(
									(equal txd txp)
									(cam1 (list (nth 0 (nth ctt lbk2))) (nth 2 (nth ctt1 lbk1)))
									(setq ctt1 (length lbk1)
										pst 1
									)
								)
								(
									(not (equal txd txp))
									(setq ctt1 (+ ctt1 1))
								)
							)
						)
						(setq ctt (+ ctt 1))
					)
					(cond
						(
							(= pst 0)
							(alert "NO EXISTEN ATRIBUTOS COINCIDENTES")
						)
					)
				)
			)
		)
	)
)
;;;***
;;PROYECTO: Lisp
;;CLASIFICACION: Manipulacion de atributos (ATT)
;;TITULO: NXX1. Obtiene el nombre de entidad y valor de codigos de cada atributo
;;DESCRIPCION:	NXX1. Apartir del nombre (entidad) de un block, obtiene los
;;	valores de los codigos definidos en el argumento (2) de cada
;;	uno de los atributos contenidos en dicho block
;;ARGUMENTOS:
;;	1. NBD0: Nombre de Entidad del Block con atributos
;;	<Entity name: 7ffffb05a80>
;;	2. LS10: Lista de codigos a extraer en cada uno de los atributos
;;	Tipo: Lista sencilla de numeros enteros (codigos)
;;	(8 5 10 7)
;;DEVUELVE:
;;	LSF. Lista estructurada (lista de listas) de codigos y valores
;;	de cada uno de los atributos del block; empezando por el
;;	el nombre de entidad del atributo
;; ((NomAtt1 (Cód.Val) (Cod . Val))(NomAtt2 (Cod.Val) (Cod.Val)))
;;((<Entity name: 7ffffb05a90> (8 . "0") (5 . "221") (7 . "Standard")) (....) ...)
;;DEPENDIENTES:
;; CoOrd(); lscod ();
;;ANOTACIONES:
;;	Devuelve nil en caso de analizar una entidad diferente al block con atributos
;;	NXX1 es el arrgelo de NXX
(defun nxx1
	(nbd0 ls10 / 
		nbd ls lsf lsf0
	)
	;
	;(setq nbd nil ls nil lsf nil lsf0 nil)
;	(brkstep1 '("nbd0" "ls10") (list nbd0 ls10) "00" "NXX1")
	(cond
		(
			(and (= (type nbd0) 'ENAME) (= (type ls10) 'LIST))
			(setq nbd nbd0
				ls ls10
			)
			(cond
				(
					(and
						(= (cdr (assoc 0 (entget nbd))) "INSERT")
						(not (= (entnext nbd) nil))
					)
					;;
;					(brkstep1
;						'("(entget nbd)"
;							"(entget (entnext nbd))"
;						) 
;						(list (entget nbd)
;							(entget (entnext nbd))
;						)
;						"01" "NXX1"
;					)
					;;
					(while
						(= (cdr (assoc 0 (entget (entnext nbd)))) "ATTRIB")
						(setq nbd (entnext nbd))
						;;
;						(brkstep1
;							'("(entget nbd)" "(entget (entnext nbd)")
;							(list (entget nbd) (entget (entnext nbd)))
;							"02" "NXX1"
;						)
						;;
						(setq lsf0 (lscod nbd ls))
;						(brkstep1 '("lsf0") (list lsf0) "03" "NXX1")
						(cond
							(
								(not (= lsf0 nil))
								(setq lsf0 (CodOrd lsf0 ls))
								(setq lsf
									(append lsf
										(list
											(append (list  nbd) lsf0)
										)
									)
								)
							)
						)
						;;
						;(brkstep1
						;	'("lsf" "(entget nbd)" "(entget (entnext nbd))")
						;	(list lsf (entget nbd) (entget (entnext nbd)))
						;	"04"
						;	"NXX1"
						;)
						;;
					)
				)
			)
		)
	)
	(setq lsf lsf)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;TITULO. CORTXT. Convierte una coordenada en cadena de texto
;;DESCRIPCION: CORTXT. Convierte una coordenada en cadena de texto separado
;;	por comas para utilizar en la funcion "command"
;;	> (x y) = "x,y" o (x y z) = "x,y,z" 
;;DEVUELVE: cortx. Cadena de texto de coordenadas
;;	> "x,y" o "x,y,z"
;;ARGUMENTOS
;;	1.lv44. Lista de coordenada
;;	> (x y) o (x y z)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
(defun cortxt (lv44 / pase1 txt1 cortx con1)
					;(brkstep '("lv44") "00" "CORTXT")
  (cond
    (
     (not (= lv44 nil))
     (cond
       (
	(= (type lv44) 'LIST)
	(setq con1 0
	      pase1 0
	)
	(while (< con1 (- (length lv44) 1))
	  (setq txt1 (rtos (nth con1 lv44)))
	  (cond
	    (
	     (= pase1 0)
	     (setq pase1 1)
	     (setq cortx
		    (strcat txt1 ",")
	     )
					;(brkstep '("cortx" "txt1") "00" "CORTXT")
	    )
	    (
	     (= pase1 1)
	     (setq cortx
		    (strcat cortx txt1 ",")
	     )
					;(brkstep '("cortx" "txt1") "01" "CORTXT")
	    )
	  )
	  (setq con1 (+ con1 1))
	)
	(cond
	  (
	   (and	(= cortx nil)
		(= (length lv44) 1)
	   )
	   (setq cortx (rtos (nth con1 lv44)))
	  )
	  (
	   (not (= cortx nil))
	   (setq cortx
		  (strcat cortx
			  (rtos (nth con1 lv44))
		  )
	   )
	  )
	)
       )
     )
    )
  )
					;(brkstep '("cortx" "txt1") "02" "CORTXT")
  (setq cortx cortx)
)
;
;;
;;;
;;;;
;;;;***************************NEXTPOINT0**********
;;PROYECTO: Lisp
;;CLASIFICACION:COOR
;;OBJETO: NEXTPOINT0
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. ANA. Nombre de entidad de polilinea
;;	> ENAME
;;	2.CO1A. Coordenada de division inicial
;;	> NN. Numero natural
;;	3. DISIE. Distancia de division (distancia de tubo)
;;	> ## Numero real (positivo)
;;	4. NUMINI. Numeracion inicial (numero de tubo inicial)
;;	> NN. Numero natural.
;;	5. PREC. Presi Precision numerica
;;	> NN. Numero natural.
;;	6. ANGINI0. Angulo inicial (radianes)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;**************************************************
(defun nextpoint0
	(ana co1a disie numini prec angini0 / 
		disac  co2 discoor con1 
		lis1 lisele0 lisele1 
		liselef ps1 ps2 numprec
		lisele2 snapo disi co1 angins
	)
	;(brkstep1 '("ana" "co1a" "disie" "numini" "prec" "angini0")
	;	(list ana co1 disie numini prec)
	;	"00" "NEXTPOINT0"
	;)
	(setq disi disie
		co1 co1a
		angini (dtr angini0)
	)
	(cond
		(
			(= prec nil)
			(setq numprec 0.00002)
			(setq prec 5)
		)
		(
			(= prec 1)
			(setq numprec 0.1)
		)
		(
			(= prec 2)
			(setq numprec 0.01)
		)
		(
			(= prec 3)
			(setq numprec 0.001)
		)
		(
			(= prec 4)
			(setq numprec 0.0002)
		)
		(
			(= prec 5)
			(setq numprec 0.00002)
		)
		(
			(= prec 6)
			(setq numprec 0.000002)
		)
		(
			(= prec 7)
			(setq numprec 0.0000002)
		)
		(
			(= prec 8)
			(setq numprec 0.00000002)
		)
	)
	(setq prel (getvar "luprec"))
	(setq preau (getvar "auprec"))
	(setq snapo (getvar "osmode"))
	(setvar "luprec" prec)
	(setvar "auprec" prec)
	(setvar "osmode" 0)
	(setq con1 (lcoor1 ana co1 prec))
	(setq lis1 (prepol ana prec))
	(setq numini (- numini 1))
	(setq ps1 0)
	(setq co2 (nth (+ con1 1) lis1))
	
	;(brkstep1 '("con1" "lis1" "numini" "ps1" "(lenght lis1)" "co2")
	;	(list con1 lis1 numini ps1 (length lis1) co2)
	;	"01" "NEXTPOINT0"
	;)
	(while (and (= ps1 0) (< con1 (- (length lis1) 1)))
		(setq disac 0
			ps2 0
		)
		(setq numini (+ numini 1))
		(setq lisele (list numini co1 (angle co1 co2)))
		(setq lisele1 nil)
		;(brkstep1 '("numini" "co2" "co1" "lisele" "ps2")
		;	(list numini co2 co1 lisele ps2)
		;	"02" "NEXTPOINT0"
		;)
		(while (= ps2 0)
			(command "zoom" "c" co1 "35")
			(setq angins (angres1 angini co1 co2 0))
			(setq angini (angle co1 co2))
			;(brkstep1 '("disi" "disac" "co1" "co2" "lisele1" "con1" "angins" "angini")
			;	(list disi disac co1 co2 lisele1 con1 angins angini)
			;	"02A" "NEXTPOINT0")
			(cond
				(
					(equal
						(- disi disac)
						(distance co1 co2)
						numprec
					)
					;(alert "igual")
					(setq lisele1
						(append lisele1
							(list
								(list 
									(dtr2 angins)
									(distance co1 co2)
								)
							)
						)
					)
					(setq disac 0
						co1 co2
						ps2 1
						con1 (+ con1 1)
					)
					(cond
						(
							(< (+ con1 1) (length lis1))
							(setq co2 (nth (+ con1 1) lis1))
						)
						(
							(>= (+ con1 1) (length lis1))
							(setq ps1 1)
						)
					)
					;(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
					;	(list lisele1 disac co1 co2 ps2 con1)
					;	"02B" "NEXTPOINT0"
					;)
				)
				(
					(<
						(- disi disac)
						(distance co1 co2)
					)
					;(alert "menor")
					(setq co1
						(polar co1
							(angle co1 co2)
							(- disi disac)
						)
					)
					(setq lisele1
						(append lisele1
							(list
								(list
									(dtr2 angins)
									(- disi disac)
								)
							)
						)
					)
					(setq disac 0
						ps2 1
					)
					;(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
					;	(list lisele1 disac co1 co2 ps2 con1)
					;	"02C" "NEXTPOINT0"
					;)
				)
				(
					(>
						(- disi disac)
						(distance co1 co2)
					)
					;(alert "mayor")
					(setq lisele1
						(append lisele1
							(list
								(list
									(dtr2 angins)
									(distance co1 co2)
								)
							)
						)
					)
					(setq disac (+ disac (distance co1 co2)))
					(setq co1 co2)
					(setq con1 (+ con1 1))
					(cond
						(
							(< (+ con1 1) (length lis1))
							(setq co2 (nth (+ con1 1) lis1))
						)
						(
							(>= (+ con1 1) (length lis1))
							(setq co2 (nth (+ con1 1) lis1))
							(setq ps2 1)
						)
					)
					;(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
					;	(list lisele1 disac co1 co2 ps2 con1)
					;	"02D" "NEXTPOINT0"
					;)
				)
			)
		)
		(setq lisele2 (append lisele (list lisele1)))
		(setq liselef (append liselef (list lisele2)))
		;(brkstep1 '("LISELE1" "LISELEF" "DISAC" "CO1" "CO2" "PS2" "CON1")
		;	(list lisele1 liselef disac co1 co2 ps2 con1)
		;	"03" "NEXTPOINT0"
		;)
		(setvar "luprec" prel)
		(setvar "auprec" preau)
		(setvar "osmode" snapo)
	)
	(setq liselef liselef)
)
;;;;***************************NEXTPOINT**********
;;PROYECTO: Lisp
;;CLASIFICACION:COOR
;;OBJETO: NEXTPOINT. Crea lista de cadenamiento (nexpoint CIVIL)
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. ANA. Nombre de entidad de polilinea
;;	> ENAME
;;	2.CO1A. Coordenada de division inicial
;;	> NN. Numero natural
;;	3. DISIE. Distancia de division (distancia de tubo)
;;	> ## Numero real (positivo)
;;	4. NUMINI. Numeracion inicial (numero de tubo inicial)
;;	> NN. Numero natural.
;;	5. PREC. Presi Precision numerica
;;	> NN. Numero natural.
;;	6. ANGINI0. Angulo inicial (radianes)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Introduccion de atributos por medio de blocks (attreq 1)
;;;(brkstep '("") "001TEMP" "")
;;**************************************************
(defun nextpoint 
	(ana co1a disie numini prec angini0 /
		disac co2 discoor con1
		lis1 lisele0 lisele1
		liselef ps1 ps2 numprec
		snapo disi co1 angins angini rev
		angini2 nextcad nextinf mensacad nextangi 
		ppta1 ppta2 deci msele diatt ecov numinext coini
		din anin mimi co2a anic midonut nePass
		neHand neMarc0 neMarc1 neTubo0 neTubo1 neTubo
		neAttReq neAttDia
	)
;	(setq
;		disac nil co2 nil discoor nil con1 nil
;		lis1 nil lisele0 nil lisele1 nil
;		liselef nil ps1 nil ps2 nil numprec nil
;		snapo nil disi nil co1 nil angins nil angini nil rev nil
;		angini2 nil nextcad nil nextinf nil mensacad nil nextangi nil 
;		ppta1 nil ppta2 nil deci nil msele nil diatt nil ecov nil numinext nil coini nil
;		din nil anin nil mimi nil co2a nil anic nil midonut nil nePass nil
;		neHand nil neMarc0 nil neMarc1 nil neTubo0 nil neTubo1 nil neTubo nil
;		neAttReq nil neAttDia nil
;	)
	;(brkstep1 '("ana" "co1a" "disie" "numini" "prec" "angini0")
	;	(list ana co1a disie numini prec)
	;	"00" "NEXTPOINT"
	;)
	(setq diatt (getvar "attdia")
		ecov (getvar "cmdecho")
		msele (ssadd)
		neAttReq (getvar "attreq")
		neAttDia (getvar "attdia")
	)
	(setvar "attdia" 0)
	(setvar "cmdecho" 1)
	(cond
		((= prec nil) (setq numprec 0.00002) (setq prec 5))
		((= prec 1) (setq numprec 0.1))
		((= prec 2) (setq numprec 0.01))
		((= prec 3) (setq numprec 0.001))
		((= prec 4) (setq numprec 0.0002))
		((= prec 5) (setq numprec 0.00002))
		((= prec 6) (setq numprec 0.000002))
		((= prec 7) (setq numprec 0.0000002))
		((= prec 8) (setq numprec 0.00000002))
	)
	;(brkstep1 '("numprec") (list numprec) "01" "NEXTPOINT")
	(setq prel (getvar "luprec"))
	(setq preau (getvar "auprec"))
	(setq snapo (getvar "osmode"))
	(setvar "luprec" prec)
	(setvar "auprec" prec)
	;(setvar "osmode" 0)
	;(brkstep1 '("prel" "preau" "snapo") (list prel preau snapo) "02" "NEXPOINT")
	;**VARIABLES
	(setq disi disie
		deci "CONTINUAR"
		co1 co1a
		co1 (list (nth 0 co1) (nth 1 co1))
		angini  angini0
		neHand (cdr (assoc 5 (entget ana)))
	)
	(setq con1 (LCoo2 ana co1 prec))
	;(brkstep1 '("disi" "co1" "angini" "neHand") (list disi co1 angini neHand) "03" "NEXTPOINT")
	;**DISI. ##.## -DISTANCIA DE CADENAMIENTO-
	;**CO1 (XY) -COORDENADA INICIAL-
	;**ANGINI. ##.## en radianes -ANGULO INICIAL-
	;neHand. Handlet de polilinea
	;con1. Posicion nth de coordenada correspondiente al tramo inicial
	;(proximo anterior al punto de designacion o punto exacto)
	(cond
		(
			(not (= con1 nil))
			(setq con1 (+ con1 1))
			;(setq lis1 (prepol ana prec))
			(setq lis1
				(mapcar 'cdr (lscod ana '(10)))
			)
			(setq numini (- numini 1))
			;(brkstep1
			;	'("con1" "lis1" "numini" "ps1")
			;	(list con1 lis1 numini ps1)
			;	"04" "NEXTPOINT"
			;)
			;**LIS1. Lista de coordenadas de polilinea ((XY) (...) ...)
			;NUMNI. Numero de tubo inicial (-1 para comenzar)
			(while
				(and
					(< con1 (length lis1))
					(not (= deci "SALIR"))
				)
				(princ)
				(setq disi (getreal "Introduzca la distancia <enter para terminar>: "))
				(princ)
				(cond
					(
						(not (= disi nil))
						;(brkstep1 '("DECI") (list deci) "04A" "NEXTPOINT")
						(setq disac 0 ps2 0)
						(setq numini (+ numini 1))
						(setq co2 (nth con1 lis1)
							co2 (list (nth 0 co2) (nth 1 co2))
						)
						(setq lisele (list numini co1 (angle co1 co2)))
						(setq coini co1)
						(setq lisele1 nil)
						;(brkstep1 '("disac" "ps2" "numini" "co2" "co1" "lisele")
						;	(list disac ps2 numini co2 co1 lisele)
						;	"05" "NEXTPOINT"
						;)
						;**DISAC = 0
						;**CO2 (XY)
						;**LISELE (nnTubo (XY)inicial #.##RAD)
						(while
							(and
								(= ps2 0)
								(< con1 (length lis1))
								(not (= deci "SALIR"))
							)	
							;(brkstep1 '("DECI") (list deci) "05A" "NEXTPOINT")
							(setq deci nil
								neMarc nil
							)
							(setvar "osmode" 0)
							(command "zoom" "c" co1 "50")
							(setq co2 (nth con1 lis1)
								co2 (list (nth 0 co2) (nth 1 co2))
							)
							(command "zoom" co1 co2)
							;(brkstep1 '("co1" "co2") (list co1 co2) "05B" "NEXPOINT")
							(command "zoom" "sc" 50)
							(setvar "osmode" snapo)
							;(setq rev (boli2 (list co1 co2) 0.30))
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							;(brkstep1
							;	'("CO1" "CO2"
							;		"ANGINI" "ANGANTERIOR"
							;		"ANGINS"  "ANGULO" "ANGULOACTUAL"
							;	)
							;	(list co1 co2 angini
							;		(dtr2 angini) angins 
							;		(angle co1 co2) (dtr2 (angle co1 co2))
							;	)
							;	"06" "NEXTPOINT"
							;)
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							;(command "erase" rev "")
							(cond
								(
									(equal angini (angle co1 co2) 0.0174533)
									(setq angins 0)
									;(brkstep1 '("angins") (list (dtr2 angins)) "00TEMP" "Next")
								)
								(
									(not (equal angini (angle co1 co2) 0.0174533))
									(setq angins (angres5 angini co1 co2  0 prec))
									;(brkstep1 '("angins") (list (dtr2 angins)) "01TEMP" "Next")
								)
							)
							(setq angini (round (angle co1 co2) prec))
							;(brkstep1
							;	'("disi" "disac" "(- disi disac)" "con1" "co2" "angini" "angins")
							;	(list disi disac (- disi disac) con1 co2 angini angins)
							;	"06A" "NEXTPOINT"
							;)
							;;;;;;;;;;;;;;;;;ANALISIS DE CADENAMIENTO;;;;;;;;;;;;;;;;;;;(0)
							(cond
								(
									(equal
										(- disi disac)
										(distance co1 co2)
										numprec
									)
									;(alert "Samehere")
									(setq numinext nil)
									(setq nextcad (rtos (round (- disi disac) prec)))
									(setq nextinf (rtos (round (distance co1 co2) prec)))
									(setvar "osmode" 0)
									(command "donut" 0 0.8 co2 "")
									(setvar "osmode" snapo)
									(setq midonut (entlast))
									(cam1 (list midonut) '(62 . 1))
									(setq mensacad
										(strcat 
											"Distancia al proximo Cadenamiento " nextcad "\n"
											"Distancia al proximo punto de inclinacion " nextinf "\n"
										)
									)
									(cond
										(
											(< con1 (- (length lis1) 1))
											(setq nextangi
												(angres5 angini co2 (nth (+ con1 1) lis1) 0 prec)
												nextangi (rtos (dtr2 nextangi))
											)
											(setq mensacad
												(strcat mensacad "Inclinacion del siguiente tubo "
													nextangi
												)
											)
										)
									)
									;(alert mensacad)
									(setq deci "CONTINUAR"
									;	(opc
									;		'("Continuar" "Definir distancia" "Salir")
									;		"Que desea hacer?: "
									;	)
									)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(brkstep1
									;	'("disac" "(- disi disac)" "DECI")
									;	(list disac (- disi disac) deci)
									;	"00temp" "NEXTPOINT"
									;)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									(cond
										(
											(= deci "CONTINUAR")
											(setq anin
												(round (angle coini co2) prec)
												anic
												(round (angle co1 co2) prec)
											)
											(setq
												co2a co2
												din
												(polar coini anin (/ (distance coini co2a) 2))
												din
												(polar din (sumang anin 1.5708) 2)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("DIN" "ANIN" "NUMINI (TXT)" "CO2A")
											;	(list din anin numini co2a)
											;	"06B" "NEXPOINT"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setvar "osmode" 0)
											(setvar "attdia" 0)
											(setvar "attreq" 1)
											(command "insert"
												"NumeroTubo"
												(strcat (cortxt din) ",0") 1 1
												;0
												(round (dtr2 (AngCam anin)) 3)
												;(dtr2 anin)
												(itoa numini)
											)	
											(setq neTubo (entlast)
												mimi (cdr (assoc 5 (entget neTubo)))
											)
											(command "insert"
												"punta1"
												(strcat (cortxt co2a) ",0") 1 1
												(dtr2 anic)
												(itoa (+ numini 1))
												"-"
												"-"
											)
											(setq neMarc1 (entlast))
											(setvar "attreq" neAttReq)
											(setvar "attdia" neAttDia)
											;;;;;;;;;
;											(brkstep1
;												'("neHand" "neTubo"
;													"neMarc1" "neMarc0"
;													"Distancia" "Tubo"
;												)
;												(list neHand neTubo
;													neMarc1 neMarc0
;													(rtos disi 2 2)
;													numini
;												)
;												"06C" "NEXTPOINT"
;											)
											;;
											(xinat0
												'("ELEMENTO"
													"ID_POL"
													"DIST_ANTERIOR"
													"DIST_POSTERIOR"
													"TUBO_ANTERIOR"
													"TUBO_POSTERIOR"
												)
												(list "MARCADOR" neHand
													(rtos disi 2 2) "-"
													(itoa numini) "-"
												)
												"-" "AZ-CIVIL" neMarc1
											)
											(cond
												(
													(not (= neMarc0 nil))
													(xin4
														neMarc0
														(list
															(list "DIST_POSTERIOR"
																(rtos disi 2 2)
															)
															(list "TUBO_POSTERIOR"
																(itoa numini)
															)
														)
														"AZ-CIVIL"
													)
												)
											)
											(setq neMarc0 neMarc1);;;;;Insertar nuevo metodo
											(xinat0
												'("ELEMENTO" "ID_POL" "DISTANCIA" "NUM_TUBO")
												(list "ETIQUETA" neHand
													(rtos disi 2 2) (itoa numini)
												)
												"-" "AZ-CIVIL" neTubo
											)
											;;
											(setvar "osmode" snapo)
											(setq lisele1
												(append lisele1
													(list
														(list 
															(dtr2 angins)
															(round (distance co1 co2) prec)
															(dtr2 angini)
															co1
															co2
														)
													)
												)
											)
											(setq disac 0
												co1 co2
												ps2 1
												con1 (+ con1 1)
											)
											;**LISELE1. ((##.##AngRad ##.##DistTramo) (...) ...)
											;**DISAC = 0
											;(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1" "DECI")
											;(list lisele1 disac co1 co2 ps2 con1 deci)
											;"07A" "NEXTPOINT"
											;)
										)
										(
											(= deci "DEFINIR DISTANCIA")
											(setq disi (getreal "Introduzca la distancia de tramo :"))
											(princ) (princ)
											(cond
												(
													(= disi nil)
													(while
														(= disi nil)
														(setq ppta1 (getpoint "Seleccione el primer punto: ")
															ppta2 (getpoint "seleccione el segundo punto: ")
														)
														(cond
															(
																(and
																	(not (= ppta1 nil))
																	(not (= ppta2 nil))
																)
																(setq disi (distance ppta1 ppta2))
																(if
																	(not (= disi nil))
																	(round disi prec)
																)
															)
														)
													)	
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("DECI" "DISI")
											;	(list deci disi)
											;	"07B" "NEXTPOINT"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										)
									)
									(entdel midonut)
								)
								(
									(<
										(- disi disac)
										(distance co1 co2)
									)
									;(alert "lessthan")
									;(brkstep1 '("disac" "(- disi disac)") (list disac (- disi disac)) "08" "NEXTPOINT")
									(setq nextcad (rtos (round (- disi disac) prec)))
									(setq nextinf (rtos (round (distance co1 co2) prec)))
									(setvar "osmode" 0)
									(command "donut" 0 0.8
										(polar co1 (angle co1 co2) (- disi disac))
										""
									)
									(setvar "osmode" snapo)
									(setq midonut (entlast))
									(cam1 (list midonut) '(62 . 1))
									(setq mensacad
										(strcat 
											"Distancia al proximo Cadenamiento " nextcad "\n"
											"Distancia al proximo punto de inclinacion " nextinf "\n"
										)
									)
									(cond
										(
											(< con1 (- (length lis1) 1))
											(setq nextangi
												(angres5 angini co2 (nth (+ con1 1) lis1) 0 prec)
												nextangi (rtos (dtr2 nextangi))
											)
											(setq mensacad
												(strcat mensacad "Inclinacion del siguiente tubo "
													nextangi
												)
											)
										)
									)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(brkstep1
									;	'("NEXTCAD" "NEXTINF" "NEXTANGI")	
									;	(list nextcad nextinf nextangi)
									;	"09" "NEXTPOINT"
									;)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(alert mensacad)
									(setq deci "CONTINUAR"
										;(opc
										;	'("Continuar" "Definir distancia" "Salir")
										;	"Que desea hacer?: "
										;)	
									)
									(cond
										(
											(= deci "CONTINUAR")
											(setq anin
												(round (angle coini co2) prec)
												anic
												(round (angle co1 co2) prec)
											)
											(setq
												co2a
												(polar co1 (angle co1 co2) (- disi disac))
												din
												(polar coini anin (/ (distance coini co2a) 2))
												din
												(polar din (sumang anin 1.5708) 2)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("DIN" "ANIN" "NUMINI (TXT)" "CO2A" "COORDENADA")
											;	(list din anin numini co2a (strcat (cortxt din) ",0"))
											;	"09A" "NEXPOINT"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setvar "osmode" 0)
											(setvar "attdia" 0)
											(setvar "attreq" 1)
											(command "insert" "NumeroTubo" din 1 1
												(round (dtr2 (AngCam anin)) 3)
												(itoa numini)
											)
											(setq neTubo (entlast)
												mimi (cdr (assoc 5 (entget neTubo)))
											)
											(command "insert"
												"punta1"
												(strcat (cortxt co2a) ",0") 1 1
												(dtr2 anic)
												(itoa (+ numini 1))
												""
												""
											)
											(setq neMarc1 (entlast))
											(setvar "attdia" neAttDia)
											(setvar "attreq" neAttReq)
											;;;;;;;;;
;											(brkstep1
;												'("neHand" "neTubo"
;													"neMarc1" "neMarc0"
;													"Distancia" "Tubo"
;												)
;												(list neHand neTubo
;													neMarc1 neMarc0
;													(rtos disi 2 2)
;													numini
;												)
;												"09B" "NEXTPOINT"
;											)
											;;
											(xinat0
												'("ELEMENTO"
													"ID_POL"
													"DIST_ANTERIOR"
													"DIST_POSTERIOR"
													"TUBO_ANTERIOR"
													"TUBO_POSTERIOR"
												)
												(list
													"MARCADOR" neHand
													(rtos disi 2 2) "-"
													(itoa numini) "-"
												)
												"-" "AZ-CIVIL" neMarc1
											)
											(cond
												(
													(not (= neMarc0 nil))
													(xin4
														neMarc0
														(list
															(list "DIST_POSTERIOR"
																(rtos disi 2 2)
															)
															(list "TUBO_POSTERIOR"
																(itoa numini)
															)
														)
														"AZ-CIVIL"
													)
												)
											)
											(setq neMarc0 neMarc1);;;;;;;;;;;;;Insertar nuevo
											(xinat0
												'("ELEMENTO" "ID_POL" "DISTANCIA" "NUM_TUBO")
												(list "ETIQUETA" neHand
													(rtos disi 2 2) (itoa numini)
												)
												"-" "AZ-CIVIL" neTubo
											)
											;;
											(setvar "osmode" snapo)
											(setq lisele1
												(append lisele1
													(list
														(list
															(dtr2 angins)
															(- disi disac)
															(dtr2 angini)
															co1
															(polar co1 (angle co1 co2) (- disi disac))
														)
													)
												)
											)
											(setq co1
												(polar co1
													(angle co1 co2)
													(- disi disac)
												)
											)
											(setq co1 (list (nth 0 co1) (nth 1 co1)))
											(setq disac 0
												ps2 1
											)
											;(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
											;	(list lisele1 disac co1 co2 ps2 con1)
											;	"10" "NEXTPOINT"
											;)
										)
										;;;;;;;;;;;;;;;;;;
										(
											(= deci "DEFINIR DISTANCIA")
											(setq disi (getreal "Introduzca la distancia de tramo :"))
											(princ) (princ)
											(cond
												(
													(= disi nil)
													(while
														(= disi nil)
														(setq ppta1 (getpoint "Seleccione el primer punto: ")
															ppta2 (getpoint "seleccione el segundo punto: ")
														)		
														(cond
															(
																(and
																	(not (= ppta1 nil))
																	(not (= ppta2 nil))
																)
																(setq disi (distance ppta1 ppta2))
																(if
																	(not (= disi nil))
																	(round disi prec)
																)
															)
														)
													)	
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("DECI" "DISI")
											;	(list deci disi)
											;	"11" "NEXTPOINT"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										)
									)
									(entdel midonut)
								)
								(
									(>
										(- disi disac)
										(distance co1 co2)
									)
									;(alert "Morethan")
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(brkstep1
									;	'("co1" "co2"
									;		"(distance co1 co2)"
									;		"disac"
									;		"(- disi disac)"
									;		"disac"
									;		"(- disi disac)"
									;	)
									;	(list co1 co2
									;		(distance co1 co2)
									;		disac
									;		(- disi disac)
									;		disac
									;		(- disi disac)
									;	)
									;	"12" "NEXTPOINT"
									;)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									(setq nextcad (rtos (round (- disi disac) prec)))
									(setq nextinf (rtos (round (distance co1 co2) prec)))
									(cond
										(
											(>= con1 (- (length lis1) 1))
											(setq mensacad
												(strcat "Distancia al ultimo cadenamiento " nextcad)
											)
											(setvar "osmode" 0)
											(command "donut" 0 0.8 co2 "")
											(setq midonut (entlast))
											(cam1 (list midonut) '(62 . 1))
											(setvar "osmode" snapo)
										)
										(
											(< con1 (- (length lis1) 1))
											(setq nextangi
												(angres5 angini co2 (nth (+ con1 1) lis1) 0 prec)
												nextangi (rtos (dtr2 nextangi))
											)
											(setvar "osmode" 0)
											(command "donut" 0 0.8
												(polar co2 
													(angle co1 (nth (+ con1 1) lis1))
													(- disi (+ disac (distance co1 co2)))
												)
												""
											)
											(setq midonut (entlast))
											(cam1 (list midonut) '(62 . 1))
											(setvar "osmode" snapo)
											(setq mensacad
												(strcat 
													"Distancia al proximo Cadenamiento " nextcad "\n"
													"Distancia al proximo punto de inclinacion " nextinf "\n"
													"Inclinacion del siguiente tubo " nextangi
												)
											)
										)
									)
									;(alert mensacad)
									(setq deci "CONTINUAR"
										;(opc	
										;	'("Continuar" "Definir distancia" "Salir")
										;	"Que desea hacer?: "
										;)
									)
									;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(brkstep1
									;	'("DECI") (list deci) "13" "NEXPOINT"
									;)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;
									(cond
										(
											(= deci "DEFINIR DISTANCIA")
											(setq disi (getreal "Introduzca la distancia de tramo :"))
											(princ) (princ)
											(cond
												(
													(= disi nil)
													(while
														(= disi nil)
														(setq ppta1 (getpoint "Seleccione el primer punto: ")
															ppta2 (getpoint "seleccione el segundo punto: ")
														)
														(cond
															(
																(and
																	(not (= ppta1 nil))
																	(not (= ppta2 nil))
																)
																(setq disi (distance ppta1 ppta2))
																(if
																	(not (= disi nil))
																	(round disi prec)
																)
															)
														)
													)	
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("DECI" "DISI")
											;	(list deci disi)
											;	"14" "NEXTPOINT"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										)
										(
											(= deci "CONTINUAR")
											(setq lisele1
												(append lisele1
													(list
														(list
															(dtr2 angins)
															(distance co1 co2)
															(dtr2 angini)
															co1
															co2
														)
													)
												)
											)
											(cond 
												(
													(>= con1 (- (length lis1) 1))
													(command ^^C)
											;		(setq anin (round (angle coini co2) prec))
											;		(setq anic (round (angle co1 co2) prec))
											;		(setq din (polar coini anin (/ (distance coini co2) 2)))
											;		(setq din (polar din (sumang anin 1.5708) 2))
											;		(command "insert" "NumeroTubo"
											;			(strcat (cortxt din) ",0") 1 1
											;			(dtr2 anin) (itoa numini)
											;		)
											;		(command "insert" "punta1"
											;			(strcat (cortxt co2) ",0") 1 1
											;			(dtr2 anic) "Niple" "-" "-" ""
											;		)
												)
											)
											(setq disac (+ disac (distance co1 co2)))
											(setq co1 co2)
											(setq con1 (+ con1 1))
											(setq ps2 0)
											;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
											;	(list lisele1 disac co1 co2 ps2 con1)
											;	"15" "NEXTPOINT"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;
										)
									)
									(entdel midonut)
								)
							)
							;;;;;;;;;;;;;;;;;ANALISIS DE CADENAMIENTO;;;;;;;;;;;;;;;;;;;(1)
						)
						(cond
							(
								(not (= lisele1 nil))
								(setq lisele2
									(append lisele (list lisele1))
								)
								(setq liselef
									(append liselef (list lisele2))
								)
								;(brkstep1
								;	'("LISELE1" "LISELEF"
								;		"DISAC" "CO1" "CO2"
								;		"PS2" "CON1" "ANGINI"
								;		"ANGINS"
								;	)
								;	(list lisele1 liselef
								;		disac co1 co2 ps2 con1
								;		angini angins
								;	)
								;	"15" "NEXTPOINT"
								;)
							)
						)
					)
					(
						(= disi nil)
						(setq deci "SALIR")
					)
				)
				;(brkstep1
				;	'("LISELEF")
				;	(list liselef)
				;	"09" "NEXPOINT"
				;)
			)
		)
	)
	(princ) (princ)
	(setvar "luprec" prel)
	(setvar "auprec" preau)
	(setvar "osmode" snapo)
	(setq liselef liselef)
)
;
;;
;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:LIST
;;OBJETO:CORDEN. Ordena la lista base (un grupo) o la lista de conexiones
;;	de acuerdo a su pendiente
;;	> ((p o hd (xy) (xy)) (...) ...)
;;	> ((p o hd (cnx xy) (...) ...) (...) ...)
;;DEVUELVE:
;;	> Misma lista ordenada
;;ARGUMENTOS
;;	1.BB0. Lista base de un grupo de pendiente (ejemplo en descripcion del
;;	objeto.
;;	2. CX. Tipo de lista:
;;		0. Sin conexiones
;;		1. Con conexiones
;;	3. PPZ0. Precision de comparacion numerica
;;		Numero entero (numero de decimales)
;;DEPENDIENTES
;;	> MAT5A <>; AGRU2 <>; NTHX <>; ORDEN5 <>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")

(defun corden
	(bb0 cx ppz0 /
		con101 indipen frstls ppredis bb1 ppz part1 part2 	
		final0 con0 final1 final2 listpos ordenf con10 final3 coprevar
	)
	;(setq con101 nil indipen nil frstls nil ppredis nil bb1 nil ppz nil part1 nil part2 nil
	;	final0 nil con0 nil final1 nil final2 nil listpos nil ordenf nil con10 nil final3 nil
	;	coprevar nil)
	;;;;;;;;;;;;;;;;ARGUMENTOS;;;;;;;;;;;;;;;;
	;(brkstep '("bb0" "ppz0" "cx" "(length bb0)") "00" "CORDEN")
	(cond
		(
			(and
				(not (= bb0 nil))
				(not (= ppz0 nil))
			)
			(setq coprevar (getvar "luprec"))
			(setvar "luprec" 8)
			(setq bb1 bb0)
			(setq ppz ppz0)
			(cond
				((= ppz 0) (setq ppredis 1))
				((= ppz 1)(setq ppredis 0.15))
				((= ppz 2)(setq ppredis 0.015))
				((= ppz 3)(setq ppredis 0.0015))
				((= ppz 4)(setq ppredis 0.00015))
				((= ppz 5)(setq ppredis 0.000015))
				((= ppz 6)(setq ppredis 0.0000015))
				((= ppz 7)(setq ppredis 0.0000002))
				((= ppz 8)(setq ppredis 0.00000002))
			)
			;(brkstep '("bb1" "(length bb1)") "01" "CORDEN")
			;(xdat2 bb1 "," 8)
			(setq con101 0)
			(while
				(< con101 (length bb1))
				(setq frstls (nth con101 bb1))
				(setq indipen (nthx '(0 0) bb1))
				(setq part1
					(list
						(nth 0 frstls)
						(nth 1 frstls)
						(nth 2 frstls)
					)
				)
				(setq part2
					(nth 0
						(mat5a (list frstls) 3 1)
					)
				)
				;(brkstep '("frstls" "indipen" "part1" "part2" "cx") "02" "CORDEN")
				(cond
					(
						(and (equal cx 0 ppredis) (equal indipen "nop"))
						(setq part2 (orden4 part2 0 1 ppz))
						(setq listpos '(3 1)
							ordenf 0
						)
					)
					(
						(and (equal cx 1 ppredis) (equal indipen "nop"))
						(setq part2 (orden4 part2 0 2 ppz))
						(setq listpos '(3 2)
							ordenf 0
						)
					)
					(
						(and (equal cx 0 ppredis) (< indipen 0))
						(setq part2 (orden4 part2 1 0 ppz))
						(setq listpos '(3 0)
							ordenf 1
						)
					)
					(
						(and (equal cx 1 ppredis) (< indipen 0))
						(setq part2 (orden4 part2 1 1 ppz))
						(setq listpos '(3 1)
							ordenf 1
						)
					)
					(
						(and (equal cx 0 ppredis) (< 0 indipen))
						(setq part2 (orden4 part2 0 0 ppz))
						(setq listpos '(3 0)
							ordenf 0
						)
					)
					(
						(and (equal cx 1 ppredis) (< 0 indipen))
						(setq part2 (orden4 part2 0 1 ppz))
						(setq listpos '(3 1)
							ordenf 0
						)
					)
					(
						(and (equal cx 0 ppredis) (equal indipen 0 ppredis))
						(setq part2 (orden4 part2 0 0 ppz))
						(setq listpos '(3 0)
							ordenf  0
						)
					)
					(
						(and (equal cx 1 ppredis) (equal indipen 0 ppredis))
						(setq part2 (orden4 part2 0 1 ppz))
						(setq listpos '(3 1)
							ordenf 0
						)
					)
				)
				;(brkstep '("part1" "part2" "(append part1 part2)") "03" "CORDEN")
				(setq frstls (append part1 part2))
				(setq final0 (append final0 (list frstls)))
				(setq con101 (+ con101 1))
				;(brkstep '("frstls" "final0" "(length final0)" "con101") "04" "CORDEN")
			)
			;(brkstep '("final0" "(length final0)" "frstls") "04a" "CORDEN")
			(cond
				(
					(equal indipen "nop")
					(setq final0 (orden4 final0 0 1 ppz))
				)
				(
					(< indipen 0)
					(setq final0 (orden4 final0 0 1 ppz))
				)
				(
					(< 0 indipen)
					(setq final0 (orden4 final0 0 1 ppz))
				)
				(
					(equal indipen 0 ppredis)
					(setq final0 (orden4 final0 0 1 ppz))
				)
			)
			;(brkstep '("final0" "(length final0)") "05" "CORDEN")
			(setq final1 (agru2 final0 () 1 ppredis))
			;(brkstep '("final1" "(length final1)") "06" "CORDEN")
			;(xdat2 final1 "," 4)
			(setq con101 0)
			(while
				(< con101 (length final1))
				(setq final2 (nth con101 final1))
				;(brkstep '("final2") "07" "CORDEN")
				(setq final2 (orden5 final2 ordenf listpos ppz))
				;(brkstep '("final2") "08" "CORDEN")
				(setq final3 (append final3 final2))
				;(brkstep '("final3") "09" "CORDEN")
				(setq con101 (+ con101 1))
			)
			;(brkstep '("final3" "(length final3)") "10" "CORDEN")
			(setvar "luprec" coprevar)
		)
	)
	(setq final3 final3)
)
;;PROYECTO: Lisp
;;CLASIFICACION:TXT
;;OBJETO / TITULO:QuiTx. Elimina el caracter indicado en una cadena de texto
;;DESCRIPCION:
;;	>QuiTx. Apartir de la definicion de un caracter los elimina de
;;	una cadena de texto tambien definida en argumento.
;;DEVUELVE:
;;	> quTxFn. Misma cadena de texto pero sin los caracteres
;;	que correspondan al caracter definido en el argumento o nil
;;	si toda la cadena contiene el caracter.
;;	<STR / nil >
;;ARGUMENTOS
;;	1.quTxNo0. Caracter para eliminar de la cadena de texto
;;	> <STR>
;;	2.quTxWk0. Cadena de texto 
;; > <STR>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> para los tabs el caracter es "\t"
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun QuiTx
	(quTxNo0  quTxWk0 /
		quTxNo quTxWk quCon1 quPas quTxFn
	)
	;(setq quTxNo nil quTxWk nil quCon1 nil
	;	quPas nil quTxFn nil
	;)
	;(brkstep1 '("quTxNo0" "quTxWk0") (list quTxNo0 quTxWk0) "00" "QuiTx")
	(cond
		(
			(and (= (type quTxNo0) 'STR)
				(= (type quTxWk0) 'STR)
			)
			(setq quTxNo quTxNo0
				quTxWk quTxWk0
			)
			;(brkstep1 '("quTxNo" "quTxWk") (list quTxNo quTxWk) "01" "QuiTx")
			(setq quCon1 1)
			(setq quPas 1)
			(while
				(and (= quPas 1)
					(<= quCon1 (strlen quTxWk))
				)
				;(brkstep1 '("quTxNo" "(substr quTxWk quCon1 1)")
				;	(list quTxNo (substr quTxWk quCon1 1))
				;	"02" "QuiTx"
				;)
				(cond
					(
						(not
							(= (substr quTxWk quCon1 1)
								quTxNo
							)
						)
						(setq quTxFn
							(substr quTxWk quCon1 1)
							quPas 0
						)
					)
				)
				(setq quCon1 (+ quCon1 1))
			)
			(while (<= quCon1 (strlen quTxWk))
				(cond
					(
						(not (= (substr quTxWk quCon1 1) quTxNo))
						(setq quTxFn (strcat quTxFn (substr quTxWk quCon1 1)))
					)
				)
				(setq quCon1 (+ quCon1 1))
			)
		)
	)
	(setq quTxFn quTxFn)
)
;;PROYECTO: Lisp
;;CLASIFICACION: Manipulacion de listas (TXT)
;;TITULO: CodOrd. Apartir de la lista de pares punteado y una lista
;;	de los mismos codigos (lista sencilla de codigos sin valores),
;;	reordena la lista de pares punteados de acuerdo a la lista de codigos
;;ARGUMENTOS:
;;	1. coLsPar0: Lista de pares punteados.
;;	((xx.xx)...) 
;;	2. coLsCod0: Lista de codigos
;;	(x ...)
;;DEVUELVE:
;;	coLsFin. Misma lista de pares punteados ordenada de acuerdo a los codigos
;;	definidos en la lista de codigos.
(defun CodOrd
	(coLsPar0 coLsCod0 /
		coLsPar coLsCod coCon1 coCon2 coCodWk coLsFin
	)
;	(setq coLsPar nil coLsCod nil coCon1 nil coCon2 nil coCodWk nil coLsFin nil)
	;;
;	(brkstep1 '("coLsPar0" "coLsCod0") (list coLsPar0 coLsCod0) "00" "CodOrd")
	;;
	(cond
		(
			(and (= (LsType coLsPar0) 'LIST)
				(= (LsType coLsCod0) "NUM")
			)
			(setq coLsPar coLsPar0 coLsCod coLsCod0)
			(setq coCon1 0)
			(while (< coCon1 (length coLsCod0))
				(setq coCon2 0
					coCodWk (nth coCon1 coLsCod)
				)
				;;
;				(brkstep1 '("coCodWk" "coLsPar") (list coCodWk coLsPar) "01" "CodOrd")
				;;
				(while (< coCon2 (length coLsPar))
					;;
;					(brkstep1 '("coCon2" "coLsPar") (list coCon2 coLsPar) "02" "CodOrd")
					;;
					(cond
						(
							(= (car (nth coCon2 coLsPar)) coCodWk)
							;;
;							(brkstep1
;								'("coLsFin" "(nth coCon2 coLsPar)" "(lsno coLsPar coCon2")
;								(list coLsFin (nth coCon2 coLsPar) (lsno coLsPar coCon2))
;								"03" "CodOrd"
;							)
							;;
							(setq coLsFin
								(append coLsFin (list (nth coCon2 coLsPar)))
							)
							(setq coLsPar (lsno coLsPar coCon2))
						)
						(
							(not (= (car (nth coCon2 coLsPar) )coCodWk))
							;;
;							(brkstep1 '("coCon2") (list coCon2) "04" "CodOrd")
							;;
							(setq coCon2 (+ coCon2 1))
						)
					)
				)
				(setq coCon1 (+ coCon1 1))
			)
			;;
;			(brkstep1 '("coLsPar" "coLsFin" "(length coLsPar)")
;				(list coLsPar coLsFin (length coLsPar))
;				"05" "CodOrd"
;			)
			;;
			(cond
				(
					(< 0 (length coLsPar))
					(setq coLsFin (append  coLsFin coLsPar))
				)
			)
		)
	)
	(setq coLsFin coLsFin)
)
;;PROYECTO: Lisp
;;CLASIFICACION: COO
;;OBJETO: FINDCO
;;	> Encuentra los segmentos que coincidan con la coordenada indicada
;;	a partir de una lista de segmentos que contenga xy de los dos puntos
;;	( ((x1 y1) XXXX (x2 y2) XXX) (...) ...)
;;DEVUELVE:
;;	> Los segmento que coincidan con la coordenada (XY) o nil si el punto no se
;;	encuentra en la lista de coordenadas.
;;ARGUMENTOS
;;	1.LBC: Lista de coordenadas
;;	> ( (?? (X1 Y1) ??? ??? (X2 Y2)??) ... (...) )
;;	2.CBC: Coordenada
;;	> (x y)
;; 3. LPSO: Lista de posiciones (nth) donde se encuentran las coordenadas
;; (X1 Y1) y (X2 Y2)
;;DEPENDIENTES
;;	> LNPO
;;ANOTACIONES
;;	> Si la coordenada (cbc) entra con (XYZ) la cambia a (XY)
;;
(defun findco (lbc cbc lpso / mico1 mipos con lsfinal)
	(cond
		(
			(= (length cbc) 3)
			(setq cbc
				(list
					(nth 0 cbc)
					(nth 1 cbc)
				)
			)
		)
	)
	(setq con 0
		lsfinal '()
	)
	(while
		(< con (length lpso))
		(setq mico1 (lnpo cbc lbc (nth con lpso) 1))
		(cond
			(
				(not (= mico1 nil))
				(setq lsfinal
					(append lsfinal (list mico1))
				)
			)
		)
		(setq con (+ con 1))
	)
	(setq lsfinal lsfinal)
)
;;PROYECTO: Lisp
;;CLASIFICACION: DLG (Ejecutable de cuadro de dialogo)
;;OBJETO: TTB: Ejecucion del cuadro de dialogo del cuadro de dialogo 
;;	de creacion de tableros
;;	>  Nombre del dialogo: tablero
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	> PASVAL(); PASVAL1 (); LISCAJA ()
;;	RENOM0 (); BORRTAB (); MIRA1 (); MIRA2 () CILCO
;;ANOTACIONES
;;	> paction pval
;;;(brkstep '("") "001TEMP" "")
;;
(defun c:ttb
	( / mdcl nomustab opendial
		miarch flag midial
		dcl_id mipoli
		pp1 pp7 pas
		sal v1 nomac
		nomnv melref
		mmll hdlt 
		colatt w h rfpl
		nn1 mmll
		mmll0 mmll1 mmll2 
		mmll3 mmll4 mmll5
		mmll6 val2 why2 
		val3 why3 val4  why4 
		val9  why9 val10 why10 
		val11 why11 val12 why12 
		val13 why13 valtab0a 
		valtab0b ssval hdd
		colatt pascolor
		valp1 paspend
		passis nome2
		pashd
	)
	;;Variables temporales (0)******
	(setq lsustab nil
		valtab nil
		valtab1 nil
		valtab0 nil
	)
	;;Variables temporales (1)******
	;;Variables locales (1)*********
	;;******************************
	;;RUTA de archivos (0)*******************
	(setq miarch 
		(strcat
			(obten "rutas.csv" "DCL_LISP" "RUTA")
			"DCL_TTB.dcl"
		)
		midial "tablero"
		mdcl
		(strcat
			(obten "rutas.csv" "DCL_LISP" "RUTA")
			"DCL_OBJETOS.lsp"
		)
	)
	;;RUTA de archivos (1)*******************
	;(brkstep '("miarch" "midial" "mdcl") "01" "ttb")
	(load mdcl)
	;;Carga de archivo (1)*******************
	;;Definicion de tableros existentes (0)***
	(actual)
	(if
		(qcodls "nvtablero" 1005)
		(setq lsustab (qcodls "nvtablero" 1005))
		;(setq lsustab (list "Nombre Tablero"))
	)
	(setq lsustab lsustab)
	;;Definicion de tableros existentes (1)***
	;;Definicion de variables publicas = nil******(0)
	(setq pval nil)
	(setq paction nil)
	;;Definicion de variables publicas = nil******(1)
	;(brkstep '("pval" "paction") "00" "TTB")
	;;Carga dialogo y flag (0)****************
	(setq flag 4)
	(setq dcl_id  (load_dialog miarch))
	;;Carga dialogo y flag (1)****************
	(while
		(> flag 2)
		;;Abre dialogo (0)*********************
		(if 
			(not (new_dialog midial dcl_id))
			(exit)
		)
		;;Abre dialogo (1)*********************
		;;Definicion de controles iniciales(0)**
		(mode_tile "renombre" 1)
		(mode_tile "ver" 1)
		(mode_tile "elimina" 1)
		(liscaja "existentes" lsustab)
		(cond
			(
				(= paction nil)
				(mode_tile "9" 1)
				(mode_tile "10" 1)
				(mode_tile "13" 1)
			)
		)
		(cond
			(
				(not (= valp1 nil))
				(set_tile "8" valp1)
			)
		)
		(cond
			(
				(not (= rfpl nil))
				(set_tile "12" rfpl)
			)
		)
		(cond
			(
				(= ssval "0")
				(set_tile "2" "1")
			)
			(
				(= ssval "1")
				(set_tile "3" "1")
			)
			(
				(= ssval "2")
				(set_tile "4" "1")
			)
			(
				(or 
					(= ssval "-")
					(= ssval nil)
				)
				(set_tile "2" "0")
				(set_tile "3" "0")
				(set_tile "4" "0")
			)
		)
		(cond
			(
				(= hdd "0")
				(set_tile "10" "1")
			)
			(
				(= hdd "1")
				(set_tile "9" "1")
			)
		)
		(cond
			(
				(not (= paction nil))
				(set_tile "existentes" pval)
				(setq valtab0 (pasval0 pval lsustab))
				;;VALTAB0: ValorLista
				(setq valtab (xrorig "nvtablero" valtab0 1005))
				;;VALTAB: Handlet
				(setq valtab1
					(extraxr
						(nthx '(0 1) (lb217 (list valtab)))
						"XD_NOVIDESA"
					)
				)
				;;VALTAB1:XD elemento( (NomAtt ValAtt) (...) ...)
				(set_tile "nombrenvo"  valtab0)
				(cond
					(
						(= passis 0)
						(setq ssval (valatt "SISTEMA" valtab1))
						(cond
							(
								(= ssval  "0")
								(set_tile "2" "1")
							)
							(
								(= ssval "1")
								(set_tile "3" "1")
							)
							(
								(= ssval "2")
								(set_tile "4" "1")
							)
							(
								(or 
									(= ssval "-")
									(= ssval nil)
								)
								(set_tile "2" "0")
								(set_tile "3" "0")
								(set_tile "4" "0")
							)
						)
					)
				)
				(cond
					(
						(= pashd 0)
						(setq hdd (valatt "OCULTO" valtab1))
						(cond
							(
								(= hdd "1")
								(set_tile "9" "1")
							)
							(
								(= hdd "0")
								(set_tile "10" "1")
							)
							(	
								(or
									(= hdd "-")
									(= hdd "")
									(= hdd " ")
									(= hdd nil)
								)
								(set_tile "9" "0")
								(set_tile "10" "0")
							)
						)
					)
				)
				(cond 
					(
						(not (= pascolor 1))
						(setq colatt (valatt "COLOR" valtab1))
					)
					(
						(= pascolor 1)
						(setq colatt (itoa colatt))
					)
				)
				(cond
					(
						(not (= colatt "-"))
						(setq colatt (atoi colatt))
					)
					(
						(= colatt "-")
						(setq colatt 
							(getcolor  lsustab pval "nvtablero")
						)
					)
				)
				(setq w (dimx_tile "6")
					h (dimy_tile "6")
				)
				(start_image "6")
				(fill_image 0 0 w h colatt)
				(end_image)
				(cond
					(
						(= paspend 0)
						(setq valp1 (valatt "PEND" valtab1))
						(cond
							(
								(not (= valp1 "-"))
								(set_tile "8" valp1)
							)
							(
								(= valp1 "-")
								(set_tile "8" "-")
							)
						)
					)
				)
				(cond
					(
						(= pasref 0)
						(setq rfpl (valatt "IDREFPL" valtab1))
						(cond
							(
								(not (= rfpl "-"))
								(set_tile "12" rfpl)
							)
						)
					)
				)
			)
		)
		;;*******************************************
		;;action_tile OK*******
		(action_tile "accept"
			"(done_dialog)
			(setq salida (pasval1 paction pval lsustab))"
		)
		;;action_tile OK*******
		;;**********************************************
		;;action_tile edit_box = Seleccion de lista ("existentes")
		(action_tile "existentes"
			"(setq paction $reason)
			(setq pval $value)
			(setq valtab0 (pasval0 pval lsustab))
			(setq valtab (xrorig \"nvtablero\" valtab0 1005))
			(setq nome2 (nthx '(0 1) (lb217 (list valtab))))
			(pasval paction pval lsustab \"nombrenvo\")
			(setq valtab1
				(actls paction pval lsustab \"nvtablero\" 1005)
			)
			(cond
				(
					(= valtab1 nil)
					(admod nome2 valtab0)
					(setq valtab1
						(actls paction pval lsustab \"nvtablero\" 1005)
					)
				)
			)
			(setq paspend 0)
			(setq pascolor 0)
			(setq pasref 0)
			(setq passis 0)
			(setq pashd 0)
			(mode_tile \"9\" 0)
			(mode_tile \"10\" 0)
			(mode_tile \"13\" 0)
			(setq colatt (valatt \"COLOR\" valtab1))
			(cond
				(
					(not (= colatt \"-\"))
					(setq colatt (atoi colatt))
				)
				(
					(= colatt \"-\")
					(setq colatt
						(getcolor lsustab pval \"nvtablero\")
					)
				)
			)
			(cond
				(
					(not (= colatt \"-\"))
					(setq w (dimx_tile \"6\")
						h (dimy_tile \"6\")
					)
					(start_image \"6\")
					(fill_image 0 0 w h colatt)
					(end_image)
				)
			)
			(setq valp1 (valatt \"PEND\" valtab1))
			(cond
				(
					(= paspend 0)
					(cond
						(
							(not (= valp1 \"-\"))
							(set_tile \"8\" valp1)
						)
						(
							(= valp1 \"-\")
							(set_tile \"8\" \"-\")
						)
					)
				)
			)
			(setq rfpl (valatt \"IDREFPL\" valtab1))
			(cond
				(
					(= pasref 0)
					(cond
						(
							(not (= rfpl \"-\"))
							(set_tile \"12\" rfpl)
						)
						(
							(= rfpl \"-\")
							(set_tile \"12\" \"-\")
						)
					)
				)
			)
			(cond
				(
					(= passis 0)
					(setq ssval (valatt \"SISTEMA\" valtab1))
					(cond
						(
							(= ssval  \"0\")
							(set_tile \"2\" \"1\")
						)
						(
							(= ssval \"1\")
							(set_tile \"3\" \"1\")
						)
						(
							(= ssval \"2\")
							(set_tile \"4\" \"1\")
						)
						(
							(or 
								(= ssval \"-\")
								(= ssval nil)
							)
							(set_tile \"2\" \"0\")
							(set_tile \"3\" \"0\")
							(set_tile \"4\" \"0\")
						)	
					)
				)
			)
			(cond
				(
					(= pashd 0)
					(setq hdd (valatt \"OCULTO\" valtab1))
					(cond
						(
							(or
								(= hdd \"-\")
								(= hdd \"\")
								(= hdd \"1\")
							)
							(setq hdd \"1\")
							(set_tile \"9\" \"1\")
						)
						(
							(= hdd \"0\")
							(set_tile \"10\" \"1\")
						)
					)
				)
			)
			"
		)
		;;action_tile edit_box = Seleccion de lista ("existentes")
		;;********************************************
		;;action_tile renombre
		(action_tile "renombre"
			"(setq vjoval (pasval1 paction pval lsustab))
			(setq nomnv (get_tile \"nombrenvo\"))
			(setq pas 2)
			(done_dialog 4)
			"
		)
		;;action_tile renombre
		;(setq flag (start_dialog))
		;;********************************************
		;;action_tile Agrega
		(action_tile "agrega" "(setq pas 1) (done_dialog 4)")
		;;action_tile Agrega
		;;********************************************
		;;action_tile elimina
		(action_tile "elimina" 
			"(setq vjoval (pasval1 paction pval lsustab))
			(setq pas 3)
			(done_dialog 4)"
		)
		;;action_tile elimina
		;;***************************************
		;;action_tile ver (0)
		(action_tile "ver"
			"(setq vjoval (pasval1 paction pval lsustab))
			(setq pas 4)
			(done_dialog 4)"
		)
		;;action_tile ver (1)
		;;**************************************
		;;action_tile "nombrenvo" (0)
		;;action_tile "nombrenvo" (1)
		;;;*************************************
		;; "2" "IKOS" (0)
		(action_tile "2"
			"(setq val2 $value)
			(setq why2 $reason)
			(setq ssval \"0\")
			(setq passis 1)"
		)
		;; "2" "IKOS" (1)
		;;;*************************************
		;; "3" "MAKROS" (0)
		(action_tile "3"
			"(setq val3 $value)
			(setq why3 $reason)
			(setq ssval \"1\")
			(setq passis 1)"
		)
		;; "3" "MAKROS" (1)
		;;;*************************************
		;; "4" "HOLMAK" (0)
		(action_tile "4"
			"(setq val4 $value)
			(setq why4 $reason)
			(setq ssval \"2\")
			(setq passis 1)"
		)
		;; "4" "HOLMAK" (1)
		;;;**************************************
		;; "9" "MUESTRA POLIGONAL" (0)
		(action_tile "9"
			"(setq hdd \"1\")
			(setq val9 $value)
			(setq why9 $reason)
			(setq pashd 1)"
		)
		;; "9" "MUESTRA POLIGONAL" (1)
		;;;**************************************
		;; "10" "OCULTA POLIGONAL" (0)
		(action_tile "10"
			"(setq hdd \"0\")
			(setq val10 $value)
			(setq why10 $reason)
			(setq pashd 1)"
		)
		;; "10" "OCULTA POLIGONAL" (1)
		;;;**************************************
		;;	"5" "COLOR" (0)
		(action_tile "5"
			"(setq val5 $value)
			(setq why5 $reason)
			(setq pas \"color\")
			(done_dialog 4)"
		)
		;; "5" "COLOR" (1)
		;;;****************************************
		;;	"7" "PENDIENTE" (0)
		(action_tile "7"
			"(setq val7 $value)
			(setq why7 $reason)
			(setq pas \"pend1\")
			(done_dialog 4)"
		)
		;;	"7" "PENDIENTE" (1)
		;;;****************************************
		;;	"8" "PENDIENTE BOX" (0)
		(action_tile "8"
			"(setq val8 $value)
			(setq why8 $reason)"
		)
		;;	"8" "PENDIENTE BOX" (1)
		;;;****************************************
		;;	"11" "REFERENCIA A PLANTA" (0)
		(action_tile
			"11"
			"(setq why11 $reason)
			(setq val11 $value)
			(setq pas \"ref\")
			(done_dialog 4)"
		)
		;;	"11" "REFERENCIA A PLANTA" (1)
		;;;****************************************
		;; "12" "REFERENCIA A PLANTA BOX" (0)
		(action_tile "12"
			"(setq val12 $value)
			(setq why12 $reason)"
		)
		;;	"12" "REFERENCIA A PLANTA BOX" (1)
		;;;****************************************
		;;	"13" "MODIFICACION" (0)
		(action_tile "13"
			"(setq val13 $value)
			(setq why13 $reason)
			(setq pas \"mod\")
			(done_dialog 4)"
		)
		;;	"13" "MODIFICACION" (1)
		;;;****************************************
		(setq flag (start_dialog))
		(cond
			(
				(and (= flag 4) (= pas 1))
				(setq pp1 0
					pas 0
				)
				(setq mipoli
					(ssget '((0 . "LWPOLYLINE")))
				)
				(cond
					(
						(not (= mipoli nil))
						(setq pp1 1
							mipoli (nth 0 (noment mipoli))
						)
						(nuvitab mipoli "nvtablero" 1005)
						(setq lsustab (renom0 "nvtablero"))
						(setq valtab1 (qcodls0 "nvtablero" 1005)
							hdlt
							(cdr (assoc 5 (entget mipoli)))
							valtab0
							(lnpo hdlt valtab1 0 1)
							valtab0
							(nthx '(0 1) valtab0)
						)
						(admod mipoli valtab0)
					)
				)
			)
			(
				(and (= flag 4) (= pas 2))
				(setq pas 0)
				(renom vjoval nomnv "nvtablero" 1005)
				(setq lsustab (renom0 "nvtablero"))
			)
			(
				(and (= flag 4) (= pas 3))
				(setq pas 0)
				(borrtab "nvtablero" vjoval)
				(setq lsustab (renom0 "nvtablero"))
				(liscaja "existentes" lsustab)
				(setq paction nil
					pval nil)
			)
			(
				(and (= flag 4) (= pas 4))
				(setq pas 0)
				(camb
					(list
						(nthx ' (0 1)
							(lb217
								(list (xrorig "nvtablero" vjoval 1005))
							)
						)
					)
					1
				)
				(ciclo "nvtablero" vjoval 1005)
				(cond
					(
						(= hdd "0")
						(camb
							(list
								(nthx '(0 1)
									(lb217
										(list
											(xrorig
												"nvtablero"
												vjoval
												1005
											)
										)
									)
								)
							)
							2
						)
					)
				)
			)
			(
				(and (= flag 4) (= pas "color"))
				(setq pas 0)
				(setq pascolor 1)
				(setq colatt (clr))
				(cond
					(
						(not (= colatt nil))
						(setq w (dimx_tile "6")
							h (dimy_tile "6")
						)
						(start_image "6")
						(fill_image 0 0 w h colatt)
						(end_image)
					)
				)
			)
			(
				(and (= flag 4) (= pas "pend1"))
				(setq pas 0
					paspend 1
				)
				(setq valp1 (pasval2 why7 "8"))
				(action_tile "8"
					"(set_tile \"8\" valp1)"
				)
			)
			(
				(and (= flag 4) (= pas "ref"))
				(setq pasref 1)
				(setq rfpl (refhd "12"))
			)
			(
				(and
					(= flag 4)
					(= pas "mod")
					(not (= nome2 nil))
				)
				(setq pas 0)
				(admod nome2 valtab0)
				(cond
					(
						(not (= colatt nil))
						(cam1 (list nome2) (cons 62 colatt))
					)
				)
				(cond
					(
						(= hdd "0")
						(camb (list nome2) 2)
					)
					(
						(= hdd "1")
						(camb (list nome2) 1)
					)
				)
			)
		)
	)
	(unload_dialog dcl_id)
	(princ)
)
;;PROYECTO: Lisp
;;CLASIFICACION: TRZ
;;OBJETO: DIVMU. Divide una recta (dadas sus coordenadas) en tramos iguales
;;		a una distancia definida en el argumento con opcion de ajuste al centro
;;		de la linea o en algun extremo de la misma. Se considera un ajuste minimo
;;		que si se exede toma otro tramo para dividir el ajuste entre dos piezas.
;;	>	((XYZ) DIST) (...) ...)
;;DEVUELVE:
;;	> Lista inicial de y distancia de cada tramo.
;;ARGUMENTOS
;;	1.PTO1. Primera coordenada
;;	> (XYZ) o (XY)
;;	2.PTO2. Segunda coordenada
;;	> (XYZ) o (XY)
;;	3.DISI. Distancia de division
;;	> #.#
;;	4.MODI. Modo de distribucion
;;	> 0. Distribucion al centro
;;	> 1. Distribucion en el primer punto
;;	> 2. Distribucion en el segundo punto
;;	> 3. Distribucion sin ajuste
;;	5.PREZI. Precision numerica
;;	> ## Numero de decimales
;;	6.MINIDI. Distancia minima de division
;;	> #.#
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;DEVUELVE
;;	Lista de coordenadas
;;	>( (XY) (...) (...) )
(defun divmu
	     (pto1     pto2	disi	 modi	  prezi	   minidi
	      /	       disit	disie	 disif	  predi	   disim
	      lsdis    disie1	disie2	 disie0	  lscof	   conta
	      disim2   lsfin0	lsfin	 ptoq	  ele0	   osimod
	      osiprec  angil
	     )
					;(setq disit nil disie nil disif nil
					;	predi nil disim nil lsdis nil
					;	disie1 nil disie2 nil disie0 nil
					;	lscof nil conta nil disim2 nil lsfin0 nil
					;	lsfin nil ptoq nil ele0 nil osimod nil osiprec nil
					;	angil nil
					;)
					;(brkstep
					;	'("pto1" "pto2" "disi" "modi" "prezi" "minidi")
					;	"00" "DIVMU"
					;)
  (cond
    (
     (and
       (= (type pto1) 'LIST)
       (= (type pto2) 'LIST)
       (= (numberp disi) T)
       (= (type modi) 'INT)
       (= (type prezi) 'INT)
       (= (numberp minidi) T)
     )
     (setq osimod (getvar "osmode"))
     (setq osiprec (getvar "luprec"))
     (setvar "luprec" 8)
     (setvar "osmode" 0)
     (setq angil (angle pto1 pto2))
     (cond
       ((= prezi 1) (setq predi 0.1))
       ((= prezi 2) (setq predi 0.01))
       ((= prezi 3) (setq predi 0.001))
       ((= prezi 4) (setq predi 0.0001))
       ((= prezi 5) (setq predi 0.00001))
       ((= prezi 6) (setq predi 0.000001))
       ((= prezi 7) (setq predi 0.0000002))
       ((= prezi 8) (setq predi 0.00000002))
     )
     (setq disit (round1 (distance pto1 pto2) prezi))
     (setq disie (round1 (/ disit disi) 0))
     (setq disif (round1 (* disie disi) prezi))
					;(brkstep
					;	'("disie" "disit" "disif" "disi" "(equal disif disit predi)")
					;	"01" "DIVMU"
					;)
     (cond
       (
	(Eq0 disif disit predi)
	(setq disim nil)
	(repeat	disie
	  (setq lsfin0 (append lsfin0 (list disi)))
	)
					;(brkstep '("lsfin0") "01a" "DIVMU")
       )
       (
	(< disit disif)
	(setq disie (- disie 1))
	(setq disif (* disie disi))
	(setq disim (- disit disif))
       )
       (
	(< disif disit)
	(setq disim (- disit disif))
       )
     )
					;(brkstep '("lsfin0" "disie" "disif" "disim" "minidi" "disit") "02" "DIVMU");;;;;;;;;;;;aqui
     (cond
       (
	(< disif disit)
	(if
	  (< disim minidi)
	   (progn
	     (setq disie (- disie 1))
	     (setq disim2 (round1 (/ (+ disi disim) 2) 4))
	     (setq disim
		    (list disim2 disim2)
	     )
	   )
	   (setq disim (list disim))
	)
					;(brkstep '("disie" "disim") "03" "DIVMU")
					;**DISIM (XX) O (XX XX)
	(cond
	  (
	   (= modi 0)
	   (setq disie1	(round1 (/ disie 2) 0)
		 disie2	(- disie disie1)
	   )
	   (setq lsfin0 nil)
					;(brkstep '("disie1" "disie2" "lsfin0") "03a" "DIVMU")
	   (setq lsfin0
		  (repeat disie1
		    (setq lsfin0 (append lsfin0 (list disi)))
		  )
	   )
					;(brkstep '("lsfin0") "03b" "DIVMU")
	   (setq lsfin0
		  (append
		    lsfin0
		    disim
		  )
	   )
					;(brkstep '("lsfin0" "disim") "03c" "DIVMU")
	   (setq lsfin0
		  (repeat disie2
		    (setq lsfin0 (append lsfin0 (list disi)))
		  )
	   )
					;(brkstep '("lsfin0") "03A" "DIVMU")
	  )
	  (
	   (= modi 1)
	   (setq lsfin0 disim)
	   (repeat disie
	     (setq lsfin0
		    (append lsfin0 (list disi))
	     )
	   )
					;(brkstep '("lsfin0") "03B" "DIVMU")
	  )
	  (
	   (= modi 2)
	   (setq lsfin0 nil)
	   (repeat disie
	     (setq lsfin0
		    (append lsfin0 (list disi))
	     )
	   )
	   (setq lsfin0
		  (append lsfin0 disim)
	   )
					;(brkstep '("lsfin0") "03C" "DIVMU")
	  )
	  (
	   (= modi 3)
	   (setq lsfin0 nil)
	   (repeat (+ disie 2);;;;;;;;SIN AJUSTE;;;;;;;;;;;;;;;
	     (setq lsfin0
		    (append lsfin0 (list disi))
	     )
	   )
					;(brkstep '("lsfin0") "03D" "DIVMU")
	  )
	)
       )
     )
					;(brkstep '("lsfin0") "04" "DIVMU")
     (setq ptoq pto1)
     (setq conta 0)
     (while
       (< conta (length lsfin0))
	(setq ele0 (list ptoq (nth conta lsfin0)))
	(setq lsfin (append lsfin (list ele0)))
	(setq ptoq (polar ptoq angil (nth conta lsfin0)))
	(setq conta (+ conta 1))
					;(brkstep '("ele0" "lsfin" "ptoq" "conta") "05" "DIVMU")
     )
     (setvar "luprec" osiprec)
     (setvar "osmode" osimod)
     (setq lsfin lsfin)
    )
  )
  (setq lsfin lsfin)
)
;;PROYECTO: Lisp
;;CLASIFICACION:BDATA
;;OBJETO:XIN2. Compara los atributos accesibles del layout (IDE_SALIDA.CSV)
;; y escribe los valores introducidos por el usuario
;; en la entidad definida con la siguiente
;;	estructura.
;;	>((x.x)(...)...(-3("MIAPP"(1000."Indice , Valor ")(...)...)))
;;DEVUELVE: 
;;	> 0. Si no se realizo la insercion de datos
;;		no encontro nombre de elemento
;;	> 1. Si se realizo la insersion de datos
;;		si encontro nombre de elemento
;;ARGUMENTOS
;;	1.MMIAP Nombre de la aplicacion
;;	> "XXX"
;;	2. MMIENTI: Nombre de la entidad
;;	ENAME
;;	3. ELENAM: Nombre de elemento de cuantificacion
;;	"XXX" (si el nombre de se omite se toma el nombre de la lista)
;;	4. LVATT: Lista de atributos y valores introducidos por el usuario.
;;	( ("atributo" "valor") (...) ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;; *1. El nombre de los atributos deben de coincidir con los nombres
;;	del archivo (layout)
;;	*2. El primer elemento de ambas listas (atributo y valor)
;; siempre sera el tipo de elemento de cuantificacion.
;;	*3. Los valores siempre se almacenan en cadenas de texto.
;; *4. Si se omite el nombre de elemento se toma el nombre de elemento 
;;	de la lista de atributos y valores introducidos por el usuario.
;;	*5. Si se omite la variable de lista de datos de la entidad
;;	se aplica "-"
;;	*6. La ubicacion del archivo LAYOUT de atributos se encuentra
;;	definido en el archivo de rutas.csv en el renglon (ID_BDATOS).
;;	*7. Toma el nombre del atributo del layout y el valor de los datos
;;	introducidos por el usuario, en caso de no encontrar el dato definido
;;	por el usuario, toma el valor actual de la entidad, y en el caso
;;	que tampoco exista en la entidad el valor es = "-".
;;;(brkstep '("") "001TEMP" "")
;; *8. Si la funcion devuelve nil, talvez no encontró el elemento registrado
;;	en la base de datos.
;;**********************************************************************
(defun xin2
	(mmiap0 mmienti0 elenam0 lvatt0 /
		obj1 attrib   mimi     insele	insele1	 lins	  con1
		elelo miatt	miattv	 miattvx  compro
		entidat mmiap mmienti elenam lvatt
	)
;	(setq mmiap nil mmienti nil elenam nil lvatt nil
;		obj1 nil attrib nil mimi nil insele nil insele1 nil lins nil con1 nil
;		elelo nil miatt nil 	miattv nil miattvx nil compro nil entidat nil
;	)
;	(brkstep1
;		'("mmiap0" "mmienti0" "elenam0" "lvatt0" "(camb (list mmienti0) 3)")
;		(list mmiap0 mmienti0 elenam0 lvatt0 (camb (list mmienti0) 3))
;		"00" "XIN2"
;	)
	(cond
		(
			(and
				(= (type mmiap0) 'STR)
				(= (type mmienti0) 'ENAME)
				;(= (type elenam0) 'STR)
				(= (type lvatt0) 'LIST)
			)
			(setq mmiap mmiap0 mmienti mmienti0 elenam elenam0 lvatt lvatt0)
			(setq compro 0)
			;;
;			(brkstep1
;				'("mmiap" "mmienti" "lvatt" "elenam" "(lnpo \"ELEMENTO\" lvatt 0 1)")
;				(list mmiap mmienti lvatt elenam (lnpo "ELEMENTO" lvatt 0 1))
;				"01" "XIN2"
;			)
			;;
			(if
				(not (tblsearch "APPID" mmiap))
				(regapp mmiap)
			);Crea aplicacion
			(cond
				(
					(and
						(= elenam nil)
						(not (= (lnpo "ELEMENTO" lvatt 0 1) nil))
					)
					(setq elenam
						(nth 1 (nth 0 (lnpo "ELEMENTO" lvatt 0 1)))
					)
					;;
;					(brkstep1
;						'("elenam") (list elenam) "01A" "XIN2"
;					)
					;;
				)
			)
			;;Definicion de nombre de elemento de la lista de
			;;		atributos introducida por el usuario (argumento)
			(setq entidat (extraxr mmienti mmiap))
			;;
;			(brkstep1
;				'("entidat" "elenam")
;				(list entidat elenam)
;				"03" "XIN2"
;			)
			;;
			;entidat. Atributos de la entidad (existentes)
			;elenam. Nombre de elemento a introducir
			(cond
				(
					(and
						(not (= entidat nil))
						(= elenam nil)
					)
					;; La entidad tiene datos
					;;	No esta definido el nombre del elemento
					;; 	ni en el argumento ni en la lista
;					(brkstep1
;						'("(lnpo \"ELEMENTO\" entidat 0 1)")
;						(list (lnpo "ELEMENTO" entidat 0 1))
;						"04" "XIN2"
;					)
					;;
					(cond
						(
							(not(= (lnpo "ELEMENTO" entidat 0 1) nil))
							(setq elenam
								(nth 1
									(nth 0 (lnpo "ELEMENTO" entidat 0 1))
								)
							)
							;;
;							(brkstep1
;								'("elenam")
;								(list elenam)
;								"05" "XIN2"
;							)
							;;
						)
					);Extraccion del nombre de elemento de Entidad
				)
			)
			;;
;			(brkstep1
;				'("elenam" "entidat")
;				(list elenam entidat)
;				"06" "XIN2"
;			)
			;;
			(cond
				(
					(not (= elenam nil))
					(setq con1 0)
					;;;;Importacion de atributos;;;;(0)
					(setq attrib
						(impdat "rutas.csv" "ID_BDATOS" "RUTA" "IDE_SALIDA.csv" ())
					)
					;;;;Importacion de atributos;;;;;(1)
					;;
;					(brkstep1 
;						'("attrib" "elenam" "(nthx (list 0 con1) attrib)"
;							"(lnpo elenam attrib 0 1)"
;						)
;						(list attrib elenam (nthx (list 0 con1) attrib)
;							(lnpo elenam attrib 0 1)
;						)
;						"07" "XIN2"
;					)
					(cond
						(;Verifica nombre de elemento coincidente con base de datos
							(not (= (lnpo elenam attrib 0 1) nil))
							(while (< con1 (length (nth 0 attrib)))
								;;
;								(brkstep1
;									'("(nthx (list 0 con1) attrib)"
;										"con1" "(length (nth 0 attrib))"
;									)
;									(list
;										(nthx (list 0 con1) attrib)
;										con1
;										(length (nth 0 attrib))
;									)
;									"08" "XIN2"
;								)
								;;Verificación si el nombre de elemento coincide
								;;		con la base de datos
								(setq	mimi
									(qnth2
										attrib
										elenam
										(nthx (list 0 con1) attrib)
										0.001
									)
								)
								;;
;								(brkstep1
;									'("mimi") (list mimi)
;									"09" "XIN2"
;								)
								;;
								(cond
									(
										(and
											(not (= (strcase mimi t) "no"))
											(not (= (strcase mimi t) "non"))
										)
										;;
;										(brkstep1
;											'("miatt" "con1" "lvatt" "entidat")
;											(list miatt con1 lvatt entidat) 
;											"10" "XIN2"
;										)
										;;
										(setq miatt (nthx (list 0 con1) attrib))
										;;
;										(brkstep1
;										'("miatt") (list miatt)
;											"11" "XIN2"
;										)
										;;
										(setq miattv (lnpo miatt lvatt 0 1))
										(setq miattvx (lnpo miatt entidat 0 1))
										;;
;										(brkstep1
;											'("miattv" "miattvx")
;											(list miattv miattvx)
;											"12" "XIN2"
;										)
										;;
										(cond
											(
												(not (= miattvx nil))
												(setq miattvx (nth 1 (nth 0 (lnpo miatt entidat 0 1))))
											)
										)
;										(brkstep1
;											'("miattv" "miattvx")
;											(list miattv miattvx)
;											"13" "XIN2"
;										)
										(cond
											(
												(not (= miattv nil))
												(setq miattv (nth 1 (nth 0 (lnpo miatt lvatt 0 1))))
												;;
;												(brkstep1
;													'("miattv") (list miattv)
;													"14" "XIN2"
;												)
												;;
											)
											(
												(and
													(= miattv nil)
													(not (= miattvx nil))
												)
												(setq miattv miattvx)
												;;
;												(brkstep1
;													'("miattv") (list miattv)
;													"15" "XIN2"
;												)
												;;
											)
											(
												(and
													(= miattv nil)
													(= miattvx nil)
												)
												(setq miattv "-")
;												(brkstep1
;													'("miattv") (liat miattv)
;													"16" "XIN2"
;												)
											)
										)
										;;
;										(brkstep1
;											'("miatt" "miattv") (list miatt miattv)
;											"17" "XIN2"
;										)
										;;
										(setq insele
											(cons 1000 (strcat miatt "," miattv))
										)
										(setq insele1
											(append insele1 (list insele))
										)
										;;
;										(brkstep1 '("insele" "insele1")
;											(list insele insele1)
;											"18" "XIN2"
;										)
										;;
									)	
								)
								(setq con1 (+ con1 1))
							)
							(cond
								(
									(not (= insele1 nil))
									(setq insele1
										(list -3
											(append
												(list mmiap)
												insele1
											)
										)
									)
									;;
;									(brkstep1 '("insele1") (list insele1) "19" "XIN2")
									;;
									(setq obj1
										(append (entget mmienti) (list insele1))
									)
									;;
;									(brkstep1 '("obj1") (list obj1) "20" "XIN2")
									;;
									(entmod obj1)
									(setq compro 1)
								)
							)
						)
					)
				)
			)
			(setq compro compro)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: TRZ
;;OBJETO: DIVMU1. Divide una recta (dadas sus coordenadas) en tramos iguales
;;		a una distancia definida en el argumento con opcion de ajuste al centro
;;		de la linea o en algun extremo de la misma. Se considera un ajuste minimo
;;		que si se exede toma otro tramo para dividir el ajuste entre dos piezas.
;;	>	((XYZ) DIST) (...) ...)
;;DEVUELVE:
;;	> Lista inicial de y distancia de cada tramo.
;;ARGUMENTOS
;;	1.PTO10. Primera coordenada
;;	> (XYZ) o (XY)
;;	2.PTO20. Segunda coordenada
;;	> (XYZ) o (XY)
;;	3.DISI0. Distancia de division
;;	> #.#
;;	4.MODI0. Modo de distribucion
;;	> 0. Distribucion al centro
;;	> 1. Distribucion en el primer punto
;;	> 2. Distribucion en el segundo punto
;;	> 3. Distribucion sin ajuste
;;	5.PREZI0. Precision numerica
;;	> ## Numero de decimales
;;	6.MINIDI0. Distancia minima de division
;;	> #.#
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Arreglo de DIVMU
;;;(brkstep '("") "001TEMP" "")
;;DEVUELVE
;;	Lista de coordenadas
;;	>( (XY) (...) (...) )
(defun divmu1
	(pto10 pto20 disi0 modi0 prezi0 minidi0 /
		pto1 pto2 disi modi prezi minidi
		disit disie disif predi disim lsdis
		disie1 disie2 disie0 lscof conta
		disim2 lsfin0 lsfin ptoq ele0 osimod
		osiprec angil
	)
;	(setq pto1 nil pto2 nil disi nil modi nil prezi nil minidi nil
;		disit nil disie nil disif nil
;		predi nil disim nil lsdis nil
;		disie1 nil disie2 nil disie0 nil
;		lscof nil conta nil disim2 nil lsfin0 nil
;		lsfin nil ptoq nil ele0 nil osimod nil osiprec nil
;		angil nil
;	)
	;;
;	(brkstep1
;		'("pto10" "pto20" "disi0" "modi0" "prezi0" "minidi0")
;		(list pto10 pto20 disi0 modi0 prezi0 minidi0)
;		"00" "DIVMU1"
;	)
	(cond
		(
			(and
				(= (LsType pto10) "NUM")
				(= (LsType pto20) "NUM")
				(= (numberp disi0) T)
				(= (type modi0) 'INT)
				(= (type prezi0) 'INT)
				(= (numberp minidi0) T)
			)
			(setq pto1 pto10
				pto2 pto20
				disi disi0
				modi modi0
				prezi prezi0
				minidi minidi0
			)
			(setq osimod (getvar "osmode"))
			(setq osiprec (getvar "luprec"))
			(setvar "luprec" 8)
			(setvar "osmode" 0)
			(cond
				(
					(=  prezi nil)
					(setq predi 0.00015)
				)
				(
					(< 0 prezi)
					(setq predi (expt 10.0 (* -1 prezi)))
				)
				(
					(= prezi 0)
					(setq predi 0.15)
				)
			)
			(setq angil (angle pto1 pto2))
			(setq disit (distance pto1 pto2))
			(setq disie (fix (/ disit disi)))
			(setq disif (* disie disi))
;			(brkstep1
;				'("disie" "disit" "disif" "disi" "(EqLs disif disit 0 predi)")
;				(list disie disit disif disi (EqLs disif disit 0 predi))
;				"01" "DIVMU1"
;			)
			(cond
				(
					(EqLs disif disit 0 predi)
					(setq disim nil)
					(repeat disie
						(setq lsfin0 (append lsfin0 (list disi)))
					)
;					(brkstep1 '("lsfin0") (list lsfin0) "01a" "DIVMU1")
				)
				(
					(< disit disif)
					(setq disie (- disie 1))
					(setq disif (* disie disi))
					(setq disim (- disit disif))
				)
				(
					(< disif disit)
					(setq disim (- disit disif))
				)
			)
;			(brkstep1
;				'("lsfin0" "disie" "disif" "disim" "minidi" "disit")
;				(list lsfin0 disie disif disim minidi disit)
;				"02" "DIVMU1"
;			)
			(cond
				(
					(and
						(not (= disim nil))
						(< disif disit)
					)
					(if
						(<= disim minidi)
						(progn
							(setq disie (- disie 1))
							(setq disim2 (/ (+ disi disim) 2))
							(setq disim
								(list disim2 disim2)
							)
						)
						(setq disim (list disim))
					)
;					(brkstep1 '("disie" "disim") (list disie disim) "03" "DIVMU")
					;**DISIM (XX) O (XX XX)
					(cond
						(
							(= modi 0)
							(setq disie1 (round (/ disie 2) 0)
									disie2	(- disie disie1)
							)
							(setq lsfin0 nil)
							;;
;							(brkstep1
;								'("disie1" "disie2" "lsfin0")
;								(list disie1 disie2 slfin0)
;								"03a" "DIVMU1"
;							)
							;;
							(setq lsfin0
								(repeat disie1
									(setq lsfin0 (append lsfin0 (list disi)))
								)
							)
							;;
;							(brkstep1 '("lsfin0") (list lsfin0) "03b" "DIVMU1")
							;;
							(setq lsfin0
								(append
									lsfin0
									disim
								)
							)
							;;
;							(brkstep1
;								'("lsfin0" "disim")
;								(list lsfin0 disim)
;								"03c" "DIVMU1"
;							)
							;;
							(setq lsfin0
								(repeat disie2
									(setq lsfin0 (append lsfin0 (list disi)))
								)
							)
							;;
;							(brkstep1 '("lsfin0") (list lsfin0) "03A" "DIVMU1")
							;;
						)
						(
							(= modi 1)
							(setq lsfin0 disim)
							(repeat disie
								(setq lsfin0
									(append lsfin0 (list disi))
								)
							)
							;;
;							(brkstep1 '("lsfin0") (list lsfin0) "03B" "DIVMU1")
							;;
						)
						(
							(= modi 2)
							(setq lsfin0 nil)
							(repeat disie
								(setq lsfin0
									(append lsfin0 (list disi))
								)
							)
							(setq lsfin0
								(append lsfin0 disim)
							)
							;;
;							(brkstep1 '("lsfin0") (list lsfin0) "03C" "DIVMU1")
							;;
						)
						(		
							(= modi 3)
							(setq lsfin0 nil)
							(repeat disie
								(setq lsfin0
									(append lsfin0 (list disi))
								)
							)
							;;
;							(brkstep1 '("lsfin0") (list lsfin0) "03D" "DIVMU1")
							;;
						)
					)
				)
			)
			;;
;			(brkstep1 '("lsfin0") (list lsfin0) "04" "DIVMU1")
			;;
			(setq ptoq pto1)	
			(setq conta 0)
			(while
				(< conta (length lsfin0))
				(setq ele0 (list ptoq (nth conta lsfin0)))
				(setq lsfin (append lsfin (list ele0)))
				(setq ptoq (polar ptoq angil (nth conta lsfin0)))
				(setq conta (+ conta 1))
				;;
;				(brkstep1
;					'("ele0" "lsfin" "ptoq" "conta")
;					(list ele0 lsfin ptoq conta)
;					"05" "DIVMU"
;				)
				;;
			)
			(setvar "luprec" osiprec)
			(setvar "osmode" osimod)
			(setq lsfin lsfin)
		)
	)
	(setq lsfin lsfin)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: TRZ
;;OBJETO / TITULO: GuiPan. Trazo de paneles
;;DESCRIPCION: GuiPan. Inserta en serie a lo largo de las lineas
;;		(definidas por la lista de nombre de entidades) el  block definido por
;;		el argumento.
;;DEVUELVE:
;;	> guiLsFin. Lista de nombre de entidades de blocks insertados.
;; <(ENAME ...)>
;;ARGUMENTOS
;;	1.guiSL0. Lista de nombre de entidades de lineas guia.
;;	<(ENAME ...)>
;; 2.guiPos0. Posicion de insercion de block
;; <"HORIZONTAL". Inserta el block con rotacion 0 con respecto a la linea guia
;;	"VERTICAL". Inserta el block girado 90 grados con respecto a la linea guia>
;; 3.guiMoDis0. Modo de distribucion del insercion de los blocks.
;; <"SIMPLE" Inserta los blocks sobre todas las guias.
;;	"ALTERNADO" Inseta los block alternando las guias (una si una no).
;; 4.guiDsH0. Distancia de insercion de blocks en sentido horizontal.
;; <#.## (insercion a 0 grados)>
;;	5.guiDsV0. Distancia de insercion de blocks en sentido vertical.
;; <#.## (insercion a 90 grados)>
;; 6.guiNomBL0. Nombre de block de insercion
;;	<"xxx">
;;	7.guiSep0. Distancia de separacion de insercion de blocks con respecto a la guia.
;; <#.##>
;; 8.guiNiv0. Niveles. <"xxx">
;;	9.guiColor0. Color. <## INT>
;;DEPENDIENTES
;;	>LsType (); orden4 (); DIVMU1 (); ONAM (); DTR2 (); XIN2 (); CORTXT ();
;;	NTHX ()
;;ANOTACIONES
;; > Presicion de comparacion decimal para la variable guiSep 0.0001
;;	> XD datos:
;;	> Nombre de aplicación "XD_NOVIDESA"
;;	> Nombre de elemento: "PL_Panel"
;;	> Ruta de acceso a blocks y archivo de atributos registrados dados
;;	> por funcion MRR4
;;	> XD atributos:
;;	> "ELEMENTO" "PL_Panel"
;;	> "TABLERO" "-"
;;	> "MATERIAL" "PL_panel"
;;	> "NIVELES" "1"
;;	> "COLOR" "8"
;;	> "LARGO" "1.00"
;;	> "ESPESOR" "0.27"
;;	> "OCULTOS" "1"
;;	> "ID" guiHand (handle de entidad)
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun GuiPan
	(guiSL0 guiPos0 guiMoDis0 guiDsH0 guiDsV0  guiNomBl0 guiSep0  guiNiv0 guiColor0 /
		guiSL guiPos guiMoDis  guiDsH guiDsV guiNomBl guiSep  guiNiv  guiColor
		guiNum guiCon1 guiCon2 guiCoo guiCoo1 guiEle guiAn
		guiAn90 guiLsWk guiModIns guiAnIns guiNomIns guiHand
		guiLsFin
	)
;;;;;;;;;;;;;;;;;;;
;	(setq guiSL nil guiPos nil guiMoDis nil guiDsH nil
;		guiDsV nil guiNomBl nil guiSep nil guiNiv nil guiColor nil
;		guiNum nil guiCon1 nil guiCon2 nil guiCoo nil guiCoo1 nil guiEle nil guiAn nil
;		guiAn90 nil guiLsWk nil guiModIns nil guiAnIns nil guiNomIns nil guiHand nil
;		guiLsFin nil
		
;	)
;;;;;;;;;;;;;;;;;;
;	(brkstep1
;		'("guiSL0" "guiPos0" "guiMoDis0" "guiDsH" "guiDsV" "guiNomBL0"
;		"guiSep0" "guiNiv0" "guiColor0"
;		)
;		(list guiSL0 guiPos0 guiMoDis0 guiDsH0 guiDsV0 guiNomBL0 guiSep0
;			guiNiv0 guiColor0
;		)
;		"00" "GuiPan"
;	)
;;;;;;;;;;;;;;;;;;
	(cond
		(
			(and (= (LsType guiSL0) 'ENAME)
				(= (type guiPos0) 'STR)
				(= (type guiMoDis0) 'STR)
				(= (numberp guiDsV0) T)
				(= (numberp guiDsH0) T)
				(= (type guiNomBL0) 'STR)
				(= (numberp guiSep0) T)
				(= (type guiNiv0) 'STR)
				(= (type guiColor0) 'INT)
			)
			(setq guiSL guiSL0
				guiPos guiPos0
				guiMoDis guiMoDis0
				guiDsV guiDsV0
				guiDsH guiDsH0
				guiNomBl guiNomBL0
				guiSep guiSep0
				guiNiv guiNiv0
				guiColor guiColor0
			)
			(setq guiLsWk (mat10 guiSL))
			;;
;			(brkstep1 '("guiLsWk") (list guiLsWk) "01" "GuiPan")
			;;
			(setq guiLsWk (nth 0 guiLsWk))
			(setq guiLsWk (orden4 guiLsWk 0 1 5))
			;;Orden de lista de menor a mayor por su ordenada al origen
;			(brkstep1 '("guiLsWk") (list guiLsWk) "02" "GuiPan")
			;;
			;guiLsWk. Lista de trabajo ordenada por su ordenada o abcisa
			;	al origen de menor a mayor
			;		<((p o i (xy) (xy)) ...)>
			(setq guiNum (length guiLsWk)
				guiRest (- guiNum (* (fix (/ guiNum 2)) 2))
			)
			(setq guiCon1 0)
			;guiNum. Numero de lineas (listas)
			;guiRest. Numero non o par
			;		<0 = par; 1 = non>
			(while (< guiCon1 guiNum)
				(setq guiEle (nth guiCon1 guiLsWk))
				(setq guiCoo (list (nth 3 guiEle) (nth 4 guiEle)))
				;;
;				(brkstep1 '("guiEle" "guiCoo") (list guiEle guiCoo) "03" "GuiPan")
				;;
				;;guiEle. Elemento (linea) <(poi (xy) (xy))>
				;;guiCoo. Lista de coordenadas (linea) ((xy) (xy))
				(cond
					(
						(= (nth 0 guiEle) "nop")
						(setq guiCoo (orden4 guiCoo 1 1 5)
							guiAn (angle (nth 0 guiCoo) (nth 1 guiCoo))
							guiAn90 0
						)
						;;
;						(brkstep1 '("guiCoo" "guiAn") (list guiCoo guiAn) "04A" "GuiPan")
						;; Pendiente indeterminada (90)
						;;guiCoo. Lista de coordenadas (ordenada de mayor a menor segun Y)
						;;		<((xy) (xy))>
						;;guiAn. Angulo de coordenadas (radianes) <xx.xx>
					)		
					(
						(= (nth 0 guiEle) 0)
						(setq guiCoo (orden4 guiCoo 0 0 5)
							guiAn 0.0
							guiAn90 (/ pi 2)
						)
						;; Pendiente = 0
;						(brkstep1 '("guiCoo" "guiAn") (list guiCoo guiAn) "04B" "GuiPan")
						;;
						;;guiCoo. Lista de coordenadas (ordenada de menor a mayor segun X)
						;;		<((xy) (xy))>
						;;guiAn. Angulo de coordenadas (radianes) <xx.xx>
					)
					(
						(< 0 (nth 0 guiEle))
						(setq guiCoo (orden4 guiCoo 0 0 5)
							guiAn (angle (nth 0 guiCoo) (nth 1 guiCoo))
							guiAn90 (sumang guiAn (/ pi 2))
						)
						;; Pendiente positiva
;						(brkstep1 '("guiCoo" "guiAn") (list guiCoo guiAn) "04C" "GuiPan")
						;;
						;;guiCoo. Lista de coordenadas (ordenada de menor a mayor segun X)
						;;		<((xy) (xy))>
						;;guiAn. Angulo de coordenadas (radianes) <xx.xx>
					)
					(
						(< (nth 0 guiEle) 0)
						(setq guiCoo (orden4 guiCoo 0 0 5)
							guiAn (angle (nth 0 guiCoo) (nth 1 guiCoo))
							guiAn90 (sumang guiAn (/ pi 2))
						)
						;; Pendiente negativa
;						(brkstep1 '("guiCoo" "guiAn") (list guiCoo guiAn) "03D" "GuiPan")
						;;
						;;guiCoo. Lista de coordenadas (ordenada de menor a mayor segun X)
						;;		<((xy) (xy))>
						;;guiAn. Angulo de coordenadas (radianes) <xx.xx>
					)
				)
				;; coordenadas linea de trazo (separacion)
				(cond
					(
						(< 0 guiSep)
						(setq guiCoo1
							(list (polar (nth 0 guiCoo) guiAn90 guiSep)
								(polar (nth 1 guiCoo) guiAn90 guiSep)
							)
						)
					)
					(
						(EqLs guiSep 0 0.0001)
						(setq guiCoo1
							(list (nth 0 guiCoo)
								(nth 1 guiCoo)
							)
						)
					)
				)
				(cond ;Ajuste de coordenadas para insercion vertical
					(
						(= guiPos "VERTICAL")
						(setq guiCoo1
							(list (polar (nth 0 guiCoo1) guiAn  guiDsV)
								(polar (nth 1 guiCoo1) guiAn guiDsV)
							)
						)
						(setq guiModIns (divmu1 (nth 0 guiCoo1) (nth 1 guiCoo1) guiDsV 2 7 0.000)
							guiAnIns guiAn90
						)
						;;
;						(brkstep1
;							'("guiCoo1" "guiModIns" "guiDsV")
;							(list guiCoo1 guiModIns guiDsV)
;							"04A" "GuiPan"
;						)
						;;
						;guiCoo1. Nuevas coordenadas de linea de trazo <((xy) (xy))>
						;guiModIns. Lista de coordenadas y distancias de insercion
						;		<((XYZ) DIST) (...) ...)>
					)
					(
						(= guiPos "HORIZONTAL")
						(setq guiModIns (divmu1 (nth 0 guiCoo1) (nth 1 guiCoo1) guiDsH 2 7 0.000)
							guiAnIns guiAn
						)
						;;
;						(brkstep1
;							'("guiCoo1" "guiModIns" "guiAn" "guiDsH")
;							(list guiCoo1 guiModIns guiAn guiDsH)
;							"04B" "GuiPan"
;						)
						;;
						;guiCoo1. Nuevas coordenadas de linea de trazo <((xy) (xy))>
						;guiModIns. Lista de coordenadas y distancias de insercion
						;	<((XYZ) DIST) (...) ...)>
						;guiAnIns. Angulo de insercion
					)
				)
				(setq guiCon2 0) ;Insercion de bloques
				(while (< guiCon2 (length guiModIns))
					(cond
						(
							(= (onam (list guiNomBl) "BLOCK" 0) nil)
							(setq guiNomIns guiNomBl)
							;;
;							(brkstep1
;								'("guiNomIns" "guiNomBl")
;								(list guiNomIns guiNomBl)
;								"05A" "GuiPan"
;							)
							;;
						)
						(
							(not (= (onam (list guiNomBl) "BLOCK" 0) nil))
							(setq guiNomIns
								(strcat
									(obten "rutas.csv" "BLOCKS" "RUTA")
									guiNomBl
									".dwg"
								)
							)
							;;
;							(brkstep1
;								'("guiNomIns" "guiNomBl")
;								(list guiNomIns guiNomBl)
;								"05B" "GuiPan"
;							)
							;;
						)
					)
					(command "insert" guiNomIns 
						(cortxt (nthx (list guiCon2 0) guiModIns))
						"1" "1" (dtr2 guiAnIns)
					)
					(setq guiLast (entlast)
						guiHand (cdr (assoc 5 (entget guiLast)))
						guiLsFin (append guiLsFin (list guiLast))
					)
					;;
;					(brkstep1 '("guiLast") (list guiLast) "06" "GuiPan")
					;;
					(xin2
						"XD_NOVIDESA" guiLast "PL_panel"
						(list
							(list "ELEMENTO" "PL_panel")
							(list "TABLERO" "-")
							(list "MATERIAL" "PL_panel")
							(list "NIVELES" guiNiv)
							(list "COLOR" (itoa guiColor))
							(list "LARGO" "1.00")
							(list "ESPESOR" "0.27")
							(list "OCULTOS" "1")
							(list "ID" guiHand)
						)
					)
					(cam1 (list guiLast) (cons 62 guiColor))
					(setq guiCon2 (+ guiCon2 1))
				)
				;;
;				(brkstep1 '("guiMoDis") (list guiMoDis) "07" "GuiPan")
				;;
				(cond
					(
						(= guiMoDis "ALTERNADO")
						(setq guiCon1 (+ guiCon1 2))
					)
					(
						(= guiMoDis "SIMPLE")
						(setq guiCon1 (+ guiCon1 1))
					)
				)
			)
		)
	)
	(setq guiLsFin guiLsFin)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:COO
;;OBJETO:PoliCoo. Define el par de coordenadas apartir de la seleccion de una poligonal
;;DEVUELVE: poCooFn. Lista de par de coordenadas de un lado del poligono seleccionado
;;	>((XYZ)(ZYZ))
;;ARGUMENTOS
;;	1.- poEname0. Nombre de entidad de polilinea
;;	> ENAME
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun PoliCoo
	       (poEname0 / poCon poCooFn poLsCo poPass poEname)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;(setq poCon nil poEname nil poCooFn nil poLsCo nil
					;	poPass nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;(brkstep '("poEname0") "00" "POLICOO")
  (cond
    (
     (= (type poEname0) 'ENAME)
     (setq poEname poEname0)
     (cond
       (
	(= (cdr (assoc 0 (entget poEname))) "LWPOLYLINE")
	(setq poLsCo
	       (mapcar 'cdr
		       (lscod poEname '(10))
	       )
	)
					;(brkstep '("poLsCo") "01" "POLICOO")
	(setq poLsCo (seg2v poLsCo))
					;(brkstep '("poLsCo") "02" "POLICOO")
	(setq poCon 0
	      poPass nil
	)
					;(brkstep '("poLsCo" "poCon" "poPass" "poEname") "03" "POLICOO")
	(while (and (not (= poLsCo nil)) (= poPass nil))
	  (grvecs
	    (append (list 2) (nth poCon poLsCo))
	  )
					;(brkstep
					;	'("PoPass" "(append (list 2) (list (nth poCon poLsCo)))")
					;	"04" "POLICOO"
					;)
	  (initget 2 "Aceptar Salir")
	  (setq	poPass
		 (getkword
		   "\nDesea esta alineacion? (enter para continuar) <Aceptar Salir>: "
		 )
	  )
	  (princ)
	  (command "_redrawall")
	  (princ)
	  (print)
					;(brkstep '("poPass") "05" "POLICOO")
	  (cond
	    (
	     (= poPass "Aceptar")
	     (setq poPass t)
	     (setq poCooFn (nth poCon poLsCo))
	    )
	    (
	     (= poPass nil)
	     (setq poPass nil)
	     (cond
	       (
		(< poCon (- (length poLsCo) 1))
		(setq poCon (+ poCon 1))
	       )
	       (
		(<= (- (length poLsCo) 1) poCon)
		(setq poCon 0)
	       )
	     )
	    )
	    (
	     (= poPass "Salir")
	     (setq poPass t)
	    )
	  )
	)
       )
     )
    )
  )
					;(brkstep '("poCooFn") "06" "POLICOO")
  (setq poCooFn poCooFn)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: SEG2V
;;	> (segunda version de SEG1V)
;;	Devuelve la lista de segmentos apartir de la definicion
;;	de una lista de coordenadas donde cada segmento de recta repite una
;;	coordenada con la anterior y posterior como segmentos conectados.
;;	Uniendo la coordenada final con la inicial para una polilinea cerrada
;;DEVUELVE: Lista de segmentos
;;	>( (coordenada1 coordenada2) (coordenada2 coordenada3) ....)
;;ARGUMENTOS
;;	1. CORSEG: Lista de coordena
;;	> ( (X Y) (X Y) ...)
;;DEPENDIENTES
;;	> ERT ()
;;ANOTACIONES
;;	>
(defun seg2v (corseg / con fnl fnll)
  (setq	con 0
	finll '()
  )
					;(brkstep '("corseg") "00" "SEG2V")
  (while (< con (- (length corseg) 1))
    (setq fnl (ert corseg (list con (+ con 1)))
    )
    (setq fnll
	   (append fnll (list fnl))
    )
    (setq con (+ con 1))
  )
  (setq	fnl  (list (nth (- (length corseg) 1) corseg) (nth 0 corseg))
	fnll (append fnll (list fnl))
  )
					;(brkstep '("fnll") "01" "SEG2V")
  (setq fnll fnll)
)
;;PROYECTO: Lisp
;;CLASIFICACION; TRZ
;;OBJETO: Para2. dibuja lineas paralelas en ambos lados apartir de la definicion 
;;	dos coordenadas 
;;DEVUELVE:
;;	paCoFn. lista de nombre de elementos de las lineas trazadas
;;	>(ENAME ...)
;;ARGUMENTOS
;;	1. paCoo0. par de coordenadas para trazo de paralelas
;;	> ((XYZ) (XYZ)) o ((XY) (XY))
;;	2. paDis0. Distancia paralela
;;	> REAL
;;	3. paMoDis0. Modo de distribucion paralela
;;		0. la Distancia de distribucion se repite a cada lado
;;		1. La distancia se reparte entre dos para distribuir a cada
;;		lado.
;;	4. paProp0.Lista de propiedades
;;	> ((cod . Valor) (...) ....)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Toma unicamente los valores XY
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;VARIABLES. paCo1 paCo2 paDisT paPer1 paPer2 paLsAng paLsCo1
;;	paLsCo2 paLsLn paL1P1 paL1P2 paL2P1 paL2P2
;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun Para2
	     (paCoo0	paDis0	  paMoDis0  paProp0   /
	      paCoo	paDis	  paMoDis   paProp    paCo1
	      paCo2	paDisT	  paPer1    paPer2    paLsAng
	      paLsCo1	paLsCo2	  paLsLn    paL1P1    paL1P2
	      paL2P1	paL2P2	  paMoSnap
	     )
					;(setq paCoo nil paDis nil paMoDis nil paProp nil paCo1 nil paCo2 nil paDisT nil
					;	paPer1 nil paPer2 nil paLsAng nil paLsCo1 nil paLsCo2 nil paLsLn nil
					;	paL1P1 nil  paL1P2 nil paL2P1 nil paL2P2 nil paMoSnap nil
					;)
					;(brkstep
					;	'("paCoo0" "paDis0" "paMoDis0" "paProp0"
					;		"(= (type paCoo0) 'LIST)"
					;		"(= (numberp paDis0) t)"
					;		"(= (type paMoDis0) 'INT)"
					;		"(= (type paProp0) 'LIST)"
					;	)
					;	"00" "Para2"
					;)
  (cond
    (
     (and
       (= (type paCoo0) 'LIST)
       (= (numberp paDis0) t)
       (= (type paMoDis0) 'INT)
       (= (type paProp0) 'LIST)
     )
     (setq paMoSnap (getvar "osmode"))
     (setvar "osmode" 0)
     (setq paCoo   paCoo0
	   paDis   paDis0
	   paMoDis paMoDis0
	   paProp  paProp0
     )
					;(brkstep '("paCoo" "paDis" "paMoDis" "paProp") "01" "Para2")
     (setq paCo1
		  (list	(nthx '(0 0) paCoo)
			(nthx '(0 1) paCoo)
		  )
	   paCo2
		  (list
		    (nthx '(1 0) paCoo)
		    (nthx '(1 1) paCoo)
		  )
	   paDisT (distance paCo1 paCo2)
	   paPer1 (sumang (angle paCo1 paCo2) 1.57079632)
	   paPer2 (sumang (angle paCo2 paCo1) 1.57079632)
     )
					;(brkstep '("paCo1" "paCo2" "paDisT" "paPer1" "paPer2")
					;	"02" "Para2"
					;)
					;paCo1. Coordenada1 de par de coordenadas
					;<(XY)>
					;paCo2. Coordenada2 de par de coordenadas
					;<(XY)>
					;paDisT. Distancia total entre par de coordenadas iniciales
					;paPer1. Angulo perpendicular 1
					;Angulo en radianes
					;paPer2, Angulo perpendicular 2
					;Angulo en radianes
     (cond
       (
	(= paMoDis 1)
	(setq paDis (/ paDis 2))
       )
     )
     (cond
       (
	(and
	  (not (= paPer1 nil))
	  (not (= paPer2 nil))
	)
	(setq paLsAng (list paPer1 paPer2)
	      paLsCo1
		      (mapcar '(lambda (x) (polar paCo1 x paDis)) paLsAng)
	      paLsCo2
		      (mapcar '(lambda (x) (polar x (angle paCo1 paCo2) paDisT))
			      paLsCo1
		      )
	)
					;(brkstep '("paLsAng" "paLsCo1" "paLsCo2")
					;	"03" "Para2"
					;)
					;paLsAng. Lista de angulos perpendiculares al angulo
					;	formado entre las dos coordenadas del argumento.
					;paLsCo1. Par de coordenadas paralelas al primer
					;	punto de la coordenada.
					;<((XY) (XY))>
					;paLsCo2, Par de coordenadas paralelas al segundo punto
	;;<((XY) (XY))>
	(setq paL1P1 (strcat (cortxt (nth 0 paLsCo1)) "," (rtos 0))
	      paL1P2 (strcat (cortxt (nth 0 paLsCo2)) "," (rtos 0))
	      paL2P1 (strcat (cortxt (nth 1 paLsCo1)) "," (rtos 0))
	      paL2P2 (strcat (cortxt (nth 1 paLsCo2)) "," (rtos 0))
	)
					;paL1P1. Primer coordenada de linea1
					;<"X,Y,Z">. Z=0 
					;paL1P2. Segunda coordenada de linea1
					;<"X,Y,Z">. Z=0 
					;paL2P1. Primer coordenada de linea2
					;<"X,Y,Z">. Z=0 
					;paLsP2. Segunda coordenada de Linea2
					;(brkstep '("paL1P1" "paL1P2" "paL2P1" "paL2P2") "04" "Para2")
	;;VARIABLES
	(command "_line" paL1P1 paL1P2 "")
	(setq paLsLn (append paLsLn (list (entlast))))
					;(brkstep '("paLsLn") "05" "Para2")
	(command "_line" paL2P1 paL2P2 "")
	(setq paLsLn (append paLsLn (list (entlast))))
					;(brkstep '("paLsLn") "06" "Para2")
	(cond
	  (
	   (not (= paProp nil))
	   (mapcar '(lambda (x) (cam1 paLsLn x)) paProp)
	  )
	)
       )
     )
     (setvar "osmode" paMoSnap)
    )
  )
  (setq paLsLn paLsLn)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIN
;;OBJETO: MAT10
;;	> A partir de la lista de nombre de entidad de lineas, extrae las coordenadas
;;	id (HANDLET) para crear una lista de lineas con pendiente, ordenada al origen
;;	y coordenadas.
;;DEVUELVE: Lista de lineas agrupadas por pendientes
;;	 con las siguientes caracteristicas por linea:
;;	>1. Pendiente
;;	>2. Ordenada al origen
;;	>3. IDname (handlet)
;;	>4... (XY) INICIAL
;;	>5... (XY) FINAL
;;	>{ [ ( pend ordenada ID (xy) (xy) ) (...) ...] [ ... ] }
;;ARGUMENTOS
;;	1.LINENAME: Lista lista de nombres de entidades de lineas
;;	> (ename ename ....)
;;DEPENDIENTES
;;	> LNPO2 ()
;;	> LISCOD()
;;	> EqCo (LsType)
;;ANOTACIONES
;;	> 
(defun mat10
	(lin0 /
		con1 con2 lifs li1
		mipe mior eleli indpen grpen0
		indi1 pilf pil0 npil0 pre miname micolor1 facord ordena1
		lisf1 lifsn lifs0 lifs2 con3a mimos numpos lmicolor angprec
	)
;	(setq con1 nil con2 nil lifs nil li1 nil
;		mipe nil mior nil eleli nil indpen nil grpen0 nil
;		indi1 nil pilf nil pil0 nil npil0 nil pre nil miname nil micolor1 nil facord nil
;		ordena1 nil lisf1 nil lifsn nil lifs0 nil lifs2 nil con3a nil mimos nil linename nil
;		numpos nil lmicolor nil angprec nil
;	)
	(setq linename lin0)
	;;
;	(brkstep1
;		'("linename" "(length linename)")
;		(list linename (length linename))
;		"00" "MAT10"
;	)
	;;
	;**LINENAME (ENAME ...) Lista de nombre de entidad de lineas
	(setq mimos (getvar "osmode"))
	(setvar "osmode" 0)
	(setq pre (getvar "luprec"))
	(setq angprec (getvar "auprec"))
	(setvar "luprec" 8)
	(setvar "auprec" 8)
	(setq con1 0
		lifs nil)
	(while
		(< con1 (length linename))
		(cond
			(
				(=
					(cdr (assoc 0 (entget (nth con1 linename))))
					"LINE"
				)
				(setq li1
					(lscod
						(nth con1 linename)
						'(5 10 11)
					)
				)
				(setq miname (handent (cdr (assoc 5 li1)));;
					micolor1 (assoc 62 (entget miname));;
				);;
;				(brkstep1
;					'("li1" "(length li1)" "miname" "(nth con1 linename)")
;					(list li1 (length li1) miname (nth con1 linename))
;					"01" "MAT10"
;				)
				;;
				;**MINAME. ENAME
				;**LI1. ((5 . "xxx") (10 #.# #.# #.#) (11 #.# #.# #.#))
				;**
				;;MICOLOR ## / NIL. COLOR DE LINEA
				(cond
					(
						(= micolor1 nil)
						(setq micolor1 '(62 . 256))
					)
				)
				(cam1 (list miname) '(62 . 1))
				;;
;				(brkstep1 
;					'("li1")
;					(list li1)
;					"02" "MAT10"
;				)
				;;
				(cam1 (list miname) micolor1)
				(setq lmicolor (append lmicolor (list miname)))
				(setq
					li1
					;(append
					;	(list (cdr (nth 0 li1)))
					;	(list (roundcor (ert (nth 1 li1) '(1 2)) 8))
					;	(list (roundcor (ert (nth 2 li1) '(1 2)) 8))
					;)
					(append
						(list (cdr (nth 0 li1)))
						(list (ert (nth 1 li1) '(1 2)))
						(list (ert (nth 2 li1) '(1 2)))
					)
					facord nil
				)
				;**LI1.(ID (X1 Y1) (X2 Y2)). Elemento de linea
				;**Facord Factor de orden.
				;;
;				(brkstep1
;					'("li1" "(angle (nth 1 li1) (nth 2 li1))"
;						"(nth 1 li1)" "(nth 2 li1)"
;					)
;					(list 
;						li1 (angle (nth 1 li1) (nth 2 li1))
;						(nth 1 li1) (nth 2 li1)
;					)
;					"03" "MAT"
;				)
				;;
				(cond
					(
						(not
							(EqCo
								(nth 1 li1)
								(nth 2 li1)
								0
								0.0001
							)
						)
						(cond
							(
								(or
									(EqLs
										(angle
											(nth 1 li1)
											(nth 2 li1)
										)
										1.5708
										0
										0.0001
									)
									(EqLs
										(angle
											(nth 1 li1)
											(nth 2 li1)
										)
										4.71239
										0
										0.0001
									)
								)
								(setq mipe "nop"
									mior (nth 0 (nth 1 li1));Abscisa
								)
								;;
;								(brkstep1
;									'("mipe" "mior" "facord")
;									 (list mipe mior facord)
;									 "04A" "MAT10"
;								)
								;;
							)
							(
								(EqLs
									(nthx '(1 1) li1)
									(nthx '(2 1) li1)
									0
									0.0001
								)
								(setq mipe 0
									mior (nthx '(1 1) li1)
								)
								;;
;								(brkstep1
;									'("mior" "mipe")
;									(list mior mipe)
;										"04A1" "MAT10"
;								)
								;;
							)
							(
								(= 0 0)
								(setq mipe (ppnd3 (nth 1 li1) (nth 2 li1) 7))
								(setq mipe (round1 mipe 8)) ;;;;;;;;;;;;;Redondeo
								(setq mior (ordi (nth 1 li1) mipe))
								(setq mior (round1 mior 8)) ;;;;;;;;;;;;;;;;,Redondeo
								;;
;								(brkstep1
;									'("mipe" "mior")
;									(list mipe mior)
;									"04B" "MAT10"
;								)
								;;
							)
						)
						(cond
							(
								(equal mipe "nop")
								(setq facord 0
									numpos 1
								)
							)
							(
								(< mipe 0)
								(setq facord 1
									numpos 0
								)
							)
							(
								(< 0 mipe)
								(setq facord 0
									numpos 0
								)
							)
							(
								(equal mipe 0 0.0001)
								(setq facord 0
									numpos 0)
							)
						)
						;** FACORD. 0.Orden de menor a mayor; 1. Orden de mayor a menor
						;** NUMPOS. 0.Posicion de elemento (X);
						;		1. Posicion de elemento (Y)
						(setq ordena1
							(orden2
								(list
									(nth 1 li1)
									(nth 2 li1)
								)
								numpos
								facord
							)
						)
						;(brkstep '("ordena1") "05" "MAT1")
						;**ORDENA1 ((XY) (XY)). Lista de coordenadas ordenadas.
						(setq eleli
							(append
								(list mipe)
								(list mior)
								(list (cdr (assoc 5 (entget (nth con1 linename)))))
								ordena1
							)
						)
						(setq lifs (append lifs (list eleli)))
						;**ELELI. (Pend Ordenada ID (X1Y1) (X2Y2))
						;**	Lista elemento.
						;**LIFS ((Pend Ordenada ID (X1Y1) (X2Y2)) (..))
					)
				)
			)
		)
		;(brkstep '("lifs" "eleli" "con1" "(length lifs)" "con1") "06" "MAT1")
		(setq con1 (+ con1 1))
	)
	(setq lifs lifs)
	;**LIFS. ((Pend Ordenada ID (X1Y1) (X2Y2)) (...)...). Lista de guias
	;(brkstep '("lifs" "(length lifs)") "07" "MAT1")
	(cond
		(
			(not (= lifs nil))
			(setq lisvar
				(lva0 lifs 1 1 3)
			)
			;(brkstep '("lifs" "(length lifs)" "lisvar" "(length lisvar)") "08" "MAT1")
			;**LIFS ((Pend Ordenada ID (X1Y1) (X2Y2)) (..)). Lista total de elementos
			;**LISVAR (Pend1 Pend2 ...) Lista de pendientes
			(setq con2 0)
			(while
				(< con2 (length lisvar))
				(setq pil0
					(lnpo4
						(nth con2 lisvar)
						lifs
						0
						1
						0.001
					)
				)
				;;**PIL0. [ (pend1 (xy) (xy)) (...) ...] misma pendiente
				;(brkstep '("pil0" "(length pil0)") "09" "MAT1")
				(setq pilf
					(append
						pilf
						(list pil0)
					)
				)
				;**PILF ( [(pend1 (xy) (xy)) (...) ...] [....] )
				;		Lista final de elementos agrupados x pendiente
				(setq con2 (+ con2 1))
			)
		)
	)
	;(brkstep
	;	'("pilf"
	;		"(length (nth 0 pilf))"
	;		"(length (nth 1 pilf))"
	;		"(length Pilf)"
	;		"(+ (length (nth 0 pilf)) (length (nth 1 pilf)))"
	;		"con2"
	;	)
	;	"10" "MAT1"
	;)
	(cam1 lmicolor micolor1)
	(setvar "osmode" mimos)
	(setvar "luprec" pre)
	(setvar "auprec" angprec)
	(setq pilf pilf)
)
;;;;;;;;;;;;;;;;;;;;;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MDAT
;;OBJETO / TITULO: EqCo. Compara la igualdad entre coordenadas
;;DESCRIPCION: Compara la igualdad de dos coordenadas con opcion
;;	a omitir la coordenada en Z
;;	>
;;DEVUELVE: eqRs. T / nil dependiendo del resultado
;;	> T. Si las coordenadas son iguales
;;	> nil. Si los elementos no son iguales
;;ARGUMENTOS
;; 1.eqCo10. Primera coordenada de comparacion
;;	> (X Y Z) / (X Y)
;;	2.eqCo20. Segunda coordenada de comparacion
;;	> (X Y Z) / (X Y)
;; 3.eqZ0 Modo de evaluacion para coordenadas
;;		sin considerar "Z" (tercer elemento dentro de una lista numerica).
;;	> En modo 0. No considera la coordenada en Z (tercera coordenada)
;;	> En modo 1. Considera la coordenada en Z (tercera coordenada).
;; 4. eqNPr0. Precision decimal para comparacion numerica.
;;	> numero decimal <x.xxx>
;;DEPENDIENTES
;;	>Eq0;LsType
;;ANOTACIONES
;;	> 
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun EqCo
	(eqCo10 eqCo20 eqZ0 eqNPr0 /
		eqCo1 eqCo2 eqZ eqNPr
		eqRs eqNum eqLuPrec
	)
;	(setq eqCo1 nil eqCo2 nil eqZ nil eqNPr nil
;		eqRs nil eqNum nil eqLuPrec nil
;	)
	(setq eqLuPrec (getvar "luprec"))
	(setvar "luprec" 8)
	;;
;	(brkstep1
;		'("eqCo10" "eqCo20" "eqZ0" "eqNPr0")
;		(list eqCo10 eqCo20 eqZ0 eqNPr0)
;		"00" "EqCo"
;	)
	;;
	(cond
		(
			(and (= (LsType eqCo10) "NUM")
				(= (LsType eqCo20) "NUM")
				(= (type eqZ0) 'INT)
				(= (type eqNPr0) 'REAL)
			)
			(setq eqCo1 eqCo10
				eqCo2 eqCo20
				eqZ eqZ0
				eqNPr eqNPr0
			)
			;;
;			(brkstep1
;				'("eqCo1" "eqCo2" "eqZ" "eqNPr")
;				(list eqCo1 eqCo2 eqZ eqNPr)
;				"01" "EqCo"
;			)
			;;
;			(brkstep1
;				'("(length eqCo1)" "(length eqEqCo2)")
;				(list (length eqCo1) (length eqCo2))
;				"02" "EqCo"
;			)
			;;
			(cond
				(
					(and (< 1 (length eqCo1))
						(> 4 (length eqCo1))
						(< 1 (length eqCo2))
						(> 4 (length eqCo2))
					)
					(cond
						(
							(and
								(= (length eqCo1) 3)
								(= (length eqCo2) 3)
								(= eqZ 1)
							)
							(setq eqNum (distance eqCo1 eqCo2))
						)
						(
							(and
								(= (length eqCo1) 2)
								(= (length eqCo2) 2)
								(= eqZ 1)
							)
							(setq eqNum (distance eqCo1 eqCo2))
						)
						(
							(and
								(= (length eqCo1) 2)
								(= (length e1Co2) 3)
								(= eqZ1)
								(setq eqCo1 (list (nth 0 eqCo1) (nth 1 eqCo2) 0.0))
								(setq eqNum (distance eqCo1 eqCo2))
							)
						)
						(
							(and
								(= (length eqCo1) 3)
								(= (length eqCo2) 2)
							)
							(= eqZ1)
							(setq eqCo2 (list (nth 0 eqCo1) (nth  1 eqCo2) 0.0))
							(setq eqNum (distance eqCo1 eqCo2))
						)
						(
							(= eqZ 0)
							(setq eqCo1 (list (nth 0 eqCo1) (nth 1 eqCo1))
								eqCo2 (list (nth 0 eqCo2) (nth 1 eqCo2))
							)
							(setq eqNum (distance eqCo1 eqCo2))
						)
					)
;					(brkstep1 '("eqNum") (list eqNum) "03" "EqCo")
					(setq eqRs nil)
					(cond
						(
							(equal eqNum eqNPr 0.0000001)
							;;
;							(brkstep1
;								'("(equal eqNum eqNpr 0.0000001)")
;								(list (equal eqNum eqNpr 0.0000001))
;								"03A" "EqCo"
;							)
							;;
							(setq eqRs T)
						)
						(
							(< eqNum eqNPr)
							;;
;							(brkstep1
;								'("(< eqNum eqNPr)")
;								(list (< eqNum eqNPr))
;								"03B" "EqCo"
;							)
							;;
							(setq eqRs T)
						)
					)
				)
			)
		)
	)
;	(brkstep1 '("eqRs") (list eqRs) "04" "EqCo")
	(setvar "luprec" eqLuPrec)
	(setq eqRs eqRs)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MDAT
;;OBJETO / TITULO: Eq0. Compara la igualdad entre dos cantidades
;;DESCRIPCION: Eq0. Compara la igualdad de dos cantidades tanto tipo
;;	de datos entero y decimal.
;;DEVUELVE: eqR0. T / nil dependiendo del resultado
;;	> T. Si las dos cantidades son iguales
;;	> nil. Si las dos cantidades no son iguales
;;ARGUMENTOS
;; 1.eqNum10. Primer numero de comparacion
;;	> #.# / ##
;;	2.eqNum20. Segundo numero de comparacion
;;	> #.# / ##
;; 3. eqNPrec0. Precision decimal para elementos
;;		numericos.
;;	> numero decimal <x.xxx>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> En elementos numericos, compara la cantidad absoluta del
;;		resultado de la resta entre los dos elementos.
;;	> La precision maxima es 0.00000002 (aprox)
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun Eq0
	(eqNum10 eqNum20 eqNPrec0 /
		eqNum1 eqNum2 eqNPrec eqR0 eqCon0 eqPs0
		eqNumQ0 abs10 abs20 eqVar0
	)
	;(setq eqNum1 nil eqNum2 nil eqNPrec nil
	;	eqR0 nil eqCon0 nil eqPs0 nil eqNumQ0 nil 
	;	abs10 nil abs20 nil eqVar0 nil
	;)
	;;
;	(brkstep1
;		'("eqNum10" "eqNum20" "eqNPrec0")
;		(list eqNum10 eqNum20 eqNPrec0)
;		"00" "Eq0"
;	)
	;;
	(cond
		(
			(and (numberp eqNum10) 
				(not (= eqNum20 nil))
				(= (type eqNPrec0) 'REAL)
			)
			(setq eqNum1 eqNum10
				eqNum2 eqNum20
				eqNPrec eqNPrec0
			)
			;;;Iguala tipo de datos numericos;;;(0)
			(cond
				(
					(= (type eqNum1) 'INT)
					(setq eqNum1 (+ eqNum1 0.000))
				)
			)
			(cond
				(
					(=(type eqNum2) 'INT)
					(setq eqNum2 (+ eqNum2 0.000))
				)
			)
			;;;Iguala tipo de datos numericos;;;(1)
			;;
;			(brkstep1
;				'("(type eqNum1)" "(type eqNum2)")
;				(list (type eqNum1) (type eqNum2))
;				"01" "Eq0"
;			)
			;;
			(setq eqVar0 (getvar "luprec"))
			(setvar "luprec" 8)
			(cond
				(
					(and (numberp eqNum1)
						(numberp eqNum2)
					)
					(setq eqNumQ (abs (- eqNum1 eqNum2)))
					;;
					;(brkstep1
					;	'("eqNumQ"
					;		"eqNPrec"
					;		"(or (equal eqNumQ eqNPrec 0.00000001)
					;			(> eqNprec eqNumQ)
					;		)"
					;	)
					;	(list eqNumQ
					;		eqNPrec
					;		(or (equal eqNumQ eqNPrec 0.00000001)
					;			(> eqNPrec eqNumQ)
					;		)
					;	)
					;	"02" "Eq0"
					;)
					;;
					;(brkstep1
					;	'(
					;		"eqNPrec" "eqNumQ"
					;		"(equal eqNumQ eqNPrec 0.0000001)"
					;		"(> eqNPrec eqNumQ)"
					;	)
					;	(list eqNPrec eqNumQ
					;		(equal eqNumQ eqNPrec 0.0000001)
					;		(> eqNPrec eqNumQ)
					;	)
					;	"03" "Eq0"
					;)
					(setq eqR0 nil)
					(cond
						(
							(equal eqNumQ eqNPrec 0.00000001)
							(setq eqR0 T)
						)
						(
							(> eqNPrec eqNumQ)
							(setq eqR0 T)
						)
					)
				)
			)
		)
	)
	(setq eqR0 eqR0)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MDAT
;;OBJETO / TITULO: EqLs. Compara la igualdad entre dos elementos
;;DESCRIPCION: Compara la igualdad de dos elementos, ya sean textos, listas
;;		o numeros con una precision definida
;;	>
;;DEVUELVE: eqRes. T / nil dependiendo del resultado
;;	> T. Si los dos elementos son iguales
;;	> nil. Si los elementos no son iguales
;;ARGUMENTOS
;; 1.eqEl10. Primer elemento de comparacion
;;	> (xxx) / xxx / #.# / ##
;;	2.eqEl20. Segundo elemento de comparacion
;;	> (xxx) / xxx / #.# / ##
;; 3.eqMd0 Modo de evaluacion para coordenadas
;;		sin considerar "Z" (tercer elemento dentro de una lista numerica).
;;	> En modo 0. No admite listas numericas donde
;;		no se considera el tercer subelemento de los
;;		dos elementos.
;;	> En modo 1 admite listas numericas de 2 o 3 
;;		subelementos y solo analiza los dos primeros
;;		(coordenadas donde no se considera "Z").
;; 4. eqNPre0. Precision decimal para elementos
;;		numericos.
;;	> numero decimal <x.xxx>
;;DEPENDIENTES
;;	>Eq0;LsType
;;ANOTACIONES
;;	> En elementos numericos, compara la cantidad absoluta del
;;		resultado de la resta entre los dos elementos.
;;	> La precision maxima es 0.00000002 (aprox) en coordenadas
;;	> La precision maxima es 0.00000004 (aprox) en numeros
;;	> En lista de varios tipos de datos la comparación es exacta
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun EqLs
	(eqEl10 eqEl20 eqMd0 eqNPre0 /
		eqEl1 eqEl2 eqMd eqNPre eqRes eqCon1 eqPas
		eqNumQ abs1 abs2 eqVar
	)
;	(setq eqEl1 nil eqEl2 nil eqMd nil eqNPre nil
;		eqRes nil eqCon1 nil eqPas nil eqNumQ nil 
;		abs1 nil abs2 nil eqVar nil
;	)
	(setq eqVar (getvar "luprec"))
	(setvar "luprec" 8)
	;;
;	(brkstep1
;		'("eqEl10" "eqEl20" "eqMd0" "eqNPre0")
;		(list eqEl10 eqEl20 eqMd0 eqNPre0)
;		"00" "EqLs"
;	)
	;;
	(cond
		(
			(= (type eqEl10) 'INT)
			(setq eqEl10 (+ eqEl10 0.000))
		)
	)
	(cond
		(
			(= (type eqEl20) 'INT)
			(setq eqEl20 (+ eqEl20 0.000))
		)
	)
	(cond
		(
			(and (= (type eqEl10) (type eqEl20))
				(= (type eqMd0) 'INT)
				(= (type eqNPre0) 'REAL)
			)
			(setq eqEl1 eqEl10
				eqEl2 eqEl20
				eqMd eqMd0
				eqNPre eqNPre0
			)
			;;
;			(brkstep1
;				'("(type eqEl1)" "(type eqEl2)")
;				(list (type eqEl1) (type eqEl2))
;				"01" "EqLs"
;			)
			;;
			(cond
				;;;;;Tipo String;;;;;;(0)
				(
					(and (= (type eqEl1) 'STR)
						(= (type eqEl2) 'STR)
					)
					(if (equal eqEl1 eqEl2)
						(setq eqRes T)
					)
				)
				;;;;;Tipo String;;;;;;;(1)
				;;;;;ENAME;;;;;;;;;;;;;;(0)
				(
					(and
						(equal (type eqEL1) 'ENAME)
						(equal (type eqEL2) 'ENAME)
					)
					;br
;					(brkstep1
;						'("eqEL1" "eqEL2") (list eqEL1 eqEL2)
;						"EqLs:01a" "01a"
;					)
					;br..
					(if (equal eqEL1 eqEL2)
						(setq eqRes T)
					)
				)
				;;;;;;ENAME;;;;;;;;;;;;;;(1)
				;;;;;Tipo Numerico ;;;;(0)
				(
					(and (= (numberp eqEl1) T)
						(= (numberp eqEl2) T)
					)
					(setq eqRes (Eq0 eqEl1 eqEl2 eqNPre))
					;;
;					(brkstep1
;						'("eqRes"
;							"eqNPre"
;						) 
;						(list eqRes
;							eqNPre
;						)
;						"02" "EqLs"
;					)
					;;
				)
				;;;;;Tipo Numerico ;;;;(1)
				;;;;;Tipo Lista ;;;;;;;(0)
				(
					(and (= (type eqEl1) 'LIST)
						(= (type eqEl2) 'LIST)
					)
					;;
;					(brkstep1 '("eqEl1" "eqEl2") (list eqEl1 eqEl2) "03" "EqLs")
					;;
					(cond 
						(
							(and
								(= (LsType eqEl1) "NUM")
								(= (LsType eqEl2) "NUM")
							)
							;;
;							(brkstep1
;								'("(length eqEl1)" "(length eqEqEl2)")
;								(list (length eqEl1) (length eqEl2))
;								"04" "EqLs"
;							)
							;;
							(cond
								(
									(and (< 1 (length eqEl1))
										(> 4 (length eqEl1))
										(< 1 (length eqEl2))
										(> 4 (length eqEl2))
										(= eqMd 1)
									)
									(setq eqEl1
										(list (nth 0 eqEl1)
											(nth 1 eqEl2)
										)
										eqEl2
										(list (nth 0 eqEl2)
											(nth 1 eqEl2)
										)
									)
									;;
;									(brkstep1
;										'("eqEl1" "eqEl2" "eqNPre")
;										(list eqEl1 eqEl2 eqNPre)
;										"05" "EqLs"
;									)
									;;
									(cond
										(
											(and
												(Eq0 (nth 0 eqEl1) (nth 0 eqEl2) eqNPre)
												(Eq0 (nth 1 eqEl1) (nth 1 eqEl2) eqNPre)
											)
											(setq eqRes T)
											;;
;											(brkstep1 '("eqRes") (list eqRes) "06" "EqLs")
											;;
										)
									)
								)
								(
									(and
										(= (length eqEl1) (length eqEl2))
										(= eqMd 0)
									)
									(setq eqCon1 0
										eqRes T
									)
									(while
										(< eqCon1 (length eqEl1))
										;;
;										(brkstep1
;											'("eqCon1" "eqEl1" "eqEl2"
;												"Eval Eq0"
;											)
;											(list eqCon1 eqEl1 eqEl2
;												(Eq0 
;													(nth eqCon1 eqEl1)
;													(nth eqCon1 eqEl2)
;													eqNpre
;												)
;											)
;											"06A" "EqLs"
;										)
										;;
										(cond
											(
												(not
													(Eq0 (nth eqCon1 eqEl1)
														(nth eqCon1 eqEl2) eqNPre
													)
												)
												(setq eqRes nil)
												;;
;												(brkstep1 '("eqRes") (list eqRes) "07" "Eq0")
												;;
											)
										)
										(setq eqCon1 (+ eqCon1 1))
									)
									;;
;									(brkstep1 '("eqRes") (list eqRes) "08" "Eq0")
									;;
								)
							)
						)
						(
							(or (= (LsType eqEl1) "PAR")
								(= (LsType eqEl2) "PAR")
							)
							(setq eqRes (equal eqEl1 eqEl2))
						)
						(
							(and
								(= (length eqEl1) (length eqEl2))
								(and
									(not (= (LsType eqEl1) "NUM"))
									(not (= (LsType eqEl2) "NUM"))
								)
							)
							(setq eqRes T
								eqCon1 0
							)
							(while (< eqCon1 (length eqEl1))
								;;
;								(brkstep1
;									'("(nth eqCon1 eqEl1)" "(nth eqCon1 eqEl2)" "eqRes")
;									(list (nth eqCon1 eqEl1) (nth eqCon1 eqEl2) eqRes)
;									"09A"  "EqLs"
;								)
								;;
								(cond
									(
										(and (numberp (nth eqCon1 eqEl1))
											(numberp (nth eqCon1 eqEl2))
										)
										;;
;										(brkstep1
;											'("(not (Eq0 (nth eqCon1 eqEl1)
;													(nth eqCon1 eqEl2)
;													eqNPre
;												))"
;											)
;											(list
;												(not (Eq0
;													(nth eqCon1 eqEl1)
;													(nth eqCon1 eqEl2)
;													eqNPre)
;												)
;											)
;											"09B" "EqLs"
;										)
										;;
										(cond
											(
												(not
													(Eq0
														(nth eqCon1 eqEl1)
														(nth eqCon1 eqEl2)
														eqNPre
													)
												)
												(setq eqRes nil)
												;;
;												(brkstep1 '("eqRes") (list eqRes) "09C" "EqLs")
												;;
											)
										)
									)
									(
										(and 
											(not (numberp (nth eqCon1 eqEl1)))
											(not (numberp (nth eqCon1 eqEl2)))
										)
										;;
;										(brkstep1 
;											'("(not
;													(equal
;														(nth eqCon1 eqEl1)
;														(nth eqCon1 eqEl2) eqNPre
;													)
;												)"
;											)
;											(list
;												(not
;													(equal (nth eqCon1 eqEl1) (nth eqCon1 eqEl2)
;														eqNPre
;													)
;												)
;											)
;											"09D" "EqLs"
;										)
										;;
										(cond
											(
												(not 
													(equal
														(nth eqCon1 eqEl1) (nth eqCon1 eqEl2)
														eqNPre
													)
												)
												(setq eqRes nil)
											)
										)
									)
								)
								(setq eqCon1 (+ eqCon1 1))
							)
							;;
;							(brkstep1 '("eqRes") (list eqRes) "10" "EqLs")
							;;
						)
					)
				)
				;;;;;Tipo lista;;;;(1)
			)
		)
	)
	(setvar "luprec" eqVar)
	;;
;	(brkstep1 '("eqRes") (list eqRes) "06" "NUM")
	;;
	(setq eqRes eqRes)
)
;;PROYECTO: Lisp
;;CLASIFICACION: ENT
;;OBJETO: LSCOD
;;	> Extrae en orden de la lista de códigos del argumento los mismos de una entidad
;;DEVUELVE: Lista de codigos y valores
;;	> (X.X X.X ...)
;;ARGUMENTOS
;;	1. MIENT : Nombre de entidad
;;	> ENAME
;;	2. MISCOD : Lista de códigos
;;	(# # # ...)
;;DEPENDIENTES
;;	> NINGUNO
;;ANOTACIONES
;;	> La rutina toma el primer elemento de cada elemento como indice de
;;	comparacion sea par punteado o lista sencilla (CAR).
(defun lscod (mient miscod / con1 con2 milis1 milis lsfn)
  (setq	con1  0
	milis (entget mient)
	lsfn  '()
  )
  (while (< con1 (length milis))
    (setq milis1 (nth con1 milis)
	  con2	 0
    )
    (while (< con2 (length miscod))
      (cond
	(
	 (= (car milis1) (nth con2 miscod))
	 (setq lsfn (append lsfn (list milis1))
	       con2 (length miscod)
	 )
	)
	(
	 (not (= (nth con2 miscod) (car milis1)))
	 (setq con2 (+ con2 1))
	)
      )
    )

    (setq con1 (+ con1 1))
  )
  (setq lsfn lsfn)
)
;;PROYECTO: Lisp
;;CLASIFICACION:MDAT
;;OBJETO / TITULO: LsType Define el tipo de datos en una lista
;;DESCRIPCION: Analiza cada tipo de dato de una lista
;;	y devuelve el tipo de dato en caso de que todos los 
;;	tipo de elementos en la lista sean iguales
;;	>
;;DEVUELVE:lsT.
;;	> "STR". Si todos los elementos de la lista
;;		son de tipo string
;;	> "NUM". Si todos los elementons de la lista
;;	son de tipo numerico (real o int)
;;	> "VAR" Si existe mas de un tipo en los elementos
;;	de la lista.
;;	> "PAR" Si es un par punteado (xx . xx)
;;	> nil. Si el argumento no es una lista
;;ARGUMENTOS
;;	1. lsList0. Lista de trabajo
;;	> (x xx xx …)
;;DEPENDIENTES
;;	<(brkstep1)>
;;LOCALIZACION
;;	<>
;;HISTORIAL DE CORRECCIONES
;;	>2022.01.24: Arreglo para condicion de par punteado
;;ANOTACIONES
;;	>
;;ESTADO
;;	> ok
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun LsType
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
;;PROYECTO:Lisp
;;CLASIFICACION: MAIN
;;OBJETO: PARALE2
;;	> Comando de ejecucion de la funcion FACPA (cerramiento paralelo)
;;		con 2 en el tercer argumento y precision 8.
;;		Para cerramiento de tres lineas (paneles por par).
;;DEVUELVE:
;;	>
;;ARGUMENTOS **Argumentos definidos**
;;	1. APPNOM. Nombre de aplicacion.
;;	> 		Definido: ()
;;	2. LISCODI. Lista de codigos para filtra la seleccion.
;;	> '((codigo . valor) (...) ...) 0 ()
;;			Definido: ()
;;	3. PRECI. Numero entero para definir la precision
;;	> Numero de decimales.
;;			Definido 8
;;	4. NUMII. Numero de lineas de agrupacion.
;;	> 1 . Agrupacion de par de lineas (conexion paralela de uno a uno)
;;	> 2. Agrupacion de tres lineas (conexion paralela para dos paneles)
;;			Definido 2
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:parale2 ()
	(facpa () () 8 2)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: PARALE1
;;	> Comando de ejecucion de la funcion FACPA (cerramiento paralelo)
;;		con 1 en el tercer argumento y precision 8.
;;		Para cerramiento de tres lineas (paneles individuales).
;;DEVUELVE:
;;	>
;;ARGUMENTOS **Argumentos definidos**
;;	1. APPNOM. Nombre de aplicacion.
;;	> 		Definido: ()
;;	2. LISCODI. Lista de codigos para filtra la seleccion.
;;	> '((codigo . valor) (...) ...) 0 ()
;;			Definido: ()
;;	3. PRECI. Numero entero para definir la precision
;;	> Numero de decimales.
;;			Definido 8
;;	4. NUMII. Numero de lineas de agrupacion.
;;	> 1 . Agrupacion de par de lineas (conexion paralela de uno a uno)
;;	> 2. Agrupacion de tres lineas (conexion paralela para dos paneles)
;;			Definido 1
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;
(defun c:parale1 ()
	(facpa () () 8 1)
)
;;PROYECTO: Lisp
;;CLASIFICACION: Interface de depuración (DEP)
;;OBJETO: BRKSTEP1	
;;	Pausa el programa y muestra el valor del las variables definidas
;; 	en el argumento, contiene dos argumentos mas para la descripcion de
;;	los pasos anteriores y posteriores.
;;DEVUELVE: Muestra en pantalla el valor de las variables
;;ARGUMENTOS
;;	1. lstx. lista de nombre de variables
;;	1. LSCMD. Lista de comandos 
;;		Lista de cadenas de texto ("" "" "")
;;	2. BKSTP. Descripción de pasos anteriores
;;		Cadena de texto "  "
;;	3. FWRSTP. 	Descripción de texto de siguientes pasos
;;		Cadena de texto "  "
;;DEPENDIENTES:
;;	Ninguno
;;ANOTACIONES
(defun brkstep1 (lstx lscmd bkstp fwrstp / conx ppx bkstp1 fwrstp1)
	(setq ppx "ss")
	(while
		(not (= ppx ""))
			(setq conx 0)
			(setq bkstp1 (strcat "***** " bkstp " *****"))
			(print	bkstp1)
			(princ "\n")
			(prin1)
			(while
				(< conx (length lscmd))
				(princ)
				(princ (strcat (nth conx lstx) ": "))
				(princ)
				(princ (nth conx lscmd))
				(princ)
				(princ "\n")
				(setq conx (+ conx 1))
			)
			(setq fwrstp1 (strcat "***** " fwrstp " *****"))
			(print fwrstp1)
			(princ "\n")
		(setq ppx (getstring "*********ENTER PARA CONTINUAR**************  "))
	)
)
;
;;
;;;
;;;;
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: FUN
;;OBJETO / TITULO: ComLsp. Compila (escribe) una serie de funciones lisp
;;	en un solo archivo
;;DESCRIPCION: ComLsp.Crea y escribe en dos archivos (lisp y dcl)
;;	con las funciones definidas en listas correspondientes
;; mismas que se extraen de los archivos originales.
;;	>
;;DEVUELVE: comRes.Lista de las rutas y nombre del archivo donde
;; se crearon los archivos lisp y dcl compilados o nil si no realizo
;;	ninguna compilacion.
;;	> ("C: xx/xxx.lsp" "C: xx/xxx.dcl") <LIST>.
;;ARGUMENTOS
;;	1.comLsFnc0. Lista de funciones para compilar (nombre de archivo).
;;	> ("xxx" ...) <LIST>
;;	2. comLsDcl0. Lista de archivos de dialogo para compilar
;;	 (nombre de archivo).
;;	> ("xxx" ...) <LIST>
;;	3.comRtFnc0. Ruta donde se encuentran las funciones a cargar.
;;	> "C:/x/xxx/ <STR>
;;	4. comRtDcl0. Ruta donde se encuentran los archivos DCL.
;;	"C:/x/xxx/" <STR>
;;	5.comRtAr0. Ruta donde se encontrara el archivo compilado
;;	> "C:/xxx/xxx/" <STR>
;;	6.comNamAr0. Nombre que tendrá el achivo compilado sin extension
;;	"xxxx" <STR>
;; 7.comMod0. Modo de transcripcion de codigo
;;	> 0. Transcripcion de codigo sin comentarios
;;	> 1. Transcripcion de codigo con comentarios
;;DEPENDIENTES
;;<QuiTx LsType>
;;ANOTACIONES
;;	> El formato de las funciones es .lsp
;;	> El formato de los cuadros de dialogo es .lsp
;;	> El formato del archivo compilado es .lsp y .dcl
;;	> El nombre del archivo Dcl es igual solo cambiando la extension
;;	> El caracter de omision para funciones es ";"
;;	> El caracter de omision para dialogos es "//"
;;	> Cada elemento de la lista DCL debe tener la extension ".lsp"
;;	> Cada elemento de la lista de funciones debe tener la extension ".lsp"
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ComLsp
	(comLsFnc0 comLsDcl0 comRtFnc0 comRtDcl0 comRtAr0 comNamAr0 comMod0 /
		comLsFnc comLsDcl comRtFnc comRtDcl comRtAr comNamAr comMod
		comCon1 comNamFnc comOpFnc comOpAr comFnLn comPasFnc comDclLn
		comOpDcl  comAr1 comCon2 comRes  comAr0 comOpAr0
	)
;	(setq comLsFnc nil comLsDcl nil comRtFnc nil comRtDcl nil
;		comRtAr nil comNamAr nil comMod nil
;		comCon1 nil comNamFnc nil comOpFnc nil comOpAr nil comFnLn nil
;		comPasFnc nil comDclLn nil comOpDcl nil
;		 comAr1 nil comCon2 nil comRes nil
;		 comAr0 nil comOpAr0 nil
;	)
	;br
;	(brkstep1 
;		'("comLsFnc0" "comLsDcl0" "comRtFnc0" "comRtDcl0"
;			"comRtAr0" "comNamAr0" "comMod0"
;		)
;		(list comLsFnc0 comLsDcl0 comRtFnc0 comRtDcl0 comRtAr0 comNamAr0 comMod0)
;		"00" "ComLsp"
;	)
	;br..
	(cond
		(
			(or
				(and (= (type comRtFnc0) 'STR) (= (type comLsFnc0) 'LIST))
				(and (= (type comRtDcl0) 'STR) (= (type comLsDcl0) 'LIST))
			)
			(setq comLsFnc comLsFnc0
				comLsDcl comLsDcl0
				comRtFnc comRtFnc0
				comRtDcl comRtDcl0
				comRtAr comRtAr0
				comNamAr comNamAr0
				comMod comMod0
			)
			;br
;			(brkstep1
;				'("comLsFnc" "comLsDcl" "comRtFnc" "comRtDcl" "comRtAr" "comNamAr")
;				(list comLsFnc comLsDcl comRtFnc comRtDcl comRtAr comNamAr)
;				"01" "ComLsp"
;			)
			;br..
			(setq comAr0 (strcat comRtAr comNamAr ".lsp")
				comOpAr0 (open comAr0 "w")
			)
			;;Abre archivo para lisp
			(cond
				(
					(= (LsType comLsFnc) 'STR)
					(setq comCon1 0
						comCon2 0)
					;br
;					(brkstep1
;						'("comNamAr" "comOpAr0")
;						(list comNamAr comOpAr0)
;						"02" "ComLsp"
;					)
					;br..
					(while (< comCon1 (length comLsFnc))
						(setq comOpFnc nil)
						(setq comNamFnc (strcat comRtFnc (nth comCon1 comLsFnc))
							comOpFnc (open comNamFnc "r")
						)
						;br
;						(brkstep1
;							'("comNamFnc" "comOpFnc")
;							(list comNamFnc comOpFnc)
;							"03" "ComLsp"
;						)
						;br..
						(cond
							(
								(not (= comOpFnc nil))
								(setq comPasFnc 1)
								(while (= comPasFnc 1)
									(setq comFnLn (read-line comOpFnc))
									;br
;									(brkstep1 '("comFnLn") (list comFnLn) "04" "ComLsp")
									;br..
									(cond
										(
											(= comFnLn nil)
											(setq comPasFnc 0)
										)
										(
											(= comMod 1)
											(write-line comFnLn comOpAr0)
										)
										(
											(= (QuiTx "\t" comFnLn) nil)
											
										)
										(
											(not (= (substr (QuiTx "\t" comFnLn) 1 1) ";"))
											;br
;											(brkstep1
;												'("comFnLn")
;												(list comFnLn)
;												"04a" "ComLsp"
;											)
											;br..
											(write-line comFnLn comOpAr0)
										)
									)
								)
								(close comOpFnc)
								(setq comCon2 (+ comCon2 1))
							)
						)
						(setq comCon1 (+ comCon1 1))
					)
				)
			)
			(close comOpAr0)
			(cond
				(
					(< 0 comCon2)
					;br
;					(brkstep1
;						'("comRes" "comAr0")
;						(list comRes comAr0)
;						"04b" "ComLsp"
;					)
					;br..
					(setq comRes
						(append comRes (list comAr0))
					)
				)
			)
			;;;;;;;;;;;;;ESCRITURA DCL*****
			(setq comAr1 (strcat comRtAr comNamAr ".dcl"))
			(setq comOpAr (open comAr1 "w"))
			(setq comCon2 0)
			;br
;			(brkstep1
;				'("comAr1" "comOpAr")
;				(list comAr1 comOpAr)
;				"05" "ComLsp"
;			)
			;br..
			(cond
				(
					(and
						(not (= comOpAr nil))
						(= (LsType comLsDcl) 'STR)
					)
					(setq comCon1 0)
					(while
						(< comCon1 (length comLsDcl))
						;br
;						(brkstep1 '("comRtDcl" "comCon1" "comLsDcl")
;							(list comRtDcl comCon1 comLsDcl)
;							"06" "ComLsp"
;						)
						;br..
						(setq comOpDcl
							(strcat comRtDcl (nth comCon1 comLsDcl))
						)
						;br
;						(brkstep1 '("comOpDcl") (list comOpDcl) "07" "ComLsp")
						;br..
						(setq comOpDcl
							(open
								comOpDcl
								"r"
							)
						)
						;br
;						(brkstep1 '("comOpDcl")
;							(list comOpDcl) "08"
;							"ComLsp"
;						)
						;br..
						(cond
							(
								(not (= comOpDcl nil))
								(setq comCon2 (+ comCon2 1))
								(setq comPasFnc 1)
								(while (= comPasFnc 1)
									(setq comDclLn
										(read-line comOpDcl)
									)
									;br
;									(brkstep1
;										'("comDslLn")
;										(list comDclLn)
;										"09" "ComLsp"
;									)
									;br..
									(cond
										(
											(= comDclLn nil)
											(setq comPasFnc 0)
										)
										(
											(= comMod 1)
											(write-line comDclLn comOpAr)
										)
										(
											(= (QuiTx "\t" comDclLn) nil)
											(write-line comDclLn comOpAr)
										)
										(
											(not
												(and
													(equal
														(substr (QuiTx "\t" comDclLn)  1 1)
														"/"
													)
													(equal (substr comDclLn 2 1) "/")
												)
											)
											(write-line comDclLn comOpAr)
										)
									)
								)
								(close comOpDcl)
							)
						)
						(setq comCon1 (+ comCon1 1))
					)
					(close comOpAr)
					(cond
						(
							(< 0 comCon2)
							;br
;							(brkstep1
;								'("comAr1")
;								(list comAr1)
;								"10" "ComLsp"
;							)
							;br..
							(setq comRes (append comRes (list comAr1)))
						)
					)
				)
			)
		)
	)
	(setq comRes comRes)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:MDAT
;;OBJETO / TITULO: LsType Define el tipo de datos en una lista
;;DESCRIPCION: Analiza cada tipo de dato de una lista
;;	y devuelve el tipo de dato en caso de que todos los 
;;	tipo de elementos en la lista sean iguales
;;	>
;;DEVUELVE:lsT.
;;	> "STR". Si todos los elementos de la lista
;;		son de tipo string
;;	> "NUM". Si todos los elementons de la lista
;;	son de tipo numerico (real o int)
;;	> "VAR" Si existe mas de un tipo en los elementos
;;	de la lista.
;;	> "PAR" Si es un par punteado (xx . xx)
;;	> nil. Si el argumento no es una lista
;;ARGUMENTOS
;;	1. lsList0. Lista de trabajo
;;	> (x xx xx …)
;;DEPENDIENTES
;;	<(brkstep1)>
;;LOCALIZACION
;;	<>
;;HISTORIAL DE CORRECCIONES
;;	>2022.01.24: Arreglo para condicion de par punteado
;;ANOTACIONES
;;	>
;;ESTADO
;;	> ok
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun LsType
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
;;PROYECTO: Lisp
;;CLASIFICACION:TXT
;;OBJETO / TITULO:QuiTx. Elimina el caracter indicado en una cadena de texto
;;DESCRIPCION:
;;	>QuiTx. Apartir de la definicion de un caracter los elimina de
;;	una cadena de texto tambien definida en argumento.
;;DEVUELVE:
;;	> quTxFn. Misma cadena de texto pero sin los caracteres
;;	que correspondan al caracter definido en el argumento o nil
;;	si toda la cadena contiene el caracter.
;;	<STR / nil >
;;ARGUMENTOS
;;	1.quTxNo0. Caracter para eliminar de la cadena de texto
;;	> <STR>
;;	2.quTxWk0. Cadena de texto 
;; > <STR>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> para los tabs el caracter es "\t"
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun QuiTx
	(quTxNo0  quTxWk0 /
		quTxNo quTxWk quCon1 quPas quTxFn
	)
	;(setq quTxNo nil quTxWk nil quCon1 nil
	;	quPas nil quTxFn nil
	;)
	;(brkstep1 '("quTxNo0" "quTxWk0") (list quTxNo0 quTxWk0) "00" "QuiTx")
	(cond
		(
			(and (= (type quTxNo0) 'STR)
				(= (type quTxWk0) 'STR)
			)
			(setq quTxNo quTxNo0
				quTxWk quTxWk0
			)
			;(brkstep1 '("quTxNo" "quTxWk") (list quTxNo quTxWk) "01" "QuiTx")
			(setq quCon1 1)
			(setq quPas 1)
			(while
				(and (= quPas 1)
					(<= quCon1 (strlen quTxWk))
				)
				;(brkstep1 '("quTxNo" "(substr quTxWk quCon1 1)")
				;	(list quTxNo (substr quTxWk quCon1 1))
				;	"02" "QuiTx"
				;)
				(cond
					(
						(not
							(= (substr quTxWk quCon1 1)
								quTxNo
							)
						)
						(setq quTxFn
							(substr quTxWk quCon1 1)
							quPas 0
						)
					)
				)
				(setq quCon1 (+ quCon1 1))
			)
			(while (<= quCon1 (strlen quTxWk))
				(cond
					(
						(not (= (substr quTxWk quCon1 1) quTxNo))
						(setq quTxFn (strcat quTxFn (substr quTxWk quCon1 1)))
					)
				)
				(setq quCon1 (+ quCon1 1))
			)
		)
	)
	(setq quTxFn quTxFn)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIN
;;OBJETO / TITULO: MAT22. Genera una lista POI de las intersecciones 
;;	existentes entre los elementos de la misma lista.
;;DESCRIPCION:
;;	>MAT22. Apartir de la definicion de una lista tipo POI agrupada por
;;	sus pendientes, genera una lista con del mismo tipo POI con las intersecciones
;;	que existan entre los elementos de la misma.
;;DEVUELVE:
;;	> Lista de lineas formato POI con intersecciones por cada linea agrupada por
;;	su pendiente <( ( (p o i (xy1) (xyInt) (...) ... (xy2)) (...) ...) (...) ...)>
;;	> nil. Cuando los argumento no cumplen con el formato, solo existe
;;	un grupo de pendiente en la lista inicial.
;;ARGUMENTOS
;;	1.maLsIn0. Lista inicial de lineas generada con MAT10
;;	agrupadas por su pendiente.
;;	<( ( (p o i (xy) (xy)) ... ) (...) )>
;;	2.maPre0. Precision de comparacion numerica <INT. Numero de decimales>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> El orden de las coordenadas sera
;	En pendiente 0.- De menor a mayor conforme a las X
;	En pendiente "nop".- De mayor a menor conforme a las Y
;	En pendiente negativa.- De menor a mayor conforme a las X
;	En pendiente positive.- De menor a mayor conforme a las X
;; Procedimiento:
;	1.Apartir de una lista tipo (poi () ()) aplica MAT2 por cada grupo de 
;	lineas (por pendiente) con los demas grupos.
;	2. Extrae la lista (variantes) de Handlet, por cada Handlet agrupa las
;	coordenadas
;	3. Ordena y elimina repetidas dejando por cada entidad una lista
;	de coordenadas con todas las intersecciones que tenga
;; Formato POI:
;	( ( (pendiente ordenada al origen Handlet (XYinicial) (XYinterseccion) (...) (XYfinal)) (...) ...) (...) ...)
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mat22
	(maLsIn0 maPre0 /
		maLsIn maPre
		maVar maPred mCon1 mCon2 mCon3 maLsFin maLs0 maLs1
		maLs2 maLs3 mCon4 maLs4 maLs5 mVarFn maLs10
	)
;	(setq maLsIn nil maPre nil
;		maVar nil mCon1 nil mCon2 nil mCon3 nil maLsFin nil maLs0 nil
;		maLs1 nil maLs2 nil maLs3 nil mCon4 nil maLs4 nil maLs5 nil mVarFn nil
;		maLs10 nil
;	)
	;;
;	(brkstep1 '("maLsIn0" "maPre0") (list maLsIn0 maPre0) "00" "MAT22")
	;;
	(cond
		(
			(and
				(= (type maLsIn0) 'LIST)
				(= (type maPre0) 'INT)
			)
			(setq maLsIn maLsIn0
				maPre maPre0
			)
			(setq maVar (getvar "osmode"))
			(setvar "osmode" 8)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			(cond
				(
					(=  maPre nil)
					(setq maPred 0.00015)
				)
				(
					(< 0 maPre)
					(setq maPred
						(expt 10.0 (* -1 maPre))
					)
				)
				(
					(= maPre 0)
					(setq maPred 0.15)
				)
			)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			(setq mCon1 0)
			(while (< mCon1 (length maLsIn))
				(setq mCon2 0
					maLs1 nil
				)
				(while (< mCon2 (length maLsIn))
					;;
;					(brkstep1 '("mCon1" "mCon2") (list mCon1 mCon2) "01" "MAT22")
					;;
					(cond
						(
							(not (= mCon2 mCon1))
							(setq maLs0 (mat2 (nth mCon1 maLsIn) (nth mCon2 maLsIn) (list 3 4) 3))
							;;
;							(brkstep1 '("maLs0") (list maLs0) "02" "MAT22")
							;;
							(cond
								(
									(not (= maLs0 nil))
									(setq maLs1 (append maLs1 maLs0))
									;;
;									(brkstep1 '("maLs1") (list maLs1) "03" "MAT22")
									;maLs1. Lista de intersecciones de una pendiente
									; con las demas <((poi ()()...()) ()...)>
								)
							)
						)
					)
					(setq mCon2 (+ mCon2 1))
				)
				;;
;				(brkstep1 '("maLs1") (list maLs1) "04" "MAT22")
				;maLs1. Lista de intersecciones de una pendiente
				; con las demas <((poi ()()...()) ()...)>
				(cond
					(
						(not (= maLs1 nil))
						(setq mVarFn (lva0 maLs1 3 1 maPre)
							mCon3 0
							maLs4 nil
						)
						;;Lista de variantes de entidad
;						(brkstep1 '("mVarFn") (list mVarFn) "05" "MAT22")
						;; mVarFn. Lista de variantes de entidad por de una pendiente
						;	("xx" ...)
						(while (< mCon3 (length mVarFn))
							(setq maLs2 (lnpo (nth mCon3 mVarFn) maLs1 2 1)
								mCon4 0
								maLs3 nil
							)
							(setq maLs10 (cut 0 2 (nth 0  maLs2)))
							;;Lista de coordenadas por entidad
;							(brkstep1 '("maLs2" "maLs10") (list maLs2 maLs10) "06" "MAT22")
							;maLs1 Lista P O I de entidad <(p o i)>
							;maLs2 Lista (POI () ()...()) de endidad
							(while (< mCon4 (length maLs2))
								(setq maLs3
									(append
										maLs3 (cdddr (nth mCon4 maLs2))
									)
									mCon4 (+ mCon4 1)
								)
							)
							;;;;ordena
							(cond
								(
									(EqLs (nth 1 maLs10) 0.00 0 maPred)
									(setq maLs3 (orden4 maLs3 0 0 maPre))
									;; De menor a mayor conforme a X
;									(brkstep1 '("maLs3") (list maLs3) "06A" "MAT22")
									;;
								)
								(	
									(< (nth 1 maLs10) 0.0)
									(setq maLs3 (orden4 maLs3 0 0 maPre))
									;; De menor a mayor conforme a X
;									(brkstep1 '("maLs3") (list maLs3) "06B" "MAT22")
									;;
								)
								(
									(> (nth 1 maLs10) 0.0)
									(setq maLs3 (orden4 maLs3 0 0 maPre))
									;; De menor a mayor conforme a X
;									(brkstep1 '("maLs3") (list maLs3) "06C" "MAT22")
									;;
								)
								(
									(= (nth 1 maLs10) "nop")
									(setq maLs3 (orden4  maLs3 1 1 maPre))
									;;	De mayor a menor conforme a Y
;									(brkstep1 '("maLs3") (list maLs3) "06D" "MAT22")
									;;
								)
							)
							;;;;ordena
							(setq maLs3 (append maLs10 maLs3))
							;;
;							(brkstep1 '("maLs3") (list maLs3) "07" "MAT22")
							;maLs3. lista (poi () ()...()) con todas la intersecciones
							; de una entidad
							(setq maLs3 (lva0 maLs3 1 0 maPre))
							;;
;							(brkstep1 '("maLs3") (list maLs3) "08" "MAT22")
							;maLs3. Lista (poi () ()...()) con intersecciones sin repetir
							;	de una entidad.
							(setq maLs4 (append maLs4  (list maLs3)))
							(setq mCon3 (+ mCon3 1))
						)
						;;
;						(brkstep1 '("maLs4") (list maLs4) "09" "MAT22")
						;maLs4. Lista ((poi () ()...()) ...) de una pendientes
						(setq maLs5 (append maLs5 (list maLs4)))
						;;
;						(brkstep1 '("maLs5") (list maLs5) "10" "MAT22")
						;maLs5. Lista total (((poi () ()...()) ...) () ...)
						;	agrupada por pendientes
					)
				)
				(setq mCon1 (+ mCon1 1))
			)
			(setvar "osmode" maVar)
		)
	)
	;;
;	(brkstep1 '("maLs5") (list maLs5) "11" "MAT22")
	;maLs5. Lista total (((poi () ()...()) ...) () ...)
	;	agrupada por pendientes
	(setq maLs5 maLs5)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO / TITULO:TXNO1. Elimina los elementos de una lista que
;;		coincidan con el argumento con presicion
;;DESCRIPCION: LispLIST_TXNO1
;;	> Apartir de una lista sencilla de datos elimina todos los elementos
;;		que sean iguales a todos los elementos definido en el argumento y
;;		con precision numerica definida en un numero decimal
;;DEVUELVE: Misma lista sin los elementos coincidentes.
;;	> (Xx xxx ....)
;;ARGUMENTOS
;;	1.txLsWk0. Lista de elementos
;;	>(xx xxx ...)
;;2.txEle0.Elemento a eliminar
;;	>xxx
;;3.txPre0.Numero de precision en comparacion numerica
;;	>xx.xx (numero decimal)
;;DEPENDIENTES
;;	>EqLs <Eq0>;
;;ANOTACIONES
;;	
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun TxNo1
	(txLsWk0 txEle0 txPre0 /
		txLsFn txCon1  txVarP
	)
;	(setq txLsWk nil txEle nil txPre nil
;		txLsFn nil txCon1 nil txVarP nil
;	)
	(setq txCon1 0)
	(setq txVarP (getvar "luprec"))
	(setvar "luprec" 8)
	;;
;	(brkstep1
;		'("txLsWk0" "txEle0" "txPre0")
;		(list txLsWk0 txEle0 txPre0)
;		"00" "TxNo1"
;	)
	;;
	(cond
		(
			(and
				(= (type txLsWk0) 'LIST)
				(not (= txEle0 nil))
				(= (type txPre0) 'REAL)
			)
			(setq txLsWk txLsWk0
				txEle txEle0
				txPre txPre0
			)
			(while (< txCon1 (length txLsWk))
				;;
;				(brkstep1
;					'("(nth txCon1 txLsWk)"
;						"txEle"
;						"(EqLs (nth txCon1 txLsWk) txEle 0 txPre)"
;					)
;					(list
;						(nth txCon1 txLsWk)
;						txEle
;						(EqLs (nth txCon1 txLsWk) txEle 0 txPre)
;					)
;					"01" "Txno1"
;				)
				;;
				(cond
					(
						(not (EqLs (nth txCon1 txLsWk) txEle 0 txPre))
						(setq txLsFn (append txLsFn (list (nth txCon1 txLsWk))))
					)
				)
				(setq txCon1 (+ txCon1 1))
			)
		)
	)
	(setvar "luprec" txVarP)
	;(brkstep1 '("txLsFn") (list txLsFn) "02" "TxNo1")
	(setq txLsFn txLsFn)
)
;
;;
;;;
;;;;

;;PROYECTO: Lisp
;;CLASIFICACION: TRZ
;;OBJETO / TITULO: MuroX0. Corta  lineas entre dos grupos con la misma pendiente
;;DESCRIPCION: MuroX0. Apartir de la definicion de nombre de entidad de lineas
;;	que tengan dos pendientes corta de manera alternada en las intersecciones
;; que existan y traza la lineas alternadas seleccionadas
;;DEVUELVE:
;;	> muLsFin. Lista de nombre de entidades resultantes. <(ename...)>
;;ARGUMENTOS
;;	1. muLsNom0. Lista de nombre de entidades de lineas. <(ename...)>
;;	2. muPrec0. Presicion de comparación numerica. <INT. Numero de decimales>
;;	3. muMod0. Modo de eliminado de lineas originales
;;		0. Elimina las lineas originales
;;		1. Conserva las lineas originales
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun MuroX0
	(muLsNom0 muPrec0 muMod0 /
		muLsNom muPrec muMod
		muVarOs muPred muLnSl muLnNom muLnLs muLnInt1 muLnInt2
		muCon1 muCon2 muLsWk muPos muWk0 muWk1 muWk2 muPas1
		muGpo muLsEnt muAns muCon3 muCon0 muCon4 muCon5 muLsWk0 muEleWk
		muLsEntFn muIdWk muColor muTpLyn muIdProp muCon0 muLsWk1
	)
;	(setq
;		muLsNom nil muPrec nil muMod nil
;		muVarOs nil muPred nil
;		muLnSl nil muLnNom nil muLnLs nil muLnInt1 nil muLnInt2 nil
;		muCon1 nil muCon2 nil muLsWk nil muPos nil muWk0 nil muWk1 nil
;		muWk2 nil muPas1 nil muGpo nil muLsEnt nil muAns nil muCon3 nil
;		muCon0 nil muCon4 nil muCon5 nil muLsWk0 nil muEleWk nil muLsEntFn nil
;		muIdWk nil muColor nil muTpLyn nil muIdProp nil muCon0 nil muLsWk1 nil
;	)
	;;
;	(brkstep1 '("muLsNom0" "muPrec0") (list muLsNom0 muPrec0) "00" "MuroX0")
	;;
	(cond
		(
			(and
				(= (LsType muLsNom0) 'ENAME)
				(= (type muPrec0) 'INT)
				(= (type muMod0) 'INT)
			)
			(setq muLsNom muLsNom0
				muPrec muPrec0
				muMod muMod0
			)
			(setq muVarOs (getvar "osmode"))
			;MuVarOs. Variable osnap existente
			;;;Definicion de precision;;;(0)
			(cond
				(
					(=  muPrec nil)
					(setq muPred 0.00015)
				)
				(
					(< 0 muPrec)
					(setq muPred
						(expt 10.0 (* -1 muPrec))
					)
				)
				(
					(= muPrec 0)
					(setq muPred 0.15)
				)
			)
			;;;Definicion de precision;;;(1)
			(setq muLnLs (mat10 muLsNom))
			;;
;			(brkstep1 '("muLnLs" "(length muLnLs)")
;				(list muLnLs (length muLnLs))
;				"01" "MuroX0"
;			)
			;;
			;MuLnLs. Lista de datos de lineas agrupados por sus pendientes.
			;<( ((p o i (xy) (xy)) ...) (...))>
			(cond
				(
					(< 1 (length muLnLs))
					(setq muLnInt1 (mat2 (nth 0 muLnLs) (nth 1 muLnLs) (list 3 4) 4)
						muLnInt2 (mat2 (nth 1 muLnLs) (nth 0 muLnLs) (list 3 4) 4)
						muLsWk muLnInt1
					)
					;;
;					(brkstep1
;						'("muLnInt1" "muLsWk" "muLnInt2")
;						(list muLnInt1 muLsWk muLnInt2)
;						"02" "MuroX0"
;					)
					;;
					;muLnInt1. Lista de primer grupo con intersecciones
					;;<((p o i (xy) (xyInt) ... (xy)) ...)>
					;muLsWk. Lista de primer grupo con intersecciones para trabajo
					;;<((p o i (xy) (xyInt) ... (xy)) ...)>
					;muLnInt2. Lista de segundo grupo con intersecciones
					;;<((p o i (xy) (xyInt) ... (xy)) ...)>
					(repeat 2
;						(brkstep1 '("muLsWk") (list muLsWk) "03" "MuroX0")
						(setq muCon0 0)
						(while (< muCon0 (length muLsWk))
							(setq muLsWk1
								(append muLsWk1
									(list
										(append
											(cut 0 2 (nth muCon0 muLsWk))
											(lva0
												(cut 3
													(- (length (nth muCon0 muLsWk)) 1)
													(nth muCon0 muLsWk)
												)
												1 0 7
											)
										)
									)
								)
							)
							(setq muCon0 (+ muCon0 1))
;							(brkstep1 '("muLsWk1") (list muLsWk1) "04" "MuroX0")
						)
						(setq muLsWk muLsWk1)
;						(brkstep1 '("muLsWk") (list muLsWk) "05" "MuroX0")
						(cond
							((= (nthx (list 0 0) muLsWk) "nop") (setq muPos 1))
							((EqLs (nthx (list 0 0) muLsWk) 0 0 0.00001) (setq muPos 0))
							((< (nthx (list 0 0) muLsWk) 0) (setq muPos 0))
							((> (nthx (list 0 0) muLsWk) 0) (setq muPos 0))
						)
						;;
;						(brkstep1 '("muPos") (list muPos) "06" "MuroX0")
						;;muPos. Posicion de orden
						; <1 = sobre Y; 0 = sobre X>
						;;Orden de coordenadas (0)
						(setq muCon0 0)
						(while (< muCon0 (length muLsWk))
							(setq muLsWk0
								(append muLsWk0
									(list (orden4 (cdddr (nth muCon0 muLsWk)) 0 muPos 5))
								)
							)
							(setq muIdWk
								(append muIdWk
									(list (nthx (list muCon0 2) muLsWk))
								)
							)
							;;
;							(brkstep1
;								'("muLsWk0" "muIdWk")
;								(list muLsWk0 muIdWk)
;								"07" "MuroX0"
;							)
							;;muLsWk0. Lista de coordenadas ordenadas de una
							;	pendiente
							;<(((xy) (xyInt)...(xy))...)>
							;;muIdWk. Lista de handle de la lista de trabajo muLsWk
							;<("xxx" ...)>
							(setq muCon0 (+ muCon0 1))
						)
						;;
;						(brkstep1 '("muLsWk0") (list muLsWk0) "08" "MuroX0")
						;;
						(setq muLsWk muLsWk0)
						;;Orden de coordenadas (1);;;
						(setq muCon1 0)
						;;
;						(brkstep1 '("muLsWk") (list muLsWk) "09" "MuroX0")
						;;
						;muLsWk. Nueva lista de trabajo (coordenadas)
						;<(((xy) (xyint) ... (xy)) ...)>
						(while (< muCon1 (length muLsWk))
							(setq muEleWk (nth muCon1 muLsWk)
								muCon4 1
							)
							;;
;							(brkstep1 '("muEleWk") (list muEleWk) "10" "MuroX0")
							;;muEleWk. Elemento no. muCon1 de muLsWk
							;<((xy) (xyint) ... (xy))>
							(while (< muCon4 (length muEleWk))
								(setq muWk0
									(list (nth (- muCon4 1) muEleWk) (nth muCon4 muEleWk))
								)
								;;
;								(brkstep1 '("muWk0") (list muWk0) "11" "MuroX0")
								;;muWk0. Lista de par de coordenadas (segmento)
								;	extraido de muEleWk
								;<((xy) (xy))>
								(cond
									(
										(not (= (* (fix (/ muCon4 2)) 2) muCon4))
										(setq muWk1 (append muWk1 (list muWk0)))
										;;
;										(brkstep1 '("muWk1") (list muWk1) "12" "MuroX0")
										;;
										;muWk1. Lista de coordenadas de linea segmentada
										; "non" ;<(((xy)(xy)) (....) ....)>
									)
									(
										(= (* (fix (/ muCon4 2)) 2) muCon4)
										(setq muWk2 (append muWk2 (list muWk0)))
										;;
;										(brkstep1 '("muWk2") (list muWk2) "13" "MuroX0")
										;;
										;muWk2. Lista de coordenadas de linea segmentada
										; "par" ;<(((xy)(xy)) (....) ....)>
									)
								)
								(setq muCon4 (+ muCon4 1))
							)
							(setq muCon1 (+ muCon1 1))
						)
						;;
;						(brkstep1 '("muWk1" "muWk2") (list muWk1 muWk2) "14" "MuroX0")
						;;
						(cond
							(
								(or (not (= muWk1 nil)) (not (= muWk2 nil)))
								(setq muPas1 1
									muGpo muWk2
								)
								(while (= muPas1 1)
									(cond
										(
											(= muGpo muWk2)
											(setq muGpo muWk1)
											;;
;											(brkstep1 '("muGpo") (list muGpo) "15" "MuroX0")
											;;
										)
										(
											(= muGpo muWk1)
											(setq muGpo muWk2)
											;;
;											(brkstep1 '("muGpo") (list muGpo) "16" "MuroX0")
											;;
										)
									)
									(setq muCon2 0)
									(setvar "osmode" 0)
									(setq muLsEnt nil)
									(while (< muCon2 (length muGpo))
										(setq muColor (getvar "CECOLOR")
											muTpLyn (getvar "CELTYPE")
										)
										;;
;										(brkstep1
;											'("muColor" "muTpLyn")
;											(list muColor muTpLyn)
;											"17" "MuroX0"
;										)
										;
										(setvar "CECOLOR" "ByLayer")
										(setvar "CELTYPE" "ByLayer")
										(command "LINE"
											(cortxt (nthx (list muCon2 0) muGpo))
											(cortxt (nthx (list muCon2 1) muGpo))
											""
										)
										(command ^^c)
										(setvar "CECOLOR" muColor)
										(setvar "CELTYPE" muTpLyn)
										(setq muLsEnt (append muLsEnt (list (entlast))))
										(cam1 muLsEnt (cons 62 1))
										(setq muCon2 (+ muCon2 1))
									)
									(setvar "osmode" muVarOs)
									;;
;									(brkstep1 '("muLsEnt") (list muLsEnt) "18" "MuroX0")
									;;muLsEnt. Lista de nombre entidad de nuevas lineas
									;	<(ENAME ...)>
									(cond
										(
											(not (= muGpo nil))
											(initget 2 "Si No")
											(setq muAns
												(getkword
													"\nEL ARREGLO ES CORRECTO? SI/NO <ENTER PARA ANULAR>: "
												)
											)
											;;
;											(brkstep1 '("muAns") (list muAns) "19" "MuroX0")
											;;
											(cond
												(
													(= muAns "Si")
													(setq muPas1 0)
													(setq muLsEntFn (append muLsEntFn muLsEnt))
													;;
;													(brkstep1
;														'("muLsEntFn")
;														(list muLsEnFn)
;														"20" "MuroX0"
;													)
													;;muLsEntFn. Lista final de nuevas lineas
													; <(ENAME...)>
													(setq muIdWk (lb217 muIdWk)
														muIdWk (bindls (mapcar 'cdr muIdWk))
													)
													;;
;													(brkstep1
;														'("muIdWk") (list muIdWk)
;														"21" "MuroX0"
;													)
													;;muIdWk. Lista de nombre de entidad
													;	de lineas originales de una pendiente.
													;	<(ENAME ....)>
													(setq muIdProp
														(lscod (nth 0 muIdWk) '(8 62 6))
													)
													;;
;													(brkstep1
;														'("muIdProp") (list muIdProp)
;														"22" "MuroX0"
;													)
													;;muIdProp. Lista de propiedades de
													;	Primera linea original de la pendiente
													;	de trabajo muIdWk
													;	<((xx.xx) ...)>
													(cond
														(
															(= (assoc 62 muIdProp) nil)
															(cam1 muLsEnt '(62 . 256))
														)
													)
													(setq muCon5 0)
													(while (< muCon5 (length muIdProp))
														(cam1 muLsEnt (nth muCon5 muIdProp))
														(setq muCon5 (+ muCon5 1))
													)
													(setq muLsEnt nil)
													(cond
														(
															(= muMod 0)
															(setq muCon3 0)
															;(setq muIdWk (lb217 muIdWk)
															;	muIdWk
															;	(bindls (mapcar 'cdr muIdWk))
															;)
															;;
;															(brkstep1
;																'("muIdWk") (list muIdWk)
;																"23" "MuroX0"
;															)
															;;
															(while (< muCon3 (length muIdWk))
																(entdel (nth muCon3 muIdWk))
																(setq muCon3 (+ muCon3 1))
															)
														)
													)
												)
												(
													(= muAns "No")
													(setq muCon3 0)
													(while (< muCon3 (length muLsEnt))
														(entdel (nth muCon3 muLsEnt))
														(setq muCon3 (+ muCon3 1))
													)
													(setq muLsEnt nil)
												)
												(
													(= muAns nil)
													(setq muPas1 0
														muCon3 0
													)
													(while (< muCon3 (length muLsEnt))
														(entdel (nth muCon3 muLsEnt))
														(setq muCon3 (+ muCon3 1))
													)
													(setq muLsEnt nil)
												)
											)
											;;
;											(brkstep1
;												'("muPas1" "muLsEnt")
;												(list muPas1 muLsEnt)
;												"24" "MuroX0"
;											)
											;;
										)
									)
								)
							)
						)
						(setq muLsWk muLnInt2
								muWk1 nil muWk2 nil muLsWk0 nil muIdWk nil muLsWk1 nil
						)
						;;
;						(brkstep1 '("muLsWk") (list muLsWk) "25" "MuroX0")
						;;
					)
				)
			)
		)
	)
	;;
;	(brkstep1 '("muLsEntFn") (list muLsEntFn) "26" "MuroX0")
	;;muLsEnFn. Lista de nombre de entidad de nuevas lineas
	(setq muLsEntFn muLsEntFn)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO / TITULO: EXID.Extrae elementos de la lista que contengan el subelemento indice
;;DESCRIPCION: EXID. Extrae de una lista los elementos que contengan
;;	el subelemento indicado en  el argumento. 
;;DEVUELVE:
;;	> finl. Lista de elemento que contienen a su vez el subelemento 
;;	indicado en el elemento
;;	<((xxx xxx xx) ...)>
;;ARGUMENTOS
;;	1. les0. Lista (estructurada) de elementos con subelementos
;;	<((xxx xxx xxx) ...)>
;;	2. eid0. Elemento indice
;; <xxx>
;;DEPENDIENTES
;;	> EqLs (LsType (), Eq0 ());
;;ANOTACIONES
;;	> La precision es de 0.000001
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun exid
	(les0 eid0 / 
		les eid
		mod con1 con2 pas1 pas2 elc finl
	)
;	(setq les nil eid nil
;		mod nil con1 nil con2 nil pas1 nil pas2 nil elc nil finl nil
;	)
;	(brkstep1 '("les0" "eid0") (list les0 eid0) "00" "EXID")
	(cond
		(
			(and (not (= les0 nil))
				(not (= eid0 nil))
			)
			(setq les les0 eid eid0)
			(setq con1 0
				pas1 0
				finl nil
				mod 0
			)
			(while (< con1 (length les))
				(setq elc (nth con1 les)
					con2 0
					pas2 0
				)
;				(brkstep1 '("elc") (list elc) "01" "EXID")
				(cond
					(
						(= mod 0)
						(while (< con2 (length elc))
							;;
;							(brkstep1
;								'("(nth con2 elc)" "eid")
;								(list (nth con2 elc) eid)
;								"02" "EXID"
;							)
							;;
							(cond 
								(
									(EqLs (nth con2 elc) eid 0 0.001)
									(setq con2 (length elc)
										finl (append finl (list elc))
									)
								)
								(
									(not (EqLs (nth con2 elc) eid 0 0.001))
									(setq con2 (+ con2 1))
								)
							)
;							(brkstep1 '("finl") (list finl) "03" "EXID")
						)
					)
				)
				(setq con1 (+ con1 1))
			)
		)
	)
	;;
;	(brkstep1 '("finl") (list finl) "04" "EXID")
	(setq finl finl)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: ATT
;;OBJETO / TITULO: CAMTAG. Cambia el valor de una atributo a un grupo de blocks
;;DESCRIPCION:
;;	> CAMTAG. Apartir de una lista de nombres de entidad de blocks. Cambia el
;;	valor de un TAG determinado en todos los blocks. 
;;DEVUELVE:
;;	> 
;;ARGUMENTOS
;;	1. lsnb0. Lista de nombre de blocks
;;	<(ENAME...)>
;;	2. tga0. Nombre del TAG
;;	<"xxx">
;; 3. vtga0. Nuevo valor del TAG.
;; <"xxx">
;;DEPENDIENTES
;;	> NXX1 (); 
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun camtag
	(lsnb0 tga0 vtga0 /
		lsnb tga vtga
		cnna tga1 nnb1 attn attn1
	)
;	(setq 
;		lsnb nil tga nil vtga nil
;		cnna nil tga1 nil nnb1 nil attn nil attn1 nil
;	)
;	(brkstep1 '("lsnb0" "tga0" "vtga0") (list lsnb0 tga0 vtga0) "00" "CAMTAG")
	(setq lsnb lsnb0
		tga tga0
		vtga vtga0
	)
	(setq cnna 0
		tga1 (cons 2 tga)
		vtga (cons 1 vtga)
	)
;	(brkstep1 '("cnna" "tga1" "vtga") (list ccna tga1 vtga) "01" "CAMTAG")
	(while (< cnna (length lsnb))
		(setq nnb1 (nth cnna lsnb))
;		(brkstep1 '("nnb1") (list nnb1) "01a" "CAMTAG")
		(setq attn (nxx1 nnb1 '(1 2))
			attn1 (exid attn tga1)
		)
;		(brkstep1 '("nnb1" "attn" "attn1") (list nnb1 attn attn1) "02" "CAMTAG")
		(cond
			(
				(not (= attn1 nil))
				(setq attn1 (nth 0 (nth 0 attn1)))
				(cam1 (list attn1) vtga)
			)
		)
		(setq cnna (+ cnna 1))
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: COO
;;TITULO: INTER. Encuentra la interseccion entre dos lineas
;;OBJETO: INTER. A partir de la definicion de cuatro coordenadas,
;;	donde las dos primeras corresponden a la primera recta y las dos
;;	ultimas corresponden a la segunda linea; define la coordenada de
;;	interseccion.
;;	> Con precision de numero entero que define el numero de decimales.
;;DEVUELVE:
;;	> Lista (XY) de coordenada de interseccion.
;;ARGUMENTOS
;;	1. P1L10. Coordenada1 de linea1
;;	> (XY) o (XYZ)
;;	2.	P2LL10. Coordenada2 de linea1
;;	>	(XY) o (XYZ)
;;	3. P1L20. Coordenada1 de linea2
;;	>	(XY) o (XYZ)
;;	4.	P2L20. Coordenada2 de linea2
;;	> (XY) o (XYZ)
;;	5. PREZI0. Numero de decimales de precision numerica
;;	> Numero entero.
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;
(defun inter
	(p1l10 p2l10 p1l20 p2l20 prezi0 /
		p1l1 p2l1 p1l2 p2l2 prezi pedis facmb1 facmb2 varmb m01 m02
		b01 b02 nomin denom resul resulx resuly
	)
	;;
;	(brkstep1 '("p1l10" "p2l10" "p1l20" "p2l20" "prezi0")
;		'(p1l10 p2l10 p1l20 p2l20 prezi0)
;		"00" "inter"
;	)
;	(setq p1l1 nil p2l1 nil p1l2 nil p2l2 nil prezi nil predis nil
;		facmb1 nil facmb2 nil varmb nil m01 nil m02 nil
;		b01 nil b02 nil nomin nil
;		denom nil resul nil resulx nil resuly nil
;	)
	;;
	(cond
		(
			(and
				(equal (type p1l10) 'LIST)
				(equal (type p2l10) 'LIST)
				(equal (type p1l20) 'LIST)
				(equal (type p2l20) 'LIST)
				(equal (type prezi0) 'INT)
			)
			(setq p1l1 (list (nth 0 p1l10) (nth 1 p1l10))
				p2l1 (list (nth 0 p2l10) (nth 1 p2l10))
				p1l2 (list (nth 0 p1l20) (nth 1 p1l20))
				p2l2 (list (nth 0 p2l20) (nth 1 p2l20))
				prezi prezi0
			)
			;;
;			(brkstep1
;				'("p1l1" "p2l1" "p1l2" "p2l2" "prezi")
;				(list p1l1 p2l1 p1l2 p2l2 prezi)
;				"01" "INTER"
;			)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			(cond
				(
					(=  prezi nil)
					(setq pedis 0.00015)
				)
				(
					(< 0 prezi)
					(setq pedis
						(expt 10.0 (* -1 prezi))
					)
				)
				(
					(= prezi 0)
					(setq pedis 0.15)
				)
			)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			(setq varmb (getvar "luprec"))
			(setvar "luprec" 8)
			(setq facmb1 (mbpend p1l1 p2l1 prezi)
				facmb2 (mbpend p1l2 p2l2 prezi)
			)
			;;
;			(brkstep1
;				'("facmb1" "facmb2")
;				(list facmb1 facmb2)
;				"02" "INTER"
;			)
			;;
			(cond
				(
					(and (not (= facmb1 nil))
						(not (= facmb2 nil))
					)
					(setq b01 (nth 1 facmb1)
						m01 (nth 0 facmb1)
					)
					(setq b02 (nth 1 facmb2)
						m02 (nth 0 facmb2)
					)
					(setq nomin (- b02 b01)
						denom (- m01 m02)
						resulx (/ nomin denom)
					)
					(setq resuly (+ (* resulx m01) b01))
					;;
;					(brkstep1
;						'("resulx" "resuly")
;						(list resulx resuly)
;						"03a" "INTER"
;					)
					;;
				)
				(
					(= facmb1 nil)
					(setq resulx (nth 0 p1l1))
					(setq m02 (nth 0 facmb2))
					(setq b02 (nth 1 facmb2))
					(setq resuly (+ (* m02 resulx) b02))
					;;
;					(brkstep1
;						'("resulx" "resuly")
;						(list resulx resuly)
;						"03b" "INTER"
;					)
					;;
				)
				(
					(= facmb2 nil)
					(setq resulx (nth 0 p1l2))
					(setq m01 (nth 0 facmb1))
					(setq b01 (nth 1 facmb1))
					(setq resuly (+ (* m01 resulx) b01))
					;;
;					(brkstep1
;						'("resulx" "resuly")
;						(list resulx resuly)
;						"03c" "INTER"
;					)
					;;
				)
			)
			;;
;			(brkstep1
;				'("b01" "b02" "m01" "m02")
;				(list b01 b02 m01 m02)
;				"03" "INTER"
;			)
			;;
			(setq resulx (round1 resulx prezi))
			(setq resuly (round1 resuly prezi))
			(setvar "luprec" varmb)
			(setq resul (list resulx resuly))
		)
	)
	;;
;	(brkstep1 '("resul") (list resul) "04" "INTER")
	;;
	(setq resul resul)
)
;;PROYECTO: Lisp
;;CLASIFICACION: COO
;;TITULO: CORIN. Verifica si un punto se encuentra dentro de una recta.
;;DESCRIPCION: CORIN. Apartir de la definicion de la lista de coordenadas
;;	de una recta y verifica si un punto (coordenada) se encuentra
;;	dentro de una recta.
;;	>
;;DEVUELVE: 0 Si el punto no se encuentra dentro de la recta; 1 Si el punto
;;		se encuentra dentro de la recta.
;;	> 
;;ARGUMENTOS
;;	1.LCOR0. Lista de coordenadas de la recta
;;	> ((XYZ) (XYZ))
;;	2.pto10. Punto de comparacion
;; > (XYZ)
;;	3.PREC0. Numero de decimales de precision predeterminado 3
;;	maximo 5
;;	> Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Distancia (P1 Pc) + (Pc P2) = P1 P2
;;	> Tiene un factor de error de 0.0005
;;;(brkstep '("") "001TEMP" "")
(defun corin
	(lcoor0 pto10 prec0 /
		lcoor pto1 prec
		resa ds1 ds2 ds3 pred varpre
	)
;	(setq lcoor nil pto1 nil prec nil
;		resa nil ds1 nil ds2 nil ds3 nil pred nil varpre nil	
;	)
	;;
;	(brkstep1
;		'("lcoor0" "pto10" "prec0")
;		(list lcoor0 pto10 prec0)
;		"00" "CORIN"
;	)
	;;
	(cond
		(
			(and
				(= (type lcoor0) 'LIST)
				(= (type pto10) 'LIST)
				(= (type prec0) 'INT)
			)
			(setq lcoor lcoor0
				pto1 pto10
				prec prec0
			)
			;;
;			(brkstep1
;				'("lcoor" "pto1" "prec") (list lcoor pto1 prec)
;				"01" "CORIN"
;			)
			;;
			(setq varpre (getvar "luprec"))
			(setvar "luprec" 8)
			(setq resa 0)
			(cond
				(
					(=  prec nil)
					(setq pred 0.00015)
				)
				(
					(< 0 prec)
					(setq pred
						(expt 10.0 (* -1 prec))
					)
				)
				(
					(= prec 0)
					(setq pred 0.15)
				)
			)
			;;;;
;			(brkstep1 '("pred") (list pred) "02" "CORIN")
			;;
			(setq ds1 (distance (nth 0 lcoor) pto1)
				ds2 (distance (nth 1 lcoor) pto1)
				ds3 (distance (nth 0 lcoor) (nth 1 lcoor))
			)
			;;
;			(brkstep1
;				'("ds1" "ds2" "ds3" "(+ ds1 ds2)" "Igualdad")
;				(list ds1 ds2 ds3 (+ ds1 ds2)
;					(EqLs (+ ds1 ds2) ds3 0 pred)
;				)
;				"01" "CORIN"
;			)
			;;ds1. Distancia primer punto de linea al punto de comparacion
			;;ds2. Distancia segundo punto de linea al punto de comparacion
			;;ds3. Distancia total de linea
			(cond
				(
					(or
						(EqLs (nth 0 lcoor) pto1 0 pred)
						(EqLs (nth 1 lcoor) pto1 0 pred)
					)
					(setq resa 1)
				)
				(
					(and
						(EqLs (+ ds1 ds2) ds3 0 pred)
						(EqLs
							(angle (nth 0 lcoor) pto1)
							(angle pto1 (nth 1 lcoor))
							0 pred
						)
					)
					(setq resa 1)
				)
			)
			(setvar "luprec" varpre)
		)
	)
	(setq resa resa)
)
;
;;
;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;ParCoo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;1. paCo10. Coordenada1
					;2. paCo20. Coordenada2
					;3. paCo00. Coordenada de aplicacion
					;4. paDist. Distancia de aplicacion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: TRZ
;;OBJETO:ParCoo. Define el par de coordenadas de una paralela, apartir
;;	de la definicion de una linea, polilineas o dos puntos.
;;	> 
;;DEVUELVE: paFnCo. Lista de par de coordenadas paralelas
;;	> ((XYZ) (XYZ))
;;ARGUMENTOS
;;	1. Coordenada 1
;;	> (xyz)
;;	2. Coordenada 2
;;	> (xyz)
;;	3. Coordenada que indica el lado
;;	> (xyz)
;; 4. paDist0. Distancia entre lineas paralelas.
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun ParCoo
	      (paCo10	 paCo20	   paCo00    paDist0   /
	       paCo1	 paCo2	   paCo0     paDist    paAnOr
	       PaAnPer1	 paAnPer0  paCoInt   paCoPer   paFnCoo
	      )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;	(setq paCo1 nil paCo2 nil paCo0 nil paDist nil paAnOr nil paCoInt nil paCoPer nil
					;		ejCooPar nil paAnPer0 nil paFnCoo nil
					;	)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;	(brkstep
					;		'("paCo10" "paCo20" "paCo00" "paDist0")
					;		"00" "ParCoo"
					;	)
  (cond
    (
     (and
       (= (type paCo10) 'LIST)
       (= (type paCo20) 'LIST)
       (= (numberp paDist0) t)
     )
     (setq paCo1  paCo10
	   paCo2  paCo20
	   paCo0  paCo00
	   paDist paDist0
     )
					;			(brkstep '("paCo1" "paCo2" "paDist") "01" "ParCoo")
     (setq paAnOr   (angle paCo1 paCo2)
	   paAnPer0 (sumang paAnOr 1.5707963267949)
     )
					;			(brkstep '( "paAnOr" "paAnPer0" "(polar paCo0 paAnPer0 1)")
					;				"02" "ParCoo"
					;			)
     (setq
       paCoInt
	(inters	paCo1
		paCo2
		paCo0
		(polar paCo0 paAnPer0 1)
		nil
	)
     )
					;			(brkstep '("paAnOr" "paAnPer0" "paCoInt") "001" "ParCoo")
     (setq paAnPer1 (angle paCoInt paCo0)
	   paFnCoo
		    (list (polar paCo1 paAnPer1 paDist)
			  (polar paCo2 paAnPer1 paDist)
		    )
     )
					;			(brkstep '("paCoInt" "paAnPer1" "paFnCoo")
					;				"01" "paCoo"
					;			)
    )
  )
  (setq paFnCoo paFnCoo)
)
;;;*
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;TITULO: PREPOL1. Genera una lista de cordenadas de una polilinea
;;DESCRIPCION: PREPOL1. A partir de la definicion del nombre de entidad de una polilinea
;;	 genera la lista de coordenadas de la misma en el orden que fue creada la polilinea.
;;DEVUELVE: Lista de coordenadas
;;	> ((X Y) (X Y) ...)
;;ARGUMENTOS
;;	1.entpol0. Nombre de entidad
;;	> ENAME
;;	2.migenprec0. Precision
;;	> Numero entero (numero de decimales).
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
(defun prepol1
	(entpol0 migenprec0 /
		entpol migenprec
		mipos milprec mianprec mi
	)
;	(setq entpol nil migenprec nil
;		mipos nil milprec nil mianprec nil mi nil
;	)
	;;
;	(brkstep1 '("entpol" "migenprec")
;		(list entpol migenprec)
;		"00" "PREPOL"
;	)
	;;
	(setq milprec (getvar "luprec")
		mianprec (getvar "auprec")
	)
	(cond
		(
			(and (= (type entpol0) 'ENAME)
				(= (type migenprec0) 'INT)
			)
			(setq entpol entpol0 migenprec migenprec0)
			(setvar "luprec" 8)
			(setvar "auprec" 8)
			(setq mi entpol)
			(cond
				(
					(and
						(= (type mi) 'ENAME)
						(= (cdr (assoc 0 (entget mi))) "LWPOLYLINE")
					)
					(setq mi (lscod mi '(10))
						mi (mapcar 'cdr mi)
					)
					;;
;					(brkstep1 '("mi") (list mi) "01" "PREPOL1")
					;;
					(setq	mi (lva0 mi () 0 migenprec))
					;;
;					(brkstep1 '("mi" "Longitud de lista")
;						(list mi (length mi))
;						"01" "PREPOL"
;					)
					;;
				)
			)
		)
	)
	(setvar "luprec" milprec)
	(setvar "auprec" mianprec)
	;(brkstep1 '("mi")
	;	(list mi)
	;	"01" "PREPOL" 
	;)
	(setq mi mi)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: COO. Manipulacion de coordenadas
;;SINTAXIS: (LCOOR2 [EntNamPol] [CoordLocalizacion] [precision])
;;TITULO: LCOOR2. Localiza la posicion (nth) del vertice proximo anterior
;;	a una coordenada definida
;;DESCRIPCION: LCOOR2. Apartir de la definicion de un nombre de entidad de polilinea,
;;		devuelve la ubicacion (nth) de la coordenada anterior mas proxima
;;		a la coordenada del argumento
;;	>
;;DEVUELVE:
;;	> lcIndif. Numero (nth) de coordenada proxima anterior a la coordenada
;;	de argumento o nil si la coordenada no coincide con la trayectoria.
;;ARGUMENTOS
;;	1. lcNam0. Nombre de entidad de polilinea
;;	>	ENAME
;;	2. lcCor0. Coordenada de punto de localizacion
;;	>	(X X Z) o (X Y)
;;	3. lcpp10. Precision (numero de decimales)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;***************************
(defun lcoor2
	(lcNam0 lcCor0 lcpp10 /
		lcNam lcCor lcpp1
		lcCon1 lcPsf lcTry lcP1 lcP2
		lcAuvar lcLuvar lcNumr
		lcIndif lcLsc1
	)
;	(setq lcNam nil lcCor nil lcpp1 nil
;		lcCon1 nil lcPsf nil lcTry nil 
;		lcP1 nil lcP2 nil lcAuvar nil  lcLuvar nil lcNumr nil lcIndif nil
;		lcLsc1 nil 
;	)
;;
;	(brkstep1 '("lcNam0" "lcCor0" "lcpp10")
;		(list lcNam0 lcCor0 lcpp10)
;		"00" "LCOOR2"
;	)
;;
	(cond
		(
			(and
				(not (= lcNam0 nil))
				(not (= lcCor0 nil))
				(not (= lcpp10 nil))
			)
			(setq lcNam lcNam0 lcCor lcCor0 lcpp1 lcpp10)
			(cond
				(
					(= (type lcNam) 'ENAME)
					(setq lcLsc1 (prepol1 lcNam lcpp1))
				)
			)
			;;
;			(brkstep1
;				'("lcLsc1" "lcCor" "lcpp1")
;				(list lcLsc1 lcCor lcpp1)
;				"01" "LCOOR2"
;			)
			;;
			(cond
				(
					(and
						(= (type lcLsc1) 'LIST)
						(= (type lcCor) 'LIST)
						(= (type lcpp1) 'INT)
					)
					(setq lcAuvar (getvar "auprec"))
					(setq lcLuvar (getvar "luprec"))
					;;
;					(brkstep1 '("lcAuvar" "lcLuvar" "lcpp1")
;						(list lcAuvar lcLuvar lcpp1)
;						"02" "LCOOR2"
;					)
					;;
					(cond
						(
							(=  lcpp1 nil)
							(setq lcNumr 0.00015)
						)
						(
							(< 0 lcpp1)
							(setq lcNumr
								(expt 10.0 (* -1 lcpp1))
							)
						)
						(
							(= lcpp1 0)
							(setq lcNumr 0.15)
						)
					)
					(setvar "luprec" 8)
					(setvar "auprec" 8)
					(setq lcCon1 0)
					;;
;					(brkstep1
;						'("lcpp1" "lcNumr" "lcCon1")
;						(list lcpp1 lcNumr lcCon1) "03" "LCOOR2"
;					)
					;;
					(cond
						(
							(and
								(not (= lcLsc1 nil))
								(not (= lcCor  nil))
							)
							(setq lcCor (list (nth 0 lcCor) (nth 1 lcCor)))
							;**lcCor (XY)
							(while
								(< lcCon1 (- (length lcLsc1) 1))
								(setq lcP1 (nth lcCon1 lcLsc1)
									lcP2 (nth (+ lcCon1 1) lcLsc1)
								)
								(cond
									(
										(and
											(not (= lcP1 nil))
											(not (= lcP2 nil))
										)
										(setq lcP1 (list (nth 0 lcP1) (nth 1 lcP1))
											lcP2 (list (nth 0 lcP2) (nth 1 lcP2))
										)
									)
								)
								;**lcP1 (XY)
								;**lcP2 (XY)
								;;
;								(brkstep1 '("lcLsc1" "lcP1" "lcP2" "lcCor" "lcCon1")
;									(list lcLsc1 lcP1 lcP2 lcCor lcCon1)
;									"LCOOR2" "02"
;								)
								;;
								(cond
									(
										(eqCo lcP1 lcCor 0 lcNumr);correccion
										(setq lcIndif lcCon1)
										(setq lcCon1 (length lcLsc1))
										;;
;										(brkstep1 '("lcIndif" "lcCon1")
;											(list lcIndif lcCon1)
;											"LCOOR2" "02A"
;										)
										;;
									)
									(
										(eqCo lcP2 lcCor 0 lcNumr);correccion
										(setq lcIndif (+ lcCon1 1))
										(setq lcCon1 (length lcLsc1))
										;;
;										(brkstep1 '("lcIndif" "lcCon1")
;											(list lcIndif lcCon1)
;											"LCOOR2" "02B"
;										)
										;;
									)
									(
										(= (corin4 (list lcP1 lcP2) lcCor lcPp1) 1)
										(setq lcIndif lcCon1)
										(setq lcCon1 (length lcLsc1))
										;;
;										(brkstep1
;											'("lcIndif" "lcCon1"
;												"(corin4 (list lcP1 lcP2) lcCor lcPp1)"
;											)
;											(list
;												lcIndif lcCon1 (corin4 (list lcP1 lcP2) lcCor lcPp1)
;											)
;											"LCOOR2" "02C"
;										)
										;;
									)
									(
										(= (corin4 (list lcP1 lcP2) lcCor lcPp1) 0)
										(setq lcCon1 (+ lcCon1 1))
										;;
;										(brkstep1
;											'("lcIndif" "lcCon1"
;												"(corin4 (list lcP1 lcP2) lcCor lcPp1)"
;											)
;											(list lcIndif lcCon1
;												(corin4 (list lcP1 lcP2) lcCor lcPp1)
;											)
;											"LCOOR2" "02D"
;										)
										;;
									)
								)
							)
						)
					)
				)
			)
			(setvar "luprec" lcLuvar)
			(setvar "auprec" lcAuvar)
		)
	)
	;;
;	(brkstep1 '("lcIndif")
;		(list lcIndif)
;		"LCOOR2" "03"
;	)
	;;
	(setq lcIndif lcIndif)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:COO (Manipulacion de coordenadas)
;;OBJETO / TITULO :LCoo2. POSICION NTH DE COORDENADA EN POLILINEA
;;		(POLILINEA)
;;DESCRIPCION: A partir de la definicion del nombre de entidad, devuelve
;;		la ubicación (NTH) de la coordenada anterior mas proxima a la coordenada
;;		del argumento. (posicion basada en lista de coordenadas)
;;DEVUELVE: Posicion (NTH) de la coordenada proxima anterior de lista de coordenadas
;;	de polilinea.
;;	> INT
;;ARGUMENTOS
;;	1. lcEne0. Nombre de entidad de la polilinea
;;	>	ENAME
;;	2. lcCoo0. Coordenada de localizaciion
;;	>	(XYZ) o (XY)
;;	3. lcPrec0. Precicion de comparacion numerica
;;	> INT. Numero de decimalales
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun LCoo2
	(lcEne0 lcCoo0 lcPrec0 /
		lcEne lcCoo lcPrec con1 posf try p1 p2
		auvar luvar numr
		indif lsc1 lcPrecD lcCorin
	)
;	(setq lcEne nil lcCoo nil lcPrec nil
;		con1 nil posf nil try nil p1 nil p2 nil
;		auvar nil luvar nil numr nil
;		indif nil lsc1 nil lcPrecD nil lcCorin nil
;	)
;	(brkstep1 '("lcEne0" "lcCoo0" "lcPrec0")
;		(list lcEene0 lcCoo0 lcPrec0)
;		"00" "LCoo2"
;	)
	(setq auvar (getvar "auprec"))
	(setq luvar (getvar "luprec"))
	(setvar "auprec" 7)
	(setvar "luprec" 7)
	(cond
		(
			(and
				(= (type lcEne0) 'ENAME)
				(= (type lcCoo0) 'LIST)
				(= (type lcPrec0) 'INT)
			)
			(setq lcEne lcEne0
				lcCoo lcCoo0
				lcPrec lsPrec0
			)

			(cond
				(
					(= lcPrec nil)
					(setq lcPrecD 0.00015)
				)
				(
					(< 0 lcPrec nil)
					(setq lcPrecD
						(expt 10.0 (* -1 lcPrec))
					)
				)
				(
					(= lcPrec 0)
					(setq lcPrecD 0.15)
				)
			)
;			(brkstep1 '("lcPrec" "lcPrecD") (list lcPrec lcPrecD) "01" "LCoo2")
			(setq lsc1
				(mapcar 'cdr (lscod lcEne '(10)))
			)
			;;;;
;			(setq lsc1
;				(lva
;					(mapcar 'cdr (lscod lcEne '(10)))
;					0
;					0
;				)
;			)
			;;
;			(brkstep1 '("lsc1") (list lsc1) "02" "LCoo2")
			;;lsc1. Lista de coordenadas (sin repeticiones)
			;((xyz) (xyz) ...)
			(if (= lsc1 nil) (alert "LCoo2: lsc1 = nil\nBRK02"));Verifica 02
			(setq con1 0)
			(cond
				(
					(and
						(not (= lsc1 nil))
						(not (= lcCoo nil))
					)
					(setq lcCoo (list (nth 0 lcCoo) (nth 1 lcCoo)))
					;**lcCoo xy de coordenada
					;>(XY)
					(while
						(< con1 (- (length lsc1) 1))
						(setq p1 (nth con1 lsc1)
							p2 (nth (+ con1 1) lsc1)
						)
						(cond
							(
								(and
									(not (= p1 nil))
									(not (= p2 nil))
								)
								(setq p1 (list (nth 0 p1) (nth 1 p1))
									p2 (list (nth 0 p2) (nth 1 p2))
								)
							)
						)
						(setq lcCorin
							(corin4
								(list p1 p2)
								lcCoo 5
							)
						)
						;**P1 (XY) Primer punto de tramo
						;**P2 (XY) Segundo punto de tramo
						;(brkstep1 '("lsc1" "P1" "P2" "lcCoo" "con1" "IGUAL" "lcCorin")
						;	(list lsc1 p1 p2 lcCoo con1 (equal p1 coco1 lcPrecD) lcCorin)
						;	"LCoo2" "03"
						;)
						;;lcCorin. Indice de coordenada
						;;dentro de par de coordenadas
						;;(P1 P2)
						;;<0 / 1>
						(cond
							(
								(EqCo p1 lcCoo 0 lcPrecD)
								(setq indif con1)
								(setq con1 (length lsc1))
								;(brkstep1 '("indif" "con1")
								;	(list indif con1)
								;	"LCoo2" "03A"
								;)
							)
							(
								(EqCo p2 lcCoo 0 lcPrecD)
								(setq indif (+ con1 1))
								(setq con1 (length lsc1))
								;(brkstep1 '("indif" "con1")
								;	(list indif con1)
								;	"LCoo2" "03B"
								;)
							)
							(
;								(= (corin4 (list p1 p2) lcCoo 5) 1)
								(= lcCorin 1)
								(setq indif con1)
								(setq con1 (length lsc1))
								;(brkstep1
								;	'("indif" "con1" "Dentro?")
								;	(list indif con1 (corin4 (list p1 p2) lcCoo 5))
								;	"LCoo2" "03C"
								;)
							)
							(
;								(= (corin4 (list p1 p2) lcCoo 5) 0)
								(= lcCorin 0)
								(setq con1 (+ con1 1))
								;(brkstep1
								;	'("indif" "con1" "Dentro?")
								;	(list indif con1 (corin4 (list p1 p2) lcCoo 5))
								;	"LCoo2" "03D"
								;)
							)
						)
					)
				)
			)
		)
	)
	(setvar "luprec" luvar)
	(setvar "auprec" auvar)
	;(brkstep1 '("indif")
	;	(list indif)
	;	"LCoo2" "04"
	;)
	(setq indif indif)
)
;
;;
;;;
;;;;...LCOO2
;;PROYECTO: Lisp
;;CLASIFICACION: (BGL) Definiciones de curvatura
;;OBJETO: ANINC
;;	> Calcula el angulo del centro de una curva determinada
;;	dado por el Bugle
;;DEVUELVE:
;;	> Angulo expresado en radianes
;;ARGUMENTOS
;;	1. bugle
;;DEPENDIENTES
;;	>	Ninguno
;;ANOTACIONES
;;	> PR...
(defun aninc (blg)
	(* 4.0 (atan blg))
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: (MAT) Definiciones matematicaS
;;OBJETO: PPND2
;;	> Apartir de la definicion de dos puntos, calcula su pendiente
;;DEVUELVE:
;;	> Pendiente
;;ARGUMENTOS
;;	1. PP1 (x y z) ó (x y)
;;	2. PP2 (x y z) ó (x y)
;;DEPENDIENTES
;;	>	Ninguno
;;ANOTACIONES
;;	> Cuando la recta es vertical (x1 = x2) devuelve nil
;; Toma los dos primero puntos de la coordenada (x y) normalmente.
;;PR...
(defun ppnd2 (pp1 pp2 / pndi x1 x2 y1 y2 mpr1)
	(setq mpr1 (getvar "luprec"))
	(setvar "luprec" 4)
	(cond
		(
			(not (equal (nth 0 pp1) (nth 0 pp2) 0.001))
			;(brkstep
			;	'("pp1"
			;		"pp2"
			;		"(- (nth 1 pp2) (nth 1 pp1))"
			;		"(- (nth 0 pp2) (nth 0 pp1))"
			;		"(/
			;			(- (nth 1 pp2) (nth 1 pp1))
			;			(- (nth 0 pp2) (nth 0 pp1))
			;		)"
			;	)
			;	"Pendiente" "??Presicion"
			;)
			(setq x1 (atof (rtos (nth 0 pp1)))
				x2 (atof (rtos (nth 0 pp2)))
				y1 (atof (rtos (nth 1 pp1)))
				y2 (atof (rtos (nth 1 pp2)))
			)
			;(brkstep '("x1" "x2" "y1" "y2") "coordenadas" "??Precision")
			(setq pndi
				(/
					(- y2 y1)
					(- x2 x1)
				)
			)
			(if
				(= pndi 0)
				(setq pndi 0)
				(setq pndi pndi)
			)
			;(brkstep
			;	'("(/
			;		(- y2 y1)
			;		(- x2 x1)
			;		)"
			;		"pndi"
			;		"(= pndi 0)"
			;	)
			;	"precision nueva" "??"
			;)
		)
	)
	(setvar "luprec" mpr1)
	(setq pndi pndi)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: Definiciones matematicas (MAT)
;;OBJETO: ABC
;;	> Apartir de la definicion de la pendiente de la recta, su ordenada
;;	al origen, las coordenadas del centro de la circunferencia y el radio
;;	de la misma; calcula los valores A B C para la formula general de segundo grado.
;;DEVUELVE:
;;	> Lista de valores donde el primer valor corresponde a "A" el segundo a "B"
;;	y el tercero a "C"
;;ARGUMENTOS
;;	1.PEND: Pendiente de la recta.
;;	> Numero real
;;	2.ORIGEN: Ordenada al origen
;;	> Numero real (valor de Y cuando X=0)
;;	3.PTC: Coordenadas del centro de la circunferencia.
;;	4.RD: Radio de circunferencia
;;DEPENDIENTES
;;	> Ninguno
;;ANOTACIONES
;;	>	Calculos esperados en 2d
;;	>	Los valores A B C son calculados con base en la formula ordinaria
;;		de la recta (Y = MX + B), que sustituye el valor de Y en la formula
;;	 	ordinaria de la circuferencia. ((X - H)^2 + (Y - K)^2 )
;;	>	Los valores correspondientes para cada valor (A B C) son
;;		X^2 para A
;;		X para B
;;		Terminos independientes para C
;;	>	Los argumentos y variables se sustituyen de la siguiente forma:
;;		M = pend : pendiente de la recta
;;		B = origen : Ordenada al origen
;;		H = (nth 0 ptc) : Coordenada centro en X de la circunferencia
;;		K = (nth 1 ptc) : Coordenada centro en Y de la circunferencia
;;		R = rd : Radio de la circunferencia
;;	>	Quedando los siguientes valores:
;;		A = (M^2 + 1)
;;		B = (2(M)(TMD) - 2H)
;;			Donde TMD es la resolusion de ordenada al origen menos coordenada
;;			Y del centro
;;		C = (H^2 + TMD^2 - R^2)
;;;;;;;;;
(defun abc (pend origen ptc rd / tmd a b1 b2 br c1 c2 c3 cr lfine)
	(setq tmd (- origen (nth 1 ptc)))
	(setq a (+ 1 (* pend pend)))
	(setq b1 (* 2 pend tmd)
		b2 (* -1 (* 2 (nth 0 ptc)))
		br (+ b1 b2)
	)
	(setq c1 (* (nth 0 ptc) (nth 0 ptc)) ;;C = (H^2 + TMD^2 - R^2)
		c2 (* rd rd)
		c2 (* -1 c2)
		c3 (* tmd tmd)
		cr (+ c1 c2 c3)
	)
	(setq lfine (list a br cr))
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO: DISC
;;	> Discriminante de la ecuacion general de segundo grado
;;		b2-4ac
;;DEVUELVE: Resolucion de discriminante
;;	> Numero Real
;;ARGUMENTOS
;;	1. AA: Factor Cuadr?tico
;;	> Numero real
;;	2. BB: Factor Lineal
;;	> Numero real
;;	3. CC: Factor independiente
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
(defun disc (aa bb cc / tt1 tt2 ttr)
	(setq tt1 (* 4 aa cc)
		tt1 (* -1 tt1)
		tt2 (* bb bb)
		ttr (+ tt1 tt2)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO: EG11
;;	> Apartir de los valores para A B y C desarrolla y resuelve
;;		la ecuacion general de segundo grado.
;;DEVUELVE:
;;	> Lista de valor resuelto para x (+ y -)
;;ARGUMENTOS
;;	1. elea1: Valor de A (elemento de segundo grado)
;;	> Numero real
;;	2. eleb1: Valor de B (elemento lineal รณ de primero grado)
;;	> Numero real
;;	3. elec1: Valor de C (elemento independiente)
;;ANOTACIONES
;;	> Los valores de A B C son calculados en ABC, para la encontrar
;;		la interseccion entre una curva y una recta.
;;DEPENDIENTES:
;;	> DISC
;;PR...
(defun eg11 (elea1 eleb1 elec1 / di1 mb t1 t2 denom tr1 tr2 vlfin)
	(setq di1 (disc elea1 eleb1 elec1)
		di1 (sqrt di1)
		mb (* -1 eleb1)
		t1 (+ mb di1)
		t2 (- mb di1)
	)
	(setq denom (*  2 elea1)
		tr1 (/ t1 denom)
		tr2 (/ t2 denom)
		vlfin (list tr1 tr2)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: SEG
;;	> Devuelve la lista de segmentos (recta o curva) apartir de la definicion
;;	de la lista de coordenadas  y curvatura (BUGLE) extraida de una polilinea
;;DEVUELVE: Lista de segmentos
;;	>( (coordenada bugle coordenada) (...) )
;;ARGUMENTOS
;;	1. CORSEG: Lista de coordena y curvaturas, donde el primer elemento
;;	donde el primer elemento siempre sera el codigo 70
;;	(inidicador de polilinea cerrada)
;;	La estructura de la lista se obtiente con la funcion
;;	aplicada a una polilinea (lscod \ 70 10 42)
;;	> ((70 . xx) (10 . xx) (42 . xx) (10 . xx) ... (10 . xx) (42 . xx))
;;	2. MOD1: Modo de polilinea (cerrada / abierta),
;;	> En modo (1): Si la polilinea est? abierta (70 . 0), devuelve
;;	el ultimo segmento como una polilinea cerrada.
;;DEPENDIENTES
;;	> ERT ()
;;ANOTACIONES
;;	>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
(defun seg
	(corseg0 mod10 / 
		corseg mod1 con fnl fnl1 fnll verFnl1
	)
;	(setq corseg nil mod1 nil con nil fnl nil fnl1 nil fnll nil verFnl1 nil)
;	(brkstep1 '("corseg0" "mod10") (list corseg0 mod10) "00" "Seg")
	(cond
		(
			(and
				(= (type corseg0) 'LIST)
				(= (type mod10) 'INT)
			)
			(setq corseg corseg0
				mod1 mod10
			)
			(setq con 1
				finll '()
			)
			(while (< con (- (length corseg) 3))
				(setq fnl (ert corseg (list con (+ con 1) (+ con 2))))
				(setq fnl
					(list (cdr (nth 0 fnl))
						(cdr (nth 1 fnl))
						(cdr (nth 2 fnl))
					)
				)
				(setq fnll
					(append fnll (list fnl))
				)
				(setq fnl1 fnl)
				(setq con (+ con 2))
			)
;			(brkstep1 '("fnl" "fnll" "fnl1") (list fnl fnll fnl1) "01" "Seg")
			(setq verFnl1 (equal (cdr (nth 1 corseg)) (nth 2 fnl1) 0.0015))
;			(brkstep1 '("verFnl1") (list verFnl1) "02" "Seg")
			(cond
				(
					(and
						(or
							(= (cdr (nth 0 corseg)) 1)
							(= mod1 1)
						)
						(= verFnl1 nil)
					)
					(setq fnl
						(ert corseg
							(list con (+ con 1) 1)
						)
					)
;					(brkstep1 '("corseg" "fnl" "con") (list corseg fnl con) "03" "Seg")
					(setq fnl
						(list (cdr (nth 0 fnl))
							(cdr (nth 1 fnl))
							(cdr (nth 2 fnl))
						)
					)
;					(brkstep1 '("fnl") (list fnl) "04" "Seg")
					(setq fnll
						(append fnll
							(list fnl)
						)
					)
;					(brkstep1 '("fnll") (list fnll) "05" "Seg")
				)
			)
		)
	)
	(setq fnll fnll)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;OBJETO: RADIO
;;	> A partir de la definicion de los puntos de un arco y curvatura
;;	dentro de una polilinea calcula el radio de la misma.
;;DEVUELVE: Dimension del radio
;;	>
;;ARGUMENTOS
;;	1. PTA1: Coordenada1 de arco
;;	> (X Y) o (X Y Z)
;;	2. PTA1: Coordenada2 de arco
;;	> (X Y) o (X Y Z)
;;	3. BG: Bugle (valor absoluto)
;;DEPENDIENTES
;;	> NINGUNO
;;ANOTACIONES
;;	>PR...
(defun radio (pta1 pta2 bg / sgm rd1 dst1 sgm2 rd2 rdf sgm3)
	(setq dst1 (distance pta1 pta2))
	(setq bg (abs bg))
	(setq sgm (/ dst1 2))
	(setq sgm (* sgm bg))
	(setq rd1 (/ dst1 2))
	(setq rd1 (* rd1 rd1))
	(setq sgm2 (* sgm sgm))
	(setq rd2 (+ rd1 sgm2))
	(setq sgm3 (* sgm 2))
	(setq rdf (/ rd2 sgm3))
)
;
;;
;;;
;;;;
;;Proyecto: Lisp
;;Clasificacion: Interface de ejecucion (INT)
;;Objeto: OPC
;;Interface que recorre una lista de opciones
;;Argumentos:
;;1.LI: Lista de opciones
;;	Lista sencilla de cadenas de texto: ("xxx" "..." ..)
;;2. XTX: Mensaje de seleccion
;;	Cadena de texto: "xxx"
;;PR...
(defun opc (li xtx / con pase npl res xtx1 quo)
  (setq con 0
	pase 0)
  (cond (
	 (not (= li nil))
	 (while (= pase 0)
	   (setq  npl (nth con li)
		  xtx1 (strcat xtx " " npl " [Aceptar / Siguiente / Regresar / Cancelar]: ")
		  )
	   (initget 1 "Aceptar Siguiente Regresar Cancelar")
	   (setq quo (getkword xtx1))
	   (cond
	     (
	      (= quo "Aceptar")
	      (setq pase 1
		    res npl)
	      )
	     (
	      (= quo "Siguiente")
	      (cond
		(
		 (= con (- (length li) 1))
		 (setq con 0)
		 )
		(
		 (< con (length li))
		 (setq con (+ con 1))
		 )
		)
	      (setq xtx1 xtx)
	      )
	     (
	      (= quo "Regresar")
	      (cond
		(
		 (= con 0)
		 (setq con (- (length li) 1))
		 )
		(
		 (< con (length li))
		 (setq con (- con 1))
		 )
		)
	      (setq xtx1 xtx)
	      )
	     (
	      (= quo "Cancelar")
	      (setq pase 1
		    res nil)
	      )
	     )
	   )
	 )
	)
  )
;
;;
;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: CI
;;SINTAXIS: (DiTick [EntName/coord1] [EntName/coord2] [EntNamPol] [Prec])
;;OBJETO / TITULO: DiTick. Calcula la distancia entre dos Ticks sobre una polilinea
;;DESCRIPCION: DiTick. Apartir de la definicion de nombre de entidad de
;;	dos marcadores (tick) o sus coordenadas y una polilinea, calcula su distancia.
;;	>
;;DEVUELVE:
;;	> diDsFn. Distancia total
;;ARGUMENTOS
;;	1.diNamT10. Nombre de entidad o coordenada del block (tick) inicial
;;	<Ename> / (XY)
;; 2. diNamT20. Nombre de entidad o coordenada del Block (tick) final
;;	<Ename> / (XY)
;; 3. diPlNam0. Nombre de entidad de polilinea
;;	<Ename>
;; 4. diPrec0. Precision. numero de decimales
;;	<INT>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun DiTick
	(diNamT10 diNamT20 diPlNam0 diPrec0 /
		diNamT1 diNamT2 diPlNam diPrec
		diPred diP1 diP2 diDs diCoor1 diCoor1a diCoor2 diCoor2a diLsCoor diAn1
		diAn2 diDs1 diDs2 diDsFn diPsT1 diPsT2 diPrecVar
	)
;	(setq diNamT1 nil diNamT2 nil diPlNam nil diPrec nil
;		diPred nil diP1 nil diP2 nil diDs nil diCoor1 nil diCoor1a nil
;		diCoor2a nil diCoor2 nil diLsCoor nil diAn1 nil diAn2 nil diDs1 nil
;		diDs2 nil diDsFn nil diPsT1 nil diPsT2 nil diPrecVar nil
;	)
	;;
;	(brkstep1
;		'("diNamT10" "diNamT20" "diPlNam0" "diPrec0")
;		(list diNamT10 diNamT20 diPlNam0 diPrec0)
;		"00"	"DiTick"
;	)
	;;
	(setq diPrecVar (getvar "luprec"))
	(setvar "luprec" 8)
	(cond
		(
			(and
				(or (= (type diNamT10) 'ENAME)
					(= (LsType diNamT10) "NUM")
				)
				(or (= (type diNamT20) 'ENAME)
					(= (LsType diNamT20) "NUM")
				)
				(= (type diPlNam0) 'ENAME)
				(= (type diPrec0) 'INT)
			)
			(setq diNamT1 diNamT10
				diNamT2 diNamT20
				diPlNam diPlNam0
				diPrec diPrec0
			)
			;;
;			(brkstep1
;				'("diNamT1" "diNamT2" "diPlNam" "diPrec")
;				(list diNamT1 diNamT2 diPlNam diPrec)
;				"01" "DiTick"
;			)
			;;
			(cond
				(
					(=  diPrec nil)
					(setq diPred 0.00015)
				)
				(
					(< 0 diPrec)
					(setq diPred
						(expt 10.0 (* -1 diPrec))
					)
				)
				(
					(= diPrec 0)
					(setq diPred 0.15)
				)
			)
			;;
;			(brkstep1 '("diPrec" "diPred") (list diPrec diPred) "02" "DiTick")
			;;
			(setq diLsCoor (PrePol1 diPlNam diPrec))
			(cond
				(
					(= (type diNamT1) 'ENAME)
					(setq diCoor1
						(cdr 
							(assoc 10 (entget diNamT1))
						)
					)
				)
				(
					(= (LsType diNamT1) "NUM")
					(setq diCoor1 diNamT1)
				)
			)
			(cond
				(
					(= (type diNamT2) 'ENAME)
					(setq diCoor2
						(cdr
							(assoc 10
								(entget diNamT2)
							)
						)
					)
				)
				(
					(= (LsType diNamT2) "NUM")
					(setq diCoor2 diNamT2)
				)
			)
			(setq diPsT1 (lcoor2 diPlNam diCoor1 diPrec)
				diPsT2 (lcoor2 diPlNam diCoor2 diPrec)
			)
			;;
;			(brkstep1
;				'("diLsCoor" "diCoor1" "diCoor2" "diPsT1" "diPsT2")
;				(list diLsCoor diCoor1 diCoor2 diPsT1 diPsT2)
;				"03" "DiTick"
;			)
			;;
			(cond
				(
					(or
						(< diPsT2 diPsT1)
						(and (= diPsT1 diPsT2)
							(< (distance (nth diPsT1 diLsCoor) diCoor2)
								(distance (nth diPsT1 diLsCoor) diCoor1)
							)
						)
					)
					(setq diCoor1a diCoor2 diCoor2a diCoor1)
					(setq diCoor1 diCoor1a diCoor2 diCoor2a)
				)
			)
			;;
;			(brkstep1 '("diCoor1" "diCoor2") (list diCoor1 diCoor2) "04" "DiTick")
			;;
			(setq diDs 0
				diP1 (+ (lcoor2 diPlNam diCoor1 diPrec) 1)
				diP2 (lcoor2 diPlNam diCoor2 diPrec)
				diDs1 (distance diCoor1 (nth diP1 diLsCoor))
				diDs2 (distance diCoor1 diCoor2)
				diAn1 (angle diCoor1 (nth diP1 diLsCoor))
				diAn2 (angle diCoor1 diCoor2)
			)
			;;
;			(brkstep1
;				'("diLsCoor" "diCoor1"
;					"diCoor2" "diP1" "diP2" "diDs1" "diDs2" "diAn1" "diAn2"
;				)
;				(list diLsCoor diCoor1 diCoor2 diP1 diP2 diDs1 diDs2
;					diAn1 diAn2
;				)
;				"05" "DiTick"
;			)
			;;diLsCoor. Lista de coordenadas de polilinea <((xy)...)>
			;diCoor1. Coordenada de insercion de tick 1 <(xy)>
			;diCoor2. Coordenada de insercion de tick 2 <(xy)>
			;diP1 Posicion (NTH) +1 de Tick 1 <xx>
			;diP2 Posicion (NTH) de Tick 2 <xx>
			;diDs1. Distancia insercion de Tick 1 a la Posicion (NTH) +1 de Tick1
			;diDs2. Distancia insercion de Tick 1 a Tick 2
			(cond
				(
					(or
						(EqLs (nth diP1 diLsCoor) diCoor2 1 diPred)
						(and (<  diDs2 diDs1) (EqLs diAn1 diAn2 0 diPred))
					)
					(setq diDsFn diDs2)
				)
				(
					(or
						(and (<  diDs2 diDs1) (not (EqLs diAn1 diAn2 0 diPred)))
						(< diDs1 diDs2)
					)
					(while (and (< diP1 (length diLsCoor))(<= diP1 dip2))
						;;
;						(brkstep1 '("diDs" "diP1") (list diDs diP1) "06" "DiTick")
						;;
						(setq diDs (+ diDs (distance diCoor1 (nth diP1 diLsCoor)))
							diCoor1 (nth diP1 diLsCoor)
							diP1 (+ diP1 1)
						)
						;;
;						(brkstep1
;							'("diDs" "diP1" "diCoo1")
;							(list diDs diP1 diCoo1)
;							"07" "DiTick"
;						)
						;;
					)
					(setq diDs (+ diDs (distance diCoor1 diCoor2)))
					(setq diDsFn diDs)
				)
			)
		)
	)
	(setvar "luprec" diPrecVar)
	(setq diDsFn diDsFn)
)
;
;;
;;;
;;;;
;;PROYECTO: LISP
;;CLASIFICACION: SL
;;TITULO: SelAtt. Devuelve la lista de Nombre de entidades
;;	que correspondan a un valor de atributo definido
;;DESCRIPCION: SELATT. Apartir de una lista de nombre de entidades
;;	devuelve la lista de entidades filtrada con los elementos que
;; correspondan con el valor del atributo definido
;;	> (ename ...)
;;DEVUELVE: seLsFn. Lista de entidades que corresponden al valor del atributo
;; (tag) definido en el atributo
;;	> (ename ...)
;;ARGUMENTOS
;;	1. seLsName0. Lista de nombre de entidades.
;;	> (ename ...)
;; 2. seNamTag0. Nombre del tag buscado
;;	> "XXX"
;;	3. seValTag0. Valor del tag buscado
;; > "XXX"
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> El valor del atributo, asi como el nombre de tag, es sencible
;;		a las mayusculas.
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun SelAtt
	( seLsName0 seNamTag0 seValTag0 /
		seLsName seNamTag seValTag seCon1 seEle
		seEleAtt seLsFn
	)
	;;;;;VARIABLES DEPURACION (0)
;	(setq selsName nil seNamTag nil seValTag nil
;		seCon1 nil seEle nil seEleAtt nil selsFn nil
;	)
	;;;;;VARIABLES DEPURACION (1)
;	(brkstep1
;		'("seLsName0" "seNamTag0" "seValTag0")
;		(list seLsName0 seNamTag0 seValTag0)
;		"00" "SELATT"
;	)
	;;
	(cond
		(
			(and
				(= (type seLsName0) 'LIST)
				(= (type seNamTag0) 'STR)
				(= (type seValTag0) 'STR)
			)
			(setq seLsName seLsName0
				seNamTag seNamTag0
				seValTag seValTag0
			)
			(setq seCon1 0)
			(while
				(< seCon1 (length seLsName))
				(setq seEle (nth seCon1 seLsName)
					seEleAtt
					(cdr
						(nthx '(0 1)
							(lnpo (cons 2 seNamTag)
								(nxx1 seEle '(1 2))
								2 1
							)
						)
					)
				)
				;** seEle. Nombre de entidad no.seCon1
				;< ename >
				;** seEleAtt. Valor del atributo correspondiente al tag definid0
				;< "xxx" >
				;;
;				(brkstep1
;					'("seCon1" "seEle" "seEleAtt")
;					(list seCon1 seEle seEleAtt)
;					"01" "SELATT"
;				)
				;;
				(cond
					(
						(= seEleAtt seValTag)
						(setq seLsFn (append seLsFn (list seEle)))
					)
				)
				;;
;				(brkstep1 '("seLsFn") (list seLsFn) "02" "SELATT")
				;;
				(setq seCon1 (+ seCon1 1))
			)
		)
	)
	;;
;	(brkstep1 '("seLsFn") (list seLsFn) "03" "SELATT")
	;;
	(setq seLsFn seLsFn)
)
;;PROYECTO: Lisp
;;CLASIFICACION:BDATA
;;OBJETO / TITULO: XIN4. Agrega atributos con valores a una entidad.
;;DESCRIPCION: XIN4. Apartir de la definicion de una lista de atributos
;;	con sus valores y el nombre de entidad, lo inserta a la misma entidad.
;;	si la entidad ya tiene los atributos, cambia los valores, si no los tiene
;;	los agrega.
;;DEVUELVE:
;;	> xfin. Lista final de atributos de la entidad.
;;	((NombreAtt ValAtt) ...)
;;ARGUMENTOS
;;	1. xiEnti0. Nombre de entidad
;;	> ENAME
;;	2. xiLsNw0. Lista de atributos que se agregaran o modificaran.
;;	(("NomATT" "ValAtt") ...)
;;	3. xiNamApp0. Nombre de aplicación
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Cuando la entidad si tiene atributos Y el atributo con su valor no se
;;		encuentra en la entidad, éste es agregado al final de los atributos.
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun Xin4
	(xiEnti0 xiLsNw0 xiNamApp0 /
		xiEnti xiLsNw xiNamApp
		xiLsOld xiCon1 xiAtt0 xiPos0 xiFn
	)
;	(setq xiEnti nil xiLsNw nil xiNamApp nil
;		xiLsOld nil xiCon1 nil xiAtt0 nil xiPos0 nil xiFn nil
;	)
	;;
;	(brkstep1
;		'("xiEnti0" "xiLsNw0" "xiNamApp0")
;		(list xiEnti0 xiLsNw0 xiNamApp0)
;		"00" "Xin4"
;	)
	;;
	(cond
		(
			(and
				(= (type xiEnti0) 'ENAME)
				(= (type xiLsNw0) 'LIST)
				(= (type xiNamApp0) 'STR)
			)
			(setq xiEnti xiEnti0 xiLsNw xiLsNw0 xiNamApp xiNamApp0)
			(setq xiLsOld (extraxr xiEnti xiNamApp))
			;;
;			(brkstep1 '("xiLsNw" "xiLsOld") (list xiLsNw xiLsOld) "01" "Xin4")
			;;xiLsOld. Lista de atributos (XD) actual en la entidad
			;<((NamaAtt ValAtt) ...)
			(cond
				(
					(= xiLsOld nil)
					(xinat0
						(mapcar 'car xiLsNw)
						(mapcar 'cadr xiLsNw)
						"-" xiNamApp xiEnti
					)
					(setq xiFn xiLsNw)
					;;
;					(brkstep1 '("xiFn") (list xiFn) "02" "Xin4")
					;;xiFn. Lista final de atributos y valores de entidad
					;<((NamAtt ValAtt) ...)>
				)
				(
					(not (= xiLsOld nil))
					(setq xiCon1 0)
					(while (< xiCon1 (length xiLsNw))
						(setq xiAtt0 (nthx (list xiCon1 0) xiLsNw)
							xiPos0 (nthx '(0 0) (qnth1 xiLsOld xiAtt0 0.0001))
						)
 						;;
;						(brkstep1
;							'("xiAtt0" "xiPos0" "LsIns")
;							(list xiAtt0 xiPos0
;								(list (list xiPos0 (nth xiCon1 xiLsNw)))
;							)
;							"03" "Xin4"
;						)
						;;xiAtt0. Nombre del atributo no.(xiCon1) de lista nueva
						;;xiPos0. Posición NTH que oupa actualmente el atributo
						;;	no.(xiCon4)
						(cond
							(
								(not (= xiPos0 nil))
								(setq xiLsOld
									(sus1
										(list
											(list xiPos0 (nth xiCon1 xiLsNw))
										)
										xiLsOld
									)
								)
								;;
;								(brkstep1 '("xiLsOld") (list xiLsOld) "03" "Xin4")
								;;xiLsOld. Lista de atributos actualizada
								;<((NamAtt ValAtt) ...)>
							)
							(
								(= xiPos0 nil)
								(setq xiLsOld
									(append xiLsOld (list (nth xiCon1 xiLsNw)))
								)
								;;
;								(brkstep1 '("xiLsOld") (list xiLsOld) "04" "Xin4")
								;;xiLsOld. Lista de atributos con nuevo atributo al final
								;<((NamAtt ValAtt) ...)>
							);;;;;;;;;;;CORREGIR!
						)
						(setq xiCon1 (+ xiCon1 1))
					)
					(xinat0 
						(mapcar 'car xiLsOld)
						(mapcar 'cadr xiLsOld)
						"-"
						xiNamApp
						xiEnti
					)
					(setq xiFn (extraxr xiEnti xiNamApp))
					;;
;					(brkstep1 '("xiFn") (list xiFn) "05" "Xin4")
					;;xiFn. Lista final de atributos con valores de la entidad
					;<((NamAtt ValAtt) ...)>
				)
			)
		)
	)
	;;
;	(brkstep1 '("xinFn") (list xiFn) "06" "Xin4")
	;;xiFn. Lista final de atributos con valores de la entidad
	;<((NamAtt ValAtt) ...)>
	(setq xiFn xiFn)
)
;;PROYECTO: Lisp
;;CLASIFICACION: BDATA
;;SINTAXIS: (ExNoma [NomAppXd] [LsCodFiltro] [LsEntNom])
;;TITULO: EXNOMA. Filtra lista de entidades deacuerdo a un codigo XD
;;	((100 . "NomAtt,ValAtt") ...)
;; DESCRIPCION: EXNOMA. Apartir de la
;;	definicion de:
;;	1. Nombre de aplicacion XDATA
;;	2. Lista de pares punteados XDATA con el codigo 100
;;	para atributos 
;;	3. Lista de nombre de entidades
;;	Filtra la misma lista que correspondan al atributo y valor
;;	definidos en el argumento.
;;DEVUELVE: 
;;	fnls. Lista de nombre de entidades correspondientes
;;		al atributo y valor definido en el argumento <(Ename ...)>
;;	> nil si no existen entidades dentro de la lista de nombres
;; que  contengan los codigo.
;;ARGUMENTOS
;;	1. napp0: Nombre de la aplicacion XDATA
;;	> "XXX"
;;	2. xco0: Lista de codigos XDATA de filtro
;; >( (cod . Val) (...) ...)
;;	3. nomb0: Lista de nombre de entidades
;;	> (ENAME ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun ExNoma
	(napp0 xco0 nomb0 /
		napp xco nomb
		exCon2 exCon1 nomb1 nomls pass fnls
	)
;	(setq napp nil xco nil nomb nil
;		exCon2 nil exCon1 nil nomb1 nil
;		nomls nil pass nil fnls nil
;	)
	;;
;	(brkstep1
;		'("napp0" "xco0" "nomb0")
;		(list napp0 xco0 nomb0)
;		"00" "EXNOMA"
;	)
	;;
	(setq napp napp0 xco xco0 nomb nomb0)
	(setq exCon1 0 )
	(while (< exCon1 (length nomb))
		(setq nomb1 (nth exCon1 nomb)
			nomls (assoc -3 (entget nomb1 (list napp)))
		)
		;;
;		(brkstep1 '("nomb1" "nomls") (list nomb1 nomls) "01" "EXNOMA")
		;;
		(cond
			(
				(not (= nomls nil))
				(setq exCon2 0
					pass 0
					nomls (cdr (nth 1 nomls))
					nomls (mapcar 'cdr nomls)
				)
				;;
;				(brkstep1 '("nomls" "xco") (list nomls xco) "02" "EXNOMA")
				;;
				(while
					(< exCon2 (length xco))
					;;
;					(brkstep1
;						'("(bc nomls (cdr (nth exCon2 xco)))")
;						(list (bc nomls (cdr (nth exCon2 xco))))
;						"03" "EXNOMA"
;					)
					;;
					(cond 
						(
							(bc0 nomls (cdr (nth exCon2 xco)))
							(setq pass (+ pass 1))
							;;
;							(brkstep1 '("pass") (list pass) "03" "EXNOMA")
							;;
						)
					)
					(setq exCon2 (+ exCon2 1))
				)
				;;
;				(brkstep1 '("pass") (list pass) "04" "EXNOMA")
				;;
				(cond
					(
						(= pass (length xco))
						(setq fnls (append fnls (list nomb1)))
					)
				)
				;;
;				(brkstep1 '("fnls") (list fnls) "05" "EXNOMA")
				;;
			)
		)
		(setq exCon1 (+ exCon1 1))
	)
	(setq fnls fnls)
)
;
;;
;;;
;;;;
;;;;;;LISTA DE ATRIBUTOS PARA MARCADORES;;;;;;(0)
;MARCADOR:
;	ELEMENTO ID_POL DIST_ANTERIOR DIST_POSTERIOR
;	TUBO_ANTERIOR TUBO_POSTERIOR
;ETIQUETA:
;	ELEMENTO ID_POL DISTANCIA NUM_TUBO 
;APLICACION:
;	AZ-CIVIL	
;;;;;LISTA DE ATRIBUTOS PARA MARCADORES;;;;;;;(1)
;;*********************************************;;
;;PROYECTO: Lisp
;;CLASIFICACION: CI
;;OBJETO / TITULO: MarcLs. Genera una lista de
;;	posicion NTH, distancia a la primera coordenada
;;	y coordenada de insercion y nombre de entidad
;;	de todos los marcadores que pasen por una polilinea
;;DESCRIPCION:MarcLs. Genera una lista de
;;	marcadores (PDN COO ENAME) que pasa por una polilinea representada por
;;	una lista de coordenadas con
;; la siguiente estructura:
;;	1. Posicion NTH que ocupa en la polilinea
;;	2. Distancia de la coordenada de posicion
;;		NTH de la polilinea a la coordenada de
;;		insersion
;;	3. Numero de tubo (posterior) o Nil
;;	4. Coordenada de insersion del marcador
;;	5. Nombre de entidad del marcador
;;	>
;;DEVUELVE: maLsFn. Lista de marcadores que pasan
;;	por una polilinea
;;	((PosNTH Dist NumTubo CoordenadaIns Ename) ...)
;;ARGUMENTOS
;;	1. maLsMarc0. Lista de nombre de entidad de elementos <(ename ...)>
;;	2. maPolNam0. Nombre de entidad de polilinea <ENAME>
;;	3. maPre0. Numero entero que indica el numero de decimales para
;;	la precision numerica. <INT>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> El numero de tubo (maNum) del atributo corresponde
;;		al numero de tubo posterior.
;;	> El numero de tubo devuelto en cada marcador es el
;;	> numero de tubo posterior.
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun MarcLs
	(maLsMarc0 maPolNam0 maPre0 /
		maLsMarc maPolNam maPre
		maPred maPoLs maPreVar maCon1 maMarcPos
		maDs maMarc0 maMarc maNun maPins maCir maMarcAnt MaDsAnt maPas
		maLsFn maMarc1 maNumIni maNxt
	)
;	(setq maLsMarc nil maPolNam nil maPre nil
;		maPred nil maPoLs nil maPreVar nil maCon1 nil maMarcPos nil
;		maDs nil maMarc0 nil maMarc nil maNum nil maPins nil maCir nil
;		maMarcAnt nil maDsAnt nil maPos nil maLsFn nil maMarc1 nil
;		maNumIni nil maNxt nil
;	)
	;;
;	(brkstep1
;		'("maLsMarc0" "maPolNam0" "maPre0")
;		(list maLsMarc0 maPolNam0 maPre0)
;		"00" "MarcLs"
;	)
	;;Variables de argumento
	;maLsMarc0. Lista de nombre de entidades de marcadores <(ename ...)>
	;maPolNam0. Nombre de entidad de polilinea (perfil) <ename>
	;maPre0. Numero de decimales de precision numerica <INT>
	(setq maPreVar (getvar "luprec"))
	(setvar "luprec" 8)
	(cond
		(
			(and
				(= (LsType maLsMarc0) 'ENAME)
				(= (type maPolNam0) 'ENAME)
				(= (type maPre0) 'INT)
			)
			(setq maLsMarc maLsMarc0
				maPolNam maPolNam0
				maPre maPre0
			)
			;;
;			(brkstep1 '("maLsMarc" "maPolNam" "maPre")
;				(list maLsMarc maPolNam maPre)
;				"01" "MarcLs"
;			)
			;;Variables de argumento
			(cond
				(;<Definicion de precision decimal>;
					(= maPre nil)
					(setq maPred 0.00015)
				)
				(
					(< 0 maPre)
					(setq maPred
						(expt 10.0 (* -1 maPre))
					)
				)
				(
					(= maPre 0)
					(setq maPred 0.15)
				)
			)
			;;
			(setq maPoLs (PrePol1 maPolNam maPre))
			;;
;			(brkstep1 '("maPoLs") (list maPoLs) "02" "MarcLs")
			;;maPoLs. Lista de coordenada de polilinea
			;;	<((xyz) ...)>
			(cond
				(
					(not (= maPoLs nil))
					(setq maCon1 0)
					(while (< maCon1 (length maLsMarc))
						(setq maDs nil
							maPas "Si"
							maCir nil
							maMarcPos
							(Lcoo2 maPolNam
								(cdr
									(assoc 10 (entget (nth maCon1 maLsMarc)))
								)
								maPre
							)
						)
						(redraw (nth maCon1 maLsMarc) 3)
						(command "circle"
							(cdr (assoc 10 (entget (nth maCon1 maLsMarc))))
							2
						)
						(setq maCir (entlast))
						(cam1 (list maCir) '(62 . 2))
						(command "zoom" "c"
							(cdr (assoc 10 (entget (nth maCon1 maLsMarc))))
							50
						)
						(cond
							(
								(= maMarcPos nil)
								(initget 1 "Si No")
								(setq maPas
									(getkword "DESEA INCLUIR ESTE MARCADOR?: [Si / No] ")
								)
								;;;Ajuste de coordenada de marcador (0)
								(while
									(and
										(= maMarcPos nil)
										(= maPas "Si")
									)
									(setq maMarcAnt nil
										maPins nil
										maNxt nil
									)
									(setq maNumini1 nil
										maNumini2 nil
									)
									(setq maPins
										(getpoint
											(cdr (assoc 10 (entget (nth maCon1 maLsMarc))))
												"SELECCIONE EL PUNTO DE CORRECCION DEL MARCADOR [ENTER PARA REFERENCIAR]: "
										)
									)
									;;
;									(brkstep1 '("maPins") (list maPins) "03" "MarcLs")
									;; maPins. Nuevo punto de marcador <(xyz)>
									(cond
										(
											(= maPins nil)
											(setq maMarcAnt
												(car
													(entsel "SELECCIONE EL MARCADOR ANTERIOR: ")
												)
											)
											;;
;											(brkstep1
;												'("maMarcAnt")
;												(list maMarcAnt)
;												"04" "MarcLs"
;											)
											;;maMarcAnt. Nombre de entidad de marcador <ENAME>
											(cond
												(
													(not (= maMarcAnt nil))
													(setq maDsAnt
														(getreal
															"INDIQUE LA DISTANCIA AL SIGUIENTE MARCADOR: "
														)
													)
													;;
												;;SINTAXIS: (NexrP1 [Ename] [Coo] [LsDs] [NumIni] [PrecInt] [AngIni] )
													(setq maNumIni
														(cdr
															(nthx '(0 1)
																(lnpo '(2 . "NUMERO") 
																	(nxx1 (nth maCon1 maLsMarc) '(1 2))
																	2 1
																)
															)
														)
													)
													;;
;													(brkstep1 '("maNumIni" "maDsAnt")
;														(list maNumIni maDsAnt)
;														"05" "MarcLs"
;													)
													;;
													(cond
														(
															(= maNumini nil)
															(setq maNumIni
																(getint "INDIQUE EL NUMERO DE TUBO ANTERIOR:")
															)
														)
														(
															(not (= maNumIni nil))
															(setq maNumIni
																(- (atoi maNumIni) 1)
															)
														)
													)
													;;
;													(brkstep1 '("maPolNam" "maMarcAnt" "maDsAnt" "(nth maCon1 maLsMarc)" "maNumIni")
;														(list maPolNam maMarcAnt maDsAnt (nth maCon1 maLsMarc) maNumIni)
;														"06" "MarcLs"
;													)
													;;
													(setq maNxt
														(NextP1
															maPolNam
															(cdr (assoc 10 (entget maMarcAnt)))
															(list (list maDsAnt (nth maCon1 maLsMarc)))
															maNumIni
															3
															0.0
														)
													)
													(cond
														(
															(not (= maNxt nil))
															(setq maPins
																(list 
																	(nth (- (length (bindls maNxt)) 2) (bindls maNxt))
																	(nth (- (length (bindls maNxt)) 1) (bindls maNxt))
																)
															)
														)
													)
													;;
;													(brkstep1
;														'("maPins" "maNxt") (list maPins maNxt)
;														"07" "MarcLs"
;													)
													;;maPins. Coordenada de marcador
													;<(XYZ)>
												)
											)
										)
									)
									(setq maMarcPos
										(Lcoo2 maPolNam maPins maPre)
									)
									;;
;									(brkstep1
;										'("maMarcPos") (list maMarcPos) "08" "MarcLs"
;									)
									;;maMarcPos. Posicion NTH
									;  de marcador en polilinea
									;  <INT>
									(cond
										(
											(not (= maMarcPos nil))
											(cam1 
												(list (nth maCon1 maLsMarc))
													(append
														(list 10) maPins
													)
											)
										);;;INCLUIR ANGULO DE ROTACION
									)
								)
							)
						)
						(cond
							(
								(not (= maMarcPos nil))
								(setq maDs
									(distance
										(nth maMarcPos maPoLs)
										(cdr (assoc 10 (entget (nth maCon1 maLsMarc))))
									)
								)
								;;
;								(brkstep1 '("maDs") (list maDs) "09" "MarcLs")
								;;MaDs. Distancia de coordenada
								; proxima antetior de la posicion
								; en la polilinea a coordenada
								; de marcador <REAL>
								(setq maNum
									(nxx1
										(nth maCon1 maLsMarc) 
										(list 2 1)
									)
									maNum (lnpo '(2 . "NUMERO") maNum 1 1)
								)
								;;
;								(brkstep1
;									'("maNum") (list maNum)
;									"10" "MarcLs"
;								)
								;;maNum. Lista de atributo "NUMERO"
								; para numero de tubo
								;;<((Ename (2 . Tag ) (1 . ValTa)))>
								(cond
									(;<marcador = 0 / nil>;
										(not (= maNum nil))
										;;
;										(brkstep1 '("Numero?")
;											(list (cdr (nthx '(0 2) maNum)))
;											"11" "MarcLs"
;										)
										;;
										(cond
											(
												(= (cdr (nthx '(0 2) maNum)) "0")
												(setq maNum 0)
											)
											(
												(not
													(= (cdr (nthx '(0 2) maNum)) "0")
												)
												(setq maNum
													(atoi (cdr (nthx '(0 2) maNum)))
												)
												(if
													(= maNum 0)
													(setq maNum nil)
												)
											)
										)
									)
								)
								;;
;								(brkstep1
;									'("maNum") (list maNum)
;									"12" "MarcLs"
;								)
								;;maNum. Numero de tubo
								;<INT>
								(setq maMarc
									(append maMarc
										(list
											(list maMarcPos maDs maNum
												(cdr
													(assoc 10
														(entget
															(nth maCon1 maLsMarc)
														)
													)
												)
												(nth maCon1 maLsMarc)
											)
										)
									)
								)
							)
						)
						(entdel maCir)
						(redraw (nth maCon1 maLsMarc) 4)
						(setq maCon1 (+ maCon1 1))
						;;
;						(brkstep1
;							'("maMarc") (list maMarc)
;							"13" "MarcLs"
;						)
						;;maMarc. Lista final de datos
						; de mmarcadores
						; ((PosNth Dist NumTuboAnterior (xyCoor) Ename) ...)
					)
					;;
;					(brkstep1 '("maMarc final")
;						(list maMarc)
;						"14" "MarcLs"
;					)
					;;
					;Orden de lista final ;;;;;; (0)
					;Posicion;;;;(0)
					(cond
						(
							(not (= maMarc nil))
							(setq maMarc (orden4 maMarc 0 0 3))
							;;
;							(brkstep1 '("maMarc") (list maMarc) "15" "MarcLs")
							;
							(setq maMarc
								(agru1 maMarc () 0 maPred)
							)
							;;
;							(brkstep1
;								'("maMarc") (list maMarc)
;								"16" "MarcLs"
;							)
							;;maMarc. Lista agrupada por
							;; posicion nth dentro de
							;; polilinea
							;;<(((PDN XY Ename) ...) (...) ...)
							(setq maCon1 0
								maLsFn nil
							)
							(while (< maCon1 (length maMarc))
								(setq maLsFn
									(append
										maLsFn (orden4 (nth maCon1 maMarc) 0 1 3)
									)
									maCon1 (+ maCon1 1)
								)
								;;
;								(brkstep1 '("maLsFn") (list maLsFn) "17" "MarcLs")
								;;
							)
						)
					)
				)
			)
		)
	)
	(setvar "luprec" maPreVar)
	;;
;	(brkstep1 '("maLsFn") (list maLsFn) "18" "MarcLs")
	;;
	(setq maLsFn maLsFn)
)
;;PROYECTO: Lisp
;;CLASIFICACION:CI
;;OBJETO / TITULO: IntDat. Inserta atributos en marcadores
;;SINTAXIS: (IntDat [LsMarc])
;;DESCRIPCION: IntDat. Intruce los atributos en marcadores de cadenamiento
;; apartir de una lista hecha con la funcion MarcLs con la estructura
;;	(PDN COO ENAME)
;;	>
;;DEVUELVE: inLsFn. Lista de nombre de entidades de marcadores <(ename ...)>
;;	>
;;ARGUMENTOS
;;	1.inLs0. Lista de marcadores con coordenadas de insercion
;;	> <((Posicion Distancia Numero Coordenada Ename) ...)>
;;	2. inPl0. Nombre de entidad de polilinea
;;	<ENAME>
;;
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MARCADOR:
;	ELEMENTO
;	ID_POL
;	DIST_ANTERIOR, DIST_POSTERIOR
;	TUBO_ANTERIOR, TUBO_POSTERIOR
;ETIQUETA:
;	ELEMENTO
;	ID_POL
;	DISTANCIA
;	NUM_TUBO
;;APP: AZ-CIVIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun IntDat
	(inLs0 inPl0 /
		inLs inPl
		inDs inNumIni inCon1 inMarc1 inMarc2 inDs2 inHdPl inLsFn
		inCir
	)
;	(setq inLs nil inPl nil
;		inDs nil inNumIni nil inCon1 nil inMarc1 nil inMarc2 nil 
;		inDs2 nil inHdPl nil inLsFn nil inCir nil
;	)
;	(brkstep1 '("inLs0") (list inLs0) "00" "InLs0")
	(cond
		(
			(and
				(= (type inLs0) 'LIST)
				(= (type inPl0) 'ENAME)
			)
			(setq inLs inLs0 inPl inPl0)
			(redraw (nthx '(0 4) inLs) 3)
			(command
				"circle"
				(cdr (assoc 10 (entget (nthx '(0 4) inLs))))
				2
			)
			(setq inCir (entlast))
			(cam1 (list inCir) '(62 . 2))
			(command "zoom" "c" (cdr (assoc 10 (entget inCir))) 50)
			(setq inDs
				(getreal
					"INDIQUE LA DISTANCIA DEL TUBO INICIAL (0 PARA INICIAL / ENTER PARA CALCULAR LA DISTANCIA: "
				)
			)
			(terpri) (princ)
			;;
;			(brkstep1 '("inDs") (list inDs)
;				"01" "InTDat"
;			)
			;;InDs. Distancia anterior (primera) <#.#>
			(cond
				(
					(= inDs nil)
					(setq inDs
						(getpoint "INDIQUE EL PUNTO DE INICIO DEL TUBO ANTERIOR: ")
					)
					(cond
						(
							(= (LsType inDs) "NUM")
							(setq inDs
								(DiTick
									inDs
									(nthx (list 0 4) inLs)
									inPl
									3
								)
							)
						)
					)
					(cond
						(
							(= inDs nil)
							(setq inDs "-")
						)
						(
							(= (numberp inDs) T)
							(setq inDs (rtos inDs 2 2))
						)
					)
				)
			)
			;;
;			(brkstep1 '("inDs" "inNumIni" "(nthx '(0 2) inLs)")
;				(list inDs inNumIni (nthx '(0 2) inLs))
;				"02" "IntDat"
;			)
			;; inDs. Distancia inicial <"#.#" / "-">
			;; inNumIni. Numero de tubo posterior al marcador
			;;	<INT> (nil para entrar a ciclo)
			(setq inCon1 0)
			(while (= inNumIni nil)
				(cond
					(
						(= (nthx '(0 2) inLs) nil)
						(setq InNumIni
							(getint "INIDQUE EL NUMERO DE TUBO POSTERIOR: ")
						)
					)
					(
						(= (numberp (nthx '(0 2) inLs)) t) 
						(setq inNumIni (nthx '(0 2) inLs))
					)
				)
				;;
;				(brkstep1 '("inNumIni") (list inNumIni) "03" "IntDat")
				;;
			)
			(setq inHdPl (cdr (assoc 5 (entget inPl))))
			(entdel inCir)
			(redraw (nthx '(0 4) inLs) 4)
			;;
;			(brkstep1
;				'("inHdPl" "inNumini" "inDs")
;				(list inHdPl inNumini inDs)
;				"04" "IntDat"
;			)
			;;
			(while 
				(< inCon1 (- (length inLs) 1))
				(setq inMarc1 (nthx (list inCon1 4) inLs)
					inMarc2 (nthx (list (+ inCon1 1) 4) inLs)
					inDs2 (DiTick inMarc1 inMarc2 inPl 3)
				)
				;;
;				(brkstep1
;					'("inMarc1" "inMarc2" "inNumIni" "inDs" "inDs2")
;					(list inMarc1 inMarc inNumIni inDs inDs2)
;					"05" "IntDat"
;				)
				;;
				(xinat0
					(list
						"ELEMENTO"
						"ID_PL"
						"DIST_ANTERIOR"
						"DIST_POSTERIOR"
						"TUBO_ANTERIOR"
						"TUBO_POSTERIOR"
					)
					(list
						"MARCADOR"
						inHdPl
						(rtos inDs 2 2)
						(rtos inDs2 2 2)
						(itoa (- inNumIni 1))
						(itoa inNumIni)
					)
					"-" "AZ-CIVIL"
					inMarc1
				)
				(setq inDs inDs2
					inNumIni (+ inNumIni 1)
					inCon1 (+ inCon1 1)
				)
				(setq inLsFn (append inLsFn (list inMarc1)))
				;;
;				(brkstep1
;					'("inLsFn" "inNumIni" "inDs")
;					(list inLsFn inNumIni inDs)
;					"06" "IntDat"
;				)
				;;
			)
			;;
;			(brkstep1 
;				'("inHdPl" "inDs" "inNumini" "inLsFn")
;				(list inHdPl inDs inNumini inLsFn)
;				"07" "IntDat"
;			)
			;;
			(xinat0 
				(list
					"ELEMENTO"
					"ID_PL"
					"DIST_ANTERIOR"
					"DIST_POSTERIOR"
					"TUBO_ANTERIOR"
					"TUBO_POSTERIOR"
				)
				(list
					"MARCADOR"
					inHdPl
					(rtos inDs 2 2)
					"-"
					(itoa (- inNumIni 1))
					"-"
				)
				"-" "AZ-CIVIL"
				inMarc2
			)
			(setq inLsFn (append inLsFn (list inMarc2)))
		)
	)
	;;
;	(brkstep1 '("inLsFn") (list inLsFn) "08" "IntDat")
	;;
	(setq inLsFn inLsFn)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:BDATA
;;OBJETO: EXTRAXR
;;	>A partir de la definicion del nombre de entidad y Nombre de aplicacion,
;;	Extrae los elemento guardados en XDATA con el  siguiente formato:
;;	( (Codigo . "NomATT,ValATT") (...) ...)
;;	
;;SINTAXIS. (EXTRAXR [NomEntidad] [NomAplicacion])
;;DEVUELVE: Lista de pares (no punteados) donde el primer elemento de cada
;;	elemento corresponde al Nombre del atributo  y el segundo al Valor.
;;	> ( (NomATT ValATT)
;;ARGUMENTOS
;;	1. NOMEN1; Nombre de la entidad.
;;	>	ENAME
;;	2. NOMAPP; Nombre de la aplicacion
;;	>	"xxx"
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;**************************************************
(defun extraxr (nomen1 nomapp / con1 qq qq0 qqf)
	(setq qq
		(assoc -3 (entget nomen1 (list nomapp)))
		con1 1
	)
	;(brkstep1 '("qq") (list qq) "00" "EXTRAXR")
	(cond
		(
			(not (= qq nil))
			(setq qq (cdr (nth 0 (cdr qq))))
			;(brkstep1 '("qq") (list qq) "01" "EXTRAXR")
			(setq qq (mapcar 'cdr qq)
				qq (lise qq)
			)
			;(brkstep1 '("qq") (list qq) "02" "EXTRAXR")
			(setq con1 1)
			(while
				(<= con1 (length qq))
				(setq qq0 (exl qq con1 0))
				;(brkstep1 '("qq0") (list qq0) "03" "EXTRAXR")
				(setq qqf
					(append qqf
						(list qq0)
					)
				)
				(setq con1 (+ con1 1))
			)
		)
	)
	;(brkstep1 '("qqf") (list qqf) "04" "EXTRAXR")
	(setq qqf qqf)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:CI
;;OBJETO / TITULO:ReUb0. Reubica los marcadores de una polilinea
;;SINTAXIS:(ReUb0 [Lista Marcadores] [EnamePol])
;;DESCRIPCION:ReUb0. Reubica los marcadores con atributos XD de una
;;	lista definida en el argumento.
;;	>
;;DEVUELVE:
;;	> 
;;ARGUMENTOS
;;	1.reMaLs0. Lista de marcadores con los siguientes atributos
;	ELEMENTO: MARCADOR
;	ID_POL
;	DIST_ANTERIOR, DIST_POSTERIOR
;	TUBO_ANTERIOR, TUBO_POSTERIOR
;;APP: AZ-CIVIL
;;<ENAME ...>
;;	2.rePlNam0. Nombre de entidad de polilinea <ENAME>
;;	3.reAppNam0. Nombre de aplicacion XD.
;;	<"xxxx">
;;	4.rePre0. Precision numerica (numero de decimales). <INT>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>Arreglo para numeracion aleatoria
;;
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ReUb0
	(reMaLs0 rePlNam0 reAppNam0 rePre0 /
		reMaLs rePlNam reAppNam rePre
		reCon1 rePred reComLs reEname1 reDat reCir reConect rePas
		reEname2 reOrig reLsNext reDs reNumIni reNumInfo reUbFn
		reOsMod
	)
;	(setq reMaLs nil rePlNam nil reAppNam nil rePre nil
;		reCon1 nil rePred nil reComLs nil reEname1 nil reDat nil
;		reCir nil reConect nil rePas nil reEname2 nil reOrig nil
;		reLsNext nil reDs nil reNumIni nil reNumInfo nil reUbFn nil
;		reOsMod nil
;	)
	;;;;;;;;;;;;;;;;;
;	(brkstep1 '("reMaLs0" "rePlNam0" "(type rePlNam0)" "reAppNam0" "rePre0")
;		(list reMaLs0 rePlNam0 (type rePlNam0) reAppNam0 rePre0)
;		"00" "ReUb0"
;	)
	;;
	(setq reOsMod (getvar "osmode"))
	(cond
		(
			(and
				(= (LsType reMaLs0) 'ENAME)
				(= (type rePlNam0) 'ENAME)
				(= (type reAppNam0) 'STR)
				(= (type rePre0) 'INT)
			)
			;;
;			(brkstep1
;				'("(LsType reMaLs0)"
;					"(type rePlNam0)"
;					"(type reAppNam0)"
;					"(type rePre0)"
;				)
;				(list
;					(LsType reMaLs0)
;					(type rePlNam0)
;					(type reAppNam0)
;					(type rePre0)
;				)
;				"00A"
;				"ReUb0"
;			)
			;;
			(setq reMaLs reMaLs0
				rePlNam rePlNam0
				reAppNam reAppNam0
				rePre rePre0
			)
			;;
;			(brkstep1 '("reMaLs" "(length reMaLs)" "rePlNam" "reAppNam" "rePre")
;				(list reMaLs (length reMaLs) rePlNam reAppNam rePre)
;				"01" "ReUb0"
;			)
			;;
			(cond
				(
					(= rePre nil)
					(setq rePred 0.00015)
				)
				(
					(< 0 rePre)
					(setq rePred
						(expt 10.0 (* -1 rePre))
					)
				)
				(
					(= rePre 0)
					(setq rePred 0.15)
				)
			)
			;;;;;;;;;;;
			(setq reCon1 0)
			(while (= reEname1 nil)
				(setq reEname1
					(car (entsel "INDIQUE EL MARCADOR INICIAL: "))
				)
				(cond
					(
						(not (= reEname1 nil))
						(cond
							(
								(not (= (cdr (assoc 2 (entget reEname1))) "Punta1"))
								(setq reEname1 nil)
							)
						)
						;;
;						(brkstep1
;							'("reEname1" "(cdr (assoc 2 (entget reEname1)))")
;							(list reEname1 (cdr (assoc 2 (entget reEname1))))
;							"02" "ReUb0"
;						)
						;;reEname1. Marcador inicial. <ENAME>
					)
				)
			);...While (= reEname1 nil) marcador inicial
			(setq reMaLs (txno reMaLs reEname1))
			;;
;			(brkstep1 
;				'("reMaLs" "(length reMaLs)"
;					"(FindAtt reEname1 \"AZ-CIVIL\" \"TUBO_POSTERIOR\")"
;				)
;				(list reMaLs (length reMaLs)
;					(FindAtt reEname1 "AZ-CIVIL" "TUBO_POSTERIOR")
;				)
;				"03" "ReUb0"
;			)
			;;
			(cond
				(
					(= (FindAtt reEname1 "AZ-CIVIL" "TUBO_POSTERIOR")
						nil
					)
					(xin4 reEname1 '(("TUBO_POSTERIOR" "-")) "AZ-CIVIL")
				)
			)
			(setq reDat (extraxr reEname1 "AZ-CIVIL"))
			;;
;			(brkstep1 '("reDat" "(length reMaLs)" "reEname1" "TUBO_POSTERIOR")
;				(list reDat (length reMaLs) reEname1
;					(FindAtt reEname1 "AZ-CIVIL" "TUBO_POSTERIOR")
;				)
;				"04" "ReUb0"
;			)
			;; reEname1. Marcador inicial <Ename>
			;; reDat. Atributos de marcador <(("NomAtributo" "ValAtt")...)>
			(cond
				(
					(not (= reDat nil))
					;;
;					(brkstep1 '("TuboPosterior")
;						(list
;							(nthx '(0 1)
;								(lnpo "TUBO_POSTERIOR" reDat 0 1)
;							)
;						)
;						"05" "ReUb0"
;					)
					;;
					(cond
						(
							(=
								(atoi 
									(nthx
										'(0 1)
										(lnpo "TUBO_POSTERIOR" reDat 0 1)
									)
								)
								0
							)
							(setvar "osmode" 0)
							(command
								"zoom" "c"
								(cdr (assoc 10 (entget reEname1)))
								"50"
							)
							(command "circle" (cdr (assoc 10 (entget reEname1))) 2)
							(setq reCir (entlast))
							(setvar "osmode" reOsMod)
							(cam1 (list reCir) '(62 . 2))
							(while (not (= (type reConect) 'INT))
								(setq reConect (getInt "INDIQUE EL NUMERO DE TUBO POSTERIOR: "))
							)
							(if (not (= reCir nil))
								(progn (entdel reCir) (setq reCir nil))
							)
							(princ)
							(if (= (type reConect) 'INT) (progn (setq reConect (itoa reConect))))
							(cond
								(
									(= (type reConect) 'STR)
									(xin4 reEname1
										(list
											(list "ELEMENTO" "MARCADOR")
											(list "ID_POL" (cdr (assoc 5 (entget rePlNam))))
											(list "TUBO_POSTERIOR" reConect)
										)
										"AZ-CIVIL"
									)
								)
							)
						);...TUBO_POSTERIOR reEname1 no localizado / reConect Numero de tubo posterior
						(
							(< 0
								(atoi
									(nthx
										'(0 1)
										(lnpo "TUBO_POSTERIOR" reDat 0 1)
									)
								)
							)
							(setq reConect
								(nthx '(0 1)
									(lnpo "TUBO_POSTERIOR" reDat 0 1)
								)
							)
							;;
;							(brkstep1 '("reConect") (list reConect) "05A" "ReUb0")
							;;reConect. Numero deTUBO_POSTERIOR <STR>
						);...TUBO_POSTERIOR >0
					);... Cond
					;;
;					(brkstep1
;						'("(cdr (assoc 10 (entget reEname1)))" "(atoi reConect)")
;						(list
;							(cdr (assoc 10 (entget reEname1))) (atoi reConect)
;						)
;						"05B" "ReUb0"
;					)
					;;
					(setq
						reOrig (cdr (assoc 10 (entget reEname1)))
						reNumIni (atoi reConect)
						rePas 0
					)
					(if (not (= reCir nil))
						(progn
							(entdel reCir)
							(setq reCir nil)
						)
					)
					;;
;					(brkstep1
;						'("reConect" "reOrig" "reNumIni")
;						(list reConect reOrig reNumIni)
;						"06" "ReUb0"
;					)
					;;reConect. Numero de tubo posterior. <STR>
					;;reOrig. Coordenada de inicio
					;;reNumIni. Numero de tubo inicial <'INT>
				);...(not (= reDat nil))
			);...Cond
			;;;;;;;;;;**Lista reLsNext**;;;;;;(0)
			(while
				(and (= rePas 0)
					(not (= reConect nil))
					(< 0 (length reMaLs))
				)
				;;
;				(brkstep1
;					'("reMaLs" "(length reMaLs)" "reConect" )
;					(list reMaLs (length reMaLs) reConect)
;					"07" "ReUb0"
;				)
				;;
				(setq reEname2
					(exnoma "AZ-CIVIL" 
						(list (cons 1000 "ELEMENTO,MARCADOR")
							(cons 1000 (strcat "TUBO_ANTERIOR" "," reConect))
						)
						reMaLs
					)
				)
				;;
;				(brkstep1 '("reEname2") (list reEname2) "08" "ReUb0")
				;;reEname2. Entidad coincidente con reConect <ENAME>
				(cond
					(
						(= reEname2 nil)
						(setvar "osmode" 0)
						(command "circle" (cdr (assoc 10 (entget reEname1))) 2)
						(setq reCir (entlast))
						(cam1 (list reCir) '(62 . 2))
						(command "zoom" "c" 
							(cdr (assoc 10 (entget reEname1)))
							50
						)
						(setvar "osmode" reOsMod)
						(setq reEname2 
							(car
								(entsel
									"SELECCIONE EL SIGUIENTE MARCADOR [ENTER PARA TERMINAR]: "
								)
							)
						)
						(if 
							(not (= reCir nil))
							(progn (entdel reCir) (setq reCir nil))
						)
						;;
;						(brkstep1
;							'("reEname2" "reConect")
;							(list reEname2 reConect)
;							"09" "ReUb0"
;						)
						;;
						(cond
							(
								(= reEname2 nil)
								(setq rePas 1)
								(if
									(not (= reCir nil))
									(progn
										(entdel reCir)
										(setq reCir nil)
									)
								)
							)
						)
					);...reEname2 = nil
				);...Cond
				;;
;				(brkstep1 '("reEname2" "rePas") (list reEname2 rePas) "10" "ReUb0")
				;;
				(cond 
					(
						(and
							(not (= reEname2 nil))
							(= rePas 0)
						)
						(cond
							(
								(= (type reEname2) 'LIST)
								(setq reEname2 (nth 0 reEname2))
							)
						)
						(cond
							(
								(= reConect "-")
								(setvar "osmode" 0)
								(command
									"zoom" "c"
									(cdr (assoc 10 (entget reEname2)))
									"50"
								)
								(command "circle" (cdr (assoc 10 (entget reEname2))) 2)
								(setq reCir (entlast))
								(setvar "osmode" reOsMod)
								(cam1 (list reCir) '(62 . 2))
								(while
									(or (= reConect "-")
										(= reConect nil)
									)
									(setq reConect
										(getint "INDIQUE EL NUMERO DE TUBO ANTERIOR: ")
									)
								)
								(if
									(not (= reCir nil))
									(progn
										(entdel reCir)
										(setq reCir nil)
									)
								)
								(cond
									(
										(= (type reConect) 'INT)
										(setq reConect (itoa reConect))
									)
								)
							);...(reConect = "-")
						)
						(setq reDat (extraxr reEname2 "AZ-CIVIL"))
						(setq reDs (FindAtt reEname2 "AZ-CIVIL" "DIST_ANTERIOR"))
						;;
;						(brkstep1
;							'("reDat" "reDs" "reConect")
;							(list reDat reDs reConect)
;							"11" "ReUb0"
;						)
						;;
						(if (not (= reCir nil)) (entdel reCir))
						;;reDat. Lista de atributos y valores de
						;		la endidad <(("NomAtributo" "ValAtributo")...)>
						;;reDs. Distancia anterior registrada en la entidad
						;		<TXT>
						(while (= reDs nil)
							(setq reNumInfo
								(strcat "INDIQUE LA DISTANCIA DEL TUBO " reConect ": ")
							)
							(setq reDs (getreal reNumInfo))
						)
						(cond
							(
								(= (type reDs) 'STR)
								(setq reDs (atof reDs))
							)
						)
						;;Verificacion de atributos***(0)
						(xin4 reEname1
							(list
								(list "ELEMENTO" "MARCADOR")
								(list "ID_POL" (cdr (assoc 5 (entget rePlNam))))
								(list "DIST_POSTERIOR" (rtos reDs 2 2))
								(list "TUBO_POSTERIOR" reConect)
							)
							"AZ-CIVIL"
						)
						(xin4 reEname2
							(list
								(list "ELEMENTO" "MARCADOR")
								(list "ID_POL" (cdr (assoc 5 (entget rePlNam))))
								(list "DIST_ANTERIOR" reDs)
								(list "TUBO_ANTERIOR" reConect)
							)
							"AZ-CIVIL"
						)
						(cond
							(
								(= (FindAtt reEname2 "AZ-CIVIL" "TUBO_POSTERIOR") nil)
								(setq reConect "-")
								(xin4
									reEname2
									(list (list "TUBO_POSTERIOR" "-"))
									"AZ-CIVIL"
								)
							)
							(
								(not (= (FindAtt reEname2  "AZ-CIVIL" "TUBO_POSTERIOR") nil))
								(setq reConect (FindAtt reEname2 "AZ-CIVIL" "TUBO_POSTERIOR"))
							)
						)
						;;Verificacion de atributos***(1)
						(setq reLsNext
							(append reLsNext
								(list (list reDs reEname2))
							)
						)
						(setq reMaLs (txno reMaLs reEname2))
						(setq reEname1 reEname2)
						(setq reEname2 nil
							reDat nil
							reDs nil
						)
					)
				)
				;;
;				(brkstep1 
;					'("reLsNext" "reEname1" "reConect" "reMaLs" "(length reMaLs)")
;					(list reLsNext reEname1 reConect reMaLs (length reMaLs))
;					"12" "ReUb0"
;				)
				;; reLsNext. Lista de entidades y distancias para
				;		reubicar con NextP1 <((ename dist) ...)>
			);;SEGUNDO WHILE
			;;
;			(brkstep1 '("reLsNext" "rePlNam" "reOrig" "reNumini")
;				(list reLsNext rePlNam reOrig reNumini)
;				"13" "ReUb0"
;			)
			;;reLsNext. Lista de entidades y distancias terminada
			;;rePlNam. Nombre de entidad de polilinea <ENAME>
			;;reOrig. Coordenada del marcador inicial <(X Y)>
			;;reNumini. Numero de tubo inicial. <INT>
			(cond
				(
					(not (= reLsNext nil))
					(setq reUbFn (NextP1 rePlNam reOrig reLsNext reNumIni 3 0.0))
				)
			)
		)
	)
	;;
;	(brkstep1 '("reUbFn") (list reUbFn) "14" "ReUb0")
	;;
	(setq reUbFn reUbFn)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: CI
;;OBJETO: anFlex
;;	> Inserta todos los  puntos  de inflexion de una poilinea
;;DEVUELVE:
;;	> anFil. Lista de nombre de entidades de los bloques de puntos
;;	de inflexion de la polilinea
;;ARGUMENTOS
;;	1.Nombre de Entidad
;;	> 1. anEnti0. Nombre de entidad de polilinea
;;	> 2. anPrec0. Precision
;;	> 3. anDisIn0. Distancia de insersion
;;	> 4. anSc0. Escala de Block
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>Nombre de la aplicación: AZ-CIVIL
;;	>Nombre de atributo: ID_POL
;;	>Nombre del bloque: pto-inf
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun anFlex
	( anEnti0 anPrec0 anDisIn0 anSc0 /
		anEnti anPrec anDisIn anSc anCooPl anCon1 anInf anBase anMid anCooIns anLsFn anCon2
		anReq anLsPto anFil anBlkIns anDir anRoIns anEnti
		anNomAp anNomXd anInd anBlkIns1 anIns1 anMode
	)
;	(setq anEnti nil anPrec nil anDisIn nil anSc nil anCooPl nil anCon1 nil anInf nil
;		anBase nil anMid nil anCooIns nil anLsFn nil anCon2 nil anReq nil anLsPto nil
;		anFil nil anBlkIns nil anDir nil anRoIns nil anEnti nil
;		anNomAp nil anNomXd nil anInd nil anBlkIns1 nil anIns1 nil anMode nil
;	)
	;;
;	(brkstep1 '("anEnti0" "anPrec0" "anDisIn0" "anSc0")
;		(list anEnti0 anPrec0 anDisIn0 anSc0)
;		"00" "anFlex"
;	)
	;;
	(setq anMode (getvar "osmode"))
	(setvar "osmode" 0)
	(cond
		(
			(and
				(= (type anEnti0) 'ENAME)
				(= (type anPrec0) 'INT)
				(= (numberp anDisIn0) T)
				(= (numberp anSc0) T)
			)
			(setq anEnti anEnti0
				anPrec anPrec0
				anDisIn anDisIn0
				anSc anSc0
			)
			(setq anNomAp "AZ-CIVIL"
				anNomXd "ID_POL"
			)
			(setq anCooPl (prepol1 anEnti 3)
				anCon1 0
			)
			;;
;			(boli2 anCooPl 0.0001)
;			(brkstep1 '("anCooPl" "(length anCooPl)") (list anCooPl (length anCooPl)) "01" "anFlex")
			;;
			(while
				(< anCon1 (- (length anCooPl) 2))
				(setq anInf
					(angres5
						(angle
							(nth anCon1 anCooPl) 
							(nth (+ anCon1 1) anCooPl)
						)
						(nth (+ anCon1 1) anCooPl)
						(nth (+ anCon1 2) anCooPl) 0 3
					)
				)
				;;
;				(brkstep1 '("anInf") (list anInf) "02" "anFlex")
				;;
				(cond 
					(
						(< 0.000 anInf)
						(setq anBase (- pi anInf))
						(setq anDir
							(angresta
								(angle
									(nth (+ anCon1 1) anCooPl)
									(nth (+ anCon1 2) anCooPl)
								)
								(angle
									(nth anCon1 anCooPl)
									(nth (+ anCon1 1) anCooPl)
								)
							)
						)
						;;
;						(brkstep1 '("anDir" "anCooPl") (list anDir anCooPl) "03" "anFlex")
						;;
						(cond
							(
								(< anDir pi)
								(setq anMid
									(sumang
										(angle (nth (+ anCon1 1) anCooPl)
											(nth (+ anCon1 2) anCooPl)
										)
										(+ (/ anBase 2) pi)
									)
									anInd "CI"
									anRoIns (angresta (angresta anMid (/ pi 2)) pi)
								)
							)
							(
								(< pi anDir)
								(setq anMid
									(angresta
										(angle
											(nth (+ anCon1 1) anCooPl)
											(nth (+ anCon1 2) anCooPl)
										)
										(/ anBase 2)
									)
									anRoIns (sumang anMid (/ pi 2))
									anInd "CS"
								)
							)
						)
						(setq anCooIns
							(polar
								(nth (+ anCon1 1) anCooPl)
								anMid
								anDisIn
							)
						)
						;;
;						(brkstep1
;							'("anBase" "anMid" "anCooIns" "anRoIns" "anInf")
;							(list
;								(dtr2 anBase)
;								(dtr2 anMid)
;								anCooIns
;								(dtr2 anRoIns)
;								(dtr2 anInf)
;							)
;							"04" "anFlex"
;						)
						;;
						(setq anLsFn
							(append anLsFn
								(list
									(list anCooIns anMid anRoIns anInf anInd)
								)
							)
						)
						;;
;						(brkstep1 '("anLsFn") (list anLsFn) "04" "anFlex")
						;;
					)
				)
				(setq anCon1 (+ anCon1 1))
			);...while (< anCon1o (- 1 (lentg anCooPL)))
			;;
;			(brkstep1 '("anLsFn") (list anLsFn) "05" "anFlex")
			;;
			(cond
				(
					(not (= anLsFn nil))
					(setq anCon2 0)
					(setq anReq (getvar "attreq"))
					(setvar "attreq" 0)
					(while
						(< anCon2 (length anLsFn))
						;;
;						(brkstep1
;							'("Coordenadas" "Escala" "anguloIns" "anguloAtt")
;							(list
;								(nthx (list anCon2 0) anLsFn)
;								anSc
;								(dtr2 (nthx (list anCon2 2) anLsFn))
;								(dtr2 (nthx (list anCon2 3) anLsFn))
;							)
;							"05A"
;							"anFlex"
;						)
						;;
						(cond
							(
								(<= 0.0174533 (nthx (list anCon2 3) anLsFn))
								(setq anIns1 (nthx (list anCon2 2) anLsFn))
								(cond
									(
										(and
											(< 1.5708 anIns1)
											(< anIns1 4.71239)
										)
										(setq anIns1 (sumang anIns1 3.14159))
									)
								)
								(command "insert" "pto-inf"
									(nthx (list anCon2 0) anLsFn)
									anSc "" 0
									;(dtr2 (nthx (list anCon2 2) anLsFn))
								)
								(command ^^c)
								(setq anBlkIns (entlast))
								(command "insert" "MAR_VER"
									(nthx (list anCon2 0) anLsFn)
									0.5 "" 1
								)
								(command ^^c)
								(setq anBlkIns1 (entlast))
								(camtag
									(list anBlkIns)
									"ANGULO"
									(rtos (dtr2 (nthx (list anCon2 3) anLsFn)) 2 1)
								)
								(camtag
									(list anBlkIns)
									"INFLEXION"
									(nthx (list anCon2 4) anLsFn)
								)
								(setq anLsPto (append anLsPto (list anBlkIns)))
								;;
;								(brkstep1
;									'("anLsPto" "anBlkIns" "anEnti")
;									(list anLsPto anBlkIns)
;									"06" "anFlex"
;								)
								;;
								(xin3 "AZ-CIVIL" anBlkIns
									(list
										(list "ELEMENTO,PTO_INF")
										(list (strcat "ID_POL," (cdr (assoc 5 (entget anEnti)))))
										(list
											(strcat "AN_INF,"
												(rtos (dtr2 (nthx (list anCon2 3) anLsFn)) 2 1)
											)
										)
										(list
											(strcat "CS_CI,"
												(nthx (list anCon2 4) anLsFn)
											)
										)
									)
								)
								;;
								;(brkstep1 '("anBlkIns") (list anBlkIns) "07" "anFlex")
								;;
;								(xinat0
;									(list anNomXd)
;									(list (cdr (assoc 5 (entget anEnti))))
;									"-" anNomAp anBlkIns
;								)
;								(xin4 anBlkIns
;									(list
;										(list "ELMENTO" "PTO_INF")
;										(list "AN_INF"
;											(rtos (dtr2 (nthx (list anCon2 3) anLsFn)) 2 1)
;										)
;										(list "CS_CI"
;											(nthx (list anCon2 4) anLsFn)
;										)
;									)
;									"AZ-CIVIL"
;								)
								(xin3 "AZ-CIVIL" anBlkIns1
									(list
										(list "ELEMENTO,MARC_INF")
										(list (strcat "ID_POL," (cdr (assoc 5 (entget anEnti)))))
										(list (strcat "ID_INF," (cdr (assoc 5 (entget anBlkIns)))))
									)
								)
								;;
								;(brkstep1 '("anBlkIns1") (list anBlkIns1) "08" "AnFlex")
								;;
;								(xinat0
;									(list anNomXd)
;									(list (cdr (assoc 5 (entget anEnti))))
;									"-" anNomAp anBlkIns1
;								)
;								(xin4 anBlkIns1
;									(list
;										(list "ELEMENTO" "MARC_INF")
;										(list "ID_INF" (cdr (assoc 5 (entget anBlkIns))))
;									)
;									"AZ-CIVIL"
;								)
;								(setq anFil
;									(seldata2
;										anLsPto
;										(list anNomXd)
;										(list (cdr (assoc 5 (entget anEnti))))
;										anNomAp
;									)
;								)
							);...(<= 0.0174533 (nthx (list anCon2 3) anLsFn))
						);...Cond
						;;
;						(brkstep1 '("anFil") (list anFil) "09" "anFlex")
						;;
						(setq anCon2 (+ anCon2 1))
					)
				)
			)
			(setvar "attreq" anReq)
			;;
;			(brkstep1 '("anLsPto" "anFil") (anLsPto anFil) "10" "anFlex")
			;;
		)
	)
	(textpage)
	(graphscr)
	(setvar "osmode" anMode)
;	(setq anFil anFil)
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION:BDATA
;;OBJETO: GOCDICT (Get or create dictionary)
;;	> Obtiene o crea un diccionario en la base de datos del dibujo
;;	> (DICTIONARY)
;;DEVUELVE: Nombre de "entidad" de diccionario personal creado
;;	>	ENAME
;;ARGUMENTOS
;;	1.OURDICT Nombre de diccionario
;;	> Cadena de texto
;;DEPENDIENTES
;;	> Ninguno
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun gocdict (ourdict  / adict)
	(if
		(not (setq adict (dictsearch (namedobjdict) ourdict)))
		(progn
			(setq adict (entmakex '((0 . "DICTIONARY")(100 . "AcDbDictionary"))))
			(if
				adict
				(setq adict
					(dictadd
						(namedobjdict) ourdict
						adict
					)
				)
			)
		)
		(setq adict (cdr (assoc -1 adict)))
	)
)
;
;;
;;;
;;;;
;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BDATA
;;OBJETO: GOCXR; Devuelve el nombre del Xreactor, si no existe,
;; lo crea y si existe solo devuelve el nombre.
;;	> 
;;DEVUELVE: Nombre del Xreactor
;;	> ENAME
;;ARGUMENTOS
;;	1. DIXY. Nombre del diccionario donde vamos a agregar
;;	nuestro Xrecord
;;	> "xxx"
;;	2. XRNAME. Nombre del Xrecord
;; > "xxx"
;;	3. XRLIST. Lista de valores del Xrecord
;;	> ((cod . val) (cod . val) (...) ...)
;;DEPENDIENTES
;;	> gocdict ()
;;ANOTACIONES
;;	> No modifica el reactor si ya existe.
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun gocxr (dixy xrname xrlist / midic anXrec)
	;(brkstep '("dixy" "xrname" "xrlist") "00;Entrada" "GOCXR")
	(cond
	;;Obtiene el nombre de entidad de diccionario, sino, lo crea
		(
			(not (= (setq midic (gocdict dixy)) nil))
			;(brkstep '("midic") "01" "GOCXR")
			(cond
			;;Si el diccionario esta creado, busca el Xrecord por su nombre
				(
					(not
						(setq anXrec (dictsearch midic xrname))
					)
					;(brkstep '("anxrec") "02" "GOCXR")
					;;Si el Xrecord no exista lo crea
					(setq xrlist
						(append '((0 . "XRECORD") (100 . "AcDbXrecord"))
							xrlist
						)
					)
					;(brkstep '("xrlist") "03" "GOCXR")
					(setq anXrec (entmakex xrlist))
					;;Si Xrecord es creado con éxito, lo agrega al
					;; diccionario
					(if anXrec
						(setq anXrec
							(dictadd midic xrname anXrec)
						)
					)
				);; Si ya existe todo devuelve el nombre
				(setq anXrec
					(cdr (assoc -1 (dictsearch midic xrname)))
				)
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BDATA
;;OBJETO: EXNAME. Obtiene el nombre de entidad de una lista
;; de diccionarios o Xreactor con el patron de codigo (3 350)
;; donde el codigo 3 es el nombre (simbolo) y 350 el nombre
;;	de entidad
;;	> 
;;DEVUELVE: Nombre de entidad del simbolo (nombre) buscado
;;	>  ENAME
;;ARGUMENTOS
;;	1. LX Lista de diccionario o Xrecord
;;	> ((cod  . val) (...) ...)
;;	2. SIMX. Simbolo del nombre buscado
;; > "xxx"
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;
(defun  exname (lx simx / lxn lx1 nn)
	(setq lx1 (expat '((3 350)) lx))
	;(brkstep '("lx1") "01" "EXNAME")
	(cond
		(
			(not (= lx1 nil))
			(setq nn (cons 3 simx))
			;(brkstep '("nn") "02" "EXNAME")
			(setq lxn (lnpo nn lx1 1 1))
			;(brkstep '("lxn") "03" "EXNAME")
			(setq lxn
				(nth 2
					(nth 0 lxn)
				)
				lxn (cdr lxn)
			)
		)
	)
	(setq lxn lxn)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BDATA
;;OBJETO:DELRCOD. Elimina o renombra un Xrecord o Diccionario
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. DATNAME. Nombre de entidad donde se localiza el diccionarios
;;	o  Xrecord
;;	> ENAME
;;	2. LSELE. Lista de nombres del diccionarios o Xrecord (simbolo)
;; que se van a modificar
;;	> ("xxx" ...)
;;	3. LSREM. Lista de nombres de diccionario o Xrecord (simbolo)
;; que se van a remplazar
;;		Tiene que tener el mismo numero de elementos que la lista
;; 	nombres a modificar.
;;		Se omite () en caso de utilizarlo para eliminar elementos
;;DEPENDIENTES
;;	> 
;;ANOTACIONES
;; Si el tercer argumento es omitido () se realiza la accion de borrar
;; los elementos.
;;;(brkstep '("") "001TEMP" "")
;;
(defun delrcod (datname lsele lsrem / con1 pas)
	(princ)
	(setq pas 1)
	(cond 
		(
			(and
				(not (= datname nil))
				(not (= lsele nil))
			)
			(cond
				(
					(not (= lsrem nil))
					(if
						(not (= (length lsrem) (length lsele)))
						(setq pas 0)
					)
				)
			)
			(setq con1 0)
			(while
				(and
					(< con1 (length lsele))
					(= pas 1)
				)
				(cond
					(
						(= lsrem nil)
						(dictremove datname (nth con1 lsele))
					)
					(
						(not (= lsrem nil))
						(dictrename datname 
							(nth con1 lsele)
							(nth con1 lsrem)
						)
					)
				)
				(setq con1 (+ con1 1))
			)
		)
	)
	(princ)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:BDATA
;;OBJETO / TITULO: FindAtt. Devuelve valor XD de una entidad
;;SINTAXIS:(FindAtt [Ename] [AppNom] [AttNom])
;;DESCRIPCION:FindAtt. Apartir de la definicion del nombre de
;;	de entidad de un elemento, nombre de aplicación 
;;	y nombre de aplicacion; devuelve el valor del atributo XD.
;;	>
;;DEVUELVE: fnFn. Valor del atributo XD. 
;;	> xxx / nil
;;ARGUMENTOS
;;	1.fnEname0. Nombre de entidad del elemento
;;	<Ename>
;;	2.fnApp0. Nombre de la aplicacion XD
;; <STR>
;; 3.fnAtt0. Nombre del atributo
;;	<STR>
;;DEPENDIENTES
;;	> Extraxr ();
;;ANOTACIONES
;;	> La estructura de la aplicación de la base de datos es:
;;	((1000 . "NomAtt,ValAtt") ...)
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun FindAtt
	(fnEname0 fnApp0 fnAtt0 /
		fnEname fnApp fnAtt
		fnLs fnFn
	)
;	(setq fnEname nil fnApp nil fnAtt nil
;		fnLs nil fnFn nil
;	)
	;;
;	(brkstep1 '("fnEname0" "fnApp0" "fnAtt0")
;		(list fnEname0 fnApp0 fnAtt0)
;		"00" "FindAtt"
;	)
	;;
	(cond
		(
			(and
				(= (type fnEname0) 'ENAME)
				(= (type fnApp0) 'STR)
				(= (type fnAtt0) 'STR)
			)
			(setq fnEname fnEname0
				fnApp fnApp0
				fnAtt fnAtt0
			)
			;;
;			(brkstep1 '("fnEname" "fnApp" "fnAtt")
;				(list fnEname fnApp fnAtt)
;				"01" "FindAtt"
;			)
			;;
			(setq fnLs (extraxr fnEname fnApp))
			;;
;			(brkstep1 '("fnLs") (list fnLs) "02" "FindAtt")
			;;
			(cond
				(
					(not (= fnLs nil))
					(setq fnFn
						(nthx '(0 1) (lnpo fnAtt fnLs 0 1))
					)
				)
			)
		)
	)
	;;
;	(brkstep1 '("fnFn") (list fnFn) "03" "FindAtt")
	;;
	(setq fnFn fnFn)
)
;
;;
;;;
;;;;
;;PROYECTO: LISP
;;CLASIFICACION: MAT
;;SINTAXIS. (CORIN4 [LsCoorRecta] [CoorComp] [Precision])
;;TITULO: CORIN4. Verifica si una coordenada es parte de una recta
;;DESCRIPCION: CORIN4. A partir de la definicion de las coordenadas
;;  Verifica si un punto se encuentra dentro de dicha recta
;;	>
;;DEVUELVE: 0 Si el punto no se encuentra dentro de la recta; 1 Si el punto
;;		se encuentra dentro de la recta.
;;	> 
;;ARGUMENTOS
;;	1.coLsCo0. Lista de coordenadas de la recta
;;	> ((XYZ) (XYZ))
;;	2.coPto0. Punto de comparacion
;; > (XYZ)
;;	3.coPreInt0. Numero de decimales de precision predeterminado 3
;;	maximo 5
;;	> Numero entero
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Agregada funcion AngFix
;;	> Distancia (P1 Pc) + (Pc P2) = P1 P2 y
;;	Angulo p1 pc = Angulo pc p2
;;	> Tiene un factor de error de 0.0005
;;;(brkstep '("") "001TEMP" "")
;;
(defun corin4
	(coLsCo0 coPto0 coPreInt0 /
		coLsCo coPto coPreInt
		resa ds1 ds2 ds3 prec coPreDc an1 an2 auvar luvar
	)
;	(setq coLsCo nil coPto nil coPreInt nil
;		resa nil ds1 nil ds2 nil ds3 nil prec nil coPreDc nil
;		an1 nil an2 nil auvar nil luvar nil
;	)
	(setq auvar (getvar "auprec")
		luvar (getvar "luprec")
	)
	(setvar "auprec" 8)
	(setvar "luprec" 8)
	;;
;	(brkstep1
;		'("coLsCo0" "coPto0" "coPreInt0"
;			"(= (type coLsCo0) 'LIST)"
;			"(= (LsType coPto0) \"NUM\")"
;			"(= (type coPreInt) 'INT)"
;		)
;		(list coLsCo0 coPto0 coPreInt0
;			(= (type coLsCo0) 'LIST)
;			(= (LsType coPto0) "NUM")
;			(= (type coPreInt0) 'INT)
;		)
;		"00" "CORIN4"
;	)
	;;
	(cond
		(
			(and
				(= (type coLsCo0) 'LIST)
				(= (LsType coPto0) "NUM")
				(= (type coPreInt0) 'INT)
			)
			(setq coLsCo coLsCo0
				coPto coPto0
				coPreInt coPreInt0
			)
			;;;;Definicion decimal (0)
			(cond
				(
					(< 0 coPreInt)
					(setq coPreDc
						(expt 10.0 (* -1 coPreInt))
					)
				)
				(
					(= coPreInt 0)
					(setq coPreDc 0.15)
				)
			)
			;;;;Definicion decimal (1)
			(setq resa 0)
			(cond
				(
					(and
						(< 1 (length coLsCo))
						(< 1 (length coPto))
					)
					(setq ds1 (distance (nth 0 coLsCo) coPto) 
						ds2 (distance (nth 1 coLsCo) coPto)
						ds3 (distance (nth 0 coLsCo) (nth 1 coLsCo))
						an1 (round1 (AngFix (angle (nth 0 coLsCo) coPto)) coPreInt)
						an2 (round1 (AngFix (angle coPto (nth 1 coLsCo))) coPreInt)
					)
					;;
;					(brkstep1
;						'("ds1" "ds2" "ds3" "(+ ds1 ds2)" "an1" "an2")
;						(list ds1 ds2 ds3 (+ ds1 ds2) an1 an2)
;						"01" "CORIN4"
;					)
					;;
					(cond
						(
							(and
								(eq0 (+ ds1 ds2) ds3 coPreDc)
								(eq0 an1 an2 coPreDc)
							)
							(setq resa 1)
						)
					)
				)
			)
		)
	)
	(setvar "luprec" luvar)
	(setvar "auprec" auvar)
	(setq resa resa)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:ANG
;;OBJETO / TITULO: AngFix. Arregla angulos iguales o mayores a 360 grados (en radianes)
;;SINTAXIS: (AngFix AnguloRadianes)
;;DESCRIPCION: AngFix. A partir de la definicion de un angulo en radianes, verifica
;; que no sea igual o mayor a 360 grados (en radianes 6.2832)
;;	>
;;DEVUELVE:
;;	< >
;;ARGUMENTOS
;;	1. fiAng0. Angulo en radianes para veri
;;	< >
;;DEPENDIENTES
;;	< >
;;ANOTACIONES
;;	>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun AngFix
	(fiAng0 /
		fiAng
	)
;	(setq fiAng nil)
	;;
;	(brkstep1 '("fiAng0") (list fiAng0) "00" "AngFix")
	;;
	(cond
		(
			(numberp fiAng0)
			(setq fiAng fiAng0)
			(cond
				(
					(Eq0 (* pi 2) fiAng 0.001)
					(setq fiAng 0.00)
				)
				(
					(< (* pi 2) fiAng0)
					(setq fiAng (- fiAng (* 2 pi)))
				)
			)
		)
	)
	;;
;	(brkstep1 '("fiAng") (list fiAng) "01" "AngFix")
	;;
	(setq fiAng fiAng)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:ANG
;;OBJETO / TITULO: AngFix. Arregla angulos iguales o mayores a 360 grados (en radianes)
;;SINTAXIS: (AngFix AnguloRadianes)
;;DESCRIPCION: AngFix. A partir de la definicion de un angulo en radianes, verifica
;; que no sea igual o mayor a 360 grados (en radianes 6.2832)
;;	>
;;DEVUELVE:
;; fiAng. Angulo en radianes no mayor a 360 grados.
;;	< Radianes >
;;ARGUMENTOS
;;	1. fiAng0. Angulo en radianes para verificar
;;	< Radianes >
;;DEPENDIENTES
;;	< >
;;ANOTACIONES
;;	>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun AngFix
	(fiAng0 /
		fiAng
	)
;	(setq fiAng nil)
	;;
;	(brkstep1 '("fiAng0") (list fiAng0) "00" "AngFix")
	;;
	(cond
		(
			(numberp fiAng0)
			(setq fiAng fiAng0)
			(cond
				(
					(Eq0 (* pi 2) fiAng 0.001)
					(setq fiAng 0.00)
				)
				(
					(< (* pi 2) fiAng0)
					(setq fiAng (- fiAng (* 2 pi)))
				)
			)
		)
	)
	;;
;	(brkstep1 '("fiAng") (list fiAng) "01" "AngFix")
	;;
	(setq fiAng fiAng)
)
;
;;
;;;
;;;;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:CI
;;SINTAXIS.(NextP2 [NomPol] [CoordenadaInicial] [DisTubo] [NumInicial] [Presicion] [AngIni] [Modo])
;;TITULO. NextP2. Inserta etiquetas y Crea una lista de cadenamiento de una polilinea
;;DESCRIPCION. NextP2. Apartir de la definicion
;; del nombre de entidad de una poliinea, inserta etiquetas con el bloque Punta1 y numeroTubo
;; como cadenamiento y devuelve la lista de coordenadas de cada tramo, con numeracion asendente
;; o descendente segun el modo definido en el argumento.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. ANA. Nombre de entidad de polilinea
;;	> ENAME
;;	2.CO1A. Coordenada de division inicial
;;	> NN. Numero natural
;;	3. DISIE. Distancia de division (distancia de tubo)
;;	> ## Numero real (positivo)
;;	4. NUMINI0. Numeracion inicial (numero de tubo inicial)
;;	> NN. Numero natural.
;;	5. PREC. Presi Precision numerica
;;	> NN. Numero natural.
;;	6. ANGINI0. Angulo inicial (radianes)
;;	7. nxMod0. modo de numeracion ascendente o descendente.
;;		0 Numeracion ascendente
;;		1 Numeracion descendente
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Introduccion de atributos por medio de blocks (attreq 1)
;;;(brkstep '("") "001TEMP" "")
;;**************************************************
(defun NextP2
	(ana co1a disie numini0 prec angini0 nxMod0 /
		numini nxMod disac co2 discoor nxCon1
		lis1 lisele0 lisele1
		liselef ps1 ps2 numprec
		snapo disi co1 angins angini rev
		angini2 nextcad nextinf mensacad nextangi 
		ppta1 ppta2 deci msele diatt ecov numinext coini
		din anin mimi co2a anic midonut nePass
		neHand neMarc0 neMarc1 neTubo0 neTubo1 neTubo
		neAttReq neAttDia nPunta
	)
;	(setq
;		numini nil nxMod nil disac nil co2 nil discoor nil nxCon1 nil
;		lis1 nil lisele0 nil lisele1 nil
;		liselef nil ps1 nil ps2 nil numprec nil
;		snapo nil disi nil co1 nil angins nil angini nil rev nil
;		angini2 nil nextcad nil nextinf nil mensacad nil nextangi nil 
;		ppta1 nil ppta2 nil deci nil msele nil diatt nil ecov nil numinext nil coini nil
;		din nil anin nil mimi nil co2a nil anic nil midonut nil nePass nil
;		neHand nil neMarc0 nil neMarc1 nil neTubo0 nil neTubo1 nil neTubo nil
;		neAttReq nil neAttDia nil nPunta nil
;	)
	;;
;	(brkstep1 '("ana" "co1a" "disie" "numini0" "prec" "angini0")
;		(list ana co1a disie numini0 prec)
;		"00" "NEXTP2"
;	)
	;;
	(setq diatt (getvar "attdia")
		ecov (getvar "cmdecho")
		msele (ssadd)
		neAttReq (getvar "attreq")
		neAttDia (getvar "attdia")
		nxMod nxMod0
		numini numini0
	)
	(setvar "attdia" 0)
	(setvar "cmdecho" 1)
	(cond
		((= prec nil) (setq numprec 0.00002) (setq prec 5))
		((= prec 1) (setq numprec 0.1))
		((= prec 2) (setq numprec 0.01))
		((= prec 3) (setq numprec 0.001))
		((= prec 4) (setq numprec 0.0002))
		((= prec 5) (setq numprec 0.00002))
		((= prec 6) (setq numprec 0.000002))
		((= prec 7) (setq numprec 0.0000002))
		((= prec 8) (setq numprec 0.00000002))
	)
	;;
;	(brkstep1 '("numprec") (list numprec) "01" "NEXTP2")
	;;
	(setq prel (getvar "luprec"))
	(setq preau (getvar "auprec"))
	(setq snapo (getvar "osmode"))
	(setvar "luprec" prec)
	(setvar "auprec" prec)
	(setvar "osmode" 0)
	;;
;	(brkstep1 '("prel" "preau" "snapo") (list prel preau snapo) "02" "NEXTP2")
	;;
	;**VARIABLES
	(setq disi disie
		deci "CONTINUAR"
		co1 co1a
		co1 (list (nth 0 co1) (nth 1 co1))
		angini  angini0
		neHand (cdr (assoc 5 (entget ana)))
	)
	(setq nxCon1 (LCoo2 ana co1 prec))
;	(brkstep1 '("disi" "co1" "angini" "neHand") (list disi co1 angini neHand) "03" "NEXTP2")
	;**DISI. ##.## -DISTANCIA DE CADENAMIENTO-
	;**CO1 (XY) -COORDENADA INICIAL-
	;**ANGINI. ##.## en radianes -ANGULO INICIAL-
	;neHand. Handlet de polilinea
	;nxCon1. Posicion nth de coordenada correspondiente al tramo inicial
	;(proximo anterior al punto de designacion o punto exacto)
	(cond
		(
			(not (= nxCon1 nil))
			(setq nxCon1 (+ nxCon1 1))
			;(setq lis1 (prepol ana prec))
			(setq lis1
				(mapcar 'cdr (lscod ana '(10)))
			)
			(cond
				(
					(= nxMod 0)
					(setq numini (- numini 1))
				)
				(
					(= nxMod 1)
					(setq numini (+ numini 1))
				)
			)
			;;
;			(brkstep1
;				'("nxCon1" "lis1" "numini" "ps1")
;				(list nxCon1 lis1 numini ps1)
;				"04" "NEXTP2"
;			)
			;;
			;**LIS1. Lista de coordenadas de polilinea ((XY) (...) ...)
			;NUMNI. Numero de tubo inicial (-1 para comenzar)
			(while
				(and
					(< nxCon1 (length lis1))
					(not (= deci "SALIR"))
				)
				(princ)
				(setq disi (getreal "Introduzca la distancia <enter para terminar>: "))
				(princ)
				(cond
					(
						(not (= disi nil))
						;(brkstep1 '("DECI") (list deci) "04A" "NEXTP2")
						(setq disac 0 ps2 0)
						(cond
							(
								(= nxMod 0)
								(setq numini (+ numini 1))
							)
							(
								(= nxMod 1)
								(setq numini (- numini 1))
							)
						)
						(setq co2 (nth nxCon1 lis1)
							co2 (list (nth 0 co2) (nth 1 co2))
						)
						(setq lisele (list numini co1 (angle co1 co2)))
						(setq coini co1)
						(setq lisele1 nil)
						;(brkstep1 '("disac" "ps2" "numini" "co2" "co1" "lisele")
						;	(list disac ps2 numini co2 co1 lisele)
						;	"05" "NEXTP2"
						;)
						;**DISAC = 0
						;**CO2 (XY)
						;**LISELE (nnTubo (XY)inicial #.##RAD)
						(while
							(and
								(= ps2 0)
								(< nxCon1 (length lis1))
								(not (= deci "SALIR"))
							)	
							;(brkstep1 '("DECI") (list deci) "05A" "NEXTP2")
							(setq deci nil
								neMarc nil
							)
							(setvar "osmode" 0)
							(command "zoom" "c" co1 "50")
							(setq co2 (nth nxCon1 lis1)
								co2 (list (nth 0 co2) (nth 1 co2))
							)
							(command "zoom" co1 co2)
							;(brkstep1 '("co1" "co2") (list co1 co2) "05B" "NEXTP2")
							(command "zoom" "sc" 50)
							(setvar "osmode" snapo)
							;(setq rev (boli2 (list co1 co2) 0.30))
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							;(brkstep1
							;	'("CO1" "CO2"
							;		"ANGINI" "ANGANTERIOR"
							;		"ANGINS"  "ANGULO" "ANGULOACTUAL"
							;	)
							;	(list co1 co2 angini
							;		(dtr2 angini) angins 
							;		(angle co1 co2) (dtr2 (angle co1 co2))
							;	)
							;	"06" "NEXTP2"
							;)
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							;(command "erase" rev "")
							(cond
								(
									(Eq0 angini (angle co1 co2) 0.0174533)
									(setq angins 0)
									;(brkstep1 '("angins") (list (dtr2 angins)) "00TEMP" "Next")
								)
								(
									(not (Eq0 angini (angle co1 co2) 0.0174533))
									(setq angins (angres5 angini co1 co2  0 prec))
									;(brkstep1 '("angins") (list (dtr2 angins)) "01TEMP" "Next")
								)
							)
							(setq angini (round (angle co1 co2) prec))
							;(brkstep1
							;	'("disi" "disac" "(- disi disac)" "nxCon1" "co2" "angini" "angins")
							;	(list disi disac (- disi disac) nxCon1 co2 angini angins)
							;	"06A" "NextP2"
							;)
							;;;;;;;;;;;;;;;;;ANALISIS DE CADENAMIENTO;;;;;;;;;;;;;;;;;;;(0)
							(cond
								(
									(Eq0
										(- disi disac)
										(distance co1 co2)
										numprec
									)
;									(alert "Samehere")
									;;
;									(brkstep1 '("disac" "(- disi disac)") (list disac (- disi disac)) "07" "NextP2")
									;;
									(setq numinext nil)
									(setq nextcad (rtos (round (- disi disac) prec)))
									(setq nextinf (rtos (round (distance co1 co2) prec)))
									(setvar "osmode" 0)
									(command "donut" 0 0.8 co2 "")
									(setvar "osmode" snapo)
									(setq midonut (entlast))
									(cam1 (list midonut) '(62 . 1))
									(setq mensacad
										(strcat 
											"Distancia al proximo Cadenamiento " nextcad "\n"
											"Distancia al proximo punto de inclinacion " nextinf "\n"
										)
									)
									(cond
										(
											(< nxCon1 (- (length lis1) 1))
											(setq nextangi
												(angres5 angini co2 (nth (+ nxCon1 1) lis1) 0 prec)
												nextangi (rtos (dtr2 nextangi))
											)
											(setq mensacad
												(strcat mensacad "Inclinacion del siguiente tubo "
													nextangi
												)
											)
										)
									)
									;(alert mensacad)
									(setq deci "CONTINUAR"
									;	(opc
									;		'("Continuar" "Definir distancia" "Salir")
									;		"Que desea hacer?: "
									;	)
									)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;									(brkstep1
;										'("disac" "(- disi disac)" "DECI")
;										(list disac (- disi disac) deci)
;										"08" "NextP2"
;									)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									(cond
										(
											(= deci "CONTINUAR")
											(setq anin
												(round (angle coini co2) prec)
												anic
												(round (angle co1 co2) prec)
											)
											(setq
												co2a co2
												din
												(polar coini anin (/ (distance coini co2a) 2))
												din
												(polar din (sumang anin 1.5708) 2)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("DIN" "ANIN" "NUMINI (TXT)" "CO2A")
;												(list din anin numini co2a)
;											"09" "NextP2"
;											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setvar "osmode" 0)
											(setvar "attdia" 0)
											(setvar "attreq" 1)
											(command "insert"
												"NumeroTubo"
												(strcat (cortxt din) ",0") 1 1
												;0
												(round (dtr2 (AngCam anin)) 3)
												;(dtr2 anin)
												(itoa numini)
											)	
											(setq neTubo (entlast)
												mimi (cdr (assoc 5 (entget neTubo)))
											)
											(cond
												(
													(= nxMod 0)
													(setq nPunta (itoa (+ numini 1)))
												)
												(
													(= nxMod 1)
													(setq nPunta (itoa numini))
												)
											)
											(command "insert"
												"punta1"
												(strcat (cortxt co2a) ",0") 1 1
												(dtr2 anic)
												nPunta
												"-"
												"-"
											)
											(setq neMarc1 (entlast))
											(setvar "attreq" neAttReq)
											(setvar "attdia" neAttDia)
											;;;;;;;;;
;											(brkstep1
;												'("neHand" "neTubo"
;													"neMarc1" "neMarc0"
;													"Distancia" "Tubo"
;												)
;												(list neHand neTubo
;													neMarc1 neMarc0
;													(rtos disi 2 2)
;													numini
;												)
;												"10" "NextP2"
;											)
											;;
											(xinat0
												'("ELEMENTO"
													"ID_POL"
													"DIST_ANTERIOR"
													"DIST_POSTERIOR"
													"TUBO_ANTERIOR"
													"TUBO_POSTERIOR"
												)
												(list "MARCADOR" neHand
													(rtos disi 2 2) "-"
													(itoa numini) "-"
												)
												"-" "AZ-CIVIL" neMarc1
											)
											(cond
												(
													(not (= neMarc0 nil))
													(xin4
														neMarc0
														(list
															(list "DIST_POSTERIOR"
																(rtos disi 2 2)
															)
															(list "TUBO_POSTERIOR"
																(itoa numini)
															)
														)
														"AZ-CIVIL"
													)
												)
											)
											(setq neMarc0 neMarc1);;;;;Insertar nuevo metodo
											(xinat0
												'("ELEMENTO" "ID_POL" "DISTANCIA" "NUM_TUBO")
												(list "ETIQUETA" neHand
													(rtos disi 2 2) (itoa numini)
												)
												"-" "AZ-CIVIL" neTubo
											)
											;;
											(setvar "osmode" snapo)
											(setq lisele1
												(append lisele1
													(list
														(list 
															(dtr2 angins)
															(round (distance co1 co2) prec)
															(dtr2 angini)
															co1
															co2
														)
													)
												)
											)
											(setq disac 0
												co1 co2
												ps2 1
												nxCon1 (+ nxCon1 1)
											)
											;**LISELE1. ((##.##AngRad ##.##DistTramo) (...) ...)
											;**DISAC = 0
											;(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "nxCon1" "DECI")
											;(list lisele1 disac co1 co2 ps2 nxCon1 deci)
											;"07A" "NextP2"
											;)
										)
										(
											(= deci "DEFINIR DISTANCIA")
											(setq disi (getreal "Introduzca la distancia de tramo :"))
											(princ) (princ)
											(cond
												(
													(= disi nil)
													(while
														(= disi nil)
														(setq ppta1 (getpoint "Seleccione el primer punto: ")
															ppta2 (getpoint "seleccione el segundo punto: ")
														)
														(cond
															(
																(and
																	(not (= ppta1 nil))
																	(not (= ppta2 nil))
																)
																(setq disi (distance ppta1 ppta2))
																(if
																	(not (= disi nil))
																	(round disi prec)
																)
															)
														)
													)	
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("DECI" "DISI")
											;	(list deci disi)
											;	"07B" "NextP2"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										)
									)
									(entdel midonut)
								)
								(
									(<
										(- disi disac)
										(distance co1 co2)
									)
;									(alert "lessthan")
									;;
;									(brkstep1 '("disac" "(- disi disac)") (list disac (- disi disac)) "08" "NextP2")
									;;
									(setq nextcad (rtos (round (- disi disac) prec)))
									(setq nextinf (rtos (round (distance co1 co2) prec)))
									(setvar "osmode" 0)
									(command "donut" 0 0.8
										(polar co1 (angle co1 co2) (- disi disac))
										""
									)
									(setvar "osmode" snapo)
									(setq midonut (entlast))
									(cam1 (list midonut) '(62 . 1))
									(setq mensacad
										(strcat 
											"Distancia al proximo Cadenamiento " nextcad "\n"
											"Distancia al proximo punto de inclinacion " nextinf "\n"
										)
									)
									(cond
										(
											(< nxCon1 (- (length lis1) 1))
											(setq nextangi
												(angres5 angini co2 (nth (+ nxCon1 1) lis1) 0 prec)
												nextangi (rtos (dtr2 nextangi))
											)
											(setq mensacad
												(strcat mensacad "Inclinacion del siguiente tubo "
													nextangi
												)
											)
										)
									)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(brkstep1
									;	'("NEXTCAD" "NEXTINF" "NEXTANGI")	
									;	(list nextcad nextinf nextangi)
									;	"09" "NextP2"
									;)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(alert mensacad)
									(setq deci "CONTINUAR"
										;(opc
										;	'("Continuar" "Definir distancia" "Salir")
										;	"Que desea hacer?: "
										;)	
									)
									(cond
										(
											(= deci "CONTINUAR")
											(setq anin
												(round (angle coini co2) prec)
												anic
												(round (angle co1 co2) prec)
											)
											(setq
												co2a
												(polar co1 (angle co1 co2) (- disi disac))
												din
												(polar coini anin (/ (distance coini co2a) 2))
												din
												(polar din (sumang anin 1.5708) 2)
											)
											(setvar "osmode" 0)
											(setvar "attdia" 0)
											(setvar "attreq" 1)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("DIN" "ANIN" "NUMINI (TXT)" "CO2A" "COORDENADA" "ATTREQ")
;												(list din anin numini co2a (strcat (cortxt din) ",0") (getvar "attreq"))
;												"09A" "NextP2"
;											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(command "insert" "NumeroTubo" din 1 1
												(round (dtr2 (AngCam anin)) 3)
												(itoa numini)
											)
											(setq neTubo (entlast)
												mimi (cdr (assoc 5 (entget neTubo)))
											)
											(cond
												(
													(= nxMod 0)
													(setq nPunta (itoa (+ numini 1)))
												)
												(
													(= nxMod 1)
													(setq nPunta (itoa numini))
												)
											)
											(command "insert"
												"punta1"
												(strcat (cortxt co2a) ",0") 1 1
												(dtr2 anic)
												nPunta
												"-"
												"-"
											)
											(setq neMarc1 (entlast))
											(setvar "attdia" neAttDia)
											(setvar "attreq" neAttReq)
											;;
											;;
;											(brkstep1
;												'("neHand" "neTubo"
;													"neMarc1" "neMarc0"
;													"Distancia" "Tubo"
;												)
;												(list neHand neTubo
;													neMarc1 neMarc0
;													(rtos disi 2 2)
;													numini
;												)
;												"09B" "NextP2"
;											)
											;;
											(xinat0
												'("ELEMENTO"
													"ID_POL"
													"DIST_ANTERIOR"
													"DIST_POSTERIOR"
													"TUBO_ANTERIOR"
													"TUBO_POSTERIOR"
												)
												(list
													"MARCADOR" neHand
													(rtos disi 2 2) "-"
													(itoa numini) "-"
												)
												"-" "AZ-CIVIL" neMarc1
											)
											(cond
												(
													(not (= neMarc0 nil))
													(xin4
														neMarc0
														(list
															(list "DIST_POSTERIOR"
																(rtos disi 2 2)
															)
															(list "TUBO_POSTERIOR"
																(itoa numini)
															)
														)
														"AZ-CIVIL"
													)
												)
											)
											(setq neMarc0 neMarc1);;;;;;;;;;;;;Insertar nuevo
											(xinat0
												'("ELEMENTO" "ID_POL" "DISTANCIA" "NUM_TUBO")
												(list "ETIQUETA" neHand
													(rtos disi 2 2) (itoa numini)
												)
												"-" "AZ-CIVIL" neTubo
											)
											;;
											(setvar "osmode" snapo)
											(setq lisele1
												(append lisele1
													(list
														(list
															(dtr2 angins)
															(- disi disac)
															(dtr2 angini)
															co1
															(polar co1 (angle co1 co2) (- disi disac))
														)
													)
												)
											)
											(setq co1
												(polar co1
													(angle co1 co2)
													(- disi disac)
												)
											)
											(setq co1 (list (nth 0 co1) (nth 1 co1)))
											(setq disac 0
												ps2 1
											)
											;(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "nxCon1")
											;	(list lisele1 disac co1 co2 ps2 nxCon1)
											;	"10" "NextP2"
											;)
										)
										;;;;;;;;;;;;;;;;;;
										(
											(= deci "DEFINIR DISTANCIA")
											(setq disi (getreal "Introduzca la distancia de tramo :"))
											(princ) (princ)
											(cond
												(
													(= disi nil)
													(while
														(= disi nil)
														(setq ppta1 (getpoint "Seleccione el primer punto: ")
															ppta2 (getpoint "seleccione el segundo punto: ")
														)		
														(cond
															(
																(and
																	(not (= ppta1 nil))
																	(not (= ppta2 nil))
																)
																(setq disi (distance ppta1 ppta2))
																(if
																	(not (= disi nil))
																	(round disi prec)
																)
															)
														)
													)	
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("DECI" "DISI")
											;	(list deci disi)
											;	"11" "NextP2"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										)
									)
									(entdel midonut)
								)
								(
									(>
										(- disi disac)
										(distance co1 co2)
									)
									;(alert "Morethan")
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(brkstep1
									;	'("co1" "co2"
									;		"(distance co1 co2)"
									;		"disac"
									;		"(- disi disac)"
									;		"disac"
									;		"(- disi disac)"
									;	)
									;	(list co1 co2
									;		(distance co1 co2)
									;		disac
									;		(- disi disac)
									;		disac
									;		(- disi disac)
									;	)
									;	"12" "NextP2"
									;)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									(setq nextcad (rtos (round (- disi disac) prec)))
									(setq nextinf (rtos (round (distance co1 co2) prec)))
									(cond
										(
											(>= nxCon1 (- (length lis1) 1))
											(setq mensacad
												(strcat "Distancia al ultimo cadenamiento " nextcad)
											)
											(setvar "osmode" 0)
											(command "donut" 0 0.8 co2 "")
											(setq midonut (entlast))
											(cam1 (list midonut) '(62 . 1))
											(setvar "osmode" snapo)
										)
										(
											(< nxCon1 (- (length lis1) 1))
											(setq nextangi
												(angres5 angini co2 (nth (+ nxCon1 1) lis1) 0 prec)
												nextangi (rtos (dtr2 nextangi))
											)
											(setvar "osmode" 0)
											(command "donut" 0 0.8
												(polar co2 
													(angle co1 (nth (+ nxCon1 1) lis1))
													(- disi (+ disac (distance co1 co2)))
												)
												""
											)
											(setq midonut (entlast))
											(cam1 (list midonut) '(62 . 1))
											(setvar "osmode" snapo)
											(setq mensacad
												(strcat 
													"Distancia al proximo Cadenamiento " nextcad "\n"
													"Distancia al proximo punto de inclinacion " nextinf "\n"
													"Inclinacion del siguiente tubo " nextangi
												)
											)
										)
									)
									;(alert mensacad)
									(setq deci "CONTINUAR"
										;(opc	
										;	'("Continuar" "Definir distancia" "Salir")
										;	"Que desea hacer?: "
										;)
									)
									;;;;;;;;;;;;;;;;;;;;;;;;;;
									;(brkstep1
									;	'("DECI") (list deci) "13" "NextP2"
									;)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;
									(cond
										(
											(= deci "DEFINIR DISTANCIA")
											(setq disi (getreal "Introduzca la distancia de tramo :"))
											(princ) (princ)
											(cond
												(
													(= disi nil)
													(while
														(= disi nil)
														(setq ppta1 (getpoint "Seleccione el primer punto: ")
															ppta2 (getpoint "seleccione el segundo punto: ")
														)
														(cond
															(
																(and
																	(not (= ppta1 nil))
																	(not (= ppta2 nil))
																)
																(setq disi (distance ppta1 ppta2))
																(if
																	(not (= disi nil))
																	(round disi prec)
																)
															)
														)
													)	
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("DECI" "DISI")
											;	(list deci disi)
											;	"14" "NextP2"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										)
										(
											(= deci "CONTINUAR")
											(setq lisele1
												(append lisele1
													(list
														(list
															(dtr2 angins)
															(distance co1 co2)
															(dtr2 angini)
															co1
															co2
														)
													)
												)
											)
											(cond 
												(
													(>= nxCon1 (- (length lis1) 1))
													(command ^^C)
											;		(setq anin (round (angle coini co2) prec))
											;		(setq anic (round (angle co1 co2) prec))
											;		(setq din (polar coini anin (/ (distance coini co2) 2)))
											;		(setq din (polar din (sumang anin 1.5708) 2))
											;		(command "insert" "NumeroTubo"
											;			(strcat (cortxt din) ",0") 1 1
											;			(dtr2 anin) (itoa numini)
											;		)
											;		(command "insert" "punta1"
											;			(strcat (cortxt co2) ",0") 1 1
											;			(dtr2 anic) "Niple" "-" "-" ""
											;		)
												)
											)
											(setq disac (+ disac (distance co1 co2)))
											(setq co1 co2)
											(setq nxCon1 (+ nxCon1 1))
											(setq ps2 0)
											;;;;;;;;;;;;;;;;;;;;;;;
											;(brkstep1
											;	'("LISELE1" "DISAC" "CO1" "CO2" "PS2" "nxCon1")
											;	(list lisele1 disac co1 co2 ps2 nxCon1)
											;	"15" "NextP2"
											;)
											;;;;;;;;;;;;;;;;;;;;;;;;;
										)
									)
									(entdel midonut)
								)
							)
							;;;;;;;;;;;;;;;;;ANALISIS DE CADENAMIENTO;;;;;;;;;;;;;;;;;;;(1)
						)
						(cond
							(
								(not (= lisele1 nil))
								(setq lisele2
									(append lisele (list lisele1))
								)
								(setq liselef
									(append liselef (list lisele2))
								)
								;(brkstep1
								;	'("LISELE1" "LISELEF"
								;		"DISAC" "CO1" "CO2"
								;		"PS2" "nxCon1" "ANGINI"
								;		"ANGINS"
								;	)
								;	(list lisele1 liselef
								;		disac co1 co2 ps2 nxCon1
								;		angini angins
								;	)
								;	"15" "NextP2"
								;)
							)
						)
					)
					(
						(= disi nil)
						(setq deci "SALIR")
					)
				)
				;(brkstep1
				;	'("LISELEF")
				;	(list liselef)
				;	"09" "NextP2"
				;)
			)
		)
	)
	(princ) (princ)
	(setvar "luprec" prel)
	(setvar "auprec" preau)
	(setvar "osmode" snapo)
	(setq liselef liselef)
)
;
;;
;;;
;;;;...NextP2
;;PROYECTO: Lisp
;;CLASIFICACION: SL
;;OBJETO / TITULO: SelPol. Seleccion de elementos que atraviesan por una polilinea.
;;SINTAXIS: (SelPol [EnamePol] [Lista de Filtros])
;;DESCRIPCION: SelPol. Apartir de la definicion de el nombre de entidad de una
;;	polilinea o linea, selecciona todos los elemementos que crucen por la misma
;;	y que cumplan con el filtro de seleccion (en su caso).
;;	>
;;DEVUELVE: seSetFn. Seleccion final de todos los elementos / nil si no existen elementos
;;	< SelectionSet / nil>
;;ARGUMENTOS
;;	1. seEnamPol0. Nombre de entidad de polilinea o linea
;;	< ename >
;;	2. seFilt0. Lista de filtros basado en las reglas de uso para la funcion ssget
;;	< '((cod .valor) ...) >
;;	3. seSetMod0. Modo de inclusion de linea o poliinea
;;		0. No incluye el elemento
;;		1. Si incluye el elemento
;;DEPENDIENTES
;;	< >
;;ANOTACIONES
;;	>filtros de seleccion:
;;	> (-4 . "<or") (-4 . "or>")
;;	> (-4 . "<and") (-4 . "and>")
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun SelPol
	(seEnamPol0 seFilt0 seSetMod0 /
		seEnamPol seFilt seSetMod seLsCor seSetFn
	)
;	(setq seEnamPol nil seFilt nil seSetMod nil seLsCor nil seSetFn nil)
	;;
;	(brkstep1
;		'("seEnamPol0" "seFilt0" "seSetMod0") (list seEnamPol0 seFilt0 seSetMod0)
;		"00" "SelPol"
;	)
	;;SeEnamPol. Polilinea o linea . <ENAME>
	(cond
		(
			(and
				(= (type seEnamPol0) 'ENAME)
				(= (type seSetMod0) 'INT)
			)
			(cond
				(
					(or
						(= (cdr (assoc 0 (entget seEnamPol0))) "LWPOLYLINE")
						(= (cdr (assoc 0 (entget seEnamPol0))) "LINE")
					)
					(setq seEnamPol seEnamPol0
						seFilt seFilt0
						seSetMod seSetMod0
					)
					(command "view" "s" "vv1")
					(command "zoom" "O" seEnamPol "")
					;;
;					(brkstep1 '("seEnamPol" "seFilt" "seSetMod")
;						(list seEnamPol seFilt seSetMod)
;						"01" "SeLPol"
;					)
					;;
					(cond
						(
							(= (type seFilt) 'LIST)
							(setq seSetFn
								(ssget "F"
									(mapcar 'cdr
										(lscod seEnamPol '(10 11))
									)
									seFilt
								)
							)
						)
						(
							(not (= (type seFilt) 'LIST))
							(setq seSetFn
								(ssget "F"
									(mapcar 'cdr
										(lscod seEnamPol '(10 11))
									)
								)
							)
						)
					);cond seleccion seFilt
					;;
;					(brkstep1 '("seSetFn" "(sslength seSetFn)")
;						(list seSetFn (sslength seSetFn))
;						"02" "SelPol"
;					)
					;;
					(command "view" "R" "vv1")
					(command "view" "D" "vv1")
					(cond
						(
							(= (type seSetFn) 'PICKSET)
							(cond
								(
									(= seSetMod 0)
									(ssdel seEnamPol seSetFn)
								)
								(
									(= seSetMod 1)
									(setq seSetFn (ssadd seEnamPol seSetFn))
								)
							)
							;;
;							(brkstep1 '("seSetMod" "(sslength seSetFn)")
;								(list seSetMod (sslength seSetFn))
;								"03" "SelPol"
;							)
							;;
							(cond
								(
									(= (sslength seSetFn) 0)
									(setq seSetFn nil)
								)
							)
						)
					);cond seSetMod
				)
			);cond Line o LwPoliline
		)
	);cond type Argumentos
	;;
;	(brkstep1 '("seSetFn") (list seSetFn) "04" "SelPol")
	;;
	(setq seSetFn seSetFn)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:CI
;;SINTAXIS: (NextP1 [Ename] [Coo] [LsDs] [NumIni] [PrecInt] [AngIni] )
;;TITULO: NextP1. Distribuye marcadores (Punta1.dwg) apartir de una lista sobre una polilinea
;;DESCRIPCION: NextP1. Apartir de la definicion de una lista de distancias o una lista de
;;	distancia-marcadores, los redistribuye o inserta sobre una polilinea.
;;	>
;;DEVUELVE:
;;	>liselef. Lista de tramos, angulo de inflexión y coordenadas
;;	> <(NumeroTubo ((CooInicial Angulo Variacion dist (coo1) (coo2)) ...)) (...) ...)>
;;ARGUMENTOS
;;	1. ANA0. Nombre de entidad de polilinea
;;	> ENAME
;;	2.CO1A0. Coordenada de division inicial
;;	> (XY) / (XYZ)
;;	3. DISIE0. Lista de distancias de marcadores (distancia de tubo) o lista
;;		de pares de distancia y nombre de entidad,
;;		 en este caso la distancia es considerada como la distancia
;;		 anterior:
;;	> <Estructura con distancias de marcadores (#.# ...)>
;;	> <Estructura con distancia y marcador ((dist Ename) ...)>
;;	4. NUMINI0. Numeracion inicial
;;		(numero de tubo inicial)
;;	> INT.
;;	5. PREC0. Precision numerica
;;	> (Numero de decimales) <INT>
;;	6. ANGINI0. Angulo inicial (radianes)
;;	> REAL
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>En el caso de reacomodar un marcdor (cuando la estructura del elemento es
;;	dist-Ename), no inserta Etiqueta de numero de tubo.
;; 
;;;(brkstep '("") "001TEMP" "")
;;**************************************************
(defun NextP1
	(ana0 co1a0 disie0 numini0 prec0 angini0 /
		axna co1a disie numini prec angini
		disac co2 discoor con1
		lis1 lisele0 lisele1
		liselef ps1 ps2 numprec
		liselef snapo disi co1 angins rev
		angini2 nextcad nextinf mensacad nextangi 
		ppta1 ppta2 deci msele diatt ecov numinext coini
		din anin mimi co2a anic midonut nePass
		neHand neMarc0 neMarc1 neTubo
		preau naCon1 neEname neIndiE
	)
;	(setq
;		ana nil co1a nil  disie nil numini nil
;		prec nil  angini nil
;		disac nil co2 nil discoor nil con1 nil
;		lis1 nil lisele0 nil lisele1 nil
;		liselef nil ps1 nil ps2 nil numprec nil
;		liselef nil snapo nil disi nil co1 nil angins nil rev nil
;		angini2 nil nextcad nil nextinf nil mensacad nil nextangi nil 
;		ppta1 nil ppta2 nil deci nil msele nil diatt nil ecov nil numinext nil coini nil
;		din nil anin nil mimi nil co2a nil anic nil midonut nil nePass nil
;		neHand nil neMarc0 nil neMarc1 nil neTubo nil preau nil naCon1 nil
;		neEname nil neIndiE nil
;	)
	;br
;	(brkstep1 '("ana0" "co1a0" "disie0" "numini0" "prec0" "angini0")
;		(list ana0 co1a0 disie0 numini0
;			prec0 angini0
;		)
;		"00" "NextP1"
;	)
	;;
	(setq diatt (getvar "attdia")
		ecov (getvar "cmdecho")
		snapo (getvar "osmode")
		preau (getvar "auprec")
		prel (getvar "luprec")
		msele (ssadd)
	)
	(setvar "luprec" 8)
	(setvar "auprec" 8)
	(setvar "osmode" 0)
	(setvar "attdia" 0)
	(setvar "cmdecho" 1)
	(setvar "attdia" 0)
	;;;;;;;;;;;;;;;;;;;;
	(cond
		(
			(and
				(= (type ana0) 'ENAME)
				(= (LsType co1a0) "NUM")
				(= (type disie0) 'LIST)
				(= (type numini0) 'INT)
				;(= (numberp prec0) T)
			)
			(setq
				ana ana0
				co1 co1a0
				disie disie0
				numini numini0
				prec prec0
				angini angini0
			)
			;br
;			(brkstep1 '("ana" "co1" "disie" "numini" "prec" "angini")
;				(list ana co1 disie numini prec angini)
;				"01" "NextP1"
;			)
			;br..
			;;;;;;;;
			(cond
				(
					(=  prec nil)
					(setq numprec 0.00015)
				)
				(
					(< 0 prec)
					(setq numprec
						(expt 10.0 (* -1 prec))
					)
				)
				(
					(= prec 0)
					(setq numprec 0.15)
				)
			)
			;;;;;;;
;			(brkstep1 '("numprec" ) (list numprec) "02" "NextP1")
			;;numprec. Numero decimal de comparación numerica <REAL>
			(setq deci "CONTINUAR"
				co1 (list (nth 0 co1) (nth 1 co1))
				neHand (cdr (assoc 5 (entget ana)))
			)
			(setq con1 (LCoo2 ana co1 prec))
			;br
;			(brkstep1 '("con1" "disie" "co1" "angini" "neHand")
;				(list con1 disie co1 angini neHand)
;				"03" "NextP1"	
;			)
			;br..
			;**DISIE. (#.# ...) -LISTA DE DISTANCIA DE CADENAMIENTO-
			;**CO1 (XY) -COORDENADA INICIAL-
			;**ANGINI. ##.## en radianes -ANGULO INICIAL-
			;neHand. Handlet de polilinea
			;con1. Posicion nth de coordenada correspondiente al tramo inicial
			;(proximo anterior al punto de designacion o punto exacto)
			(cond
				(
					(not (= con1 nil))
					(setq con1 (+ con1 1))
					;(setq lis1 (prepol ana prec))
					(setq lis1
						(mapcar 'cdr (lscod ana '(10)))
					)
					(setq numini (- numini 1)
						naCon1 0
					)
					;br
;				(brkstep1
;						'("con1" "lis1" "numini" "ps1" "disie")
;						(list con1 lis1 numini ps1 disie)
;						"NEXTP1:04" "04"
;					)
					;br..
					;;con1. Coordenada de vertice proximo a marcador inicial
					;**LIS1. Lista de coordenadas de polilinea ((XY) (...) ...)
					;NUMNI. Numero de tubo inicial (-1 para comenzar)
					(while
						(and
							(< con1 (length lis1))
							(not (= deci "SALIR"))
							(< naCon1 (length disie))
						)
						(setq disi
							(nth naCon1 disie)
						)
						(cond
							(
								(= (type disi) 'LIST)
								(setq neEname (nth 1 disi))
								(setq disi (nth 0 disi))
								(setq neIndiE 1)
							)
							(
								(= (numberp disi) T)
								(setq neEname nil)
								(setq neIndiE 0)
							)
						)
						;;
;						(brkstep1
;							'("disie" "disi" "naCon1" "neEname" "neIndiE")
;							(list disie disi naCon1 neEname neIndiE)
;							"05" "NextP1"
;						)
						;;disie. Lista de distancias o par distancias y nombre de entidad
						;disi. Elemento numero (naCon1) de lista disie
						;naCon1. Contador
						;neEname. Nombre de entidad
						;neIndiE. Indicador de tipo de lista <0=lista de distancias / 1=lista de par distancia ename>
						(cond
							(
								(not (= disi nil))
								;;
;								(brkstep1 '("deci") (list deci) "06" "NextP1")
								;;
								(setq disac 0 ps2 0)
								(setq numini (+ numini 1))
								(setq co2 (nth con1 lis1)
									co2 (list (nth 0 co2) (nth 1 co2))
								)
								(setq lisele (list numini co1 (angle co1 co2)))
								(setq coini co1)
								(setq lisele1 nil)
								;;
;								(brkstep1
;									'("disac" "ps2" "numini" "co2" "co1" "lisele")
;									(list disac ps2 numini co2 co1 lisele)
;									"07" "NextP1"
;								)
								;;
								;**DISAC = 0
								;**CO2 (XY)
								;**LISELE (nnTubo (XY)inicial #.##RAD)
								(while
									(and
										(= ps2 0)
										(< con1 (length lis1))
										(not (= deci "SALIR"))
									)
									;;
;									(brkstep1 '("DECI") (list deci) "08" "NextP1")
									;;
									(setq deci nil
										neMarc nil
									)
									(setvar "osmode" 0)
									(command "zoom" "c" co1 "50")
									(setq co2 (nth con1 lis1)
										co2 (list (nth 0 co2) (nth 1 co2))
									)
									(command "zoom" co1 co2)
									;;
;									(brkstep1
;										'("co1" "co2")
;										(list co1 co2)
;										"09" "NextP1"
;									)
									;;
									(command "zoom" "sc" 50)
									(setvar "osmode" snapo)
									;(setq rev (boli2 (list co1 co2) 0.30))
									;;
;									(brkstep1
;										'("CO1" "CO2" "ANGINI" "ANGANTERIOR"
;											"ANGINS"  "ANGULO" "ANGULOACTUAL"
;										)
;										(list co1 co2 angini
;											(dtr2 angini) angins 
;											(angle co1 co2) (dtr2 (angle co1 co2))
;										)
;										"10" "NextP1"
;									)
									;;
									;(command "erase" rev "")
									(cond 
										(
											(equal angini (angle co1 co2) 0.0174533)
											(setq angins 0)
											;;
;											(brkstep1
;												'("angins")
;												(list (dtr2 angins))
;												"11" "NextP1"
;											)
											;;
										)
										(
											(not (equal angini (angle co1 co2) 0.0174533))
											(setq angins (angres5 angini co1 co2  0 prec))
											;;
;											(brkstep1
;												'("angins")
;												(list (dtr2 angins))
;												"12" "NextP1"
;											)
											;;
										)
									)
									(setq angini (round1 (angle co1 co2) prec))
									;;
;									(brkstep1
;										'("disi" "disac"
;											"(- disi disac)" 
;											"Distance Co1 Co2"
;											"con1"
;											"co2" "angini" "angins"
;										)
;										(list disi disac
;											(- disi disac)
;											(distance co1 co2)
;											con1
;											co2 angini angins
;										)
;										"13" "NextP1"
;									)
									;;;;;;;;ANALISIS DE CADENAMIENTO;;;;;;;;;;;;;;;;;;;(0)
									(cond
										(
											(Eq0
												(- disi disac)
												(distance co1 co2)
												numprec
											)
											;(alert "Samehere")
											(setvar "osmode" 0)
											(command "donut" 0 0.8 co2 "")
											(setvar "osmode" snapo)
											(setq midonut (entlast))
											(cam1 (list midonut) '(62 . 1))
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("disac" "(- disi disac)" "DECI")
;												(list disac (- disi disac) deci)
;												"14" "NextP1"
;											)
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setq anin
												(round1 (angle coini co2) prec)
												anic
												(round1 (angle co1 co2) prec)
											)
											(setq
												co2a co2
												din
												(polar coini anin (/ (distance coini co2a) 2))
												din
												(polar din (sumang anin 1.5708) 2)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("DIN" "ANIN" "NUMINI (TXT)" "CO2A")
;												(list din anin numini co2a)
;												"15" "NextP1"
;											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setvar "osmode" 0)
											(cond
												(
													(= neEname nil)
													(command "insert"
														"NumeroTubo"
														(strcat (cortxt din) ",0") 1 1
														;0
														(round1 (dtr2 (AngCam anin)) 3)
														;(dtr2 anin)
														(itoa numini)
													)
													(setq neTubo (entlast)
														mimi (cdr (assoc 5 (entget neTubo)))
													)
													(command "insert"
														"punta1"
														(strcat (cortxt co2a) ",0") 1 1
														(dtr2 anic)
														(itoa (+ numini 1))
														"-"
														"-"
													)
													(setq neMarc1 (entlast))
													(xinat0
														'("ELEMENTO"
															"ID_POL"
															"DIST_ANTERIOR"
															"DIST_POSTERIOR"
															"TUBO_ANTERIOR"
															"TUBO_POSTERIOR"
														)
														(list "MARCADOR" neHand
															(rtos disi 2 2) "-"
															(itoa numini) "-"
														)
														"-" "AZ-CIVIL" neMarc1
													)
													(xinat0
														'("ELEMENTO" "ID_POL" "DISTANCIA" "NUM_TUBO")
														(list "ETIQUETA" neHand
															(rtos disi 2 2) (itoa numini)
														)
														"-" "AZ-CIVIL" neTubo
													)
												)
												(
													(= (type neEname) 'ENAME)
													(cam1 (list neEname) (append (list 10) co2a))
													(cam1 (list neEname) (cons 50 anic))
													;(camtag
													;	(list neEname)
													;	"NUMERO" (itoa (+ numini 1))
													;)
													(setq neMarc1 neEname)
													;(xin4 neMarc1
													;	(list
													;		(list "ELEMENTO" "MARCADOR")
													;		(list "ID_POL" neHand)
													;		(list "DIST_ANTERIOR" (rtos disi 2 2))
													;		(list "TUBO_ANTERIOR" (itoa numini))
													;		(list "TUBO_POSTERIOR" (itoa (+ numini 1)))
													;	)
													;	"AZ-CIVIL"
													;)
												)
											)
											;;;;;;;;;
;											(brkstep1
;												'("neHand" "neTubo"
;												"neMarc1" "neMarc0"
;													"Distancia" "Tubo"
;												)
;												(list neHand neTubo
;													neMarc1 neMarc0
;													(rtos disi 2 2)
;													numini
;												)
;												"16" "NextP1"
;											)
											;;
											(cond
												(
													(and
														(not (= neMarc0 nil))
														(= neIndiE 0)
													)
													(xin4
														neMarc0
														(list
															(list "DIST_POSTERIOR"
																(rtos disi 2 2)
															)
															(list "TUBO_POSTERIOR"
																(itoa numini)
															)
														)
														"AZ-CIVIL"
													)
												)
											)
											(setq neMarc0 neMarc1);;;;;Insertar nuevo metodo
											;;
											(setvar "osmode" snapo)
											(setq lisele1
												(append lisele1
													(list
														(list 
															(dtr2 angins)
															(round1 (distance co1 co2) prec)
															(dtr2 angini)
															co1
															co2
														)
													)
												)
											)
											(setq disac 0
												co1 co2
												ps2 1
												con1 (+ con1 1)
											)
											;**LISELE1. ((##.##AngRad ##.##DistTramo) (...) ...)
											;**DISAC = 0
											;(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1" "DECI")
											;	(list lisele1 disac co1 co2 ps2 con1 deci)
											;	"17" "NextP1"
											;)
											(entdel midonut)
										)
										(
											(<
												(- disi disac)
												(distance co1 co2)
											)
											;(alert "lessthan")
											;;
;											(brkstep1
;												'("disac" "(- disi disac)")
;												(list disac (- disi disac))
;												"18" "NextP1"
;											)
											;;
											(setq nextcad (rtos (round1 (- disi disac) prec)))
											(setq nextinf (rtos (round1 (distance co1 co2) prec)))
											(setvar "osmode" 0)
											(command "donut" 0 0.8
												(polar co1 (angle co1 co2) (- disi disac))
												""
											)
											(setvar "osmode" snapo)
											(setq midonut (entlast))
											(cam1 (list midonut) '(62 . 1))
											(cond
												(
													(< con1 (- (length lis1) 1))
													(setq nextangi
														(angres5 angini co2 (nth (+ con1 1) lis1) 0 prec)
														nextangi (rtos (dtr2 nextangi))
													)
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("NEXTCAD" "NEXTINF" "NEXTANGI")	
;												(list nextcad nextinf nextangi)
;												"19" "NextP1"
;											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setq anin
												(round1 (angle coini co2) prec)
												anic
												(round1 (angle co1 co2) prec)
											)
											(setq
												co2a
												(polar co1 (angle co1 co2) (- disi disac))
												din
												(polar coini anin (/ (distance coini co2a) 2))
												din
												(polar din (sumang anin 1.5708) 2)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("DIN" "ANIN" "NUMINI (TXT)" "CO2A" "COORDENADA")
;												(list din anin numini co2a (strcat (cortxt din) ",0"))
;												"20" "NextP1"
;											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setvar "osmode" 0)
											(cond
												(
													(= neEname nil)
													(command "insert"
														"NumeroTubo"
														(strcat (cortxt din) ",0") 1 1
														;0
														(round1 (dtr2 (AngCam anin)) 3)
														;(dtr2 anin)
														(itoa numini)
													)
													(setq neTubo (entlast)
														mimi (cdr (assoc 5 (entget neTubo)))
													)
													(command "insert"
														"punta1"
														(strcat (cortxt co2a) ",0") 1 1
														(dtr2 anic)
														(itoa (+ numini 1))
														"-"
														"-"
													)
													(setq neMarc1 (entlast))
													(xinat0
														'("ELEMENTO"
															"ID_POL"
															"DIST_ANTERIOR"
															"DIST_POSTERIOR"
															"TUBO_ANTERIOR"
															"TUBO_POSTERIOR"
														)
														(list "MARCADOR" neHand
															(rtos disi 2 2) "-"
															(itoa numini) "-"
														)
														"-" "AZ-CIVIL" neMarc1
													)
													(xinat0
														'("ELEMENTO" "ID_POL" "DISTANCIA" "NUM_TUBO")
														(list "ETIQUETA" neHand
															(rtos disi 2 2) (itoa numini)
														)
														"-" "AZ-CIVIL" neTubo
													)
												)
												(
													(= (type neEname) 'ENAME)
													(cam1 (list neEname) (append (list 10) co2a))
													(cam1 (list neEname) (cons 50 anic))
;													(camtag
;														(list neEname)
;														"NUMERO"
;														(itoa (+ numini 1))
;													)
													(setq neMarc1 neEname)
;													(xin4 neMarc1
;														(list
;															(list "ELEMENTO" "MARCADOR")
;															(list "ID_POL" neHand)
;															(list "DIST_ANTERIOR" (rtos disi 2 2))
;															(list "TUBO_ANTERIOR" (itoa numini))
;															(list "TUBO_POSTERIOR" (itoa (+ numini 1)))
;														)
;														"AZ-CIVIL"
;													)
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("neHand" "neTubo"
;													"neMarc1" "neMarc0"
;													"Distancia" "Tubo"
;												)
;												(list neHand neTubo
;													neMarc1 neMarc0
;													(rtos disi 2 2)
;													numini
;												)
;												"21" "NextP1"
;											)
											;;
											(cond
												(
													(and
														(not (= neMarc0 nil))
														(= neIndiE 0)
													)
													(xin4
														neMarc0
														(list
															(list "DIST_POSTERIOR"
																(rtos disi 2 2)
															)
															(list "TUBO_POSTERIOR"
																(itoa numini)
															)
														)
														"AZ-CIVIL"
													)
												)
											)
											(setq neMarc0 neMarc1);;;;;;;;;;;;;Insertar nuevo
											;;
											(setvar "osmode" snapo)
											(setq lisele1
												(append lisele1
													(list
														(list
															(dtr2 angins)
															(- disi disac)
															(dtr2 angini)
															co1
															(polar co1 (angle co1 co2) (- disi disac))
														)
													)
												)
											)
											(setq co1
												(polar co1
													(angle co1 co2)
													(- disi disac)
												)
											)
											(setq co1 (list (nth 0 co1) (nth 1 co1)))
											(setq disac 0
												ps2 1
											)
											;;
;											(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
;												(list lisele1 disac co1 co2 ps2 con1)
;												"22" "NextP1"
;											)
											;;
											(entdel midonut)
										)
										(
											(>
												(- disi disac)
												(distance co1 co2)
											)
											;(alert "Morethan")
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("co1" "co2"
;													"(distance co1 co2)"
;													"disac"
;													"(- disi disac)"
;													"disac"
;													"(- disi disac)"
;												)
;												(list co1 co2
;													(distance co1 co2)
;													disac
;													(- disi disac)
;													disac
;													(- disi disac)
;												)
;												"23" "NextP1"
;											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setq nextcad (rtos (round1 (- disi disac) prec)))
											(setq nextinf (rtos (round1 (distance co1 co2) prec)))
											(cond
												(
													(>= con1 (- (length lis1) 1))
													(setvar "osmode" 0)
													(command "donut" 0 0.8 co2 "")
													(setq midonut (entlast))
													(cam1 (list midonut) '(62 . 1))
													(setvar "osmode" snapo)
												)
												(
													(< con1 (- (length lis1) 1))
													(setvar "osmode" 0)
													(command "donut" 0 0.8
														(polar co2 
															(angle co1 (nth (+ con1 1) lis1))
															(- disi (+ disac (distance co1 co2)))
														)
														""
													)
													(setq midonut (entlast))
													(cam1 (list midonut) '(62 . 1))
													(setvar "osmode" snapo)
												)
											)
											(setq lisele1
												(append lisele1
													(list
														(list
															(dtr2 angins)
															(distance co1 co2)
															(dtr2 angini)
															co1
															co2
														)
													)
												)
											)
											(setq disac (+ disac (distance co1 co2)))
											(setq co1 co2)
											(setq con1 (+ con1 1))
											(setq ps2 0)
											;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
;												(list lisele1 disac co1 co2 ps2 con1)
;												"24" "NEXTPOINT"
;											)
											;;;;;;;;;;;;;;;;;;;;;;;;;
											(entdel midonut)
										)
									)
									;;;;;;;;;ANALISIS DE CADENAMIENTO;;;;;;;;;;;;;;;;;;;(1)
								)
								;;
;								(brkstep1 '("lisele1") (list lisele1) "25" "NextP1")
								;; lisele1. lista de elementos  de cadenamiento
								(cond
									(
										(not (= lisele1 nil))
										(setq lisele2
											(append lisele (list lisele1))
										)
										(setq liselef
											(append liselef (list lisele2))
										)
										;(brkstep1
										;	'("LISELE1" "LISELEF"
										;		"DISAC" "CO1" "CO2"
										;		"PS2" "CON1" "ANGINI"
										;		"ANGINS"
										;	)
										;	(list lisele1 liselef
										;		disac co1 co2 ps2 con1
										;		angini angins
										;	)
										;	"25" "NextP1"
										;)
									)
								)
							)
							(
								(= disi nil)
								(setq deci "SALIR")
							)
						)
						;(brkstep1
						;	'("LISELEF")
						;	(list liselef)
						;	"26" "NextP1"
						;)
						(setq naCon1 (+ naCon1 1))
					)
				)
			)
		)
	)
	;;
;	(brkstep1 '("liselef") (list liselef) "27" "NextP1")
	;;
	(princ) (princ)
	(setvar "luprec" prel)
	(setvar "auprec" preau)
	(setvar "osmode" snapo)
	(setq liselef liselef)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:LIST
;;OBJETO / TITULO:JO1. Une dos listas estructuradas
;;SINTAXIS: (JO1 [Lista1] [Lista2] [ValorNulo])
;;DESCRIPCION:JO1. Une dos listas estructuradas (lista de listas) en orden correspondiente, es decir,
;;	el primer elemento de la lista 1 con el primer elemento de la lista 2 y sucesivamente, en caso de
;;	que alguna de las lista sea menor a la otra esta (la menor) crea uno o varios (segun lo necesite)
;;	elementos con la repeticion del valor nulo el numero de veces igual al numero de subelementos que contenga
;;	el primer elemento de la lista menor.
;;
;;	>(setq a '((1 2 3) (4 5) (6))))
;;	>(setq b '((7 8) (9 10)))
;;	>(setq c "non"
;;	>(setq d (jo1 a b c))
;;	>!d ((1 2 3 7 8) (4 5 9 10) (6 “non” "non"))
;;DEVUELVE: LFF. Lista estructurada con las listas del argumento unidas
;;	< ((...) ...)>
;;ARGUMENTOS
;;	1.l10. Lista estructurada (lista de listas)
;;	<((...)...)>
;;	2.l20. lista estructurada (lista de listas)
;;	<((...)...)>
;;	3. trl0. Valor nulo, cualquier valor que no sea nli
;;	< xxx >
;;DEPENDIENTES
;;	< brkstep1 >
;;LOCALIZACION
;;	<FuncionesLisp>
;;HISTORIAL DE CORRECCIONES
;;	>18-04.2019:.Revisión y ajuste de descripcion
;;ANOTACIONES
;;	>Las listas del argumento tienen que ser estructuradas
;;	(lista de listas).
;
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun jo1
	(l10 l20 trl0 /
		l1 l2 trl
		cnt ll1 ll2 pss lrl ctp2 ctp1 eun lff lsrl
	)
;	(setq l1 nil l2 nil trl nil
;		cnt nil ll1 nil ll2 nil pss nil
;		lrl nil ctp2 nil ctp1 nil eun nil lff nil lsrl nil
;	)
	;;
;	(brkstep1 '("l10" "l20" "trl0") (list l10 l20 trl0) "00" "JO1")
	;;
	(cond
		(
			(and
				(= (type l10) 'LIST)
				(= (type l20) 'LIST)
				(not (= trl0 nil))
			)
			(setq l1 l10
				l2 l20
				trl trl0
			)
			(setq cnt 0
				ll1 (length l1)
				ll2 (length l2)
				pss 0
			)
			;;
;			(brkstep1 '("l1" "(length l1)" "ll1" "l2" "(length l2)" "ll2" "trl")
;				(list l1 (length l1) ll1 l2 (length l2) ll2 trl)
;				"01" "JO1"
;			)
			;;
			(cond
				(
					(< ll2 ll1)
					(setq ctp1 ll2
						ctp2 ll1
						lrl (length (nth 0 l2))
					)
				)
				(
					(< ll1 ll2)
					(setq ctp1 ll1
						ctp2 ll2
						lrl (length (nth 0 l1))
					)
				)
				(
					(= ll1 ll2)
					(setq ctp1 ll1
						ctp2 ll2
						lrl (length (nth 0 l1))
					)
				)
			);...Cond
			;;
;			(brkstep1 '("ctp1" "ctp2" "lrl") (list ctp1 ctp2 lrl) "02" "JO1")
			;;ctp1:.Longitud menor de listas
			;;ctp2:.Longitud mayor de listas
			(while (< cnt ctp1)
				(setq eun (append (nth cnt l1) (nth cnt l2)))
				(setq lff (append lff (list eun)))
				(setq cnt (+ cnt 1))
				;;
;				(brkstep1 '("l1" "l2" "eun" "lff" "cnt") (list l1 l2 eun lff cnt) "002" "JO1")
				;;
			)
			;;
;			(brkstep1 '("cnt" "ctp2" "lsrl" "lff") (list cnt ctp2 lsrl lff) "03" "JO1")
			;;eun:.Elementos correspondientes de cada lista unidas en un elemento.
			;;lff:.Lista final
			(setq lsrl (list trl))
			(repeat (- lrl 1)
				(setq lsrl (append lsrl (list trl)))
			)
			;;
;			(brkstep1 '("lsrl") (list lsrl) "04" "JO1")
			;;lsrl:.Lista compuesta por el elemento nulo repetido el numero de veces
			;; igual al numero de subelementos del primer elemento de la lista mas chica
			(while (< cnt ctp2)
				(cond
					(
						(< ll2 ll1)
						(setq eun (append (nth cnt l1) lsrl))
					)
					(
						(< ll1 ll2)
						(setq eun (append lsrl (nth cnt l2)))
					)
				)
				(setq lff (append lff (list eun))
					cnt (+ cnt 1)
				)
				;;
;				(brkstep1 '("l1" "ll1" "l2" "ll2" "lff" "eun" "cnt")
;					(list l1 ll1 l2 ll2 lff eun cnt)
;					"05" "JO1"
;				)
				;;
			);...While
			;;
;			(brkstep1 '("lff") (list lff) "06" "JO1")
			;;
		);...Verificacion de argumentos
	);... Cond
	(setq lff lff)
)
;:...JO1
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BDATA
;;OBJETO: XINAT0. Introduce o sobrescribe atributos
;;	sin importar los datos que contenga con el siguiente
;;	formato:
;;	((1000 . "NomAtt,ValAtt") (...) ...)
;;DEVUELVE: 
;;	>...
;;ARGUMENTOS
;;	1. LISNOM10 Lista de nombre de atributos o primer valor
;;	de cada elemento "XXX,..."
;;	> ("xxx" "xxx" ...)
;;	2.	LISNOM20. Lista de valor de atributos o segundo elemento
;;	de cada elemento "...,XXX"
;;	> ("xxx" "xxx" ...)
;;	3. ELEMNUL0. Elemento Nulo: sustituye en el caso de que el numero
;;	de los elemento sea distintas
;;	4. NOMAPP0. Nombre de la aplicacion
;;	>	"xxx"
;;	5. NOMBENT0. Nombre de entidad
;;<EANME>
;;DEPENDIENTES
;;	> XIN3 ();
;;ANOTACIONES
;;	>	1. Crea pares de datos en orden de cada elemento de lista
;;	(1 2 3) (4 5 6) = (1,4) (2,5) (3,6)
;; > 2. Cuando el numero de elementos es menor a la
;;	otra lista, se sustituye con elementos "nulo" definido
;;	en el argumento.
;;	> 3. Introduce los datos con el codigo 1000
;;;(brkstep '("") "001TEMP" "")
;;	> 4. Solamente trabaja con textos
;;	> 5. El orden de elementos de ambas listas debe
;;	ser el mismo (el primer elemento de la primera lista
;;	corresponde al primer elemento de la segunda, sucesivamente)
;;	> 6. Los elementos nulos siempre se agregan al final de la
;;	lista.
(defun  xinat0
	(lisNom10 lisNom20 elemNul0 nomApp0 nombEnt0 /
		lisNom1 lisNom2 elemNul1  nomApp nombEnt
		elemenF
	)
	;;
;	(setq lisNom1 nil lisNom2 nil elemNul nil nomApp nil nombEnt nil
;		elemenF nil
;	)
	;;
;	(brkstep1
;		'("lisNom10" "(type lisNom10)"
;			"lisNom20" "(type lisNom20)"
;			"elemNul0" "(type elemNul0)"
;			"nomApp0" "(type nomApp0)"
;			"nombEnt0" "(type nombEnt0)"
;		)
;		(list
;			lisNom10 (type lisNom10)
;			lisNom20 (type lisNom20)
;			elemNul0 (type elemNul0)
;			nomApp0 (type nomApp0)
;			nombEnt0 (type nombEnt0)
;		)
;		"00" "xinat0"
;	)
	;;
	(cond
		(
			(and
				(= (type lisNom10) 'LIST)
				(= (type lisNom20) 'LIST)
				(= (type elemNul0) 'STR)
				(= (type nomApp0) 'STR)
				(= (type nombEnt0) 'ENAME)
			)
			(setq lisNom1 lisNom10
				lisNom2 lisNom20
				elemNul elemNul0
				nomApp nomApp0
				nombEnt nombEnt0
			)
			;;
;			(brkstep1 '("lisNom1" "lisNom2" "elemNul" "nomApp" "nombEnt")
;				(list lisNom1 lisNom2 elemNul nomApp nombEnt)
;				"01" "XinAt0"
;			)
			;;
			(setq elemenF
				(txl
					(jo2 (list lisNom1 lisNom2) elemNul)
					3
					","
				)
			)
			;;
;			(brkstep1
;				'("elemenF" "lisNom1" "lisNom2")
;				(list elemenF lisNom1 lisNom2)
;				"02" "XINAT0"
;			)
			;;
			(setq elemenF (lise elemenF))
			(cond
				(
					(not (= elemenF nil))
					(xin3 nomApp nombEnt elemenF)
				)
			)
		);...Argumentos validos
	);...Cond
)
;
;;
;;;
;;;;...XINAT0
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO / TITULO:JO2. Une listas sencillas en una lista
;;		estructurada
;;SINTAXIS:(JO2 [ListaEstructurada] [ValorNulo])
;;DESCRIPCION:JO2. Apartir de la definicion una lista estructurada
;;		crea una lista estructurada donde cada elemento contiene a
;; todos los subelementos que corresponden a su posicion devolviendo una
;; lista estructurada con todos los sub-elementos de una misma longitud.
;;	>ejemplo
;;		Lista: '((1 2 3) (4 5) (6 7 8 9 0))
;;		Elemento nulo: "-"
;;		Devuelve: '((1 4 6) (2 5 7) (3 "-" 8) ("-" "-" 9) ("-" "-" 0))
;;DEVUELVE: Lista estructurada con elementos del mismo tamaño
;;	< ((x ...) ...)>
;;ARGUMENTOS
;;	1.lsls0. Lista estructurada de trabajo
;;	< ((x...) ...)>
;;	2. cNull0. Elemento Nulo
;;DEPENDIENTES
;;	<(jo1a) (lise)>
;;ANOTACIONES
;;	>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun  jo2
	(lsls0 cnull0 /
		lsls cnull
		lsCon1 lsJoin lsJoin0 lsMax lsConMx lsFull lsEl0
	)
;	(setq lsls nil cnull nil
;		lsCon1 nil lsJoin nil lsJoin0 nil lsMax nil lsConMx nil
;		lsFull nil lsEl0 nil
;	)
	;;
;	(brkstep1 '("lsls0" "cNull0") (list lsls0 cNull0) "00" "JO2")
	;;
	(cond
		(
			(and
				(= (type lsls0) 'LIST)
				(not (= cNull0 nil))
			)
			(setq lsls lsls0
				cNull cNull0
				lsConMx 0
			)
			;;
;			(brkstep1
;				'("lsls" "cNull" "lsConMx")
;				(list lsls cNull lsConMx)
;				"01" "JO2"
;			)
			;;
			(while (< lsConMx (length lsls))
				(setq lsMax
					(append lsMax
						(list (length (nth lsConMx lsls)))
					)
				)
				(setq lsConMx (+ lsConMx 1))
			)
			(setq lsMax (apply 'max lsMax))
			;;
;			(brkstep1 '("lsMax") (list lsMax) "02" "JO2")
			;;
			(setq lsConMx 0)
			(while (< lsConMx (length lsls))
				(setq lsEl0 (nth lsConMx lsls))
				(repeat (- lsMax (length lsEl0))
					(setq lsEl0 (append lsEl0 (list cNull)))
				)
				;;
;				(brkstep1 '("lsEl0") (list lsEl0) "03" "JO2")
				;;
				(setq lsFull
					(append lsFull
						(list lsEl0)
					)
				)
				(setq lsConMx (+ lsConMx 1))
				;;
;				(brkstep1 '("lsConMx" "lsFull" "lsEl0")
;					(list lsConMx lsFull lsEl0)
;					"04" "JO2"
;				)
				;;
			)
			;;
;			(brkstep1
;				'("lsls" "cNull" "lsCon1" "lsJoin")
;				(list lsls cNull lsCon1 lsJoin)
;				"05" "JO2"
;			)
			;;
			(setq lsls lsFull
				lsCon1 1
				lsJoin (lise (nth 0 lsls))
			)
			(while
				(< lsCon1 (length lsls))
				(setq lsJoin0 (lise (nth lsCon1 lsls)))
				;;
;				(brkstep1
;					'("lsJoin0")
;					(list lsJoin0)
;					"06" "JO2"
;				)
				;;
				(setq lsJoin (jo1a lsjoin lsJoin0 cNull))
				;;
;				(brkstep1 '("lsJoin") (list lsJoin) "07" "JO2")
				;;
				(setq lsCon1 (+ lsCon1 1))
			);...While
		);...Verificacion de datos
	);...Cond
	(setq lsjoin lsjoin)
)
;
;;
;;;
;;;;...JO2
	
	;;PROYECTO: Lisp
	;;CLASIFICACION: LIST
	;;OBJETO / TITULO: JO1A. Une dos listas estructuradas
	;;SINTAXIS: (JO1A [listEstruct1] [ListEstruct2] [ElemNulo]
	;;DESCRIPCION: JO1A. Apartir de la definicion de dos listas
	;;	estructuradas (lista de listas) y un elemento nulo,
	;;	une las dos listas por elementos correspondientes, es decir,
	;;	el primer elemento de la lista 1 con el primer elemento de
	;;	la lista dos y sucesivamente; en caso de que una lista tenga
	;;	menos elementos que la ortra, la de menor numero de elementos
	;;	creará un elemento con el mismo numero de subelementos del
	;;	elemento de la lista mayor
	;;	>ej,
	;;> lista1 ((1 2 3) (2 5))
	;;> lista2 ((6 7 8 9))
	;;> elemento nulo "non"
	;;> Resultado ((1 2 3 6 7 8 9) (2 5 non non) )
	;;DEVUELVE: jLfn. Lista estructurada con las dos listas unidas
	;;	< ((...) ...)>
	;;ARGUMENTOS
	;;	1.jLs10. Lista estructurada 1
	;;	< ((...) ...)>
	;;	2.jLs20. Lista estructurada 2
	;;	<( (...) ...)>
	;;	3. jLvm0. Elemento para valores nulos (cualquier elemento que no sea nulo)
	;;	<xxx>
	;;DEPENDIENTES
	;;	< >
	;;LOCALIZACION
	;;	<FuncionesLisp>
	;;HISTORIAL DE CORRECCIONES
	;;	>17-04-2019: Revisión y correccion de errores
	;;ANOTACIONES
	;;	>Es necesario que las listas sean listas estructuradas (listas de listas)
	;
	;;;(brkstep1 '("") (list ) "001TEMP" "")
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;(cond
	;	(
	;		(=  ;Ent nil)
	;		(setq ;Dec 0.00015)
	;	)
	;	(
	;		(< 0 ;Ent)
	;		(setq ;Dec
	;			(expt 10.0 (* -1 ;Ent))
	;		)
	;	)
	;	(
	;		(= ;Ent 0)
	;		(setq ;Dec 0.15)
	;	)
	;)
	(defun jo1a
		(jLs10 jLs20 jLvm0 /
			jLs1 jLs2 jLvm
			jEle1 jEle2 jCon1 jMaxLen jLfn jRnum
		)
	;	(setq jLs1 nil jLs2 nil jLvm nil
	;		jEle1 nil jEle2 nil jCon1 nil jMaxLen nil jLfn nil
	;		jRnum nil
	;	)
		;;
	;	(brkstep1
	;		'("jLs10" "jLs20" "jLvm0")
	;		(list jLs10 jLs20 jLvm0)
	;		"00" "JO1a"
	;	)
		;;
		(cond
			(
				(and
					(= (type jLs10) 'LIST)
					(= (type jLs20) 'LIST)
					(not (= jLvm0 nil))
				)
				(setq jLs1 jLs10
					jLs2 jLs20
					jLvm jLvm0
				)
				;;
	;			(brkstep1 '("jLs1" "jLs2" "jLvm")
	;				(list jLs1 jLs2 jLvm)
	;				"01" "JO1a"
	;			)
				;;
				(setq jMaxLen (max (length jLs1) (length jLs2))
					jCon1 0
				)
				;;
	;			(brkstep1
	;				'("jMaxLen" "jCon1" "(length jLs1)" "jLs1"
	;					"(length jLs2)" "jLs2"
	;				)
	;				(list jMaxLen jCon1  (length jLs1) jLs1
	;					(length jLs2) jLs2
	;				)
	;				"02" "JO1a"
	;			)
				;;jMaxLen Maxima longiud de lista entre jLs1 y jLs2
				;<INT>
				(while (< jCon1 jMaxLen)
					;;
	;				(brkstep1
	;					'("jMaxLen" "jCon1" "(length jLs1)"
	;						"(nth jCon1 jLs1)" "jLs1"
	;						"(length JLs2)" "(nth jCon1 jLs2)" "jLs2"
	;					)
	;					(list jMaxLen jCon1 (length jLs1)
	;						(nth jCon1 jLs1) jLs1
	;						(length jLs2) (nth jCon1 jLs2) jLs2
	;					)
	;					"03" "JO1A"
	;				)
					;;
					(cond
						(
							(and 
								(>= jCon1 (length jLs1))
								(< jCon1 (length jLs2))
							)
							(setq jRnum (length (nth jCon1 jLs2)))
							(setq jEle1 ())
							(repeat jRnum
								(setq jEle1 (append jEle1 (list jLvm)))
							)
							(setq jEle2 (nth jCon1 jLs2))
							;;
	;						(brkstep1
	;							'("jEle1" "jEle2" "jRnum")
	;							(list jEle1 jEle2 jRnum)
	;							"04" "JO1a"
	;						)
							;;
						)
						(
							(and
								(>= jCon1 (length jLs2))
								(< jCon1 (length jLs1))
							)
							(setq jRnum (length (nth jCon1 jLs1)))
							(setq jEle2 ())
							(setq jEle2
								(repeat jRnum
									(setq jEle2 (append jEle2 (list jLvm)))
								)
							)
							(setq jEle1 (nth jCon1 jLs1))
							;;
	;						(brkstep1
	;							'("jEle1" "jEle2" "jRnum")
	;							(list jEle1 jEle2 jRnum)
	;							"05" "JO1a"
	;						)
							;;
						)
						(
							(and
								(< jCon1 (length jLs1))
								(< jCon2 (length jLs2))
							)
							(setq jEle1 (nth jCon1 jLs1)
								jEle2 (nth jCon1 jLs2)
							)
							;;
	;						(brkstep1 
	;							'("jEle1" "jEle2") (list jEle1 jEle2)
	;							"06" "JO1a"
	;						)
							;;
						)
					);...Cond
					;;
	;				(brkstep1 '("jEle1" "jEle2") (list jEle1 jEle2) "07" "JO1a")
					;;
					(setq jLfn
						(append jLfn
							(list (append jEle1 jEle2))
						)
					)
					;;
	;				(brkstep1 '("jLfn" "jCon1") (list jLfn jCon1) "08" "JO1a")
					;;
					(setq jCon1 (+ jCon1 1))
				)
				;;
	;			(brkstep1 '("jLfn") (list jLfn) "09" "JO1A")
				;;
			);...Validacion de Argumentos
		);...Cond
		(setq jLfn jLfn)
	)
	;
	;;
	;;;JO1a
	;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO / TITULO: BC0. Cuenta el numero de veces que se repite el elemento
;;	en la lista de trabajo.
;;SINTAXIS: (Bc0 [ListaTrbajo] [ElementoDeBusqueda])
;;DESCRIPCION: BC0. A partir de una lista de trabajo devuelve el numero de veces que
;;	un elemento de buqueda definido en el argumento.
;;	>
;;DEVUELVE: Numero de veces que se repite el elemento del argumento.
;;	<INT>
;;ARGUMENTOS
;;	1. lbc0. Lista de trabajo.
;;	< (x ...) >
;;	2. cbc0. Elemento de busqueda
;;	<xxx>
;;DEPENDIENTES
;;	< >
;;ANOTACIONES
;;	> Misma funcion que BC pero simplificada para elementos no
;;	numericos.
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bc0
	(lbc0 cbc0 /
		lbc cbc
		ccon rs
	)
;	(setq lbc nil cbc nil
;		ccon nil rs nil
;	)
	;;
;	(brkstep1 '("lbc0" "cbc0") (list lbc0 cbc0) "00" "BC0")
	;;
	(cond
		(
			(and
				(= (type lbc0) 'LIST)
				(not (= cbc0 nil))
			)
			(setq lbc lbc0 cbc cbc0)
;			(brkstep1 '("lbc" "cbc") (list lbc cbc) "01" "BC0")
			(setq ccon 0
				rs 0
			)
			(While (< ccon (length lbc))
				(cond
					(
						(equal (nth ccon lbc) cbc 0.015)
						(setq rs (+ rs 1))
					)
				)
				(setq ccon (+ ccon 1))
			)
			(cond
				(
					(= rs 0)
					(setq rs nil)
				)
			)
			(setq rs rs)
		);...Validacion de argumentos
	);...Cond
)
;
;;
;;;
;;;;...BC0
;;PROYECTO: Lisp
;;CLASIFICACION: PH:. Manipulacion de datos y administración de archivos
;;OBJETO / TITULO: Vere. Verifica la existencia de un archivo.
;;SINTAXIS: (Vere [rutaCompleta])
;;DESCRIPCION: Vere. A partir de la definicion de una ruta completa
;; ruta. nombre y archivo. verifica si el archviivo existe o no.
;;	> t / f
;;DEVUELVE: ress1
;;	 <T:. Si existe el archivo >
;;	 <nil:. Si no existe el archivo >
;;ARGUMENTOS
;;	1. rrt0:. Ruta completa del archivo a vereficar
;; 		Ruta con "\\"  o "/"
;;	<STRING >
;;DEPENDIENTES
;;	< >
;;LOCALIZACION
;;	<Dropbox:..00SOLUCIONESCAD/CADDapps/FuncionesLisp:..>
;;ANOTACIONES
;;	>
;
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun Vere
	(rrt0 /
		ress res0 ress1
	)
;	(setq rrt nil
;		ress nil res0 nil ress1 nil
;	)
	;;
;	(brkstep1 '("rrt0" "Type_rrt0") (list rrt0 (type rrt0))
;		"00" "VERE"
;	)
	;;
	(cond
		(
			(= (type rrt0) 'STR)
			(setq rrt rrt0)
			(setq ress (open rrt "r"))
			;;
;			(brkstep1 '("ress") (list ress) "01" "VERE")
			;;ress:. Id de archivo abierto
			(cond
				(
					(not (= ress nil))
					(setq ress1 t)
					(setq ress (close ress))
				)
				(
					(= ress nil)
					(setq ress1 nil)
				)
			);...cond ress
			;;
;			(brkstep1 '("ress1") (list ress1) "02" "VERE")
			;;ress1:. Resultado de comprobacion <t/f>
			(setq ress1 ress1)
		);...cond rrt0 = string
	);...Cond rrt0
);:.VERE
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MDAT
;;OBJETO / TITULO: ESCR1. Escritura de lista de cadena de texto en archivo.
;;SINTAXIS:(Escr1 [ListaCadena] [NombreArchivo] [Extension] [Ruta] [Modo])
;;DESCRIPCION: ESCR1. Apartir de la definicion de una lista sencilla de cadenas
;;	de texto, nombre de archivo, extension, ruta de localizacion de archivo
;;	y modo de escritura, escribe o agrega cada cadena de texto en una linea de un
;;	archivo externo.
;;	>
;;DEVUELVE:
;;	< >
;;ARGUMENTOS
;;	1.LTA0. Lista de cadenas de texto donde cada cadena se escribira en una
;;	linea del archivo
;;	< ( "xx,xxx,xx" ....) >
;;	2.NMBR0. Nombre de archivo
;;	< "xxx" >
;;	3.XTE0. Extension de archivo
;;	< "xx" >
;;	4.RTU0. Nombre de la ruta; el separador de carpetas puede ser
;;	"\\" ó "/"; se puede omitir (), si es omitido se solicita la definicion
;;	de parte del usuario.
;;	<"xxx\\xxx\\">
;;	5.MMD0. Modo de escritura:
;;	> 0. Crea un archivo nuevo o reemplaza el existente
;,	> 1. Agrega los datos en el archivo existente al final. 
;;DEPENDIENTES
;;	<BRKSTEP1;RUTN;SUTX>
;;LOCALIZACION
;;	<FOOII>
;;HISTORIAL DE CORRECCIONES
;;	> 2019-04-21:. Primer registro
;;	> 2019-06-17:.. Verificacion de terimacnion de ruta
;;ANOTACIONES
;;	>
;
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;
(defun escr1
	(lta0 nmbr0 xte0 rtu0 mmd0 /
		lta nmbr xte rtu mmd
		cnn vr mrtu arr1 xteR
	)
;	(setq
;		lta nil nmbr nil xte nil rtu nil mmd nil
;		cnn nil vr nil mrtu nil arr1 nil xtreR nil
;	)
	;;
;	(brkstep1 
;		'("lta0" "nmbr0" "xte0" "rtu0" "mmd0" "TipoDatos")
;		(list lta0 nmbr0 xte0 rtu0 mmd0
;			(and
;				(= (type lta0) 'LIST)
;				(= (type nmbr0) 'STR)
;				(= (type xte0) 'STR)
;				(= (type mmd0) 'INT)
;			)
;		)
;		"00" "Escr1"
;	)
	;;
;	(brkstep1
;		'("(= (type lta0) 'LIST)"
;			"(= (type nmbr0) 'STR)"
;			"(= (type xte0) 'STR)"
;			"(= (type mmd0) 'INT)"
;		)
;		(list
;			(= (type lta0) 'LIST)
;			(= (type nmbr0) 'STR)
;			(= (type xte0) 'STR)
;			(= (type mmd0) 'INT)
;		)
;		"000" "Escr1"
;	)
	;;
	(cond
		(
			(and
				(= (type lta0) 'LIST)
				(= (type nmbr0) 'STR)
				(= (type xte0) 'STR)
				(= (type mmd0) 'INT)
			)
			(setq lta lta0
				nmbr nmbr0
				xte xte0
				rtu rtu0
				mmd mmd0
			)
			;;
;			(brkstep1 '("lta" "nmbr" "xte" "rtu" "mmd")
;				(list lta nmbr xte rtu mmd) "01" "Escr1"
;			)
			;;
			(cond
				(
					(= rtu nil)
					(setq rtu (rutn nmbr xte "DE ESCRITURA"))
				)
			);...
			;;
;			(brkstep1 '("rtu") (list rtu) "02" "EscR1")
			;;
			(cond
				(
					(not (= rtu nil))
					(cond
						(
							(or
								(= (substr rtu (strlen rtu) 1) "\\")
								(= (substr rtu (strlen rtu) 1) "/")
							)
							(setq mrtu (strcat rtu nmbr "." xte))
						)
						(
							(and
								(not (= (substr rtu (strlen rtu) 1) "\\"))
								(not (= (substr rtu (strlen rtu) 1) "/"))
							)
							;;
;							(brkstep1 '("Extension?")
;								(list
;									(substr rtu
;										(+ 1 (- (strlen rtu) (strlen xte)))
;											(strlen xte)
;										)
;								)
;								"002" "EscR1"
;							)
							(setq xteR
								(substr rtu
									(+ 1
										(- (strlen rtu)
											(strlen xte)
										)
									)
									(strlen xte)
								)
							)
							;;
;							(brkstep1 '("xteR") (list xteR) "002a" "Escr1")
							;;:...xteR ternimación de ruta
							;;:..Verificacion de extension
							;;:.. en ruta (rtu)
							(cond
								(
									(= xte xteR)
									(setq mrtu rtu)
								)
								(
									(not (= xte xteR))
									(setq mrtu
										(strcat
											rtu "\\" nmbr "." xte
										)
									)
								)
							);;:..mrtu: Ruta armada
;							(brkstep1
;								'("mrtu") (list mrtu) "0002" "EscR1"
;							)
						)
					);:..Cond Terminacion "\\"
				)
			);;:..Cond rtu not nil
			;;
;			(brkstep1 '("mrtu") (list mrtu) "03" "EscR1")
			;;
			(cond
				(
					(not (= mrtu nil))
					(setq mrtu (sutx mrtu (list (list "/" "\\"))))
					;;
;					(brkstep1 '("mrtu" "mmd") (list mrtu mmd) "04" "EscR1")
					;;mrtu:...Ruta de escritura con "\\"
					(cond
						(
							(= mmd 0)
							(setq arr1 (open mrtu "w"))
						)
						(
							(= mmd 1)
							(setq arr1 (open mrtu "a"))
						)
					);:..Cond apertura de archivo (agrega o sbre-escribe)
					;;
;					(brkstep1 '("arr1") (list arr1) "05" "EscR1")
					;;
					(cond
						(
							(not (= arr1 nil))
							(setq cnn 0)
							(while (< cnn (length lta))
								(write-line (nth cnn lta) arr1)
								(setq cnn (+ cnn 1))
							);:..While
							(close arr1)
						)
					);:..Cond (not (= arr1 nil))
				)
			);:..Cond (not (= mrtu nil))
		)
	);..Cond tipo argumentos
);..Escr1
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MDAT
;;OBJETO / TITULO: DAT. Extrae los datos de un archivo externo como cadenas de texto
;;SINTAXIS: (DAT [Ruta])
;;DESCRIPCION:DAT. A partir de una ruta y nombre de archivo; extrae los
;;	datos de un archivo externo, devolviendo una lista de cadenas de texto
;;	donde cada elemento corresponde a cada linea del archivo.
;;	>
;;DEVUELVE: lsFin. Lista de cadenas de texto de datos importados
;;	< ("xxxx" ...)>
;;ARGUMENTOS
;;	1.lsRu0. Ruta y nombre de archivo para extraer datos.
;;	< "xxx" >
;;DEPENDIENTES
;;	< >
;;ANOTACIONES
;;	> Si el argumento de ruta es lista:. toma el primer
;;	elemento como ruta
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dat
	(lsRu0 /
		lsRu
		arch pas cara lsLst lsFin
	)
;	(setq lsRu nil
;		arch nil pas nil cara nil lsLst nil lsFin nil
;	)
	;;
;	(brkstep1 '("lsRu0") (list lsRu0) "00" "DAT")
	;;
	(cond
		(
			(= (type lsRu0) 'LIST)
			(setq lsRu0 (nth 0 lsRu0))
		)
	)
	(cond
		(
			(= (type lsRu0) 'STR)
			(setq lsRu lsRu0)
			(setq arch (open lsRu "r")
				pas 0
			)
			(setq cara (read-line arch))
			;;
;			(brkstep1 '("cara") (list cara) "01" "DAT")
			;;cara. Linea de archivo <"xx">
			(cond
				(
					(or (= cara nil)(= cara ""))
					(setq cara (read-line arch))
				)
			);VERIFICA QUE EXISTAN DATOS EN EL ARCHIVO (1a VEZ)
			;;
			;(brkstep1 '("cara") (list cara) "02" "DAT")
			;;
			(cond
				(
					(or (= cara nil) (= cara ""))
					(alert "NO EXISTEN DATOS EN EL ARCHIVO")
				)
			);CONFIRMA QUE NO EXISTAN DATOS EN EL ARCHIVO (2a LINEA)
			(while (not (or (= cara nil) (= cara "")))
				(setq lsLst (append lsLst (list cara)))
				(setq cara (read-line arch))
				;;
				;(brkstep1 '("cara" "lsLst") '(cara lsLst) "03" "DAT")
				;;lsLst. Lista de datos dada por cadenas de textos <("xxx" ...)>
				;;cara. linea de datos de archivo <"xxxx">
			)
			(close arch)
		);...Type lsRu0
	);...Cond
	;;
;	(brkstep1 '("lsLst") (list lsLst) "04" "DAT")
	;;
	(setq lsFin lsLst)
)
;
;;
;;;
;;;;...DAT
;:PROYECTO:
;;	> Lisp
;:CLASIFICACION:
;;	> ENT
;:FUNCION / TITULO:
;; > CAMB. Visualiza las entidades de acuerdo al modo indicado
;:SINTAXIS:
;;	> (CAMB [ListaEname] [Modo])
;:DESCRIPCION:
;;	<<
;;	CAMB. A partir de una lista de nombre de entidades:.
;;	visualiza las entidades de acuerdo al modo indicado
;;	>>
;:EJEMPLO:
;;	<<
;;
;;	>>
;:DEVUELVE:
;;	<<
;;
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. lft0. Lista de nombre de entidades
;;	<(ename ...)>
;;	2. mod0. Modo de visualizacion
;;	<1. Muestra las entidades>
;;	<2. Oculta las entidades>
;;	<3. Muestra entidades en seleccion>
;;	<4. Muestra entidades des-seleccionadas> 
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;	>
;:HISTORIAL DE CORRECCIONES:
;;	>
;:ANOTACIONES:
;;	>
;:ESTADO:
;;	>Terminado Probado por Registrar
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun camb
	(lft0 mod0 /
		lft mod
		con1 a
	)
;	(setq lft nil mod nil
;		con1 nil mod nil
;	)
	;br
;	(brkstep1
;		'("lft0" "mod0") (list lft0 mod0)
;		"CAMB:00" "00"
;	)
	;br..
	(cond
		( ;condtype
			(and
				(equal (LsType lft0) 'ENAME)
				(equal (type mod0) 'INT)
			)
			(setq lft lft0
				mod mod0
			)
			;br
;			(brkstep1
;				'("lft" "mod") (list lft mod)
;				"CAMB:01" "01"
;			)
			;br..
			(mapcar '(lambda (a) (redraw a mod)) lft)
		)
	)
)
;
;;
;;;;
;:PROYECTO:
;;<Lisp>
;:CLASIFICACION:
;;<PH>
;:FUNCION / TITULO:
;;<TERM. Arregla una ruta con la separacion de carpetas y termino en \\>
;:SINTAXIS:
;;<(TERM [Ruta])>
;:DESCRIPCION:
;;<<
;;	TERM. Apartir de la definicion de una ruta (cadena de texto)
;;	Revisa que el caracter de separacion de las carpetas
;;	sea de "\\" y la terminacion se en "\\".
;;>>
;:EJEMPLO:
;;<<
;;	(setq pf11Rt "C:/Users/jrsto/OneDrive/Documentos")
;;	(setq pf11Res (term pf11Rt))
;;	>pf11Res: C:\Users\jrsto\OneDrive\Documentos\
;;>>
;:DEVUELVE:
;;<<
;;	TeRes. Ruta arreglada
;;	<"xxx">
;:ARGUMENTOS:
;;<<
;;	1.InRt0: Ruta de trabajo
;;	<"xxx">
;:DEPENDIENTES:
;;<brkstep1 sutx>
;:LOCALIZACION:
;;<C:\\Dropbox\\...\\FuncionesLisp>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;>2022.06.21:. Creado
;;>>
;:ANOTACIONES:
;;<<
;;>La separacion entre carpetas es \\
;;>La terminacion de la ruta es con \\
;;>>
;:ESTADO:
;;<<
;;	>Actualizado
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun term
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
);Defun..
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:TXT Manipulación de textos
;;OBJETO / TITULO: SUTX. Sustituye una serie de caracteres por otros en una cadena de texto
;;SINTAXIS: (SUTX [CadenaTxt] [ListaCaracteres])
;;DESCRIPCION:SUTX. Apartir de la definicion de una cadena de texto
;; y una lista estructurada de pares donde el primer elemento de cada 
;; sublista corresponde al caracter original que va a ser cambiado y
;; el segundo elemento de cada sublista corresponde al caracter que
;; va a tomar su lugar, sustituye cada cada caracter en la cadena de texto
;;	>
;;DEVUELVE:txCf:. Cadena de texto con los caracteres sustituidos
;;	<"xxxx">
;;ARGUMENTOS
;;	1.txCm0:.Cadena de texto
;;	<"xxxx">
;;	2.lxCm0:. Lista estructurada de pares de caracteres
;;	donde el primer elemento corresponde al caracter original
;;	y el segundo al caracter que tomara su lugar
;;<((CaracterOriginal CaracterSustituto) (...)...)>
;;DEPENDIENTES
;;	<brkstep1>
;;LOCALIZACION
;;	<FOO>
;;HISTORIAL DE CORRECCIONES
;;	>2019-05-06:. Primer registro y revision
;;	>2019-05-23:. Segundo revision
;;	>2021-12-21:. Revision OK
;;ANOTACIONES
;;	> algoritmo:..Recorre toda la cadena de texto con el primer par de
;;	caracteres, sustituyendo la cadena original para pasar al siguiente
;;	par de caracteres y así sucesivamente.
;;	> Tomar en cuenta el algoritmo para ordenar la lista de pares de caracteres
;;	a sustituir:
;;	a = "Cadena de texto"
;;	b = '(("a" "ui") ("i" "1"))
;;	 (sutx a b)
;;	 "Cuidenui de texto" ;...Primer par’
;;	 "Cu1denu1 de texto" :...Segundo par
;;	 "Cu1denu1 de texto" :...Cadena final
;
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sutx
	(txcm0 lxcm0 /
		txcm lxcm
		vtx ntx txcf tcn pcn tcn1 txcm1
	)
;	(setq txCm nil lxCm nil
;		vtx nil ntx nil txCf nil tcn nil pcn nil tcn1 nil txCm1 nil
;	)
	;;
;	(brkstep1 '("txCm0" "(type txCm0)" "lxCm" "(type lxCm)")
;		(list txCm0 (type txCm0) lxCm0 (type lxCm0))
;		"00" "sutx"
;	)
	;;
	(cond
		(
			(and
				(= (type txCm0) 'STR)
				(= (type lxCm0) 'LIST)
			)
			(setq txCm txCm0
				lxCm lxCm0
			)
			;;
;			(brkstep1 '("txCm" "lxCm") (list txCm lxCm) "01" "SUTX")
			;;:..txCm. Nueva variable Cadena de texto
			;:... lxCm Nueva variable de lista de caracteres a sustituir
			(setq tcn1 0
				txcm1 txcm
			)
			(while (< tcn1 (length lxcm));...Ciclo1 longitud de lista de caracteres
				(setq ntx (nth 1 (nth tcn1 lxcm))
					vtx (nth 0 (nth tcn1 lxcm))
				)
				;;
;				(brkstep1 '("ntx" "vtx") (list ntx vtx) "02" "SUTX")
				;;ntx:.Caracter sustituto
				;vtx:. Caracter original
				(cond
					(
						(and
							(not (= ntx nil))
							(not (= vtx nil))
						)
						(setq pcn 0
							tcn 1
						)
						(while (<= tcn (strlen txcm));...Ciclo2 longitud de cadena de argumento
							;;
;							(brkstep1 '("vtx" "(substr txCm tcn 1)" "pcn") (list vtx (substr txCm tcn 1) pcn) "002" "Sutx")
							;;pcn:..Pase de escritura
							(cond
								(
									(= (substr txcm tcn 1) vtx)
									(cond
										(
											(= pcn 0)
											(setq txcf ntx
												pcn 1
											)
										)
										(
											(= pcn 1)
											(setq txcf (strcat txcf ntx))
										)
									)
								);:.caracter = original
								(
									(not (= (substr txcm tcn 1) vtx))
									(cond
										(
											(= pcn 0)
											(setq txcf (substr txcm tcn 1)
												pcn 1
											)
										);:.pcn=0
										(
											(= pcn 1)
											(setq txcf (strcat txcf (substr txcm tcn 1)))
										)
									);cond Pcn
								)
							);:..Cond y= caraterTxt caracterLista
							(setq tcn (+ tcn 1))
							;;
;							(brkstep1 '("tcn" "txcf" "txCm") (list tcn txcf txCm) "03" "Sutx")
							;;txCf. Cadena de texto final con caracteres cambiados
							;;<str>
						);:..Ciclo2...While CadenaTxt
					)
				);:..Cond ntx/vtx not nil
				(setq tcn1 (+ tcn1 1)
					txcm txcf
				)
			);:...Ciclo1 longitud de lista de caracteres
		)
	);:..Cond Validación de argumentos
);...SUTX
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: TXT
;;FUNCION / TITULO:
;;	><<Sepa. Separa una cadena de textos en dos dependiendo
;;	del caracter de separacion inidcado en el argumento (seIndi)
;;	>>
;;SINTAXIS:
;;	<(sepa ruta[""] CaracterSeparacion[""])>
;;DESCRIPCION:
;;	><<
;;	Apartir de la definicion de una ruta como cadena de texto
;;	y un caracter de separacion. separa la ruta en dos cadenas
;; Ruta y archivo omitiendo el caracter de separacion
;;	>>
;;EJEMPLO:
;;	><<
;;	"C:\\Users\\joserra\\Documents\\Blocks" se separa en
;;	"C:\\Users\\joserra\\Documents" "Blocks"
;;	omitiendo el caracter "\\" que los separa
;;	El objeto busca de atras hacia adelante hasta encontrar
;;	el caracter indicado.
;;	>>
;;DEVUELVE:
;;	><<
;;	Lista de dos elementos. el primero corresponde a la ruta
;;	el segundo al archivo
;;	(PrimerElem SegundoElem)
;;	>>
;;ARGUMENTOS:
;;	><<
;;	1.seRut0
;;	<Nombre de ruta [""]>
;;	2.seIndi0
;;	<Caracter de separacion [""]>
;;	>>
;;DEPENDIENTES
;;	< BRKSTEP1 >
;;LOCALIZACION
;;	<FOOII><Original>
;;HISTORIAL DE CORRECCIONES
;;	>2021.12.22:.Probado y registrado
;;	><<2022.01.21:.Arreglo Devuelve la misma cadena de ruta
;;	si no encuentra el caracter de separacion,
;;	si el caracter de separacion esta al final o al inicio
;;	de la cadena
;;	>>
;;ANOTACIONES
;;	>
;
;;ESTADO
;;	> Probado
;;	> Actualizado
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)

(defun sepa
	(seRut0 SeIndi0 /
		seRut seIndi
		seCn sePs seFru seNom seRu seFru
	)
;	(setq seRut nil seIndi nil
;		seCn nil sePs nil seNom nil seRu nil seFru nil
;	)
	;;br
	;(brkstep1  '("seRut0" "seIndi0") (list seRut0 seIndi0) "00:sepa" "00")
	;;br..
	(cond
		(;..Cond General
			(and (= (type seRut0) 'STR)
				(= (type seIndi0) 'STR)
			)
			(setq seRut seRut0
				seIndi seIndi0
			)
			(setq seCn (strlen seRut)
				sePs 0
			)
			(while
				(and (< 0 seCn)
					(= sePs 0)
				)
				(cond ;.. Cond seIndi
					(
						(= (substr Serut seCn 1) seIndi)
						(setq seNom (substr seRut (+ seCn 1) (strlen seRut))
							seRu (substr seRut 1 (- seCn 1))
							sePs 1
							seCn 0
						)
					)
					(
						(not (= (substr seRut seCn 1) seIndi))
						(setq seCn (- seCn 1))
					)
				);..Cond SeIndi
      );..While
			(cond
				(
					(and
						(not (= seRu nil))
						(not (= SeNom nil))
					)
					(setq seFru (list seRu SeNom))
				)
				(
					(and
						(= seRu nil)
						(not (= seNom nil))
					)
					(setq seFru (list seNom))
				)
				(
					(and
						(not (= seRu nil))
						(= seNom nil)
					)
					(setq seFru (list seRu))
				)
				(
					(and
						(= seRu nil)
						(= seNom nil)
					)
					(setq seFru (list seRut))
				)
			)
    );..Cond General
  );..Cond
	;;br
;	(brkstep1 '("seRu" "seNom" "seFru")
;		(list seRu seNom seFru)
;		"02:SEPA" "SEPA"
;		)
	;;br..
	(setq seFru seFru)
)
;....Sepa	
;
;;
;;;
;;;;
;;PROYECTO:
;;<Lisp>
;;CLASIFICACION:
;;<FUN>
;;FUNCION / TITULO:
;;<ComLsp2. Compila (escribe) una parte de codigo en un archivo nuevo>
;;SINTAXIS:
;;<<
;;	(compLsp2
;;		[ArchivoOrig] [RutaDestino]
;;		[ArchivoDestino] [Extension]
;;		[Modo] [LimiteInicial] [LimiteFinal]
;;	)
;;>>
;;DESCRIPCION:
;;<<
;;	ComLsp2. Apartir de la seleccion de un archivo..
;;	la definicion de una cadena inicial y una cadena final..
;;	Crea y escribe una seccion de este en un nuevo archivo
;;>>
;;EJEMPLO:
;;<<
;;	pf6Ar: Testi2 (nombre archivo destino)
;;	pf6Rt: C:\Users\jrsto\Dropbox\ (ruta destino)
;;	pf6Orig:C:\Users\jrsto\Dropbox\LispATT_PSB.lsp (archivo orig)
;;	pf6In: descripcion (limite inicial)
;;	pf6Fn: nil (limite final)
;;	(setq pf6Res
;;		(compLsp2 pf6Orig pf6Rt pf6Ar "lsp" 0 pf6In pf6Fn)
;;	)
;;	pf6Res: C:\Users\jrsto\Dropbox\Testi2.lsp
;;	si el archivo se creo correctamente devuelve su ruta
;;	y nombre
;;>>
;;DEVUELVE:
;;<<
;;	comRes.Nombre y ruta del archivo complilado o
;;	nil si no creo ninguna aplicacion
;;	"C: xx/xxx.lsp"
;;>>
;;ARGUMENTOS
;;<<
;;	1.comFnc0. nombre y ruta del archivo de donde se extrae
;;	la informacion en una sola cadena (con extension)
;;	"xxx" :.String.:
;;	2.comRt0. Ruta de archivo donde se escribira la informacion
;;	 "xx\\...\\" :.string.:
;;	3.comNam0. Nombre del archivo que se creara para escribir
;;	la informacion (sin extension) :.strig.:
;;	3.comExt0. Extension (sin punto) del archivo donde se va a
;;	escribir la informacion. "xxx" :.string.:
;;	4.comMod0. Modo de transcripcion de codigo
;;	> 0. Transcripcion de codigo sin comentarios
;;	> 1. Transcripcion de codigo con comentarios
;;	5.comIni0. Cadena de texto inicial
;;	(nil) para comenzar desde el principio
;;	:.String.:
;;	6.comFin0. Cadena de texto final (nil)
;;	para transcribir hasta el final
;;	:.String.:
;;>>
;;DEPENDIENTES
;;<Brkstep1 QuiTx MatchTx>
;;LOCALIZACION
;;<Dropbox\...\FuncionesLisp\>
;;HISTORIAL DE CORRECCIONES
;;<2022/06/06:.Terminado>
;;ANOTACIONES
;;<<
;;	> Los separadores de carpetas son con \\
;;	>	En la cadena de carpetas siempre tiene que terminar en \\
;;	> La definicion de la extension se escribe sin punto.
;;;>>
;;ESTADO:
;;<<
;;	Terminado
;;	Probado
;;	Registrado
;;>>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun CompLsp2
	(comFnc0 comRt0 comNam0 comExt0 comMod0
		comIni0 comFin0	/
		comFnc comRt comNam comExt comMod
		comIni comFin
		comOpFnc comFnLn comPasFnc
		comRes  comAr0 comOpAr0 comFinPas
		comCar comCon3 comLn
		comInd comPsw comPar comPss
	)
;	(setq comFnc nil comRt nil comNam nil comExt nil comMod nil comIni nil comFin nil
;		comOpFnc nil comFnLn nil comPasFnc nil
;		comRes  nil comAr0 nil comOpAr0 nil
;		comCar nil comCon3 nil comLn nil comFinPas nil
;		comInd nil comPsw nil comPar nil comPss nil
;	)
	;br
;	(brkstep1 
;		'("comFnc0" "comRt0" "comNam0" "comExt0" "comMod0" "comIni0" "comFin0")
;		(list comFnc0 comRt0 comNam0 comExt0
;			comMod0 comIni0 comFin0)
;		"CompLsp2:00" "00"
;	)
	;br..
	(cond
		(;condType
			(and
				(= (type comFnc0) 'STR)
				(= (type comRt0) 'STR)
				(= (type comNam0) 'STR)
				(= (type comExt0) 'STR)
				(= (type comMod0) 'INT)
			)
			(setq comFnc comFnc0
				comRt comRt0
				comNam comNam0
				comExt comExt0
				comMod comMod0
				comIni comIni0
				comFin comFin0
			)
;			;br
;			(brkstep1
;				'("comFnc" "comRt" "comNam" "comExt" "comMod" "comIni" "comFin")
;				(list comFnc comRt comNam comExt comMod comIni comFin)
;				"ComLsp2:01" "01"
;			)
			;br..
			(setq comAr0 (strcat comRt comNam "." comExt)
				comOpAr0 (open comAr0 "w")
			)
			;br
;			(brkstep1
;				'("comAr0" "comOpAr0")
;				(list comAr0 comOpAr0)
;				"CompLsp2:02" "02"
;			)
			;br..
			(setq comOpFnc (open comFnc "r"))
			;br
;			(brkstep1
;				'("comOpFnc")
;				(list comOpFnc)
;				"CompLsp2:03" "03"
;			)
			;br..
			(cond
				(;condComOpFnc=T
					(not (= comOpFnc nil))
					(setq comPasFnc 1)
					(cond
						(
							(= comIni nil)
							(setq comInd 1
								comPsw 0
							)
						)
						(
							(not (= comIni nil))
							(setq comInd 0
								comPsw 1
							)
						)
					)
					;br
;					(brkstep1
;						'("comIni" "comPsw")
;						(list comIni comPsw)
;						"CompLsp2:04" "04"
;					)
					;br..
					(while (= comPasFnc 1)
						(setq comFnLn (read-line comOpFnc)
							comPss 0
						)
						(cond
							(
								(or
									(= (matchTx comIni comFnLn 1) t)
									(= (matchTx comFin comFnLn 1) t)
								)
								(setq comInd (+ comInd 1)
									comPar (rem comInd 2)
								)
								(cond
									(
										(= comPsw 0)
										(setq comPsw 1)
									)
									(
										(= comPsw 1)
										(setq comPsw 0)
									)
								)
							)
							(
								(and
									(= (matchTx comIni comFnLn 1) nil)
									(= (matchTx comFin comFnLn 1) nil)
								)
								(setq comInd (+ comInd 2)
									comPar (rem comInd 2)
								)
							)
						)
						(cond
							(
								(and (= comPsw 1) (= comPar 0))
								(setq comPss 1
									comPsw 0
								)
							)
							(
								(= comPar 1)
								(setq comPss 1)
							)
						)
						;br
;						(brkstep1
;							'("comFnLn" "comIni" "comFin" "comInd" "comPsw" "comPar" "comPss")
;							(list comFnLn comIni comFin comInd comPsw comPar comPss)
;							"CompLsp2:05" "05"
;						)
						;br..
						(cond
							(
								(= comFnLn nil)
								(setq comPasFnc 0)
							)
							(
								(and
									(= comMod 1)
									(= comPss 1)
								)
								(write-line comFnLn comOpAr0)
								(setq comFinPas 1)
							)
							(;condQuitx
								(and
									(= comMod 0)
									(not (= (QuiTx "\t" comFnLn) nil))
									(= comPss 1)
								)
								(setq comCar nil
									comCon3 1
									comPas3 0
									comLn nil
								)
								(while
									(and
										(not (= comCar ";"))
										(<= comCon3 (strlen comFnLn))
									)
									(setq comCar (substr comFnLn comCon3 1))
									(cond
										(;condComCar
											(not (= comCar ";"))
											(if
												(= comPas3 0)
												(progn
													(setq comPas3 1
														comLn comCar
													)
												)
												(setq comLn (strcat comln comCar))
											)
											;br
;											(brkstep1
;												'("comLn") (list comLn) "pf2:06" "06"
;											)
											;br..
										);condComCar..
									);cond..
									(setq comCon3 (+ comCon3 1))
								);while..
								;br
;								(brkstep1
;									'("comLn") (list comLn) "pf2:07" "07"
;								)
								;br..
								(cond
									(
										(and (not (= comLn nil))
											(not (= (QuiTx "\t" comLn) nil))
											(= comPss 1)
										)
										(setq comFnLn comLn)
										(write-line comFnLn comOpAr0)
										(setq comFinPas 1)
									)
								)
							);condQuitx..
						);cond..
					);whileComPasFnc
					(close comOpFnc)
					(close comOpAr0)
				);condComOpFnc=T
			);cond..
		);condType
	);cond..
	(if
		(= comFinPas 1)
		(setq comRes comAr0)
	)
	(setq comRes comRes)
);defun..	

;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:CI
;;SINTAXIS: (NextP1 [Ename] [Coo] [LsDs] [NumIni] [PrecInt] [AngIni] [FormNom])
;;TITULO: NextP1. Distribuye marcadores (Punta1.dwg) apartir de una lista sobre una polilinea
;;DESCRIPCION: NextP1. Apartir de la definicion de una lista de distancias o una lista de
;;	distancia-marcadores, los redistribuye o inserta sobre una polilinea.
;;	>
;;DEVUELVE:
;;	>liselef. Lista de tramos, angulo de inflexión y coordenadas
;;	> <(NumeroTubo ((CooInicial Angulo Variacion dist (coo1) (coo2)) ...)) (...) ...)>
;;ARGUMENTOS
;;	1. nxLsCoo0. lista de coordenadas
;;	> ((xx xxx xxx) (...)...)
;;	2.CO10. Coordenada de division inicial
;;	> (XY) / (XYZ)
;;	3. DISIE0. Lista de Datos de levantamiento (filtrada)
;;	> <(xhead ...) (xx ..) (...) ...)>
;;	4. NUMINI0. Numeracion inicial
;;		(numero de tubo inicial)
;;	> INT.
;;	5. PREC0. Precision numerica
;;	> (Numero de decimales) <INT>
;;	6. ANGINI0. Angulo inicial (radianes)
;;	> REAL
;;	7.nxAf0. Nombre de archivo de Formulas
;;	<"xxx">
;;	8.nxEq0. Nombre de archivo de equivalencia (bloques)
;;	<"xxx">
;;	9.nxDr0. Datos de rutas
;;	10.nxLim0. Longitud de limite de predio
;;	11.nxNv0. Offset de insercion de nivel socioeconomico
;;	12.nxBl0. Offset de inserción de bloques
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>En el caso de reacomodar un marcdor (cuando la estructura del elemento es
;;	dist-Ename), no inserta Etiqueta de numero de tubo.
;; 
;;;(brkstep '("") "001TEMP" "")
;;**************************************************
(defun NxtLv2
	(nxLsCoo0 co10 disie0 numini0 prec0 angini0 nxAf0 nxEq0 
		nxDr0 nxLim0 nxNv0 nxBl0 /
		nxLsCoo co1 disie numini prec angini nxAf nxEq
		nxDr nxLim nxNv nxBl nxPos
		disac co2 discoor con1
		lis1 lisele0 lisele1
		liselef ps1 ps2 numprec
		snapo disi co1 angins rev
		angini2 nextcad nextinf mensacad nextangi 
		ppta1 ppta2 deci msele diatt ecov numinext coini
		din anin mimi co2a anic midonut nePass
		neMarc0 neMarc1 neTubo
		preau naCon1 neEname neIndiE
		nxPd nxDat nxCon0 disie1
		nxF nxHead nxTbl nxEl nxEqLs
		nxFac nxFacMsj
		diatt ecov snapo preau prel msele
	)
;	(setq
;		nxLsCoo nil co1 nil  disie nil numini nil 
;		prec nil  angini nil nxAf nil nxEq nil
;		nxDr nil nxLim nil nxNv nil nxBl nil nxPos nil
;		disac nil co2 nil discoor nil con1 nil
;		lis1 nil lisele0 nil lisele1 nil
;		liselef nil ps1 nil ps2 nil numprec nil
;		snapo nil disi nil co1 nil angins nil rev nil
;		angini2 nil nextcad nil nextinf nil mensacad nil nextangi nil 
;		ppta1 nil ppta2 nil deci nil msele nil diatt nil ecov nil numinext nil coini nil 
;		din nil anin nil mimi nil co2a nil anic nil midonut nil nePass nil
;		neMarc0 nil neMarc1 nil neTubo nil preau nil naCon1 nil
;		neEname nil neIndiE nil
;		nxPd nil nxDat nil nxCon0 nil disie1 nil
;		nxF nil nxHead nil nxTbl nil nxEl nil nxEqls nil
;		nxFac nil nxFacMsj nil
;		diatt nil ecov nil snapo nil preau nil prel nil msele nil
;	)
	;br
;	(brkstep1
;		'("nxLsCoo0" "co10" "disie0" "numini0" "prec0" "angini0" "nxAf0" "nxEq0" "nxDr0" "nxLim0" "nxNv0" "nxBl0")
;		(list nxLsCoo0 co10 disie0 numini0 prec0 angini0 nxAf0 nxEq0
;			nxDr0 nxLim0 nxNv0 nxBl0
;		)
;		"NxtLv2:00" "00"
;	)
	;br..
	(setq diatt (getvar "attdia")
		ecov (getvar "cmdecho")
		snapo (getvar "osmode")
		preau (getvar "auprec")
		prel (getvar "luprec")
		msele (ssadd)
	)
	(setvar "luprec" 8)
	(setvar "auprec" 8)
	(setvar "osmode" 0)
	(setvar "attdia" 0)
	(setvar "cmdecho" 1)
	(setvar "attdia" 0)
	;;;;;;;;;;;;;;;;;;;;
	(cond
		(;Cond type T
			(and
				(= (type nxLsCoo0) 'LIST)
				(= (LsType co10) "NUM")
				(= (type disie0) 'LIST)
				(= (type numini0) 'INT)
				(= (numberp prec0) T)
				(= (type nxAf0) 'STR)
				(= (type nxEq0) 'STR)
				(= (type nxDr0) 'LIST)
				(= (numberp nxLim0) T)
				(= (numberp nxNv0) T)
				(= (numberp nxBl0) T)
			)
			(setq
				nxLsCoo nxLsCoo0
				co1 co10
				disie disie0
				numini numini0
				prec prec0
				angini angini0
				nxAf nxAf0
				nxEq nxEq0
				nxDr nxDr0
				nxLim nxLim0
				nxNv nxNv0
				nxBl nxBl0
			)
			;br
;			(brkstep1
;				'("nxLsCoo" "co1" "disie" "numini" "prec" "angini" "nxAf"
;					"nxEq" "nxDr" "nxLim" "nxNv" "nxBl"
;				)
;				(list nxLsCoo co1 disie numini prec angini nxAf
;					nxEq nxDr nxLim nxNv nxBl)
;				"NxtLv2:01" "01"
;			)
			;br..
			;;;;;;;;
			(cond
				(
					(=  prec nil)
					(setq numprec 0.00015)
				)
				(
					(< 0 prec)
					(setq numprec
						(expt 10.0 (* -1 prec))
					)
				)
				(
					(= prec 0)
					(setq numprec 0.15)
				)
			)
			;;;;;;;
			;br
;			(brkstep1 '("numprec" ) (list numprec) "02" "NextP1")
			;br..
			;;numprec. Numero decimal de comparación numerica <REAL>
			;;;;;;;DEFININICION DE PARAMETROS DE INSERCIÓN;;;(0)
			;;..
			;;;;;;DEFINICION DE PARAMETROS DE INSERCIÓN;;;;;(1)
			;;;;;;;;;;;;IMPORTACION DE TABLAS;;;;;;;;;;;;;;;;;;;(0)
			(setq nxTbl nxDr ;Datos de rutas
				nxF ;Datos de formulas
				(vere02 nxTbl nxAf (list "FORMULAS" "SELECCIONA EL ARCHIVO DE FORMULAS"));Datos de formulas..
				nxEqls ;datos de equivalencias
				(vere02 nxTbl nxEq
					(list "EQUIVALENCIA" "SELELCCIONA EL ARCHIVO DE EQUIVALENCIAS")
				);datos de equivalencias..
				nxHead
					(nth 0 disie)
			)
			;;;;;;;;LIMPIEZA DE FORMULAS;;;;;;;;;;;;(0)
			(if ;limpieza en Formulas
				nxf
				(progn
					(setq nxF (lnpo4 "non" nxF 1 0 0.001))
				)
			)
			;;;;;;;;LIMPIEZA DE FORMULAS;;;;;;;;;;;;(1)
			;br
;			(brkstep1
;				'("nxTbl" "nxF" "nxHead")
;				(list nxTbl nxF nxHead)
;				"NxtLv2:02" "02"
;			)
			;br..
			;;;;;;;;;;;;;;;;;;IMPORTACION DE TABLAS;;;;;;;;;;;;;;;;;(1)..
			
			(setq co1 (list (nth 0 co1) (nth 1 co1)));xy..
			(setq con1 0)
			;br
;			(brkstep1 '("con1" "disie" "co1" "angini")
;				(list con1 disie co1 angini)
;				"NxtLv2:03" "03"	
;			)
			;br..
			;;;;;;;;LIMPIEZA DE TABLA DE DATOS;;;;;;;;;;(0)
			(setq nxPd
				(nth 0
					(Qnth00 (nth 0 disie) "Distancia" 0.001)
				)
				disie
				(append
					(list (nth 0 disie))
					(orden4
						(cdr (lnpo4 "non" disie 0 0 0.0001))
						0
						nxPd
						3
					)
				)
				nxDat disie ;;Lista levantamiento arreglada por distancia
				disie ;;disie =  Lista de distancias continua
				(append
					(list 0)
					(cdr (lss nxDat (+ 1 nxPd)))
				)
			)
			;;;;;;;;FACTOR DE ESCALA;;;;;;(0)
			(setq nxFac
				(/ (DsPol () nxLsCoo) (nth (- (length disie) 1) disie))
			)
			;;;;;;;;FACTOR DE ESCALA;;;;;;(1)
			(setq nxFacMsj
				(strcat
					"FACTOR DE DESVIACION DE ESCALA:\n" "\t" (rtos nxFac)
				)
			)
			(alert nxFacMsj)
			;br
;			(brkstep1
;				'("disie" "nxDat" "nxFac") (list disie nxDat nxFac)
;				"NxtLv2:04" "04"
;			)
			;br..
			(setq nxCon0 0)
			(while
				(< nxCon0 (length disie))
				(cond
					(
						(= (numberp (nth (+ nxCon0 1) disie)) T)
						(setq disie1
							(append disie1
								(list
									(- (nth (+ nxCon0 1) disie)
										(nth nxCon0 disie)
									)
								)
							)
						)
					)
				)
				(setq nxCon0 (+ nxCon0 1))
			) ;Disie1 lista de distancias inter
			
			;br
;			(brkstep1
;				'("disie1") (list disie1)
;				"NxtLv2:05" "05"
;			)
			;br..
			(setq disie1
				(mapcar
					'(lambda (i) (* nxFac i))
					disie1
				);Insersion de Factor escala;;;;;
			)
			;br
;			(brkstep1
;				'("disie1") (list disie1)
;				"NxtLv2:06" "06"
;			)
			;br..
			(setq disie disie1
				disie1 nil
			) ;disie = lista de distancias inter elementos
			;br..
			;;;;;;;;LIMPIEZA DE TABLA DE DATOS;;;;;;;;;;(1)
			;**DISIE. (#.# ...) -LISTA DE DISTANCIAS INTER-
			;**nxDat. ((xHead ...) (xx ...) (...) ...)
			;LISTA DE DATOS DE LEVANTAMIENTO
			;**CO1 (XY) -COORDENADA INICIAL-
			;**ANGINI. ##.## en radianes -ANGULO INICIAL-
			;con1. Posicion nth de coordenada correspondiente al tramo inicial
			;(proximo anterior al punto de designacion o punto exacto)
			(cond
				( ;Cond con1 T
					(not (= con1 nil))
					(setq con1 (+ con1 1))
					(setq lis1 nxLsCoo) ;Lista de coordenadas
					(setq numini (- numini 1)
						naCon1 0
						loPre nil
					)
					;;
;					(brkstep1
;						'("nxDat" "con1" "lis1" "numini" "ps1" "disie")
;						(list nxDat con1 lis1 numini ps1 disie)
;						"NxtLv:07" "07"
;					)
					;;
					;;con1. Posicion de coordenada de vertice proximo a marcador inicial
					;**LIS1. Lista de coordenadas de polilinea ((XY) (...) ...)
					;NUMNI. Numero inicial (-1 para comenzar)
					;NaCon1 Contador para lista de coordenadas de
					;polilinea
					(while
						(and
							(< con1 (length lis1))
							(< naCon1 (length disie))
						)
						(setq disi
							(nth naCon1 disie) ;Elemento (Distancia)
							nxEl (nth naCon1 (cdr nxDat)) ;Registro (elemento x de tabla de datos)
						)
						;br
;						(brkstep1
;							'("disie" "naCon1" "disi" "neEname" "neIndiE" "nxEl"
;								"length disie" "length nxdat"
;							)
;							(list disie naCon1 disi neEname neIndiE nxEl
;								(length disie) (length nxDat)
;							)
;							"NxtLv2:08" "08"
;						)
						;br..
						;;disie. Lista de distancias
						;disi. Elemento numero (naCon1) de distancias
						;naCon1. Contador
						(cond
							(;Cond disi T
								(not (= disi nil))
								(setq disac 0 ps2 0)
								(setq numini (+ numini 1))
								(setq co2 (nth con1 lis1);
									co2 (list (nth 0 co2) (nth 1 co2));xy.. Coordenada 2 de tramo
								)
								(setq lisele (list numini co1 (angle co1 co2))) ;numero coordenada angulo
								(setq coini co1)
								(setq lisele1 nil)
								;br
;								(brkstep1
;									'("disac" "ps2" "numini" "co2" "co1" "lisele")
;									(list disac ps2 numini co2 co1 lisele)
;									"NxtLv2:09" "09"
;								)
								;br..
								;**DISAC = 0
								;**CO1 (XY) PRIMERA COORDENADA DE TRAMO
								;**CO2 (XY) SEGUNDA COORDENADA DE TRAMO
								;**LISELE (Numero (XY)inicial #.##RAD)
								(while
									(and
										(= ps2 0)
										(< con1 (length lis1))
									)
									;br
;									(brkstep1 '("con1") (list con1)
;										"NxtLv2:10" "10"
;									)
									;br..
									(setvar "osmode" 0)
									(command "zoom" "c" co1 50)
									(setq co2 (nth con1 lis1)
										co2 (list (nth 0 co2) (nth 1 co2))
									)
									(command "zoom" co1 co2)
									;br
;									(brkstep1
;										'("co1" "co2")
;										(list co1 co2)
;										"NxtLv2:11" "11"
;									)
									;br..
									(command "zoom" "sc" 50)
									(setvar "osmode" snapo)
									;(setq rev (boli2 (list co1 co2) 0.30))
									;br
;									(brkstep1
;										'("CO1" "CO2" "ANGINI" "ANGANTERIOR"
;											"ANGINS"  "ANGULO" "ANGULOACTUAL"
;										)
;										(list co1 co2 angini
;											(dtr2 angini)
;											angins 
;											(angle co1 co2)
;											(dtr2 (angle co1 co2))
;										)
;										"NxtLv2:12" "12"
;									)
									;br..
									;(command "erase" rev "")
									(cond 
										(
											(equal angini
												(angle co1 co2)
												0.0174533
											)
											(setq angins 0)
											;br
;											(brkstep1
;												'("angins")
;												(list (dtr2 angins))
;												"NxtLv2:14" "14"
;											)
											;br..
										)
										(
											(not
												(equal
													angini (angle co1 co2)
													0.0174533
												)
											)
											(setq angins (angres5 angini co1 co2  0 prec))
											;br
;											(brkstep1
;												'("angins")
;												(list (dtr2 angins))
;												"NxtLv2:15" "15"
;											)
											;br..
										)
									)
									(setq angini
										(round1 (angle co1 co2) prec)
									)
									;br
;									(brkstep1
;										'("disi" "disac"
;											"(- disi disac)" 
;											"Distance Co1 Co2"
;											"con1"
;											"co2" "angini" "angins"
;										)
;										(list disi disac
;											(- disi disac)
;											(distance co1 co2)
;											con1
;											co2 angini angins
;										)
;										"NxtLv2:16" "16"
;									)
									;br..
									;;;;;;;;ANALISIS DE CADENAMIENTO;;;;;;;;;;;;;;;;;;;(0)
									(cond
										(;Cond SAMEHERE
											(Eq0
												(- disi disac)
												(distance co1 co2)
												numprec
											)
					;;;;;;;;;;;;;;;;;;;;;SAMEHERE;;;;;;;;;;;;;;;;;;;;						
;											(alert "Samehere")
											(setvar "osmode" 0)
											(command "donut" 0 0.5 co2 "")
											(setvar "osmode" snapo)
											(setq midonut (entlast))
											(cam1 (list midonut) '(62 . 1))
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;br
;											(brkstep1
;												'("disac" "(- disi disac)")
;												(list disac (- disi disac))
;												"NxtLv2:17" "17"
;											)
											;br..
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setq anin
												(round1 (angle coini co2) prec)
												anic
												(round1 (angle co1 co2) prec)
											)
											(setq co2a co2)
											;br
;											(brkstep1
;												'("conini" "co2a" "loPre") (list coini co2A loPre)
;												"NxtLv2:18" "18"
;											)
											;br..
											;br
;											(brkstep1
;												'("lopre") (list lopre)
;												"NxtLv2:18A" "18A"
;											)
											;br..
											;;;;;;;;COORDENADA DE LOTE PREVIO;;;;;(0)
											(cond
												(
													(= loPre nil)
													(setq	din
														(polar coini anin
															(/ (distance coini co2a) 2)
														)
														din
														(polar din (sumang anin 1.5708) 2)
													)
												)
												(
													(not (= lopre nil))
													(if
														(= (type lopre) 'STR)
														(progn
															(setq lopre
																(mapcar 'atof
																	(sepa02 lopre ",")
																)
															)
														)
													)
													(setq	din
														(polar loPre anin
															(/ (distance coini co2a) 2)
														)
														din
														(polar din (sumang anin 1.5708) 2)
													)
												)
											)
											;;;;;;;;COORDENADA DE LOTE PREVIO;;;;;(1)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											(brkstep1
;												'("DIN" "ANIN" "NUMINI (TXT)" "CO2A" "LOPRE" "DIN")
;												(list din anin numini co2a lopre din)
;												"NxtLv2:19" "29"
;											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setvar "osmode" 0)
											;br
;											(brkstep1
;												'("nxf" "nxdr" "nxDat" "nxEqls" "nxEl"
;													"anic" "anin" "co2a" "din"
;												)
;												(list nxf nxdr nxDat nxEqls nxEl
;													anic anin co2a din
;												)
;												"NxtLv2:20" "20"
;											)
											;br..
											;br
;											(brkstep1
;												'("Tip anic" "Tip anin" "tip co2a" "Tip din" "Tip nxf"
;													"Tip nxdr" "Tip nxDat" "Tip nxEqls" "Tip nxEl"
;												)
;												(list (type anic) (type anin) (LsType co2a) (LsType din)
;													(type nxf) (type nxdr) (type nxDat) (type nxEqls)
;													(type nxEl)
;												)
;												"NxtLv2:21" "21"
;											)
											;br..
					;;;;;;;;;;;;;;;INDAT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(0)
											(setq lopre
												(inDat anic anin co2A
													din nxF nxDr nxDat
													nxEqls nxEl
												)
											)
											;br
;											(brkstep1
;												'("lopre") (list lopre)
;												"NxtLv2:22" "22"
;											)
											;br..
					;;;;;;;;;;;;;;INDAT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(1)
											(setvar "osmode" snapo)
											(setq lisele1
												(append lisele1
													(list
														(list 
															(dtr2 angins)
															(round1 (distance co1 co2) prec)
															(dtr2 angini)
															co1
															co2
														)
													)
												)
											)
											(setq disac 0
												co1 co2
												ps2 1
												con1 (+ con1 1)
											)
											;**LISELE1. ((##.##AngRad ##.##DistTramo) (...) ...)
											;**DISAC = 0
											;br
;											(brkstep1
;												'("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
;												(list lisele1 disac co1 co2 ps2 con1)
;												"NxtLv2:23" "23"
;											)
											;br..
											(entdel midonut)
										);Cond SAMEHERE..
										(;Cond LESSTHAN
											(<
												(- disi disac)
												(distance co1 co2)
											)
							;;;;;;;;;;;;;;;LESSTHAN;;;;;;;;;;;;;;
;											(alert "lessthan")
											;
;											(brkstep1
;												'("disac" "(- disi disac)")
;												(list disac (- disi disac))
;												"NxtLv2:24" "24"
;											)
											;;
											(setq nextcad (rtos (round1 (- disi disac) prec)))
											(setq nextinf (rtos (round1 (distance co1 co2) prec)))
											(setvar "osmode" 0)
											(command "donut" 0 0.5
												(polar co1 (angle co1 co2) (- disi disac))
												""
											)
											(setvar "osmode" snapo)
											(setq midonut (entlast))
											(cam1 (list midonut) '(62 . 1))
											(cond
												(
													(< con1 (- (length lis1) 1))
													(setq nextangi
														(angres5 angini co2 (nth (+ con1 1) lis1) 0 prec)
														nextangi (rtos (dtr2 nextangi))
													)
												)
											)
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;br
;											(brkstep1
;												'("NEXTCAD" "NEXTINF" "NEXTANGI")	
;												(list nextcad nextinf nextangi)
;												"NxtLv:25" "25"
;											)
											;br..
											;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setq anin
												(round1 (angle coini co2) prec)
												anic
												(round1 (angle co1 co2) prec)
											)
											(setq
												co2a
												(polar co1 (angle co1 co2) (- disi disac))
											)
											;br
;											(brkstep1
;												'("lopre") (list lopre)
;												"NxtLv2:25A" "25A"
;											)
											;br..
											;;;;;;;;COORDENADA DE LOTE PREVIO;;;;;(0)
											(cond
												(
													(= loPre nil)
													(setq	din
														(polar coini anin
															(/ (distance coini co2a) 2)
														)
														din
														(polar din (sumang anin 1.5708) 2)
													)
												)
												(
													(not (= lopre nil))
													(if
														(= (type lopre) 'STR)
														(progn
															(setq lopre
																(mapcar 'atof
																	(sepa02 lopre ",")
																)
															)
														)
													)
													(setq	din
														(polar loPre anin
															(/ (distance coini co2a) 2)
														)
														din
														(polar din (sumang anin 1.5708) 2)
													)
												)
											)
											;;;;;;;;COORDENADA DE LOTE PREVIO;;;;;(1)
											;br
;											(brkstep1
;												'("lopre") (list lopre)
;												"NxtLv2:25B" "25B"
;											)
											;br..
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;br
;											(brkstep1
;												'("DIN" "ANIN" "NUMINI (TXT)" "CO2A" "COORDENADA")
;												(list din anin numini co2a (strcat (cortxt din) ",0"))
;												"NxtLv2:26" "26"
;											)
											;br..
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setvar "osmode" 0)
											;br
;											(brkstep1
;												'("nxdr" "nxDat" "nxEqls" "nxEl"
;													"anic" "anin" "co2a" "din" "nxf"
;												)
;												(list nxdr nxDat nxEqls nxEl
;													anic anin co2a din nxf
;												)
;												"NxtLv2:27" "27"
;											)
											;br..
											;br
;											(brkstep1
;												'("Tip anic" "Tip anin" "Tip co2a" "Tip din" "Tip nxf"
;													"Tip nxdr" "Tip nxDat" "Tip nxEqls" "Tip nxEl"
;												)
;												(list (type anic) (type anin) (LsType co2a) (LsType din)
;													(type nxf) (type nxdr) (type nxDat) (type nxEqls)
;												(type nxEl)
;											)
;												"NxtLv2:28" "28"
;											)
											;br..
										;;;;;;;;;;;;;;;;;;INDAT;;;;;;;;;;;;;;;;;(0)
											(setq lopre
												(inDat anic anin co2a
													din nxF nxDr nxDat
													nxEqls nxEl
												)
											)
											;br
;											(brkstep1
;												'("LOPRE") (list lopre)
;												"NxtLv2:29" "29"
;											)
											;br..
										;;;;;;;;;;;;;;INDAT;;;;;;;;;;;;;;;;;;;;;;(1)
											;;
											(setvar "osmode" snapo)
											(setq lisele1
												(append lisele1
													(list
														(list
															(dtr2 angins)
															(- disi disac)
															(dtr2 angini)
															co1
															(polar co1 (angle co1 co2) (- disi disac))
														)
													)
												)
											)
											(setq co1
												(polar co1
													(angle co1 co2)
													(- disi disac)
												)
											)
											(setq co1 (list (nth 0 co1) (nth 1 co1)))
											(setq disac 0
												ps2 1
											)
											;;
											;br
;											(brkstep1 '("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
;												(list lisele1 disac co1 co2 ps2 con1)
;												"NxtLv2:30" "30"
;											)
											;br..
											;;
										);Cond LESSTHAN..
										(;Cond MORETHAN
											(>
												(- disi disac)
												(distance co1 co2)
											)
								;;;;;;;;;;;;;;MORETHAN;;;;;;;;;;;;;;;;			
;											(alert "Morethan")
									;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											;br
;											(brkstep1
;												'("co1" "co2"
;													"(distance co1 co2)"
;													"disac"
;													"(- disi disac)"
;													"disac"
;													"(- disi disac)"
;												)
;												(list co1 co2
;													(distance co1 co2)
;													disac
;													(- disi disac)
;													disac
;													(- disi disac)
;												)
;												"NxtLv2:31" "31"
;											)
											;br..
											;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
											(setq nextcad (rtos (round1 (- disi disac) prec)))
											(setq nextinf (rtos (round1 (distance co1 co2) prec)))
											(cond
												(
													(>= con1 (- (length lis1) 1))
													(setvar "osmode" 0)
													(command "donut" 0 0.5 co2 "")
													(setq midonut (entlast))
													(cam1 (list midonut) '(62 . 1))
													(setvar "osmode" snapo)
												)
												(
													(< con1 (- (length lis1) 1))
													(setvar "osmode" 0)
													(command "donut" 0 0.8
														(polar co2 
															(angle co1 (nth (+ con1 1) lis1))
															(- disi (+ disac (distance co1 co2)))
														)
														""
													)
													(setq midonut (entlast))
													(cam1 (list midonut) '(62 . 1))
													(setvar "osmode" snapo)
												)
											)
											(setq lisele1
												(append lisele1
													(list
														(list
															(dtr2 angins)
															(distance co1 co2)
															(dtr2 angini)
															co1
															co2
														)
													)
												)
											)
											(setq disac (+ disac (distance co1 co2)))
											(setq co1 co2)
											(setq con1 (+ con1 1))
											(setq ps2 0)
											;;;;;;;;;;;;;;;;;;;;;;;
											;br
;											(brkstep1
;												'("LISELE1" "DISAC" "CO1" "CO2" "PS2" "CON1")
;												(list lisele1 disac co1 co2 ps2 con1)
;												"NxtLv2:32" "32"
;											)
											;br..
											;;;;;;;;;;;;;;;;;;;;;;;;;
										);Cond MORETHAN..
									);Cond..
									;br
;									(brkstep1
;										'("midonut") (list midonut)
;										"NxtLv2:32A" "32A"
;									)
									;br..
									(entdel midonut)
									;;;;;;;;;ANALISIS DE CADENAMIENTO;;;;;;;;;;;;;;;;;;;(1)
								);While..
								;;
								;br
;								(brkstep1 '("lisele1") (list lisele1) "NxtLv2:33" "33")
								;
								;; lisele1. lista de elementos  de cadenamiento
								(cond
									(
										(not (= lisele1 nil))
										(setq lisele2
											(append lisele (list lisele1))
										)
										(setq liselef
											(append liselef (list lisele2))
										)
										;br
;										(brkstep1
;											'("LISELE1" "LISELEF"
;												"DISAC" "CO1" "CO2"
;												"PS2" "CON1" "ANGINI"
;												"ANGINS"
;											)
;											(list lisele1 liselef
;												disac co1 co2 ps2 con1
;												angini angins
;											)
;											"NxtLv2:33" "33"
;										)
										;br..
									)
								)
							);Cond disi T..
							(
								(= disi nil)
								(setq naCon1 (length disie))
							)
						);Cond..
						;br
;						(brkstep1
;							'("LISELEF")
;							(list liselef)
;							"NxtLv2:34" "34"
;						)
						;br..
						(setq naCon1 (+ naCon1 1))
					);While..
				);Cond con1 T..
			);Cond..
		);Cond type T..
	);Cond..
	;;
	;br
;	(brkstep1 '("liselef") (list liselef) "NxtLv2:35" "35")
	;br..
	;;
	(princ) (princ)
	(setvar "luprec" prel)
	(setvar "auprec" preau)
	(setvar "osmode" snapo)
	(setq liselef liselef)
)
;
;;
;;;
;;;;
;:PROYECTO:
;;	<lISP>
;:CLASIFICACION:
;;	<MAIN>
;:FUNCION / TITULO: INV. Ejecutable de aplicación sin cuadros de dialogo
;:SINTAXIS:
;;	<C:INV>
;:DESCRIPCION:
;;	<<
;;		INV. Ejecutable sin cuadros de dialogo para el
;;		dibujo de levantamiento basado en la aplicación
;;		de podio de levantamiento.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	
;;	>>
;:ARGUMENTOS:
;;	<<
;;
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun c:inv
	( /
		lepol leDr leDat leReg leLim leNv leBl lePos lePas
			lepf   leCo1 lesVar leID leDatf leNomf
			leNomBl leLev lep1 lep2
	)
	
;	(setq lepol nil ledr nil leDat nil leReg nil leLim nil
;		leNv nil leBl nil lePos nil lepas nil leCo1 nil lesVar nil
;		leID nil leDatf nil leNomf nil leNomBl nil leLev nil
;		lep1 nil lep2 nil lepf nil leCo1 nil	
;	)
	;;;;;SELECCION DE CALLE
	(setq lepas 1
		lep1
		(getpoint "SELECCIONE EL PUNTO DE INICIO (Enter para polilinea): ")
	)
	(cond
		(;Seleccion de entidad
			(= lep1 nil)
			(setq lepf (mapcar 'cdr (lscod (car(entsel)) (list 10))))
			(setq lepas 0)
		);Seleccion de entidad..
		(;Definicion de puntos
			(not (= lep1 nil))
			(setq lepf (append lepf (list lep1)))
			(while
				(= lepas 1)
				(setq lep2
					(getpoint "SELECCIONE EL SIGUIENTE PUNTO " lep1)
				)
				(cond
					(
						(= lep2 nil)
						(setq lepas 0)
					)
					(
						(not (= lep2 nil))
						(setq lepas 1
							lepf (append lepf (list lep2))
							lep1 lep2
						)
					)
				)
			);While..
		);Definicion de punto..
	);Cond..
	(if
		lepf
		(setq lepas 1)
	);lepf t..
	(cond
		(;cond lepf t
			(= lepas 1)
			;;;;;SELECCION DE CALLE..
			(setq leCo1 (nth 0 lepf)) ;;Coordenada inicial
			;br
;			(brkstep1
;				'("lepF")
;				(list lepF)
;				"pop10:00" "00"
;			)
			;br..
			(setq
				leDr ;RUTAS DE TRABAJO
				(vere01
					(list
						(list "BDATOS" "SELECCIONA LA CARPETA DE DATOS")
						(list "BLOCKS" "SELECCIONA LA CARPETA DE BLOQUES")
						(list "FUNCIONES" "SELECCIONA LA CARPETA DE FUNCIONES")
					)
				);;RUTAS DE TRABAJO..
				leDat ;;DATOS LEVANTAMIENTO
				(vere02
					leDr
					"Levantamiento GSP_CSV" 
					(list
						"TBL_INVENTARIO"
						"SELECCIONA EL ARCHIVO DE LEVANTAMIENTO"
					)
				);;DATOS LEVANTAMIENTO ..
			)
			;br
;			(brkstep1
;				'("leDr" "leDat") (list leDr leDat)
;				"POP10:01" "01"
;			)
			;br..
			;;;;;;;;;;;FILTRA DATOS;;;;;;;;;;(0)
			(setq lesVar
				(cdr (lva leDat 1 1))
			);LISTA DE CALLES
			(setq lesVar (txno1 lesvar "non" 0.001))
			;br
;			(brkstep1
;				'("lesVar") (list lesVar)
;				"INV:02" "02"
;			);LISTA DE CALLES..
			;br..
			(setq leID
				(opc lesVar "SELECCIONE LA CALLE PARA TRAZAR: ")
			);SELECCION DE CALLE DE TRABAJO
			;br
;			(brkstep1
;				'("leDr" "leDat" "lesVar" "leID")
;				(list leDr leDat lesVar leID)
;				"popc10:02" "02"
;			)
			;br..
			(setq LeDatf
				(append
					(list (nth 0 leDat))
					(lnpo4 leID leDat 0 1 0.001)
				)
			);CALLES DE TRABAJO
			(if leDatf 
				(setq leDat leDatf)
			);;CALLE DE TRABAJO = LEDAT
			;;;;;;;;;;;FILTRA DATOS;;;;;;;;;;(1)
			(setq leReg (nth 1 leDat)) ;PRIMER REGISTRO
			;;;;;;;;;;;;DATOS DE INSERCION;;;;;(0)
			(setq
				leLim 8 ;input Limite de predio
				leNv 5 ;input Nivel SocioEconomico
				leBl 1 ;input insercion de bloques
				lePos 1 
			)
			;;;;;;;;;;;;DATOS DE INSERCION;;;;;(1)
			;;;;NOMBRES DE ARCHIVOS;;;
			(setq leNomF "Formulas_CSV"
				leNomBl "Equivalencia_CSV"
			);;NOMBRE DE TABLAS DE EQUIVALENCIAS DE BLOCKS / FORMULAS
			;br
;			(brkstep1
;				'("leDatf" "leDat" "leReg"  "leLim" "leNv" "leBl" "LeNomF" "LeNomBl")
;				(list leDatf leDat leReg  leLim leNv leBl LeNomF LeNomBl)
;				"pop10:03" "03"
;			)
			;br..
			;br
;			(brkstep1
;				'("lepF" "leCo1" "leDat" "leNomF" "LeNomBl" "leDr"
;					"leLim" "leNv" "leBl"
;				) (list lepF leCo1 leDat leNomF LeNomBl leDr leLim leNv leBl)
;				"pop10:04" "04"
;			)
			;br..
			(setq leLev
				(NxtLv2 lepF leCo1 leDat 1 3 0.0
					leNomF LeNomBl leDr leLim leNv leBl
				)
			);;INSERCION DE DATOS
			;br
;			(brkstep1
;				'("leLev") (list leLev)
;				"popc:05" "05"
;			)
			;br..
		);Cond lepf T..
	);cond..
);INV..
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:MAIN
;;OBJETO:CPL2
;;	> Ejecutable de cerramiento de lineas divergentes
;; FUNCION CPL1
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;
(defun c:cpl2 ()
	(cpl1)
)
;;*****COMANDO MULTIPLE DE ESCRITURA DE PUNTOS (id)******
;;PROYECTO: Lisp
;;CLASIFICACION: DEP
;;OBJETO: MPONID
;;	> Escribe las coordenadas de un punto en un texto seleccionado
;;COMMAND:
;;	> MP
;;DEVUELVE:
;;	> Escribe las coordenadas en el texto
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	> CAM1 ()
;;ANOTACIONES
;;	>
(defun c:mp ( / mipoint mipresi txpoint pass entxt)
	(setq prre (getint "Precision? : "))
	(setq mipoint '(0 0 0))
	(while
		(not (= mipoint nil))
		(princ)
		(setq mipoint (getpoint "ID point: "))
		(princ)
		(prin1)
		(cond
			(
				(not (= mipoint nil))
				(if
					(= prre nil)
					(setq mipresi 0)
					(setq mipresi prre)
				)
				(princ)
				(prin1)
				(setq txpoint
					(strcat
						(rtos (nth 0 mipoint) 2 mipresi)
						" , "
						(rtos (nth 1 mipoint) 2 mipresi)
						" , "
						(rtos (nth 2 mipoint) 2 mipresi)
					)		
				)
				(setq entxt (car (entsel)))
				(cond
					(
						(not (= entxt nil))
						(cam1
							(list entxt)
							(cons 1 txpoint)
						)
					)
					(
						(= entxt nil)
						(setq mipoint nil)
					)
				)
			)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: AnDv. Divide el vertice
;;	de un fragmento de polilinea seleccionado
;;	devolviendo las nuevas coordenadas
;;	>
;;DEVUELVE: diLsFn. Lista de tres elementos
;;	1.Nombre de entidad de polilinea
;;	2.Coordenadas nuevas de tramos del
;;		vertice dividido
;;	3. Posicion Numero de coordenada vertice
;;	>(Ename ((XYZ) (XYZ) ...) (No.Vertice))
;;	;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;NOTAS:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:AnDv
	( /
		coEname coPos coNmTram coDsTram diPrEx
		diPrExAn diPrecEnt diNamPol diPrecDec
		diLsCoo diPsCoo diSel diCoSel diAnBase
		diCoBase diArgDiv diArgDim diVrtz diCon
		diAnIni diCoAd diCoFn
		diPtoIni diPass diInSel diPass1 diNwAn diNwDs diNwCo diCoFn1
		diCon2 diCoFn0 diFn diSnap
	)
;(setq diPrEx nil diPrExAn nil diPrecEnt nil diNamPol nil
;	diPrecDec nil diLsCoo nil diPsCoo nil  diSel nil diCoSel nil diAnBase nil
;	diCoBase nil diArgDiv nil diArgDim nil diVrtz nil diCon nil diAnIni nil diCoAd nil diCoFn nil
;	diPtoIni  nil diPass nil diInSel nil diPass1 nil diNwAn nil diNwDs nil diNwCo nil diCoFn1 nil
;	diCon2 nil diCoFn0 nil diFn nil diSnap nil
;)
;
(setq diPrecEnt 3)
(setq diArgDiv (getint "Numero de divisiones del vertice: ")
	diArgDim (getint "Numero de dimensiones de tubos: ")
)
;;;;;;;;;;;variable de precision;;;;(0)
(setq diPrEx (getvar "luprec")
	diPrExAn (getvar "auprec")
)
(setq diSnap (getvar "osmode"))
(setvar "luprec" 7)
(setvar "auprec" 7)
;;;;;;;variable de precision;;;;;;(1)
(setq diPass 1
	diPass1 0
)
(cond
	(
		(= diPrecEnt nil)
		(setq diPrecDec 0.00015)
	)
	(
		(< 0 diPrecEnt)
		(setq diPrecDec
			(expt 10.0 (* -1 diPrecEnt))
		)
	)
	(
		(= diPrecEnt 0)
		(setq diPrecDec 0.15)
	)
)
(while (= diPass 1)
	(setvar "osmode" 512)
	(setq diSel (nentselp (getpoint "Indique algun punto sobre la poligonal: ")))
	(setvar "osmode" diSnap)
	(cond
		(
			(= diSel nil)
			(setq diPass 0)
		)
		(
			(and
				(not (= diSel nil))
				(= (cdr (assoc 0 (entget (nth 0 diSel)))) "LWPOLYLINE")
			)
			(setq diPsCoo (LCoo2 (nth 0 diSel) (nth 1 diSel) diPrecEnt))
			(cond
				(
					(and
						(= diPsCoo nil)
						(= (cdr (assoc 0 (entget (nth 0 diSel)))) "LWPOLYLINE")
					)
					(setq diPass 1)
					(alert "El Punto seleccionado\nno coincide con el poligono")
				)
				(
					(and
						(= diPsCoo nil)
						(not (= (cdr (assoc 0 (entget (nth 0 diSel)))) "LWPOLYLINE"))
					)
					(setq diPass 1)
					(alert
						(strcat
							"El elemento seleccionado\nde tipo "
							(cdr (assoc 0 (entget (nth 0 diSel))))
							" no coincide con el punto seleccionado"
						)
					)
				)
				(
					(and
						(not (= diPsCoo nil))
						(not (= (cdr (assoc 0 (entget (nth 0 diSel)))) "LWPOLYLINE"))
					)
					(setq diPass 1)
					(alert
						(strcat
							"El elemento seleccionado es de tipo\n"
							(cdr (assoc 0 (entget (nth 0 diSel))))
						)
					)
				)
				(
					(and
						(not (= diPsCoo nil))
						(= (cdr (assoc 0 (entget (nth 0 diSel)))) "LWPOLYLINE")
					)
					(setq diPass 0
						diPass1 1
					)
				)
			)
		)
	)
)
(cond
	(
		(= diPass1 1)
		(setq diNamPol (car diSel)
			diCoSel (nth 0 (cdr diSel))
		)
		;(brkstep1 
		;	'("diNamPol" "diSel" "diPrecEnt" "diCoSel" "diArgDiv" "diArgDim")
		;	(list diNamPol diSel diPrecEnt diCoSel diArgDiv diArgDim)
		;	"01" "AnDv"
		;)
		;diArgDiv. Argumento de division de vertice
		;<INT>
		;diArgDim. Argumento de dimension de tubos
		;(brkstep1 '("diPrecDec") (list diPrecDec) "02" "IPHONEFOO")
		;(brkstep1 '("Type" "Polyline?")
		;	(list (type diNamPol)
		;		(cdr (assoc 0 (entget diNamPol)))
		;	)
		;	"02" "AnDv"
		;)
		(setq diLsCoo (lscod diNamPol '(10))
			diLsCoo (mapcar 'cdr diLsCoo)
		)
		;(brkstep1 '("diPsCoo" "diLsCoo" "diNamPol")
		;	(list diPsCoo diLsCoo diNamPol)
		;	"03" "AnDv"
		;)
		;diSel. Lista entget de polilinea
		;<(Ename (xyz))
		;diCoSel. Coordenadas de seleccion de polilinea
		;<(XYZ)
		;diNamPol. Nombre de entidad de polilinea
		;<ENAME>
		;diLsCoo. Lista de coordenadas
		;<((XYZ) (XYZ) ...)>
		;diPsCoo. Posicion de coordenada anterior
		;	a coordenada de selecccion
		;<NTH>
		(cond
			(
				(< diPsCoo (- (length diLsCoo) 2))
				(setq diCoBase 
					(ert diLsCoo
						(list diPsCoo (+ diPsCoo 1) (+ diPsCoo 2))
					)
				)
				;(brkstep1 '("diCoBase") (list diCoBase) "04" "AnDv")
				;diCoBase. Lista de coordenadas (3) que forman
				;		el angulo de division
				;	>((XYZ) (XYZ) (XYZ))
				(cond
					(
						(not (= diCoBase nil))
						(setq diAnBase
							;(- pi
								(angres5 
									(angle (nth 0 diCoBase) (nth 1 diCoBase))
									(nth 1 diCoBase)
									(nth 2 diCoBase)
									0
									diPrecEnt
								)
							;)
						)
						(cond
							(
								(< 0 diArgDiv)
								(setq diNvVrtz (/ diAnBase (+ diArgDiv 1)))
								(setq diCon 0
									diAnIni
									(angle
										(nth 0 diCoBase)
										(nth 1 diCoBase)
									)
									diPtoIni diCoSel
								)
								(while (< diCon diArgDiv)
									;(brkstep1
									;	'("diNvVrtz" "diCon" "diAnIni" "diPtoIni" "diAnBase")
									;	(list diNvVrtz diCon diAnIni diPtoIni diAnBase)
									;	"05" "AnDv"
									;)
									;diAnBase. Angulo formado entre la inclinacion
									;	del primer tramo y el angulo del segundo tramo
									;	(angulo exterior)
									;	> Radianes
									;diNvVrtz. Angulo dividido, porcion de angulo
									;	>Radianes
									;diCon. Contador
									;diAnIni. Angulo Inicial. Cambiante
									;	>Radianes
									;diPtoIni. Punto inicial. Cambiante
									;	>(XYZ)
									(cond
										(
											(<
												(angresta
													(angle
														(nth 1 diCoBase)
														(nth 2 diCoBase)
													)
													(angle
														(nth 0 diCoBase)
														(nth 1 diCoBase)
													)
												)
												pi
											)
											(setq diAnIni (sumang diAnIni diNvVrtz))
											;(brkstep1 '("diAnIni") (list diAnIni) "06" "AnDv")
										)
										(
											(<
												pi
												(angresta
													(angle
														(nth 1 diCoBase)
														(nth 2 diCoBase)
													)
													(angle
														(nth 0 diCoBase)
														(nth 1 diCoBase)
													)
												)
											)
											(setq diAnIni
												(angresta diAnIni diNvVrtz)
											)
											;(brkstep1 '("diAnIni") (list diAnIni) "07" "AnDv")
										)
									)
									(setq diCoAd
										(polar
											diPtoIni
											diAnIni
											diArgDim
										)
										diPtoIni diCoAd
									)
									;(brkstep1
									;	'("diPtoIni" "diCoAd") 
									;	(list diPtoIni diCoAd)
									;	"08" "AnDv"
									;)
									;diCoAd. Nueva coordenada. Se asigna a
									;	diPtoIni
									;	>(XYZ)
									(setq diCoFn
										(append
											diCoFn
											(list 
												diCoAd
											)
										)
										diCon (+ diCon 1)
									)
									;diCoFn. Lista final de coordenadas
									;	>(XYZ)
								)
							)
						)
					)
				)
			)
		)
		(cond
			(
				(not (= diCoFn nil))
				(setq diCoFn (append (list diCoSel) diCoFn))
				;(boli diCoFn)
				;(brkstep1 '("diCoFn") (list diCoFn) "09" "AnDv")
				(setq diNwAn (angle diCoSel (nth 1 diCoBase))
					diNwCo
					(inters
						(nth (- (length diCoFn) 1) diCoFn)
						(polar (nth (- (length diCoFn) 1) diCoFn)  diNwAn 1)
						(nth 1 diCoBase)
						(nth 2 diCoBase)
						nil
					)
				)
				;(brkstep1 '("diNwCo") (list diNwCo) "10" "AnDv")
				(setq diNwDs
					(distance (nth (- (length diCoFn) 1) diCoFn) diNwCo)
					diNwAn (angle (nth (- (length diCoFn) 1) diCoFn) diNwCo)
				)
				;(brkstep1
				;	'("diNwAn" "diNwCo" "diNwDs") (list diNwAn diNwCo diNwDs)
				;	"11" "AnDv"
				;)
				(setq diCon2 0)
				(while
					(< diCon2 (length diCoFn))
					(setq diCoFn0
						(polar (nth diCon2 diCoFn) diNwAn diNwDs)
					)
					(setq diCoFn1 (append diCoFn1 (list diCoFn0)))
					(setq diCon2 (+ diCon2 1))
				)
				;(brkstep1
				;	'("diCoFn1") (list diCoFn1)
				;	"12" "AnDv"
				;)
			)
		)
	)
)
(setq diCoFn1 (list diNamPol diCoFn1 (+ diPsCoo 1)))
(setq diFn (InPto0 2 (nth 0 diCoFn1) (nth 2 diCoFn1) 3 (nth 1 diCoFn1)))
)
;(alert "Listo!")
;diAnBase. Angulo en radianes interno
;<#.#>
;diCoBase. Coordenadas (3) de trabajo
;<((XYZ) (XYZ) (XYZ))>
;diNvVrtz. Nuevo angulo de division del vertice en radianes
;<#.#>
;diAnIni. Angulo inicial / creciente
;decreciente
;<#.# radianes>
;diCoAd. Coordenada de nuevo
;vertice
;<(XYZ)>
;diCoFn. Lista final de cordenadas
;nuevas
;<((XYZ) (...) ...)
;diPtoIni. Coordenada vertice de arranque
;Codigos de polilinea 10, 40, 41, 42, 91
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;TITULO:PPBL. Pasa los valores de atributos similares a block con atributos.
;;NOMBRE: LispMAIN_Ppbl
;;	> Apartir de la selección de un block con atributos, pasa sus valores a 
;; blocks que tengan los mismos atributos.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>	PSB ()
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
(defun c:ppbl 
	( / 
		con1 primero segundos pasw
	)
	;(setq con1 nil primero nil segundos nil pasw nil)
	(setq con1 0
		pasw 1
	)
	(while (= pasw 1)
		(setq primero
			(car (entsel "SELECCIONE EL BLOQUE DE ORIGEN (enter para terminar): "))
		)
		;(brkstep1 '("primero") (list primero) "01" "PPBL")
		(cond
			(
				(= primero nil)
				(setq pasw 0)
			)
			(
				(not (= primero nil))
				(prin1)
				(print "SELECCIONA LOS BLOQUES DE DESTINO")
				(princ)
				(setq segundos (ssget))
				;(brkstep1 '("segundos") (list segundos) "02" "PPBL")
				(cond
					(
						(not (= segundos nil))
						(setq segundos (noment segundos))
						(while
							(< con1 (length segundos))
							;;
							;(brkstep1
							;	'("(nth con1 segundos)")
							;	(list (nth con1 segundos))
							;	"03"  "PPBL"
							;)
							;;
							(psb primero (nth con1 segundos) 1)
							(setq con1 (+ con1 1))
						)
					)
					(
						(= segundos nil)
						(alert "NO EXISTE SELECCION DE DESTINO"
						)
					)
				)
			)
		)
	)
)
;;*****COMANDO DE ESCRITURA DE PUNTOS (id)******
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;TITULO: PONID
;;	> Escribe las coordenadas de un punto en un texto seleccionado
;;DEVUELVE:
;;	> Escribe las coordenadas en el texto
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	> CAM1 ()
;;ANOTACIONES
;;	>
(defun c:ponid ( / mipoint mipresi txpoint)
	(princ)
	(prin1)
	(princ)
	(setq mipoint (getpoint "ID point: "))
	(princ)
	(prin1)
	(setq mipresi (getint "Precision: "))
	(princ)
	(prin1)
	(setq txpoint
		(strcat
			(rtos (nth 0 mipoint) 2 mipresi)
			" , "
			(rtos (nth 1 mipoint) 2 mipresi)
			" , "
			(rtos (nth 2 mipoint) 2 mipresi)
		)
	)
	(cam1
		(list (car (entsel)))
		(cons 1 txpoint)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: CRET
;;	> Interface (inicial) para la creación por medio de hatch de
;;	la retícula para la panelización en el proyecto de NOVIDESA.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>PR...
(defun c:cret (/ ppo xlong ylong miangix miangiy xypto pplis mila mile)
	(setq ppo (ssget)
		pplis '()
	)
	(setq mila
		(opc '("HOLMAK" "IKOS" "MAKROS") "SELECCIONE EL SISTEMA : ")
	)
	(setq xlong (getreal "Indique la distancia en base: "))
	(setq ylong (getreal "Indique la distancia de largo: "))
	(setq xypto (getpoint "Indique el punto inicial"))
	(setq miangix
		(getangle xypto "Introduzca alineacion de Base :")
		miangiy (+ miangix (dtr 90))
	)
	(setq miangiy (dtr2 miangiy)
		miangix (dtr2 miangix)
	)
	(princ)
	(command "_hatch" "u" miangiY xlong "N" ppo "")
	(setq pplis (append pplis (list (entlast))))
	(cam1 (list (nth 0 pplis)) (cons 43 (nth 0 xypto)))
	(command "_hatch" "u" miangiX ylong "N" ppo "")
	(setq pplis (append pplis (list (entlast))))
	(cam1 (list (nth 1 pplis)) (cons 44 (nth 1 xypto)))
	(cam1 pplis (cons 8 mila))
)
;;PROYECTO: Lisp
;;CLASIFICACION:MAIN
;;OBJETO:MURET
;;	> Mueve la reticula al punto indicado
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;
(defun c:muret (/ ppo xypto)
	(setq ppo (ssget))
	(setq xypto (getpoint "Indique el punto de desplazamiento: "))
	(princ)
	(cam1 (noment ppo) (cons 43 (nth 0 xypto)))
	(cam1 (noment ppo) (cons 44 (nth 1 xypto)))
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: IDET
;;	> Interface inicial el trazo de lineas que cruzan
;;	de lado a lado para indicar soportes de fijación en
;;	el proyecto de cuantificación de NOVIDESA.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
(defun c:idet
	(/ midett loc1 angloc1 mpil mispp mipast mispp1 con1 pase1 mimod pasi lisinom conti2 nomi idnomi longi
		midett1
	)
	(print)
	(setq mpil (ssget '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (-4 . "OR>"))))
	(setq mpil (noment mpil))
	(setq pasi 1)
	(while (= pasi 1)
		;(setq midett nil)
		(setq loc1 (getpoint "INDIQUE EL PUNTO DE LOCALIZACION (enter para cancelar): "))
		(princ)
		(cond
			(
				(not (= loc1 nil))
				(setq angloc1 (getangle loc1 "INDIQUE LA ALINEACION : "))
				(setq mispp (ret0a loc1 angloc1 mpil))
				(cond
					(
						(= midett nil)
						(setq midett (c:selmat))
					)
				)
				(if
					(= midett nil)
					(setq midett "0")
				)
				(setq midett1 midett)
				;(brkstep '("mispp" "midett") "01" "IDET")
				(cond
					(
						(and
							(not (= mispp nil))
							(= (length mispp) 2)
						)
						(setq mimod (getvar "osmode"))
						(setvar "osmode" 0)
						(command "line" (nth 0 mispp) (nth 1 mispp) "")
						(setq lisinom (append lisinom (list (entlast))))
						(cam1 (list (entlast)) (cons 8 midett))
						(setvar "osmode" mimod)
						;(brkstep '("mimod" "midett") "01A" "IDET")
					)
					(
						(and
							(not (= mispp nil))
							(< 2 (length mispp))
						)
						(setq mispp1 (seg1v mispp))
						;(brkstep '("mispp1") "02" "IDET")
						(setq pase1 t
							con1 0)
						(while
							(and (not (= mispp1 nil))
								(not (= pase1 nil))
							)
							;(brkstep '("con1" "(length mispp1)") "03" "IDET")
							(grvecs
								(append
									(list 2)
									(nth con1 mispp1)
								)
							)
							;(brkstep '("pase1") "04" "IDET")
							(initget 2 "Si No")
							(setq pase1
								(getkword
									"\nDeseas incluir esta guia Si/No <enter para salir>?: "
								)
							)
							(princ)
							(command "redrawall")
							(cond
								(
									(= pase1 "Si")
									(setq mimod (getvar "osmode"))
									(setvar "osmode" 0)
									(command
										"line"
										(nth 0 (nth con1 mispp1))
										(nth 1 (nth con1 mispp1))
										""
									)
									(setq lisinom (append lisinom (list (entlast))))
									(setvar "osmode" mimod)
									(setq mispp1 (txno mispp1 (nth con1 mispp1)))
									(cam1 (list (entlast)) (cons 8 midett))
								)
							)
							(cond
								(
									(and
										(= pase1 "No")
										(< con1 (- (length mispp1) 1))
									)
									(setq con1 (+ con1 1))
								)
								(
									(<= (- (length mispp1) 1) con1)
									(setq con1 0)
								)
							)
						)
					)
				)
			)
			(
				(= loc1 nil)
				(setq pasi 0)
			)
		)
	)
	(cond
		(
			(not (= lisinom nil))
			(setq conti2 0)
			(while
				(< conti2 (length lisinom))
				(setq nomi (nth conti2 lisinom)
					idnomi (cdr (assoc 5 (entget nomi)))
					longi 
					(rtos
						(distance
							(cdr (assoc 10 (entget nomi)))
							(cdr (assoc 11 (entget nomi)))
						)
					)
				)
				;(brkstep '("midett") "Temp" "idet")
				(xinat0
					(list
						"ELEMENTO" 
						"MATERIAL"
						"CUAN"
						"SISTEMA"
						"COLOR"
						"ID"
						"LARGO"
					)
					(list
						"AL_ACCESORIO"
						midett1
						"SI"
						"ACCESORIO"
						"256"
						idnomi
						longi
					)
					"-"
					"XD_NOVIDESA"
					nomi
				)
				(setq conti2 (+ conti2 1))
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO / TITULO: LYC. Importa Layers de una tabla csv
;;DESCRIPCION: LYC. Apartir de la definicion de una tabla csv Importa
;; los layers con sus caracteristicas en el dibujo
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Si el layer ya existe cambia su caracteristica
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:lyc ()
  (setq mim (lec 1 ())
	miml (lss mim 1)
	mimn (onam miml "layer" 0)
	)
  (cly mimn)
  (terpri)
  (princ "Cambiando propiedades..........................")
  (prin1)
  (setq mimnb (onam miml "layer" 1))
  (vly mim mimnb)
)
;;PROYECTO: NV (NOVIDESA)
;;CLASIFICACION: MAIN (EJECUTABLE)
;;OBJETO:
;;	> PANEL.Metodo>Selecciona los elementos (guias) del tablero
;;	 e inserta las multilineas correspondientes
;;DEVUELVE:
;;	>Lista de coordenadas (4) de cada panesl
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;
(defun c:panel ()
	(setq msil (ssget '((0 . "LINE")))
		msil (noment msil)
	)
	;(brkstep '("msil") "00" "PANEL")
	(setq rrut1 (obten "rutas.csv" "MLINE" "RUTA"))
	(setq bb1 (mat1 msil))
	;(brkstep '("bb1") "01" "PANEL")
	(setq mpp (nth 0 (nth 0 (nth 0 bb1))))
	(setq ffa 1)
	(cond
		(
			(or
				(= mpp "nop")
				(equal mpp 0 0.001)
			)
			(setq ffa 0)
		)
	)
	;(brkstep '("bb1" "mpp" "(length (nth 0 bb1))" "(length (nth 1 bb1))") "EXEFOO: MAT1" "...")
	;(xdat2 (append (nth 0 bb1) (nth 1 bb1)) "," 3)
	(setq paqm (mat4 bb1 0.1 1))
	;(brkstep '("bb1" "paqm" "(length paqm)") "EXEFOO : 1 Lista matriz" "PAQM")
	;(xdat2 paqm "," 3)
	(setq paqr (mat3 bb1 1))
	;(brkstep '("paqr" "(length paqr)") "EXEFOO: 3" "PAQR")
	;(xdat2 paqr "," 3)
	(setq conex (mat6 paqr ffa 0.1));;;;;;;;;;seleccion de tipo de pendiente
	;(brkstep '("conex" "(length conex)") "EXEFOO: 4" "Lista reticula")
	;(xdat2 conex "," 3)
	(setq rectangulo (matconect conex paqm ffa 0.1));;;;seleccion de tipo de pendiente
	;(brkstep '("rectangulo" "(length rectangulo)") "EXEFOO: 5" "MATCONECT")
	;(xdat2 rectangulo "," 3)
	;;;;;;;;;;;;;PREPARACION DE LISTA PARA RECTANGULAR;;;;;;;;;;;;;;;;,
	(setq rectangulo (orden3 rectangulo 0 1))
	;(brkstep '("rectangulo") "EXEFOO: 6" "Matriz ordenada")
	(setq rectangulo (mat5a rectangulo 3 1))
	;(xdat2 rectangulo "," 3)
	(setq recs (panel2 rectangulo 0 1 "Mlines.dwg" rrut1))
	;(brkstep '("recs") "CoordenadasRectangulo" "...")
	;(xdat2 recs "," 3)
	(setq recs recs)
)
;;PROYECTO: NV
;;CLASIFICACION: MAIN
;;OBJETO: PARALE
;;	> Ejecucion de (cpl) cerramiento de lineas paralelas
;;		con filtro para lineas y precicion de 8 decimales.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	> (cpl)
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;PR...
(defun c:parale ()
	(cpl () '((0 . "LINE")) 8)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO / TITULO: ASOC. Pasa datos de un block tipo VALATT a la
;;	base de datos de la entidad.
;;DESCRIPCION: ASOC. Extrae los valores de un block con atributos tipo VALATT#.
;;	donde cada numero corresponde al numero de atributo de la tabla de atributos csv
;;	e los inserta en la base XD de la entidad.
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Ejecucion de la funcion METEDAT1
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;EJECUTABLE DE METEDAT1
(defun c:asoc ( / emenda)
	(setq emenda (noment (ssget)))
	(cond
		(
			(not (= emenda nil))
			(metedat1 emenda)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO / TITULO: SELMAT. Cuadro de dialogo de seleccion de materiales
;;DESCRIPCION: SELMAT. Ejecucion de cuadro de dialogo de seleccion
;;		materiales basado en el archivo "NVDLG_MAT.lsp".
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;EJECUTABLE DE CUADRO DE DIALOGO DE SELECCION DE MATERIALES DEVUELVE EL MATERIAL DEVUELTO
(defun c:selmat ( / salida diload)
	(setq diload (strcat (obten "rutas.csv" "DCL_LISP" "RUTA") "NVDLG_MAT.lsp"))
	(load diload)
	(dmat)
	(setq sal salida)
)
;
;;
;;;
;;;;
;;TRAZO DE GUIA
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: IDET2
;;	> Interface inicial el trazo de lineas que cruzan
;;	de lado a lado para indicar soportes de fijación en
;;	el proyecto de cuantificación de NOVIDESA.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;
(defun c:idet2 (/ midett loc1 angloc1 mpil mispp mipast mispp1 con1 pase1 mimod pasi)
	(print)
	(setq mpil (ssget '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (-4 . "OR>"))))
	(setq mpil (noment mpil))
	(setq pasi 1)
	(while (= pasi 1)
		(setq midett nil)
		(setq loc1 (getpoint "INDIQUE EL PUNTO DE LOCALIZACION (enter para cancelar): "))
		(princ)
		(cond
			(
				(not (= loc1 nil))
				(setq angloc1 (getangle loc1 "INDIQUE LA ALINEACION : "))
				(setq mispp (ret0a loc1 angloc1 mpil))
				;(setq midett (c:selmat))
				(if
					(= midett nil)
					(setq midett "0")
				)
				;(brkstep '("mispp" "midett") "01" "IDET")
				(cond
					(
						(and
							(not (= mispp nil))
							(= (length mispp) 2)
						)
						(setq mimod (getvar "osmode"))
						(setvar "osmode" 0)
						(command "line" (nth 0 mispp) (nth 1 mispp) "")
						(cam1 (list (entlast)) (cons 8 midett))
						(setvar "osmode" mimod)
						;(brkstep '("mimod" "midett") "01A" "IDET")
					)
					(
						(and
							(not (= mispp nil))
							(< 2 (length mispp))
						)
						(setq mispp1 (seg1v mispp))
						;(brkstep '("mispp1") "02" "IDET")
						(setq pase1 t
							con1 0)
						(while
							(and (not (= mispp1 nil))
								(not (= pase1 nil))
							)
							;(brkstep '("con1" "(length mispp1)") "03" "IDET")
							(grvecs
								(append
									(list 2)
									(nth con1 mispp1)
								)
							)
							;(brkstep '("pase1") "04" "IDET")
							(initget 2 "Si No")
							(setq pase1
								(getkword
									"\nDeseas incluir esta guia Si/No <enter para salir>?: "
								)
							)
							(princ)
							(command "redrawall")
							(cond
								(
									(= pase1 "Si")
									(setq mimod (getvar "osmode"))
									(setvar "osmode" 0)
									(command
										"line"
										(nth 0 (nth con1 mispp1))
										(nth 1 (nth con1 mispp1))
										""
									)
									(setvar "osmode" mimod)
									(setq mispp1 (txno mispp1 (nth con1 mispp1)))
									(cam1 (list (entlast)) (cons 8 midett))
								)
							)
							(cond
								(
									(and
										(= pase1 "No")
										(< con1 (- (length mispp1) 1))
									)
									(setq con1 (+ con1 1))
								)
								(
									(<= (- (length mispp1) 1) con1)
									(setq con1 0)
								)
							)
						)
					)
				)
			)
			(
				(= loc1 nil)
				(setq pasi 0)
			)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: CUAN. Metodo general de cuantificacion, extrae la lista de
;;		materiales de cuantificacion, selecciona y prepara la lista de elementos
;;		que cumplan con su formula correspondiente. Ejecuta cada formula de
;;		cuantificacion y exporta el resumen de cuantificacion al archivo CSV
;;		
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>Formato de entrada de datos de cuantificacion (cuanele):
;;	> (
;;			(materialNativo cantidad ("NombreAtributo" "ValorAtributo") (...)
;;			...
;;		)
;; > Variable de salida de lista de cuantificacion: formu1
;;	> Formato de lista de cuantificacion
;; ("MatArea" "Area" "LongdArea" "TransArea"
;;		"PzaArea" "MatProd" "LongProd" "TransProd" "PzaProd"
;	)
;;;(brkstep '("") "001TEMP" "")
;;**********************************************************************
;;PR...
(defun c:cuan
	( /
		con1 final bdatt formu1 lscuan ruload
		tipsel mdatos mdet indidet
		cuanls datcuan selcuan lstfinal
	)
	;(setq con1 nil final nil 
	;	bdatt nil formu1 nil 
	;	tipsel nil lscuan nil
	;	ruload nil mdatos nil mdet nil indidet nil cuanls nil
	;	datcuan nil selcuan nil lstfinal nil
	;)
;;DEFINICION DE FORMULAS DE CUANTIFICACION****(0)
;;*****************************************************************

;;*****************************************************************
;;;;DEFINICION DE FORMULAS DE CUANTIFICACION****(1)
	;;ENTRADA DE ARGUMENTOS**(0)
	(setq tipsel (getint "0 Seleccion / 1 Todo: "))
	;;ENTRADA DE ARGUMENTOS**(1)
	(setq mdatos
		(impdat "rutas.csv" "ID_BDATOS" "RUTA" "SALIDA.csv" 0)
	)
	(setq lscuan (lbase mdatos))
	(setq mdet (impdat "rutas.csv" "ID_BDATOS" "RUTA" "SALIDA_DET.csv" ()))
	;** LSCUAN
	;	(
	;		((MATERIAL FORMULA)
	;			(C.U. #.#)
	;			(D-xx #.#) (...)...
	;			(Block_PL "XX") (PLINE_PL "XX") (MLINE_PL "XX") (ENTIDAD_PL"XX")
	;			(Block_AL "XX") (PLINE_AL "XX") (MLINE_AL "XX") (ENTIDAD_AL"XX")
	;		)
	;		(...) ...
	;	)
	;** MDET. Lista de representacion de detalles.
	;	(
	;		(CLAVE BLOCK_PL PLINE_PL MLINE_PL ENTIDAD_PL
	;			BLOCK_AL PLINE_AL MLINE_AL ENTIDAD_AL
	;		)
	;		("DXXX" "XX" "XX" "XX" "XX" "XX" "XX" "XX" "XX")
	;		(...) ...
	;	)
	;(brkstep '("lscuan" "mdet") "01" "EXEFOO")
	;** LSCUAN. ((material formula) (cantUnitaria xx) (Dxx xx) (...) ...)
	(cond
		(
			(not (= lscuan nil))
			(cond 
				(
					(= tipsel 0)
					(setq selcuan 
						(ssget '((-3 ("XD_NOVIDESA"))))
					)
				)
				;**SELCUAN SELECTION_SET
				(
					(= tipsel 1)
					(setq selcuan
						(ssget "x" '((-3 ("XD_NOVIDESA"))))
					)
				)
				;**SELCUAN SELECTION_SET
				;-Seleccion de entidades de cuantificacion (solo "XD_NOVIDESA")-
			)
			;(brkstep '("selcuan" "(sslength selcuan)") "02" "EXEFOO")
			(cond
				(
					(not (= selcuan nil))
					(setq con1 0)
					(while (< con1 (length lscuan))
						(setq formu1 nil)
						(setq bdatt (nth con1 lscuan))
						(setq cuanls (lstelem bdatt mdet))
						(setq ruload
							(strcat
								(obten
									"rutas.csv"
									"FORMULAS"
									"RUTA"
								)
								(nthx '(0 1) bdatt)
								".lsp"
							)
						)
						;(brkstep '("bdatt" "mdet" "ruload" "cuanls") "03" "EXEFOO")
						(cond
							(
								(and (not (= ruload nil))
									(not (= cuanls nil))
								)
								(setq datcuan (cuanele selcuan cuanls))
								;(brkstep '("datcuan" "ruload") "04" "EXEFOO")
								(cond
									(
										(not (= datcuan nil))
										(load ruload)
									)
								)
							)
						)
						(cond
							(
								(not (= formu1 nil))
								(setq lstfinal
									(append lstfinal formu1)
								)
								;(brkstep '("lstfinal" "formu1") "05" "EXEFOO")
								(setq formu1 nil)
							)
						)
						(setq con1 (+ con1 1))
					)
				)
			)
		)
	)
	(cond
		(
			(not (= lstfinal nil))
			(xdat2 lstfinal "," 2)
		)
	)
	(setq lstfinal lstfinal)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO / TITULO: Cadena
;;DESCRIPCION: Comando de ejecución par colocar cadenamientos en una polilinea.
;; >
;;DEVUELVE:
;; >
;;ARGUMENTOS
;; 1.
;; >
;;DEPENDIENTES
;; >
;;ANOTACIONES
;; >El orden de la numeracion de los tubos puede ser
;;	ascendente o descendente y con +- 1
;;	>El bloque de cadenamiento (marcador) es "Punta1.dwg"
;;	>El bloque del numero de tubo es "NumeroTubo.dwg"
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:cadena
	(/
		a1 a2 a3 a4 coni coni1 lili0
		lili1 tutb lilis lilis1
		lilidis lilian lilie imp qq caPass caMod
		caMod1
	)
;	(setq a1 nil a2 nil a3 nil a4 nil coni nil coni1 nil lili0 nil
;		lili1 nil tutb nil lilis nil lilis1 nil
;		lilidis nil lilian nil lilie nil imp nil qq nil caPass nil caMod nil caMod1
;	)
	(setq imp 0)
	(princ) 
	(princ)
	(setq a2 (car (entsel "Seleccione el perfil: ")))
	(princ "\n")
	(princ)
	(cond
		(
			(not (= a2 nil))
			(cond
				(
					(= (cdr (assoc 0 (entget a2))) "LWPOLYLINE")
					(setq a1 (getpoint "Seleccione el punto de inicio: "))
					;;
					;(brkstep1 '("a1") (list a1) "00" "CADENA")
					;;
					(princ "\n")
					(princ)
					(cond
						(
							(= (type a1) 'LIST)
							;;
;							(brkstep1 '("a1" "a2") (list a1 a2) "01" "CADENA")
							;;
							;;a1.Coordenada inicial
							;..a2.Polilinea <ENAME>
							(setq caPass (LCoo2 a2 a1 7));;;;;;;;;;;;;;;;;;
							;;
;							(brkstep1 '("caPass") (list caPass) "02" "CADENA")
							;;
							(cond
								(
									(not (= caPass nil))
									(setq a3 (getint "Indique el numero inicial de tubo: "))
									(princ "\n")
									(princ)
								)
							)
							(initget 128 "Ascendente Descendente")
							(setq caMod
								(getkword
									"Seleccione el tipo de numeracion [Ascendente / Descendente]: "
								)
							)
							(cond
								(
									(= caMod "Ascendente")
									(setq caMod1 0)
								)
								(
									(= caMod "Descendente")
									(setq  caMod1 1)
								)
							)
						)
					)
				)
			)
		)
	)
	;;
;	(brkstep1 '("caMod" "caMod1") (list caMod caMod1) "03" "CADENA")
	;;
	;(setq a4 (getreal "Indique la distancia de tubos: "))
	(setq a4 0)
	(princ "\n")
	(princ)
	(cond
		(
			(and
				(not (= a1 nil))
				(not (= a2 nil))
				(not (= a3 nil))
				(not (= a4 nil))
			)
			(setq qq (NextP2 a2 a1 a4 a3 7 0 caMod1))
			(cond
				(
					(not (= qq nil))
					(setq qq (jtubo qq 4))
				)
			)
			;;
			;(brkstep1
			;	'("QQ")
			;	(list qq)
			;	"01" "CADENA"
			;)
			;(insercad qq () ())
			;(dimet qq)
			;;
		)
	)
	(cond
		(
			(and
				(not (= qq nil))
				(= imp 1)
			)
			(setq coni 0
				lili1 (list (list "TUBO" "DISTANCIA" "ANGULO" "INCLINACION" ))
			)
			(while
				(< coni (length qq))
				(setq lili0 (nth coni qq))
				(setq coni1 0
					tutb (nth 0 lili0)
					lilis (nth 3 lili0)
				)
				;(brkstep1 '("lilis") (list lilis) "01" "CADENA")
				(while (< coni1 (length lilis))
					(setq lilis1 (nth coni1 lilis))
					(setq lilian (round (nth 0 lilis1) 2))
					(setq lilian1 (round (nth 2 lilis1) 2))
					(setq lilidis (round (nth 1 lilis1) 3))
					(setq lilie (list tutb lilidis lilian1 lilian))
					(setq lili1
						(append lili1
							(list lilie)
						)
					)
					(setq coni1 (+ coni1 1))
				)
				(setq coni (+ coni 1))
			)
;			(brkstep1 '("lili1") (list lili1) "02" "CADENA")
			(xdat2 lili1 "," 3)
		)
	)
)
;
;;
;;;
;;;;
;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:MAIN
;;OBJETO: COPYCAT
;;	> Copia elementos XD de un elemento a varios
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")

(defun c:copycat
		 (/	      miEntOrig	  miDatEnt    miCon1
		  miLsFn      miAtColor	  miLsEntDes  miCon2
		 )
  (setq miEntOrig (car (entsel "SELECCIONA EL ELEMENTO DE ORIGEN: ")))
  (cond
    (
     (not (= miEntOrig nil))
     (setq miDatEnt (extraxr miEntOrig "XD_NOVIDESA"))
     (cond
       (
	(not (= miDatEnt nil))
	(setq miAtColor (lnpo "COLOR" miDatEnt 0 1))
	(cond
	  (
	   (not (= miAtColor nil))
					;(brkstep1 (list "miAtColor") (list miAtColor) "00" "MiCoAtt")
	   (setq miAtColor (atoi (nthx '(0 1) miAtColor)))
	  )
	)
	(setq miCon1 0)
	(while (< miCon1 (length miDatEnt))
	  (setq	miLsFn
		 (append miLsFn
			 (list
			   (list
			     (strcat
			       (nthx (list miCon1 0) miDatEnt)
			       ","
			       (nthx (list miCon1 1) miDatEnt)
			     )
			   )
			 )
		 )
	  )
					;(brkstep1 (list "miLsFn") (list miLsFn) "01" "MiCoAtt")
	  (setq miCon1 (+ miCon1 1))
	)
					;(brkstep1 (list "miLsFn") (list miLsFn) "02" "MiCoAtt")
	(print "SELECCIONE LAS ENTIDADES DE DESTINO....")
	(princ)
	(princ)
	(setq miLsEntDes (ssget))
	(cond
	  (
	   (and
	     (not (= miLsEntDes nil))
	     (not (= miLsFn nil))
	   )
	   (setq miLsEntDes (noment miLsEntDes))
	   (cond
	     (
	      (not (= miAtColor nil))
					;(brkstep1 '("miAtColor") (list miAtColor) "03" "miCoAtt")
	      (cam1 miLsEntDes (cons 62 miAtColor))
	     )
	   )
					;(brkstep1 '("miLsEntDes") (list miLsEntDes) "04" "miCoAtt")
	   (setq miCon2 0)
	   (while (< miCon2 (length miLsEntDes))
	     (xin3 "XD_NOVIDESA" (nth miCon2 miLsEntDes) miLsFn)
	     (cam1 (list (nth miCon2 miLsEntDes))
		   (assoc 8 (entget miEntOrig))
	     )
					;(brkstep1 '("ID") (list (nth miCon2 miLsEntDes)) "03" "miCoAtt")
	     (setq miCon2 (+ miCon2 1))
	   )
	  )
	)
       )
     )
    )
  )
)
;
;;
;;;
;;;;
;;PROYECTO: NV
;;CLASIFICACION: DLG (Ejecutable de cuadro de dialogo)
;;	>NVDLG_DETPL
;;OBJETO: DETALLES EN PLANTA
;;	>  
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;******************************************
;;PR...
(defun C:xdt (/ mirun)
	(setq mirun (strcat (obten "rutas.csv" "DCL_LISP" "RUTA") "NVDLG_DETPL.lsp"))
	(cond
		(
			(not (= mirun nil))
			(load mirun)
			(detpl)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: LISP
;;CLASIFICACION:MAIN
;;OBJETO: QATT
;;	> Metodo de consulta de atributos de cuantificacion de
;;	 la aplicacion de NOVIDESA (XD_NOVIDESA).
;;PROCEDIMIENTO:
;;	>Seleccion de una entidad > Muestra mensaje con lod valores de los atributos.
;;ARGUMENTOS
;;	1. NOMIAP: Nombre de aplicacion.
;;	> "XXXXX"
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;
(defun c:qatt ( / nomiap miele conta speach pas1 miele1)
	(setq nomiap "XD_NOVIDESA")
	(setq miele (noment (ssget)))
	(setq miele (nth 0 miele))
	;(brkstep '("miele") "01" "MSJ")
	(setq miele (extraxr miele nomiap))
	;(brkstep '("miele") "02" "MSJ")
	(setq conta 0
		pas1 0
	)
	;(brkstep '("miele" ) "01" "QATT")
	(cond
		(
			(not (= miele nil))
			(while 
				(< conta (length miele))
				(setq miele1 (nth conta miele))
				(cond
					(
						(= (length miele1) 1)
						(setq miele1 (append miele1 (list "-")))
					)
				)
				(cond
					(
						(= pas1 0)
						(setq pas1 1
							speach
							(strcat
								(nth 0 miele1) ": "
								(nth 1 miele1) "\n"
							)
						)
						;(brkstep '("speach") "02a" "QATT")
					)
					(
						(= pas1 1)
						(setq speach
							(strcat
								speach
								(nth 0 miele1) ": "
								(nth 1 miele1) "\n"
							)
						)
					)
				)
				;(brkstep '("speach" "pas1" "conta") "03" "QATT")
				(setq conta (+ conta 1))
			)
			;(brkstep '("speach") "03" "QATT")
		)
		(
			(= miele nil)
			(setq speach "LA ENTIDAD NO CONTIENE\nINFORMACION DE CUANTIFICACION")
			;(brkstep '("speach") "04B" "QATT")
		)
	)
	(alert speach)
)
;;PROYECTO: Lisp
;;CLASIFICACION:MAIN
;;OBJETO: C:GUIA. Comando ejecucion del metodo (DISTPER) para el trazo
;;		de guias distribuidas dentro de una poligonal. 
;;	> Utiliza introduccion de datos por medio de ordenes
;;DEVUELVE:
;;ARGUMENTOS
;;
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;
(defun c:guia
	( /
		xsPoint1 xsPoint2 xsAng xsLsLim xsPrec xsDisDis xsDisMin xsLsLine
	)
	;(setq xsPoint1 nil xsPoint2 nil xsAng nil xsLsLim nil xsPrec
	;	nil xsDisDis nil xsDisMin nil xsLsLine nil
	;)
	(princ) (princ)
	(setq xsPoint1 (getpoint "Indique el punto inicial : "))
	(princ) (princ)
	(setq xsPoint2 (getpoint xsPoint1 "Indique el segundo Punto : "))
	(princ) (princ)
	;;DEFINICION DE PARAMETROS (0)
	(setq xsAng (sumang (angle xsPoint1 xsPoint2) (/ pi 2)))
	(setq xsMod (getint "Indique el modo de distribucion : "))
	(princ) (princ)
	(setq xsLsLim
		(noment
			(ssget '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (-4 . "OR>")))
		)
	)
	(princ) (princ)
	(setq xsPrec (getint "Indique la precision : "))
	(princ) (princ)
	(setq xsDisDis (getreal "Indique la distancia de distribucion : "))
	(princ) (princ)
	(setq xsDisMin (getreal "Indique la distancia minima de distribucion : "))
	(princ) (princ)
	(setq xsLsLine
		(distper
			xsPoint1
			xsPoint2
			xsAng
			xsLsLim
			xsDisDis
			xsMod
			xsPrec
			xsDisMin
		)
	)
)
;
;;
;;;
;;;;
;;TRAZO DE GUIA
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: GUIA1
;;	> Interface inicial el trazo de lineas que cruzan
;;	de lado a lado para indicar soportes de fijación en
;;	el proyecto de cuantificación de NOVIDESA.
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
(defun c:guia1 (/ midett loc1 angloc1 mpil mispp mipast	mispp1 con1
		pase1 mimod pasi loc0)
  (print)
  (setq	mpil
	 (ssget
	   '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (-4 . "OR>"))
	 )
  )
  (setq mpil (noment mpil))
  (setq pasi 1)
  (while (= pasi 1)
    (setq midett nil
	  angloc1 nil
    )
    (setq loc1
	   (getpoint
	     "INDIQUE EL PUNTO DE LOCALIZACION (enter para cancelar): "
	   )
    )
    (princ)
    (cond
      (
       (not (= loc1 nil))
       (setq angloc1
	      (getangle	loc1
			"INDIQUE LA ALINEACION (enter para otro punto): "
	      )
       )
       (cond
	 (
	  (= angloc1 nil)
	  (setq loc0 (getpoint "INDIQUE EL PRIMER PUNTO DEL ANGULO: "))
	  (cond
	    (
	     (not (= loc0 nil))
	     (setq angloc1
		    (getangle
		      loc0
		      "INDIQUE EL SEGUNDO PUNTO DEL ANGULO: "
		    )
	     )
	    )
	  )
	 )
       )
       (setq mispp (ret0a loc1 angloc1 mpil))
					;(setq midett (c:selmat))
       (if
	 (= midett nil)
	  (setq midett "0")
       )
					;(brkstep '("mispp" "midett") "01" "IDET")
       (cond
	 (
	  (and
	    (not (= mispp nil))
	    (= (length mispp) 2)
	  )
	  (setq mimod (getvar "osmode"))
	  (setvar "osmode" 0)
	  (command "_line" (nth 0 mispp) (nth 1 mispp) "")
	  (cam1 (list (entlast)) (cons 8 midett))
	  (setvar "osmode" mimod)
					;(brkstep '("mimod" "midett") "01A" "IDET")
	 )
	 (
	  (and
	    (not (= mispp nil))
	    (< 2 (length mispp))
	  )
	  (setq mispp1 (seg1v mispp))
					;(brkstep '("mispp1") "02" "IDET")
	  (setq	pase1 t
		con1 0
	  )
	  (while
	    (and (not (= mispp1 nil))
		 (not (= pase1 nil))
	    )
					;(brkstep '("con1" "(length mispp1)") "03" "IDET")
	     (grvecs
	       (append
		 (list 2)
		 (nth con1 mispp1)
	       )
	     )
					;(brkstep '("pase1") "04" "IDET")
	     (initget 2 "Si No")
	     (setq pase1
		    (getkword
		      "\nDeseas incluir esta guia Si/No <enter para salir>?: "
		    )
	     )
	     (princ)
	     (command "_redrawall")
	     (cond
	       (
		(= pase1 "Si")
		(setq mimod (getvar "osmode"))
		(setvar "osmode" 0)
		(command
		  "_line"
		  (nth 0 (nth con1 mispp1))
		  (nth 1 (nth con1 mispp1))
		  ""
		)
		(setvar "osmode" mimod)
		(setq mispp1 (txno mispp1 (nth con1 mispp1)))
		(cam1 (list (entlast)) (cons 8 midett))
	       )
	     )
	     (cond
	       (
		(and
		  (= pase1 "No")
		  (< con1 (- (length mispp1) 1))
		)
		(setq con1 (+ con1 1))
	       )
	       (
		(<= (- (length mispp1) 1) con1)
		(setq con1 0)
	       )
	     )
	  )
	 )
       )
      )
      (
       (= loc1 nil)
       (setq pasi 0)
      )
    )
  )
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: GuiTz. Metodo de definicion de lineas guias
;;	>
;;DEVUELVE: guFn. Lista de los elementos (guias) trazadas
;;	en el  dibujo o nil.
;;	> (ename ....)
;;	> nil
;;ARGUMENTOS
;; 1.guAnDes0. Angulo de desplazamiento (grados)
;;	> ##.##
;;	2.guAnTz0. Angulo de trazo de guias (radianes)
;;	> ##.##
;;	3.guDis0. Distancia de distribucion
;;	> ##.##
;;DEPENDIENTES
;;	> noment; PoliCoo; distper; 
;;ANOTACIONES
;;	>
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;
(defun GuiTz
	     (guAnDes0 guAnTz0	guDis0	 /	  guSele   guP1
	      guP2     guPas	guFn	 guCoo	  guMsj	   guOrto
	      guAnDes  guAnTz	guLsLn	 guDis
	     )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;(setq guSele nil guP1 nil guP2 nil
					;	guPas nil guFn nil guCoo nil guMsj nil guOrto nil
					;	guAnDes nil guAnTz nil guLsLn nil guDis nil
					;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;(brkstep '("guAnDes0" "guAnTz0" "guDis0") "00" "GuiTz")
  (cond
    (
     (and
       (numberp guAnDes0)
       (numberp guAnTz0)
       (numberp guDis0)
     )
     (setq guAnDes guAnDes0
	   guAnTz  guAnTz0
	   guDis   guDis0
     )
     (setq guPas 1)
     (while (= guPas 1)
					;(brkstep '("guPas" "guSele") "01" "GuiTz")
       (setq guSele
	      (car (entsel "SELECCIONE EL ELEMENTO DE TRAYECTORIA: "))
       )
					;(brkstep '("guSele" "(type guSele)") "02" "GuiTz")
       (cond
	 (
	  (= (type guSele) nil)
	  (setq guPas 0)
	  (setq	guP1
		 (getpoint
		   "SELECCIONE EL PRIMER PUNTO DE TRAYECTORIA: <Enter para cancelar>: "
		 )
	  )
					;(brkstep '("GuP1") "02A" "GuiTz")
	  (cond
	    (
	     (not (= guP1 nil))
	     (command "_ucs" "z" guAnDes)
	     (princ)
	     (setq guOrto (getvar "orthomode"))
	     (setvar "orthomode" 1)
	     (princ)
	     (setq guP2
		    (getpoint (trans guP1 0 1)
			      "SELECCIONE EL SEGUNDO PUNTO DE TRAYECTORIA: "
		    )
	     )
	     (cond
	       (
		(not (= guP2 nil))
		(setq guP2 (trans guP2 1 0))
	       )
	     )
	     (command "_ucs" "")
	     (command ^^c)
	     (setvar "orthomode" guOrto)
					;(brkstep '("guP2") "02B" "GuTz")
	     (cond
	       (
		(and (not (= guP1 nil)) (not (= guP2 nil)))
		(setq guLim
		       (ssget
			 '((-4 . "<OR")
			   (0 . "LWPOLYLINE")
			   (0 . "LINE")
			   (-4 . "OR>")
			  )
		       )
		)
					;(brkstep '("guLim") "03" "GuiTz")
		(cond
		  (
		   (not (= guLim nil))
					;(brkstep
					;	'("guPas" "guP1" "guP2" "guAnTz"
					;		"(noment guLim)" "guDis"
					;	) "04" "GuiTz"
					;)
		   (setq guPas 0)
		   (setq guLsLn
			  (distper
			    guP1
			    guP2
			    guAnTz
			    (noment guLim)
			    guDis
			    3 ;;;;;;;;;;;;;;;;;;;SIN AJUSTE;;;;;;;;;;;;;;
			    8
			    guDis
			  )
		   )
		  )
		)
	       )
	     )
					;(brkstep '("guLsLn") "05" "GuiTz")
	    )
	  )
					;(brkstep '("guLsLn") "06" "GuiTz")
	 )
	 (
	  (= (type guSele) 'ENAME)
					;(brkstep
					;	'("(cdr (assoc 0 (entget guSele)))" "guPas") "07" "GuiTz"
					;)
	  (cond
	    (
	     (= (cdr (assoc 0 (entget guSele))) "LWPOLYLINE")
	     (setq guPas 0)
	     (setq guCoo (PoliCoo guSele))
					;(brkstep '("guCoo") "08" "GuiTz")
	     (cond
	       (
		(not (= guCoo nil))
		(setq guP1 (nth 0 guCoo)
		      guP2 (nth 1 guCoo)
		)
					;(brkstep
					;	'("guPas" "guP1" "guP2" "guAnTz"
					;		"(list guSele)" "guDis"
					;	)
					;	"09" "GuiTz"
					;)
		(setq guPas 0)
		(setq guLsLn
		       (distper
			 guP1
			 guP2
			 guAnTz
			 (list guSele)
			 guDis
			 3 ;;;;;;;;;;;;;;;;;;;SIN AJUSTE;;;;;;;;;;;;;;
			 8
			 guDis
		       )
		)
	       )
	     )
	    )
	    (
	     (= (cdr (assoc 0 (entget guSele))) "LINE")
	     (setq guPas 0)
	     (setq guP1	(cdr (assoc 10 (entget guSele)))
		   guP2	(cdr (assoc 11 (entget guSele)))
	     )
	     (setq guLim
		    (ssget
		      '((-4 . "<OR")
			(0 . "LWPOLYLINE")
			(0 . "LINE")
			(-4 . "OR>")
		       )
		    )
	     )
	     (cond
	       (
		(not (= guLim nil))
					;(brkstep
					;	'("guP1" "guP2" "guAnTz"
					;		"(noment guLim)" "guDis" 
					;	)
					;	"10" "GuiTz"
					;)
		(setq guLsLn
		       (distper
			 guP1
			 guP2
			 guAnTz
			 (noment guLim)
			 guDis
			 3 ;;;;;;;;;;;;;;;;;;;SIN AJUSTE;;;;;;;;;;;;;;
			 8
			 guDis
		       )
		)
	       )
	     )
	    )
	  )
	 )
       )
       (cond
	 (
	  (= guPas 1)
	  (setq	guMsj
		 (strcat "HA SELECCIONADO UN ELEMENTO DE TIPO\n"
			 (cdr (assoc 0 (entget guSele)))
		 )
	  )
	  (alert guMsj)
	 )
       )
     )
    )
  )
					;(brkstep '("guLsln") "FIN" "TaDf")
  (setq guFn guLsLn)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO / TITULO: EjePar. Metodo de trazo de lineas paralelas
;;DESCRIPCION: EjePar. Metodo de trazo de lineas paralelas en ambos
;;	lados o uno solo a partir de la seleccion de una linea, poligono,
;;	o seleccion de dos puntos.
;;DEVUELVE:
;;	> ejFnLs. Lista de entidades trazadas
;;ARGUMENTOS
;1. ejDist0 . Distancia de trazo paralelo
;2. ejMod0 . Modo de Trazo paralelo
;		0 = Trazo a un solo lado
;		1 = Trazo en ambos lados
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DEVUELVE
;Lista de nombre de entidades de lineas trazadas
;> (ename ...)
(defun EjePar
	      (ejDist0	 ejMod0	   /	     ejDist    ejElem
	       ejPas	 ejP1	   ejP2	     ejMsj     ejCooPar
	       ejCooTz	 ejFnLs	   ejModVar  ejMod
	      )
					;	(setq ejDist nil ejElem nil ejP1 nil ejP2 nil ejMsj nil ejP3 nil
					;	ejCooPar nil ejCooTz nil ejFnLs nil ejMod nil ejModVar nil
					;)
					;	(brkstep '("ejDist0" "ejMod0") "00" "EjePar")
  (setq	ejDist ejDist0
	ejMod  ejMod0
	ejPas  1
  )
  (setq ejModVar (getvar "osmode"))
  (while
    (= ejPas 1)
     (setq ejPas 0)
     (setq ejElem (car (entsel "SELECCIONE EL ELEMENTO DE EJE: ")))
					;		(brkstep '("ejElem") "01" "EjePar")
     (cond
       (
	(= (type ejElem) nil)
	(setq
	  ejP1 (getpoint
		 "SELECCIONE EL PRIMER PUNTO <ENTER PARA CANCELAR>: "
	       )
	)
	(princ)
	(prin1)
	(princ)
	(cond
	  (
	   (not (= ejP1 nil))
	   (setq ejP2
		  (getpoint
		    ejP1
		    "SELECCIONES EL SEGUNDO PUNTO <ENTER PARA CANCELAR>: "
		  )
	   )
	  )
	)
       )
       (
	(not (= ejElem nil))
	(cond
	  (
	   (= (cdr (assoc 0 (entget ejElem))) "LWPOLYLINE")
	   (setq ejPas 0)
	   (setq ejCooPar (PoliCoo ejElem))
	   (cond
	     (
	      (not (= ejCooPar nil))
	      (setq ejP1 (nth 0 ejCooPar)
		    ejP2 (nth 1 ejCooPar)
	      )
	     )
	   )
	  )
	  (
	   (= (cdr (assoc 0 (entget ejElem))) "LINE")
	   (setq ejPas 0)
	   (setq ejP1 (cdr (assoc 10 (entget ejElem)))
		 ejP2 (cdr (assoc 11 (entget ejElem)))
	   )
	  )
	  (
	   (= ejPas 1)
	   (setq ejMsj
		  (strcat "HA SELECCIONADO UN ELEMENTO DE TIPO\n"
			  (cdr (assoc 0 (entget ejElem)))
		  )
	   )
	  )
	)
       )
     )
  )
  (cond
    (
     (and
       (= (type ejP1) 'LIST)
       (= (type ejP2) 'LIST)
     )
     (cond
       (
	(= ejMod 0)
	(setq ejP3 (getpoint "INDIQUE EL LADO DEL EJE: "))
	(cond
	  (
	   (= (type ejP3) 'LIST)
	   (setq ejCooTz (ParCoo ejP1 ejP2 ejP3 ejDist))
					;							(brkstep '("ejCooTz") "02" "EjePar")
	   (cond
	     (
	      (not (= (type ejCooTz) nil))
	      (setvar "osmode" 0)
	      (command "_line" (nth 0 ejCooTz) (nth 1 ejCooTz) "")
	      (setq ejFnLs (list (entlast)))
	      (setvar "osmode" ejModVar)
	     )
	   )
	  )
	)
       )
       (
	(= ejMod 1)
					;(brkstep '("ejP1" "ejP2" "ejDist") "03A1" "EjePar")
	(setvar "osmode" 0)
	(setq ejFnLs (Para2 (list ejP1 ejP2) ejDist 0 '((8 . "0"))))
					;(brkstep '("ejFnLs") "03A" "EjePar")
	(setvar "osmode" ejModVar)
       )
     )
    )
  )
					;	(brkstep '("ejFnLs") "03" "EjePar")
  (setq ejFnLs ejFnLs)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO: TabTar0. Metodo de definición de tablero con angulos de alineacion
;;	>
;;DEVUELVE:
;;taFn. Lista de nombre de entidad + lista de par de angulos ortogonales
;;	que la componen (angulos en radianes)
;;	>(ENAME (anRad1 anRad2))
;;ARGUMENTOS
;;	1.Ninguno
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun TabTar0
	       (/ taSel	taRec1 taRec2 taPas taMsj taAnPer taAnDes
		taCooPer taFn)
					;(setq taSel nil taRec1 nil taRec2 nil taPas nil taMsj nil taAnPer nil taAnDes nil
					;	taCooPer nil taFn nil
					;)	
;;;;;;;;;;;;;;;;;;;;;;;;;;
  (princ)
  (print "SELECCIONE LA ENTIDAD DE TRABAJO: ")
  (setq taSel (car (entsel "SELECCIONE LA ENTIDAD DE TRABAJO: ")))
  (setq taPas 1)
  (while (= taPas 1)
    (cond
      (
       (= (type taSel) 'ENAME)
					;(brkstep
					;	'("taSel" "(cdr (assoc 0 (entget taSel)))"
					;	)
					;	"01" "TabTar0"
					;)
       (cond
	 (
	  (= (cdr (assoc 0 (entget taSel))) "LINE")
	  (setq	taAnDes
		 (angle
		   (cdr (assoc 10 (entget taSel)))
		   (cdr (assoc 11 (entget taSel)))
		 )
	  )
	  (setq taSel nil)
					;(brkstep '("taAnDes" "taSel") "02" "TabTar0")
	 )
       )
      )
    )
    (cond
      (
       (= taSel nil)
       (setq taPas 0)
       (cond
	 (
	  (= taAnDes nil)
	  (setq taAnDes (getangle "DEFINA LA ALINEACION DEL TABLERO: "))
	 )
       )
       (cond
	 (
	  (not (= taAnDes nil))
	  (setq taAnDes (round (dtr2 taAnDes) 2))
	 )
       )
       (cond
	 (
	  (not (= taAnDes nil))
	  (command "_ucs" "z" taAnDes)
	  (setq	taRec1
		 (getpoint "SELECCIONE LA PRIMERA ESQUINA DEL TABLERO: ")
	  )
	  (cond
	    (
	     (not (= taRec1 nil))
	     (command "_rectangle" taRec1 pause)
	     (setq taSel (entlast))
					;(brkstep '("taSel") "03" "TabTar0")
	     (command "_ucs" "")
	     (command ^^c)
	    )
	  )
	 )
       )
      )
      (
       (not (= taSel nil))
					;(brkstep '("taSel" "(cdr (assoc 0 (entget taSel)))") "04" "TabTar0")
       (cond
	 (
	  (= (cdr (assoc 0 (entget taSel))) "LWPOLYLINE")
	  (setq taPas 0)
	 )
	 (
	  (not (= (cdr (assoc 0 (entget taSel))) "LWPOLYLINE"))
	  (setq	taMsj
		 (strcat
		   "EL ELEMENTO SELECCIONADO ES DE TIPO\n"
		   (cdr (assoc 0 (entget taSel)))
		 )
	  )
	  (alert taMsj)
	  (setq taSel nil)
	 )
       )
      )
    )
  )
					;(brkstep '("taSel") "05" "TabTar0") 
  (cond
    (
     (not (= taSel nil))
     (setq taCooPer (PoliCoo taSel))
     (cond
       (
	(not (= taCooPer nil))
	(setq taAnPer (Orto (nth 0 taCooPer) (nth 1 taCooPer) 8))
	(setq taFn (list taSel taAnPer))
					;(brkstep '("taFn") "06" "TabTar0")
       )
     )
    )
  )
  (command "_ucs" "")
  (command ^^c)
  (princ)
  (princ)
  (setq taFn taFn)
)
;;PROYECTO: IBS
;;CLASIFICACION: MAIN
;;OBJETO: InCoPc
;;	>Inserta guias, correas y portacorreas.
;;		
;;DEVUELVE:
;;	> inTotEnti. Lista total de nombre de entidades insertadas.
;;ARGUMENTOS
;;	1. inLsAn0. Lista de Angulo y par de coordenadas para trazar guias de correas
;;		y portacorreas (hecha con la funcion TabTar1)
;;	>	( ENAME (AnguloCorreaRad ((XY) (XY))) (AnguloPortaRad ((XY) (XY))))
;;	2. inLsBlCo0. Lista de bloques y distancias de correas
;;	> ((BlockName Distancia) (...) ...)
;;	3. inLsBlPc0. Lista de bloques y distancias de portacorreas
;;	> ((BlockName Distancia) (...) ...)
;;	4. inAtGuCo0. Lista de atributos para Guias de Correas
;;	> (("NomAtt" "ValAtt") (...) ...)
;; 5. inAtGuPc0. Lista de atributos para Guias de PortaCorreas
;;	> (("NomAtt" "ValAtt") (...) ...)
;; 6. inAtBlCo0. Lista de atributos para Bloques de Correas
;;	> (("NomAtt" "ValAtt") (...) ...)
;; 7. inAtBlPc0. Lista de atributos para Bloques de PortaCorreas
;;	> (("NomAtt" "ValAtt") (...) ...)
;; 8. inNomTip0. Nombre del atributo que determina el tipo de Guia
;; > "xxx"
;;	9. inValGu0. Nombre del elemento de la Guia
;;	> "xxx"
;;	10. inNomApp0. Nombre de la aplicacion XDATA.
;;	> "xxx"
;;	11. inDsCo0. Distancia de distribucion de Correas
;;	> ##.##
;;	12. inDsPc0. Distancia de distribucion de PortaCorreas
;;	> ##.##
;; 13. inSeCo0. Distancia de separacion o punto de arranque
;;		en la distribucion de las Correas
;;	> ##.##
;;	14. inSePc0. Distancia de separacion o punto de arranque
;;		en la distribucion de las PortaCorreas
;;	> ##.##
;;	15. inAtMat. Nombre de atributo que guarda el valor del material
;;	(para correas y portacorreas)
;;	> "xxx" 
;;	16. inPosMat. Numero de posición NTH del atributo valor del material
;;	(para correas y portacorreas)
;;	> ##
;;	> (("ELEMENTO" "XXX") ("MATERIAL" "XXX")) = 1
;;	17. inAtId0. Nombre de atributo que guarda el valor Id (de referencia)
;;	> "XXX"
;;	18. inPosId. Numero de posicion que contiene el atributo y valor del ID
;;		(de referencia) en la lista de atributos
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> En la distribucion de las guias de las portacorreas
;;		deja un margen de 0.50
;;;(brkstep '("") "001TEMP" "")
					;VARIABLES
					;inSusPc inSusCo
					;********************
					;ARGUMENTOS
					;	inAtMat inPosMat
					;******************
;;**************************************************
(defun InCoPc
	      (inLsAn0	   inLsBlCo0   inLsBlPc0   inAtGuCo0
	       inAtGuPc0   inAtBlCo0   inAtBlPc0   inNomTip0
	       inValGu0	   inNomApp0   inDsCo0	   inDsPc0
	       inSeCo0	   inSePc0     inAtMat0	   inPosMat0
	       inAtId0	   inPosId0    /	   inLsAn
	       inLsBlCo	   inLsBlPc    inAtGuCo	   inAtGuPc
	       inAtBlCo	   inAtBlPc    inNomTip	   inValGu
	       inNomApp	   inDsCo      inDsPc	   inSeCo
	       inSePc	   inP1Co      inP2Co	   inAnTzCo
	       inLim	   inGuCo      inCon1	   inBlCo
	       inCon2	   inP1Pc      inP2Pc	   inAnTzPc
	       inBlPc	   inGuPc      inSusPc	   inSusCo
	       inAtMat	   inPosMat    inIdTab	   inAtId
	       inPosId	   inTotEnti
	      )
					;(setq inLsAn nil inLsBlCo nil inLsBlPc nil inAtGuCo nil
					;	inAtGuPc nil inAtBlCo nil inAtBlPc nil
					;	inNomTip nil inValGu nil inNomApp nil
					;	inDsCo nil inDsPc nil inSeCo nil inSePc nil
					;	inP1Co nil  inP2Co nil inAnTzCo nil
					;	inLim nil  inGuCo nil inCon1 nil inBlCo nil
					;	inCon2 nil inP1Pc nil inP2Pc nil 
					;	inAnTzPc nil inBlPc nil inGuPc nil inSusPc nil
					;	inSusCo nil inAtMat nil inPosMat nil inIdTab nil
					;	inAtId nil inPosId nil inTotEnti nil
					;)
					;(brkstep
					;	'("inLsAn0" "inLsBlCo0" "inLsBlPc0" "inAtGuCo0"
					;		"inAtGuPc0" "inAtBlCo0" "inAtBlPc0" "inNomTip0"
					;		"inValGu0" "inNomApp0" "inDsCo0" "inDsPc0" "inSeCo0" "inSePc0"
					;		"inAtMat0" "inPosMat0" "inAtId0" "inPosId0"
					;	)
					;	"00" "InCoPc"
					;)
  (cond
    (
     (and
       (= (type inLsAn0) 'LIST)
       (= (type inLsBlCo0) 'LIST)
       (= (type inLsBlPc0) 'LIST)
       (= (type inAtGuCo0) 'LIST)
       (= (type inAtGuPc0) 'LIST)
       (= (type inAtBlCo0) 'LIST)
       (= (type inAtBlPc0) 'LIST)
       (= (type inNomTip0) 'STR)
       (= (type inValGu0) 'STR)
       (= (type inNomApp0) 'STR)
       (= (numberp inDsCo0) t)
       (= (numberp inDsPc0) t)
       (= (numberp inSeCo0) t)
       (= (numberp inSePc0) t)
       (= (type inAtMat0) 'STR)
       (= (type inPosMat0) 'INT)
       (= (type inAtid0) 'STR)
       (= (type inPosId0) 'INT)
     )
     (setq inLsAn   inLsAn0
	   inLsBlCo inLsBlCo0
	   inLsBlPc inLsBlPc0
	   inAtGuCo inAtGuCo0
	   inAtGuPc inAtGuPc0
	   inAtBlCo inAtBlCo0
	   inAtBlPc inAtBlPc0
	   inNomTip inNomTip0
	   inValGu  inValGu0
	   inNomApp inNomApp0
	   inDsCo   inDsCo0
	   inDsPc   inDsPc0
	   inSeCo   inSeCo0
	   inSePc   inSePc0
	   inAtMat  inAtMat0
	   inPosMat inPosMat0
	   inAtId   inAtId0
	   inPosId  inPosId0
     )
     (setq inIdTab (cdr (assoc 5 (entget (nth 0 inLsAn)))))
					;inIdTab. Handlet de tablero
					;(brkstep '("inIdTab") "01" "InCoPc")
;;;;;;DISTRIBUCION CORREA***********************(0)
     (setq
       inP1Co
		(polar (nthx '(2 1 0) inLsAn)
		       (angle (nthx '(2 1 0) inLsAn) (nthx '(2 1 1) inLsAn))
		       inSeCo
		)
       inP2Co	(nthx '(2 1 1) inLsAn)
       inAnTzCo	(nthx '(1 0) inLsAn)
       inLim	(list (nth 0 inLsAn))
     )
					;(brkstep '("inP1Co" "inP2Co" "inAnTzCo" "inLim") "01a" "InCoPc")
     (setq
       inGuCo (distper inP1Co inP2Co inAnTzCo inLim inDsCo 3 8 inDsCo)
     )
	  ;;;;;;;;;;;;;;;;;;;SIN AJUSTE;;;;;;;;;;;;;;
					;(brkstep '("inGuCo") "02" "InCoPc")
					;inP1Co. Primer coordenada de Trazo de Correas
					;<(XYZ)>
					;inP2Co. Segunda coordenada de Trazo de Correas
					;<(XYZ)>
					;inAnTzCo. Angulo de trazo
					;<Radianes>
					;inLim. Elementos limte de trazo de guias
					;<(ename ...)>
					;inGuCo. Elementos Guia trazados
					;<(ename ...)>
     (cond
       (
	(not (= inGuCo nil))
	(setq inTotEnti (append inTotEnti inGuCo))
					;(brkstep '("inTotEnti") "03" "InCoPc")
	(setq inCon1 0)
	(while (< inCon1 (length inGuCo))
;;;;;;;agreegar ID
	  (xin2	inNomApp
		(nth inCon1 inGuco)
		(nthx '(0 1) inAtGuCo)
		inAtGuCo
	  )
	  (setq	inBlCo
		 (InsPza inLsBlCo
			 (list
			   (cdr (assoc 10 (entget (nth inCon1 inGuCo))))
			   (cdr (assoc 11 (entget (nth inCon1 inGuCo))))
			 )
			 8
			 1
		 )
	  )
					;(brkstep '("inBlCo") "03" "InCoPc")
					;inBlCo. Lista de entidades de bloques insertados
					;<((ename NomElemento) (...) ...) >
	  (cond
	    (
	     (not (= inBlCo nil))
	     (setq inCon2 0)
	     (while (< inCon2 (length inBlCo))
	       (setq inSusCo
		      (list
			(list 0
			      (list "ELEMENTO"
				    (nthx (list inCon2 1) inBlCo)
			      )
			)
			(list inPosMat
			      (list inAtMat
				    (nthx (list inCon2 1) inBlCo)
			      )
			)
		      )
	       )
					;inSusCo. Lista de sustitucion para lista de
					;	atributos de Correas
					;<((0 ("ELEMENTO" "xxx")) (PsMat (NomATMat "xxx")))>
					;(brkstep
					;	'("inSusCo" "inAtMat" "inPosMat")
					;	"04" "InCoPc"
					;)
	       (setq inAtBlCo (sus1 inSusCo inAtBlCo))
					;(brkstep '("inAtBlCo") "05" "InCoPc")
	       (xin2 inNomApp
		     (nthx (list inCon2 0) inBlCo)
		     (nthx (list inCon2 1) inBlCo)
		     inAtBlCo
	       )
	       (setq inTotEnti
		      (append inTotEnti
			      (list (nthx (list inCon2 0) inBlCo))
		      )
	       )
					;(brkstep '("inTotEnti") "06" "InCoPc")
	       (setq inCon2 (+ inCon2 1))
	     )
	    )
	  )
	  (setq inCon1 (+ inCon1 1))
	)
	**
       )
     )
;;;;;;DISTRIBUCION CORREA***********************(1)
     ;;***********************
;;;;;;DISTRIBUCION PORTACORREA******************(0)
     (setq
       inP1Pc
		(polar (nthx '(1 1 0) inLsAn)
		       (angle (nthx '(1 1 0) inLsAn) (nthx '(1 1 1) inLsAn))
		       inSePc
		)
       inP2Pc	(nthx '(1 1 1) inLsAn)
       inAnTzPc	(nthx '(2 0) inLsAn)
     )
					;(brkstep
					;	'("inP1Pc" "inP2Pc" "inAnTzPc" "inLim")
					;	"07" "InCoPc"
					;)
     (setq
       inGuPc (distper inP1Pc inP2Pc inAnTzPc inLim inDsPc 3 8 inDsPc)
     )
	  ;;;;;;;;;;;;;;;;;;;SIN AJUSTE;;;;;;;;;;;;;;
					;(brkstep '("inGuPc") "08" "InCoPc")
					;inP1Pc. Primer coordenada de Trazo de Correas
					;<(XYZ)>
					;inP2Pc. Segunda coordenada de Trazo de Correas
					;<(XYZ)>
					;inAnTzPc. Angulo de trazo
					;<Radianes>
					;inLim. Elementos limte de trazo de guias
					;<(ename ...)>
					;inGuPc. Elementos Guia trazados
					;<(ename ...)>
     (cond
       (
	(not (= inGuPc nil))
	(setq inTotEnti (append inTotEnti inGuPc))
					;(brkstep '("inTotEnti") "09" "InCoPc")
	(setq inCon1 0)
	(while (< inCon1 (length inGuPc))
;;;;;;;AGREGAR ID
	  (xin2	inNomApp
		(nth inCon1 inGuPc)
		(nthx '(0 1) inAtGuPc)
		inAtGuPc
	  )
	  (setq	inBlPc
		 (InsPza inLsBlPc
			 (list
			   (cdr (assoc 10 (entget (nth inCon1 inGuPc))))
			   (cdr (assoc 11 (entget (nth inCon1 inGuPc))))
			 )
			 8
			 1
		 )
	  )
					;(brkstep '("inBlPc") "10" "InCoPc")
					;inBlPc. Lista de entidades de bloques insertados
					;<((ename "nomBlock") (...)...)>
	  (cond
	    (
	     (not (= inBlPc nil))
	     (setq inCon2 0)
	     (while (< inCon2 (length inBlPc))
	       (setq inSusPc
		      (list
			(list 0
			      (list "ELEMENTO"
				    (nthx (list inCon2 1) inBlPc)
			      )
			)
			(list inPosMat
			      (list inAtMat
				    (nthx (list inCon2 1) inBlPc)
			      )
			)
		      )
	       )
					;inSusPc. Lista de sustitucion de atriutos
					;<(PosElem ("ELEMENTO" "XX") (PosMat ("NomMat" "XX"))>
					;(brkstep
					;	'("inSusPc" "inAtMat" "inPosMat")
					;	"11" "InCoPc"
					;)
	       (setq inAtBlPc (sus1 inSusPc inAtBlPc))
					;(brkstep
					;	'("inAtBlPc") "12" "InCoPc"
					;)
	       (xin2 inNomApp
		     (nthx (list inCon2 0) inBlPc)
		     (nthx (list inCon2 1) inBlPc)
		     inAtBlPc
	       )
	       (setq inTotEnti
		      (append inTotEnti
			      (list (nthx (list inCon2 0) inBlPc))
		      )
	       )
					;(brkstep '("inTotEnti") "13" "InCoPc")
	       (setq inCon2 (+ inCon2 1))
	     )
	    )
	  )
	  (setq inCon1 (+ inCon1 1))
	)

       )
     )
					;DISTRIBUCION
					;PORTACORREA******************(1)
    )
  )
					;(brkstep '("inTotEnti") "14" "InCoPc")
  (setq inTotEnti inTotEnti)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO / TITULO: MuroX1. Comando 'MUROX'. Limplia lineas en cruce.
;;DESCRIPCION: MuroX. Apartir de dos pares de lineas paralelas,
;;	corta las lineas para limpiar el cruce entre ellas.
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:muroX
	( /
		m1Ans m1Fl m1Sl m1LsFl m1EntRs m1Opc
	)
;	(setq m1Ans nil m1Fl nil m1Sl nil m1LsFl nil m1EntRs nil m1Opc nil)
	(initget 2 "Si No Enter")
	(setq m1Ans (getkword "DESEA FILTRAR LA SELECCION POR LAYER? [Si / No / Enter para salir]: "))
	(princ) (princ)
	(cond
		(
			(= m1Ans "Si")
			(setq m1Opc "Filtrar")
		)
		(
			(= m1Ans "No")
			(setq m1Opc "Continuar")
		)
		(
			(= m1Ans nil)
			(setq m1Opc "Enter")
		)
	)
;	(brkstep1 '("m1Ans" "m1Opc") (list m1Ans m1Opc) "01" "MuroX1")
	(while (not (or (= m1Opc nil) (= m1Opc "Enter")))
		(cond
			(
				(= m1Opc "Filtrar")
				(setq m1Fl
					(car
						(entsel
							"SELECCIONES ALGUNA ENTIDAD CON EL LAYER DESEADO: (Enter 	Continuar)"
						)
					)
				)
;				(brkstep1 '("m1Fl") (list m1Fl) "02" "MuroX1")
				(cond
					(
						(not (= m1Fl nil))
						(setq m1LsFl (list '(0 . "LINE") (assoc 8 (entget m1Fl))))
;						(brkstep1 '("m1LsFl") (list m1LsFl) "03" "MuroX1")
						(setq m1Sl (ssget m1LsFl))
;						(brkstep1 '("m1Sl") (list m1Sl) "04" "MuroX1")
					)
					(
						(= m1Fl nil)
						(setq m1Opc "Continuar")
					)
				)
			)
			(
				(= m1Opc "Continuar")
				(setq m1Sl (ssget '((0 . "LINE"))))
;				(brkstep1 '("m1Sl") (list m1Sl) "05" "MuroX1")
				
			)
		)
;		(brkstep1 '("m1Sl") (list m1Sl) "06" "MuroX")
		(cond
			(
				(not (= m1Sl  nil))
				(setq m1EntRs (MuroX0 (noment m1Sl) 7 0))
				(initget 2 "Continuar Filtrar Salir")
				(setq m1Opc
					(getkword "DESEAS CONTINUAR O CAMBIAR DE FILTRO?; [Filtrar / Continuar / Enter para salir]: ")
				)
			)
			(
				(= m1Sl nil)
				(initget 2)
				(setq m1Opc
					(getkword "DESEAS CONTINUAR O CAMBIAR DE FILTRO? [Filtrar / Continuar / Entier para salir]: ")
				)
			)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: MAIN
;;OBJETO / TITULO: DsTubo0. Comando DSTUBO. Calcula la distancia entre dos
;; marcadores sobre una polilinea
;;DESCRIPCION: DsTubo0. Comando DSTUBO. Apartir de la definicion de
;;	numero de tubo inicial, numero de tubo final y  el perfil (polilinea)
;;	calcula la distancia que existe entre los mismos marcadores sobre dicho perfil.
;;DEVUELVE:
;;	> selDist. Distancia total entre marcadores
;;ARGUMENTOS
;;
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:DsTubo
	(/
		msel prim sec selMarc1 selMarc0 selPas selPas1 selTxt selT1 selT2 selMarc2 selDist selPoli
		dsOrden dsEnamPl dsCiclo dsLsTx1 dsLsTx2 dsTx3 selMarcFn dsAtt dsType
	)
	;;VARIABLES DE DEPURACION;;;(0)
;	(setq msel nil prim nil sec nil selMarc1 nil selMarc0 nil selPas nil
;		selPas1 nil selTxt nil selT1 nil selT2 nil
;		selMarc2 nil selDist nil selPoli nil dsOrden nil dsEnamPl nil dsCiclo nil
;		dsLsTx1 nil dsLsTx2 nil dsTx3 nil selMarcFn nil dsAtt nil dsType nil
;	)
	;;VARIABLES DE DEPURACION;;;(1)
	(setq selPas1 1)
	(while (= selPas1 1)
		(setq dsEnamPl (car (entsel "SELECCIONE LA POLILINEA [ENTER PARA TERMINAR]: ")))
		;;
;		(brkstep1 '("dsEnamPl") (list dsEnamPl) "01" "DsTubo0")
		;;dsEnamPl. Nombre de entidad de polilinea <ENAME>
		(cond
			(
				(= (type dsEnamPl) 'ENAME)
				(setq dsType (cdr (assoc 0 (entget dsEnamPl))))
				;;
;				(brkstep1 '("dsType") (list dsType) "02" "DsTubo0")
				;;
				(if (= dsType "LWPOLYLINE")
					(setq selPas1 0)
					(progn
						(alert
							(strcat "EL ELEMENTO SELECCIONADO\nES DE TIPO "
								(cdr (assoc 0 (entget dsEnamPl)))
							)
						)
					)
				);..IF
			);..type dsEnamPl = 'ENAME
			(
				(= dsEnamPl nil)
				(setq selPas1 2)
			)
		);...cond
		;;
;		(brkstep1 '("selPas1") (list selPas1) "03" "DsTubo0")
		;;
	);...While
	;;
;	(brkstep1 '("selPas1" "dsEnamPl") (list selPas1 dsEnamPl) "04" "DsTubo0")
	;;
	(cond
		(
			(= selPas1 0)
			(setq msel
				(noment
					(SelPol dsEnamPl '((2 . "Punta1")) 0)
				)
			)
			;;
;			(brkstep1 '("msel" "(length msel)") (list msel (length msel)) "05" "DsTubo0")
			;;msel. Lista de nombre de entidad de marcadores de polilinea  <(ename...)>
			(cond
				(
					(= msel nil)
					(alert "NO EXISTEN MARCADORES EN LA POLILINEA SELECCIONADA: ")
				)
				(
					(not (= msel nil))
					(setq dsCiclo 0)
					(while
						(< dsCiclo 2)
						(setq prim nil selMarc1 nil selMarc0 nil)
						(setq dsLsTx1 (list "INICIAL" "FINAL"))
						(setq dsLsTx2 (list "PRIMER" "SEGUNDO"))
						(setq dsLsTx3 (list "TUBO_POSTERIOR" "TUBO_ANTERIOR"))
						(setq prim
							(getint
								(strcat "INDIQUE EL NUMERO DE TUBO "
									(nth dsCiclo dsLsTx1)
									": [ENTER PARA SELECCIONAR]: "
								)
							)
						)
						(princ) (prin1) (princ)
						;;
;						(brkstep1 '("prim") (list prim) "06" "DsTubo0")
						;;prim. Numero de marcador <INT>
						(cond
							(
								(not (= prim nil))
								(setq selMarc1
									(exnoma "AZ-CIVIL"
										(list
											(cons 1000
												(strcat
													(nth dsCiclo dsLsTx3)
													","
													(itoa prim)
												)
											)
										)
										msel
									)
								)
							);...(not (= prim nil))
						);...Cond
						(cond
							(
								(= selMarc1 nil)
								(setq selPas 1)
								(while (= selPas 1)
									(setq selMarc0
										(car
											(entsel
												(strcat "SELECCIONE EL " (nth dsCiclo dsLsTx2) " MARCADOR [ENTER PARA SALIR]: ")
											)
										)
									)
									;;
;									(brkstep1 '("selMarc0") (list selMarc0) "07" "DsTubo0")
									;;selMarc0. Marcador seleccionado cuando no se encontro el numero indicado
									(cond
										(
											(= selMarc0 nil)
											(setq selPas 0)
										);...selMarc0 = nil
										(
											(not (= (cdr (assoc 2 (entget selMarc0))) "Punta1"))
											(alert "LA ENTIDAD SELECCIONADA NO ES VALIDA\nSE REQUIERE (Punta1)")
										);...(not selMarc0 = "punta1")
										(
											(= (cdr (assoc 2 (entget selMarc0))) "Punta1")
											(setq selPas 0)
											(setq selMarc1 (list selMarc0))
										);...selMarc0 = "punta1"
									);..Cond selMarc0
								);...while selPas=1
								;;
;								(brkstep1
;									'("selMarc1") (list selMarc1)
;									"08" "DsTubo0"
;								)
								;;selMarc1. Nombre Entidad marcador <Ename>
							);...selMarc1 = nil
						);...cond
						(cond
							(
								(not (= selMarc1 nil))
								(setq selMarcFn
									(append selMarcFn selMarc1)
								)
								(setq dsCiclo (+ dsCiclo 1))
							);...(not (= selMarc1 nil))
							(
								(= selMarc1 nil)
								(setq dsCiclo 3)
								(setq selMarcFn nil)
							);...selMarc1 = nil
						);...cond
						;;
;						(brkstep1 '("selMarcFn" "dsCiclo") (list selMarcFn dsCiclo) "09" "DsTubo0")
						;;
						;;selMarcFn. Lista de marcadores <(enameMarc1 enameMarc2)>
					);...While (< dsCiclo 2)
				);...(not (= msel nil))
			);...Cond msel
			;;
;			(brkstep1 '("selMarcFn") (list selMarcFn) "10" "DsTubo0")
			;;
			(cond
				(
					(not (= selMarcFn nil))
					(setq selPoli dsEnamPl
						selT1 (nth 0 selMarcFn)
						selT2 (nth 1 selMarcFn)
					)
					;;
;					(brkstep1 
;						'("selPoli") (list selPoli) "11" "DsTubo0"
;					)
					;;selPoli. Nombre de entidad de polilinea
					(cond
						(
							(not (= selPoli nil))
							(setq selDist (DiTick selT1 selT2 selPoli 3))
							;;
;							(brkstep1 '("selDist") (list selDist) "12" "DsTubo0").
							;;
							(cond
								(
									(not (= selDist nil))
									(alert
										(strcat
											"DISTANCIA TOTAL =\n"
											(rtos selDist 2 2)
										)
									)
								);...(not (= selDist nil))
							);...Cond
						);...(not selPoli = nil)
					);...cond
				);...(not (= selMarcFn nil))
			);...Cond
			(setq selDist (round1 selDist 2))
		);...selPas1 = 0 <polilinea>
	);...cond
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: Main
;;OBJETO / TITULO: IntDat1. Comando Marc
;;	Introduccion de atributos.
;;SINTAXIS: C:marc
;;DESCRIPCION: IntDat1. Comando Marc.
;;	Metodo para la introduccion de atributos
;;	 en los marcadores representados por el
;;	 block "Punta1.dwg" que pasan por una
;;	 que pasan por una polilinea.
;;	
;;	>
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1.
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Atributos:
;;	> ELEMENTO: MARCADOR
;;	> ID_POL: HANDLET
;;	> DIST_ANTERIOR:
;;	> DIST_POSTERIOR:
;;	> TUBO_ANTERIOR:
;;	> TUBO_POSTERIOR:
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(maLsMarc0 maPolNam0 maPre0
;(IntDat [LsMarc])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:marc
	(/
		mrMaSel mrPlSel mrMaLs
	)
;	(setq mrMaSel nil mrPlSel nil mrMaLs nil)
	(setvar 'nomutt 0)
	(while (= mrMaSel nil)
		(prompt "\nSELECCIONE LOS MARCADORES [Enter para seleccionar todos]: ")
		(setvar 'nomutt 1)
		(setq mrMaSel
			(ssget '((2 . "Punta1.dwg"))
			)
		)
		(if mrMaSel (sslength mrMaSl))
		(setvar 'nomutt 0)
		(cond
			(
				(= mrMaSel nil)
				(setq mrMaSel (ssget "x" '((2 . "Punta1"))))
			)
		)
	)
	;;
;	(brkstep1 '("mrMaSel") (list mrMaSel) "01" "Marc")
	;;
	(cond
		(
			(not (= mrMaSel nil))
			(setq mrMaLs (noment mrMaSel))
		)
	)
	(setq mrPlSel (car(entsel "SELECCIONE LA POLILINEA: ")))
	;;
;	(brkstep1 '("mrPlSel" "mrMaLs") (list mrPlSel mrMaLs) "02" "MarcLs")
	;;
	(cond
		(
			(and
				(= (type mrPlSel) 'ENAME)
				(= (LsType mrMaLs) 'ENAME)
			)
			(setq mrMaLs (MarcLs mrMaLs mrPlSel 3))
			;;
;			(brkstep1 '("mrMaLs") (list mrMaLs) "03" "MarcLs")
			;;
			(cond
				(
					(not (= mrMaLs nil))
					(IntDat mrMaLs mrPlSel)
				)
			)
		)
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION:MAIN
;;OBJETO / TITULO:ReUb. Comando c:Ubica.  Reubica los marcadores de una polilinea
;;SINTAXIS: Ubica
;;DESCRIPCION:ReUb. Comando c:Ubica. Reubica los marcadores con atributos XD de una
;;	definida en el argumento
;;	>
;;DEVUELVE:
;;	> 
;;ARGUMENTOS
;;
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
(defun c:Ubica
	(/
		ubPolSl ubMacSl
	)
;	(setq ubPolSl nil ubMacSl nil)
	(command "view" "s" "ReUbica")
	(setvar "nomutt" 0)
	(prompt "\nSELECCIONE LOS MARCADORES [Enter para seleccionar todos]: ")
	(setvar 'nomutt 1)
	(setq ubMacSl
		(ssget '((2 . "Punta1")))
	)
	;;
;	(brkstep1 '("ubMacSl") (list ubMacSl) "01" "ReUb")
	;;
	(cond
		(
			(= ubMacSl nil)|
			(setq ubMacSl
				(ssget "x" '((2 . "Punta1")))
			)
		)
	)
	(setq ubMacSl (noment ubMacSl))
	;;
;	(brkstep1 '("ubMacSl") (list ubMacSl) "02" "ReUb")
	;;
	(cond
		(
			(not (= ubMacSl nil))
			(setq ubPolSl
				(car
					(entsel "SELECCIONE LA POLILINEA: ")
				)
			)
			;;
;			(brkstep1 '("ubPolSl") (list ubPolSl) "03" "ReUb")
			;;
			(cond
				(
					(= (type ubPolSl) 'ENAME)
					(ReUb0 ubMacSl ubPolSl "AZ-CIVIL" 3)
				)
			)
		)
	)
	(command "view" "r" "ReUbica")
	(command "view" "d" "ReUbica")
)
;
;;
;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: Main
;;OBJETO: ACTUALIZA
;;	> Actualiza todos los  puntos  de inflexion de una poilinea
;;DEVUELVE:
;;	> anFil. Lista de nombre de entidades de los bloques de puntos
;;	de inflexion de la polilinea
;;ARGUMENTOS
;;	1.Metodo
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>Nombre de la aplicación: AZ-CIVIL
;;	>Nombre de atributo: ID_POL
;;	>Nombre del bloque: Pto-inf; MAR_VER
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:Actualiza
	( /
		acEnti acLsPto acNomXd acNomAp acFil acLsFn acLsNo acCon1 acSel acCon2 acTag
		acHnd
	)
;	(setq acEnti nil acLsPto nil acNomXd nil acNomAp nil acFil nil acLsFn nil acLsNo nil
;		acCon1 nil acSel nil acCon2 nil acTag nil acHnd nil
;	)
	(setq acSel (ssget "x" '((-4 . "<OR") (2 . "Pto-inf") (2 . "MAR_VER") (-4 . "OR>"))))
	(setq acEnti (car (entsel "SELECCIONE EL PERFIL: ")))
	;;
;	(brkstep1 '("acSel" "acEnti") (list acSel acEnti) "00" "Actualiza")
	;;
	(cond
		(
			(and
				(not (= acSel nil))
				(not (= acEnti nil))
			)
			(setq acHnd (cdr (assoc 5 (entget acEnti)))
				acLsPto (noment acSel)
				acNomXd "ID_POL"
				acNomAp "AZ-CIVIL"
				acCon2 0
			)
			(setq acLsPto
				(exnoma
					"AZ-CIVIL"
					(list
						(cons 1000
							(strcat acNomXd "," acHnd)
						)
					)
					acLsPto
				)
			)
			;;
;			(brkstep1
;				'("acLsPto" "(length acLsPto)" "acNomXd" "acNomAp")
;				(list acLsPto (length acLsPto) acNomXd acNomAp)
;				"01" "Actualiza"
;			)
			;;
			(cond
				(
					(and
						(not (= acEnti nil))
						(not (= acLsPto nil))
					)
					(cond
						(
							(= anSc nil)
							(setq anSc (getreal "INDIQUE LA ESCALA DEL BLOQUE: "))
						)
					)
					(mapcar 'entdel acLsPto)
					;;
;					(brkstep1 '("acEnti" "anSc") (list acEnti anSc) "02" "Actualiza")
					;;
;					(setq acLsFn (anFlex acEnti 3 0.0 anSc))
					(anFlex acEnti 3 0.0 anSc)
					;;
;					(brkstep1 '("acLsFn") (list acLsFn) "03" "Actualiza")
					;;
				)
			)
			
		)
	)
	(textpage)
	(graphscr)
;	(setq acLsFn acLsFn)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;TITULO: CATOP. Define las coordenadas de la recta que va del centro
;;	a la perpendicular de la recta que corta la curva (cateto opuesto)
;;DESCRIPCION. CATOP. A partir de la definicion del radio como hipotenusa,
;;	coordenada X del punto o recta de interseccion y la coordenada (XY) del centro
;;  se define las dos coordenadas de intersección con la recta de 90 grados.
;;	(cateto opuesto)
;;DEVUELVE: Las dos coordenadas interseccion de la curva con la recta a 90 grados.
;;	> ( (x y) (x y) )
;;ARGUMENTOS
;;	1.RD10. Radio de circunfencia
;;	> Numero real
;;	2. XP10. coordenada x de punto o recta de interseccion
;;	> Numero real
;;	3. XYCEN0. Coordenada XY de centro de circunferencia o curva.
;; 	(X Y)
;;DEPENDIENTES
;;	> NINGUNO
;;ANOTACIONES
;;	>
(defun catop
	(rd10 xp10 xycen0 /
		rd1 xp1 xycen
		co2 cay cay2 rd2  co coory coory1 coory2 lcfin
	)
	;;
;	(brkstep1 '("rd10" "xp10" "xycen0")
;		(list rd10 xp10 xycen0)
;		"00" "CATOP"
;	)
	;;
;	(setq rd1 nil xp1 nil xycen nil
;		co2 nil cay nil cay2 nil rd2 nil co nil coory nil
;		coory1 nil coory2 nil lcfin nil
;	)
	(cond
		(
			(and
				(not (= rd10 nil))
				(not (= xp10 nil))
				(not (= xycen0 nil))
			)
			(setq rd1 rd10
				xp1 xp10
				xycen xycen0
			)
			;;
;			(brkstep1
;				'("rd1" "xp1" "xycen")
;				(list rd1 xpl xycen)
;				"01" "CATOP"
;			)
			;;
			(setq cay
				(abs
					(- xp1 (nth 0 xycen))
				)
				lcfin '()
			)	
			(setq cay2 (* cay cay)
				rd2 (* rd1 rd1)
			)
			(setq co2 (- rd2 cay2)
				co (sqrt co2)
			)
			(setq coory (nth 1 xycen))
			(setq coory1
				(- coory co)
			)
			(setq coory2
				(+ co coory)
			)
			(setq lcfin
				(append lcfin
					(list
						(list
							xp1 coory1
						)
					)
					(list
						(list
							xp1 coory2
						)
					)
				)
			)
		)
	)
	(setq lcfin lcfin)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO: YINT
;;TITULO. YINT. Calcula la coordenada de interseccion 
;;DESCRIPCION. YINT. A partir de la definición de la coordenada X,
;;	pendiente y ordenada al origen de una recta inclinada,
;;	devuelve la coordenada de intersección.
;;DEVUELVE: Coordenada de intersección
;;	> (X Y)
;;ARGUMENTOS
;;	1. XR10: Coordenada x de intersección
;;	> Numero real
;;	2. B10: Ordenada al origen de la recta
;;	3. M10: Pendiente de la recta
;;DEPENDIENTES
;;	> Ninguno
;;ANOTACIONES
;;
(defun yint
	(xr10 b10 m10 /
		xr1 b1 m1
		tt1 ttr resf
	)
	;;
;	(setq xr1 nil b1 nil m1 nil
;		tt1 nil ttr nil resf nil
;	)
	;;
;	(brkstep1
;		'("xr10" "b10" "m10")
;		(list xr10 b10 m10)
;		"00" "YINT"
;	)
	;;
	(setq
		xr1 xr10
		b1 b10
		m1 m10
	)
	;;
;	(brkstep1
;		'("xr1" "b1" "m1")
;		(list xr1 b1 m1)
;		"01" "YINT"
;	)
	;;
    (setq tt1 (* m1 xr1)
        ttr (+ tt1 b1)
    )
    (setq resf (list xr1 ttr))
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;TITULO. ETA. Calcula la mitad del angulo incluido
;;DESCRIPCION: ETA. Angulo eta (la mitad del angulo theta o incluido)
;;	de la curva dentro de una poligonal.
;;DEVUELVE:
;;	> Valor del angulo Eta
;;ARGUMENTOS
;;	1.bugle0. Factor de curvatura <REAL>
;;	>
;;DEPENDIENTES
;;	> ANINC
;;ANOTACIONES
;;	> Puede devolver angulos 
(defun eta
	(bugle0 /
		bugle
		mieta
	)
	;;
;	(brkstep1 '("bugle0") (list bugle0) "00" "eta")
	;;
;	(setq bugle nil mieta nil)
	;;
;	(brkstep1 '("bugle") (list bugle) "01" "eta")
	;;
	(cond
		(
			(not (= bugle0 nil))
			(setq bugle bugle0)
			(setq mieta
				(/
					(aninc
						(abs bugle)
					)
					2.0
				)
			)
		)
	)
	(setq mieta mieta)
)
;
;;
;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;TITULO: GAMMA. Angulo de la recta del radio de la curva y la recta cortante.
;;DESCRIPCION: GAMMA. Angulo GAMMA formado entre:
;;	la recta que va de un extremo de la curva al centro de la misma y
;;	la recta que va del mismo extremo de la curva al otro extremo de la curva.
;; <REAL>.
;;DEVUELVE:
;;	> Valor del angulo Gamma
;;ARGUMENTOS
;;	1. bugle0. Curvatura de un arco
;;	>
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Calcula el valor absoluto de Bugle
(defun gamma
	(bugle0 /
		bugle
		migam
	)
	;;
;	(brkstep1 '("bugle0") (list bugle0) "00" "GAMMA")
	;;
;	(setq bugle nil migam nil)
	(cond
		(
			(not (= bugle0 nil))
			(setq bugle bugle0)
			;;
;			(brkstep1 '("bugle") (list bugle) "01" "GAMMA")
			;;
			(setq migam
				(-
					(/ pi
						2.0
					)
					(*
						2.0
						(atan (abs bugle))
					)
				)
			)
		)
	)
	(setq migam migam)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;OBJETO: PHI: Encuentra el angulo PHI de una curva dentro de una polilinea
;;	> Angulo PHI formado entre:
;;	La recta que va de un extremo de la curva al punto medio de la curva y
;;	La recta que va del mismo extremo de la curva al centro de la misma
;;
;;DEVUELVE:
;;	> Valor del angulo Phi
;;ARGUMENTOS
;;	1. (bugle)
;;	> Código 42 de lista de base de datos de la polilinea
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Calcula con el valor absoluto de bugle
(defun phi (bugle / miphi)
	(setq bugle (abs bugle))
	(setq miphi
		(-
			(/ pi 2.0)
			(atan bugle)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;OBJETO: EPSI: Encuentra el angulo EPSILON de una curva dentro de una polilinea
;;	> Angulo EPSILON formado entre:
;;	La recta que va de un extremo de la curva al  otro extremo de la curva y
;;	La recta que va del mismo extremo de la curva al punto medio de la misma
;;
;;DEVUELVE:
;;	> Valor del angulo epsilon
;;ARGUMENTOS
;;	1. (bugle)
;;	> Código 42 de lista de base de datos de la polilinea
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Calcula con el valor absoluto de bugle
(defun epsi (bugle / miepsi)
	(setq miepsi
		(atan
			(abs bugle)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;OBJETO: ALTCU: Encuentra la altura de la curva
;;	> Altura de la curva:
;;	Linea formada desde el punto medio de la curva y
;;	el punto medio de la recta formada entre ambos extremos de la curva
;;	formando un angulo recto entre las dos rectas.
;;DEVUELVE:
;;	> Valor de la altura de la curva
;;ARGUMENTOS
;;	1. (bugle)
;;	> Código 42 de lista de base de datos de la polilinea
;;	2. PT1: Coordenada1 del extremo de la curva
;;	(x y z)
;;	3. PT2: Coordenada2 del extremo de la curva
;;	(x y z)
;;DEPENDIENTES
;;	>  Ninguno
;;ANOTACIONES
;;	> Calcula con el valor absoluto de bugle
(defun altcu (bugle pt1 pt2 / mialt)	
	(setq mialt
		(*
			(/
				(distance pt1 pt2)
				2.0
			)
			(abs bugle)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;OBJETO: RADIO1
;;	> Distancia de cualquier punto de la curva al centro de la misma. (opcion)
;;DEVUELVE:
;;	> Valor de la distancia (Radio de la curva).
;;ARGUMENTOS
;;	1. BUGLE: Curvatura (bugle).
;;	> Código 42 de lista de base de datos de la polilinea
;;	2. PP0: Coordenada1 del extremo de la curva
;;	(x y z)
;;	3. PP1: Coordenada2 del extremo de la cura
;;	(x y z)
;;DEPENDIENTES
;;	>  ALTCU
;;ANOTACIONES
;;	> Calcula con el valor absoluto de bugle
(defun radio1 (bugle pp0 pp1 / mira1)
	(setq mira1
		(/
			(+
				(expt
					(/
						(distance pp0 pp1)
						2.0
					)
					2.0
				)
				(expt
					(altcu bugle pp0 pp1)
					2.0
				)
			)
			(*
				2.0
				(altcu bugle pp0 pp1)
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;OBJETO: RADIO2: Calcula el radio de una curva dentro de una polilinea
;;	> Distancia de cualquier punto de la curva al centro de la misma. (opcion)
;;DEVUELVE:
;;	> Valor de la distancia (Radio de la curva).
;;ARGUMENTOS
;;	1. BUGLE
;;	> Código 42 de lista de base de datos de la polilinea
;;	2. PP0: Coordenada1 del extremo de la curva
;;	(x y z)
;;	3. PP1: Coordenada2 del extremo de la cura
;;	(x y z)
;;DEPENDIENTES
;;	>  ALTCU, EPSI, PHI
;;ANOTACIONES
;;	> Calcula con el valor absoluto de bugle
;;PR...
(defun radio2 (bugle pp0 pp1 / mira2)
	(setq mira2
		(/
			(altcu bugle pp0 pp1)
			(* 
				2.0
				(sin
					(epsi bugle)
				)
				(cos
					(phi bugle)
				)
			)
		)
	)	
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: BGL
;;OBJETO: APOT
;;	> APOTEMA: Calcula la distancia del centro de la curva al punto medio
;;	de la recta formada entre ambos extremos de la curva.
;;DEVUELVE:
;;	> Valor de la distancia de apotema.
;;ARGUMENTOS
;;	1. BUGLE
;;	> Código 42 de lista de base de datos de la polilinea
;;	2. PP0: Coordenada1 del extremo de la curva
;;	(x y z)
;;	3. PP1: Coordenada2 del extremo de la cura
;;	(x y z)
;;DEPENDIENTES
;;	>  ALTCU, EPSI, PHI
;;ANOTACIONES
;;	> Calcula con el valor absoluto de bugle
(defun apot (bugle pp0 pp1 / apo1)
	(setq apo1
		(sqrt
			(-
				(expt
					(radio2 bugle pp0 pp1)
					2.0
				)
				(expt
					(/
						(distance pp0 pp1)
						2.0
					)
					2.0
				)
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:BGL
;;OBJETO: CEN1
;;	> Encuentra las coordenadas del centro de una curva dentro de una polilinea
;;	Apartir de la definicion de los dos puntos de la curva y la curvatura
;;DEVUELVE: Cordenada del centro de la curva
;;	> Coordenada (x y z)
;;ARGUMENTOS
;;	1.BUGLE.- Curvatura
;;	> Código 42 de lista de base de datos de la polilinea
;;	2.PT1 Coordenada 1 de curva
;;	3.PT2 Coordenada 2 de curva
;;DEPENDIENTES
;;	> GAMMA (); RADIO1 (ALTCU)
;;ANOTACIONES
;;	>
(defun cen1 (bugle pt1 pt2 / ang1 ddi1 coorf1)
	(setq
		ang1  
		(if
			(>= bugle 0)
			(+
				(angle pt1 pt2)
				(gamma bugle)
			)
			(-
				(angle pt1 pt2)
				(gamma bugle)
			)
		)
	)
	(setq ddi1 (radio1 bugle pt1 pt2))
	(setq coorf1 (polar pt1 ang1 ddi1))
	(setq coorf1 coorf1)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: SEG1V
;;	> Devuelve la lista de coordenadas donde cada segmento de recta repite una
;;	coordenada con la anterior y posterior como segmentos conectados, a partir de la definicion
;;	de una lista de coordenadas ordenadas como polilinea.
;;DEVUELVE: Lista de segmentos
;;	>( (coordenada1 coordenada2) (coordenada2 coordenada3) ....)
;;ARGUMENTOS
;;	1. CORSEG: Lista de coordena
;;	> ( (X Y) (X Y) ...)
;;DEPENDIENTES
;;	> ERT ()
;;ANOTACIONES
;;
(defun seg1v (corseg / con fnl fnll)
	(setq con 0
		finll '()
	)
	(while (< con (- (length corseg) 1))
		(setq fnl (ert corseg (list con (+ con 1)))
		)
		(setq fnll
			(append fnll (list fnl))
		)
		(setq con (+ con 1))
	)
	(setq fnll fnll)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO: CURIN1
;;	> Define el punto de interseccion de una curva y una recta.
;;DEVUELVE: Coordenadas de interseccion de la curva donde
;;	la primera coordenada es la que se encuentra mas cerca del punto medio
;;	entre la recta del punto de inicio y el punto final de la curva.
;;	> Coordanada ((X1 Y)
;;ARGUMENTOS
;;	1. INPTO: Punto de inicio
;;	> (X Y) o (X Y Z)
;;	2. ALIAN: Angulo de alineacion
;; 	> Angulo en radianes
;;	3. SEGP: Segundo punto de recta
;;	(X Y) o (X Y Z)
;;	4. PART: Segmento de polilinea
;;	> ( (X Y) BUGLE (X Y) )
;;DEPENDIENTES
;;	> CEN1 ()
;;	> RADIO2 (ATLCU (); EPSI (); PHI ())
;;	> CATOP ()
;;	> PPND2 ()
;;	> ORDI ()
;;	> ABC ()
;;	> YINT ()
;;	> EG11 ()
;;	> CURIN1 ()
;;	> DISC ()
;;ANOTACIONES
;;	> Si existe el segundo punto en el argumento (segp) se puede omitir el angulo (),
;;	si no existe el segundo punto (), es necesario que exista el angulo.
(defun curin1
	(inpto alian segp part /
		coorf pdm mior micen
		mirad facts fa fb fc
		mix mmp dix1 dix2 mixf mix1 mix2 miangi
	)
	(cond
		(
			(= segp nil)
			(cond
				(
					(not (= alian nil))
					(setq segp
						(polar inpto alian 1)
						segp
						(list (nth 0 segp) (nth 1 segp))
					)
				)
			)
		)
	)
	(cond
		(
			(not (= segp nil))
			(setq micen (cen1 (nth 1 part) (nth 0 part) (nth 2 part)))
			(setq mirad (radio2 (nth 1 part) (nth 0 part) (nth 2 part)))
			(setq miangi (angle inpto segp))
			(setq mmp
				(polar
					(nth 0 part)
					(angle (nth 0 part) (nth 2 part))
					( / (distance (nth 0 part) (nth 2 part)) 2)
				)
			)
			(cond
				(
					(or
						(EqLs miangi 1.5708 0 0.0001)
						(EqLs miangi 4.71239 0 0.0001)
					)
					(cond
						(
							(<
								(distance
									(nth 1
										(linin
											micen
											0
											(append inpto segp)
										)
									)
									micen
								)
								mirad
							)
							(setq xco (nth 0 inpto))
							(setq mixf (catop mirad xco micen)
								mixf (curin2 mixf part)
							)
						)
					)
				)
				(
					(and
						(not (EqLs miangi 1.5708 0 0.0001))
						(not (EqLs miangi 4.71239 0 0.0001))
					)
					(setq pdm (ppnd2  inpto segp)
						mior (ordi inpto pdm)
					)
					(setq facts (abc pdm mior micen mirad))
					(setq fa (nth 0 facts))
					(setq fb (nth 1 facts))
					(setq fc (nth 2 facts))
					(cond
						(
							(< 0 (disc fa fb fc))
							(setq mix (eg11 fa fb fc))
							(setq mix1
								(yint
									(nth 0 mix) mior pdm
								)
								mix2
								(yint
									(nth 1 mix) mior pdm
								)
								mixf
								(list mix1 mix2)
							)
							(setq mixf (curin2 mixf part))
						)
					)
				)
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: ORDEN
;;	Ordena una lista (generada por EXPAT) con base en el
;;	primer elemento de cada lista
;;DEVUELVE:
;;	Misma lista generada por EXPAT ordenada
;;	( (No. val1 val2 val...) (...) ...)
;;ARGUMENTOS:
;;	1. LISTO: Lista de elementos para ordenar de acuerdo
;;	al primer numero de cada lista
;;	( (no. val1 val2 val...) (...) ...)
;;	2. MODOOR: Modo de orden
;;	En modo 0: Ordena las listas de manera ascendente
;;	En modo 1: Ordena las listas de manera descendente
;;ANOTACIONES:
;;PR...
;;DEPENDIENTES:
;;	TXNO
(defun orden
	(listo modoor / con1 nlid ps1 nflid)
	(setq ps1 0)
	(while
		(not (= listo nil))
		(setq con1 0
			nlid (nth 0 listo)
		)
		(cond
			(
				(= (length listo) 1)
				(setq listo nil)
			)
		)
		(while
			(< con1 (length listo))
			(cond
				(
					(<= (nth 0 (nth con1 listo)) (nth 0 nlid))
					(setq nlid (nth con1 listo))
				)
			)
			(setq con1 (+ con1 1))
		)
		(setq listo (txno listo nlid))
		(cond
			(
				(= ps1 0)
				(setq ps1 1
					nflid (list nlid)
				)
			)
			(
				(= ps1 1)
				(cond
					(
						(= modoor 0)
						(setq nflid (append nflid (list nlid)))
					)
					(
						(= modoor 1)
						(setq nflid (append (list nlid) nflid))
					)
				)
			)
		)
    )
	(setq nflid nflid)
 )
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO: ANGRESTA
;;	> Resta de angulos considerando un minimo de 0 grados
;;DEVUELVE:
;;	> Angulo en radianes
;;ARGUMENTOS
;;	1.ANGB: Angulo base
;;	> Angulo en radianes
;;	2.ANGRE : Angulo de resta
;;	> Angulo en radianes
;;DEPENDIENTES
;;	> NINGUNO
;;ANOTACIONES
;;	> Todos los angulos se manejan en radianes.
(defun angresta
	(angb angre / angf0 angf1)
	(cond
		(
			(< angb angre)
			(setq angf0 (- angre angb))
			(setq angf1
				(- (* 2 pi)
					angf0
				)
			)
		)
		(
			(= 0 0)
			(setq angf1 (- angb angre))
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: MAT
;;OBJETO: CURIN2
;;	> Verifica de los puntos de interseccion de la curva (circunferencia)
;;	cuales puntos realmente pertenecen al segmento de la polilinea.
;;DEVUELVE:
;;	> Lista de coordenadas que pertenecen a la curva.
;;	((xy) (xy) ...)
;;ARGUMENTOS
;;	1. INTCOR: Lista de coordenadas que intersectan con la curva (circunferencia)
;;	> ((xy) (xy) ...)
;;	2. SEGM: Segmento de curva con el formato creado por (SEG)
;;	( (xy) bulge (xy) )
;;DEPENDIENTES
;;	> CURIN1 (?)
;;ANOTACIONES
;;	> Trabaja con radianes
;;;
(defun curin2 (intcor segm / con finall anb rota ptom ptom2)
	(cond
		(
			(and
				(not (= intcor nil))
				(not (= segm nil))
			)
			
			(setq con 0
				finall '()
				anb
				(angle (nth 0 segm)
					(nth 2 segm)
				)
			)
			(while
				(< con (length intcor))
				(cond
					(
						(< (nth 1 segm) 0)
						(setq rota
							(angresta anb 1.5708)
						)
					)
					(
						(> (nth 1 segm) 0)
						(setq rota
							(sumang anb 1.5708)
						)
					)
				)
				(setq ptom
					(linin
						(nth con intcor)
						Rota
						(append
							(nth 0 segm)
							(nth 2 segm)
						)
					)
				)
				(setq ptom2
					(polar
						(nth con intcor)
						rota
						(distance
							(nth con intcor)
							(nth 1 ptom)
						)
					)
				)
				(cond
					(
						(equal
							(nth 1 ptom)
							ptom2
							0.001
						)
						(setq finall
							(append
								finall
								(list
									(nth con intcor)
								)
							)
						)
					)
				)
				(setq con (+ con 1))
			)
			(setq finall finall)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIN
;;OBJETO: RET0
;;	> Define las coordenadas que van de lado a lado
;;	una polilinea.
;;DEVUELVE:
;;	>((x1 y1 z1) (x2 y2 z2))
;;ARGUMENTOS
;;	1.MIPUN: Punto de inicio
;;	> (X Y Z)
;;	2.MIANG: Angulo de alineacion
;;	> En radianes
;;	3.PLIN: Polilinea de area
;;	> ENAME
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> ATENDER SI EL PUNTO SALE DE UN VERTICE DE LA POLIGONAL
(defun ret0 (mipun miang plin / seg1 con1 miscoo  lpto bugg pprob lptoang interpt)
	(setq seg1 (lscod plin '(70 10 42))
		seg1 (seg seg1 1) ;(((XY) BGL (XY)) (...)...)
		lpto '()
		con1 0
		mipun
			(list
				(nth 0 mipun)
				(nth 1 mipun)
			) ;;(X Y) *Elimina Z*
	)
	;(brkstep '("seg1") "01" "RET0")
	(while (< con1 (length seg1))
		(setq miscoo
			(append
				(nth 0 (nth con1 seg1))
				(nth 2 (nth con1 seg1))
			)
		)
		(setq bugg (nth 1 (nth con1 seg1))
			pprob (linin mipun miang miscoo)
			interpt nil
		)
		(cond
			(
				(not (equal bugg 0 0.0000001))
				(setq interpt (curin1 mipun miang () (nth con1 seg1)))
			)
			(
				(and
					(equal bugg 0 0.0000001)
					(not (= pprob nil))
				)
				(cond
					(
						(not (= (nth 0 pprob) nil))
						(setq interpt
							(append
								(list (nth 1 pprob))
							)
						)
					)
				)
			)
		)
		(cond
			(
				(not (= interpt nil))
				(setq lpto
					(append 
						lpto
						interpt
					)
				)
			)
		)
		(setq con1 (+ con1 1))
	)
	(cond
		(
			(not (= lpto nil))
			(setq lpto (lva lpto 0 0))
			(cond
				(
					(< 1 (length lpto))
					(setq lptoang
						(angle
							(nth 0 lpto)
							(nth (- (length lpto) 1) lpto)
						)
					)
					(cond
						(
							( or
								(equal
									lptoang
									1.5708
									0.0001
								)
								(equal
									lptoang
									4.71239
									0.0001
								)
							)
							(setq lpto (orden2 lpto 0 1))
						)
						(
							(= 0 0)
							(setq lpto (orden2 lpto 0 0))
						)
					)
				)
			)
		)
	)
	(setq lpto lpto)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: CUT
;;	Corta una lista sencilla según un rango inferior y
;;	un rango superior
;;DEVUELVE: Lista con los elmentos comprendidos entre el
;;	rango inferior y el rango superior
;;	(xx xx () ...)
;;ARGUMENTOS:
;;	1.AG1: Número entero, rango inferior
;;	2.AG2: Número entero, rango superior
;;	3.LLI: Lista de elementos
;;	(xx xx () ...)
;;NOTA:
;;	Los rangos se manejan igual que nth (empieza desde el 0)
;;DEPENDIENTES: NO
(defun cut (ag1 ag2 lli / pas con lli1 lli2)
  (cond
    (
     (> ag2 (length lli))
     (alert
       "El rango superior es mayor a la longitud de la lista"
     )
    )
    (
     (< ag2 (length lli))
     (setq con ag1
	   pas 0
     )
     (while (<= con ag2)
       (setq lli1 (nth con lli))
       (cond
	 (
	  (= pas 0)
	  (setq	lli2 (list lli1)
		pas  1
	  )
	 )
	 (
	  (= pas 1)
	  (setq lli2 (append lli2 (list lli1)))
	 )
       )
       (setq con (+ con 1))
     )
    )
  )
  (setq lli2 lli2)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: ISL1
;;	Insercion de un elemento en una lista
;;	sencilla de acuerdo a una posicion
;;	definida en el argumento
;;ARGUMENTOS:
;;	1. EE: xxx Elemento que se va a insertar en la lista
;;	2. TTR: Lista de trabajo, donde se insertaran el elemento
;;	3. PPO: Posicion donde se inserta el elemento
;; lo coloca a la izquierda de la posicion
;; si se omite coloca el elemento de insersion al final
;;DEPENDIENTE:
;;	CUT
(defun isl1 (ee ttr ppo / fin1 pra1 pra2)
	(cond
		(
			(= ppo nil)
			(setq fin1
				(append ttr (list ee))
			)
		)
		(
			(= 0 ppo);primero
			(setq fin1 (append (list ee) ttr))
		)
		(
			(= ppo (- (length ttr) 1)); ultimo
			(setq fin1
				(append
					(cut 0 (- ppo 1) ttr)
					(list ee)
					(list (nth (- (length ttr) 1) ttr))
				)
			)
		)
		(
			(= ppo 1);segundo
			(setq fin1
				(append
					(list (nth 0 ttr))
					(list ee)
					(cut 1 (- (length ttr) 1) ttr)
				)
			)
		)
		(
			(and
				(< 1 ppo)
				(< ppo (- (length ttr) 1))
			)
			(setq pra1 (cut 0 (- ppo 1) ttr)
				pra2 (cut ppo (- (length ttr) 1) ttr)
				fin1 (append pra1 (list ee) pra2)
			)
		)
    )
	(setq fin1 fin1)
)
;
;;
;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: AGRU1
;;	> Agrupación de una lista estructurada de acuerdo a algún elemento
;;	común en la lista (definido por su posición)
;;DEVUELVE: Misma lista agrupada
;;	> { [ ( x x x ) (...) ...] [...] ...}
;;ARGUMENTOS
;;	1. LST1 Lista de trabajo
;;	> ( (..) (..) (...) ... ))
;;	2. VVAL: Valor especifico
;;	Valor tomado para agrupar solo los elementos que coincidan en la posicion
;;	del tercer argumento
;;	NOTA: Si este argumento se omite () se agrupara con todas las variantes
;;	localizadas en la posición indicada en el tercer argumento.
;;	3. PPS1: Posición (nth) donde se encuentra el elemento para agrupar
;;	> Numero entero
;;	4. PRSC: Presicion de comparación numerica numero real
;;	Numero real
;;EJEMPLO
;;	( (1 2 3) (2 2 3) (1 W E ) (2 R R E) (5 T T) (5 W W) )
;;	pps1 = 0 / VVAL = nil
;; >( (1 2 3) (1 W E) ) ( (2 2 3) (2 R R E) ) ( (5 W W) (5 T T) )
;;	pps1 = 0 / VVAL 1
;;	( (1 2 3) (1 W E) ) ( (2 2 3) (2 R R E) (5 T T) (5 W W) )
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> 1. Si no existe coincidencia (cuando el valor especifico es definido)
;;	devuelve nil
(defun agru1
	(lst1 vval pps1 prsc /
		lind con1 elecon finl elecon0 pz agruprec
	)
	;(setq lind nil con1 nil elecon nil finl nil elecon0 nil pz nil agruprec nil)
	;(brkstep '("lst1" "vval" "pps1" "prsc" "(length lst1)") "00" "AGRU1")
	(cond
		((= prsc 1) (setq pz 0))
		((= prsc 0.1) (setq pz 1))
		((= prsc 0.01) (setq pz 2))
		((= prsc 0.001) (setq pz 3))
		((= prsc 0.0001) (setq pz 4))
		((= prsc 0.00001) (setq pz 5))
		((= prsc 0.000001) (setq pz 6))
		((= prsc 0.0000002) (setq pz 7))
		((= prsc 0.00000002) (setq pz 8))
	)
	(setq agruprec (getvar "luprec"))
	(setvar "luprec" 8)
	(setq con1 0)
	(cond
		(
			(not (= vval nil))
			(setq lind (list vval))
		)
		(
			(setq lind (lva0 lst1 (+ pps1 1) 1 pz))
		)
	)
	;(brkstep '("lind" "(length lind)" "prsc") "Lista indice" "2")
	(while
		(< con1 (length lind))
		(setq elecon
			(lnpo4
				(nth con1 lind)
				lst1
				pps1
				1
				prsc
			)
		)
		;(brkstep '("elecon" "(length elecon)") "lista coincidente" "...")
		(cond
			(
				(not (= elecon nil))
				(setq finl
					(append finl (list elecon))
				)
			)
		)
		;(brkstep '("finl") "3" "3")
		(setq
			con1 (+ con1 1)
		)
	)
	;(brkstep '("finl" "(length finl)") "04" "AGRU1")
	(cond
		(
			(and
				(not (= finl nil))
				(not (= vval nil))
			)
			(setq elecon0
				(lnpo4 vval lst1 pps1 0 prsc)
				finl
				(append finl (list elecon0))
			)
			;(brkstep '("finl" "elecon0") "05" "AGRU1")
		)
	)
	(setvar "luprec" agruprec)
	(setq finl finl)
)
;
;;
;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIN
;;OBJETO: MAT1
;;	> A partir de la lista de nombre de entidad de lineas, extrae las coordenadas
;;	id (HANDLET) para crear una lista de lineas con pendiente, ordenada al origen
;;	y coordenadas.
;;DEVUELVE: Lista de lineas agrupadas por pendientes
;;	 con las siguientes caracteristicas por linea:
;;	>1. Pendiente
;;	>2. Ordenada al origen
;;	>3. IDname (handlet)
;;	>4... (XY) INICIAL
;;	>5... (XY) FINAL
;;	>{ [ ( pend ordenada ID (xy) (xy) ) (...) ...] [ ... ] }
;;ARGUMENTOS
;;	1.LINENAME: Lista lista de nombres de entidades de lineas
;;	> (ename ename ....)
;;DEPENDIENTES
;;	> LNPO2 ()
;;	> LISCOD()
;;ANOTACIONES
;;	> Nueva version MAT10	
;;
(defun mat1 
	(lin0 /
		con1 con2 lifs li1
		mipe mior eleli indpen grpen0
		indi1 pilf pil0 npil0 pre miname micolor1 facord ordena1
		lisf1 lifsn lifs0 lifs2 con3a mimos numpos lmicolor angprec
	)
	;(setq con1 nil con2 nil lifs nil li1 nil
	;	mipe nil mior nil eleli nil indpen nil grpen0 nil
	;	indi1 nil pilf nil pil0 nil npil0 nil pre nil miname nil micolor1 nil facord nil
	;	ordena1 nil lisf1 nil lifsn nil lifs0 nil lifs2 nil con3a nil mimos nil linename nil
	;	numpos nil lmicolor nil angprec nil
	;)
	(setq linename lin0)
	;(brkstep '("linename" "(length linename)") "00" "MAT1")
	;**LINENAME (ENAME ...) Lista de nombre de entidad de lineas
	(setq mimos (getvar "osmode"))
	(setvar "osmode" 0)
	(setq pre (getvar "luprec"))
	(setq angprec (getvar "auprec"))
	(setvar "luprec" 8)
	(setvar "auprec" 8)
	(setq con1 0
		lifs nil)
	(while
		(< con1 (length linename))
		(cond
			(
				(=
					(cdr (assoc 0 (entget (nth con1 linename))))
					"LINE"
				)
				(setq li1
					(lscod
						(nth con1 linename)
						'(5 10 11)
					)
				)
				(setq miname (handent (cdr (assoc 5 li1)));;
					micolor1 (assoc 62 (entget miname));;
				);;
				;(brkstep
				;	'("li1" "(length li1)" "miname" "(nth con1 linename)")
				;	"01" "MAT1"
				;)
				;**MINAME. ENAME
				;**LI1. ((5 . "xxx") (10 #.# #.# #.#) (11 #.# #.# #.#))
				;**
				;;MICOLOR ## / NIL. COLOR DE LINEA
				(cond
					(
						(= micolor1 nil)
						(setq micolor1 '(62 . 256))
					)
				)
				(cam1 (list miname) '(62 . 3))
				;(brkstep '("li1") "02" "MAT")
				(cam1 (list miname) micolor1)
				(setq lmicolor (append lmicolor (list miname)))
				(setq
					li1
					;(append
					;	(list (cdr (nth 0 li1)))
					;	(list (roundcor (ert (nth 1 li1) '(1 2)) 8))
					;	(list (roundcor (ert (nth 2 li1) '(1 2)) 8))
					;)
					(append
						(list (cdr (nth 0 li1)))
						(list (ert (nth 1 li1) '(1 2)))
						(list (ert (nth 2 li1) '(1 2)))
					)
					facord nil
				)
				;**LI1.(ID (X1 Y1) (X2 Y2)). Elemento de linea
				;**Facord Factor de orden.
				;(brkstep
				;	'("li1"
				;		"(angle (nth 1 li1) (nth 2 li1))"
				;		"(nth 1 li1)"
				;		"(nth 2 li1)"
				;	)
				;	"03" "MAT"
				;)
				(cond
					(
						(not
							(equal
								(nth 1 li1)
								(nth 2 li1)
								0.0001
							)
						)
						(cond
							(
								(or
									(equal
										(round1
											(angle
												(nth 1 li1)
												(nth 2 li1)
											)
											8
										)
										1.5708
										0.0001
									)
									(equal
										(round1
											(angle
												(nth 1 li1)
												(nth 2 li1)
											)
											8
										)
										4.71239
										0.00001
									)
								)
								(setq mipe "nop"
									mior (nth 0 (nth 1 li1));Abscisa
								)
								;(brkstep '("mipe" "mior" "facord") "04A" "MAT1")
							)
							(
								(equal
									(nthx '(1 1) li1)
									(nthx '(2 1) li1)
									0.0001
								)
								(setq mipe 0
									mior (nthx '(1 1) li1)
								)
								;(brkstep
								;	'("mior" "mipe")
								;		"04A1" "MAT1"
								;)
							)
							(
								(= 0 0)
								(setq mipe (ppnd3 (nth 1 li1) (nth 2 li1) 7))
								(setq mipe (round1 mipe 8)) ;;;;;;;;;;;;;Redondeo
								(setq mior (ordi (nth 1 li1) mipe))
								(setq mior (round1 mior 8)) ;;;;;;;;;;;;;;;;,Redondeo
								;(brkstep '("mipe" "mior") "04B" "MAT1")
							)
						)
						(cond
							(
								(equal mipe "nop")
								(setq facord 0
									numpos 1
								)
							)
							(
								(< mipe 0)
								(setq facord 1
									numpos 0
								)
							)
							(
								(< 0 mipe)
								(setq facord 0
									numpos 0
								)
							)
							(
								(equal mipe 0 0.0001)
								(setq facord 0
									numpos 0)
							)
						)
						;** FACORD. 0.Orden de menor a mayor; 1. Orden de mayor a menor
						;** NUMPOS. 0.Posicion de elemento (X);
						;		1. Posicion de elemento (Y)
						(setq ordena1
							(orden2
								(list
									(nth 1 li1)
									(nth 2 li1)
								)
								numpos
								facord
							)
						)
						;(brkstep '("ordena1") "05" "MAT1")
						;**ORDENA1 ((XY) (XY)). Lista de coordenadas ordenadas.
						(setq eleli
							(append
								(list mipe)
								(list mior)
								(list (cdr (assoc 5 (entget (nth con1 linename)))))
								ordena1
							)
						)
						(setq lifs (append lifs (list eleli)))
						;**ELELI. (Pend Ordenada ID (X1Y1) (X2Y2))
						;**	Lista elemento.
						;**LIFS ((Pend Ordenada ID (X1Y1) (X2Y2)) (..))
					)
				)
			)
		)
		;(brkstep '("lifs" "eleli" "con1" "(length lifs)" "con1") "06" "MAT1")
		(setq con1 (+ con1 1))
	)
	(setq lifs lifs)
	;**LIFS. ((Pend Ordenada ID (X1Y1) (X2Y2)) (...)...). Lista de guias
	;(brkstep '("lifs" "(length lifs)") "07" "MAT1")
	(cond
		(
			(not (= lifs nil))
			(setq lisvar
				(lva0 lifs 1 1 3)
			)
			;(brkstep '("lifs" "(length lifs)" "lisvar" "(length lisvar)") "08" "MAT1")
			;**LIFS ((Pend Ordenada ID (X1Y1) (X2Y2)) (..)). Lista total de elementos
			;**LISVAR (Pend1 Pend2 ...) Lista de pendientes
			(setq con2 0)
			(while
				(< con2 (length lisvar))
				(setq pil0
					(lnpo4
						(nth con2 lisvar)
						lifs
						0
						1
						0.001
					)
				)
				;;**PIL0. [ (pend1 (xy) (xy)) (...) ...] misma pendiente
				;(brkstep '("pil0" "(length pil0)") "09" "MAT1")
				(setq pilf
					(append
						pilf
						(list pil0)
					)
				)
				;**PILF ( [(pend1 (xy) (xy)) (...) ...] [....] )
				;		Lista final de elementos agrupados x pendiente
				(setq con2 (+ con2 1))
			)
		)
	)
	;(brkstep
	;	'("pilf"
	;		"(length (nth 0 pilf))"
	;		"(length (nth 1 pilf))"
	;		"(length Pilf)"
	;		"(+ (length (nth 0 pilf)) (length (nth 1 pilf)))"
	;		"con2"
	;	)
	;	"10" "MAT1"
	;)
	(cam1 lmicolor micolor1)
	(setvar "osmode" mimos)
	(setvar "luprec" pre)
	(setvar "auprec" angprec)
	(setq pilf pilf)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIN
;;OBJETO: MAT4A
;;	> A partir de definicion de la lista de lineas base
;;	define las cuatro coordenadas para la definicion de la 
;;	perimetral de la matriz (en el caso de ser
;;	una reticula ortogonal
;;DEVUELVE: lista de cuatro coordenadas ordenadas
;;	pertenecientes a los cuatro vertices de la perimetral
;;	> orden: 
;;	1.- Inferior izquierdo
;;	2.- Inferior derecho
;;	3.- Superior derecho
;;	4.- Superior izquierdo
;;ARGUMENTOS
;;	1. COB: Lista de lineas base de reticula
;;	> [ ( (Pend1 Ord (XY1) (XY2)) (...) ...)
;;		( (Pend2 Ord (XY1) (XY2)) (...) ...) ]
;;2. PDIM: Dimension de los puntos de verificacion
;;	> Numero real
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Solamente para reticulas ortogonales
;;
(defun mat4a
	(cob pdim /
		gr1 gr2 con1 grt ind grc cof0 cof1 cof2 ang lxx selis
		cone c1 c2 c3 c4 c5 selis2 mimos cftxt
	)
	;(setq gr1 nil gr2 nil con1 nil grt nil ind nil grc nil cof0 nil cof1 nil cof2 nil ang nil
	;	lxx nil selis nil cone nil c1 nil c2 nil c3 nil c4 nil c5 nil selis2 nil mimos nil cftxt nil
	;)
	(setq mimos (getvar "osmode"))
	(setvar "osmode" 0)
	;(brkstep '("cob") "00" "MAT4A")
	(cond
		(
			(and
				(not (= cob nil))
				(= (type cob) 'LIST)
				(= (length cob) 2)
			)
			(cond
				(
					(= (nth 0 (nth 0 (nth 0 cob))) "nop")
					(setq gr1 (nth 0 cob)
						gr2 (nth 1 cob)
					)
				)
				(
					(= (nth 0 (nth 0 (nth 1 cob))) "nop")
					(setq gr2 (nth 0 cob)
						gr1 (nth 1 cob)
					)
				)
			)
			;(brkstep '("gr1" "gr2") "01" "MAT4A")
			(setq ind 1)
			(setq grt gr1)
			(setq ang (list 0.00000000 3.14159))
			(repeat
				2
				(setq con1 0
					grc nil
				)
				;(brkstep
				;	'(
				;		"grt"
				;		"(nth con1 grt)"
				;		"(- (length (nth con1 grt)) 3)"
				;	)
				;	"01A"
				;	"MAT4A"
				;)
				(while
					(< con1 (length grt))
					(setq grc
						(append
							grc
							(nth 1
								(org
									(nth con1 grt)
									(list
										3
										(- (length (nth con1 grt)) 3)
									)
									0
								)
							)
						)
					)
					;(brkstep
					;	'("grc" "con1" "grt")
					;	"02"
					;	"MAT4A"
					;)
					(setq con1 (+ con1 1))
				)
				;(brkstep '("grc")
				;	"03"
				;	"MAT4A"
				;)
				(setq grc
					(orden2 grc 0 ind)
				)
				;(brkstep
				;	'("grc")
				;	"04"
				;	"MAT4A"
				;)
				(setq cof0
					(append cof0
						(list
							(list
								(nth 0 grc)
								(nth 0 ang)
							)
							(list
								(nth (- (length grc) 1) grc)
								(nth 1 ang)
							)
						)
					)
					ang (list 4.71239 1.5708)
					ind 0
					grt gr2
				)
				;(brkstep
				;	'("ang" "ind" "grt" "cof0")
				;	"05"
				;	"MAT4A"
				;)
			)
			;(brkstep '("cof0")
			;	"06"
			;	"MAT4A"
			;)
			(setq lxx (list 0 3 1 2))
			(setq con1 0)
			(setq selis (ssadd))
			(while
				(< con1 (length lxx))
				(setq cf1 (nth 0 (nth (nth con1 lxx) cof0))
					cf2
					(polar cf1
						(nth 1
							(nth
								(nth con1 lxx)
								cof0
							)
						)
						1
					)
				)
				;(brkstep '("cf1" "cf2")
				;	"Definicion de puntos"
				;	"(5A) Dibujo de puntos"
				;)	
				(command "donut" 0 pdim cf1 "")
				(setq selis (ssadd (entlast) selis))
				(setq cftxt;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					(cortxt cf1)
				);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				(command "zoom" "c" cftxt "7")
				(command "donut" 0.0 pdim cf2 "")
				(setq selis (ssadd (entlast) selis))
				(setq cftxt (cortxt cf2))
				(command "zoom" "c" cftxt "7")
				(setq cof1
					(append cof1
						(list
							(list cf1 cf2)
						)
					)
					con1 (+ con1 1)
				)
				;(brkstep '("cf1" "cf2" "cof0" "cof1" "con1")
				;	"Armado de elementos de coordenadas"
				;	"(5B) Limite de while"
				;)
			)
			;(brkstep '("cf1" "cf2" "cof1" "con1")
			;"Armado de coordenadas de lineas por lado perimetral"
			;"(6) Prueba de zoom seleccion"
			;)
			(command "zoom" "o" selis "")
			;(brkstep '("selis")
			;	"Prueba superada"
			;	"Definicion de lados"
			;)
			(command "erase" selis "")
			(setq selis nil
				selis (ssadd)
				selis2 (ssadd)
				ind '((3 0) (0 1) (1 2) (2 3))
				con1 0
			)
			(while
				(< con1 (length ind))
				(setq cone (nth con1 ind)
					c1 (nth 0 (nth (nth 0 cone) cof1))
					c2 (nth 1 (nth (nth 0 cone) cof1))
				)
				(command "donut" 0.0 pdim c1 "")
				(setq selis (ssadd (entlast) selis))
				;(brkstep '("c1") "00TEMP" "MATA")
				(setq cftxt (cortxt c1))
				(command "zoom" "c" cftxt "7")
				(command "donut" 0.0 pdim c2 "")
				(setq selis (ssadd (entlast) selis))
				(setq cftxt (cortxt c2))
				(command "zoom" "c" cftxt "7")
				(setq 
					c3 (nth 0 (nth (nth 1 cone) cof1))
					c4 (nth 1 (nth (nth 1 cone) cof1))
				)
				(setq
					c1 (append c1 (list 0.0))
					c2 (append c2 (list 0.0))
					c3 (append c3 (list 0.0))
					c4 (append c4 (list 0.0))
				)
				(command "donut" 0.0 pdim c3 "")
				(setq selis (ssadd (entlast) selis))
				(setq cftxt (cortxt c3))
				(command "zoom" "c" cftxt "7")
				(command "donut" 0.0 pdim c4 "")
				(setq selis (ssadd (entlast) selis))
				(setq cftxt (cortxt c4))
				(command "zoom" "c" cftxt "7")
				;(brkstep '("c1" "c2" "c3" "c4" "(inters c1 c2 c3 c4)")
				;	"interseccion?" "6B"
				;)
				(setq c5 (inters c1 c2 c3 c4 nil))
				(cond
					(
						(not (= c5 nil))
						(setq c5 (ert c5 '(0 1)))
					)
				)
				(setq cof2 (append cof2 (list c5)))
				;(brkstep '("c1" "c2" "c3" "c4" "c5" "cof2")
				;	"coordenadas de interseccion"
				;	"(7) Prueba de zoom"
				;)
				(command "zoom" "o" selis "")
				(command "donut" 0.0 pdim c5 "")
				(setq selis2 (ssadd (entlast) selis2))
				(setq cftxt (cortxt c5))
				(command "zoom" "c" cftxt "7")
				(cam1 (noment selis2) (cons 62 1))
				(setq con1 (+ con1 1))
			)
			(command "zoom" "o" selis2 "")
			;(brkstep '("cof2")
			;	"coordenadas de interseccion"
			;	"(8)"
			;)
			(command "erase" selis2 "")
			(command "erase" selis "")
		)
	)
	(setvar "osmode" mimos)
	(setq cof2 cof2)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: LIN
;;OBJETO: MAT4B
;;	> A partir de definicion de la lista de lineas base
;;	define las cuatro coordenadas para la definicion de la 
;;	perimetral de la matriz (en el caso de ser
;;	una reticula con inclinacion)
;;DEVUELVE: lista de cuatro coordenadas ordenadas
;;	pertenecientes a los cuatro vertices de la perimetral
;;	> orden: 
;;	1.- Inferior izquierdo
;;	2.- Inferior derecho
;;	3.- Superior derecho
;;	4.- Superior izquierdo
;;ARGUMENTOS
;;	1. COB: Lista de lineas base de reticula
;;	> [ ( (Pend1 Ord (XY1) (XY2)) (...) ...)
;;		( (Pend2 Ord (XY1) (XY2)) (...) ...) ]
;;2. PDIM: Dimension de los puntos de verificacion
;;	> Numero real
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Solamente para reticulas inclinadas
;;
(defun mat4b
	(cob pdim /
		gr1 gr2 grt
		con1
		pinv
		cord0 cord1 cord2
		pase
		pord1 pord2
		lld lld1 lld2 lld3 lld4
		selec selec1 selec2 selec3
		lv lv1 lv2 lv3 lv4
		clor
		grc1 grc2
		cols
		cortx
	)
	;(brkstep '("cob") "MAT4B: Entrada" "0")
	(cond
		(
			(and
				(not (= cob nil))
				(= (type cob) 'LIST)
				(= (length cob) 2)
			)
			(cond
				(
					(< 0 (nth 0 (nth 0 (nth 0 cob))))
					(setq gr1 (nth 0 cob)
						gr2 (nth 1 cob)
					)
				)
				(
					(< 0 (nth 0 (nth 0 (nth 1 cob))))
					(setq gr2 (nth 0 cob)
						gr1 (nth 1 cob)
					)
				)
			)
			(setq gr1 (orden2 gr1 0 1)
				gr2 (orden2 gr2 0 1)
				grom1 (nth 0 gr1)
				grox1 (nth (- (length gr1) 1) gr1)
				grom2 (nth 0 gr2)
				grox2 (nth (- (length  gr2) 1) gr2)
			)
			(setq grt gr1
				pinv (nth 0 (nth 0 gr2))
				pase 0
				selec (ssadd)
				clor 3
			)
			;(brkstep '("gr1" "gr2" "grt" "pinv" "grom1" " grox1" "grom2" "grox2" "clor")
			;	"Grupos Pendientes"
			;	"(1)"
			;)
			(repeat 2
				(setq con1 0)
				(setq grc1 nil
					grc2 nil
				)
				(while
					(< con1 (length grt))
					(setq cord0
						(org
							(nth con1 grt)
							(list 3
								(- (length (nth con1 grt)) 3)
							)
							0
						)
						cord0 (nth 1 cord0)
						cord0 (orden2 cord0 0 0)
					)
					;(brkstep '("grt" "con1" "cord0");;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;	"Par de coordenadas"
					;	"2"
					;)
					(setq cord1 (nth 0 cord0))
					(command "donut" 0.0 pdim cord1 "")
					(setq selec (ssadd (entlast) selec))
					(setq cortx
						(strcat
							(rtos (nth 0 cord1))
							","
							(rtos (nth 1 cord1))
						)
					)
					;(brkstep '("cortx") "TEMP01" "TEMP01")
					(command "zoom" "c" cortx "7")
					(setq cord2 (nth 1 cord0))
					(command "donut" 0.0 pdim cord2 "")
					(setq selec (ssadd (entlast) selec))
					(setq cortx
						(strcat
							(rtos (nth 0 cord2))
							","
							(rtos (nth 1 cord2))
						)
					)
					(command "zoom" "c" cortx "7")
					(setq pord1 (ordi cord1 pinv)
						grc1 (append grc1 (list (list pord1 cord1)))
						pord2 (ordi cord2 pinv)
						grc2 (append grc2 (list (list pord2 cord2)))
					)
					(setq con1 (+ con1 1))
					;(brkstep '("cord1" "cord2" "pord1" "pord2" "grc1" "grc2" "con1")
					;	"MAT4B: Par de coordenadas"
					;	"(3)"
					;)
				)
				(command "zoom" "o" selec "")
				(setq cols (noment selec))
				;(brkstep '("grc1" "grc2" "con1" "cols" "clor")
				;	"MATT4B: (3A)" "(3A)"
				;)
				(cam1 cols (cons 62 clor))
				(setq grc1 (orden2 grc1 0 0)
					grc2 (orden2 grc2 0 0)
				)
				;(brkstep '("grc1" "grc2" "pase") "MAT4B: Par de coordenadas" "(4)")
				(cond
					(
						(= pase 0)
						(setq pase 1)
						(cond
							(
								(<= (nth 1 grom2) (nth 0 (nth 0 grc1)))
								(setq lld1
									(nth 1
										(org grom2
											(list 3 (- (length grom2) 3))
											0
										)
									)
								)
							)
							(
								(> (nth 1 grom2) (nth 0 (nth 0 grc1)))
								(setq lld1
									(list
										(list 0.0 (nth 0 (nth 0 grc1)))
										(nth 1 (nth 0 grc1))
									)
								)
							)
						)
						;(brkstep 
						;	'("lld1"
						;		"grox2"
						;		"(nth 0 (nth (- (length grc2) 1) grc2))"
						;	) "LADO1" "4a1"
						;)
						(cond
							(
								(>= (nth 1 grox2) (nth 0 (nth (- (length grc2) 1) grc2)))
								(setq lld3
									(nth 1
										(org grox2
											(list 3 (- (length grox2) 3))
											0
										)
									)
								)
							)
							(
								(< (nth 1 grox2) (nth 0 (nth (- (length grc2) 1) grc2)))
								(setq lld3
									(list
										(list 0.0
											(nth 0
												(nth (- (length grc2) 1) grc2)
											)
										)
										(nth 1 (nth (- (length grc2) 1) grc2))
									)
								)
							)
						)
						;(brkstep '("lld3") "LADO3" "4a2")
						(setq grt gr2)
						(setq pinv (nth 0 (nth 0 gr1)))
						(setq selec1 selec
							selec nil
							selec (ssadd)
							clor 2
						)
					)
					(
						(= pase 1)
						;(brkstep '("grom1" "grc2" "grox1") "4b0" "4b0")
						(cond
							(
								(<= (nth 1 grom1) (nth 0 (nth 0 grc2)))
								(setq lld2
									(nth 1
										(org grom1
											(list 3 (- (length grom1) 3))
											0
										);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									)
								)
							)
							(
								(> (nth 1 grom1) (nth 0 (nth 0 grc2)))
								(setq
									lld2
									(list
										(list 0.0 (nth 0 (nth 0 grc2)))
										(nth 1 (nth 0 grc2))
									)
								)
							)
						)
						;(brkstep '("lld2") "LADO2" "4b1")
						(cond
							(
								(>= (nth 1 grox1) (nth 0 (nth (- (length grc1) 1) grc1)))
								(setq lld4
									(nth 1
										(org grox1 (list 3 (- (length grox1) 3)) 0)
									)
								)
							)
							(
								(< (nth 1 grox1) (nth 0 (nth (- (length grc1) 1) grc1)))
								(setq lld4
									(list
										(list 0.0
											(nth 0 (nth (- (length grc1) 1) grc1))
										)
										(nth 1 (nth (- (length grc1) 1) grc1))
									)
								)
							)
						)
						;(brkstep '("lld4") "LADO4" "4b2")
						(setq selec2 selec
							selec nil
							selec (ssadd)
							clor 1
						)
					)
				)
				;(brkstep '("grt" "pinv" "pase" "lld1" "lld2" "lld3" "lld4")
				;	"(5)" "(5)"
				;)
			)
			(setq lld (list lld1 lld2 lld3 lld4))
			;(brkstep '("lld")
			;	"(6)" "(6)"
			;)
			(setq selec3 (ssadd))
			(setq lv1
				(inters
					(nth 0 lld1)
					(nth 1 lld1)
					(nth 0 lld4)
					(nth 1 lld4)
					nil
				)
			)
			;(brkstep '("lv1") "00TEMP" "00TEMP")
			(command "donut" 0.0 pdim lv1 "")
			(setq selec3 (ssadd (entlast) selec3))
			(setq cortx
				(strcat
					(rtos (nth 0 lv1))
					","
					(rtos (nth 1 lv1))
				)
			)
			(command "zoom" "c" cortx "7")
			(setq lv2
				(inters
					(nth 0 lld1)
					(nth 1 lld1)
					(nth 0 lld2)
					(nth 1 lld2)
					nil
				)
			)
			(command "donut" 0.0 pdim lv2 "")
			(setq selec3 (ssadd (entlast) selec3))
			(setq cortx
				(strcat
					(rtos (nth 0 lv2))
					","
					(rtos (nth 1 lv2))
				)
			)
			(command "zoom" "c" cortx "7")
			(setq lv3
				(inters
					(nth 0 lld3)
					(nth 1 lld3)
					(nth 0 lld2)
					(nth 1 lld2)
					nil
				)
			)
			(command "donut" 0.0 pdim lv3 "")
			(setq selec3 (ssadd (entlast) selec3))
			(setq cortx
				(strcat
					(rtos (nth 0 lv3))
					","
					(rtos (nth 1 lv3))
				)
			)
			(command "zoom" "c" cortx "7")
			(setq lv4
				(inters
					(nth 0 lld3)
					(nth 1 lld3)
					(nth 0 lld4)
					(nth 1 lld4)
					nil
				)
			)
			(command "donut" 0.0 pdim lv4 "")
			(setq selec3 (ssadd (entlast) selec3))
			(setq cortx
				(strcat
					(rtos (nth 0 lv4))
					","
					(rtos (nth 1 lv4))
				)
			)
			;(brkstep '("selec3" "(noment selec3)") "01TEMP" "01TEMP")
			(command "zoom" "c" cortx "7")
			(command "zoom" "o" selec3 "");;;;
			(cam1 (noment selec3) (cons 62 clor))
			;(brkstep '("selec3" "selec2" "selec3") "02TEMP" "02TEMP")
			(command "erase" selec1 "") 
			(command "erase" selec2 "")
			(command "erase" selec3 "");;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;(brkstep '("lv1" "lv2" "lv3" "lv4") "(7)" "(7)")
			(setq lv (list lv1 lv2 lv3 lv4))
			(setq lv lv)
		)
	)
)
;;PROYECTO: LISP
;;CLASIFICACION: LIST
;;OBJETO: NTHZ
;;	> Aplica nthx a una lista estructurada
;;DEVUELVE: datos extraidos segun la lista de contadores por elemento
;;	> (x x ...)
;;ARGUMENTOS
;;	1.LISIC: Lista de contadores de extraccion por cada elemento
;;	> (# # # ...)
;;	2. LITR: Lista estrucurada de trabajo
;; > 
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Realiza la extraccion de general a particular o de afuera a dentro
;;
(defun nthz (lisic litr / con1 finl fin1 lisic1)
	;(brkstep '("lisic" "litr") "Entrada" "0")
	(setq con1 0)
	(while
		(< con1 (length litr))
		(setq lisic1
			(append (list con1)
				lisic
			)
		)
		(setq fin1
			(nthx lisic1 litr)
		)
		;(brkstep '("fin1") "1" "1")
		(setq finl
			(append finl
				(list fin1)
			)
		)
		;(brkstep '("finl") "2" "2")
		(setq con1 (+ con1 1))
		(setq finl finl)
	)
)
;
;;
;;;
;;;;;
;;PROYECTO: Lisp
;;CLASIFICACION: SL
;;OBJETO: SENAME
;;	>A partir de lista de nombre
;;	de entidades o lista de handlet, devuelve una seleccion
;;	con las entidades
;;DEVUELVE: Seleccion de entidades
;;	> SelectionSet
;;ARGUMENTOS
;;	1.LLSNAM: Lista de nombre de entidades o lista de handlet
;;	> (ename ename ...) o (handlet handlet ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
(defun sename (llsnam / con1 mill eliza)
	;(brkstep '("llsnam") "Entrada" "0")
	(cond
		(
			(= (type (nth 0 llsnam)) 'STR)
			(setq mill (lb217 llsnam)
				mill (nthz (list 1) mill)
			)
			;(brkstep '("mill") "1a" "1a") 
		)
		(
			(= (type (nth 0 llsnam)) 'ENAME)
			(setq mill llsnam)
			;(brkstep '("mill") "1b" "1b")
		)
	)
	(setq con1 0
		eliza (ssadd)
	)
	(while (< con1 (length mill))
		(setq eliza (ssadd (nth con1 mill) eliza)
			con1 (+ con1 1)
		)
	)
	;(brkstep '("(sslength eliza)") "2" "2")
	(setq eliza eliza)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:POL
;;OBJETO: InPto0. Modifica una polilinea
;;		a partir de la definicion de una lista de
;;		nuevas coordenadas
;;	> 
;;DEVUELVE: Lista nueva de entidada
;;	>inFn1 ((odigo . Valor) (codigo . Valor) ...)
;;ARGUMENTOS
;;	1.inInd0. Indice de insercion de nuevos
;;		puntos
;;	> 0. Los puntos se insertan antes de
;;		la posicion NTH (lista de coordenadas)
;;		de la polilinea.
;;	> 1. Los puntos se insertan despues de
;;		la posicion NTH (lista de coordenadas)
;;		de la polilinea
;;	> 2. Los puntos sustituyen la coordenada
;;		que corresponde a la posicion NTH (lista
;;		de coordenadas) de la polilinea
;;	2. inEnti0. Nombre de entidad de la
;;		polilinea
;;	> ENAME
;;	3. inPosi0. Numero de posicion NTH (lista
;;	de coordenadas) de la coordenada vertice donde se van
;;	localizar los nuevos puntos de inserción
;;	4. inPrec0. Numero de precision
;;	5. inLsIns0. Lista de coordenadas de insercion
;;	>	((XYZ) (XYZ) ...)
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	> Se considera que la polilinea es abierta
;;	> Se considera que la polilinea esta
;;		formada por rectas
;;	>Codigos de polilinea 10, 40, 41, 42, 91
;;;(brkstep '("") "001TEMP" "")
(defun InPto0
	(inInd0 inEnti0 inPosi0 inPrec0  inLsIns0 /
		inInd inEnti inPosi inPrec inLsIns inLsCoo inCoo
		inPosIns inFnEnti inCon0 inLsIns1 inLsNw
		inLsPs0 inLsPs1 inLsPsCon0 inLsPsCon1
		inRep0 inRep1 inPrecDec inNmVrtz0 inNmVrtz1
	)
	;(setq inInd nil inEnti nil inPosi nil
	;	inPrec nil inLsIns nil inLsCoo nil
	;	inCoo nil inPosIns nil inFnEnti nil
	;	inCon0 nil inLsIns1 nil inLsNw nil
	;	inLsPs0 nil inLsPs1 nil inLsPsCon0 nil
	;	inLsPsCon1 nil inRep0 nil inRep1 nil
	;	inPrecDec nil inNmVrtz0 nil inNmVrtz1 nil
	;)
	;(brkstep1
	;	'("inInd0" "inEnti0" "inPosi0" "inPrec0" "inLsIns0")
	;	(list inInd0 inEnti0 inPosi0 inPrec0 inLsIns0)
	;	"00" "InPto0"
	;)
	(cond
		(
			(and
				(= (type inInd0) 'INT)
				(= (type inEnti0) 'ENAME)
				(= (type inPosi0) 'INT)
				(= (type inPrec0)'INT)
				(= (type inLsIns0) 'LIST)
			)
			(setq inInd inInd0
				inEnti inEnti0
				inPosi inPosi0
				inPrec inPrec0
				inLsIns inLsIns0
			)
			;(brkstep1'("inInd") (list inInd) "011" "InPto0")
			;;;;;;;;;;
			(cond
				(
					(= inPrec nil)
					(setq inPrecDec 0.0015)
				)
				(
					(< 0 inPrec)
					(setq inPrecDec
					(expt 10.0 (* -1 inPrec))
					)
				)
				(
					(= inPrec 0)
					(setq inPrecDec 0.15)
				)
			)
			;(brkstep1 '("inPrecDec")(list inPrecDec) "01aa"  "InPto")
			;;;;;;;;;;
			(setq inLsEnti (entget inEnti)
				inCon0 0
			)
			;(brkstep1 '("inEnti" "inPosi" "inPrec" "inLsIns" "inLsEnti" "inCon0" "inPrecDec")
			;	(list inEnti inPosi inPrec inLsIns inLsEnti InCon0 inPrecDec)
			;	"01a" "InPto0"
			;)
			(while
				(< inCon0 (length inLsIns))
				(setq inLsIns1
					(append inLsIns1
						(list
							(append
								(list 10)
								(nth inCon0 inLsIns)
							)
							(cons 40 0.0)
							(cons 41 0.0)
							(cons 42 0.0)
							(cons 91 0)
						)
					)
				)
				(setq inCon0 (+ inCon0 1))
			)
			;(brkstep1 '("inLsIns1" "inLsEnti") (list inLsIns1 inLsEnti) "01" "InPto")
			;inLsEnti. Lista de entidad de la polilinea
			;> ((cod.val)...)
			;inLsIns1. Lista de codigos de nuevas coordenadas de insercion
			;> ((10 X Y Z) (40 . 0) (42 . 0) (91 . 0) ...)
			(setq inPosIns
				(qnth
					inLsEnti
					(nth
						inPosi
						(lscod inEnti '(10))
					)
					inPrecDec
				)
			)
			;(brkstep1 '("inPosIns") (list inPosIns) "02" "InPto")
			;inPosIns. Numero (nth) de posicion
			;que ocupa
			;<Entero>
			(cond
				(
					(not (= inPosIns nil))
					(setq inPosIns (nth 0 inPosIns))
					(cond
						(
							(= inInd 0)
							(setq inLsPsCon0 0
								inLsPsCon1 inPosIns
								inRep0 inPosIns
								InRep1
								(- (length inLsEnti) inPosIns)
							)
							;(brkstep1
							;	'("inLsPsCon0" "inLsPsCon1"
							;		"inRep0" "inRep1"
							;	)
							;	(list inPsCon0 inLsPsCon1
							;		inRep0 inRep1
							;	)
							;	"03" "InPto0"
							;)
						)
						(
							(= inInd 1)
							(setq inLsPsCon0 0
								inLsPsCon1 (+ inPosIns 5)
								inRep0 (+ inPosIns 5)
								inRep1
								(-
									(length inLsEnti)
									(+ inPosIns 5)
								)
							)
						)
						(
							(= inInd 2)
							(setq inLsPsCon0 0
								inLsPsCon1 (+ inPosIns 5)
								inRep0 inPosIns
								inRep1
								(- (length inLsEnti)
									(+ inPosIns 5)
								)
							)
						)
					)
					;(brkstep1
					;	'("inLsPsCon0" "inLsPsCon1"
					;		"inRep0" "inRep1"
					;	)
					;	(list inLsPsCon0
					;		inLsPsCon1
					;		inRep0
					;		inRep1
					;	)
					;	"04" "InPto0"
					;)
					(repeat
						inRep0
						(setq inLsPs0
							(append inLsPs0
								(list inLsPsCon0)
							)
						)
						(setq inLsPsCon0
							(+ inLsPsCon0 1)
						)
					)
					;(brkstep1 '("inLsPs0") (list inLsPs0) "05a" "InPto0")
					(repeat
						inRep1
						(setq inLsPs1
							(append inLsPs1
								(list inLsPsCon1)
							)
						)
						(setq inLsPsCon1
							(+ inLsPsCon1 1)
						)
					)
					;(brkstep1 '("inLsPs1" "inLsIns1" "inLsPs0")
					;	(list inLsPs1 inLsIns1 inLsPs0)
					;	"05" "InPto0"
					;)
					(setq inLsNw
						(append (ert inLsEnti inLsPs0) inLsIns1 (ert inLsEnti inLsPs1))
						inNmVrtz0 (assoc 90 inLsEnti)
						inNmVrtz1 (cons 90 (+ (cdr inNmVrtz0) (- (length inLsIns) 2))) 
					)
					;(brkstep1 '("inNmVrtz0" "inNmVrtz1") (list inNmVrtz0 inNmVrtz1)
					;	"05a0" "InPto"
					;)
					(setq inLsNw (subst inNmVrtz1 inNmVrtz0 inLsNw))
					;(brkstep1 '("primero")(list (ert inLsEnti InLsPs0)) "05a" "InPto0")
					;(brkstep1 '("segundo") (list inLsIns1) "05b" "InPto0")
					;(brkstep1 '("tercero") (list (ert inLsEnti inLsPs1)) "05c" "InPto0")
					;(brkstep1 '("inLsNw") (list inLsNw) "06" "InPto0")
					(entmod inLsNw)
					(entupd inEnti)
				)
			)
		)
	)
)
;
;;
;;;
;;;;
;;PROYECTO: CI
;;CLASIFICACION: Main
;;OBJETO: inFlex
;;	> Inserta todos los  puntos  de inflexion de una poilinea
;;DEVUELVE:
;;	> inLsFn. Lista de nombre de entidades de los bloques de puntos
;;	de inflexion de la polilinea
;;ARGUMENTOS
;;	1.Metodo.
;;>	a:Seleccion de perfil
;;>	b:seleccion de escala
;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>Nombre de la aplicación: AZ-CIVIL
;;	>Nombre de atributo: ID_POL
;;	>Nombre del bloque: pto-inf
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:inflex
	( /
		inEnti inLsFn
	)
	(setq inEnti
		(car (entsel "SELECCIONE EL PERFIL: "))
	)
	(cond
		(
			(not (= inEnti nil))
			(setq anSc
				(getreal
					"INDIQUE LA ESCALA DEL BLOQUE: "
				)
			)
			;(brkstep1
			;	'("anSc" "inEnti")
			;	(list anSc inEnti)
			;	"01" "inflex"
			;)
;			(setq inLsFn
;				(anFlex inEnti 3 0.0 anSc)
;			)
			(anFlex inEnti 3 0.0 anSc)
		)
	)
	(textpage)
	(graphscr)
;	(setq inLsFn inLsFn)
)
;
;;
;;;
;;;;
;;PROYECTO: Lisp
;;CLASIFICACION:PH
;;FUNCION / TITULO:
;;<<
;;	DefR01. Interface Devuelve lista de
;;	rutas seleccionadas por el usuario
;;>>
;;SINTAXIS:
;;<(DefR01 [listaMetodo])>
;;DESCRIPCION:
;;<<
;;	DefR01. Apartir de la definicion de la lista de cracteristicas
;;	para la definicion de rutas llamada
;;	"Lista de Metodo" devuelve una lista de rutas definidas por
;;	el usuario.
;;>>
;;DEVUELVE:
;;<<
;;	ruf. Lista de rutas definidas por
;;	el usuario.
;;	<((IdRuta RutaCompleta) (...)...) >
;;	Estructura de la lista final
;;	1. ID de ruta
;;	2. Ruta y nombre (en su caso)
;;>>
;;ARGUMENTOS:
;;<<
;;	1. defLs0. Lista Metodo para la definicion
;;	de rutas por el usuario.
;;	(
;;		([Tipo "C"Carpeta/"A"Archivo]
;;		[Mensaje de solicitud]
;;		[IdRuta] [NomArch] [NomExt]
;;		)
;;		(...) ...
;;	)
;;	Estructura de cada elemento de la lista:
;;	1. Tipo de ruta ("C" para carpeta, "A" para archivo)
;;	2. Mensaje de solicitud
;;	3. ID de ruta
;;	4. Nombre de archivo (0 para carpetas)
;;	5. Extension         (0 para carpetas)
;;>>
;;DEPENDIENTES
;;<Brkstep1 sepa sutx>
;;LOCALIZACION
;;	<FOO II >
;;HISTORIAL DE CORRECCIONES
;;<<
;;	>2022.01.22. Arreglo para cancelar rutas
;;	>2022.06.09 Cambio de nombre de Defr1 a Defr01 para conservar
;;	la version anterior.
;;>>
;;ANOTACIONES
;;<<
;;	> En la definición de extension no se agregan ".", solo la extension
;;	> Definir el mensaje de solicitud completo
;;	> La division de carpetas es "\\"
;;	> En ruta de tipo carpeta termina con "\\"
;;	> Version basada en Defr1
;;>>
;; ESTADO:
;; >Actualizado
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun DefR01
	(defLs0 /
		defLs
		cn ps miru msj tipr extr nomr ruf idr defTerm defPar
	)
;	(setq defLs nil
;		cn nil ps nil miru nil msj nil
;		tipr nil extr nil nomr nil
;		ruf nil idr nil defTerm nil defPar nil
;	)
	;;br
;	(brkstep1 '("defLs0") (list defLs0)
;		"00" "DefR01"
;	)
	;;br..
	(cond
		(
			(= (type defLs0) 'LIST)
			(setq defLs defLs0)
			(setq cn 0
				ps 0
			)
			;;br
;			(brkstep1 '("defLs" "cn" "ps")
;				(list defLs cn ps)
;				"01" "DefR01"
;			)
			;;br..
		;;defLs:..Lista de Metodo
		;:..<((c/a msj id nom ext)...)>
			(while (< cn (length defLs))
				(setq defPar (nth cn defLs)
					msj (nth 1 defPar)
					tipr (strcase (nth 0 defPar))
					idr (nth 2 defPar)
					miru nil
				)
				;;br
				;(brkstep1
				;	'("defPar" "msj" "tipr" "idr")
				;	(list defPar msj tipr idr)
				;	"02" "DefR01"
				;)
				;;br..
				;;miru:.Lista de argumentos de
				;definicion <(c/a msj id nom ext)>
				;msj:.Mensaje de solicitud <"...">
				;tipr:.Tipo de ruta <"A"/"C">
				;idr:.Identificador de ruta <"...">
				(cond
					(
						(= tipr "C")
						(setq nomr idr
							extr " "
							miru (getfiled msj nomr extr 3)
						)
						;;br
						;(brkstep1
						;	'("nomr" "idr" "extr" "miru") (list nomr idr extr miru)
						;	"02A:DefR01" "02A"
						;)
						;;br..
						(cond
							(
								(not (= miru nil))
								(setq miru (sutx miru (list (list "/" "\\")))
									miru (nth 0 (sepa miru "\\"))
									defTerm (substr miru (strlen miru) 1)
								)
								;;br
								;(brkstep1 '("miru" "defTerm") (list miru defTerm)
								;	"02B:DefR01" "DefR01"
								;)
								;;br..
								;(setq miru (vl-directory-files miru))
								;(vl-filename-directory
								;(getfiled msj nomr extr 3)
								;)
								(cond
									(
										(not (= defTerm "\\"))
										(setq miru (strcat miru "\\"))
									)
								)
								;;br
								;(brkstep1 '("miru") (list miru) "02C:DefR01" "02C")
								;;br..
							)
						)	
					);..tipr=C
					(
						(= tipr "A")
						(setq nomr (nth 3 defPar)
							extr (nth 4 defPar)
							miru
							(getfiled msj nomr extr 3)
						)
						;;br
						;(brkstep1
						;	'("nomr" "extr" "miru")
						;	(list nomr extr miru)
						;	"DefR01:03" "03"
						;)
						;;br..
						(cond
							(
								(not (= miru nil))
								(setq miru (sutx miru '(("/" "\\"))))
							)
						)
					);..tipr=A
				);..cond tipo
				;nomr:.Ruta definida por usuario
				;;br
				;(brkstep1 '("miru") (list miru) "DefR01:04" "04")
				;;br..
				(cond
					(
;						(= (type nomr) 'STR)
						(not (= miru nil))
						(setq ruf
							(append ruf
								(list (list idr miru))
							)
						)
						;;br
						;(brkstep1 '("ruf") (list ruf)
						;	"DefR01:05" "05"
						;)
						;;br..
						;;ruf:. Lista final de rutas
						;:.((id ruta)(...)...)
					);..nomr=str
				);..cond
				(setq cn (+ cn 1))
			);..while
		);..Condicion tipo de entrada
	);:..
	;;br
	;(brkstep1 '("ruf") (list ruf) "06:DefR01" "06")
	;;br..
	(setq ruf ruf)
);:.DefR01..
;
;;
;;;
;;;;
;;PROYECTO:
;;<Lisp>
;;CLASIFICACION:
;;<TXT>
;;FUNCION / TITULO:
;;<MATCHTX.Verifica una subcadena dentro de otra>
;;SINTAXIS:
;;<(MATCHTX [SeccionTxt][CadenaCompleta][ModoBusqueda])>
;;DESCRIPCION:
;;<<
;;	A partir de la definicion de una seccion de texto y una cadena
;;	analiza si la seccion se encuentra dentro de la cadena
;;>>
;;EJEMPLO
;;<<
;;(setq pf2tx "Vendeme"
;;	pf2Cad "vendeme  esta pluma Vendeme"
;;	pf2Res (MatchTx pf2Tx pf2Cad 1)
;;)
;;<<
;;DEVUELVE:
;;<<
;;	maRes. T si la seccion de texto
;;	esta dentro de la cadena
;;	nil si la seccion de texto
;;	no se encuentra dentro de la cadena
;;>>
;;ARGUMENTOS
;;>>
;;1.matx0 fragmento de texto :.String.:
;;2.maCad0.Cadena de donde se busca el fragmento :.String..
;;3.maMd0.Modo de busqueda:
;;	0:Busqueda mayusculas y minuscula (como se escribio) :.INT.:
;;	1:Sin considerar mayusculas o minusculas
;;>>
;;DEPENDIENTES
;;<brkstep1>
;;LOCALIZACION
;;<Dropbox ... FuncionesLisp
;;HISTORIAL DE CORRECCIONES
;;<<
;;	22/06/02. Creado y Registrado
;;>>
;;ANOTACIONES
;;	>
;;ESTADO
;;<Terminado>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun MatchTx
	(maTx0 maCad0 maMd0 /
		maTx maCad maMd
		maCon1 maCon2
	)
;	(setq maTx nil maCad nil maMd nil
;		maCon1 nil maCon2 nil
;	)
	;br
;	(brkstep1
;		'("maTx0" "maCad0" "maMd0")
;		(list maTx0 maCad0 maMd0)
;		"MatchTx:00" "00"
;	)
	;br..
	(cond
		(;condType
			(and
				(= (type maTx0) 'STR)
				(= (type maCad0) 'STR)
				(= (type maMd0) 'INT)
			)
			(setq
				maTx maTx0
				maCad maCad0
				maMd maMd0
			)
			;br
;			(brkstep1
;				'("maTx" "maCad" "maMd")
;				(list maTx maCad maMd)
;				"MatchTx:01" "01"
;			)
			;br..
			(setq maCon1 1
				maCon2 1
			)
			(while
				(and
					(<= maCon1 (strlen maTx))
					(<= maCon2 (strlen maCad))
				)
				;br
;				(brkstep1
;					'("maCon1" "maCon2")
;					(list maCon1 maCon2)
;					"MatchTx:02" "02"
;				)
				;br..
				(setq maTx0 (substr maTx maCon1 1)
					maCad0 (substr maCad maCon2 1)
				)
				(if
					(= maMd 1)
					(progn
						(setq maTx0 (strcase maTx0)
							maCad0 (strcase maCad0)
						)
					)
				)
				;br
;				(brkstep1
;					'("maTx0" "maCad0")
;					(list maTx0 maCad0)
;					"MatchTx:02" "02"
;				)
				;br..
				(cond
					(
						(= maCad0 maTx0 )
						(setq maCon1 (+ maCon1 1))
						(setq maCon2 (+ maCon2 1))
					)
					(
						(not (= maTx0 maCad0))
						(setq maCon1 1
							maCon2 (+ maCon2 1)
						)
					)
				)
				;br
;				(brkstep1
;					'("maCon1" "maCon2")
;					(list maCon1 maCon2)
;					"MatchTx:03" "03"
;				)
				;br..
			);while
			(cond
				(
					(= maCon1 (+ (strlen maTx) 1))
					(setq maRes T)
				)
				(
					(not (= maCon1 (strlen maTx)))
					(setq maRes nil)
				)
			);cond..
		);condType..
	);cond..
);defun..
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO / TITULO:
;;	><< EXL. Convierte un elemento no. X de una lista tipo DAT
;; en un elemento de lista estructurada.
;;	>>
;;SINTAXIS:
;;	> (EXL [Lista] [NoElemento] [Modo Conversion Numerica])
;;DESCRIPCION:
;;	><< EXL. Convierte un elemento no. X de una lista tipo DAT 
;; ("xx,xx,xx" "..." ...)
;; en un elemento de lista estructurada
;; (xxx xxx xxx)
;;	>>
;;DEVUELVE:
;;	><< ltf. Lista de elementos
;; separados extraídos de la lista de datos
;; tipo DAT ("xx,xx,..." "..." ...)
;; seleccionada por el argumento 
;; de ubicacion (xxx xxxx ....)
;;	>>
;;ARGUMENTOS:
;;	><<<
;;	1.ls0:. Lista de trabajo
;;		<("xxx,..." "..." ...)>
;;		<((xx,...)(...)...)>
;;	2.con0:. Número de posición de la lista
;;		< Int >
;;	3.an0:. Modo de extracción numérica
;;		0:. String
;;		1:. Entero
;;		2:. Decimal
;;	>>
;;DEPENDIENTES
;;	< >
;;LOCALIZACION
;;	<>
;;HISTORIAL DE CORRECCIONES
;;	><<
;;	29/03/2022. Ajuste de lista, admite lista sencilla
;;	y estructurada
;;	<<
;;	<21/05/2022. Aclaracion de argumento: Modo numerico (0 = String)>
;;
;;ANOTACIONES
;;	>
;
;;ESTADO
;;	> Probado
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun exl
	(ls00 con0 an0 /
		ls0 con an
		long ls lt ltf pas lian lydum
		pas2 conta ltw
	)
;	(setq ls0 nil con nil an nil
;		long nil ls nil lt nil ltf nil
;		pas nil lian nil lydum nil
;		pas2 nil conta nil ltw nil
;	)
	;;br
;	(brkstep1 '("ls00" "con0" "an0")
;		(list ls00 con0 an0)
;		"00:EXL" "EXL"
;	)
	;;br..
	(cond
		(
			(and
				(= (type ls00) 'LIST)
				(= (type con0) 'INT)
			)
			(setq ls0 ls00
				an an0
				con con0
			)
			;;br
;			(brkstep1 '("ls0" "an" "con")
;				(list ls0 an con)
;				"EXL:01" "EXL"
;			)
			;;br..
			(setq pas2 0)
			(cond
				(
					(= (lsType ls0) 'LIST)
					(setq ls0 (bindls ls0))
				)
			)
			;;br
;			(brkstep1 '("ls0") (list ls0) "EXL:01A" "EXL")
			;;br..
			(cond
				(
					(<= con 0)
					(alert "EL INDICE DEBE SER MAYOR A 0")
				)
				(
					(< (length ls0) con)
					(alert "EL CONTADOR ESTA FUERA DE RANGO")
				)
				(
					(and
						(< 0 con)
						(<= con (length ls0))
					)
					(setq pas2 1)
				)
			);
			;;br
;			(brkstep1 '("pas2" "con")
;				(list pas2 con)
;				"EXL:02" "EXL"
;			)
			;;br..
			(cond
				(
					(= pas2 1)
					(setq
						ls (nth (- con 1) ls0)
						pas 0
						conta 1
						long (strlen ls)
					)
					;;br
;					(brkstep1
;						'("long" "pas" "conta")
;						(list long pas conta)
;						"EXL:03" "EXL"
;					)
					;;br..
					;;ls:. Elemento para extraer
					;;<"xx,xx,...">
					;;long:. Longitud de elemento
					(while
						(<= conta long)
						(setq ltw nil
							pas 0
						)
						(setq lt (substr ls conta 1))
						;;br
;						(brkstep1    
;							'("lt" "ltw" "pas" "conta" "long" "ls")
;							(list lt ltw pas conta long ls)
;							"EXL:04" "EXL"
;						)
						;;br..
						(while
							(and
								(not (= lt ","))
								(<= conta (strlen ls))
							)
							;;br
;							(brkstep1
;								'("lt" "ltw" "pas" "conta" "long")
;								(list lt ltw pas conta long)
;								"EXL:05" "EXL"
;							)
							;;br..
							(cond
								(
									(= pas 0)
									(setq ltw lt
										pas 1
									)
								)
								(
									(= pas 1)
									(setq ltw (strcat ltw lt))
								)
							)
							(setq conta (+ conta 1)
								lt (substr ls conta 1)
							)
							;;br
;							(brkstep1
;								'("lt" "ltw" "pas" "conta")
;								(list lt ltw pas conta)
;								"EXL:06" "EXL"
;							)
							;;br..
						);; while..","
						(cond
							(
								(not (= ltw nil))
								(cond
									(
										(not (= (distof ltw) nil))
										(cond
											(
												(= an 1)
												(setq ltw (atoi ltw))
											)
											(
												(= an 2)
												(setq ltw (atof ltw))
											)
										)
									)
								)
								(setq ltf (append ltf (list ltw)))
								;;br
;								(brkstep1
;									'("ltf" "ltw")
;									(list ltf ltw)
;									"EXL:07" "EXL"
;								)
								;;br..
							)
						)
						(setq conta (+ conta 1))
						;;br
;						(brkstep1
;							'("conta" "long")
;							(list conta long)
;							"EXL:08"	"EXL"
;						)
						;;br..
					)
				);cond:.Pase2
			);cond:.
		);cond:.Inicio
	);cond:.
	;;br
;	(brkstep1
;		'("ltf") (list ltf)
;		"EXL:09" "EXL"
;	)
	;;br..
	(setq ltf ltf)
)
;EXL:..
;
;;
;;;
;;;;
;:PROYECTO:
;;	<Lisp>
;:CLASIFICACION:
;;	<MDAT>
;:FUNCION / TITULO:
;;	<Lec01. Extrae un archivo con relleno en campos vacios>
;:SINTAXIS:
;;	<(Lec01 [ModoExraccionNumerica] [Ruta y nombre Archivo][valorNulo])>
;:DESCRIPCION:
;;	<<
;;	LEC01. A partir de la definicion del nombre y ruta, modo de
;;	conversion numerica, valor en campos nulos.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	LeRes. Lista estructurada de datos del archivo.
;;	<((xx …) (…) …)>
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. leMd0. Modo de conversion en datos numericos
;;	0.String
;;	1.Entero
;;	2. Decimal
;;	2. leRt0. Ruta y nombre de archivo csv
;;	3. leNul0. Valor para los campos vacios
;;	>>
;:DEPENDIENTES:
;;	<Brkstep1 Ruta Dat Fill>
;:LOCALIZACION:
;;<<
;;	>FuncionesLisp
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>230801 eliminado strcat en la funcion ruta
;;>>
;:ANOTACIONES:
;;<<
;;	> Segunda version de lec con llenado de campos vacios
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(Brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun lec01
	(leMd0 leRt0 leNul0 /
		leMd leRt leNul
		leEle0 leCn1 leCn2 leRes leResF lePas leDt leLim
		leCn0 leEle1 leMax
	)
;	(setq leMd nil  leRt nil leNul nil
;		leEle0 nil leCn1 nil leCn2 nil leRes nil leResF nil lePas nil leDt nil leLim nil
;		leCn0 nil leEle1 nil leMax nil
;	)
	;br
;	(Brkstep1
;		'("leMd0" "leRt0" "leNul0") (list leMd0 leRt0 leNul0)
;		"LEC01:00" "00"
;	)
	;br..
	(setq leCn1 1
		leCn2 1
	)
	(cond
		(
			(equal leNul0 nil)
			(setq leNul0 "non")
		)
	)
	(cond
		(
			(equal leRt0 nil)
			(setq leRt0
					(Ruta "csv" "DE LECTURA")
			)
		)
	)
	;br
	;(Brkstep1
	;	'("leMd0" "leRt0" "leNul0") (list leMd0 leRt0 leNul0)
	;	"LEC01:01" "01"
	;)
	;br..
	(cond
		(;cond type
			(and
				(not (equal leNul0 nil))
				(not (equal leRt0 nil))
				(equal (type leMd0) 'INT)
			)
			(setq leNul leNul0
				leRt leRt0
				leMd leMd0
			)
			;br
			;(Brkstep1
			;	'("leNul" "leMd" "leRt") (list leNul leMd leRt)
			;	"LEC01:02" "02"
			;)
			;br..
			(setq leDt (dat leRt)
				leCn0 0
			)
			;br
			;(Brkstep1
			;	'("leDt") (list leDt)
			;	"LEC01:03" "03"
			;)
			;br..
			(while ;While1
				(< leCn0 (length leDt))
				(setq leEle0 (nth leCn0 leDt)
					leLim (strlen leEle0)
					leCn1 1
					leCn2 1
				)
				;br
;				(Brkstep1
;					'("leCn1" "leCn2" "leEle0" "leLim")
;					(list leCn1 leCn2 leEle0 lelim)
;					"LEC01:04" "04"
;				)
				;br..
				(while ;While2
					(<= leCn2 leLim)
					(setq lePas 0
						leCn1 leCn2
					)
					;br
;					(Brkstep1
;						'("leCn1" "leCn2" "lePas") (list leCn1 leCn2 lePas)
;						"LEC01:05" "05"
;					)
					;br..
					(while ;While3
						(and
							(not (equal (substr leEle0 leCn2 1) ","))
							(<= leCn2 leLim)
						)
						;br
;						(Brkstep1
;							'("leCn1" "leCn2" "leLim")
;							(list leCn1 leCn2 leLim)
;							"LEC01:06" "06"
;						)
						;br..
						(setq 
							lePas 1
							leCn2 (+ leCn2 1)
						)
						;br
;						(Brkstep1
;							'("lePas" "leCn1" "leCn2")
;							(list lePas leCn1 leCn2)
;							"LEC01:07" "07"
;						)
						;br..
					) ;While3..
					;br
;					(Brkstep1
;						'("leCn1" "leCn2" "lePas" "Caracter")
;						(list leCn1 leCn2 lePas (substr leEle0 leCn2 1))
;						"LEC01:08" "08"
;					) 
					;br..
					(cond
						(;cond lePas0
							(and
								(equal lePas 0)
								(<= leCn2 leLim)
							)
							(setq leRes
								(append leRes
									(list leNul)
								)
							)
						);;cond lePas0..
						(;cond lePas1
							(equal lePas 1)
							(setq leEle1 (substr leEle0 leCn1 (- leCn2 leCn1)))
							(cond
								(
									(not (equal (distof leEle1) nil))
									(cond
										(
											(equal leMd 1)
											(setq leEle1 (atoi leEle1))
										)
										(
											(equal leMd 2)
											(setq leEle1 (atof leEle1))
										)
									)
								)
							)
							;br
;							(Brkstep1
;								'("leEle1") (list leEle1)
;								"LEO01:09" "09"
;							)
							;br..
							(setq leRes
								(append leRes
									(list
										leEle1
									)
								)
							)
						);cond lePas1..
					)
					;br
;					(Brkstep1
;						'("leRes") (list leRes)
;						"LEC01:10" "10"
;					)
					;br..
					(setq leCn2 (+ leCn2 1))
				);while2..
				(setq leCn0 (+ leCn0 1))
				(setq leResF
					(append leResF (list leRes))
					leRes nil
				)
				;br
;				(Brkstep1
;					'("leRes" "leResF") (list leRes leResF)
;					"LEC01:11" "11"
;			 	)
				;br..
			);While1..
			;br
;			(Brkstep1
;				'("leResF") (list leResF)
;				"LEC01:11a" "11a"
;			)
			;br..
			(cond
				(
					(not (equal leResF nil))
					(setq leResF
						(Fill leResF leNul 1)
					);;;;;;;;;Relleno Funcion
					;br
					;(Brkstep1
					;	'("leResF") (list leResF)
					;	"LEC01:12" "12"
					;)
					;br..
				)
			)
		);Cond Type..
	);Cond..
	;br
;	(Brkstep1
;		'("leResF") (list leResF)
;		"LEC01:12a" "12a"
;	)
	;br..
	(setq leResF leResF)
)		
;:PROYECTO:
;;	<Lisp>
;:CLASIFICACION:
;;	<LIST>
;:FUNCION / TITULO:
;; <Fill. Rellena campos vacios al principio o final de un registro por el valor indicado>
;:SINTAXIS:
;;	<(Fill [Lista Tabla] [ValorNulo] [ModoLocalizacion])>
;:DESCRIPCION:
;;	<<
;;	Fill. A partir de la definicion de una lista estructurada (lista Tabla)
;;	Llena los campos vacios al final o principio de cada registro
;;	<((xx xx ...)(..,),,,)>
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	FiRes. Lista de con campos vacios llenos con el argumento "nulo"
;;	((xx ...) (...) ...)
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. fiLs0. Lista estructurada para rellenar
;;	<((xx ...) (...) ...)>
;;	2. fiNul0. Elemento nulo para llenar en campos vacios
;;	3.fiMd0. Modo de llenado:.
;;		>0:. Llenado al principio
;;		>1:.Llenado al final
;;	>>
;:DEPENDIENTES:
;;	<Brkstep1 NeleLs >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	> Si se omite el valor nulo (fiNul) tendrá el valor "non"
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Fill
	(fiLs0 fiNul0 fiMd0 /
		fiLs fiNul fiMd
		fiMax fiCn0 fiEle fiRes	fiRep
	)
;	(setq fiLs nil fiNul nil fiMd nil
;		fiMax nil fiCn0 nil fiEle nil fiRes nil fiRep nil
;	)
	;br
;	(brkstep1
;		'("fiLs0" "fiNul0" "fiMd0") (list fiLs0 fiNul0 fiMd0)
;		"Fill:00" "00"
;	)
	;br..
	(cond
		(;Cond type true
			(and
				(equal (LsType fiLs0) 'LIST)
				(equal (type fiMd0) 'INT)
			)
			(setq fiLs fiLs0
				fiNul fiNul0
				fiMd fiMd0
			)
			(cond
				(
					(equal fiNul nil)
					(setq fiNul "non")
				)
			)
			(setq fiMax
				(nth 0 (NeleLs fiLs))
			)
			;br
;			(brkstep1
;				'("fiLs" "fiNul" "fiMd" "fiMax") (list fiLs fiNul fiMd fiMax)
;				"Fill:01" "01"
;			)
			;br..
			(setq fiCn0 0)
			(while ;while length fiLs
				(< fiCn0 (length fiLs))
				(setq fiEle (nth fiCn0 fiLs)
					fiRep (- fiMax (length fiEle)) 
				)
				;br
;				(brkstep1
;					'("fiEle" "fiMax" "fiRep")
;					(list fiEle fiMax fiRep)
;					"Fill:02" "02"
;				)
				;br..
				(cond
					( ;cond repeat <0
						(not (equal fiRep 0))
						(repeat (- fiMax (length fiEle))
							(cond
								(
									(= fiMd 0)
									(setq fiEle
										(append
											(list fiNul)
											fiEle
										)
									)
									;br
;									(brkstep1
;										'("fiEle") (list fiEle)
;										"Fill:03" "03"
;									)
									;br..
								)
								(
									(= fiMd 1)
									(setq fiEle
										(append fiEle
											(list fiNul)
										)
									)
									;br
;									(brkstep1
;										'("fiEle") (list fiEle)
;										"Fill:04" "04"
;									)
									;br..
								)
							)
						)
					) ;cond repeat <0..
				)
				;br
;				(brkstep1
;					'("fiEle") (list fiEle)
;					"Fill:05" "05"
;				)
				;br..
				(cond
					(
						(not (equal fiEle nil))
						(setq fiRes (append fiRes (list fiEle)))
					)
				)
				(setq fiCn0 (+ fiCn0 1))
				;br
;				(brkstep1
;					'("fiRes" "fiCn0") (list fiRes fiCn0)
;					"Fill:02" "02"
;				)
				;br..
			);while length fiLs..
			;br
;			(brkstep1
;				'("fiRes") (list fiRes)
;				"Fill:03" "03"
;			)
			;br..
		);Cond type true..
	)
	(setq fiRes fiRes)
)
;:PROYECTO:
;;	<Lisp>
;:CLASIFICACION:
;;	<LIST>
;:FUNCION / TITULO:
;;	<NeleLs.Devuelve el numero maximo y minimo de elementos dentro de una lista estructurada>
;:SINTAXIS:
;;	<(NeleLs [ListaEstructurada])>
;:DESCRIPCION:
;;	<<
;;	NeleLs. A partir de la definicion de una lista estructurada ((xx xx ...)(...) ...):.
;;	devuelve el maximo y el minimo numero de elementos que contiene el sus registros (filas)
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:	
;;	<<
;;	Numero maximo y minimo de elementos que contiene la lista en sus registros (filas)
;;	<(Maximo Minimo)>
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1.neLs0. Lista estructurada
;;	<((xx ...) (...) ...)>
;;	>>
;:DEPENDIENTES:
;;	<brkstep1 ordVar0 lsType>
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>Terminado
;;	>Terminar registro
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun NeleLs
	(neLs0 /
		neLS
		neCn0 neCnL neRes
	)
;	(setq leLs nil
;		neCn0 nil neCnL nil neRes nil
;	)
;	;br
;	(brkstep1
;		'("neLs0") (list neLs0)
;		"NeleLs:00" "00"
;	)
	;br..
	(cond
		(;cond type true
			(equal (LsType neLs0) 'LIST)
			(setq neLs neLs0)
			;br
;			(brkstep1
;				'("neLs") (list neLs)
;				"NeleLs:01" "01"
;			)
			;br..
			(setq neCn0 0)
			(while
				(< neCn0 (length neLs))
				(setq neCnL
					(append neCnL
						(list (length (nth neCn0 neLs)))
					)
				)
				(setq neCn0 (+ neCn0 1))
				;br
;				(brkstep1
;					'("neCnL") (list neCnL)
;					"NeleLs: 02" "02"
;				)
				;br..
			)
			;br
;			(brkstep1
;				'("neCnL") (list neCnL)
;				"NeleLs:03" "03"
;			)
			;br..
			(cond
				(
					(not (equal neCnL nil))
					(setq neCnL (OrdVar0 neCnL 1))
					;br
;					(brkstep1
;						'("neCnL") (list neCL)
;						"NeleLs:04" "04"
;					)
					;br..
					(setq neRes
						(list
							(nth 0 neCnL)
							(nth (- (length neCnL) 1) neCnL)
						)
					)
					;br
;					(brkstep1
;						'("neRes") (list neRes)
;						"NeleLs:05" "05"
;					)
					;br..
				)
			)
		);cond type true..
	)
	(setq neRes neRes)
)
;
;;
;;;
;;;;
;;PROYECTO:
;;<LISP>
;;CLASIFICACION:
;;<TBL>
;;FUNCION / TITULO:
;;<<
;;QNTH00. Define las posiciones donde se
;;	encuentra un elemento en una lista
;;	sin considerar mayusculas
;;>>
;;SINTAXIS:
;;<(QNTH00 [Lista] [ElemIndice] [PrecisionNum])>
;;DESCRIPCION:
;;<<
;;	QNTH00. Define las posiciones donde
;;	encuentra un elemento determinado
;;	de una lista sencilla sin considerar mayusculas
;;	o minusculas en los textos.
;;	Basado en la funcion original QNTH
;;>>
;;EJEMPLO
;;<<
;;	pf5Ls: (Id Ruta Nombre)
;;	pf5Ele: ruta
;;	(setq pf5Res (qnth00 pf5Ls pf5Ele 0.001))
;;	pf5Res: (1)
;;>>
;;DEVUELVE:
;;<<
;;	LFP. Lista sencilla de posiciones
;;	que ocupa el elemento
;;	:.(num ...).:
;;>>
;;ARGUMENTOS
;;<<
;;	1.QLS0: Lista donde se busca el elemento
;;	:.(X X XX XX X XXX XX).:
;;	2.QEL0: Elemento indice, que se busca en la lista
;;	> XXX
;;	3. QPR0: Presicion de comparacion numerica
;;	:.Real.:
;;>>
;;DEPENDIENTES
;;<brkstep1>
;;LOCALIZACION
;;<DropBox...FuncionesLisp>
;;HISTORIAL DE CORRECCIONES
;;<<
;;	>2022.06.11: Creado basado en QNTH 
;;>>
;;ANOTACIONES
;;<<
;;	>Version modificada de QNTH con la variante
;;	de comparacion de texto sin considerar mayusculas
;;	y minusculas.
;;>>
;;ESTADO
;;<<
;;	>Actualizado
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun qnth00
	(
		qls0 qel0 qpr0 /
		qls qel qpr
		con1 lfp
	)
;	(setq qls nil qel nil qpr nil
;		con1 nil lfp nil
;	)
	;br
;	(brkstep1
;		'("qls0" "qel0" "qpr0")
;		(list qls0 qel0 qpr0)
;		"QNTH00:00" "00")
	;br..
	(cond
		(
			(and
				(= (type qpr0) 'REAL)
				(= (type qls0) 'LIST)
			)
			(setq
				qls qls0
				qel qel0
				qpr qpr0
			)
			;br
;			(brkstep1 
;				'("qls" "qel" "qpr")
;				(list qls qel qpr)
;				"QNTH00:00" "00"
;			)
			;br..
			(setq con1 0)
			(while
				(< con1 (length qls))
				(cond
					(;condSTR
						(and
							(= (type qel) 'STR)
							(= (type (nth con1 qls)) 'STR)
						)
						(cond
							(
								(equal
									(strcase qel)
									(strcase (nth con1 qls))
								)
								(setq lfp
									(append lfp
										(list con1)
									)
								)
							)
						)
					);condSTR..
					(;condNotSTR
						(or
							(not (= (type qel) 'STR))
							(not
								(= (type (nth con1 qls))
									'STR
								)
							)
						)
						(cond
							(;CondEqQel
								(equal qel
									(nth con1 qls)
									qpr
								)
								(setq lfp
									(append lfp
										(list con1)
									)
								)
							);CondEqQel..
						);cond..
					);condNotSTR..
				);cond..
				;br
;				(brkstep1
;					'("qel" "lfp" "con1"
;						"(equal qel (nth con1 qls) qpr)"
;					)
;					(list qel lfp con1 (equal qel (nth con1 qls) qpr))
;					"QNTH00:01" "01"
;				)
				;br..
				(setq con1 (+ con1 1))
			);while..
		)
	)
	(setq lfp lfp)
)
;defun..
;;
;;;
;;;;

;:PROYECTO:
;;	<Lisp>
;:CLASIFICACION:
;;	<PH>
;:FUNCION / TITULO:
;:SINTAXIS:
;;	<(ObVer [Archivo de Rutas])>
;:DESCRIPCION:
;;	<<
;;	ObVer. Verifica el formato de RUTAS.csv en una lista estructurada
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	> ObRes.
;;	>		Datos extraídos del archivo de rutas
;;	>		con la columna de busqueda insertada en su caso
;;	> T:. Si cumple con el formato y si existe la columna
;;	>		de busqueda.
;;	> nil:. Si el archivo no cumple con el formato de rutas
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. obAr0. Lista estructurada para analizar
;;	<((xx ...) (...) ...)>
;;	2. obCol0. Nombre de la columna de busqueda
;;	<"xxx">
;;	3. obNul0. Valor nulo para campos vacios
;;	en el caso de que se inserte la nueva columna.
;;	>>
;:DEPENDIENTES:
;;	<brkstep1  >
;:LOCALIZACION:
;;<<
;;	>Document/CADDapps/FuncionesLisp
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	> El formato de archivo de rutas debe cumplir:
;;	> Ser archivo tipo Lista
;;	> El primer renglon debe ser encabezado y contener unicamente
;;	> Datos de tipo String
;;	> El primer encabezado debe ser "ID"
;;	> En caso de no existir la columna con el campo
;;	> buscado:. Inserta la columna con datos vacios con el valor nulo
;;	>	de argumento
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun
	ObVer
	(obAr0 obCol0 obNull0 /
		obAr obCol obNull
		obRes
	)
;	(setq
;		obAr nil obCol nil obNull nil
;		obRes nil
;	)
	;br
;	(brkstep1
;		'("obAr0" "obCol0" "obNull0") (list obAr0 obCol0 obNull0)
;			"ObVer:00" "00"
;	)
	;br..
	(cond
		( ;cond type true
			(and
				(not (= obAr0 nil))
				(not (= obCol0 nil))
				(not (= obNull0 nil))
			)
			(setq obAr obAr0
				obCol obCol0
				obNull obNull0
				obRes nil
			)
			;br
;			(brkstep1
;				'("obAr" "obCol" "obRes") (list obAr obCol obRes)
;				"OBVER:01" "01"
;			)
			;br..
			(cond
				(
					(and
						(equal (type obAr) 'LIST)
						(equal (lstype (nth 0 obAr)) 'STR)
					)
					;br
;					(brkstep1
;						'("obAr" "obCol" "obRes") (list obAr obCol obRes)
;						"OBVER:02" "02"
;					)
					;br..
					(cond
						( ;cond ID
							(equal (strcase (nthx '(0 0) obAr)) "ID")
							(setq obRes T)
							(cond
								(
									(equal (qnth00 (nth 0 obAr) obCol 0.00) nil)
									(setq obRes (jo1 obAr (list (list obCol)) obNull))
									(alert
										(strcat "COLUMNA " obCol " INSERTADA...")
									)
								)
							)
						);cond ID T..
					)
				)
			)
			;br
;			(brkstep1
;				'("obAr" "obCol" "obRes") (list obAr obCol obRes)
;				"OBVER:03" "03"
;			)
			;br..
			(if
				(equal obRes nil)
				(alert "EL ARCHIVO NO TIENE EL FORMATO NECESARIO")
			)
		) ;cond type T
		( ;cond type nil
			(equal obAr0 nil)
			(alert "ARCHIVO NO ENCONTRADO...")
		) ;cond type nil
	) ;cond
	;br
;	(brkstep1
;		'("obAr" "obCol" "obRes") (list obAr obCol obRes)
;		"OBVER:03" "03"
;	)
	;br..
	(setq obRes obRes)
)
;;
;;;
;;;;
;;;;;

;;PROYECTO:
;;<Lisp>
;;CLASIFICACION:
;;<PH> 
;;FUNCION / TITULO:
;;<OBTEN01. Obtiene los datos de la tabla seleccionada>
;;SINTAXIS
;;<(OBTEN01 [RutaDefault] [NomArchivo] [COL] [ListaDeFault] [ValorNulo] [Prescision])>
;;DESCRIPCION:
;;	OBTEN01. Apartir de la definicion de un nombre de archivo,
;;		columna extrae los datos del archivo seleccionado con 
;;	revision de caracteristicas del archivo de rutas:.
;;	Contiene interface para la definicion de archivo
;;	nuevo o copiar un archivo existente.
;;	inserta el campo definido en el argumento caso de que no exista
;;EJEMPLO:
;;	<<
;;
;;	>>
;;DEVUELVE:
;;<<
;;	obDat. Tabla de datos (lista estructurada de datos)
;;	contenido del archivo
;;	<((xx ...) (...) ...)>
;;>>
;;ARGUMENTOS:
;;<<
;;	1. RT0. Ruta de archivo
;;	2. NOMAR0. Nombre de archivo de rutas
;;	<"xxx.csv">
;;	3. COL0. Nombre de la columna que contiene la ruta
;;	<"xx">
;;	4. obLs0. Lista de campos para definir la tabla del
;;		archivo de rutas (en caso de crear una tabla nueva)
;;		(si se omite introduce los predeterminados)
;;	5. obNul0. Valor Nulo en caso de que la tabla tenga campos
;;	vacios.
;;	6. obPrec0. Precsicion de extraccion de datos
;;		número de decimale.
;;	7.obMod0. Modo de extraccion de datos numericos
;;		0:. String
;;		1:. Entero
;;		2:. Decimal
;;>>
;;DEPENDIENTES:
;;<brkstep1 mrr4>
;;LOCALIZACION
;;<C:...[gsp]\\CADDapps\\FuncionesLisp\\LispPH_Obten01.lsp>
;;HISTORIAL DE CORRECCIONES
;;<<
;;	>2019.12.10:..Nueva ruta de archivo (autoguardado)
;;	>2020. Verificacion de archivo de ruta
;;	>2023.08.09:..Modificación de estructura
;;		Obten01. Verificacion y extraccion de datos de archivo
;;		Obten02. Obtencion e introducción de datos
;;		Obten00. Obtencion de datos y verificacion (union 01 y 02)
;;>>
;;ANOTACIONES
;;<<
;;	1:.Verifica si existe el archivo, en caso
;;	de que no exista crea uno nuevo
;;	o lo copia.
;;	2:. Verifica si el archivo tiene
;;	encabezado con el primer elemento
;;	llamado "ID"
;;	3:.El archivo predeterminado se define en el argumento:.
;;		si se omite toma la ruta de autosalvado
;;	> El archivo de rutas es de tipo tabla donde el primer elemento
;;	de la lista corresponde a los valores de cabecera (titulos)
;;	y.. sucesivamente.. el primer elemento de cada subelemento 
;;	corresponde al nombre(indice) de cada ruta.
;;	> Plantilla de archivo nuevo:
;;	<("ID" "RUTA" "NOM" "TYPE" "EXT" "PROY" "CLS" "CLAS" "EXE")>
;;>>
;;	ESTADO:
;;<<
;;	> Modificando la ruta del achivo nde rutas al directorio de
;;	autoguardado.
;;	> Modificando opciones de menú principal:
;;	copia de archivo o crear archivo nuevo
;;	> Opciones de menú secundario
;;	grabar ruta en archivo si/no '(2021-10-04)
;;	> Modificando interface de copiado y nuevo
;;	> 
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;**********************************************************
(defun obten01
	(rt0 nomar0 col0 obls0 obNul0 obPrec0 obMod0 /
		rt nomar col obls obNul obPrec obMod
		mi1 mi2
		obDat obNom obPas01 obDatV
		des des01
	)
	;var
;	(setq rt nil nomar nil col nil obLs nil
;		obNul nil obPrec nil obMod nil
;		mi1 nil mi2 nil
;		obDat nil obNom nil obPas01 nil obDatV nil
;		des nil des01 nil
;	)
	;var..
	;br
;	(brkstep1
;		'("rt0" "nomar0" "col0" "obLs0" "obNul0" "obPrec0" "obMod0")
;		(list rt0 nomar0 col0 obLs0 obNul0 obPrec0 obMod0)
;		"OBTEN01:00" "00"
;	)
	;br..
	(cond
		(;con:. Type
			(and
				(= (type nomar0) 'STR)
				(= (type col0) 'STR)
				(not (= obNul0 nil))
				(= (type obPrec0) 'INT)
				(= (type obMod0) 'INT)
			)
			(setq
				rt rt0
				nomar nomar0
				col col0
				obls obls0
				obNul obNul0
				obPrec obPrec0
				obMod obMod0
			)
			;br
;			(brkstep1
;				'("rt" "nomar" "col" "obLs" "obNul" "obPrec" "obMod")
;				(list rt nomar col obLs obNul obPrec obMod)
;				"OBTEN01:01" "01"
;			)
			;..br
			(cond
				(
					(= rt nil)
					(setq rt
						(getvar "savefilepath")
					)
				)
			)
			(setq mi1
				(strcat (term rt) nomar ".csv")
			)
			;br
;			(brkstep1
;				'("nomar" "mi1")
;				(list nomar mi1)
;				"OBTEN:02" "O2"
;			)
			;br..
			(cond
				(
					(vere mi1)
					(setq obDat (lec01 obMod mi1 obNul))
				)
			)
			(setq	
				obPas01 0
				des "x"
			)
			;br
;			(brkstep1
;				'("obDat") (list obDat)
;				"OBTEN01:03" "03"
;			)
			;br..
			(setq obDatV (ObVer obDat col obNul))
			;br
;			(brkstep1
;				'("obDatv") (list obDatV)
;				"OBTEN01:04" "04"
;			)
			;br..
			(if
				(= obDatV T)
				(setq obPas01 1)
			)
			(while
				(and
					(= obPas01 0)
					(not (= des "Salir"))
				)
				(setq des nil
					des01 nil
					obPas01 0
				)
				;br
;				(brkstep1
;					'("obPas01" "des") (list obPas01 des)
;					"OBTEN01:05" "05"
;				)
				;br..
				(initget 128 "Copiar Nuevo Salir")
				(setq des
					(getkword
						"Seleccione la opcion :\nCopiar un archivo de ruta\nCrear un archivo Nuevo\nSalir [Copiar / Nuevo / Salir]: "
					)
				)
				;br
;				(brkstep1
;					'("des") (list des)
;					"OBTEN:06" "06"
;				)
				;br..
				(cond
					(;Cond Salir
						(= des "Salir");;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;desde aqui
						(cond
							(;Cond obDatV 'LIST
								(equal (LsType obDatV) 'LIST)
								(initget 128 "Si No")
								(setq des01
									(getkword
										"Deseas conservar el archivo de datos con la columna nueva [Si / No]: "
									)
								)
								;br
;								(brkstep1
;									'("des01" "obDatV") (list des01 obDatV)
;									"OBTEN01:07" "07"
;								)
								;br..
								(if
									(= des01 "Si")
									(setq obDat obDatV)
								)
							);Cond obDatV 'LIST..
						)
						(setq obPas01 1)
						;br
;						(brkstep1
;							'("des01" "obPas01" "obDat") (list des01 obPas01 obDat)
;							"OBTEN:08" "08"
;						)
						;br..
					);CondDes Salir..
					(;CondDes Copiar
						(= des "Copiar")
						(setq mi2 nil obDat nil des01 nil)
						(setq mi2
							(ruta "csv" nomar)
						)
						;br
;						(brkstep1
;							'("mi2" "obDat" "des01")
;							(list mi2 obDat des01)
;							"OBTEN:09" "09"
;						)
						;br..
						(cond
							(;mi2 True
								(not (= mi2 nil))
								(setq obDat (lec01 obMod mi2 obNul))
								;br
;								(brkstep1
;									'("obDat") (list obDat)
;									"Obten01:10" "10"
;								)
								;br..************************************+
								(setq obDatV (obVer obDat col obNul))
								;br
;								(brkstep1
;									'("obDatV" "obPas01") (list obDatV obPas01)
;									"OBTEN01:11" "11"
;								)
								;br..
								(cond
									( ;cond obDat T
										(= obDatV T)
										(setq obPas01 1
											des "Salir"
										)
									) ; cond obDat T..
									(;cond obDat = list
										(equal (Lstype obDatV) 'LIST)
										(initget 128 "Si No")
										(setq des01
											(getkword 
												"Deseas conservar el archivo de datos con la columna nueva [Si / No]: "
											)
										)
										;br
;										(brkstep1
;											'("des01") (list des01)
;											"OBTEN01:12" "12"
;										)
										;br..
										(cond
											(
												(equal des01 "Si")
												(setq obDat obDatV
													obPas01 1
													des "Salir"
												)
												;br
;												(brkstep1
;													'("obDat") (list obDat)
;													"OBTEN01:13" "13"
;												)
												;br..
											)
										)
									);cond obDat = list..
								); cond ..
							);Cond mi2 T..
						);cond ..
						;br
;						(brkstep1
;							'("obDat") (list obDat)
;							"OBTEN01:14" "14"
;						)
						;br..
					);CondDes Copiar..
					(;CondDes Nuevo..
						(equal des "Nuevo")
						(cond
							(
								(equal mi1 nil)
								(setq rt
									(getvar "savefilepath")
								)
								(setq mi1 (strcat (term rt) nomar ".csv"))
								;br
;								(brkstep1
;									'("mi1") (list mi1)
;									"OBTEN01:15" "15"
;								)
								;br..
							)
						)
						(cond
							(
								(not (= (lstype obLs) 'STR))
								(setq obDat
									(list
										(list "ID" "RUTA" "NOM" "TYPE" "EXT" "PROY" "CLS" "CLAS" "EXE"
										)
									)
								)
							)
							(
								(= (lstype obLs) 'STR)
								(setq ObDat (list obLs))
							)
						)
						(setq obdatV (obVer obDat col obNul))
						;br
;						(brkstep1
;							'("obDatV") (list obDatV)
;							"OBTEN01:16" "16"
;						)
						;br..
						(cond
							(
								(equal obDatV T)
								(setq
									obPas01 1
									des "Salir"
								)
							)
							(
								(equal (lsType obDatV) 'LIST)
								(setq des01 nil)
								(initget "Si No")
								(setq des01
									(getkword
										"Deseas conservar el archivo de datos con la columna nueva [Si / No]: "
									)
								)
								;br
;								(brkstep1
;									'("des01") (list des01)
;									"OBTEN01:17" "17"
;								)
								;br..
								(cond
									(
										(= des01 "Si")
										(setq obDat obDatV)
									)
								)
								(setq obPas01 1
									des "Salir"
								)
							)
						)
						;br
;						(brkstep1
;							'("obDat" "mi1") (list obDat mi1)
;							"OBTEN:18" "18"
;						)
						;br..
					); ConDes Nuevo..
				);Cond..
			); While..
		) ; cond type T
	); Cond ..
	;br
;	(brkstep1
;		'("mi1" "obDat") (list mi1 obDat)
;		"OBTEN01:19" "19"
;	)
	;br..
	(cond
		(
			(not (equal obDat nil))
			(escr1 (txl1 obDat obPrec ",") nomar "csv" mi1 0)
		)
	)
	(setq obDat obDat)
); obten01..
;
;;
;;;
;;;;
;;PROYECTO:
;;<Lisp>
;;CLASIFICACION:
;;<TBL>
;;FUNCION / TITULO:
;;<QNTH1. Devuelve las posiciones (H y V) de un elemento en una lista tipo tabla>
;;SINTAXIS:
;;<(QNTH01 [ListaTabla] [ElementoBusqueda] [PrecisionNum])>
;;DESCRIPCION:
;;<<
;;	QNTH1. Funcion original.
;;	A partir de la definicion de un elemento devuelve la lista de las
;;	posiciones en las que se encuentra dicho elemento en una lista
;;	tipo tabla.
;;	en la comparacion con cadenas de texto considera mayusculas y minusculas.
;;>>
;;EJEMPLO
;;<<
;;	pf5Ls: ((Id Ruta Nombre Ruta) (2 20 ruta roro vendeme) (esta pluma 1000 12000))
;;	pf5Ele: ruta
;;	(setq pf5Res (qnth1 pf5Ls pf5Ele 0.001))
;;	pf5Res: ((1 (2)))
;;DEVUELVE:
;;<<
;;	PF. Lista de posiciones en las que se encuentra el elemento indicado
;;	con la siguiente estructura
;;	((Renglonx (columnax1 columnax2 ...)) (...) ..)
;;>>
;;ARGUMENTOS
;;<<
;;	1. ql0. Lista estructurada (tipo tabla)
;;	((xx ...) (...) ...) :.LIST.:
;;	2. qe0. Elemento de busqueda
;;	:.xxx.:
;;	3.qp0. Precision Numerica
;;	:.Real.:
;;>>
;;DEPENDIENTES
;;<Brkstep1 qnth>
;;LOCALIZACION
;;<Dropbox\\...\\FuncionesLisp\\>
;;HISTORIAL DE CORRECCIONES
;;<<
;;	>2022.06.12. Actualizado
;;>>
;;ANOTACIONES
;;<<
;;	>Funcion original. En elemento de tipo cadena de textos
;;	toma en cuenta mayusculas y minusculas
;;>>
;;ESTADO
;;<Actualizado>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;
(defun qnth1
	(ql0 qe0 qp0 / 
		ql qe qp
		con1 phz pf
	)
;	(setq ql nil qe nil qp nil
;		con1 nil phz nil pf nil
;	)
	;br
;	(brkstep1
;		'("ql0" "qe0" "qp0") (list ql0 qe0 qp0)
;		"QNTH1:00" "00"
;	)
	;br..
	(cond
		(;Condtype True
			(and 
				(= (type ql0) 'LIST)
				(= (type qp0) 'REAL)
				(not (= qe0 nil))
			)
			(setq
				ql ql0
				qe qe0
				qp qp0
			)
			;br
;			(brkstep1
;				'("ql" "qe" "qp")
;				(list ql qe qp)
;				"Qnth1:00" "00"
;			)
			;br..
			(cond
				(;CondTypeQl List
					(= (type (nth 0 ql)) 'LIST)
					(setq con1 0)
					(while (< con1 (length ql))
						(setq phz
							(qnth 
								(nth con1 ql)
								qe
								qp
							)
						)
						;br
;						(brkstep1
;							'("phz") (list phz) "Qnth1:01" "01"
;						)
						;br..
						(cond
							(
								(not (= phz nil))
								(setq pf
									(append
										pf
										(list
											(list
												con1
												phz
											)
										)
									)
								)
							)
						)
						(setq con1 (+ con1 1))
						;br
;						(brkstep1
;							'("pf" "phz" "con1")
;							(list pf phz con1)
;							"Qnth:02" "02"
;						)
						;br..
					);while...
					;br
;					(brkstep1 '("pf") (list pf) "Qnth:03" "03")
					;br..
				);CondTypeQl List..
			);Cond
		);Condtype True..
	);Cond..
	(setq pf pf)
);defun..
;
;;
;;;
;;;;
;;PROYECTO:
;;<Lisp>
;;CLASIFICACION:
;;<TBL>
;;FUNCION / TITULO:
;;<QNTH01. Devuelve las posiciones (H y V) de un elemento en una lista tipo tabla>
;;SINTAXIS:
;;<(QNTH01 [ListaTabla] [ElementoBusqueda] [PrecisionNum])>
;;DESCRIPCION:
;;<<
;;	A partir de la definicion de un elemento
;;	Devuelve la lista de posiciones en las que se encuentra
;;	dicho elemento en una lista tipo tabla.
;;	basado en la funcion original QNTH1
;;	con la comparacion en Cadenas de texto sin tomar en cuenta
;;	mayusculas o minusculas.
;;>>
;;EJEMPLO
;;<<
;;	pf5Ls: ((Id Ruta Nombre Ruta) (2 20 ruta roro vendeme) (esta pluma 1000 12000))
;;	pf5Ele: ruta
;;	(setq pf5Res (qnth01 pf5Ls pf5Ele 0.001))
;;	pf5Res: ((0 (1 3)) (1 (2)))
;;>>
;;DEVUELVE:
;;<<
;;	PF. Lista de posiciones vertical y horizontal en las que
;;	se encuentra el elemento indicado con la siguiente
;;	estructura.
;;	<((posicionVertical (posHrz1 posHrz2 ...)) (...) ...)>
;;>>
;;ARGUMENTOS
;;<<
;;	1. ql0. Lista de trabajo tipo tabla donde se
;;	va a buscar el elemento.
;;	:..((xx ...) (...) ...)..:
;;	2. qe0. Elemento indice de busqueda
;;	:..xx..:
;;	3. qp0. Precision numerica
;;	:..Numero Real..:
;;>>
;;DEPENDIENTES
;;<Brkstep1 QNTH00>
;;LOCALIZACION
;;<Dropbox\\...\\FuncionesLisp\\>
;;HISTORIAL DE CORRECCIONES
;;<<
;;	>2022.12.06. Creacion Apartir de la funcion QNTH1
;;>>
;;ANOTACIONES
;;<<
;;	>Basado en la funcion original QNTH1 con la variante
;;	de comparacion en cadenas de texto sin considerar
;;	mayusculas o minusculas
;;>>
;;ESTADO
;;	>Actualizado
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;**************************************************
(defun qnth01
	(ql0 qe0 qp0 /
		ql qe qp
		con1 phz pf
	)
;	(setq qp nil qe nil qp nil
;		con1 nil phz nil pf nil
;	)
	;br
;	(brkstep1
;		'("ql0" "qe0" "qp0")
;		(list ql0 qe0 qp0)
;		"QNTH01:00" "00"
;	)
	;br..
	(cond
		(;CondTypeTrue
			(and
				(= (type ql0) 'LIST)
				(= (type qp0) 'REAL)
				(not (= qe0 nil))
			)
			(setq ql ql0
				qe qe0
				qp qp0
			)
			;br
;			(brkstep1
;				'("ql" "qe" "qp")
;				(list ql qe qp)
;				"QNTH01:01" "01"
;			)
			;br..
			(cond
				(;condTypeQl
					(= (type (nth 0 ql)) 'LIST)
					(setq con1 0)
					(while (< con1 (length ql))
						(setq phz
							(qnth00 
								(nth con1 ql)
								qe
								qp
							)
						)
						;br
;						(brkstep1
;							'("phz") (list phz) "QNTH01:02" "02"
;						)
						;br..
						(cond
							(
								(not (= phz nil))
								(setq pf
									(append
										pf
										(list
											(list
												con1
												phz
											)
										)
									)
								)
							)
						)
						(setq con1 (+ con1 1))
						;br
;						(brkstep1
;							'("pf" "phz" "con1")
;							(list pf phz con1)
;							"QNTH01:03" "03"
;						)
						;br..
					)
					;br
;					(brkstep1 '("pf") (list pf) "QNTH01:04" "04")
					;br..
				);condTypeQl..
			);cond..
		);CondTypeTrue..
	);Cond..
	(setq pf pf)
);defun..
;
;;
;;;
;;;;
;:PROYECTO:
;;	> Lisp
;:CLASIFICACION:
;;	> LIST
;:FUNCION / TITULO:
;;	> SusEle. Sustituye un elemento en una lista
;:SINTAXIS:
;;	> (SusEle [ListaTrabajo] [Elemento] [PosicionNth])
;:DESCRIPCION:
;;	<<
;;	SusEle. Sustituye un elemento en una lista
;;	de acuerdo a una posicion (nth) determinada
;;	>>
;:EJEMPLO:
;;	>
;:DEVUELVE:
;;	> suRes. Lista con el elemento sustituido
;;	<(x ...)>
;:ARGUMENTOS:
;;	<<
;;	1. suLs0. Lista de trabajo
;;	<(x ...)>
;;	2. suEl0. Elemento a sustituir
;;	<xx>
;;	3. suPos0. Posicion (nth) del elemento a sustituir
;;	<INT>
;:DEPENDIENTES:
;;	>
;:LOCALIZACION:
;;	>
;:HISTORIAL DE CORRECCIONES:
;;	>
;:ANOTACIONES:
;;	>
;:ESTADO:
;;	>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun SusEle
	(suLs0 suEl0 suPos0 /
		suLs suEl suPos
		suRes
	)
;	(setq suLs nil suEl nil suPos nil
;		suRes nil
;	)
	;br
;	(brkstep1
;		'("suLs0" "suEl0" "suPos0") (list suLs0 suEl0 suPos0)
;		"SuEle: 00" "00"
;	)
	;br..
	(cond
		( ;Cond Type true
			(and
				(= (type suLs0) 'LIST)
				(not (= suEl0 nil))
				(= (type suPos0) 'INT)
			)
			(setq suLs suLs0
				suEl suEl0
				suPos suPos0
			)
			;br
;			(brkstep1
;				'("suLs" "suEl" "suPos") (list suLs suEl suPos)
;				"susEle: 01" "01"
;			)
			;br..
			(cond
				(
					(= suPos (- (length suLs) 1))
					(setq suRes (isl1 suEl (lsno suLs suPos) ()))
				)
				(
					(< suPos (- (length suLs) 1))
					(setq suRes (isl1 suEl (lsno suLs suPos) suPos))
				)
			)
			;br
;			(brkstep1
;				'("suRes") (list suRes)
;				"SusEle: 02" "02"
;			)
			;br..
		) ;Cond Type true..
	) ;Cond..
	(setq suRes suRes)
)
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<MAT>
;:FUNCION / TITULO: AngCam. Cambia un angulo no gire mas de 180 grados
;:SINTAXIS:
;;	<(ANGCAM [AngRad])>
;:DESCRIPCION:
;;	<<
;;	AngCAm. A partir de la definición de un angulo en radianes
;;	Cambia el angulo para que sea el equivalente y no sea mayor a
;;	180 (?)
;;
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	
;;	>>
;:ARGUMENTOS:
;;	<<
;;
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>Revisar funcionamiento y completar descripcion
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)

(defun AngCam
	(anRd0 /
		anRd
	)
	;(setq anRd nil)
	;(brkstep1 '("anRd0") (list anRd0) "00" "AngCam")
	(cond
		(
			(= (type anRd0) 'REAL)
			(setq anRd anRd0)
			(cond
				(
					(and
						(< 1.5708 anRd)
						(< anRd 3.14159)
					)
					(setq anRd (+ anRd 3.14159))
				)
				(
					(and
						(<= 3.14159 anRd)
						(<= anRd 4.71239)
					)
					;(brkstep1 '("anRd") (list anRd) "01" "AngCam")
					(setq anRd (- anRd 3.14159))
				)
			)
		)
	)
	(setq anRd anRd)
)
;
;;
;;;
;;;;
;
;;
;;;
;;;;
;;PROYECTO:
;;<LISP>
;;CLASIFICACION:
;;<TBL>
;;FUNCION / TITULO:
;;<<
;;QNTH. Define las posiciones donde se
;;	encuentra un elemento en una lista
;;>>
;;SINTAXIS:
;;<(QNTH [Lista] [ElemIndice] [PrecisionNum])>
;;DESCRIPCION:
;;<<
;;	QNTH. Define las posiciones donde
;;	encuentra un elemento determinado
;;	de una lista sencilla.
;;>>
;;EJEMPLO
;;<<
;;	pf5Ls: (Id Ruta Nombre)
;;	pf5Ele: Ruta
;;	(setq pf5Res (qnth pf5Ls pf5Ele 0.001))
;;	pf5Res: (1)
;;>>
;;DEVUELVE:
;;<<
;;	LFP. Lista sencilla de posiciones
;;	que ocupa el elemento
;;	:.(num ...).:
;;>>
;;ARGUMENTOS
;;<<
;;	1.QLS0: Lista donde se busca el elemento
;;	:.(X X XX XX X XXX XX).:
;;	2.QEL0: Elemento indice, que se busca en la lista
;;	> XXX
;;	3. QPR0: Presicion de comparacion numerica
;;	:.Real.:
;;>>
;;DEPENDIENTES
;;<brkstep1>
;;LOCALIZACION
;;	>DropBox...FuncionesLisp
;;HISTORIAL DE CORRECCIONES
;;	>22.05.25:. Actualizacion
;;	>22.06.02:. Registrado
;;ANOTACIONES
;;	>
;;ESTADO
;;	>Actualizado
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun qnth
	(
		qls0 qel0 qpr0 /
		qls qel qpr
		con1 lfp
	)
;	(setq qls nil qel nil qpr nil
;		con1 nil lfp nil
;	)
	;br
;	(brkstep1
;		'("qls0" "qel0" "qpr0")
;		(list qls0 qel0 qpr0)
;		"QNTH:00" "00")
	;br..
	(cond
		(
			(and
				(= (type qpr0) 'REAL)
				(= (type qls0) 'LIST)
			)
			(setq
				qls qls0
				qel qel0
				qpr qpr0
			)
			;br
;			(brkstep1 
;				'("qls" "qel" "qpr")
;				(list qls qel qpr)
;				"QNTH:00" "00"
;			)
			;br..
			(setq con1 0)
			(while
				(< con1 (length qls))
				(if
					(equal qel (nth con1 qls) qpr)
					(setq lfp (append lfp (list con1)))
				)
				;br
;				(brkstep1
;					'("qel" "lfp" "con1"
;						"(equal qel (nth con1 qls) qpr)"
;					)
;					(list qel lfp con1 (equal qel (nth con1 qls) qpr))
;					"QNTH:01" "01"
;				)
				;br..
				(setq con1 (+ con1 1))
			)
		)
	)
	(setq lfp lfp)
)
;defun..
;;
;;;
;;;;

;;PROYECTO:
;;<Lisp>
;;CLASIFICACION:
;;<TBL>
;;FUNCION / TITULO:
;;<QNTH02. Extrae en una tabla el valor indicado por la columna y renglon>
;;SINTAXIS:
;;<(QNTH02 [Tabla] [Renglon] [Columna] [PrecisionNum])>
;;DESCRIPCION:
;;<<
;; 	A partir de la definicion de un valor ID de registro (Renglon)
;;	y un valor de cabecera (Columna) devuelve el valor que corresponde
;;	en una lista estructurada tipo tabla.
;;	Funcion basada en QNTH2
;;	En los datos de tipo String no considera mayusculas y minusculas.
;;>>
;;EJEMPLO
;;<<
;;	(setq 
;;			pf5Ls
;;			'(
;;				("Id" "Ruta" "Nombre" "Tipo")
;;				("a01" "rt1" "ruta" "roro" "vendeme")
;;				("b02" "rt2" 1000 12000)
;;				("c03" 22.2 29 "ruta" "una" "ruta" "mas")
;;			)
;;			pf5ID "C03"
;;			pf5col "NOMBRE"
;;		)
;;	(setq pf5Res (qnth02 pf5Ls pf5ID pf5Col 0.001))
;;	pf5Res: 29
;;>>
;;DEVUELVE:
;;<<
;;	VARF. Valor que corresponde a la columna (valor vertical) y
;;	renglon (valor horizontal).
;;	:..xx..:
;;>>
;;ARGUMENTOS
;;<<
;;	1. TBL0. Lista estructurada (tipo tabla)
;;	:..((xx ...) ...)..:
;;	2. VALHZ0. Valor buscado en el renglon
;;	:..xxx..:
;;	3. VALVER0. Valor buscado en columnas
;;	:..xxx..:
;;	4. POS0: Valor de precision numerica
;;	:..Numero Real..:
;;>>
;;DEPENDIENTES
;;<BRKSTEP1 QNTH01 NTHX>
;;LOCALIZACION
;;<Dropbox\\...\\LispFunciones\\>
;;HISTORIAL DE CORRECCIONES
;;<<
;;<2022.06.15:. Funcion basada en QNTH2 con la variante
;;	que en la comparacion de datos tipo string no
;;	considera mayusculas o minusculas
;;>>
;;ANOTACIONES
;;<<
;;	>Funcion basada en  QNTH2. para la comparacion de
;;	textos ignora  mayusculas o minusculas.
;;>>
;;ESTADO
;;<Actualizado>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun qnth02
	(tbl0 valhz0 valver0 pos0 /
		tbl valhz valver pos
		posver poshz valf varf
	)
	;var
;	(setq tbl nil valhz nil valver nil pos nil
;		posver nil poshz nil valf nil varf nil
;	)
	;var..
	;br
;	(brkstep1 
;		'("tbl0" "valhz0" "valver0" "pos0")
;		(list tbl0 valhz0 valver0 pos0)
;		"QNTH02:00" "00"
;	)
	;br..
	(cond
		(
			(and
				(= (type tbl0) 'LIST)
				(= (type pos0) 'REAL)
				(not (= valver0 nil))
				(not (= valhz0 nil))
			)
			(setq
				tbl tbl0
				pos pos0
				valver valver0
				valhz valhz0
			)
			;br
;			(brkstep1
;				'("tbl" "pos" "valver" "valhz")
;				(list tbl pos valver valhz)
;				"QNTH02:01" "01"
;			)
			;br..
			(cond
				(
					(= (type (nth 0 tbl)) 'LIST)
					(setq posver (qnth01 tbl valver pos))
					(setq poshz (qnth01 tbl valhz pos))
					;br
;					(brkstep1 
;						'("posver" "posHz")(list posver posHz)
;						"QNTH2:02" "02"
;					)
					;br..
					(cond
						(
							(and
								(not (= posver nil))
								(not (= poshz nil))
							)  
							(setq posver (nthx '(0 1 0) posver))
							(setq poshz (nthx '(0 0) poshz))
							(setq varf (nthx (list poshz posver) tbl))
						)
					)
					;br
;					(brkstep1
;						'("posver" "posHz" "varF")
;						(list posver posHz varF)
;						"QNTH02:03" "03"
;					)
					;br..
				)
			)
		)
	)
	;br
;	(brkstep1
;		'("varf") (list varf)
;		"QNTH02:04" "04"
;	)
	;br..
	(setq varf varf)
	
);defun..
;
;;
;;;
;;;;
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<MAIN>
;:FUNCION / TITULO: <DfRt. Seleccion de usuario para grabar rutas y datos en el archivo de rutas>
;:SINTAXIS:
;;	<(DfRt [RUTA] [NOM_ARCHIVO RUTA] [EXTENSION] [((A/Ctipo "MENSAJE" "ID" "NOMAR" "NOMEXT") (...)...))] [COL] [NUL] [PREC] [LSCAMPOS])>
;:DESCRIPCION:
;;	<<
;;	DfRt. A partir de una lista de nombre de archivos o
;; 	carpetas para definir, solicita al usuario cada una de
;;	las rutas para grabar en el archivo de rutas.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	dfRes.Lista de datos de archivos grabados
;;	>>
;:ARGUMENTOS:
;;	<<
;;		1. dfRuta0. Ruta de archivo donde se va a grabar
;;		(opcional)
;;		2.dfNom0. Nombre de archivo de donde se graba la
;;		información
;;		3.dfEx0. Extensión del archivo de escritura.
;;		4. dfLs0. Lista de carpetas y rutas para grabar
;;		(formato DEFR01)
;;		5. dfCol0. Nombre Columna donde se va a grabar la ruta
;;		6.dfNul0. Valor nulo para campos vacíos
;;		7.dfPrec0. Precisión de valores numéricos
;;		(numero de decimales)
;;		8.dfLsCam0. Lista de campos predefinidos para
;;		archivos nuevos.
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>Asume que existe un solo registro de cada ID
;;		asi que extrae la primera posicion
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun DfRt
	(dfRuta0 dfNom0 dfEx0 dfLs0 dfCol0 dfNul0 dfPrec0 dfCam0 /
		dfRuta dfNom dfEx dfLs dfCol dfNul dfPrec dfCam
		dfRts dfDat dfIdp dfCon1  dfEl dfCp dfRg
	)
;	(setq dfRuta nil dfNom nil dfEx nil dfLs nil dfCol nil
;		dfNul nil dfPrec nil dfCam nil
;		dfRts nil dfDat nil dfIdp nil dfCon1 nil dfEl nil
;		dfCp nil dfRg nil
;	)
	;br
;	(brkstep1
;		'("dfRuta0" "dfNom0" "dfEx0""dfLs0"
;			"dfCol0" "dfNul0" "dfPrec0" "dfCam0"
;		)
;		(list dfRuta0 dfNom0 dfEx0 dfLs0 dfCol0 dfNul0 dfPrec0 dfCam0)
;		"DfRt:00" "00"
;	)
	;br..
	(cond
		(;Cond type T
			(and
				(= (type dfNom0) 'STR)
				(= (tYPE dfEx0) 'STR)
				(= (type dfLs0) 'LIST)
				(= (type dfCol0) 'STR)
				(= (type dfNul0) 'STR)
				(= (type dfPrec0) 'INT)
			)
			(setq dfRuta dfRuta0
				dfNom dfNom0
				dfEx dfEx0
				dfLs dfLs0
				dfCol dfCol0
				dfNul dfNul0
				dfPrec dfPrec0
				dfCam dfCam0
			)
			;br
;			(brkstep1
;				'("dfRuta" "dfNom" "dfEx" "dfLs" "dfCol" "dfNul" "dfPrec" "dfCam")
;				(list dfRuta dfNom dfEx dfLs dfCol dfNul dfPrec dfCam)
;				"DFRT:01" "01"
;			)
			;br..
			(cond
				(
					(= dfRuta nil)
					(setq dfRuta (term (getvar "savefilepath")))
				)
			)
			(setq
				dfRts (defr01 dfLs)
				dfDat
					(Obten01
						dfRuta dfNom dfCol dfCam dfNul dfPrec 0
					)
			)
			;br
;			(brkstep1
;				'("dfRts" "dfDat") (list dfRts dfDat)
;				"DFRT:02" "02"
;			)
			;br..
			(cond
				(;cond Ruta:.Datos T
					(and
						(not (= dfRts nil))
						(not (= dfDat nil))
					)
					(setq dfCon1 0)
					(while
						(< dfCon1 (length dfRts))
						(setq
							dfEl (nth dfCon1 dfRts)
							dfIdp
								(nthx '(0 0)
									(qnth01 dfDat (nth 0 dfEl) 0.0001)
								)
							dfCp (qnth00 (nth 0 dfDat) dfCol 0.0001)
						)
						;br
;						(brkstep1
;							'("dfCon1" "dfEl" "dfIdp" "dfCp")
;								(list dfCon1 dfEl dfIdp dfCp)
;							"DFRT:03" "03"
;						)
						;br..
						(cond
							(
								(= dfIdp nil)
								(setq dfReg
									(Reg0
										(nth 0 dfEl)
										(length (nth 0 dfDat))
										dfNul
									)
								)
								;br
;								(brkstep1
;									'("dfReg") (list dfReg)
;									"DFRT:04" "04"
;								)
								;br..
							)
							(
								(not (= dfIdp nil))
								(setq dfReg (nth dfIdp dfDat))
							)
						)
						(setq dfReg
							(susele dfReg
								(nth 1 dfEl)
								(nth 0 dfCp)
							)
						)
						;br
;						(brkstep1
;							'("dfReg") (list dfReg)
;							"DFRT:05" "05"
;						)
						;br..
						(cond
							(
								(= dfIdp nil)
								(setq dfDat
									(append dfDat (list dfReg))
								)
								;br
;								(brkstep1
;									'("dfDat") (list dfDat)
;									"DFRT:06" "06"
;								)
								;br..
							)
							(
								(not (= dfIdp nil))
								(setq dfDAt (susele dfDat dfreg	dfIdp))
								;br
;								(brkstep1
;									'("dfDat") (list dfDat)
;									"DFRT:07" "07"
;								)
								;br.
							)
						)
						;br
;						(brkstep1
;							'("dfDat") (list dfDat)
;							"DFRT:08" "08"
;						)
						;br..
						(setq dfCon1 (+ dfCon1 1))
					);While..
					;br
;					(brkstep1
;						'("dfDat" "dfRuta" "dfNom")
;						(list dfDat dfRuta dfNom)
;						"DFRT:08" "08"
;					)
					;br..
					(cond
						(
							(not (= dfDat nil))
							(escr1
								(txl1 dfDat dfPrec ",")
								dfNom dfEx dfRuta 0
							)
						)
					)
				);Cond Ruta:.Datos T..
			); Cond..
		);Cond type T..
	)
	;br
;	(brkstep1
;		'("dfDAt") (list dfDat)
;		"DFRT:09" "09"
;	)
	;br..
	(setq dfDat dfDat)
)





;:PROYECTO:
;;	<Lisp>
;:CLASIFICACION:
;;	<TBL>
;:FUNCION / TITULO: REG0. Crea un registro el número de columnas ID y valores nulos.
;:SINTAXIS:
;;	<(REG0 [ID] [NumCol] [Valor Nulo])>
;:DESCRIPCION:
;;	<<
;;		REG0. A partir de la definición de un ID Numero total de campos
;;		(columnas) y valor nulo:. una lista registro de valores
;;		nulos:. excepto el ID
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;		ReRes. Registro con valores Nulos
;;		<(ID Nulo ...)>
;;		El tamaño del registro es el que se especifica en el argumento.
;;	>>
;:ARGUMENTOS:
;;	<<
;;		1. ReId0. Nombre de ID
;;		<"xx...">
;;		2. ReCol0. Número de columnas (contando con el campo ID)
;;		<INT>
;;		3. ReNul0. Valor Nulo 
;;		<"xx....">
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Reg0
	(reId0 reCol0 reNul0 /
		reId reCol reNul
	)
;	(setq reId nil reCol nil reNul nil)
	;br
;	(brkstep1
;		'("reId0" "reCol0" "reNul0") (list reId0 reCol0 reNul0)
;		"REG0:00" "00"
;	)
	;br..
	(cond
		(;Cond type T
			(and
				(= (type ReId0) 'STR)
				(= (type reCol0) 'INT)
				(= (type reNul0) 'STR)
			)
			(setq reId reId0
				reCol reCol0
				reNul reNul0
			)
			;br
;			(brkstep1
;				'("reId" "reCol" "reNul") (list reId reCol reNul)
;				"REG0:01" "01"
;			)
			;br..
			(setq reRes (list reId))
			(repeat (- reCol 1)
				(setq reRes (append reRes (list reNul)))
			)
			;br
;			(brkstep1
;				'("reRes") (list reRes)
;				"REG0:02" "02"
;			)
			;br..
		);Cond type T..
	)
	(setq reRes reREs)
);REG0..
	
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<PH>
;:FUNCION / TITULO:<Grab01. Graba rutas y archivos en el archivo principal de rutas (RUTAS)>
;:SINTAXIS:
;;	<(GRAB01 [Ruta] [NombreArchivo] [Extension] [Columna] [Lista Carpetas] [Lista Archivos]>
;:DESCRIPCION:
;;	<<
;;	GRAB01. A partir de la definición de lista de archivos;
;;	y lista de carpetas a definir:. graba las rutas por medio
;;	de la interface (DEFR01).
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	grRes. Datos de la tabla del archivo principal de rutas
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. grRt0, Ruta donde se encuentra el archivo principal
;;		de ruta (opcional):. sino se define:. toma la ruta de
;;		autoguardado.
;;	2. grNm0. Nombre del archivo principal de rutas (opcional):.
;;		sino se define el nombre es "RUTAS"
;;	3.grEx0. Extensión del archivo principal de rutas (opcional):.
;;		sino se define la extensión es "csv".
;;	4.grCol0. Nombre de la columna donde se va a grabar la ruta
;;		(opcional):. sino se define el nombre de la columna es "RUTA"
;;	5. grC0. Lista de carpeta para registrar con el siguiente
;;		formato
;;		1. Id de ruta
;;		2. Mensaje de solicitud
;;		<((ID MSG) (...) ...)>
;;	6.grA0. Lista de archivos para registrar con el siguiente
;;		formato
;;		1.ID de archivo
;;		2.Nombre de archivo
;;		3.Extensión
;;		4.Mensaje de solicitud
;;		<((ID NOM EXT MSG) (...)...)>
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Grab01
	(grRt0 grNm0 grEx0 grCol0 grC0 grA0 /
		grRt grNm grEx grCol grC grA
		grLs grCon grNul grDat
	)
;	(setq grRt nil grNm nil grEx nil grCol nil grC nil grA nil
;		grLs nil grCon nil grNul nil grDat nil
;	)
	;br
;	(brkstep1
;		'("grRt0" "grNm0" "grEx0" "grCol0" "grC0" "grA0")
;		(list grRt0 grNm0 grEx0 grCol0 grC0 grA0)
;		"GRAB01:00" "00"
;	)
	;br..
	(setq
		grRt grRt0
		grNm grRt0
		grEx grEx0
		grCol grCol0
		grC grC0
		grA grA0
	)
	;br
;	(brkstep1
;		'("grRt" "grNm" "grEx" "grCol" "grC" "grA")
;		(list grRt grNm grEx grCol grC grA)
;		"GRAB01:01" "01"
;	)
	;br..
	;;;;;;;DEFINICIONES;;;;;;;;;;;;;;;;(0)
	(setq grNul "non")
	(if (= grNm nil) (setq grNm "RUTAS"))
	(if (= grEx nil) (setq grEx "csv"))
	(if (= grCol nil) (setq grCol "RUTA"))
	;;;;;;;DEFINICIONES;;;;;;;;;;;;;;;;(1)
	;br
;	(brkstep1
;		'("grNul" "grNm" "grEx" "grCol" "grA" "grC")
;		(list grNul grNm grEx grCol grA grC)
;		"GRAB01:02" "02"
;	)
	;br..
	(cond
		(
			(not (= grA nil))
			(setq grCon 0)g
			(while (< grCon (length grA))
				(setq grLs
					(append
						grLs
						(list
							(list "A"
								(nthx (list grCon 3) grA)
								(nthx (list grCon 0) grA)
								(nthx (list grCon 1) grA)
								(nthx (list grCon 2) grA)
							)
						)
					)
				)
				(setq grCon (+ grCon 1))
				;br
;				(brkstep1
;					'("grLs") (list grLs)
;					"GRAB01:01" "01"
;				)
				;br..
			)
		)
	)
	(cond
		(
			(not (= grC nil))
			(setq grCon 0)
			(while
				(< grCon (length grC))
				(setq grLs
					(append grLs
						(list
							(list
								"C"
								(nthx (list grCon 1) grC)
								(nthx (list grCon 0) grC)
								nil
								nil
							)
						)
					)
				)
				(setq grCon (+ grCon 1))
				;br
;				(brkstep1
;					'("grLs") (list grLs)
;					"GRAB01:02" "02"
;				)
				;br..
			)
		)
	)
	(cond
		(
			(not (= grls nil))
			(setq grDat
				(DfRt grRT grNm grEx grLs grCol "non" 3 ())
			)
		)
	)
	;br
;	(brkstep1
;		'("grDat") (list grDat)
;		"GRAB01:03" "03"
;	)
	;br..
	(setq grDat grDat)
);GRAB01..
;:PROYECTO:
;;	<Lisp>
;:CLASIFICACION:
;;	<PH>
;:FUNCION / TITULO:<VERE01. Extrae los datos del archivo principal de rutas (verificacion)>
;:SINTAXIS:
;;	<(VERE01 [Lista de Rutas])>
;:DESCRIPCION:
;;	<<
;;		VERE01. Verifica el archivo principal de rutas con valores predeterminados, en caso de que no exista lo crea con las rutas del argumento:. Extrae los datos finales del archivo
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	v1Res. Datos del archivo principal de rutas
;;	<((ID RUTA NOM TYPE EXT PROY CLS CLAS EXE) (..... C:\XXX\...  ....) (....) ...))>	
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1.V1Ls0. Lista de rutas para grabar
;;		<((ID MENSAJE) (...) ...))>
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>VALORES PREDEFINIDOS:.
;;	Nombre de archivo principal de rutas: "RUTAS"
;;	Tipo de archivos: csv
;;	Localización de archivo principal de rutas: Ruta de autoguardado
;;	Columna de rutas: RUTA
;;>>
;:ESTADO:
;;<<
;;	>En curso
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Vere01
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
;:PROYECTO:
;;	<Lisp>
;:CLASIFICACION:
;;	<PH>
;:FUNCION / TITULO: <Vere02. Extrae los datos de un archivo indicado en el archivo principal de rutas (con verificación)>
;:SINTAXIS:
;;	<(Vere02 [DatosRuta] [NomArchivo] [ListaArchivoGrab] )>
;:DESCRIPCION:
;;	<<
;;	Vere02. Extrae la información de un archivo indicado
;;		en el archivo de rutas verificando si existe:.
;;		sino existe solicita al usuario que seleccione el archivo.
;;		Graba el nombre y ruta del archivo final en el archivo
;;		principal de rutas
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	v2Res. Datos del archivo seleccionado
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. v2Dat0. Archivos de rutas 
;;	2. v2Ar0. Nombre de archivo
;;	3. v2Ls0. Lista  ID Mensaje de solicitud para nueva ruta
;;		en caso de no estar grabada.
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Vere02
	(v2Dat0 v2Ar0 v2Ls0 /
		v2DAt v2Ar v2Ls
		v2Res
	)
;	(setq v2Dat nil v2Ar nil v2Ls nil
;		v2Res nil
;	)
	;br
;	(brkstep1
;		'("v2Dat0" "v2Ar0" "v2Ls0")
;		(list v2Dat0 v2Ar0 v2Ls0)
;		"Vere02:00" "00"
;	)
	;br..
	(cond
		(
			(and
				(= (lsType V2Dat0) 'LIST)
				(= (type v2Ar0) 'STR)
				(= (lsType v2Ls0) 'STR)
			)
			(setq
				v2Dat v2Dat0
				v2Ar v2Ar0
				v2LS v2Ls0
			)
			;br
;			(brkstep1
;				'("v2Dat" "v2Ls" "v2Res")
;				(list v2Dat v2Ls v2Res)
;				"Vere02:01" "01"
;			)
			;br..
			(if
				(vere
					(strcat
						(term
							(qnth02 v2Dat "BDATOS" "RUTA" 0.001)
						)
						v2Ar ".csv"
					)
				)
				(progn
					(setq v2Res
						(lec01 2
							(strcat
								(term
									(qnth02 v2Dat "BDATOS" "RUTA" 0.001)
								)
								v2Ar
								".csv"
							)
							"non"
						)
					)
				)
				(progn
					(setq v2Dat
						(grab01
							() () () "RUTA" ()
							(list
								(list (nth 0 v2Ls) v2ar "csv"
									(nth 1 v2Ls)
								)
							)
						)
					)
					(cond
						(
							(not (= v2Dat nil))
							(setq v2Res
								(lec01 2
									(Qnth02
										v2Dat (nth 0 v2Ls) "RUTA" 0.001
									)
									"non"
								)
							)
						)
					)
				)
			)
			;br
;			(brkstep1
;				'("v2Dat" "v2Res") (list v2DAt v2Res)
;				"Vere02:01" "01"
;			)
			;br..
			(setq v2Res v2Res)
		)
	)
);Vere02..
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<TXT>
;:FUNCION / TITULO: Sepa02. Separa una cadena de texto mediante un carcter de separación 
;:SINTAXIS:
;;	<(SEPA02 [CadenaTXT] [Caracter])>
;:DESCRIPCION:
;;	<<
;;	SEPA02. A partir de la definición de un caracter de
;;		separación separa una cadena de texto en partes
;;		donde se encuentre dicho carcter.
;;	>>
;:EJEMPLO:
;;	<<
;;
;;	>>
;:DEVUELVE:
;;	<<
;;	seRes.- (lista de cadenas de cadenas de texto)
;;	>>
;:ARGUMENTOS:
;;	<<
;;	> 1. seCad0. Cadena de texto
;;	> 2. seCar0. Caracter de separación
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Sepa02
	(
		seCad0 seCar0 /
		seCad seCar
		seRes seLs
	)
;	(setq seCad nil seCar nil
;		seRes nil seLs nil
;	)
	;br
;	(brkstep1
;		'("seCad0" "seCar0") (list seCad0 seCar0)
;		"SEPA01:00" "00"
;	)
	;br..
	(cond
		(;cond typle T
			(and
				(equal (type seCad0) 'STR)
				(equal (type seCar0) 'STR)
			)
			(setq seCad seCad0
				seCar seCar0
			)
			;br
;			(brkstep1
;				'("seCad" "seCar") (list seCad seCar )
;				"SEPA02:01" "01"
;			)
			;br..
			(setq seLs (sepa seCad seCar))
			;br
;			(brkstep1
;				'("seCad" "seLs") (list seCad seLs)
;				"SEPA02:02" "02"
;			)
			;br..
			(while
				(< 1 (length seLs))
				(setq seRes
					(append (list (nth 1 seLs)) seRes)
				)
				(setq seLs (sepa (nth 0 seLs) seCar))
				;br
;				(brkstep1
;					'("seLs" "seRes") (list seLs seRes)
;						"SEPA02:03" "03"
;				)
				;br..
			)
			(setq seRes (append seLs seRes))
			;br
;			(brkstep1
;				'("seRes" "seLs") (list seRes seLs)
;				"SEPA02:04" "04"
;			)
			;br..
		); cond type T
	)
	(setq seRes seRes)
); SEPA02..
;;PROYECTO: Lisp
;;CLASIFICACION:LIST
;;NOMBRE DE ARCHIVO: LispLIST_JO2D.lsp
;;OBJETO / TITULO:JO2 (Ditapsa). Une dos listas en una sola
;;SINTAXIS:(jo2 [Lista1] [Lista2])
;;DESCRIPCION:JO2 (Ditapsa). Une dos listas sencillas en una
;; estructurada siempre y cuando ambas tengan la misma dimension
;;	>
;;DEVUELVE: lista con los elementos unidos:
;;		ejemplo:
;;		Lista1.- (a b c d)
;;		Lista2.- (1 2 3 4)
;;		= ((a 1) (b 2) (c 3) (d 4))
;;ARGUMENTOS
;;	1. lst10. Primera lista
;;	<(x x ...)>
;;	2. lst20. Segunda lista
;;	<(x x ...)>
;;DEPENDIENTES
;;	< >
;;ANOTACIONES
;;	> Esta funcion es usada para el Proyecto de Ditapsa despues se cambio
;		con el mismo nombre pero diferentes argumentos
;;	> Si las listas no tienen el mismo tamaño manda un mensaje de
;;		error.
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun jo2d
	(lst10 lst20 /
		lst1 lst2
		cnt pst ele1 leun
	)
;	(setq lst1 nil lst2 nil
;		cnt nil pst nil ele1 nil leun nil
;	)
	;;
;	(brkstep1 '("lst10" "lst20") (list lst10 lst20) "00" "JO2")
	;;
	(cond
		(
			(and
				(= (type lst10) 'LIST)
				(= (type lst20) 'LIST)
			)
			(setq lst1 lst10
				lst2 lst20
			)
			(cond
				(
					(not (= (length lst1) (length lst2)))
					(alert "JO2:\nLAS LISTAS TIENEN DIFERENTE DIMENSION")
				)
				(
					(= (length lst1) (length lst2))
					(setq cnt 0)
					(while (< cnt (length lst1))
						(setq ele1 (list (nth cnt lst1) (nth cnt lst2)))
						(setq leun (append leun (list ele1)))
						(setq cnt (+ cnt 1))
					)
				)
			)
		)
	)
	(setq leun leun)
)
;
;;
;;;
;;;;
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<POL>
;:FUNCION / TITULO: DsPol. Distancia total de una polilinea o un conjunto de coordenadas
;:SINTAXIS:
;;	<(DsPol [Ename] [ListaCoordenadas])>
;:DESCRIPCION:
;;	<<
;;		DsPol. A partrir de la definicion del nombre de entidad
;;		de una polilinea o una lista de coordenadas:. 
;;		Calcula su distancia.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	
;;	>>
;:ARGUMENTOS:
;;	<<
;;		1. dsEname0. Ename de polilinea
;;		2.dsList0. Lista de coordenadas en orden para calculo
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun DsPol
	(dsEname0 dsList0 /
		dsEname dsList
		dsCont dsDsr
	)
	(setq dsEname nil dsList nil
		dsCont nil dsDsr nil
	)
	;br
;	(brkstep1
;		'("dsEname0" "dsList0") (list dsEname0 dsList0)
;		"DSPOL:00" "00"
;	)
	;br..
	(cond
		(	;Cond Type T
			(or
				(= (type dsEname0) 'ENAME)
				(= (type dsList0) 'LIST)
			)
			(setq dsEname dsEname0
				dsList dsList0
			)
			;br
;			(brkstep1
;				'("dsEname" "dsList") (list dsEname dsList)
;				"DSPOL:01" "01"
;			)
			;br..
			(setq dsCont 1
				dsDsr 0
			)
			(cond
				(
					(not (= dsEname nil))
					(setq dsList (mapcar 'cdr (lscod dsEname (list 10))))
					;br
;					(brkstep1
;						'("dsList") (list dsList)
;						"DSPOL:02" "02"
;					)
					;br..
				)
			)
			(cond
				( ;Cond type list
					(not (= dsList nil))
					(while
						(< dsCont (length dsList))
						(setq dsDsr
							(+ dsDsr
								(distance
									(nth (- dsCont 1) dsList)
									(nth dsCont dsList)
								)
							)
						)				
						(setq dsCont (+ dsCont 1))
					)
				)
			)
			;br
;			(brkstep1
;				'("dsDsr") (list dsDsr)
;				"DSPOL:03" "03"
;			)
			;br..
		);cond type T..
	);Cond..
	(setq dsDsr dsDsr)
)
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<MAIN>
;:FUNCION / TITULO:<Qgps. Muestra los valores de los atributos (XData) de un elemento seleccionado>
;:SINTAXIS:
;;	<C:QGSP>
;:DESCRIPCION:
;;	<<
;;		Qgps: Ejecutable que muestra los atributos (XData)
;;		de la aplicación GSP_TOOLS contenga una guardados
;;		una entidad
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	
;;	>>
;:ARGUMENTOS:
;;	<<
;;
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun c:QGSP ( / nomiap miele conta speach pas1)
	(setq nomiap "GSP_TOOLS")
	(setq miele (noment (ssget)))
	(setq miele (nth 0 miele))
	;(brkstep '("miele") "01" "MSJ")
	(setq miele (extraxr miele nomiap))
	;(brkstep '("miele") "02" "MSJ")
	(setq conta 0
		pas1 0
	)
	;(brkstep '("miele" ) "01" "QATT")
	(cond
		(
			(not (= miele nil))
			(while 
				(< conta (length miele))
				(cond
					(
						(= pas1 0)
						(setq pas1 1
							speach
							(strcat
								(nth 0 (nth conta miele)) ": "
								(nth 1 (nth conta miele)) "\n"
							)
						)
						;(brkstep '("speach") "02a" "QATT")
					)
					(
						(= pas1 1)
						(setq speach
							(strcat
								speach
								(nth 0 (nth conta miele)) ": "
								(nth 1 (nth conta miele)) "\n"
							)
						)
					)
				)
				(setq conta (+ conta 1))
			)
			;(brkstep '("speach") "03" "QATT")
		)
		(
			(= miele nil)
			(setq speach "LA ENTIDAD NO CONTIENE\nINFORMACION DE CUANTIFICACION")
			;(brkstep '("speach") "04B" "QATT")
		)
	)
	(alert speach)
)
;
;;
;;;
;;;;
;:PROYECTO:
;;	<>
;:CLASIFICACION:
;;	<>
;:FUNCION / TITULO:
;:SINTAXIS:
;;	<>
;:DESCRIPCION:
;;	<<
;;
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	
;;	>>
;:ARGUMENTOS:
;;	<<
;;
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun c:lot (/ mip mis sal bonEnt)
	(setq mip 1)
	(while
		(not (= mip nil))
		(setq mip (getpoint "SELECCIONA EL LOTE"))
		
		(princ "\nSELECCIONA EL NUMERO Y NIVEL" )
		(setq mis (ssget))
		(command "boundary" mip "")
		(setq bonEnt (entlast))
		(setq mis (ssadd bonEnt mis))
		(command "group" mis "")
	)
)
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<LEV>
;:FUNCION / TITULO:InDat. Extrae los datos de levantamiento y ejecuta las formulas correspondientes
;:SINTAXIS:
;;	<(InDat [AnguloIns] [AnguloMedio][CoorIns][CoorMed][TBLFormula][TBLRutas][TBLlevantamiento][TBLBlockEq][RegNth])>
;:DESCRIPCION:
;;	<<
;;		InDat. A partir de la definición de tablas,
;;			rutas y datos de levantamiento, crea la lista de
;;			ejecución para dibujo e introducción de datos
;;			en el plano.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;; inReL. Lista de argumentos para la ejecución
;;  de las formulas y funciones para dibujo del
;;	levantamiento en el plano.
;;<(NomFormula Tipo:xx nivel:xxx Calle:xxx Offset:xxx
;;	NumeroLote:xxx bis:xx Lineas existentes:xxx
;;	crecimiento:xxx Anotaciones:xxx)>
;;	>>
;:ARGUMENTOS:
;;	<<
;;		1. inAin0: Angulo de inserción en radianes
;;		2. inMd0: Angulo medio de inserción en radianes
;;		3. inCoin0: Coordenadas Inserción
;;		4. inCoMd0: Coordenadas de  inserción media
;;		5. inTbF0: Tabla de formulas por Campos
;;		6. inTBRt0:Tabla de rutas de trabajo
;;		7. inTbLv0:Tabla de Levantamiento
;;		8. inTblb0:Tabla de bloques equivalentes
;;		9. inEl0: Registro de datos elemento
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun inDat
	(inAin0 inMd0 inCoin0 inCoMd0 inTbF0 inTbRt0 
		inTbLv0 inTblb0 inEl0 /	
		
		inAin inMd inCoin inCoMd inTbF inTbRt inTbLv
		inTblb inReg
		inLCmd inEl inFatt inCon0 inFatv inH inFatt1
		inff inForm inFtip inFval inCmd inAtd inLCmd
		inRExe inStr inCmd0  inTbr0 inCont
	)
;	(setq inAin nil inMd nil inCoin nil inCoMd nil
;		inTbF nil inTbRt nil inTbLv nil inTblb nil
;		inReg nil
;		inLCmd nil inEl nil inFatt nil inCon0 nil
;		inFatv nil inH nil inFatt1 nil inff nil inForm nil
;		inFtip nil inFval nil inCmd nil inAtd nil inLCmd nil
;		inRExe nil inStr nil inCmd0 nil inTbr0 nil inCont nil
;	)
	;br
;	(brkstep1
;		'("inAin0" "inMd0" "inCoin0" "inCoMd0" "inTbF0"
;			"inTbRt0" "inTbLv0"  "inTblb0" "inEl0")
;			(list inAin0 inMd0 inCoin0 inCoMd0 inTbF0
;				inTbRt0 inTbLv0  inTblb0 inEl0
;			)
;		"INDAT:00" "00"
;	)
	;br..
	(cond
		(;Cond Type T
			(and
				(= (numberp inAin0) t)
				(= (numberp inMd0) t)
				(= (Lstype inCoin0) "NUM")
				(= (LsType inCoMd0) "NUM")
				(= (type inTbF0) 'LIST)
				(= (type inTbRt0) 'LIST)
				(= (type inTbLv0) 'LIST)
				(= (type inTblb0) 'LIST)
				(= (type inEl0) 'LIST)
			)
			(setq inAin inAin0
				inMd inMd0
				inCoin inCoin0
				inCoMd inCoMd0
				inTbF inTbF0
				inTbRt inTbRt0
				inTbLv inTbLv0
				inTblb inTblb0
				inEl inEl0
			)
			;br
;			(brkstep1
;				'("inAin" "inMd" "inCoin" "inCoMd" "inTbF"
;					"inTbRt" "inTbLv" "inTblb" "inEl"
;				)
;				(list inAin inMd inCoin inCoMd inTbF
;					inTbRt inTbLv inTblb inEl
;				)
;				"INDAT:01" "01"
;			)
			;br..
			(setq
				inH (nth 0 inTbLv)				;;ENCABEZADO
				inTbr0 (jo2d inH inEl);;lISTA DE DATOS DE RENGLON
			)
	;;;;;;;;;;;;;ARGUMENTO DE ATRIBUTOS;;;;;;(0)
			(setq inFatt
						(lnpo4 "at" inTbF 1 1 0.001)
			)
			;br
;			(brkstep1
;				'("inFatt" "inEl" "inH" "inTbr0")
;				(list inFatt inEl inH inTbr0)
;				"INDAT:02" "02"
;			)
			;br..
			(if
				inFatt
				(progn ;progn inFatt T
					(setq inCon0 0)
					(while
						(< inCon0 (length inFatt))
						(setq inFAtv
							(nth
								(nth 0
									(qnth00 inh ;;;;;;;;;;;QNTH==
										(nthx (list inCon0 0) inFatt)
										0.001
									)
								)
								inEl
							)
						)
						;br
;						(brkstep1
;							'("incon0" "inFAtv") (list incon0 inFAtv)
;							"INDAT:03" "03"
;						)
						;br..
						(cond
							(
								(= (type inFAtv) 'REAL)
								(setq inFatv (rtos inFatv))
							)
							(
								(= (type inFatv) 'INT)
								(setq inFatv (itoa inFatv))
							)
						)
						;br
;						(brkstep1
;							'("inFatv") (list inFaTv)
;							"INDAT:04" "04"
;						)
						;br..
						(if
							(not (equal inFatV nil))
							(progn
								(cond
									(;cond primera
										(= inCon0 0)
										(setq inFatt1
											(strcat
												(nthx (list inCon0 0)
													inFatt
												) ":"
												inFatv "_"
											)
										)
									);cond Primera..
									(;cond demas
										(< 0 inCon0)
										(setq inFatt1
											(strcat
												inFatt1
												(strcat
													(nthx (list inCon0 0)
														inFatt
													) ":"
													inFatv "_"
												)
											)
										)
									);cond demas..
								);cond
							)
						)
						(setq inCon0 (+ inCon0 1))
						;br
;						(brkstep1
;							'("inFatt1") (list inFAtt1)
;							"INDAT:05" "05"
;						)
						;br..
					);while..
					;br
;					(brkstep1
;						'("inFatt1") (list inFatt1)
;						"INDAT:06" "06"
;					)
					;br..
					(if
						inFatt1
						(progn
							(setq inFatt
								(substr inFatt1 1
									(- (strlen inFatt1) 1)
								)
							)
							(setq inFatt1 nil)
						)
					)
				) ;progn inFat T..
			); if..
			;br
;			(brkstep1
;				'("inFatt") (list inFatt)
;				"INDAT:07" "07"
;			)
			;br..
			(setq inFatt inFatt)
		;;;;;;;;;;;;;;;;;;ARGUMENTO DE ATRIBUTOS;;;;;;;;;;;;;(1)
		;;;;;;;;;;;;;;FORMULA TIPO Y VALOR;;;;;;;;;;;;;(0)
			(setq inff
				(lnpo4 "at" inTbF 1 0 0.001)
			);Extaccion atributos (solo formulas)
			;br
;			(brkstep1
;				'("inFf") (list inFF)
;				"INDAT:08" "08"
;			)
			;br..
			(cond
				(;cond inFF T
					(not (= inFF nil))
					(setq inCon0 0)
					(while
						(< inCon0 (length inff))
						(setq inForm
							(nthx (list inCon0 1) inff)
							inFtip
							(nthx (list inCon0 0) inff)
						)
						;br
;						(brkstep1
;							'("inFF" "inFtip") (list inFF inFtip)
;							"INDAT:09" "09"
;						)
						;br..
						(setq
							inFval
							(nth
								(nth 0
									(qnth inH
										inFtip
										0.001
									)		
								)
								inEl
							)
							inCon0 (+ inCon0 1)
						)
						(setq inCmd
							(append inCmd
								(list
									(list inForm inFtip inFval)
								)
							)
						)
						;br
;						(brkstep1
;							'("inForm" "inFtip" "inFval" "inCmd")
;							(list inForm inFtip inFVal inCmd)
;							"INDAT:10" "10"
;						)
						;br..
					);While..
					(setq inCmd
						(lnpo4 "non" inCmd 2 0 0.001)
					)
					;br
;					(brkstep1
;						'("inCmd") (list inCmd)
;						"INDAT:11" "11"
;					)
					;br..
				);cond inFF T..
			)	
			;;;;;;;;;;;;;;;;;;;FORMULA;;;;;;;;;;;;;;;;;;;;(1)
			;=incmd
			;;;;;;;;;;;;;;;;;;COORDENADAS;;;;;;;;;;;;;;;;;(0)
			(setq inAtd
				(strcat
					"pins:"
					(cortxt inCoin)
					"_"
					"pmed:"
					(cortxt inCoMd)
					"_"
					"anin:"
					(rtos (dtr2 inAin))
					"_"
					"anmed:"
					(rtos
						(round1
							(dtr2 inMd)
							3
						)
					)
				)
			)
			;br
;			(brkstep1
;				'("inAtd") (list inAtd)
;				"INDAT:12" "12"
;			)
			;br..
			;;;;;;;;;;;;;;;;;COORDENADAS;;;;;;;;;;;;;;;;(1)
			;=inAtd
			;;;;;;;;;;;;;;;INTEGRACION DE COMANDO;;;;;;;;(0)
			(setq inCon0 0)
			(while
				(< inCon0 (length inCmd))
				(setq inLCmd
					(append
						inLCmd
						(list
							(append
								(nth inCon0 inCmd)
								(list
									inFatt
									inAtd
								)
							)
						)
					)
				)
				(setq inCon0 (+ inCon0 1))
			)
			;br
;			(brkstep1
;				'("inLCmd") (list inLCmd)
;				"INDAT:14" "14"
;			)
			;br..
			;;;;;;;;;;;;;;;INTEGRACION DE COMANDO;;;;;;;;(1)..
			;;;;;;;;;;;;;;EJECUCION DE COMANDO;;;;;;;;;;;(0)
			(setq inCont 0)
			(while
				(< inCont (length inLCmd))
				(setq inCmd0 (nth inCont inLCmd))
				;br
;				(brkstep1
;					'("inCmd0") (list inCmd0)
;					"INDAT:15" "15"
;				)
				;br..
				(setq inRExe
					(nthx (list 0 1) (lnpo4 "FUNCIONES" inTbRt 0 1 0.0001))
				)
				;br
;				(brkstep1
;					'("inRExe") (list inRExe)
;					"INDAT:16" "16"
;				)
				;br..
				(setq inStr
					(strcat
						inRExe
						"LispEXE_"
						(nthx (list inCont 0) inLCmd)
						".lsp"
					)
				)
				;br
;				(brkstep1
;					'("inStr") (list inStr)
;					"INDAT:16" "16"
;				)
				;br..
				(if
					inRExe
					(progn
						(load inStr)
					)
				)
				;br
;				(brkstep1
;					'("inRexe" "incont" "lopre")
;					(list inRExe inCont lopre)
;					"INDAT:17" "17"
;				)
				;br..
				;(command "(lot1)")
				(setq inCont (+ inCont 1))
			)
			;;;;;;;;;;;;;;EJECUCION DE COMANDO;;;;;;;;;;;(1)..
			(setq inLCmd inLCmd)
			(setq loPre loPre)
		);Cond type T..
	);Cond ..
) ;InDat..
;;PROYECTO: Lisp
;;CLASIFICACION: ATT
;;OBJETO / TITULO: CAMTAG. Cambia el valor de una atributo a un grupo de blocks
;;DESCRIPCION:
;;	> CAMTAG. Apartir de una lista de nombres de entidad de blocks. Cambia el
;;	valor de un TAG determinado en todos los blocks. 
;;DEVUELVE:
;;	> 
;;ARGUMENTOS
;;	1. lsnb0. Lista de nombre de blocks
;;	<(ENAME...)>
;;	2. tga0. Nombre del TAG
;;	<"xxx">
;; 3. vtga0. Nuevo valor del TAG.
;; <"xxx">
;;DEPENDIENTES
;;	> NXX1 (); 
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun camtag
	(lsnb0 tga0 vtga0 /
		lsnb tga vtga
		cnna tga1 nnb1 attn attn1
	)
;	(setq 
;		lsnb nil tga nil vtga nil
;		cnna nil tga1 nil nnb1 nil attn nil attn1 nil
;	)
;	(brkstep1 '("lsnb0" "tga0" "vtga0") (list lsnb0 tga0 vtga0) "00" "CAMTAG")
	(setq lsnb lsnb0
		tga tga0
		vtga vtga0
	)
	(setq cnna 0
		tga1 (cons 2 tga)
		vtga (cons 1 vtga)
	)
;	(brkstep1 '("cnna" "tga1" "vtga") (list ccna tga1 vtga) "01" "CAMTAG")
	(while (< cnna (length lsnb))
		(setq nnb1 (nth cnna lsnb))
;		(brkstep1 '("nnb1") (list nnb1) "01a" "CAMTAG")
		(setq attn (nxx1 nnb1 '(1 2))
			attn1 (exid attn tga1)
		)
;		(brkstep1 '("nnb1" "attn" "attn1") (list nnb1 attn attn1) "02" "CAMTAG")
		(cond
			(
				(not (= attn1 nil))
				(setq attn1 (nth 0 (nth 0 attn1)))
				(cam1 (list attn1) vtga)
			)
		)
		(setq cnna (+ cnna 1))
	)
)
;;PROYECTO: Lisp
;;CLASIFICACION: LIST
;;OBJETO: LNPO2
;;	Extrae o elmimina las listas que
;;	correspondan al elemento indice y
;;	posicion definidos en los argumentos con la precision definida en el
;;	utlimo argumento.
;;DEVUELVE:
;;	En modo 0:
;;	( (XX XX XX ...) (...) ...)
;;	Todos los elementos de la lista inicial, menos
;;	los que correspondan a los valores de los argumentos
;;	En modo 1:
;;	( (xx EleInd xx ...) (xx EleInd xx xx ...) (...) ...)
;;	Todos los elemenento de la lista inicial que correspondan
;;	a los valores de los argumentos
;;ARGUMENTOS:
;;	1. ELDI: Elemento indice: XXX
;;	Elemento que se va a buscar para la extraccion de la lista
;;	2. TRB: Lista de trabajo: ( (xx xx ...) (...)...)
;;	Lista donde se van a extraer los elementos
;;	3. PPOS: Posicion: Numero entero (NTH)
;;	(NTH) que debe de ocupar el elemento para extraerse o
;;	quitar de la lista
;;	4. MD: Modo de resultado:
;;	5. PRES: Presicion de comparacion
;;DEPENDIENTES: Ninguno
;;PR...
(defun lnpo2 (eldi trb pos md pres / ccn pps lmdin lmd lmf)
	;(brkstep '("eldi" "trb" "pos" "md" "pres") "00" "lnpo2")
  (setq ccn 0
	pps 0)
  (while
    (< ccn (length trb))
    (setq lmd (nth ccn trb)
		lmdin nil
	)
	;(brkstep '("pos" "eldi" "lmd") "01" "lnpo2")
	(cond
		(
			(or
				(and
					(equal (nth pos lmd) eldi pres)
					(= md 1))
				(and
					(not (equal (nth pos lmd) eldi pres))
					(= md 0))
			)
			(setq lmdin lmd)
		)
      )
    (cond
      (
       (not (= lmdin nil))
       (cond
	 (
	  (= pps 0)
	  (setq pps 1
		lmf (list lmdin))
	  )
	 (
	  (= pps 1)
	  (setq lmf (append lmf (list lmdin)))
	  )
	 )
       )
      )
    (setq ccn (+ ccn 1))
    )
  (setq lmf lmf)
  )
;
;;
;;;
;;;;
;:PROYECTO:
;;	<lisp>
;:CLASIFICACION:
;;	<TXT>
;:FUNCION / TITULO:Etag. Elimina el tag de una cadena de texto
;:SINTAXIS:
;;	<(Etag [Cadena de Texto] [Caracter])>
;:DESCRIPCION:
;;	<<
;;		Etag. Elimina un caracter o un grupo de caracteres
;;		dentro de una cadena de texto (tag "\t")
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	Etel. Cadena de texto sin el caracter.
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. etel0. Cadena de texto
;;	2. etCar0. Caracter o grupo de caracteres
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	> Probado solamente para caracter de TAG "\t"
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Etag
	(etEl0 etCar0 /
		etEl etCar
	)
;	(setq etel nil etCar nil)
	;br
;	(brkstep1
;		'("etEl0" "etCar0") (list etEl0 etCar0)
;		"etEl0:00" "00"
;	)
	;br..
	(cond
		(
			(and
				(= (type etEl0) 'STR)
				(= (type etCar0) 'STR)
			)
			(setq 
				etEl etEl0
				etCar etCar0
			)
			;br
;			(brkstep1
;				'("etEl" "etCar") (list etEl etCar)
;				"ETAG:01" "01"
;			)
			;br..
			(setq etEl (sepa02 etEl etCar)
				etEl (nth (- (length etEl) 1) etEl)
			)
			;br
;			(brkstep1
;				'("etel" "etcar") (list Etel etCar)
;				"Etag:02" "02"
;			)
			;br..
		)
	)
	(setq etEl etEl)
)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
;;PROYECTO:
;;<Lisp>
;;CLASIFICACION:
;;<TXT>
;;FUNCION / TITULO:
;;<MATCHTX.Verifica una subcadena dentro de otra>
;;SINTAXIS:
;;<(MATCHTX [SeccionTxt][CadenaCompleta][ModoBusqueda])>
;;DESCRIPCION:
;;<<
;;	A partir de la definicion de una seccion de texto y una cadena
;;	analiza si la seccion se encuentra dentro de la cadena
;;>>
;;EJEMPLO
;;<<
;;(setq pf2tx "Vendeme"
;;	pf2Cad "vendeme  esta pluma Vendeme"
;;	pf2Res (MatchTx pf2Tx pf2Cad 1)
;;)
;;<<
;;DEVUELVE:
;;<<
;;	maRes. T si la seccion de texto
;;	esta dentro de la cadena
;;	nil si la seccion de texto
;;	no se encuentra dentro de la cadena
;;>>
;;ARGUMENTOS
;;>>
;;1.matx0 fragmento de texto :.String.:
;;2.maCad0.Cadena de donde se busca el fragmento :.String..
;;3.maMd0.Modo de busqueda:
;;	0:Busqueda mayusculas y minuscula (como se escribio) :.INT.:
;;	1:Sin considerar mayusculas o minusculas
;;>>
;;DEPENDIENTES
;;<brkstep1>
;;LOCALIZACION
;;<Dropbox ... FuncionesLisp
;;HISTORIAL DE CORRECCIONES
;;<<
;;	22/06/02. Creado y Registrado
;;>>
;;ANOTACIONES
;;	>
;;ESTADO
;;<Terminado>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun MatchTx
	(maTx0 maCad0 maMd0 /
		maTx maCad maMd
		maCon1 maCon2
	)
;	(setq maTx nil maCad nil maMd nil
;		maCon1 nil maCon2 nil
;	)
	;br
;	(brkstep1
;		'("maTx0" "maCad0" "maMd0")
;		(list maTx0 maCad0 maMd0)
;		"MatchTx:00" "00"
;	)
	;br..
	(cond
		(;condType
			(and
				(= (type maTx0) 'STR)
				(= (type maCad0) 'STR)
				(= (type maMd0) 'INT)
			)
			(setq
				maTx maTx0
				maCad maCad0
				maMd maMd0
			)
			;br
;			(brkstep1
;				'("maTx" "maCad" "maMd")
;				(list maTx maCad maMd)
;				"MatchTx:01" "01"
;			)
			;br..
			(setq maCon1 1
				maCon2 1
			)
			(while
				(and
					(<= maCon1 (strlen maTx))
					(<= maCon2 (strlen maCad))
				)
				;br
;				(brkstep1
;					'("maCon1" "maCon2")
;					(list maCon1 maCon2)
;					"MatchTx:02" "02"
;				)
				;br..
				(setq maTx0 (substr maTx maCon1 1)
					maCad0 (substr maCad maCon2 1)
				)
				(if
					(= maMd 1)
					(progn
						(setq maTx0 (strcase maTx0)
							maCad0 (strcase maCad0)
						)
					)
				)
				;br
;				(brkstep1
;					'("maTx0" "maCad0")
;					(list maTx0 maCad0)
;					"MatchTx:02" "02"
;				)
				;br..
				(cond
					(
						(= maCad0 maTx0 )
						(setq maCon1 (+ maCon1 1))
						(setq maCon2 (+ maCon2 1))
					)
					(
						(not (= maTx0 maCad0))
						(setq maCon1 1
							maCon2 (+ maCon2 1)
						)
					)
				)
				;br
;				(brkstep1
;					'("maCon1" "maCon2")
;					(list maCon1 maCon2)
;					"MatchTx:03" "03"
;				)
				;br..
			);while
			(cond
				(
					(= maCon1 (+ (strlen maTx) 1))
					(setq maRes T)
				)
				(
					(not (= maCon1 (strlen maTx)))
					(setq maRes nil)
				)
			);cond..
		);condType..
	);cond..
);defun..
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<MDAT>
;:FUNCION / TITULO:Inx01. Crea una lista de inserción para a partir de un archivo XML
;:SINTAXIS:
;;	<(Inx01 [Archivo XML])>
;:DESCRIPCION:
;;	<<
;;		Inx01. A partir de un archivo xml, importa los datos
;;		y crea una lista de inserción en CAD.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;		inLsf. Lista de inserción con la siguiente
;;		estructura:
;;		( (NombreElemento (COO XY XY) (typeName=xx
;;			typeNameExternalxx valor) (....) ...)
;;		(...) ....) 
;;	>>
;:ARGUMENTOS:
;;	<<
;;		1. inAr0. Ruta nombre y extensión de archivo XML
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>Estructura de origen:
;;		<featureCollection>
;;		<featureMember>
;;		<feature>
;;		<coordinates>
;;		<property> typeName=xxxTypeNameMember=xxx>
;;			Valor
;;		</property>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)inAr nil
;	(inLs nil 
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun InX01
	(inAr0 /
		inAr
		inLs inCon0 inCon1 inEl0 inEl inEl2 inLsf
	)
;	(setq inAr nil
;		inLs nil inCon0 nil inCon1 nil inEl0 nil
;		inEl nil inEl2 nil inlsf nil
;	)
	;br
;	(brkstep1
;		'("inLs0") (list inLs0)
;		"INX:00" "00"
;	)
	;br..
	(cond
		( ;Cond type True
			(= (type inAr0) 'STR)
			(setq inAr inAr0)
			;br
;			(brkstep1
;				'("inAr") (list inAr)
;				"INX:01" "01"
;			)
			;br..
			(setq inLs
				(dat inAr)
			)
			;br
;			(brkstep1
;				'("inLs") (list inLs)
;				"INX01:02" "02"
;			)
			;br..
			(setq inEl (nth 12 inls))
			(setq inCon0 0
				inCon1 0
			)
			(while
				(< inCon0 (length inLs))
				(setq inEl (nth inCon0 inLs))
				;br
;				(brkstep1
;					'("inEl" "inCon0") (list inEl inCon0)
;					"INX01:02" "02"
;				)
				;br..
				(setq inEl (sepa02 (etag inEl "\t") "\"")
					inCon1 0
					inEl2 nil
				)
				;br
;				(brkstep1
;					'("inEl") (list inEl)
;					"INX01:03" "03"
;				)
				;br..
				(while ;while att
					(< inCon1 (length inEl))
					(setq inEl0 (nth inCon1 inEl))
					(cond
						( ;Espacion al principio
							(= (substr inEl0 1 1) " ")
							(setq inEl0
								(substr
									inEl0
									2
									(strlen inEl0)
								)
							)
							;br
;							(brkstep1
;								'("inEl0") (list inEl0)
;								"INX01:04" "04"
;							)
							;br..
						) ;Espacio al principio..
						(; Espacion al ultimo
							(= 
								(substr
									inEl0
									(strlen inEl0)
									1
								)
								" "
							)
							(setq inEl0
								(substr
									inEl0
									1
									(- 
										(strlen inEl0)
										1
									)
								)
							)
							;br
;							(brkstep1
;								'("inEl0") (list inEl0)
;								"in:05" "05"
;							)
							;br..
						);Espacion al ultimo..
					);Cond..
					;;;;;;;UNION ATRIBUTO VALOR;;;;;;;(0)
					(cond
						(
							(=
								(substr
									inEl0
									(strlen inEl0)
									1
								)
								"="
							)
							(setq inEl0
								(strcat
									inEl0
									(nth (+ inCon1 1) inEl)
								)
								inCon1 (+ inCon1 1)
							)
						)
					)
					;br
;					(brkstep1
;						'("inEl0") (list inEl0)
;						"INX01:06" "06"
;					)
					;br..
					;;;;;;;UNION ATRIBUTO VALOR;;;;;;;(1)
					(setq inEl2
						(append inEl2 (list inEl0))
					)
					(setq
						inCon1 (+ inCon1 1)
					)
					;br
;					(brkstep1
;						'("inEl0" "inEl2" "inCon1")
;						(list inEl0 inEl2 inCon1)
;						"INX01:07" "07"
;					)
					;br..
				);wHILE att..
				(setq inlsf (append inlsf (list inEl2))
					inCon0 (+ inCon0 1)
				)
				;br
;				(brkstep1
;					'("inlsf" "inCon0") (list inlsf incon0)
;					"INX01:08" "08"
;				)
				;br..
			);while lista final
			;br
;			(brkstep1
;				'("inlsf") (list inlsf)
;				"INX01:09" "09"
;			)
			;br..
		) ;Cond type True..	
	);Cond..
	(setq inLsf inLsf)
);;Inx01..
;
;;
;;;
;;;;
;:PROYECTO:
;;	<Lisp>
;:CLASIFICACION:
;;	<MDAT>
;:FUNCION / TITULO: Inx02. Agrupa la información generada por Inx01
;:SINTAXIS:
;;	<(Inx02 [ListaInx01])>
;:DESCRIPCION:
;;	<<
;;	Inx02. A partir de la lista generada por (Inx01)
;;	agrupa la información por entidad para ser insertada
;;	en el dibujo.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	agLsf. Lista agrupada por entidades:
;;		( (tipo (COO X1 ,Y1 X2,Y2)
;;			(typeNamed=xx TypeExternal=xx Valor) (...) ...)
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. agLs0. Lista de datos de entidad generada por Inx01
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	> Estructura de origen:
;;		<featureCollection>
;;		<featureMember>
;;		<feature>
;;		<coordinates>
;;		<property> typeName=xxxTypeNameMember=xxx>
;;			Valor
;;		</property>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Inx02
	(agLs0 /
		agLs
		agCon agCon1 agEl agls1 agCoo agProp agLsf agUni
	)
;	(setq agCon nil agCon1 nil agEl nil agls1 nil agCoo nil
;				agProp nil agLsf nil agUni nil
;	)
	;br
;	(brkstep1
;		'("agLs0") (list agLs0)
;		"INX02:00" "00"
;	)
	;br..
	(cond
		(;Cond type T
			(= (type agLs0) 'LIST)
			(setq agLs agLs0)
			;br
;			(brkstep1
;				'("agLs") (list agLs)
;				"INX:01" "01"
;			)
			;br..
			(setq agCon 0
				agEl (nth agCon agLs)
			)
			(while ;;Buscador coleccion
				(and
					(< agCon (length agLs))
					(= (matchtx "<FeatureCollection" (nth 0 agEl) 1) nil)
				)
				(setq agCon (+ agCon 1) 
					agEl (nth agCon agls)
				)
			)
			;br
;			(brkstep1
;				'("agEl") (list agEl)
;				"INX02:02" "02"
;			)
			;br..
			(cond
				(;Cond FeatureCollection T
					(= (matchtx "<FeatureCollection" (nth 0 agEl) 1) T)
					(setq agCon (+ agCon 1)
						agEl (nth agCon agLs)
					)
					;br
;					(brkstep1
;						'("agEl") (list agEl)
;						"INX02:03" "03"
;					)
					;br..
					(While ;Elemento
						(< agCon (length agLs))
						(setq agLs1 nil
							agCoo nil
							agPase 0
						)
						(setq agEl (nth agCon agLs))						
						;br
;						(brkstep1
;							'("agEl" "agCon") (list agEl agCon)
;							"INX02:04" "04"
;						)
						;br..
						(if ;;Tipo 
							(matchtx "<featureMember" (nth 0 agEl) 1)
							(progn
								(setq agls1
									(list
										(nth 1 (sepa02 (nth 0 agEl) "="))
									)
									agPase 1
								)
							)
						);br
;						(brkstep1
;							'("agEl" "agls1" "agPase") (list agEl agls1 agPase)
;							"INX02:05" "05"
;						)
						;br..
						(while ;att
							(and
								(< agCon (length agls))
								(= (matchtx "</featureMember>" (nth 0 agEl) 1) nil)
								(= agPase 1)
							)
							(setq agEl (nth agCon agLs))
							;br
;							(brkstep1
;								'("agEl" "agCon") (list agEl agCon)
;								"INX02:06" "06"
;							)
							;br..
							(cond
								(;Cond Coordinates
									(matchtx "<coordinates>" (nth 0 agEl) 1)
									(setq agCoo
										(sepa02
											(sutx
												(nth 0 agEl)
												'(("<" " ") (">" " "))
											)
											" "
										)
									)
									;br
;									(brkstep1
;										'("agCoo") (list agCoo)
;										"INX02:07" "07"
;									)
									;br..
									(setq agCoo (list "COO" (nth 2 agCoo) (nth 3 agCoo))
										agLs1 (append agLs1 (list agCoo))
									)
									;br
;									(brkstep1
;										'("agCoo") (list agCoo)
;										"INX02:08" "08"
;									)
									;br..
								);Cond Coordinates..
								(; Cond Property
									(matchtx "<property" (nth 0 agEl) 1)
									(setq agCon1 0
										agUni nil
									)
									(while ;Property
										(< agCon1 (length agEl))
										(cond
											( ;Cond TypeNameExternal
												(matchtx "typeNameExternal" (nth agCon1 agEl) 1)
												(setq agTypex (nth agCon1 agEl))
												;br
;												(brkstep1
;													'("agTypex") (list agTypex)
;													"INX02:10" "10"
;												)
												;br..
											) ;Cond TypeNameExternal..
											( ;Cond TypeName
												(matchtx "typeName" (nth agCon1 agEl) 1)
												(setq agType (nth 1 (sepa02 (nth agCon1 agEl) " ")))
												;br
;												(brkstep1
;													'("agType") (list agType)
;													"INX02:09" "09"
;												)
												;br..
											) ; Cond TypeName..
											(;Cond Units T
												(matchtx "units" (nth agCon1 agEl) 1)
												(setq agUni (sepa02 (nth agCon1 agEl) "=")
													agUni (nth 1 agUni)
												)
												(if (= agUni "percent")
													(setq agUni "%")
												)
												;br
;												(brkstep1
;													'("agUni") (list agUni)
;													"INX02:10" "10"
;												)
												;br..
											)
											( ;Cond Val
												(matchtx "/property>" (nth agCon1 agEl) 1)
												(setq agVal
													(sutx (nth agCon1 agEl) '((" " ":")))
													agVal
													(sutx agVal '(("<" " ") (">" " ")))
													agVal (sepa02 agVal " ")
												)
												;br
;												(brkstep1
;													'("agVal") (list agVal)
;													"INX02:12" "12"
;												)
												;br..
												(setq agVal (nth (- (length agVal) 3) agVal)
													agVal (sutx agVal '((":" " ")))
												)
												;br
;												(brkstep1
;													'("agVal") (list agVal)
;													"INX02:14" "14"
;												)
												;br..
												(if
													(= agVal nil)
													(setq agVal "-")
													(progn
														(cond
															(
																(not (= agUni nil))
																(setq agval (strcat agval agUni))
															)
														)
													)
												)
											) ;Cond Val..
										)
										(setq agCon1 (+ agCon1 1))
										;br
;										(brkstep1
;											'("agCon" "agLs1") (list agCon agLs1)
;											"INX02:15" "15"
;										)
										;br..
									);While Poperty..
									(setq agLs1
										(append agLs1 (list (list agType agTypex agVal)))
									)
									;br
;									(brkstep1
;										'("agLs1" "agType" "agTypex" "agVal")
;										(list agLs1 agType agTypex agVal)
;										"INX02:16" "16"
;									)
									;br..
								); Cond Property..
							)
							(setq agCon (+ agCon 1))
						);While att..
						(if
							(= agPase 1)
							(progn 
								(setq agLsf (append agLsf (list agls1)))
							)
								(setq agCon (+ agCon 1))
						)
						;br
;						(brkstep1
;							'("agCon" "agLsf") (list agCon agLsf)
;							"INX02:17" "17"
;						)
						;br..
					);While Elemento..
					;br
;					(brkstep1
;						'("agLsf") (list agLsf)
;						"INX02:18" "18"
;					)
					;br..
				);Cond FeatureCollection T..
			);Cond..
		);Cond type T..
	);Cond..
	(setq agLsf agLsf)
);Inx02..
;
;;
;;;
;;;;
;:PROYECTO:
;;	<Lisp	>
;:CLASIFICACION:
;;	<TXT>
;:FUNCION / TITULO:Lmatch. Extrae todos los elemento de una lista sencilla que coincidan con una cadena.
;:SINTAXIS:
;;	<(Lmatch01 [Lista Sencilla txt] [CadenaTxt])>
;:DESCRIPCION:
;;	<<
;;		Lmatch. A partir de una lista sencilla de cadenas
;;		de texto:.  extrae todos los elementos que coincidan
;;		una cadena.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	lmLf: Lista de cadenas de texto que coinciden con el
;;	elemento indice.
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. lmLs0. Lista sencilla de cadenas de texto
;;	<("xx" "xxx" "xx" ..)>
;;	2. lmTx. Cadena de texto indice
;;	<"xxx">
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun Lmatch01
	(lmLs0 lmTx0 /
		lmLs lmTx 
		lmCon0 lmLf lmEl
	)
;	(setq lmLs nil lmTx nil
;		lmCon0 nil lmLf nil  lmEl nil 	
;	)
	;br
;	(brkstep1
;		'("lmLs0" "lmTx0") (list lmLs0 lmTx0)
;		"LMATCH01:00" "00"
;	)
	;br..
	(cond
		(;cond Type T
			(and
				(= (type lmLs0) 'LIST)
				(= (type lmTx0) 'STR)
			)
			(setq lmLs lmLs0
				lmTx lmTx0
			)
			;br
;			(brkstep1
;				'("lmLs" "lmTx") (list lmLs lmTx)
;				"LMATCH01:01" "01"
;			)
			;br..
			(setq lmCon0 0)
			(While
				(< lmCon0 (length lmLs))
				(setq lmEl (nth lmCon0 lmLs))
				;br
;				(brkstep1
;					'("lmEl") (list lmEl)
;					"LMATCH01:02" "02"
;				)
				;br..
				(cond
					(
						(matchtx lmTx lmEl 1)
						(setq lmLf
							(append lmLf (list lmEl))
						)
						;br
;						(brkstep1
;							'("lmLf") (list lmLf)
;							"LMATCH01:03" "03"
;						)
						;br..
					)
				)
				(setq lmCon0 (+ lmCon0 1))
			);While..
			;br
;			(brkstep1
;				'("lmLf") (list lmLf)
;				"LMATCH01:04" "04"
;			)
			;br..
		);cond Type T..
	);Cond..
	(setq lmLf lmLf)
)












;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<LIST>
;:FUNCION / TITULO: AgMatch. Filtra y agrupa una lista sencilla de cadenas de texto en Grupos de finido por dos limites
;:SINTAXIS:
;;	<(AgMatch [Lista] [Limite inicial] [Limite final])>
;:DESCRIPCION:
;;	<<
;;	AgMatch. A partir de una lista sencilla de cadenas de
;;	texto,  la definición de una cadena inicial y una
;;	cadena final agrupa y filtra todos los elementos que
;;	se encuentren entre esos limites, repitiendo el patrón
;;	en toda la lista.
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;		agRes. Lista de elementos agrupados
;;		<(("xx" ...) (...) ...)>
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. agLs0. Lista sencilla de cadenas de texto
;;	<("xx" ...)>
;;	2. agl10. Cadena de texto de limite inicial
;;	"xx"
;;	3. agl20. Cadena de texto de limite final
;;	"xxx"
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun AgMatch
	(agLs0 agl10 agl20 /
		agLs agl1 agl2
		agCon0 agPas agRes
	)
;	(setq agLs nil agl1 nil agl2 nil
;		agCon0 nil agPas nil agRes nil
;	)
	;br
;	(brkstep1
;		'("agLs0" "agl10" "agl20") (list agLs0 agl10 agl20)
;		"AGMATCH:00" "00"
;	)
	;br..
	(cond
		( ;Cond type T
			(and
				(= (LsType agLs0) 'STR)
				(= (type agl10) 'STR)
				(= (type agl20) 'STR)
			)
			(setq agLs agLs0
				agl1 agl10
				agl2 agl20
			)
			;br
;			(brkstep1
;				'("agLs" "agl1" "agl2") (list agLs agl1 agl2)
;				"AGMATCH:01" "01"
;			)
			;br..
			(setq agCon0 0
				agPas 0
			)
			(while
				(< agCon0 (length agLs))
				(setq agLs1 nil)
				(if
					(matchtx agl1 (nth agCon0 agLs) 0)
					(setq agPas 1)
					(setq agPas 0)
				)
				;br
;				(brkstep1
;					'("agPas" "Elemento") (list agPas (nth agCon0 agLs))
;					"AGMATCH:02" "02"
;				)
				;br..
				(cond
					(
						(= agPas 1)
						(setq agPas 0
							agLs1 (list (nth agCon0 agLs))
							agCon0 (+ agCon0 1)
						)
						(while
							(and
								(< agCon0 (length agLs))
								(= agPas 0)
							)
							(if
								(matchtx agl2 (nth agCon0 agLs) 0)
								(setq agPas 1)
								(setq agPas 0)
							)
							(setq agLs1 (append agLs1 (list (nth agCon0 agLs)))
								agCon0 (+ agCon0 1)
							)
							;br
	;						(brkstep1
	;							'("agLs1") (list agLs1)
	;							"AGMATCH:03" "03"
	;						)
							;br..
						);While
						(setq agRes (append agRes (list agLs1)))
						;br
;						(brkstep1
;							'("agRes") (list agRes)
;							"AGMATCH:04" "04"
;						)
						;br..
					)
					(
						(= agPas 0)
						(setq agCon0 (+ agCon0 1))
					)
				)
			);While
			;br
;			(brkstep1
;				'("agRes") (list agRes)
;				"AgMatch:05" "05"
;			)
			;br..
		);Cond type T..
	);Cond..
	(setq agRes agRes)
) ;AGMATCH..
;
;;
;;;
;;;;
;:PROYECTO:
;;	<LISP>
;:CLASIFICACION:
;;	<COO>
;:FUNCION / TITULO: CoUtm. Convierte coordenadas geograficas a UTM	 
;:SINTAXIS:
;;	<(CoUtm [Latitud] [longitud] [Hemisferio])>
;:DESCRIPCION:
;;	<<
;;	CoUtm. A partir de la definicion de latitud longitud y hemisferio en
;;	grados decimales:. convierte las coordenadas en UTM
;;	>>
;:EJEMPLO:
;;	<<
;;	>
;;	>>
;:DEVUELVE:
;;	<<
;;	coRes. Lista de coordenadas UTM
;;	<(coordenadaX CoordenadaY)
;;	>>
;:ARGUMENTOS:
;;	<<
;;	1. coLat0. Coordenada en grados decimales latitud
;;	<xx.xx>
;;	2. coLon0. Coordenada en grados decimales longitud
;;	<xxx.xxx>
;;	3. coHmf0. Lado de hemisferio
;;	<N / S>
;;	>>
;:DEPENDIENTES:
;;	< >
;:LOCALIZACION:
;;<<
;;	>
;;>>
;:HISTORIAL DE CORRECCIONES:
;;<<
;;	>
;;>>
;:ANOTACIONES:
;;<<
;;	>
;;>>
;:ESTADO:
;;<<
;;	>
;;>>
;;;(brkstep1 '("") (list ) "001TEMP" "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(cond
;	(
;		(=  ;Ent nil)
;		(setq ;Dec 0.00015)
;	)
;	(
;		(< 0 ;Ent)
;		(setq ;Dec
;			(expt 10.0 (* -1 ;Ent))
;		)
;	)
;	(
;		(= ;Ent 0)
;		(setq ;Dec 0.15)
;	)
;)
(defun CoUtm 
	(coLat0 coLon0 coHmf0 /
		coLat coLon coHmf
		coEjmy coEjmn coExc coExc2 
		coExc22 cocurv
		coRlon coRlat coHu coMhu coDl 
		coA coXi coEta coNi 
		cosCorlat cosCorLat2 cox2 cox3 
		cox4 cox5 cox6 coNi 
		coZ coA1 coA2 
		coJ2 coAlfa coBeta coGamma coBfi 
		coBn7216 coBn884 coBn5684 coBnd 
		coEjeX coEjey coRes
	)
;	(setq coLat nil coLon nil coHmf nil
;		coEjmy nil  coEjmn nil coExc nil coExc2 nil
;		coExc22 nil cocurv nil
;		coRlon nil coRlat nil coHu nil  coMhu nil coDl nil
;		coA nil coXi nil coEta nil coNi nil
;		cosCorlat nil cosCorLat2 nil cox2 nil cox3 nil
;		cox4 nil cox5 nil cox6 nil coNi nil
;		coZ nil coA1 nil coA2 nil
;		coJ2 nil coAlfa nil coBeta nil coGamma nil coBfi nil
;		coBn7216 nil coBn884 nil coBn5684 nil coBnd nil
;		coEjeX nil coEjey nil coRes nil
;	)
	;br
;	(brkstep1
;		'("coLat0" "coLon0" "coHmf0")
;		(list coLat0 coLon0 coHmf0)
;		"CoUtm:00" "00"
;	)
	;br..
	(cond
		( ;Cond type T
			(and
				(numberp coLat0)
				(numberp coLon0)
				(= (type coHmf0) 'STR)
			)
			(setq coLat coLat0
				coLon coLon0
				coHmf coHmf0
			)
			;br
;			(brkstep1
;				'("coLat" "coLon" "coHmf")
;				(list coLat coLon coHmf)
;				"CoUtm:01" "01"
;			)
			;br..
			(setq coEjmy 6378137 ;Datum semiEjeMayor
				coEjmn  6356752.314 ;Datum semiEjeMenor
				coExc 0.081819191 ;Excentricidad
				coExc2 0.082094438 ;2a Excentricidad
				coExc22 0.00673949674227624 ;E2
				cocurv 6399593.62575849 ;Radio polar de curvatura
			)
			 ;;DEFINICIÓN DE DATUM WGS84
			(setq
				coRLon (/ (* coLon pi ) 180)
				coRLat (/ (* coLat pi ) 180)
				coHu (fix (+ (/ coLon 6) 31));Huso
				coMhu (- (* 6 coHu) 183) ;Meridiano Huso
				coDL (- coRlon (/ (* coMhu pi) 180)) ;Delta Lanbda
				coA (* (cos coRlat) (sin coDl)) ;Factor A
				coXi (* 0.5 (log (/ (+ 1.0 coA)(- 1.0 coA)))) ;Factor Xi
				coEta ;Factor Eta
				(-
					(atan
						(/
							(tan coRLat)
							(cos CoDl)
						)
					)
					coRLat
				)
			)
				;;; 
			(setq cosCorlat (cos coRlat)
				cosCorLat2 (expt cosCorlat 2)
				cox2 (* cosCorLat2 coExc22)
				coX3 (+ 1.0 cox2)
				cox4 (expt cox3 0.5)
				cox5 (/ cocurv cox4)
				cox6 (* cox5 0.9996)
				coNi cox6
			)
			; 
			;;;
			(setq coz
				(*
					(/ coExc22 2)
					(expt coXi 2)
					(expt (cos coRlat) 2)
				)
				coA1 (sin (* coRLat 2))
				coA2 (* coA1 (expt (cos coRLat) 2))
				coJ2 (+ coRlat (/ coA1 2))
				coJ4 (/ (+ (* 3 coJ2) coA2) 4)
				coJ6 (/ (+
									(*(expt (cos coRLat) 2) coA2)
									(* coJ4 5)
								)
								3
							)
				coAlfa (* coExc22 0.75)
				coBeta (*(/ 5.0 3.0)(expt coAlfa 2))
				coGamma (* (/ 35.0 27.0) (expt coAlfa 3))
				coBfi (* 0.9996 cocurv (- (+ (- coRlat (* coAlfa coJ2)) (* coBeta coJ4)) (* coGamma coJ6)))
				coBFi2 (distof (rtos coBfi 2 8) 2)
			)
			(cond ;Banda (56 a 84)
				((< coLat 56) (setq coBn5684 "U"))
				((< colat 64) (setq coBn5684 "V"))
				((< colat 72) (setq coBn5684 "W"))
				((< colat 84) (setq coBn5684 "X"))
			) ;Banda (56 a 84)..
			(cond ;Banda (-8 a 48)
				((< colat -8) (setq coBn884 "L"))
				((< colat 0) (setq coBn884 "M"))
				((< colat 8) (setq coBn884 "N"))
				((< colat 16) (setq coBn884 "P"))
				((< colat 24) (setq coBn884 "Q"))
				((< colat 32) (setq coBn884 "R"))
				((< colat 40) (setq coBn884 "S"))
				((< colat 48) (setq coBn884 "T"))
			) ;Banda (-8 a 48)..
			(cond ;Banda (-72 a -16)
				((< colat -72) (setq coBn7216 "C"))
				((< colat -64) (setq coBn7216 "D"))
				((< colat -56) (setq coBn7216 "E"))
				((< colat -48) (setq coBn7216 "F"))
				((< colat -40) (setq coBn7216 "G"))
				((< colat -32) (setq coBn7216 "H"))
				((< colat -24) (setq coBn7216 "J"))
				((< colat -16) (setq coBn7216 "K"))
				((<= -16 colat) (setq coBn7216 coBn884))
			) ;Banda (-72 a -16)
			(cond ;band
				((< colat -16) (setq coBnd coBn7216))
				((< colat 48) (setq coBnd coBn884))
				((< colat 84) (setq coBnd coBn5684))
			) ;band..
			;br
;			(brkstep1
;				'("coBn7216" "coBn884" "coBn5684" "coBnd")
;				(list coBn7216 coBn884 coBn5684 coBnd)
;				"COUT:03" "03"
;			)
			;br..
			;br
;			(brkstep1
;				'("coRlon" "coRlat" "coHu" "coMhu" "coDl" "coA" "coETA"
;					"coXi" "coNi" "coZ" "coA1" "coA2" "coJ2" "coJ4"
;					"coJ6" "coAlfa" "coBeta" "coGamma" "coBfi" "coBfi2"
;				) 
;				(list coRlon coRlat coHu coMhu coDl coA coEta	coXi coNi coZ coA1 coA2 coJ2 coJ4 coJ6 coAlfa coBeta coGamma coBfi coBfi2
;				)
;				"COUT:04" "04"
;			)
			;br..
			(setq
				coEjeX (+ (* coXi coNi (+ 1 (/ coZ 3.0))) 500000)
			)
			(cond
				(
					(= (strcase coHmf) "S")
					(setq coEjey (+ (* coEta coNi (+ 1.0 coZ)) coBfi 10000000))
				)
				(
					(= (strcase coHmf) "N")
					(setq coEjey (+ (* coEta coNi (+ 1.0 coZ)) coBfi))
				)
			)
			;br
;			(brkstep1
;				'("coEjex" "coEjey") (list coEjex coEjey)
;				"COUT:05" "05"
;			)
			;br..
			(cond
				(
					(and
						(not (= coEjeX nil))
						(not (= coEjey nil))
					)
					(setq coRes
						(list coEjeX coEjey)
					)
				)
			)
		) ;Cond type T
	) ;Cond.. 
	(setq coRes coRes)
);;CoUtm..
;;PROYECTO: Lisp
;;CLASIFICACION: DEP
;;OBJETO: CONVAL. 
;;	> Inserta coordenadas y valor de conexion en cada interseccion de acuerdo
;;	a la lista de conexiones y valor de conexiones generada por Funciones tipo MAT
;; con la siguiente estructura.
;; ( ((pend ordenada hand (valconex X Y) (...) ...) (...) ...) (...) ...) รณ
;; ( ((pend ordenada hand ( X Y) (...) ...) (...) ...) (...) ...)
;;DEVUELVE:
;;	>
;;ARGUMENTOS
;;	1. LLST01. Lista de conexiones 
;;	> a. ( ((pend ordenada hand (valconex X Y) (...) ...) (...) ...) (...) ...) รณ
;; > b. ( ((pend ordenada hand ( X Y) (...) ...) (...) ...) (...) ...)
;;	2. MODIN0. Modo de insersion
;;	> 0 Para listas tipo B (sin conexion)
;;	> 1 Para listas tipo A (con conexion)
;;	3. conSc0. Escala del block ConexionNum <INT>
;;	4. conColor0. Color del bloque <INT>
;;	5. conRot0. Rotacion del bloque <Grados>
;;	6. BRK0. = 1 Pausa de insercion
;;	7. ConZoom0. = Zoom de acercamiento
;;		0.- Ejecuta sin hacer Zoom
;;		1.- Ejecuta haciendo Zoom de acercamiento

;;DEPENDIENTES
;;	>
;;ANOTACIONES
;;	>
;;;(brkstep '("") "001TEMP" "")
(defun conval
	(llst01 modin0 conSc0 conColor0 conRot0 brk0 conZoom0 /
		llst0 modin conSc conColor conRot brk conZoom
		contador0 contador1 llst1 llst2 insenti
		lsel contin conMode conReq
	)
;	(setq
;		llst0 nil modin nil conSc nil conColor nil conRot nil
;		brk nil conZoom nil
;		contador0 nil contador1 nil llst1 nil llst2 nil 
;		insenti nil lsel nil contin nil conMode nil conReq nil
;	)
	;;
;	(brkstep1
;		'("llst01" "modin0" "conSc0" "conColor0"
;			"conRot0" "brk0" "conZoom0"
;		)
;		(list llst01 modin0 conSc0 conColor0
;			conRot0 brk0 conZoom0
;		)
;		"00" "CONVAL"
;	)
	;;
	(setq conMode (getvar "osmode"))
	(setvar "osmode" 0)
	(setq conReq (getvar "attreq"))
	(setvar "attreq" 0)
	(cond
		(
			(and
				(= (type llst01) 'LIST)
				(= (type modin0) 'INT)
				(= (numberp conSc0) t)
				(= (type conColor0) 'INT)
				(= (type conRot0) 'INT)
				(= (type brk0) 'INT)
				(= (type conZoom0) 'INT)
			)
			(setq llst0 llst01 modin modin0
				conSc conSc0 conColor conColor0
				conRot conRot0 brk brk0 conZoom conZoom0
			)
			(setq contador0 0)
			(setq lsel (ssadd))
			;;
;			(brkstep1
;				'("llst0" "modin" "conSc" "conColor" "conRot"
;					"brk" "conZoom" "contador0" "lsel"
;				)
;				(list llst0 modin conSc conColor conRot
;					brk conZoom contador0 lsel
;				)
;				"01" "CONVAL"
;			)
			;;
			(while
				(< contador0 (length llst0))
				(setq llst1 (append llst1 (cdddr (nth contador0 llst0)))
					contador0 (+ contador0 1)
				)
			)
			;;
;			(brkstep1 '("llst0" "llst1") (list llst0 llst1) "02" "CONVAL")
			;;llst0. Lista base de lineas
			;<((POI (xyInicial) (xyInterseccion) ... (xyFinal))..)>
			;<((POI (ValConexion XY) ...)...)>
			;llst1. Lista de coordenadas <((xyz) ...) / ((xy) ...) / ((ValConexion XY) ...)>
			(setq contador1 0)
			(while (< contador1 (length llst1))
				(cond
					(
						(= modin 0)
						;;
;						(brkstep1 
;							'("(cortxt (nth contador1 llst1))")
;							(list (cortxt (nth contador1 llst1)))
;							"03" "CONVAL"
;						)
						;;cortxt. Coordenada en Texto <"x,y"> 
						(command 
							"insert" "ConexionNum"
							(cortxt (nth contador1 llst1))
							conSc conSc conRot
						)
						(cond
							(
								(= conZoom 1)
								(command  "zoom" "C" (cortxt (nth contador1 llst1)) 0.85)
								(command c^^)
							)
						)
					)
					(
						(= modin 1)
						;;
;						(brkstep1
;							'("(cortxt (cdr (nth contador1 llst1)))")
;							(list (cortxt (cdr (nth contador1 llst1))))
;							"04" "CONVAL"
;						)
						;;cortxt. Coordenada en Texto <"x,y">
						(command "insert" "ConexionNum"
							(cortxt (cdr (nth contador1 llst1)))
							conSc conSc conRot
						)
						(cond
							(
								(= conZoom 1)
								(command "zoom" "C" (cortxt (cdr (nth contador1 llst1))) 0.85)
								(command c^^)
							)
						)
					)
				);Cond
				(setq insenti (list (entlast)))
				(setq lsel (ssadd (nth 0 insenti) lsel))
				;;
;			(brkstep1
;					'("insenti" "lsel")
;					(list insenti (nth contador1 llst1))
;				"05" "CONVAL"
;				)
				;;insenti. Lista de elemento insertado en lista para camtag <(enname)>
				;lsel. lista de lista de seleccion de todos los elementos insertados.
				(cond
					(
						(= modin 0)
						;;
;						(brkstep1
;						'("(nth 0 (nth contador1 llst1))"
;								"(nth 1 (nth contador1 llst1))"
;							)
;							(list (nth 0 (nth contador1 llst1))
;								(nth 1 (nth contador1 llst1))
;							)
;							"06" "CONVAL"
;						)
						;;Coordenada X; Coordenada Y
						(camtag insenti "XCOOR" (rtos (nth 0 (nth contador1 llst1))))
						(camtag insenti "YCOOR" (rtos (nth 1 (nth contador1 llst1))))
						(cam1 insenti (cons 62 conColor))
					)
					(
						(= modin 1)
						;;
;						(brkstep1
;							'("(nth 1 (nth contador1 llst1))"
;							"(nth 2 (nth contador1 llst1))"
;							)
;							(list
;								(nth 1 (nth contador1 llst1))
;								(nth 2 (nth contador1 llst1))
;							)
;							"07" "CONVAL"
;						)
						;;
						(camtag insenti "XCOOR" (rtos (nth 1 (nth contador1 llst1))))
						(camtag insenti "YCOOR" (rtos (nth 2 (nth contador1 llst1))))
						(cam1 insenti (cons 62 conColor))
					)
				);;cond
				(cond
					(
						(= modin 1)
						(camtag insenti "NUMCONECT" (itoa (nth 0 (nth contador1 llst1))))
					)
					(
						(= modin 0)
						(camtag insenti "NUMCONECT" (itoa (+ contador1 1)))
					)
				)
				(cond
					(
						(= brk 1)
						(setq contin 0)
						(while (not (= contin ""))
							(setq contin (getstring "Enter para continuar"))
						)
					)
				)
				(setq contador1 (+ contador1 1))
			);...while
		)
	);...cond
	(setvar "osmode" conMode)
	(setvar "attreq" conReq)
	(setq lsel lsel)
)
;
;;
;;;
;;;;