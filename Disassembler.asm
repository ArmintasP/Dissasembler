.MODEL SMALL
.STACK 100h

CR  EQU 0Dh
LF  EQU 0Ah
TAB EQU 9h
SPC EQU 20h
GAP_SIZE_BETWEEN_CODE EQU 34
GAP_SIZE_BETWEEN_CODE_2 EQU 47
ISIZE EQU 16
OSIZE EQU 160
 

.DATA
		
	stars DB CR, LF, 80 DUP('*'), '$'
	hyphens DB CR, LF, 80 DUP('-'), '$'
    prog_info1 DB 'Pagalbos pranesimas$' 
	prog_info2 DB 'Darba atliko Armintas Pakenis, programu sistemu 1 kurso 4 grupes sudentas.', CR, LF
	prog_info3 DB 'I komandine eilute paduodami du parametrai, pvz.: file.com rez.txt', CR, LF
	prog_info4 DB 'Programa disasemblins masinini koda is .com failo i rezultato faila.$'
	succ_msg DB CR, LF, 80 DUP('-'), 'Programa sekmingai disasemblino. Rezultatas irasytas i faila.', CR, LF, 80 DUP('-'), '$'
	
	
	file1 DB 21 DUP(0)
    file2 DB 21 DUP(0)
	f1_error DB 'Klaida su pirmu failu: $' 
	f2_error DB 'Klaida kuriant rezultato faila: $'
	filemistake DB 'Ivestu failu buvo per daug arba per mazai!$'	
	error1 DB 'toks failas neegzistuoja!$'
    error2 DB 'nepavyko sukurti tokio failo!$' 
	error3 DB 'Nepavyko irasyti duomenu i faila!$'	
	error4 DB 'Nepavyko nuskaityti duomenu is failo!$'	

	handlef1 DW ?
    handlef2 DW ?
	i_buff DB ISIZE DUP (0)
	o_buff DB OSIZE DUP (0)
	
	o_buff_pos DB 0
	i_buff_pos DB 0
	read_count DB 0
	pars_count DB 0
	
	byte_temp  DB 0
	byte1 DB 0
	byte2 DB 0
	poslinkis_v DB 0
	poslinkis_j DB 0
	poslinkis DW 0
	bojb DB 0
	bovb DB 0
	ajb DB 0
	avb DB 0
	srjb DB 0
	srvb DB 0
	is_ptr DB 0
	;prefix DB ? ;0  ES, 1- CS, 2 - SS, 3 - DS, 9 - NĖRA
	
	format DB 0 ; NEZINOMOS KOMANDOS FORMATAS - 0
	temp db 0
	
	sr DB 0; 0  ES, 1- CS, 2 - SS, 3 - DS, 9 - NĖRA
	reg DB 0;
	w DB 0
	s DB 0
	d DB 0
	modd DB 0
	rm DB 0
	
	offset_v DW 0100h ; IP
	
	ptr_byte DB 'byte ptr $'
	ptr_word DB 'word ptr $'
	comma DB ', $'
	unknown_ DB 'NEATPAŽINTA$'
	push_ db 'push$'
	pop_ DB 'pop$'
	ret_ DB 'ret$'
	retf_ DB 'retf$'
	inc_ DB 'inc$'
	dec_ DB 'dec$'
	int_ DB 'int$'
	mul_ DB 'mul$'
	div_ DB 'div$'
	call_ DB 'call$'
	jmp_ DB 'jmp$'
	mov_ DB 'mov$'
	add_ DB 'add$'
	sub_ DB 'sub$'
	cmp_ DB 'cmp$'
	xor_ DB 'xor$'
	or_ DB 'or$'
	and_ DB 'and$'
	sbb_ DB 'sbb$'
	adc_ DB 'adc$'
	not_ DB 'not$'
	
	;jmpfar_ DB 'jmp far$'
	;callfar_ DB 'call far$'
	;callnear_ DB 'call near$'
	;jmpnear_ DB 'jmp near$'
	
	;far_ DB  'far  $'
	;near_ DB 'near $'
	
	
	jmpfar_ DB '$'
	callfar_ DB '$'
	callnear_ DB '$'
	jmpnear_ DB '$'
	far_ DB  '$'
	near_ DB '$'
	
	
	jo_ db 'jo$'
	jno_ db 'jno$'
	jnae_ db 'jnae$'
	jae_ db 'jae$'
	je_ db 'je$'
	jne_ db 'jne$'
	jbe_ db 'jbe$'
	ja_ db 'ja$'
	js_ db 'js$'
	jns_ db 'jns$'
	jp_ db 'jp$'
	jnp_ db 'jnp$'
	jl_ db 'jl$'
	jge_ db 'jge$'
	jle_ db 'jle$'
	jg_ db 'jg$'
	jcxz_ db 'jcxz$'
	loop_ db 'loop$'
	
	
	es_ db 'es$'
	cs_ db 'cs$'
	ss_ db 'ss$'
	ds_ db 'ds$'
	
	ax_ db 'ax$'
	cx_ db 'cx$'
	dx_ db 'dx$'
	bx_ db 'bx$'
	sp_ db 'sp$'
	bp_ db 'bp$'
	si_ db 'si$'
	di_ db 'di$'
	
	al_ db 'al$'
	cl_ db 'cl$'
	dl_ db 'dl$'
	bl_ db 'bl$'
	ah_ db 'ah$'
	ch_ db 'ch$'
	dh_ db 'dh$'
	bh_ db 'bh$'
	
	
.CODE
PREMAIN:
	MOV AX, @DATA
    MOV DS, AX   
	
	CALL CMD_SCAN
	CALL OPEN_FILE
    CALL CREATE_FILE

MAIN:
	CALL INSPECT_BYTES
	
	
	
	
	
	
	

;**********************************************************************
;**			Pagrindinė funkcija. Vykdoma tol, kol ne failo pabaiga   **
;**********************************************************************	
PROC INSPECT_BYTES
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
REPEAT_INSPECTION:	
	CALL CS_IP
	CALL GRAB_BYTE
	CALL GET_PREFIX
	CMP BYTE PTR [sr], 9h
	JE WE_GOT_OP_CODE
	CALL GRAB_BYTE
	
WE_GOT_OP_CODE:
	CALL ANALYSE_OP
	CALL DO_PROPER_FORMAT
	
	CALL WRITE_TO_FILE
	JMP REPEAT_INSPECTION
	
	POP DX
	POP CX
	POP BX
	POP AX
	RET
ENDP INSPECT_BYTES



;**********************************************************************
;**			Žiūrima į pirmą mašininio kodo baitą.					 **
;**********************************************************************

PROC ANALYSE_OP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
;	000sr 110 – PUSH segmento registras
;	000sr 111 – POP segmento registras
	MOV DL, [byte_temp]
	AND DL, 11100111b
A0:
	CMP DL, 00000110b
	JNE A1
	MOV [format], 1
	JMP ANALYSE_END
A1:
	CMP DL, 00000111b
	JNE A2
	MOV [format], 1
	JMP ANALYSE_END
	
A2:
;	1100 0011 – RET
;	1100 1011 – RETF
	MOV DL, [byte_temp]
	
	CMP DL, 11000011b
	JNE A3
	MOV [format], 2
	JMP ANALYSE_END
A3:	
	CMP DL, 11001011b
	JNE A4
	MOV [format], 2
	JMP ANALYSE_END
