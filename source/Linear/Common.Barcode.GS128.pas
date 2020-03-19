unit Common.Barcode.GS128;

interface
uses
  Common.Barcode,
  Common.Barcode.IBarcode,
  Common.Barcode.Drawer;

type
  TGS128 = class(TBarcodeCustom)
  protected const

    PatternCode128: array of string =
      ['11011001100', '11001101100', '11001100110', '10010011000', '10010001100',
       '10001001100', '10011001000', '10011000100', '10001100100', '11001001000',
       '11001000100', '11000100100', '10110011100', '10011011100', '10011001110',
       '10111001100', '10011101100', '10011100110', '11001110010', '11001011100',
       '11001001110', '11011100100', '11001110100', '11101101110', '11101001100',
       '11100101100', '11100100110', '11101100100', '11100110100', '11100110010',
       '11011011000', '11011000110', '11000110110', '10100011000', '10001011000',
       '10001000110', '10110001000', '10001101000', '10001100010', '11010001000',
       '11000101000', '11000100010', '10110111000', '10110001110', '10001101110',
       '10111011000', '10111000110', '10001110110', '11101110110', '11010001110',
       '11000101110', '11011101000', '11011100010', '11011101110', '11101011000',
       '11101000110', '11100010110', '11101101000', '11101100010', '11100011010',
       '11101111010', '11001000010', '11110001010', '10100110000', '10100001100',
       '10010110000', '10010000110', '10000101100', '10000100110', '10110010000',
       '10110000100', '10011010000', '10011000010', '10000110100', '10000110010',
       '11000010010', '11001010000', '11110111010', '11000010100', '10001111010',
       '10100111100', '10010111100', '10010011110', '10111100100', '10011110100',
       '10011110010', '11110100100', '11110010100', '11110010010', '11011011110',
       '11011110110', '11110110110', '10101111000', '10100011110', '10001011110',
       '10111101000', '10111100010', '11110101000', '11110100010', '10111011110',
       '10111101110', '11101011110', '11110101110', '11010000100', '11010010000',
       '11010011100'];
    PatternStop = '1100011101011';
    QuietZone   = '0000000000000';

  protected type
    TPatternCode = (CodeA, CodeB, CodeC);
  protected
    function PatternStartA: byte; inline;
    function PatternStartB: byte; inline;
    function PatternStartC: byte; inline;
    function PatternShift: byte; inline;
    function PatternCodeA(const CurrentCode: TPatternCode): byte; inline;
    function PatternCodeB(const CurrentCode: TPatternCode): byte; inline;
    function PatternCodeC(const CurrentCode: TPatternCode): byte; inline;
    function PatternFNC1(const CurrentCode: TPatternCode): byte; inline;
    function PatternFNC2(const CurrentCode: TPatternCode): byte; inline;
    function PatternFNC3(const CurrentCode: TPatternCode): byte; inline;
    function PatternFNC4(const CurrentCode: TPatternCode): byte; inline;

    function GetPatternCode(AChar: AnsiChar): TPatternCode;

    function GetLength: integer; override;
    function GetType: TBarcodeType; override;

    procedure ValidateRawData(const Value: string); override;
    procedure ValidateRawAddon(const Value: string); override;

    function GetCRC(const ARawData: string): integer; override;

    procedure Encode; override;
    function EncodeRaw(ARawData: string): string;
    function EncodeRawByte(ARawData: string): TArray<byte>;
    function GetSymbolCheck(ARawByte: TArray<byte>): byte;
  end;
implementation
uses
  System.SysUtils, System.Math;

{ TGS128 }

function TGS128.PatternCodeA(const CurrentCode: TPatternCode): byte;
begin
  case CurrentCode of
    CodeB: result := 100;
    CodeC: result := 99;
    else raise Exception.Create('GS128. PatternCodeA.');
  end;
end;

function TGS128.PatternCodeB(const CurrentCode: TPatternCode): byte;
begin
  case CurrentCode of
    CodeA: result := 101;
    CodeC: result := 99;
    else raise Exception.Create('GS128. PatternCodeB.');
  end;
end;

