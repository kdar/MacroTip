MacroTip = LibStub("AceAddon-3.0"):NewAddon("MacroTip", "AceConsole-3.0", "AceEvent-3.0")

local DEBUG = false

local options = {
  name = "MacroTip",
  handler = MacroTip,
  type = 'group',
  args = {
    enable = {
      type = 'toggle',
      order = 1,
      name = 'Enabled',
      width = 'double',
      desc = 'Enable or disable this addon.',
      get = function(info) return MacroTip.db.profile.enabled end,
      set = function(info, val) if (val) then MacroTip:Enable() else MacroTip:Disable() end end,
    }
  }
}

local defaults = {
  profile = {
    enabled = true
  }
}

function MacroTip:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MacroTipDB", defaults)
  local parent = LibStub("AceConfig-3.0"):RegisterOptionsTable("MacroTip", options, {"MacroTip", "al"})
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MacroTip", "MacroTip")
  profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  LibStub("AceConfig-3.0"):RegisterOptionsTable("MacroTip.profiles", profiles)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MacroTip.profiles", "Profiles", "MacroTip")

  self.list = {}
end

function MacroTip:OnEnable()
  self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
  self:RegisterEvent("SPELLS_CHANGED")

  self:RegisterEvent("UPDATE_MACROS")
  self:RegisterEvent("UNIT_SPELLCAST_START")
  self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
  self.db.profile.enabled = true
end

function MacroTip:OnDisable()
  self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
  self:UnregisterEvent("SPELLS_CHANGED")

  self:UnregisterEvent("UPDATE_MACROS")
  self:UnregisterEvent("UNIT_SPELLCAST_START")
  self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
  self.db.profile.enabled = false
end

function MacroTip:PLAYER_SPECIALIZATION_CHANGED(event, unit)
  if unit == "player" then
    self:UpdateList()
    self:UpdateMacros()
  end
end

function MacroTip:PLAYER_ENTERING_WORLD()
  -- need to give the system some time when we enter (mainly our first login).
  -- soemtimes SetMacroSpell won't work unless we delay.
  __wait(1.0, function(self)
    self:UpdateList()
    self:UpdateMacros()
  end, self)
end

function MacroTip:ACTIVE_TALENT_GROUP_CHANGED()
  self:UpdateList()
  self:UpdateMacros()
end

function MacroTip:SPELLS_CHANGED(event)
  self:UpdateList()
  self:UpdateMacros()
end

function MacroTip:UPDATE_MACROS()
  self:UpdateList()
  self:UpdateMacros()
end

function MacroTip:UNIT_SPELLCAST_START(event, unit)
  if unit ~= "player" then
    return
  end
  self:UpdateMacros()
end

function MacroTip:UNIT_SPELLCAST_SUCCEEDED(event, unit)
  if unit ~= "player" then
    return
  end
  self:UpdateMacros()
end

function MacroTip:PlayerHasSpell(spell)
  return select(1, GetSpellInfo(spell)) ~= nil
end

function MacroTip:UpdateList()
  local group = GetActiveSpecGroup()

  -- local start = debugprofilestop()

  for i=1,MAX_ACCOUNT_MACROS+MAX_CHARACTER_MACROS do
    local macroName, _, macroBody = GetMacroInfo(i)
    if macroBody ~= nil and string.find(macroBody, '#macrotip') ~= nil then
      local spells = split(string.match(macroBody, '#macrotip ?([^\n]*)'), ' *, *')
      if #spells > 0 then
        local tier = tonumber(string.match(spells[1], 'tier(%d)'))
        if tier ~= nil and tier > 0 then
          for column = 1,3, 1 do
            local _, name, _, selected, _ = GetTalentInfo(tier, column, group)
            if selected then
              --SetMacroSpell(macroName, name)
              self.list[macroName] = name
              break
            end
          end
        else
          for j=1,#spells do
            if self:PlayerHasSpell(spells[j]) then
              --SetMacroSpell(macroName, spells[j])
              self.list[macroName] = spells[j]
              break
            end
          end
        end
      end
    end
  end

  -- self:Print(format("myFunction executed in %f ms", debugprofilestop()-start))
end

function MacroTip:UpdateMacros()
  for key,value in pairs(self.list) do
    SetMacroSpell(key, value)
  end
end

-- util functions

function split(str, pat)
  if str == nil then
    return {}
  end

  local t = {}
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
  table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

local waitTable = {};
local waitFrame = nil;

function __wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end
