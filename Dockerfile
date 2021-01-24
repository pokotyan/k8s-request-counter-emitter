FROM golang:alpine as builder

WORKDIR /app
COPY go.mod .
COPY go.sum .

RUN go mod download
COPY . .

RUN GOOS=linux GOARCH=amd64 go build -o /main

FROM alpine:3.9 as bin

COPY --from=builder /main .

ENTRYPOINT ["/main"]
EXPOSE 8080