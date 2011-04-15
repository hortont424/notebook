import PrettyPrint
import Bundle
import WriteVal
import NIB
import InlineCLKernel

from SCons.Environment import *

def InstallTools(env):
    WriteVal.TOOL_WRITE_VAL(env)
    NIB.TOOL_NIB(env)
    Bundle.TOOL_BUNDLE(env)
    PrettyPrint.TOOL_PRETTY_PRINT(env)
    InlineCLKernel.TOOL_INLINE_CL_KERNEL(env)
    return env