A4:
;	0101 0reg – PUSH registras (žodinis）
;	0101 1reg – POP registras (žodinis)

;	0100 0reg – INC registras (žodinis)
;	0100 1reg– DEC registras (žodinis)
	MOV DL, [byte_temp]
	AND DL, 11111000b
	CMP DL, 01000000b
	JB A5
	CMP DL, 01011111b
	JA A5
	MOV [format], 3
	JMP ANALYSE_END
	
A5:
;	1100 1101 numeris – INT numeris
;	1100 1100  - INT 3
	MOV DL, [byte_temp]
	AND DL, 11111110b
	CMP DL, 11001100b
	JNE A6
	MOV [format], 4
	JMP ANALYSE_END
A6:
;	1000 1111 mod 000 r/m [poslinkis] – POP registras/atmintis
	CMP BYTE PTR [byte_temp], 10001111b
	JNE A7
	MOV [format], 5
	JMP ANALYSE_END
A7:
;	1111 011w mod 100 r/m [poslinkis] – MUL registras/atmintis
;	1111 011w mod 110 r/m [poslinkis] – DIV registras/atmintis
	MOV DL, [byte_temp]
	AND DL, 11111110b
	CMP DL, 11110110b
	JNE A8
	MOV [format], 5
	JMP ANALYSE_END
A8:
;1111 1111 mod 110 r/m [poslinkis] – PUSH registras/atmintis
;1111 111w mod 000 r/m [poslinkis] – INC registras/atmintis
;1111 111w mod 001 r/m [poslinkis] – DEC registras/atmintis
;1111 1111 mod 010 r/m [poslinkis] – CALL adresas (vidinis netiesioginis)
;1111 1111 mod 011 r/m [poslinkis] – CALL adresas (išorinis netiesioginis)
;1111 1111 mod 100 r/m [poslinkis] – JMP adresas (vidinis netiesioginis)
;1111 1111 mod 101 r/m [poslinkis] – JMP adresas (išorinis netiesioginis)

	CMP DL, 11111110b
	JNE A9
	MOV [format], 5
	JMP ANALYSE_END
A9:	
;	PAPILDYTA, NES PUSLAPIO VERSIJOJ BUVO IR XOR, AND IR T. T.
;-----------------------------------------
;1000 00sw mod 110 r/m [poslinkis] bojb [bovb] – XOR registras/atmintis | betarpiška
;1000 00sw mod 001 r/m [poslinkis] bojb [bovb] – OR registras/atmintis V betarpiškasoperandas
;1000 00sw mod 100 r/m [poslinkis] bojb [bovb] – AND registras/atmintis & betarpiškasoperandas
;1000 00sw mod 010 r/m [poslinkis] bojb [bovb] – ADC registras/atmintis += betarpiškasoperandas
;1000 00sw mod 011 r/m [poslinkis] bojb [bovb] – SBB registras/atmintis -= betarpiškasoperandas



;---


;	1000 00sw mod 000 r/m [poslinkis] bojb [bovb] – ADD registras/atmintis += betarpiškasoperandas
;	1000 00sw mod 101 r/m [poslinkis] bojb [bovb] – SUB registras/atmintis -= betarpiškasoperandas
;	1000 00sw mod 111 r/m [poslinkis] bojb [bovb] – CMP registras/atmintis ~ betarpiškasoperandas
	MOV DL, [byte_temp]
	AND DL, 11111100b
	CMP DL, 10000000b
	JNE A10
	CMP [byte_temp], 82h ;82 NĖRA MAŠININIO KODO.
	JE A10
	
	MOV [format], 6
	JMP ANALYSE_END
A10:
;	1100 011w mod 000 r/m [poslinkis] bojb [bovb] – MOV registras/atmintis <- betarpiškas operandas
	MOV DL, [byte_temp]
	AND DL, 11111110b
	CMP DL, 11000110b
	JNE A11
	MOV [format], 6
	JMP ANALYSE_END
A11:
;	PAPILDYTA, NES PUSLAPIO VERSIJOJ BUVO IR XOR, AND IR T. T.
;-----------------------------------------
;	0000 10dw mod reg r/m [poslinkis] – OR registras V registras/atmintis
;	0011 00dw mod reg r/m [poslinkis]– XOR registras | registras/atmintis
;	0010 00dw mod reg r/m [poslinkis] – AND registras & registras/atmintis
;-----------------------------------------
;	0000 00dw mod reg r/m [poslinkis] – ADD registras += registras/atmintis
;	0010 10dw mod reg r/m [poslinkis]– SUB registras -= registras/atmintis
;	0011 10dw mod reg r/m [poslinkis]– CMP registras ~ registras/atmintis
;	1000 10dw mod reg r/m [poslinkis] – MOV registras <-> registras/atmintis

	MOV DL, [byte_temp]
	AND DL, 11110100b
	
	CMP DL, 00000000b
	JNE A12
	MOV [format], 7
	JMP ANALYSE_END
	
A12:
	CMP DL, 00100000b
	JNE A13
	MOV [format], 7
	JMP ANALYSE_END
A13:
	CMP DL, 00110000b
	JNE A14
	MOV [format], 7
	JMP ANALYSE_END
A14:
	MOV DL, [byte_temp]
	AND DL, 11111100b
	CMP DL, 10001000b
	JNE A15
	MOV [format], 7
	JMP ANALYSE_END
	
A15:
;	PAPILDYTA, NES PUSLAPIO VERSIJOJ BUVO IR XOR, AND IR T. T.
;-----------------------------------------
;	0000 110w bojb [bovb] – OR akumuliatorius V betarpiškas operandas
;	0010 010w bojb [bovb] – AND akumuliatorius & betarpiškas operandas
;	0011 010w bojb [bovb] – XOR akumuliatorius | betarpiškas operandas
;-----------------------------------------
;	0000 010w bojb [bovb] – ADD akumuliatorius += betarpiškas operandas
;	0010 110w bojb [bovb] – SUB akumuliatorius -= betarpiškas operandas
;	0011 110w bojb [bovb] – CMP akumuliatorius ~ betarpiškas operandas

	MOV DL, [byte_temp]
	AND DL, 11110110b
	
	CMP DL, 00000100b
	JNE A17
	MOV [format], 8
	JMP ANALYSE_END
A17:
	CMP DL, 00100100b
	JNE A18
	MOV [format], 8
	JMP ANALYSE_END
A18:
	CMP DL, 00110100b
	JNE A19
	MOV [format], 8
	JMP ANALYSE_END
A19:
	MOV DL, [byte_temp]
	AND DL, 11111110b
	;1110 1001 pjb pvb – JMP žymė (vidinis tiesioginis)
	;1110 1000 pjb pvb – CALL žymė (vidinis tiesioginis)
	CMP DL, 11101000b
	JNE A20
	MOV [format], 9
	JMP ANALYSE_END
A20:
;	1100 0010 bojb bovb – RET betarpiškas operandas
;	1100 1010 bojb bovb – RETF betarpiškas operandas
	MOV DL, [byte_temp]
	AND DL, 11110111b
	
	CMP DL, 11000010b
	JNE A21
	MOV [format], 10
	JMP ANALYSE_END
A21:
; 1001 1010 ajb avb srjb srvb – CALL žymė (išorinis tiesioginis)
; 1110 1010 ajb avb srjb srvb – JMP žymė (išorinis tiesioginis)

	CMP BYTE PTR [byte_temp], 10011010b
	JNE A22
	MOV [format], 11
	JMP ANALYSE_END
A22:
	CMP BYTE PTR [byte_temp], 11101010b
	JNE A23
	MOV [format], 11
	JMP ANALYSE_END
A23:
;	1011 wreg bojb [bovb] – MOV registras <- betarpiškas operanda
	MOV DL, [byte_temp]
	AND DL, 11110000b
	CMP DL, 10110000b
	JNE A24
	MOV [format], 12
	JMP ANALYSE_END
A24:
;	1010 000w ajb avb – MOV akumuliatorius <- atmintis
;	1010 001w ajb avb – MOV atmintis <- akumuliatorius
	MOV DL, [byte_temp]
	AND DL, 11111100b
	CMP DL, 10100000b
	JNE A25
	MOV [format], 13
	JMP ANALYSE_END
A25:
;1000 11d0 mod 0sr r/m [poslinkis] – MOV segmento registras  <-> registras/atmintis
	MOV DL, [byte_temp]
	AND DL, 11111101b
	CMP DL, 10001100b
	JNE A26
	MOV [format], 14
	JMP ANALYSE_END
A26:
;	1110 1011 poslinkis – JMP žymė (vidinis artimas)

;	1110 0010 poslinkis – LOOP žymė
;	1110 0011 poslinkis – JCXZ žymė

;	0111 0000 poslinkis – JO žymė
;	0111 0001 poslinkis – JNO žymė
;	0111 0010 poslinkis – JNAE žymė; JB žymė; JC žymė
;	0111 0011 poslinkis – JAE žymė; JNB žymė; JNC žymė
;	0111 0100 poslinkis – JE žymė; JZ žymė
;	0111 0101 poslinkis – JNE žymė; JNZ žymė
;	0111 0110 poslinkis – JBE žymė; JNA žymė
;	0111 0111 poslinkis – JA žymė; JNBE žymė
;	0111 1000 poslinkis – JS žymė
;	0111 1001 poslinkis – JNS žymė
;	0111 1010 poslinkis – JP žymė; JPE žymė
;	0111 1011 poslinkis – JNP žymė; JPO žymė
;	0111 1100 poslinkis – JL žymė; JNGE žymė
;	0111 1101 poslinkis – JGE žymė; JNL žymė
;	0111 1110 poslinkis – JLE žymė; JNG žymė
;	0111 1111 poslinkis – JG žymė; JNLE žymė
	MOV DL, [byte_temp]
	
	CMP DL, 11101011b
	JNE A27
	MOV [format], 15
	JMP ANALYSE_END
A27:
	AND DL, 11111110b
	CMP DL, 11100010b
	JNE A28
	MOV [format], 15
	JMP ANALYSE_END
A28:
	AND DL, 11110000b
	CMP DL, 01110000b
	JNE UNKNOWN_COM
	MOV [format], 15
	JMP ANALYSE_END
	

UNKNOWN_COM:
	MOV [format], 0

ANALYSE_END:
	POP DX
	POP CX
	POP BX
	POP AX
	RET
ENDP ANALYSE_OP


;**********************************************************************
;**			Patirkina formato numerį ir šoka į to formato funkciją.  **
;**********************************************************************


PROC DO_PROPER_FORMAT

	CMP [format], 0
	JNE F_1
	CALL COMPLETE_FORMAT_0
	JMP PROER_FORMAT_END
F_1:
	CMP [format], 1
	JNE F_2
	CALL COMPLETE_FORMAT_1
	JMP PROER_FORMAT_END
F_2:	
	CMP [format], 2
	JNE F_3
	CALL COMPLETE_FORMAT_2
	JMP PROER_FORMAT_END
F_3:
	CMP [format], 3
	JNE F_4
	CALL COMPLETE_FORMAT_3
	JMP PROER_FORMAT_END
F_4:
	CMP [format], 4
	JNE F_5
	CALL COMPLETE_FORMAT_4
	JMP PROER_FORMAT_END
F_5:
	CMP [format], 5
	JNE F_6
	CALL COMPLETE_FORMAT_5
	JMP PROER_FORMAT_END
F_6:
	CMP [format], 6
	JNE F_7
	CALL COMPLETE_FORMAT_6
	JMP PROER_FORMAT_END
F_7:
	CMP [format], 7
	JNE F_8
	CALL COMPLETE_FORMAT_7
	JMP PROER_FORMAT_END
F_8:
	CMP [format], 8
	JNE F_9
	CALL COMPLETE_FORMAT_8
	JMP PROER_FORMAT_END
F_9:
	CMP [format], 9
	JNE F_10
	CALL COMPLETE_FORMAT_9
	JMP PROER_FORMAT_END
F_10:
	CMP [format], 10
	JNE F_11
	CALL COMPLETE_FORMAT_10
	JMP PROER_FORMAT_END
F_11:
	CMP [format], 11
	JNE F_12
	CALL COMPLETE_FORMAT_11
	JMP PROER_FORMAT_END
F_12:
	CMP [format], 12
	JNE F_13
	CALL COMPLETE_FORMAT_12
	JMP PROER_FORMAT_END
F_13:
	CMP [format], 13
	JNE F_14
	CALL COMPLETE_FORMAT_13
	JMP PROER_FORMAT_END
F_14:
	CMP [format], 14
	JNE F_15
	CALL COMPLETE_FORMAT_14
	JMP PROER_FORMAT_END
F_15:
	CMP [format], 15
	JNE F_16
	CALL COMPLETE_FORMAT_15
	JMP PROER_FORMAT_END
F_16:				
PROER_FORMAT_END:
	RET
	
ENDP DO_PROPER_FORMAT






;**********************************************************************
;**			Nežinomos komandos formatas.  							 **
;**********************************************************************

PROC COMPLETE_FORMAT_0
	PUSH BX

	CALL ADD_TABS
	LEA BX, unknown_
	CALL STR_TO_BUFF_BX

	POP BX
	RET
ENDP COMPLETE_FORMAT_0	
		






;**********************************************************************
;**			Segmentiniai push/pop									 **
;**********************************************************************
	
PROC COMPLETE_FORMAT_1
	PUSH BX
	PUSH DX
	
	MOV DL, [byte_temp]
	AND DL, 00000001b

	CALL ADD_TABS
	
	CMP DL, 1h
	JNE ITS_PUSH
ITS_POP:
	LEA BX, pop_
	CALL STR_TO_BUFF_BX	
	JMP FORMAT_1_SREG
ITS_PUSH:
	LEA BX, push_
	CALL STR_TO_BUFF_BX	
	
FORMAT_1_SREG:	
	CALL ADD_MIDDLE_TAB
	
	MOV DL, [byte_temp]
	AND DL, 00011000b
	SHR DL, 3h
	MOV [sr], DL
	
	CALL LOAD_SEG_NAME_TO_BX
	CALL STR_TO_BUFF_BX	

	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_1	





;**********************************************************************
;**			Return ir return far.									 **
;**********************************************************************

PROC COMPLETE_FORMAT_2
	PUSH BX
	PUSH DX
	CALL ADD_TABS
	
	MOV DL, [byte_temp]
	CMP DL, 11001011b
	JNE ITS_RET
	LEA BX, retf_
	CALL STR_TO_BUFF_BX	
	JMP C_F_2_END
ITS_RET:
	LEA BX, ret_
	CALL STR_TO_BUFF_BX	
	
C_F_2_END:	
	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_2




;**********************************************************************
;**			010# #reg	<--- OP kodas								 **
;**********************************************************************
PROC COMPLETE_FORMAT_3
	PUSH BX
	PUSH DX
	CALL ADD_TABS
;	0101 0reg – PUSH registras (žodinis）
;	0101 1reg – POP registras (žodinis)

;	0100 1reg– DEC registras (žodinis)
;	0100 0reg – INC registras (žodinis
	
	

	MOV Dl, [byte_temp]
	AND DL, 11111000b
	
	
	CMP DL, 01000111b
	JA C_F_3_1
	LEA BX, inc_
	CALL STR_TO_BUFF_BX	
	JMP C_F_3_REG
	
C_F_3_1:
	CMP DL, 01001111b
	JA C_F_3_2
	LEA BX, dec_
	CALL STR_TO_BUFF_BX	
	JMP C_F_3_REG
	
C_F_3_2:
	CMP DL, 01010111b
	JA C_F_3_3
	LEA BX, push_
	CALL STR_TO_BUFF_BX	
	JMP C_F_3_REG
	
C_F_3_3:
	LEA BX, pop_
	CALL STR_TO_BUFF_BX	
	
C_F_3_REG:
	CALL ADD_MIDDLE_TAB
	
	MOV DL, [byte_temp]
	AND DL, 00000111b
	MOV [reg], DL
	
	;PADAROM W -1, NES SIS FORMATAS SU ZODZIAIS DIRBA.
	MOV [w], 1;
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	
	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_3	
		




;**********************************************************************
;**			INT'ų formatas											 **
;**********************************************************************

PROC COMPLETE_FORMAT_4
	PUSH BX
	PUSH DX
	
	CMP BYTE PTR [byte_temp], 11001100b
	JNE NOT_INT3
	CALL ADD_TABS
	LEA BX, int_
	CALL STR_TO_BUFF_BX
	
	CALL ADD_MIDDLE_TAB
	MOV DL, '3'
	CALL CHAR_TO_BUFF_FROM_DL
	JMP C_F4_END
	
NOT_INT3:
	CALL GRAB_BYTE
	CALL ADD_TABS
	
	LEA BX, int_
	CALL STR_TO_BUFF_BX
	
	CALL ADD_MIDDLE_TAB
	
	
	MOV DL, [byte_temp]
	CALL PRINT_HEX
	
	;GALIMA DETI H, JEI REIKIA
	;MOV DL, 'h'
	;CALL CHAR_TO_BUFF_FROM_DL
	
C_F4_END:	
	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_4



;**********************************************************************
;**			1111 111w mod ### r/m [poslinkis] 	 					 **
;**			1111 011w mod ### r/m [poslinkis] 	 					 **
;**			1000 1111 mod 000 r/m [poslinkis] 	 					 **
;**********************************************************************


PROC COMPLETE_FORMAT_5
	PUSH BX
	PUSH DX
	
	
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte1], DL
	AND DL, 00000001b
	MOV [w], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte2], DL
	
	
	
	;idedamAS mod
	AND DL, 11000000b
	SHR DL, 6
	MOV [modd], DL
	
	;idedamas r/m
	MOV DL, [byte2]
	AND DL, 00000111b
	MOV BYTE PTR [rm], DL
	
	;idedama vidurine reiksme i reg
	MOV DL, [byte2]
	AND DL, 00111000b
	SHR DL, 3
	MOV BYTE PTR [reg], DL

	
	CALL ANALYSE_MOD_AND_RM
	CALL ADD_TABS
	
	CMP BYTE PTR [byte1], 10001111b
	JNE C_F5_1
	LEA BX, pop_
	CALL STR_TO_BUFF_BX
	JMP  C_F5_PART2
	
 C_F5_1:
	MOV DL, [byte1]
	AND DL, 11111110b
	CMP DL, 11110110b
	JNE C_F5_2
	
	CMP BYTE PTR [reg], 010b
	JNE C_F5_1_0
	LEA BX, not_
	CALL STR_TO_BUFF_BX
	MOV BYTE PTR [is_ptr], 1
	JMP C_F5_PART2
C_F5_1_0:	
	CMP BYTE PTR [reg], 100b
	JNE C_F5_1_1
	LEA BX, mul_
	CALL STR_TO_BUFF_BX
	MOV BYTE PTR [is_ptr], 1
	JMP C_F5_PART2
C_F5_1_1:
	CMP BYTE PTR [reg], 110b
	JNE C_F5_1_2
	LEA BX, div_
	CALL STR_TO_BUFF_BX
	MOV BYTE PTR [is_ptr], 1
	JMP C_F5_PART2
C_F5_1_2:
	CALL COMPLETE_FORMAT_0
	JMP C_F5_END
	
C_F5_2:
	CMP BYTE PTR [reg], 000b
	JNE C_F5_2_1
	LEA BX, inc_
	CALL STR_TO_BUFF_BX
	MOV BYTE PTR [is_ptr], 1
	JMP C_F5_PART2
C_F5_2_1:
	CMP BYTE PTR [reg], 001b
	JNE C_F5_2_2
	LEA BX, dec_
	CALL STR_TO_BUFF_BX
	MOV BYTE PTR [is_ptr], 1
	JMP C_F5_PART2
C_F5_2_2:
	CMP BYTE PTR [reg], 010b
	JNE C_F5_2_3
	LEA BX, call_
	CALL STR_TO_BUFF_BX
	CALL ADD_MIDDLE_TAB
	LEA BX, near_
	CALL STR_TO_BUFF_BX
	JMP C_F5_PART2
C_F5_2_3:	;call WORD FAR?
	CMP BYTE PTR [reg], 011b
	JNE C_F5_2_4
	LEA BX, call_
	CALL STR_TO_BUFF_BX
	CALL ADD_MIDDLE_TAB
	LEA BX, far_
	CALL STR_TO_BUFF_BX
	JMP C_F5_PART2
C_F5_2_4:	
	CMP BYTE PTR [reg], 100b
	JNE C_F5_2_5
	LEA BX, jmp_
	CALL STR_TO_BUFF_BX
	CALL ADD_MIDDLE_TAB
	LEA BX, near_
	CALL STR_TO_BUFF_BX
	JMP C_F5_PART2
C_F5_2_5:	
	CMP BYTE PTR [reg], 101b	;JMP WORD FAR?
	JNE C_F5_2_6
	LEA BX, jmp_
	CALL STR_TO_BUFF_BX
	CALL ADD_MIDDLE_TAB
	LEA BX, far_
	CALL STR_TO_BUFF_BX
	JMP C_F5_PART2
C_F5_2_6:
	LEA BX, push_
	CALL STR_TO_BUFF_BX

 
 
C_F5_PART2:	
	CALL ADD_MIDDLE_TAB
	
	
	CMP BYTE PTR [modd], 3
	JNE C_F5_PART2_1
	
	MOV DL, [rm]
	MOV [reg], DL
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	JMP C_F5_END
	
C_F5_PART2_1:
	CMP BYTE PTR [is_ptr], 1
	JNE C_F5_NOTPTR
	CALL WRITE_PTR
	MOV BYTE PTR [is_ptr], 0
	
	
C_F5_NOTPTR:	
	MOV DL, '['
	CALL CHAR_TO_BUFF_FROM_DL
	
	CALL ADDRESS_TO_BUFF
	
	MOV DL, ']'
	CALL CHAR_TO_BUFF_FROM_DL
C_F5_END:

	POP DX
	POP BX
	RET
	
ENDP COMPLETE_FORMAT_5





;**********************************************************************
;**			1000 00sw mod ### r/m [poslinkis] bojb [bovb]			 **
;**			1100 011w mod 000 r/m [poslinkis] bojb [bovb]			 **
;**********************************************************************
PROC COMPLETE_FORMAT_6
	PUSH BX
	PUSH DX
	
		
	
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte1], DL
	AND DL, 00000001b
	MOV [w], DL
	MOV DL, [byte_temp]
	AND DL, 00000010b
	SHR DL, 1
	MOV [s], DL
	
	
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte2], DL	
	
	;idedamAS mod
	AND DL, 11000000b
	SHR DL, 6
	MOV [modd], DL
	
	;idedamas r/m
	MOV DL, [byte2]
	AND DL, 00000111b
	MOV BYTE PTR [rm], DL
	
	;idedama vidurine reiksme i reg
	MOV DL, [byte2]
	AND DL, 00111000b
	SHR DL, 3
	MOV BYTE PTR [reg], DL

	CALL ANALYSE_MOD_AND_RM
	
	
	
	MOV DL, [byte1]
	AND DL, 11111110b
	CMP DL, 11000110b
	JE PICK_FOR_MOV
	
	
	
	CMP BYTE PTR [s], 0
	JNE S_NOTZERO
	
