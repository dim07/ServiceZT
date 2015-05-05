unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  wtimer, ADODB, DB, SyncObjs;

type
  TSparkyThread = class(TThread)
  public
    procedure Execute; override;
//    procedure Get_PO_Data(poid: Integer; poNm, oikName: String);
  end;

//  TPOThread = class(TThread)
//  private
//    po_id: Integer;
//    oik, poName: String;
//  public
//    procedure Execute; override;
//    constructor Create(poid: Integer; poNm, oikname: String);
//
//  end;

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
    PoList: TStringList;

  public
    h1, m1, s1: Word;
    AutoTime: Boolean;
    TimeRun: TDateTime;
    Timer: TWaitableTimer;
    procedure WriteLog(txt: String; oik: String='');
    function GetServiceController: TServiceController; override;
    { Public declarations }
    procedure ExeWork;
    procedure DataProc(po_id: Integer; oik: String);
    procedure Get_PO_Data(poid: Integer; poNm, oikName: String);
  end;

var
  ZTService: TZTService;
  SparkyThread: TSparkyThread;
  step, period: Word;
  k_kr: Double;
  t_kr: Integer;
  Lock: TCriticalSection;

implementation

{$R *.DFM}

uses
  DateUtils, tmaccess, tma_defs, IniFiles, ActiveX, ZT_TM, Math;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ZTService.Controller(CtrlCode);
end;

{$POINTERMATH ON}
procedure TZTService.DataProc(po_id: Integer; oik: String);
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
  pName, tName, obmName, dts: String;
  TransList: TPodstData;
  ObmList: TTransfData;
  ObmA, ObmA0, ObmA1 : TObmotkaArray;
  obm: TObmotka;
  nl: TNagrList;
  npl: TPrognozList;
  i,j,n: Integer;
  Quan: SmallInt;
  I_m, N_m, S_m, P_m, Q_m, nominal,K_zagr, S_fact, U, Q, S_podst: Single;
  K_max, K_med, SKM: Single;
  T_max: TDateTime;
  Obm_max: TObmotka;
  DN_Is: Boolean;
  DN: TNagrItem;
  PDN: TPrognozItem;
  MaxI: Single;
  StartDt, MaxDt, EndDt, dt: TDateTime;
  SecDlit: Int64;
  StartDate: TDateTime;
  flSumVN: Boolean;
  TransInfo: TTransInfoRorPrognozItem;
procedure GetObmData(ObmName: String);
begin
  if (not TransDS.FieldByName('snom').IsNull) then
  begin
    if (not TransDS.FieldByName('inom_'+ObmName).IsNull) and
       (not TransDS.FieldByName('iCh_'+ObmName).IsNull) and
       (not TransDS.FieldByName('iKp_'+ObmName).IsNull) and
       (not TransDS.FieldByName('iTi_'+ObmName).IsNull) and
       (not TransDS.FieldByName('uCh_'+ObmName).IsNull) and
       (not TransDS.FieldByName('uKp_'+ObmName).IsNull) and
       (not TransDS.FieldByName('uTi_'+ObmName).IsNull)
    then
    begin
      if ObmName = 'vn' then
         ObmA := TObmotkaArray.Create(VN, II) else
      if ObmName = 'sn' then
         ObmA := TObmotkaArray.Create(SN, II) else
      if ObmName = 'nn1' then
         ObmA := TObmotkaArray.Create(NN1, II) else
      if ObmName = 'nn2' then
         ObmA := TObmotkaArray.Create(NN2, II);
      GetMem(ObmA.Sf, Quan * SizeOf(Single));
      GetMem(ObmA.Qf, Quan * SizeOf(Single));
      if ObmA.GetRetroData(StartDate, step, period,
        TransDS.FieldByName('iCh_'+ObmName).AsInteger,
        TransDS.FieldByName('iKp_'+ObmName).AsInteger,
        TransDS.FieldByName('iTi_'+ObmName).AsInteger) then
      begin
        ObmList.Add(ObmA);
