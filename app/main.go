package main

import (
	"log"
	"net/http"

	"github.com/paul-benetis/devops-toolkit/app/handlers"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", handlers.HealthHandler)
	mux.HandleFunc("/tasks", handlers.TasksHandler)

	log.Println("Starting server on :8080...")
	if err := http.ListenAndServe(":8080", mux); err != nil {
		log.Fatalf("Server failed: %s", err)
	}
}
