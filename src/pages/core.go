package pages

import (
	"utils"

	tea "github.com/charmbracelet/bubbletea"
	log "github.com/charmbracelet/log"
)

type model struct {
	config utils.Config
	page   int
}

func InitialModel(config utils.Config) model {
	return model{
		config: config,
		page:   0,
	}
}

func (m model) renderPage() string {
	order := m.config.General.Order
	var page string

	if m.page > len(order) {
		log.Fatal("An invalid page index was reached. Aborting.")
	}

	switch order[m.page] {
	case "welcome":
		page = m.Welcome()
	default:
		log.Fatal("An invalid page name was found. Aborting.")
	}

	return page
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q":
			return m, tea.Quit
		}
	}

	return m, nil
}

func (m model) View() string {
	return m.renderPage()
}
