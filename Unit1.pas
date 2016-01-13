unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScktComp, StdCtrls, OleCtrls, SHDocVw, ExtCtrls, ComCtrls,inifiles,
  Buttons,printers,xpman,shellapi;

type
  TForm1 = class(TForm)
    Web: TWebBrowser;
    BarTimer: TTimer;
    LockTimer: TTimer;
    SIMTimer: TTimer;
    CustomTimer: TTimer;
    PrintBTN: TBitBtn;
    Edit1: TEdit;
    PageTimer: TTimer;
    BT_End: TButton;
    BT_Restart: TButton;
    IdleTimer: TTimer;
    Client: TClientSocket;
    procedure FormCreate(Sender: TObject);
    procedure BarTimerTimer(Sender: TObject);
    procedure LockTimerTimer(Sender: TObject);
    procedure SIMTimerTimer(Sender: TObject);
    procedure CustomTimerTimer(Sender: TObject);
    procedure PrintBTNClick(Sender: TObject);
    procedure PageTimerTimer(Sender: TObject);
    procedure BT_EndClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BT_RestartClick(Sender: TObject);
    procedure IdleTimerTimer(Sender: TObject);
    procedure ClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  private
    { Private declarations }
  public
    procedure GetInfo();
    procedure PreCloseServicePlugin;
  end;

  DataState=record
     SYS,DIA,HR,GLU,WAGLU,IDNO,WT,SPO2,ECG:string;
     cname,cbirthday,cheight,ctelno:string;
     StateChange:boolean;
     LastStateStr:string;
     NowStateStr:string;
  end;



var
  Form1: TForm1;
  Reseted: boolean;
  BARData:TstringList;
  SIMData:TstringList;
  VitalData:TstringList;
  FEMET:DataState;
  MAINADDR:string;

  IdleRestart:int64;      //config 閒置
  IdleTimeInit:int64;         //從此程式開起到目前為止idle多久
  vLastInputInfo: TLastInputInfo;

  SimStr:TStringlist; //多帶姓名，生日，性別
  function FEMET_Init(IP:string):boolean;stdcall;far;external 'FEMET_Service.dll';
  function FEMET_ResetBAR(IP:string):boolean;stdcall;far;external 'FEMET_Service.dll';
  function FEMET_GetBARState(IP:string):pchar;stdcall;far;external 'FEMET_Service.dll';
  function FEMET_GetVital(IP:string):pchar;stdcall;far;external 'FEMET_Service.dll';
  function FEMET_ResetSIM(IP:string):boolean;stdcall;far;external 'FEMET_Service.dll';
  function FEMET_GetSIMState(IP:string):pchar;stdcall;far;external 'FEMET_Service.dll';
  procedure FEMET_Release();stdcall;far;external 'FEMET_Service.dll';

implementation

{$R *.dfm}

procedure TForm1.GetInfo();
var
  Addr:string;
  Docs, Edits: OleVariant;
begin
  
  Docs := WEB.OleObject.Document;

  try
    Edits := Docs.Forms.item('form', 0).all.Item('cname', 0);
    FEMET.cname:=Edits.Value;
    Edits := Docs.Forms.item('form', 0).all.Item('cbirthday', 0);
    FEMET.cbirthday:=Edits.Value;
    Edits := Docs.Forms.item('form', 0).all.Item('cheight', 0);
    FEMET.cheight:=Edits.Value;
    Edits := Docs.Forms.item('form', 0).all.Item('ctelno', 0);
    FEMET.ctelno:=Edits.Value;
    Edits := Docs.Forms.item('form', 0).all.Item('wt', 0);
    FEMET.WT:=Edits.Value;
  except
    exit;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ConfigINI:tinifile;
  DataPath:string;
  i:integer;
begin

  DataPath:=ExtractFilePath(Application.ExeName);
  ConfigINI:=tinifile.create(DataPath+'Config.ini');
