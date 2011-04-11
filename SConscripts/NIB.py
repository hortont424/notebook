#!/usr/bin/env python

import os

from SCons.Action import *
from SCons.Builder import *

def TOOL_NIB(env):
    if 'NIB' in env['TOOLS']:
        return
    else:
        env.Append(TOOLS = 'NIB')

    def nib(target, source, env):
        args = "--errors --output-format human-readable-text"

        if "IBPLUGINSPATH" in env:
            for plugin in env["IBPLUGINSPATH"]:
                args += " --plugin-dir %s" % plugin

        os.system("ibtool %s --compile %s %s" % (args, target[0], source[0]))

    env['BUILDERS']['NIB'] = Builder(
        action = Action(nib, "$IBTOOLCOMSTR"),
        suffix = ".nib",
        src_suffix = ".xib")