PICK_FOR_MOV:	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [bojb], DL
	CMP BYTE PTR [w], 0
	JE S_DONE
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [bovb], DL
	
	JMP S_DONE
	
S_NOTZERO:
	CALL GRAB_BYTE
	MOV [bovb], 0
	MOV DL, [byte_temp]
	MOV BYTE PTR [bojb], DL
	CMP BYTE PTR [bojb], 80h
	JB S_DONE
	MOV [bovb], 0FFh
	
S_DONE:
	
	CALL ADD_TABS

	MOV [d], 9	;nesumaisyt MOV SU KITAIS.
;1100 011w mod 000 r/m [poslinkis] bojb [bovb] – MOV 	
	MOV DL, [byte1]
	AND DL, 11111110b
	CMP DL, 11000110b
	
	
	JNE C_F6_1
	MOV [d], 1
	LEA BX, mov_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
	
C_F6_1:
	;1000 00sw mod XXX r/m [poslinkis] bojb [bovb]
	CMP BYTE PTR [reg], 000b
	JNE C_F6_2
	LEA BX, add_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
C_F6_2:	
	CMP BYTE PTR [reg], 101b
	JNE C_F6_3
	LEA BX, sub_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
C_F6_3:	
	CMP BYTE PTR [reg], 111b
	JNE C_F6_4
	LEA BX, cmp_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
