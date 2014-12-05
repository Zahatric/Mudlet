
CommandBytes = {
	nameChange = "\1", 
  requestConnections = "\2",
  chatConnectionList = "\3",
	all = "\4",
	pm = "\5",
  group = "\6",
	message = "\7",
  doNotDistrub = "\8",
	version = "\19",
	pingRequest = "\26",
	pingResponse = "\27",
  terminator = "\255",
  acceptConn = "Y"
}

ChatClientName="FuckChat v0"
ChatName="Costic"

function pushChatStack(f)
  if (commandStack) then
    table.insert(commandStack,f)
    commandStack[0] = commandStack[0] + 1
  else 
    commandStack = {}
    table.insert(commandStack,f)
    commandStack[0] = 1
  end
end

function popChatStack()
  if (commandStack) then
    if (commandStack[0]>0) then
    local ret = table.remove(commandStack,commandStack[0])
    commandStack[0] = commandStack[0] - 1
    return ret
    end
  else 
    return nil
  end
end

function executeChatStack()
  local command = popChatStack()
  if (command) then
    executeChatStack()
  end
end


--local strstrtest = "Costic \029[0m[\029[0;37;46m    \029[0m]\029[1;32m test \029[0m[\029[0;37;46m    \029[0m]\029[0m\029[0;37;46m\029[0m\029[1;32m\029[0m\029[0;37;46m\029[0m"

function callit (host, port)
  socket = require("socket");
	connection = socket.tcp();
  connection:connect(host, port)
--TODO Remove mudlet specific call and replace with MQ
	enableTimer("chatreader")
--TODO add chat name support here
  sendIt("CHAT:"..ChatName.."\n127.0.0.15555\255")
	return
end

function recieveIt()
  connection:settimeout(0)
  connection:setoption('keepalive',true)
--TODO replace s with more meaningful name
  local s, status, partial = connection:receive('*a')
  if status == "closed" then 
  	closeIt()
		return
  end 
  if s then
--sometimes the OS will return multiple chats in one read
--this splits them on the chat terminator, then calls a parse
--agsinst every chat message in a loop
  	for k, v in pairs(Split(s,"\255")) do 
--since the split was performed on the terminator append it back to 
--the end for processing
		  processChat(v.."\255")
		end
 	end
  if partial and #partial > 0 then
  	for k, v in pairs(Split(partial,"\255")) do 
--since the split was performed on the terminator append it back to 
--the end for processing
		  processChat(v.."\255")
		end
  end
  return
end

function closeIt()
  connection:close()
  cecho("<red><CHAT> Connection Closed")
  --TODO remove reference 
  disableTimer("chatreader")
  return
end

function sendIt(istring)
  connection:send(istring)
end

function processChat(istring)
  local Commands = { }
  
  for name, byte in pairs( CommandBytes ) do
    Commands[ byte ] = name
  end
  local commandByte, args = string.match(istring, "^(.)(.*)\255$" )
  local command = Commands[ commandByte ]
  if command == "pingRequest" then
    sendIt(CommandBytes["pingResponse"]..args..CommandBytes["terminator"])
  elseif command == "all" then
    displayMsg(args)
  elseif command == "pm" then
    displayMsg(args)
  elseif command == "message" then
    displayMsg(args)
  elseif command == "version" then
    cecho("<cyan> Got version request")
  elseif command == "acceptConn" then 
    cecho("<red><CHAT> Connection Accepted\n")
    local lastchat = string.gsub(args,"ES:.+\n","")
    processChat(lastchat.."\255")
    sendVersion()
  end
  return
end

function displayMsg(str)
  --remove leading new lines
  res = string.gsub(str,"^\n","")
  feedTriggers("\27[0;1;31;40m>"..res.."\n")
  print(" ")
end

function ansiColortoTag(sss)
  local str = string.gsub(sss,"~~~%[","")
  local cnt = ""
  local res = ""
  echo(sss)
  if string.match(str,"^%d+m") then
    res = ansiOne(str)
  elseif string.match(str,"^%d+;%d+m") then
    res = ansiTwo(str)
  elseif string.match(str,"^%d+;%d+;%d+m") then
    res = ansiThree(str)
  else
  end
  return res
end


