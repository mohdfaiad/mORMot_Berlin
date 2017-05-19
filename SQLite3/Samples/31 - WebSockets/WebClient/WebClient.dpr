program WebClient;

uses
  {$I SynDprUses.inc} // use FastMM4 on older versions of Delphi
  SysUtils,
  Classes,


  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  Main in 'Main.pas' {MainForm: TUniForm},
  Project31LongWorkCallbackInterface in '..\Project31LongWorkCallbackInterface.pas';






{$R *.res}


begin
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
