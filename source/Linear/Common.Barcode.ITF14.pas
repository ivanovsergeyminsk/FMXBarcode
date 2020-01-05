unit Common.Barcode.ITF14;

interface
uses
  Common.Barcode,
  Common.Barcode.IBarcode,
  Common.Barcode.Drawer;

type
  TITF14 = class(TBarcodeCustom)
  protected const
    Patterns: array of string = ['00110',  '10001',  '01001',  '11000',  '00101',  '10100',  '01100',  '00011',  '10010',  '01010'];
    PatternStart = '1010';
    PatternStop  = '1101';
    PatternSpace = '000000000000000000000000000000';
  protected
    function GetLength: integer; override;
    function GetType: TBarcodeType; override;

    procedure ValidateRawData(const Value: string); override;
    procedure ValidateRawAddon(const Value: string); override;

    function GetCRC(const ARawData: string): integer; override;

    procedure Encode; override;
    procedure EncodeCenter(var AEncodeData: string; const ARawData: string);
  end;

implementation
uses
  System.SysUtils,
  System.StrUtils;

resourcestring
  StrExceptionLength = '%s: Length must be %d or %d digits';
  StrExceptionNumbers = '%s: Must contain only numbers';
  StrExceptionCRC = '%s: CRC Error';


{ TITF14 }

procedure TITF14.Encode;
begin
  FEncodeData := PatternSpace;
  FEncodeData := FEncodeData + PatternStart;
  EncodeCenter(FEncodeData, FRawData);
  FEncodeData := FEncodeData + PatternStop;
  FEncodeData := FEncodeData + PatternSpace;
end;

procedure TITF14.EncodeCenter(var AEncodeData: string; const ARawData: string);
var
  I: integer;
  Sequences, Sequence, Sequence1, Sequence2: string;
  k: Integer;
  LRawData: string;
begin
  LRawData := ARawData;
  //Если нет контрольной суммы - добавляем
  if ARawData.Length = (GetLength-1) then
    LRawData := LRawData + GetCRC(ARawData).ToString;

  I := 1;
  while I <= LRawData.Length do begin
    Sequence1 := Patterns[string(LRawData[I]).ToInteger];
    Sequence2 := Patterns[string(LRawData[I+1]).ToInteger];
    Sequence  := string.Empty;
    for k := 1 to 5 do begin
      if Sequence1[k] = '0'
        then Sequence := Sequence + '1'
        else Sequence := Sequence + '11';

      if Sequence2[k] = '0'
        then Sequence := Sequence + '0'
        else Sequence := Sequence + '00';
    end;

    Sequences := Sequences + Sequence;
    Inc(I, 2);
  end;

  AEncodeData := AEncodeData + Sequences;
end;

function TITF14.GetCRC(const ARawData: string): integer;
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

function TITF14.GetLength: integer;
begin
  result := 14;
end;

function TITF14.GetType: TBarcodeType;
begin
  result := TBarcodeType.ITF14;
end;

procedure TITF14.ValidateRawAddon(const Value: string);
begin
  inherited;

end;

procedure TITF14.ValidateRawData(const Value: string);
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


initialization
  TBarcode.RegisterBarcode(TBarcodeType.ITF14, TITF14);

end.
