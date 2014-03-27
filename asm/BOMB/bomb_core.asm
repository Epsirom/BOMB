.386      
    .model flat,stdcall      
    option casemap:none 


INCLUDE masm32.inc
INCLUDE bomb_core.inc


.data
map SDWORD MAP_SIZE DUP(-1)
mapRowSize = ($ - map)
REPEAT MAP_SIZE - 1
	SDWORD MAP_SIZE DUP(-1)
ENDM
mapSize SDWORD 3
bombTarget DWORD 4


resultQueue DWORD RESULT_QUEUE_SIZE DUP(0)

; stat
emptyBlocks SDWORD 0
numberBlocks SDWORD 2

.code


; sz in eax
InitMap PROC USES eax ebx ecx edx
	.IF (eax <= 0) || (eax >= 20)
		ret
	.ENDIF
	mov mapSize, eax
	mov ecx, eax
	mov edx, eax
	MapInitLoop:
		mov eax, ecx
		dec eax
		mov ecx, edx
		MapInitLoop2:
			dec ecx
			SetMapAt eax, ecx, -1
			inc ecx
		loop MapInitLoop2
		inc eax
		mov ecx, eax
	loop MapInitLoop
	
	; edx=mapSize
	mov eax, edx
	shr eax, 1
	mov ecx, eax
	dec ecx
	SetMapAt eax, eax, 2
	SetMapAt eax, ecx, 2
	mov emptyBlocks, 0
	mov numberBlocks, 2
	
	mov bombTarget, 4
	;mDumpMem OFFSET map, RESULT_QUEUE_SIZE / 2, TYPE map
	ret
InitMap ENDP


ResetStat PROC USES eax ebx ecx edx
	mov emptyBlocks, 0
	mov numberBlocks, 0
	mov ecx, mapSize
	.WHILE ecx != 0
		dec ecx
		mov edx, mapSize
		.WHILE edx != 0
			dec edx
			mov eax, -1
			MapAt ecx, edx
			.IF eax == 0
				inc emptyBlocks
			.ELSEIF eax < NEG_START
				inc numberBlocks
			.ENDIF
		.ENDW
	.ENDW
	ret
ResetStat ENDP


AddNum PROC USES ebx ecx edx esi edi
	mov ebx, emptyBlocks
	.IF ebx <= 0
	mov eax, 0
	ret
	.ENDIF
	
	Rand ebx
	mov edi, eax
	mov edx, mapSize
	mov ecx, edx
	FindEmptyLoop1:
		mov esi, ecx
		dec esi
		mov ecx, edx
		FindEmptyLoop2:
			dec ecx
			MapAt esi, ecx
			.IF eax == 0
				cmp edi, 0
				jle SetMapAndReturn
				dec edi
			.ENDIF
			inc ecx
		loop FindEmptyLoop2
		inc esi
		mov ecx, esi
	loop FindEmptyLoop1
	SetMapAndReturn:
		Rand 10
		mov edi, 2
		.IF eax >= 9
			shl edi, 1
		.ENDIF
		SetMapAt esi, ecx, edi
		dec emptyBlocks
		inc numberBlocks
		shl esi, 1
		add eax, esi
		shl ecx, 6
		add eax, ecx
	
	ret
AddNum ENDP


CheckMap PROC USES ebx ecx edx esi edi
	LOCAL continueFlag:BYTE, winFlag:BYTE
	mov continueFlag, 0
	mov winFlag, 1
	mov ecx, mapSize
	CheckMapLoop1:
		mov edi, ecx
		dec edi
		mov ecx, mapSize
		CheckMapLoop2:
			dec ecx
			MapAt edi, ecx
			.IF eax == 0
				mov continueFlag, 1
			.ELSEIF eax == -1
				mov winFlag, 0
			.ELSEIF continueFlag == 0
				mov edx, eax
				; check right
				inc ecx
				MapAt edi, ecx
				.IF eax == edx
					mov continueFlag, 1
				.ENDIF
				dec ecx
				; check down
				inc edi
				MapAt edi, ecx
				.IF eax == edx
					mov continueFlag, 1
				.ENDIF
				dec edi
			.ENDIF
			inc ecx
		dec ecx
		cmp ecx, 0
		jg CheckMapLoop2
		inc edi
		mov ecx, edi
	dec ecx
	cmp ecx, 0
	jg CheckMapLoop1
	
	.IF winFlag == 1
		mov eax, MAP_WIN
	.ELSEIF continueFlag == 1
		mov eax, MAP_CONTINUE
	.ELSE
		mov eax, MAP_FAIL
	.ENDIF
	
	ret
