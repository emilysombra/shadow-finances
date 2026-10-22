/// Aparências que o usuário pode escolher para o app.
///
/// Não há valor "sistema": a ausência de escolha (`null`) significa seguir o
/// tema do dispositivo, como no idioma.
///
/// Os nomes dos valores são persistidos como preferência do usuário;
/// renomeá-los exige migrar o valor salvo.
enum AppThemeMode { light, dark }