;	Pridedu dar xor, or, and adc ir sbb
C_F6_4:	
	CMP BYTE PTR [reg], 110b
	JNE C_F6_5
	LEA BX, xor_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
C_F6_5:	
	CMP BYTE PTR [reg], 001b
	JNE C_F6_6
	LEA BX, or_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
C_F6_6:	
	CMP BYTE PTR [reg], 100b
	JNE C_F6_7
	LEA BX, and_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
C_F6_7:	
	CMP BYTE PTR [reg], 010b
	JNE C_F6_8
	LEA BX, adc_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
C_F6_8:
	CMP BYTE PTR [reg], 011b
	;JNE C_F6_9
	LEA BX, sbb_
	CALL STR_TO_BUFF_BX
	JMP  C_F6_PART2
	
	
	
	
	
C_F6_PART2:
	CALL ADD_MIDDLE_TAB
	
	CMP BYTE PTR [modd], 3
	JNE C_F6_PART2_1
	
	MOV DL, [rm]
	MOV [reg], DL
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	JMP C_F6_PART3
	
C_F6_PART2_1:
	CALL WRITE_PTR




C_F6_PART2_3:

	MOV DL, '['
	CALL CHAR_TO_BUFF_FROM_DL
	
	CALL ADDRESS_TO_BUFF
	
	MOV DL, ']'
	CALL CHAR_TO_BUFF_FROM_DL


C_F6_PART3:
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	
	
	CMP BYTE PTR [d], 1
	JE TWO_BOP
		
	CMP BYTE PTR [s], 0
	JNE C_F6_PART3_1
TWO_BOP:
	CMP BYTE PTR [w], 0
	JE C_F6_NOWORD
	MOV DL, [bovb]
	CALL PRINT_HEX
C_F6_NOWORD:
	MOV DL, [bojb]
	CALL PRINT_HEX
	JMP C_F6_END
	
C_F6_PART3_1:
	CMP BYTE PTR [bojb], 80h
	JB C_F6_PART3_1_1
	MOV DL, [bovb]
	CALL PRINT_HEX
C_F6_PART3_1_1:
	MOV DL, [bojb]
	CALL PRINT_HEX
C_F6_END:	
	POP DX
	POP BX
	RET

ENDP COMPLETE_FORMAT_6







;**********************************************************************
;**			0000 #0dw mod reg r/m [poslinkis]						 **
;**			001# #0dw mod reg r/m [poslinkis]						 **
;**			1000 10dw mod reg r/m [poslinkis]						 **
;**********************************************************************
PROC COMPLETE_FORMAT_7
	PUSH BX
	PUSH DX
	
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte1], DL
	AND DL, 00000001b
	MOV [w], DL
	
	MOV DL, [byte_temp]
	AND DL, 00000010b
	SHR DL, 1
	MOV [d], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte2], DL
	
	
	
	;idedamAS mod
	AND DL, 11000000b
	SHR DL, 6
	MOV [modd], DL
	
	;idedamas r/m
	MOV DL, [byte2]
	AND DL, 00000111b
	MOV BYTE PTR [rm], DL
	
	;idedama vidurine reiksme i reg
	MOV DL, [byte2]
	AND DL, 00111000b
	SHR DL, 3
	MOV BYTE PTR [reg], DL

	CALL ANALYSE_MOD_AND_RM
	CALL ADD_TABS
	
	MOV DL, [byte1]
	AND DL, 11111100b
	
	CMP DL, 00000000b
	JNE C_F_7_1
	LEA BX, add_
	CALL STR_TO_BUFF_BX
	JMP C_F_7_PART2
	
C_F_7_1:
	CMP DL, 00101000b
	JNE C_F_7_2
	LEA BX, sub_
	CALL STR_TO_BUFF_BX
	JMP C_F_7_PART2
C_F_7_2:
	CMP DL, 00111000b
	JNE C_F_7_3
	LEA BX, cmp_
	CALL STR_TO_BUFF_BX
	JMP C_F_7_PART2
C_F_7_3:
	CMP DL, 00001000b
	JNE C_F_7_4
	LEA BX, or_
	CALL STR_TO_BUFF_BX
	JMP C_F_7_PART2
C_F_7_4:
	CMP DL, 00110000b
	JNE C_F_7_5
	LEA BX, xor_
	CALL STR_TO_BUFF_BX
	JMP C_F_7_PART2
C_F_7_5:
	CMP DL, 00100000b
	JNE C_F_7_6
	LEA BX, and_
	CALL STR_TO_BUFF_BX
	JMP C_F_7_PART2
C_F_7_6:
	LEA BX, mov_
	CALL STR_TO_BUFF_BX
	JMP C_F_7_PART2
	
C_F_7_PART2:
	CALL ADD_MIDDLE_TAB
	
	
	CMP BYTE PTR [d], 1
	JNE C_F_7_RMTOREG


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; REG <- RM
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	
	
	CMP BYTE PTR [modd], 3
	JNE C_F_7_MODNOT3
	
	MOV DL, [rm]
	MOV [reg], DL
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	JMP C_F_7_END
	
	
	
C_F_7_MODNOT3:
	MOV DL, '['
	CALL CHAR_TO_BUFF_FROM_DL
	
	CALL ADDRESS_TO_BUFF
	
	MOV DL, ']'
	CALL CHAR_TO_BUFF_FROM_DL
	
	JMP C_F_7_END
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RM --> REG
C_F_7_RMTOREG:
	

	CMP BYTE PTR [modd], 3
	JNE C_F_7_MODNOT3_2
	
	MOV DL, [rm]
	MOV [reg], DL
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	JMP C_F_7_CONTINUE
	
	
	
C_F_7_MODNOT3_2:
	CMP BYTE PTR [is_ptr], 0
	JE C_7_IT_IS_NOT_PTR
	CALL WRITE_PTR
C_7_IT_IS_NOT_PTR:
	
	MOV DL, '['
	CALL CHAR_TO_BUFF_FROM_DL
	
	CALL ADDRESS_TO_BUFF
	
	MOV DL, ']'
	CALL CHAR_TO_BUFF_FROM_DL
	
C_F_7_CONTINUE:
	
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX

	JMP C_F_7_END

C_F_7_END:
	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_7





