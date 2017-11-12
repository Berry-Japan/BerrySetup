unit Unlha32;

{/* Unlha32.pas D.Nogami        Apr. 9.1997  Ver.0.12.82
**  based on UNLHA32.H, Micco,  Mar.23,1997  Ver.0.82
**
** �@���̃��j�b�g��Micco����UNLHA32.H�����Ƃɂ��Ă��܂��B
** �@���̃��j�b�g���g�p����A�v���P�[�V�����̋N������UNLHA32.DLL���g�p�ł��邩�ǂ���
** �m�F���ALoadLibrary�Ń������Ƀ��[�h���܂��B�܂��A�I������FreeLibrary�Ń��������J��
** ���Ă��܂��B
** �@�ڂ�����Readme.txt�����Ă��������B
**
** LH 2.02a
** Copyright (c) 1988-90 by Haruyasu Yoshizaki  All rights reserved.
**
** Win/WinNT-SFX
** Copyright (c) 1995-96 by mH        All rights reserved.
**
** UNLHA32.DLL
** Copyright (c) 1995-97 by Micco     All rights reserved.
**
** Unlha32.pas
** Copyright (c) 1997    by D.Nogami  All rights reserved.
*/}

interface

uses
    Windows,SysUtils;

const
     UNLHA32_VERSION       =  82;
     FNAME_MAX32           = 512;
// function UnlhaCheckArchive�Ŏg�p����t���O
     CHECKARCHIVE_RAPID    =   0;                               // �Ȉ�(�ŏ��̂R�w�b�_�܂�)
     CHECKARCHIVE_BASIC    =   1;                               // �W��(�S�Ẵw�b�_)
     CHECKARCHIVE_FULLCRC  =   2;                               // ���S(�i�[�t�@�C���� CRC �`�F�b�N)
                                                                // �ȉ��͏�L�̃t���O�Ƒg�ݍ��킹�Ďg�p
     CHECKARCHIVE_RECOVERY =   4;                               // �j���w�b�_��ǂݔ�΂��ď���
     CHECKARCHIVE_SFX      =   8;                               // SFX ���ǂ�����Ԃ�
     CHECKARCHIVE_ALL      =  16;                               // �t�@�C���̍Ō�܂Ō�������
//function UnlhaIsSFXFile�Ŏg�p����t���O
     SFX_NOT               =   0;
     SFX_DOS_213S          =   1;
     SFX_DOS_250S          =   2;
     SFX_DOS_265S          =   3;
     SFX_DOS_213L          =  51;
     SFX_DOS_250L          =  52;
     SFX_DOS_265L          =  53;
     SFX_WIN16_213         =1001;
     SFX_WIN16_213_1       =1001;
     SFX_WIN16_213_2       =1002;
     SFX_WIN32_213         =2001;
     SFX_WIN32_250         =2011;
     SFX_WIN32_250_1       =2011;
     SFX_WIN32_250_6       =2012;
     SFX_LZHSFX_1002       =2051;
     SFX_LZHSFX_1100       =2052;
     SFX_LZHAUTO_0002      =2101;
     SFX_LZHAUTO_1002      =2102;
     SFX_LZHAUTO_1100      =2103;

// function UnlhaConfigDialog�Ŏg�p����t���O
     UNPACK_CONFIG_MODE    =   1;                               // �𓀌n�̐ݒ�
     PACK_CONFIG_MODE      =   2;                               // ���k�n�̐ݒ�
