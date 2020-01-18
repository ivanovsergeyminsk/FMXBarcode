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
  protected
    function GetLength: integer; override;
    function GetType: TBarcodeType; override;

    procedure ValidateRawData(const Value: string); override;
    procedure ValidateRawAddon(const Value: string); override;

    function GetCRC(const ARawData: string): integer; override;

    procedure Encode; override;
  end;
implementation

{ TGS128 }

procedure TGS128.Encode;
begin
  inherited;

end;

function TGS128.GetCRC(const ARawData: string): integer;
begin

end;

function TGS128.GetLength: integer;
begin

end;

function TGS128.GetType: TBarcodeType;
begin

end;

procedure TGS128.ValidateRawAddon(const Value: string);
begin
  inherited;

end;

procedure TGS128.ValidateRawData(const Value: string);
begin
  inherited;

end;

end.
