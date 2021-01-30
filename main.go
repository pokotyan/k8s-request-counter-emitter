package main

import (
	"context"
	"fmt"
	"github.com/go-redis/redis/v8"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var (
	ctx = context.Background()
	rdb *redis.Client
)

func init() {
	rdb = redis.NewClient(&redis.Options{
		Addr: "redis-service:6379",
	})
}

func publish(w http.ResponseWriter, r *http.Request) {
	if err := rdb.Publish(ctx, "EXEC_API", os.Getenv("POD_NAME")).Err(); err != nil {
		fmt.Println(err)
	}
}

func main ()  {
	mux := http.NewServeMux()
	mux.HandleFunc("/publish", publish)
	srv := &http.Server{
		Handler: mux,
	}

	go func() {
		listener, err := net.Listen("tcp", ":8080")
		if err != nil {
			log.Fatalln("failed to listen network:", err)
		}

		if err := rdb.Publish(ctx, "READY_ON", os.Getenv("POD_NAME")).Err(); err != nil {
			fmt.Println(err)
		}

		if err := srv.Serve(listener); err != http.ErrServerClosed {
			// Error starting or closing listener:
			log.Fatalln("Server closed with error:", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGTERM, os.Interrupt)
	log.Printf("SIGNAL %d received, then shutting down...\n", <-quit)

	// 死ぬ前にpublish
	if err := rdb.Publish(ctx, "SHUTDOWN", os.Getenv("POD_NAME")).Err(); err != nil {
		fmt.Println(err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		// Error from closing listeners, or context timeout:
		log.Println("Failed to gracefully shutdown:", err)
	}
	log.Println("Server shutdown")
}