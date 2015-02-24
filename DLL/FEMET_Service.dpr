library FEMET_Service;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScktComp, StdCtrls;

{$R *.res}

type
  TFEMET=class(TComponent)
  private
    { Private declarations }
  public
    ClientSocket: TClientSocket;
    ResultStr:string;
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject;Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;var ErrorCode: Integer);

    procedure InitSocket(IP:string);
    procedure Wait(Delay:integer);
  end;

procedure TFEMET.ClientSocketError(Sender: TObject;Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;var ErrorCode: Integer);
begin
   ErrorCode:=0;
end;


procedure TFEMET.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
begin
   ResultStr:=Socket.ReceiveText;
end;

procedure TFEMET.Wait(Delay:integer);
var DelayOrg:integer;
begin
  DelayOrg:=windows.GetTickCount;
  while windows.GetTickCount-DelayOrg<=Delay do
  begin
     application.ProcessMessages;
     sleep(10);
  end;

end;

procedure TFEMET.InitSocket(IP:string);
begin
  ClientSocket:=TClientSocket.Create(nil);
  ClientSocket.OnRead:=ClientSocketRead;
  ClientSocket.OnError:=ClientSocketError;
  ClientSocket.Host:=IP;
  ClientSocket.Port:=66666;
  ClientSocket.Open;
  Wait(100);
end;   

function FEMET_ResetBAR(IP:string):boolean;stdcall;far;
  var Client:TFEMET;
begin
  result:=false;
  try
    Client:=TFEMET.Create(nil);
    Client.InitSocket(IP);
    Client.ClientSocket.Socket.SendText('RESETBAR');
    Client.Wait(100);
    Client.ClientSocket.Close;
    if Client.ResultStr='OK' then
      result:=true;
  except
    result:=false;
  end;
end;

function FEMET_ResetSIM(IP:string):boolean;stdcall;far;
  var Client:TFEMET;
begin
  result:=false;
  try
    Client:=TFEMET.Create(nil);
    Client.InitSocket(IP);
    Client.ClientSocket.Socket.SendText('RESETSIM');
    Client.Wait(100);
    Client.ClientSocket.Close;
    if Client.ResultStr='OK' then
      result:=true;
  except
    result:=false;
  end;
end;

function FEMET_GetSIMState(IP:string):pchar;stdcall;far;
  var Client:TFEMET;
begin
  result:='ERR';
  try
    Client:=TFEMET.Create(nil);
    Client.InitSocket(IP);
    Client.ClientSocket.Socket.SendText('GETSIM');
    Client.Wait(100);
    Client.ClientSocket.Close;
    if Client.ResultStr<>'' then result:=pchar(Client.ResultStr);
  except
    exit;
  end;
end;

function FEMET_GetBARState(IP:string):pchar;stdcall;far;
  var Client:TFEMET;
begin
  result:='ERR';
  try
    Client:=TFEMET.Create(nil);
    Client.InitSocket(IP);
    Client.ClientSocket.Socket.SendText('GETBAR');
    Client.Wait(100);
    Client.ClientSocket.Close;
    if Client.ResultStr<>'' then result:=pchar(Client.ResultStr);
  except
    exit;
  end;
end;


exports
  FEMET_ResetBAR,
  FEMET_ResetSIM,
  FEMET_GetSIMState,
  FEMET_GetBARState;
  
begin

end.


