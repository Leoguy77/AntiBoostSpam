LogData = {} 

local debug = false

AntiBoostSpam = LibStub("AceAddon-3.0"):NewAddon("AntiBoostSpam", "AceConsole-3.0")

AntiBoostSpam.FormLink = "https://forms.gle/sZGX8bNg1514Qmze8"

local options = {
    name = "AntiBoostSpam",
    handler = AntiBoostSpam,
    type = 'group',
    args = {
		enable = {
		  name = "Enable",
		  desc = "Enables / disables the addon",
		  type = "toggle",
		  width = "full",
		  order = 1,
		  set = function(info,val) AntiBoostSpam.db.global.Enabled = val end,
		  get = function(info) return AntiBoostSpam.db.global.Enabled end
		},
		disableloadmessage = {
		  name = "Disable Loadmessage",
		  desc = "Disables the load message on join",
		  type = "toggle",
		  width = "full",
		  order = 2,
		  set = function(info,val) AntiBoostSpam.db.global.Disableloadmessage = val end,
		  get = function(info) return AntiBoostSpam.db.global.Disableloadmessage end
		},
		header = {
		  name = "Submit messages",
		  type = "header",
		  order = 3,
		},
		formtext = {
		  name = "You can send in messages that didnt get filtered so they can be added to the filter. Just submit then to the form at the link below.",
		  type = "description",
		  order = 4,
		  fontSize = "medium"
		},
		formlink = {
		  name = "Link",
		  desc = "Message Send-In Form",
		  type = "input",
		  order = 5,
		  width = "full",
		  cmdHidden = true,
		  set = function(info,val) end,
		  get = function(info) return AntiBoostSpam.FormLink end
		}
	}
}

local defaults = {
  global = {
    Enabled = true,
	Disableloadmessage = false,
    },
}


function AntiBoostSpam:OnInitialize()
	-- Load database
	self.db = LibStub("AceDB-3.0"):New("AddonDB", defaults, true)
	--Get Addon Version
	self.addon_version = GetAddOnMetadata("AntiBoostSpam", "Version") 
	--Register Config
	local config = LibStub("AceConfig-3.0")
	config:RegisterOptionsTable("AntiBoostSpam", options, {"abs", "antiboostspam"})
	local registry = LibStub("AceConfigRegistry-3.0")
	registry:RegisterOptionsTable("AntiBoostSpam Options", options)
	--Add to Addon Options
	local dialog = LibStub("AceConfigDialog-3.0");
	self.optionFrames = {
		main = dialog:AddToBlizOptions(	"AntiBoostSpam Options", "AntiBoostSpam"),
	}
	if not self.db.global.Disableloadmessage then
		AntiBoostSpam:Print("Loaded Version "..self.addon_version)
	end
end

local blocklist = {
	"%s*/%s*=%d+k",
	"+%d+%s+%d+%s*k",
	"+%s*%d+%s*=%s*%d+%s*k",
	"10/10 hc raid",
	"10/10 nhc raid",
	"[%[%(%<%-]%s*chromies",
	"[%[%(%<%-]%s*dawn",
	"[%[%(%<%-]%s*huokan",
	"[%[%(%<%-]%s*icecrown",
	"[%[%(%<%-]%s*nova",
	"[%[%(%<%-]%s*oblivion",
	"[%[%(%<%-]%s*pepega",
	"[%[%(%<%-]%s*sylvanas",
	"[%[%(%<%-]%s*twilight",
	"all layer",
	"alle%s*%d+%s*min",
	"armor stack",
	"armorstack",
	"bieten(.-)sanctum",
	"boostgruppe",
	"boost(.-)lvl",
	"boost(.-)level",
	"cant take the spam any longer",
	"csgo",
	"du haltst den spam nicht mehr aus",
	"every%s*%d+%s*min",
	"garona",
	"gear boost",
	"gold only",
	"gp is rdy",
	"gp is ready",
	"group is rdy",
	"group is ready",
	"hc for %d+%s*k",
	"hc fur %d+%s*k",
	"hc%s*=%s*%d+%p*%d*m",
	"heroic%s*=%s*%d+k",
	"in time",
	"intime",
	"kelthuzad%s*%d+%s*k",
	"kelthuzad%s*%d+%s*k",
	"kelthuzad=%d+",
	"key%s*%d+%s*=%s*%d+k",
	"key%s*%d+k",
	"ksm%s*%d+",
	"kt hc%s*%d+%s*k",
	"kt%s*%d+k",
	"last 2",
	"last boss heroic",
	"letzte 2",
	"level%s*boost",
	"level%s*up%s*boost",
	"loot%s*share",
	"lvl%s*boost",
	"lvl%s*up%s*boost",
	"m%+%s*%d+",
	"m%d+%s*+%s*%d+k",
	"m%s*%d+%s*=%s*%d+%s*k",
	"m%s*+%s*%d+%s*%d+k",
	"m+(.-)%d+%s*k",
	"multi%s*runs",
	"mythic%s*[%[%(%<]%s*%d+[-]*%d*",
	"mythic%s*plus(.-)=%d+k",
	"n%s+o%s+v%s+a",
	"normal for %d+%s*k",
	"normal fur %d+%s*k",
	"nur fur gold",
	"nur gold",
	"offer(.-)sanctum",
	"offering(.-)illidan",
	"offering(.-)kt",
	"offering(.-)sylvanas",
	"offering(.-)time-walking",
	"offering(.-)timewalking",
	"omegaboost",
	"only gold",
	"persoloot",
	"personal loot",
	"sale(.-)sod",
	"sale(.-)sylvanas",
	"selling(.-)kelthuzad",
	"selling(.-)sanctum",
	"selling(.-)ksm",
	"selling(.-)keys",
	"selling(.-)dungeons",
	"sells heroic",
	"sylvanas hc%s*%d+%s*k",
	"sylvanas%s*%d+%s*k",
	"sylvanas%s*%d+%s*k",
	"sylvanas=%d+",
	"torghast boost",
	"twilight community",
	"verkaufen(.-)kelthuzad",
	"verkaufen(.-)sanctum",
	"verkauf(.-)heroic",
	"verkauf(.-)heroisch",
	"verkauf(.-)key",
	"verkauf(.-)sanctum",
	"verkauf(.-)sylvanas",
	"verkauf(.-)halondrus",
	"verkauf(.-)lihuvim",
	"verkauf(.-)anduin",
	"verkauf(.-)rygelon",
	"verkauf(.-)lords",
	"verkauf(.-)11/11",
	"verkauf(.-)jailer",
	"vip ab",
	"vip raid",
	"vip trader",
	"viprabatt",
	"wowvendor.net",
	"wowvendor.org",
	"wts%s*keys",
	"wts%s*m%s*%d+",
	"wts%s*shadowlands keystone master",
	"wts(.-)ahead",
	"wts(.-)curve",
	"wts(.-)keystone",
	"wts(.-)m+",
	"wts(.-)mythic",
	"wts(.-)sanctum",
	"wts(.-)secret%s*mount",
	"wts(.-)sylvanas",
	"wts(.-)tazavesh",
	"wts(.-)torghast",
	"wts(.-)boost",
	--"boost", 
}

