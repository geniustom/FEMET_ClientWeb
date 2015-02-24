object Form1: TForm1
  Left = 192
  Top = 127
  Width = 405
  Height = 229
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 21
    Top = 21
    Width = 75
    Height = 25
    Caption = 'GETBAR'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 21
    Top = 51
    Width = 75
    Height = 25
    Caption = 'GETSIM'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 21
    Top = 141
    Width = 75
    Height = 25
    Caption = 'RESETSIM'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 21
    Top = 111
    Width = 75
    Height = 25
    Caption = 'RESETBAR'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Memo1: TMemo
    Left = 114
    Top = 21
    Width = 250
    Height = 154
    Lines.Strings = (
      'Memo1')
    TabOrder = 4
  end
end
