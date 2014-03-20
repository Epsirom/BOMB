;local prototye
	WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD      
	WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
	PaintProc PROTO :DWORD    
	KeyDownProc PROTO :DWORD,:DWORD,:DWORD
	KeyUpProc PROTO :DWORD,:DWORD,:DWORD
	DrawSquare PROTO :DWORD,:DWORD,:DWORD

.data
	MENU_ABOUTAUTHOR    equ    1000

	;窗体参数
	WndWidth dd 508
	WndHeight dd 531
	ClientWidth dd 488
	ClientHeight dd 488
	WndOffX dd 850
	WndOffY dd 150
	BgColor dd 00FAF8EFh
	BgBmpWidth dd 485
	BgBmpHeight dd 485
	SquareWidth dd 107
	SquareHeight dd 107
	SquareBmpWidth dd 107
	SquareBmpHeight dd 107
	Padding dd 12

	;窗口句柄
	memDC dd 0
	hDC dd 0

	;位图句柄
	BmpBackground dd ?
	BmpNumber2 dd ?
	BmpIcon dd ?

	;位图文件路径
	BmpBackgroundFilePath BYTE 'images/bg485.bmp', 0
	BmpNumber2FilePath BYTE 'images/pile107-2.bmp', 0
	BmpIconFilePath BYTE 'images/icons/icon.ico', 0
