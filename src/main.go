package main

import (
	"os"
	"pages"
	"time"
	"utils"

	tea "github.com/charmbracelet/bubbletea"
	log "github.com/charmbracelet/log"
)

func main() {
	logger := log.NewWithOptions(os.Stderr, log.Options{
		ReportCaller:    true,
		ReportTimestamp: true,
		TimeFormat:      time.Kitchen,
		Prefix:          "Stave",
	})

	config := utils.GetConfig()
	program := tea.NewProgram(pages.InitialModel(config), tea.WithAltScreen())
	if _, err := program.Run(); err != nil {
		logger.Fatal(err)
		os.Exit(1)
	}
}
