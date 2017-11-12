object Form1: TForm1
  Left = 352
  Top = 264
  AlphaBlend = True
  AlphaBlendValue = 210
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Berry OS Installer'
  ClientHeight = 330
  ClientWidth = 474
  Color = clInfoBk
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 85
    Top = 19
    Width = 85
    Height = 12
    Caption = 'Install to:'
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 28
    Top = 48
    Width = 417
    Height = 25
    Caption = 'Berry OS Install'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 28
    Top = 88
    Width = 417
    Height = 25
    Caption = 'Add grub to NTLDR'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button7: TButton
    Left = 199
    Top = 288
    Width = 75
    Height = 25
    Caption = 'Finish'
    TabOrder = 6
    OnClick = Button7Click
  end
  object Button4: TButton
    Left = 28
    Top = 168
    Width = 417
    Height = 25
    Caption = 'Make the data space'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button3: TButton
    Left = 28
    Top = 128
    Width = 417
    Height = 25
    Caption = 'Remove grub from NTLDR'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button6: TButton
    Left = 28
    Top = 248
    Width = 417
    Height = 25
    Caption = 'Install Berry OS to USB-Key'
    TabOrder = 5
    OnClick = Button6Click
  end
  object ComboBox1: TComboBox
    Left = 184
    Top = 16
    Width = 153
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    TabOrder = 8
    OnChange = ComboBox1Change
  end
  object Button8: TButton
    Left = 352
    Top = 16
    Width = 91
    Height = 25
    Caption = 'Search drive'
    TabOrder = 7
    OnClick = Button8Click
  end
  object Button5: TButton
    Left = 28
    Top = 208
    Width = 417
    Height = 25
    Caption = 'Make swap area'
    TabOrder = 4
    OnClick = Button5Click
  end
end
