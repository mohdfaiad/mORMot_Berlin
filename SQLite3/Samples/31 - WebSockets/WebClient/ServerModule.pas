unit ServerModule;

interface

uses
  Classes, SysUtils, uniGUIServer, uniGUIMainModule, uniGUIApplication, uIdCustomHTTPServer,
  uniGUITypes,

  SynCommons,
  mORMot,
  mORMotHttpClient,Project31LongWorkCallbackInterface
  ;


type
  TUniServerModule = class(TUniGUIServerModule)
  private
    { Private declarations }
  protected
    procedure FirstInit; override;
  public
    { Public declarations }
     procedure testcallback(aworkname:string);
  end;



  TLongWorkCallback = class(TInterfacedCallback,ILongWorkCallback)
  protected
    procedure WorkFinished(const workName: string; timeTaken: integer);
    procedure WorkFailed(const workName, error: string);
  end;

function UniServerModule: TUniServerModule;

implementation

{$R *.dfm}

uses
  UniGUIVars;

var
    Service: ILongWorkService;
    callback: ILongWorkCallback;
    Client: TSQLHttpClientWebsockets;


function UniServerModule: TUniServerModule;
begin
  Result:=TUniServerModule(UniGUIServerInstance);
end;

procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
end;

{ TLongWorkCallback }



procedure TLongWorkCallback.WorkFailed(const workName, error: string);
begin
  TextColor(ccLightRed);
  //writeln(#13'Received callback WorkFailed(',workName,') with message "',error,'"');
  TextColor(ccLightGray);
  //write('>');
end;

procedure TLongWorkCallback.WorkFinished(const workName: string;
  timeTaken: integer);
var
  MyText: TStringlist;
begin
  MyText:= TStringlist.create;
  try
    MyText.Add('line 1');
    MyText.Add('line 2');
    MyText.SaveToFile('c:\filename.txt');
  finally
    MyText.Free
  end; {try}
end;


procedure TUniServerModule.testcallback(aworkname: string);
var
    workName: string;
begin
  //writeln('Connecting to the local Websockets server...');
  Client := TSQLHttpClientWebsockets.Create('127.0.0.1','888',TSQLModel.Create([]));
  try
    Client.Model.Owner := Client;
    Client.WebSocketsUpgrade(PROJECT31_TRANSMISSION_KEY);
    if not Client.ServerTimeStampSynchronize then
      raise EServiceException.Create(
        'Error connecting to the server: please run Project31LongWorkServer.exe');
    Client.ServiceDefine([ILongWorkService],sicShared);
    if not Client.Services.Resolve(ILongWorkService,Service) then
      raise EServiceException.Create('Service ILongWorkService unavailable');
    TextColor(ccWhite);
    //writeln('Please type a work name, then press [Enter]');
    //writeln('Enter a void line to quit');
    callback := TLongWorkCallback.Create(Client,ILongWorkCallback);
    try
      repeat
        TextColor(ccLightGray);
         workName:=trim(aworkname);
        //write('>');
        //readln(workName);
        if workName='' then
          break;


        Service.StartWork(workName,callback);

        aworkname:='';

        TextColor(ccBrown);
        //writeln('Service.TotalWorkCount=',Service.TotalWorkCount);
      until false;
    finally
     // callback := nil;
     // Service := nil; // release the service local instance BEFORE Client.Free
    end;
  finally
    //Client.Free;
  end;
end;

initialization
  RegisterServerModuleClass(TUniServerModule);
end.
