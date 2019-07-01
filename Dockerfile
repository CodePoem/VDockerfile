FROM openjdk:8-jdk-alpine

# sdk-tools版本，版本号在以下页面的底部获取。
# https://developer.android.com/studio/index.html
ARG SDK_TOOLS_VERSION=4333796
# build-tools版本，版本号跟项目所使用的有关。
ARG ANDROID_BUILD_TOOLS_VERSION=26.0.2
# platform版本，版本号跟项目设置有关。
ARG ANDROID_VERSION=27

# 使用 /project 作为工作目录。
WORKDIR /project
# 设置ANDROID_HOME环境变量，指定Android SDK的路径。
ENV ANDROID_HOME /project/sdk

# 执行Android SDK的下载安装操作。
RUN mkdir -p ${ANDROID_HOME} && \
    chgrp -Rf root /project && \
    chmod -Rf g+w /project && \
    wget -O sdk.zip http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    unzip -qd sdk sdk.zip && \
    rm -f sdk.zip && \
    (yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses) && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https --update && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "platform-tools" && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "platforms;android-${ANDROID_VERSION}" && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "extras;google;m2repository" && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "extras;android;m2repository"

# 挂载gradle缓存目录
VOLUME /root/.gradle

# 安装后续构建的必要工具，清理缓存。
RUN apk update -y && apk add -y bash python3 git openssh-client && \
    rm -rf /var/lib/apt/lists/*

CMD [ "echo", "Android Docker~" ]
