local sandwich = require("src/init_2")

local schedule = sandwich.schedule()

local a = schedule.job(function(...) print("a", ...) end)
local b = schedule.job(function(...) print("b", ...) end)
local c = schedule.job(function(...) print("c", ...) end, b)
local d = schedule.job(function(...) print("d", ...) end, a, b)
local e = schedule.job(function(...) print("e", ...) end, c, d)
local f = schedule.job(function(...) print("f", ...) end, e, b, c)

table.insert(schedule.job_dependencies[a], c)

schedule.start("Hello")
