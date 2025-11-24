import '../entities/trivia_question.dart';

/// Servicio para gestionar preguntas de trivia después de cada lección
class TriviaService {
  static final TriviaService _instance = TriviaService._internal();
  factory TriviaService() => _instance;
  TriviaService._internal();

  /// Obtiene preguntas de trivia para una lección específica
  /// Retorna 3-4 preguntas relacionadas con el contenido de la lección
  List<TriviaQuestion> getTriviaForLesson(String lessonId) {
    // Convertir lessonId a número para identificar la lección
    final lessonNumber = int.tryParse(lessonId) ?? 0;

    switch (lessonNumber) {
      case 1:
        return _getLesson1Questions(lessonId);
      case 2:
        return _getLesson2Questions(lessonId);
      case 3:
        return _getLesson3Questions(lessonId);
      case 4:
        return _getLesson4Questions(lessonId);
      case 5:
        return _getLesson5Questions(lessonId);
      case 6:
        return _getLesson6Questions(lessonId);
      case 7:
        return _getLesson7Questions(lessonId);
      case 8:
        return _getLesson8Questions(lessonId);
      case 9:
        return _getLesson9Questions(lessonId);
      case 10:
        return _getLesson10Questions(lessonId);
      case 11:
        return _getLesson11Questions(lessonId);
      case 12:
        return _getLesson12Questions(lessonId);
      case 13:
        return _getLesson13Questions(lessonId);
      case 14:
        return _getLesson14Questions(lessonId);
      default:
        return _getGenericLactationTrivia(lessonId);
    }
  }

  // Lección 1: Lactancia materna y sus beneficios
  List<TriviaQuestion> _getLesson1Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question:
            '¿Cuál es uno de los principales beneficios de la lactancia materna para el bebé?',
        options: [
          'Mayor riesgo de infecciones',
          'Fortalece el sistema inmunológico y reduce infecciones',
          'Aumenta el riesgo de alergias',
          'No tiene beneficios especiales',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna contiene anticuerpos y factores inmunológicos que fortalecen el sistema inmunológico del bebé y reducen el riesgo de infecciones.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿Qué beneficio tiene la lactancia materna para la madre?',
        options: [
          'Aumenta el riesgo de cáncer de mama',
          'Ayuda a la recuperación postparto y reduce el riesgo de ciertos cánceres',
          'No tiene beneficios para la madre',
          'Solo beneficia al bebé',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La lactancia materna ayuda a la madre a recuperarse del parto, reduce el riesgo de cáncer de mama y ovario, y fortalece el vínculo madre-hijo.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question:
            '¿La leche materna es suficiente para alimentar al bebé durante los primeros 6 meses?',
        options: [
          'No, siempre necesita complementos',
          'Sí, proporciona todos los nutrientes necesarios',
          'Solo para los primeros 3 meses',
          'Depende del bebé',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna es el alimento completo e ideal para los bebés durante los primeros 6 meses de vida, proporcionando todos los nutrientes necesarios.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Cuál es un beneficio económico de la lactancia materna?',
        options: [
          'Es más costosa que la fórmula',
          'Es gratuita y ahorra dinero en fórmula',
          'Requiere equipos costosos',
          'No tiene beneficios económicos',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La lactancia materna es gratuita y puede ahorrar significativamente en costos de fórmula, biberones y otros suministros.',
      ),
    ];
  }

  // Lección 2: Calostro, leche de transición y leche madura
  List<TriviaQuestion> _getLesson2Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Qué es el calostro?',
        options: [
          'Leche que aparece después de 1 mes',
          'La primera leche rica en anticuerpos que produce la madre',
          'Leche de fórmula especial',
          'Leche que solo aparece en algunas madres',
        ],
        correctAnswerIndex: 1,
        explanation:
            'El calostro es la primera leche que produce la madre, rica en anticuerpos, proteínas y factores inmunológicos esenciales para el recién nacido.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿Cuándo aparece la leche de transición?',
        options: [
          'Inmediatamente después del parto',
          'Entre el día 3 y 14 después del parto',
          'Después de 1 mes',
          'Solo en algunas madres',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche de transición aparece entre el día 3 y 14 después del parto, es más abundante que el calostro y contiene más grasa y lactosa.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Cuándo se establece la leche madura?',
        options: [
          'Inmediatamente después del parto',
          'Después de aproximadamente 2 semanas',
          'Después de 3 meses',
          'Nunca se establece',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche madura se establece aproximadamente después de 2 semanas del parto y tiene una composición más estable con el equilibrio adecuado de nutrientes.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Por qué es importante el calostro para el recién nacido?',
        options: [
          'No tiene importancia especial',
          'Proporciona la primera inmunización y es rico en nutrientes',
          'Solo hidrata al bebé',
          'Es igual que la leche madura',
        ],
        correctAnswerIndex: 1,
        explanation:
            'El calostro es crucial porque proporciona la primera inmunización del bebé, es rico en proteínas y anticuerpos, y ayuda a establecer el sistema digestivo.',
      ),
    ];
  }

