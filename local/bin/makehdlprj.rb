#! /usr/bin/ruby

require 'pathname'

# Find the root .git directory, skipping submodules
def findGitRoot()
  parentpath="."
  while (true) do
    gitdir = `cd #{parentpath} && git rev-parse --show-cdup`
    if $?.exitstatus != 0
      raise "git rev-parse failed"
    end
    gitdir.chomp!
    if gitdir.empty?
      gitdir = "."
    end
    parentpath = gitdir + "/" + parentpath
    if File.directory?(parentpath + "/.git")
      return Pathname.new(parentpath).cleanpath.to_s
    else
      parentpath += "/.."
    end
  end
end

root = findGitRoot
Dir.chdir(root)
vhd_files = Dir["**/*.vhd", "**/*.vhdl"]
# remove empty files (probably from vma)
vhd_files.delete_if do |file|
  !File.file?(file) || File.zero?(file)
end
hdlFile = open("hdl-prj.json", "w")

hdlFile << <<EOF
{
  "options": {
    "ghdl_analysis": [
      "--std=08"
    ]
  },
  "files": [
#{vhd_files.map do |file| "{ \"file\": \"#{file}\", \"language\": \"vhdl\" }" end.join(",\n")}
  ]
}
EOF
hdlFile.close