CheckMap ENDP


;===============ResultQueueMacros==============

; uses ebx
; return eax
AppendQueueTpl MACRO x:REQ, y:REQ
	mov ebx, x
	shl ebx, 2
	add eax, ebx
	mov ebx, y
	shl ebx, 7
	add eax, ebx
	AppendQueue
	inc qlen
ENDM
; offset in ebx
; return eax
AppendMove MACRO x:REQ, y:REQ
	mov eax, 0
	shl ebx, 12
	add eax, ebx
	AppendQueueTpl x, y
ENDM
; uses ebx
; return eax
AppendCombine MACRO x:REQ, y:REQ
	mov eax, 1
	AppendQueueTpl x, y
ENDM
; uses ebx
; return eax
AppendExplode MACRO x:REQ, y:REQ
	mov eax, 2
	AppendQueueTpl x,y
ENDM
ExplodeAt MACRO x:REQ, y:REQ
	MapAt x, y
	.IF eax == -1
		SetMapAt x, y, 0
		inc emptyBlocks
	.ENDIF
ENDM
; uses eax, ebx
Explode MACRO
	shl bombTarget, 1
	SetMapAt ecx, edx, 0
	inc emptyBlocks
	dec numberBlocks
	dec ecx
	.IF ecx != -1
		ExplodeAt ecx, edx
	.ENDIF
	add ecx, 2
	.IF ecx < mapSize
		ExplodeAt ecx, edx
	.ENDIF
	dec ecx
	dec edx
	.IF edx != -1
		ExplodeAt ecx, edx
	.ENDIF
	add edx, 2
	.IF edx < mapSize
		ExplodeAt ecx, edx
	.ENDIF
	dec edx
	
	AppendExplode ecx, edx
ENDM

