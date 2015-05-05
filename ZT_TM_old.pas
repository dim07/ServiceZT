unit ZT_TM;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes;

type
  TSmallIntSet = set of 0 .. SizeOf(SmallInt) * 8 - 1;
  // type
  // TIntegerSet = set of 0..SizeOf(Integer)*8 - 1;
  // var
  // I : Integer;
  // N : Integer;
  // begin
  // Include(TIntegerSet(I), N);     // установили N-ный бит в 1
  // Exclude(TIntegerSet(I), N);     // сбросили N-ный бит в 0
  // if N in TIntegerSet(I) then...  // проверили N-ный бит
  // end;

  TObmotka = (VN = 1, SN, NN1, NN2);
  TNParam = (II = 1, SS, PP);

  TNagrItem = class
    Pik: Single;
    StartDt, PikDt, EndDt: TDateTime;
  end;

  TNagrList = class(TList)
  private
    function GetMax: Integer;
  public
    nominal: Double;
    Obmotka: TObmotka;
    np: TNParam;
    Step: SmallInt;
    zagr: Double;
    destructor Destroy; override;
    function GetRetroData(StartDate: TDateTime;
      StepSec, Period, Ch, RTU, Point: SmallInt): Boolean;
  end;

  PXSmallIntArray = ^TXSmallIntArray;
  TXSmallIntArray = array [0 .. MaxInt div SizeOf(SmallInt) - 1] of SmallInt;
  PXSingleArray = ^TXSingleArray;
  TXSingleArray = array [0 .. MaxInt div SizeOf(Single) - 1] of Single;

implementation

uses tmaccess, tma_defs, DB, Math, DateUtils, ADODB, main;

{ TNagrList }

destructor TNagrList.Destroy;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TNagrItem(items[i]).Free;
  inherited;
end;

function TNagrList.GetMax: Integer;
var
  i, im: Integer;
  p, pm: Single;
begin
  im := 0;
  pm := 0;
  for i := 0 to Count - 1 do
  begin
    p := TNagrItem(items[i]).Pik;
    if p >= pm then
    begin
      pm := p;
      im := i;
    end;
  end;
  Result := im;
end;

{$POINTERMATH ON}

function TNagrList.GetRetroData(StartDate: TDateTime;
  StepSec, Period, Ch, RTU, Point: SmallInt) : Boolean ;
var
  values: PXSingleArray;
  flags: PXSmallIntArray;
  i, index: Integer;
  sDT: String;
  // SN: Single;
  // Nomin: Single;
  DN: TNagrItem;
  MaxNagr: Single;
  StartDt, MaxDt, EndDt: TDateTime;
  SecDlit: Int64;
  DN_Is, Max_Is: Boolean;
  RetroInfoEx: array[0..MAX_RETRONUM] of TRetroInfoEx;
  real_step: Cardinal;
  Quan: SmallInt;
begin

    sDT := FormatDateTime('DD.MM.YYYY HH:NN:SS', StartDate);
    Step:=StepSec;
    // Application.ProcessMessages;
    index := -1;
    real_step:=0;
    FillMemory(@RetroInfoEx[0], sizeof(RetroInfoEx), 0);
    for i := 0 to tma_defs.MAX_RETRONUM do
    begin
      if tmRetroInfoEx(i, RetroInfoEx[i]) = tma_defs.FAILURE then
        break else
      begin
        if $314e = RetroInfoEx[i].rType then
        begin
//          ZTService.WriteLog('Retro '+IntToStr(i)+': '+IntToStr(RetroInfoEx[i].rPeriod));
          if (step>=RetroInfoEx[i].rPeriod) and (real_step < RetroInfoEx[i].rPeriod) then
          begin
            real_step:= RetroInfoEx[i].rPeriod;
            index := i;
          end;
        end;
      end;
    end;
    if index = -1 then
    begin
    real_step:=4294967295;
      for i := 0 to tma_defs.MAX_RETRONUM do
      begin
        if tmRetroInfoEx(i, RetroInfoEx[i]) = tma_defs.FAILURE then
          break
        else
        begin
          if $314e = RetroInfoEx[i].rType then
          begin
            if real_step > RetroInfoEx[i].rPeriod then
            begin
              real_step:= RetroInfoEx[i].rPeriod;
              step := real_step;
              index := i;
            end;
          end;
        end;
      end
    end;
    if index > -1 then
    begin
      Quan := 3600*period div step;
      GetMem(values, Quan * SizeOf(Single));
      GetMem(flags, Quan * SizeOf(SmallInt));
      try
      tmTakeRetroTit(Ch, RTU, Point, PAnsiChar(AnsiString(sDT)), Step, Quan, index,
        PSingle(values), PSmallInt(flags));

      MaxNagr := 0;
      MaxDt := StartDate;
      // StDt:= StartDate;
      // SecMax:=0;
      DN_Is := False;
      Max_Is := False;
      for i := 0 to Quan - 1 do
      begin
        if (UNRELIABLE_HDW in TSmallIntSet(flags^[i])) or
           (values^[i] > 1000000)
        then Continue;
        if values^[i] >= k_kr * nominal then
        begin
          if not DN_Is then
          begin
            DN := TNagrItem.Create;
            DN_Is := True;
            DN.StartDt := IncSecond(StartDate, i * StepSec);
            DN.Pik := values^[i];
            DN.PikDt := DN.StartDt;
            DN.EndDt := DN.StartDt;
            Add(DN);
          end else
          begin
            if values^[i] > DN.Pik then
            begin
              DN.Pik := values^[i];
              DN.PikDt := IncSecond(StartDate, i * StepSec);
            end;
            DN.EndDt := IncSecond(StartDate, i * StepSec);
          end;
        end else
        if DN_Is then
        begin
          DN_Is := False;
          if SecondsBetween(DN.StartDt, DN.EndDt) < t_kr then
          begin
            Remove(DN);
            DN.Free;
          end;
        end;

        if (i = Quan - 1) and DN_Is then // если цикл кончился с перегрузом
        begin
          if SecondsBetween(DN.StartDt, DN.EndDt) < t_kr then
          begin
            Remove(DN);
            DN.Free;
          end;
        end;

        if values^[i] > MaxNagr then
        begin
          MaxNagr := values^[i];
        end;
        zagr := 100 * MaxNagr / nominal;
      end;
      finally
        FreeMemory(values);
        FreeMemory(flags);
      end;
    end;
    Result := (index>-1);
end;
{$POINTERMATH OFF}
end.
