unit Common.Barcode.GS128;

interface
uses
  Common.Barcode,
  Common.Barcode.Code128,
  Common.Barcode.IBarcode,
  Common.Barcode.Drawer;

type
  TGS128 = class(TCode128)
  protected
    procedure EncodePatternStart(var Result: TArray<byte>; LRawData: string; var CurrentCode: TCode128.TPatternCode); override;
  end;
implementation
uses
  System.SysUtils, System.Math, System.RegularExpressions;

{ TGS128 }

procedure TGS128.EncodePatternStart(var Result: TArray<byte>; LRawData: string; var CurrentCode: TCode128.TPatternCode);
begin
  if TRegEx.IsMatch(LRawData, REGEX_NUMBER) then
  begin
    currentCode := TPatternCode.CodeC;
    result := result + [PatternStartC];
  end
  else
  begin
    currentCode := TPatternCode.CodeB;
    result := result + [PatternStartB];
  end;
  result := result + [PatternFNC1(CurrentCode)];
end;

initialization
  TBarcode.RegisterBarcode(TBarcodeType.GS128, TGS128);

end.
