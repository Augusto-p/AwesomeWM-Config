-- database.lua
local sqlite3 = require("lsqlite3")

local DatabaseManager = {}

function DatabaseManager:new(db_path)
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    self.db_path = db_path
    self.conn = sqlite3.open(db_path)
    return instance
end

-- NO Pensada Para Lua
function DatabaseManager:create_tables()
    -- Create Apps table
    local apps_table = [[
    CREATE TABLE IF NOT EXISTS Apps (
        ID           INTEGER PRIMARY KEY AUTOINCREMENT,
        Name         TEXT NOT NULL,
        Coment       TEXT,
        Generic_Name TEXT,
        Icon         TEXT NOT NULL,
        Exec         TEXT NOT NULL,
        File         TEXT NOT NULL UNIQUE,
        Usos         INTEGER DEFAULT 0
    );]]

    -- Create Actions table
    local actions_table = [[
    CREATE TABLE IF NOT EXISTS Actions (
        APP  INTEGER REFERENCES Apps(ID) ON DELETE CASCADE ON UPDATE CASCADE,
        Name TEXT NOT NULL,
        Exec TEXT NOT NULL,
        PRIMARY KEY (APP, Name)
    );]]

    self.conn:exec(apps_table)
    self.conn:exec(actions_table)
end
-- NO Pensada Para Lua
function DatabaseManager:insert_app(name, coment, generic_name, icon, exec_cmd, file)
    local stmt = self.conn:prepare([[INSERT INTO Apps (Name, Coment, Generic_Name, Icon, Exec, File) VALUES (?, ?, ?, ?, ?, ?)]]);
    stmt:bind_values(name, coment, generic_name, icon, exec_cmd, file)
    local status = stmt:step()
    stmt:finalize()

    if status ~= sqlite3.DONE then
        error("Error inserting app: " .. self.conn:errmsg())
    end
    return self.conn:last_insert_rowid()
end
-- NO Pensada Para Lua
function DatabaseManager:insert_action(app_id, name, exec_cmd)
    local stmt = self.conn:prepare([[INSERT INTO Actions (APP, Name, Exec) VALUES (?, ?, ?)]]);
    stmt:bind_values(app_id, name, exec_cmd)
    local status = stmt:step()
    stmt:finalize()

    if status ~= sqlite3.DONE then
        error("Error inserting action: " .. self.conn:errmsg())
    end
end

function DatabaseManager:get_apps()
    local apps = {}
    for row in self.conn:nrows([[SELECT Apps.ID, Apps.Name, Apps.Coment, Apps.Generic_Name, Apps.Icon, Apps.Exec,
                                CASE WHEN EXISTS (SELECT 1 FROM Actions WHERE Actions.APP = Apps.ID) THEN 1 ELSE 0 END AS HasActions
                                FROM Apps;]]) do
        table.insert(apps, row)
    end
    return apps
end

-- NO Pensada Para Lua
function DatabaseManager:get_all_files()
    local files = {}
    for row in self.conn:nrows([[SELECT File FROM Apps]]) do
        table.insert(files, row.File)
    end
    return files
end

-- NO Pensada Para Lua
function DatabaseManager:delete_app_by_file(file)
    local delete_actions = [[DELETE FROM Actions WHERE APP = (SELECT ID FROM Apps WHERE File = ?);]]
    local delete_app = [[DELETE FROM Apps WHERE File = ?;]]

    local stmt1 = self.conn:prepare(delete_actions)
    stmt1:bind_values(file)
    stmt1:step()
    stmt1:finalize()

    local stmt2 = self.conn:prepare(delete_app)
    stmt2:bind_values(file)
    stmt2:step()
    stmt2:finalize()
end

function DatabaseManager:get_top_apps(top)
    local apps = {}
    local query = [[SELECT Apps.ID, Apps.Name, Apps.Coment, Apps.Generic_Name, Apps.Icon, Apps.Exec,
                    CASE WHEN EXISTS (SELECT 1 FROM Actions WHERE Actions.APP = Apps.ID) THEN 1 ELSE 0 END AS HasActions
                    FROM Apps
                    ORDER BY Apps.Usos DESC
                    LIMIT ?;]]
    local stmt = self.conn:prepare(query)
    stmt:bind_values(top)
    for row in stmt:nrows() do
        table.insert(apps, row)
    end
    stmt:finalize()
    return apps
end

function DatabaseManager:new_use(app_id)
    local stmt = self.conn:prepare([[UPDATE Apps SET Usos = Usos + 1 WHERE ID = ?]]);
    stmt:bind_values(app_id)
    stmt:step()
    stmt:finalize()
end

function DatabaseManager:search(q, limit)
    local results = {}
    local query = [[SELECT Apps.ID, Apps.Name, Apps.Coment, Apps.Generic_Name, Apps.Icon, Apps.Exec,
                    CASE WHEN EXISTS (SELECT 1 FROM Actions WHERE Actions.APP = Apps.ID) THEN 1 ELSE 0 END AS HasActions
                    FROM Apps
                    WHERE Apps.Name LIKE '%' || ? || '%'
                    OR Apps.Coment LIKE '%' || ? || '%'
                    OR Apps.Generic_Name LIKE '%' || ? || '%'
                    OR EXISTS (SELECT 1 FROM Actions WHERE Actions.APP = Apps.ID AND Actions.Name LIKE '%' || ? || '%')
                    ORDER BY Apps.Usos DESC LIMIT ?;]]
    local stmt = self.conn:prepare(query)
    stmt:bind_values(q, q, q, q, limit)
    for row in stmt:nrows() do
        table.insert(results, row)
    end
    stmt:finalize()
    return results
end

function DatabaseManager:get_actions_by_id(app_id)
    local actions = {}
    local query = [[SELECT APP, Name, Exec FROM Actions WHERE APP = ?;]]
    local stmt = self.conn:prepare(query)
    stmt:bind_values(app_id)
    for row in stmt:nrows() do
        table.insert(actions, row)
    end
    stmt:finalize()
    return actions
end

function DatabaseManager:close()
    self.conn:close()
end

return DatabaseManager