// function UnlhaQueryFunctionList�Ŏg�p����t���O
     ISARC_FUNCTION_START               = 0;
     ISARC                              = 0;// Unlha 
     ISARC_GET_VERSION                  = 1;// UnlhaGetVersion
     ISARC_GET_CURSOR_INTERVAL          = 2;// UnlhaGetCursorInterval
     ISARC_SET_CURSOR_INTERVAL          = 3;// UnlhaSetCursorInterval
     ISARC_GET_BACK_GROUND_MODE         = 4;// UnlhaGetBackGroundMode
     ISARC_SET_BACK_GROUND_MODE         = 5;// UnlhaSetBackGroundMode
     ISARC_GET_CURSOR_MODE              = 6;// UnlhaGetCursorMode
     ISARC_SET_CURSOR_MODE              = 7;// UnlhaSetCursorMode
     ISARC_GET_RUNNING                  = 8;// UnlhaGetRunning

     ISARC_CHECK_ARCHIVE                = 16;// UnlhaCheckArchive
     ISARC_CONFIG_DIALOG                = 17;// UnlhaConfigDialog
     ISARC_GET_FILE_COUNT               = 18;// UnlhaGetFileCount
     ISARC_QUERY_FUNCTION_LIST          = 19;// UnlhaQueryFunctionList
     ISARC_HOUT                         = 20;// (UnlhaHOut)
     ISARC_STRUCTOUT                    = 21;// (UnlhaStructOut) 
     ISARC_GET_ARC_FILE_INFO            = 22;// UnlhaGetArcFileInfo 

     ISARC_OPEN_ARCHIVE                 = 23;// UnlhaOpenArchive 
     ISARC_CLOSE_ARCHIVE                = 24;// UnlhaCloseArchive 
     ISARC_FIND_FIRST                   = 25;// UnlhaFindFirst 
     ISARC_FIND_NEXT                    = 26;// UnlhaFindNext 
     ISARC_EXTRACT                      = 27;// (UnlhaExtract) 
     ISARC_ADD                          = 28;// (UnlhaAdd)
     ISARC_MOVE                         = 29;// (UnlhaMove) 
     ISARC_DELETE                       = 30;// (UnlhaDelete) 

     ISARC_GET_ARC_FILE_NAME            = 40;// UnlhaGetArcFileName 
     ISARC_GET_ARC_FILE_SIZE            = 41;// UnlhaGetArcFileSize 
     ISARC_GET_ARC_ORIGINAL_SIZE        = 42;// UnlhaArcOriginalSize
     ISARC_GET_ARC_COMPRESSED_SIZE      = 43;// UnlhaGetArcCompressedSize 
     ISARC_GET_ARC_RATIO                = 44;// UnlhaGetArcRatio 
     ISARC_GET_ARC_DATE                 = 45;// UnlhaGetArcDate 
     ISARC_GET_ARC_TIME                 = 46;// UnlhaGetArcTime 
     ISARC_GET_ARC_OS_TYPE              = 47;// UnlhaGetArcOSType 
     ISARC_GET_ARC_IS_SFX_FILE          = 48;// UnlhaGetArcIsSFXFile 
     ISARC_GET_FILE_NAME                = 57;// UnlhaGetFileName 
     ISARC_GET_ORIGINAL_SIZE            = 58;// UnlhaGetOriginalSize
     ISARC_GET_COMPRESSED_SIZE          = 59;// UnlhaGetCompressedSize 
     ISARC_GET_RATIO                    = 60;// UnlhaGetRatio 
     ISARC_GET_DATE                     = 61;// UnlhaGetDate 
     ISARC_GET_TIME                     = 62;// UnlhaGetTime 
     ISARC_GET_CRC                      = 63;// UnlhaGetCRC
     ISARC_GET_ATTRIBUTE                = 64;// UnlhaGetAttribute 
     ISARC_GET_OS_TYPE                  = 65;// UnlhaGetOSType 
     ISARC_GET_METHOD                   = 66;// UnlhaGetMethod 
     ISARC_GET_WRITE_TIME               = 67;// UnlhaGetWriteTime 
     ISARC_GET_CREATE_TIME              = 68;// UnlhaGetCreateTime
     ISARC_GET_ACCESS_TIME              = 69;// UnlhaGetAccessTime 

     ISARC_FUNCTION_END                 = 69;
// Unlha32.dll �� Windows Message �p
     WM_ARCEXTRACT                      = 'wm_arcextract';
     ARCEXTRACT_BEGIN                   = 0;                    // �Y���t�@�C���̏����̊J�n
     ARCEXTRACT_INPROCESS               = 1;                    // �Y���t�@�C���̓W�J��
     ARCEXTRACT_END                     = 2;                    // �����I���A�֘A���������J��
     ARCEXTRACT_OPEN                    = 3;                    // �Y�����ɂ̏����̊J�n
     ARCEXTRACT_COPY                    = 4;                    // ���[�N�t�@�C���̏����߂�
