.DATA
  cols DD 0								; lp of columns variable
  rows DD 0								; lp of rows variable

.CODE
;----------------------------------------------
;          MAIN FUNCTION
;----------------------------------------------
calculateTheDanceFloor proc a : DWORD, b : DWORD, c : DWORD, d : DWORD, e : QWORD, f : QWORD

  mov RSI, e							; move original table pointer to RSI
  mov RDI, f							; move return table pointer to RDI
	
  push RBP								; save the value of RBP
  mov RBP, RSP							; RBP now points to the top of the stack
  sub RSP, 48							; space allocated on the stack for the local variables i, j, aliveCount 

  i EQU [RBP - 4]						; columns iteration variable : i
  j EQU [RBP - 8]						; packs (of rows) iteration variable : j
  aliveCount EQU [RBP - 12]				; alive count variable : aliveCount

  packSize EQU [RBP - 20]				; pack size varialbe : packSize
  packsCount EQU [RBP - 24]				; number of packs variable : packsCount
  restCount EQU [RBP - 28]				; rest of rows variable : restCount

  rule12 EQU [RBP - 32]					; constant to check rules for living & 2 neighbours
  rule13 EQU [RBP - 36]					; constant to check rules for living & 3 neighbours
  rule03 EQU [RBP - 40]					; constant to check rules for dead & 3 neighbours

  mov DWORD PTR i, 0					; clear i
  mov DWORD PTR j, 0					; clear j
  mov DWORD PTR aliveCount, 0			; clear aliveCount

  mov DWORD PTR packSize, 8				; clear packSize
  mov DWORD PTR packsCount, 0			; clear packsCount
  mov DWORD PTR restCount, 0			; clear rest

  mov DWORD PTR rule12, 12h				; set rule12
  mov DWORD PTR rule13, 13h				; set rule13
  mov DWORD PTR rule03, 3h				; set rule03
  
  mov cols, ECX							; save cols
  mov rows, EDX							; save rows
  
  mov EAX, R8D							; load starting col [to acumulator]							
  mov DWORD PTR i, EAX					; move acumulator to i
LOOP_I:
  mov EAX, i							; load i
  cmp EAX, R9D							; set flag comparing with ending column
  jg KONIEC								; jump if greater (overflow)
  mov DWORD PTR j, 1					; set j = 1
  jmp CALCULATE_PACKS					; jump
LOOP_J:
  mov EAX, rows							; load rows
  sub EAX, 1							; decrement by 1
  cmp DWORD PTR j, EAX					; set flag comparing with j
  jge INC_I								; jump if greater or equal			
  call DO_CALCULATIONS_MULTIPLE			; call procedure that calculates
  jmp INC_J								; jump
LOOP_M:
  mov EAX, rows							; load rows
  sub EAX, 1							; decrement by 1
  cmp DWORD PTR j, EAX					; set flag comparing with j
  jge INC_I								; jump if greater or equal			
  call DO_CALCULATIONS_SINGLE			; call procedure that calculates
  jmp INC_J								; jump

CALCULATE_PACKS:
  mov EDX, 0							; clear EDX
  mov EAX, rows							; load rows
  mov ECX, packSize						; load packSize
  div ECX								; divide rows by packSize
  mov DWORD PTR restCount, EDX			; save rest
  mov DWORD PTR packsCount, EAX			; save number of packs
  jmp LOOP_J							; jump back

INC_J:
  add DWORD PTR j, 1					; increment j
  jmp LOOP_J							; jump

INC_I:
  add DWORD PTR i , 1					; increment i
  jmp LOOP_I							; jump

KONIEC:
  nop									; do nothing
  mov RSP, RBP							; read return pointer
  pop RBP								; pop return pointer
  ret									; return

calculateTheDanceFloor endp

;----------------------------------------------
;          CALCULATION ON SINGLE ROW
;----------------------------------------------
DO_CALCULATIONS_SINGLE proc
  ;mov RSI, RAX							; move original table pointer to RSI
  ;mov RDI, RBX							; move return table pointer to RDI

  push RBP								; save the value of RBP
  ;mov RBP, RSP							; RBP now points to the top of the stack

  mov DWORD PTR aliveCount, 0			; set aliveCount = 0

;X00
;0 0  UPPER LEFT
;000
UPPER_LEFT:
  mov RAX, 0							; clear RAX
  mov EAX, [RBP-4]						; load i	
  sub EAX, 1							; decrement by 1 [UPPER]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  ;sub EAX, 1							; decrement by 1 [LEFT]
  ;add EAX, 1							; increment by 1
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; get value from table
  cmp EAX, 1							; check if == 1
  jne UPPER_MIDDLE						; jump if not equal (skip next operation)
  add DWORD PTR aliveCount, 1			; increment aliveCount by 1

