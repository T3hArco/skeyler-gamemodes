---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 


require("mysqloo")

DB = mysqloo.connect(DB_HOST, DB_USER, DB_PASS, "skeyler", 3306) 

DB.PreConnectQueries = {} 
DB.Connected = false 

local function LogQuery(Query) -- Logging all queries so we can track problems
	local folder, File = os.date("ss/query_log/%Y/%m"), os.date("%d.txt") 
	local dircheck = ""
	for k,v in pairs(string.Explode("/", folder)) do 
		if !file.IsDir(dircheck.."/"..v, "DATA") then 
			file.CreateDir(dircheck.."/"..v) 
			if k > 1 then dircheck = dircheck.."/"..v else dircheck = v end 
		end 
	end 
	if !file.Exists(folder.."/"..File, "DATA") then file.Write(folder.."/"..File) end 

	file.Append(folder.."/"..File, os.date("[%H:%M:%S] ")..Query.."\n") 
end 

function DB:onConnected() 
	self.Connected = true 
	MsgN("[DATABASE] Successfully connected to the database")  

	-- Lets redo any queries we may have missed
	local time = 0 
	for k,v in pairs(self.PreConnectQueries) do 
		timer.Simple(time, function() DB_Query(v.query, v.SuccessFunc, v.FailFunc) end) 
		time = time+0.1 
	end 
end 

function DB:onConnectionFailed(err) 
	MsgN("[DATABASE] Connection Error:  "..err) 
	MsgN("[DATABASE] Retrying connection in 30 seconds")
	timer.Simple(30, function() MsgN("[DATABASE] Retrying connection") self:connect() end) 
end 

function DB_Query(query, SuccessFunc, FailFunc) 
	if !DB:status() == mysqloo.DATABASE_CONNECTED then DB.Connected = false end 
	if !DB.Connected then table.insert(DB.PreConnectQueries, {query=query, SuccessFunc=SuccessFunc, FailFunc = FailFunc}) return end  
	local Query = DB:query(query) 

	function Query:onSuccess(q, data) 
		if SuccessFunc then SuccessFunc(q) end 
	end 

	function Query:OnError(err, sql) 
		if FailFunc then FailFunc() end 
		Error("[DATABASE] Error QUERY=\""..sql.." ERROR=\""..err.."\"")  
	end 

	LogQuery(query) 
	Query:start()
end 

if DB_DEVS then return end 
DB:connect() 
