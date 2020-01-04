unit Common.Barcode.IBarcode;

interface

uses
  FMX.Objects;

type
  IBarcode = interface
   ['{866573A2-D281-48D3-9799-B7D218E6C6AC}']
   function GetRawData: string;
   procedure SetRawData(const Value: string);

   function GetSVG: string;

   property RawData: string read GetRawData write SetRawData;
   property SVG: string read GetSVG;
  end;

implementation

end.
