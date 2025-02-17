component "toolchain" do |pkg, settings, platform|
  if platform.is_linux?
    pkg.version "2016.05.03"
    pkg.url "file://files/cmake/linux-toolchain.cmake"
    if platform.name =~ /el-\d-x86_64|sles-\d\d-x86_64/
      # Toolchain files for rhel and sles running on IBM z-series, Power8, 
      # and aarch64, which builds on x86_64
      pkg.add_source "file://files/cmake/el-ppc64-toolchain.cmake"
      pkg.add_source "file://files/cmake/el-ppc64le-toolchain.cmake"
      pkg.add_source "file://files/cmake/sles-ppc64le-toolchain.cmake"
      pkg.add_source "file://files/cmake/el-aarch64-toolchain.cmake"
  elsif platform.is_aix?
    pkg.version "2015.10.01"
    # Despite the name, this toolchain applies to all aix versions
    pkg.url "file://files/cmake/aix-61-ppc-toolchain.cmake"
  elsif platform.is_windows?
    pkg.version "2015.11.23"
    if platform.architecture == "x64"
      pkg.url "file://files/cmake/windows-x64-toolchain.cmake"
    elsif platform.architecture == "x86"
      pkg.url "file://files/cmake/windows-x86-toolchain.cmake"
    else
      fail "Need to define a toolchain file for #{platform.name} first"
    end
  elsif platform.is_solaris?
    pkg.version "2015.10.01"
    if platform.os_version == "10"
      pkg.add_source "file://files/cmake/solaris-10-i386-toolchain.cmake"
      pkg.add_source "file://files/cmake/solaris-10-sparc-toolchain.cmake"
    elsif platform.os_version == "11"
      pkg.add_source "file://files/cmake/solaris-11-i386-toolchain.cmake"
      pkg.add_source "file://files/cmake/solaris-11-sparc-toolchain.cmake"
    else
      fail "Need to define a toolchain file for #{platform.name} first"
    end
  else
    fail "Need to define a toolchain file for #{platform.name} first"
  end

  # We still need to add support for OS X
  if platform.is_solaris?
    pkg.install_file "solaris-#{platform.os_version}-i386-toolchain.cmake", "#{settings[:basedir]}/i386-pc-solaris2.#{platform.os_version}/pl-build-toolchain.cmake"
    pkg.install_file "solaris-#{platform.os_version}-sparc-toolchain.cmake", "#{settings[:basedir]}/sparc-sun-solaris2.#{platform.os_version}/pl-build-toolchain.cmake"

    pkg.install do
      [
        # We update ownership here to make sure that solaris will put the toolchains in the package
        "chown root:root #{settings[:basedir]}/i386-pc-solaris2.#{platform.os_version}/pl-build-toolchain.cmake",
        "chown root:root #{settings[:basedir]}/sparc-sun-solaris2.#{platform.os_version}/pl-build-toolchain.cmake",
      ]
    end
  else
    filename = pkg.get_url.split('/').last
    pkg.install_file filename, "#{settings[:prefix]}/pl-build-toolchain.cmake"
    if platform.name =~ /el-\d-x86_64|sles-\d\d-x86_64/
      # Install toolchain files used by the Power8/aarch64 rhel and sles platfoms, which are built on x86_64
      pkg.install_file "el-ppc64-toolchain.cmake", "#{settings[:basedir]}/ppc64-redhat-linux/pl-build-toolchain.cmake"
      pkg.install_file "el-ppc64le-toolchain.cmake", "#{settings[:basedir]}/ppc64le-redhat-linux/pl-build-toolchain.cmake"
      pkg.install_file "sles-ppc64le-toolchain.cmake", "#{settings[:basedir]}/powerpc64le-suse-linux/pl-build-toolchain.cmake"
      pkg.install_file "el-aarch64-toolchain.cmake", "#{settings[:basedir]}/aarch64-redhat-linux/pl-build-toolchain.cmake"
  end
end
