unit Common.Barcode.Drawer;

interface

type
  IBarcodeDrawer = interface
  ['{A253E38C-AA33-47D5-B258-2DEE410BD8F2}']
    function SVG(const AEncodedData: string): string;
  end;

  TBarcodeDrawer = class(TInterfacedObject, IBarcodeDrawer)
  protected
    function Get1(const Position, Length: single): string; virtual;
    function Get0(const Position: single): string; virtual;

    //IBarcodeDrawer
    function SVG(const AEncodedData: string): string; virtual;
  end;

implementation
uses
  System.SysUtils;

{ TBarcodeDrawer }

function TBarcodeDrawer.Get0(const Position: single): string;
begin
  result := format('m %s,0', [Position.ToString.Replace(',','.')]);
end;

function TBarcodeDrawer.Get1(const Position, Length: single): string;
var
  Space: string;
  Line: string;
begin
  Space := format('m %s,0', [Position.ToString.Replace(',','.')]);
  Line  := format('h -%s v %s h %s z', [Position.ToString.Replace(',','.'),
                                        Length.ToString.Replace(',','.'),
                                        Position.ToString.Replace(',','.')
                                       ]);
  result := string.Join(' ', [Space,Line]);
end;

function TBarcodeDrawer.SVG(const AEncodedData: string): string;
var
  Item: char;
  LPath: string;
  Size, Length: currency;
begin
  Size := 0.33;
  Length := 1.0;
  result :=  Get0(1);
  for Item in AEncodedData do begin
    if Item = '0'
      then LPath := Get0(Size)
      else LPath := Get1(Size, Length);

    result := result + LPath;
  end;
end;

end.
