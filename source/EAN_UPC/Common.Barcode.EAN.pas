unit Common.Barcode.EAN;

interface
uses
  Common.Barcode,
  Common.Barcode.IBarcode,
  Common.Barcode.Drawer;

type
  TEANCustom = class abstract(TInterfacedObject, IBarcode)
  protected const
    PatternsEAN: array of string = ['AAAAAA',  'AABABB',  'AABBAB',  'AABBBA',  'ABAABB',  'ABBAAB',  'ABBBAA',  'ABABAB',  'ABABBA',  'ABBABA'];
    PatternsUPC: array of string = ['BBBAAA',  'BBABAA',  'BBAABA',  'BBAAAB',  'BABBAA',  'BAABBA',  'BAAABB',  'BABABA',  'BABAAB',  'BAABAB'];

    SequencesA:  array of string = ['0001101', '0011001', '0010011', '0111101', '0100011', '0110001', '0101111', '0111011', '0110111', '0001011'];
    SequencesB:  array of string = ['0100111', '0110011', '0011011', '0100001', '0011101', '0111001', '0000101', '0010001', '0001001', '0010111'];

    NormalGuardPattern  = '101';
    CentreGuardPattern  = '01010';
    SpecialGuardPattern = '010101';
    AddonGuardPattern   = '1011';
    AddonDelineatorPattern = '11';
  protected
    FEncodeData: string;
    FRawData: string;

    procedure ValidateRawData(const Value: string); virtual;

    function GetLength: integer; virtual; abstract;
    function GetType: TBarcodeType; virtual; abstract;

    function GetCRC(const ARawData: string): integer; virtual;
    function CheckCRC(const ARawData: string): boolean; virtual;

    procedure Encode; virtual;
    procedure EncodeL(var AEncodeData: string; const ARawData: string); virtual;
    procedure EncodeR(var AEncodeData: string; const ARawData: string); virtual;

    //IBarcode
    function GetRawData: string;
    procedure SetRawData(const Value: string);

    function GetSVG: string;
  end;

implementation
uses
  System.SysUtils,
  System.StrUtils;

resourcestring
  StrExceptionLength = '%s: Length must be %d or %d digits';
  StrExceptionNumbers = '%s: Must contain only numbers';
  StrExceptionCRC = '%s: CRC Error';

{ TEANCustom }

function TEANCustom.GetCRC(const ARawData: string): integer;
var
  Value: TArray<Char>;
  Even: integer;
  Odd: integer;
  I: Integer;
begin
  if ARawData.Length = GetLength
    then Value := ReverseString(ARawData).Substring(1).ToCharArray
    else Value := ReverseString(ARawData).ToCharArray;

  Even := 0;
  Odd  := 0;

  for I := 0 to Length(Value)-1 do
    if ((I+1) mod 2) = 0 then
      inc(Even, int32.Parse(string(Value[I])))
    else
      inc(Odd, int32.Parse(string(Value[I])));

  result := (10-((3 * Odd + Even) mod 10)) mod 10;
end;

function TEANCustom.CheckCRC(const ARawData: string): boolean;
var
  RawCRC: integer;
  CRC: integer;
begin
  RawCRC := int32.Parse(string(ARawData[ARawData.Length]));
  CRC    := self.GetCRC(ARawData);
  result := RawCRC = CRC;
end;
procedure TEANCustom.Encode;
begin
  FEncodeData := NormalGuardPattern;
  EncodeL(FEncodeData, FRawData);
  FEncodeData := FEncodeData + CentreGuardPattern;
  EncodeR(FEncodeData, FRawData);
  FEncodeData := FEncodeData + NormalGuardPattern;
end;

procedure TEANCustom.EncodeL(var AEncodeData: string; const ARawData: string);
begin

end;

procedure TEANCustom.EncodeR(var AEncodeData: string; const ARawData: string);
begin

end;

function TEANCustom.GetRawData: string;
begin
  result := FRawData;
end;

function TEANCustom.GetSVG: string;
var
  Drawer: IBarcodeDrawer;
begin
  Drawer := TBarcodeDrawer.Create;
  result := Drawer.SVG(FEncodeData);
end;

procedure TEANCustom.SetRawData(const Value: string);
begin
  ValidateRawData(Value.Trim);

  FRawData := Value.Trim;
  Encode;
end;

procedure TEANCustom.ValidateRawData;
var
  Duck: int64;
  BarLength: integer;
  BarType: TBarcodeType;
begin
  BarLength := GetLength;
  BarType   := GetType;

  if (Value.Length < BarLength - 1) or (Value.Length > BarLength) then
    raise EArgumentException.Create(format(StrExceptionLength, [BarType.ToString, BarLength-1, BarLength]));

  if not TryStrToInt64(Value, Duck) then
    raise EArgumentException.Create(format(StrExceptionNumbers, [BarType.ToString]));

  if Value.Length = BarLength then
    if not CheckCRC(Value) then
      raise EArgumentException.Create(format(StrExceptionCRC, [BarType.ToString]));
end;

end.
