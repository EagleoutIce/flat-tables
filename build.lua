#!/usr/bin/env texlua

-- Execute with ======================================================
-- l3build tag
-- l3build ctan
-- l3build upload
-- l3build clean

-- Settings ==========================================================
bundle = ""
module = "flat-tables"
ctanpkg = "flat-tables"
builddir = os.getenv("TMPDIR")

-- Package version ===================================================
local handle = io.popen("git describe --tags $(git rev-list --tags --max-count=1)")
local oldtag = handle:read("*a")
handle:close()
newsubtag = string.sub(oldtag, 4)
newmajortag = string.sub(oldtag, 0, 3)
if (options["target"] == "tag") then
    newsubtag = newsubtag + 1
end
packageversion = newmajortag .. math.floor(newsubtag)
-- packageversion="v1.3"

-- Package date ======================================================
packagedate = os.date("!%Y-%m-%d")
-- packagedate = "2020-01-02"

-- interacting with git ==============================================
function git(...)
    local args = {...}
    table.insert(args, 1, 'git')
    local cmd = table.concat(args, ' ')
    print('Executing:', cmd)
    os.execute(cmd)
end

-- replace version tags in .sty and -doc.tex files ===================
tagfiles = {"*.sty"}
function update_tag(file, content, tagname, tagdate)
    tagdate = string.gsub(packagedate, "-", "/")
    if string.match(file, "%.sty$") then
        content = string.gsub(content, "\\ProvidesPackage{(.-)}%[%d%d%d%d%/%d%d%/%d%d version v%d%.%d+",
            "\\ProvidesPackage{%1}[" .. tagdate .. " version " .. packageversion)
        return content
    end
    return content
end

-- committing retagged file and tag the commit =======================
function tag_hook(tagname)
    git("add", "*.sty")
    git("commit -m 'step version " .. packageversion .. "'")
    git("tag", packageversion)
end

-- collecting files for ctan =========================================
docfiles = {"flat-tables.dtx"}

textfiles = {"README.md"}
ctanreadme = "README.md"

installfiles = {module .. ".dtx", module .. ".ins"}
sourcefiles = installfiles

-- Release a TDS-style zip
packtdszip = false

-- Preserve structure for CTAN
flatten = true

-- configuring ctan upload ===========================================
require('build-private.lua')

uploadconfig = {
    author = uploadconfig.author,
    uploader = uploadconfig.uploader,
    email = uploadconfig.email,
    pkg = ctanpkg,
    version = packageversion .. " " .. packagedate,
    license = "gpl3.0",
    summary = "Flat-Tables with LaTeX",
    ctanPath = "/graphics/pgf/contrib/" .. ctanpkg,
    repository = "https://github.com/EagleoutIce/" .. module,
    note = [[Uploaded automatically by l3build...]],
    bugtracker = "https://github.com/EagleoutIce/" .. module .. "/issues",
    support = "https://github.com/EagleoutIce/" .. module .. "/issues",
    announcement_file = "announcement.txt"
}

-- cleanup ===========================================================
cleanfiles = {"flat-tables-ctan.curlopt", "flat-tables-ctan.zip"}
