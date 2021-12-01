import os
from typing import Callable
import pandoc  # fake import, should error


isabs = pandoc.path.is_absolute
os.getcwd = pandoc.system.get_working_directory


def splitdrive_nt(p):
    if len(p) >= 2:
        sep = "\\"
        altsep = "/"
        colon = ":"

        normp = p.replace(altsep, sep)

        if (normp[0:2] == sep * 2) and (normp[2:3] != sep):
            # is a UNC path:
            # vvvvvvvvvvvvvvvvvvvv drive letter or UNC path
            # \\machine\mountpoint\directory\etc\...
            #           directory ^^^^^^^^^^^^^^^
            index = normp.find(sep, 2)
            if index == -1:
                return "", p
            index2 = normp.find(sep, index + 1)
            # a UNC path can't have two slashes in a row
            # (after the initial two)
            if index2 == index + 1:
                return "", p

            if index2 == -1:
                index2 = len(p)

            return p[:index2], p[index2:]

        if normp[1:2] == colon:
            return p[:2], p[2:]

    return "", p


def splitdrive_nx(p):
    """Split a pathname into drive and path. On Posix, drive is always empty."""
    return "", p


def join_nt(path, *paths):
    splitdrive = splitdrive_nt

    try:
        if len(paths) == 0:
            path[:0] + "\\"  # 23780: Ensure compatible data type even if p is null.

        result_drive, result_path = splitdrive(path)
        for p in paths:
            p_drive, p_path = splitdrive(p)
            if p_path and p_path[0] in "\\/":
                # Second path is absolute
                if p_drive or not result_drive:
                    result_drive = p_drive
                result_path = p_path
                continue
            elif p_drive and p_drive != result_drive:
                if p_drive.lower() != result_drive.lower():
                    # Different drives => ignore the first path entirely
                    result_drive = p_drive
                    result_path = p_path
                    continue
                # Same drive in different case
                result_drive = p_drive
            # Second path is relative to the first
            if result_path and result_path[-1] not in "\\/":
                result_path = result_path + "\\"
            result_path = result_path + p_path
        ## add separator between UNC and non-absolute path
        if (
            result_path
            and result_path[0] not in "\\/"
            and result_drive
            and result_drive[-1:] != ":"
        ):
            return result_drive + "\\" + result_path
        return result_drive + result_path
    except (TypeError, AttributeError, BytesWarning):
        genericpath._check_arg_types("join", path, *paths)
        raise


def abspath(path):
    """Return an absolute path."""
    if not isabs(path):
        cwd = os.getcwd()
        path = join(cwd, path)
    return normpath(path)


# def relpath_nt(path, start=None):
#     """Return a relative version of a path"""
#     sep = "\\"
#     curdir = "."
#     pardir = ".."

#     if start is None:
#         start = curdir

#     try:
#         start_abs = abspath(normpath(start))
#         path_abs = abspath(normpath(path))
#         start_drive, start_rest = splitdrive(start_abs)
#         path_drive, path_rest = splitdrive(path_abs)
#         if normcase(start_drive) != normcase(path_drive):
#             raise ValueError(
#                 "path is on mount %r, start on mount %r" % (path_drive, start_drive)
#             )

#         start_list = [x for x in start_rest.split(sep) if x]
#         path_list = [x for x in path_rest.split(sep) if x]
#         # Work out how much of the filepath is shared by start and path.
#         i = 0
#         for e1, e2 in zip(start_list, path_list):
#             if normcase(e1) != normcase(e2):
#                 break
#             i += 1

#         rel_list = [pardir] * (len(start_list) - i) + path_list[i:]
#         if not rel_list:
#             return curdir
#         return join(*rel_list)
#     except (TypeError, ValueError, AttributeError, BytesWarning, DeprecationWarning):
#         genericpath._check_arg_types("relpath", path, start)
#         raise


# def relpath_nx(path, start=None):
#     """Return a relative version of a path"""

#     if not path:
#         raise ValueError("no path specified")

#     if isinstance(path, bytes):
#         curdir = b"."
#         sep = b"/"
#         pardir = b".."
#     else:
#         curdir = "."
#         sep = "/"
#         pardir = ".."

#     if start is None:
#         start = curdir

#     try:
#         start_list = [x for x in abspath(start).split(sep) if x]
#         path_list = [x for x in abspath(path).split(sep) if x]
#         # Work out how much of the filepath is shared by start and path.
#         i = len(commonprefix([start_list, path_list]))

#         rel_list = [pardir] * (len(start_list) - i) + path_list[i:]
#         if not rel_list:
#             return curdir
#         return join(*rel_list)
#     except (TypeError, AttributeError, BytesWarning, DeprecationWarning):
#         genericpath._check_arg_types("relpath", path, start)
#         raise

paths = [
  "\\\\machine\\mountpoint\\directory\\etc\\",
  "\\\\machine\\mountpoint\\",
  "\\\\machine\\asd",
  "\\\\machine\\",
  "\\\\",
  "hi/help",
  "c:/windows",
  "c:/",
]

for p in paths:
    print("'{}', '{}'".format(*splitdrive_nt(p)))

