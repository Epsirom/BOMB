IFNDEF BOMB_INC

MAX_MAP_SIZE = 20
MAP_SIZE = MAX_MAP_SIZE + 1

;local prototye
	CopyMap PROTO
	CopyMapWithoutBomb PROTO
	WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD      
	WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
	PaintProc PROTO :DWORD    
	KeyDownProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
	KeyUpProc PROTO :DWORD,:DWORD,:DWORD
    TimerProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
	DrawSquare PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
	DrawNextNumberText PROTO
	PlayMp3File PROTO :DWORD,:DWORD
	InitRect PROTO
	GetMoveDis PROTO :DWORD,:DWORD
	CheckHasCombBomb PROTO
	CheckCombine PROTO :DWORD,:DWORD
	CheckExplode PROTO :DWORD,:DWORD

.data
	POSITIVE_MAX equ 80000000h
	MENU_ABOUTAUTHOR equ 1000
	MoveTime equ 8
	CombineTime equ 12
	ShowNewTime equ 8
	ExplodeTime equ 32
	Interval equ 3

	GameTitle db "BOMB!",0
	NextNumberText db " Next Bomb Number:", 0
	FontName db "Arial", 0
	WinMsg db "You Win!", 0
	FailMsg db "You Lose!", 0
	WinMsgTitle db "成功", 0
	FailMsgTitle db "失败", 0
	MoveDir dd 0
	EXTERNDEF oldmap:SDWORD

	;窗体参数
	WndWidth dd 568
	WndHeight dd 691
	ClientWidth dd 488
	ClientHeight dd 488
	WndOffX dd 850
	WndOffY dd 150
	BgColor dd 00EFF8FAh
	TextBgColor dd 00A0ADBBh
	BgBmpWidth dd 485
	BgBmpHeight dd 485
	ClientOffX dd 30
	ClientOffY dd 130
	SquareWidth dd 107
	SquareHeight dd 107
	SquareBmpWidth dd 107
	SquareBmpHeight dd 107
	Padding dd 12

	;窗口句柄
	memDC dd 0
	imgDC dd 0
	hDC dd 0
	hBitmap HBITMAP ?
	bgBrush HBRUSH ?
	titleFont HFONT ?
	textFont HFONT ?
	textBgBrush HBRUSH ?
	rect RECT <>

	;位图句柄
	BmpBackground dd ?
	BmpIcon dd ?
	BmpBrick dd ?
	BmpNumber0 dd ?
	BmpNumber2 dd ?
	BmpNumber4 dd ?
	BmpNumber8 dd ?
	BmpNumber16 dd ?
	BmpNumber32 dd ?
	BmpNumber64 dd ?
	BmpNumber128 dd ?
	BmpNumber256 dd ?
	BmpNumber512 dd ?
	BmpNumber1024 dd ?
	BmpNumber2048 dd ?
	BmpBomb dd ?

	Mp3DeviceID dd 0
	PlayFlag    dd 0
	Mp3Files    db "*.mp3",125 dup (0)
	Mp3Device   db "MPEGVideo",0
	;音乐文件路径
	MusicFileName db 'music.mp3', 0
;===================Macros====================
SetCurrentBmp MACRO num:REQ
	.IF num >= POSITIVE_MAX
		mov eax, BmpBrick
	.ELSEIF num == 0
		mov eax, BmpNumber0
	.ELSEIF num == 1
		mov eax, BmpBomb
	.ELSEIF num == 2
		mov eax, BmpNumber2
	.ELSEIF num == 4
		mov eax, BmpNumber4
	.ELSEIF num == 8
		mov eax, BmpNumber8
	.ELSEIF num == 16
		mov eax, BmpNumber16
	.ELSEIF num == 32
		mov eax, BmpNumber32
	.ELSEIF num == 64
		mov eax, BmpNumber64
	.ELSEIF num == 128
		mov eax, BmpNumber128
	.ELSEIF num == 256
		mov eax, BmpNumber256
	.ELSEIF num == 512
		mov eax, BmpNumber512
	.ELSEIF num == 1024
		mov eax, BmpNumber1024
	.ELSEIF num == 2048
		mov eax, BmpNumber2048
	.ENDIF
ENDM

; uses ebx
; return eax
OldMapAt MACRO x:REQ, y:REQ
	push ebx
	.IF (x == -1) || (y == -1) || (x >= mapSize) || (y >= mapSize)
		mov eax, -1
	.ELSE
	mov ebx, mapRowSize
	imul ebx, x
	mov eax, oldmap[ebx + y * TYPE map]
	.ENDIF
	pop ebx
ENDM

; uses ebx
SetOldMapAt MACRO x:REQ, y:REQ, val:REQ
	push ebx
	mov ebx, mapRowSize
	imul ebx, x
	mov oldmap[ebx + y * TYPE map], val
	pop ebx
ENDM

AppendQueue MACRO
	mov [edi], eax
	add edi, TYPE resultQueue
ENDM


ENDIF