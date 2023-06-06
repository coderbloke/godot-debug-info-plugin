# godot-debug-info-plugin
 
A Godot plug-in to display debug info in separate panels in the editor.

Yet simple and early, but already useful.<br>

Component:
- [DebugInfoPanel](#DebugInfoPanel):
  Mostly for cyclic debug messages, instead flooding the console with them.
- [DebugInfoLog](#DebugInfoLog):
  If you run out-of-space or got lost in standard log
  
The plug-in provides you with an autoload singleton, which you can access from anywhere in your code.<br>
Working from tool script running in editor, but also from the app runing in debug mode.
Printed messages will always appear in the editor, not in the game.
Messages coming from the same script running in editor in tool mode and running in game in debug mode are indicated separatelly.

For plans and issues:
For feedback and idea/needs sharing:

Driving forces currently are my needs during usage.
You can change it with your feedback.

## DebugInfoPanel

You can get a slot on the DebugInfoPanel from your code, and print rich text to it.
(Panel open in the left-bottom dock by default.)

Request a slot using `info = DebugInfo.get_slot(key, clear, timeout)`.
- `key`: A string id for your slot
- `clear`: Optional. If `false`, the slot won't be cleared, when your request it. by default it's `true`
- `timeout`: Optional. Time-out of the slot in seconds. If the slot is not updated for `timeout`, it will disappear from the panel.<br>
  The default timeout is 5 second.
  If you give `timeout = 0`, the slot will remain on the panel, even if it is not updated.
  An update means, that the contect (i.e. the text) of the slot is changed.

After this you can print to the slot with `info.add_line(line)`, where line is a rich text, so BBCodes can be used.<br>
You can also clear the slot explcitily with `info.clear()`, or just reset its timer with `slot.reset_timer()`, if you need it. (I never needed yet.)

![Godot_v4 0 3-stable_win64_isGbU0doZE](https://github.com/coderbloke/godot-debug-info-plugin/assets/75695649/579ed8c4-fef8-4066-8c92-1d619843bed3)

## DebugInfoLog

You can get a log in the DebugInfoLog panel, and print on it and filter it similarly as you are used to the standard log.
In addition, it allows multiple logs, externalize the log to a separata window, display timetsamps, clear the log from script...
For example:
- You have components in your app, which are only occasionally doing some background activity.<br>
  Usually you don't need their debug info, but once you need it it's good to have them accessible:<br>
  🡒 Leave the debug printing in your code to a separate log. When you need the info, switch to log, and enable to show the timestamps.
- At certain event in your game you need lots of debug info for that one exact event:<br>
  🡒 Print to separate log. Clear the log before printing. External log and put to a second screen.

Usage:
- Request a log using `additional_log = DebugInfo.get_log(id, title)`. `id` according to which the plug-in find previously opened logs, you can change the `title` as you need.
- Or you can also access a default log (which is always present) with `DebugInfo.log`
- Print to the log using `print`, `print_rich`, `printerr`, `print_error`, `print_warning`, `print_verbose` and `print_raw`<br>
  They are working similarly then the [built-in print functions](https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#class-globalscope-method-print),
  except that they cannot accept variable number of argument, only one string parameter.<br>
  To default log: `DebugInfo.log.print(...)`, or to your custom log `additional_log.print(...)`
- There is a short-cut for printing colored rich text: `print_colored(color, msg)`<br>
  Color is a BBCode named color or an HTML color in form of #RRGGBB. Cheat names from here: [BBCode Color List](https://absitomen.com/index.php?topic=331.0)<br>
  I suggest you to use colors to help yourself. This function just saves you the boilerplate BBCode.
- Clear log with `clear()`
- With the `log.redirect_to_main` flag, you can redirect the printing to the main editor log also. (Printing will done to custom log also.)
  This is usefull, when there is a runtime error during your printing, and you want to see, where it happens between your hundreds of lines of printing.
  Set `log.redirect_to_main = true` temporarily in such cases. The `get_log` function reset the flag back to `false`.
- Other features accessible on the GUI (see right side button). Settings of the logs are saved in the background using their `id`.

![ArLG3mEm5S](https://github.com/coderbloke/godot-debug-info-plugin/assets/75695649/923ddeed-46e5-460f-afe9-e2f49ace4323)

  
