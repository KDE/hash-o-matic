// SPDX-License-Identifier: LGPL-2.1-or-later
// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

import Qt.labs.platform as Labs

import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Labs.MenuBar {
    Labs.Menu {
        title: i18nc("@action:inmenu", "File")

        Labs.MenuItem {
            icon.name: "document-open-folder"
            text: i18nc("@action:inmenu", "Open…")
            onTriggered: fileDialog.open()
        }

        Labs.MenuSeparator {}

        Labs.MenuItem {
            text: i18nc("@action:inmenu", "About Hash-o-matic")
            onTriggered: aboutAction.trigger()
            icon.name: "help-about"
        }
        Labs.MenuItem {
            text: i18nc("@action:inmenu", "Quit")
            icon.name: "gtk-quit"
            shortcut: StandardKey.Quit
            onTriggered: Qt.quit()
        }
    }

    Labs.Menu {
        title: i18nc("@action:inmenu", "View")

        Labs.MenuItem {
            text: i18nc("@action:inmenu", "Generate")
            icon.name: "password-generate"
            onTriggered: generateAction.trigger()
        }
        Labs.MenuItem {
            text: i18n("Compare")
            icon.name: "kompare"
            onTriggered: compareAction.trigger()
        }
        Labs.MenuItem {
            text: i18n("Verify")
            icon.name: "document-edit-decrypt-verify"
            onTriggered: verifyAction.trigger()
        }
    }
}
