.386
;---------------
STACK SEGMENT USE16 STACK
DB 200 DUP(0)
STACK ENDS
;---------------
DATA SEGMENT USE16
SNAME DB 'SHOP', 0;店名
BNAME DB 'taowei', 4 DUP(0);老板名
BPWD DB 'test', 0, 0;密码
INNAME DB 'please input your name:$';提示输入老板名
INPWD DB 'please input your password:$';提示输入密码
NAMEERROR DB 'name wrong!$';提示老板名错误
PWDERROR DB 'password wrong!$';提示密码错误
WELCOME DB 'welcome to shop of taowei!$';欢迎信息
AUTH DB ?;老板和顾客标志位，0代表顾客，1代表老板
CRLF DB 0DH, 0AH, '$';输出换行回车
in_name DB 10;输入的老板名存储在此处
        DB ?
        DB 10 DUP(0)
in_pwd DB 6;输入的密码存储在此处
       DB ?
       DB 6 DUP(0)
N EQU 30;商品数量
GA1 DB N-2 DUP('Temp-Value', 8, 15, 0, 20, 0, 30, 0, 2, 0, ?, ?);商品数量的一般形式
    DB 'PEN', 7 DUP(0), 10;商品名称及折扣;一个具体的商品，名字为“PEN”
    DW 35, 56, 70, 25, ?;推荐度还未计算
    DB 'BOOK', 6 DUP(0), 9
    DW 12, 30, 25, 5, ?   
FINDPRIO DB 'please input the good you want to search:$';提示输入需要查询的商品
GOODNAME DB 'the good name is:$';输出商品名
SHOWPRIO DB 'the good priority is:$';输出商品优先级
GOODFREE DB 'the good is given for free! just come and get it! $';当商品折扣为0时的提示信息
in_good DB 10;输入的商品名存储在此处
        DB ?
        DB 10 DUP(10)
DATA ENDS
;--------------
CODE SEGMENT USE16
	ASSUME CS: CODE, DS: DATA, SS: STACK
START: MOV AX, DATA
       MOV DS, AX
	 MOV BYTE PTR SNAME+4,'$'
	 LEA DX, SNAME;显示商店名称
	 MOV AH, 9
	 INT 21H
	 LEA DX, CRLF;输出换行
	 MOV AH, 9
	 INT 21H
LOPA:  LEA DX, INNAME;提示输入用户名
	 MOV AH, 9
	 INT 21H
	 LEA DX, in_name;读取从键盘输入的姓名
	 MOV AH, 10
	 INT 21H
	 MOV BH, in_name+2
       CMP BH, 'q';当输入姓名时的字符为q时，直接退出
	 JE EXIT
	 CMP BH, 0DH;如果只输入了一个回车，则把0送到AUTH变量，跳转到功能三
	 JNE NEXT1
	 MOV AUTH, 0
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       JMP NEXT3
NEXT1: LEA DX, CRLF;输出换行
       MOV AH, 9
       INT 21H
       MOV SI, 0
       MOV AL, in_name+1
LOPNAME:
       MOV BH, in_name+2[SI]
       CMP BH, BNAME[SI]
       JNE EXIT2
       INC SI
       DEC AL
       JNE LOPNAME
       MOV BH, BNAME[SI]
       CMP BH, 0
       JNE EXIT2
       JMP LOPB
LOPB:  MOV SI, 0
       LEA DX, INPWD;提示输入密码
       MOV AH, 9
       INT 21H
       LEA DX, in_pwd;读取从键盘输入的密码
       MOV AH, 10
       INT 21H
       MOV AL, in_pwd+1
LOPPWD:MOV BH, in_pwd+2[SI]
       CMP BH, BPWD[SI]
       JNE EXIT3
       INC SI
       DEC AL
       JNE LOPPWD
       MOV BH, BPWD[SI]
       CMP BH, 0
       JNE EXIT3
       JMP NEXT2
EXIT2: LEA DX, NAMEERROR
	 MOV AH, 9
	 INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
	 JMP LOPA
