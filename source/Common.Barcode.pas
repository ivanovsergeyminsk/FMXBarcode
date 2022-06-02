unit Common.Barcode;

interface
uses
 Common.Barcode.IBarcode,
 FMX.Objects,
 System.Generics.Collections, Common.Barcode.Drawer;

type
  TBarcodeType = (EAN8, EAN13, UPCA, UPCE, ITF14, GS128, Code128);

  TBarcode = class
  private
    class var Impementations: TDictionary<TBarcodeType, TClass>;
    class constructor Create;
    class destructor Destroy;
    class function GetImplement(const AType: TBarcodeType): IBarcode;
  private
    FBarcode: IBarcode;
    function GetRawData: string;
    procedure SetRawData(const Value: string);

    function GetAddonData: string;
    procedure SetAddonData(const Value: string);
  public
    constructor Create(const AType: TBarcodeType);
    destructor Destroy; override;

    property RawData: string read GetRawData write SetRawData;
    property AddonData: string read GetAddonData write SetAddonData;

    function SVG: string; overload;


    class function SVG(AType: TBarcodeType; RawData: string): string; overload; static;
    class function SVG(AType: TBarcodeType; RawData, AddonData: string): string; overload; static;
    class procedure RegisterBarcode(const AType: TBarcodeType; const AImplementation: TClass);
  end;

  TBarcodeTypeHelper = record helper for TBarcodeType
    function ToString: string;
  end;

  TBarcodeCustom = class abstract(TInterfacedObject, IBarcode)
  protected
    FEncodeData: string;
    FRawData: string;
    FRawAddon: string;

    function GetLength: integer; virtual; abstract;
    function GetType: TBarcodeType; virtual; abstract;

   procedure ValidateRawAddon(const Value: string); virtual; abstract;
   procedure ValidateRawData(const Value: string); virtual; abstract;

    function GetCRC(const ARawData: string): integer; virtual; abstract;
    function CheckCRC(const ARawData: string): boolean; virtual;

   procedure Encode; virtual; abstract;

    //IBarcode
   function GetRawData: string;
   procedure SetRawData(const Value: string);

   function GetAddonData: string;
   procedure SetAddonData(const Value: string);

   function GetSVG: string; virtual;
  end;

implementation

uses
  System.SysUtils;

{ TBarcode }

constructor TBarcode.Create(const AType: TBarcodeType);
begin
  FBarcode := TBarcode.GetImplement(AType);
  if FBarcode = nil then
    raise Exception.Create('Barcode not implements.');
end;

destructor TBarcode.Destroy;
begin
  FBarcode := nil;
end;

function TBarcode.SVG: string;
begin

  result := FBarcode.SVG;
end;

class constructor TBarcode.Create;
begin
  TBarcode.Impementations := TDictionary<TBarcodeType, TClass>.Create;
end;

class destructor TBarcode.Destroy;
begin
  TBarcode.Impementations.Free;
end;

function TBarcode.GetAddonData: string;
begin
  result := FBarcode.AddonData;
end;

class function TBarcode.GetImplement(const AType: TBarcodeType): IBarcode;
var
  BarcodeClass: TClass;
  Obj: TObject;
begin
  if not TBarcode.Impementations.TryGetValue(AType, BarcodeClass) then begin
    result := nil;
    exit;
  end;

  Obj := BarcodeClass.Create;
  Supports(Obj, IBarcode, result);
end;

function TBarcode.GetRawData: string;
begin
  result := FBarcode.RawData
end;

class procedure TBarcode.RegisterBarcode(const AType: TBarcodeType;
  const AImplementation: TClass);
begin
  if Supports(AImplementation, IBarcode) then
    TBarcode.Impementations.AddOrSetValue(AType, AImplementation);
end;

procedure TBarcode.SetAddonData(const Value: string);
begin
  FBarcode.AddonData := Value;
end;

procedure TBarcode.SetRawData(const Value: string);
begin
  FBarcode.RawData := Value;
end;

class function TBarcode.SVG(AType: TBarcodeType; RawData,
  AddonData: string): string;
var
  Barcode: TBarcode;
begin
  Barcode := TBarcode.Create(AType);
  try
    Barcode.RawData   := RawData;
    Barcode.AddonData := AddonData;
    result := Barcode.SVG;
  finally
    Barcode.Free;
  end;
end;

class function TBarcode.SVG(AType: TBarcodeType; RawData: string): string;
begin
  result := TBarcode.SVG(AType, RawData, string.Empty);
end;

{ TBarcodeTypeHelper }

function TBarcodeTypeHelper.ToString: string;
begin
  case self of
    EAN8:     result := 'EAN8';
    EAN13:    result := 'EAN13';
    UPCA:     result := 'UPC-A';
    UPCE:     result := 'UPC-E';
    ITF14:    result := 'ITF-14';
    GS128:    result := 'GS-128';
    Code128:  result := 'Code-128';
    else      result := 'unknown';
  end;
end;

{ TBarcodeCustom }

function TBarcodeCustom.CheckCRC(const ARawData: string): boolean;
var
  RawCRC: integer;
  CRC: integer;
begin
  RawCRC := int32.Parse(string(ARawData[ARawData.Length]));
  CRC    := self.GetCRC(ARawData);
  result := RawCRC = CRC;
end;

function TBarcodeCustom.GetAddonData: string;
begin
  result := FRawAddon;
end;

function TBarcodeCustom.GetRawData: string;
begin
  result := FRawData;
end;

function TBarcodeCustom.GetSVG: string;
var
  Drawer: IBarcodeDrawer;
begin
  Drawer := TBarcodeDrawer.Create;
  result := Drawer.SVG(FEncodeData);
end;

procedure TBarcodeCustom.SetAddonData(const Value: string);
begin
  ValidateRawAddon(Value);
  FRawAddon := Value;

  Encode;
end;

procedure TBarcodeCustom.SetRawData(const Value: string);
begin
  ValidateRawData(Value.Trim);

  FRawData := Value.Trim;
  Encode;
end;

end.
