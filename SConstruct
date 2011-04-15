import os
import SConscripts

SetOption('num_jobs', 8)

VariantDir('Build/Notebook', 'Notebook')
VariantDir('Build/External', 'External')
VariantDir('Build/Languages', 'Languages')

globalFlags = ["-std=c99", "-Wall", "-fobjc-gc"]
CFlags = globalFlags + []
linkFlags = globalFlags + []

releaseCFlags = CFlags + ["-O4"]
debugCFlags = CFlags + ["-g"]

releaseLinkFlags = linkFlags + ["-O4"]
debugLinkFlags = linkFlags + ["-g"]

buildMode = ARGUMENTS.get("mode", "debug")

if buildMode == "debug":
    CCFLAGS = debugCFlags
    LDFLAGS = debugLinkFlags
elif buildMode == "release":
    CCFLAGS = releaseCFlags
    LDFLAGS = releaseLinkFlags
else:
    print "Error: unknown build mode: %s" % buildMode
    exit()

print "=== Building in %s mode ===" % buildMode

outerEnv = Environment(
    ENV = { "PATH": os.environ['PATH'] },
    CC = "clang",
    FRAMEWORKPATH = ["External"],
    CCFLAGS = CCFLAGS,
    LDFLAGS = LDFLAGS,
    CPPPATH = ["#Build/External"],
    LIBPATH = ["#Build/Notebook",
               "#Build/External/JSON"])

SConscripts.InstallTools(outerEnv)
Export("outerEnv")

# External libraries
libjson = SConscript('Build/External/JSON/SConscript')

# Application
notebookapp, notebooklib, notebook = SConscript('Build/Notebook/SConscript', ["libjson"])

# Languages

## Python
python = SConscript('Build/Languages/Python/SConscript', ['notebooklib'])

## Ruby

## Lua

liblua = SConscript('Build/External/Lua/SConscript')

# Install Language PlugIns

plugindir = os.path.join(outerEnv.GetBuildPath(notebookapp)[0], "Contents", "PlugIns")

outerEnv.Install(plugindir, python)