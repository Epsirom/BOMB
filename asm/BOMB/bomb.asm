TITLE main.asm      
    .386      
    .model flat,stdcall      
    option casemap:none    



INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
INCLUDELIB gdi32.lib
INCLUDELIB masm32.lib
INCLUDELIB comctl32.lib
INCLUDELIB winmm.lib

INCLUDE masm32.inc
INCLUDE windows.inc
INCLUDE user32.inc
INCLUDE kernel32.inc
INCLUDE gdi32.inc
INCLUDE comctl32.inc
INCLUDE winmm.inc 
        
INCLUDE serialization.inc
INCLUDE bomb.inc

.data      
    hInstance       dd 0    ;应用程序句柄   
    hWnd            dd 0    ;窗口句柄   
    hMenu           dd 0    ;菜单句柄   
	CommandLine     dd 0
	CurrentBmp      dd 0

	ErrorTitle      db "Error",0
    ClassName       db "Demo",0      
    WindowName      db "BOMB",0      
    MenuAbout       db "Help", 0   
    MenuAboutAuthor db "About Author", 0   
    Author          db "Author:wcc",0dh,"Date:   19/03/2014",0   
; ===============================================      
.code      
start:      
	INVOKE GetTickCount
	INVOKE nseed, eax

    INVOKE GetModuleHandle,0    ;获取应用程序模块句柄   
    mov hInstance,eax           ;保存应用程序句柄 

	INVOKE GetCommandLine
	mov CommandLine, eax
    
	INVOKE WinMain,hInstance,0,CommandLine,SW_SHOWDEFAULT      
    INVOKE ExitProcess,eax      ;退出程序,并返回eax的值   
; ===============================================      
WinMain PROC hInst:DWORD, 
			 hPrevInst:DWORD,
			 CmdLine:DWORD,
			 CmdShow:DWORD      

    LOCAL wndclass:WNDCLASSEX      
    LOCAL msg:MSG      


	;初始化窗口
    mov wndclass.cbSize,sizeof WNDCLASSEX      
    mov wndclass.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW      
    mov wndclass.lpfnWndProc,OFFSET WndProc      
    mov wndclass.cbClsExtra,0      
    mov wndclass.cbWndExtra,0      
    mov eax,hInst      
    mov wndclass.hInstance,eax      
	INVOKE CreateSolidBrush,BgColor
    mov wndclass.hbrBackground,eax      
    mov wndclass.lpszMenuName,0      
    mov wndclass.lpszClassName,OFFSET ClassName      
    INVOKE LoadIcon, hInstance, 130
    mov wndclass.hIcon,eax      
    INVOKE LoadCursor,0,IDC_ARROW      
    mov wndclass.hCursor,eax      
    mov wndclass.hIconSm,0      
     
    INVOKE RegisterClassEx,ADDR wndclass    ;注册用户定义的窗口类    
    INVOKE CreateWindowEx,WS_EX_OVERLAPPEDWINDOW, ADDR ClassName,      
                            ADDR WindowName,      
                            WS_OVERLAPPEDWINDOW,      
                            WndOffX,WndOffY,WndWidth,WndHeight,      
                            0,0,      
                            hInst,0           ;创建窗口 
	.IF eax == 0
		call ErrorHandler
		jmp Exit_Program
	.ENDIF		  
    mov   hWnd,eax                          ;保存窗口句柄

	;载入图片
	INVOKE LoadBitmap, hInstance, 101
	mov BmpBackground, eax
	INVOKE LoadBitmap, hInstance, 115
	mov BmpBrick, eax
	INVOKE LoadBitmap, hInstance, 116
	mov BmpNumber0, eax
	INVOKE LoadBitmap, hInstance, 117
	mov BmpNumber2, eax
	INVOKE LoadBitmap, hInstance, 118
	mov BmpNumber4, eax
	INVOKE LoadBitmap, hInstance, 119
	mov BmpNumber8, eax
	INVOKE LoadBitmap, hInstance, 120
	mov BmpNumber16, eax
	INVOKE LoadBitmap, hInstance, 121
	mov BmpNumber32, eax
	INVOKE LoadBitmap, hInstance, 122
	mov BmpNumber64, eax
	INVOKE LoadBitmap, hInstance, 123
	mov BmpNumber128, eax
	INVOKE LoadBitmap, hInstance, 124
	mov BmpNumber256, eax
	INVOKE LoadBitmap, hInstance, 125
	mov BmpNumber512, eax
	INVOKE LoadBitmap, hInstance, 129
	mov BmpNumber1024, eax
	INVOKE LoadBitmap, hInstance, 128
	mov BmpNumber2048, eax

	mov eax, BmpBrick
	mov CurrentBmp, eax
	
	;初始化地图
	INVOKE LoadSerialization
	.IF eax == 0
		mov eax, 4
		INVOKE InitMap
	.ENDIF

    INVOKE ShowWindow,hWnd,SW_SHOWNORMAL    ;     
    INVOKE UpdateWindow,hWnd 
    INVOKE GetWindowRect, hWnd, ADDR rect
    ;设置时钟
    INVOKE SetTimer, hWnd, 1, 20, NULL

