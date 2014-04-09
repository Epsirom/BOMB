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
	LOCAL dwStyle:DWORD
	LOCAL scrWidth:DWORD
	LOCAL scrHeight:DWORD

	;初始化窗口
    mov wndclass.cbSize,sizeof WNDCLASSEX      
    mov wndclass.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW      
    mov wndclass.lpfnWndProc,OFFSET WndProc      
    mov wndclass.cbClsExtra,0      
    mov wndclass.cbWndExtra,0      
    mov eax,hInst      
    mov wndclass.hInstance,eax      
	INVOKE CreateSolidBrush,BgColor
	mov bgBrush, eax
    mov wndclass.hbrBackground, eax      
    mov wndclass.lpszMenuName,0      
    mov wndclass.lpszClassName,OFFSET ClassName      
    INVOKE LoadIcon, hInstance, 130
    mov wndclass.hIcon,eax      
    INVOKE LoadCursor,0,IDC_ARROW      
    mov wndclass.hCursor,eax      
    mov wndclass.hIconSm,0      
	;创建画刷、字体
	INVOKE CreateSolidBrush,TextBgColor
	mov textBgBrush, eax
	
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
    mov titleFont, eax
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
    mov textFont, eax

	mov dwStyle, WS_OVERLAPPEDWINDOW
	mov eax, WS_SIZEBOX
	not eax
	and dwStyle, eax
	INVOKE GetSystemMetrics,SM_CXSCREEN
	mov scrWidth, eax
	INVOKE GetSystemMetrics,SM_CYSCREEN
	mov scrHeight, eax
	mov edx, 0
	mov ebx, 2
	mov eax, scrWidth
	sub eax, WndWidth
	div ebx
	mov WndOffX, eax
	mov eax, scrHeight
	sub eax, WndHeight
	div ebx
	mov WndOffY, eax
    INVOKE RegisterClassEx,ADDR wndclass    ;注册用户定义的窗口类    
	INVOKE CreateWindowEx,WS_EX_OVERLAPPEDWINDOW, ADDR ClassName,      
                            ADDR WindowName,      
                            dwStyle,      
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
	INVOKE LoadBitmap, hInstance, 128
	mov BmpNumber2048, eax
	INVOKE LoadBitmap, hInstance, 133
	mov BmpBomb, eax
	INVOKE LoadBitmap, hInstance, 134
	mov BmpNumber4096, eax
	INVOKE LoadBitmap, hInstance, 135
	mov BmpNumber8192, eax
	INVOKE LoadBitmap, hInstance, 136
	mov BmpNumber16384, eax
	INVOKE LoadBitmap, hInstance, 137
	mov BmpNumber32768, eax
	INVOKE LoadBitmap, hInstance, 138
	mov BmpNumber65536, eax

	;初始化rect
	INVOKE InitRect

	;初始化动画时间
	SetOriginTimeLim

	;载入游戏进度
	INVOKE LoadSerialization
	;初始化地图
	.IF eax == 0
		mov eax, 5
		INVOKE InitMap
		;根据size设置方块大小
		ResetParameter
	.ELSE
		;载入游戏进度对话框
		INVOKE MessageBox, 0, ADDR LoadMsg, ADDR MsgTitle, MB_YESNO
		.IF eax == 7  ; "No"
			mov eax, 5
			INVOKE InitMap
			ResetParameter
		.ENDIF
	.ENDIF
	INVOKE CopyMap

    INVOKE ShowWindow,hWnd,SW_SHOWNORMAL    ;     
    INVOKE UpdateWindow,hWnd 
    ;设置时钟
    INVOKE SetTimer, hWnd, 1, Interval, NULL

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

