(*
  Copyright 2016, MARS-Curiosity library

  Home: https://github.com/andrea-magni/MARS
*)
unit MARS.Core.Token.ReadersAndWriters;

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
  TMARSTokenWriter = class(TInterfacedObject, IMessageBodyWriter)
    procedure WriteTo(const AValue: TValue; const AAttributes: TAttributeArray;
      AMediaType: TMediaType; AResponseHeaders: TStrings; AOutputStream: TStream);
  end;

//  [Consumes(TMediaType.APPLICATION_JSON)]
//  TMARSTokenReader = class(TInterfacedObject, IMessageBodyReader)
//  public
//    function ReadFrom(const AInputData: TBytes;
//      const AAttributes: TAttributeArray;
//      AMediaType: TMediaType; ARequestHeaders: TStrings): TValue; virtual;
//  end;


implementation

uses
    MARS.Core.Utils
  , MARS.Rtti.Utils
  , MARS.Core.Token
  ;


{ TMARSTokenWriter }

procedure TMARSTokenWriter.WriteTo(const AValue: TValue;
  const AAttributes: TAttributeArray; AMediaType: TMediaType;
  AResponseHeaders: TStrings; AOutputStream: TStream);
var
  LStreamWriter: TStreamWriter;
  LToken: TMARSToken;
begin
  LStreamWriter := TStreamWriter.Create(AOutputStream);
  try
    LToken := AValue.AsObject as TMARSToken;
    if Assigned(LToken) then
      LStreamWriter.Write(LToken.ToJSON);
  finally
    LStreamWriter.Free;
  end;
end;


procedure RegisterReadersAndWriters;
begin
//  TMARSMessageBodyReaderRegistry.Instance.RegisterReader<TMARSToken>(TMARSTokenReader);

  TMARSMessageBodyRegistry.Instance.RegisterWriter(
    TMARSTokenWriter
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Boolean
      begin
        Result := Assigned(AType) and AType.IsObjectOfType<TMARSToken>(True);
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
