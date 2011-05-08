#!/usr/bin/env python

def TOOL_PRETTY_PRINT(env):
    if 'PRETTY_PRINT' in env['TOOLS']:
        return
    else:
        env.Append(TOOLS = 'PRETTY_PRINT')

    greenColor = '\033[92m'
    yellowColor = '\033[93m'
    resetColor = '\033[0m'

    def message(mes, source=True):
        if source:
            color = greenColor
            fileVar = '$SOURCE'
        else:
            color = yellowColor
            fileVar = '$TARGET'

        return '%s%s: %s%s' % (color, mes, resetColor, fileVar)

    env.Replace(
        CCCOMSTR = message("Compiling object"),
        SHCCCOMSTR = message("Compiling shared object"),
        ARCOMSTR = message("Linking static library", False),
        SHLINKCOMSTR = message("Linking shared library", False),
        LINKCOMSTR = message("Linking program", False),
        LDMODULECOMSTR = message("Linking module", False),
        INSTALLSTR = message("Copying"),
        IBTOOLCOMSTR = message("Compiling XIB"),
        WRITEVALCOMSTR = message("Writing value to file", False),
        LATEXCOMSTR = message("Rendering LaTeX file"),
        INLINECLKERNELCOMSTR = message("Inlining CL kernels", False),
        RANLIBCOMSTR = message("Generating archive index", False))

    return env