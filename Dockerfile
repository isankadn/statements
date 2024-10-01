# Use the official Rust image as the base image
FROM rust:1.78 AS builder

# Set the working directory
WORKDIR /usr/src/statements

# Copy the Cargo.toml and Cargo.lock files
COPY Cargo.toml Cargo.lock ./

# Create an empty main.rs file and compile the dependencies for caching
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -f target/release/deps/statements*

# Copy the source code
COPY . .

# Install cargo-watch for auto-reload
RUN cargo install cargo-watch

# Build the application
RUN cargo build --release

# Use a smaller runtime image
FROM debian:buster-slim

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /usr/src/statements

# Copy the binary from the builder stage
COPY --from=builder /usr/src/statements/target/release/statements_archive /usr/local/bin/statements_archive

# Expose the port the application runs on
EXPOSE 8080

# Set the environment variable to development for auto-reload
ENV RUST_LOG=debug
ENV RUST_ENV=development

# Command to run the application with auto-reload using cargo-watch
CMD ["cargo", "watch", "-x", "run"]
