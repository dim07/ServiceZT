unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  wtimer, ADODB, DB;

type
  TSparkyThread = class(TThread)
  public
    procedure Execute; override;

  end;

  TPOThread = class(TThread)
  private
    po_id: Integer;
    oik: String;
  public
    procedure Execute; override;
    constructor Create(poid: Integer; oikname: String);

  end;

  TZTService = class(TService)
    ADOConnection1: TADOConnection;
    PoTable: TADOTable;
    PoTableid: TAutoIncField;
    PoTablename: TWideStringField;
    PoTableshort_name: TWideStringField;
    PoTablecnt: TIntegerField;
    PoTableoik: TWideStringField;
    PoTableoikOser: TWideStringField;
    PoTableoikPass: TWideStringField;
    PoTableisDomainUser: TSmallintField;
    ADODataSet1: TADODataSet;
    // procedure ServiceExecute(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
  private
    { Private declarations }

  public
    h1, m1, s1: Word;
    TimeRun: TDateTime;
    Timer: TWaitableTimer;
    begin_work: Boolean;
    procedure WriteLog(txt: String);
    function GetServiceController: TServiceController; override;
    { Public declarations }
    procedure ExeWork;
    procedure DataProc(po_id: Integer);
  end;

var
  ZTService: TZTService;
  SparkyThread: TSparkyThread;
  step, period: Word;
  k_kr: Double;
  t_kr: Integer;

implementation

{$R *.DFM}

uses
  DateUtils, tmaccess, tma_defs, IniFiles, ActiveX, SyncObjs, ZT_TM;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ZTService.Controller(CtrlCode);
end;

procedure TZTService.DataProc(po_id: Integer);
//const
//  sql = 'SELECT `po`.`oik`, `po`.`oikOser`, `po`.`oikPass`, `po`.`isDomainUser`'
//    + ', `podst`.`name`, `transformator`.`name`, `transformator`.`calcType`' +
//    ', `transformator`.`inom_vn`' + ', `transformator`.`snom`' +
//    ', `transformator`.`pnom`' + ', `transformator`.`inom_sn`' +
//    ', `transformator`.`inom_nn1`' + ', `transformator`.`inom_nn2`' +
//    ', `transformator`.`iCh_vn`' + ', `transformator`.`iKp_vn`' +
//    ', `transformator`.`iTi_vn`' + ', `transformator`.`uCh_vn`' +
//    ', `transformator`.`uKp_vn`' + ', `transformator`.`uTi_vn`' +
//    ', `transformator`.`pCh_vn`' + ', `transformator`.`pKp_vn`' +
//    ', `transformator`.`pTi_vn`' + ', `transformator`.`qCh_vn`' +
//    ', `transformator`.`qKp_vn`' + ', `transformator`.`qTi_vn`' +
//    ', `transformator`.`iCh_sn`' + ', `transformator`.`iKp_sn`' +
//    ', `transformator`.`iTi_sn`' + ', `transformator`.`uCh_sn`' +
//    ', `transformator`.`uKp_sn`' + ', `transformator`.`uTi_sn`' +
//    ', `transformator`.`pCh_sn`' + ', `transformator`.`pKp_sn`' +
//    ', `transformator`.`pTi_sn`' + ', `transformator`.`qCh_sn`' +
//    ', `transformator`.`qKp_sn`' + ', `transformator`.`qTi_sn`' +
//    ', `transformator`.`iCh_nn1`' + ', `transformator`.`iKp_nn1`' +
//    ', `transformator`.`iTi_nn1`' + ', `transformator`.`uCh_nn1`' +
//    ', `transformator`.`uKp_nn1`' + ', `transformator`.`uTi_nn1`' +
//    ', `transformator`.`pCh_nn1`' + ', `transformator`.`pKp_nn1`' +
//    ', `transformator`.`pTi_nn1`' + ', `transformator`.`qCh_nn1`' +
//    ', `transformator`.`qKp_nn1`' + ', `transformator`.`qTi_nn1`' +
//    ', `transformator`.`iCh_nn2`' + ', `transformator`.`iKp_nn2`' +
//    ', `transformator`.`iTi_nn2`' + ', `transformator`.`uCh_nn2`' +
//    ', `transformator`.`uKp_nn2`' + ', `transformator`.`uTi_nn2`' +
//    ', `transformator`.`pCh_nn2`' + ', `transformator`.`pKp_nn2`' +
//    ', `transformator`.`pTi_nn2`' + ', `transformator`.`qCh_nn2`' +
//    ', `transformator`.`qKp_nn2`' + ', `transformator`.`qTi_nn2`' +
//    'FROM `bp`.`groups_podst` INNER JOIN `bp`.`po` ON (`groups_podst`.`po_id` = `po`.`id`) '
//    + 'INNER JOIN `bp`.`podst` ON (`podst`.`group_id` = `groups_podst`.`id`) ' +
//    'INNER JOIN `bp`.`transformator` ON (`transformator`.`podst_id` = `podst`.`id`) '
//    + 'WHERE (`po`.`id` = %d AND `podst`.`isTit` = 1);';
var
  PodstDS, TransDS: TADODataSet;
  pName, tName: String;
