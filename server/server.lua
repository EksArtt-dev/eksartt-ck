local QBCore = exports['qb-core']:GetCoreObject()

local function isHexAllowed(hexID)
    for _, allowedHex in ipairs(Config.Hexidcik) do
        if hexID == allowedHex then
            return true
        end
    end
    return false
end

CreateThread(function()
    for _, eksartt in pairs(Config.komut) do
        QBCore.Commands.Add(eksartt, "Komut açıklaması", {{name = 'id', help = "Oyuncu ID'si"}}, true, function(source, args)
            local src = source
            local playerId = tonumber(args[1])
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player then
                local citizenid = Player.PlayerData.citizenid
                local siksoksteam, targetSteamHex, discordId, licenseId
                local adminSteamHex, adminDiscordId, adminLicenseId
                for _, id in ipairs(GetPlayerIdentifiers(src)) do
                    if string.find(id, "steam:") then
                        siksoksteam = id
                        break
                    end
                end
                for _, id in ipairs(GetPlayerIdentifiers(source)) do
                    if string.find(id, "steam:") then
                        adminSteamHex = id
                    elseif string.find(id, "discord:") then
                        adminDiscordId = id
                    elseif string.find(id, "license:") then
                        adminLicenseId = id
                    end
                end

                print("Executing Player Steam Hex: " .. (siksoksteam or "nil"))

                if Config.hexsistem then
                    if not siksoksteam then
                        TriggerClientEvent('QBCore:Notify', src, "Steam Hex ID'niz alınamadı.", 'error')
                        print("Steam Hex ID alınamadı.")
                        return
                    elseif not isHexAllowed(siksoksteam) then
                        TriggerClientEvent('QBCore:Notify', src, "Bu komutu kullanma izniniz yok.", 'error')
                        print("İzin verilmeyen Steam Hex: " .. executorSteamHex)
                        return
                    end
                else
                    local player = QBCore.Functions.GetPlayer(src)
                    if player and not QBCore.Functions.HasPermission(src, 'admin') then
                        TriggerClientEvent('QBCore:Notify', src, "Bu komutu kullanma yetkiniz yok.", 'error')
                        return
                    end
                end

                for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
                    if string.find(id, "steam:") then
                        targetSteamHex = id
                    elseif string.find(id, "discord:") then
                        discordId = id
                    elseif string.find(id, "license:") then
                        licenseId = id
                    end
                end

                print("Target Player Steam Hex: " .. (targetSteamHex or "nil"))
                print("Discord ID: " .. (discordId or "nil"))
                print("License ID: " .. (licenseId or "nil"))

                DropPlayer(playerId, Config.kickmesaj)
                CreateThread(function()
                    Wait(200)

                    exports.oxmysql:execute('DELETE FROM players WHERE citizenid = ?', { citizenid })
                    exports.oxmysql:execute('DELETE FROM player_vehicles WHERE citizenid = ?', { citizenid })
                    exports.oxmysql:execute('DELETE FROM player_outfits WHERE citizenid = ?', { citizenid })
                    exports.oxmysql:execute('DELETE FROM player_houses WHERE citizenid = ?', { citizenid })
                    exports.oxmysql:execute('DELETE FROM player_contacts WHERE citizenid = ?', { citizenid })
                    exports.oxmysql:execute('DELETE FROM playerskins WHERE citizenid = ?', { citizenid })

                    TriggerClientEvent("QBCore:Notify", src, "Komut başarıyla çalıştırıldı.")

                    local webhookUrl = Config.webhook
                    local webhookData = {
                        username = "CK Logu",
                        embeds = {
                            {
                                title = "Player",
                                description = ("Player ID: %s\nCitizen ID: %s\nSteam Hex: %s\nDiscord ID: %s\nLicense ID: %s\n\ntarafından CK atıldı ve verileri silindi Admin ID: %s\nAdmin Steam Hex: %s\nAdmin Discord ID: %s\nAdmin License ID: %s\nZaman: %s"):format(
                                    playerId,
                                    citizenid,
                                    targetSteamHex or "nil",
                                    discordId or "nil",
                                    licenseId or "nil",
                                    source,
                                    adminSteamHex or "nil",
                                    adminDiscordId or "nil",
                                    adminLicenseId or "nil",
                                    os.date('%Y-%m-%d %H:%M:%S', os.time())
                                ),
                                color = 16711680
                            }
                        }
                    }
                    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
                end)
            else
                TriggerClientEvent('QBCore:Notify', src, "Oyuncu bulunamadı.", 'error')
            end
        end, 'admin')
    end
end)

-- AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
--     local identifiers = GetPlayerIdentifiers(source)
--     print('Player Connecting: ' .. name)
--     for _, id in ipairs(identifiers) do
--         print('Identifier: ' .. id)
--     end
-- end)
