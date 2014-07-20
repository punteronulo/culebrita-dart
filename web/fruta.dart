part of culebrita_juego;

/* Fruta
 * 
 * No es más que un cuadro con un tipo, que se usa para calcular
 * el número de cuadros a crecr cuando se come, además indica
 * el color que tendrá la fruta
 ******************************************************************/
class Fruta extends Cuadro {
    num _tipo;
    var _random;
    
    Fruta(var random): super(random.nextInt(32), random.nextInt(24)) {
        _random = random;
        _tipo = random.nextInt(3); // 3 tipos de frutas
    }
    
    // el tipo se usa para el color y el número de casillas que crece la serpiente
    num get tipo => _tipo;
    
    /* reiniciar
     * 
     * Reinicia la fruta en unas nuevas coordenadas al azar y un nuevo tipo
     *********************************************************************************/
    void reiniciar() {
        setX = _random.nextInt(32);
        setY = _random.nextInt(24);
        _tipo = _random.nextInt(3); // 3 tipos de frutas
    }
}
