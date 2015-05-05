unit tma_defs;

interface
uses Windows;
const
    SUCCESS:             Word = 1;
    FAILURE:             Word = 0;

    UNRELIABLE_HDW:      Word = $0001;
    UNRELIABLE_MANU:     Word = $0002;
    REQUESTED:           Word = $0004;
    MANUALLY_SET:        Word = $0008;
    LEVEL_A:             Word = $0010;
    LEVEL_B:             Word = $0020;
    LEVEL_C:             Word = $0040;
    LEVEL_D:             Word = $0080;
    INVERTED:            word = $0100;
    FROM_BACKUP:         word = $0200;
    UNDER_CONTROL:       word = $0400;
    IS_APS:              word = $0800;
    F_STREAMING:         word = $1000;
    F_ABNORMAL:          word = $2000;
    F_UNACKED:           word = $4000;

    F_HAVERES		 =$00010000;    // Есть резервное значение
    F_AN_UNSIGNED        =$00020000;    // Заносить код как беззнаковое
    F_NO_RETRO           =$00040000;    // Не заносить в ретроспективу или журнал событий
    F_NO_ZERO		 =$00080000;    // Не обнулять значение при приходе кода 0
    F_FORMAT		 =$00100000;    // Форматировать значение при занесении
    F_EXTERNAL		 =$00200000;    // От внешнего сервера
    F_EXPRESSION	 =$00400000;    // Вычисляется по выражению
    F_CAN_OUTDATE        =$00800000;    // Значение может устаревать
    F_HAVE_NORMAL        =$01000000;    // Есть нормальное значение
    F_RESERVED25         =$02000000;    //
    F_RESERVED26         =$04000000;    //
    F_RESERVED27         =$08000000;    //
    F_RESERVED28         =$10000000;    //
    F_RESERVED29         =$20000000;    //
    SF_CONFIG		 =$40000000;    //
    SF_INIT		 =$80000000;    //

        FLAGS_IGNORE  =	$00;
        FLAGS_SET     = $01;
        FLAGS_CLEAR   = $02;
        FLAGS_COPY    = $03;
        FLAGS_RESET   = $10;


    TMCPF_NAME           = $01;
    TMCPF_ALLFLAGS       = $02;

    evSTATUS_CHANGE      = $0001;
    evALARM              = $0002;
    evCONTROL            = $0004;
    evMANUAL_CONTROL     = $0008;
    evMANUAL_STATUS_SET  = $0010;
    evMANUAL_ANALOG_SET  = $0020;
    evOLD_MASK           = $00ff;
    evEXTENDED           = $8000;
    evEXTENDED_LINK      = $2000;

    EXTEVL_KIND_STRBIN     = $100;


    drQ_ALL_TS:          Word = $0003;
    drQ_TIT:             Word = $001b;
    drMAKE_TU:           Word = $0004;
    drACKNOWLEDGE:       Word = $001D;
    drACK_ANALOG:        Word = $0021;

    TM_STATUS            = $8000;
    TM_ANALOG            = $8001;
    TM_ACCUM             = $8002;
    TM_CHANNEL           = $9000;
    TM_RTU               = $9001;
    TM_ANALOG_ALARM      = $9021;
    TM_RETRO_STATUS      = $9010;
    TM_RETRO_ANALOG      = $9011;
    TM_RETRO_ACCUM       = $9012;

    RETRO_STATUS_ELEMENT = $3153;
    RETRO_ANALOG_ELEMENT = $314e;
    RETRO_ACCUM_ELEMENT  = $3143;
    MAX_RETRONUM         = 31;

    TMCTLERR_INVALID_ADDRESS   =  0;
    TMCTLERR_NO_RESOURCES      = -1;
    TMCTLERR_TMSOURCE_FAILED   = -2;
    TMCTLERR_WAIT_TIMEOUT      = -3;
    TMCTLERR_CANNOT_REDIRECT   = -4;
    TMCTLERR_NO_TMSOURCE       = -5;
    TMCTLERR_NO_KEYCODE        = -6;
    TMCTLERR_WRONG_KEYCODE     = -7;
    TMCTLERR_KEYCODE_TIMEOUT   = -8;
    TMCTLERR_USER_NAME_UNKNOWN = -9;
    TMCTLERR_ACCESS_DENIED     = -10;
    TMCTLERR_NOT_SUPPORTED     = -11;
    TMCTLERR_NO_TM_SERVER      = -12;
    TMCTLERR_WRONG_KEY	        = -13;
    TMCTLERR_SCRIPT_ERROR      = -14;
    TMCTLERR_EXCEPT	        = -15;
{$ALIGN OFF}
type
    TADRtm = record
        Ch:    SmallInt;
        RTU:   SmallInt;
        Point: SmallInt;
    end;

    TStatusPoint = record
        Status: SmallInt;
        Flags:  Word;
    end;

    TAnalogPoint = record
        asFloat: Single;
        asCode:  SmallInt;
        Flags:   Word;
        Units:   array [0..7] of Char;
    end;

    TAccumPoint  = record   // Объект ТИИ
        Value: Single;
        Load:  Single;
        Flags:   Word;
        Units: array [0..7] of Char;
    end;

    TCommonPoint = record
        Name:           PAnsiChar;
        CP_Flags:       Byte;
        Res1:           Byte;

        TM_Type:        Word;
        Ch:             Word;
	RTU:            Word;
	Point:          Word;
	TM_Flags:       Dword;

	Res2: array [0..3] of Dword;
        Data: array [0..31] of Byte;
    end;

    TEvent       = record
        DateTime: array [0..23] of Char;
        Imp:      Word;
        ID:       Word;

        Ch:       Word;
        RTU:      Word;
        Point:    Word;

        Data:     array [0..21] of Byte;
    end;

    TTMSEvent = record
        utime:         DWORD;
        hund:           BYTE;
        Imp:            BYTE;
        ID:             WORD;
        Ch_Or_Kind:     BYTE;
        Rtu:            BYTE;
        Point_Or_Datalen: WORD;
        Data:   array [0..21] of Byte;
    end;

    pPAnsiChar       = ^PAnsiChar;
    pEventEx     = ^TEventEx;

    TEventEx     = record
        next:   pEventEx;
        size:   Dword;
        DateTime: array [0..23] of AnsiChar;
        Imp:    Word;
        ID:     Word;
        Ch_Or_Kind: Word;
        Rtu_Or_Datalen:Word;
        Point: Word;
        Data:   array [0..21] of Byte;
    end;

    TStatusData  = record
        State:    Byte;
        _Class:   Byte;
        ExtDataSig: Cardinal;
