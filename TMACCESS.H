#pragma pack(1)

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __TIME_H
#include <time.h>
#endif

#define TM_KERNEL_SIGNATURE 0x0830

#define SUCCESS 1                 // �������� ���������� �����
#define FAILURE 0                 // ������ ��� ��������� �������

/*------------- ����������� ������ �������������� -----------------*/
#define UNRELIABLE_HDW     0x0001   // ��������������� ����������
#define UNRELIABLE_MANU    0x0002   // ��������������� �� ������������
#define REQUESTED          0x0004   // ���� �����
#define MANUALLY_SET       0x0008   // ����������� �������
#define NO_ALARMS          0x0000   // ��� � �����
#define LEVEL_A            0x0010   // ��������� ������� ������� ������
#define LEVEL_B            0x0020   // ------- " ------- ������� ������
#define LEVEL_C            0x0040   // ------- " ------- �������� ������
#define LEVEL_D            0x0080   // ------- " ------- ���������� ������
#define INVERTED           0x0100   // �� ������������� ��� �������

/*------------------------ ���� ������� ---------------------------*/
#define evSTATUS_CHANGE      0x0001   // ���������
#define evALARM              0x0002   // ������� ���
#define evCONTROL            0x0004   // ��������������
#define evMANUAL_CONTROL     0x0008   // �� �� ����
#define evMANUAL_STATUS_SET  0x0010   // ����������� ��������� ��

/*--------------- ��������� ��� �������� ������� ------------------*/
#define tmSYSTEM_TIME        001
#define tmCONTROL            601
#define tmSTATUS             602
#define tmSTATUS_FULL        603
#define tmANALOG             604
#define tmANALOG_FULL        605
#define tmACCUM_VALUE        617
#define tmACCUM_LOAD         618
#define tmACCUM_FULL         619
#define tmSET_STATUS         606
#define tmFILL_STATUS_GROUP  607
#define tmSET_STATUS_FLAGS   608
#define tmCLR_STATUS_FLAGS   609
#define tmSET_ANALOG         610
#define tmSET_ANALOG_BY_CODE 611
#define tmFILL_ANALOG_GROUP  612
#define tmSET_ANALOG_FLAGS   613
#define tmCLR_ANALOG_FLAGS   614
#define tmINC_ACCUM_POINTS   620
#define tmSET_ACCUM_VALUE    621
#define tmSET_ACCUM_FLAGS    622
#define tmCLR_ACCUM_FLAGS    623
#define tmREG_EVENT          615
#define tmEVENT_LOG          616
#define tmPEEK_ALARM         625
#define tmPOKE_ALARM         626
#define tmENUM_ALARMS        627
#define tmSTATUS_BY_LIST     628
#define tmANALOG_BY_LIST     629
#define tmACCUM_BY_LIST      630

#define tmDRIVER_CALL        500
#define tmTAKE_APS           505
#define tmRETRO_INFO         508
#define tmTAKE_RETRO_TIT     509

#define WINSERV_CODE         0x1000
#define tmSERV_EX			 (WINSERV_CODE+2);
#define tmxENUM_OBJECTS        0
#define tmxRETRO_INFO_EX       1
#define tmxGET_OBJECT_NAME     2
#define tmxCONTROL_BY_STATUS  15
#define tmxSTATUS_FULL_EX	  23
#define tmxSTATUS_BY_LIST_EX  24

#define drQ_ALL_TS    003
#define drQ_ALL_TIT   006
#define drQ_ALL_TII   013
#define drQ_TIT       033
#define drMAKE_TU     004
#define drSEND_BUF    034
#define drACKNOWLEDGE 035

#define TM_STATUS       ((WORD)0x8000)
#define TM_ANALOG       ((WORD)0x8001)
#define TM_ACCUM        ((WORD)0x8002)
#define TM_CHANNEL      ((WORD)0x9000)
#define TM_RTU          ((WORD)0x9001)
#define TM_ALARM_ANALOG ((WORD)0x9021)
/*-------------------------------- * ------------------------------*/

typedef struct
	{
    short Ch;
    short RTU;
    short Point;
    } TADRtm;

typedef struct
	{
	short Status;            // ��������� �������
	short Flags;             // ���
	} TStatusPoint;  // ������ ��

