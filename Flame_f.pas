unit Flame_f;

interface

uses
  Windows, Controls, Messages, SysUtils, Graphics, Forms;

type
  TBuffer = array[1..270,1..85] of Byte;
  TFlameFrm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    InitBuffer,CurBuffer: TBuffer;
    Ticks: Cardinal;
    Frames: Byte;
    procedure Filter;
    procedure GetReady;
    procedure WMPAINT(var Msg: TWMPaint); message WM_PAINT;
  public
    { Public declarations }
  end;

var
  FlameFrm: TFlameFrm;

const
  SCaption = 'Megazoid Demo 2002';
  RPoint = 2300;  // Кол-во черных точек (чем больше число, тем меньше пламя)

implementation

{$R *.DFM}
{$R LOGO.RES}

procedure TFlameFrm.Filter; // Фильтр "вытягивающий" изображение
var
  I,J: Integer;
  Clr: Byte;
begin
  for I := 5 to 265 do
    for J := 1 to 84 do
    begin
      Clr := (CurBuffer[I-1,J] + CurBuffer[I,J] +
              CurBuffer[I+1,J] + CurBuffer[I+1,J+1]+
              CurBuffer[I,J+1] + CurBuffer[I-1,J+1]) div 6;
      if Clr < 10 then CurBuffer[I,J] := 0 else CurBuffer[I,J] := Clr;
    end;
end;

procedure TFlameFrm.FormCreate(Sender: TObject);
begin
  Randomize;
  GetReady;
  Ticks := GetTickCount;
end;

procedure TFlameFrm.GetReady;
var
  Buf,Tmp: TBitmap;
  I,J: Integer;
begin
  Buf := TBitmap.Create;
  Buf.Width := 270;
  Buf.Height := 85;
  Buf.Canvas.Brush.Color := 0; // Закрашиваем фон черным цветом
  Buf.Canvas.FloodFill(1,1,0,fsBorder);

  Tmp := TBitmap.Create; // Пишем на картинке "Megazoid"
  Tmp.LoadFromResourceName(HInstance,'LOGO');
  Buf.Canvas.Draw(10,14,Tmp);
  Tmp.Free;

  for I := 1 to 270 do // Сохраняем начальную картинку в буфер
    for J := 1 to 85 do
      InitBuffer[I,J] := Buf.Canvas.Pixels[I-1,J-1];
  Buf.Free;
end;

procedure TFlameFrm.WMPAINT(var Msg: TWMPaint);
var
  I,J: Integer;
begin
  // Бросаем на картинку черные точки, чтобы изображение не было статичным
  for I := 1 to RPoint do
    CurBuffer[2+Random(265),2+Random(84)] := 0;

  for I := 10 to 260 do   // Копируем надпись "Megazoid"
    for J := 14 to 78 do  // иначе она быстро сотрется
      if InitBuffer[I,J] <> 0 then CurBuffer[I,J] := InitBuffer[I,J];

  Filter; // Запускаем фильтр

  FlameFrm.Canvas.Lock;
  for I := 10 to 260 do  // Копируем буфер в картинку
    for J := 5 to 79 do
      if CurBuffer[I,J] <> 0 then FlameFrm.Canvas.Pixels[I,J] := CurBuffer[I,J];
  FlameFrm.Canvas.Unlock;

  Inc(Frames); // Считаем кадры по просьбам трудящихся ;)
  if GetTickCount-Ticks >= 1000 then
  begin
    Caption := SCaption + ' — FPS: ' + IntToStr(Frames);
    Frames := 0;
    Ticks := GetTickCount;
  end;
end;

end.
