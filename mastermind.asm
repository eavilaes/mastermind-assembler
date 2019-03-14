include "entorno.asm"

data segment
  DEFINIR_Variables
      
  ;Aqui puedes definir tus propias variables
  npieza DW ?   ;Variable que guarda la posicion del vector combinacion que recorre al comprobar la combinacion introducida
  posj DW ?     ;Variable que guarda la posicion del vetor juegos que recorre al comprobar la combinacion introducida             
ends

stack segment
    
  DW 128 DUP(0)
  
ends


code segment

  DEFINIR_BorrarPantalla
  DEFINIR_ColocarCursor
  DEFINIR_Imprimir
  DEFINIR_LeerTecla
  DEFINIR_ImprimeCaracterColor
  DEFINIR_DibujarIntentos
  DEFINIR_DibujarCodigo
  DEFINIR_DibujarInstrucciones
  DEFINIR_DibujaEntorno    
  DEFINIR_MuestraAciertos
  DEFINIR_MuestraCombinacion
  DEFINIR_MuestraGana
  

  ;Aqui puedes definir tus propios procedimientos
  seleccionaColor PROC
    cmp al, 52h
    je c_rojo
    cmp al, 41h
    je c_amarillo
    cmp al, 42h
    je c_blanco
    cmp al, 56h
    je c_verde
    cmp al, 5Ah
    je c_azul
    cmp al, 4Dh
    je c_marron
    
    c_rojo:
     mov bl, 04h
     jmp fincolor
    c_amarillo:
     mov bl, 0Eh
     jmp fincolor
    c_blanco:
     mov bl, 0Fh
     jmp fincolor
    c_verde:
     mov bl, 02h
     jmp fincolor
    c_azul:
     mov bl, 03h
     jmp fincolor
    c_marron:
     mov bl, 06h
    
    fincolor:
    ret
  seleccionaColor ENDP
  

  
start:
    mov ax, data
    mov ds, ax
           
           
    ;Aqui puedes definir tu codigo principal
