# Gameplay verification

Run with Godot 4:

```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/verify_game.gd
```

Checks all five campaign maps for closed rectangular boundaries, reachable key progression, mandatory door cut points, and a nontrivial exit route. Timed lasers are traversable during their safe phase. Relay stations must both be reachable before their gate and far enough apart to require two players.

Runtime checks cover actual portal overlap, relay overlap and latching, duplicate/incorrect key pickups, clean restarts, following through walls and turns, laser reactivation, independent audio buses, settings persistence in an isolated test file, and closing settings while paused.

These checks establish structural solvability and targeted physics behavior. They do not prove every dynamic monster encounter or every player strategy is balanced.

For rendered UI previews, run `tests/preview_ui.gd` without `--headless`, using `--rendering-method gl_compatibility`. PNGs are written into the ignored `.godot` directory. Use `--resolution 960x540` for the smaller-window check.
