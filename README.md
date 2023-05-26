# godot-debug-info-plugin
 
A Godot plug-in to display debug info in separate panel in the editor.

Yet simple, but already useful.<br>
Mostly for cyclic debug messages, instead flooding the console with them.

The plug-in provides you with an autoload single, which you can access from anywhere in your code.<br>
You can get a slot on the DebuginfoPanel from your code, and print rich text to it.

Request a slot using `info = DebugInfo.get_slot(key, clear, timeout)`.
- `key`: A string id for your slot
- `clear`: Optional. If `false`, the slot won't be cleared, when your request it. by default it's `true`
- `timeout`: Optional. Time-out of the slot in seconds. If the slot is not updated for `timeout`, it will disappear from the panel.<br>
  The default timeout is 5 second.
  If you give `timeout = 0`, the slot will remain on the panel, even if it is not updated.
  An update means, that the contect (i.e. the text) of the slot is changed.

After this you can print to the slot with `info.add_line(line)`, where line is a rich text, so BBCodes can be used.<br>
You can also clear the lsot explcitily with `info.clear()`, or just reset its timer with `slot.reset_timer()`, if you need it. (I never needed yet.)

Working from tool script, but also from the app run in debug mode.
Printed messages will always appear in the editor, not in the game.

![debug-info-panel-demo](https://github.com/coderbloke/godot-debug-info-plugin/assets/75695649/c6ecb0f7-4273-4762-b579-2539585f1ae7)


Possibilities
--

I assume I will make some enhancments to the already existing functionality,<br>
but I am not eager to add new features to this plug-in yet, as I don't use it for more.<br>
But during debugging other code just in the previous weeks, and from experience from past, some more feature could come, as useful for anybody.

Like:
- Realtime node tree observer
- Realtime property observer (or even editing them during runtime)
- Logging system (hierarcical, timestamp, filterable)
- Not just logging explicitly from code, but automatically also, e.g. the tree changes (node addition and deletion)
- Not just showing these in the editor, but providing in game UI comopnents for display within game
- .......

But as I said, I don't plan to update it, until I (or anybody else) doesn't need it.
