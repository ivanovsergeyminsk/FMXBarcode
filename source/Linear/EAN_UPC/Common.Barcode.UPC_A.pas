unit Common.Barcode.UPC_A;

interface
uses
  Common.Barcode,
  Common.Barcode.EAN,
  Common.Barcode.IBarcode,
  Common.Barcode.Drawer;

type
  TUPC_A = class(TEANCustom)
  protected
    function GetLength: integer; override;
    function GetType: TBarcodeType; override;

    procedure Encode; override;
    procedure EncodeL(var AEncodeData: string; const ARawData: string); override;
    procedure EncodeR(var AEncodeData: string; const ARawData: string); override;
  end;

implementation
uses
  System.SysUtils,
  System.StrUtils;

{ TUPC_A }

procedure TUPC_A.Encode;
begin
  inherited;
  EncodeAddon(FEncodeData, FRawAddon);
end;

procedure TUPC_A.EncodeL(var AEncodeData: string; const ARawData: string);
var
  Sequence: string;
  I: Integer;
begin
  for I := 0 to 5 do begin
    Sequence := SequencesA[string(ARawData[I+1]).ToInteger];
    AEncodeData := AEncodeData + Sequence;
  end;
end;

procedure TUPC_A.EncodeR(var AEncodeData: string; const ARawData: string);
var
  Sequence: string;
  I: integer;
begin
  for I := 7 to ARawData.Length do begin
    Sequence := ReverseString(SequencesB[string(ARawData[I]).ToInteger]);
    AEncodeData := AEncodeData + Sequence;
  end;

  //Если нет контрольной суммы - добавляем
  if ARawData.Length = (GetLength-1) then begin
    Sequence := ReverseString(SequencesB[GetCRC(FRawData)]);
    AEncodeData := AEncodeData + Sequence;
  end;
end;

function TUPC_A.GetLength: integer;
begin
  result := 12;
end;

function TUPC_A.GetType: TBarcodeType;
begin
  result := TBarcodeType.UPCA;
end;

initialization
  TBarcode.RegisterBarcode(TBarcodeType.UPCA, TUPC_A);

end.
