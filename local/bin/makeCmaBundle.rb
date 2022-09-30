#! /usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'pp'
require 'fileutils'

options = OpenStruct.new
options.makefile = ""
options.output = "cma_bundle"
options.native = false

OptionParser.new do |opts|
  opts.banner = "Usage: makecmabundle.rb [options]"

  opts.on("-f", "--file makefile", "Makefile to use") do |m|
    options.makefile = m
  end
  opts.on("-o", "--output-dir directory", "Output directory") do |d|
    options.output = d
  end
  opts.on("--native", "Use native compiler/linker") do |n|
    options.native = n
  end
end.parse!

headers_string = `make -f #{options.makefile} printvar VAR=HEADERS`
sources_string = `make -f #{options.makefile} printvar VAR=ALL_SOURCES`
if options.native then
  cc = 'gcc'
  ccc = 'g++'
  linker = 'g++'
else
  cc = `make -f #{options.makefile} printvar VAR=CC`
  ccc = `make -f #{options.makefile} printvar VAR=CCC`
  linker = `make -f #{options.makefile} printvar VAR=LINKER`
end
cflags = `make -f #{options.makefile} printvar VAR=CFLAGS`
ldflags = `make -f #{options.makefile} printvar VAR=LDFLAGS`
exename = `make -f #{options.makefile} printvar VAR=EXENAME`

FileUtils.mkdir_p(options.output)
headers_string.split(' ').each { |h|
  FileUtils.cp(h, options.output)
}
sources = sources_string.split ' '
sources_makefile = []
sources.each { |s|
  FileUtils.cp(s, options.output)
  sources_makefile << File.basename(s)
}
File.write("#{options.output}/Makefile", <<EOF
ifndef VERBOSE
.SILENT:
endif

OBJDIR := objects
DEPDIR := objects
BINDIR := .

SOURCES := #{sources_makefile.join(" \\\n  ")}
OBJECTS_WRONG_DIR := $(foreach source, $(SOURCES), $(basename $(source)).o)
OBJECTS := $(addprefix $(OBJDIR)/, $(OBJECTS_WRONG_DIR))
DEPS_WRONG_DIR := $(OBJECTS_WRONG_DIR:.o=.d)
DEPENDENCIES := $(addprefix $(DEPDIR)/, $(DEPS_WRONG_DIR))
EXENAME := #{exename}
CC := #{cc}
CCC := #{ccc}
LINKER := #{linker}
CFLAGS := #{cflags}
LDFLAGS := #{ldflags}

TARGET := $(BINDIR)/$(EXENAME)
LEX := flex
YACC := bison
MOC := moc
MAKEDEPEND := $(CC) -MM
CXXFLAGS := $(CFLAGS)
CPPFLAGS := $(CFLAGS)

define mkdir_target
test -d $(@D) \\
  || ( echo "Creating directory $(@D)" && mkdir -p $(@D) ) \\
  || echo Unable to create $(@D); 
endef

$(TARGET) : $(OBJECTS)
	$(mkdir_target)
	@echo Linking $@
	$(LINKER) -o $@ $(filter %.o, $^) $(LDFLAGS)

clean:
	@echo Removing objects
	-rm -f $(OBJECTS) > /dev/null 2>&1
	@echo Removing dependencies
	-rm -f $(DEPENDENCIES) > /dev/null 2>&1

realclean:
	@echo Removing $(TARGET)
	-rm -f $(TARGET) > /dev/null 2>&1

.PHONY: clean realclean

%.lex.C : %.l
	@echo Lexing $<
	$(LEX) -P$(notdir $*) -o $(dir $^)/$(notdir $@) $^

%.tab.C %.tab.h : %.y
	@echo Yaccing $^
	$(YACC) -d -p $(notdir $*) -o $(dir $^)/$(notdir $*).tab.C $^
	cd $(dir $^); \\
	if [ -f $(notdir $*).tab.C.h ]; then \\
	  mv $(notdir $*).tab.C.h $(notdir $*).tab.h; \\
	elif [ -f $(notdir $*).tab.hh ]; then \\
	  mv $*.tab.hh $*.tab.h; \\
	elif [ -f $(notdir $*).tab.hpp ]; then \\
	  mv $(notdir $*).tab.hpp $(notdir $*).tab.h; \\
	else \\
	  mv $(notdir $*).tab.H $(notdir $*).tab.h; \\
	fi

$(OBJDIR)/%.o : %.C
	$(mkdir_target)
	@echo Compiling $<
	$(CCC) -c -o $@ $< $(CXXFLAGS)

$(DEPDIR)/%.d : %.C
	$(mkdir_target)
	@echo Adjusting dependencies of $< ...
	$(SHELL) -ec '$(MAKEDEPEND) $(CPPFLAGS) $< \\
	| sed '\\''s/$(notdir $*)\\.o[ ]*:/$(subst /,\\/,$(OBJDIR))\\/$(notdir $*).o $(subst /,\\/,$@) : /g'\\'' > $@; \\
	[ -s $@ ] || (rm -f $@; exit 0)'

$(OBJDIR)/%.o : %.cpp
	$(mkdir_target)
	@echo Compiling $<
	$(CCC) -c -o $@ $< $(CXXFLAGS)

$(DEPDIR)/%.d : %.cpp
	$(mkdir_target)
	@echo Adjusting dependencies of $< ...
	$(SHELL) -ec '$(MAKEDEPEND) $(CPPFLAGS) $< \\
	| sed '\\''s/$(notdir $*)\\.o[ ]*:/$(subst /,\\/,$(OBJDIR))\\/$(notdir $*).o $(subst /,\\/,$@) : /g'\\'' > $@; \\
	[ -s $@ ] || (rm -f $@; exit 0)'

$(OBJDIR)/%.o : %.c
	$(mkdir_target)
	@echo Compiling $<
	$(CC) -c -o $@ $< $(CFLAGS)

$(DEPDIR)/%.d : %.c
	$(mkdir_target)
	@echo Adjusting dependencies of $< ...
	$(SHELL) -ec '$(MAKEDEPEND) $(CPPFLAGS) $< \\
	| sed '\\''s/$(notdir $*)\\.o[ ]*:/$(subst /,\\/,$(OBJDIR))\\/$(notdir $*).o $(subst /,\\/,$@) : /g'\\'' > $@; \\
	[ -s $@ ] || (rm -f $@; exit 0)'

$(OBJDIR)/%.o : %.cc
	$(mkdir_target)
	@echo Compiling $<
	$(CCC) -c -o $@ $< $(CXXFLAGS)

$(DEPDIR)/%.d : %.cc
	$(mkdir_target)
	@echo Adjusting dependencies of $< ...
	$(SHELL) -ec '$(MAKEDEPEND) $(CPPFLAGS) $< \\
	| sed '\\''s/$(notdir $*)\\.o[ ]*:/$(subst /,\\/,$(OBJDIR))\\/$(notdir $*).o $(subst /,\\/,$@) : /g'\\'' > $@; \\
	[ -s $@ ] || (rm -f $@; exit 0)'

ifneq ($(MAKECMDGOALS), clean)
ifneq ($(MAKECMDGOALS), realclean)
ifneq ($(MAKECMDGOALS), printvar)
-include $(DEPENDENCIES)
endif
endif
endif

EOF
          )

`tar zcvf #{options.output}.tar.gz #{options.output}`