;初始化rect
InitRect PROC USES ebx
	;INVOKE GetWindowRect, hWnd, ADDR rect
	;GameRect
	mov ebx, ClientOffY
	mov GameRect.top, ebx
	add ebx, ClientHeight
	mov GameRect.bottom, ebx
	mov ebx, ClientOffX
	mov GameRect.left, ebx
	add ebx, ClientWidth
	mov GameRect.right, 530
	;BombNumRect
	mov BombNumRect.top, 30
	mov BombNumRect.left, 330
	mov BombNumRect.right, 530
	mov BombNumRect.bottom, 110
	;rect
	mov rect.top, 0
	mov rect.left, 0
	mov ebx, WndWidth
	mov rect.right, ebx
	mov ebx, WndHeight
	mov rect.bottom, ebx
	ret
InitRect ENDP

;复制map到oldMap
CopyMap PROC USES eax ebx ecx edx
	mov ecx, 0
	mov edx, 0
	.WHILE ecx < mapSize
		.WHILE edx < mapSize
			MapAt ecx, edx
			SetOldMapAt ecx, edx, eax
			inc edx
		.ENDW
		mov edx, 0
		inc ecx
	.ENDW
	ret
CopyMap ENDP

;复制map不包括爆炸部分
CopyMapWithoutBomb PROC USES eax ebx ecx edx
	mov ecx, 0
	mov edx, 0
	.WHILE ecx < mapSize
		.WHILE edx < mapSize
			MapAt ecx, edx
			mov ebx, eax
			.IF eax == 0
				OldMapAt ecx, edx
				.IF eax < POSITIVE_MAX
					INVOKE CheckExplode, ecx, edx
					.IF eax == 0
						mov eax, ebx
						SetOldMapAt ecx, edx, eax
					.ELSE
						mov eax, bombTarget
						push edx
						mov edx, 0
						mov ebx, 2
						div ebx
						pop edx
						SetOldMapAt ecx, edx, eax
					.ENDIF	
				.ENDIF
			.ELSE
				mov eax, ebx
				SetOldMapAt ecx, edx, eax
			.ENDIF
			inc edx
		.ENDW
		mov edx, 0
		inc ecx
	.ENDW
	ret
CopyMapWithoutBomb ENDP

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

;播放爆炸声函数
PlayMp3BombFile PROC hWin:DWORD,NameOfFile:DWORD
	LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS
	mov eax,hWin        
	mov mciPlayParms.dwCallback,eax
	mov eax,OFFSET Mp3BombDevice
	mov mciOpenParms.lpstrDeviceType,eax
	mov eax,NameOfFile
	mov mciOpenParms.lpstrElementName,eax
	INVOKE mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
	mov eax,mciOpenParms.wDeviceID
	mov Mp3BombDeviceID,eax
	invoke mciSendCommand,Mp3BombDeviceID,MCI_PLAY,MCI_NOTIFY,ADDR mciPlayParms
	ret  
PlayMp3BombFile ENDP

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
        INVOKE TimerProc, hWin, uMsg, wParam, lParam
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
	.ELSEIF uMsg == WM_CLOSE
		;保存游戏进度对话框
		INVOKE MessageBox, 0, ADDR QuitMsg, ADDR MsgTitle, MB_YESNO
		.IF eax == 6
			INVOKE SaveSerialization
		.ENDIF
		INVOKE PostQuitMessage,0
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
	.IF keyLock == KEYLOCKED
		ret
	.ENDIF
	.IF wParam == VK_UP
		mov eax, DIR_UP
		AppendAQueue eax
	.ELSEIF wParam == VK_DOWN
		mov eax, DIR_DOWN
		AppendAQueue eax
	.ELSEIF wParam == VK_LEFT
		mov eax, DIR_LEFT
		AppendAQueue eax
	.ELSEIF wParam == VK_RIGHT
		mov eax, DIR_RIGHT
		AppendAQueue eax
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
	.IF aniLock == ANIUNLOCKED
		INVOKE TryExtractAction, hWin
	.ENDIF
	ret
KeyDownProc ENDP

