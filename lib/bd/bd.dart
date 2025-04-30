class CategoriaGasto {
  final String id;
  final String nombre;

  CategoriaGasto({required this.id, required this.nombre});
}

class BaseDeDatosSimulada {
  static final List<CategoriaGasto> categorias = [
    CategoriaGasto(id: '1', nombre: 'Comida'),
    CategoriaGasto(id: '2', nombre: 'Transporte'),
    CategoriaGasto(id: '3', nombre: 'Ocio'),
    CategoriaGasto(id: '4', nombre: 'Servicios'),
  ];

  static List<CategoriaGasto> obtenerCategorias() {
    return categorias;
  }
}