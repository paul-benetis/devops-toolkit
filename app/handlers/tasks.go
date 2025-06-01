package handlers

import (
	"fmt"
	"net/http"
)

func TasksHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	tasks := []string{"Task 1", "Task 2", "Task 3", "Task 4", "Task 5"}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"tasks": %q}`, tasks)
}
