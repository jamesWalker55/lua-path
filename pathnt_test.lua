local path = require "pathnt"
local test = require "test"


-- test_splitext
test.lists({path.splitext("foo.ext")}, {'foo', '.ext'})
test.lists({path.splitext("/foo/foo.ext")}, {'/foo/foo', '.ext'})
test.lists({path.splitext(".ext")}, {'.ext', ''})
test.lists({path.splitext("\\foo.ext\\foo")}, {'\\foo.ext\\foo', ''})
test.lists({path.splitext("foo.ext\\")}, {'foo.ext\\', ''})
test.lists({path.splitext("")}, {'', ''})
test.lists({path.splitext("foo.bar.ext")}, {'foo.bar', '.ext'})
test.lists({path.splitext("xx/foo.bar.ext")}, {'xx/foo.bar', '.ext'})
test.lists({path.splitext("xx\\foo.bar.ext")}, {'xx\\foo.bar', '.ext'})
test.lists({path.splitext("c:a/b\\c.d")}, {'c:a/b\\c', '.d'})


-- test_splitdrive
test.lists({path.splitdrive("c:\\foo\\bar")}, {'c:', '\\foo\\bar'})
test.lists({path.splitdrive("c:/foo/bar")}, {'c:', '/foo/bar'})
test.lists({path.splitdrive("\\\\conky\\mountpoint\\foo\\bar")}, {'\\\\conky\\mountpoint', '\\foo\\bar'})
test.lists({path.splitdrive("//conky/mountpoint/foo/bar")}, {'//conky/mountpoint', '/foo/bar'})
test.lists({path.splitdrive("\\\\\\conky\\mountpoint\\foo\\bar")}, {'', '\\\\\\conky\\mountpoint\\foo\\bar'})
test.lists({path.splitdrive("///conky/mountpoint/foo/bar")}, {'', '///conky/mountpoint/foo/bar'})
test.lists({path.splitdrive("\\\\conky\\\\mountpoint\\foo\\bar")}, {'', '\\\\conky\\\\mountpoint\\foo\\bar'})
test.lists({path.splitdrive("//conky//mountpoint/foo/bar")}, {'', '//conky//mountpoint/foo/bar'})
-- Issue #19911: UNC part containing U+0130
test.lists({path.splitdrive('//conky/MOUNTPOİNT/foo/bar')}, {'//conky/MOUNTPOİNT', '/foo/bar'})
