TITLE Demo.asm      
; ===============================================      
;       Author: 狼の禅      
;       Date:   20/07/2009      
; ===============================================      
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
; -----------------------------------------------      
        MENU_ABOUTAUTHOR    equ    1000   
; -----------------------------------------------      
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD      
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD      
; ===============================================      
.data      
        hInstance       dd 0    ;应用程序句柄   
        hWnd            dd 0    ;窗口句柄   
        hMenu           dd 0    ;菜单句柄   
     
        ClassName       db "Demo",0      
        WindowName      db "Demo(狼の禅)",0      
        MenuAbout       db "帮助(&H)", 0   
        MenuAboutAuthor db "关于作者(&A)", 0   
        Author          db "Author:狼の禅",0dh,"Date:   23/07/2009",0   
; ===============================================      
.code      
start:      
        invoke GetModuleHandle,0    ;获取应用程序模块句柄   
        mov hInstance,eax           ;保存应用程序句柄   
        invoke WinMain,hInstance,0,0,SW_SHOWDEFAULT      
        invoke ExitProcess,eax      ;退出程序,并返回eax的值   
; ===============================================      
WinMain proc hInst:DWORD, hPrevInst:DWORD,CmdLine:DWORD, CmdShow:DWORD      
        LOCAL wndclass:WNDCLASSEX      
        LOCAL Msg:MSG      
     
        mov wndclass.cbSize,sizeof WNDCLASSEX      
        mov wndclass.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW      
        mov wndclass.lpfnWndProc,OFFSET WndProc      
        mov wndclass.cbClsExtra,0      
        mov wndclass.cbWndExtra,0      
        mov eax,hInst      
        mov wndclass.hInstance,eax      
        mov wndclass.hbrBackground,COLOR_WINDOW+1      
        mov wndclass.lpszMenuName,0      
        mov wndclass.lpszClassName,OFFSET ClassName      
        invoke LoadIcon,hInst,NULL      
        mov wndclass.hIcon,eax      
        invoke LoadCursor,0,IDC_ARROW      
        mov wndclass.hCursor,eax      
        mov wndclass.hIconSm,0      
     
        invoke RegisterClassEx,ADDR wndclass    ;注册用户定义的窗口类    
        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW, ADDR ClassName,      
                              ADDR WindowName,      
                              WS_OVERLAPPEDWINDOW,      
                              200,50,500,300,      
                              0,0,      
                              hInst,0           ;创建窗口   
        mov   hWnd,eax                          ;保存窗口句柄   
        invoke ShowWindow,hWnd,SW_SHOWNORMAL    ;     
        invoke UpdateWindow,hWnd      
MessageLoop:      
        invoke GetMessage,ADDR Msg,0,0,0        ;获取消息      
        cmp eax,0      
        je ExitProgram      
        invoke TranslateMessage,ADDR Msg        ;转换键盘消息   
        invoke DispatchMessage,ADDR Msg         ;分发消息   
        jmp MessageLoop      
ExitProgram:      
        mov eax,Msg.wParam       
        ret      
WinMain endp      
; ===============================================      
WndProc proc hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD      
        local hPopMenu      ;一级菜单句柄   
        .if uMsg == WM_CREATE      
            invoke CreateMenu   
            mov hMenu, eax   
            .if eax   
                invoke CreatePopupMenu      ;创建一级菜单   
                mov hPopMenu, eax           ;保存一级菜单句柄   
                invoke AppendMenu, hPopMenu, NULL, MENU_ABOUTAUTHOR, addr MenuAboutAuthor   ;添加二级菜单   
                invoke AppendMenu, hMenu, MF_POPUP, hPopMenu, addr MenuAbout                ;添加一级菜单   
            .endif   
            invoke SetMenu, hWin, hMenu     ;设置菜单   
        .elseif uMsg == WM_DESTROY   
            invoke PostQuitMessage,0        ;退出消息循环     
        .elseif uMsg == WM_COMMAND   
            .if wParam == MENU_ABOUTAUTHOR   
                invoke MessageBoxA,hWin,ADDR Author,ADDR ClassName,MB_OK   
            .endif   
        .else     
            invoke DefWindowProc,hWin,uMsg,wParam,lParam    ;调用默认消息处理函数   
            ret      
        .endif      
        xor eax,eax      
        ret      