//===========================================================SQL DB
  MAINADDR          := ConfigINI.ReadString('SETTING','ADDR','http://61.60.148.156:8080/cchwt_Client/client_vital_wt/');
  IdleRestart       := ConfigINI.ReadInteger('SETTING','IdleRestart',3600);

  ConfigINI.WriteString('SETTING','ADDR',MAINADDR);
  ConfigINI.WriteInteger('SETTING','IdleRestart',IdleRestart);

  //Web.Navigate('http://192.168.0.102:8080/client_vital_demo/index.php');
  //Web.Navigate('http://192.168.0.102:8080/client_vital_demo/index.php?id=L124017132&sys=120&dia=80&hr=70&glu=140&act=');
  Web.Navigate(MAINADDR+'step1.php');
  SimStr:=TStringlist.Create;
  SimStr.Delimiter:=',';
  BARData:=TstringList.Create;
  BARData.Delimiter:=',';
  VitalData:=TstringList.Create;
  VitalData.Delimiter:=',';
 
  FEMET_Init('127.0.0.1');
end;

function CheckStateChange():boolean;
begin
  result:=false;

  if (FEMET.NowStateStr='') then
  begin
     FEMET.LastStateStr:=FEMET.NowStateStr;
     exit;
  end;
  if FEMET.LastStateStr<>FEMET.NowStateStr then
    result:=true;

  FEMET.LastStateStr:=FEMET.NowStateStr;
end;

function RefreshVitalData():bool;
var
  Addr:string;
  ECGF:Textfile;
begin
    result:=false;
    VitalData.DelimitedText:=FEMET_GetVital('127.0.0.1');
    if VitalData.Count<8 then exit;
    FEMET.SYS:=VitalData.Strings[0];
    FEMET.DIA:=VitalData.Strings[1];
    FEMET.HR:=VitalData.Strings[2];
    FEMET.GLU:=VitalData.Strings[3];
    FEMET.WAGLU:=VitalData.Strings[4];
    FEMET.WT:=VitalData.Strings[5];
    FEMET.SPO2:=VitalData.Strings[6];
    if VitalData.Strings[7]<>'' then FEMET.SPO2:=VitalData.Strings[7];

    try
      assignfile(ECGF,ExtractFileDir(application.ExeName)+'\ECG.txt');
      reset(ECGF);
      read(ECGF,FEMET.ECG);
      closefile(ECGF);
    except
    end;
    //FEMET.ECG:=VitalData.Strings[8];

    if FEMET.SYS='0' then FEMET.SYS:='';
    if FEMET.DIA='0' then FEMET.DIA:='';
    if FEMET.HR='0' then FEMET.HR:='';
    if FEMET.GLU='0' then FEMET.GLU:='';
    if FEMET.SPO2='0' then FEMET.GLU:='';
    result:=true; 
end;

procedure TForm1.BarTimerTimer(Sender: TObject);
var
  Addr:string;
begin
   BarTimer.Enabled:=false;
   BARData.DelimitedText:=FEMET_GetBARState('127.0.0.1');   

   RefreshVitalData();
   FEMET.IDNO:=BARData.Strings[5];

   FEMET.NowStateStr:=BARData.Strings[5];//BARData.DelimitedText;//+VitalData.DelimitedText;

   if CheckStateChange()=true then
   begin
      GetInfo();
      Addr:=MAINADDR+format('index.php?id=%s&sys=%s&dia=%s&hr=%s&glu=%s&wt=%s',
                    [FEMET.IDNO,FEMET.SYS,FEMET.DIA,FEMET.HR,FEMET.GLU,FEMET.wt]);
      //showmessage(Addr);
      edit1.text:=Addr;
      form1.Web.Navigate(Addr);

      FEMET_ResetBAR('127.0.0.1');
      FEMET.LastStateStr:='';
      FEMET.NowStateStr:='';
   end;
   //StatusBar1.SimpleText:=WEB.LocationURL;
   BarTimer.Enabled:=true;
