# Shadow Finances

Aplicativo mobile de finanças pessoais em Flutter (Material Design 3).

## Como rodar

Pré-requisitos: Docker com Compose e `make`. Nada de Flutter/Android SDK no host.

```sh
make image    # constrói o ambiente (primeira vez)
make deps     # instala dependências
make run-web  # abre em http://localhost:8080
make apk      # gera APK de debug
make help     # todos os comandos
```

## Idiomas

Português (Brasil), Português (Portugal), Espanhol (América Latina), Inglês (EUA)
e Francês. O app usa o idioma do dispositivo na primeira execução (pt-BR se o
idioma não for suportado) e permite trocá-lo nas configurações. As traduções
ficam em `lib/l10n/*.arb` (depois de editá-las, `make l10n` regenera o código).

Como o app é voltado a residentes no Brasil, **moeda, números e datas seguem
sempre o padrão brasileiro** (`R$ 1.234,56`, `21/10/2026`), seja qual for o idioma.

## Arquitetura

Segue a [arquitetura recomendada pelo Flutter](https://docs.flutter.dev/app-architecture/guide),
com camadas separadas:

- **View** — widgets que só desenham a tela;
- **ViewModel** — estado e lógica de cada tela;
- **Repository** — fonte da verdade dos dados;
- **Service** — acesso a banco, disco, rede e plugins.

## Princípios de interface

- Layouts responsivos, com medidas relativas ao espaço disponível;
- Componentes reutilizáveis em `lib/ui/core/widgets/`;
- Cores e tipografia sempre do tema (claro e escuro).

Regras detalhadas, estrutura de pastas e detalhes do ambiente em [CLAUDE.md](CLAUDE.md).
