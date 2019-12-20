unit Common.Barcode.EAN8;

interface
uses
  Common.Barcode,
  Common.Barcode.IBarcode;

type
  TEAN8 = class(TInterfacedObject, IBarcode)
  strict private const
    SequencesA: array of string = ['0001101', '0011001', '0010011', '0111101', '0100011', '0110001', '0101111', '0111011', '0110111', '0001011'];
    SequencesB: array of string = ['0100111', '0110011', '0011011', '0100001', '0011101', '0111001', '0000101', '0010001', '0001001', '0010111'];
    SequenceStart = '101';
    SequenceStop  = '101';
    SequenceInter = '01010';
  private
    FRawData: string;
    FEncodeData: string;

    procedure ValidateRawData(const Value: string);

    function GetCRC(const ARawData: string): integer;
    function CheckCRC(const ARawData: string): boolean;

    procedure Encode;
    procedure EncodeL(var AEncodeData: string; const ARawData: string);
    procedure EncodeR(var AEncodeData: string; const ARawData: string);

    function Get1(const Position, Length: single): string;
    function Get0(const Position: single): string;
  protected
    function GetRawData: string;
    procedure SetRawData(const Value: string);

    function GetSVG: string;
    function GetThickness(const Width: single): single;
  end;
implementation

uses
  System.SysUtils,
  System.StrUtils;

{ TEAN8 }

function TEAN8.CheckCRC(const ARawData: string): boolean;
var
  RawCRC: integer;
  CRC: integer;
begin
  RawCRC := int32.Parse(string(ARawData[ARawData.Length]));
  CRC    := self.GetCRC(ARawData);
  result := RawCRC = CRC;
end;

procedure TEAN8.Encode;
begin
  FEncodeData := SequenceStart;
  EncodeL(FEncodeData, FRawData);
  FEncodeData := FEncodeData + SequenceInter;
  EncodeR(FEncodeData, FRawData);
  FEncodeData := FEncodeData + SequenceStop;
end;

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
  if ARawData.Length = 7 then begin
    Sequence := ReverseString(SequencesB[GetCRC(FRawData)]);
    AEncodeData := AEncodeData + Sequence;
  end;
end;

function TEAN8.Get0(const Position: single): string;
begin
  result := format('M %s, 0', [Position.ToString.Replace(',','.')]);
end;

function TEAN8.Get1(const Position, Length: single): string;
begin
  result := format('%s L %s, %s', [Get0(Position),
                                   Position.ToString.Replace(',','.'),
                                   Length.ToString.Replace(',','.')
                                  ]);
end;

function TEAN8.GetCRC(const ARawData: string): integer;
var
  Value: TArray<Char>;
  Even: integer;
  Odd: integer;
  I: Integer;
begin
  if ARawData.Length = 8
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

function TEAN8.GetRawData: string;
begin
  result := FRawData;
end;

function TEAN8.GetSVG: string;
var
  Item: char;
  LPath: string;
  StartPosition, Length: currency;
begin
  StartPosition := 1.0;
  Length := 1.0;
  result :=  Get0(StartPosition);
  for Item in FEncodeData do begin
    if Item = '0'
      then LPath := Get0(StartPosition)
      else LPath := Get1(StartPosition, Length);

    result := result + LPath;
    StartPosition := StartPosition + 0.33;
  end;
end;

function TEAN8.GetThickness(const Width: single): single;
begin
  result := Width * 1.2 / 56;
end;

procedure TEAN8.SetRawData(const Value: string);
begin
  ValidateRawData(Value.Trim);

  FRawData := Value.Trim;
  Encode;
end;

procedure TEAN8.ValidateRawData(const Value: string);
var
  Duck: int64;
begin
  if (Value.Length < 7) or (Value.Length > 8) then
    raise EArgumentException.Create('EAN8: Length must be 7 or 8 digits');

  if not TryStrToInt64(Value, Duck) then
    raise EArgumentException.Create('EAN8: Must contain only numbers');

  if Value.Length = 8 then
    if not CheckCRC(Value) then
      raise EArgumentException.Create('EAN8: CRC Error');
end;

initialization
  TBarcode.RegisterBarcode(TBarcodeType.EAN8, TEAN8);

end.