typedef struct
	{
	float asFloat;           // �������� �������� ���
	short asCode;            // ��� ���, ����������� � ��
	short Flags;             // ���
	char  Unit[8];           // ������� ���������
	} TAnalogPoint;  // ������ ���

typedef struct
    {
    short           Point;
    char            RTU;
    char            Ch;
	char 			GroupId;
	char 			AlarmId;
	float 			Value;
	unsigned 		Sign		:1;
	unsigned 		Sensibility	:7;
	unsigned 		Active		:2;
	unsigned 		InUse		:2;
	unsigned 		Importance	:4;
	unsigned short 	Period;
	char 			DayMap[6];
	char 			WeekMap;
	char 			YearMap[6];
	char 			InDirect;
	unsigned short 	CountDown;
	double 			Sum;
    } TAlarm;

typedef struct
	{
	float Value;             // �������� ��������
	float Load;              // ��������
	short Flags;             // ���
	char Unit[8];            // ������� ���������
	} TAccumPoint;   // ������ ���

typedef struct
	{
	char DateTime[24];       // ����� ������� � ������� ��.��.���� ��:��:��.cc

	unsigned short Imp;      // ������� ������
	unsigned short ID;       // ��� �������

	unsigned short Ch;       // ����
	unsigned short RTU;      // ����� ��  (c 1)
	unsigned short Point;    // ������    (c 1)

	char Data[22];
	} TEvent;      // �������

struct StatusData  // ��������� ������������ ��
	{
	char State;    // ����� ��������� ��
	char Class;    // ����� ����������� (�.�. - 0  ��� - 1)
	};
struct AlarmData   // ��������� ����������� ������
	{
	float Val;     // �������� ��������������� ���
	short AlarmID; // ������������� ������
	char  State;   // 0 - ������� �����, 1 - ������� ��������
	};
struct ControlData // ��������� ��������� ��������������
	{
	char  Ch;
	char  RTU;
	short Point;
	char  Cmd;     // �������� �������
	char  Result;  // == SUCCESS ���� �� �������, ����� FAILURE
	char  UserName[16];  // ������������, �������� ��
	};
typedef struct
    {
    unsigned short TII_RETRO_PERIOD;
    unsigned short TII_RETRO_DEPTH;
    unsigned short TIT_RETRO_PERIOD[3];
    unsigned short TIT_RETRO_DEPTH[3];
    char           TIT_RETRO_NAME[3][30];
    } TRetroInfo;

typedef struct {
	WORD	type;
	CHAR	name[128];
	CHAR	descr[30];
	DWORD	period;
	DWORD	capacity;
	DWORD	start;
	DWORD	stop;
	DWORD	rec_count;
	DWORD	reserved[16];
}TRetroInfoEx;

#ifdef IN_LIBRARY
__declspec(dllexport)
#else
__declspec(dllimport)
#endif
float huge_flt;


#ifndef IN_LIBRARY
/*----------------------- ����� ������� --------------------------*/

//***************************************************************
/*	�������:*/  short __stdcall tmInit(const char *ServerName,
									   const char *LocalName);
//	��������:       ��� ������� �������������� ����������
//					������� � ������������
//
//	���������:      ServerName - ��� �������
//                  LocalName  - ��� ��������� �����
//
//	�������:        SUCCESS - ������������� �������
//					FAILURE - ������, ������ ����������
//***************************************************************

//***************************************************************
/*	�������:*/  void __stdcall tmClose(void);
//
//	��������:       ��������� �����  ������ � ����������� ��
//
//	���������:      ��
//
//	�������:        ��
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmControl(short Ch, short RTU, short Point,
										  short Cmd);
//
//	��������:       ������ ������� ��������������
//
//	���������:      Ch    - �����,
//					RTU   - ����� �� (� 1),
//					Point - ����� ������� (� 1)
//					Cmd - ������� �� (0-����, 1-���)
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmSystemTime(char *DateTime, struct tm *tm);
//
//	��������:       ������ ������� �� ��-�������
//
//	���������:      DateTime - ����� ������ ��� ������ ������
//                             � ������� "��.��.���� ��:��:��" ��� NULL
//					tm       - ����� ��������� tm (��. TIME.H) ��� NULL
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************