;0X0
;0 0  UPPER MIDDLE
;000
UPPER_MIDDLE:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  sub EAX, 1							; decrement by 1 [UPPER]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  add EAX, 1							; increment by 1
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; get value from table
  cmp EAX, 1							; check if == 1
  jne UPPER_RIGHT						; jump if not equal (skip next operation)
  add DWORD PTR aliveCount, 1			; increment aliveCount by 1

;00X
;0 0  UPPER RIGHT
;000
UPPER_RIGHT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  sub EAX, 1							; decrement by 1 [UPPER]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  add EAX, 1							; increment by 1 [RIGHT]
  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; get value from table
  cmp EAX, 1							; check if == 1
  jne MIDDLE_LEFT						; jump if not equal (skip next operation)
  add DWORD PTR aliveCount, 1			; increment aliveCount by 1

;000
;X 0  MIDDLE LEFT
;000
MIDDLE_LEFT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  sub EAX, 1							; decrement by 1 [LEFT]
  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; get value from table
  cmp EAX, 1							; check if == 1
  jne MIDDLE_RIGHT						; jump if not equal (skip next operation)
  add DWORD PTR aliveCount, 1			; increment aliveCount by 1

;000
;0 X  MIDDLE RIGHT
;000
MIDDLE_RIGHT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  add EAX, 1							; increment by 1 [RIGHT]
  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; get value from table
  cmp EAX, 1							; check if == 1
  jne DOWN_LEFT							; jump if not equal (skip next operation)
  add DWORD PTR aliveCount, 1			; increment aliveCount by 1

;X00
;0 0  DOWN LEFT
;000
DOWN_LEFT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  add EAX, 1							; increment by 1 [DOWN]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  sub EAX, 1							; decrement by 1 [LEFT]
  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; get value from table
  cmp EAX, 1							; check if == 1
  jne DOWN_MIDDLE						; jump if not equal (skip next operation)
  add DWORD PTR aliveCount, 1			; increment aliveCount by 1

;0X0
;0 0  DOWN MIDDLE
;000
DOWN_MIDDLE:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  add EAX, 1							; increment by 1 [DOWN]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; get value from table
  cmp EAX, 1							; check if == 1
  jne DOWN_RIGHT						; jump if not equal (skip next operation)
  add DWORD PTR aliveCount, 1			; increment aliveCount by 1

;00X
;0 0  DOWN RIGHT
;000
DOWN_RIGHT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  add EAX, 1							; increment by 1 [DOWN]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  add EAX, 1							; increment by 1 [RIGHT]
  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; get value from table
  cmp EAX, 1							; check if == 1
  jne CHECK_RULES_1						; jump if not equal (skip next operation)
  add DWORD PTR aliveCount, 1			; increment aliveCount by 1

CHECK_RULES_1:
  cmp DWORD PTR aliveCount, 3			; compare aliveCount == 3
  jne CHECK_RULES_2						; jump if not
  jmp SET_TABLE_1						; jump

CHECK_RULES_2:
  jmp GET_TABLE_VAL						; jump
BACK:
  cmp EAX, 1							; compare value == 1
  jne RULE_NOK							; jump if not
  cmp DWORD PTR aliveCount, 2			; compare aliveCount == 2
  jne RULE_NOK							; jump if not
  jmp SET_TABLE_1						; jump

RULE_NOK:
  jmp SET_TABLE_0						; jump

SET_TABLE_1:
  mov RAX, 0							; clear RAX
  mov EAX, rows							; get rows
  imul EAX, i							; multiply by i
  add EAX, j							; add j
  add EAX, 1							; add 1
  imul EAX, 4							; multiply by 4
  mov DWORD PTR [RDI + RAX], 1			; move 1 to return table cell
  jmp END_PROCEDURE						; jump

SET_TABLE_0:
  mov RAX, 0							; clear RAX
  mov EAX, rows							; get rows
  imul EAX, i							; multiply by i
  add EAX, j							; add j
  add EAX, 1							; add 1
  imul EAX, 4							; multiply by 4
  mov DWORD PTR [RDI + RAX], 0			; move 0 to return table cell
  jmp END_PROCEDURE						; jump

GET_TABLE_VAL:
  mov RAX, 0							; clear RAX
  mov EAX, rows							; get rows
  imul EAX, i							; multiply by i
  add EAX, j							; add j
  add EAX, 1							; add 1
  imul EAX, 4							; multiply by 4
  mov EAX, [RSI + RAX]					; load value
  jmp BACK								; jump

