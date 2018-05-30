package body app_custom is

procedure close_window(wnd in varchar2) is
  /*
    This procedure is called whenever the user closes a window, as
    a result of the WHEN-WINDOW-CLOSED trigger firing. You are responsible
    for supplying unqiue code that addresses the needs of each window, such as
    deferring master-detail relations, or closing related windows.

    Other windows that will be referenced into your form rely on the default
    code at the beginning and end of this procedure - under no circumstances
    should you modify that code.
  */
begin

  /*
    THE FOLLOWING CODE MUST NOT BE MODIFIED. It prevents windows from closing
    while in enter-query mode.
  */

  if (name_in('system.mode') = 'ENTER-QUERY') then
    app_exception.disabled;
    return;
  end if;

  /*
    YOU MUST MODIFY THE FOLLOWING CODE to account for specific behaviors of your
    form, including:
    1. identifying the 'first window' of the form and treating
       a close window on that window like a close form.
    2. deferring master-detail relations for detail blocks that
       exist in other windows.
    3. closing other related windows.
    The default code at the end of this procedure actually closes the window.
    If you do that yourself in this code, issue a 'return;' at the end of 
    your logic for your specific windows.
  */ 

  if (wnd = 'CWARCCPM') then
  	IF :PARAMETER.AUCTION_ORDER = 'Y' THEN
  		CW_AUCTION_DELETE_RECORDS;
  	END IF;
  	/*CW_AUCTION_TIMEOUT;
		CW_AUCTION_LOCK;*/
    app_window.close_first_window;
  elsif (wnd = 'CREDIT_OVERRIDE') then 
  	CW_AUCTION_TIMEOUT;
		CW_AUCTION_LOCK;
    --defer relations
    --close related windows   
    null;  
  elsif (wnd = '<yet another window>') then 
    --defer relations
    --close related windows   
    null;
  end if;

  /*
    THE FOLLOWING CODE MUST NOT BE MODIFIED. It ensures the cursor is not in 
    the window that will be closed (by moving it to the previous block if 
    needed), and actually closes the specified window.
  */

  if (wnd = get_view_property(get_item_property(:SYSTEM.CURSOR_ITEM, 
                              ITEM_CANVAS), WINDOW_NAME)) then
    do_key('PREVIOUS_BLOCK');
  end if;
  hide_window(wnd);

end close_window;

procedure open_window(wnd in varchar2) is
  /*
    This procedure should be called from any code that could result
    in a non-modal window being opened.
  */
begin  
  /*
    YOU MUST MODIFY THE FOLLOWING CODE to account for specific behaviors of your
    form, including:   
    1. Positioning the window to be opened
    2. Resetting master-detail relations for blocks in the window    
    3. navigation to a block in that window
  */
  if (wnd = '<a window>') then
    --position the window
    --reset master-detail relations
    --navigate to a block in the window
    null;
  elsif (wnd = '<another window>') then 
    --position the window
    --reset master-detail relations
    --navigate to a block in the window
    null;
  elsif (wnd = '<yet another window>') then 
    --position the window
    --reset master-detail relations
    --navigate to a block in the window
    null;
  end if;

end open_window;

end app_custom;
