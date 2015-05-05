object ZTService: TZTService
  OldCreateOrder = False
  DisplayName = 'ZTService'
  Password = 'OR54321@'
  ServiceStartName = '_oik-reader@bashes.ru'
  OnContinue = ServiceContinue
  OnPause = ServicePause
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 358
  Width = 470
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=MSDASQL.1;Persist Security Info=True;User ID=root;Exten' +
      'ded Properties="Driver=MySQL ODBC 5.2 Unicode Driver;SERVER=loca' +
      'lhost;UID=root;PWD=cats;DATABASE=bp;PORT=3306;CHARSET=utf8;NO_PR' +
      'OMPT=1"'
    LoginPrompt = False
    Provider = 'MSDASQL.1'
    Left = 264
    Top = 120
  end
  object ADODataSet1: TADODataSet
    Connection = ADOConnection1
    Parameters = <>
    Left = 264
    Top = 248
  end
  object poTable: TADODataSet
    Connection = ADOConnection1
    CursorType = ctStatic
    CommandText = 'select * from po where id in (1,3)'
    Parameters = <>
    Left = 264
    Top = 184
    object poTableid: TAutoIncField
      FieldName = 'id'
      ReadOnly = True
    end
    object poTablename: TWideStringField
      FieldName = 'name'
      Size = 50
    end
    object poTableshort_name: TWideStringField
      FieldName = 'short_name'
      Size = 10
    end
    object poTablecnt: TIntegerField
      FieldName = 'cnt'
    end
    object poTableoik: TWideStringField
      FieldName = 'oik'
      Size = 50
    end
    object poTableoikOser: TWideStringField
      FieldName = 'oikOser'
      Size = 50
    end
    object poTableoikPass: TWideStringField
      FieldName = 'oikPass'
    end
    object poTableisDomainUser: TSmallintField
      FieldName = 'isDomainUser'
    end
    object poTablepo_damage_id: TIntegerField
      FieldName = 'po_damage_id'
    end
    object poTablepo_potreb_id: TIntegerField
      FieldName = 'po_potreb_id'
    end
    object poTableweather_station_id: TIntegerField
      FieldName = 'weather_station_id'
    end
  end
end