;**********************************************************************
;**			0000 #10w bojb [bovb]									 **
;**			001# #10w bojb [bovb]									 **
;**********************************************************************
PROC COMPLETE_FORMAT_8
	PUSH BX
	PUSH DX

	MOV DL, [byte_temp]
	MOV BYTE PTR [byte1], DL
	AND DL, 00000001b
	MOV [w], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [bojb], DL
	
	CMP BYTE PTR [w], 1
	JNE C_F8_NAME
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [bovb], DL
	
	
C_F8_NAME:
	CALL ADD_TABS
	
	MOV DL, [byte1]
	AND DL, 11111110b
	
	CMP DL, 00000100b
	JNE C_F_8_1
	LEA BX, add_
	CALL STR_TO_BUFF_BX
	JMP C_F_8_PART2
C_F_8_1:
	CMP DL, 00101100b
	JNE C_F_8_2
	LEA BX, sub_
	CALL STR_TO_BUFF_BX
	JMP C_F_8_PART2
C_F_8_2:
	CMP DL, 00110100b
	JNE C_F_8_3
	LEA BX, xor_
	CALL STR_TO_BUFF_BX
	JMP C_F_8_PART2
C_F_8_3:
	CMP DL, 00001100b
	JNE C_F_8_4
	LEA BX, or_
	CALL STR_TO_BUFF_BX
	JMP C_F_8_PART2
C_F_8_4:
	CMP DL, 00100100b
	JNE C_F_8_5
	LEA BX, and_
	CALL STR_TO_BUFF_BX
	JMP C_F_8_PART2
C_F_8_5:

	LEA BX, cmp_
	CALL STR_TO_BUFF_BX
	JMP C_F_8_PART2
	
C_F_8_PART2:
	CALL ADD_MIDDLE_TAB


	
	CMP BYTE PTR [w], 1
	JNE C_F_8_PART2_1
	
	LEA BX, ax_
	CALL STR_TO_BUFF_BX
	
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	
	MOV DL, [bovb]
	CALL PRINT_HEX
	MOV DL, [bojb]
	CALL PRINT_HEX
	JMP C_F_8_END
	
C_F_8_PART2_1:

	LEA BX, al_
	CALL STR_TO_BUFF_BX
	
	LEA BX, comma
	CALL STR_TO_BUFF_BX

	MOV DL, [bojb]
	CALL PRINT_HEX
	JMP C_F_8_END

C_F_8_END:
	POP DX
	POP BX
	RET
	
ENDP COMPLETE_FORMAT_8





;**********************************************************************
;**			1110 100# pjb pvb										 **
;**********************************************************************
PROC COMPLETE_FORMAT_9
	PUSH BX
	PUSH DX
	
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte1], DL
	
	;ASPAKICIUOJAM PJBPVB
	XOR DX, DX
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	CALL GRAB_BYTE
	MOV DH, [byte_temp]
	
	;ADD DX, 3
	MOV [poslinkis], DX
	MOV DX, [offset_v]
	ADD [poslinkis], DX
	
	CALL ADD_TABS
	
	CMP BYTE PTR [byte1], 11101000b
	JNE C_F_9_2
	LEA BX, call_
	CALL STR_TO_BUFF_BX
	JMP C_F1_9_PART2
	
C_F_9_2:
	LEA BX, jmp_
	CALL STR_TO_BUFF_BX
	JMP C_F1_9_PART2
	
C_F1_9_PART2:
	CALL ADD_MIDDLE_TAB
	
	MOV DX, [poslinkis]
	MOV DL, DH
	CALL PRINT_HEX
	
	MOV DX, [poslinkis]
	CALL PRINT_HEX

C_F_9_END:
	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_9








;**********************************************************************
;**			1100 #010 bojb bovb										 **
;**********************************************************************
PROC COMPLETE_FORMAT_10
	PUSH BX
	PUSH DX
	
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte1], DL

	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [bojb], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [bovb], DL
	
	CALL ADD_TABS
	
	CMP BYTE PTR [byte1], 11000010b
	JNE C_F_10_1
	LEA BX, ret_
	CALL STR_TO_BUFF_BX
	JMP C_F_10_PART2
	
C_F_10_1:
	LEA BX, retf_
	CALL STR_TO_BUFF_BX
	JMP C_F_10_PART2	
	
C_F_10_PART2:
	CALL ADD_MIDDLE_TAB
	
	MOV DL, [bovb]
	CALL PRINT_HEX
	MOV DL, [bojb]
	CALL PRINT_HEX
	

	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_10








;**********************************************************************
;**			1001 1010 ajb avb srjb srvb								 **
;**			1110 1010 ajb avb srjb srvb								 **
;**********************************************************************
PROC COMPLETE_FORMAT_11
	PUSH BX
	PUSH DX
	
	MOV DL, [byte_temp]
	MOV BYTE PTR [byte1], DL

	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [ajb], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [avb], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [srjb], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [srvb], DL
	
	
	CALL ADD_TABS
	
	CMP BYTE PTR [byte1], 10011010b	
	JNE C_F_11_1
	LEA BX, call_
	CALL STR_TO_BUFF_BX
	CALL ADD_MIDDLE_TAB
	LEA BX, far_
	CALL STR_TO_BUFF_BX
	JMP C_F_11_PART2
	
C_F_11_1:
	LEA BX, jmp_
	CALL STR_TO_BUFF_BX
	CALL ADD_MIDDLE_TAB
	LEA BX, far_
	CALL STR_TO_BUFF_BX
	JMP C_F_11_PART2	
	
	;; FAR JMP/CMP? 
C_F_11_PART2:
	CALL ADD_MIDDLE_TAB

	MOV DL, [srvb]
	CALL PRINT_HEX
	MOV DL, [srjb]
	CALL PRINT_HEX
	
	MOV DL, ':'
	CALL CHAR_TO_BUFF_FROM_DL
	
	MOV DL, [avb]
	CALL PRINT_HEX
	MOV DL, [ajb]
	CALL PRINT_HEX
	


	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_11








;**********************************************************************
;**			1011 wreg bojb [bovb]									 **
;**********************************************************************
PROC COMPLETE_FORMAT_12
	PUSH BX
	PUSH DX
	
	MOV DL, [byte_temp]
	MOV [byte1], DL
	
	AND DL, 00000111b
	MOV [reg], DL
	
	MOV DL, [byte_temp]
	AND DL, 00001000b
	SHR DL, 3
	MOV [w], DL
	

	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV [bojb], DL
	
	CMP BYTE PTR [w], 1
	JNE C_F_12_1
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV [bovb], DL

C_F_12_1:	
	CALL ADD_TABS
	
	LEA BX, mov_
	CALL STR_TO_BUFF_BX
	
	CALL ADD_MIDDLE_TAB
	
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	
	CMP BYTE PTR [w], 1
	JNE C_F_12_2
	MOV DL, [bovb]
	CALL PRINT_HEX
C_F_12_2:
	MOV DL, [bojb]
	CALL PRINT_HEX
	
	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_12








;**********************************************************************
;**			1010 00#w ajb avb										 **
;**********************************************************************
PROC COMPLETE_FORMAT_13
	PUSH BX
	PUSH DX
	
	MOV DL, [byte_temp]
	MOV [byte1], DL
	AND DL, 00000001b
	MOV [w], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV [ajb], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV [avb], DL
	
	
	
	CALL ADD_TABS
	
	

	LEA BX, mov_
	CALL STR_TO_BUFF_BX
	CALL ADD_MIDDLE_TAB
	CALL WRITE_PTR
	
	MOV DL, [byte1]
	AND DL, 11111110b
;----------AKUM <- ATMINTIS
	CMP DL, 10100000b
	JNE C_13_1
	
	
	CMP BYTE PTR [w], 1
	JNE C_13_0_BYTE
	
	LEA BX, ax_
	CALL STR_TO_BUFF_BX
	JMP C_13_0_ADDRESS
	
C_13_0_BYTE:
	LEA BX, al_
	CALL STR_TO_BUFF_BX
	JMP C_13_0_ADDRESS
	
C_13_0_ADDRESS:	
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	MOV DL, '['
	CALL CHAR_TO_BUFF_FROM_DL
	
	CALL WRITE_PREFIX
	MOV DL, [avb]
	CALL PRINT_HEX
	MOV DL, [ajb]
	CALL PRINT_HEX
	
	
	MOV DL, ']'
	CALL CHAR_TO_BUFF_FROM_DL
	JMP C_13_END


;----------ATMINTIS -> AKUM	
C_13_1:

	

	MOV DL, '['
	CALL CHAR_TO_BUFF_FROM_DL
	
	CALL WRITE_PREFIX
	MOV DL, [avb]
	CALL PRINT_HEX
	MOV DL, [ajb]
	CALL PRINT_HEX
	
	
	MOV DL, ']'
	CALL CHAR_TO_BUFF_FROM_DL
	
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	
	
	CMP BYTE PTR [w], 1
	JNE C_13_1_BYTE
	LEA BX, ax_
	CALL STR_TO_BUFF_BX
	JMP C_13_END
	
	
C_13_1_BYTE:
	LEA BX, al_
	CALL STR_TO_BUFF_BX
	JMP C_13_END

	
C_13_END:
	POP DX
	POP BX
	RET
	
	
ENDP COMPLETE_FORMAT_13









;**********************************************************************
;**			1000 11d0 mod 0sr r/m [poslinkis]						 **
;**********************************************************************
PROC COMPLETE_FORMAT_14
	PUSH BX
	PUSH DX
	PUSH AX
	
	MOV DL, [byte_temp]
	MOV [byte1], DL
	
	AND DL, 00000010b
	SHR DL, 1
	MOV [d], DL
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV [byte2], DL
	
	AND DL, 11000000b
	SHR DL, 6
	MOV [modd], DL
	
	MOV DL, [byte2]
	AND DL, 00000111b
	MOV [rm], DL
	
	
	;I REG IDESIM SREG REIKSME
	MOV DL, [byte2]
	AND DL, 00011000b
	SHR DL, 3
	MOV [reg], DL
	
	CALL ANALYSE_MOD_AND_RM
	
	CALL ADD_TABS
	LEA BX, mov_
	CALL STR_TO_BUFF_BX
	CALL ADD_MIDDLE_TAB
	


	CMP BYTE PTR [d], 1
	JNE C_14_TORM
	
