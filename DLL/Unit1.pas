unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScktComp, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  function FEMET_ResetBAR(IP:string):boolean;stdcall;far;external 'FEMET_Service.dll';
  function FEMET_ResetSIM(IP:string):boolean;stdcall;far;external 'FEMET_Service.dll';
  function FEMET_GetSIMState(IP:string):pchar;stdcall;far;external 'FEMET_Service.dll';
  function FEMET_GetBARState(IP:string):pchar;stdcall;far;external 'FEMET_Service.dll';

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
   Memo1.Text:= FEMET_GetBARState('127.0.0.1');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Memo1.Text:= FEMET_GetSIMState('127.0.0.1');
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Memo1.Text:= booltostr(FEMET_ResetBAR('127.0.0.1'),true);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Memo1.Text:= booltostr(FEMET_ResetSIM('127.0.0.1'),true);
end;

end.