NEG_START EQU 80000000h
; direction in eax
DoMove PROC USES ebx ecx edx esi edi
	LOCAL qlen:DWORD, oldVal:DWORD
	mov edi, OFFSET resultQueue
	mov qlen, 0
	mov oldVal, 0
	mov ebx, eax
	cmp ebx, 2
	jge LeftAndRight
	cmp ebx, 1
	jge MoveDown
	
	MoveUp:
		mov edx, 0
		.WHILE edx < mapSize
			mov ecx, 0
			.WHILE ecx < mapSize
				MapAt ecx, edx
				.IF eax < NEG_START	; >= 0
					mov oldVal, eax
					mov esi, ecx
					.REPEAT
						inc esi
						MapAt esi, edx
					.UNTIL eax != 0
					.IF eax >= NEG_START	; <0
						mov ecx, esi
					.ELSE	; eax > 0
						.IF oldVal == 0	; target = 0, move directly
							SetMapAt ecx, edx, eax
							SetMapAt esi, edx, 0
							
							; append move
							mov ebx, esi
							sub ebx, ecx
							AppendMove esi, edx
							
							dec ecx
						.ELSEIF oldVal == eax	; target != 0, and can combine
							shl eax, 1
							SetMapAt ecx, edx, eax
							SetMapAt esi, edx, 0
							push eax
							
							; append move
							mov ebx, esi
							sub ebx, ecx
							AppendMove esi, edx
							
							AppendCombine ecx, edx
							dec numberBlocks
							inc emptyBlocks
							
							pop eax
							.IF eax >= bombTarget
								Explode
							.ENDIF
						;.ELSE	; target != 0, and can not combine, just move next to target
							;inc ecx
							;SetMapAt ecx, edx, eax
							;SetMapAt esi, edx, 0
							
							; append move
							;mov ebx, esi
							;sub ebx, ecx
							;AppendMove esi, edx
							
							;dec ecx
						.ENDIF
					.ENDIF
				.ENDIF
				inc ecx
			.ENDW
			inc edx
		.ENDW
		jmp MoveEnd
	
	MoveDown:
		mov edx, 0
		.WHILE edx < mapSize
			mov ecx, mapSize
			dec ecx
			.WHILE ecx < NEG_START	; >=0
				MapAt ecx, edx
				.IF eax < NEG_START	; >=0
					mov oldVal, eax
					mov esi, ecx
					.REPEAT
						dec esi
						MapAt esi, edx
					.UNTIL eax != 0
					.IF eax >= NEG_START	; <0
						mov ecx, esi
					.ELSE	; eax > 0
						.IF oldVal == 0	; target = 0, move directly
							SetMapAt ecx, edx, eax
							SetMapAt esi, edx, 0
							
							; append move
							mov ebx, ecx
							sub ebx, esi
							AppendMove esi, edx
							
							inc ecx
						.ELSEIF oldVal == eax	; target != 0, and can combine
							shl eax, 1
							SetMapAt ecx, edx, eax
							SetMapAt esi, edx, 0
							push eax
							
							; append move
							mov ebx, ecx
							sub ebx, esi
							AppendMove esi, edx
							
							AppendCombine ecx, edx
							dec numberBlocks
							inc emptyBlocks
							
							pop eax
							.IF eax >= bombTarget
								Explode
							.ENDIF
						;.ELSE	; target != 0, and can not combine, just move next to target
							;dec ecx
							;SetMapAt ecx, edx, eax
							;SetMapAt esi, edx, 0
							
							; append move
							;mov ebx, ecx
							;sub ebx, esi
							;AppendMove esi, edx
							
							;inc ecx
						.ENDIF
					.ENDIF
				.ENDIF
				dec ecx
			.ENDW
			inc edx
		.ENDW
		jmp MoveEnd
	
	LeftAndRight:
		cmp ebx, 3
		jge MoveRight
	
	MoveLeft:
		mov ecx, 0
		.WHILE ecx < mapSize
			mov edx, 0
			.WHILE edx < mapSize
				MapAt ecx, edx
				.IF eax < NEG_START	; >= 0
					mov oldVal, eax
					mov esi, edx
					.REPEAT
						inc esi
						MapAt ecx, esi
					.UNTIL eax != 0
					.IF eax >= NEG_START	; <0
						mov edx, esi
					.ELSE	; eax > 0
						.IF oldVal == 0	; target = 0, move directly
							SetMapAt ecx, edx, eax
							SetMapAt ecx, esi, 0
							
							; append move
							mov ebx, esi
							sub ebx, edx
							AppendMove ecx, esi
							
							dec edx
						.ELSEIF oldVal == eax	; target != 0, and can combine
							shl eax, 1
							SetMapAt ecx, edx, eax
							SetMapAt ecx, esi, 0
							push eax
							
							; append move
							mov ebx, esi
							sub ebx, edx
							AppendMove ecx, esi
							
							AppendCombine ecx, edx
							dec numberBlocks
							inc emptyBlocks
							
							pop eax
							.IF eax >= bombTarget
								Explode
							.ENDIF
							
						;.ELSE	; target != 0, and can not combine, just move next to target
							;inc edx
							;SetMapAt ecx, edx, eax
							;SetMapAt ecx, esi, 0
							
							; append move
							;mov ebx, esi
							;sub ebx, edx
							;AppendMove ecx, esi
							
							;dec edx
						.ENDIF
					.ENDIF
				.ENDIF
				inc edx
			.ENDW
			inc ecx
		.ENDW
		jmp MoveEnd
	
	MoveRight:
		mov ecx, 0
		.WHILE ecx < mapSize
			mov edx, mapSize
			dec edx
			.WHILE edx < NEG_START	; >=0
				MapAt ecx, edx
				.IF eax < NEG_START	; >=0
					mov oldVal, eax
					mov esi, edx
					.REPEAT
						dec esi
						MapAt ecx, esi
					.UNTIL eax != 0
					.IF eax >= NEG_START	; <0
						mov edx, esi
					.ELSE	; eax > 0
						.IF oldVal == 0	; target = 0, move directly
							SetMapAt ecx, edx, eax
							SetMapAt ecx, esi, 0
							
							; append move
							mov ebx, edx
							sub ebx, esi
							AppendMove ecx, esi
							
							inc edx
						.ELSEIF oldVal == eax	; target != 0, and can combine
							shl eax, 1
							SetMapAt ecx, edx, eax
							SetMapAt ecx, esi, 0
							push eax
							
							; append move
							mov ebx, edx
							sub ebx, esi
							AppendMove ecx, esi
							
							AppendCombine ecx, edx
							dec numberBlocks
							inc emptyBlocks
							
							pop eax
							.IF eax >= bombTarget
								Explode
							.ENDIF
							
						;.ELSE	; target != 0, and can not combine, just move next to target
							;dec edx
							;SetMapAt ecx, edx, eax
							;SetMapAt ecx, esi, 0
							
							; append move
							;mov ebx, edx
							;sub ebx, esi
							;AppendMove ecx, esi
							
							;inc edx
						.ENDIF
					.ENDIF
				.ENDIF
				dec edx
			.ENDW
			inc ecx
		.ENDW
		jmp MoveEnd
		
	MoveEnd:
		mov eax, qlen
		ret
	
DoMove ENDP



END