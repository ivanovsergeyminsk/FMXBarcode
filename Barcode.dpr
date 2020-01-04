program Barcode;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Main in 'Example\View.Main.pas' {FormMain},
  Common.Barcode in 'source\Common.Barcode.pas',
  Common.Barcode.IBarcode in 'source\Common.Barcode.IBarcode.pas',
  Common.Barcode.EAN13 in 'source\EAN_UPC\Common.Barcode.EAN13.pas',
  Common.Barcode.EAN8 in 'source\EAN_UPC\Common.Barcode.EAN8.pas',
  Common.Barcode.UPC_A in 'source\EAN_UPC\Common.Barcode.UPC_A.pas',
  Common.Barcode.Drawer in 'source\Common.Barcode.Drawer.pas',
  Common.Barcode.EAN in 'source\EAN_UPC\Common.Barcode.EAN.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
