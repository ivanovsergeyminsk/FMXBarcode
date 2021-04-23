# FMXBarcode
Generates a barcode image as svg-path (TPath.Data)

| Barcode type | Barcode | Supported          |
| --------------- | ----------- | ------------------ |
| Linear          | EAN-8       | :white_check_mark: |
|                 | EAN-13      | :white_check_mark: |
|                 | UPC-A       | :white_check_mark: |
|                 | UPC-E       | :white_check_mark: |
|                 | ITF-14      | :white_check_mark: |
|                 | GS-128      | :white_check_mark: |
|                 | Databar     | :x: (future)       |
| Two dimensioanl | DataMatrix  | :x: (future)       |
|                 | QR Code     | :x: (future)       |
|                 | DotCode     | :x: (future)       |
| Composite       |             | :x: (future)       |

# Using
Add the module:
```pascal
uses
 Common.Barcode;
```

Get svg-path:
```pascal
var
  Barcode: TBarcode;
  SVGString: string;
begin
  Barcode := TBarcode.Create(TBarcodeType.EAN8);
  try
    Barcode.RawData := '12345678';
    SVGString := Barcode.SVG;
  finally
    Barcode.Free;
  end;
end;
```

You can display the barcode through the TPath component: 
```pascal
var
 Barcode: TBarcode;
 DisplayBarcode: TPath;
begin
//...
  DisplayBarcode.Data.Data := Barcode.SVG;
//...
end;
```
