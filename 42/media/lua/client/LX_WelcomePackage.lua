--[[
    LX_SPLITSCREEN_WELCOME_PACKAGE

    Every local character (player 1, 2, 3 or 4 in split-screen) gets, once, an army ALICE
    pack worn on the back, filled with survival and building gear.

    Contents are grouped and each group can be switched off in the mod options:
      - Backpack : the ALICE pack itself (off = everything goes to the main inventory).
      - Weapons  : shotgun, 4 boxes of shells, machete.
      - Tools    : hammer, screwdriver, bolt cutters, crowbar, blowtorch, welding mask,
                   wood axe, saw, box of nails, rope, torch.
      - Survival : full canteen, 4 bandages.

    - Recorded in the character's modData: reloading never duplicates it.
    - A character who already received v1 only gets the v2 additions.
    - A new character (after dying, for instance) gets the whole thing.
    - Anything that does not fit in the pack (capacity 28) goes to the main inventory.
    - Delivered ~2 s after spawning, once the character has finished initialising.
    - If something is already worn on the back, the pack stays in the inventory
      (nothing you are wearing is ever replaced).

    v2.1.0 - contents are configurable (Options -> MODS), text is translatable.
]]

local FLAG_V1 = "LX_WelcomePackage_v1"
local FLAG_V2 = "LX_WelcomePackage_v2"
local BAG = "Base.Bag_ALICEpack_Army"
local DELAY_MS = 2000

-- { fullType, count, group }
local CONTENTS_V1 = {
    { "Base.Shotgun", 1, "weapons" },
    { "Base.ShotgunShellsBox", 4, "weapons" },
    { "Base.Hammer", 1, "tools" },
    { "Base.Screwdriver", 1, "tools" },
    { "Base.BoltCutters", 1, "tools" },
    { "Base.Machete", 1, "weapons" },
    { "Base.Crowbar", 1, "tools" },
}
local CANTEEN = { "Base.Canteen", 1, "survival" }
local CONTENTS_V2 = {
    { "Base.BlowTorch", 1, "tools" },
    { "Base.WeldingMask", 1, "tools" },
    { "Base.WoodAxe", 1, "tools" },
    { "Base.Saw", 1, "tools" },
    { "Base.NailsBox", 1, "tools" },
    { "Base.Rope", 1, "tools" },
    { "Base.HandTorch", 1, "tools" },
    { "Base.Bandage", 4, "survival" },
}

local opt = { enabled = true, backpack = true, weapons = true, tools = true, survival = true }
local pending = {} -- [playerNum] = timestamp from which to deliver

local function log(msg) print("[LX_WelcomePackage] " .. tostring(msg)) end

local function fillWithWater(item)
    if not item or not item.getFluidContainer then return end
    local fc = item:getFluidContainer()
    if not fc then return end
    fc:Empty()
    fc:addFluid(FluidType.Water, fc:getCapacity())
end

-- Puts the item in the pack if it fits, otherwise in the main inventory.
local function put(player, bagInv, inv, fullType)
    local item = instanceItem(fullType)
    if not item then
        log("could not create " .. fullType)
        return nil
    end
    if bagInv and bagInv:hasRoomFor(player, item) then
        return bagInv:AddItem(item)
    end
    return inv:AddItem(item)
end

local function putList(player, bagInv, inv, list)
    for _, entry in ipairs(list) do
        if opt[entry[3]] ~= false then
            for _ = 1, entry[2] do put(player, bagInv, inv, entry[1]) end
        end
    end
end

-- The ALICE pack we already gave them (worn or in the inventory), if any.
local function findOurBag(player)
    local inv = player:getInventory()
    local items = inv:getItems()
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it and it:getFullType() == BAG and player:isEquippedClothing(it) then return it end
    end
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it and it:getFullType() == BAG then return it end
    end
    return nil
end

local function giveCanteen(player, bagInv, inv)
    if opt.survival == false then return end
    local canteen = put(player, bagInv, inv, CANTEEN[1])
    if canteen then
        local ok, err = pcall(fillWithWater, canteen)
        if not ok then log("canteen: " .. tostring(err)) end
    end
end

local function giveFull(player)
    local inv = player:getInventory()
    local bag, bagInv = nil, nil
    if opt.backpack ~= false then
        bag = inv:AddItem(BAG)
        if not bag then
            log("could not create the backpack " .. BAG)
            return false
        end
        bagInv = bag:getItemContainer()
    end

    putList(player, bagInv, inv, CONTENTS_V1)
    giveCanteen(player, bagInv, inv)
    putList(player, bagInv, inv, CONTENTS_V2)

    -- wear it on the back if that slot is free
    if bag then
        local loc = bag:canBeEquipped()
        if loc and loc ~= "" and not player:getWornItem(loc) then
            player:setWornItem(loc, bag)
            pcall(syncVisuals, player)
        end
    end
    return true