KeyUpProc PROC uMsg:DWORD, wParam:DWORD, lParam:DWORD
	;INVOKE MessageBox, NULL, pErrorMsg, ADDR ErrorTitle, MB_OK
	ret
KeyUpProc ENDP

;时钟事件
TimerProc PROC USES ebx edx hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	.IF BombSoundTime > 0
		dec BombSoundTime
		.IF BombSoundTime == 0
			invoke mciSendCommand,Mp3BombDeviceID,MCI_CLOSE,0,0
		.ENDIF
	.ENDIF
	.IF aniFlag == 1
		;移动
		inc moveticks
		AdjustAniTimeLim
		INVOKE InvalidateRect, hWin, ADDR GameRect, FALSE
		mov eax, MoveTime
		.IF moveticks > eax
			mov moveticks, 0
			mov bl, 2
			mov aniFlag, bl
			INVOKE CopyMapWithoutBomb
			INVOKE InvalidateRect, hWin, ADDR BombNumRect, FALSE
		.ENDIF
	.ELSEIF aniFlag == 2
		;结合
		.IF (combineticks == 0) && (hasCombBomb == 0)
			mov ebx, CombineTime
			mov combineticks, ebx
		.ENDIF 
		inc combineticks
		AdjustAniTimeLim
		mov eax, CombineTime
		.IF combineticks > eax
			mov combineticks, 0
			mov bl, 3
			mov aniFlag, bl
		.ENDIF
		INVOKE InvalidateRect, hWin, ADDR GameRect, FALSE
	.ELSEIF aniFlag == 3
		;爆炸
		.IF (explodeticks == 0) && (hasCombBomb < 2)
			mov ebx, ExplodeTime
			mov explodeticks, ebx
		.ENDIF
		inc explodeticks
		AdjustAniTimeLim
		mov eax, ExplodeTime
		.IF explodeticks > eax
			INVOKE CopyMap
			mov explodeticks, 0
			mov bl, 4
			mov aniFlag, bl
		.ENDIF
		INVOKE InvalidateRect, hWin, ADDR GameRect, FALSE
	.ELSEIF aniFlag == 4
		;出现新方块
		.IF showticks == 0
			INVOKE AddNum
			mov edx, eax
			and eax, 01h
			.IF eax == 0
				mov eax, 2
			.ELSE
				mov eax, 4
			.ENDIF
			mov newNum, eax
			mov eax, edx
			shr eax, 1
			and eax, 001Fh
			mov newNumPosX, eax
			mov eax, edx
			shr eax, 6
			and eax, 001Fh
			mov newNumPosY, eax
		.ENDIF
		inc showticks
		AdjustAniTimeLim
		INVOKE InvalidateRect, hWin, ADDR GameRect, FALSE
		mov eax, ShowNewTime
		.IF showticks > eax
			mov showticks, 0
			mov aniFlag, 0		
			INVOKE CopyMap
			INVOKE CheckMap
			.IF eax == MAP_FAIL
				mov keyLock, KEYLOCKED
				INVOKE MessageBox, 0, ADDR FailMsg, ADDR MsgTitle, MB_OK
				ResetGame
				INVOKE InvalidateRect, hWin, NULL, FALSE
			.ELSEIF eax == MAP_WIN
				mov keyLock, KEYLOCKED
				INVOKE MessageBox, 0, ADDR WinMsg, ADDR MsgTitle, MB_OK
				ResetGame
				INVOKE InvalidateRect, hWin, NULL, FALSE
			.ENDIF
			INVOKE TryExtractAction, hWin
		.ENDIF
	.ENDIF
	ret
TimerProc ENDP

TryExtractAction PROC hWin:DWORD
	mov aniLock, ANILOCKED
	ExtractAQueue
	.IF eax == -1
		mov aniLock, ANIUNLOCKED
		ret
	.ENDIF
	mov MoveDir, eax
	INVOKE DoMove
	mov qlen, eax
	.IF qlen == 0
		INVOKE TryExtractAction, hWin
		ret
	.ENDIF
	INVOKE CheckHasCombBomb
	mov aniFlag, 1 ;开始动画
	.IF hasCombBomb == 2  
        invoke PlayMp3BombFile,hWin,ADDR BombFileName
		mov BombSoundTime, 200
    .ENDIF
	ret
