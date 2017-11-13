object Form2: TForm2
  Left = 260
  Top = 276
  AlphaBlend = True
  AlphaBlendValue = 210
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsSingle
  Caption = #12487#12540#12479#38936#22495#20316#25104
  ClientHeight = 180
  ClientWidth = 474
  Color = clCream
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
    Caption = #12489#12521#12452#12502#21517
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 216
    Height = 12
    Caption = 'Berry OS '#12398#12487#12540#12479#38936#22495#12434#20316#25104#12375#12414#12377#12290
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
    Caption = #23550#35937#12489#12521#12452#12502#21517#12392#12469#12452#12474#12434#25351#23450#12375#12390#12289#20316#25104#12508#12479#12531#12434#25276#12375#12390#12367#12384#12373#12356#12290
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
    Caption = #12487#12540#12479#38936#22495
  end
  object Label6: TLabel
    Left = 168
    Top = 48
    Width = 63
    Height = 12
    Caption = #12489#12521#12452#12502#24773#22577
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
    Caption = #20316#25104
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
    Orientation = trHorizontal
    Frequency = 1
    Position = 100
    SelEnd = 0
    SelStart = 0
    TabOrder = 1
    TickMarks = tmBottomRight
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
    Min = 0
    Max = 100
    TabOrder = 4
  end
  object Button2: TButton
    Left = 376
    Top = 144
    Width = 75
    Height = 25
    Caption = #12461#12515#12531#12475#12523
    TabOrder = 5
    OnClick = Button2Click
  end
end
