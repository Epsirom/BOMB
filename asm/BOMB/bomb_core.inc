
IFNDEF BOMB_CORE_INC
BOMB_CORE_INC equ <1>

;INCLUDE Irvine32.inc
;INCLUDE Macros.inc
;.386      
;    .model flat,stdcall      
;    option casemap:none 


MAX_MAP_SIZE = 20
MAP_SIZE = MAX_MAP_SIZE + 1
RESULT_QUEUE_SIZE = MAX_MAP_SIZE * MAX_MAP_SIZE * 2

.data
EXTERNDEF map:SDWORD, 
	mapRowSize:ABS, 
	mapSize:SDWORD, 
	bombTarget:SDWORD, 
	resultQueue:DWORD, 
	emptyBlocks:SDWORD, 
	numberBlocks:SDWORD

;=================Directions=================
DIR_UP EQU 0
DIR_DOWN EQU 1
DIR_LEFT EQU 2
DIR_RIGHT EQU 3
;=================CheckMapResults==============
MAP_CONTINUE EQU 0
MAP_WIN EQU 1
MAP_FAIL EQU 2

;===================Macros====================
; return eax
Rand MACRO range:REQ
	;mov eax, range
	;call RandomRange
	INVOKE nrandom, range
ENDM

; uses ebx
; return eax
MapAt MACRO x:REQ, y:REQ
	.IF (x == -1) || (y == -1) || (x >= mapSize) || (y >= mapSize)
		mov eax, -1
	.ELSE
	mov ebx, mapRowSize
	imul ebx, x
	mov eax, map[ebx + y * TYPE map]
	.ENDIF
ENDM

; uses ebx
SetMapAt MACRO x:REQ, y:REQ, val:REQ
	mov ebx, mapRowSize
	imul ebx, x
	mov map[ebx + y * TYPE map], val
ENDM

AppendQueue MACRO
	mov [edi], eax
	add edi, TYPE resultQueue
ENDM

;==================Macros End=======================

.code
InitMap PROTO
AddNum PROTO
CheckMap PROTO
DoMove PROTO

	
ELSE
echo -----------------------------------------
echo WARNING Duplicate include file bomb_core.inc
echo -----------------------------------------
ENDIF
