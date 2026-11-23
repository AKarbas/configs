rex.bind("cmd+k", "com.superlogical.terminal.clear")
rex.bind("shift+cmd+k", "session.switch")

-- Ghostty
rex.bind("ctrl+alt+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+alt+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+alt+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+alt+l", "pane.focus", { direction = "right" })
rex.bind("ctrl+cmd+h", "pane.resize", { direction = "left" })
rex.bind("ctrl+cmd+j", "pane.resize", { direction = "down" })
rex.bind("ctrl+cmd+k", "pane.resize", { direction = "up" })
rex.bind("ctrl+cmd+l", "pane.resize", { direction = "right" })

-- iTerm2
rex.bind("shift+enter", "pane.send_key", { key = "ctrl+j" })