// function UnlhaOpenArchive���Ŏg�p����t���O
     M_INIT_FILE_USE                    = $00000001;            // ���W�X�g���̐ݒ���g�p
     M_REGARDLESS_INIT_FILE             = $00000002;            // �@�@�@�@�@�V�@�@�@�@�@���g�p���Ȃ�
     M_CHECK_ALL_PATH                   = $00000100;            // ���i�ȃt�@�C�����T�[�`
     M_CHECK_FILENAME_ONLY              = $00000200;            // �@�@�@�@�@�V�@�@�@�@�@���s��Ȃ�
     M_USE_DRIVE_LETTER                 = $00001000;            // �h���C�u������i�[
     M_NOT_USE_DRIVE_LETTER             = $00002000;            // �@�@�@�@�V�@�@�@�@���i�[���Ȃ�
     M_ERROR_MESSAGE_ON                 = $00400000;            // �G���[���b�Z�[�W��\��
     M_ERROR_MESSAGE_OFF                = $00800000;            // �@�@�@�@�@�V�@�@�@�@�@��\�����Ȃ�
     M_RECOVERY_ON                      = $08000000;            // �j���w�b�_�̓ǂݔ�΂�

     EXTRACT_FOUND_FILE                 = $40000000;            // �������ꂽ�t�@�C������
     EXTRACT_NAMED_FILE                 = $80000000;            // �w�肵���t�@�C������
                                                                // EXTRACT_FOUND_FILE
// Attribute
     FA_RDONLY                          = $071;                  // �������ݕی쑮��
     FA_HIDDEN                          = $02;                  // �B������
     FA_SYSTEM                          = $04;                  // �V�X�e������
     FA_LABEL                           = $08;                  // �{�����[���E���x��
     FA_DIREC                           = $10;                  // �f�B���N�g��
     FA_ARCH                            = $20;                  // �A�[�J�C�u����
// �G���[�R�[�h�ꗗ
     ERROR_DISK_SPACE                   = $8005;
     ERROR_READ_ONLY                    = $8006;
     ERROR_USER_SKIP                    = $8007;
     ERROR_UNKNOWN_TYPE                 = $8008;
     ERROR_METHOD                       = $8009;
     ERROR_PASSWORD_FILE                = $800A;
     ERROR_VERSION                      = $800B;
     ERROR_FILE_CRC                     = $800C;
     ERROR_FILE_OPEN                    = $800D;
     ERROR_MORE_FRESH                   = $800E;
     ERROR_NOT_EXIST                    = $800F;
     ERROR_ALREADY_EXIST                = $8010;

     ERROR_TOO_MANY_FILES               = $8011;

// //ERROR
     ERROR_MAKEDIRECTORY                = $8012;
     ERROR_CANNOT_WRITE                 = $8013;
     ERROR_HUFFMAN_CODE                 = $8014;
     ERROR_COMMENT_HEADER               = $8015;
     ERROR_HEADER_CRC                   = $8016;
     ERROR_HEADER_BROKEN                = $8017;
     ERROR_ARC_FILE_OPEN                = $8018;
     ERROR_NOT_ARC_FILE                 = $8019;
     ERROR_CANNOT_READ                  = $801A;
     ERROR_FILE_STYLE                   = $801B;
     ERROR_COMMAND_NAME                 = $801C;
     ERROR_MORE_HEAP_MEMORY             = $801D;
     ERROR_ENOUGH_MEMORY                = $801E;
     ERROR_ALREADY_RUNNING              = $801F;
     ERROR_USER_CANCEL                  = $8020;
     ERROR_HARC_ISNOT_OPENED            = $8021;
     ERROR_NOT_SEARCH_MODE              = $8022;
     ERROR_NOT_SUPPORT                  = $8023;
     ERROR_TIME_STAMP                   = $8024;
     ERROR_TMP_OPEN                     = $8025;
     ERROR_LONG_FILE_NAME               = $8026;
     ERROR_ARC_READ_ONLY                = $8027;
     ERROR_SAME_NAME_FILE               = $8028;
     ERROR_NOT_FIND_ARC_FILE            = $8029;
     ERROR_RESPONSE_READ                = $802A;
     ERROR_NOT_FILENAME                 = $802B;
     ERROR_TMP_COPY                     = $802C;

