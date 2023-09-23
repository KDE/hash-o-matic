# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

add_executable(hashomatic
    main.cpp
    clipboard.cpp
    controller.cpp
    hashhelper.cpp
    resources.qrc)

target_link_libraries(hashomatic
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Svg
        KF6::I18n
        KF6::CoreAddons
        KF6::ConfigGui
)

if(TARGET KF6::DBusAddons)
    target_link_libraries(hashomatic PRIVATE KF6::DBusAddons Qt6::Widgets)
    target_compile_definitions(hashomatic PRIVATE -DHAVE_KDBUSADDONS)
endif()

if(TARGET KF6::WindowSystem)
    target_link_libraries(hashomatic PRIVATE KF6::WindowSystem)
    target_compile_definitions(hashomatic PRIVATE -DHAVE_WINDOWSYSTEM)
endif()


install(TARGETS hashomatic ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES hashFile.desktop DESTINATION ${KDE_INSTALL_DATADIR}/kio/servicemenus)
