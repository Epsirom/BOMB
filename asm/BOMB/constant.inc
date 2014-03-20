.data

MENU_ABOUTAUTHOR    equ    1000

;窗体参数
WndWidth dd 505
WndHeight dd 528
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

;位图文件路径
BmpBackgroundFilePath BYTE "BgBmp.bmp", 0
BmpNumber2FilePath BYTE "Number2.bmp", 0