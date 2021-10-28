# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

add_executable(hashvalidator main.cpp clipboard.cpp hashhelper.cpp about.cpp resources.qrc)

target_link_libraries(hashvalidator
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    QCoro::QCoroCore
    KF5::I18n
    KF5::CoreAddons)

install(TARGETS hashvalidator ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
