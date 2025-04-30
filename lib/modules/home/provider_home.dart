import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/services/gasto_service.dart';
import 'package:gestor_de_gastos_jc/config/services/presupuesto_service.dart';
import 'package:gestor_de_gastos_jc/core/models/gasto_model.dart';
import 'package:gestor_de_gastos_jc/core/models/presupuesto_model.dart';
import 'package:hive/hive.dart';

class ProviderHome with ChangeNotifier {
  //metood init
  Future<void> init() async {
    await _gastoService.initHive(); // Inicializar Hive
    await _presupuestoService.initHive(); // Inicializar Hive
    cargarDatosPresupuesto(); // Obtener presupuesto al iniciar
    await cargarGastos(); // Cargar gastos al iniciar
  }

  //  properties
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _cantidadController = TextEditingController();
  String? _categoriaSeleccionada;
  DateTime? _fechaSeleccionada;
  double _presupuestoGeneral = 0.0; // Presupuesto general
  double _saldoRestante = 0.0; // Saldo restante
  //ahorro
  double _ahorro = 0.0; // Ahorro

  List<GastoModel> gastos = [];

  List<GastoModel> _gastos = [];
  //__________________________________________________________________
  final GastoService _gastoService = GastoService();
  final PresupuestoService _presupuestoService = PresupuestoService();
  //__________________________________________________________________
  //getts
  //ahorro
  double get ahorro => _ahorro;
  String get descripcion => _descripcionController.text;
  String get cantidad => _cantidadController.text;
  String get categoriaSeleccionada => _categoriaSeleccionada ?? 'Sin categoría';
  DateTime? get fechaSeleccionada => _fechaSeleccionada;
  double get presupuestoGeneral => _presupuestoGeneral;
  double get saldoRestante => _saldoRestante;
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get descripcionController => _descripcionController;
  TextEditingController get cantidadController => _cantidadController;
  //__________________________________________________________________
  //setsters
  //ahorro
  set ahorro(double value) {
    _ahorro = value;
    notifyListeners();
  }

  set descripcion(String value) {
    _descripcionController.text = value;
    notifyListeners();
  }

  set cantidad(String value) {
    _cantidadController.text = value;
    notifyListeners();
  }

  set presupuestoGeneral(double value) {
    _presupuestoGeneral = value;
    notifyListeners();
  }

  set saldoRestante(double value) {
    _saldoRestante = value;
    notifyListeners();
  }

  set categoriaSeleccionada(String value) {
    _categoriaSeleccionada = value;
    notifyListeners();
  }

  set fechaSeleccionada(DateTime? value) {
    _fechaSeleccionada = value;
    notifyListeners();
  }

//__________________________________________________________________

