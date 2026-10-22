# Ambiente de desenvolvimento Flutter + Android SDK com versões fixadas.
# Toda ferramenta do projeto (flutter, dart, gradle, adb) roda a partir desta imagem.
FROM eclipse-temurin:17-jdk-noble

ARG FLUTTER_VERSION=3.47.7
ARG ANDROID_CMDLINE_TOOLS=16111833
ARG ANDROID_PLATFORM=android-36
ARG ANDROID_BUILD_TOOLS=36.0.0
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    FLUTTER_HOME=/opt/flutter \
    FLUTTER_SUPPRESS_ANALYTICS=true \
    PUB_CACHE=/home/dev/.pub-cache \
    GRADLE_USER_HOME=/home/dev/.gradle
ENV PATH=${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash ca-certificates curl git unzip xz-utils zip libglu1-mesa usbutils make \
    && rm -rf /var/lib/apt/lists/*

# Usuário não-root com o mesmo UID/GID do host, para que os arquivos gerados
# no volume montado pertençam ao usuário local.
RUN (getent passwd ${USER_UID} | cut -d: -f1 | xargs -r userdel -r) \
    && (getent group ${USER_GID} | cut -d: -f1 | xargs -r groupdel) \
    && groupadd -g ${USER_GID} dev \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash dev \
    && groupadd -f plugdev && usermod -aG plugdev dev \
    && mkdir -p ${ANDROID_HOME} ${FLUTTER_HOME} /app \
    && chown -R dev:dev ${ANDROID_HOME} ${FLUTTER_HOME} /app

USER dev

# Android SDK
RUN curl -fsSL -o /tmp/cmdline-tools.zip \
        https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip \
    && yes | sdkmanager --licenses > /dev/null \
    && sdkmanager --install "platform-tools" "platforms;${ANDROID_PLATFORM}" "build-tools;${ANDROID_BUILD_TOOLS}" > /dev/null

# Flutter SDK fixado na tag exata
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter config --no-analytics --no-cli-animations \
        --no-enable-linux-desktop --no-enable-macos-desktop --no-enable-windows-desktop \
    && dart --disable-analytics \
    && flutter precache --android --web --no-ios \
    && yes | flutter doctor --android-licenses > /dev/null

# Pré-aquece Gradle, NDK e plataformas exigidas pelo template desta versão do
# Flutter, para que builds do projeto não dependam de downloads em tempo de execução.
RUN cd /tmp \
    && flutter create --platforms android warmup > /dev/null \
    && cd warmup && flutter build apk --debug \
    && cd / && rm -rf /tmp/warmup

WORKDIR /app