//#define EVL_ST_RSRV_SIG	'RSRV' ($52535256)
//#define EVL_ST_EXT_SIG	0xEEAAEE00
//#define EVL_ST_EXTF_RESERVE		1
//#define EVL_ST_EXTF_FIXTIME		2
        resCh:       BYTE;
        resRTU:      BYTE;
        resPoint:    WORD;
        FixTime:    Cardinal;
    end;
    TAlarmData   = record
        Val:      Single;
        AlarmID:  Word;
        State:    Byte;
    end;
    TOIKControlData = record
        Ch:       Byte;
        RTU:      Byte;
        Point:    Word;
        Cmd:      Byte;
        Result:   Byte;
        UserName: array [0..15] of AnsiChar;
    end;
    TAnalogSetData = record
        Value:    Single;
        Cmd:      Byte;
        UserName: array [0..15] of AnsiChar;
    end;
    TExtendLinkData = record
        Index: Dword;
    end;
    TStrBinData = record
        Source:   Dword;
        StrBin:   array [0..0] of AnsiChar;
    end;
    TRetroInfo   = record
        TII_RETRO_PERIOD: Word;
        TII_RETRO_DEPTH:  Word;
        TIT_RETRO_PERIOD: array[0..2] of Word;
        TIT_RETRO_DEPTH:  array[0..2] of Word;
        TIT_RETRO_NAME:   array[0..2,0..29] of AnsiChar;
    end;
    TRetroInfoEx = record
        rType: Word;
        rName: array [0..127] of AnsiChar;
        rDescr: array [0..29] of AnsiChar;
        rPeriod: Cardinal;
        rCapacity: Cardinal;
        rStart: Cardinal;
        rStop: Cardinal;
        rRecCount: Cardinal;
        reserved: array[0..15] of Cardinal;
    end;


    TAlarm = record
    	 Point:     Word;
        RTU:       Byte;
        Ch:        Byte;
        GroupID:   Byte;
        AlarmID:   Byte;
        Value:   Single;
        BitFields: Word; // xxxx xxxx xxxx xxx1 - Sign
                         // xxxx xxxx 1111 111x - Sensibility
                         // xxxx xx11 xxxx xxxx - Active
                         // xxxx 11xx xxxx xxxx - InUse
                         // 1111 xxxx xxxx xxxx - Importance
        Period:    Word;
        DayMap: array[0..5] of Byte;
        WeekMap:   Byte;
        YearMap: array[0..5] of Byte;
        InDirect:  Byte;
        CountDown: Word;
        Sum:     Double;
    end;

    pADRtm       = ^TADRtm;
    pSP          = ^TStatusPoint;
    pAP          = ^TAnalogPoint;
    pAcP         = ^TAccumPoint;
    pAL          = ^TAlarm;
    pEV          = ^TEvent;
    pTMSEV       = ^TTMSEvent;
    pCommonPoint = ^TCommonPoint;
{$ALIGN ON}
implementation

end.
