# UISurface

**UISurface** is a communication bridge that allows **Nyxian** **to communicate** with the **UI elements**. First of all it has to be initialised. It does that using `void UISurface_Handoff_Slave(UIView *view)` which is a function for the view that you wanna use as the slave to be handoffed. Now when a user includes the **`ui` module**, the module can basically call `UIView* UISurface_Handoff_Master(void)` which basically outputs the handoffed view to the **`ui` module**.

The **`ui` module** needs that to communicate with the slave view. For that **UISurface** has a few more functions.

- `NSString* UISurface_Wait_On_Msg(void)`: **waits till** a **UI element has send a message** and returns it to **Nyxian Runtime**
- `void UISurface_Send_Msg(NSString *umsg)`: sends a message and signals the waiter that waits using ``NSString* UISurface_Wait_On_Msg(void)``
- `BOOL* UISurface_Did_Got_Messaged(void)`: **just asks** instead of waiting if a **UI element has send a message**
- `NSString* UISurface_Get_Message(void)`: **gets message** if it was **passed by a UI element**



***

### Messaging

As teased previously you can message UI elements using **UISurface**. Here is a code snippets that demonstrates that.

- **Active messaging**:

  ```js
  // include UI library first
  include("ui");
  
  // 1st button
  let button = ui.spawnButton();
  button.setBackgroundColor(255, 0, 0, 1.0);
  button.setFrame(0, 0, 120, 40);
  button.setText("Message");
  button.setMsg("continue");
  
  // 2nd button
  let button2 = ui.spawnButton();
  button2.setBackgroundColor(255, 0, 0, 1.0);
  button2.setFrame(0, 0, 120, 40);
  button2.setText("Message");
  button2.setMsg("exit");
  
  // uiloop
  function uiloop() {
    while(true) {
      let msg = ui.waitOnMsg();
      switch(msg) {
        case "exit":
          // user wants to exit so we go
          return;
        case "continue":
          // user wants us to continue
          break;
        default:
          break;
      }
    }
  }
  ```

- **Passive messaging**:

  ```js
  // include UI library first
  include("ui");
  include("timer");
  
  // 1st button
  let button = ui.spawnButton();
  button.setBackgroundColor(255, 0, 0, 1.0);
  button.setFrame(0, 0, 120, 40);
  button.setText("Message");
  button.setMsg("continue");
  
  // 2nd button
  let button2 = ui.spawnButton();
  button2.setBackgroundColor(255, 0, 0, 1.0);
  button2.setFrame(0, 0, 120, 40);
  button2.setText("Message");
  button2.setMsg("exit");
  
  // uiloop
  function uiloop() {
    while(true) {
      // Do task in between
      // .. (your hypothetical code that gets executed in between) ..
      // was I even messaged?
      if(ui.gotMsg()) {
        // get message
      	let msg = ui.getMsg();
      	switch(msg) {
        	case "exit":
          	// user wants to exit so we go
          	return;
        	case "continue":
          	// user wants us to continue
          	break;
        	default:
          	break;
      	}
      }
      // dont do too much at once
      timer.wait(0.05);
    }
  }
  ```

