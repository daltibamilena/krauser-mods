ShowTyping = {}

ShowTyping.checkChat = function(player)
    if (getWorld():getGameMode() ~= "Multiplayer") then

        return
    end

    local chatInstance = ISChat.instance
    local textEntryTextLength = chatInstance.textEntry:getText():len()

    if (ISChat.focused and textEntryTextLength > 0) then --Window gains focus when clicking the 'lock/unlock' button so we need to check text length too
        if (chatInstance.currentTabID == 2) then
            return --don't show if on 'Admin' tab
        end

        if (chatInstance.currentTabID == 1) then
            player:setHaloNote("Digitando...")
        end

    end

end

Events.OnPlayerUpdate.Add(ShowTyping.checkChat)