TryExtractAction ENDP

;绘图函数
PaintProc PROC hWin:DWORD
	LOCAL hOld: DWORD
	LOCAL xIndex: DWORD
	LOCAL yIndex: DWORD
	LOCAL textRect: RECT
	LOCAL movedis: DWORD
	LOCAL scale: DWORD  ;1~100

	mov movedis, 0

    INVOKE CreateCompatibleDC, hDC
    mov memDC, eax

	INVOKE CreateCompatibleDC, hDC
    mov imgDC, eax
	INVOKE CreateCompatibleBitmap, hDC, WndWidth, WndHeight
	mov hBitmap, eax
    INVOKE SelectObject, memDC, hBitmap
    mov hOld, eax
	;INVOKE CreateSolidBrush, BgColor
	INVOKE FillRect, memDC, ADDR rect, bgBrush
	
	;画背景
	INVOKE SelectObject, imgDC, BmpBackground
	INVOKE StretchBlt, memDC, ClientOffX, ClientOffY, ClientWidth, ClientHeight, imgDC,0, 0, BgBmpWidth, BgBmpHeight, SRCCOPY

	;画文字
	INVOKE SetBkMode, memDC, TRANSPARENT
	INVOKE SetTextColor, memDC, 00656E77h
	INVOKE SelectObject, memDC, titleFont
	mov textRect.top, 20
	mov textRect.left, 30
	mov textRect.right, 300
	mov textRect.bottom, 200
	INVOKE DrawText, memDC, ADDR GameTitle, -1, ADDR textRect, DT_VCENTER 
	;INVOKE BitBlt, memDC, 0, 0, textRect.right, textRect.bottom, imgDC, 0, 0, SRCCOPY

	;先画砖块、空格等背景
	mov xIndex, 0
	mov yIndex, 0
	mov ecx, xIndex
	mov edx, yIndex
	.WHILE ecx < mapSize
		.WHILE edx < mapSize
			OldMapAt edx, ecx
			mov ecx, eax
			.IF (ecx >= POSITIVE_MAX) || (ecx == 0)
				SetCurrentBmp ecx
				mov CurrentBmp, eax
				INVOKE DrawSquare, xIndex, yIndex, CurrentBmp, 0, 100
			.ELSE
				mov eax, 0
				SetCurrentBmp eax
				mov CurrentBmp, eax
				INVOKE DrawSquare, xIndex, yIndex, CurrentBmp, 0, 100
			.ENDIF
			inc yIndex
			mov ecx, xIndex
			mov edx, yIndex
		.ENDW
		inc xIndex
		mov yIndex, 0
		mov ecx, xIndex
		mov edx, yIndex
	.ENDW
	;再画数字
	mov xIndex, 0
	mov yIndex, 0
	mov ecx, xIndex
	mov edx, yIndex
	.WHILE ecx < mapSize
		.WHILE edx < mapSize
			mov ecx, xIndex
			mov edx, yIndex
			OldMapAt edx, ecx
			mov ecx, eax
			.IF (ecx < POSITIVE_MAX) && (ecx > 0)
				mov scale, 100
				;移动
				.IF moveticks > 0
					INVOKE GetMoveDis, yIndex, xIndex
					mul moveticks
					mov ebx, SquareWidth
					add ebx, Padding
					mul ebx
					mov edx, 0
					mov ebx, MoveTime
					div ebx
					mov movedis, eax
				;合成
				.ELSEIF combineticks > 0
					INVOKE CheckCombine, yIndex, xIndex
					push ecx
					.IF eax == 1
						mov edx, 0
						mov eax, CombineTime
						mov ecx, 2
						div ecx
						mov ebx, eax  ;store half of CombineTime in ebx
						.IF combineticks < ebx
							mov edx, 0
							mov eax, 60
							mul combineticks
							div ebx
							mov edx, 110
							sub edx, eax
							mov scale, edx
						.ELSE
							mov eax, combineticks
							sub eax, ebx
							mov ecx, 50
							mul ecx
							mov edx, 0
							div ebx
							add eax, 50
							mov scale, eax
						.ENDIF
					.ENDIF
					pop ecx
				;爆炸
				.ELSEIF explodeticks > 0
					INVOKE CheckExplode, yIndex, xIndex
					.IF eax == 1
						mov eax, 50
						mul explodeticks
						mov edx, 0
						mov ebx, ExplodeTime
						div ebx
						add eax, 50
						mov scale, eax
						mov ecx, 1
						SetCurrentBmp ecx
						mov CurrentBmp, eax
						INVOKE DrawSquare, xIndex, yIndex, CurrentBmp, movedis, scale
					.ENDIF
				.ENDIF
				SetCurrentBmp ecx
				mov CurrentBmp, eax
				INVOKE DrawSquare, xIndex, yIndex, CurrentBmp, movedis, scale
				mov movedis, 0
			.ENDIF
			inc yIndex
			mov ecx, xIndex
			mov edx, yIndex
		.ENDW
		inc xIndex
		mov yIndex, 0
		mov ecx, xIndex
		mov edx, yIndex
	.ENDW
	
	;画新添加的方块
	.IF showticks > 0
		mov eax, 50
		mul showticks
		mov edx, 0
		mov ebx, ShowNewTime
		div ebx
		add eax, 50
		mov scale, eax
		mov ecx, newNum
		SetCurrentBmp ecx
		mov CurrentBmp, eax
		INVOKE DrawSquare, newNumPosY, newNumPosX, CurrentBmp, movedis, scale
	.ENDIF
		
	INVOKE DrawNextNumberText

	INVOKE BitBlt, hDC, 0, 0, WndWidth, WndHeight, memDC, 0, 0, SRCCOPY 
    INVOKE SelectObject,hDC,hOld
    INVOKE DeleteDC,memDC
	INVOKE DeleteDC,imgDC
	INVOKE DeleteObject, hBitmap
    ret