;开始程序的持续消息处理循环     
MessageLoop:      
    INVOKE GetMessage,ADDR msg,0,0,0        ;获取消息      
    cmp eax,0      
    je Exit_Program      
    INVOKE TranslateMessage,ADDR msg        ;转换键盘消息   
    INVOKE DispatchMessage,ADDR msg         ;分发消息   
    jmp MessageLoop  
    
	;关闭时钟
	INVOKE KillTimer, hWnd, 1
Exit_Program:
        INVOKE ExitProcess, 0      
WinMain endp      

;播放音乐函数
PlayMp3File PROC hWin:DWORD,NameOfFile:DWORD

	LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS

	mov eax,hWin        
	mov mciPlayParms.dwCallback,eax
	mov eax,OFFSET Mp3Device
	mov mciOpenParms.lpstrDeviceType,eax
	mov eax,NameOfFile
	mov mciOpenParms.lpstrElementName,eax
	INVOKE mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
	mov eax,mciOpenParms.wDeviceID
	mov Mp3DeviceID,eax
	invoke mciSendCommand,Mp3DeviceID,MCI_PLAY,MCI_NOTIFY,ADDR mciPlayParms
	ret  

PlayMp3File ENDP


;消息处理函数   
WndProc PROC hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD      
    LOCAL hPopMenu      ;一级菜单句柄
	LOCAL ps  :PAINTSTRUCT
	LOCAL pt  :POINT

    .IF uMsg == WM_CREATE      
    ;    INVOKE CreateMenu   
    ;    mov hMenu, eax   
    ;    .IF eax   
    ;        INVOKE CreatePopupMenu      ;创建一级菜单   
    ;        mov hPopMenu, eax           ;保存一级菜单句柄   
    ;        INVOKE AppendMenu, hPopMenu, NULL, MENU_ABOUTAUTHOR, addr MenuAboutAuthor   ;添加二级菜单   
    ;        INVOKE AppendMenu, hMenu, MF_POPUP, hPopMenu, addr MenuAbout                ;添加一级菜单   
    ;    .ENDIF   
    ;    INVOKE SetMenu, hWin, hMenu     ;设置菜单
		jmp WndProcExit
	.ELSEIF uMsg == WM_TIMER
        INVOKE TimerProc, uMsg, wParam, lParam
	.ELSEIF uMsg == WM_PAINT
		INVOKE BeginPaint, hWin, ADDR ps
		mov hDC, eax
		INVOKE PaintProc, hWin
		INVOKE EndPaint, hWin, ADDR ps
		jmp WndProcExit
	.ELSEIF uMsg == WM_KEYDOWN
		INVOKE KeyDownProc, hWin, uMsg, wParam, lParam
		jmp WndProcExit
	.ELSEIF uMsg == WM_KEYUP
		INVOKE KeyUpProc, uMsg, wParam, lParam
		jmp WndProcExit
    .ELSEIF uMsg == WM_DESTROY   
        INVOKE PostQuitMessage,0        ;退出消息循环
		jmp WndProcExit     
    .ELSEIF uMsg == WM_COMMAND   
        .IF wParam == MENU_ABOUTAUTHOR   
            INVOKE MessageBoxA,hWin,ADDR Author,ADDR ClassName,MB_OK   
        .ENDIF
		jmp WndProcExit   
    .ELSE
        INVOKE DefWindowProc,hWin,uMsg,wParam,lParam    ;调用默认消息处理函数   
        jmp WndProcExit      
    .ENDIF      
    ;xor eax,eax
