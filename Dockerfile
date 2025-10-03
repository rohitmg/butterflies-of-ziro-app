# Base image: pinned Flutter version for reproducible builds.
# This image includes Flutter, Dart SDK, and the Android SDK.
FROM ghcr.io/cirruslabs/flutter:3.35.4

# Switch to the root user to perform system-level installs
USER root
WORKDIR /app

# Install essential build tools needed by Flutter/Gradle
RUN apt-get update && apt-get install -y \
    unzip zip curl xz-utils pkg-config libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Configure environment variables for Android SDK and Gradle
ENV ANDROID_SDK_ROOT=/opt/android-sdk-linux
ENV GRADLE_USER_HOME=/root/.gradle
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools

# Accept the Android SDK licenses. This is a crucial step for Android builds.
RUN yes | flutter doctor --android-licenses

# --- Dependency caching step ---
# Copy only pubspec files first to leverage Docker's caching mechanism.
# This is an excellent optimization for CI/CD pipelines.
COPY pubspec.* ./
RUN flutter pub get

# --- Source code ---
# Copy the rest of the project source code into the container.
COPY . .

# Ensure google-services.json is copied if it exists in the local project.
# COPY android/app/google-services.json android/app/google-services.json

# Apply Gradle performance optimizations. These flags can speed up builds.
RUN echo "org.gradle.jvmargs=-Xmx4g -Dfile.encoding=UTF-8" >> android/gradle.properties \
    && echo "org.gradle.daemon=true" >> android/gradle.properties \
    && echo "org.gradle.parallel=true" >> android/gradle.properties \
    && echo "org.gradle.configureondemand=true" >> android/gradle.properties \
    && echo "android.builder.sdkDownload=true" >> android/gradle.properties

# A useful default command. This can be overridden when running the container.
CMD ["flutter", "build", "apk", "--debug"]