end;

procedure TForm1.LockTimerTimer(Sender: TObject);
begin
{
  if (pos('step4-1.php',Web.LocationURL)>0) then
    BarTimer.Enabled:=true
  else
  begin
    BarTimer.Enabled:=false;
  end;

  if (pos('step4-2.php',Web.LocationURL)>0) then
    SIMTimer.Enabled:=true
  else
  begin
    SIMTimer.Enabled:=false;
  end;

  if (pos('step4-3.php',Web.LocationURL)>0) then
    CustomTimer.Enabled:=true
  else
  begin
    CustomTimer.Enabled:=false;
  end;

  if (pos('step1.php',Web.LocationURL)>0)and(Reseted=false)then
  begin
     FEMET_ResetBAR('127.0.0.1');
     FEMET_ResetSIM('127.0.0.1');
     FEMET.LastStateStr:='';
     FEMET.NowStateStr:='';
     Reseted:=true;
  end
  else
  begin
    if (pos('step1.php',Web.LocationURL)<=0) then //若不是在第一頁
      Reseted:=false;
  end;
}
end;



procedure TForm1.SIMTimerTimer(Sender: TObject);
var
  Addr:string;
begin
   SIMTimer.Enabled:=false;
   SIMData.DelimitedText:=FEMET_GetSIMState('127.0.0.1');
   RefreshVitalData();
   FEMET.IDNO:=SIMData.Strings[5];

   FEMET.NowStateStr:=SIMData.Strings[5];//BARData.DelimitedText;//+VitalData.DelimitedText;

   if FEMET.IDNO<>'' then
   begin
      GetInfo();
      Addr:=MAINADDR+format('index1.php?id=%s&sys=%s&dia=%s&hr=%s&glu=%s&wt=%s&cname=%s&cbirthday=%s&cheight=%s&ctelno=%s&act=save',
                    [FEMET.IDNO,FEMET.SYS,FEMET.DIA,FEMET.HR,FEMET.GLU,FEMET.wt,FEMET.cname,FEMET.cbirthday,FEMET.cheight,FEMET.ctelno]);
      //showmessage(Addr);
      FEMET_ResetSIM('127.0.0.1');

      form1.Web.Navigate(Addr);
      FEMET.LastStateStr:='';
      FEMET.NowStateStr:='';
   end;
   //StatusBar1.SimpleText:=WEB.LocationURL;
   SIMTimer.Enabled:=true;
end;

procedure TForm1.CustomTimerTimer(Sender: TObject);
var
  Addr:string;
  Docs, Edits: OleVariant;
begin
  CustomTimer.Enabled:=false;
  RefreshVitalData();
  
  Docs := WEB.OleObject.Document;

  try
    Edits := Docs.Forms.item('form', 0).all.Item('glu', 0);
    Edits.Value := FEMET.GLU;
    Edits := Docs.Forms.item('form', 0).all.Item('sys', 0);
    Edits.Value := FEMET.SYS;
    Edits := Docs.Forms.item('form', 0).all.Item('dia', 0);
    Edits.Value := FEMET.DIA;
    Edits := Docs.Forms.item('form', 0).all.Item('hr', 0);
    Edits.Value := FEMET.HR;
    Edits := Docs.Forms.item('form', 0).all.Item('wt', 0);
    Edits.Value := FEMET.WT;
    Edits := Docs.Forms.item('form', 0).all.Item('spo2', 0);
    Edits.Value := FEMET.SPO2;
    Edits := Docs.Forms.item('form', 0).all.Item('ekg', 0);
    Edits.Value := FEMET.ECG;
  except
    exit;
  end;
  FEMET.LastStateStr:='';
  FEMET.NowStateStr:='';

  CustomTimer.Enabled:=true;
end;

