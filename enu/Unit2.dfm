object Form2: TForm2
  Left = 260
  Top = 276
  AlphaBlend = True
  AlphaBlendValue = 210
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Making the data space'
  ClientHeight = 180
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
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 336
    Top = 86
    Width = 17
    Height = 12
    Caption = 'MB'
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 51
    Height = 12
    Caption = 'Drive'
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 216
    Height = 12
    Caption = 'Make the data space for Berry OS.'
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 8
    Top = 24
    Width = 353
    Height = 12
    Caption = 'Please select your drive and push "Create" button.'
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 8
    Top = 88
    Width = 57
    Height = 12
    Caption = 'Data space'
  end
  object Label6: TLabel
    Left = 168
    Top = 48
    Width = 63
    Height = 12
    Caption = 'Drive information'
  end
  object LabelInfo: TLabel
    Left = 248
    Top = 48
    Width = 4
    Height = 12
  end
  object ComboBox1: TComboBox
    Left = 88
    Top = 48
    Width = 65
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    TabOrder = 0
    OnChange = ComboBox1Change
    OnKeyPress = ComboBox1KeyPress
  end
  object Button1: TButton
    Left = 196
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Create'
    TabOrder = 3
    OnClick = Button1Click
  end
  object TrackBar1: TTrackBar
    Left = 80
    Top = 80
    Width = 150
    Height = 25
    Max = 100
    Min = 100
    Position = 100
    TabOrder = 1
    TickStyle = tsNone
    OnChange = TrackBar1Change
    OnKeyPress = TrackBar1KeyPress
  end
  object Memo1: TMemo
    Left = 248
    Top = 82
    Width = 81
    Height = 17
    Alignment = taRightJustify
    Lines.Strings = (
      '100')
    TabOrder = 2
    WordWrap = False
    OnChange = Memo1Change
    OnKeyPress = Memo1KeyPress
  end
  object ProgressBar1: TProgressBar
    Left = 20
    Top = 120
    Width = 433
    Height = 16
    TabOrder = 4
  end
  object Button2: TButton
    Left = 376
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Cansel'
    TabOrder = 5
    OnClick = Button2Click
  end
end
