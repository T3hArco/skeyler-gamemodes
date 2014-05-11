---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

require("mysqloo")

DB = mysqloo.connect(DB_HOST, DB_USER, DB_PASS, "skeyler", 3306) 

DB.PreConnectQueries = {} 
DB.Connected = false 
DB.Fails = 0 

local function LogQuery(Query) -- Logging all queries so we can track problems
	local folder, File = os.date("ss/query_log/%Y/%m"), os.date("%d.txt") 
	local dircheck = ""
	for k,v in pairs(string.Explode("/", folder)) do 
		if !file.IsDir(dircheck.."/"..v, "DATA") then 
			if k > 1 then dircheck = dircheck.."/"..v else dircheck = v end 
			file.CreateDir(dircheck) 
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
	DB.Fails = DB.Fails + 1 
	if DB.Fails > 3 then return end 
	LogQuery("Connection Error:  "..err) 
	MsgN("[DATABASE] Connection Error:  "..err) 
	MsgN("[DATABASE] Retrying connection in 60 seconds")
	timer.Simple(60, function() MsgN("[DATABASE] Retrying connection") self:connect() end) 
end 

function DB_Query(query, SuccessFunc, FailFunc) 
	if !DB.Connected then table.insert(DB.PreConnectQueries, {query=query, SuccessFunc=SuccessFunc, FailFunc = FailFunc}) return end  
	LogQuery(query) 
	local Query = DB:query(query) 

	function Query:onSuccess(q, data) 
		if SuccessFunc then SuccessFunc(q) end 
	end 

	function Query:onError(err, sql) 
		LogQuery("[ERROR] QUERY=\""..sql.." ERROR=\""..err.."\"")
		Error("[DATABASE] Error QUERY=\""..sql.." ERROR=\""..err.."\"")  
		if DB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			DB.Connected = false
			
			table.insert(DB.PreConnectQueries, {query=sql, SuccessFunc=SuccessFunc, FailFunc = FailFunc})
			DB:connect()
			return
		end
		if FailFunc then FailFunc() end 
	end 

	Query:start()
end 

if DB_DEVS then return end 
DB:connect()
-- SS.Punishments:LoadPunishments()
