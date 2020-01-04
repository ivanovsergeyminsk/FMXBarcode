unit Common.Barcode.UPC_E;

interface
uses
  Common.Barcode,
  Common.Barcode.EAN,
  Common.Barcode.IBarcode,
  Common.Barcode.Drawer;

type
  TUPC_E = class(TEANCustom)
  protected
    function GetLength: integer; override;
    function GetType: TBarcodeType; override;

    procedure Encode; override;
    procedure EncodeL(var AEncodeData: string; const ARawData: string); override;
  end;

implementation
uses
  System.SysUtils,
  System.StrUtils;


{ TUPC_E }

procedure TUPC_E.Encode;
begin
  FEncodeData := NormalGuardPattern;
  EncodeL(FEncodeData, FRawData);
  FEncodeData := FEncodeData + SpecialGuardPattern;
end;


procedure TUPC_E.EncodeL(var AEncodeData: string; const ARawData: string);
var
  Pattern: string;
  Sequence: string;
  I: Integer;
begin
  Pattern := PatternsUPC[GetCRC(ARawData)];

  for I := 1 to 6 do begin
    if Pattern[I] = 'A' then
      Sequence := SequencesA[string(ARawData[I+1]).ToInteger]
    else
      Sequence := SequencesB[string(ARawData[I+1]).ToInteger];

    AEncodeData := AEncodeData + Sequence;
  end;
end;

function TUPC_E.GetLength: integer;
begin
  result := 8;
end;

function TUPC_E.GetType: TBarcodeType;
begin
  result := TBarcodeType.UPC_E;
end;

initialization
  TBarcode.RegisterBarcode(TBarcodeType.UPC_E, TUPC_E);

end.
