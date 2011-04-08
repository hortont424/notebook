import os
import SConscripts

SetOption('num_jobs', 8)

VariantDir('Build/Notebook', 'Notebook')
VariantDir('Build/External', 'External')

includes = ["-IExternal/JSON/Classes", "-I/opt/local/include"]
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
    LIBPATH = ["#Build/Notebook",
               "#Build/External/JSON"])

SConscripts.InstallTools(outerEnv)
Export("outerEnv")

# External libraries
libjson = SConscript('Build/External/JSON/SConscript')
lua = SConscript('Build/External/Lua/SConscript')
libraries = ['libjson', 'lua']

# Application
notebook = SConscript('Build/Notebook/SConscript')

# Base Libraries
#libparticles = SConscript('Libraries/build/libparticles/SConscript', libraries)
#libcurve = SConscript('Libraries/build/libcurve/SConscript', libraries)
#libcomputer = SConscript('Libraries/build/libcomputer/SConscript', libraries)
#libraries += ['libcomputer', 'libparticles', 'libcurve']

# High-level Libraries
#librenderer = SConscript('Libraries/build/librenderer/SConscript', libraries)
#libpreviewer = SConscript('Libraries/build/libpreviewer/SConscript', libraries)
#libsimulator = SConscript('Libraries/build/libsimulator/SConscript', libraries)
#libraries += ['librenderer', 'libpreviewer', 'libsimulator']

# Tools
#simulator = SConscript('Simulator/build/SConscript', libraries)
#interpolator = SConscript('Interpolator/build/SConscript', libraries)

#outerEnv.Install('/usr/local/lib', [libjsonc, libparticles, libcurve, libcomputer, librenderer, libpreviewer, libsimulator])
#outerEnv.Alias('install', '/usr/local/lib')