WndProcExit:      
    ret      
WndProc endp      

;错误处理，打印出错误信息
ErrorHandler PROC
.data
pErrorMsg  DWORD ?		; ptr to error message
messageID  DWORD ?
.code
	INVOKE GetLastError	; Returns message ID in EAX
	mov messageID,eax

	; Get the corresponding message string.
	INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
	  FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
	  ADDR pErrorMsg,NULL,NULL

	; Display the error message.
	INVOKE MessageBox, NULL, pErrorMsg, ADDR ErrorTitle, MB_ICONERROR+MB_OK

	; Free the error message string.
	INVOKE LocalFree, pErrorMsg
	ret
ErrorHandler ENDP
 
;键盘事件
KeyDownProc PROC hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL qlen: DWORD
	mov qlen, 0
	.IF wParam == VK_UP
		mov eax, DIR_UP
		INVOKE DoMove
		mov qlen, eax
	.ELSEIF wParam == VK_DOWN
		mov eax, DIR_DOWN
		INVOKE DoMove
		mov qlen, eax
	.ELSEIF wParam == VK_LEFT
		mov eax, DIR_LEFT
		INVOKE DoMove
		mov qlen, eax
	.ELSEIF wParam == VK_RIGHT
		mov eax, DIR_RIGHT
		INVOKE DoMove
		mov qlen, eax
	.ELSEIF wParam == 78 ;press VK 'N' to start a new game
		mov eax, 4
		INVOKE InitMap
	.ELSEIF wParam == 83 ;press VK 'S' to save game
		INVOKE SaveSerialization
	.ELSEIF wParam == 80 ;press VK 'P' to Play mp3, press again to stop mp3
		.IF PlayFlag == 0
            mov PlayFlag,1  
            invoke PlayMp3File,hWin,ADDR MusicFileName
		.ELSE
			invoke mciSendCommand,Mp3DeviceID,MCI_CLOSE,0,0
			mov PlayFlag,0
        .ENDIF
	.ELSEIF wParam == MM_MCINOTIFY
        invoke mciSendCommand,Mp3DeviceID,MCI_CLOSE,0,0
        mov PlayFlag,0 
	.ENDIF
	.IF qlen > 0
		INVOKE MoveAnimateProc, qlen, wParam
		INVOKE AddNum
	.ENDIF
	INVOKE InvalidateRect, hWin, NULL, FALSE
	INVOKE CheckMap
	.IF eax == MAP_FAIL
		INVOKE MessageBox, 0, ADDR FailMsg, ADDR FailMsgTitle, MB_OK
		mov eax, 4
		INVOKE InitMap
		INVOKE InvalidateRect, hWin, NULL, FALSE
	.ELSEIF eax == MAP_WIN
		INVOKE MessageBox, 0, ADDR WinMsg, ADDR WinMsgTitle, MB_OK
		mov eax, 4
		INVOKE InitMap
		INVOKE InvalidateRect, hWin, NULL, FALSE
	.ENDIF
	ret
KeyDownProc ENDP

KeyUpProc PROC uMsg:DWORD, wParam:DWORD, lParam:DWORD
	;INVOKE MessageBox, NULL, pErrorMsg, ADDR ErrorTitle, MB_OK
	ret
KeyUpProc ENDP

;时钟事件
TimerProc PROC uMsg:DWORD, wParam:DWORD, lParam:DWORD
	ret
TimerProc ENDP