procedure TForm1.PrintBTNClick(Sender: TObject);
var PageWidth:integer;
begin
  PageWidth:=800;
  Printer.PrinterIndex := 0;
  Printer.Orientation := poPortrait;//直  poLandscape;    //橫
  Printer.BeginDoc; // ?定打印?容
  with Printer do
  begin
     // Set up a medium sized font
     Canvas.Font.Color := clBlack;
     Canvas.Font.Style:=[fsBold];

     // Write out
     Canvas.Font.Size   := 24;
     Canvas.TextOut(150,  0, '檢測數據');
     

     // Write out
     Canvas.Font.Name:='微軟正黑體';
     Canvas.Font.Size   := 10;
     Canvas.TextOut(50,  100, formatdatetime('檢測日期：yyyy/mm/dd  hh:nn',now));

     // Underline this page number
     Canvas.MoveTo(40,150);
     Canvas.LineTo(Printer.PageWidth-20,150);
     
     Canvas.TextOut(50,  200, format('您的血壓　收縮壓： %s mm/Hg',[FEMET.SYS]));
     Canvas.TextOut(50,  250, format('您的血壓　舒張壓： %s mm/Hg',[FEMET.DIA]));
     Canvas.TextOut(50,  300, format('您的心跳　　　　： %s beats/min',[FEMET.HR]));
     Canvas.TextOut(50,  350, format('您的血糖　　　　： %s mg/dL',[FEMET.GLU]));

     // Underline this page number
     Canvas.MoveTo(40,400);
     Canvas.LineTo(Printer.PageWidth-20,400);

     Canvas.TextOut(50,  450, '標準血壓　收縮壓： 120 mm/Hg');
     Canvas.TextOut(50,  500, '標準血壓　舒張壓： 80 mm/Hg');
     Canvas.TextOut(50,  550, '標準心跳　　　　： 60~100 beats/min');
     Canvas.TextOut(50,  600, '標準血糖　　　　： 80~120 mg/dL');

     // Underline this page number
     Canvas.MoveTo(40,650);
     Canvas.LineTo(Printer.PageWidth-20,650);

     Canvas.TextOut(50,  700, '遠　東　醫　電　科　技　關　心　您');

  end;
  Printer.EndDoc;

end;

procedure ERROUT(str:string);
begin
   //showmessage(str);
end;

procedure TForm1.PageTimerTimer(Sender: TObject);
var
  Docs, Edits: OleVariant;
begin
//----------------------------------------------血糖--------------------------------------
  if (pos('step1.php',Web.LocationURL)>0) then
  begin
     FEMET_ResetSIM('127.0.0.1');
  end;