PaintProc ENDP

;获取移动距离
GetMoveDis PROC USES edi ebx edx xIndex:DWORD, yIndex:DWORD
	mov ebx, 0
	mov edi, OFFSET resultQueue
	.WHILE ebx < qlen
		mov eax, [edi]
		mov edx, eax
		shr eax, 2
		and eax, 001Fh
		.IF eax == xIndex
			mov eax, edx
			shr eax, 7
			and eax, 001Fh
			.IF eax == yIndex
				mov eax, edx
				and eax, 0003h
				.IF eax == 0
					mov eax, edx
					shr eax, 12
					and eax, 001Fh
					ret
				.ENDIF
			.ENDIF
		.ENDIF 
		add edi, TYPE resultQueue
		inc ebx
	.ENDW
	mov eax, 0
	ret
GetMoveDis ENDP

;检查是否有合成和爆炸动画
CheckHasCombBomb PROC USES edi ebx eax
	mov hasCombBomb, 0
	mov ebx, 0
	mov edi, OFFSET resultQueue
	.WHILE ebx < qlen
		mov eax, [edi]
		mov edx, eax
		and eax, 0002h
		.IF eax == 2
			mov hasCombBomb, eax
			ret
		.ENDIF
		mov eax, edx
		and eax, 0001h
        .IF eax == 1
			.IF hasCombBomb == 0
				mov hasCombBomb, eax
			.ENDIF
		.ENDIF
		add edi, TYPE resultQueue
		inc ebx
	.ENDW
	ret
CheckHasCombBomb ENDP

