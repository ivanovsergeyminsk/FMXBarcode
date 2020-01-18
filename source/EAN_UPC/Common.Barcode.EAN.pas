unit Common.Barcode.EAN;

interface
uses
  Common.Barcode,
  Common.Barcode.IBarcode,
  Common.Barcode.Drawer;

type
  TEANCustom = class abstract(TBarcodeCustom)
  protected const
    PatternsEAN: array of string = ['AAAAAA',  'AABABB',  'AABBAB',  'AABBBA',  'ABAABB',  'ABBAAB',  'ABBBAA',  'ABABAB',  'ABABBA',  'ABBABA'];
    PatternsUPC: array of string = ['BBBAAA',  'BBABAA',  'BBAABA',  'BBAAAB',  'BABBAA',  'BAABBA',  'BAAABB',  'BABABA',  'BABAAB',  'BAABAB'];
    PatternsAddonTwo: array of string = ['AA', 'AB', 'BA', 'BB'];
    PatternAddonFive: array of string = ['BBAAA', 'BABAA', 'BAABA', 'BAAAB', 'ABBAA', 'AABBA', 'AAABB', 'ABABA', 'ABAAB', 'AABAB'];

    SequencesA:  array of string = ['0001101', '0011001', '0010011', '0111101', '0100011', '0110001', '0101111', '0111011', '0110111', '0001011'];
    SequencesB:  array of string = ['0100111', '0110011', '0011011', '0100001', '0011101', '0111001', '0000101', '0010001', '0001001', '0010111'];

    NormalGuardPattern  = '101';
    CentreGuardPattern  = '01010';
    SpecialGuardPattern = '010101';
    AddonGuardPattern   = '1011';
    AddonDelineatorPattern = '01';
    AddonDelimiter = '0000000';

  strict private
    procedure EncodeAddonTwo(var AEncodeData: string; const ARawAddon: string);
    procedure EncodeAddonFive(var AEncodeData: string; const ARawAddon: string);
  protected
    procedure ValidateRawData(const Value: string); override;
    procedure ValidateRawAddon(const Value: string); override;

    function GetCRC(const ARawData: string): integer; override;

    procedure Encode; override;
    procedure EncodeL(var AEncodeData: string; const ARawData: string); virtual;
    procedure EncodeR(var AEncodeData: string; const ARawData: string); virtual;

    procedure EncodeAddon(var AEncodeData: string; const ARawAddon: string); virtual;
  end;

implementation
uses
  System.SysUtils,
  System.StrUtils;

resourcestring
  StrExceptionLength = '%s: Length must be %d or %d digits';
  StrExceptionNumbers = '%s: Must contain only numbers';
  StrExceptionCRC = '%s: CRC Error';

  StrExceptionAddonLength = '%s: Addon Length must be %d or %d digits';
  StrExceptionAddonNumbers = '%s: Addon Must contain only numbers';

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

procedure TEANCustom.Encode;
begin
  FEncodeData := NormalGuardPattern;
  EncodeL(FEncodeData, FRawData);
  FEncodeData := FEncodeData + CentreGuardPattern;
  EncodeR(FEncodeData, FRawData);
  FEncodeData := FEncodeData + NormalGuardPattern;
end;

procedure TEANCustom.EncodeAddon(var AEncodeData: string;
   const ARawAddon: string);
begin
  if (ARawAddon.Length = 2) or (ARawAddon.Length = 5) then  begin
    AEncodeData := AEncodeData + AddonDelimiter;

    case ARawAddon.Length of
      2: EncodeAddonTwo(AEncodeData,  ARawAddon);
      5: EncodeAddonFive(AEncodeData, ARawAddon);
    end;
  end;
end;

procedure TEANCustom.EncodeAddonFive(var AEncodeData: string;
  const ARawAddon: string);
var
  Pattern, Sequence: string;

  Sequences: TArray<string>;
  I: integer;

  function GetIdx(const AAddon: string): integer;
  var
    Step1,
    Step2,
    Step3: integer;
  begin
    Step1 :=
      AAddon.Substring(0,1).ToInteger +
      AAddon.Substring(2,1).ToInteger +
      AAddon.Substring(4,1).ToInteger;

    Step1 := Step1 * 3;

    Step2 :=
      AAddon.Substring(1,1).ToInteger +
      AAddon.Substring(3,1).ToInteger;

    Step2 := Step2 * 9;
    Step3 := Step1 + Step2;

    result := Step3.ToString
                   .Substring(Step3.ToString.Length-1).ToInteger;
  end;

begin
  Pattern := PatternAddonFive[GetIdx(ARawAddon)];

  AEncodeData := AEncodeData + AddonGuardPattern;
  for I := 1 to 5 do begin
    if Pattern[I] = 'A' then
      Sequence := SequencesA[string(ARawAddon[I]).ToInteger]
    else
      Sequence := SequencesB[string(ARawAddon[I]).ToInteger];

    Sequences := Sequences + [Sequence];
  end;

  AEncodeData := AEncodeData + string.Join(AddonDelineatorPattern, Sequences);
end;

procedure TEANCustom.EncodeAddonTwo(var AEncodeData: string;
  const ARawAddon: string);
var
  Pattern, Sequence: string;
  Sequences: TArray<string>;
  I: integer;

  function IsMultiple(const AValue, Multiple: integer): boolean;
  begin
    result := (AValue mod Multiple) = 0;
  end;

begin
  AEncodeData := AEncodeData + AddonGuardPattern;

  if (ARawAddon.ToInteger = 0) or IsMultiple(ARawAddon.ToInteger, 4) then
    Pattern := PatternsAddonTwo[0]
  else if (ARawAddon.ToInteger = 1) or IsMultiple(ARawAddon.ToInteger, 4+1) then
    Pattern := PatternsAddonTwo[1]
  else if (ARawAddon.ToInteger = 2) or IsMultiple(ARawAddon.ToInteger, 4+2) then
    Pattern := PatternsAddonTwo[2]
  else
    Pattern := PatternsAddonTwo[3];

  for I := 1 to 2 do begin
    if Pattern[I] = 'A' then
      Sequence := SequencesA[string(ARawAddon[I]).ToInteger]
    else
      Sequence := SequencesB[string(ARawAddon[I]).ToInteger];

    Sequences := Sequences + [Sequence];
  end;

  AEncodeData := AEncodeData + string.Join(AddonDelineatorPattern, Sequences);
end;

procedure TEANCustom.EncodeL(var AEncodeData: string; const ARawData: string);
begin

end;

procedure TEANCustom.EncodeR(var AEncodeData: string; const ARawData: string);
begin

end;

procedure TEANCustom.ValidateRawAddon(const Value: string);
var
  Duck: int64;
  BarType: TBarcodeType;
begin
  BarType   := GetType;

  if Value.IsEmpty then exit;
  
  if not ((Value.Length = 2) or (Value.Length = 5)) then
    raise EArgumentException.Create(format(StrExceptionAddonLength, [BarType.ToString, 2, 5]));

  if not TryStrToInt64(Value, Duck) then
    raise EArgumentException.Create(format(StrExceptionAddonNumbers, [BarType.ToString]));
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
