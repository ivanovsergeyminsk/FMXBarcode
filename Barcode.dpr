program Barcode;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Main in 'Example\View.Main.pas' {Form1},
  Common.Barcode in 'source\Common.Barcode.pas',
  Common.Barcode.IBarcode in 'source\Common.Barcode.IBarcode.pas',
  Common.Barcode.EAN13 in 'source\Common.Barcode.EAN13.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
