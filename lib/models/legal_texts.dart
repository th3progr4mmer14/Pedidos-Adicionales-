/// Textos legales de PedidosOXXO.
///
/// IMPORTANTE: Todo lo que está entre [CORCHETES] lo tienes que llenar
/// con los datos reales. El aviso de privacidad debe aprobarlo OXXO
/// (son los responsables de los datos de sus empleados) y conviene
/// que lo revise un abogado antes de publicarlo.
///
/// Cada vez que cambies un texto, sube [LegalTexts.version] para que la
/// app pida aceptar de nuevo.
class LegalSection {
  const LegalSection(this.title, this.paragraphs);
  final String title;
  final List<String> paragraphs;
}

class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.updatedAt,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String updatedAt;
  final String intro;
  final List<LegalSection> sections;
}

class LegalTexts {
  LegalTexts._();

  /// Versión vigente de las políticas. Guárdala en BD cuando el usuario acepte.
  static const String version = '1.0';
  static const String updatedAt = '22 de octubre de 2026';

  static const String contactEmail = '[CORREO DE CONTACTO PARA PRIVACIDAD]';

  // ---------------------------------------------------------------------------
  // AVISO DE PRIVACIDAD (integral)
  // ---------------------------------------------------------------------------
  static const LegalDocument privacyNotice = LegalDocument(
    title: 'Aviso de privacidad',
    updatedAt: updatedAt,
    intro:
        'Este aviso explica qué datos personales se usan en la aplicación '
        'PedidosOXXO, para qué se usan y cómo puedes ejercer tus derechos, '
        'conforme a la Ley Federal de Protección de Datos Personales en '
        'Posesión de los Particulares.',
    sections: [
      LegalSection('1. Responsable y encargado', [
        '[RAZÓN SOCIAL DE OXXO], con domicilio en [DOMICILIO], es el '
            'responsable del tratamiento de tus datos personales.',
        'Eduardo Suárez Mollinedo, proveedor de la aplicación, actúa como '
            'encargado: trata los datos únicamente por cuenta del responsable '
            'y conforme a sus instrucciones.',
      ]),
      LegalSection('2. Datos personales que se tratan', [
        'Datos de identificación y laborales: número de empleado, nombre, '
            'rol, plaza y tienda asignadas, y correo electrónico (si aplica).',
        'Datos de uso: pedidos que registras, fechas y horas de captura, y '
            'cambios que realizas en la aplicación.',
        'Datos técnicos: tipo de dispositivo, versión de la app, dirección IP '
            'y registros de acceso, usados con fines de seguridad.',
        'No se tratan datos personales sensibles.',
      ]),
      LegalSection('3. Finalidades necesarias', [
        'Estas finalidades son necesarias para que la aplicación funcione y '
            'derivan de tu relación laboral:',
        '• Crear tu cuenta, autenticarte y asignarte tu plaza y tienda.',
        '• Registrar, consultar y dar seguimiento a los pedidos de tu tienda.',
        '• Enviar notificaciones por correo relacionadas con los pedidos.',
        '• Mantener la seguridad de la aplicación, prevenir accesos no '
            'autorizados y conservar un registro de auditoría.',
      ]),
      LegalSection('4. Finalidades que requieren tu consentimiento', [
        '[SI NO HAY FINALIDADES ADICIONALES, DEJA ESTE TEXTO:] Tus datos no se '
            'usan para finalidades distintas a las señaladas en el punto 3. '
            'Si en el futuro se quisieran usar para otra finalidad, se te '
            'pedirá tu consentimiento antes.',
      ]),
      LegalSection('5. Almacenamiento y terceros', [
        'La información se almacena en servicios de infraestructura en la '
            'nube contratados para operar la aplicación (Supabase y Render), '
            'cuyos servidores pueden ubicarse fuera de México. Estos '
            'proveedores no usan tus datos para fines propios.',
        'Tus datos no se venden ni se comparten con terceros ajenos a la '
            'operación de la aplicación, salvo requerimiento de autoridad '
            'competente.',
      ]),
      LegalSection('6. Medidas de seguridad', [
        'Se aplican medidas técnicas y administrativas como contraseñas '
            'cifradas, conexiones cifradas (HTTPS), control de acceso por rol, '
            'límites de intentos y registro de actividad.',
      ]),
      LegalSection('7. Derechos ARCO y revocación del consentimiento', [
        'Puedes solicitar el Acceso, Rectificación, Cancelación u Oposición '
            '(derechos ARCO) respecto de tus datos, así como revocar tu '
            'consentimiento, enviando un correo a $contactEmail con tu número '
            'de empleado, tu nombre y la descripción de lo que solicitas.',
        'Se dará respuesta en un plazo máximo de [20] días hábiles.',
        'Algunos datos no pueden cancelarse mientras sigas siendo usuario de '
            'la aplicación, porque son necesarios para su funcionamiento o '
            'para cumplir obligaciones del responsable.',
      ]),
      LegalSection('8. Conservación', [
        'Tus datos se conservan mientras tengas una cuenta activa y durante '
            '[PLAZO] posterior a su baja. Al terminar el servicio, la '
            'información se entrega al responsable y se elimina de forma '
            'segura de los servidores del proveedor.',
      ]),
      LegalSection('9. Cambios a este aviso', [
        'Cualquier cambio se notificará dentro de la aplicación. Si el cambio '
            'lo requiere, se te pedirá aceptar nuevamente.',
      ]),
      LegalSection('10. Autoridad', [
        'Si consideras que tu derecho a la protección de datos personales ha '
            'sido vulnerado, puedes acudir a la Secretaría Anticorrupción y '
            'Buen Gobierno.',
      ]),
    ],
  );

