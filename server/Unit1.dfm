object NetOptimizationSer: TNetOptimizationSer
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'NetOptimizationSer'
  Left = 802
  Top = 229
  Height = 101
  Width = 119
  object ServiceTimer: TTimer
    Interval = 10000
    OnTimer = ServiceTimerTimer
    Left = 40
    Top = 16
  end
end