//        GetMem(ObmA.Sf, Quan * SizeOf(Single));
      end else
      begin
        ObmA.Free;
        WriteLog('�� ������� ���������� ������������� ��� I('+ObmName+')', oik);
      end;
    end else
    if //(not TransDS.FieldByName('snom').IsNull) and
       (not TransDS.FieldByName('pCh_'+ObmName).IsNull) and
       (not TransDS.FieldByName('pKp_'+ObmName).IsNull) and
       (not TransDS.FieldByName('pTi_'+ObmName).IsNull)
    then
    begin
      if ObmName = 'vn' then
         ObmA := TObmotkaArray.Create(VN, PP) else
      if ObmName = 'sn' then
         ObmA := TObmotkaArray.Create(SN, PP) else
      if ObmName = 'nn1' then
         ObmA := TObmotkaArray.Create(NN1, PP) else
      if ObmName = 'nn2' then
         ObmA := TObmotkaArray.Create(NN2, PP);
      GetMem(ObmA.Sf, Quan * SizeOf(Single));
      GetMem(ObmA.Qf, Quan * SizeOf(Single));
      if ObmA.GetRetroData(StartDate, step, period,
        TransDS.FieldByName('pCh_'+ObmName).AsInteger,
        TransDS.FieldByName('pKp_'+ObmName).AsInteger,
        TransDS.FieldByName('pTi_'+ObmName).AsInteger) then
      begin
        ObmList.Add(ObmA);
//        GetMem(ObmA.Sf, Quan * SizeOf(Single));
      end else
      begin
        ObmA.Free;
        WriteLog('�� ������� ���������� ������������� ��� P('+ObmName+')', oik);
      end;
    end else
    if (ObmName = 'vn') and (ObmList.Count>1) and not TransDS.FieldByName('inom_vn').IsNull and not (TransDS.FieldByName('inom_vn').AsFloat=0) then
    begin
    //  ������������� ���� ����������� (��������� ������ �� ������ �������)
      flSumVN := TRUE;
      ObmA := TObmotkaArray.Create(VN, SI);
      GetMem(ObmA.values, Quan * SizeOf(Single));
      GetMem(ObmA.flags, Quan * SizeOf(SmallInt));
      GetMem(ObmA.Qf, Quan * SizeOf(Single));
//      GetMem(ObmA.Sf, Quan * SizeOf(Single));
      ObmList.Add(ObmA);
    end;
  end;
end;

function GetObmS(o: TObmotkaArray; ai: Integer): Single;
begin
  Result := huge_flt;
  case o.Obmotka of
    VN: obmName := 'vn';
    SN: obmName := 'sn';
    NN1: obmName := 'nn1';
    NN2: obmName := 'nn2';
  end;

//  Q := huge_flt;
  o.Qf^[ai] := huge_flt;
  if not TransDS.FieldByName('qCh_'+ObmName).IsNull and
        not TransDS.FieldByName('qKp_'+ObmName).IsNull and
        not TransDS.FieldByName('qTi_'+ObmName).IsNull
  then
  begin
   o.Qf^[ai] := Abs(tmAnalog(TransDS.FieldByName('qCh_'+ObmName).AsInteger,
          TransDS.FieldByName('qKp_'+ObmName).AsInteger,
          TransDS.FieldByName('qTi_'+ObmName).AsInteger,
          PAnsiChar(AnsiString(dts)),
          0));
  end;

  case o.N_param of
    II:
    begin
      // ���� �� ��� U
     if not TransDS.FieldByName('uCh_'+ObmName).IsNull and
        not TransDS.FieldByName('uKp_'+ObmName).IsNull and
        not TransDS.FieldByName('uTi_'+ObmName).IsNull
     then
     begin
       U:=Abs(tmAnalog(TransDS.FieldByName('uCh_'+ObmName).AsInteger,
                          TransDS.FieldByName('uKp_'+ObmName).AsInteger,
                          TransDS.FieldByName('uTi_'+ObmName).AsInteger,
                          PAnsiChar(AnsiString(dts)),
                          0));
       if U <> huge_flt then
       begin
        Result := o.values^[ai]*U*Sqrt(3)/1000;
       end;
     end;
    end;
    PP:
    begin
     // ���� �� ��� Q
     Q := o.Qf^[ai];
     if Q <> huge_flt then
      Result := Sqrt(o.values^[ai]*o.values^[ai]+Q*Q)
     else
      if o.values^[ai] <> huge_flt then
        Result := Sqrt(1.16*o.values^[ai]*o.values^[ai]);
    end;
  end;
end;