;------------SEGREG <--- ATMINTIS/REG	
	MOV AH, [sr]
	MOV DL, [reg]
	MOV [sr], DL
	CALL LOAD_SEG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	MOV [sr], AH
	
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	
	
	
	CMP BYTE PTR [modd], 3
	JNE C_14_MODNOT3
	
	MOV DL, [rm]
	MOV [reg], DL
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	JMP C_14_END
	
	
	
C_14_MODNOT3:
	MOV DL, '['
	CALL CHAR_TO_BUFF_FROM_DL
	
	CALL ADDRESS_TO_BUFF
	
	MOV DL, ']'	
	CALL CHAR_TO_BUFF_FROM_DL
	
	JMP C_14_END

;------------ATMINTIS/REG  <--- SEGREG 
	
C_14_TORM:

	CMP BYTE PTR [modd], 3
	JNE C_14_MODNOT3_1
	
	MOV DL, [rm]
	MOV [reg], DL
	CALL LOAD_REG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	JMP C_14_2
	
	
	
C_14_MODNOT3_1:
	MOV DL, '['
	CALL CHAR_TO_BUFF_FROM_DL
	
	CALL ADDRESS_TO_BUFF
	
	MOV DL, ']'	
	CALL CHAR_TO_BUFF_FROM_DL
C_14_2:		
	LEA BX, comma
	CALL STR_TO_BUFF_BX
	
	MOV AH, [sr]
	
	MOV DL, [reg]
	MOV [sr], DL
	CALL LOAD_SEG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	
	MOV [sr], AH
	
	JMP C_14_END

C_14_END:
	POP AX
	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_14








;**********************************************************************
;**			0111 #### poslinkis										 **
;**			1110 001# poslinkis										 **
;**			1110 1011 poslinkis										 **
;**********************************************************************
PROC COMPLETE_FORMAT_15
	PUSH BX
	PUSH DX
	
	MOV DL, [byte_temp]
	MOV [byte1], DL
	
	
	MOV [poslinkis], 0
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	XOR DH, DH
	CMP DL, 80h
	JB DONT_EXPAND
	MOV DH, 0FFh
DONT_EXPAND:
	MOV [poslinkis], DX
	MOV DX, [offset_v]
	ADD [poslinkis], DX
	
	CALL ADD_TABS
	
	CMP BYTE PTR [byte1], 70h
	JNE C_15_1
	LEA BX, jo_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_1:
	CMP BYTE PTR [byte1], 71h
	JNE C_15_2
	LEA BX, jno_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_2:
	CMP BYTE PTR [byte1], 72h
	JNE C_15_3
	LEA BX, jnae_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_3:
	CMP BYTE PTR [byte1], 73h
	JNE C_15_4
	LEA BX, jae_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_4:
	CMP BYTE PTR [byte1], 74h
	JNE C_15_5
	LEA BX, je_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_5:
	CMP BYTE PTR [byte1], 75h
	JNE C_15_6
	LEA BX, jne_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_6:	
	CMP BYTE PTR [byte1], 76h
	JNE C_15_7
	LEA BX, jbe_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_7:	
	CMP BYTE PTR [byte1], 77h
	JNE C_15_8
	LEA BX, ja_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_8:	
	CMP BYTE PTR [byte1], 78h
	JNE C_15_9
	LEA BX, js_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_9:	
	CMP BYTE PTR [byte1], 79h
	JNE C_15_10
	LEA BX, jns_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_10:	
	CMP BYTE PTR [byte1], 7Ah
	JNE C_15_11
	LEA BX, jp_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_11:	
	CMP BYTE PTR [byte1], 7Bh
	JNE C_15_12
	LEA BX, jnp_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_12:	
	CMP BYTE PTR [byte1], 7Ch
	JNE C_15_13
	LEA BX, jl_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_13:	
	CMP BYTE PTR [byte1], 7Dh
	JNE C_15_14
	LEA BX, jge_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_14:	
	CMP BYTE PTR [byte1], 7Eh
	JNE C_15_15
	LEA BX, jle_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_15:	
	CMP BYTE PTR [byte1], 7Fh
	JNE C_15_16
	LEA BX, jg_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_16:
	CMP BYTE PTR [byte1], 0E3h
	JNE C_15_17
	LEA BX, jcxz_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_17:	
	CMP BYTE PTR [byte1], 0E2h
	JNE C_15_18
	LEA BX, loop_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_18:
	CMP BYTE PTR [byte1], 0EBh
	JNE C_15_19
	LEA BX, jmp_
	CALL STR_TO_BUFF_BX
	JMP C_15_PART2
	
C_15_19:		
	
C_15_PART2:	
	CALL ADD_MIDDLE_TAB
	
	MOV DX, [poslinkis]
	MOV DL, DH
	CALL PRINT_HEX
	
	MOV DX, [poslinkis]
	CALL PRINT_HEX

	POP DX
	POP BX
	RET
ENDP COMPLETE_FORMAT_15






;**********************************************************************
;**			Parašo prefix'ą, jei toks yra.							 **
;**********************************************************************
PROC WRITE_PREFIX
	PUSH BX
	PUSH DX
	
	
	CMP BYTE PTR [sr], 9
	JE NO_PREFIX
	CALL LOAD_SEG_NAME_TO_BX
	CALL STR_TO_BUFF_BX
	MOV DL, ':'
	CALL CHAR_TO_BUFF_FROM_DL
NO_PREFIX:

	POP DX
	POP BX

	RET
ENDP WRITE_PREFIX




;**********************************************************************
;**			Suformatuoja adresą pagal mod ir r/m, įrašo į bufferį.	 **
;**********************************************************************
PROC ADDRESS_TO_BUFF
	PUSH BX
	PUSH DX
	
	CALL WRITE_PREFIX
	;PREFIXAS AR YRA?
	;CMP BYTE PTR [sr], 9
	;JE A1_RM
	;CALL LOAD_SEG_NAME_TO_BX
	;CALL STR_TO_BUFF_BX
	;MOV DL, ':'
	;CALL CHAR_TO_BUFF_FROM_DL
	
	
;A1_RM:	
	CMP BYTE PTR [modd], 0
	JE MOD_ZERO
	JMP MOD_NOTZERO
MOD_ZERO:
	CMP BYTE PTR[rm], 000b
	JNE A_RM1
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	JMP ADDR_END
A_RM1:
	CMP BYTE PTR[rm], 001b
	JNE A_RM2
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	JMP ADDR_END
A_RM2:
	CMP BYTE PTR[rm], 010b
	JNE A_RM3
	LEA BX, bp_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	JMP ADDR_END
A_RM3:
	CMP BYTE PTR[rm], 011b
	JNE A_RM4
	LEA BX, bp_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	JMP ADDR_END
A_RM4:
	CMP BYTE PTR[rm], 100b
	JNE A_RM5
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	JMP ADDR_END
A_RM5:
	CMP BYTE PTR[rm], 101b
	JNE A_RM6
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	JMP ADDR_END
A_RM6:
	CMP BYTE PTR[rm], 110b
	JNE A_RM7
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	JMP ADDR_END
	
A_RM7:
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	JMP ADDR_END
;----------------------------------------------------


MOD_NOTZERO:
	CMP BYTE PTR [modd], 01b
	JE MOD_ONE
	JMP MOD_NOTONE
MOD_ONE:
	CMP BYTE PTR [poslinkis_j], 80h
	JB MOD_ONE_INDEED
	JMP MOD_NOTONE


	
MOD_ONE_INDEED:
	CMP BYTE PTR[rm], 000b
	JNE AA_RM1
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AA_RM1:
	CMP BYTE PTR[rm], 001b
	JNE AA_RM2
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AA_RM2:
	CMP BYTE PTR[rm], 010b
	JNE AA_RM3
	LEA BX, bp_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AA_RM3:
	CMP BYTE PTR[rm], 011b
	JNE AA_RM4
	LEA BX, bp_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	JMP ADDR_END
AA_RM4:
	CMP BYTE PTR[rm], 100b
	JNE AA_RM5
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	JMP ADDR_END
AA_RM5:
	CMP BYTE PTR[rm], 101b
	JNE AA_RM6
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AA_RM6:
	CMP BYTE PTR[rm], 110b
	JNE AA_RM7
	LEA BX, bp_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
	
AA_RM7:
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	JMP ADDR_END


;--------------------------------


MOD_NOTONE:
	CMP BYTE PTR[rm], 000b
	JNE AAA_RM1
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AAA_RM1:
	CMP BYTE PTR[rm], 001b
	JNE AAA_RM2
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AAA_RM2:
	CMP BYTE PTR[rm], 010b
	JNE AAA_RM3
	LEA BX, bp_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AAA_RM3:
	CMP BYTE PTR[rm], 011b
	JNE AAA_RM4
	LEA BX, bp_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AAA_RM4:
	CMP BYTE PTR[rm], 100b
	JNE AAA_RM5
	LEA BX, si_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AAA_RM5:
	CMP BYTE PTR[rm], 101b
	JNE AAA_RM6
	LEA BX, di_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
AAA_RM6:
	CMP BYTE PTR[rm], 110b
	JNE AAA_RM7
	LEA BX, bp_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END
	