function ansiOne(istring)

  local boldColors = {}
  boldColors["30"] = "<pink>"
  boldColors["31"] = "<red>"
  boldColors["32"] = "<green>"
  boldColors["33"] = "<yellow>"
  boldColors["34"] = "<blue>"
  boldColors["35"] = "<magenta>"
  boldColors["36"] = "<cyan>"
  boldColors["37"] = "<orange>"
  
  local darkColors = {}
  darkColors["30"] = "<black>"
  darkColors["31"] = "<firebrick>"
  darkColors["32"] = "<dark_green>"
  darkColors["33"] = "<gold>"
  darkColors["34"] = "<navy>"
  darkColors["35"] = "<dark_violet>"
  darkColors["36"] = "<CadetBlue>"
  darkColors["37"] = "<purple>"
  local res = ""
  local a = string.gsub(istring,"^(%d+)m","%1")
  if a == "0" then 
    res = "<reset>"
  elseif a == "1" then 
    res = ""
  else
    res = boldColors[a]
  end
  return res
end
       -- case 0: c = pHost->mFgColor;  break;
       -- case 1: c = pHost->mLightBlack; break;
       -- case 2: c = pHost->mBlack; break;
       -- case 3: c = pHost->mLightRed; break;
       -- case 4: c = pHost->mRed; break;
       -- case 5: c = pHost->mLightGreen; break;
       -- case 6: c = pHost->mGreen; break;
       -- case 7: c = pHost->mLightYellow; break;
       -- case 8: c = pHost->mYellow; break;
       -- case 9: c = pHost->mLightBlue; break;
       -- case 10: c = pHost->mBlue; break;
       -- case 11: c = pHost->mLightMagenta; break;
       -- case 12: c = pHost->mMagenta; break;
       -- case 13: c = pHost->mLightCyan; break;
       -- case 14: c = pHost->mCyan; break;
       -- case 15: c = pHost->mLightWhite; break;
       -- case 16: c = pHost->mWhite; break;
       --
--/* ANSI color codes: sequence = "ESCAPE + [ code_1; ... ; code_n m"
--      -----------------------------------------
--      0 reset
--      1 intensity bold on
--      2 intensity faint
--      3 italics on
--      4 underline on
--      5 blink slow
--      6 blink fast
--      7 inverse on
--      9 strikethrough
--      10 ? TODO
--      22 intensity normal (not bold, not faint)
--      23 italics off
--      24 underline off
--      27 inverse off
--      28 strikethrough off
--      30 fg black
--      31 fg red
--      32 fg green
--      33 fg yellow
--      34 fg blue
--      35 fg magenta
--      36 fg cyan
--      37 fg white
--      39 bg default white
--      40 bg black
--      41 bg red
--      42 bg green
--      43 bg yellow
--      44 bg blue
--      45 bg magenta
--      46 bg cyan
--      47 bg white
--      49 bg black FIXME: add
--
--      sequences for 256 Color support:
--      38;5;0-256 foreground color
--      48;5;0-256 background color */


function sendChatAll(istring)
  local	str = CommandBytes["all"]..istring..CommandBytes["terminator"]
  processChat(str)
  echo("\n")
  sendIt(str)
  return 
end

function sendChatPM(istring)
  local	str = CommandBytes["pm"].."\nchats to you, '"..istring.."'\n"..CommandBytes["terminator"]
  echo("\n")
  sendIt(str)
  return 
end

function sendVersion()
  sendIt(CommandBytes["version"]..ChatClientName..CommandBytes["terminator"])
  echo("sent version")
  return
end

function HexDumpString(str,spacer)
  return (string.gsub(str,"(.)",function (c)
    return string.format("%02X%s",string.byte(c), spacer or "")
  end)
  )
end

-- Compatibility: Lua-5.0
function Split(str, delim, maxNb)
  -- Eliminate bad cases...
  if string.find(str, delim) == nil then
    return { str }
  end
  if maxNb == nil or maxNb < 1 then
    maxNb = 0    -- No limit
  end
  local result = {}
  local pat = "(.-)" .. delim .. "()"
  local nb = 0
  local lastPos
  for part, pos in string.gfind(str, pat) do
    nb = nb + 1
    result[nb] = part
    lastPos = pos
  if nb == maxNb then break end
  end
  -- Handle the last field
  if nb ~= maxNb then
    result[nb + 1] = string.sub(str, lastPos)
  end
  return result
end


