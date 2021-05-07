#!/usr/bin/env bash
set -eo pipefail
SESSION=elm-exhibit
WINDOW=${SESSION}:0
TS_WATCH_PANE=${WINDOW}.1
EDITOR_PANE=${WINDOW}.0
tmux new -d -s $SESSION
tmux send-keys -t $SESSION "tmux split-pane -v" Enter
# Wait for tmux to create new pain
sleep 0.5
tmux select-pane -t $TS_WATCH_PANE
tmux send-keys -t $SESSION "tmux resize-pane -D 20 && yarn ts:watch" Enter
tmux select-pane -t $EDITOR_PANE
tmux send-keys -t $SESSION "nvim ." Enter
# tmux attach-session -t $SESSION

# This will return 1 if the TS_WATCH_PANE exists
# tmux list-panes -F "#D #{pane_tty}" | grep -q 1
