program NetOptimization;

uses
  SvcMgr,
  Unit1 in 'Unit1.pas' {NetOptimizationSer: TService};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TNetOptimizationSer, NetOptimizationSer);
  Application.Run;
end.
