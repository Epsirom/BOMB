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
	TryExtractAction PROTO :DWORD

.data
	;窗口句柄
	hInstance dd 0    ;应用程序句柄   
    hWnd dd 0    ;窗口句柄   
    hMenu dd 0    ;菜单句柄   
	CommandLine dd 0
	CurrentBmp dd 0 
	memDC dd 0
	imgDC dd 0
	hDC dd 0
	hBitmap HBITMAP ?
	bgBrush HBRUSH ?
	titleFont HFONT ?
	textFont HFONT ?
	textBgBrush HBRUSH ?
	rect RECT <>
	
	keyLock			db 0; 0:unlock, 1:lock
	aniLock         db 0; 0:unlock, 1:lock
	aniFlag         db 0
	moveticks       dd 0
	combineticks    dd 0
	explodeticks    dd 0
	showticks       dd 0
	GameRect        RECT <>
	BombNumRect     RECT <>
	qlen			dd 0
	hasCombBomb     dd 0
	newNum			dd 0
	newNumPosX		dd 0
	newNumPosY		dd 0
	oldmap SDWORD MAP_SIZE DUP(-1)
	REPEAT MAP_SIZE - 1
		SDWORD MAP_SIZE DUP(-1)
	ENDM

	POSITIVE_MAX equ 80000000h
	MENU_NEWGAMEM equ 1000
	MENU_NEWGAMEH equ 1001
	MENU_SAVEGAME equ 1002
	MENU_PLAYMUSIC equ 1003
	MENU_STOPMUSIC equ 1004
	MENU_HELPINFO equ 1005
	MENU_ABOUTAUTHOR equ 1006
	MaxMoveTime equ 8
	MaxCombineTime equ 12
	MaxShowNewTime equ 8
	MaxExplodeTime equ 32
	Interval equ 3
	ANIUNLOCKED equ 0
	ANILOCKED equ 1
	KEYUNLOCKED equ 0
	KEYLOCKED equ 1

	MoveTime dd 0
	CombineTime dd 0
	ShowNewTime dd 0
	ExplodeTime dd 0
	
	;字符串定义
	GameTitle db "BOMB!",0
	NextNumberText db " Next Bomb Number:", 0
	FontName db "Arial", 0
	WinMsg db "YOU WIN!!!", 0
	FailMsg db "YOU LOSE!", 0
	LoadMsg db "Do you want to read the game progress?", 0
	QuitMsg db "Do you want to save the game progress?", 0
	MsgTitle db 0
	MoveDir dd 0
	ErrorTitle db "Error",0
    ClassName db "Demo",0      
    WindowName db "BOMB",0      
    MenuAbout db "Help", 0
	MenuAboutHelpInfo db "Help(H)", 0      
    MenuAboutAuthor db "About Us(A)", 0   
    Author db "Author: wcc",0dh,"Date: 19/03/2014",0
	Help db "Keyboard Shortcuts",0dh,"'N' for creating a new game",0dh,"'S' for saving the game progress",0dh,"'P' for playing the background music",0dh,"'P' again for stopping the background music",0
	MenuFile db "File",0 
	MenuFileNewM db "New(medium)",0
	MenuFileNewH db "New(hard)",0 
	MenuFileSave db "Save(S)",0
	MenuFilePlay db "Play Music(P)",0
	MenuFileStop db "Stop Music(P)",0

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
	BmpNumber4096 dd ?
	BmpNumber8192 dd ?
	BmpNumber16384 dd ?
	BmpNumber32768 dd ?
	BmpNumber65536 dd ?
	BmpBomb dd ?

	Mp3DeviceID dd 0
	PlayFlag    dd 0
	Mp3Files    db "*.mp3",125 dup (0)
	Mp3Device   db "MPEGVideo",0
	Mp3BombDeviceID dd 0
	BombSoundTime dd 0
	Mp3BombDevice   db "MPEGVideo",0
	;音乐文件路径
	MusicFileName db 'music.mp3', 0
	BombFileName db 'bomb.mp3', 0
	
	;Action Queue
	AQ_LEN EQU 16
	AQueue dd AQ_LEN DUP(0)
	AHead dd 0
	ATail dd 0
	ALock dd 0
	
;===================Macros====================
AppendAQueue MACRO act:REQ
	push ebx
	mov ebx, AHead
	.IF ebx == 0
		mov ebx, AQ_LEN
	.ENDIF
	dec ebx
	.IF ATail != ebx
		mov ebx, ATail
		mov AQueue[ebx * TYPE AQueue], act
		inc ATail
		.IF ATail >= AQ_LEN
			mov ATail, 0
		.ENDIF
	.ENDIF
	pop ebx
ENDM

ExtractAQueue MACRO
	push edx
	mov eax, -1
	mov edx, ATail
	.IF AHead != edx
		push ebx
		mov ebx, AHead
		mov eax, AQueue[ebx * TYPE AQueue]
		inc AHead
		.IF AHead >= AQ_LEN
			mov AHead, 0
		.ENDIF
		pop ebx
	.ENDIF
	pop edx
ENDM

;清空AQueue
ResetAQueue MACRO
	mov AHead, 0
	mov ATail, 0
ENDM

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
	.ELSEIF num == 4096
		mov eax, BmpNumber128
	.ELSEIF num == 8192
		mov eax, BmpNumber256
	.ELSEIF num == 16384
		mov eax, BmpNumber512
	.ELSEIF num == 32768
		mov eax, BmpNumber1024
	.ELSEIF num == 65536
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

SetOriginTimeLim MACRO
	mov MoveTime, MaxMoveTime
	mov CombineTime, MaxCombineTime
	mov ShowNewTime, MaxShowNewTime
	mov ExplodeTime, MaxExplodeTime
ENDM

SetTimeLim MACRO divisor:REQ
	push edx
	push ebx
	mov edx, 0
	mov ebx, divisor
	mov eax, MaxMoveTime
	div ebx
	mov MoveTime, eax
	mov eax, MaxShowNewTime
	div ebx
	mov ShowNewTime, eax
	mov eax, MaxCombineTime
	div ebx
	mov ebx, 2
	mul ebx
	mov ebx, 3
	div ebx
	mov CombineTime, eax
	mov eax, MaxExplodeTime
	mov ebx, divisor
	div ebx
	mov ebx, 4
	div ebx
	mov ExplodeTime, eax
	pop ebx
	pop edx
ENDM

AdjustAniTimeLim MACRO
	push ecx
	push ebx
	mov ebx, ATail
	.IF ebx >= AHead
		sub ebx, AHead
	.ELSE
		add ebx, AQ_LEN
		sub ebx, AHead
	.ENDIF
	.IF ebx >= 2
		SetTimeLim 2
	.ELSEIF ebx >= 4
		SetTimeLim 4
	.ELSEIF ebx >= 6
		SetTimeLim 8
	.ELSEIF ebx == 0
		SetOriginTimeLim
	.ENDIF
	pop ebx
	pop ecx
ENDM

ResetParameter MACRO
	mov eax, Padding
	mov ebx, mapSize
	inc ebx
	mul ebx
	mov ebx, eax
	mov eax, ClientWidth
	sub eax, ebx
	mov edx, 0
	mov ebx, mapSize
	div ebx
	mov SquareWidth, eax
	mov SquareHeight, eax
ENDM

ResetGame MACRO size:REQ
	mov eax, size
	INVOKE InitMap
	INVOKE CopyMap
	mov aniLock, ANIUNLOCKED
	mov keyLock, KEYUNLOCKED
	ResetAQueue
	ResetParameter
ENDM

ENDIF