type
    TIndividualinfo = record
        dwOriginalSize   : Longint;                             // �t�@�C���̃T�C�Y
        dwCompressedSize : Longint;                             // ���k��̃T�C�Y
        dwCRC            : Longint;                             // �i�[�t�@�C���̃`�F�b�N�T��
        uFlag            : integer;                             // ��������
        uOSType          : integer;                             // ���ɍ쐬�Ɏg��ꂽ�n�r
        wRatio           : word;                                // ���k��
        wDate            : word;                                // �i�[�t�@�C���̓��t(DOS �`��)
        wTime            : word;                                // �i�[�t�@�C���̎���(�V)
        szFileName       : array [0..FNAME_MAX32 + 1] of char;  // ���ɖ�
        dummy1           : array [0..3] of char;
        szAttribute      : array [0..8] of char;                // �i�[�t�@�C���̑���(���ɌŗL)
        szMode           : array [0..8] of char;                // �i�[�t�@�C���̊i�[���[�h(�V)
        end;
    TExtractinginfo = record
        dwFileSize       : Longint;                             // �i�[�t�@�C���̃T�C�Y
        dwWriteSize      : Longint;                             // �������݃T�C�Y
        szSourceFileName : array [0..FNAME_MAX32 + 1] of char;  // �i�[�t�@�C����
        dummy1           : array [0..3] of char;
        szDestFileName   : array [0..FNAME_MAX32 + 1] of char;  // �𓀐�܂��͈��k���p�X��
        dummy            : array [0..3] of char;
        end;
    TExtractinginfoEx = record
        exinfo           : TExtractinginfo;
        dwCompressedSize : Longint;
        dwCRC            : Longint;
        uOSType          : integer;
        wRatio           : word;
        wDate            : word;
        wTime            : word;
        szAttribute      : array [0..8] of char;
        szMode           : array [0..8] of char;
        end;
    TLhalocalinfo = record
        uTotalFiles      : integer;
        uCountInfoFiles  : integer;
        uErrorCount      : integer;
        lDiskSpace       : Longint;
        hSubInfo         : THandle;
        end;

//LHA.DLL Ver 1.1 �ƌ݊����̂��� API �ł��B
function UnlhaGetVersion : word;
function UnlhaGetRunning : Boolean;
function UnlhaGetBackGroundMode : Boolean;
function UnlhaSetBackGroundMode(const _BackGroundMode :Boolean) : Boolean;
function UnlhaGetCursorMode : Boolean;
function UnlhaSetCursorMode(const _CursorMode : Boolean) : Boolean;
function UnlhaGetCursorInterval : word;
function UnlhaSetCursorInterval(const _Interval : word) : Boolean;
function Unlha(const _hwnd : HWND ; const _szCmdLine : PChar ;
                 var _szOutput : String ; const _dwSize : Longint) : integer;
//�w�����A�[�J�C�o API�x���ʂ� API �ł��B
//�@�g�p����t���O�̓t�@�C���̐擪�ɂ܂Ƃ߂Ă���܂��B
function UnlhaCheckArchive(_szFileName : PChar ; const _iMode : integer) : Boolean;
function UnlhaGetFileCount(_szArcFile : PChar) : integer;
function UnlhaConfigDialog(const _hwnd : HWND ; _lpszComBuffer : PChar ;
                                                   const _iMode : integer) : Boolean;
function UnlhaQueryFunctionList(const _iFunction : integer): Boolean;
function UnlhaSetOwnerWindow(const _hwnd : HWND) : Boolean;
function UnlhaClearOwnerWindow : Boolean;

// �����̓e�X�g��
{
function ARCHIVERPROC(_hwnd : HWND ; _uMsg : Integer;
                      _nState : Integer ; var _lpEis : TExtractinginfoEx) : Boolean;

// Message�󂯎��p�ϐ��i���̃��j�b�g�Ǝ��j
var
    Unlha32OwnerWindow  : HWND ;               //���_hwnd�Ɠ���
    Unlha32Message      : Integer;             //���_uMsg�Ɠ���
    Unlha32RunningMode  : Integer ;            //���_nState�Ɠ���
    Unlha32RunningInfo  : TExtractinginfoEx;   //���_lpEis�Ɠ���
    Unlha32Aborted      : Boolean;             //���~�������Ƃ��ɂ�True�ɐݒ�

//
function UnlhaSetOwnerWindowEx(_hwnd : HWND ; var _lpArcProc : Pointer ) : Boolean;
function UnlhaKillOwnerWindowEx(_hwnd : HWND) : Boolean;
}

