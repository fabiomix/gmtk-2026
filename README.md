# GMTK Game Jam 2026
The GMTK Game Jam is an annual game making marathon, where individuals
and teams try to make a game that fits a theme, in just a few days.

The theme for the year 2026 was **Countdown**.

This game was not part of the jam, I made it months later to find out whether
the idea I had works. Also, as an experiment, the prototype was built with AI,
which goes against the spirit of a game jam, but the point was to test what
current models can do. The original specs are in [PROMPT.md](PROMPT.md) (in
Italian).


## Project GLASSWING
A small top-down escape game with a captured spy in a secret lab.

> Nineteen days undercover to get inside the Varga Institute.
> You reached sub-level 3. Then someone recognised your face.
>
> They took your gear and locked you in a holding cell.
> The lock is cheap. The guards are not.
>
> Getting out comes first.
> If you can, bring back proof of Project GLASSWING.


## How it plays
- **Every run starts in the cell**, with a countdown: the patrol checks the
  cells every minute. When the time is up, the guards catch you and take you
  back. It's a capture, not a death.
- **The lab never changes** during a game: rooms, doors, items and notes are
  always in the same place, so every run teaches you something.
- **Items are physical** (a screwdriver, a staff badge...). They open doors
  and boxes. After a capture you can hide only **one item** from the guards;
  everything else is confiscated and goes back where you found it.
- **Knowledge is permanent:** notes, signs and logs you read go into your
  **journal** and stay there for the whole game, without taking an item slot.
  Some of what you learn opens things that no item can.
- **Escaping is the goal.** Bringing back the GLASSWING report is optional,
  and the escape screen tells you whether the investigation is complete.
- **No combat, no dialogues:** the scientists are busy and the spy has no gadgets.

| Action | Keys |
|---|---|
| Move | WASD / arrow keys |
| Interact | E / Space |
| Journal | J / Tab |
| Pause | Esc / P |


## MVP
The MVP is written entirely with **Claude Opus 5.5** starting from human-written
specifications, in order to evaluate the game idea and the capabilities of
modern AI models.

- Player moves and collides correctly with walls and obstacles.
- Static map with 6 rooms, player can move between connected rooms.
- Player can collect items, discovered information is added to the journal.
- When the timer reaches zero it triggers the capture event.
- Player can choose which items to keep (with a limit), unselected items are lost.
- A new run begins in the cell, with the timer reset.
- Reaching the exit concludes the run successfully.
- Investigation can be completed or left incomplete.


## Roadmap and improvements
- A shorter countdown, tuned together with room sizes, walking speed and
  actions that take time (e.g. unscrewing a panel).
- Final pixel art, more scientists, rooms and items, sound.
- Keypad input: type codes you have learned instead of opening locks automatically.
- Procedural labs: every New Game generates a new lab from a seed, with new
  codes and item placements, while all the runs of a game keep the same lab.
- Dependency graph: ensure that items required to proceed are always reachable.
- Timed events (alarms, doors locking, people moving), saving to disk.
