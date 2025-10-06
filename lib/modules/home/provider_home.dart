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
    await calcularAhorroSemanal(); // Calcular ahorro semanal al iniciar
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
  // Meta de ahorro
  double _metaAhorro = 0.0; // Meta de ahorro
  int _semanasMetaAhorro = 0; // Semanas para alcanzar la meta
  
  // Getter y setter para la meta de ahorro
  double get metaAhorro => _metaAhorro;
  int get semanasMetaAhorro => _semanasMetaAhorro;
  
  set metaAhorro(double value) {
    _metaAhorro = value;
    notifyListeners();
  }

  set semanasMetaAhorro(int value) {
    _semanasMetaAhorro = value;
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
        
        // Recalcular el ahorro
        await calcularAhorroSemanal();
        
        final presupuestoActualizado = PresupuestoModel(
          presupuestoGeneral: presupuestoActual.presupuestoGeneral,
          saldoRestante: nuevoSaldoRestante,
          ahorro: _ahorro,
          metaAhorro: presupuestoActual.metaAhorro,
          semanasMetaAhorro: presupuestoActual.semanasMetaAhorro,
        );
        await box.put('presupuesto', presupuestoActualizado);

        _saldoRestante = nuevoSaldoRestante;
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
      final nuevoSaldoRestante =
          presupuestoActual.saldoRestante + gasto.cantidad;
      
      // Recalcular el ahorro después de eliminar un gasto
      await calcularAhorroSemanal();
      
      final presupuestoActualizado = PresupuestoModel(
        presupuestoGeneral: presupuestoActual.presupuestoGeneral,
        saldoRestante: nuevoSaldoRestante,
        ahorro: _ahorro,
        metaAhorro: presupuestoActual.metaAhorro,
        semanasMetaAhorro: presupuestoActual.semanasMetaAhorro,
      );
      await box.put('presupuesto', presupuestoActualizado);

      _saldoRestante = nuevoSaldoRestante;
    }
    
    cargarGastos(); // Recargar la lista de gastos
    notifyListeners();
    
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
      _metaAhorro = presupuesto.metaAhorro;
      _semanasMetaAhorro = presupuesto.semanasMetaAhorro;
      _ahorro = presupuesto.ahorro;
    } else {
      _presupuestoGeneral = 0.0;
      _saldoRestante = 0.0;
      _metaAhorro = 0.0;
      _semanasMetaAhorro = 0;
      _ahorro = 0.0;
    }
    notifyListeners();
  }

  /// Establece el presupuesto general (solo lógica)
  Future<void> establecerPresupuesto(double presupuesto) async {
    // Asegurarse de que la caja esté abierta
    if (!Hive.isBoxOpen('presupuestoBox')) {
      await Hive.openBox<PresupuestoModel>('presupuestoBox');
    }

    final box = Hive.box<PresupuestoModel>('presupuestoBox');
    final presupuestoActual = box.get('presupuesto');

    // Recalcular el ahorro recomendado automáticamente (15% del nuevo presupuesto)
    final double nuevoAhorro = presupuesto * 0.15;

    // Actualizar el presupuesto y el saldo restante
    final nuevoPresupuesto = PresupuestoModel(
      presupuestoGeneral: presupuesto,
      saldoRestante: presupuesto,
      ahorro: nuevoAhorro,
      metaAhorro: presupuestoActual?.metaAhorro ?? _metaAhorro,
      semanasMetaAhorro: presupuestoActual?.semanasMetaAhorro ?? _semanasMetaAhorro,
    );
    await box.put('presupuesto', nuevoPresupuesto);

    _presupuestoGeneral = nuevoPresupuesto.presupuestoGeneral;
    _saldoRestante = nuevoPresupuesto.saldoRestante;
    _ahorro = nuevoPresupuesto.ahorro;
    
    // Recalcular el ahorro recomendado considerando la meta
    await calcularAhorroSemanal();
    
    notifyListeners();
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

  Future<void> calcularAhorroSemanal() async {
    // Asegurarse de que Hive esté inicializado
    await _gastoService.initHive();
  
    // Calcular el ahorro recomendado (15% del presupuesto general)
    if (_presupuestoGeneral > 0) {
      final double ahorroRecomendadoMensual = _presupuestoGeneral * 0.15;
      
      // Si hay una meta de ahorro establecida, verificar si ya se alcanzó
      if (_metaAhorro > 0) {
        // El ahorro acumulado será el 15% hasta llegar a la meta
        _ahorro = ahorroRecomendadoMensual > _metaAhorro 
            ? _metaAhorro 
            : double.parse(ahorroRecomendadoMensual.toStringAsFixed(2));
        
        print('Meta de ahorro: $_metaAhorro');
        print('Ahorro recomendado mensual (15%): ${ahorroRecomendadoMensual.toStringAsFixed(2)}');
        print('Ahorro actual: $_ahorro');
        
        if (_ahorro >= _metaAhorro) {
          print('🎉 ¡Meta de ahorro alcanzada!');
        } else {
          final double faltante = _metaAhorro - _ahorro;
          print('Faltante para alcanzar la meta: ${faltante.toStringAsFixed(2)}');
        }
      } else {
        // Si no hay meta, simplemente mostrar el 15% recomendado
        _ahorro = double.parse(ahorroRecomendadoMensual.toStringAsFixed(2));
        print('Ahorro recomendado mensual (15% del presupuesto): ${_ahorro.toStringAsFixed(2)}');
      }
    } else {
      _ahorro = 0.0;
      print('Presupuesto general no establecido. Ahorro: $_ahorro');
    }
  
    notifyListeners();
  }



  Future<void> calcularRecomendacionAhorro(int semanas) async {
    if (_metaAhorro <= 0 || semanas <= 0 || _presupuestoGeneral <= 0) {
      print('⚠️ Meta de ahorro, semanas o presupuesto no válidos');
      return;
    }
  
    // Ahorro mensual recomendado (15% del presupuesto)
    final double ahorroMensualRecomendado = _presupuestoGeneral * 0.15;
    
    // Calcular cuántos meses tomará alcanzar la meta ahorrando el 15% mensual
    final double mesesNecesarios = _metaAhorro / ahorroMensualRecomendado;
    
    // Calcular ahorro semanal (asumiendo 4 semanas por mes)
    final double ahorroSemanalRecomendado = ahorroMensualRecomendado / 4;
  
    // Imprimir la recomendación
    print('═══════════════════════════════════════');
    print('📊 ANÁLISIS DE META DE AHORRO');
    print('═══════════════════════════════════════');
    print('💰 Presupuesto mensual: \$${_presupuestoGeneral.toStringAsFixed(2)}');
    print('🎯 Meta de ahorro: \$${_metaAhorro.toStringAsFixed(2)}');
    print('📅 Semanas definidas: $semanas semanas');
    print('');
    print('💡 RECOMENDACIÓN (15% del presupuesto):');
    print('   • Ahorro mensual: \$${ahorroMensualRecomendado.toStringAsFixed(2)} (15%)');
    print('   • Ahorro semanal: \$${ahorroSemanalRecomendado.toStringAsFixed(2)}');
    print('   • Meses para alcanzar meta: ${mesesNecesarios.toStringAsFixed(1)} meses');
    print('   • Semanas para alcanzar meta: ${(mesesNecesarios * 4).toStringAsFixed(0)} semanas');
    print('═══════════════════════════════════════');
    
    if (semanas < (mesesNecesarios * 4)) {
      print('⚠️ ALERTA: El plazo definido ($semanas semanas) es muy corto.');
      print('   Se recomienda ${(mesesNecesarios * 4).toStringAsFixed(0)} semanas para mantener el 15% mensual.');
    } else {
      print('✅ El plazo definido es adecuado para ahorrar el 15% mensual.');
    }
  }
  
  /// Establece la meta de ahorro y la guarda en Hive
  Future<void> establecerMetaAhorro(double meta, int semanas) async {
    if (meta <= 0 || semanas <= 0) {
      throw Exception('Meta y semanas deben ser mayores a 0');
    }
    
    // Asegurarse de que la caja esté abierta
    if (!Hive.isBoxOpen('presupuestoBox')) {
      await Hive.openBox<PresupuestoModel>('presupuestoBox');
    }

    final box = Hive.box<PresupuestoModel>('presupuestoBox');
    final presupuestoActual = box.get('presupuesto');
    
    // Actualizar las variables locales
    _metaAhorro = meta;
    _semanasMetaAhorro = semanas;
    
    // Calcular recomendación
    await calcularRecomendacionAhorro(semanas);
    
    // Recalcular el ahorro con la nueva meta
    await calcularAhorroSemanal();
    
    // Guardar en Hive
    final presupuestoActualizado = PresupuestoModel(
      presupuestoGeneral: presupuestoActual?.presupuestoGeneral ?? _presupuestoGeneral,
      saldoRestante: presupuestoActual?.saldoRestante ?? _saldoRestante,
      ahorro: _ahorro,
      metaAhorro: _metaAhorro,
      semanasMetaAhorro: _semanasMetaAhorro,
    );
    await box.put('presupuesto', presupuestoActualizado);
    
    print('✅ Meta de ahorro guardada en Hive: \$$meta en $semanas semanas');
    notifyListeners();
  }
}