// OpenArchive �n API �ł��B

function UnlhaOpenArchive(const _hwnd : HWND ; _szFileName : PChar ;
                                                  const _dwMode : Longint) : THandle;
function UnlhaCloseArchive(_harc : THandle) : integer;
function UnlhaFindFirst(_harc : THandle ; _szWildName : PChar;
                            var _lpSubInfo : TIndividualinfo ) : integer;
function UnlhaFindNext(_harc : THandle ; var _lpSubInfo : TIndividualinfo) : integer;
function UnlhaGetArcFileName(_harc : THandle ; _lpBuffer : PChar ;
                                               const _nSize : integer) : integer;
function UnlhaGetArcFileSize(_harc : THandle) : Longint;
function UnlhaGetArcOriginalSize(_harc : THandle) : Longint;
function UnlhaGetArcCompressedSize(_harc : THandle) : Longint;
function UnlhaGetArcRatio(_harc : THandle) : WORD;
function UnlhaGetArcDate(_harc : THandle) : WORD;
function UnlhaGetArcTime(_harc : THandle) : WORD;
function UnlhaGetArcOSType(_harc : THandle) : integer;
function UnlhaIsSFXFile(_harc : THandle) : integer;
function UnlhaGetFileName(_harc : THandle ; _lpBuffer : PChar ; const _nSize : integer) : integer;
function UnlhaGetMethod(_harc : THandle ; _lpBuffer : PChar ; const _nSize : integer) : integer;
function UnlhaGetOriginalSize(_harc : THandle) : Longint;
function UnlhaGetCompressedSize(_harc : THandle) : Longint;
function UnlhaGetRatio(_harc : THandle) : WORD;
function UnlhaGetDate(_harc : THandle) : WORD;
function UnlhaGetTime(_harc : THandle) : WORD;
function UnlhaGetWriteTime(_harc : THandle) : Longint;
function UnlhaGetAccessTime(_harc : THandle) : Longint;
function UnlhaGetCreateTime(_harc : THandle) : Longint;
function UnlhaGetCRC(_harc : THandle) : Longint;
function UnlhaGetAttribute(_harc : THandle) : integer;
function UnlhaGetOSType(_harc : THandle) : integer;

// ### UNLHA32.DLL �Ǝ��� API �ł��B###
function UnlhaGetSubVersion : word;

function UnlhaExtractMem(const _hwndParent : HWND ; _szCmdLine : PChar ; _lpBuffer : PChar ;
                         const _dwSize : Longint ; _lpTime : TDateTime; var _lpwAttr : word ;
                         var _lpdwWriteSize : word) : integer;
function UnlhaCompressMem(const _hwndParent : HWND ; _szCmdLine : PChar ; const _lpBuffer : PChar ;
                          const _dwSize : Longint ; const _lpTime : TDateTime ; const _lpwAttr : word ;
                          var _lpdwWriteSize : Longint) : integer;

var
//���̃��j�b�g�Ǝ��̕ϐ��ł��BUnlha32.DLL���g�p�\��������g���ă`�F�b�N���Ă��������B
    Unlha32CanUse : Boolean;

implementation

//���̕ϐ��͂��̃��j�b�g�����Ŏg�p����Ǝ��̕ϐ��Ȃ̂ŁAUNLHA32.H�ɂ͂���܂���B
var
    Unlha32Handle : THandle;

//�������A���ۂ̊֐��̌Ăяo�����L�q����܂��B
//���͏Ȃ��܂��B

function UnlhaGetVersion : word;
type
    TFunc = function : word;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetVersion');
        Result := F;
        end
        else
        Result := 0;
end;

function UnlhaGetRunning : Boolean;
type
    TFunc = function : Boolean;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetRunning');
        Result := F;
        end
        else
        Result := False;
end;

function UnlhaGetBackGroundMode : Boolean;
type
    TFunc = function : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetBackGroundMode');
        Result := F;
        end
        else
        Result := False;
end;

function UnlhaSetBackGroundMode(const _BackGroundMode :Boolean) : Boolean;
type
    TFunc = function(const _BackGroundMode_ :Boolean) : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaSetBackGroundMode');
        Result := F(_BackGroundMode);
        end
        else
        Result := False;
