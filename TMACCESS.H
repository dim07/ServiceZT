#pragma pack(1)

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __TIME_H
#include <time.h>
#endif

#define TM_KERNEL_SIGNATURE 0x0830

#define SUCCESS 1                 // Успешное завершение функц
#define FAILURE 0                 // Ошибка при обработке запроса

/*------------- Определения флагов телепараметров -----------------*/
#define UNRELIABLE_HDW     0x0001   // Недостоверность аппаратная
#define UNRELIABLE_MANU    0x0002   // Недостоверность от пользователя
#define REQUESTED          0x0004   // Идет опрос
#define MANUALLY_SET       0x0008   // Установлено вручную
#define NO_ALARMS          0x0000   // ТИТ в норме
#define LEVEL_A            0x0010   // Сработала уставка первого уровня
#define LEVEL_B            0x0020   // ------- " ------- второго уровня
#define LEVEL_C            0x0040   // ------- " ------- третьего уровня
#define LEVEL_D            0x0080   // ------- " ------- четвертого уровня
#define INVERTED           0x0100   // ТС инвертируется при занесен

/*------------------------ Типы событий ---------------------------*/
#define evSTATUS_CHANGE      0x0001   // Телесигна
#define evALARM              0x0002   // Уставка ТИТ
#define evCONTROL            0x0004   // Телеуправление
#define evMANUAL_CONTROL     0x0008   // ТУ со щита
#define evMANUAL_STATUS_SET  0x0010   // Обозначение положения ТС

/*--------------- Константы для сетевого доступа ------------------*/
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
	short Status;            // состояние объекта
	short Flags;             // фла
	} TStatusPoint;  // Объект ТС

typedef struct
	{
	float asFloat;           // реальное значение ТИТ
	short asCode;            // код ТИТ, поступивший с ТМ
	short Flags;             // фла
	char  Unit[8];           // единицы измерения
	} TAnalogPoint;  // Объект ТИТ

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
	float Value;             // значение счетчика
	float Load;              // нагрузка
	short Flags;             // фла
	char Unit[8];            // единицы измерения
	} TAccumPoint;   // Объект ТИИ

typedef struct
	{
	char DateTime[24];       // время события в формате ДД.ММ.ГГГГ ЧЧ:ММ:СС.cc

	unsigned short Imp;      // уровень важнос
	unsigned short ID;       // тип события

	unsigned short Ch;       // кана
	unsigned short RTU;      // номер КП  (c 1)
	unsigned short Point;    // объект    (c 1)

	char Data[22];
	} TEvent;      // Событие

struct StatusData  // параметры переключения ТС
	{
	char State;    // новое состояние ТС
	char Class;    // класс телесигнала (К.А. - 0  АПС - 1)
	};
struct AlarmData   // параметры сработавшей уставк
	{
	float Val;     // значение контролируемого ТИТ
	short AlarmID; // идентификатор уставк
	char  State;   // 0 - уставка снята, 1 - уставка взведена
	};
