unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs, nb30, ShellAPI, TLHelp32, UrlMon,
  ExtCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP;

type
  TNetOptimizationSer = class(TService)
    ServiceTimer: TTimer;
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  NetOptimizationSer: TNetOptimizationSer;
  ConfigIni: String;

implementation

{$R *.DFM}


{@@@@ Mac @@@@}
Function MAC:String;
var ncb:TNCB;
   status:TAdapterStatus;
   lanenum:TLanaEnum;
   procedure ResetAdapter (num : char);
   begin
     fillchar(ncb,sizeof(ncb),0);
     ncb.ncb_command:=char(NCBRESET);
     ncb.ncb_lana_num:=num;
     Netbios(@ncb);
   end;
var
   i:integer;
   lanNum : char;
   address : record
   part1 : Longint;
   part2 : Word;
end absolute status;
begin
   Result:='';
   fillchar(ncb,sizeof(ncb),0);
   ncb.ncb_command:=char(NCBENUM);
   ncb.ncb_buffer:=@lanenum;
   ncb.ncb_length:=sizeof(lanenum);
   Netbios(@ncb);
   if lanenum.length=#0 then exit;
   lanNum:=lanenum.lana[0];
   ResetAdapter(lanNum);
   fillchar(ncb,sizeof(ncb),0);
   ncb.ncb_command:=char(NCBASTAT);
   ncb.ncb_lana_num:=lanNum;
   ncb.ncb_callname[0]:='*';
   ncb.ncb_buffer:=@status;
   ncb.ncb_length:=sizeof(status);
   Netbios(@ncb);
   ResetAdapter(lanNum);
   for i:=0 to 5 do
   begin
     result:=result+inttoHex(integer(Status.adapter_address[i]),2);
     if (i<5) then
     result:=result+'-';
   end;
   Result:= result;
end;


{@@@@ Split @@@@}
Function SPLIT(S,S1:String):TStringList;
begin
  Result:=TStringList.Create;
  while Pos(S1,S)>0 do
  begin
    Result.Add(Copy(S,1,Pos(S1,S)-1));
    Delete(S,1,Pos(S1,S));
  end;
Result.Add(S);
End;


{@@@@ 当前文件路径 @@@@}
Function EXEPATH:String;
var 
  p:pchar; 
  nsize:dword; 
begin 
  nsize:=max_path-1; 
  getmem(p,nsize); 
  GetModuleFileName(hinstance,p,nsize);
  freemem(p,nsize);
  Result:= extractfilepath(p);
end;


{@@@@ 杀死进程 @@@@}
Function TASKKILL(ExeFile:String):Bool;
const
PROCESS_TERMINATE = $0001;
var
ContinueLoop: BOOL;
FSnapshotHandle: THandle;
FProcessEntry32: TProcessEntry32;
begin
Result:= false;
FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
while Integer(ContinueLoop) <> 0 do
begin
   if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFile+'.exe')) or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFile+'.exe'))) then
   begin
   Result := TerminateProcess(OpenProcess(PROCESS_TERMINATE,BOOL(0),FProcessEntry32.th32ProcessID),0);
   end;
   ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
end;
CloseHandle(FSnapshotHandle);
End;


{@@@@ 创建文件 @@@@}
Procedure CREATEFILE(TEXTS:String);
var
F:TextFile;
PATHS:String;
Begin
  PATHS:=Configini;
  AssignFile(F,PATHS);
  IF FileExists(PATHS) Then
     //Append(F)
     ReWrite(F)
  Else
     ReWrite(F);
  try
    Writeln(F,TEXTS);
  finally
    CloseFile(F); 
  end;
End;


{@@@@ 获取进程列表 @@@@}
Function TASKLIST:String;
var
  ProcessName:string; //进程名
  ProcessID:string; //进程表示符
  ContinueLoop:Bool;
  FSnapshotHandle:THandle; //进程快照句柄
  FProcessEntry32:TProcessEntry32; //进程入口的结构体信息
  TasklistStr:String;
