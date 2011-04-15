#!/usr/bin/env python
# Initially from Joey Mukherjee (joey@swri.edu), 2005; heavily modified

"""Provides tools for building Mac OS X bundles."""

from os.path import *

from SCons.Builder import *
from SCons.Script.SConscript import SConsEnvironment

def TOOL_BUNDLE(env):
    if env['PLATFORM'] != 'darwin':
        return
    if 'BUNDLE' in env['TOOLS']:
        return
    env.Append(TOOLS = 'BUNDLE')

    def Bundle(env, app, info_plist="Info.plist", creator='APPL',
               resources=[], frameworks=[], dylibs=[], hasPkgInfo=True, suffix=".app"):
        """Create and populate the structure of a Mac OS X application"""

        if SCons.Util.is_List(app):
            app = app[0]

        if SCons.Util.is_String(app):
            app = env.subst(app)
            appbase = basename(app)
        else:
            appbase = basename(str(app))

        bundledir = env.subst(appbase + suffix)
        contentsdir = join(bundledir, "Contents")
        resourcesdir = join(contentsdir, "Resources")
        frameworksdir = join(contentsdir, "Frameworks")
        bindir = join(contentsdir, "MacOS")

        env.SideEffect(bundledir, app)

        # Install various required files to the .app/Contents
        inst = env.Install(bindir, app)
        inf = env.InstallAs(join(contentsdir, "Info.plist"), info_plist)
        
        if hasPkgInfo:
            env.WriteVal(target=join(contentsdir, "PkgInfo"),
                         source=SCons.Node.Python.Value("APPL" + creator))

        # Install all resources to .app/Contents/Resources
        for r in resources:
            # Compile XIBs, copy the resultant NIB instead
            if r.endswith(".xib"):
                r = env.NIB(r)[0]
            env.Install(resourcesdir, r)
        
        for d in dylibs:
            env.Install(bindir, d)

        # Install included frameworks to .app/Contents/Frameworks
        for r in frameworks:
            env.Install(frameworksdir, r)

        return [SCons.Node.FS.default_fs.Dir(bundledir)]

    SConsEnvironment.Bundle = Bundle
