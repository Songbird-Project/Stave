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
	style := utils.GetStyle(config)

	program := tea.NewProgram(pages.InitialModel(config, style), tea.WithAltScreen())
	if _, err := program.Run(); err != nil {
		logger.Fatal(err)
		os.Exit(1)
	}
}
