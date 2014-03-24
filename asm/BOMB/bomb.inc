;local prototye
	WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD      
	WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
	PaintProc PROTO :DWORD    
	KeyDownProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
	KeyUpProc PROTO :DWORD,:DWORD,:DWORD
    TimerProc PROTO :DWORD,:DWORD,:DWORD
	DrawSquare PROTO :DWORD,:DWORD,:DWORD

.data
	MENU_ABOUTAUTHOR    equ    1000

	;窗体参数
	WndWidth dd 568
	WndHeight dd 591
	ClientWidth dd 488
	ClientHeight dd 488
	WndOffX dd 850
	WndOffY dd 150
	BgColor dd 00EFF8FAh
	BgBmpWidth dd 485
	BgBmpHeight dd 485
	ClientOffX dd 30
	ClientOffY dd 30
	SquareWidth dd 107
	SquareHeight dd 107
	SquareBmpWidth dd 107
	SquareBmpHeight dd 107
	Padding dd 12

	;窗口句柄
	memDC dd 0
	hDC dd 0
	rect RECT <>

	;位图句柄
	BmpBackground dd ?
	BmpIcon dd ?
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

	;位图文件路径
	BmpBackgroundFilePath BYTE 'images/bg485.bmp', 0
	BmpIconFilePath BYTE 'images/icons/icon.ico', 0
	BmpNumberFilePath BYTE 'images/pile107-0.bmp', 0
	BmpNumber2FilePath BYTE 'images/pile107-2.bmp', 0
	BmpNumber4FilePath BYTE 'images/pile107-4.bmp', 0
	BmpNumber8FilePath BYTE 'images/pile107-8.bmp', 0
	BmpNumber16FilePath BYTE 'images/pile107-16.bmp', 0
	BmpNumber32FilePath BYTE 'images/pile107-32.bmp', 0
	BmpNumber64FilePath BYTE 'images/pile107-64.bmp', 0
	BmpNumber128FilePath BYTE 'images/pile107-128.bmp', 0
	BmpNumber256FilePath BYTE 'images/pile107-256.bmp', 0
	BmpNumber512FilePath BYTE 'images/pile107-512.bmp', 0
	BmpNumber1024FilePath BYTE 'images/pile107-1024.bmp', 0
	BmpNumber2048FilePath BYTE 'images/pile107-2048.bmp', 0

	Mp3DeviceID dd 0
	PlayFlag    dd 0
	Mp3Files    db "*.mp3",125 dup (0)
	Mp3Device   db "MPEGVideo",0
	;音乐文件路径
	MusicFileName db 'music.mp3', 0