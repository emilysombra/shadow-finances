# Shadow Finances

Aplicativo mobile de finanças pessoais em Flutter, com Material Design 3 como base visual.

## Ambiente

Nada de Flutter/Dart/Android SDK é instalado no host. Todo comando roda dentro do
container definido em [docker/Dockerfile](docker/Dockerfile) via `make` (que usa
`docker compose run`). Versões fixadas na imagem:

- Flutter 3.47.7 (Dart 3.13.5), JDK 17, Android SDK platform 36 / build-tools 36.0.0

Dependências do pub ficam em `./.pub-cache` (dentro do projeto, ignorado pelo git);
o cache do Gradle fica no volume nomeado `gradle-cache`. O `pubspec.lock` é
versionado para garantir builds idênticas.

Para mudar a versão do Flutter, altere `FLUTTER_VERSION` no Dockerfile **e** a tag
`image:` em [compose.yaml](compose.yaml), depois rode `make image`.

## Comandos

```sh
make image        # constrói a imagem (primeira vez / após mudar o Dockerfile)
make deps         # flutter pub get
make run-web      # roda em http://localhost:8080 (preview rápido)
make run-android  # roda em dispositivo Android via USB (depuração USB ativa)
make apk          # APK de debug em build/app/outputs/flutter-apk/
make test         # testes
make analyze      # análise estática
make format       # dart format
make shell        # shell no container, para qualquer outro comando
```

Nunca rode `flutter`/`dart` direto no host. Para comandos avulsos:
`docker compose run --rm flutter <comando>`.

## Estrutura

- `lib/main.dart` — ponto de entrada, `MaterialApp` e tema
- `test/` — testes de widget/unidade
- `android/`, `ios/`, `web/` — projetos de plataforma gerados pelo Flutter
  (iOS não pode ser compilado neste ambiente Linux)

## Convenções

- Material 3: cores via `ColorScheme.fromSeed`, tipografia via `Theme.of(context).textTheme`;
  não fixe cores ou tamanhos de fonte em widgets.
- Suporte a tema claro e escuro desde o início.
- Lints: `flutter_lints` (ver `analysis_options.yaml`); `make analyze` e `make test`
  devem passar antes de concluir qualquer mudança.
- Textos de interface em português (pt-BR).
