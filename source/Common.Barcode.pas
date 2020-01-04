unit Common.Barcode;

interface
uses
 Common.Barcode.IBarcode,
 FMX.Objects,
 System.Generics.Collections;

type
  TBarcodeType = (EAN8, EAN13, UPC_A);

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
  public
    constructor Create(const AType: TBarcodeType);
    destructor Destroy; override;

    property RawData: string read GetRawData write SetRawData;

    function SVG: string;

    class procedure RegisterBarcode(const AType: TBarcodeType; const AImplementation: TClass);
  end;

  TBarcodeTypeHelper = record helper for TBarcodeType
    function ToString: string;
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

procedure TBarcode.SetRawData(const Value: string);
begin
  FBarcode.RawData := Value;
end;

{ TBarcodeTypeHelper }

function TBarcodeTypeHelper.ToString: string;
begin
  case self of
    EAN8:   result := 'EAN8';
    EAN13:  result := 'EAN13';
    UPC_A:  result := 'UPC-A';
    else    result := 'unknown';
  end;
end;

end.
