package handlers

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestTasksHandler(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/tasks", nil)
	rec := httptest.NewRecorder()

	TasksHandler(rec, req)

	res := rec.Result()
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		t.Errorf("Expected status code 200, got %d", res.StatusCode)
	}

	body := rec.Body.String()
	if !strings.Contains(body, "tasks") {
		t.Errorf("Expected response body to contain tasks, got %s", body)
	}
}