  // Lección 3: Cosas a considerar al momento de amamantar
  List<TriviaQuestion> _getLesson3Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Qué es importante considerar antes de amamantar?',
        options: [
          'Nada, solo dar el pecho',
          'Comodidad de la madre, posición del bebé y ambiente tranquilo',
          'Solo la posición del bebé',
          'Solo el ambiente',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Es importante considerar la comodidad de la madre, la posición correcta del bebé, un ambiente tranquilo y que ambos estén relajados.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿Cuál es una posición adecuada para amamantar?',
        options: [
          'Solo de pie',
          'Posición cuna, balón de rugby, acostada de lado',
          'Solo sentada',
          'Cualquier posición es igual',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Existen varias posiciones adecuadas como la posición cuna, balón de rugby, acostada de lado, etc. Lo importante es que madre y bebé estén cómodos.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Qué indica un buen agarre del pecho?',
        options: [
          'El bebé solo toca el pezón',
          'El bebé tiene la boca bien abierta, abarca parte de la areola y no hay dolor',
          'Siempre hay dolor al amamantar',
          'El bebé solo chupa el pezón',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Un buen agarre incluye que el bebé tenga la boca bien abierta, abarque parte de la areola (no solo el pezón), y que la madre no sienta dolor.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Es necesario limpiar el pecho antes de cada toma?',
        options: [
          'Sí, siempre con jabón',
          'No, la higiene diaria normal es suficiente',
          'Solo con agua caliente',
          'Solo si está sucio',
        ],
        correctAnswerIndex: 1,
        explanation:
            'No es necesario limpiar el pecho antes de cada toma. La higiene diaria normal es suficiente, y el exceso de limpieza puede eliminar las bacterias beneficiosas.',
      ),
    ];
  }

