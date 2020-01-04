unit Common.Barcode.EAN13;

interface
uses
  Common.Barcode,
  Common.Barcode.EAN,
  Common.Barcode.IBarcode,
  Common.Barcode.Drawer;

type
  TEAN13 = class(TEANCustom)
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

{ TEAN13 }

procedure TEAN13.EncodeL(var AEncodeData: string; const ARawData: string);
var
  Pattern: string;
  Sequence: string;
  I: Integer;
begin
  Pattern := PatternsEAN[string(ARawData[1]).ToInteger];

  for I := 1 to 6 do begin
    if Pattern[I] = 'A' then
      Sequence := SequencesA[string(ARawData[I+1]).ToInteger]
    else
      Sequence := SequencesB[string(ARawData[I+1]).ToInteger];

    AEncodeData := AEncodeData + Sequence;
  end;
end;

procedure TEAN13.EncodeR(var AEncodeData: string; const ARawData: string);
var
  Sequence: string;
  I: integer;
begin
  for I := 8 to ARawData.Length do begin
    Sequence := ReverseString(SequencesB[string(ARawData[I]).ToInteger]);
    AEncodeData := AEncodeData + Sequence;
  end;

  //Если нет контрольной суммы - добавляем
  if ARawData.Length = (GetLength-1) then begin
    Sequence := ReverseString(SequencesB[GetCRC(FRawData)]);
    AEncodeData := AEncodeData + Sequence;
  end;
end;

function TEAN13.GetLength: integer;
begin
  result := 13;
end;

function TEAN13.GetType: TBarcodeType;
begin
  result := TBarcodeType.EAN13;
end;


initialization
  TBarcode.RegisterBarcode(TBarcodeType.EAN13, TEAN13);

end.