end;

function UnlhaGetCursorMode : Boolean;
type
    TFunc = function : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetCursorMode');
        Result := F;
        end
        else
        Result := False;
end;

function UnlhaSetCursorMode(const _CursorMode : Boolean) : Boolean;
type
    TFunc = function(const _CursorMode_ : Boolean) : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaSetCursorMode');
        Result := F(_CursorMode);
        end
        else
        Result := False;
end;

function UnlhaGetCursorInterval : word;
type
    TFunc = function : word; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetCursorInterval');
        Result := F;
        end
        else
        Result := 0;
end;

function UnlhaSetCursorInterval(const _Interval : word) : Boolean;
type
    TFunc = function(const _Interval_ : word) : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaSetCursorInterval');
        Result := F(_Interval);
        end
        else
        Result := False;
end;
function Unlha(const _hwnd : HWND ; const _szCmdLine : PChar ;
                 var _szOutput : String ; const _dwSize : Longint): integer;
type
    TFunc = function(const _hwnd_ : HWND ; const _szCmdLine_ : PChar ;
                     var _szOutput_ : Char ;
                     const _dwSize_ : Longint) : integer; stdcall;
var
    F : TFunc;
    Buf : PChar;
begin
    if Unlha32CanUse = True then begin
        Buf := StrAlloc(_dwSize);
        F := GetProcAddress(Unlha32Handle,'Unlha');
        Result := F(_hwnd,_szCmdLine,Buf^,_dwSize);  // ^ �͓��I�ϐ��ւ̎Q��
        _szOutPut := Buf;
        StrDispose(Buf);
        end
        else
        Result := ERROR_ARC_FILE_OPEN; //UNLHA32.DLL���g���Ȃ��Ƃ��ɂ�LZH�t�@�C�����J���Ȃ���
                                       //�����G���[�R�[�h��Ԃ��܂��B
end;

function UnlhaCheckArchive(_szFileName : PChar ; const _iMode : integer) : Boolean;
type
    TFunc = function(_szFileName_ : PChar ; const _iMode_ : integer) : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaCheckArchive');
        Result := F(_szFileName,_iMode);
        end
        else
        Result := False;
end;

function UnlhaGetFileCount(_szArcFile : PChar) : integer;
type
    TFunc = function(const _szArcFile_ : PChar) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetFileCount');
        Result := F(_szArcFile);
        end
        else
        Result := -1;
end;

function UnlhaConfigDialog(const _hwnd : HWND ; _lpszComBuffer : PChar ;
                                                   const _iMode : integer) : Boolean;
type
    TFunc = function(const _hwnd_ : HWND ; _lpszComBuffer_ : PChar ;
                                              const _iMode_ : integer) : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaConfigDialog');
        Result := F(_hwnd,_lpszComBuffer,_iMode);
        end
        else
        Result := False;
end;

function UnlhaQueryFunctionList(const _iFunction : integer) : Boolean;
type
    TFunc = function(const _iFunction_ : integer) : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaQueryFunctionList');
        Result := F(_iFunction);
        end
        else
        Result := False;
end;

function UnlhaSetOwnerWindow(const _hwnd : HWND) : Boolean;
type
    TFunc = function(const _hwnd_ : HWND) : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetVersion');
        Result := F(_hwnd);
        end
        else
        Result := False;
end;

function UnlhaClearOwnerWindow : Boolean;
type
    TFunc = function : Boolean; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaClearOwnerWindow');
        Result := F;
        end
        else
        Result := False;
end;