end

local function giveV2Extras(player)
    local inv = player:getInventory()
    local bag = findOurBag(player)
    local bagInv = bag and bag:getItemContainer() or nil
    putList(player, bagInv, inv, CONTENTS_V2)
    return true
end

local function give(player)
    if not opt.enabled then return end

    local md = player:getModData()
    if md[FLAG_V1] and md[FLAG_V2] then return end

    -- extra safety: if they already have the ALICE pack (e.g. a character rebuilt from the
    -- save) do not hand out another full one; at most the v2 extras.
    if not md[FLAG_V1] and findOurBag(player) then
        md[FLAG_V1] = true
        log("player " .. (player:getPlayerNum() + 1) .. " already had the pack: not giving another")
        if md[FLAG_V2] then return end
    end

    local done, what
    if not md[FLAG_V1] then
        done, what = giveFull(player), "full package"
    else
        done, what = giveV2Extras(player), "v2 extras"
    end
    if not done then return end

    md[FLAG_V1] = true
    md[FLAG_V2] = true
    pcall(function() HaloTextHelper.addGoodText(player, getText("UI_LXWP_halo")) end)
    log(what .. " delivered to player " .. (player:getPlayerNum() + 1))
end

local function onCreatePlayer(playerNum, player)
    if playerNum == nil or playerNum < 0 or playerNum > 3 then return end
    pending[playerNum] = getTimestampMs() + DELAY_MS
end

local function onPlayerUpdate(player)
    if not player then return end
    local n = player:getPlayerNum()
    local due = n and pending[n]
    if not due or getTimestampMs() < due then return end
    pending[n] = nil
    if player:isDead() then return end
    local okLocal, isLocal = pcall(player.isLocalPlayer, player)
    if not okLocal or not isLocal then return end
    local ok, err = pcall(give, player)
    if not ok then log("error: " .. tostring(err)) end
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnPlayerUpdate.Add(onPlayerUpdate)

-- ---------------------------------------------------------------- options
if PZAPI and PZAPI.ModOptions then
    local o = PZAPI.ModOptions:create("LXSplitWelcome", getText("UI_LXWP_name"))
    o:addDescription(getText("UI_LXWP_desc"))
    o:addSeparator()
    local tEnabled = o:addTickBox("ENABLED", getText("UI_LXWP_enable"), true, getText("UI_LXWP_enable_tip"))
    local tBag = o:addTickBox("BACKPACK", getText("UI_LXWP_backpack"), true, getText("UI_LXWP_backpack_tip"))
    local tWeapons = o:addTickBox("WEAPONS", getText("UI_LXWP_weapons"), true, getText("UI_LXWP_weapons_tip"))
    local tTools = o:addTickBox("TOOLS", getText("UI_LXWP_tools"), true, getText("UI_LXWP_tools_tip"))
    local tSurvival = o:addTickBox("SURVIVAL", getText("UI_LXWP_survival"), true, getText("UI_LXWP_survival_tip"))

    -- Greys the group switches out while the master switch is off.
    local function setGroupsEnabled(on)
        for _, t in ipairs({ tBag, tWeapons, tTools, tSurvival }) do
            if t and t.setEnabled then pcall(t.setEnabled, t, on == true) end
        end
    end

    o.apply = function(self)
        opt.enabled = tEnabled:getValue() == true
        opt.backpack = tBag:getValue() == true
        opt.weapons = tWeapons:getValue() == true
        opt.tools = tTools:getValue() == true
        opt.survival = tSurvival:getValue() == true
        setGroupsEnabled(opt.enabled)
    end

    -- onChange runs on the click, BEFORE the options screen writes the new value into the
    -- option (MainOptions does that in its own apply()), so getValue() would still hand back
    -- the previous one here. Use the value we are given, and only touch the greying: the real
    -- settings are read in apply(), which PZAPI calls right after committing every value.
    tEnabled.onChange = function(self, value) setGroupsEnabled(value) end

    -- PZAPI does not call apply() on load: force it on menu entry and on game start.
    Events.OnMainMenuEnter.Add(function() o:apply() end)
    Events.OnGameStart.Add(function() o:apply() end)
end
