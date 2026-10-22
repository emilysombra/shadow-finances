export USER_UID := $(shell id -u)
export USER_GID := $(shell id -g)

COMPOSE := docker compose
RUN     := $(COMPOSE) run --rm flutter
RUN_DEV := $(COMPOSE) run --rm flutter-device

.DEFAULT_GOAL := help

.PHONY: help image deps l10n run-web run-android devices apk test analyze format format-check doctor shell clean

help: ## Lista os comandos disponíveis
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

image: ## Constrói a imagem Docker de desenvolvimento
	$(COMPOSE) build

deps: ## Instala as dependências (flutter pub get) em ./.pub-cache
	$(RUN) flutter pub get

l10n: ## Regenera as traduções a partir de lib/l10n/*.arb
	$(RUN) flutter gen-l10n

run-web: ## Roda o app no navegador em http://localhost:8080
	$(COMPOSE) run --rm --service-ports flutter \
		flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080

run-android: ## Roda o app em um dispositivo Android conectado via USB
	$(RUN_DEV) flutter run

devices: ## Lista dispositivos visíveis para o Flutter
	$(RUN_DEV) flutter devices

apk: ## Gera APK de debug em build/app/outputs/flutter-apk/
	$(RUN) flutter build apk --debug

test: ## Roda os testes
	$(RUN) flutter test

analyze: ## Análise estática
	$(RUN) flutter analyze

format: ## Formata o código
	$(RUN) dart format lib test

format-check: ## Verifica formatação sem alterar arquivos
	$(RUN) dart format --output=none --set-exit-if-changed lib test

doctor: ## Diagnóstico do ambiente Flutter
	$(RUN) flutter doctor -v

shell: ## Abre um shell dentro do container
	$(RUN) bash

clean: ## Remove artefatos de build
	$(RUN) flutter clean