begin
  PodstDS := TADODataSet.Create(nil);
  PodstDS.Connection := ADOConnection1;

  PodstDS.CommandText :=
    'SELECT p.id, p.name as pname, p.kdn, p.IsTit FROM podst p, groups_podst g WHERE p.group_id = g.id and g.po_id = '
    + IntToStr(po_id);
  try
    PodstDS.Open;
    PodstDS.First;
    StartDate := IncHour(TimeRun, -period);

    while not PodstDS.Eof do
    begin
      pName := PodstDS.FieldByName('pname').AsString;
      WriteLog('������ ��������� �� ' + pName,oik);
      if PodstDS.FieldByName('IsTit').AsInteger > 0 then
      begin
        TransDS := TADODataSet.Create(nil);
        TransDS.Connection := ADOConnection1;
        TransDS.CommandText := 'SELECT * FROM transformator WHERE podst_id = ' +
          PodstDS.FieldByName('id').AsString;
        TransList := TPodstData.Create;
        try
          TransDS.Open;
          TransDS.First;
          while not TransDS.Eof do
          begin
            tName := TransDS.FieldByName('name').AsString;
            WriteLog('������ ��������� ' + tName, oik);
            ObmList := TTransfData.Create;
            ObmList.tr_id := TransDS.FieldByName('id').AsInteger;
            if not TransDS.FieldByName('snom').IsNull then
              ObmList.S_nom := TransDS.FieldByName('snom').AsFloat;
            TransList.Add(ObmList);
            try
              Quan := 3600*period div step;
              flSumVN := FALSE;

              try
              GetObmData('sn');
              GetObmData('nn1');
              GetObmData('nn2');
              GetObmData('vn');

              MaxDt := StartDate;
              MaxI := 0;
              DN_Is := False;
              nl := TNagrList.Create;
              nl.TransId := TransDS.FieldByName('id').AsInteger;
              K_max:=0;
              SKM:=0;
              for i:=0 to Quan-1 do
              begin
                I_m := 0;
                N_m :=0;
                P_m :=0;
                S_m := 0;
                dt := IncSecond(StartDate, i * step);
                dts := FormatDateTime('DD.MM.YYYY HH:NN:SS',dt);
                for j:=0 to ObmList.Count-1 do
                begin
                  ObmA := ObmList.Items[j];
                  if IsNan(ObmA.values^[i]) or (UNRELIABLE_HDW in TSmallIntSet(ObmA.flags^[i])) or
                     (ObmA.values^[i] > 1000000)
                  then Continue;

                  // ����� ��������������� �������
                  if ObmA.N_param = II then
                  begin
                    case ObmA.Obmotka of
                      VN: nominal:= TransDS.FieldByName('inom_vn').AsFloat;
                      SN: nominal:= TransDS.FieldByName('inom_sn').AsFloat;
                      NN1: nominal:= TransDS.FieldByName('inom_nn1').AsFloat;
                      NN2: nominal:= TransDS.FieldByName('inom_nn2').AsFloat;
                    end
                  end else
                  begin
                    nominal:= ObmList.S_nom;
                  end;

                  if nominal = 0 then
                     break;
                  // ������� ���������, ������� ���������� �� ������ ������� �� ��������
                  if ObmA.N_param = II then
                  begin
                    ObmA.Sf^[i]:= GetObmS(ObmA, i);
                    K_zagr:= ObmA.values^[i]/nominal;
                    if N_m < K_zagr then
                    begin
                       I_m := ObmA.values^[i];
                       N_m := K_zagr;
                       P_m := 0;
                       if ObmA.Sf^[i] <> huge_flt then
                        S_m := ObmA.Sf^[i];
                       obm := ObmA.Obmotka;
                    end;
                  end else
                  if ObmA.N_param = PP then
                  begin  ///ObmA.N_param = PP
                    //S_fact := Sqrt(1.16*ObmA.values^[i]*ObmA.values^[i]);
                    ObmA.Sf^[i]:= GetObmS(ObmA, i);
                    S_fact := ObmA.Sf^[i];
                    if ObmA.Sf^[i] <> huge_flt then
                      K_zagr := S_fact/nominal;
                    if N_m < K_zagr then
                    begin
                       I_m := 0;
                       P_m:=ObmA.values^[i];
                       N_m := K_zagr;
                       S_m := S_fact;
                       obm := ObmA.Obmotka;
                    end;
                  end else
                  if ObmA.N_param = SI then //����������� � �������� IU ��� PQ �� ����
                  begin
                   S_fact := GetObmS(ObmList.Items[j-1], i);
                   if S_fact <> huge_flt then
                   begin
                     ObmA.values^[i] := S_fact;
                     S_fact := GetObmS(ObmList.Items[j-2], i);
                     if S_fact <> huge_flt then
                     begin
                       ObmA.values^[i] := ObmA.values^[i] + S_fact;
                       K_zagr := ObmA.values^[i]/nominal;
                       if N_m < K_zagr then
                       begin
                         I_m := 0;
                         P_m:= 0;
                         N_m := K_zagr;
                         S_m := ObmA.values^[i];
                         obm := ObmA.Obmotka;
                       end;
                     end else
                       WriteLog('������ ��� ��������� ������ �� ���', oik);
                   end else
                     WriteLog('������ ��� ��������� ������ �� ���', oik);
                  end;
                end;
                // ������ �������� �������� ���� ���� ��� ���������
                nl.zagr := max(nl.zagr, 100*N_m);
                SKM := SKM + 100*N_m;
                if K_max < 100*N_m then
                begin
                  K_max := 100*N_m;
                  T_max := IncSecond(StartDate, i * step);
                  Obm_max := obm;
                end;

                //������� ��� ��������� ������ ��������, ���� �������� ����. k_kr
                if N_m >= k_kr then
                begin
                  if not DN_Is then
                  begin
                    DN := TNagrItem.Create;
                    DN_Is := True;
                    DN.StartDt := IncSecond(StartDate, i * step);
                    DN.Imax := I_m;
                    DN.Pik := N_m;
                    DN.Pmax := P_m;
                    DN.Smax := S_m;
                    DN.PikDt := DN.StartDt;
                    DN.EndDt := DN.StartDt;
                    DN.Obmotka := obm;
                    nl.Add(DN);
                  end else
                  begin
                    if N_m > DN.Pik then
                    begin
                      DN.Pik := N_m;
                      DN.Imax := I_m;
                      DN.Pmax := P_m;
                      DN.Smax := S_m;
                      DN.Obmotka := obm;
                      DN.PikDt := IncSecond(StartDate, i * step);
                    end;
                    DN.EndDt := IncSecond(StartDate, i * step);
                  end;
                end else
                if DN_Is then
                begin
                  DN_Is := False;
                  if SecondsBetween(DN.StartDt, DN.EndDt) < t_kr then
                  begin
                    nl.Remove(DN);
                    DN.Free;
                  end;
                end;
                if (i = (Quan - 1)) and DN_Is then // ���� ���� �������� � ����������
                begin
                  if SecondsBetween(DN.StartDt, DN.EndDt) < t_kr then
                  begin
                    nl.Remove(DN);
                    DN.Free;
                  end;
                end;
              end;

              //��� ��������� � ����
              WriteLog('������� '+IntToStr(nl.Count)+' ����������, �������� '+IntToStr(round(nl.zagr))+'%', oik);
              try
              Lock.Enter;
              nl.InsertToDB(StartDate, IncHour(StartDate, period));
              finally
                Lock.Leave;
              end;
              K_med := SKM/Quan;
              if K_max > 0 then
              begin
                try
                Lock.Enter;
                InsertNagrToDB(nl.TransId, StartDate, IncHour(StartDate, period), T_max, K_max, K_med, Obm_max);
                finally
                  Lock.Leave;
                end;
              end;
              except
                on e: Exception do
                  WriteLog('������: '+e.message, oik);
              end;
            finally
              nl.Free; // ���������� ��� � ����������� ���� ���������
              WriteLog('����� ��������� ' + tName, oik);
              TransDS.Next;
            end;
          end;

          //// ������ �������� �������� ����������  ////
          ///  ������� MIN ������� S ����� ��-���
          TransList.S_nom_min := huge_flt;
          for i := 0 to TransList.Count-1 do
          begin
            ObmList := TransList.Items[i];
            for j:=0 to ObmList.Count-1 do
            begin
              if TransList.S_nom_min > ObmList.S_nom then
                TransList.S_nom_min := ObmList.S_nom;
            end;
          end;

          DN_Is:=False;
          N_m := 0;
          npl := TPrognozList.Create;
          npl.PodstId := PodstDS.FieldByName('id').AsInteger;
          try
          for n := 0 to Quan-1 do
          begin
            dt := IncSecond(StartDate, n * step);
            S_podst := 0;
            for i := 0 to TransList.Count-1 do
            begin
              ObmList := TransList.Items[i];
              S_fact := 0;
              S_m := 0;
              Q_m := 0;
              for j:=0 to ObmList.Count-1 do
              begin
                ObmA := ObmList.Items[j];
                if ObmA.N_param <> SI then
                  S_fact := ObmA.Sf[n] else
                  S_fact := ObmA.values[n];
                if (S_fact>100000) or IsNan(S_fact) or (S_fact = huge_flt) then
                   S_fact := 0;
                // ����� ���� ������� �-�� �������� ���� S
                if S_m < S_fact then
                begin
                   S_m := S_fact;
                   if not IsNan(ObmA.Qf[n]) then
                     Q_m := ObmA.Qf[n]
                end;
              end;
              ObmList.S_max := S_m;
              if (Q_m <> huge_flt) and (S_m > Q_m) and (S_m>0) and (Q_m>0) then
                ObmList.tg_fi := Q_m / Sqrt(S_m*S_m - Q_m*Q_m);
              S_podst := S_podst + S_m;
            end;
            K_zagr := S_podst/TransList.S_nom_min;
            if K_zagr>=k_kr then
            begin
              if not DN_Is then
              begin
                N_m:=K_zagr;
                PDN := TPrognozItem.Create;
                DN_Is := True;
                PDN.StartDt:=dt;
                PDN.PikDt:=dt;
                PDN.EndDt:=dt;
                PDN.PikS:=S_podst;
                PDN.Pik:=K_zagr;
                npl.Add(PDN);
                for i := 0 to TransList.Count-1 do
                begin
                  ObmList := TransList.Items[i];
                  TransInfo := TTransInfoRorPrognozItem.Create;
                  TransInfo.tr_id := ObmList.tr_id;
                  TransInfo.Nagr_fact := 100*ObmList.S_max/ObmList.S_nom;
                  TransInfo.tg_fi := ObmList.tg_fi;
                  PDN.TransInfoList.Add(TransInfo);
                end;
              end else
              begin
                PDN.EndDt:=dt;
                if N_m<K_zagr then
                begin
                  PDN.Pik:=K_zagr;
                  PDN.PikS:=S_podst;
                  PDN.PikDt:=dt;
                end;
              end;
            end else
            if DN_Is then
            begin
              DN_Is := False;
              if SecondsBetween(PDN.StartDt, PDN.EndDt) < t_kr then
              begin
                npl.Remove(PDN);
                PDN.Free;
              end;
            end;
            if (n = (Quan - 1)) and DN_Is then // ���� ���� �������� � ����������
            begin
              if SecondsBetween(PDN.StartDt, PDN.EndDt) < t_kr then
              begin
                npl.Remove(PDN);
                PDN.Free;
              end;
            end;
          end;

          //��� ��������� � ����
          WriteLog('��������� ���������: '+IntToStr(npl.Count)+' �������',oik);
          for i := 0 to npl.Count-1 do
          begin
            PDN := npl.Items[i];
            WriteLog(FloatToStr(PDN.Pik*100)+'% '+DateTimeToStr(PDN.PikDt),oik);
          end;
          try
          Lock.Enter;
          npl.InsertToDB(StartDate, IncHour(StartDate, period));
          finally
            Lock.Leave;
          end;

          finally
            for i := 0 to npl.Count-1 do
                TPrognozItem(npl.Items[i]).Free;
            npl.Free;
          end;


        finally
          if TransDS.Active then
            TransDS.Close;
          TransDS.Free;

          for i := 0 to TransList.Count-1 do
          begin
            ObmList := TransList.Items[i];
            for j:=0 to ObmList.Count-1 do
                TObmotkaArray(ObmList.items[j]).Free;
            ObmList.Free;
          end;
          TransList.Free;
        end;
      end
      else
      begin
        WriteLog('�� ' + pName + ' �� ����� ��� �������', oik);
      end;
      WriteLog('����� ��������� �� ' + pName, oik);
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