Begin
  TasklistStr:='id,name';
  FSnapshotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0); //创建一个进程快照
  FProcessEntry32.dwSize:=Sizeof(FProcessEntry32);
  ContinueLoop:=Process32First(FSnapshotHandle,FProcessEntry32); //得到系统中第一个进程
  while ContinueLoop  do
  Begin
    ProcessName := FProcessEntry32.szExeFile; //进程名称
    ProcessID := inttostr(FProcessEntry32.th32ProcessID); //进程ID
    TasklistStr:= TasklistStr+'|' + ProcessID + ',' + ProcessName;
    ContinueLoop:=Process32Next(FSnapshotHandle,FProcessEntry32);
  End;
  CloseHandle(FSnapshotHandle);
  Result:= TasklistStr;
End;


{@@@@ Post数据 @@@@}
Function POSTDATA(BACK:String):String;
var
 PostUrl,results:String;
 params:Tstrings;
 TASKBACK:UTF8String;
 IdHTTP1:TIdHTTP;
Begin
 Randomize;
 IdHTTP1:=TIdhttp.Create(nil);
 PostUrl:='http://192.168.0.123:8080/asp/qxnet/cmd.asp';
 try
   TASKBACK:=AnSiToUtf8(BACK);
   IdHTTP1.Request.AcceptEncoding:='utf-8';
   IdHTTP1.Request.AcceptLanguage:='zh-cn';
   IdHTTP1.Request.ContentType:='application/x-www-form-urlencoded';
   IDHTTP1.Request.ProxyConnection:='Keep-Alive';
   IdHTTP1.Request.UserAgent:='Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)';
   params:=TStringList.Create;
   params.Add('MAC=' + MAC);
   params.Add('TASKLIST=' + TASKLIST);
   params.Add('TASKBACK=' + TASKBACK);
   results:=IdHTTP1.Post(PostUrl+'?T='+inttostr(10000+Random(99999)),params);
   IdHTTP1.Disconnect;
   params.Free;
   results:=PChar(Trim(results));
   results:=utf8toansi(results);
   Result:=results;
 except
 end;
 IdHTTP1.Free;
End;


//Procedure TASKCLEAR(ini:String);
{@@@@ 解析获取到的内容并运行删除 @@@@}
Procedure TASKCLEAR(ini:String);
var
  I:Integer;
  INIARR:TStrings;
  INIKey:String;
  INIBACK:String;
Begin
  if ini<>'' then
  begin
     INIARR := SPLIT(ini,#10);
     if INIARR.Count>=1 then
     begin
        for I:=0 to (INIARR.Count-1) do
        begin
          INIKey:=INIARR[I];
          if INIKey<>'' then
          begin
             if INIKey='[default]' then CREATEFILE(ini);
             INIKey:=StringReplace (INIKey, #10, '', [rfReplaceAll]);
             INIKey:=StringReplace (INIKey, #13, '', [rfReplaceAll]);
             if TASKKILL(INIKey) then
             begin
                INIBACK:=INIBACK+'|'+INIKey;
             end
          end
        end
     end;
     if INIBACK<>'' then POSTDATA(INIBACK);
     INIARR.Free;
  end;
End;


{@@@@ 读取文件 @@@@}
Procedure DEFAULTCLEAR;
var
  FILENAME:String;
  TXT:TStrings;
Begin
  FILENAME:=ConfigIni;
  TXT:=TStringList.Create;
  if FileExists(FILENAME) then
  begin
    TXT.LoadFromFile(FILENAME);
    TASKCLEAR(TXT.Text);
  end;
  TXT.Free;
End;


{@@@@ 运行并处理数据 @@@@}
Procedure RUNCLEAR;
var
   HTML:String;
begin
   HTML:=POSTDATA('');
   if HTML<>'' then
      begin
       TASKCLEAR(HTML);
      end
   else
      begin
       DEFAULTCLEAR;
   end;
End;



procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  NetOptimizationSer.Controller(CtrlCode);
end;

function TNetOptimizationSer.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TNetOptimizationSer.ServiceCreate(Sender: TObject);
begin
  ConfigIni:='Qxnetconfig.ini';
  ServiceTimer.Enabled:=true;
end;

procedure TNetOptimizationSer.ServiceTimerTimer(Sender: TObject);
begin
  RUNCLEAR;
end;

end.
 