;绘图函数
PaintProc PROC hWin:DWORD
	LOCAL hOld: DWORD
	LOCAL xIndex: DWORD
	LOCAL yIndex: DWORD
	LOCAL textRect: RECT
	LOCAL hfont: HFONT   

    INVOKE CreateCompatibleDC,hDC

    mov memDC, eax
    
    INVOKE SelectObject,memDC,BmpBackground
    mov hOld, eax

	;画背景
	INVOKE StretchBlt, hDC, ClientOffX, ClientOffY, ClientWidth, ClientHeight, memDC,0, 0, BgBmpWidth, BgBmpHeight, SRCCOPY

	;画文字
	INVOKE CreateFont, 80,
                       0,
                       0,
                       0,
                       FW_EXTRABOLD,
                       FALSE,
                       FALSE,
                       FALSE,
                       DEFAULT_CHARSET,
                       OUT_TT_PRECIS,
                       CLIP_DEFAULT_PRECIS,
                       CLEARTYPE_QUALITY,
                       DEFAULT_PITCH or FF_DONTCARE,
                       OFFSET FontName
    mov hfont, eax
	INVOKE SetBkMode, hDC, TRANSPARENT
	INVOKE SetTextColor, hDC, 00656E77h
	;INVOKE CreateSolidBrush, 008888FFh
	;INVOKE FillRect,hDC,ADDR textRect,eax
	INVOKE SelectObject, hDC, hfont
	mov textRect.top, 20
	mov textRect.left, 30
	mov textRect.right, 300
	mov textRect.bottom, 200
	INVOKE DrawText, hDC, ADDR GameTitle, -1, ADDR textRect, DT_VCENTER 
	;INVOKE BitBlt, hDC, 0, 0, textRect.right, textRect.bottom, memDC, 0, 0, SRCCOPY

	;画方块
	mov xIndex, 0
	mov yIndex, 0
	.WHILE xIndex < 4
		.WHILE yIndex < 4
			mov ecx, xIndex
			mov edx, yIndex
			MapAt edx, ecx
			mov ecx, eax
			SetCurrentBmp ecx
			mov CurrentBmp, eax
			INVOKE DrawSquare, xIndex, yIndex, CurrentBmp
			inc yIndex	
		.ENDW
		inc xIndex
		mov yIndex, 0
	.ENDW

	INVOKE DrawNextNumberText
    INVOKE SelectObject,hDC,hOld
    INVOKE DeleteDC,memDC
    ret
PaintProc ENDP

;画方块
DrawSquare PROC xIndex:DWORD, yIndex:DWORD, bmpObj:DWORD
	LOCAL xPos: DWORD
	LOCAL yPos: DWORD

	mov eax, xIndex
	inc eax
	mul Padding
	mov xPos, eax
	mov eax, xIndex
	mul SquareWidth
	add xPos, eax
	mov eax, ClientOffX
	add xPos, eax

	mov eax, yIndex
	inc eax
	mul Padding
	mov yPos, eax
	mov eax, yIndex
	mul SquareHeight
	add yPos, eax
	mov eax, ClientOffY
	add yPos, eax

	INVOKE SelectObject,memDC,bmpObj
	INVOKE StretchBlt, hDC, xPos, yPos, SquareWidth, SquareHeight, memDC, 0, 0, SquareBmpWidth, SquareBmpHeight, SRCCOPY
	ret
DrawSquare ENDP

DrawNextNumberText PROC
	LOCAL textRect: RECT
	LOCAL hfont: HFONT
	
	mov textRect.top, 30
	mov textRect.left, 330
	mov textRect.right, 530
	mov textRect.bottom, 110
	INVOKE CreateSolidBrush, 00A0ADBBh
	INVOKE FillRect,hDC,ADDR textRect,eax
	INVOKE CreateFont, 22,
                       0,
                       0,
                       0,
                       FW_EXTRABOLD,
                       FALSE,
                       FALSE,
                       FALSE,
                       DEFAULT_CHARSET,
                       OUT_TT_PRECIS,
                       CLIP_DEFAULT_PRECIS,
                       CLEARTYPE_QUALITY,
                       DEFAULT_PITCH or FF_DONTCARE,
                       OFFSET FontName
    mov hfont, eax
	INVOKE SetBkMode, hDC, TRANSPARENT
	INVOKE SetTextColor, hDC, 00EFF8FAh
	INVOKE SelectObject, hDC, hfont
	INVOKE DrawText, hDC, ADDR NextNumberText, -1, ADDR textRect, DT_VCENTER 
	SetCurrentBmp bombTarget
	mov CurrentBmp, eax
	INVOKE SelectObject,memDC, CurrentBmp
	INVOKE StretchBlt, hDC, 410, 60, 40, 40, memDC, 0, 0, SquareBmpWidth, SquareBmpHeight, SRCCOPY
	ret
DrawNextNumberText ENDP

MoveAnimateProc PROC qlen:DWORD, movedir:DWORD
	
	ret
MoveAnimateProc ENDP

end start 