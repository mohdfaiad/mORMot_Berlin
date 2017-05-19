unit Main;

interface

  {$I SynDprUses.inc} // use FastMM4 on older versions of Delphi

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniButton,

  SynCommons,
  mORMot,
  mORMotHttpClient,
  Project31LongWorkCallbackInterface, uniEdit
  ;

type
  TMainForm = class(TUniForm)
    UniButton1: TUniButton;
    UniEdit1: TUniEdit;
    procedure UniButton1Click(Sender: TObject);
  private
    { Private declarations }
         procedure fcallback(aworkname:string);

  public
    { Public declarations }
  end;


type
  TLongWorkCallback = class(TInterfacedCallback,ILongWorkCallback)
  protected
    procedure WorkFinished(const workName: string; timeTaken: integer);
    procedure WorkFailed(const workName, error: string);
  end;



function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, ServerModule;

var
    Service: ILongWorkService;
    callback: ILongWorkCallback;
    Client: TSQLHttpClientWebsockets;


procedure TLongWorkCallback.WorkFailed(const workName, error: string);
begin
  TextColor(ccLightRed);
  //writeln(#13'Received callback WorkFailed(',workName,') with message "',error,'"');
  TextColor(ccLightGray);
  //write('>');

  ShowMessage('Failed');



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
    MyText.SaveToFile('c:\filename1.txt');
  finally
    MyText.Free
  end; {try}
end;




function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.fcallback(aworkname: string);
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


procedure TMainForm.UniButton1Click(Sender: TObject);
begin
  fcallback(UniEdit1.Text);
 // UniServerModule.testcallback(UniEdit1.Text);
//  uniser.testcallcabck(UniEdit1.Text);
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
