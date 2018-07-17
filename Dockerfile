# -
# Build statically
# -

FROM ekidd/rust-musl-builder as builder

ADD . .
RUN sudo chown -R rust:rust . && cargo update
RUN cargo build --release


# -
# Add static binary to runtime scratch image
# -

FROM scratch as runner

COPY --from=builder target/x86_64-unknown-linux-musl/release/timerunner /
EXPOSE 3000

ENTRYPOINT ["/timerunner"]