  // Lección 4: Composición Nutricional de la Leche Materna
  List<TriviaQuestion> _getLesson4Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Qué componente principal contiene la leche materna?',
        options: [
          'Solo agua',
          'Agua, proteínas, grasas, carbohidratos, vitaminas y minerales',
          'Solo proteínas',
          'Solo grasas',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna contiene una composición completa: agua, proteínas, grasas, carbohidratos (lactosa), vitaminas, minerales y factores inmunológicos.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿La composición de la leche materna cambia?',
        options: [
          'No, siempre es igual',
          'Sí, cambia durante la toma, durante el día y según la edad del bebé',
          'Solo cambia una vez',
          'Solo cambia según la hora del día',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La composición de la leche materna es dinámica: cambia durante la toma (más grasa al final), durante el día, y se adapta a las necesidades del bebé según su edad.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Qué tipo de proteínas contiene la leche materna?',
        options: [
          'Solo proteínas de origen animal',
          'Proteínas de fácil digestión como la lactoferrina y la inmunoglobulina A',
          'Solo proteínas vegetales',
          'No contiene proteínas',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna contiene proteínas de fácil digestión como la lactoferrina y la inmunoglobulina A, que son específicas para las necesidades del bebé.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Por qué es importante la grasa en la leche materna?',
        options: [
          'No es importante',
          'Proporciona energía y es esencial para el desarrollo del cerebro',
          'Solo proporciona sabor',
          'Solo es importante para el peso',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La grasa en la leche materna es crucial porque proporciona la mayor parte de la energía y contiene ácidos grasos esenciales para el desarrollo del cerebro y el sistema nervioso.',
      ),
    ];
  }

  // Lección 5: ¿Cómo saber que el bebé se alimentó lo suficiente?
  List<TriviaQuestion> _getLesson5Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question:
            '¿Cuál es una señal de que el bebé está recibiendo suficiente leche?',
        options: [
          'Llora constantemente',
          'Aumenta de peso adecuadamente, moja 6+ pañales al día y está contento',
          'Duerme todo el día',
          'Rechaza el pecho',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Las señales de que el bebé recibe suficiente leche incluyen: aumento de peso adecuado, mojar al menos 6 pañales al día, estar contento entre tomas y tener deposiciones regulares.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question:
            '¿Cuántos pañales mojados al día indica que el bebé está bien alimentado?',
        options: [
          '1-2 pañales',
          'Al menos 6 pañales mojados',
          'Solo 3 pañales',
          'No importa la cantidad',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Un bebé bien alimentado debe mojar al menos 6 pañales al día con orina clara o amarilla pálida, lo que indica una hidratación adecuada.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Qué indica un buen aumento de peso en el bebé?',
        options: [
          'No aumenta de peso',
          'Aumenta aproximadamente 20-30 gramos por día en los primeros meses',
          'Aumenta 100 gramos por día',
          'El peso no es importante',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Un buen aumento de peso en los primeros meses es aproximadamente de 20-30 gramos por día, aunque puede variar. Lo importante es una tendencia de crecimiento constante.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question:
            '¿Cuándo se debe buscar ayuda si hay preocupación sobre la alimentación?',
        options: [
          'Nunca',
          'Si el bebé no aumenta de peso, moja menos de 6 pañales o está muy somnoliento',
          'Solo después de 6 meses',
          'Solo si llora mucho',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Se debe buscar ayuda profesional si el bebé no aumenta de peso adecuadamente, moja menos de 6 pañales al día, está muy somnoliento o muestra signos de deshidratación.',
      ),
    ];
  }

  // Lección 6: Hitos de peso a vigilar
  List<TriviaQuestion> _getLesson6Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Cuál es un hito de peso esperado en los primeros días?',
        options: [
          'El bebé no debe perder peso',
          'Es normal que pierda hasta 10% del peso al nacer en los primeros días',
          'Debe ganar peso inmediatamente',
          'El peso no importa',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Es normal que un recién nacido pierda hasta un 10% de su peso al nacer en los primeros días, pero debe recuperarlo alrededor del día 10-14.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿Cuándo debe recuperar el bebé su peso al nacer?',
        options: [
          'Inmediatamente',
          'Alrededor de los 10-14 días de vida',
          'Después de 1 mes',
          'Nunca lo recupera',
        ],
        correctAnswerIndex: 1,
        explanation:
            'El bebé debe recuperar su peso al nacer alrededor de los 10-14 días de vida. Si no lo hace, es importante consultar con un profesional.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Qué indica un crecimiento adecuado del bebé?',
        options: [
          'Aumenta de peso de forma irregular',
          'Sigue una curva de crecimiento consistente según su percentil',
          'Aumenta mucho peso de golpe',
          'El peso no es indicador',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Un crecimiento adecuado se refleja en que el bebé sigue una curva de crecimiento consistente según su percentil, no necesariamente aumentando mucho, sino de forma constante.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question:
            '¿Con qué frecuencia se debe pesar al bebé en los primeros meses?',
        options: [
          'Todos los días',
          'Según las recomendaciones del pediatra, típicamente en controles regulares',
          'Solo una vez al mes',
          'No es necesario pesarlo',
        ],
        correctAnswerIndex: 1,
        explanation:
            'El bebé debe pesarse según las recomendaciones del pediatra en controles regulares. No es necesario pesarlo diariamente en casa a menos que haya una preocupación específica.',
      ),
    ];
  }

  // Lección 7: Higiene de manos y técnicas de lactancia materna
  List<TriviaQuestion> _getLesson7Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Cuándo es importante lavarse las manos antes de amamantar?',
        options: [
          'Nunca es necesario',
          'Antes de cada toma, especialmente después de cambiar pañales o tocar objetos',
          'Solo por la mañana',
          'Solo si están visiblemente sucias',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Es importante lavarse las manos antes de cada toma, especialmente después de cambiar pañales, tocar objetos o preparar alimentos, para prevenir la transmisión de gérmenes.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question:
            '¿Es necesario limpiar el pecho con jabón antes de cada toma?',
        options: [
          'Sí, siempre con jabón',
          'No, la higiene diaria normal es suficiente',
          'Solo con agua caliente',
          'Solo si está sucio',
        ],
        correctAnswerIndex: 1,
        explanation:
            'No es necesario limpiar el pecho con jabón antes de cada toma. La higiene diaria normal durante el baño es suficiente y evita eliminar las bacterias beneficiosas.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Qué técnica ayuda a facilitar el flujo de leche?',
        options: [
          'Presionar fuerte el pecho',
          'Masajes suaves, compresión del pecho y relajación',
          'Solo esperar',
          'No hay técnicas',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Técnicas como masajes suaves del pecho, compresión del pecho durante la toma y mantener un ambiente relajado pueden ayudar a facilitar el flujo de leche.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question:
            '¿Qué hacer si el bebé tiene dificultad para agarrar el pecho?',
        options: [
          'Forzar el agarre',
          'Buscar ayuda profesional, verificar la posición y ser paciente',
          'Cambiar a biberón inmediatamente',
          'Esperar que se resuelva solo',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Si hay dificultades de agarre, es importante buscar ayuda profesional, verificar que la posición sea correcta, y ser paciente. No se debe forzar ni cambiar inmediatamente a biberón.',
      ),
    ];
  }

  // Lección 8: Medicamentos durante la lactancia materna
  List<TriviaQuestion> _getLesson8Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Se puede tomar medicamentos durante la lactancia?',
        options: [
          'Nunca se puede tomar ningún medicamento',
          'Muchos medicamentos son seguros, pero siempre se debe consultar con el médico',
          'Todos los medicamentos son seguros',
          'Solo medicamentos naturales',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Muchos medicamentos son seguros durante la lactancia, pero es esencial consultar siempre con el médico o farmacéutico antes de tomar cualquier medicamento.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question:
            '¿Qué hacer si necesitas tomar un medicamento durante la lactancia?',
        options: [
          'Tomarlo sin consultar',
          'Consultar con el médico sobre la compatibilidad con la lactancia',
          'Suspender la lactancia automáticamente',
          'Solo tomar medicamentos naturales',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Siempre se debe consultar con el médico sobre la compatibilidad del medicamento con la lactancia. La mayoría de medicamentos comunes son seguros, pero es importante verificarlo.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Los medicamentos pasan a la leche materna?',
        options: [
          'Nunca pasan',
          'Algunos medicamentos pueden pasar en pequeñas cantidades, por eso es importante consultar',
          'Todos pasan en grandes cantidades',
          'Solo los antibióticos pasan',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Algunos medicamentos pueden pasar a la leche materna en pequeñas cantidades. Por eso es crucial consultar con un profesional de la salud para evaluar el riesgo-beneficio.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question:
            '¿Dónde se puede consultar sobre la seguridad de medicamentos durante la lactancia?',
        options: [
          'Solo en internet',
          'Con el médico, farmacéutico o en bases de datos especializadas como e-lactancia',
          'No hay forma de consultar',
          'Solo con otros padres',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Se debe consultar con el médico, farmacéutico o en bases de datos especializadas como e-lactancia.org que proporcionan información actualizada sobre medicamentos y lactancia.',
      ),
    ];
  }

  // Lección 9: Signos o Complicaciones en la Lactancia
  List<TriviaQuestion> _getLesson9Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Cuál es un signo de complicación en la lactancia?',
        options: [
          'El bebé se alimenta bien',
          'Dolor persistente, grietas en el pezón, mastitis o el bebé no aumenta de peso',
          'Solo si el bebé llora',
          'No hay signos de complicación',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Signos de complicación incluyen: dolor persistente, grietas en el pezón, mastitis, el bebé no aumenta de peso adecuadamente, o dificultades de agarre persistentes.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿Qué es la mastitis?',
        options: [
          'Una condición normal',
          'Una inflamación del tejido mamario que puede incluir infección',
          'Solo dolor en el pecho',
          'No existe',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La mastitis es una inflamación del tejido mamario que puede incluir una infección. Se caracteriza por dolor, enrojecimiento, calor y a veces fiebre. Requiere atención médica.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Qué hacer si hay dolor persistente al amamantar?',
        options: [
          'Ignorarlo',
          'Buscar ayuda profesional para identificar y tratar la causa',
          'Suspender la lactancia',
          'Solo tomar analgésicos',
        ],
        correctAnswerIndex: 1,
        explanation:
            'El dolor persistente al amamantar no es normal y requiere buscar ayuda profesional para identificar la causa (mala posición, agarre incorrecto, infección) y tratarla adecuadamente.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Las grietas en el pezón son normales?',
        options: [
          'Sí, siempre aparecen',
          'No, generalmente indican un problema de agarre o posición que debe corregirse',
          'Solo aparecen en algunas madres',
          'No son importantes',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Las grietas en el pezón generalmente indican un problema de agarre o posición. No son normales y deben abordarse corrigiendo la técnica de lactancia con ayuda profesional.',
      ),
    ];
  }

  // Lección 10: Masajes al seno antes de iniciar la lactancia
  List<TriviaQuestion> _getLesson10Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Para qué sirven los masajes al seno antes de amamantar?',
        options: [
          'No sirven para nada',
          'Ayudan a estimular el flujo de leche y facilitar el agarre',
          'Solo para relajar',
          'Solo si hay dolor',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Los masajes al seno antes de amamantar ayudan a estimular el flujo de leche, ablandar el pecho si está muy lleno, y facilitar que el bebé pueda agarrar mejor el pecho.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿Cómo se realizan los masajes al seno?',
        options: [
          'Con mucha fuerza',
          'Con movimientos suaves y circulares desde la base hacia el pezón',
          'Solo presionando el pezón',
          'No hay técnica específica',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Los masajes se realizan con movimientos suaves y circulares desde la base del seno hacia el pezón, ayudando a movilizar la leche y preparar el pecho para la toma.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Cuándo es especialmente útil masajear el seno?',
        options: [
          'Nunca es útil',
          'Cuando el pecho está muy lleno, antes de amamantar o para aliviar congestión',
          'Solo por la noche',
          'Solo si hay dolor',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Los masajes son especialmente útiles cuando el pecho está muy lleno, antes de amamantar para facilitar el flujo, o para aliviar la congestión mamaria.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Los masajes pueden ayudar con la extracción de leche?',
        options: [
          'No, no tienen efecto',
          'Sí, pueden mejorar la extracción manual o con bomba',
          'Solo con bomba eléctrica',
          'Solo manualmente',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Los masajes pueden mejorar significativamente la extracción de leche, ya sea manual o con bomba, ayudando a vaciar mejor el pecho y aumentar la producción.',
      ),
    ];
  }

  // Lección 11: Mi banco de leche en casa y su preservación
  List<TriviaQuestion> _getLesson11Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question:
            '¿Cuánto tiempo se puede conservar la leche materna extraída a temperatura ambiente?',
        options: [
          'Solo 1 hora',
          'Hasta 4 horas a temperatura ambiente (hasta 6-8 horas en condiciones muy limpias)',
          'Todo el día',
          'Solo 30 minutos',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna extraída se puede conservar hasta 4 horas a temperatura ambiente (hasta 6-8 horas en condiciones muy limpias y frescas).',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question:
            '¿Cuánto tiempo se puede conservar la leche materna en el refrigerador?',
        options: [
          'Solo 1 día',
          'Hasta 4 días en el refrigerador (a 4°C o menos)',
          'Solo 2 días',
          'No se puede refrigerar',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna se puede conservar hasta 4 días en el refrigerador a una temperatura de 4°C o menos, preferiblemente en la parte trasera del refrigerador.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Cómo se debe almacenar la leche materna extraída?',
        options: [
          'En cualquier recipiente',
          'En recipientes limpios y esterilizados, etiquetados con fecha y hora',
          'Solo en biberones',
          'No importa el recipiente',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna debe almacenarse en recipientes limpios y esterilizados (bolsas especiales o recipientes de vidrio/plástico aptos), etiquetados con fecha y hora de extracción.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Cómo se debe descongelar la leche materna congelada?',
        options: [
          'En el microondas directamente',
          'En el refrigerador durante la noche o bajo agua tibia, nunca en microondas',
          'Solo a temperatura ambiente',
          'En agua hirviendo',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche congelada debe descongelarse en el refrigerador durante la noche o bajo agua tibia corriente. Nunca se debe usar microondas porque destruye nutrientes y crea puntos calientes.',
      ),
    ];
  }

  // Lección 12: Leyes en Panamá que apoyan la lactancia materna
  List<TriviaQuestion> _getLesson12Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: '¿Existen leyes en Panamá que protegen la lactancia materna?',
        options: [
          'No existen leyes',
          'Sí, existen leyes que protegen y promueven la lactancia materna',
          'Solo en algunos lugares',
          'Solo para funcionarias públicas',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Sí, Panamá tiene leyes que protegen y promueven la lactancia materna, incluyendo derechos laborales para las madres trabajadoras.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question:
            '¿Qué derechos tienen las madres trabajadoras en Panamá respecto a la lactancia?',
        options: [
          'Ningún derecho especial',
          'Derecho a pausas para amamantar y espacios adecuados',
          'Solo pueden amamantar en casa',
          'Deben renunciar para amamantar',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Las madres trabajadoras en Panamá tienen derecho a pausas para amamantar y a espacios adecuados (salas de lactancia) en sus lugares de trabajo.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question:
            '¿Las leyes panameñas protegen la lactancia en espacios públicos?',
        options: [
          'No, está prohibido',
          'Sí, protegen el derecho de amamantar en espacios públicos',
          'Solo en algunos lugares',
          'Depende del lugar',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Las leyes panameñas protegen el derecho de las madres a amamantar en espacios públicos, promoviendo la normalización de la lactancia materna.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question:
            '¿Por qué son importantes las leyes que protegen la lactancia?',
        options: [
          'No son importantes',
          'Garantizan los derechos de las madres y promueven la salud de los bebés',
          'Solo protegen a algunas madres',
          'Solo son simbólicas',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Las leyes que protegen la lactancia son importantes porque garantizan los derechos de las madres, promueven la salud de los bebés y crean un entorno favorable para la lactancia materna.',
      ),
    ];
  }

  // Lección 13: Diferencias entre la leche materna y la leche de vaca
  List<TriviaQuestion> _getLesson13Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question:
            '¿Cuál es una diferencia clave entre la leche materna y la leche de vaca?',
        options: [
          'Son iguales',
          'La leche materna tiene anticuerpos y se adapta al bebé, la de vaca no',
          'Solo difieren en el sabor',
          'No hay diferencias importantes',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna contiene anticuerpos, factores inmunológicos y se adapta a las necesidades del bebé. La leche de vaca no tiene estos componentes y está diseñada para terneros, no para bebés humanos.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question:
            '¿Por qué la leche materna es más fácil de digerir que la de vaca?',
        options: [
          'No hay diferencia',
          'Tiene proteínas de fácil digestión y composición específica para humanos',
          'Solo porque es más líquida',
          'Por el sabor',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna tiene proteínas de fácil digestión (como la lactoferrina) y una composición específicamente diseñada para el sistema digestivo humano, a diferencia de la leche de vaca.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿La leche materna cambia según las necesidades del bebé?',
        options: [
          'No, siempre es igual',
          'Sí, se adapta según la edad del bebé, hora del día y necesidades',
          'Solo cambia una vez',
          'Solo cambia el sabor',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna es dinámica y se adapta según la edad del bebé, la hora del día, e incluso durante la misma toma, proporcionando exactamente lo que el bebé necesita.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Qué contiene la leche materna que la de vaca no tiene?',
        options: [
          'Nada especial',
          'Anticuerpos, factores de crecimiento, probióticos y componentes inmunológicos',
          'Solo más agua',
          'Solo más grasa',
        ],
        correctAnswerIndex: 1,
        explanation:
            'La leche materna contiene componentes únicos como anticuerpos, factores de crecimiento, probióticos y otros componentes inmunológicos que la leche de vaca no proporciona.',
      ),
    ];
  }

  // Lección 14: Mitos de la lactancia materna
  List<TriviaQuestion> _getLesson14Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question:
            '¿Es cierto que algunas mujeres no producen suficiente leche?',
        options: [
          'Sí, la mayoría no produce suficiente',
          'Es un mito común; la mayoría de mujeres pueden producir suficiente leche con apoyo adecuado',
          'Solo algunas pueden amamantar',
          'Depende de la edad',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Es un mito común. La mayoría de mujeres pueden producir suficiente leche. Las dificultades generalmente se deben a problemas de técnica, apoyo inadecuado o información incorrecta, no a falta de capacidad.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question:
            '¿Es necesario dar agua al bebé además de leche materna en los primeros 6 meses?',
        options: [
          'Sí, siempre necesita agua',
          'No, la leche materna proporciona toda la hidratación necesaria',
          'Solo en verano',
          'Solo si tiene fiebre',
        ],
        correctAnswerIndex: 1,
        explanation:
            'No es necesario dar agua adicional a un bebé amamantado en los primeros 6 meses. La leche materna proporciona toda la hidratación y nutrición necesaria.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Es cierto que amamantar duele siempre?',
        options: [
          'Sí, siempre duele',
          'No, el dolor indica un problema (mala posición o agarre) que debe corregirse',
          'Solo duele al principio',
          'Depende de la madre',
        ],
        correctAnswerIndex: 1,
        explanation:
            'El dolor al amamantar no es normal. Si hay dolor, generalmente indica un problema de posición o agarre que debe identificarse y corregirse con ayuda profesional.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: '¿Se puede amamantar si los senos son pequeños?',
        options: [
          'No, se necesita senos grandes',
          'Sí, el tamaño del seno no afecta la capacidad de producir leche',
          'Solo si son medianos',
          'Depende de la forma',
        ],
        correctAnswerIndex: 1,
        explanation:
            'El tamaño del seno no afecta la capacidad de producir leche. Las mujeres con senos pequeños pueden amamantar perfectamente, ya que la producción de leche depende del tejido glandular, no del tamaño.',
      ),
    ];
  }

  /// Preguntas genéricas sobre lactancia materna (fallback)
  List<TriviaQuestion> _getGenericLactationTrivia(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question:
            '¿Cuál es la frecuencia recomendada de alimentación para un recién nacido?',
        options: [
          'Cada 2-3 horas',
          'Cada 4-5 horas',
          'Solo cuando el bebé llora',
          'Una vez al día',
        ],
        correctAnswerIndex: 0,
        explanation:
            'Los recién nacidos deben alimentarse cada 2-3 horas para asegurar un crecimiento adecuado.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿Cuánto tiempo debe durar una sesión de lactancia típica?',
        options: [
          '5-10 minutos',
          '10-20 minutos por pecho',
          '30-45 minutos',
          'Más de 1 hora',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Una sesión típica de lactancia dura entre 10-20 minutos por pecho, aunque puede variar según el bebé.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Qué indica que el bebé está recibiendo suficiente leche?',
        options: [
          'Llora constantemente',
          'Aumenta de peso adecuadamente y moja 6+ pañales al día',
          'Duerme todo el día',
          'Rechaza el pecho',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Un bebé que recibe suficiente leche aumenta de peso adecuadamente y moja al menos 6 pañales al día.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question:
            '¿Cuándo se debe buscar ayuda profesional para problemas de lactancia?',
        options: [
          'Nunca, todo se resuelve solo',
          'Solo si hay dolor extremo',
          'Cuando hay dolor persistente, dificultades de agarre o preocupaciones sobre la alimentación',
          'Después de 6 meses',
        ],
        correctAnswerIndex: 2,
        explanation:
            'Es importante buscar ayuda profesional cuando hay dolor persistente, dificultades de agarre o cualquier preocupación sobre la alimentación del bebé.',
      ),
    ];
  }

  /// Verifica si una respuesta es correcta
  bool isAnswerCorrect(TriviaQuestion question, int selectedIndex) {
    return question.correctAnswerIndex == selectedIndex;
  }

  /// Calcula el puntaje de una trivia completada
  int calculateScore(
    List<TriviaQuestion> questions,
    List<int> selectedAnswers,
  ) {
    if (questions.length != selectedAnswers.length) {
      return 0;
    }

    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (isAnswerCorrect(questions[i], selectedAnswers[i])) {
        correct++;
      }
    }

    return correct;
  }
}
