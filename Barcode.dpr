program Barcode;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Main in 'Example\View.Main.pas' {FormMain},
  Common.Barcode in 'source\Common.Barcode.pas',
  Common.Barcode.IBarcode in 'source\Common.Barcode.IBarcode.pas',
  Common.Barcode.EAN13 in 'source\Common.Barcode.EAN13.pas',
  Common.Barcode.EAN8 in 'source\Common.Barcode.EAN8.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