{
// �Ғ��F�������R�[���o�b�N�֐����g�p���郆�j�b�g�ɒǉ����Ă��������B
function ARCHIVERPROC(_hwnd : HWND ; _uMsg : Integer ;
                      _nState : Integer ; var _lpEis : TExtractinginfoEx) : Boolean;
begin
    Unlha32OwnerWindow := _hwnd;
    Unlha32Message     := _uMsg;
    Unlha32RunningMode := _nState;
    Unlha32RunningInfo := _lpEis;
    Result             := not Unlha32Aborted;
end;

/*  ���󂯎��p�ϐ����X�g
    Unlha32OwnerWindow : HWND ;               //���_hwnd�Ɠ���
    Unlha32Message     : Integer;             //���_uMsg�Ɠ���
    Unlha32RunningMode : Integer ;            //���_nState�Ɠ���
    Unlha32RunningInfo : TExtractinginfoEx;   //���_lpEis�Ɠ���
    Unlha32Aborted     : Boolean;             //���~�������Ƃ��ɂ�True�ɐݒ�
*/

function UnlhaSetOwnerWindowEx(_hwnd : HWND ; var _lpArcProc : Pointer ) : Boolean;
type
    TFunc = function(_hwnd_ : HWND ; var _lpArcProc : Pointer ) : Boolean;stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaSetOwnerWindowEx');
        Result := F(_hwnd,_lpArcProc);
        end
        else
        Result := False;
end;

function UnlhaKillOwnerWindowEx(_hwnd : HWND) : Boolean;
type
    TFunc = function(_hwnd_ : HWND) : Boolean;stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaKillOwnerWindowEx');
        Result := F(_hwnd);
        end
        else
        Result := False;
end;
}

function UnlhaOpenArchive(const _hwnd : HWND ; _szFileName : PChar ;
                                            const _dwMode : Longint) : THandle;
type
    TFunc = function(const _hwnd_ : HWND ; _szFileName_ : PChar ;
                                        const _dwMode_ : Longint) : THandle;stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaOpenArchive');
        Result := F(_hwnd,_szFileName,_dwMode);
        end
        else
        Result := THandle(nil);
end;

function UnlhaCloseArchive(_harc : THandle) : integer;
type
    TFunc = function(_harc_ : THandle) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaCloseArchive');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaFindFirst(_harc : THandle ; _szWildName : PChar;
                            var _lpSubInfo : TIndividualinfo ) : integer;
type
    TFunc = function(_harc_ : THandle ; _szWildName_ : PChar;
                            var _lpSubInfo_ : TIndividualinfo )  : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaFindFirst');
        Result := F(_harc,_szWildName,_lpSubInfo) ;
        end
        else
        Result := -1;
end;

function UnlhaFindNext(_harc : THandle ; var _lpSubInfo : TIndividualinfo) : integer;
type
    TFunc = function(_harc_ : THandle ; var _lpSubInfo_ : TIndividualinfo) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaFindNext');
        Result := F(_harc,_lpSubInfo);
        end
        else
        Result := -1;
end;

function UnlhaGetArcFileName(_harc : THandle ; _lpBuffer : PChar ;
                                               const _nSize : integer) : integer;
type
    TFunc = function(_harc_ : THandle ; _lpBuffer_ : PChar ;
                                     const _nSize_ : integer)  : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetArcFileName');
        Result := F(_harc,_lpBuffer,_nSize) ;
        end
        else
        Result := -1;
end;

