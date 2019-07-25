FROM ubuntu:16.04

# sdk-tools版本，版本号在以下页面的底部获取。
# https://developer.android.com/studio/index.html
# 下载地址 http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip
ARG SDK_TOOLS_VERSION=4333796
# build-tools版本，版本号跟项目所使用的有关。
ARG ANDROID_BUILD_TOOLS_VERSION=26.0.2
# platform版本，版本号跟项目设置有关。
ARG ANDROID_VERSION=27

# 使用 /home/gitlab-runner 作为工作目录。
WORKDIR /home/gitlab-runner
# 设置ANDROID_HOME环境变量，指定Android SDK的路径。
ENV USER_NAME=gitlab-runner
ENV ANDROID_HOME /home/gitlab-runner/sdk
ENV HOME=/home/gitlab-runner
ENV GRADLE_USER_HOME /home/gitlab-runner/.gradle

COPY docker-entrypoint.sh /

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get -y install sudo vim && \
    sudo apt-get -y install curl unzip && \
    apt-get -y install openjdk-8-jdk && \
    chmod ug+x /docker-entrypoint.sh && \
    chmod -R g+rw /etc/passwd && \
    mkdir -p ${ANDROID_HOME} && \
    curl -o sdk-tools.zip http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    unzip -qd sdk sdk-tools.zip && \
    rm -f sdk-tools.zip && \
    (yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses) && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https --update && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "platform-tools" && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "platforms;android-${ANDROID_VERSION}" && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "extras;google;m2repository" && \
    $ANDROID_HOME/tools/bin/sdkmanager --no_https "extras;android;m2repository" && \
    sudo curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash && \
    sudo apt-get -y install --fix-missing gitlab-runner

# 安装后续构建的必要工具，清理缓存。
RUN apt-get update && apt-get install -y bash python3 git openssh-client && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

USER ${USER_NAME}

VOLUME ["/home/gitlab-runner", "/root/.gradle"]
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["gitlab-runner", "run", "--working-directory=/home/gitlab-runner"]