EXIT3: LEA DX, CRLF
       MOV AH, 9
       INT 21H 
       LEA DX, PWDERROR
       MOV AH, 9
       INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       JMP LOPB
NEXT2: LEA DX, CRLF
       MOV AH, 9
       INT 21H
       LEA DX, WELCOME
	 MOV AH, 9
	 INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       MOV AUTH, 1
NEXT3: LEA DX, FINDPRIO;提示用户输入需要查询的商品的推荐度
       MOV AH, 9
       INT 21H
       LEA DX, in_good;
       MOV AH, 10
       INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       MOV SI, 0
       MOV BX, 0
       MOV DI, 0;表示当前商品数量
       MOV AL, in_good[1];
       MOV CH, in_good[2]
       CMP CH, 0DH
       JNZ LOPGOOD_NAME
       JMP LOPA
LOPGOOD:
       INC DI
       MOV SI, 0
       ADD BX, 21
       CMP DI, N
       JAE NEXT3
LOPGOOD_NAME:
       MOV CL, GA1[SI][BX]
       CMP CL, in_good+2[SI]
       JNZ LOPGOOD
       INC SI
       DEC AL
       JNE LOPGOOD_NAME
       MOV CL, GA1[SI][BX]
       CMP CL, 0;防止输入的是商品名称的子串的情况
       JNE LOPGOOD
AUTH_BRANCH:
       CMP BYTE PTR AUTH, 1
       JZ AUTH1
       JMP AUTH0
AUTH1: LEA DX, GOODNAME;已经登陆的状态
       MOV AH, 9
       INT 21H
       MOV SI, 0
       MOV AL, in_good[1]
LOPSHOWNAME:
       MOV DL, GA1[SI][BX]
       MOV AH, 2
       INT 21H
       INC SI
       DEC AL
       JNE LOPSHOWNAME
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       JMP LOPA
AUTH0: MOV SI, 13
       MOV AX, WORD PTR GA1[SI][BX];销售价
       MOV SI, 10
       MOV CL, GA1[SI][BX];折扣
       CMP CL, 0
       JE SHOWFREE
       MOV CH, 00H
       MUL CX;(销售价*折扣),字乘法，DX、AX中存放结果
       MOV CX, 10
       DIV CX;字除法，此时AX中存放实际销售价格
       MOV BP, AX
       MOV SI, 11
       MOV AX, WORD PTR GA1[SI][BX];进货价
       MOV DX, 00H
       SAL AX, 7
       DIV BP;进货价/实际销售价，字除法，AX存放结果
       ADD SI, 4
       MOV DX, WORD PTR GA1[SI][BX];进货总数
       SAL DX, 1
       ADD SI, 2
       MOV CX, WORD PTR GA1[SI][BX];已售数量
       MOV BP, AX
       MOV AX, CX
       MOV CX, DX
       MOV DX, 00H
       SAL AX, 7
       DIV CX;（已售数量）/（2*进货总数）,字除法，AX存放结果
       ADD BP, AX
       JMP NEXT4
NEXT4: LEA DX, SHOWPRIO
       MOV AH, 9
       INT 21H
       CMP BP, 100
       JG SHOWA
       CMP BP, 50
       JG SHOWB
       CMP BP, 10
       JG SHOWC
       JMP SHOWF
SHOWA: MOV DL, 41H
       MOV AH, 2
       INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       JMP LOPA
SHOWB: MOV DL, 42H
       MOV AH, 2
       INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       JMP LOPA
SHOWC: MOV DL, 43H
       MOV AH, 2
       INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       JMP LOPA
SHOWF: MOV DL, 46H
       MOV AH, 2
       INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       JMP LOPA
SHOWFREE:
       LEA DX, GOODFREE
       MOV AH, 9
       INT 21H
       LEA DX, CRLF
       MOV AH, 9
       INT 21H
       JMP LOPA
EXIT:  MOV AH, 4CH
       INT 21H
;---------------------
CODE ENDS
       END START

