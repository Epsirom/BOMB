TITLE main.asm      
    .386      
    .model flat,stdcall      
    option casemap:none    

INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
INCLUDELIB gdi32.lib

INCLUDE windows.inc
INCLUDE user32.inc
INCLUDE kernel32.inc
INCLUDE gdi32.inc 
               
INCLUDE bomb.inc

.data      
    hInstance       dd 0    ;应用程序句柄   
    hWnd            dd 0    ;窗口句柄   
    hMenu           dd 0    ;菜单句柄   
	CommandLine     dd 0

	ErrorTitle      db "Error",0
    ClassName       db "Demo",0      
    WindowName      db "BOMB",0      
    MenuAbout       db "Help", 0   
    MenuAboutAuthor db "About Author", 0   
    Author          db "Author:wcc",0dh,"Date:   19/03/2014",0   
; ===============================================      
.code      
start:      
    INVOKE GetModuleHandle,0    ;获取应用程序模块句柄   
    mov hInstance,eax           ;保存应用程序句柄 
	 
	INVOKE GetCommandLine
	mov CommandLine, eax
    
	INVOKE WinMain,hInstance,0,CommandLine,SW_SHOWDEFAULT      
    INVOKE ExitProcess,eax      ;退出程序,并返回eax的值   
; ===============================================      
WinMain proc hInst:DWORD, 
			 hPrevInst:DWORD,
			 CmdLine:DWORD,
			 CmdShow:DWORD      

    LOCAL wndclass:WNDCLASSEX      
    LOCAL msg:MSG      
     
	;==================================================
	; Fill WNDCLASSEX structure with required variables
	;==================================================

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
    INVOKE LoadImage, NULL, ADDR BmpIconFilePath, IMAGE_ICON, 0, 0, LR_LOADFROMFILE      
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
	INVOKE LoadImage, NULL, ADDR BmpBackgroundFilePath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov BmpBackground, eax
	INVOKE LoadImage, NULL, ADDR BmpNumber2FilePath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov BmpNumber2, eax
	   
    INVOKE ShowWindow,hWnd,SW_SHOWNORMAL    ;     
    INVOKE UpdateWindow,hWnd 

;开始程序的持续消息处理循环     
MessageLoop:      
    INVOKE GetMessage,ADDR msg,0,0,0        ;获取消息      
    cmp eax,0      
    je Exit_Program      
    INVOKE TranslateMessage,ADDR msg        ;转换键盘消息   
    INVOKE DispatchMessage,ADDR msg         ;分发消息   
    jmp MessageLoop  
    
Exit_Program:      
        INVOKE ExitProcess, 0      
WinMain endp      
; ===============================================   

;消息处理函数   
WndProc proc hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD      
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
	.ELSEIF uMsg == WM_PAINT
		INVOKE BeginPaint, hWin, ADDR ps
		mov hDC, eax
		INVOKE PaintProc, hWin
		INVOKE EndPaint, hWin, ADDR ps
		jmp WndProcExit
	.ELSEIF uMsg == WM_KEYDOWN
		INVOKE KeyDownProc,uMsg, wParam, lParam
		jmp WndProcExit
	.ELSEIF uMsg == WM_KEYUP
		INVOKE KeyUpProc,uMsg, wParam, lParam
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

;---------------------------------------------------
ErrorHandler PROC
; Display the appropriate system error message.
;---------------------------------------------------
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
 
;#################
;键盘事件
KeyDownProc PROC uMsg:DWORD, wParam:DWORD, lParam:DWORD
	.IF wParam == VK_UP
	.ELSEIF wParam == VK_DOWN
	.ELSEIF wParam == VK_LEFT
	.ELSEIF wParam == VK_RIGHT
	.ENDIF
	ret
KeyDownProc ENDP

KeyUpProc PROC uMsg:DWORD, wParam:DWORD, lParam:DWORD
	INVOKE MessageBox, NULL, pErrorMsg, ADDR ErrorTitle, MB_OK
	ret
KeyUpProc ENDP

;###################
;绘图函数
PaintProc PROC hWin:DWORD
	LOCAL hOld: DWORD
	LOCAL xIndex: DWORD
	LOCAL yIndex: DWORD

    INVOKE CreateCompatibleDC,hDC
    mov memDC, eax
    
    INVOKE SelectObject,memDC,BmpBackground
    mov hOld, eax

	;画背景
    ;INVOKE BitBlt,hDC,0,0,600,600,memDC,0,0,SRCCOPY
	INVOKE StretchBlt, hDC, 0, 0, ClientWidth, ClientHeight, memDC,0, 0, BgBmpWidth, BgBmpHeight, SRCCOPY

	;画方块
	mov xIndex, 0
	mov yIndex, 0
	.WHILE xIndex < 4
		.WHILE yIndex < 4
			INVOKE DrawSquare,xIndex,yIndex,BmpNumber2
			inc yIndex	
		.ENDW
		inc xIndex
		mov yIndex, 0
	.ENDW

    INVOKE SelectObject,hDC,hOld

    INVOKE DeleteDC,memDC
    ret
PaintProc ENDP

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

	mov eax, yIndex
	inc eax
	mul Padding
	mov yPos, eax
	mov eax, yIndex
	mul SquareHeight
	add yPos, eax

	INVOKE SelectObject,memDC,bmpObj
	INVOKE StretchBlt, hDC, xPos, yPos, SquareWidth, SquareHeight, memDC, 0, 0, SquareBmpWidth, SquareBmpHeight, SRCCOPY
	ret
DrawSquare ENDP

end start    