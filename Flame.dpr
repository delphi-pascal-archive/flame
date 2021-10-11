program Flame;

uses
  Forms,
  Flame_f in 'Flame_f.pas' {FlameFrm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Megazoid Demo 2002';
  Application.CreateForm(TFlameFrm, FlameFrm);
  Application.Run;
end.
