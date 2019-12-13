ARG FROM_IMAGE=jenkins/jnlp-slave:3.35-5-alpine

FROM ${FROM_IMAGE}

USER root

ARG NODEJS_VERSION=""
ARG NPM_VERSION=""
# example NODEJS_VERSION="=12.13.1"
RUN apk add --update --no-cache bash libstdc++ libc6-compat libgc++ libgcc ncurses5-widec-libs ncurses-libs ncurses5-libs zlib wget zip unzip chromium nodejs${NODEJS_VERSION} nodejs-npm${NPM_VERSION} && rm -f /var/cache/apk/*
# example IONIC_VERSION="@5.4.12"
RUN npm install -g ionic${IONIC_VERSION} cordova${CORDOVA_VERSION}

ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ARG SDK_INSTALL_DIR="/opt/android-sdk"

RUN wget -O sdk-tools-linux.zip ${ANDROID_SDK_URL}
RUN mkdir ${SDK_INSTALL_DIR}
RUN unzip sdk-tools-linux.zip -d ${SDK_INSTALL_DIR}

ENV ANDROID_HOME=${SDK_INSTALL_DIR}
ENV ANDROID_SDK_ROOT=${SDK_INSTALL_DIR}
ENV CHROME_BIN="/usr/bin/chromium-browser"

ARG ANDROID_SDK_MANAGER=${SDK_INSTALL_DIR}/tools/bin/sdkmanager
ARG ANDROID_AVD_MANAGER=${SDK_INSTALL_DIR}/tools/bin/avdmanager

ARG ANDROID_SDK_BUILD_TOOLS_VERSION="28.0.3"
ARG ANDROID_SDK_VERSIONS="android-28"
ARG ANDROID_SDK_SYSTEM_IMAGES="system-images;android-28;google_apis;x86_64"

RUN yes | ${ANDROID_SDK_MANAGER} "build-tools;${ANDROID_SDK_BUILD_TOOLS_VERSION}"
RUN for v in ${ANDROID_SDK_VERSIONS}; do yes | ${ANDROID_SDK_MANAGER} "platforms;$v"; done
RUN for i in ${ANDROID_SDK_SYSTEM_IMAGES}; do yes | ${ANDROID_SDK_MANAGER} "$i"; done
RUN ${ANDROID_SDK_MANAGER} "emulator"
RUN ${ANDROID_SDK_MANAGER} "platform-tools"
RUN ${ANDROID_AVD_MANAGER} create avd -n API_28 -k "system-images;android-28;google_apis;x86_64" -c 1024M -f -d pixel_xl
#you can create more emulators by extending this docker file

