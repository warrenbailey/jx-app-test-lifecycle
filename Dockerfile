FROM alpine:3.9

RUN apk --update add ca-certificates

COPY ./build/jx-app-test-lifecycle /jx-app-test-lifecycle

EXPOSE 8080
ENTRYPOINT ["/jx-app-test-lifecycle"]

