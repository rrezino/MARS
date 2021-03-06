(*
  Copyright 2016, MARS-Curiosity library

  Home: https://github.com/andrea-magni/MARS
*)
unit MARS.JsonDataObjects.ReadersAndWriters;

{$I MARS.inc}

interface

uses
  Classes, SysUtils, Rtti

  , MARS.Core.Attributes
  , MARS.Core.Declarations
  , MARS.Core.MediaType
  , MARS.Core.MessageBodyWriter
  , MARS.Core.MessageBodyReader
  ;

type
  [Produces(TMediaType.APPLICATION_JSON)]
  TJsonDataObjectsWriter = class(TInterfacedObject, IMessageBodyWriter)
    procedure WriteTo(const AValue: TValue; const AAttributes: TAttributeArray;
      AMediaType: TMediaType; AResponseHeaders: TStrings; AOutputStream: TStream);
  end;

  [Consumes(TMediaType.APPLICATION_JSON)]
  TJsonDataObjectsReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(const AInputData: TBytes;
      const AAttributes: TAttributeArray;
      AMediaType: TMediaType; ARequestHeaders: TStrings): TValue; virtual;
  end;


implementation

uses
    JsonDataObjects
  , MARS.Core.Utils
  , MARS.Rtti.Utils
  ;

{ TJsonDataObjectsWriter }

procedure TJsonDataObjectsWriter.WriteTo(const AValue: TValue;
  const AAttributes: TAttributeArray; AMediaType: TMediaType;
  AResponseHeaders: TStrings; AOutputStream: TStream);
var
  LStreamWriter: TStreamWriter;
  LJsonBO: TJsonBaseObject;
begin
  LStreamWriter := TStreamWriter.Create(AOutputStream);
  try
    LJsonBO := AValue.AsObject as TJsonBaseObject;
    if Assigned(LJsonBO) then
      LStreamWriter.Write(LJsonBO.ToJSON);
  finally
    LStreamWriter.Free;
  end;
end;

{ TJsonDataObjectsReader }

function TJsonDataObjectsReader.ReadFrom(const AInputData: TBytes;
  const AAttributes: TAttributeArray;
  AMediaType: TMediaType; ARequestHeaders: TStrings): TValue;
var
  LJson: TJsonBaseObject;
begin
  Result := TValue.Empty;

  LJson := TJsonBaseObject.Parse(AInputData);
  if Assigned(LJson) then
    Result := LJson;
end;

procedure RegisterReadersAndWriters;
begin
  TMARSMessageBodyReaderRegistry.Instance.RegisterReader<TJsonBaseObject>(TJsonDataObjectsReader);

  TMARSMessageBodyRegistry.Instance.RegisterWriter(
    TJsonDataObjectsWriter
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Boolean
      begin
        Result := Assigned(AType) and AType.IsObjectOfType<TJsonBaseObject>(True);
      end
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Integer
      begin
        Result := TMARSMessageBodyRegistry.AFFINITY_HIGH;
      end
  );

end;


initialization
  RegisterReadersAndWriters;

end.
