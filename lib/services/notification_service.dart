import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static int _id = 0;

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'sagaeat_channel',
            'SagaEat Notifikasyon',
            description: 'Alèt pou kòmand, pèman, ak pwomo.',
            importance: Importance.high,
          ),
        );
  }

  static Future<void> _show(String title, String body) async {
    try {
      await _plugin.show(
        _id++,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sagaeat_channel',
            'SagaEat Notifikasyon',
            channelDescription: 'Alèt pou kòmand, pèman, ak pwomo.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (_) {}
  }

  // ── Kòmand avèk Livrezon ──────────────────────────────────────

  static Future<void> orderEnCours({
    required String restoran,
    required int quantite,
    required String plat,
    String? sipleman,
    required String mode,
  }) {
    final detail = sipleman != null && sipleman.isNotEmpty
        ? 'ki gen kom sipleman $sipleman'
        : '';
    final body =
        'Ou komande $quantite $plat${detail.isNotEmpty ? ' $detail' : ''} nan $restoran';
    return _show('Kòmand Resevwa ✅', body);
  }

  static Future<void> orderEnPreparation({
    required String restoran,
    required int quantite,
    required String plat,
    required String tempsPrep,
    required String mode,
  }) {
    final suffix = mode == 'pickup'
        ? '. N ap envite w komanse prepare w pou pase pran kòmand lan'
        : '';
    return _show(
      'Manje ap Prepare 👨‍🍳',
      '$restoran ap prepare $quantite $plat. Pla sa ta sipoze disponib nan mwens ke $tempsPrep$suffix',
    );
  }

  static Future<void> orderEnLivrezon({
    required String restoran,
    required int quantite,
    required String plat,
  }) {
    return _show(
      'Manje nan Livrezon 🛵',
      '$restoran an fini prepare $quantite $plat a pou ou. Li nan livrezon, n ap envite w pran yon ti pasyans silvouplè',
    );
  }

  static Future<void> orderAnile({required String restoran}) {
    return _show(
      'Kòmand Anile ❌',
      'Malerezman $restoran an anile kòmand ou an, kòb la ap monte sou kont ou nan yon ti moman',
    );
  }

  static Future<void> orderRanbousman({
    required String restoran,
    required int quantite,
    required String plat,
    required double montant,
  }) {
    return _show(
      'Ranbousman Resevwa 💚',
      '$quantite $plat ou te kòmande nan $restoran an anile, ou gen ${montant.toStringAsFixed(0)} HTG ki retounen sou kont ou',
    );
  }

  // ── Pòtmonè ───────────────────────────────────────────────────

  static Future<void> depotFait(double amount) {
    return _show(
      'Depo Reyisi 💰',
      'Ou fè yon depo ${amount.toStringAsFixed(0)} HTG sou kont ou, pa bliye manje se lavi an nou manje pou n selebre',
    );
  }

  static Future<void> argentResevwa({
    required String sender,
    required double amount,
  }) {
    return _show(
      'Kòb Resevwa 🎉',
      'Jounen an son bèl jounen paske $sender voye ${amount.toStringAsFixed(0)} kob pou ou pou achte manje sou Sagaeat',
    );
  }

  // ── Pwomo (super admin) ───────────────────────────────────────

  static Future<void> codePromo(String message) {
    return _show('Pwomo Espesyal 🎁', message);
  }
}