function TGS128.PatternCodeC(const CurrentCode: TPatternCode): byte;
begin
  case CurrentCode of
    CodeA: result := 101;
    CodeB: result := 100;
    else raise Exception.Create('GS128. PatternCodeC.');
  end;
end;

function TGS128.PatternFNC1(const CurrentCode: TPatternCode): byte;
begin
  result := 102;
end;

function TGS128.PatternFNC2(const CurrentCode: TPatternCode): byte;
begin
  result := 97;
end;

function TGS128.PatternFNC3(const CurrentCode: TPatternCode): byte;
begin
  result := 96;
end;

function TGS128.PatternFNC4(const CurrentCode: TPatternCode): byte;
begin
  case CurrentCode of
    CodeA: result := 101;
    CodeB: result := 100;
    else raise Exception.Create('GS128, PatternFNC4.');
  end;
end;

function TGS128.PatternShift: byte;
begin
  result := 98;
end;

function TGS128.PatternStartA: byte;
begin
  result := 103;
end;

function TGS128.PatternStartB: byte;
begin
  result := 104;
end;

function TGS128.PatternStartC: byte;
begin
  result := 105;
end;

function TGS128.GetPatternCode(AChar: AnsiChar): TPatternCode;
begin
  case ord(AChar) of
    0..95: result := TPatternCode.CodeA;
    else   result := TPatternCode.CodeB;
  end;
end;

procedure TGS128.Encode;
begin
  FEncodeData := QuietZone;
  FEncodeData := FEncodeData + EncodeRaw(FRawData);

  FEncodeData := FEncodeData + PatternStop;
  FEncodeData := FEncodeData + QuietZone;
end;

function TGS128.EncodeRaw(ARawData: string): string;
var
  RawByte: TArray<byte>;
  ChValue: byte;
begin
  result := string.Empty;
  RawByte := EncodeRawByte(ARawData);

  for ChValue in RawByte do
    result := result + PatternCode128[chValue];
end;

function TGS128.EncodeRawByte(ARawData: string): TArray<byte>;
var
  CurrentCode, NewCode: TPatternCode;
  AnsiRawData: AnsiString;
  Ch: AnsiChar;
  ChCode: integer;
  ChCheck: integer;
begin  
  result := [];
 if ARawData.IsEmpty then exit;
  AnsiRawData := AnsiString(ARawData);

  currentCode := GetPatternCode(AnsiRawData[1]);

  case CurrentCode of
    CodeA: result := result + [PatternStartA];
    CodeB: result := result + [PatternStartB];
  end;

  result := result + [PatternFNC1(CurrentCode)];

  for Ch in AnsiRawData do begin
    ChCode := 0;
    NewCode := GetPatternCode(Ch);
    if CurrentCode <> NewCode then begin
      case NewCode of
        CodeA: result := result + [PatternCodeA(CurrentCode)];
        CodeB: result := result + [PatternCodeB(CurrentCode)];
      end;
      CurrentCode := NewCode;
    end;

    case CurrentCode of
      CodeA:  ChCode := ifthen(ord(Ch) < 32, ord(ch)+64, ord(ch)-32);
      CodeB:  ChCode := ord(Ch)-32;
    end;

    result := result + [ChCode];
  end;

  ChCheck := GetSymbolCheck(result);
  result := result + [ChCheck];
end;

function TGS128.GetSymbolCheck(ARawByte: TArray<byte>): byte;
var
  I: integer;
  SymbolCheck: integer;
begin
  SymbolCheck := ARawByte[0] + ARawByte[1];
  for I := 2 to length(ARawByte)-1 do
    SymbolCheck := SymbolCheck + ARawByte[I]*I;

  result := SymbolCheck mod 103;
end;

function TGS128.GetCRC(const ARawData: string): integer;
begin
  result := 0;
end;

function TGS128.GetLength: integer;
begin
  result := 0;
end;

function TGS128.GetType: TBarcodeType;
begin
  result := TBarcodeType.GS128;
end;

procedure TGS128.ValidateRawAddon(const Value: string);
begin
  inherited;

end;

procedure TGS128.ValidateRawData(const Value: string);
begin
  inherited;

end;

initialization
  TBarcode.RegisterBarcode(TBarcodeType.GS128, TGS128);

end.
