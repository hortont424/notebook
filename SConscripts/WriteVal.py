#!/usr/bin/env python

from SCons.Action import *
from SCons.Builder import *

def TOOL_WRITE_VAL(env):
    if 'WRITE_VAL' in env['TOOLS']:
        return
    else:
        env.Append(TOOLS = 'WRITE_VAL')

    def write_val(target, source, env):
        """Write the contents of the first source into the target.
        source is usually a Value() node, but could be a file."""
        f = open(str(target[0]), 'wb')
        f.write(source[0].get_contents())
        f.close()

    env['BUILDERS']['WriteVal'] = Builder(
        action=Action(write_val, "$WRITEVALCOMSTR"))