JuegoMM:
    mov finJuego, 0         ;Bool finJuego = 0, porque empieza un nuevo juego
    mov aciertosPos, 0
    mov aciertosColor, 0
    mov intento, 0           
    call BorrarPantalla
    mov fila, f_inicio1     ;Titulo de MasterMind
    mov colum, c_inicio1
    call ColocarCursor
    lea dx, d_inicio1
    call Imprimir
    mov fila, f_inicio2     ;Solicita npiezas y comprueba que el numero sea correcto
    mov colum, c_inicio2
    call ColocarCursor
    lea dx, d_inicio2
    call Imprimir
   s_npiezas:
    call leerTecla
    mov al, caracter
    mov npiezas, al
    cmp npiezas, 33h
    jl s_npiezas
    cmp npiezas, 36h
    jg s_npiezas
    mov bl, 07h
    call ImprimeCaracterColor   ;Si npiezas es correcto lo imprime en pantalla y le resta 30h
    sub npiezas, 30h
    mov fila, f_inicio3     ;Solicita indJuego y comprueba que el numero es correcto
    mov colum, c_inicio3
    call ColocarCursor
    lea dx, d_inicio3
    call Imprimir
   s_indJuego: 
    call leerTecla
    mov al, caracter
    mov indJuego, al
    cmp indJuego, 30h
    jl s_indJuego
    cmp indJuego, 34h
    jg s_indJuego
    mov bl, 07h
    call ImprimeCaracterColor   ;Si indJuego es correcto lo imprime en pantalla y le resta 30h
    sub indJuego, 30h      
   JuegoB:                  ;Segunda pantalla juego
    call BorrarPantalla
    call dibujaEntorno
   JuegoC:
    call leerTecla          ;Lee tecla de accion
    cmp caracter, 49h           ;I = Instertar Combinacion
    je t_nuevaCombinacion       
    cmp caracter, 53h           ;S = Resolver y terminar juego (no programa)
    je t_resolver               
    cmp caracter, 4Eh           ;N = Nuevo Juego (desde el principio)
    je JuegoMM                  
    cmp caracter, 1Bh           ;ESC = Terminar programa (CODIGO 1Bh)
    je FinPrograma
    jmp JuegoC                  ;Tecla no valida -> solicita de nuevo
    
   t_nuevaCombinacion:
    PUSH DI
    PUSH AX
    cmp finJuego, 1         ;Comprueba si es el final del juego para prohibir nueva combinacion o mostrar solucion
    je juegoC
    mov fila, f_intento
    mov al, intento
    mov dl, 2h
    mul dl
    add fila, al
    mov colum, c_intento
    call ColocarCursor
    xor cx, cx
    mov cl, npiezas
    xor di, di
   c_nuevaCombinacion:      ;Lee nueva pulsacion de tecla dentro de la combinacion
    call LeerTecla
    mov al, caracter
   b_nuevaCombinacion:      ;Comprueba si la tecla pulsada es valida
    cmp al, 52h             ;R
    je seleccionac
    cmp al, 41h             ;A
    je seleccionac
    cmp al, 42h             ;B
    je seleccionac
    cmp al, 56h             ;V
    je seleccionac
    cmp al, 5Ah             ;Z
    je seleccionac
    cmp al, 4Dh             ;M
    je seleccionac              
    
    jmp c_nuevaCombinacion  ;Si no es valida vuelve a pedir tecla
   seleccionac:
    mov combinacion[di], al ;Si es valida la guarda en el vector combinacion
    inc di
    call seleccionaColor    ;Si es valida imprime por pantalla la tecla con el color correcto
    call imprimeCaracterColor
    inc colum
    inc colum
    call ColocarCursor
    loop c_nuevaCombinacion ;Pide la siguiente tecla npiezas veces, terminando el bucle cuando cl es 0
    jmp comprobarCombinacion;Una vez introducida la combinacion, pasa a comprobarla
    POP AX
    POP DI                  
    
   comprobarCombinacion:
    mov aciertosPos, 00h
    mov aciertosColor, 00h
    mov al, indJuego            ;Calcula la combinacion correcta...
    mov dl, 06h
    mul dl
    mov di, ax                  ;En di esta la primera posicion del vector juegos
    mov cl, npiezas             ;Repite el bucle npiezas veces para comprobar los vectores completos
    mov posj, 0
   b_buclen:
    mov npieza, 0  
    PUSH CX
    mov cl, npiezas              
   b_buclei:                    ;Compara cada pieza del vector combinacion(bucle) con el vector juegos
    mov si, npieza
    mov al, juegos[di]
    cmp al, combinacion[si]
    jne fincomprobpos
    mov bx, posj
    cmp bx, npieza
    jne igualcolor
    inc aciertosPos
    jmp fincomprobpos
   igualcolor:
    inc aciertosColor 
   fincomprobpos:
    inc npieza 
    loop b_buclei
    POP CX
    inc di
    inc posj  
    loop b_buclen
    jmp pintaAciertos
    
   pintaAciertos:               ;Una vez contados los aciertos, procede a mostrarlos
    mov colum, c_aciertos
    call ColocarCursor
    mov cl, aciertosPos         ;Imprime los aciertos en posicion y color (VERDE)
    cmp cl, 00h
    je imprimeColor
   imprimeAciertos:              
    mov al, 56h
    mov bl, 0Ah
    call ColocarCursor
    call ImprimeCaracterColor
    inc colum
    inc colum
    loop imprimeAciertos
    mov cl, aciertosPos         ;Si aciertosPos = npiezas termina el juego con la combinacion correcta
    cmp npiezas, cl
    mov cl, aciertosColor
    jne imprimeColor
   ganador:                      
    call MuestraCombinacion
    mov fila, f_mensajes
    mov colum, c_mensajes
    call ColocarCursor
    lea dx, msj_gana
    call Imprimir
    mov finJuego, 1
    jmp JuegoC
    
   imprimeColor:                ;Si no es combinacion correcta, imprime los aciertos de color (AZUL)
    mov cl, aciertosColor
   bucleColor:
    cmp aciertosColor, 00h
    je finImprimeColor
    call ColocarCursor
    mov al, 56h
    mov bl, 09h
    call ImprimeCaracterColor
    inc colum
    inc colum
    loop bucleColor
   finImprimeColor:             ;Coloca el cursor al final de la columna de aciertos (unicamente por estilo)
    mov colum, c_aciertos
    mov al, npiezas
    mov dl, 02h
    mul dl
    add colum, al 
    call ColocarCursor
    inc intento
    cmp intento, 09h            ;Comprueba si se ha superado el numero maximo de intentos
    jge maxintentos     
    jmp JuegoC
    
   t_resolver:              ;Se pulsa la tecla de resolver
    PUSH CX
    PUSH AX
    PUSH DI
    cmp finJuego, 1         ;Comprueba si es el final del juego para prohibir mostrar la solucion de nuevo
    je juegoC
    mov fila, f_code
    mov colum, c_code
    call ColocarCursor
    call MuestraCombinacion     ;Muestra la combinacion correcta    
    mov finJuego, 1             ;Bool finJuego = 1
    mov fila, f_mensajes
    mov colum, c_mensajes
    call ColocarCursor
    lea dx, msj_teclaAccion     ;Pide nueva tecla de accion     
    call Imprimir
    POP DI
    POP AX
    POP CX
    jmp JuegoC
                  
   maxintentos:                 ;Numero maximo de intentos superado (el incluido en el entorno permitia pulsar teclas prohibidas)
    lea dx, msj_superaintentos
    mov fila, f_mensajes
    mov colum, c_mensajes
    call ColocarCursor
    call Imprimir
    mov finJuego, 1
    jmp JuegoC
    
    
           
    
   FinPrograma:             ;FINAL DE PROGRAMA. Devuelve el control. (Tecla ESC)
    mov ax, 4C00h           
    int 21h

ends

end start