WndProc endp      
; ===============================================      
end start    
TITLE Demo.asm   
; ===============================================   
;       Author: 狼の禅   
;       Date:   20/07/2009   
; ===============================================   
   .386   
        .model flat,stdcall   
        option casemap:none 
             
        include windows.inc   
        include user32.inc   
        include kernel32.inc   
        includelib user32.lib   
; -----------------------------------------------   
        MENU_ABOUTAUTHOR    equ    1000
; -----------------------------------------------   
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD   
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD   
; ===============================================   
.data   
        hInstance   dd 0 ;应用程序句柄
        hWnd    dd 0 ;窗口句柄
        hMenu    dd 0 ;菜单句柄

        ClassName   db "Demo",0   
        WindowName   db "Demo(狼の禅)",0   
   MenuAbout   db "帮助(&H)", 0
     MenuAboutAuthor db "关于作者(&A)", 0
     Author    db "Author:狼の禅",0dh,"Date:   23/07/2009",0
; ===============================================   
.code   
start:   
        invoke GetModuleHandle,0 ;获取应用程序模块句柄
        mov hInstance,eax    ;保存应用程序句柄
        invoke WinMain,hInstance,0,0,SW_SHOWDEFAULT   
        invoke ExitProcess,eax   ;退出程序,并返回eax的值
; ===============================================   
WinMain proc hInst:DWORD, hPrevInst:DWORD,CmdLine:DWORD, CmdShow:DWORD   
        LOCAL wndclass:WNDCLASSEX   
        LOCAL Msg:MSG   

        mov wndclass.cbSize,sizeof WNDCLASSEX   
        mov wndclass.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW   
        mov wndclass.lpfnWndProc,OFFSET WndProc   
        mov wndclass.cbClsExtra,0   
        mov wndclass.cbWndExtra,0   
        mov eax,hInst   
        mov wndclass.hInstance,eax   
        mov wndclass.hbrBackground,COLOR_WINDOW+1   
        mov wndclass.lpszMenuName,0   
        mov wndclass.lpszClassName,OFFSET ClassName   
        invoke LoadIcon,hInst,NULL   
        mov wndclass.hIcon,eax   
        invoke LoadCursor,0,IDC_ARROW   
        mov wndclass.hCursor,eax   
        mov wndclass.hIconSm,0   

        invoke RegisterClassEx,ADDR wndclass ;注册用户定义的窗口类 
        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW, ADDR ClassName,   
                              ADDR WindowName,   
                              WS_OVERLAPPEDWINDOW,   
                              200,50,500,300,   
                              0,0,   
                              hInst,0    ;创建窗口
        mov   hWnd,eax        ;保存窗口句柄
        invoke ShowWindow,hWnd,SW_SHOWNORMAL ; 
        invoke UpdateWindow,hWnd   
MessageLoop:   
        invoke GetMessage,ADDR Msg,0,0,0   ;获取消息   
        cmp eax,0   
        je ExitProgram   
        invoke TranslateMessage,ADDR Msg   ;转换键盘消息
        invoke DispatchMessage,ADDR Msg    ;分发消息
        jmp MessageLoop   
ExitProgram:   
        mov eax,Msg.wParam    
        ret   
WinMain endp   
; ===============================================   
WndProc proc hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD   
   local hPopMenu   ;一级菜单句柄
        .if uMsg == WM_CREATE   
    invoke CreateMenu
            mov hMenu, eax
            .if eax
                invoke CreatePopupMenu   ;创建一级菜单
                mov hPopMenu, eax    ;保存一级菜单句柄
                invoke AppendMenu, hPopMenu, NULL, MENU_ABOUTAUTHOR, addr MenuAboutAuthor ;添加二级菜单
                invoke AppendMenu, hMenu, MF_POPUP, hPopMenu, addr MenuAbout     ;添加一级菜单
            .endif
            invoke SetMenu, hWin, hMenu   ;设置菜单
        .elseif uMsg == WM_DESTROY
            invoke PostQuitMessage,0   ;退出消息循环 
        .elseif uMsg == WM_COMMAND
    .if wParam == MENU_ABOUTAUTHOR
     invoke MessageBoxA,hWin,ADDR Author,ADDR ClassName,MB_OK
    .endif
        .else 
            invoke DefWindowProc,hWin,uMsg,wParam,lParam ;调用默认消息处理函数
            ret   
        .endif   
        xor eax,eax   
        ret   
WndProc endp   
; ===============================================   
end start  