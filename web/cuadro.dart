part of culebrita_juego;

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
    
    // getters, retorna la posición multiplicada por el tamaño de la casilla
    // para dibujarlos en pantalla
    num get px => _x * 20;
    num get py => _y * 20;

    // setters
    set setX(num nx) => _x = nx;
    set setY(num ny) => _y = ny;
    
}