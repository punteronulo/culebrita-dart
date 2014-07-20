part of culebrita_juego;

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
    
    // indice del bloque de ella misma con el que chocó
    // la cabeza, o -1 si no hay choque
    num _choque;
    
    // lista de casillas que componeen la serpiente, la cabeza es solo el
    // elemento 0 de la lista
    List<Cuadro> _cuadros;
    
    Serpiente() {
        _cuadros = new List();
        
        // empieza con tres cuadros moviéndose hacia la derecha
        _cuadros..add(new Cuadro(6, 14))
                ..insert(0, new Cuadro(7, 14))
                ..insert(0, new Cuadro(8, 14));

        _direccion = DERECHA;
        _crecer = 0;
        _choque = -1;
    }
    
    /* dibujar
     * 
     * Dibuja la serpiente en el canvas que recibe. La cabeza
     * se pinta de diferente color, que no es más que el primer 
     * elemento de la lista.
     * Cada cuadro es de 20x20, pero los pinto de 19x19 para
     * dejar un px de separación, queda mejor, creo XD
     **************************************************************/
    void dibujar(CanvasRenderingContext2D ctx) {
        // cascade en acción :)
        ctx..fillStyle = "red"
           ..fillRect(_cuadros[0].px, _cuadros[0].py, 19, 19)
           ..fillStyle = "green";
        
        for(var i = 1; i < _cuadros.length; i++)
            ctx.fillRect(_cuadros[i].px, _cuadros[i].py, 19, 19);
        
        // si choca con sigo misma, ese bloque se marca de otro color
        if(_choque != -1)
            ctx..fillStyle = "brown"
               ..fillRect(_cuadros[_choque].px, _cuadros[_choque].py, 19, 19);
    }
    
    /* mover
     * 
     * Para moverla simplemente se añade un nuevo bloque y se borra el
     * último, lo que da sensación de movimiento. Si hay que crecer, no
     * se borra el último al avanzar
     * 
     * Retorna TRUE si hubo alguna colisión
     *******************************************************************/
    bool mover(List<Fruta> frutas) {
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
            if(_cuadros[i]._x == nx && _cuadros[i]._y == ny) {
                colision = true;
                _choque = i;
                break;
            }
        }

        // si la nueva casilla está en una posición válida se crea y si hay que crecer
        // no se borra la última de la lista
        if(!colision) {
            querySelector("#cuadros").text = "Longitud " + _cuadros.length.toString();
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
    void cambiarDireccion(num nuevaDir) {
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