  // ---------------------------------------------------------------------------
  // TÉRMINOS Y CONDICIONES DE USO
  // ---------------------------------------------------------------------------
  static const LegalDocument termsOfUse = LegalDocument(
    title: 'Términos y condiciones de uso',
    updatedAt: updatedAt,
    intro:
        'Al activar tu cuenta y usar PedidosOXXO aceptas estos términos. '
        'Si no estás de acuerdo, no uses la aplicación y avisa a tu asesor.',
    sections: [
      LegalSection('1. Objeto', [
        'PedidosOXXO es una herramienta interna para registrar y dar '
            'seguimiento a pedidos de las tiendas OXXO de la región '
            '[REGIÓN]. Su uso es exclusivamente laboral.',
      ]),
      LegalSection('2. Tu cuenta', [
        '• Tu cuenta es personal e intransferible y está ligada a tu número '
            'de empleado.',
        '• Debes cambiar la contraseña temporal en tu primer ingreso y no '
            'compartirla con nadie.',
        '• Eres responsable de lo que se registre con tu cuenta. Si crees '
            'que alguien más la usó, avisa de inmediato a tu asesor o a '
            '$contactEmail.',
      ]),
      LegalSection('3. Uso permitido', [
        'No está permitido:',
        '• Registrar pedidos falsos o información que no corresponda a tu '
            'tienda.',
        '• Intentar acceder a información de otras tiendas o plazas sin '
            'autorización.',
        '• Extraer, copiar o compartir información de la aplicación fuera de '
            'la empresa.',
        '• Intentar vulnerar, alterar o hacer ingeniería inversa de la '
            'aplicación.',
      ]),
      LegalSection('4. Suspensión de cuentas', [
        'Las cuentas pueden suspenderse por mal uso, por baja del colaborador '
            'o a solicitud de la empresa.',
      ]),
      LegalSection('5. Disponibilidad', [
        'Se procura que la aplicación esté disponible de forma continua, pero '
            'puede haber interrupciones por mantenimiento o fallas. En esos '
            'casos usa el procedimiento alterno que indique tu asesor.',
      ]),
      LegalSection('6. Propiedad intelectual', [
        'La aplicación, su código y su diseño son propiedad de su '
            'desarrollador y se licencian a [RAZÓN SOCIAL DE OXXO] para su '
            'uso interno. La información de pedidos pertenece a la empresa.',
      ]),
      LegalSection('7. Privacidad', [
        'El tratamiento de tus datos personales se rige por el Aviso de '
            'privacidad disponible en Ajustes.',
      ]),
      LegalSection('8. Cambios', [
        'Estos términos pueden actualizarse. Los cambios se avisarán en la '
            'aplicación y, si es necesario, se pedirá aceptarlos de nuevo.',
      ]),
    ],
  );
}