//  nomin: Double;
  nl: TNagrList;
begin
  PodstDS := TADODataSet.Create(nil);
  PodstDS.Connection := ADOConnection1;
  // PodstDS.CommandText := 'set names utf8';
  // PodstDS.Open;
  // PodstDS.Close;

  PodstDS.CommandText :=
    'SELECT p.id, p.name as pname, p.kdn, p.IsTit FROM podst p, groups_podst g WHERE p.group_id = g.id and g.po_id = '
    + IntToStr(po_id);
  try
    PodstDS.Open;
    PodstDS.First;
    while not PodstDS.Eof do
    begin
      pName := PodstDS.FieldByName('pname').AsString;
      WriteLog('Начало обработки ПС ' + pName);
      if PodstDS.FieldByName('IsTit').AsInteger > 0 then
      begin
        TransDS := TADODataSet.Create(nil);
        TransDS.Connection := ADOConnection1;
        TransDS.CommandText := 'SELECT * FROM transformator WHERE podst_id = ' +
          PodstDS.FieldByName('id').AsString;
        try
          TransDS.Open;
          TransDS.First;
          while not TransDS.Eof do
          begin
            tName := TransDS.FieldByName('name').AsString;
            WriteLog('Начало обработки ' + tName);

            if not TransDS.FieldByName('inom_vn').IsNull then
            begin
              if (not TransDS.FieldByName('iCh_vn').IsNull) and
                 (not TransDS.FieldByName('iKp_vn').IsNull) and
                 (not TransDS.FieldByName('iTi_vn').IsNull)  then
              begin
                nl := TNagrList.Create;
                try
                  nl.nominal:= TransDS.FieldByName('inom_vn').AsFloat;
                  nl.np:=II;
                  nl.Obmotka:=VN;
                  nl.GetRetroData(IncHour(TimeRun, -period), step, 3600*period div step,
                  TransDS.FieldByName('iCh_vn').AsInteger,
                  TransDS.FieldByName('iKp_vn').AsInteger,
                  TransDS.FieldByName('iTi_vn').AsInteger);
                  WriteLog('Найдено '+IntToStr(nl.Count)+' перегрузок, загрузка '+IntToStr(round(nl.zagr))+'%');
                finally
                  nl.Free;
                end;
              end;
            end;

            if not TransDS.FieldByName('inom_sn').IsNull then
            begin
              if (not TransDS.FieldByName('iCh_sn').IsNull) and
                 (not TransDS.FieldByName('iKp_sn').IsNull) and
                 (not TransDS.FieldByName('iTi_sn').IsNull)  then
              begin
                nl := TNagrList.Create;
                try
                  nl.nominal:= TransDS.FieldByName('inom_sn').AsFloat;
                  nl.np:=II;
                  nl.Obmotka:=SN;
                  nl.GetRetroData(IncHour(TimeRun, -period), step, 3600*period div step,
                  TransDS.FieldByName('iCh_sn').AsInteger,
                  TransDS.FieldByName('iKp_sn').AsInteger,
                  TransDS.FieldByName('iTi_sn').AsInteger);
                  WriteLog('Найдено '+IntToStr(nl.Count)+' перегрузок, загрузка '+IntToStr(round(nl.zagr))+'%');
                finally
                  nl.Free;
                end;
              end;
            end;

            if not TransDS.FieldByName('inom_nn1').IsNull then
            begin
              if (not TransDS.FieldByName('iCh_nn1').IsNull) and
                 (not TransDS.FieldByName('iKp_nn1').IsNull) and
                 (not TransDS.FieldByName('iTi_nn1').IsNull)  then
              begin
                nl := TNagrList.Create;
                try
                  nl.nominal:= TransDS.FieldByName('inom_nn1').AsFloat;
                  nl.np:=II;
                  nl.Obmotka:=NN1;
                  nl.GetRetroData(IncHour(TimeRun, -period), step, 3600*period div step,
                  TransDS.FieldByName('iCh_nn1').AsInteger,
                  TransDS.FieldByName('iKp_nn1').AsInteger,
                  TransDS.FieldByName('iTi_nn1').AsInteger);
                  WriteLog('Найдено '+IntToStr(nl.Count)+' перегрузок, загрузка '+IntToStr(round(nl.zagr))+'%');
                finally
                  nl.Free;
                end;
              end;
            end;

            if not TransDS.FieldByName('inom_nn2').IsNull then
            begin
              if (not TransDS.FieldByName('iCh_nn2').IsNull) and
                 (not TransDS.FieldByName('iKp_nn2').IsNull) and
                 (not TransDS.FieldByName('iTi_nn2').IsNull)  then
              begin
                nl := TNagrList.Create;
                try
                  nl.nominal:= TransDS.FieldByName('inom_nn2').AsFloat;
                  nl.np:=II;
                  nl.Obmotka:=NN2;
                  nl.GetRetroData(IncHour(TimeRun, -period), step, 3600*period div step,
                  TransDS.FieldByName('iCh_nn2').AsInteger,
                  TransDS.FieldByName('iKp_nn2').AsInteger,
                  TransDS.FieldByName('iTi_nn2').AsInteger);
                  WriteLog('Найдено '+IntToStr(nl.Count)+' перегрузок, загрузка '+IntToStr(round(nl.zagr))+'%');
                finally
                  nl.Free;
                end;
              end;
            end;


            WriteLog('Конец обработки ' + tName);
            TransDS.Next;
          end;
        finally
          if TransDS.Active then
            TransDS.Close;
          TransDS.Free;
        end;
      end
      else
      begin
        WriteLog('ПС ' + pName + ' не имеет ТИТ адресов');
      end;
      WriteLog('Конец обработки ПС ' + pName);
      PodstDS.Next;
    end;
  finally
    if PodstDS.Active then
      PodstDS.Close;
    PodstDS.Free;
  end;
  // ADODataSet1.CommandText := Format(sql, [po_id]);
  // ADODataSet1.Open;
