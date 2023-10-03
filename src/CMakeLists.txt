# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

add_library(hashomatic_static STATIC)

target_sources(hashomatic_static PUBLIC
    clipboard.cpp
    clipboard.h
    controller.cpp
    controller.h
    hashhelper.cpp
    hashhelper.h
)

target_link_libraries(hashomatic_static
    PUBLIC
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

if(TARGET KF6::WindowSystem)
    target_link_libraries(hashomatic_static PUBLIC KF6::WindowSystem)
    target_compile_definitions(hashomatic_static PUBLIC -DHAVE_WINDOWSYSTEM)
endif()

if(TARGET Gpgmepp)
    target_link_libraries(hashomatic_static PUBLIC Gpgmepp QGpgmeQt6 KPim6::Libkleo)
    target_compile_definitions(hashomatic_static PUBLIC -DHAVE_GPGME)
    target_sources(hashomatic_static PUBLIC urlhandler.cpp urlhandler.h)
endif()

add_executable(hashomatic
    main.cpp
    resources.qrc
)

target_link_libraries(hashomatic PRIVATE hashomatic_static )

if(TARGET KF6::DBusAddons)
    target_link_libraries(hashomatic PRIVATE KF6::DBusAddons)
    target_compile_definitions(hashomatic PRIVATE -DHAVE_KDBUSADDONS)
endif()

if(TARGET Qt6::Widgets)
    target_link_libraries(hashomatic PRIVATE Qt6::Widgets)
endif()



install(TARGETS hashomatic ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES hashFile.desktop DESTINATION ${KDE_INSTALL_DATADIR}/kio/servicemenus)
