local file_manager = require("file_manager")
local file_storage = require("file_storage")

describe("File manager (Phase 12)", function()
    before_each(function()
        local registry = file_storage.new_registry(file_storage.new_local({ root_dir = "uploads_test" }))
        file_manager.set_registry(registry)
    end)

    it("processa e armazena arquivos validados", function()
        local files, err = file_manager.process_files({
            {
                field = "doc",
                filename = "invoice.pdf",
                content_type = "application/pdf",
                data = "abc",
                size = 3
            }
        })

        assert.is_not_nil(files)
        assert.is_nil(err)
        assert.are.equal(1, #files)
        assert.is_not_nil(files[1].id)
    end)

    it("bloqueia upload invalido", function()
        local files, err = file_manager.process_files({
            {
                field = "doc",
                filename = "../../bad.exe",
                content_type = "application/x-msdownload",
                data = "abc",
                size = 3
            }
        })

        assert.is_nil(files)
        assert.is_not_nil(err)
    end)
end)