struct ControlData // параметры выданного телеуправления
	{
	char  Ch;
	char  RTU;
	short Point;
	char  Cmd;     // выданная команда
	char  Result;  // == SUCCESS если ТУ успешно, иначе FAILURE
	char  UserName[16];  // пользователь, выдавший ТУ
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
/*----------------------- ОБЩИЕ ФУНКЦИИ --------------------------*/

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmInit(const char *ServerName,
									   const char *LocalName);
//	ОПИСАНИЕ:       Эта функция инициализирует библиотеку
//					доступа к телемеханике
//
//	ПАРАМЕТРЫ:      ServerName - имя сервера
//                  LocalName  - имя локальной машин
//
//	ВОЗВРАТ:        SUCCESS - инициализация успешна
//					FAILURE - ошибка, работа невозможна
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  void __stdcall tmClose(void);
//
//	ОПИСАНИЕ:       Завершает сеанс  работы с библиотекой ТМ
//
//	ПАРАМЕТРЫ:      не
//
//	ВОЗВРАТ:        не
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmControl(short Ch, short RTU, short Point,
										  short Cmd);
//
//	ОПИСАНИЕ:       выдача команды телеуправления
//
//	ПАРАМЕТРЫ:      Ch    - канал,
//					RTU   - номер КП (с 1),
//					Point - номер объекта (с 1)
//					Cmd - команда ТУ (0-ОТКЛ, 1-ВКЛ)
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmSystemTime(char *DateTime, struct tm *tm);
//
//	ОПИСАНИЕ:       Запрос времени на ТМ-сервере
//
//	ПАРАМЕТРЫ:      DateTime - адрес строки для выдачи времен
//                             в формате "ДД.ММ.ГГГГ ЧЧ:ММ:СС" или NULL
//					tm       - адрес структуры tm (см. TIME.H) или NULL
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************


/*--------------- ФУНКЦИИ ПОЛУЧЕНИЯ ДАННЫХ -----------------------*/

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmStatus(short Ch, short RTU, short Point);
//
//	ОПИСАНИЕ:       Возвращает состояние объекта ТС
//
//	ПАРАМЕТРЫ:      Ch    - канал,
//					RTU   - номер КП (с 1),
//					Point - номер объекта (с 1)
//
//	ВОЗВРАТ:        0 - ОТКЛ,  1 - ВК
//				   -1 - ошибка, нет данных
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmStatusFull(short Ch, short RTU, short Point,
											 TStatusPoint *SP);
//
//	ОПИСАНИЕ:       Возвращает состояние объекта ТС в структуре
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					SP             - указатель на структуру объекта ТС
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка, нет данных
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  float __stdcall tmAnalog(short Ch, short RTU, short Point,
										 const char  *DateTime, short RetroNum);
//
//	ОПИСАНИЕ:       Возвращает значение объекта ТИТ
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					DateTime, RetroNum - опциональные параметры получения
//									     значения из ретроспективы.
//                                       DateTime задается в формате
//                                       "ДД.ММ.ГГ ЧЧ:ММ:СС"
//									     Если интересуют текущие значения,
//									     то DateTime == NULL
//
//	ВОЗВРАТ:        реальное значение ТИТ или huge_flt при отсутствии данных
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmAnalogFull(short Ch, short RTU, short Point,
											 TAnalogPoint *AP,
											 const char *DateTime,
											 short RetroNum);
//
//	ОПИСАНИЕ:       Возвращает значение объекта ТИТ в структуре
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					AP             - указатель на структуру ТИТ
//									 если AP->asFloat == _huge_flt то
//									 преобразования из кода в значение не
//									 производится. При этом уменьшается
//									 время доступа.
//					DateTime, RetroNum - опциональные параметры получения
//									     значения из ретроспективы.
//                                       DateTime задается в формате
//                                       "ДД.ММ.ГГ ЧЧ:ММ:СС"
//									     Если интересуют текущие значения,
//									     то DateTime == NULL
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка, нет данных
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  float __stdcall tmAccumValue(short Ch, short RTU, short Point,
											 const char *DateTime);
//
//	ОПИСАНИЕ:       Возвращает значение счетчика ТИИ
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					DateTime - опциональный параметр получения
//							   значения из ретроспективы.
//                             DateTime задается в формате
//                             "ДД.ММ.ГГ ЧЧ:ММ:СС"
//							   Если интересуют текущие значения,
//							   то DateTime == NULL
//
//	ВОЗВРАТ:        значение счетчика ТИИ или huge_flt при ошибке
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  float __stdcall tmAccumLoad(short Ch, short RTU, short Point,
											const char *DateTime);
//
//	ОПИСАНИЕ:       Возвращает значение нагрузки из ТИИ
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					DateTime - опциональный параметр получения
//							   значения из ретроспективы.
//                             DateTime задается в формате
//                             "ДД.ММ.ГГ ЧЧ:ММ:СС"
//							   Если интересуют текущие значения,
//							   то DateTime == NULL
//
//	ВОЗВРАТ:        значение нагрузки или huge_flt при ошибке
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmAccumFull(short Ch, short RTU, short Point,
											TAccumPoint *AP,
											const char *DateTime);
//
//	ОПИСАНИЕ:       Возвращает значение объекта ТИИ в структуре
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					AP       - указатель на структуру ТИИ
//					DateTime - опциональный параметр получения
//							   значения из ретроспективы.
//                             DateTime задается в формате
//                             "ДД.ММ.ГГ ЧЧ:ММ:СС"
//							   Если интересуют текущие значения,
//							   то DateTime == NULL
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка, нет данных
//***************************************************************


/*--------------- ФУНКЦИИ ЗАНЕСЕНИЯ ДАННЫХ -----------------------*/

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmSetStatus(short Ch, short RTU, short Point,
											char Value,
											const char *DateTime);
//
//	ОПИСАНИЕ:       задает состояние объекта ТС
//
//	ПАРАМЕТРЫ:      Ch    		   - канал,
//					RTU            - номер КП (с 1),
//					Point          - номер объекта (с 1)
//					Value          - новое значение ТС
//					DateTime       - опциональный параметр реального
//									 времени возникновения ТС.
//									 формат: "ДД.ММ.ГГ ЧЧ:ММ:СС.сс"
//									 сс - сотые доли секунд
//									 Если реальное время неизвестно, то
//									 следует передать Time = NULL
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmFillStatusGroup(short Ch, short RTU, short Point,
												  short Quan, char *SGroup);
//
//	ОПИСАНИЕ:       задает состояние группы ТС
//
//	ПАРАМЕТРЫ:      Ch, RTU        - см. выше
//					Point          - начальный объект ТС
//					Quan           - количество ТС в группе
//					SGroup         - указатель на массив ТС (массив бит,
//									 младший бит в байте - меньший номе
//									 объекта)
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmSetStatusFlags(short Ch, short RTU, short Point,
												 short Flags);
				short __stdcall tmClrStatusFlags(short Ch, short RTU, short Point,
													 short Flags);
//
//	ОПИСАНИЕ:       Устанавливают/сбрасывают флаги объекта ТС
//					tmSetStatusFlags - установка
//					tmClrStatusFlags - сброс
//
//	ПАРАМЕТРЫ:      Ch, RTU        - см. выше
//					Point          - N объекта (с 1), если == 0 то
//									 операция производится со все
//									 объектами данного К
//					Flags          - битовая маска флагов
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmSetAnalog(short Ch, short RTU, short Point,
											float Value,
											const char *DateTime);
//
//	ОПИСАНИЕ:       задает значение объекта ТИТ
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					Value          - новое значение ТИТ (реальное число)
//					DateTime       - опциональный параметр записи ТИТ
//									 в ретроспективу в формате "ДД.ММ.ГГ ЧЧ:ММ:СС"
//									 Если задается мгновенное значение, то
//									 следует передать DateTime = NULL
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmSetAnalogByCode(short Ch, short RTU, short Point,
												  short Value);
//
//	ОПИСАНИЕ:       задает значение объекта ТИТ в коде
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					Value          - код ТИТ. Отрицательные значения
//									 задаются в дополнительном коде
//									 (-1 == 0FFFFh)
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/      short tmFillAnalogGroup(short Ch, short RTU, short Point,
											short Quan, short *AGroup);
//
//	ОПИСАНИЕ:       задает значения группы ТИТ
//
//	ПАРАМЕТРЫ:      Ch, RTU        - см. выше
//					Point          - начальный объект ТИТ
//					Quan           - количество ТИТ в группе
//					AGroup         - указатель на массив ТИТ (коды)
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmSetAnalogFlags(short Ch, short RTU, short Point,
												 short Flags);
				short __stdcall tmClrAnalogFlags(short Ch, short RTU, short Point,
												 short Flags);
//
//	ОПИСАНИЕ:       Устанавливают/сбрасывают флаги объекта ТИТ
//					tmSetAnalogFlags - установка
//					tmClrAnalogFlags - сброс
//
//	ПАРАМЕТРЫ:      Ch, RTU        - см. выше
//					Point          - N объекта (с 1), если == 0 то
//									 операция производится со все
//									 объектами данного К
//					Flags          - битовая маска флагов
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmIncAccumPoints(short Ch, short RTU, short Point,
												 short DataType, short Quan,
												 void *AGroup);
//
//	ОПИСАНИЕ:       Поступление новых значений для объектов ТИИ
//
//	ПАРАМЕТРЫ:      Ch, RTU        - см. выше
//					Point          - начальный объект ТИИ
//                  DataType       - разрядность аппаратного счетчика
//                                   если (DataType&0x8000) != 0 то
//							 		 предоставляемые данные - чистый
//                                   прирост импульсов
//					Quan           - количество ТИИ в группе
//					AGroup         - указатель на массив ТИИ
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmSetAccumValue(short Ch, short RTU, short Point,
												float Value,
												const char *DateTime);
//
//	ОПИСАНИЕ:       задает значение счетчика ТИИ
//
//	ПАРАМЕТРЫ:      Ch, RTU, Point - см. выше
//					Value          - новое значение счетчика (реальное число)
//					DateTime       - опциональный параметр записи ТИТ
//									 в ретроспективу в формате "ДД.ММ.ГГ ЧЧ:ММ:СС"
//									 Если задается мгновенное значение, то
//									 следует передать DateTime = NULL
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmSetAccumFlags(short Ch, short RTU, short Point,
												short Flags);
				short __stdcall tmClrAccumFlags(short Ch, short RTU, short Point,
												short Flags);
//
//	ОПИСАНИЕ:       Устанавливают/сбрасывают флаги объекта ТИИ
//					tmSetAccumFlags - установка
//					tmClrAccumFlags - сброс
//
//	ПАРАМЕТРЫ:      Ch, RTU        - см. выше
//					Point          - N объекта (с 1), если == 0 то
//									 операция производится со все
//									 объектами данного К
//					Flags          - битовая маска флагов
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************


/*--------------- ЖУРНАЛ РЕГИСТРАЦИИ СОБЫТИЙ ---------------------*/

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmRegEvent(TEvent *tmEvent);
//
//	ОПИСАНИЕ:       регистрация события в ретроспективе
//
//	ПАРАМЕТРЫ:      tmEvent - указатель на структуру с событие
//
//	ВОЗВРАТ:        SUCCESS - успех
//					FAILURE - ошибка
//***************************************************************

//***************************************************************
/*	ФУНКЦИЯ:*/  short __stdcall tmEventLog(const char *StartTime,
										   const char *EndTime,
										   short EvMask, TEvent *EvLog,
										   short Cpct, unsigned long *Cursor);
//
//	ОПИСАНИЕ:       Выборка данных из журнала регистрации событий
//
//	ПАРАМЕТРЫ:      StartTime   - время начала выборк
//					EndTime     - время конца выборк
//					EvMask      - маска событий, попадающих в выборку
//					EvLog       - указатель на массив структур для
//								  занесения выбраных событий
//					Cpct        - количество элементов этого массива
//					Cursor      - указатель на служебную переменную
//								  текущей позиции в журнале. Используется
//								  для порционной выборки из ретроспективы.
//								  Перед первым вызовом *Cursor должно быть 0L
//								  При нехватке места в массиве для всех
//								  событий *Cursor будет установлено и его
//								  не следует менять при последовательных
//								  вызовах до полного получения всех событий
//
//	ВОЗВРАТ:        Количество считаных событий
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
