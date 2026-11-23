rex.bind("cmd+k", "com.superlogical.terminal.clear")
rex.bind("shift+cmd+k", "session.switch")
rex.bind("cmd+enter", "client.window.fullscreen.toggle")
rex.bind("shift+cmd+=", "pane.balance")

rex.mode("resize", { exclusive = true })
rex.bind("shift+cmd+r", "client.mode.enter", { name = "resize" })
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")

-- Ghostty
rex.bind("ctrl+alt+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+alt+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+alt+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+alt+l", "pane.focus", { direction = "right" })

-- iTerm2
rex.bind("shift+enter", "pane.send_key", { key = "ctrl+j" })
