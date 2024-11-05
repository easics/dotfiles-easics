
sources = gdb.execute("info sources", False, True)
sources = sources.split(",")

for source in sources:
    moresources = source.strip().split() # split on whitespace
    for moresource in moresources:
        moresource = moresource.strip()
        if moresource.startswith("/usr") or \
           moresource.startswith("/home_leuven") or \
           moresource.startswith("/asic_leu") or \
           moresource.find("mambaforge") != -1:
            gdb.execute("skip file {0}".format(moresource))

moreskips = [ "../../../../*/libstdc++-v3/libsupc++/dyncast.cc",
        ]
for skip in moreskips:
    gdb.execute("skip -gfi {0}".format(skip))
