
IFNDEF SERIZATION_INC
SERIZATION_INC equ <1>

INCLUDE kernel32.inc
INCLUDE windows.inc
INCLUDE bomb_core.inc

.data

DO_NOT_SHARE EQU 0
NULL EQU 0

EXTERNDEF hFile:HANDLE,
	fileName:BYTE

OpenSfile MACRO
	.IF hFile != INVALID_HANDLE_VALUE
		CloseSfile
	.ENDIF
	INVOKE CreateFile,
		ADDR fileName,
		GENERIC_READ,
		DO_NOT_SHARE,
		NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		0
	.IF eax != INVALID_HANDLE_VALUE
		mov hFile, eax
	.ENDIF
ENDM

ReadSfile MACRO buf:REQ, sz:REQ, reallen:REQ
	.IF hFile != INVALID_HANDLE_VALUE
		INVOKE ReadFile,
			hFile,
			ADDR buf,
			sz,
			ADDR reallen,
			0
	.ELSE
		mov reallen, 0
	.ENDIF
ENDM

CloseSfile MACRO
	.IF hFile != INVALID_HANDLE_VALUE
		INVOKE CloseHandle, hFile
		mov hFile, INVALID_HANDLE_VALUE
	.ENDIF
ENDM

SaveSfile MACRO
	.IF hFile != INVALID_HANDLE_VALUE
		CloseSfile
	.ENDIF
	INVOKE CreateFile,
		ADDR fileName,
		GENERIC_WRITE,
		DO_NOT_SHARE,
		NULL,
		CREATE_ALWAYS,
		FILE_ATTRIBUTE_NORMAL,
		0
	.IF eax != INVALID_HANDLE_VALUE
		mov hFile, eax
	.ENDIF
ENDM

WriteSfile MACRO buf:REQ, sz:REQ, reallen:REQ
	.IF hFile != INVALID_HANDLE_VALUE
		INVOKE WriteFile,
			hFile,
			ADDR buf,
			sz,
			ADDR reallen,
			0
	.ELSE
		mov reallen, 0
	.ENDIF
ENDM



.code
LoadSerialization PROTO
SaveSerialization PROTO

ENDIF