/*--------------- ������� ��������� ������ -----------------------*/

//***************************************************************
/*	�������:*/  short __stdcall tmStatus(short Ch, short RTU, short Point);
//
//	��������:       ���������� ��������� ������� ��
//
//	���������:      Ch    - �����,
//					RTU   - ����� �� (� 1),
//					Point - ����� ������� (� 1)
//
//	�������:        0 - ����,  1 - ��
//				   -1 - ������, ��� ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmStatusFull(short Ch, short RTU, short Point,
											 TStatusPoint *SP);
//
//	��������:       ���������� ��������� ������� �� � ���������
//
//	���������:      Ch, RTU, Point - ��. ����
//					SP             - ��������� �� ��������� ������� ��
//
//	�������:        SUCCESS - �����
//					FAILURE - ������, ��� ������
//***************************************************************

//***************************************************************
/*	�������:*/  float __stdcall tmAnalog(short Ch, short RTU, short Point,
										 const char  *DateTime, short RetroNum);
//
//	��������:       ���������� �������� ������� ���
//
//	���������:      Ch, RTU, Point - ��. ����
//					DateTime, RetroNum - ������������ ��������� ���������
//									     �������� �� �������������.
//                                       DateTime �������� � �������
//                                       "��.��.�� ��:��:��"
//									     ���� ���������� ������� ��������,
//									     �� DateTime == NULL
//
//	�������:        �������� �������� ��� ��� huge_flt ��� ���������� ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmAnalogFull(short Ch, short RTU, short Point,
											 TAnalogPoint *AP,
											 const char *DateTime,
											 short RetroNum);
//
//	��������:       ���������� �������� ������� ��� � ���������
//
//	���������:      Ch, RTU, Point - ��. ����
//					AP             - ��������� �� ��������� ���
//									 ���� AP->asFloat == _huge_flt ��
//									 �������������� �� ���� � �������� ��
//									 ������������. ��� ���� �����������
//									 ����� �������.
//					DateTime, RetroNum - ������������ ��������� ���������
//									     �������� �� �������������.
//                                       DateTime �������� � �������
//                                       "��.��.�� ��:��:��"
//									     ���� ���������� ������� ��������,
//									     �� DateTime == NULL
//
//	�������:        SUCCESS - �����
//					FAILURE - ������, ��� ������
//***************************************************************

//***************************************************************
/*	�������:*/  float __stdcall tmAccumValue(short Ch, short RTU, short Point,
											 const char *DateTime);
//
//	��������:       ���������� �������� �������� ���
//
//	���������:      Ch, RTU, Point - ��. ����
//					DateTime - ������������ �������� ���������
//							   �������� �� �������������.
//                             DateTime �������� � �������
//                             "��.��.�� ��:��:��"
//							   ���� ���������� ������� ��������,
//							   �� DateTime == NULL
//
//	�������:        �������� �������� ��� ��� huge_flt ��� ������
//***************************************************************

//***************************************************************
/*	�������:*/  float __stdcall tmAccumLoad(short Ch, short RTU, short Point,
											const char *DateTime);
//
//	��������:       ���������� �������� �������� �� ���
//
//	���������:      Ch, RTU, Point - ��. ����
//					DateTime - ������������ �������� ���������
//							   �������� �� �������������.
//                             DateTime �������� � �������
//                             "��.��.�� ��:��:��"
//							   ���� ���������� ������� ��������,
//							   �� DateTime == NULL
//
//	�������:        �������� �������� ��� huge_flt ��� ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmAccumFull(short Ch, short RTU, short Point,
											TAccumPoint *AP,
											const char *DateTime);
//
//	��������:       ���������� �������� ������� ��� � ���������
//
//	���������:      Ch, RTU, Point - ��. ����
//					AP       - ��������� �� ��������� ���
//					DateTime - ������������ �������� ���������
//							   �������� �� �������������.
//                             DateTime �������� � �������
//                             "��.��.�� ��:��:��"
//							   ���� ���������� ������� ��������,
//							   �� DateTime == NULL
//
//	�������:        SUCCESS - �����
//					FAILURE - ������, ��� ������
//***************************************************************


/*--------------- ������� ��������� ������ -----------------------*/

