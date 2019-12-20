unit View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, FMX.ScrollBox, FMX.Memo,
  FMX.Layouts, FMX.ListBox,
  Common.Barcode;

type
  TForm1 = class(TForm)
    EditRawData: TEdit;
    ButtonGenerateBarcode: TButton;
    PathBarcode: TPath;
    LayoutTop: TLayout;
    LayoutClient: TLayout;
    MemoSVGPathData: TMemo;
    ComboBoxBarcodeType: TComboBox;
    LayoutRight: TLayout;
    SplitterRight: TSplitter;
    TextSVG: TText;
    procedure ButtonGenerateBarcodeClick(Sender: TObject);
    procedure PathBarcodeResize(Sender: TObject);
  private
    { Private declarations }
    FLastSelectedType: TBarcodeType;
    function SelectedBarcodeType: TBarcodeType;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.ButtonGenerateBarcodeClick(Sender: TObject);
var
  Barcode: TBarcode;
begin
  FLastSelectedType := SelectedBarcodeType;
  Barcode := TBarcode.Create(FLastSelectedType);
  try
    Barcode.RawData := EditRawData.Text;

    PathBarcode.Data.Data := Barcode.SVG;
    MemoSVGPathData.Lines.Text := Barcode.SVG;
  finally
    Barcode.Free;
  end;
end;

procedure TForm1.PathBarcodeResize(Sender: TObject);
begin
  PathBarcode.Stroke.Thickness := TBarcode.Thickness(FLastSelectedType, PathBarcode.Width);
end;

function TForm1.SelectedBarcodeType: TBarcodeType;
begin
  result := TBarcodeType(ComboBoxBarcodeType.ItemIndex);
end;

initialization
  ReportMemoryLeaksOnShutdown := true;

finalization
  CheckSynchronize;

end.
