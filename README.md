Lua plugins for `mpv` media player

# Install

Assuming `~/.config/mpv/` is `mpv`'s configuration directory on your computer, from the
working copy of this repository, run

```bash
mkdir ~/.config/mpv/scripts
cp *.lua ~/.config/mpv/scripts/
```

... or select the scripts that you need (well, currently there's just one, ha-ha-ha).

# Scripts

## `edl.lua`

Writes an Editing Decision List (EDL) in a format `mpv` itself understands. The file name
is preserved, except the extensioni suffix changes to `.edl`. If a `name.edl` file already
exists, the subsequent files will be created with a serial number, i.e. `name-1.edl`,
`name-2.edl`, etc.

### Key Bindings

| Key binding | Action |
|-------------|--------|
| Ctrl-i | Mark IN |
| Ctrl-o | Mark  OUT|
| Ctrl-i | Mark end of clip as OUT |

### Verify Edits

The resulting EDL file can then be fed to `mpv` as an argument and will be taken as a
playlist, essentially:

```
# Plays the entire file
mpv name.mp4

# Plays your cuts only
mpv name.edl
```

This is useful to verify your edits.

### Apply the Edits

The basic `ffmpeg` command to process a single EDL entry is

```
ffmpeg -i "$INFILE" -ss "$START" -to "$((START + DURATION))" -c copy "$OUTFILE"
```

### Caveat

There are many EDL formats, and they are more elaborate than the one that `mpv` uses. If
you want to import EDL into your editing software, you should likely create a different
script.