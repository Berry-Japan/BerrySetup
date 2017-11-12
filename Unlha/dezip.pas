unit DeZip;

interface

Uses
  Windows;

{ Stuff needed generically by all uncompression methods }

Const
   MAXNAMES = 20;

Var
   InFileSpecs :  Array[1..MAXNAMES] of String;   { Input file specifications }
   MaxSpecs    :  Word;        { Total number of entries in InFileSpecs array }
   OutPath     :  String;      { Output path specification                    }

   TenPercent  :  LongInt;

{ Define ZIP file header types }

Const
   LOCAL_FILE_HEADER_SIGNATURE = $04034B50;

Type
   Local_File_Header_Type = Record
                             { Signature              :  LongInt; }
                               Extract_Version_Reqd   :  Word;
                               Bit_Flag               :  Word;
                               Compress_Method        :  Word;
                               Last_Mod_Time          :  Word;
                               Last_Mod_Date          :  Word;
                               Crc32                  :  LongInt;
                               Compressed_Size        :  LongInt;
                               Uncompressed_Size      :  LongInt;
                               Filename_Length        :  Word;
                               Extra_Field_Length     :  Word;
                            end;

Const
   CENTRAL_FILE_HEADER_SIGNATURE = $02014B50;

Type
   Central_File_Header_Type = Record
                               { Signature            :  LongInt; }
                                 MadeBy_Version       :  Word;
                                 Extract_Version_Reqd :  Word;
                                 Bit_Flag             :  Word;
                                 Compress_Method      :  Word;
                                 Last_Mod_Time        :  Word;
                                 Last_Mod_Date        :  Word;
                                 Crc32                :  LongInt;
                                 Compressed_Size      :  LongInt;
                                 Uncompressed_Size    :  LongInt;
                                 Filename_Length      :  Word;
                                 Extra_Field_Length   :  Word;
                                 File_Comment_Length  :  Word;
                                 Starting_Disk_Num    :  Word;
                                 Internal_Attributes  :  Word;
                                 External_Attributes  :  LongInt;
                                 Local_Header_Offset  :  LongInt;
                              End;

Const
   END_OF_CENTRAL_DIR_SIGNATURE = $06054B50;

Type
   End_of_Central_Dir_Type =  Record
                               { Signature               :  LongInt; }
                                 Disk_Number             :  Word;
                                 Central_Dir_Start_Disk  :  Word;
                                 Entries_This_Disk       :  Word;
                                 Total_Entries           :  Word;
                                 Central_Dir_Size        :  LongInt;
                                 Start_Disk_Offset       :  LongInt;
                                 ZipFile_Comment_Length  :  Word;
                              end;

Const
   CRC_32_TAB : Array[0..255] of LongInt = (
$00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3,
$0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91,
$1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
$136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63, $8d080df5,
$3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
$35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59,
$26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
$2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d,
$76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433,
$7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
$6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457,
$65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65,
$4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb,
$4369e96a, $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
$5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
$5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad,
$edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683,
$e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1,
$f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7,
$fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
$d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
$d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79,
$cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f,
$c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
$9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
$95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21,
$86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777,
$88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
$a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db,
$aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
$bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf,
$b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
);

Const
   BUFSIZE       = 8192;           { Size of buffers for I/O }

Type
   BufPtr        = ^BufType;
   BufType      = Array[1..BUFSIZE] of Byte;

Var
   ZipName       :  String;         { Name of Zip file to be processed }
   ZipFile       :  File;           { Zip file variable }
   EndFile       :  Boolean;        { End of file indicator for ZipFile }
   ZipBuf        :  BufPtr;         { Input buffer for ZipFile }
   //ZipBuf        :  Array[1..BUFSIZE] of Byte; { Input buffer for ZipFile }
   ZipPtr        :  Word;           { Index for ZipFile input buffer }
   ZipCount      :  Integer;           { Count of bytes in ZipFile input buffer }

   ExtFile       :  File;           { Output file variable }
   ExtBuf        :  BufPtr;         { Output buffer for ExtFile }
   ExtPtr        :  Word;           { Index for ExtFile output buffer }
   ExtCount      :  LongInt;        { Count of characters written to output }

   LocalHdr       : Local_File_Header_Type;  { Storage for a local file hdr }
   Hdr_FileName   : String;
   Hdr_ExtraField : String;
   Hdr_Comment    : String;

   Crc32Val      :  LongInt;        { Running CRC (32 bit) value }

   Bytes_To_Go   :  LongInt;        { Bytes left to process in compressed file }


{ Stuff needed for unSHRINKing }

Const
   MINCODESIZE    =    9;
   MAXCODESIZE    =   13;
   SPECIAL        =  256;
   FIRSTFREE      =  257;
   LZW_TABLE_SIZE =  (1 SHL MAXCODESIZE) - 1;      { 0..8191 }
   LZW_STACK_SIZE =  (1 SHL MAXCODESIZE) - 1;      { 0..8191 }

Type

   LZW_Table_Rec  =  Record
                        Prefix      :  Integer;
                        Suffix      :  Byte;
                        ChildCount  :  Word;  { If ChildCount = 0 then leaf node }
                     end;
   LZW_Table_Ptr  =  ^LZW_Table_Type;
   LZW_Table_Type =  Array[0..LZW_TABLE_SIZE] of LZW_Table_Rec;

   FreeListPtr    =  ^FreeListArray;
   FreeListArray  =  Array[FIRSTFREE..LZW_TABLE_SIZE] of Word;

   StackPtr       =  ^StackType;
   StackType      =  Array[0..LZW_STACK_SIZE] of Word;

Var
   LZW_Table   :  LZW_Table_Ptr; { Code table for LZW decoding                }
   FreeList    :  FreeListPtr;   { List of free table entries                 }
   NextFree    :  Word;          { Index for free list array                  }
                                 {   FreeList^[NextFree] always contains the  }
                                 {   index of the next available entry in     }
                                 {   the LZW Prefix:Suffix table (LZW_Table^) }
   LZW_Stack   :  StackPtr;      { A stack used to build decoded strings      }
   StackIdx    :  Word;          { Stack array index variable                 }
                                 {   StackIdx always points to the next       }
                                 {   available entry in the stack             }
   SaveByte    :  Byte;          { Our input code buffer - 1 byte long }
   BitsLeft    :  Byte;          { Unprocessed bits in the input code buffer }
   FirstCh     :  Boolean;       { Flag indicating first char being processed }


{ Stuff needed for unREDUCEing }

Const
   MAXDICTSIZE    =  8192;       { size will be 4096 for unreduce and either  }
                                 { 4096 or 8192 for exploding                 }

Type
   FollowerSet    =  Record
                        SetSize  :  Word;
                        FSet     :  Array[0..31] of Byte;
                     end;
   FollowerPtr    =  ^FollowerArray;
   FollowerArray  =  Array[0..255] of FollowerSet;

   DictPtr        =  ^DictArray;
   DictArray      =  Array[0..MAXDICTSIZE - 1] of Byte;

