mod build;
mod components;
mod config;
mod pages;
mod utils;

use std::{io, str::FromStr};

use color_eyre::{eyre::Ok, Result};
use config::Config;
use crossterm::{
    event::{
        self, EnableMouseCapture, Event, KeyCode, KeyEvent, KeyEventKind, KeyEventState,
        KeyModifiers,
    },
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen},
};
use pages::users::{active, inactive};
use ratatui::{
    layout::{self, Constraint, Layout},
    style::{Color, Style},
    widgets::{Block, BorderType, Borders, Tabs},
    DefaultTerminal, Frame,
};
use tui_textarea::{Input, Key, TextArea};
use utils::{down, render_page, up};

fn main() -> Result<()> {
    color_eyre::install()?;
    let terminal = ratatui::init();
    let app_result = App::default().run(terminal);
    disable_raw_mode()?;
    ratatui::restore();
    app_result
}

#[derive(Default)]
struct App<'a> {
    tab: usize,
    input: bool,
    fields: Vec<TextArea<'a>>,
    config: Config,
}

impl<'a> App<'a> {
    fn run(&mut self, mut terminal: DefaultTerminal) -> Result<()> {
        let mut idx = 0;
        enable_raw_mode()?;

        loop {
            terminal.draw(|frame| self.draw(frame))?;

            if self.input {
                match event::read()?.into() {
                    Input { key: Key::Esc, .. } => {
                        self.input = false;
                    }
                    Input { key: Key::Tab, .. }
                    | Input {
                        key: Key::Enter, ..
                    } => {
                        inactive(&mut self.fields[idx], &self.config);
                        idx = (idx + 1) % 2;
                        active(&mut self.fields[idx], &self.config);
                    }
                    Input {
                        key: Key::Char('q'),
                        ctrl: true,
                        ..
                    } => return Ok(()),
                    input => {
                        self.fields[idx].input(input);
                        if idx == 0 {}
                    }
                }
            } else if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press && !self.input {
                    match key.code {
                        KeyCode::Esc | KeyCode::Char('q') => return Ok(()),
                        KeyCode::Tab => {
                            self.tab += up(self.tab, 2);
                        }
                        KeyCode::BackTab => {
                            self.tab -= down(self.tab);
                        }
                        _ => {}
                    }
                }
                if key.modifiers.contains(KeyModifiers::CONTROL) {
                    match key.code {
                        KeyCode::Char('q') => return Ok(()),
                        _ => {}
                    }
                }
            }
        }
    }

    fn draw(&mut self, frame: &mut Frame) {
        let config = Config::get();
        self.config = config.clone();

        let pages = Tabs::new(config.general.tabs.clone())
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .border_type(BorderType::Rounded)
                    .border_style(
                        Style::default()
                            .fg(Color::from_str(&config.colors.border).expect("Invalid color!")),
                    ),
            )
            .style(
                Style::default()
                    .fg(Color::from_str(&config.colors.inactive_text).expect("Invalid color!"))
                    .bg(Color::from_str(&config.colors.inactive_text_bg).expect("Invalid color!")),
            )
            .highlight_style(
                Style::default()
                    .fg(Color::from_str(&config.colors.active_text).expect("Invalid color!"))
                    .bg(Color::from_str(&config.colors.active_text_bg).expect("Invalid color!")),
            )
            .divider(config.general.tab_spacer.clone())
            .select(self.tab);

        let layout = Layout::new(
            layout::Direction::Vertical,
            vec![Constraint::Min(3), Constraint::Percentage(100)],
        )
        .spacing(0)
        .split(frame.area());

        frame.render_widget(pages, layout[0]);
        render_page(
            config.general.tabs[self.tab].clone(),
            frame,
            layout[1],
            config,
            self,
        );
    }
}
