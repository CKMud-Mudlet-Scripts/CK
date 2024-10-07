setTriggerStayOpen("Score Scrape", 0)
if CK.Toggles.hide_score then
    CK.Toggles.hide_score = nil
    gagLine()
    -- This will delete all the lines after affections 
    -- but also the empty line and next prompt
    tempLineTrigger(1, 3, [[ gagLine() ]])
end