Var
   Followers   :  FollowerPtr;
   Dictionary  :  DictPtr;       { The sliding dictionary }
   DictIdx     :  Word;          { Always points to next pos. to be filled }
   DictSize    :  Word;          { size (in bytes) of sliding dictionary }
   State       :  Byte;
   Len         :  Word;
   V           :  Byte;


{ Stuff needed for unIMPLODEing }

Const
   MAX_SF_TREE_SIZE     =  511;

   LITERAL_TREE_ROOT    =  511;
   DISTANCE_TREE_ROOT   =  127;
   LENGTH_TREE_ROOT     =  127;

Type

   { The following structures are used to define the Shannon-Fano trees used  }
   { in decoding an imploded file                                             }

   SF_Node              =  Record
                              LChild   :  Integer;
                              RChild   :  Integer;
                           end;
   SF_Literal_Ptr       =  ^SF_Literal_Array;
   SF_Distance_Ptr      =  ^SF_Distance_Array;
   SF_Length_Ptr        =  ^SF_Length_Array;
   SF_Literal_Array     =  Array[0..LITERAL_TREE_ROOT] of SF_Node;
   SF_Distance_Array    =  Array[0..DISTANCE_TREE_ROOT] of SF_Node;
   SF_Length_Array      =  Array[0..LENGTH_TREE_ROOT] of SF_Node;

   { The Shannon-Fano data that is stored at the beginning of the compressed  }
   { file is itself compressed.  The following structures are used to decode  }
   { that data and build the required Shannon-Fano trees                      }
   SF_BuildRec          =  Record
                              Len   :  Byte;
                              Val   :  Byte;
                              Code  :  Word;
                           end;
   SF_BuildPtr          =  ^SF_BuildArray;
   SF_BuildArray        =  Array[0..255] of SF_BuildRec;

Var
   SF_Literal           :  SF_Literal_Ptr;   { These are the 3 Shannon-Fano   }
   SF_Distance          :  SF_Distance_Ptr;  { trees that are used to implode }
   SF_Length            :  SF_Length_Ptr;    { a file.                        }
                                             
   NextFreeLiteral      :  Word;    { Free node pointers used while trees     }
   NextFreeLength       :  Word;    { are being constructed                   }
   NextFreeDistance     :  Word;

   SF_Build             :  SF_BuildPtr;      { Array used in building the     }
                                             { Shannon-Fano trees needed to   }
                                             { decode the imploded file       }

   SF_Build_Idx         :  Byte;    { Index var for SF_Build array            }

   NumOfTrees           :  Byte;    { the # of SF trees needed (2 or 3)       }
   MinMatchLen          :  Byte;    { minimum dictionary match length (2 or 3)}
      

{ --------------------------------------------------------------------------- }
implementation

uses SysUtils;

{function SetFTime(FileName: string; DateTime: TDateTime): Boolean;
var
  hFile: Integer;
begin
  hFile := FileOpen(FileName, fmOpenWrite);
  Result := hFile > 0;
  if Result then begin
    Result := FileSetDate(hFile, DateTimeToFileDate(DateTime)) = 0;
    FileClose(hFile)
  end
end;}

Procedure Abort(Msg : String);
Begin
   Writeln;
   Writeln(Msg);
   Writeln('Returning to DOS');
   Writeln;
   Halt;
end {Abort};

{ --------------------------------------------------------------------------- }

Procedure Syntax;
Begin
   Writeln('Usage:  DeZip ZipFileName [OutPathSpec] [FileSpec [...]]');
   Writeln;
   Writeln('Optional file specifications may contain DOS ');
   Writeln('wildcard characters.');
   Writeln;
   Writeln('If no filespecs are entered, *.* is assumed.');
   Writeln;
   Halt;
End;

{ --------------------------------------------------------------------------- }

Function HexLInt(L : LongInt) : String;
Type
   HexType  = Array [0..15] of Char;
Const
   HexChar : HexType = ('0','1','2','3','4','5','6','7',
                        '8','9','A','B','C','D','E','F');
Begin
   HexLInt  := HexChar[(L AND $F0000000) SHR 28] +
               HexChar[(L AND $0F000000) SHR 24] +
               HexChar[(L AND $00F00000) SHR 20] +
               HexChar[(L AND $000F0000) SHR 16] +
               HexChar[(L AND $0000F000) SHR 12] +
               HexChar[(L AND $00000F00) SHR  8] +
               HexChar[(L AND $000000F0) SHR  4] +
               HexChar[(L AND $0000000F)       ] +
               'h';
end {HexLInt};

{ --------------------------------------------------------------------------- }

Function IO_Test : Boolean;
Var
   ErrorCode   :  Word;
   CodeStr     :  String;
   Ok          :  Boolean;
Begin
   Ok := TRUE;
   ErrorCode := IOResult;
   If ErrorCode <> 0 then begin
      Ok := FALSE;
      Case ErrorCode of
           2 : Writeln('File Not Found');
           3 : Writeln('Path Not Found');
           5 : Writeln('Access Denied');
         101 : Writeln('Disk Full');
        else   Writeln('I/O Error # ', ErrorCode);
      end {Case};
   end {if};
   IO_Test := Ok;
end {IO_Test};

{ --------------------------------------------------------------------------- }

Procedure Initialize;
//Var
//   Code : Integer;
Begin
   GetMem(ZipBuf, SizeOf(ZipBuf^));
   GetMem(ExtBuf, SizeOf(ExtBuf^));
   {Code := GetMem(ZipBuf, SizeOf(ZipBuf^)) OR
           GetMem(ExtBuf, SizeOf(ExtBuf^));
   If Code <> 0 then
      Abort('Not enough memory available to allocate I/O buffers!');}
end {Initialize};

{ --------------------------------------------------------------------------- }

{ Converted to Turbo Pascal (tm) V4.0 March, 1988 by J.R.Louvau               }
{ COPYRIGHT (C) 1986 Gary S. Brown.  You may use this program, or             }
{ code or tables extracted from it, as desired without restriction.           }
{                                                                             }
{ First, the polynomial itself and its table of feedback terms.  The          }
{ polynomial is                                                               }
{ X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0         }
{                                                                             }
{ Note that we take it "backwards" and put the highest-order term in          }
{ the lowest-order bit.  The X^32 term is "implied"; the LSB is the           }
{ X^31 term, etc.  The X^0 term (usually shown as "+1") results in            }
{ the MSB being 1.                                                            }
{                                                                             }
{ Note that the usual hardware shift register implementation, which           }
{ is what we're using (we're merely optimizing it by doing eight-bit          }
{ chunks at a time) shifts bits into the lowest-order term.  In our           }
{ implementation, that means shifting towards the right.  Why do we           }
{ do it this way?  Because the calculated CRC must be transmitted in          }
{ order from highest-order term to lowest-order term.  UARTs transmit         }
{ characters in order from LSB to MSB.  By storing the CRC this way,          }
{ we hand it to the UART in the order low-byte to high-byte; the UART         }
{ sends each low-bit to hight-bit; and the result is transmission bit         }
{ by bit from highest- to lowest-order term without requiring any bit         }
{ shuffling on our part.  Reception works similarly.                          }
{                                                                             }
{ The feedback terms table consists of 256, 32-bit entries.  Notes:           }
{                                                                             }
{     The table can be generated at runtime if desired; code to do so         }
{     is shown later.  It might not be obvious, but the feedback              }
{     terms simply represent the results of eight shift/xor opera-            }
{     tions for all combinations of data and CRC register values.             }
{                                                                             }
{     The values must be right-shifted by eight bits by the "updcrc"          }
{     logic; the shift must be unsigned (bring in zeroes).  On some           }
{     hardware you could probably optimize the shift in assembler by          }
{     using byte-swap instructions.                                           }
{     polynomial $edb88320                                                    }
{                                                                             }