AAA_RM7:
	LEA BX, bx_
	CALL STR_TO_BUFF_BX
	MOV DL, '+'
	CALL CHAR_TO_BUFF_FROM_DL
	MOV DL, [poslinkis_v]
	CALL PRINT_HEX
	MOV DL, [poslinkis_j]
	CALL PRINT_HEX
	
	JMP ADDR_END

ADDR_END:
	POP DX
	POP BX
	RET

ENDP ADDRESS_TO_BUFF





;**********************************************************************
;**			Analizuoja Mod ir R/m. Pagal tai, nusrepndžia, ar		 **	
;**			ir kiek reikia dar paimt papildomų baitų iš bufferio.	 **
;**********************************************************************
PROC ANALYSE_MOD_AND_RM
	PUSH BX
	PUSH DX
	
	CMP BYTE PTR [modd], 3
	JE ANALYSE_MOD_AND_RM_END
		
	; Jei mod 10b
	CMP BYTE PTR [modd], 2
	JNE ANALYSE_MOD_AND_RM_1
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [poslinkis_j], DL
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [poslinkis_v], DL
	JMP ANALYSE_MOD_AND_RM_END
	
ANALYSE_MOD_AND_RM_1:
	CMP BYTE PTR [modd], 1
	JNE ANALYSE_MOD_AND_RM_0
	
	
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	
	MOV BYTE PTR [poslinkis_j], DL
	CMP BYTE PTR [poslinkis_j], 80h	; PLEČIAMAS PLĖSTI PLĖTIMAS ADRESAS
	JB ANALYSE_MOD_AND_RM_END
	MOV BYTE PTR [poslinkis_v], 0FFh
	JMP ANALYSE_MOD_AND_RM_END
	
ANALYSE_MOD_AND_RM_0:	
	CMP BYTE PTR [rm], 6 ; AR TIESIOGINIS ADRESAS?
	JNE ANALYSE_MOD_AND_RM_END
	
	MOV [is_ptr], 1
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [poslinkis_j], DL
	CALL GRAB_BYTE
	MOV DL, [byte_temp]
	MOV BYTE PTR [poslinkis_v], DL
	JMP ANALYSE_MOD_AND_RM_ALTERNATIVE_END
	
ANALYSE_MOD_AND_RM_END:
	MOV [is_ptr], 0
	
ANALYSE_MOD_AND_RM_ALTERNATIVE_END:	
	POP DX
	POP BX
	RET
ENDP ANALYSE_MOD_AND_RM



	
;**********************************************************************
;**			Patikrina, ar prefixas. Įrašoma atinkama reikšmė į sr    **	
;**********************************************************************	
PROC GET_PREFIX
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	CMP BYTE PTR [byte_temp], 26h
	JNE NOT_26
	MOV [sr], 0h
	JMP GO__TO_END
NOT_26:
	CMP BYTE PTR [byte_temp], 2Eh
	JNE NOT_2E
	MOV [sr], 1h
	JMP GO__TO_END
NOT_2E:
	CMP BYTE PTR [byte_temp], 36h
	JNE NOT_36
	MOV [sr], 2h
	JMP GO__TO_END
NOT_36:
	CMP BYTE PTR [byte_temp], 3Eh
	JNE NOT_3E
	MOV [sr], 3h
	JMP GO__TO_END
NOT_3E:
	
	;NERA JOKIO PREFIKSO, JEI IKI CIA PRIEJO
	MOV [sr], 9h
	
GO__TO_END:	
	POP DX
	POP CX
	POP BX
	POP AX
	RET
ENDP GET_PREFIX
	
	
	
	
;**********************************************************************
;**			Paima baitą iš buferio								     **	
;**********************************************************************	
PROC GRAB_BYTE
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	
	XOR BX, BX
	MOV BL, read_count
	CMP BYTE PTR [pars_count], BL
	JB DONT_GRAB_MORE
GRAB_MORE:
	CALL READ_TO_BUFF
	MOV pars_count, 0
DONT_GRAB_MORE:
	XOR DX, DX
	MOV DL, pars_count
	MOV SI, DX
	LEA BX, i_buff
	MOV BX, [BX+SI]
	MOV BYTE PTR [byte_temp], BL
	INC [pars_count]
	
	MOV DL, [byte_temp]
	CALL PRINT_HEX
	
	MOV DL, ' '
	XOR BX, BX
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	
	INC [offset_v] ;PADIDINAM IP REIKŠMĘ
	
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX
	RET
ENDP GRAB_BYTE





;**********************************************************************
;**			Nuskaitom iš failo į buffer'į.						     **	
;**********************************************************************	
PROC READ_TO_BUFF
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV AX, 3F00h
	MOV BX, handlef1
	MOV CX, ISIZE
	LEA DX, i_buff
	INT 21h
	JC ERROR_READ
	MOV [read_count], AL
	
	CMP AL, 0
	JE NO_BYTES_LEFT
	POP DX
	POP CX
	POP BX
	POP AX
	RET

NO_BYTES_LEFT:
	;CALL WRITE_TO_FILE
	CALL SUCCESS
	CALL CLOSEPROGRAM
	
ERROR_READ:
	LEA DX, stars
    CALL PRINT_STR     
    LEA DX, error4
    CALL PRINT_STR
    LEA DX, stars
    CALL PRINT_STR 
	
	CALL CLOSEPROGRAM
	
ENDP READ_TO_BUFF




;**********************************************************************
;**			Įrašom output bufferio reikšmes į failą.			     **	
;**********************************************************************	
PROC WRITE_TO_FILE
	
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	CALL WRITE_ENTER_AT_END
	
	MOV BX, handlef2
	XOR CX, CX
	MOV CL, o_buff_pos
	LEA DX, o_buff
	MOV AX, 4000h
	INT 21h
	JC ERROR_WRITE
	
	MOV o_buff_pos, 0
	
	POP DX
	POP CX
	POP BX
	POP AX
	RET
	
ERROR_WRITE:
	LEA DX, stars
    CALL PRINT_STR     
    LEA DX, error3
    CALL PRINT_STR
    LEA DX, stars
    CALL PRINT_STR 
	
	CALL CLOSEPROGRAM
	
	
ENDP WRITE_TO_FILE




;**********************************************************************
;**			Spausdina einamąjį poslinkį prieš mašinnį kodą ir        **	
;**			disasemblintą komandą.									 **
;**********************************************************************	
PROC CS_IP
	PUSH BX
	PUSH DX
	
	MOV DX, [offset_v]
	MOV DL, DH
	CALL PRINT_HEX
	
	MOV DX, [offset_v]
	CALL PRINT_HEX
	
	MOV DL, ':'
	XOR BX, BX
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	
	MOV DL, TAB
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	
	POP DX
	POP BX
	
	RET
	
ENDP CS_IP




;**********************************************************************
;**			DL reikšmę atspausdina hex skaičiais. Kitaip tariant,    **	
;**			Jei DL'e yra 5A, tai buff[x] = 5, buff[x+1] = A0		 **
;**********************************************************************	
PROC PRINT_HEX; DL REGISTRE BAITO REIKSME

	PUSH AX
	PUSH BX
	PUSH DX

	MOV AL, DL
	
	SHR DL, 4h
	CMP DL, 9h
	JBE NUM
	ADD DL, 11h
	SUB DL, 0Ah
	NUM:
	ADD DL, '0'
	
	XOR BX, BX
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	
	MOV DL, AL
	AND DL, 0Fh
	CMP DL, 9h
	JBE NUM2
	ADD DL, 11h
	SUB DL, 0Ah
	NUM2:
	ADD DL, '0'
	
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_poS
	

	
	POP DX
	POP BX
	POP AX

	
	RET

ENDP PRINT_HEX





;**********************************************************************
;**			Space tarp mašininio kodo ir disasemblinto			     **	
;**********************************************************************	
PROC ADD_TABS
	PUSH BX
	PUSH DX
	MOV DL, SPC
	CMP BYTE PTR [o_buff_pos], GAP_SIZE_BETWEEN_CODE
	JNB TABS_END
KEEP_ADDING_TABS:	
	XOR BX, BX
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	CMP BYTE PTR [o_buff_pos], GAP_SIZE_BETWEEN_CODE; Kol Neprirašėm space iki pozicijos.
	JB KEEP_ADDING_TABS
TABS_END:
	POP DX
	POP BX
	RET
ENDP ADD_TABS






;**********************************************************************
;**			Space tarp komandos ir kintamųjų. Pvz, POP <space> ax    **	
;**********************************************************************	
PROC ADD_MIDDLE_TAB
	PUSH BX
	PUSH DX
	MOV DL, SPC
KEEP_ADDING_TABS_2:	
	XOR BX, BX
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	CMP BYTE PTR [o_buff_pos], GAP_SIZE_BETWEEN_CODE_2; Kol Neprirašėm space iki pozicijos.
	JB KEEP_ADDING_TABS_2
	
	POP DX
	POP BX
	RET
ENDP ADD_MIDDLE_TAB




;**********************************************************************
;**	 Jei į BX įdėtas masyvo adresas, įdės visas jo reikšmes į buff   **	
;**********************************************************************	
PROC STR_TO_BUFF_BX	;PRIES KREIPIANTIS I SITA FUNKCIJA, STRINGO ADRESA IDET I BX.
	PUSH BX
	PUSH DX
	PUSH SI
	XOR SI, SI
	
STR_REPEAT:	
	CMP BYTE PTR [BX+SI], '$'
	JE STR_END
	MOV DL, [BX+SI]
	CALL CHAR_TO_BUFF_FROM_DL
	INC SI
	JMP STR_REPEAT
	
STR_END:
	POP SI
	POP DX
	POP BX
	RET

ENDP STR_TO_BUFF_BX

PROC CHAR_TO_BUFF_FROM_DL
	PUSH BX
	PUSH DX
	
	XOR BX, BX
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	
	POP DX
	POP BX
	RET