;检查是否是合成方块
CheckCombine PROC USES edi ebx edx xIndex:DWORD, yIndex:DWORD
	mov ebx, 0
	mov edi, OFFSET resultQueue
	.WHILE ebx < qlen
		mov eax, [edi]
		mov edx, eax
		shr eax, 2
		and eax, 001Fh
		.IF eax == xIndex
			mov eax, edx
			shr eax, 7
			and eax, 001Fh
			.IF eax == yIndex
				mov eax, edx
				and eax, 0003h
				.IF eax == 01h
					ret
				.ENDIF
			.ENDIF
		.ENDIF 
		add edi, TYPE resultQueue
		inc ebx
	.ENDW
	mov eax, 0
	ret
CheckCombine ENDP

;检查是否是爆炸
CheckExplode PROC USES edi ebx edx xIndex:DWORD, yIndex:DWORD
	mov ebx, 0
	mov edi, OFFSET resultQueue
	.WHILE ebx < qlen
		mov eax, [edi]
		mov edx, eax
		shr eax, 2
		and eax, 001Fh
		.IF eax == xIndex
			mov eax, edx
			shr eax, 7
			and eax, 001Fh
			.IF eax == yIndex
				mov eax, edx
				and eax, 0003h
				.IF eax == 02h
					mov eax, 1
					ret
				.ENDIF
			.ENDIF
		.ENDIF 
		add edi, TYPE resultQueue
		inc ebx
	.ENDW
	mov eax, 0
	ret
CheckExplode ENDP

;画方块
DrawSquare PROC USES eax ebx ecx edx xIndex:DWORD, yIndex:DWORD, bmpObj:DWORD, movedis:DWORD, scale:DWORD
	;scale: 1~100->1%~100%
	LOCAL xPos: DWORD
	LOCAL yPos: DWORD
	LOCAL finalWidth: DWORD
	LOCAL finalHeight: DWORD

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

	;缩放
	mov eax, SquareWidth
	mul scale
	mov ebx, 100
	mov edx, 0
	div ebx
	mov finalWidth, eax
	mov finalHeight, eax
	mov ecx, SquareWidth
	sub ecx, eax
	mov eax, ecx
	mov ebx, 2
	mov edx, 0
	div ebx
	mov ecx, eax
	add eax, xPos
	mov xPos, eax
	mov eax, ecx
	add eax, yPos
	mov yPos, eax

	;移动
	INVOKE SelectObject,imgDC,bmpObj
	mov eax, movedis
	.IF MoveDir == DIR_UP
		sub yPos, eax
	.ELSEIF MoveDir == DIR_DOWN
		add yPos, eax
	.ELSEIF MoveDir == DIR_LEFT
		sub xPos, eax
	.ELSEIF	MoveDir == DIR_RIGHT
		add xPos, eax
	.ENDIF



	INVOKE StretchBlt, memDC, xPos, yPos, finalWidth, finalHeight, imgDC, 0, 0, SquareBmpWidth, SquareBmpHeight, SRCCOPY
	ret
DrawSquare ENDP

;画下一个爆炸的数字提示
DrawNextNumberText PROC
	
	;INVOKE CreateSolidBrush, 00A0ADBBh
	INVOKE FillRect,memDC,ADDR BombNumRect,textBgBrush
	INVOKE SetBkMode, memDC, TRANSPARENT
	INVOKE SetTextColor, memDC, 00EFF8FAh
	INVOKE SelectObject, memDC, textFont
	INVOKE DrawText, memDC, ADDR NextNumberText, -1, ADDR BombNumRect, DT_VCENTER 
	SetCurrentBmp bombTarget
	mov CurrentBmp, eax
	INVOKE SelectObject,imgDC, CurrentBmp
	INVOKE StretchBlt, memDC, 410, 60, 40, 40, imgDC, 0, 0, SquareBmpWidth, SquareBmpHeight, SRCCOPY
	ret
DrawNextNumberText ENDP

end start 