Function UpdC32(Octet: Byte; Crc: LongInt) : LongInt;
Var
   L : LongInt;
   W : Array[1..4] of Byte Absolute L;
Begin

   UpdC32 := CRC_32_TAB[Byte(Crc XOR LongInt(Octet))] XOR ((Crc SHR 8) AND $00FFFFFF);

end {UpdC32};

{ --------------------------------------------------------------------------- }

Procedure Read_Zip_Block;
Begin
//   BlockRead(ZipFile, ZipBuf^, BUFSIZE, ZipCount);
   BlockRead(ZipFile, ZipBuf, BUFSIZE, ZipCount);
   If ZipCount = 0 then
      EndFile := TRUE;
   ZipPtr := 1;
End {Read_Zip_Block};

{ --------------------------------------------------------------------------- }

Procedure Write_Ext_Block;
Begin
   If ExtPtr > 1 then begin
      BlockWrite(ExtFile, ExtBuf^, Pred(ExtPtr));
      If NOT IO_Test then
         Halt;
      ExtPtr := 1;
   end {if};
End {Write_Ext_Block};

{ --------------------------------------------------------------------------- }

Procedure Open_Zip;
Begin
   Assign(ZipFile, ZipName);
   FileMode := 64;  { Read Only / Deny None }
   {$I-} Reset(ZipFile, 1) {$I+};
   If NOT IO_Test then
      Halt;
   EndFile := FALSE;
   Read_Zip_Block;
End {Open_Zip};

{ --------------------------------------------------------------------------- }

Function Open_Ext : Boolean;
Begin
   Assign(ExtFile, OutPath + Hdr_FileName);
   FileMode := 66;  { Read & Write / Deny None }
   {$I-} Rewrite(ExtFile, 1) {$I+};
   If NOT IO_Test then
      Open_Ext := FALSE
   else begin
      ExtPtr := 1;
      Open_Ext := TRUE;
   end {if};
end {Open_Ext};

{ --------------------------------------------------------------------------- }

Function Get_Zip : Integer;
Begin
   If ZipPtr > ZipCount then
      Read_Zip_Block;

   If EndFile then
      Get_Zip := -1
   else begin
      Get_Zip := ZipBuf^[ZipPtr];
      Inc(ZipPtr);
   end {if};
end {Get_Zip};

{ --------------------------------------------------------------------------- }

Procedure Put_Ext(C : Byte);
Begin
   Crc32Val := UpdC32(C, Crc32Val);
   ExtBuf^[ExtPtr] := C;
   Inc(ExtPtr);
   Inc(ExtCount);
   If ExtPtr > BUFSIZE then
      Write_Ext_Block;
end {Put_Ext};

{ --------------------------------------------------------------------------- }

Procedure Close_Zip;
Begin
   {$I-} Close(Zipfile) {$I+};
   If IO_Test then ;
end {Close_Zip};

{ --------------------------------------------------------------------------- }

Procedure Close_Ext;
Type
   TimeDateRec = Record
                    Time : Word;
                    Date : Word;
                 end {record};
Var
   TimeDate      : TimeDateRec;
   TimeDateStamp : LongInt Absolute TimeDate;
Begin
   Write_Ext_Block;
   TimeDate.Time := LocalHdr.Last_Mod_Time;
   TimeDate.Date := LocalHdr.Last_Mod_Date;
//   SetFTime(ExtFile, TimeDateStamp);
   FileSetDate(TFileRec(ExtFile).Handle, DateTimeToFileDate(TimeDateStamp));
   {$I-} Close(ExtFile) {$I+};
   If IO_Test then ;
end {Close_Ext};

{ --------------------------------------------------------------------------- }

Procedure FSkip(Offset : LongInt);
Var
   Rec : LongInt;
Begin
   If (Offset + ZipPtr) <= ZipCount then
      Inc(ZipPtr, Offset)
   else begin
      Rec := FilePos(ZipFile) + (Offset - (ZipCount - ZipPtr) - 1);
      {$I-} Seek(ZipFile, Rec) {$I+};
      If NOT IO_Test then
         Halt;
      Read_Zip_Block;
   end {if};
end {FSkip};

{ --------------------------------------------------------------------------- }

Procedure FRead(Var Buf; RecLen : Word);
Var
   I  :  Word;
   B  :  Array[1..MaxInt] of Byte Absolute Buf;
Begin
   For I := 1 to RecLen do
      B[I] := Get_Zip;
end {FRead};

{ --------------------------------------------------------------------------- }

Function Read_Local_Hdr : Boolean;
Var
   Sig : LongInt;
Begin
   If EndFile then
      Read_Local_Hdr := FALSE
   else begin
      FRead(Sig, SizeOf(Sig));
      If Sig = CENTRAL_FILE_HEADER_SIGNATURE then begin
         Read_Local_Hdr := FALSE;
         EndFile        := TRUE;
      end {then}
      else begin
         If Sig <> LOCAL_FILE_HEADER_SIGNATURE then
            Abort('Missing or invalid local file header in ' + ZipName);
         FRead(LocalHdr, SizeOf(LocalHdr));
         With LocalHdr do begin
            If FileName_Length > 255 then
               Abort('Filename of compressed file exceeds 255 characters!');
//            FRead(Hdr_FileName[1], FileName_Length);
//            Hdr_FileName[0] := Chr(FileName_Length);
            FRead(Hdr_FileName[2], FileName_Length);
            Hdr_FileName[1] := Chr(FileName_Length);
            If Extra_Field_Length > 255 then
               Abort('Extra field of compressed file exceeds 255 characters!');
//            FRead(Hdr_ExtraField[1], Extra_Field_Length);
//            Hdr_ExtraField[0] := Chr(Extra_Field_Length);
            FRead(Hdr_ExtraField[2], Extra_Field_Length);
            Hdr_ExtraField[1] := Chr(Extra_Field_Length);
         end {with};
         Read_Local_Hdr := TRUE;
      end {if};
   end {if};