end;

procedure TZTService.ExeWork;
var
  po, oik: String;
  fld: TField;
  sl: TStringList;
  trd: TPOThread;
begin
  ADOConnection1.Connected := True;
  try
    if ADOConnection1.Connected then
    begin
      WriteLog('Соединение с SQL-сервером установлено');
      PoTable.Open;
      PoTable.First;
      while not PoTable.Eof do
      begin
        po := Trim(PoTable.FieldByName('short_name').AsString);
        oik := Trim(PoTable.FieldByName('oik').AsString);
        WriteLog('Начало загрузки данных по ' + po + '(' + oik + ')');
        sl := TStringList.Create;
        fld := PoTable.FieldByName('oik');
        if fld.IsNull or (Trim(fld.AsString) = '') then
          sl.Append('ОИК');
        // fld := PoTable.FieldByName('oikOser');
        // if fld.IsNull or (Trim(fld.AsString) = '') then
        // sl.Append('логин ОИК');
        // fld := PoTable.FieldByName('oikPass');
        // if fld.IsNull or (Trim(fld.AsString) = '') then
        // sl.Append('пароль ОИК');
        if sl.Count = 0 then
        begin // получение данных
          trd:= TPOThread.Create(PoTable.FieldByName('id').AsInteger, oik);
          trd.Resume;