local a={["[%*%\"!%?`'_%#%%%^&;:~]"]="",["??"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["??"]="",["???"]="",["???"]="",["??"]="",["??"]="",["???"]="",["???"]="",["???"]="",["???"]="",["??"]="",["???"]="",["??"]="",["??"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="e",["??"]="g",["??"]="g",["??"]="g",["??"]="g",["??"]="g",["??"]="g",["??"]="g",["??"]="g",["??"]="h",["??"]="h",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["??"]="i",["???"]="i",["???"]="i",["??"]="j",["??"]="j",["??"]="k",["??"]="k",["??"]="k",["??"]="l",["??"]="l",["??"]="l",["??"]="l",["??"]="l",["??"]="l",["??"]="m",["??"]="m",["???"]="q",["???"]="q",["??"]="n",["??"]="n",["??"]="n",["??"]="n",["??"]="n",["??"]="n",["??"]="n",["??"]="n",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["??"]="o",["???"]="o",["???"]="o",["??"]="p",["??"]="p",["??"]="p",["??"]="p",["??"]="p",["??"]="r",["??"]="r",["??"]="r",["??"]="r",["??"]="r",["??"]="r",["??"]="r",["??"]="r",["??"]="s",["??"]="s",["??"]="s",["??"]="s",["??"]="s",["??"]="s",["??"]="s",["??"]="s",["??"]="s",["??"]="s",["??"]="t",["??"]="t",["??"]="t",["??"]="t",["??"]="t",["??"]="t",["??"]="t",["??"]="t",["??"]="t",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="u",["??"]="w",["??"]="w",["???"]="w",["???"]="w",["???"]="w",["???"]="w",["??"]="w",["??"]="w",["???"]="w",["???"]="w",["???"]="w",["???"]="w",["??"]="y",["??"]="y",["??"]="y",["??"]="y",["???"]="0",["???"]="1",["???"]="2",["???"]="3",["???"]="4",["???"]="5",["???"]="6",["???"]="7",["???"]="8",["???"]="9",["???"]=".",["??"]=".",["???"]=",",["??"]="o",["??"]="r",["???"]="o",["???"]="t",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="a",["??"]="c",["??"]="c",["??"]="c",["??"]="c",["??"]="c",["??"]="c",["??"]="c",["??"]="c",["??"]="c",["??"]="c",["??"]="d",["??"]="d",["??"]="d",["??"]="d",["??"]="n",["??"]="n",["??"]="n",["??"]="n",["??"]="",["|"]="",["??"]="",["??"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["??"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["???"]="",["??"]="",["??"]="",["???"]=""}
local function Cleanmsg(c)c=gsub(c,"|c[^%[]+%[([^%]]+)%]|h|r","%1")c=c:lower()for d,e in next,a do c=gsub(c,d,e)end;return c end

local prevLineId, result

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(_,event,msg,player,_,_,_,flag,chanid,_,_,_,lineId,guid)
	if not AntiBoostSpam.db.global.Enabled then return false end
	if lineId == prevLineId then
			return result
	else
		prevLineId, result = lineId, nil
		if event == "CHAT_MSG_CHANNEL" and (chanid == 0 or type(chanid) ~= "number") then return end
		cleanedmsg = Cleanmsg(msg)
		for i = 1, #blocklist do
			if cleanedmsg:find(blocklist[i]) then 
				if debug then 
					tinsert(LogData,format("%s,%s,%s,%s",date(),blocklist[i],player,msg))
					print("blocked: ",msg)
				end
				result = true
				return true
			end
			
			
		end
		
	end	
end)	