end {Read_Local_Hdr};

{ --------------------------------------------------------------------------- }

Function Get_Compressed : Integer;
Var
   PctDone : Integer;
Begin
   If Bytes_To_Go = 0 then
      Get_Compressed := -1
   else begin
      Get_Compressed := Get_Zip;
      If Bytes_To_Go mod TenPercent = 0 then begin
         PctDone := 100 - Round( 100 * (Bytes_To_Go / LocalHdr.Compressed_Size));
//         GotoXY(WhereX - 4, WhereY);
         Write(PctDone:3, '%');
      end {if};
      Dec(Bytes_To_Go);
   end {if};
end {Get_Compressed};

{ --------------------------------------------------------------------------- }

Function LZW_Init : Boolean;
Var
   RC       :  Word;
   I        :  Word;
Label
   Exit;
Begin
   { Initialize LZW Table }
   GetMem(LZW_Table, SizeOf(LZW_Table^));
   For I := 0 to LZW_TABLE_SIZE do begin
      With LZW_Table^[I] do begin
         Prefix     := -1;
         If I < 256 then
            Suffix  := I
         else
            Suffix  := 0;
         ChildCount := 0;
      end {with};
   end {for};

   GetMem(FreeList, SizeOf(FreeList^));
   For I := FIRSTFREE to LZW_TABLE_SIZE do
      FreeList^[I] := I;
   NextFree := FIRSTFREE;

   { Initialize the LZW Character Stack }
   GetMem(LZW_Stack, SizeOf(LZW_Stack^));
   StackIdx := 0;
   LZW_Init := TRUE;

Exit:
end {LZW_Init};

{ --------------------------------------------------------------------------- }

Procedure LZW_Cleanup;
Var
   Code : Word;
Begin
   Dispose(LZW_Table);
   Dispose(FreeList);
   Dispose(LZW_Stack);
end {LZW_Cleanup};

{ --------------------------------------------------------------------------- }

Procedure Clear_LZW_Table;
Var
   I      :  Word;
Begin
   StackIdx := 0;

   For I := FIRSTFREE to LZW_TABLE_SIZE do begin      { Find all leaf nodes }
      If LZW_Table^[I].ChildCount = 0 then begin
         LZW_Stack^[StackIdx] := I;                   { and put each on stack }
         Inc(StackIdx);
      end {if};
   end {for};

   NextFree := Succ(LZW_TABLE_SIZE);

   While StackIdx > 0 do begin                        { clear all leaf nodes }
      Dec(StackIdx);
      I := LZW_Stack^[StackIdx];
      With LZW_Table^[I] do begin
         If LZW_Table^[I].Prefix <> -1 then
            Dec(LZW_Table^[Prefix].ChildCount);
         Prefix     := -1;
         Suffix     :=  0;
         ChildCount :=  0;
      end {with};
      Dec(NextFree);                         { add cleared nodes to freelist }
      FreeList^[NextFree] := I;
   end {while};

End {Clear_LZW_Table};

{ --------------------------------------------------------------------------- }

Procedure Add_To_LZW_Table(Prefix : Integer; Suffix : Byte);
Var
   I  :  Word;
Begin

   If NextFree <= LZW_TABLE_SIZE then begin
      I := FreeList^[NextFree];
      Inc(NextFree);
      LZW_Table^[I].Prefix     := Prefix;
      LZW_Table^[I].Suffix     := Suffix;
      Inc(LZW_Table^[Prefix].ChildCount);
   end {if};

End {Add_To_LZW_Table};

{ --------------------------------------------------------------------------- }

Function GetCode(CodeSize : Byte) : Integer;
Const
   Mask       :  Array[1..8] of Byte = ($01, $03, $07, $0F, $1F, $3F, $7F, $FF);
   TmpInt     : Integer = 0;
Var
   BitsNeeded : Byte;
   HowMany    : Byte;
   HoldCode   : Integer;
Label
   Exit;