//***************************************************************
/*	�������:*/  short __stdcall tmSetStatus(short Ch, short RTU, short Point,
											char Value,
											const char *DateTime);
//
//	��������:       ������ ��������� ������� ��
//
//	���������:      Ch    		   - �����,
//					RTU            - ����� �� (� 1),
//					Point          - ����� ������� (� 1)
//					Value          - ����� �������� ��
//					DateTime       - ������������ �������� ���������
//									 ������� ������������� ��.
//									 ������: "��.��.�� ��:��:��.��"
//									 �� - ����� ���� ������
//									 ���� �������� ����� ����������, ��
//									 ������� �������� Time = NULL
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmFillStatusGroup(short Ch, short RTU, short Point,
												  short Quan, char *SGroup);
//
//	��������:       ������ ��������� ������ ��
//
//	���������:      Ch, RTU        - ��. ����
//					Point          - ��������� ������ ��
//					Quan           - ���������� �� � ������
//					SGroup         - ��������� �� ������ �� (������ ���,
//									 ������� ��� � ����� - ������� ����
//									 �������)
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmSetStatusFlags(short Ch, short RTU, short Point,
												 short Flags);
				short __stdcall tmClrStatusFlags(short Ch, short RTU, short Point,
													 short Flags);
//
//	��������:       �������������/���������� ����� ������� ��
//					tmSetStatusFlags - ���������
//					tmClrStatusFlags - �����
//
//	���������:      Ch, RTU        - ��. ����
//					Point          - N ������� (� 1), ���� == 0 ��
//									 �������� ������������ �� ���
//									 ��������� ������� �
//					Flags          - ������� ����� ������
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmSetAnalog(short Ch, short RTU, short Point,
											float Value,
											const char *DateTime);
//
//	��������:       ������ �������� ������� ���
//
//	���������:      Ch, RTU, Point - ��. ����
//					Value          - ����� �������� ��� (�������� �����)
//					DateTime       - ������������ �������� ������ ���
//									 � ������������� � ������� "��.��.�� ��:��:��"
//									 ���� �������� ���������� ��������, ��
//									 ������� �������� DateTime = NULL
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmSetAnalogByCode(short Ch, short RTU, short Point,
												  short Value);
//
//	��������:       ������ �������� ������� ��� � ����
//
//	���������:      Ch, RTU, Point - ��. ����
//					Value          - ��� ���. ������������� ��������
//									 �������� � �������������� ����
//									 (-1 == 0FFFFh)
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/      short tmFillAnalogGroup(short Ch, short RTU, short Point,
											short Quan, short *AGroup);
//
//	��������:       ������ �������� ������ ���
//
//	���������:      Ch, RTU        - ��. ����
//					Point          - ��������� ������ ���
//					Quan           - ���������� ��� � ������
//					AGroup         - ��������� �� ������ ��� (����)
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmSetAnalogFlags(short Ch, short RTU, short Point,
												 short Flags);
				short __stdcall tmClrAnalogFlags(short Ch, short RTU, short Point,
												 short Flags);
//
//	��������:       �������������/���������� ����� ������� ���
//					tmSetAnalogFlags - ���������
//					tmClrAnalogFlags - �����
//
//	���������:      Ch, RTU        - ��. ����
//					Point          - N ������� (� 1), ���� == 0 ��
//									 �������� ������������ �� ���
//									 ��������� ������� �
//					Flags          - ������� ����� ������
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmIncAccumPoints(short Ch, short RTU, short Point,
												 short DataType, short Quan,
												 void *AGroup);
//
//	��������:       ����������� ����� �������� ��� �������� ���
//
//	���������:      Ch, RTU        - ��. ����
//					Point          - ��������� ������ ���
//                  DataType       - ����������� ����������� ��������
//                                   ���� (DataType&0x8000) != 0 ��
//							 		 ��������������� ������ - ������
//                                   ������� ���������
//					Quan           - ���������� ��� � ������
//					AGroup         - ��������� �� ������ ���
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmSetAccumValue(short Ch, short RTU, short Point,
												float Value,
												const char *DateTime);
