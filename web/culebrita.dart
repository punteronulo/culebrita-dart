import 'dart:html';
import 'juego.dart';

void main() {
    CanvasElement canvas = querySelector("#canvas");
    canvas.focus(); // no funciona :(
    
    // crear e iniciar el juego
    Juego juego = new Juego(canvas.context2D);
    juego.iniciar();
}