  Future<void> guardarGasto(BuildContext context) async {
    await _gastoService.initHive();
    if (_formKey.currentState!.validate() && _fechaSeleccionada != null) {
      final nuevoGasto = GastoModel(
        descripcion: _descripcionController.text,
        cantidad: double.parse(_cantidadController.text),
        categoria: _categoriaSeleccionada!,
        fecha: _fechaSeleccionada!,
      );

      await _gastoService.saveGasto(nuevoGasto);

      // Asegurarse de que la caja esté abierta
      if (!Hive.isBoxOpen('presupuestoBox')) {
        await Hive.openBox<PresupuestoModel>('presupuestoBox');
      }

      // Actualizar el saldo restante en Hive
      final box = Hive.box<PresupuestoModel>('presupuestoBox');
      final presupuestoActual = box.get('presupuesto');
      if (presupuestoActual != null) {
        final nuevoSaldoRestante =
            presupuestoActual.saldoRestante - nuevoGasto.cantidad;
        final presupuestoActualizado = PresupuestoModel(
          presupuestoGeneral: presupuestoActual.presupuestoGeneral,
          saldoRestante: nuevoSaldoRestante,
          ahorro: presupuestoActual.ahorro,
        );
        await box.put('presupuesto', presupuestoActualizado);

        _saldoRestante = nuevoSaldoRestante;
        notifyListeners();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Gasto registrado exitosamente')),
      );

      clear();
      cargarGastos();
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ Por favor, completa todos los campos')),
      );
    }
  }

  Future<void> cargarGastos() async {
    await _gastoService.initHive(); // Asegurarse de que Hive esté inicializado
    gastos = _gastoService.getAllGastos();
    notifyListeners();
  }

  Future<void> eliminarGasto(BuildContext context, int index) async {
    final gasto = gastos[index]; // Use the correct list 'gastos'
    await _gastoService.deleteGasto(gasto.key!); // Eliminar por clave
    gastos.removeAt(index); // Remove from the correct list 'gastos'

    // Asegurarse de que la caja esté abierta
    if (!Hive.isBoxOpen('presupuestoBox')) {
      await Hive.openBox<PresupuestoModel>('presupuestoBox');
    }

    // Actualizar el saldo restante en Hive
    final box = Hive.box<PresupuestoModel>('presupuestoBox');
    final presupuestoActual = box.get('presupuesto');
    if (presupuestoActual != null) {
      final nuevoSaldoRestante = presupuestoActual.saldoRestante + gasto.cantidad;
      final presupuestoActualizado = PresupuestoModel(
        presupuestoGeneral: presupuestoActual.presupuestoGeneral,
        saldoRestante: nuevoSaldoRestante,
        ahorro: presupuestoActual.ahorro,
      );
      await box.put('presupuesto', presupuestoActualizado);

      _saldoRestante = nuevoSaldoRestante;
      notifyListeners();
    }
    cargarGastos(); // Recargar la lista de gastos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑 Gasto eliminado exitosamente')),
    );
  }

  //cargar datos del presupuesto
  Future<void> cargarDatosPresupuesto() async {
    final presupuesto = await obtenerPresupuesto();
    if (presupuesto != null) {
      _presupuestoGeneral = presupuesto.presupuestoGeneral;
      _saldoRestante = presupuesto.saldoRestante;
    } else {
      _presupuestoGeneral = 0.0;
      _saldoRestante = 0.0;
    }
    notifyListeners();
  }

  Future<void> EstablecerPresupuesto(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        final presupuestoController = TextEditingController();
        return AlertDialog(
          title: const Text('Establecer Presupuesto General'),
          content: TextField(
            controller: presupuestoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Presupuesto'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final presupuesto = double.tryParse(presupuestoController.text);
                if (presupuesto != null) {
                  // Asegurarse de que la caja esté abierta
                  if (!Hive.isBoxOpen('presupuestoBox')) {
                    await Hive.openBox<PresupuestoModel>('presupuestoBox');
                  }

                  final box = Hive.box<PresupuestoModel>('presupuestoBox');
                  final presupuestoActual = box.get('presupuesto');

                  // Actualizar el presupuesto y el saldo restante
                  final nuevoPresupuesto = PresupuestoModel(
                    presupuestoGeneral: presupuesto,
                    saldoRestante: presupuesto,
                    ahorro: presupuestoActual?.ahorro ?? 0.0,
                  );
                  await box.put('presupuesto', nuevoPresupuesto);

                  _presupuestoGeneral = nuevoPresupuesto.presupuestoGeneral;
                  _saldoRestante = nuevoPresupuesto.saldoRestante;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('✅ Presupuesto establecido exitosamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            '⚠️ Ingresa un valor válido para el presupuesto')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  //metodo para obtener el presupuesto
  Future<PresupuestoModel?> obtenerPresupuesto() async {
    // Asegurarse de que la caja esté abierta
    if (!Hive.isBoxOpen('presupuestoBox')) {
      await Hive.openBox<PresupuestoModel>('presupuestoBox');
    }
    final box = Hive.box<PresupuestoModel>('presupuestoBox');
    return box.get('presupuesto');
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (fechaSeleccionada != null) {
      _fechaSeleccionada = fechaSeleccionada;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _descripcionController.clear();
    _cantidadController.clear();
    _categoriaSeleccionada = null;
    _fechaSeleccionada = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _cantidadController.dispose();
    Hive.box<PresupuestoModel>('presupuestoBox').close();
    super.dispose();
  }
}
