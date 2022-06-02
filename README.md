# FMXBarcode
Generates a barcode image as svg-path (TPath.Data)

| Barcode type | Barcode | Supported          |
| --------------- | ----------- | ------------------ |
| Linear          | EAN-8       | :white_check_mark: |
|                 | EAN-13      | :white_check_mark: |
|                 | UPC-A       | :white_check_mark: |
|                 | UPC-E       | :white_check_mark: |
|                 | ITF-14      | :white_check_mark: |
|                 | Code-128    | :white_check_mark: |  
|                 | GS-128      | :white_check_mark: |
|                 | Databar     | :x: (future)       |
| Two dimensioanl | DataMatrix  | :x: (future)       |
|                 | QR Code     | :x: (future)       |
|                 | DotCode     | :x: (future)       |
| Composite       |             | :x: (future)       |

![EAN8](/Example/screens/BarcodeExample_EAN8.png) 
![EAN8](/Example/screens/BarcodeExample_GS128.png)

# Using
Add the module:
```pascal
uses
 Common.Barcode;
```

Get svg-path:
```pascal
var
  SVGString: string;
begin
  SVGString := TBarcode.SVG(TBarcodeType.EAN8, '1234567');
end;
```

You can display the barcode through the TPath component: 
```pascal
var
 DisplayBarcode: TPath;
begin
//...
  DisplayBarcode.Data.Data := TBarcode.SVG(TBarcodeType.Code128, 'User:1234567');
//...
end;
```
