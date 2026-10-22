# Shadow Finances

Aplicativo mobile de finanças em Flutter (Material Design 3).

Pré-requisitos: Docker com Compose e `make`. Nada de Flutter/Android SDK no host.

```sh
make image    # constrói o ambiente (primeira vez)
make deps     # instala dependências
make run-web  # abre em http://localhost:8080
make apk      # gera APK de debug
make help     # todos os comandos
```

Detalhes do ambiente e convenções em [CLAUDE.md](CLAUDE.md).
