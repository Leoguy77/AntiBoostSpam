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

local a={["[%*%\"!%?`'_%#%%%^&;:~]"]="",["¨"]="",["”"]="",["“"]="",["▄"]="",["▀"]="",["█"]="",["▓"]="",["▲"]="",["◄"]="",["►"]="",["▼"]="",["♣"]="",["░"]="",["♥"]="",["♫"]="",["●"]="",["■"]="",["☼"]="",["¤"]="",["☺"]="",["↑"]="",["«"]="",["»"]="",["♦"]="",["▌"]="",["▒"]="",["□"]="",["¬"]="",["√"]="",["²"]="",["´"]="",["☻"]="",["★"]="",["☆"]="",["◙"]="",["◘"]="",["▎"]="",["▍"]="",["▂"]="",["▅"]="",["▆"]="",["＋"]="",["‘"]="",["’"]="",["【"]="",["】"]="",["│"]="",["е"]="e",["è"]="e",["é"]="e",["ë"]="e",["ё"]="e",["ê"]="e",["Ę"]="e",["ę"]="e",["Ė"]="e",["ė"]="e",["Ě"]="e",["ě"]="e",["Ē"]="e",["ē"]="e",["Έ"]="e",["έ"]="e",["Ĕ"]="e",["ĕ"]="e",["Ε"]="e",["ε"]="e",["Ğ"]="g",["ğ"]="g",["Ĝ"]="g",["ĝ"]="g",["Ģ"]="g",["ģ"]="g",["Ġ"]="g",["ġ"]="g",["Ĥ"]="h",["ĥ"]="h",["ì"]="i",["í"]="i",["ï"]="i",["î"]="i",["İ"]="i",["ı"]="i",["Ϊ"]="i",["ϊ"]="i",["Ι"]="i",["ι"]="i",["Ί"]="i",["ί"]="i",["Ĭ"]="i",["ĭ"]="i",["Ї"]="i",["ї"]="i",["Į"]="i",["į"]="i",["Ĩ"]="i",["ĩ"]="i",["Ī"]="i",["ī"]="i",["Ｉ"]="i",["ｉ"]="i",["Ĵ"]="j",["ĵ"]="j",["к"]="k",["Ķ"]="k",["ķ"]="k",["Ł"]="l",["ł"]="l",["Ĺ"]="l",["ĺ"]="l",["Ľ"]="l",["ľ"]="l",["Μ"]="m",["м"]="m",["Ｑ"]="q",["ｑ"]="q",["Ń"]="n",["ń"]="n",["Ņ"]="n",["ņ"]="n",["Ň"]="n",["ň"]="n",["Ŋ"]="n",["ŋ"]="n",["о"]="o",["ò"]="o",["ó"]="o",["ö"]="o",["ô"]="o",["õ"]="o",["ø"]="o",["σ"]="o",["Ō"]="o",["ō"]="o",["Ǿ"]="o",["ǿ"]="o",["Ő"]="o",["ő"]="o",["Θ"]="o",["θ"]="o",["Ŏ"]="o",["ŏ"]="o",["Ｏ"]="o",["ｏ"]="o",["р"]="p",["þ"]="p",["φ"]="p",["Ρ"]="p",["ρ"]="p",["г"]="r",["я"]="r",["Ř"]="r",["ř"]="r",["Ŕ"]="r",["ŕ"]="r",["Ŗ"]="r",["ŗ"]="r",["Ş"]="s",["ş"]="s",["Š"]="s",["š"]="s",["Ś"]="s",["ś"]="s",["Ŝ"]="s",["ŝ"]="s",["Ѕ"]="s",["ѕ"]="s",["т"]="t",["Ŧ"]="t",["ŧ"]="t",["Τ"]="t",["τ"]="t",["Ţ"]="t",["ţ"]="t",["Ť"]="t",["ť"]="t",["ù"]="u",["ú"]="u",["ü"]="u",["û"]="u",["Ų"]="u",["ų"]="u",["Ŭ"]="u",["ŭ"]="u",["Ů"]="u",["ů"]="u",["Ű"]="u",["ű"]="u",["Ū"]="u",["ū"]="u",["ω"]="w",["ώ"]="w",["Ẃ"]="w",["ẃ"]="w",["Ẁ"]="w",["ẁ"]="w",["Ŵ"]="w",["ŵ"]="w",["Ẅ"]="w",["ẅ"]="w",["Ｗ"]="w",["ｗ"]="w",["у"]="y",["ý"]="y",["Ÿ"]="y",["ÿ"]="y",["０"]="0",["１"]="1",["２"]="2",["３"]="3",["４"]="4",["５"]="5",["６"]="6",["７"]="7",["８"]="8",["９"]="9",["•"]=".",["·"]=".",["，"]=",",["º"]="o",["®"]="r",["○"]="o",["†"]="t",["а"]="a",["à"]="a",["á"]="a",["ä"]="a",["â"]="a",["ã"]="a",["å"]="a",["Ą"]="a",["ą"]="a",["Ā"]="a",["ā"]="a",["Ă"]="a",["ă"]="a",["с"]="c",["ç"]="c",["Ć"]="c",["ć"]="c",["Č"]="c",["č"]="c",["Ĉ"]="c",["ĉ"]="c",["Ċ"]="c",["ċ"]="c",["Ď"]="d",["ď"]="d",["Đ"]="d",["đ"]="d",["η"]="n",["ή"]="n",["ñ"]="n",["Ν"]="n",["¦"]="",["|"]="",[";"]="",["΅"]="",["™"]="",["。"]="",["◆"]="",["◇"]="",["♠"]="",["△"]="",["¯"]="",["《"]="",["》"]="",["（"]="",["）"]="",["～"]="",["—"]="",["！"]="",["："]="",["·"]="",["˙"]="",["…"]=""}
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