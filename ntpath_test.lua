local path = require "ntpath"
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


-- test_join
test.strings(path.join(""), '')
test.strings(path.join("", "", ""), '')
test.strings(path.join("a"), 'a')
test.strings(path.join("/a"), '/a')
test.strings(path.join("\\a"), '\\a')
test.strings(path.join("a:"), 'a:')
test.strings(path.join("a:", "\\b"), 'a:\\b')
test.strings(path.join("a", "\\b"), '\\b')
test.strings(path.join("a", "b", "c"), 'a\\b\\c')
test.strings(path.join("a\\", "b", "c"), 'a\\b\\c')
test.strings(path.join("a", "b\\", "c"), 'a\\b\\c')
test.strings(path.join("a", "b", "\\c"), '\\c')
test.strings(path.join("d:\\", "\\pleep"), 'd:\\pleep')
test.strings(path.join("d:\\", "a", "b"), 'd:\\a\\b')

test.strings(path.join('', 'a'), 'a')
test.strings(path.join('', '', '', '', 'a'), 'a')
test.strings(path.join('a', ''), 'a\\')
test.strings(path.join('a', '', '', '', ''), 'a\\')
test.strings(path.join('a\\', ''), 'a\\')
test.strings(path.join('a\\', '', '', '', ''), 'a\\')
test.strings(path.join('a/', ''), 'a/')

test.strings(path.join('a/b', 'x/y'), 'a/b\\x/y')
test.strings(path.join('/a/b', 'x/y'), '/a/b\\x/y')
test.strings(path.join('/a/b/', 'x/y'), '/a/b/x/y')
test.strings(path.join('c:', 'x/y'), 'c:x/y')
test.strings(path.join('c:a/b', 'x/y'), 'c:a/b\\x/y')
test.strings(path.join('c:a/b/', 'x/y'), 'c:a/b/x/y')
test.strings(path.join('c:/', 'x/y'), 'c:/x/y')
test.strings(path.join('c:/a/b', 'x/y'), 'c:/a/b\\x/y')
test.strings(path.join('c:/a/b/', 'x/y'), 'c:/a/b/x/y')
test.strings(path.join('//computer/share', 'x/y'), '//computer/share\\x/y')
test.strings(path.join('//computer/share/', 'x/y'), '//computer/share/x/y')
test.strings(path.join('//computer/share/a/b', 'x/y'), '//computer/share/a/b\\x/y')

test.strings(path.join('a/b', '/x/y'), '/x/y')
test.strings(path.join('/a/b', '/x/y'), '/x/y')
test.strings(path.join('c:', '/x/y'), 'c:/x/y')
test.strings(path.join('c:a/b', '/x/y'), 'c:/x/y')
test.strings(path.join('c:/', '/x/y'), 'c:/x/y')
test.strings(path.join('c:/a/b', '/x/y'), 'c:/x/y')
test.strings(path.join('//computer/share', '/x/y'), '//computer/share/x/y')
test.strings(path.join('//computer/share/', '/x/y'), '//computer/share/x/y')
test.strings(path.join('//computer/share/a', '/x/y'), '//computer/share/x/y')

test.strings(path.join('c:', 'C:x/y'), 'C:x/y')
test.strings(path.join('c:a/b', 'C:x/y'), 'C:a/b\\x/y')
test.strings(path.join('c:/', 'C:x/y'), 'C:/x/y')
test.strings(path.join('c:/a/b', 'C:x/y'), 'C:/a/b\\x/y')

for _, x in ipairs({'', 'a/b', '/a/b', 'c:', 'c:a/b', 'c:/', 'c:/a/b', '//computer/share', '//computer/share/', '//computer/share/a/b'}) do
  for _,y in ipairs({'d:', 'd:x/y', 'd:/', 'd:/x/y', '//machine/common', '//machine/common/', '//machine/common/x/y'}) do
    test.strings(path.join(x, y), y)
  end
end

test.strings(path.join('\\\\computer\\share\\', 'a', 'b'), '\\\\computer\\share\\a\\b')
test.strings(path.join('\\\\computer\\share', 'a', 'b'), '\\\\computer\\share\\a\\b')
test.strings(path.join('\\\\computer\\share', 'a\\b'), '\\\\computer\\share\\a\\b')
test.strings(path.join('//computer/share/', 'a', 'b'), '//computer/share/a\\b')
test.strings(path.join('//computer/share', 'a', 'b'), '//computer/share\\a\\b')
test.strings(path.join('//computer/share', 'a/b'), '//computer/share\\a/b')