{$POINTERMATH OFF}

procedure TZTService.ExeWork;
var
  po, oik: String;
  fld: TField;

//  Handles: array of THandle;
//  Threads: array of TPOThread;

//  Lock: TCriticalSection;
  I,N, poId: Integer;
begin
  ADOConnection1.Connected := True;
  try
    if ADOConnection1.Connected then
    begin
      WriteLog('���������� � SQL-�������� �����������');
      PoTable.Open;
      PoTable.First;
//      N:= PoTable.RecordCount;
//      SetLength(Handles, N);
//      SetLength(Threads, N);
//      I:=0;
      while not PoTable.Eof do
      begin
        po := Trim(PoTable.FieldByName('short_name').AsString);
        poId := PoTable.FieldByName('id').AsInteger;
//        WriteLog('������ �������� ������ �� ' + po);
        if PoList.IndexOf(IntToStr(poId)) >= 0 then
        begin
          fld := PoTable.FieldByName('oik');

          if not (fld.IsNull or (Trim(fld.AsString) = '')) then
             oik := Trim(PoTable.FieldByName('oik').AsString)
          else  oik := '';
          Get_PO_Data(poid,po,oik);
//          Threads[I]:= TPOThread.Create(poId, po, oik);
//          Handles[I] := Threads[I].Handle;
        end;
