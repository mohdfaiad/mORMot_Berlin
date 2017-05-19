object MainForm: TMainForm
  Left = 0
  Top = 0
  ClientHeight = 567
  ClientWidth = 1257
  Caption = 'MainForm'
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  PixelsPerInch = 96
  TextHeight = 13
  object UniButton1: TUniButton
    Left = 80
    Top = 40
    Width = 153
    Height = 25
    Hint = ''
    Caption = 'call back'
    TabOrder = 0
    OnClick = UniButton1Click
  end
  object UniEdit1: TUniEdit
    Left = 576
    Top = 296
    Width = 121
    Hint = ''
    Text = 'UniEdit1'
    TabOrder = 1
  end
end
