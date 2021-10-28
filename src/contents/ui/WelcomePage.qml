// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.19 as Kirigami
import org.kde.hashvalidator 1.0
import Qt.labs.platform 1.1

Kirigami.Page {
    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent - Kirigami.Units.gridUnit * 4
        text: i18n('Welcome to HashValidator')
        helpfulAction: Kirigami.Action {
            icon.name: "document-open-folder"
            text: i18nc("@action:button", "Select file")
            onTriggered: fileDialog.open()
        }
    }
}
