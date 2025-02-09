local item = "Tech Spinny Wheel Ticket"
local class = "Misc"
local maxPrice = "3200"
local maxBuyItem = 1000
local WebhookLink = "https://discord.com/api/webhooks/1200490379296911370/rSb6R8yOFqmpXAQz_AVdOuE4pkZQqwEenkRD-1rrF449TuPxs-PgkZ2NkSKYJ0UYYG8N"

--Classes can be found here - require(game:GetService("ReplicatedStorage").Library.Items.Types).Types

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer:GetAttribute("__LOADED") == true

function UnAbbreviateNumber(Number)
    if string.find(Number,".") then
        OldNumber = string.split(Number,".")[1]
        if string.find(Number,"k") then
            OldNumber = Number.."k"
        elseif string.find(Number,"m") then
            OldNumber = Number.."m"
        elseif string.find(Number,"b") then
            OldNumber = Number.."b"
        end
    end
    if string.find(Number,"k") then
        return tonumber(string.split(Number,"k")[1]) * 1000
    elseif string.find(Number,"m") then
        return tonumber(string.split(Number,"m")[1]) * 1000000
    elseif string.find(Number,"b") then
        return tonumber(string.split(Number,"b")[1]) * 1000000000
    end
end


function Webhook(Info)
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "Item Sniped",
            ["description"] = "",
            ["fields"] = {
                {
                    ["name"] = "Item:",
                    ["value"] = "```"..Info.ItemName.."```",
                    ["inline"] = true
                },
                {
                    ["name"] = "Price:",
                    ["value"] = "```"..Info.Price.."```",
                    ["inline"] = true
                },
                {
                    ["name"] = "Quantity:",
                    ["value"] = "```"..Info.Quantity.."```",
                    ["inline"] = true
                },
            },
            ["type"] = "rich",
            ["color"] = tonumber(0x3ed841),
            ["footer"] = {text = "Sniped From: "..Info.BoothSellerName, icon_url=""},
            },
        }    
    }
    request({Url=WebhookLink, Body=game:GetService("HttpService"):JSONEncode(data), Method="POST", Headers={["content-type"] = "application/json"}})   
end

local Library =  require(game:GetService("ReplicatedStorage").Library.Client.Network)

function SearchItem()
    print("Started Searching")
    repeat task.wait(5)
        local SearchRemote
        if class == "Consumbale" then
            SearchRemote = Library.Invoke("TradingTerminal_Search",class,"{\"id\":\""..item.."\",\"tn\":1}", nil, false)
        else
            SearchRemote = Library.Invoke("TradingTerminal_Search",class,"{\"id\":\""..item.."\"}", nil, false)
        end
        if SearchRemote ~= nil then
            local SearchInfo = {UserId = SearchRemote["user_id"],PlaceId = SearchRemote["place_id"],JobId = SearchRemote["job_id"],BoothNumber = SearchRemote["booth"],}
            writefile("PetSim99Sniper.Snipe",game:GetService("HttpService"):JSONEncode(SearchInfo))
            game:GetService("TeleportService"):TeleportToPlaceInstance(SearchInfo.PlaceId, SearchInfo.JobId)
        end
    until test == true
end

if isfile("PetSim99Sniper.Snipe") then
    --Purchase Item First
    local SearchInfo = game:GetService("HttpService"):JSONDecode(readfile("PetSim99Sniper.Snipe"))
    local User = nil
    local Booth = nil
    if game:GetService("Players"):GetPlayerByUserId(SearchInfo.UserId) ~= nil then
        User = game:GetService("Players"):GetPlayerByUserId(SearchInfo.UserId).DisplayName
    end
    for i,v in pairs(game:GetService("Workspace").__THINGS.Booths:GetChildren()) do
        if v:GetAttribute("Owner") == SearchInfo.UserId then
            game.Players.LocalPlayer.Character:PivotTo(v.Booth.CFrame * CFrame.new(0,0,-8))
            Booth = v
        end
    end
    if Booth ~= nil then
        local ClassMod = require(game:GetService("ReplicatedStorage").Library.Items.Types)
        if ClassMod.Types[class] and ClassMod.Types[class].Directory[item] then
            if #Booth.Pets.BoothTop.PetScroll:GetChildren() > 0 then
                for i,v in pairs(Booth.Pets.BoothTop.PetScroll:GetChildren()) do
                    if v:IsA("Frame") and v:FindFirstChild("Holder") and v.Holder.ItemSlot.Icon.Image == tostring(ClassMod.Types[class].Directory[item].Icon) and tonumber(string.split(v.Holder.ItemSlot.Quantity.Text,"x")[2]) > 0 then
                        UID = v.Name
                        Quantity = tonumber(string.split(v.Holder.ItemSlot.Quantity.Text,"x")[2])
                        Price = UnAbbreviateNumber(v.Buy.Cost.Text)
                        if Price <= maxPrice then
                            local PurchaseTable = nil
                            if Quantity < maxBuyItem then
                                PurchaseTable = {[UID] = Quantity}
                                local PurchaseRemote = Library.Invoke("Booths_RequestPurchase",SearchInfo.UserId, PurchaseTable)
                                if PurchaseRemote == true then
                                    Webhook({
                                        Quantity=Quantity,
                                        Price=Price,
                                        ItemName=ClassMod.Types[class].Directory[item].DisplayName,
                                        BoothSellerName=tostring(User),
                                    })
                                end
                            elseif Quantity >= maxBuyItem then
                                PurchaseTable = {[UID] = maxBuyItem}
                                local PurchaseRemote = Library.Invoke("Booths_RequestPurchase",SearchInfo.UserId, PurchaseTable)
                                if PurchaseRemote == true then
                                    Webhook({
                                        Quantity=maxBuyItem,
                                        Price=Price,
                                        ItemName=ClassMod.Types[class].Directory[item].DisplayName,
                                        BoothSellerName=tostring(User),
                                    })
                                end
                            end
                        end
                        print("Not Buying That Shit")
                        delfile("PetSim99Sniper.Snipe")
                    end
                end
            else
                SearchItem()
            end
        end
    else
        SearchItem()
    end
    --
    local SearchRemote
    if class == "Consumbale" then
        SearchRemote = Library.Invoke("TradingTerminal_Search",class,"{\"id\":\""..item.."\",\"tn\":1}", nil, false)
    else
        SearchRemote = Library.Invoke("TradingTerminal_Search",class,"{\"id\":\""..item.."\"}", nil, false)
    end
    if SearchRemote ~= nil then
        local SearchInfo = {
            UserId = SearchRemote["user_id"],
            PlaceId = SearchRemote["place_id"],
            JobId = SearchRemote["job_id"],
            BoothNumber = SearchRemote["booth"],
        }
        
        writefile("PetSim99Sniper.Snipe",game:GetService("HttpService"):JSONEncode(SearchInfo))
        game:GetService("TeleportService"):TeleportToPlaceInstance(SearchInfo.PlaceId, SearchInfo.JobId)
    end
else
    SearchItem()
end

if queue_on_teleport ~= nil then
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/IJustFloat/Script/refs/heads/main/ps99/Sniper.lua"))()')
end
