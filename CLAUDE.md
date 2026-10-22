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
make deps         # flutter pub get (também regenera as traduções)
make l10n         # só regenera as traduções a partir dos .arb
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

## Como trabalhar neste projeto

- **A pessoa usuária não tem experiência com Flutter.** Ao fazer qualquer mudança,
  explique em detalhe o que foi feito e por quê: quais arquivos mudaram, o papel de
  cada um na arquitetura, conceitos de Flutter/Dart envolvidos (widget, `BuildContext`,
  `ChangeNotifier`, `async`/`await` etc.) e como verificar o resultado.
- **Mantenha este arquivo e o [README.md](README.md) atualizados** sempre que uma
  mudança alterar comandos, estrutura de pastas, dependências, arquitetura, idiomas
  ou convenções. O CLAUDE.md guarda as regras detalhadas; o README, a visão geral
  para pessoas.
- `make analyze` e `make test` devem passar antes de concluir qualquer mudança.

## Arquitetura

Seguimos a [arquitetura recomendada pelo Flutter](https://docs.flutter.dev/app-architecture/guide)
(MVVM em camadas). Siga-a à risca: cada classe pertence a **uma** camada e só
conversa com a camada imediatamente abaixo.

```
View  ──▶  ViewModel  ──▶  Repository  ──▶  Service
(UI)       (estado e      (fonte da        (acesso cru a
            lógica da      verdade dos      banco, disco,
            tela)          dados)           rede, plugins)
```

| Camada | O que faz | O que **não** pode fazer |
|---|---|---|
| **View** (`ui/<feature>/widgets/`) | Monta widgets a partir do estado do ViewModel; repassa eventos (toques, textos) para o ViewModel. | Ter regra de negócio, chamar Repository/Service, formatar ou calcular dados além do necessário para exibir. |
| **ViewModel** (`ui/<feature>/view_models/`) | Estende `ChangeNotifier`; guarda o estado da tela; expõe comandos (métodos) que a View chama; usa Repositories. | Importar `package:flutter/material.dart` ou widgets, receber `BuildContext`, acessar Services diretamente. Só `package:flutter/foundation.dart`. |
| **Repository** (`data/repositories/`) | Única fonte da verdade de um tipo de dado; converte dados crus em modelos de domínio; cache, retentativas. | Conhecer UI ou ViewModels; depender de outro Repository. |
| **Service** (`data/services/`) | Encapsula uma fonte externa (SQLite, `shared_preferences`, HTTP, plugins). Sem estado e sem regra. | Ter lógica de negócio. |
| **Modelos de domínio** (`domain/models/`) | Classes imutáveis em Dart puro (sem Flutter) que representam conceitos do app (transação, conta, categoria). | Depender de qualquer outra camada. |

Regras adicionais:

- **Injeção de dependência** com o pacote [`provider`](https://pub.dev/packages/provider):
  Services e Repositories são criados uma vez em `config/dependencies.dart`
  (`createDependencies`); `providersFor` recebe os Repositories para que os
  testes passem versões falsas.
- **ViewModels de tela** são criados na rota ([lib/routing/router.dart](lib/routing/router.dart))
  e entregues à tela pelo construtor (`SettingsScreen(viewModel: ...)`).
  **ViewModels de estado global** (hoje só `SettingsViewModel`, porque o idioma
  afeta o app inteiro) são registrados em `config/dependencies.dart`, carregados
  antes do `runApp` e lidos pela rota com `context.read()`.
- Tela sem estado (ex.: `HomeScreen` hoje) não precisa de ViewModel; ganha um
  assim que tiver dados ou ações.
- A View escuta o ViewModel com `ListenableBuilder` (ou `context.watch` no
  `app.dart`) e chama seus métodos; nunca altera campos dele diretamente.
- **Erros** atravessam as camadas como `Result<T>` ([lib/utils/result.dart](lib/utils/result.dart):
  `Ok` ou `Failure`), nunca como exceção solta até a UI. Services lançam
  exceções; Repositories as capturam e devolvem `Failure`.
- **Dinheiro** é sempre `int` em centavos nos modelos e cálculos; nunca `double`
  (que acumula erros de arredondamento). Só vira texto na View, via `BrFormat`.
- Imports sempre no formato `package:shadow_finances/...`, nunca relativos
  (exceto testes importando `test/fakes/`).
- **Casos de uso** (`domain/use_cases/`) só quando uma lógica combinar vários
  Repositories ou for reutilizada por vários ViewModels. Não crie por padrão.
- Organização **por funcionalidade** dentro de `ui/` (ex.: `ui/transactions/`,
  `ui/settings/`); `data/` e `domain/` são compartilhados.
- Testes espelham `lib/` em `test/`. ViewModels e Repositories têm testes de
  unidade usando implementações falsas (`test/fakes/`) das camadas abaixo.

### Estrutura de pastas

```
lib/
  main.dart                 # só inicializa dependências e chama runApp
  app.dart                  # MaterialApp: tema, idiomas, rotas
  config/dependencies.dart  # registro dos providers
  routing/                  # rotas do app
  domain/models/            # modelos imutáveis em Dart puro
  data/
    repositories/           # fonte da verdade (interface abstrata + implementação)
    services/               # acesso a fontes externas
  ui/
    core/
      themes/               # ThemeData, ColorScheme, extensões de tema, espaçamentos
      layout/               # tamanhos de janela (responsividade)
      formatting/           # formatação de moeda, números e datas
      l10n/                 # ponte entre idiomas do domínio e Locale do Flutter
      widgets/              # componentes reutilizáveis entre features
    <feature>/
      view_models/
      widgets/              # telas e componentes específicos da feature
  l10n/                     # arquivos .arb de tradução (+ código gerado)
  utils/                    # Result, helpers puros
test/                       # espelha lib/
```

Estado atual (exemplo de referência para novas features):

```
lib/
  main.dart, app.dart
  config/dependencies.dart
  routing/routes.dart, routing/router.dart
  domain/models/app_language.dart            # idiomas e regra de escolha
  data/services/shared_preferences_service.dart
  data/repositories/settings/
    settings_repository.dart                 # interface abstrata
    settings_repository_local.dart           # implementação
  ui/core/
    themes/app_theme.dart, app_spacing.dart
    layout/window_size_class.dart
    formatting/br_format.dart
    l10n/app_language_locale.dart            # AppLanguage ↔ Locale do Flutter
    widgets/page_body.dart
  ui/home/widgets/home_screen.dart
  ui/settings/view_models/settings_view_model.dart
  ui/settings/widgets/settings_screen.dart
  l10n/app_*.arb
  utils/result.dart
test/
  fakes/                                     # Repositories e Services falsos
  ...                                        # espelha lib/
```

## Convenções de UI

### Responsividade e medidas

- Componentes devem funcionar de telas pequenas a tablets e na web. Prefira
  layouts que se adaptam ao espaço disponível: `Expanded`, `Flexible`, `Wrap`,
  `FractionallySizedBox`, `AspectRatio`, `LayoutBuilder`.
- **Evite medidas fixas** (`width: 320`, `height: 48`). Quando um tamanho precisar
  depender da tela, use proporções do espaço disponível (`LayoutBuilder` /
  `MediaQuery.sizeOf(context)`), nunca números mágicos.
- Adapte o layout pelos **tamanhos de janela do Material 3** (compact < 600,
  medium 600–840, expanded ≥ 840 dp de largura) usando `WindowSizeClass.of(context)`
  ([lib/ui/core/layout/window_size_class.dart](lib/ui/core/layout/window_size_class.dart)),
  nunca comparando larguras soltas pelo código.
- Toda tela usa `PageBody` como corpo: ele respeita as áreas seguras e limita a
  largura do conteúdo em telas grandes.
- Espaçamentos e raios vêm de `AppSpacing.of(context)` (`xs`, `sm`, `md`, `lg`,
  `xl`, `radius`), nunca de literais nos widgets. Precisa de um valor novo?
  Adicione-o à escala em [lib/ui/core/themes/app_spacing.dart](lib/ui/core/themes/app_spacing.dart).
- Não fixe altura de nada que contenha texto: o texto deve poder crescer com a
  escala de fonte de acessibilidade do sistema.

### Cores e tipografia

- Cores **sempre** do tema: `Theme.of(context).colorScheme` (gerado por
  `ColorScheme.fromSeed` em [lib/ui/core/themes/app_theme.dart](lib/ui/core/themes/app_theme.dart),
  o único lugar com uma cor escrita: a semente). Proibido `Colors.xxx`,
  `Color(0x...)` ou opacidades fixas em widgets.
- Cores semânticas que o Material não tem (ex.: receita/despesa) são definidas
  numa `ThemeExtension` com variantes clara e escura, derivadas do esquema.
- Tipografia via `Theme.of(context).textTheme`; não fixe `fontSize`.
- Tema claro e escuro suportados desde o início; teste as telas nos dois.

### Reusabilidade

- Antes de criar um widget, procure em `ui/core/widgets/` algo que sirva.
- Se um padrão visual aparece em dois lugares, extraia para um componente em
  `ui/core/widgets/` (ou em `ui/<feature>/widgets/` se for só daquela feature).
- Componentes recebem dados e callbacks por parâmetro; não acessam ViewModels
  por conta própria. Só a tela (widget raiz da feature) conhece o ViewModel.
- Prefira compor widgets pequenos a criar widgets grandes com muitos `if`.

## Internacionalização (i18n)

Nenhum texto visível ao usuário fica escrito direto no código: todos vêm de
`AppLocalizations.of(context)` (`import 'package:shadow_finances/l10n/app_localizations.dart'`),
gerado pelo `flutter gen-l10n` (pacotes `flutter_localizations` + `intl`) a partir
dos `.arb` em `lib/l10n/`, conforme [l10n.yaml](l10n.yaml). Os arquivos
`lib/l10n/app_localizations*.dart` são gerados e ignorados pelo git; são recriados
por `make deps`, `make test`, `make run-*` ou `make l10n`.

Para adicionar um texto: crie a chave em `app_pt.arb` com `@chave.description`,
traduza em `app_es.arb`, `app_en.arb` e `app_fr.arb` (e em `app_pt_PT.arb` só se
o português de Portugal for diferente), rode `make l10n` e use
`AppLocalizations.of(context).chave`. O teste [test/l10n/arb_files_test.dart](test/l10n/arb_files_test.dart)
falha se alguma tradução faltar.

| Idioma | Locale | Arquivo |
|---|---|---|
| Português (Brasil) — **padrão e template** | `pt_BR` | `app_pt.arb` |
| Português (Portugal) | `pt_PT` | `app_pt_PT.arb` (só o que difere do pt-BR) |
| Espanhol (América Latina) | `es_419` | `app_es.arb` |
| Inglês (EUA) | `en_US` | `app_en.arb` |
| Francês | `fr` | `app_fr.arb` |

- `app_pt.arb` é o template: toda chave nova nasce nele, com descrição
  (`@chave`), e deve ser adicionada a todos os outros arquivos na mesma mudança.
- Plurais e variáveis usam a sintaxe ICU dos `.arb`, não concatenação de strings.
- **Moeda, números e datas seguem sempre o padrão brasileiro**, independente do
  idioma da interface, porque o app é voltado a residentes no Brasil: em inglês
  o usuário continua vendo `R$ 1.234,56` e `21/10/2026`. Use sempre `BrFormat`
  ([lib/ui/core/formatting/br_format.dart](lib/ui/core/formatting/br_format.dart):
  `currency(centavos)`, `number`, `date`, `time`); nunca crie `NumberFormat` ou
  `DateFormat` nos widgets, nem concatene símbolos e separadores manualmente.
  Formatos com nome de mês ou dia da semana (que dependem do idioma) devem ser
  discutidos antes de serem adicionados.
- **Escolha do idioma:** na primeira execução o app segue o idioma do
  dispositivo. A resolução é: idioma + país exatos → mesmo idioma (pt de
  qualquer país sem ser `PT` → pt-BR; qualquer espanhol → es-419) → **pt-BR** se o
  idioma do dispositivo não for suportado.
- A regra de escolha fica em `AppLanguage.resolve` ([lib/domain/models/app_language.dart](lib/domain/models/app_language.dart)),
  usada pelo `MaterialApp` através de `resolveAppLocale`.
- O usuário pode trocar o idioma em Configurações; a escolha (ou "usar idioma do
  dispositivo", que é `null`) é salva pelo `SettingsRepository` com
  `shared_preferences` e aplicada via `MaterialApp.locale`.
- Exceções que não são traduzidas: o nome "Shadow Finances" (marca) e os nomes
  dos idiomas na tela de escolha, que aparecem escritos no próprio idioma
  (`AppLanguage.nativeName`), para que qualquer pessoa reconheça o seu.
