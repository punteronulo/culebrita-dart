library culebrita_juego;

import 'dart:html';
import 'dart:math';

part 'serpiente.dart';
part 'cuadro.dart';
part 'fruta.dart';

/* Juego
 ****************************************************************************/
class Juego {
    CanvasRenderingContext2D _ctx;
    bool jugando = true;
    num _tiempo;
    
    Serpiente _serpiente;
    // dos frutas
    List<Fruta> _frutas = new List(2);
    
    // colores de las frutas
    var _colores = ["cyan", "blue", "magenta"];
    
    // números aleatorios
    var _random = new Random();
    
    /* constructor
     * 
     * Recive el contexto2D del canvas para dibujar sobre el
     * Establece los listener para las pulsaciones de las teclas y
     * crea la serpiente y las dos frutas
     ********************************************************************/
    Juego(this._ctx) {
        window.onKeyDown.listen((KeyboardEvent e){
            if(e.keyCode == KeyCode.UP) {
                _serpiente.cambiarDireccion(Serpiente.ARRIBA);
            }

            if(e.keyCode == KeyCode.DOWN) {
                _serpiente.cambiarDireccion(Serpiente.ABAJO);
            }

            if(e.keyCode == KeyCode.RIGHT) {
                _serpiente.cambiarDireccion(Serpiente.DERECHA);
            }

            if(e.keyCode == KeyCode.LEFT) {
                _serpiente.cambiarDireccion(Serpiente.IZQUIERDA);
            }
        });
        
        _serpiente = new Serpiente();

        _frutas[0] = new Fruta(_random);
        _frutas[1] = new Fruta(_random);
    }
    
    /* iniciar
     * 
     * Inicia el loop que controla el juego
     **********************************************************************/
    void iniciar() {
        _tiempo = new DateTime.now().millisecondsSinceEpoch;
        
        window.animationFrame.then(_loop);
    }
    
    /* _loop
     * 
     * loop del juego, dibuja y actualiza la serpiente, y se vuelve a
     * llamar para el siguiente ciclo solo si no terminó la partida
     * el control de los FPS es extremadamente simple, tan solo miro
     * el tiempo que pasó desde la última llamada y si no pasó un mínimo
     * de milisegundos no se actualiza ni dibuja nada
     *********************************************************************/
    void _loop(num delta) {
        var tmp = new DateTime.now();
        
        if((tmp.millisecondsSinceEpoch - _tiempo) > 170) {
            _actualizar();
            _dibujar();

            _tiempo = tmp.millisecondsSinceEpoch;
        }
        
        // si no hemos chocado volvemos a llamar al _loop
        if(jugando) window.animationFrame.then(_loop);
    }
    
    /* _dibujar
     * 
     * Borra el canvas y luego dibuja las frutas y luego la serpiente, lo
     * hago en ese orden por si sale una nueva fruta en un lugar que ocupa
     * la serpiente no se muestre el cuadro de la fruta
     ************************************************************************/
    void _dibujar(){
        // limpiar pantalla
        _ctx..clearRect(0, 0, 640, 480);
  
        // curuiosa forma de hacer el foreach, no sé, yo veo mas claro
        // el código comentado de abajo, será que no estoy acostumbrado
        _frutas.forEach((fruta) => _ctx..fillStyle = _colores[fruta.tipo]
                                       ..fillRect(fruta.px, fruta.py, 19, 19));
        
/*        for(Fruta fruta in _frutas) {
            _ctx..fillStyle = _colores[fruta.tipo]
                ..fillRect(fruta.px, fruta.py, 19, 19);
        }*/
        
        // dibujar la serpiente
        _serpiente.dibujar(_ctx);
    }
    
    /* _actualizar
     * 
     * llama al método mover de la serpiente, que se le pasa el array de 
     * las frutas para que compruebe las colisones
     * si hubo alguna colisión se termina el juego
     ************************************************************************/
    void _actualizar() {
        jugando = !_serpiente.mover(_frutas);
    }
}