END_PROCEDURE:
  nop									; do nothing
  ;mov RSP, RBP							; read return pointer
  pop RBP								; pop return pointer
  ret									; return from function

DO_CALCULATIONS_SINGLE endp



;----------------------------------------------
;          CALCULATION ON MULTIPLE ROWS
;----------------------------------------------
DO_CALCULATIONS_MULTIPLE proc
  push RBP								; save the value of RBP
  ;mov RBP, RSP							; RBP now points to the top of the stack

;000
;0X0  CENTER
;000
SAVE_ORIGINAL_VALUES:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
 ; add EAX, 1							; add 1
  imul EAX, 4							; multiply by 4
  vmovups ymm7, [RSI + RAX]				; vector get values from table  
  mov RBX, RAX							; save starting pointer value

;X00
;0 0  UPPER LEFT
;000
M_UPPER_LEFT:
  mov RAX, 0							; clear RAX
  mov EAX, [RBP-4]						; load i	
  sub EAX, 1							; decrement by 1 [UPPER]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  sub EAX, 1							; decrement by 1 [LEFT]
;  add EAX, 1							; increment by 1
  imul EAX, 4							; multiply by 4
  vmovups ymm0, [RSI + RAX]				; vector get values from table

;0X0
;0 0  UPPER MIDDLE
;000
M_UPPER_MIDDLE:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  sub EAX, 1							; decrement by 1 [UPPER]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
;  add EAX, 1							; increment by 1
  imul EAX, 4							; multiply by 4
  vaddps ymm0, ymm0, [RSI + RAX]		; vector get values from table

;00X
;0 0  UPPER RIGHT
;000
M_UPPER_RIGHT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  sub EAX, 1							; decrement by 1 [UPPER]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  add EAX, 1							; increment by 1 [RIGHT]
;  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  vaddps ymm0, ymm0, [RSI + RAX]		; vector get values from table

;000
;X 0  MIDDLE LEFT
;000
M_MIDDLE_LEFT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  sub EAX, 1							; decrement by 1 [LEFT]
;  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  vaddps ymm0, ymm0, [RSI + RAX]		; vector get values from table

;000
;0 X  MIDDLE RIGHT
;000
M_MIDDLE_RIGHT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  add EAX, 1							; increment by 1 [RIGHT]
;  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  vaddps ymm0, ymm0, [RSI + RAX]		; vector get values from table

;X00
;0 0  DOWN LEFT
;000
M_DOWN_LEFT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  add EAX, 1							; increment by 1 [DOWN]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  sub EAX, 1							; decrement by 1 [LEFT]
;  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  vaddps ymm0, ymm0, [RSI + RAX]		; vector get values from table

;0X0
;0 0  DOWN MIDDLE
;000
M_DOWN_MIDDLE:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  add EAX, 1							; increment by 1 [DOWN]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
;  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  vaddps ymm0, ymm0, [RSI + RAX]		; vector get values from table

;00X
;0 0  DOWN RIGHT
;000
M_DOWN_RIGHT:
  mov RAX, 0							; clear RAX
  mov EAX, i							; load i	
  add EAX, 1							; increment by 1 [DOWN]
  imul EAX, rows						; multiply by rows count
  add EAX, j							; add j
  add EAX, 1							; increment by 1 [RIGHT]
;  add EAX, 1							; increment by 1 
  imul EAX, 4							; multiply by 4
  vaddps ymm0, ymm0, [RSI + RAX]		;vector get values from table

SAVE_VALUES_FROM_YMM:
  vpslld ymm6, ymm7, 4					; move left
  vpaddd ymm6, ymm6, ymm0				; add calculated value -> save to ymm6
  vpbroadcastd ymm5, DWORD PTR rule12	; load rule12
  vcmpps ymm1, ymm6, ymm5, 0			; compare with rule12
  vmovups ymm2, ymm1					; move to ymm2
  vpbroadcastd ymm5, DWORD PTR rule13	; load rule13
  vcmpps ymm1, ymm6, ymm5, 0			; compare with rule13
  vpaddd ymm2, ymm2, ymm1				; add to ymm2
  vpbroadcastd ymm5, DWORD PTR rule03	; load rule03
  vcmpps ymm1, ymm6, ymm5, 0			; compare with rule03
  vpaddd ymm2, ymm2, ymm1				; add to ymm2
  vmovups DWORD PTR [RDI + RBX], ymm2	; save to returned table
  jmp M_END_PROCEDURE					; jmp to end procedure

M_END_PROCEDURE:
  nop									; do nothing
  ;mov RSP, RBP							; read return pointer
  pop RBP								; pop return pointer
  ret									; return from function

DO_CALCULATIONS_MULTIPLE endp

END


