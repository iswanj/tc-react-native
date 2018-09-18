# Pull base image.
FROM ubuntu:16.04

# Install base software packages
RUN apt-get update && \
    apt-get install software-properties-common \
    python-software-properties \
    wget \
    curl \
    git \
    lftp \
    unzip -y && \
    apt-get clean


# ——————————
# Install Java.
# ——————————

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer


# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


# ——————————
# Installs i386 architecture required for running 32 bit Android tools
# ——————————

RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean


# ——————————
# Installs Android SDK
# ——————————

# ENV ANDROID_SDK_VERSION r24.4.1
ENV ANDROID_SDK_VERSION sdk-tools-linux-3859397.zip
ENV ANDROID_BUILD_TOOLS_VERSION build-tools-27.0.3,build-tools-26.0.2,build-tools-25.0.3,build-tools-25.0.2,build-tools-25.0.0,build-tools-23.0.2,build-tools-23.0.3,build-tools-23.0.1

# ENV ANDROID_SDK_FILENAME android-sdk_${ANDROID_SDK_VERSION}-linux.tgz
#ENV ANDROID_SDK_URL http://dl.google.com/android/${ANDROID_SDK_FILENAME}
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_VERSION}
ENV ANDROID_API_LEVELS android-26,android-25,android-23
ENV ANDROID_EXTRA_COMPONENTS extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
# RUN cd /opt && \
#     wget -q ${ANDROID_SDK_URL} && \
#     tar -xzf ${ANDROID_SDK_VERSION} && \
#     rm ${ANDROID_SDK_VERSION} && \
#     echo y | android update sdk --no-ui -a --filter tools,platform-tools,${ANDROID_API_LEVELS},${ANDROID_BUILD_TOOLS_VERSION} && \
#     echo y | android update sdk --no-ui --all --filter "${ANDROID_EXTRA_COMPONENTS}"
RUN cd /opt
RUN wget -q ${ANDROID_SDK_URL}
# RUN tar -xzf ${ANDROID_SDK_VERSION}
RUN unzip ${ANDROID_SDK_VERSION}
RUN rm ${ANDROID_SDK_VERSION}
RUN mkdir -p ${ANDROID_HOME}
RUN mv tools/ ${ANDROID_HOME}

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
RUN yes | sdkmanager --licenses && sdkmanager --update

RUN sdkmanager \
    "tools" \
    "platform-tools" \
    "emulator" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services"

RUN sdkmanager "build-tools;27.0.3"

RUN sdkmanager \
    "platforms;android-27" \
    "platforms;android-26" \
    "platforms;android-25"

# ——————————
# Installs Gradle
# ——————————

# Gradle
ENV GRADLE_VERSION 3.3

RUN cd /usr/lib \
 && curl -fl https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle-bin.zip \
 && unzip "gradle-bin.zip" \
 && ln -s "/usr/lib/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
 && rm "gradle-bin.zip"

# Set Appropriate Environmental Variables
ENV GRADLE_HOME /usr/lib/gradle
ENV PATH $PATH:$GRADLE_HOME/bin


# ——————————
# Install Node and global packages
# ——————————
ENV NODE_VERSION 8.11.1
RUN cd && \
    wget -q http://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz && \
    tar -xzf node-v${NODE_VERSION}-linux-x64.tar.gz && \
    mv node-v${NODE_VERSION}-linux-x64 /opt/node && \
    rm node-v${NODE_VERSION}-linux-x64.tar.gz
ENV PATH ${PATH}:/opt/node/bin

# ——————————
# Install Required apt packages
# ——————————
RUN apt-get update -y
RUN apt-get install apt-transport-https -y

# ——————————
# Install Yarn
# ——————————

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -y && apt-get install yarn -y

# ——————————
# Install Basic React-Native packages
# ——————————
RUN npm install react-native-cli -g

ENV LANG en_US.UTF-8

# ——————————
# Change container time zone
# ——————————
RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/Asia/Colombo /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