//        else
//        begin
//          Threads[I]:= Nil;
//        end;
//        Inc(I);
        PoTable.Next;
      end;

//      for I := 0 to N - 1 do
//      begin
//        if Assigned(Threads[I]) then
//        begin
//          Threads[I].Start;
//          WaitForSingleObject(Handles[I], INFINITE);
//        end;
//      end;
      // Wait until threads terminate
      // This may take up to ArrLen - 1 seconds
      //WaitForMultipleObjects(N, @Handles, True, INFINITE);

      // Destroy thread instances
//      for I := 0 to N - 1 do
//       if Assigned(Threads[I]) then
//        Threads[I].Free;
    end
    else
    begin
      WriteLog('������! ���������� � SQL-�������� �� �����������!');
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

procedure TZTService.Get_PO_Data(poid: Integer; poNm, oikName: String);
var
hr: HResult;
begin
  if oikName<>'' then
  begin
      if tmInit(PAnsiChar(AnsiString(oikName)), 'ZT') = 1 then
      begin
        WriteLog('��-������ '+ oikName + ' ���������');

        hr := CoInitialize(nil);
        try
        WriteLog('�������� '+poNm+' ��������');
        DataProc(poid, oikName);
        finally
          tmClose;
          case hr of
            S_OK, S_FALSE:
              CoUninitialize;
          end;
          WriteLog('�������� '+poNm+' ���������');
        end;

        WriteLog('��-������ ' + oikName + ' ����������');
      end
      else
      begin
        WriteLog('������! ��-������ ' + oikName + ' �� ���������');
      end;
  end
  else ZTService.WriteLog('�� ����� ���');

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
// // LogStr := DateTimeToStr(Now) + '> ' + '������ ������� �� ' +DateTimeToStr(TimeRun);
// WriteLog('������ ������� �� ' + DateTimeToStr(TimeRun));
// Timer := TWaitableTimer.Create(false, nil, '');
// Timer.Time := TimeRun; // ����� �����������
// Timer.Period := 0; // ��� ���������, ����������� ���� ���
// Timer.Start; // ������ �������
// if Timer.Wait(INFINITE) <> wrError then
// begin
// if not Terminated then
// begin
// // WaitForSingleObject(Semaphore, INFINITE);
// // LogStr := DateTimeToStr(Now) + '> ' + '������ ��������';
// WriteLog(DateTimeToStr(Now) + '> ' + '������ ��������');
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
// WriteLog('�������� ���������');
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
  WriteLog('����� �������');
  PoList := TStringList.Create;
  ifl := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    ADOConnection1.ConnectionString := ifl.ReadString('Path', 'SQL',
      ADOConnection1.ConnectionString);
    PoList.CommaText := ifl.ReadString('Path','ListPO', '');
    AutoTime := ifl.ReadBool('Time','at',TRUE);
    h1 := ifl.ReadInteger('Time', 'hh', 5);
    m1 := ifl.ReadInteger('Time', 'mm', 0);
    s1 := ifl.ReadInteger('Time', 'ss', 0);
    t_kr := ifl.ReadInteger('Algoritm', 'tkr', 180);
    k_kr := ifl.ReadFloat('Algoritm', 'kkr', 0.9);
    step := ifl.ReadInteger('Algoritm', 'retro_step', 20);
    period := ifl.ReadInteger('Algoritm', 'run_period', 24);
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
  PoList.Free;
  WriteLog('���� �������');
  if Assigned(Timer) then
    Timer.Free;
