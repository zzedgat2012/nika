package.path = "./src/?.lua;./?.lua;./tests/?.lua;" .. package.path

local runner = require("tests.busted_runner")

local ok = runner.run()
if not ok then
    os.exit(1)
end
