if CK.API:is_connected() and (CK.Toggles.botmode or CK.Toggles.training) then
    if CK.API.Times:last("prompt") > 8 then
        send("\n")
    end
end

if CK.API.Times:last("prompt") > 3600 then
  cecho("<red>!!!!!Prompt is not parsing file a bug!!!!!")
end
