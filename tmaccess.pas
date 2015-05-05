unit tmAccess;
interface
uses tma_defs, Windows;
var
    hf_l:     LongInt = $7f7fffff;
    huge_flt: Single absolute hf_l;

function String2Utime(DateTime: PAnsiChar): Integer;
         stdcall; external 'tmaccess.dll' name '_String2Utime@4';
function tmInit(ServerName, LocalName: PAnsiChar): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmInit@8';
function tmClose: SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmClose@0';
function tmSystemTime( DateTime:PAnsiChar; Dummy: LongInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmSystemTime@8';
function tmRetroInfo(var RetroInfo: TRetroInfo): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmRetroInfo@4'
function tmRetroInfoEx(idx:Word; var rinfo:TRetroInfoEx):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmRetroInfoEx@8';

function tmStatus(Ch, RTU, Point: SmallInt):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmStatus@12';
function tmStatusFull(Ch, RTU, Point: SmallInt; SP: pSP):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmStatusFull@16';

function tmAnalog(Ch, RTU, Point: SmallInt;
                  Time: PAnsiChar; RetroNum: SmallInt): Single;
{         stdcall; external 'tmaccess.dll' name '_tmAnalog@24'}
function tmAnalogFull(Ch, RTU, Point: SmallInt; AP: pAP;
                  Time: PAnsiChar; RetroNum: SmallInt):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmAnalogFull@24';
function tmAccumFull(Ch, RTU, Point: SmallInt; AcP: pAcP;
                  Time: PAnsiChar):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmAccumFull@20';
function tmEventLog( StartTime, EndTime: PAnsiChar;
                     EvMask: Word; EvLog: pEV;
                     Cpct:Word; var Cursor: LongInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmEventLog@24';

function tmPeekAlarm(Ch, RTU, Point, AlarmID: SmallInt; Alarm: pAL):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmPeekAlarm@20';
function tmPokeAlarm(Ch, RTU, Point, AlarmID: SmallInt; Alarm: pAL):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmPokeAlarm@20';
function tmEnumAlarms(Ch, RTU, Point: SmallInt; Alarm: pAL;
                      MaxQuan, ActiveOnly: SmallInt):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmEnumAlarms@24';
function tmCheckForDatagram(Buf: PAnsiChar; MaxBytes, TimeOut: Integer): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmCheckForDatagram@12';
function tmDriverCall(ADR: Integer; Q_Code, Command: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmDriverCall@12';

procedure tmStatusByList(Quan: SmallInt; List: pADRtm; SPs:   pSP);
         stdcall; external 'tmaccess.dll' name '_tmStatusByList@12';
function tmStatusByListEx(Quan: SmallInt; List: pADRtm; SPs: pSP; Time: PAnsiChar): Integer;
         stdcall; external 'tmaccess.dll' name '_tmStatusByListEx@16';
procedure tmAnalogByList(Quan: SmallInt; List: pADRtm; APs:   pAP;
                         Time: PAnsiChar; RetroNum: SmallInt);
         stdcall; external 'tmaccess.dll' name '_tmAnalogByList@20';
procedure tmAccumByList(Quan: SmallInt;  List: pADRtm; AcPs: pAcP; Time: Integer);
         stdcall; external 'tmaccess.dll' name '_tmAccumByList@16';

function tmSetAnalog(Ch, RTU, Point: SmallInt; Value: Single; Time: PAnsiChar): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmSetAnalog@20';
function tmSetAnalogByCode(Ch, RTU, Point: SmallInt; Value: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmSetAnalogByCode@16';
function tmFillAnalogGroup(Ch, RTU, Point: SmallInt; Quan: SmallInt; AGroup: Pointer): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmFillAnalogGroup@20';

function tmSetStatus(Ch, RTU, Point: SmallInt; Value: Byte; Time: PAnsiChar; Hund: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmSetStatus@24';
function tmFillStatusGroup(Ch, RTU, Point: SmallInt; Quan: SmallInt; SGroup: Pointer): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmFillStatusGroup@20';

function tmSetAnalogFlags(Ch, RTU, Point, Flags: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmSetAnalogFlags@16';
function tmClrAnalogFlags(Ch, RTU, Point, Flags: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmClrAnalogFlags@16';
function tmSetStatusFlags(Ch, RTU, Point, Flags: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmSetStatusFlags@16';
function tmClrStatusFlags(Ch, RTU, Point, Flags: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmClrStatusFlags@16';
function tmRegEvent(Event:  pEV): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmRegEvent@4';

function tmEnumObjects( ObjectType: WORD; count: BYTE; var buf: WORD; Ch, RTU, Point: WORD): BYTE;
         stdcall; external 'tmaccess.dll' name '_tmEnumObjects@24';
function tmGetObjectName(ObjectType: WORD; Ch, RTU, Point: SmallInt; Buffer: PAnsiChar; MaxBufLen: Integer): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmGetObjectName@24';
function tmGetObjectNameEx(ObjectType: WORD; Ch, RTU, Point, SubObjectId: SmallInt; Buffer: PAnsiChar; MaxBufLen: Integer): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmGetObjectNameEx@28';
function tmGetObjectProperties(ObjectType:Word; Ch, RTU, Point: SmallInt; Buf:PAnsiChar; cbBuf:LongInt):SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmGetObjectProperties@24';

function tmTakeAPS(var APS_Array: Integer): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmTakeAPS@4';
function tmControlByStatus(Ch, RTU, Point, Cmd: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmControlByStatus@16';

function tmTakeRetroTIT(Ch, RTU, Point: SmallInt;
                        Time: PAnsiChar;
                        Step, Quan, RetroNum: SmallInt;
                        Values: PSingle;
                        Flags:  PSmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmTakeRetroTIT@36';
function tmCheckForHWKey: Integer;
         stdcall; external 'tmaccess.dll' name '_tmCheckForHWKey@0';
         
function tmGetServerFeature(FeatureCode: Integer): Integer;
         stdcall; external 'tmaccess.dll' name '_tmGetServerFeature@4';
function tmGetStatusNormal(Ch, RTU, Point: SmallInt; NValue: PSmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmGetStatusNormal@16';
function tmSetStatusNormal(Ch, RTU, Point: SmallInt; NValue: SmallInt): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmSetStatusNormal@16'
function tmGetStatusClassData(count:Dword;statuses:pADRtm):pPAnsiChar;
         stdcall; external 'tmaccess.dll' name '_tmGetStatusClassData@8';
function tmEventLogByIndex(index: DWORD; ut: DWORD; pSize: PDWORD): pTMSEV;
         stdcall; external 'tmaccess.dll' name '_tmEventLogByIndex@12';
procedure tmFreeMemory(ptr: Pointer);
         stdcall; external 'tmaccess.dll' name '_tmFreeMemory@4';
function tmGetCurrentServer(machine:PAnsiChar; cbMachine:Dword; pipe:PAnsiChar; cbPipe:DWORD): SmallInt;
         stdcall; external 'tmaccess.dll' name '_tmGetCurrentServer@16';

function tmExecuteControlScript(Ch, RTU, Point: SmallInt; Cmd:SmallInt):LongInt;
         stdcall; external 'tmaccess.dll' name '_tmExecuteControlScript@16';
function tmOverrideControlScript(fOverride:LongBool): LongBool;
         stdcall; external 'tmaccess.dll' name '_tmOverrideControlScript@4';
function tmGetLastErrorText(var ptext:PAnsiChar):LongInt;
         stdcall; external 'tmaccess.dll' name '_tmGetLastErrorText@4';
function tmEvaluateExpression(expr,res:PAnsiChar; cbBytes:Integer): SmallInt;
    stdcall;external 'tmaccess.dll' name '_tmEvaluateExpression@12';

procedure d_printf(f: PAnsiChar);
procedure m_printf(f: PAnsiChar);
procedure e_printf(f: PAnsiChar);

implementation
function tmAnalog(Ch, RTU, Point: SmallInt;
                  Time: PAnsiChar; RetroNum: SmallInt): Single;
var
    AP: TAnalogPoint;
begin
    AP.asFloat := 0.0;
    if tmAnalogFull(Ch, RTU, Point, @AP, Time, RetroNum) = tma_defs.SUCCESS then
        tmAnalog := AP.asFloat
      else
        tmAnalog := huge_flt;
end;
procedure d_printf(f: PAnsiChar);
begin
end;
procedure m_printf(f: PAnsiChar);
begin
end;
procedure e_printf(f: PAnsiChar);
begin
end;
end.
