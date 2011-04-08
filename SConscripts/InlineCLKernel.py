#!/usr/bin/env python

import os

from SCons.Action import *
from SCons.Builder import *

def TOOL_INLINE_CL_KERNEL(env):
    if 'INLINE_CL_KERNEL' in env['TOOLS']:
        return
    else:
        env.Append(TOOLS = 'INLINE_CL_KERNEL')

    def inline_cl_kernel(target, source, env):
        f = open(str(target[0]), 'wb')
        for clfile in source:
            kname = os.path.basename(str(clfile)).replace(".cl", "")
            kernelString = clfile.get_contents()
            kernelString = kernelString.replace('"', '\\"')
            lines = ['"' + s + '\\n" \\' for s in kernelString.split("\n")]
            kernelString = "const char * SMKernelSource_" + kname + " = "
            kernelString += "\n".join(lines)
            f.write(kernelString + "\n\"\";\n\n")
        f.close()

    env['BUILDERS']['InlineCLKernel'] = Builder(
        action=Action(inline_cl_kernel, "$INLINECLKERNELCOMSTR"))