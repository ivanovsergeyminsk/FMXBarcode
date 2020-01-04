unit Common.Barcode.EAN8;

interface
uses
  Common.Barcode,
  Common.Barcode.EAN,
  Common.Barcode.IBarcode;

type
  TEAN8 = class(TEANCustom)
  protected
    function GetLength: integer; override;
    function GetType: TBarcodeType; override;

    procedure EncodeL(var AEncodeData: string; const ARawData: string); override;
    procedure EncodeR(var AEncodeData: string; const ARawData: string); override;
  end;
implementation

uses
  System.SysUtils,
  System.StrUtils;

{ TEAN8 }

procedure TEAN8.EncodeL(var AEncodeData: string; const ARawData: string);
var
  Sequence: string;
  I: Integer;
begin
  for I := 0 to 3 do begin
    Sequence := SequencesA[string(ARawData[I+1]).ToInteger];
    AEncodeData := AEncodeData + Sequence;
  end;
end;

procedure TEAN8.EncodeR(var AEncodeData: string; const ARawData: string);
var
  Sequence: string;
  I: integer;
begin
  for I := 5 to ARawData.Length do begin
    Sequence := ReverseString(SequencesB[string(ARawData[I]).ToInteger]);
    AEncodeData := AEncodeData + Sequence;
  end;

  //Если нет контрольной суммы - добавляем
  if ARawData.Length = (GetLength-1) then begin
    Sequence := ReverseString(SequencesB[GetCRC(FRawData)]);
    AEncodeData := AEncodeData + Sequence;
  end;
end;

function TEAN8.GetLength: integer;
begin
  result := 8;
end;

function TEAN8.GetType: TBarcodeType;
begin
  result := TBarcodeType.EAN8;
end;

initialization
  TBarcode.RegisterBarcode(TBarcodeType.EAN8, TEAN8);

end.