Begin
   If FirstCh then begin               { If first time through ...         }
      TmpInt := Get_Compressed;        { ... then prime the code buffer    }
      If TmpInt = -1 then begin        { If EOF on fill attempt ...        }
         GetCode := -1;           { ... then return EOF indicator ... }
         Goto Exit;                    { ... and return to caller.         }
      end {if};
      SaveByte := TmpInt;
      BitsLeft := 8;                   { there's now 8 bits in our buffer  }
      FirstCh  := FALSE;
   end {if};

   BitsNeeded := CodeSize;
   HoldCode   := 0;

   While (BitsNeeded > 0) And (TmpInt <> -1) do begin

      If BitsNeeded >= BitsLeft
         then HowMany := BitsLeft         { HowMany <-- Min(BitsLeft, BitsNeeded) }
         else HowMany := BitsNeeded;

      HoldCode := HoldCode OR ((SaveByte AND Mask[HowMany]) SHL (CodeSize - BitsNeeded));
      SaveByte := SaveByte SHR HowMany;
      Dec(BitsNeeded, HowMany);
      Dec(BitsLeft, HowMany);

      If BitsLeft <= 0 then begin         { If no bits left in buffer ...     }
         TmpInt := Get_Compressed;        { ... then attempt to get 8 more.   }
         If TmpInt = -1 then
            Goto Exit;
         SaveByte := TmpInt;
         BitsLeft := 8;
      end {if};

   end {while};

Exit:

   If (BitsNeeded = 0) then               { If we got what we came for ... }
      GetCode := HoldCode            { ... then return it             }
   else
      GetCode := -1;                 { ... Otherwise, return EOF      }

end {GetCode};

{ --------------------------------------------------------------------------- }

Procedure UnShrink;
Var
   Ch       :  Char;
   CodeSize :  Byte;          { Current size (in bits) of codes coming in  }
   CurrCode :  Integer;
   SaveCode :  Integer;
   PrevCode :  Integer;
   BaseChar :  Byte;
Label
   Exit;
Begin
   CodeSize := MINCODESIZE;               { Start with the smallest code size }

   PrevCode := GetCode(CodeSize);        { Get first code from file          }
   If PrevCode = -1 then                  { If EOF already, then ...          }
      Goto Exit;                          { ... just exit without further ado }
   BaseChar := PrevCode;
   Put_Ext(BaseChar);                      { Unpack the first character        }

   CurrCode := GetCode(CodeSize);        { Get next code to prime the while loop }

   While CurrCode <> -1 do begin          { Repeat for all compressed bytes   }

      If CurrCode = SPECIAL then begin    { If we've got a "special" code ... }

         CurrCode := GetCode(CodeSize);
         Case CurrCode of
            1  :  Begin                   { ... and if followed by a 1 ...    }
                     Inc(CodeSize);       { ... then increase code size       }
                  end {1};
            2  :  Begin                   { ... and if followed by a 2 ...    }
                     Clear_LZW_Table;     { ... clear leaf nodes in the table }
                  end {2};
            else  begin                   { ... if neither 1 or 2, discard    }
                     Writeln;
                     Writeln('Encountered code 256 not followed by 1 or 2!');
                     Writeln;
                     Write('Press a key to continue ...');
                     Ch := ReadKey;
                     DelLine;
                     GotoXY(1, WhereY);
                  end {else};
         end {case};

      end {then}
      else begin                          { Not a "special" code              }

         SaveCode := CurrCode;            { Save this code someplace safe...  }

         If CurrCode > LZW_TABLE_SIZE then
            Abort('Invalid code encountered!');

         If (CurrCode >= FIRSTFREE) and (LZW_Table^[CurrCode].Prefix = -1) then begin
            If StackIdx > LZW_STACK_SIZE then begin
               Write_Ext_Block;
               Writeln;
               Writeln('Stack Overflow (', StackIdx, ')!');
               Halt;
            end {if};
            LZW_Stack^[StackIdx] := BaseChar;
            Inc(StackIdx);
            CurrCode := PrevCode;
         end {if};

         While CurrCode >= FIRSTFREE do begin
            If StackIdx > LZW_STACK_SIZE then begin
               Write_Ext_Block;
               Writeln;
               Writeln('Stack Overflow (', StackIdx, ')!');
               Halt;
            end {if};
            LZW_Stack^[StackIdx] := LZW_Table^[CurrCode].Suffix;
            Inc(StackIdx);
            CurrCode := LZW_Table^[CurrCode].Prefix;
         end {while};

         BaseChar := LZW_Table^[CurrCode].Suffix;         { Get last character ...   }
         Put_Ext(BaseChar);

         While (StackIdx > 0) do begin
            Dec(StackIdx);
            Put_Ext(LZW_Stack^[StackIdx]);
         end {while};                     { ... until there are none left     }

         Add_to_LZW_Table(PrevCode, BaseChar);  { Add new entry to table      }

         PrevCode := SaveCode;

      end {if};

      CurrCode := GetCode(CodeSize);     { Get next code from input stream   }

   end {while};
Exit:
end {UnShrink};

{ --------------------------------------------------------------------------- }

Function Init_UnReduce : Boolean;
Var
   Code : Word;
Label
   Exit;
Begin
   Code := Malloc(Followers, SizeOf(Followers^));
   If Code <> 0 then begin
      Init_UnReduce := FALSE;
      Goto Exit;
   end {if};

   DictSize := 4096;
   Code := Malloc(Dictionary, DictSize);
   If Code <> 0 then begin
      Init_UnReduce := FALSE;
      Goto Exit;
   end {if};

   Init_UnReduce := TRUE;

Exit:
end {Init_UnReduce};

{ --------------------------------------------------------------------------- }

Procedure Cleanup_UnReduce;
Var
   Code : Word;
Begin
   Code := Dalloc(Followers);
   Code := Dalloc(Dictionary);
end {Cleanup_UnReduce};

{ --------------------------------------------------------------------------- }

Function D(X, Y : Byte) : Word;
Var
   tmp : LongInt;
Begin
   X := X SHR (8 - Pred(LocalHdr.Compress_Method));
   Tmp := X * 256;
   D := Tmp + Y + 1;
end {D};

{ --------------------------------------------------------------------------- }

Function F(X : Word) : Byte;
Const
   TestVal : Array[1..4] of Byte = (127, 63, 31, 15);
Begin
   If X = TestVal[Pred(LocalHdr.Compress_Method)] then
      F := 2
   else
      F := 3;
end {F};

{ --------------------------------------------------------------------------- }

Function L(X : Byte) : Byte;
Const
   Mask : Array[1..4] of Byte = ($7F, $3F, $1F, $0F);
Begin
   L := X AND Mask[Pred(LocalHdr.Compress_Method)];
end {L};

{ --------------------------------------------------------------------------- }

Procedure UpdateDictionary(C : Byte);
Begin
   Put_Ext(C);
   Dictionary^[DictIdx] := C;
   DictIdx := Succ(DictIdx) MOD DictSize;
end {UpdateDictionary};

{ --------------------------------------------------------------------------- }

Procedure DictionaryInit;
Begin
   State := 0;
   FillChar(Dictionary^[0], DictSize, $00);
   DictIdx := 0;
end {DictionaryInit};

{ --------------------------------------------------------------------------- }

Procedure UnScrnch(C : Byte);
Const
   DLE   =  $90;
Var
   S           :  Integer;
   Count       :  Word;
   OneByte     :  Byte;
   Tmp1        :  LongInt;
Begin
   Case State of
      0  :  begin
               If C = DLE then
                  State := 1
               else
                  UpdateDictionary(C);
            end {0};
      1  :  begin
               If C = 0 then begin
                  UpdateDictionary(DLE);
                  State := 0;
               end {then}
               else begin
                  V     := C;
                  Len   := L(V);
                  State := F(Len);
               end {if};
            end {1};
      2  :  begin
               Inc(Len, C);
               State := 3;
            end {2};
      3  :  begin
               Tmp1 := D(V, C);
               S    := DictIdx - Tmp1;
               If S < 0 then
                  S := S + DictSize;
               Count := Len + 3;
               While Count > 0 do begin
                  OneByte := Dictionary^[S];
                  UpdateDictionary(OneByte);
                  S := Succ(S) MOD DictSize;
                  Dec(Count);
               end {while};
               State := 0;
            end {3};
   end {case};

end {UnScrnch};

{ --------------------------------------------------------------------------- }

Function MinBits(Val : Byte) : Byte;
Begin
   Dec(Val);
   Case Val of
       0..1  : MinBits := 1;
       2..3  : MinBits := 2;
       4..7  : MinBits := 3;
       8..15 : MinBits := 4;
      16..31 : MinBits := 5;
      else     MinBits := 6;
   end {case};
end {MinBits};

{ --------------------------------------------------------------------------- }

Procedure UnReduce;
Var
   LastChar    :  Byte;
   N           :  Byte;
   I, J        :  Word;
   Code        :  Integer;
   Ch          :  Char;
Begin
   For I := 255 downto 0 do begin          { Load follower sets }
      N := GetCode(6);                { Get size of 1st set }
      Followers^[I].SetSize := N;
      If N > 0 then
         For J := 0 to Pred(N) do
            Followers^[I].FSet[J] := GetCode(8);
   end {for};

   DictionaryInit;

   LastChar := 0;
   Repeat

      If Followers^[LastChar].SetSize = 0 then begin
         Code := GetCode(8);
         UnScrnch(Code);
         LastChar := Code;
      end {then}
      else begin
         Code := GetCode(1);
         If Code <> 0 then begin
            Code := GetCode(8);
            UnScrnch(Code);
            LastChar := Code;
         end {then}
         else begin
            I := MinBits(Followers^[LastChar].SetSize);
            Code := GetCode(I);
            UnScrnch(Followers^[LastChar].FSet[Code]);
            LastChar := Followers^[LastChar].FSet[Code];
         end {if};
      end {if};
   Until (ExtCount = LocalHdr.Uncompressed_Size);
   Code := Dalloc(Followers);
end {UnReduce};

{ --------------------------------------------------------------------------- }

Function Init_Explode : Boolean;
{ Get ready to unimplode                                                      }
Var
   Failure : Boolean;
   RC      : Word;
Begin
   Failure := FALSE;

   { Extract pertinent info from the general purpose bit flag                 }
   DictSize    := (((LocalHdr.Bit_Flag SHR 1) and $01) * 4096) + 4096;
   NumOfTrees  := (( LocalHdr.Bit_Flag SHR 2) and $01) + 2;
   MinMatchLen := NumOfTrees;

   { Allocate memory for the Length & Distance Shannon-Fano trees             }
   RC  :=  Malloc(SF_Length,   SizeOf(SF_Length^))      +
           Malloc(SF_Distance, SizeOf(SF_Distance^));
   Failure := Failure or (RC <> 0);

   { Initialize Length & Distance nodes to all -1's and set the Next Free     }
   { Node pointers for each                                                   }
   FillChar(SF_Length^,   SizeOf(SF_Length^),   $FF);
   NextFreeLength   := Pred(LENGTH_TREE_ROOT);
   FillChar(SF_Distance^, SizeOf(SF_Distance^), $FF);
   NextFreeDistance := Pred(DISTANCE_TREE_ROOT);

   { If we need a literal tree, then allocate the memory , initialize the     }
   { nodes to all -1's, and set the Next Free Node pointer                    }
   If NumOfTrees = 3 then begin
      RC := Malloc(SF_Literal,  SizeOf(SF_Literal^));
      Failure := Failure or (RC <> 0);
      FillChar(SF_Literal^, SizeOf(SF_Literal^), $FF);
      NextFreeLiteral := Pred(LITERAL_TREE_ROOT);
   end {if};

   { Allocate memory for the sliding dictionary                               }
   RC := Malloc(Dictionary,  DictSize);
   Failure := Failure or (RC <> 0);

   { Allocate memory for the array used in building the SF-Trees              }
   RC := Malloc(SF_Build,    SizeOf(SF_Build^));
   Failure := Failure or (RC <> 0);

   { If any memory allocations failed, deallocate any memory that may have    }
   { been successfully allocated.                                             }
   If Failure then
      RC       := Dalloc(SF_Length)    +
                  Dalloc(SF_Distance)  +
                  Dalloc(SF_Literal)   +
                  Dalloc(Dictionary)   +
                  Dalloc(SF_Build);

   { Return either success or failure }
   Init_Explode := NOT Failure;
end { Init_Explode };

{ --------------------------------------------------------------------------- }

Procedure Cleanup_Explode;
{ Clean things up after unimploding a file }
Var
   RC :  Word;
Begin
   RC := Dalloc(SF_Length)    +
         Dalloc(SF_Distance)  +
         Dalloc(SF_Literal)   +
         Dalloc(Dictionary)   +
         Dalloc(SF_Build);
end { Cleanup_Explode };

{ --------------------------------------------------------------------------- }

Procedure Bad_SF_Tree;
Begin
   Writeln;
   Abort('Ambiguous Shannon-Fano decode tree encountered!');
end { Bad_SF_Tree };

{ --------------------------------------------------------------------------- }

Procedure Add_SF_SubTree( Var SF_Tree;
                          Var SF_NextFree     : Word;
                              SF_Root         : Word;
                              SF_Code         : Word;
                              SF_Code_Length  : Byte;
                              SF_Value        : Byte
                         );
{ Add the subtree defined by SF_Code to a Shannon-Fano tree                   }
Var
   SF_Array :  Array [0..MAX_SF_TREE_SIZE] of SF_Node absolute SF_Tree;
   CurrNode :  Word;
   LastLeaf :  Word;
   I        :  Byte;
Begin

   { The Shannon-Fano tree is implemented as an array of records. Each        }
   { record contains both left and right pointers (ie. this is a binary       }
   { tree).  The root of the tree is the last array element. The first N      }
   { elements (0..N-1) are defined to be the "leaves" of the tree (ie. they   }
   { represent the characters that the decode algorithm will generate).  N    }
   { may be 64 (for the length tree), 128 (for the distance tree), or 256     }
   { (for the Literal tree). The remaining elements of the array are used to  }
   { represent the non-leaf and non-root nodes of the tree.                   }

   CurrNode := SF_Root;
   LastLeaf := Pred(Succ(SF_Root) DIV 2);

   { All bits in the code except the least significant define non-leaf nodes  }
   { in the tree.  Process these first.                                       }

   For I := Pred(SF_Code_Length) downto 1 do begin
      If CurrNode <= LastLeaf then
         Bad_SF_Tree;
      If Boolean((SF_Code SHR I) AND $0001) then begin   { if the bit is a 1  }
         If SF_Array[CurrNode].RChild = -1 then begin    { no RChild yet      }
            SF_Array[CurrNode].RChild := SF_NextFree;
            Dec(SF_NextFree);
         end {if};
         CurrNode := SF_Array[CurrNode].RChild;       { on 1 bits, follow the }
                                                      { right subtree         }
      end { then }
      else begin                                         { the bit is a 0     }
         If SF_Array[CurrNode].LChild = -1 then begin    { no LChild yet      }
            SF_Array[CurrNode].LChild := SF_NextFree;
            Dec(SF_NextFree);
         end {if};
         CurrNode := SF_Array[CurrNode].LChild;       { on 0 bits, follow the }
                                                      { left subtree          }
      end { if };
   end { for };

   { All that's left now is to process the least significant bit of the code. }
   { This will define a leaf node.  The leaf node to be linked is defined by  }
   { the SF_Value that is passed to the procedure.                            }

   If Boolean(SF_Code AND $0001) then
      If SF_Array[CurrNode].RChild <> -1 then
         Bad_SF_Tree
      else
         SF_Array[CurrNode].RChild := SF_Value
   else
      If SF_Array[CurrNode].LChild <> -1 then
         Bad_SF_Tree
      else
         SF_Array[CurrNode].LChild := SF_Value;

end { Add_SF_SubTree };

{ --------------------------------------------------------------------------- }

Procedure Sort_SF_Build_Array( Count : Word );

   Procedure Exchange(Var Node1, Node2 : SF_BuildRec);
   Var
      Node3 : SF_BuildRec;
   Begin
      Node3.Len  := Node1.Len;
      Node3.Val  := Node1.Val;
    { Node3.Code := Node1.Code; }   { the Code field is irrelevant at this point }

      Node1.Len  := Node2.Len;
      Node1.Val  := Node2.Val;
    { Node1.Code := Node2.Code; }   { ditto }

      Node2.Len  := Node3.Len;
      Node2.Val  := Node3.Val;
    { Node2.Code := Node3.Code; }   { ditto again }
   end { Exchange };

   function ShouldSwap( P1, P2 : SF_BuildRec ) : Boolean;
   begin
      If  (P1.Len > P2.Len)  or
         ((P1.Len = P2.Len)  and
          (P1.Val > P2.Val))
      then
         ShouldSwap := TRUE
      else
         ShouldSwap := FALSE;
   end { ShouldSwap };

   procedure sort(lb, ub : integer);

   (***** BUBBLE SORT **************************************************)

   (*  The list is scanned repeatedly, and adjacent items that are out of
       order are swapped.  When a pass occurs with no swaps, the list is
       sorted.  *)

   var
      swapped : boolean;
      cell    : integer;
   begin
       repeat
           swapped := false;
           for cell := lb to ub - 1 do
           begin
               if ShouldSwap(SF_Build^[cell], SF_Build^[cell + 1]) then
               begin
                   Exchange(SF_Build^[cell], SF_Build^[cell + 1]);
                   swapped := true;
               end;
           end;
       until (swapped = false);
   end;

Begin
   Sort(0, Count);
end { Sort_SF_Build_Array };

{ --------------------------------------------------------------------------- }

Procedure Build_SF_Trees;
{ Extract SF data from an imploded file and build the required SF trees }
Var
   OneByte              :  Byte;    { These "misc" variables are also used in }
   CodeLen              :  Byte;    { building the SF trees                   }
   CodeCount            :  Byte;

   SF_Table_Codes       :  Word;    { # of bytes representing SF tree data - 1}
   BuildCount           :  Word;    { total entries in SF_Build array         }

   Code                 :  Word;    { These three variables used in           }
   CodeIncrement        :  Word;    { constructing the Shannon-Fano codes     }
   LastBitLength        :  Word;    { that will be used to build the SF trees }

   WhichTree            :  Word;    { Counter indicating which SF tree is     }
                                    {   currently under construction          }
   SF_Tree              :  Pointer;
   SF_NextFree          :  Word;
   SF_Root              :  Word;

   I, J                 :  Word;    { Generic loop counter                    }

Begin

   For WhichTree := 1 to NumOfTrees do begin
      { Before we go any further, determine which subtree-add procedure       }
      { parameters will be needed on the call to Add_SF_SubTree               }
      Case NumOfTrees of
         2  :  Case WhichTree of
                  1  :  Begin
                           SF_Tree     := SF_Length;
                           SF_NextFree := NextFreeLength;
                           SF_Root     := LENGTH_TREE_ROOT;
                        end { 1 };
                  2  :  Begin
                           SF_Tree     := SF_Distance;
                           SF_NextFree := NextFreeDistance;
                           SF_Root     := DISTANCE_TREE_ROOT;
                        end { 2 };
               end { case whichtree };
         3  :  Case WhichTree of
                  1  :  Begin
                           SF_Tree     := SF_Literal;
                           SF_NextFree := NextFreeLiteral;
                           SF_Root     := LITERAL_TREE_ROOT;
                        end { 1 };
                  2  :  Begin
                           SF_Tree     := SF_Length;
                           SF_NextFree := NextFreeLength;
                           SF_Root     := LENGTH_TREE_ROOT;
                        end { 2 };
                  3  :  Begin
                           SF_Tree     := SF_Distance;
                           SF_NextFree := NextFreeDistance;
                           SF_Root     := DISTANCE_TREE_ROOT;
                        end { 3 };
               end { case whichtree };
      end { case numoftrees };

      { Build the Shannon-Fano tree                                           }
      SF_Build_Idx   := 0;
      BuildCount     := 0;
      SF_Table_Codes := GetCode(8);
      For I := 0 to SF_Table_Codes do begin
         { Load the SF_Build array with data from the compressed file         }
         OneByte     := GetCode(8);
         CodeLen     := (OneByte AND $0F) + 1;
         CodeCount   := (OneByte SHR 4);
         For J := 0 to CodeCount do begin
            SF_Build^[SF_Build_Idx].Len  := CodeLen;
            SF_Build^[SF_Build_Idx].Val  := SF_Build_Idx;
            Inc(SF_Build_Idx);
         end { for J };
      end { for I };
      BuildCount := Pred(SF_Build_Idx);

      { Sort the SF_Build Array based on the Len field                        }
      Sort_SF_Build_Array(BuildCount);

      { Generate the SF codes that will be used to grow the SF tree using the }
      { algorithm outlined in the AppNote.Txt file (as distributed within the }
      { PKZip v1.0 self extracting ZIP archive).                              }
      Code           := 0;
      CodeIncrement  := 0;
      LastBitLength  := 0;
      For I := BuildCount downto 0 do begin
         Inc(Code, CodeIncrement);
         If SF_Build^[I].Len <> LastBitLength then begin
            LastBitLength := SF_Build^[I].Len;
            CodeIncrement := 1 SHL (16 - LastBitLength);
         end {if};
         SF_Build^[I].Code := Code SHR (16 - SF_Build^[I].Len);

         { Ok, we've got a value and a code.  This represents a subtree in    }
         { the Shannon-Fano tree structure.  Add it to the appropriate tree.  }
         Add_SF_SubTree(   SF_Tree^,
                           SF_NextFree,
                           SF_Root,
                           SF_Build^[I].Code,
                           SF_Build^[I].Len,
                           SF_Build^[I].Val     );

      end { for buildcount };

   end { for whichtree };

end { Build_SF_Trees };

{ --------------------------------------------------------------------------- }

Procedure Bad_SF_Data;
Begin
   Writeln;
   Abort('Bad Shannon-Fano code encountered in file!')
end { Bad_SF_Tree };

{ --------------------------------------------------------------------------- }

Function Decode_SF_Data( Var SF_Tree;
                             SF_Root : Word
                        ) : Byte;
{ Read bits from the input file and decode them using one of the 3 possible   }
{ Shannon-Fano trees.  The method is idential to that used in decoding files  }
{ encoded with the Huffman method (popularaly known as "squeezing") in that   }
{ the tree is traced from the root to either the right or left depending on   }
{ the last bit read until finally, one encounteres a leaf node.               }
Var
   SF_Array :  Array [0..MAX_SF_TREE_SIZE] of SF_Node absolute SF_Tree;
   OneBit   :  Byte;
   CurrNode :  Word;
   LastLeaf :  Word;
Begin

   CurrNode := SF_Root; { We start traversing the tree from it's root node    }
   LastLeaf := Pred(Succ(SF_Root) DIV 2);

   While CurrNode > LastLeaf do begin
      { Walk the tree until you hit a leaf node                               }
      OneBit := GetCode(1);
      If Boolean(OneBit and $01) then        { if the bit is a 1 ...          }
         If SF_Array[CurrNode].RChild = -1 then
            Bad_SF_Data
         else
            CurrNode := SF_Array[CurrNode].RChild
      else
         If SF_Array[CurrNode].LChild = -1 then
            Bad_SF_Data
         else
            CurrNode := SF_Array[CurrNode].LChild
   end { while };

   Decode_SF_Data := CurrNode;
end { Decode_SF_Data };

{ --------------------------------------------------------------------------- }

Procedure Explode;
Var
   OneByte     :  Byte;
   Literal     :  Byte;
   Length      :  Word;
   DistVal     :  Word;
   Distance    :  Word;
   DictStart   :  Integer;
Begin

   Build_SF_Trees;
   DictionaryInit;

   Repeat
      OneByte := GetCode(1);
      If OneByte <> 0 then begin
         { This is literal data ... no dictionary lookup involved          }
         If NumOfTrees = 3 then
            Literal := Decode_SF_Data(SF_Literal^, LITERAL_TREE_ROOT)
         else
            Literal := GetCode(8);
         UpdateDictionary(Literal);
      end { then }
      else begin
         { Data for output will come from the sliding dictionary           }
         If DictSize = 8192 then begin
            Distance := GetCode(7);
            DistVal  := Decode_SF_Data(SF_Distance^, DISTANCE_TREE_ROOT);
            Distance := (Distance OR (DistVal SHL 7)) AND $1FFF;
         end {then}
         else begin
            Distance := GetCode(6);
            DistVal  := Decode_SF_Data(SF_Distance^, DISTANCE_TREE_ROOT);
            Distance := (Distance OR (DistVal SHL 6)) AND $0FFF;
         end {if};

         Length   := Decode_SF_Data( SF_Length^, LENGTH_TREE_ROOT );
         If Length = 63 then
            Length := Length + GetCode(8);
         Length := Length + MinMatchLen;

         DictStart := DictIdx - (Distance + 1);
         If DictStart < 0 then
            DictStart := DictStart + DictSize;

         While Length > 0 do begin
            UpdateDictionary(Dictionary^[DictStart]);
            DictStart := Succ(DictStart) MOD DictSize;
            Dec(Length);
         end {while};
      end {if};

   Until (ExtCount >= LocalHdr.Uncompressed_Size);

end { Explode };

{ --------------------------------------------------------------------------- }

Procedure UnZip;
Var
   C  :  Integer;
Begin
   Crc32Val    := $FFFFFFFF;
   Bytes_To_Go := LocalHdr.Compressed_Size;
   FirstCh     := TRUE;

   ExtCount    := 0;

   TenPercent := LocalHdr.Compressed_Size DIV 10;
   If TenPercent = 0 then TenPercent := 1;

   Case LocalHdr.Compress_Method of
      0     :  Begin
                  While Bytes_to_go > 0 do
                     Put_Ext(Get_Compressed);
               end {0 = Stored};
      1     :  Begin
                  If LZW_Init then
                     UnShrink
                  else begin
                     Writeln('Not enough memory available to unshrink!');
                     Writeln('Skipping ', Hdr_FileName, ' ...');
                     FSkip(LocalHdr.Compressed_Size);
                     Crc32Val := NOT LocalHdr.Crc32;
                  end {if};
                  LZW_Cleanup;
               end {1 = shrunk};
      2..5  :  Begin
                  If Init_UnReduce then
                     UnReduce
                  else begin
                     Writeln('Not enough memory available to unreduce!');
                     Writeln('Skipping ', Hdr_FileName, ' ...');
                     FSkip(LocalHdr.Compressed_Size);
                     Crc32Val := NOT LocalHdr.Crc32;
                  end {if};
                  Cleanup_UnReduce;
               end {2..5};
         6  :  Begin
                  If Init_Explode then
                     Explode
                  else begin
                     Writeln('Not enough memory available to unimplode!');
                     Writeln('Skipping ', Hdr_FileName, ' ...');
                     FSkip(LocalHdr.Compressed_Size);
                     Crc32Val := NOT LocalHdr.Crc32;
                  end {if};
                  Cleanup_Explode;
               end {6};
      else     Begin
                  Writeln('Unknown compression method used on ', Hdr_FileName);
                  Writeln('Skipping ', Hdr_FileName, ' ...');
                  FSkip(LocalHdr.Compressed_Size);
                  Crc32Val := NOT LocalHdr.Crc32;
               end {else};
   end {case};

   Crc32Val := NOT Crc32Val;
   If Crc32Val <> LocalHdr.Crc32 then begin
      Writeln;
      Writeln('WARNING: File ', OutPath + Hdr_FileName, ' fails CRC check!');
      Writeln('   Stored CRC = ', HexLInt(LocalHdr.Crc32),
              '   Calculated CRC = ', HexLInt(Crc32Val));
   end {if};

end {UnZip};

{ --------------------------------------------------------------------------- }

Procedure Extract_File;
Var
   YesNo  : Char;
   DosDTA : SearchRec;
Label
   Exit;
Begin
   FindFirst(OutPath + Hdr_FileName, ANYFILE, DosDTA);
   If DosError = 0 then begin
      Write('WARNING: ', OutPath + Hdr_FileName, ' already exists.  Overwrite (Y/N)? ');
      YesNo := ReadKey;
      Writeln(YesNo);
      If UpCase(YesNo) <> 'Y' then begin
         FSkip(LocalHdr.Compressed_Size);
         Goto Exit;
      end {if};
   end {if};

   If Open_Ext then begin
      Write('Extracting: ', OutPath + Hdr_FileName, ' ...    ');
      UnZip;
      GotoXY(WhereX - 4, WhereY);
      ClrEol;
      Writeln(' done');
      Close_Ext;
   end {then}
   else begin
      Writeln('Could not open output file ', OutPath + Hdr_FileName, '!  Skipping to next file ...');
      FSkip(LocalHdr.Compressed_Size);
   end {If};
Exit:
end {Extract_File};

{ --------------------------------------------------------------------------- }

Procedure Extract_Zip;
Var
   Match : Boolean;
   I     : Word;
Begin
   Open_Zip;
   While Read_Local_Hdr do begin
      Match := FALSE;
      I := 1;
      Repeat
         If SameFile(InFileSpecs[I], Hdr_FileName) then
            Match := TRUE;
         Inc(I);
      Until Match or (I > MaxSpecs);
      If Match then
         Extract_File
      else
         FSkip(LocalHdr.Compressed_Size);
   end {while};
   Close_Zip;
end;

{ --------------------------------------------------------------------------- }

Begin
   Assign(Output, '');
   Rewrite(Output);
   Writeln;
   Writeln(COPYRIGHT);
   Writeln(VERSION);
   Writeln;
   Load_Parms;   { get command line parameters }
   Initialize;   { one-time initialization }
   Extract_Zip;  { de-arc the file }
end.