//          if tmInit(PAnsiChar(AnsiString(oik)), 'ZT') = SUCCESS then
//          begin
//            WriteLog('ТМ-сервер ' + po + '(' + oik + ') подключен');
//
//            DataProc(PoTable.FieldByName('id').AsInteger);
//
//            tmClose;
//            WriteLog('ТМ-сервер ' + po + '(' + oik + ') отсоединен');
//          end
//          else
//          begin
//            WriteLog('ОШИБКА! ТМ-сервер ' + po + '(' + oik + ') не подключен');
//          end;
        end
        else
        begin
          WriteLog('Загрузка данных отменена, по причине отсутствия данных для '
            + po + ': ' + sl.Text);
        end;
        sl.Free;
        PoTable.Next;
      end;
    end
    else
    begin
      WriteLog('ОШИБКА! Соединение с SQL-сервером НЕ УСТАНОВЛЕНО!');
    end;
  finally
    if ADOConnection1.Connected then
      ADOConnection1.Close;
  end;
end;

function TZTService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

// procedure TZTService.ServiceExecute(Sender: TService);
// var
// yy, mn, dd, hh, mm, ss, ms: Word;
// // TimeRun:  TDateTime;
// SUCCESS: HResult;
// // LogStr: String;
// begin
// while not Terminated Do
// begin
// DecodeDateTime(Now, yy, mn, dd, hh, mm, ss, ms);
// TimeRun := EncodeDateTime(yy, mn, dd, h1, m1, s1, 0);
// if Now > TimeRun then
// TimeRun := IncDay(TimeRun);
// // LogStr := DateTimeToStr(Now) + '> ' + 'Таймер запущен на ' +DateTimeToStr(TimeRun);
// WriteLog('Таймер запущен на ' + DateTimeToStr(TimeRun));
// Timer := TWaitableTimer.Create(false, nil, '');
// Timer.Time := TimeRun; // время србатывания
// Timer.Period := 0; // нет интервала, срабатывает один раз
// Timer.Start; // запуск таймера
// if Timer.Wait(INFINITE) <> wrError then
// begin
// if not Terminated then
// begin
// // WaitForSingleObject(Semaphore, INFINITE);
// // LogStr := DateTimeToStr(Now) + '> ' + 'Таймер сработал';
// WriteLog(DateTimeToStr(Now) + '> ' + 'Таймер сработал');
// SUCCESS := CoInitialize(nil);
// try
// ExeWork;
// finally
// case SUCCESS of
// S_OK, S_FALSE:
// CoUninitialize;
// end;
// // ReleaseSemaphore(Semaphore, 1, NIL);
// // tmClose;
// WriteLog('Загрузка завершена');
// end;
// end;
// /// /if not Terminated then
// end;
// ServiceThread.ProcessRequests(false);
// end;
// end;

procedure TZTService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  SparkyThread.Resume;
  Continued := True;
end;

procedure TZTService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  SparkyThread.Suspend;
  Paused := True;
end;

procedure TZTService.ServiceStart(Sender: TService; var Started: Boolean);
var
  // ms: Word;
  ifl: TIniFile;
begin
  WriteLog('Старт сервиса');
  ifl := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    ADOConnection1.ConnectionString := ifl.ReadString('Path', 'SQL',
      ADOConnection1.ConnectionString);
    h1 := ifl.ReadInteger('Time', 'hh', 5);
    m1 := ifl.ReadInteger('Time', 'mm', 0);
    s1 := ifl.ReadInteger('Time', 'ss', 0);
    t_kr := ifl.ReadInteger('Algoritm', 'tkr', 180);
    k_kr := ifl.ReadFloat('Algoritm', 'kkr', 0.9);
    step := ifl.ReadInteger('Algoritm', 'retro_step', 20);
    period := ifl.ReadInteger('Algoritm', 'run_period', 24);
    begin_work := True;
    // ms := ifl.ReadInteger('Time','ms',0);
    // ms := 0;
    // flStart := ifl.ReadInteger('State','start',0);
    // TimeRun := EncodeTime(h1,m1,s1,ms);
  finally
    ifl.Free;
  end;
  SparkyThread := TSparkyThread.Create(False);
  Started := True;
