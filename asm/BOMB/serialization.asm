.386      
    .model flat,stdcall      
    option casemap:none 

INCLUDE serialization.inc

.data
hFile HANDLE INVALID_HANDLE_VALUE
fileName BYTE "bomb.wcc", 0
sBuffer BYTE 128 DUP(0)

; Serialization File Format:
; mapSize, map(all), bombTarget


.code
LoadSerialization PROC USES ebx ecx edx esi edi
	LOCAL reallen:DWORD
	
	mov reallen, 0
	OpenSfile
	.IF hFile == INVALID_HANDLE_VALUE
		mov eax, 0
		ret
	.ENDIF
	ReadSfile mapSize, TYPE mapSize, reallen
	ReadSfile map, MAP_SIZE * MAP_SIZE * TYPE map, reallen
	ReadSfile bombTarget, TYPE bombTarget, reallen
	INVOKE ResetStat
	ret
LoadSerialization ENDP


SaveSerialization PROC USES ebx ecx edx esi edi
	LOCAL reallen:DWORD
	
	mov reallen, 0
	SaveSfile
	.IF hFile == INVALID_HANDLE_VALUE
		mov eax, 0
		ret
	.ENDIF
	WriteSfile mapSize, TYPE mapSize, reallen
	WriteSfile map, MAP_SIZE * MAP_SIZE * TYPE map, reallen
	WriteSfile bombTarget, TYPE bombTarget, reallen
	CloseSfile
	mov eax, 1
	ret
SaveSerialization ENDP

END