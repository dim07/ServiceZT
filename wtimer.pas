unit wtimer;

{ **** UBPFD *********** by delphibase.endimus.com **** 
 >> �����-�������� ��� ������� ������������� WaitableTimer. 
 
 ����� ������������ ����� �������� ��� ������� ������������� WaitableTimer, 
 ������������� � ������������ ��������, ���������� �� ���� WinNT. 
 
 ������. 
 -------------- 
 Start - ������ �������. 
 
 Stop - ��������� �������. 
 
 Wait - ������� ������������ ������� �������� ���������� ����������� � 
 ���������� ��������� ��������. 
 
 ��������. 
 -------------- 
 Time : TDateTime - ����/����� ����� ������ ��������� ������. 
 
 Period : integer - ������ ������������ �������. ���� �������� ����� 0, �� 
 ������ ����������� ���� ���, ���� �� �������� ������� �� ����, ������ ����� 
 ����������� ������������ � �������� ����������, ������ ������������ ���������� 
 � ������, �������� ��������� Time. 
 
 LongTime : int64 - �������������� ������ ������� ������� ������������. ����� 
 �������� � ������� UTC. 
 
 Handle : THandle (������ ������) - ����� ������ �������������. 
 
 LastError : integer (������ ������) - � ������ ���� ����� Wait ���������� 
 wrError, ��� �������� �������� ��������, ������������ �������� GetLastError. 
 
 �����������: Windows, SysUtils, SyncObjs 
 �����:  vuk 
 Copyright: ������� ������� 
 ����:  25 ������ 2002 �. 
 ***************************************************** } 
 
 interface 
 
 uses 
 Windows, SysUtils, SyncObjs; 
 
 type
 
 TWaitableTimer = class(TSynchroObject) 
 protected 
  FHandle: THandle; 
  FPeriod: longint; 
  FDueTime: TDateTime; 
  FLastError: Integer; 
  FLongTime: int64; 
 public 
 
  constructor Create(ManualReset: boolean; 
  TimerAttributes: PSecurityAttributes; const Name: string); 
  destructor Destroy; override; 
 
  procedure Start; 
  procedure Stop; 
  function Wait(Timeout: Cardinal): TWaitResult;
 
  property Handle: THandle read FHandle; 
  property LastError: integer read FLastError; 
  property Period: integer read FPeriod write FPeriod; 
  property Time: TDateTime read FDueTime write FDueTime; 
  property LongTime: int64 read FLongTime write FLongTime; 
 
 end; 
 
 implementation 
 
 { TWaitableTimer } 
 
 constructor TWaitableTimer.Create(ManualReset: boolean; 
 TimerAttributes: PSecurityAttributes; const Name: string); 
 var 
 pName: PChar; 
 begin 
 inherited Create; 
 if Name = '' then 
  pName := nil 
 else 
  pName := PChar(Name); 
 FHandle := CreateWaitableTimer(TimerAttributes, ManualReset, pName); 
 end; 
 
 destructor TWaitableTimer.Destroy; 
 begin 
 CloseHandle(FHandle); 
 inherited Destroy; 
 end; 
 
 procedure TWaitableTimer.Start; 
 var 
 SysTime: TSystemTime; 
 LocalTime, UTCTime: FileTime; 
 Value: int64 absolute UTCTime; 
 
 begin 
 if FLongTime = 0 then 
 begin 
  DateTimeToSystemTime(FDueTime, SysTime); 
  SystemTimeToFileTime(SysTime, LocalTime); 
  LocalFileTimeToFileTime(LocalTime, UTCTime); 
 end 
 else 
  Value := FLongTime; 
 SetWaitableTimer(FHandle, Value, FPeriod, nil, nil, false); 
 end; 
 
 procedure TWaitableTimer.Stop; 
 begin 
 CancelWaitableTimer(FHandle); 
 end; 
 
 function TWaitableTimer.Wait(Timeout: Cardinal): TWaitResult;
 begin 
 case WaitForSingleObjectEx(Handle, Timeout, BOOL(1)) of 
  WAIT_ABANDONED: Result := wrAbandoned; 
  WAIT_OBJECT_0: Result := wrSignaled; 
  WAIT_TIMEOUT: Result := wrTimeout; 
  WAIT_FAILED: 
  begin 
  Result := wrError; 
  FLastError := GetLastError; 
  end; 
 else 
  Result := wrError; 
 end; 
 end; 
 
 end.

 // ������ �������� �������, ������� ����������� �� ��������� "������ � ��� �� 
 // ����� � ����� � ���������� � ���� ������". 
 
// var
// Timer: TWaitableTimer;
// begin
// Timer := TWaitableTimer.Create(false, nil, '');
// Timer.Time := Now + 1; //������ � ��� �� �����
// Timer.Period := 60 * 1000; //�������� � 1 ������
// Timer.Start; //������ �������
// end;

