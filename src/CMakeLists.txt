# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

add_executable(hashvalidator
    main.cpp
    clipboard.cpp
    controller.cpp
    hashhelper.cpp
    about.cpp
    resources.qrc)

target_link_libraries(hashvalidator
PRIVATE
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n
    KF5::CoreAddons)

if(TARGET KF5::DBusAddons)
    target_link_libraries(hashvalidator PRIVATE KF5::DBusAddons)
    target_compile_definitions(hashvalidator PRIVATE -DHAVE_KDBUSADDONS)
endif()

if(NOT ANDROID)
    target_link_libraries(hashvalidator PRIVATE KF5::ConfigGui KF5::WindowSystem KF5::ConfigCore)
    target_compile_definitions(hashvalidator PRIVATE -DHAVE_WINDOWSYSTEM)
endif()


install(TARGETS hashvalidator ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES hashFile.desktop DESTINATION ${KSERVICESDIR}/ServiceMenus)
