# tmux-picker

**tmux-picker**: Selecting and copy-pasting in terminal using Vimium-like hint mode for tmux.

![screencast](https://i.imgur.com/sz0176k.gif)

This is a slimmed-down, improved and extended fork of [tmux-fingers](https://github.com/Morantron/tmux-fingers). Check [Acknowledgements](#acknowledgements) for comparison.

# Usage

Press ( <kbd>prefix</kbd> + <kbd>F</kbd> ) to enter **[picker]** hint mode, in which relevant stuff (e.g. file paths, git SHAs) in the current
pane will be highlighted along with letter hints. By pressing those letters, the highlighted match will be copied to the system clipboard.

By default, following items are highlighted:

* File paths (that contain `/`)
* git SHAs
* numbers (4+ digits)
* hex numbers
* IP addresses
* UUIDs

You can press:

* <kbd>SPACE</kbd> to highlight additional items (everything that might be a file path, if it's longer than 4 characters).
* <kbd>ESC</kbd> to exit **[picker]** hint mode

# Installation

## Manual

* Clone the repo: `git clone https://github.com/pawel-wiejacha/tmux-picker ~/.tmux/tmux-picker`
* Add `run-shell ~/.tmux/tmux-picker/tmux-picker.tmux` to your `~/.tmux.conf`
* Reload tmux config by running: `tmux source-file ~/.tmux.conf`


## TPM

Add the following to your `.tmux.conf`: 
```
set -g @plugin 'eemed/tmux-picker'
```

Install using (<kbd>prefix</kbd> + <kbd>i</kbd>) and you should be good to go.

# Configuration

NOTE: for changes to take effect, you'll need to source again your `.tmux.conf` file.

## @picker-key

`default: F`

Customize how to enter picker mode. To use without prefix use `-n M-f`

For example:

```
set -g @picker-key '-n M-f'
```

## @picker-command

`default: xsel --clipboard -f`

By default **tmux-picker** will just yank matches to the system clipboard.

If you want to set your own custom command you can do so like this:

```
set -g @picker-command 'xclip -selection clipboard'
```

This command will also receive the copied text using `stdin`.

## @picker-uppercase-command

`default: tmux set-buffer \"\$(cat -)\"; tmux paste-buffer`

This command will also receive the copied text using `stdin`.

For example to open using `xdg-open`:

```
set -g @picker-uppercase-command 'xargs xdg-open'
```

## @picker-hint-front

`default: 1`

Whether to show hints
at the front
or back of the matched text.
By default,
hints appear at the front of matches.
To show hints at the back,
set the value to `0`.

## @picker-unmatched-format

`default: "%s"`

Highlight format of the unmatched text.
By default,
tmux-picker does not modify the unmatched format.

If you want extra contrast in the hinting,
you can dim the unmatched text with the following:

```
set -g @picker-unmatched-format "#[dim]%s"
```

# Requirements

* tmux 2.2+
* bash 4+
* gawk 4.1+ (which was released in 2013)

# Acknowledgements

It started as a fork of [tmux-fingers](https://github.com/Morantron/tmux-fingers). I would like to thank to [Morantron](https://github.com/Morantron) (the tmux-fingers author) for a really good piece of code!

My main problem with tmux-fingers was that it did not support terminal colors (it strips them down). I have fancy powerline prompt, colored `ls`, zsh syntax highlighting, colored git output, etc. So after entering tmux-fingers hint mode it was like *'WTF? Where are all my colors? Where am I? Where's the item I want to highlight??!'*. I could enable capturing escape sequences for colors in `tmux capture-pane`, but it would break tmux-fingers pattern matching.

My other problem with tmux-fingers was that it was sluggish. So I started adding color support to `tmux-fingers` and improving its performance. I had to simplify things to make it reliable. I completely rewrote awk part, added Huffman Coding, added second hint mode. I therefore decided to fork and rename project instead of submitting pull requests that turn things upside down.

## Comparison

Comparing to tmux-fingers, tmux-picker:

- **supports terminal colors** (does not strip color escape codes)
- uses Huffman Coding to generate hints (**shorter hints**, less typing)
    - and supports unlimited number of hints
- is **noticeably faster**
    - and does not have redraw glitches
- has **better patterns** and **two modes** (with different pattern sets)
    - and blacklist pattern
- is self-contained, smaller and easier to hack

Like tmux-fingers, tmux-picker still supports:

- hints in copy-mode
- split windows/multiple panes
- zoomed panes
- two different commands
- configurable hint/highlight styles
- configurable patterns

# How it works?

The basic idea is:

- create auxiliary pane with the same width and height as the current pane
- `tmux capture-pane -t $current_pane | gawk -f find-and-highlight-patterns.awk` to auxiliary pane
- swap panes (the easiest way not to break things like copy-mode)
- read typed keys and execute user command on selected item

# License

[MIT](https://github.com/pawel-wiejacha/tmux-picker/blob/master/LICENSE)
