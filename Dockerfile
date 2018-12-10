From openjdk:8-jdk

LABEL maintainer="Mr.V"

# sdk-tools版本，版本号在以下页面的底部获取。
# https://developer.android.com/studio/index.html
ARG SDK_TOOLS_VERSION=4333796
# build-tools版本，版本号跟项目所使用的有关。
ARG BUILD_TOOLS_VERSION=26.0.2
# platform版本，版本号跟项目设置有关。
ARG PLATFORM_VERSION=27

# 使用 /project 作为工作目录。
WORKDIR /project
# 设置ANDROID_HOME环境变量，指定Android SDK的路径。
ENV ANDROID_HOME /project/sdk
# 执行Android SDK的安装操作
RUN mkdir sdk && \
    wget http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    unzip -qd sdk sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    rm -f sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https --update) && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "build-tools;${BUILD_TOOLS_VERSION}") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "platform-tools") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "platforms;android-${PLATFORM_VERSION}") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;google;m2repository") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;android;m2repository")

# 安装后续构建的必要工具，清理缓存，预先创建known_hosts。
RUN apt-get update -y && apt-get install -y bash python3 git openssh-client && \
    rm -rf /var/lib/apt/lists/*
