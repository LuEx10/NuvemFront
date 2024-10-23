# Stage 1: Build the Flutter application
FROM ubuntu:22.04 AS builder

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up Flutter environment
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz \
    && tar xf flutter_linux_3.24.3-stable.tar.xz -C /usr/local/ \
    && rm flutter_linux_3.24.3-stable.tar.xz \
    && flutter doctor \
    && flutter config --no-analytics \
    && flutter config --enable-web

# Download and setup Flutter SDK
#RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME && \
#    cd $FLUTTER_HOME && \
#    git checkout 3.24.3 && \
#    flutter doctor && \
#    flutter config --no-analytics && \
#    flutter config --enable-web

# Set the working directory
WORKDIR /app

# Copy the Flutter project files
COPY . .

# Get Flutter dependencies
RUN flutter pub get

# Build for web
RUN flutter build web --release

# Stage 2: Serve the application using Nginx
FROM nginx:alpine

# Copy the built Flutter web app to Nginx's serve directory
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
