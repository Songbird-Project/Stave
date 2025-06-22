package utils

import (
	"os"

	"github.com/BurntSushi/toml"
)

type (
	Brand struct {
		Name string `toml:"name"`
		Desc string `toml:"description"`
		Logo string `toml:"logo"`
	}

	Color struct {
		Bg     string `toml:"background"`
		Fg     string `toml:"text"`
		Border string `toml:"border"`
	}

	General struct {
		Order  []string
		Border string
	}

	Text struct {
		Bold      bool `toml:"bold"`
		Italic    bool `toml:"italic"`
		Blink     bool `toml:"blink"`
		Underline bool `toml:"underline"`
	}
)

func GetConfig() Config {
	var conf Config

	if _, err := os.Stat("/etc/stave/config.toml"); err == nil {
		toml.DecodeFile("/etc/stave/config.toml", &conf)
	} else if _, err := os.Stat("./config.toml"); err == nil && os.Getenv("STAVE_DEBUG") == "1" {
		toml.DecodeFile("./config.toml", &conf)
	} else {
		conf = getDefaultConfig()
	}

	return conf
}

func getDefaultConfig() Config {
	brand := Brand{
		Name: "SongbirdOS",
		Desc: "A perfect and elegant Arch-based, rolling release distro.",
		Logo: "",
	}
	color := Color{
		Bg:     "#cccccc",
		Border: "#aaaaaa",
		Fg:     "#ffffff",
	}
	general := General{
		Order: []string{"welcome"},
	}
	text := Text{
		Bold:      false,
		Italic:    false,
		Blink:     false,
		Underline: false,
	}

	config := Config{
		Brand:   brand,
		Color:   color,
		General: general,
		Text:    text,
	}

	return config
}