//
//	��������:       ������ �������� �������� ���
//
//	���������:      Ch, RTU, Point - ��. ����
//					Value          - ����� �������� �������� (�������� �����)
//					DateTime       - ������������ �������� ������ ���
//									 � ������������� � ������� "��.��.�� ��:��:��"
//									 ���� �������� ���������� ��������, ��
//									 ������� �������� DateTime = NULL
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmSetAccumFlags(short Ch, short RTU, short Point,
												short Flags);
				short __stdcall tmClrAccumFlags(short Ch, short RTU, short Point,
												short Flags);
//
//	��������:       �������������/���������� ����� ������� ���
//					tmSetAccumFlags - ���������
//					tmClrAccumFlags - �����
//
//	���������:      Ch, RTU        - ��. ����
//					Point          - N ������� (� 1), ���� == 0 ��
//									 �������� ������������ �� ���
//									 ��������� ������� �
//					Flags          - ������� ����� ������
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************


/*--------------- ������ ����������� ������� ---------------------*/

//***************************************************************
/*	�������:*/  short __stdcall tmRegEvent(TEvent *tmEvent);
//
//	��������:       ����������� ������� � �������������
//
//	���������:      tmEvent - ��������� �� ��������� � �������
//
//	�������:        SUCCESS - �����
//					FAILURE - ������
//***************************************************************

//***************************************************************
/*	�������:*/  short __stdcall tmEventLog(const char *StartTime,
										   const char *EndTime,
										   short EvMask, TEvent *EvLog,
										   short Cpct, unsigned long *Cursor);
//
//	��������:       ������� ������ �� ������� ����������� �������
//
//	���������:      StartTime   - ����� ������ ������
//					EndTime     - ����� ����� ������
//					EvMask      - ����� �������, ���������� � �������
//					EvLog       - ��������� �� ������ �������� ���
//								  ��������� �������� �������
//					Cpct        - ���������� ��������� ����� �������
//					Cursor      - ��������� �� ��������� ����������
//								  ������� ������� � �������. ������������
//								  ��� ���������� ������� �� �������������.
//								  ����� ������ ������� *Cursor ������ ���� 0L
//								  ��� �������� ����� � ������� ��� ����
//								  ������� *Cursor ����� ����������� � ���
//								  �� ������� ������ ��� ����������������
//								  ������� �� ������� ��������� ���� �������
//
//	�������:        ���������� �������� �������
//****************************************************************
short __stdcall tmRetroInfo(TRetroInfo *RetroInfo);
short __stdcall tmRetroInfoEx(WORD idx, TRetroInfoEx *RetroInfoEx);
short __stdcall tmPeekAlarm(short Ch, short RTU, short Point,
                  short AlarmID, TAlarm *Alarm);
short __stdcall tmPokeAlarm(short Ch, short RTU, short Point,
                  short AlarmID, TAlarm *Alarm);
short __stdcall tmEnumAlarms(short Ch, short RTU, short Point,
                  TAlarm *Alarm, short MaxQuan, short ActiveOnly);
short __stdcall tmCheckForDatagram(unsigned char *Buf, unsigned cnt, unsigned timeout);
short __stdcall tmDriverCall(unsigned ADR, short Q_Code, short Command );
void  __stdcall tmStatusByList(short Quan, TADRtm *List, TStatusPoint *SPs);
void  __stdcall tmStatusByListEx(short Quan, TADRtm *List, TStatusPoint *SPs,
                               const char *DateTime);
void  __stdcall tmAnalogByList(short Quan, TADRtm *ADRs, TAnalogPoint *APs,
                               const char *DateTime, short RetroNum);
void  __stdcall tmAccumByList (short Quan, TADRtm *List, TAccumPoint *AcPs,
                               const char *DateTime);
short __stdcall tmGetObjectName(short ObjectType, short Ch, short RTU, short Point, char *Buffer, int MaxBufLen);
short __stdcall tmGetObjectNameEx(short ObjectType, short Ch, short RTU, short Point, short SubObjectId, char *Buffer, int MaxBufLen);
short __stdcall tmTakeRetroTIT(short Ch, short RTU, short Point,
                               char *DateTime,
                               unsigned short Step, unsigned short Quan, short RetroNum,
                               float *Values,
                               unsigned short *Flags);
time_t __stdcall String2Utime(const char *DateTime);
short __stdcall  tmCheckForHWKey();
#endif //IN_LIBRARY

#ifdef __cplusplus
}
#endif