function UnlhaGetArcFileSize(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetArcFileSize');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetArcOriginalSize(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetArcOriginalSize');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetArcCompressedSize(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetArcCompressedSize');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetArcRatio(_harc : THandle) : WORD;
type
    TFunc = function(_harc_ : THandle) : word; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetArcRatio');
        Result := F(_harc);
        end
        else
        Result := 65535;
end;

function UnlhaGetArcDate(_harc : THandle) : word;
type
    TFunc = function(_harc_ : THandle) : word; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetArcDate');
        Result := F(_harc);
        end
        else
        Result := 65535;
end;

function UnlhaGetArcTime(_harc : THandle) : word;
type
    TFunc = function(_harc_ : THandle) : word; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetArcTime');
        Result := F(_harc);
        end
        else
        Result := 65535;
end;

function UnlhaGetArcOSType(_harc : THandle) : integer;
type
    TFunc = function(_harc_ : THandle) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetArcOSType');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaIsSFXFile(_harc : THandle) : integer;

type
    TFunc = function(_harc_ : THandle) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaIsSFXFile');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetFileName(_harc : THandle ; _lpBuffer : PChar ; const _nSize : integer): integer;
type
    TFunc = function(_harc_ : THandle ; _lpBuffer_ : PChar ; const _nSize_ : integer) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetFileName');
        Result := F(_harc,_lpBuffer,_nSize);
        end
        else
        Result := -1;
end;

function UnlhaGetMethod(_harc : THandle ; _lpBuffer : PChar ; const _nSize : integer) : integer;
type
    TFunc = function(_harc_ : THandle ; _lpBuffer_ : PChar ; const _nSize_ : integer) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetMethod');
        Result := F(_harc,_lpBuffer,_nSize);
        end
        else
        Result := -1;
end;

function UnlhaGetOriginalSize(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetOriginalSize');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetCompressedSize(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetCompressedSize');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetRatio(_harc : THandle) : word;
type
    TFunc = function(_harc_ : THandle) : word; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetRatio');
        Result := F(_harc);
        end
        else
        Result := 65535;
end;

function UnlhaGetDate(_harc : THandle) : word;
type
    TFunc = function(_harc_ : THandle) : word; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetDate');
        Result := F(_harc);
        end
        else
        Result := 65535;
end;

function UnlhaGetTime(_harc : THandle) : word;
type
    TFunc = function(_harc_ : THandle) : word; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetTime');
        Result := F(_harc);
        end
        else
        Result := 65535;
end;

function UnlhaGetWriteTime(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetWriteTime');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetAccessTime(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetAccessTime');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetCreateTime(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetCreateTime');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetCRC(_harc : THandle) : Longint;
type
    TFunc = function(_harc_ : THandle) : Longint; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetCRC');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetAttribute(_harc : THandle) : integer;
type
    TFunc = function(_harc_ : THandle) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetAttribute');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetOSType(_harc : THandle) : integer;
type
    TFunc = function(_harc_ : THandle) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetOSType');
        Result := F(_harc);
        end
        else
        Result := -1;
end;

function UnlhaGetSubVersion : word;
type
    TFunc = function : word; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaGetSubVersion');
        Result := F;
        end
        else
        Result := 0;
end;

function UnlhaExtractMem(const _hwndParent : HWND ; _szCmdLine : PChar ; _lpBuffer : PChar ;
                         const _dwSize : Longint ; _lpTime : TDateTime; var _lpwAttr : word ;
                         var _lpdwWriteSize : word) : integer;
type
    TFunc = function(const _hwndParent : HWND ; _szCmdLine : PChar ; _lpBuffer : PChar ;
                     const _dwSize : Longint ; _lpTime : TDateTime; var _lpwAttr : word ;
                     var _lpdwWriteSize : word) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaExtractMem');
        Result := F(_hwndParent,_szCmdLine,_lpBuffer,_dwSize,_lpTime,_lpwAttr,_lpdwWriteSize);
        end
        else
        Result := -1;
end;

function UnlhaCompressMem(const _hwndParent : HWND ; _szCmdLine : PChar ; const _lpBuffer : PChar ;
                          const _dwSize : Longint ; const _lpTime : TDateTime ; const _lpwAttr : word ;
                          var _lpdwWriteSize : Longint) : integer;
type
    TFunc = function(const _hwndParent : HWND ; _szCmdLine : PChar ; const _lpBuffer : PChar ;
                     const _dwSize : Longint ; const _lpTime : TDateTime ; const _lpwAttr : word ;
                     var _lpdwWriteSize : Longint) : integer; stdcall;
var
    F : TFunc;
begin
    if Unlha32CanUse = True then begin
        F := GetProcAddress(Unlha32Handle,'UnlhaCompressMem');
        Result := F(_hwndParent,_szCmdLine,_lpBuffer,_dwSize,_lpTime,_lpwAttr,_lpdwWriteSize);
        end
        else
        Result := -1;
end;

initialization
     //���������ł��B�A�v���P�[�V�����̋N�����Ɏ��s����܂��B
     begin
     //�c�k�k�����[�h���A�g�p�\�ɂ��܂��B
     Unlha32Handle := Loadlibrary('UNLHA32');
     //���s�����Ƃ��́A�ϐ�Unlha32CanUse��False�ɂ��܂��B
     if Unlha32Handle = 0 then begin
        Unlha32CanUse := False;
        end
        else
        Unlha32CanUse := True;
     end;

finalization
     //�I�����ł��B�A�v���P�[�V�����̏I�����Ɏ��s����܂��B
     begin
     //�c�k�k���g�p����Ă���΁A�A�����[�h���A��������������܂��B
     if Unlha32CanUse = True then
        FreeLibrary(Unlha32Handle);
     end;
end.
