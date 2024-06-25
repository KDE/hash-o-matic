# SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
# SPDX-License-Identifier: BSD-2-Clause

cmake_minimum_required(VERSION 3.16)

project(hashomatic VERSION 1.0.1)

set(QT_MIN_VERSION "6.5.0")
set(KF_MIN_VERSION "6.0.0")
set(KPIM_LIBKLEO_VERSION "6.0.0")
set(KDE_COMPILERSETTINGS_LEVEL "6.0.0")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(FeatureSummary)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(ECMPoQmTools)
include(ECMAddTests)
include(KDEGitCommitHooks)
include(KDEClangFormat)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.c)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX HASHVALIDATOR
    SOVERSION ${PROJECT_VERSION_MAJOR}
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/src/config-hashomatic.h"
)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core Gui Qml QuickControls2 Svg)
find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS Kirigami I18n CoreAddons Config)

qt_policy(SET QTP0001 NEW)

if (NOT ANDROID AND NOT WIN32 AND NOT APPLE AND NOT HAIKU)
    find_package(KF6DBusAddons ${KF_MIN_VERSION} REQUIRED)
    find_package(KF6WindowSystem ${KF_MIN_VERSION} REQUIRED)
endif()

if (NOT ANDROID)
    find_package(Qt6Widgets ${QT_MIN_VERSION} REQUIRED)
endif()

find_package(KPim6Libkleo ${KPIM_LIBKLEO_VERSION} CONFIG)
set_package_properties(Gpgmepp PROPERTIES
    DESCRIPTION "LibKleo Library"
    URL "https://invent.kde.org/pim/libkleo/"
    TYPE OPTIONAL
    PURPOSE "LibKleo is required for OpenPGP support"
)

find_package(Gpgmepp ${GPGME_REQUIRED_VERSION} CONFIG)
set_package_properties(Gpgmepp PROPERTIES
    DESCRIPTION "GpgME++ Library"
    URL "https://www.gnupg.org"
    TYPE OPTIONAL
    PURPOSE "GpgME++ is required for OpenPGP support"
)

find_package(QGpgmeQt6 ${GPGME_REQUIRED_VERSION} CONFIG)
set_package_properties(Gpgmepp PROPERTIES
    DESCRIPTION "QGpgME Library"
    URL "https://www.gnupg.org"
    TYPE OPTIONAL
    PURPOSE "QGpgME is required for OpenPGP support"
)
add_subdirectory(src)

ki18n_install(po)

if (BUILD_TESTING)
    find_package(Qt6Test ${QT_MIN_VERSION} REQUIRED)
    add_subdirectory(autotests)
endif()


install(PROGRAMS org.kde.hashomatic.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.hashomatic.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES org.kde.hashomatic.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
