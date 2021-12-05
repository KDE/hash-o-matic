// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.19 as Kirigami
import org.kde.hashomatic 1.0
import Qt.labs.platform 1.1

Kirigami.Page {
    id: page
    title: i18nc('@title', 'Welcome')
    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent - Kirigami.Units.gridUnit * 4
        text: i18n('Welcome to Hash-o-Matic')
        helpfulAction: Kirigami.Action {
            icon.name: "document-open-folder"
            text: i18nc("@action:button", "Select file")
            onTriggered: fileDialog.open()
        }
    }

    DropArea {
        id: dropAreaFile
        anchors.fill: parent
        onDropped: hashHelper.file = drop.urls[0]
    }

    QQC2.Popup {
        visible: dropAreaFile.containsDrag
        height: parent ? parent.height -  Kirigami.Units.gridUnit * 2 : 0
        width: parent ? parent.width - Kirigami.Units.gridUnit * 2 : 0
        x: Kirigami.Units.gridUnit
        y: Kirigami.Units.gridUnit
        modal: true
        parent: page.QQC2.Overlay.overlay
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            text: i18n("Drag files here to hash then")
        }
    }
}
