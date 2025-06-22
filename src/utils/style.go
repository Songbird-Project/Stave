package utils

import "github.com/charmbracelet/lipgloss"

type Style struct {
	Border    lipgloss.Border
	BorderCol lipgloss.Color
	FgCol     lipgloss.Color
	BgCol     lipgloss.Color
}

func GetStyle(config Config) (style *Style) {
	style = &Style{
		Border:    stringToBorder(config.General.Border),
		BorderCol: lipgloss.Color(config.Color.Border),
		FgCol:     lipgloss.Color(config.Color.Fg),
		BgCol:     lipgloss.Color(config.Color.Bg),
	}

	return
}

func stringToBorder(str string) (border lipgloss.Border) {

	switch str {
	case "rounded":
		border = lipgloss.RoundedBorder()
	case "double":
		border = lipgloss.DoubleBorder()
	case "block":
		border = lipgloss.BlockBorder()
	case "ascii":
		border = lipgloss.ASCIIBorder()
	case "none":
		border = lipgloss.HiddenBorder()
	case "thick":
		border = lipgloss.ThickBorder()
	default:
		border = lipgloss.NormalBorder()
	}

	return
}
