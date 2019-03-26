.386
;----------------------------
STACK	SEGMENT  use16 STACK
		DB	200 DUP(0)
STACK	ENDS
;----------------------------
DATA	SEGMENT use16
BUF1	DB	0, 1, 2, 3, 4, 5, 6, 7, 8, 9
BUF2	DB	10	DUP(0)
BUF3	DB	10	DUP(0)
BUF4	DB	10	DUP(0)
DATA	ENDS
;------------------------------
CODE SEGMENT use16
        ASSUME CS:CODE,DS:DATA,SS:STACK
BEGIN:	
	MOV  AX, DATA
	MOV  DS, AX
	MOV  SI, 0
	MOV  CX, 10
LOPA:
	MOV  AL, BUF1[SI]
	MOV  BUF2[SI], AL
	INC  AL
	MOV  BUF3[SI], AL
	ADD  AL, 3
	MOV  BUF4[SI], AL
	INC  SI
	INC  DI
	INC  BP
	INC  BX
	DEC  CX
	JNZ  LOPA
	MOV  AH,4CH
	INT  21H
;-----------------------------
CODE	ENDS
	END BEGIN
