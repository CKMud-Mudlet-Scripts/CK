setTriggerStayOpen("Status Affections", 0)
if CK.Toggles.hide_status then
  CK.Toggles.hide_status = nil
  deleteLine()
  -- This will delete all the lines after affections 
  -- but also the empty line and next prompt
  tempLineTrigger(1, 9, [[ deleteLine() ]])
end