end;

procedure TZTService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  SparkyThread.Terminate;
  Stopped := True;

  WriteLog('Стоп сервиса');
  if Assigned(Timer) then
    Timer.Free;
end;

// ServiceThread.ProcessRequests(false);
// Sleep(1000);
// End;
// end;

procedure TZTService.WriteLog(txt: String);
var
  Filename: string;
  LogFile: TextFile;
begin
  // prepares log file
  Filename := ChangeFileExt(ParamStr(0), '.log');
  AssignFile(LogFile, Filename);
  if FileExists(Filename) then
    Append(LogFile) // open existing file
  else
    Rewrite(LogFile); // create a new one
  try
    // write to the file and show error
    Writeln(LogFile, DateTimeToStr(Now) + '> ' + txt);
    // Application.ShowException (E);
  finally
    // close the file
    CloseFile(LogFile);
  end;
end;

{ TSparkyThread }

procedure TSparkyThread.Execute;
var
  yy, mn, dd, hh, mm, ss, ms: Word;
  // TimeRun:  TDateTime;
  SUCCESS: HResult;
  // LogStr: String;
  hs_btwn, n: Int64;
  CurDT: TDateTime;
begin
//  while not Terminated Do
//  begin
    CurDT := Now;
    DecodeDateTime(CurDT, yy, mn, dd, hh, mm, ss, ms);
    With ZTService do
    begin
      TimeRun := EncodeDateTime(yy, mn, dd, h1, m1, s1, 0);
      if CurDT > TimeRun then
      begin
        TimeRun := IncDay(TimeRun);
      end;
      WriteLog('Таймер установлен на ' + DateTimeToStr(TimeRun));
      Timer := TWaitableTimer.Create(False, nil, '');
      try
        Timer.Time := TimeRun; // время србатывания
        //Timer.period := 0; // нет интервала, срабатывает один раз
        Timer.period := period*60*60*1000;
        Timer.Start; // запуск таймера
        while not Terminated do
          if Timer.Wait(INFINITE) <> wrError then
          begin
            if not Terminated then
            begin
              // WaitForSingleObject(Semaphore, INFINITE);
              // LogStr := DateTimeToStr(Now) + '> ' + 'Таймер сработал';
              WriteLog('Таймер сработал');
              SUCCESS := CoInitialize(nil);
              try
                ExeWork;
              finally
                case SUCCESS of
                  S_OK, S_FALSE:
                    CoUninitialize;
                end;
                // ReleaseSemaphore(Semaphore, 1, NIL);
                // tmClose;
                WriteLog('Загрузка завершена');
                TimeRun := IncHour(TimeRun, period);
                WriteLog('Таймер установлен на ' + DateTimeToStr(TimeRun));
              end;
            end;
            /// /if not Terminated then
          end else
            WriteLog('Ошибка таймера');
      finally
        Timer.Free;
      end;
      // ProcessRequests(false);
    end;
//  end;
end;

{ TPOThread }

constructor TPOThread.Create(poid: Integer; oikname: String);
begin
  oik := oikname;
  po_id := poid;
  inherited Create(True);
end;

procedure TPOThread.Execute;
var
SUCCESS: HResult;
begin
  With ZTService do
  begin
    SUCCESS := CoInitialize(nil);
    try
      if tmInit(PAnsiChar(AnsiString(oik)), 'ZT') = SUCCESS then
          begin
            WriteLog('ТМ-сервер '+ oik + ' подключен');

            DataProc(PoTable.FieldByName('id').AsInteger);

            tmClose;
            WriteLog('ТМ-сервер ' + oik + ' отсоединен');
          end
          else
          begin
            WriteLog('ОШИБКА! ТМ-сервер ' + oik + ' не подключен');
          end;
    finally
      case SUCCESS of
        S_OK, S_FALSE:
          CoUninitialize;
      end;
      WriteLog('Загрузка завершена');
    end;
  end;
end;

end.
