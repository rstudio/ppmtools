test_distro <- function(pretty_name, distro) {
  unlockBinding("osVersion", getNamespace("utils"))
  assign("osVersion", pretty_name, envir = getNamespace("utils"))
  expect_equal(detect_distro(), distro)
}

test_that("known distros are detected", {
  test_distro("Ubuntu 18.04.1 LTS", "bionic")
  test_distro("Ubuntu 20.04.4 LTS", "focal")
  test_distro("Ubuntu 22.04 LTS", "jammy")
  test_distro("Red Hat Enterprise Linux Server 7.5 (Maipo)", "rhel7")
  test_distro("Red Hat Enterprise Linux 8.0 (Ootpa)", "rhel8")
  test_distro("Red Hat Enterprise Linux 9.1 (Plow)", "rhel9")
  test_distro("Rocky Linux 8.7 (Green Obsidian)", "rhel8")
  test_distro("Rocky Linux 9.1 (Blue Onyx)", "rhel9")
  test_distro("CentOS Linux 7 (Core)", "centos7")
  test_distro("CentOS Linux 8", "rhel8")
  test_distro("SUSE Linux Enterprise Server 15 SP1", "sles154")
  test_distro("openSUSE Leap 15.4", "opensuse154")
  test_distro("MysteryLinux 123", "unknown")
})
