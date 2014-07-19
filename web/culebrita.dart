import 'dart:html';
import 'dart:math';

void main() {
    CanvasElement canvas = querySelector("#canvas");
    canvas.focus(); // no funciona :(
    
    // crear e iniciar el juego
    Juego juego = new Juego(canvas.context2D);
    juego.iniciar();
}

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
    void _loop(delta) {
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
        
        for(Fruta fruta in _frutas) {
            _ctx..fillStyle = _colores[fruta.tipo]
                ..fillRect(fruta.px, fruta.py, 19, 19);
        }
        
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

/* Serpiente
 * 
 * Clase para manejar la serpiente, que no es más que una lista de
 * la clase Cuadro. La cabeza no es más que el primer elemento de
 * la lista.
 **********************************************************************/
class Serpiente {
    // direcciones de movimiento
    static const num DERECHA = 0;
    static const num IZQUIERDA = 1;
    static const num ARRIBA = 2;
    static const num ABAJO = 3;
    
    num _direccion, _crecer;
    
    List<Cuadro> _cuadros;
    
    Serpiente() {
        _cuadros = new List();
        
        // empieza con tres cuadros moviéndose hacia la derecha
        _cuadros..add(new Cuadro(6, 14))
                ..insert(0, new Cuadro(7, 14))
                ..insert(0, new Cuadro(8, 14));

        _direccion = DERECHA;
        _crecer = 0;
    }
    
    /* dibujar
     * 
     * Dibuja la serpiente en el canvas que recibe. La cabeza
     * se pinta de diferente color, que no es más que el primer 
     * elemento de la lista.
     * Cada cuadro es de 20x20, pero los pinto de 19x19 para
     * dejar un px de separación, queda mejor, creo XD
     **************************************************************/
    void dibujar(ctx) {
        // cascade en acción :)
        ctx..fillStyle = "red"
           ..fillRect(_cuadros[0].px, _cuadros[0].py, 19, 19)
           ..fillStyle = "green";
        
        for(var i = 1; i < _cuadros.length; i++)
            ctx.fillRect(_cuadros[i].px, _cuadros[i].py, 19, 19);
    }
    
    /* mover
     * 
     * Para moverla simplemente se añade un nuevo bloque y se borra el
     * último, lo que da sensación de movimiento. Si hay que crecer, no
     * se borra el último al avanzar
     * 
     * Retorna TRUE si hubo alguna colisión
     *******************************************************************/
    bool mover(frutas) {
        var nx = _cuadros[0]._x;
        var ny = _cuadros[0]._y;
        
        switch(_direccion) {
            case DERECHA:
                nx++;
                break;
            case IZQUIERDA:
                nx--;
                break;
            case ARRIBA:
                ny--;
                break;
            default: // ABAJO
                ny++;
                break;
        }
        
        var colision = false;
        
        // comprobar si se come alguna fruta
        // solo la cabeza puede comer una fruta
        for(Fruta fruta in frutas)
            if(fruta._x == nx && fruta._y == ny) {
                _crecer += (fruta.tipo + 1) * 2;
                fruta.reiniciar();
            }
        
        // comprobar si se sale de la pantalla
        if(nx < 0 || nx >= 32) colision = true;
        if(ny < 0 || ny >= 24) colision = true;
        
        // colisión con sigo misma, se mira a partir de la coordenada 3, ya que
        // es imposible que la cabeza choque con la 1 y la 2
        for(var i = 3; i < _cuadros.length; i++) {
            if(_cuadros[i]._x == nx && _cuadros[i]._y == ny)
                colision = true;
        }

        if(!colision) {
            _cuadros.insert(0, new Cuadro(nx, ny));
            if(_crecer == 0) _cuadros.removeLast();
            else _crecer--;
        }
        
        return colision;
    }
    
    /*cambiarDireccion
     * 
     * Intenta cambiar la dirección de movimiento. Si va hacia
     * ARRIBA no puede cambiar hacia ABAJO y viceversa, igual con
     * IZQUIERDA y DERECHA
     ***************************************************************/
    void cambiarDireccion(nuevaDir) {
        switch(nuevaDir) {
            case ARRIBA:
            case ABAJO:
                if(_direccion == DERECHA || _direccion == IZQUIERDA) {
                    _direccion = nuevaDir;
                }
                break;
            default: // IZQUIERDA Y DERECHA
                if(_direccion == ARRIBA || _direccion == ABAJO) {
                    _direccion = nuevaDir;
                }
        }
    }
}

/* Cuadro
 * 
 * Clase que representa cada uno de los tramos de la serpiente. Son
 * simplemente las coordenadas que ocupan.
 * 
 * La pantalla la divido en un tablero de bloques de 20x20 px
 * Mediante el getter devuelvo la coordenada ya traducida a ese tablero
 ***********************************************************************/
class Cuadro {
    num _x;
    num _y;
    
    Cuadro(this._x, this._y);
    
    num get px => _x * 20;
    num get py => _y * 20;

    set setX(num nx) => _x = nx;
    set setY(num ny) => _y = ny;
    
}

/* Fruta
 * 
 * No es más que un cuadro con un tipo, que se usa para calcular
 * el número de cuadros a crecr cuando se come, además indica
 * el color que tendrá la fruta
 ******************************************************************/
class Fruta extends Cuadro {
    num _tipo;
    var _random;
    
    Fruta(random): super(random.nextInt(32), random.nextInt(24)) {
        _random = random;
        _tipo = random.nextInt(3); // 3 tipos de frutas
    }
    
    num get tipo => _tipo;
    
    void reiniciar() {
        setX = _random.nextInt(32);
        setY = _random.nextInt(24);
        _tipo = _random.nextInt(3); // 3 tipos de frutas
    }
}