end;

// ServiceThread.ProcessRequests(false);
// Sleep(1000);
// End;
// end;

procedure TZTService.WriteLog(txt: String; oik: String='');
var
  Filename: string;
  LogFile: TextFile;
begin
  Lock.Enter;
  // prepares log file
  if oik<>'' then
  begin
    oik := StringReplace(oik,'\','_', [rfReplaceAll, rfIgnoreCase]);
    Filename := ExtractFilePath(ParamStr(0))+ oik+'.log';
  end else
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
    Lock.Leave;
  end;

end;

{ TSparkyThread }

procedure TSparkyThread.Execute;
var
  yy, mn, dd, hh, mm, ss, ms: Word;
  SUCCESS: HResult;
  CurDT: TDateTime;
begin
    CurDT := Now;
    DecodeDateTime(CurDT, yy, mn, dd, hh, mm, ss, ms);
    With ZTService do
    begin
      if  AutoTime then
       TimeRun := IncMinute(CurDt, 1) else
      begin
        TimeRun := EncodeDateTime(yy, mn, dd, h1, m1, s1, 0);
        if CurDT > TimeRun then
        begin
          TimeRun := IncHour(TimeRun, period);//IncDay(TimeRun);
        end;
      end;
      WriteLog('������ ���������� �� ' + DateTimeToStr(TimeRun));
      Timer := TWaitableTimer.Create(False, nil, '');
      try
        Timer.Time := TimeRun; // ����� �����������
        //Timer.period := 0; // ��� ���������, ����������� ���� ���
        Timer.period := period*60*60*1000;
        Timer.Start; // ������ �������
        while not Terminated do
          if Timer.Wait(INFINITE) <> wrError then
          begin
            if not Terminated then
            begin
              // WaitForSingleObject(Semaphore, INFINITE);
              // LogStr := DateTimeToStr(Now) + '> ' + '������ ��������';
              WriteLog('������ ��������');
              SUCCESS := CoInitialize(nil);
              try
                ExeWork;
              finally
                case SUCCESS of
                  S_OK, S_FALSE:
                    CoUninitialize;
                end;
//                WriteLog('�������� ���������');
                TimeRun := IncHour(TimeRun, period);
                WriteLog('������ ���������� �� ' + DateTimeToStr(TimeRun));
              end;
            end;
            /// /if not Terminated then
          end else
            WriteLog('������ �������');
      finally
        Timer.Free;
      end;
      // ProcessRequests(false);
    end;
//  end;
end;



{ TPOThread }

//constructor TPOThread.Create(poid: Integer; poNm, oikname: String);
//begin
//  oik := oikname;
//  poName := poNm;
//  po_id := poid;
//  //inherited Create(False); // ����������� ����� ����� �������� (False)
//  inherited Create(True);
//end;
//
//procedure TPOThread.Execute;
//var
//hr: HResult;
//begin
//  if oik<>'' then
//  With ZTService do
//  begin
////    SUCCESS := CoInitialize(nil);
////    try
//      if tmInit(PAnsiChar(AnsiString(oik)), 'ZT') = 1 then
//      begin
//        WriteLog('��-������ '+ oik + ' ���������');
//
//        hr := CoInitialize(nil);
//        try
//        WriteLog('�������� '+poName+' ��������');
//        DataProc(po_id, oik);
//        finally
//          tmClose;
//          case hr of
//            S_OK, S_FALSE:
//              CoUninitialize;
//          end;
//          WriteLog('�������� '+poName+' ���������');
//        end;
//
//        WriteLog('��-������ ' + oik + ' ����������');
//      end
//      else
//      begin
//        WriteLog('������! ��-������ ' + oik + ' �� ���������');
//      end;
////    finally
////      case SUCCESS of
////        S_OK, S_FALSE:
////          CoUninitialize;
////      end;
////      WriteLog('�������� ���������');
////    end;
//  end
//  else ZTService.WriteLog('�� ����� ���');
//
//end;

initialization
  Lock:=TCriticalSection.Create;

finalization
  Lock.Free;

end.