ENDP CHAR_TO_BUFF_FROM_DL





;**********************************************************************
;**			Į BX įdeda atitinkamo segmento pavadinimo masyvo adresą	 **	
;**********************************************************************	
PROC LOAD_SEG_NAME_TO_BX
	PUSH DX
	
	MOV DL, [sr]
	CMP DL, 00h;
	JNE C_F1_1
	LEA BX, es_
	JMP C_F1_END
C_F1_1:
	CMP DL, 01h;
	JNE C_F1_2
	LEA BX, cs_
	JMP C_F1_END
C_F1_2:
	CMP DL, 02h;
	JNE C_F1_3
	LEA BX, ss_
	JMP C_F1_END
C_F1_3:
	LEA BX, ds_

C_F1_END:

	POP DX
	RET
	
ENDP LOAD_SEG_NAME_TO_BX



;**********************************************************************
;**			Į BX įdeda atitinkamo registro pavadinimo masyvo adresą	 **	
;**********************************************************************	
PROC LOAD_REG_NAME_TO_BX
	PUSH DX
	CMP BYTE PTR [w], 1
	JNE LRN_B
	
LRN_W:
	CMP BYTE PTR [reg], 0
	JNE LRN_W1
	LEA BX, ax_
	JMP LRN_END
LRN_W1:	
	CMP BYTE PTR [reg], 1
	JNE LRN_W2
	LEA BX, cx_
	JMP LRN_END
LRN_W2:	
	CMP BYTE PTR [reg], 2
	JNE LRN_W3
	LEA BX, dx_
	JMP LRN_END
LRN_W3:	
	CMP BYTE PTR [reg], 3
	JNE LRN_W4
	LEA BX, bx_
	JMP LRN_END		
LRN_W4:	
	CMP BYTE PTR [reg], 4
	JNE LRN_W5
	LEA BX, sp_
	JMP LRN_END		
LRN_W5:	
	CMP BYTE PTR [reg], 5
	JNE LRN_W6
	LEA BX, bp_
	JMP LRN_END	
LRN_W6:	
	CMP BYTE PTR [reg], 6
	JNE LRN_W7
	LEA BX, si_
	JMP LRN_END	
LRN_W7:	
	LEA BX, di_
	JMP LRN_END	
	
	
	
LRN_B:

	CMP BYTE PTR [reg], 0
	JNE LRN_B1
	LEA BX, al_
	JMP LRN_END
LRN_B1:	
	CMP BYTE PTR [reg], 1
	JNE LRN_B2
	LEA BX, cl_
	JMP LRN_END
LRN_B2:	
	CMP BYTE PTR [reg], 2
	JNE LRN_B3
	LEA BX, dl_
	JMP LRN_END
LRN_B3:	
	CMP BYTE PTR [reg], 3
	JNE LRN_B4
	LEA BX, bl_
	JMP LRN_END		
LRN_B4:	
	CMP BYTE PTR [reg], 4
	JNE LRN_B5
	LEA BX, ah_
	JMP LRN_END		
LRN_B5:	
	CMP BYTE PTR [reg], 5
	JNE LRN_B6
	LEA BX, ch_
	JMP LRN_END	
LRN_B6:	
	CMP BYTE PTR [reg], 6
	JNE LRN_B7
	LEA BX, dh_
	JMP LRN_END	
LRN_B7:	
	LEA BX, bh_
	
LRN_END:
	
	POP DX
	RET
ENDP LOAD_REG_NAME_TO_BX




;**********************************************************************
;**			Enter į bufferį.										 **	
;**********************************************************************	
PROC WRITE_ENTER_AT_END
	PUSH BX
	PUSH DX
	
	MOV DL, CR
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	MOV DL, LF
	MOV BL, o_buff_pos
	MOV o_buff[BX], DL
	INC o_buff_pos
	POP DX
	POP BX
	RET
ENDP WRITE_ENTER_AT_END



;**********************************************************************
;**			Byte/Word ptr į bufferį									 **	
;**********************************************************************	
PROC WRITE_PTR
	PUSH BX
	PUSH DX
	
	CMP BYTE PTR [w], 0
	JNE PT_WORD
	LEA BX, ptr_byte
	CALL STR_TO_BUFF_BX
	JMP PTR_END
	
PT_WORD:
	LEA BX, ptr_word
	CALL STR_TO_BUFF_BX
	
PTR_END:	
	POP DX
	POP BX
	RET

ENDP WRITE_PTR



;*************************************************************************************************
;***		KOMANDINĖS EILUTĖS IR FAILŲ ATIDARYMAI, VALIDACIJOS, PAGALBOS PRANEŠIMAI		   ***
;*************************************************************************************************



PROC CMD_SCAN 
    PUSH SI
    PUSH BX
    PUSH AX
    PUSH DI
    PUSH DX
    MOV DX, 0
    MOV DI, 0
    MOV AX, 0 ;JEI AL= 0, TAI IKI SIOL BUVO SUTIKTI TIK TARPAI. JEI AL = 1, TAI PRASIDEJES YRA FAILO PAV.
    MOV DX, 0
    MOV SI, 82h
	
	CMP BYTE PTR ES:[80h], 0 ; Jei nieko neįvesta į kom. eilutę, spausdinamas pagalbos pranešimas.
    JE J_INFO
     
KEEP_SCANNING:
    CMP BYTE PTR ES:[SI], CR
    JE EOL
    
    CMP BYTE PTR ES:[SI], ' '
    JE SPACE
    
    CMP AL, 1
    JE SKIP
    MOV AL, 1
    INC AH
SKIP:    
    CMP AH, 1
    JE F1
    CMP AH, 2
    JE F2
	JMP KEEP_SCANNING
F1: 
    LEA BX,FILE1
    JMP WORD_2
F2:
    LEA BX,FILE2
    JMP WORD_2       
WORD_2:
    MOV DL, ES:[SI]
    MOV [BX+DI], DL
    INC SI
    INC DI
    JMP KEEP_SCANNING
SPACE:
    CMP AL, 0
    JE SPACE_2
    MOV AL, 0
    MOV DI, 0     
SPACE_2:       
    INC SI
    JMP KEEP_SCANNING    

FM:
	CMP AH, 0
	JE J_INFO
	CMP AH, 1
	JNE FILE_COUNT_ERROR
	LEA BX, file1
	CMP BYTE PTR BX[0], '/'
	JNE FILE_COUNT_ERROR
	CMP BYTE PTR BX[1], '?'
	JNE FILE_COUNT_ERROR
	CMP BYTE PTR BX[2], 0
	JNE FILE_COUNT_ERROR
J_INFO:
	CALL INFO
FILE_COUNT_ERROR:
    CALL FERROR

EOL:
    CMP AH, 2
    JNE FM
    
    POP DX
    POP DI   
    POP AX    
    POP BX    
    POP SI    
    RET   
ENDP CMD_SCAN 


PROC FERROR
    LEA DX, stars
    CALL PRINT_STR 
    LEA DX, filemistake
    CALL PRINT_STR
    LEA DX, stars
    CALL PRINT_STR  
    CALL INFO  
ENDP FERROR

PROC OPEN_FILE

    PUSH AX
    PUSH DX
    PUSH BX
    
    MOV AX, 3D00h ; AL = 0, nes failas bus tik skaitomas.
    LEA DX, file1 ; Nurodomas file1 pav. adresas.
    INT 21h
    JC ERROR_OPEN1
    
    LEA BX, handlef1
    MOV [BX], AX  ;Išsaugomas dekriptoriaus numeris į handlef2.
    
    POP BX
    POP DX
    POP AX 
    RET
  
ERROR_OPEN1:
    LEA DX, stars
    CALL PRINT_STR 
    LEA DX, f1_error
    CALL PRINT_STR
    
    LEA DX, error1
    CALL PRINT_STR
    LEA DX, stars
    CALL PRINT_STR  
    
    CALL INFO
ENDP OPEN_FILE


PROC CREATE_FILE 
    PUSH CX
    PUSH DX
    PUSH AX
	PUSH BX
    
    MOV AX, 3C00h
    MOV CX, 0
    LEA DX, file2
    INT 21h
    JC ERROR_CREATE 
    
    LEA BX, handlef2
    MOV [BX], AX
    
    POP BX
    POP AX
    POP DX
    POP CX
    RET  
    
ERROR_CREATE:
    LEA DX, stars
    CALL PRINT_STR 
    LEA DX, f2_error
    CALL PRINT_STR
    
    LEA DX, error2
    CALL PRINT_STR
    LEA DX, stars
    CALL PRINT_STR 
    
    
    CALL INFO 
      
ENDP CREATE_FILE


PROC INFO
    LEA DX, hyphens
    CALL PRINT_STR
    LEA DX, prog_info1
	CALL PRINT_STR
	LEA DX, hyphens
    CALL PRINT_STR
	LEA DX, prog_info2
	CALL PRINT_STR
    LEA DX, hyphens
    CALL PRINT_STR
    CALL CLOSEPROGRAM
ENDP INFO


PROC SUCCESS
	PUSH DX
	LEA DX, succ_msg
	CALL PRINT_STR
	
	MOV AH, 3Eh
	MOV BX, handlef1
	INT 21h
	
	MOV AH, 3Eh
	MOV BX, handlef2
	INT 21h
	
	
	POP DX
	RET
ENDP SUCCESS


PROC PRINT_STR
    PUSH AX
    MOV AX, 0900h
    INT 21h
    POP AX  
    RET
ENDP PRINT_STR

         
PROC CLOSEPROGRAM

	
    MOV AX, 4C00h
    INT 21h    
ENDP       

END PREMAIN
