# qutebrowser config for the deck.
#
# This file exists for one setting. Everything else qutebrowser does out of the
# box is already right for this machine, and `config.load_autoconfig(True)`
# below keeps whatever gets set interactively with `:set`.

config.load_autoconfig(True)

# PINCH ZOOM OFF.
#
# Measured on the panel 2026-09-29: two or three contacts anywhere on the glass
# are taken as a pinch by QtWebEngine long before anything else gets a chance to
# read them as a swipe, and the fingers have to stay almost exactly parallel not
# to trigger it. The result was that every attempt at a multi-finger gesture
# zoomed the page instead, and the zoom then had to be undone by hand on a
# machine with no mouse.
#
# Deliberate zoom is not lost, it just moves to the keyboard and the menu:
# `+` and `-`, or `:zoom 150`, or `:zoom` to reset. That is the right trade here
# because accidental zoom costs a recovery every time and deliberate zoom on a
# 1280x800 panel is rare.
#
# qt.args takes Chromium switches WITHOUT the leading dashes (configdata.yml:
# "Additional arguments to pass to Qt, without leading `--`"), so this is
# Chromium's --disable-pinch. It needs a restart of qutebrowser, not a reload.
c.qt.args = ['disable-pinch']

# Every new tab lands on the launcher page (bin/58-landing-page.sh). On a deck
# where the browser is often the only thing open, an empty new tab is a dead end
# and a page listing every local service, app and ZIM is not.
c.url.start_pages = ['http://127.0.0.1:8000']
c.url.default_page = 'http://127.0.0.1:8000'