//----------------------------------------------血糖--------------------------------------
  if (pos('step2-1.php',Web.LocationURL)>0) then
  begin
    try
      if RefreshVitalData()=false then exit;
      Docs := WEB.OleObject.Document;
      Edits := Docs.all.Item('glu', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.GLU;
      if FEMET.GLU='' then Edits.Value := FEMET.WAGLU;
      if FEMET.WAGLU='' then Edits.Value := FEMET.GLU;
    except
      ERROUT('血糖ERROR');
      exit;
    end;
  end;
//----------------------------------------------血壓--------------------------------------
  if (pos('step2-2.php',Web.LocationURL)>0) then
  begin
    try
      if RefreshVitalData()=false then exit;
      Docs := WEB.OleObject.Document;
      Edits := Docs.all.Item('sys', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.SYS;
      Edits := Docs.all.Item('dia', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.DIA;
      Edits := Docs.all.Item('hr', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.HR;
    except
      ERROUT('血壓ERROR');
      exit;
    end;
  end;
//----------------------------------------------體重--------------------------------------
  if (pos('step2-3.php',Web.LocationURL)>0) then
  begin
    try
      if RefreshVitalData()=false then exit;
      Docs := WEB.OleObject.Document;
      Edits := Docs.all.Item('wt', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.WT;
    except
      ERROUT('體重ERROR');
      exit;
    end;
  end;
//----------------------------------------------血氧--------------------------------------
  if (pos('step2-4.php',Web.LocationURL)>0) then
  begin
    try
      if RefreshVitalData()=false then exit;
      Docs := WEB.OleObject.Document;
      Edits := Docs.all.Item('spo2', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.spo2;
    except
      ERROUT('血氧ERROR');
      exit;
    end;
  end;
//----------------------------------------------EKG--------------------------------------
  if (pos('step2-5.php',Web.LocationURL)>0) then
  begin
    try
      if RefreshVitalData()=false then exit;
      Docs := WEB.OleObject.Document;
      Edits := Docs.all.Item('ekg', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.ECG;
    except
      ERROUT('EKG ERROR');
      exit;
    end;
  end;
//----------------------------------------CHECK EKG--------------------------------------
  if (pos('step2-6.php',Web.LocationURL)>0) then
  begin
    try
      if RefreshVitalData()=false then exit;
      Docs := WEB.OleObject.Document;
      Edits := Docs.all.Item('ekg', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      //Memo1.Text:= Edits.Value;
    except
      ERROUT('CHECK EKG ERROR');
      exit;
    end;
  end;
//--------------------------------------- 健保卡偵測 ---------------------------------------
  if (pos('step4-3.php',Web.LocationURL)>0) then
  begin
    SimStr.Clear;
    SimStr.DelimitedText:=FEMET_GetSIMState('127.0.0.1');
    SimStr.DelimitedText:=SimStr.Strings[5];
    if (SimStr.Count=4) and (SimStr.DelimitedText<>',,,')then
    begin
      Docs := WEB.OleObject.Document;
      Docs.Forms.item('frm', 0).submit;
    end;
  end;
//--------------------------------------- 健保卡帶入資料 ---------------------------------------
  if (pos('step5.php',Web.LocationURL)>0) then
  begin
    try
      if RefreshVitalData()=false then exit;
      Docs := WEB.OleObject.Document;
    {
      Edits := Docs.all.Item('sys', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.SYS;
      Edits := Docs.all.Item('dia', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.DIA;
      Edits := Docs.all.Item('hr', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := FEMET.HR;
      Edits := Docs.all.Item('glu', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      if FEMET.GLU='' then Edits.Value := FEMET.WAGLU;
      if FEMET.WAGLU='' then Edits.Value := FEMET.GLU;
    }
      Edits := Docs.all.Item('id', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := SimStr.Strings[0];
      Edits := Docs.all.Item('c_name', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := SimStr.Strings[1];
      Edits := Docs.all.Item('t_birthday', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      Edits.Value := SimStr.Strings[2];
      Edits := Docs.all.Item('sex', 0);  //Docs.Forms.item('form', 0).all.Item('glu', 0);
      if SimStr.Strings[3]='M' then Edits.Value := 1;
      if SimStr.Strings[3]='F' then Edits.Value := 2;
      SimStr.Clear;
    except
      ERROUT('健保卡帶入資料 ERROR');
      exit;
    end;
  end;
//---------------------------------------
  if (pos('step6.php',Web.LocationURL)>0) then
  begin
    PrintBTN.Visible:=true;
  end
  else
  begin
    PrintBTN.Visible:=false;
  end;

end;

procedure TForm1.BT_EndClick(Sender: TObject);
begin
  PreCloseServicePlugin;

  WinExec('command.com /c taskkill /F /T /IM FEMET_ServicePlugin.exe',sw_Hide);
  WinExec('taskkill /F /T /IM FEMET_ServicePlugin.exe',sw_Hide);
  //Sleep(1000);
  CLOSE;
end;

procedure TForm1.FormActivate(Sender: TObject);
var i:integer;
begin
  FEMET_ResetBAR('127.0.0.1');
  FEMET_ResetSIM('127.0.0.1');
  BT_End.Left:= Form1.ClientWidth- BT_End.ClientWidth -100;
  BT_Restart.Left:= BT_End.left- BT_End.ClientWidth -10;
  //status.Left:=BT_Restart.Left-BT_Restart.ClientWidth -10;
  //TopMost.Left:= Form1.ClientWidth- BT_End.ClientWidth -100;
  //TopMost.Brush.Style := bsClear;
  //SetWindowLong(TopMost.Handle, GWL_EXSTYLE, WS_EX_TRANSPARENT);
  for i:=0 to 30 do
  begin
     application.ProcessMessages;
     sleep(100);
  end;

  //LockTImer.Enabled:=true;
  PageTimer.Enabled:=true;
  //IDLE計時
  vLastInputInfo.cbSize := SizeOf(vLastInputInfo);
  GetLastInputInfo(vLastInputInfo);
  IdleTimeInit:=getTickCount-vLastInputInfo.dwTime;
  IdleTimer.Enabled:=true;
end;

procedure TForm1.PreCloseServicePlugin;
var i:integer;
begin
  Client.Close;
  Client.Host:='127.0.0.1';
  Client.Open;

  for i:=0 to 100 do
  begin
     sleep(100);
     if Client.Socket.Connected then break;
     application.processmessages;
  end;

  if Client.Socket.Connected then
  begin
    Client.Socket.SendText('HIDEICON');
    Client.Close;
  end;
end;

procedure TForm1.BT_RestartClick(Sender: TObject);
var
  bat:TStringList;
  i:integer;
begin
  BarTimer.Enabled:=false;
  SimTimer.Enabled:=false;
  CustomTimer.Enabled:=false;

  PreCloseServicePlugin;

  bat:=TStringList.Create;

  bat.Add('command.com /c taskkill /F /IM FEMET_ServicePlugin.exe');
  bat.Add('taskkill /F /IM FEMET_ServicePlugin.exe');
  //bat.Add('timeout /t 2');

  bat.Add('command.com /c taskkill /F /IM FEMET_ClientWeb.exe');
  bat.Add('taskkill /F /IM FEMET_ClientWeb.exe');
  bat.Add('timeout /t 2');

  bat.Add(ExtractFileDir(application.ExeName)+'\FEMET_ServicePlugin.exe');
  //bat.Add('timeout /t 1');
  bat.SaveToFile(ExtractFileDir(application.ExeName)+'\run.cmd');

  WinExec(pchar('cmd /c "'+ExtractFileDir(application.ExeName)+'\run.cmd"'),SW_Hide);
  //shellExecute(0,'open',pchar(ExtractFileDir(application.ExeName)+'\run.cmd'),nil,nil,SW_SHOWNORMAL);
{
  WinExec('command.com /c taskkill /F /T /IM FEMET_ServicePlugin.exe',sw_Hide);
  WinExec('taskkill /F /T /IM FEMET_ServicePlugin.exe',sw_Hide);
  sleep(1000);
  WinExec(pchar(ExtractFileDir(application.ExeName)+'\FEMET_ServicePlugin.exe'),0);
}
end;

procedure TForm1.IdleTimerTimer(Sender: TObject);
begin
  IdleTimer.Enabled:=false;
  vLastInputInfo.cbSize := SizeOf(vLastInputInfo);
  GetLastInputInfo(vLastInputInfo);
  //Edit1.Text:=Format('初始閒置:%d,目前已閒置:%d,Idle重啟:%d',[IdleTimeInit,((getTickCount-vLastInputInfo.dwTime-IdleTimeInit) div 1000),IdleRestart]);
  //status.Text:=Format('已閒置: %d 秒', [(getTickCount-vLastInputInfo.dwTime-IdleTimeInit) div 1000]);
  application.processmessages;
  if ((getTickCount-vLastInputInfo.dwTime-IdleTimeInit) div 1000)>IdleRestart then
  begin
    //showmessage('Restart');
    BT_Restart.Click;
  end
  else
  begin
    IdleTimer.Enabled:=true;
  end;
end;

procedure TForm1.ClientError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
   ErrorCode:=0;
end;

end.
