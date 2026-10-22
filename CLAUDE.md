# Shadow Finances

Aplicativo mobile de finanças pessoais em Flutter, com Material Design 3 como base visual.
**Código aberto** sob a GPL-3.0 ([LICENSE](LICENSE)): tudo o que entra no git é
público. Veja [Código aberto e segurança](#código-aberto-e-segurança).

## Ambiente

Nada de Flutter/Dart/Android SDK é instalado no host. Todo comando roda dentro do
container definido em [docker/Dockerfile](docker/Dockerfile) via `make` (que usa
`docker compose run`). Versões fixadas na imagem:

- Flutter 3.47.7 (Dart 3.13.5), JDK 17, Android SDK platform 36 / build-tools 36.0.0

Dependências do pub ficam em `./.pub-cache` (dentro do projeto, ignorado pelo git);
o cache do Gradle fica no volume nomeado `gradle-cache`. O `pubspec.lock` é
versionado para garantir builds idênticas.

Para mudar a versão do Flutter, altere `FLUTTER_VERSION` e `FLUTTER_COMMIT` no
Dockerfile **e** a tag `image:` em [compose.yaml](compose.yaml), depois rode
`make image` (como conferir os hashes está em [Código aberto e segurança](#código-aberto-e-segurança)).

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
- **O código é aberto.** Antes de concluir qualquer mudança, confira as regras
  de [Código aberto e segurança](#código-aberto-e-segurança): nada de segredos,
  dados pessoais ou dados do usuário saindo do dispositivo.

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
  **ViewModels de estado global** (hoje só `SettingsViewModel`, porque idioma e
  tema afetam o app inteiro) são registrados em `config/dependencies.dart`, carregados
  antes do `runApp` e lidos pela rota com `context.read()`.
- Tela sem estado não precisa de ViewModel; ganha um assim que tiver dados ou
  ações (como a `HomeScreen`, que ganhou o `HomeViewModel` ao exibir o resumo).
  Um ViewModel pode usar vários Repositories (o `HomeViewModel` usa contas,
  receitas e despesas); se essa combinação passar a ser usada por outro
  ViewModel, extraia-a para um caso de uso.
- Enquanto uma funcionalidade não tem dados reais, use uma implementação
  provisória do Repository com valores fixos (sufixo `Static`, ex.:
  `ExpenseRepositoryStatic`), registrada em `config/dependencies.dart`.
  ViewModel e View já nascem prontos; depois só a implementação é trocada.
- A View escuta o ViewModel com `ListenableBuilder` (ou `context.watch` no
  `app.dart`) e chama seus métodos; nunca altera campos dele diretamente.
- **Erros** atravessam as camadas como `Result<T>` ([lib/utils/result.dart](lib/utils/result.dart):
  `Ok` ou `Failure`), nunca como exceção solta até a UI. Services lançam
  exceções; Repositories as capturam e devolvem `Failure`.
- **Dinheiro** é sempre `int` em centavos nos modelos e cálculos; nunca `double`
  (que acumula erros de arredondamento). Só vira texto na View, via `BrFormat`.
- **Modelo financeiro** (em `domain/models/`):
  - `Transaction` é `sealed`, com dois subtipos: `Expense` (saída) e `Income`
    (entrada). Valores são sempre positivos; o tipo diz o sentido. Use
    `switch` sobre a transação para que o compilador exija tratar os dois.
  - **Toda transação pertence a uma conta** (`accountId`, obrigatório na
    classe base). Ao criar uma sem conta escolhida, use a principal:
    `AccountRepository.getMainAccount()` (a conta com `isMain`, que existe
    exatamente uma). Por ora o usuário tem só essa conta.
  - O saldo inicial de uma conta (opcional) entra como receita
    `Income.initialBalance`, da categoria `IncomeCategory.initialBalance`. Sem
    saldo inicial, nenhuma receita é criada.
  - **Totais são mantidos, nunca recalculados.** Cada conta tem seus totais
    de receitas e despesas (`AccountBalance.totals`, um `FinancialSummary`),
    guardados pelo `AccountRepository` junto com a conta. Ao gravar, editar ou
    excluir uma transação, o Repository aplica só a diferença
    (`AccountBalance.add` / `remove`; editar = `remove(antiga).add(nova)`) na
    mesma operação que grava a transação.
  - Quem precisa de totais (o card da tela inicial, futuras telas de conta)
    usa esses totais guardados: o total geral é `FinancialSummary.sum` dos
    totais das contas. **Nunca some a lista de transações para exibir
    totais.** `FinancialSummary.of(transações)` existe só para conferência
    (testes) e migração de dados.
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
  domain/models/app_theme_mode.dart          # temas que o usuário pode escolher
  domain/models/transaction.dart             # Transaction (sealed): Expense e Income
  domain/models/expense_category.dart        # categorias de despesa
  domain/models/income_category.dart         # categorias de receita (inclui saldo inicial)
  domain/models/account.dart                 # conta (id, nome, se é a principal)
  domain/models/account_balance.dart         # conta + totais guardados e saldo
  domain/models/financial_summary.dart       # totais de receitas e despesas, saldo
  data/services/shared_preferences_service.dart
  data/repositories/account/
    account_repository.dart                  # interface abstrata
    account_repository_static.dart           # a única conta e seus totais (provisório)
  data/repositories/expense/
    expense_repository.dart                  # interface abstrata
    expense_repository_static.dart           # despesas fictícias (provisório)
  data/repositories/income/
    income_repository.dart                   # interface abstrata
    income_repository_static.dart            # receitas fictícias (provisório)
  data/repositories/settings/
    settings_repository.dart                 # interface abstrata
    settings_repository_local.dart           # implementação
  ui/core/
    themes/app_theme.dart, app_spacing.dart
    themes/app_theme_mode_flutter.dart       # AppThemeMode ↔ ThemeMode do Flutter
    themes/finance_colors.dart               # cores de receita e despesa
    layout/window_size_class.dart
    formatting/br_format.dart
    l10n/app_language_locale.dart            # AppLanguage ↔ Locale do Flutter
    l10n/category_label.dart                 # nome traduzido das categorias
    widgets/page_body.dart
    widgets/section_header.dart              # título de seção em listas
    widgets/category_avatar.dart             # ícone das categorias
  ui/home/view_models/home_view_model.dart
  ui/home/widgets/home_screen.dart
  ui/home/widgets/balance_summary_card.dart  # saldo, receitas e despesas
  ui/home/widgets/transaction_list_tile.dart # uma receita ou despesa na lista
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
  o único lugar com cores escritas: as sementes). Proibido `Colors.xxx`,
  `Color(0x...)` ou opacidades fixas em widgets.
- Cores semânticas que o Material não tem são definidas numa `ThemeExtension`
  com variantes clara e escura, derivadas do esquema. Receita e despesa já
  existem em `FinanceColors.of(context)` ([lib/ui/core/themes/finance_colors.dart](lib/ui/core/themes/finance_colors.dart)):
  `income`/`expense` para texto sobre superfícies e `incomeContainer`/
  `onIncomeContainer` (e equivalentes de despesa) para blocos coloridos.
  Receita vem de uma semente verde; despesa, dos papéis de erro do esquema.
- Tipografia via `Theme.of(context).textTheme`; não fixe `fontSize`.
- Tema claro e escuro suportados desde o início; teste as telas nos dois.
- O usuário escolhe o tema em Configurações: claro, escuro ou "usar tema do
  dispositivo" (`null`, o padrão). A escolha é o enum `AppThemeMode`
  ([lib/domain/models/app_theme_mode.dart](lib/domain/models/app_theme_mode.dart)),
  salva pelo `SettingsRepository` e aplicada via `MaterialApp.themeMode`.

### Reusabilidade

- Antes de criar um widget, procure em `ui/core/widgets/` algo que sirva.
- Se um padrão visual aparece em dois lugares, extraia para um componente em
  `ui/core/widgets/` (ou em `ui/<feature>/widgets/` se for só daquela feature).
- Componentes recebem dados e callbacks por parâmetro; não acessam ViewModels
  por conta própria. Só a tela (widget raiz da feature) conhece o ViewModel.
- Prefira compor widgets pequenos a criar widgets grandes com muitos `if`.
- Listas que podem crescer (transações) usam construção preguiçosa
  (`SliverList.builder` / `ListView.builder`), nunca `children` com todos os itens.
- Teste telas novas numa largura estreita (320 dp) com fonte em 200%
  (`MediaQueryData(textScaler: TextScaler.linear(2))`): nada pode transbordar.

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

## Código aberto e segurança

O projeto é distribuído sob a **GPL-3.0** ([LICENSE](LICENSE)), com copyright
de Emily Sombra. Tudo o que entra no git, **inclusive o histórico**, é público:
apagar um arquivo num commit novo não o remove dos commits antigos.

### O que nunca vai para o repositório

- **Segredos:** senhas, tokens, chaves de API, keystores, `key.properties`,
  `.env`, `google-services.json`. Valores sensíveis entram por arquivo ignorado
  pelo git ou variável de ambiente. O [.gitignore](.gitignore) já bloqueia os
  formatos comuns; um tipo novo de credencial deve ser adicionado lá na mesma
  mudança que passar a usá-lo.
- **Dados pessoais e da máquina de quem desenvolve:** nomes de usuário,
  caminhos como `/home/...`, e-mails, dados financeiros reais em testes,
  exemplos ou capturas de tela. Use sempre dados fictícios.
- Se um segredo chegar a ser commitado, trate-o como **vazado**: revogue ou
  troque a credencial primeiro; reescrever o histórico não basta (cópias e
  forks já podem existir).

### Assinatura do Android

Builds de release assinam com a chave descrita em `android/key.properties`
(fora do git), que aponta para o keystore:

```properties
storeFile=/caminho/fora/do/repositorio/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Sem esse arquivo, o release cai na chave de debug só para que
`flutter run --release` funcione localmente. **Nunca distribua um APK assim.**

### Dados do usuário

O app lida com dados financeiros, que são sensíveis:

- Os dados ficam **só no dispositivo**. Nada de telemetria, analytics, crash
  reporting ou envio a servidores sem discussão prévia e consentimento
  explícito do usuário.
- Não registre (`print`, `debugPrint`, logs) valores, descrições de transações
  ou qualquer dado do usuário.
- Antes de começar a guardar dados financeiros (hoje só há idioma e tema),
  discuta criptografia em repouso e as regras de backup do Android
  (`android:allowBackup`, `dataExtractionRules`).
- Permissões novas no `AndroidManifest.xml` / `Info.plist` só com justificativa;
  o app hoje não pede nenhuma.

### Dependências e cadeia de build

- Só pacotes com manutenção ativa e **licença compatível com a GPL-3.0** (MIT,
  BSD, Apache-2.0, LGPL, GPL...). Pacotes sem licença ou proprietários não
  entram. Confira a licença no pub.dev antes de adicionar.
- O `flutter pub get` mostra avisos de segurança (*advisories*) das
  dependências; eles não podem ser ignorados.
- O [Dockerfile](docker/Dockerfile) verifica a integridade de tudo que baixa.
  Ao mudar uma versão, atualize também o hash correspondente:
  - `FLUTTER_COMMIT`: `git ls-remote https://github.com/flutter/flutter.git refs/tags/<versão>`.
  - `ANDROID_CMDLINE_TOOLS_SHA256`: baixe o zip, confira se o SHA-1 dele é o
    publicado pelo Google em <https://dl.google.com/android/repository/repository2-3.xml>
    e só então gere o SHA-256 com `sha256sum`.
- Serviços de desenvolvimento escutam só em `127.0.0.1` ([compose.yaml](compose.yaml)),
  para não ficarem expostos na rede local.

