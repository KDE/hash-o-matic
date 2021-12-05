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

    title: i18n("Verify Hash")

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width
        QQC2.Button {
            icon.name: hashHelper.md5sum === "" ? "document-open-folder" : hashHelper.minetypeIcon
            Layout.alignment: Qt.AlignHCenter
            text: hashHelper.md5sum === "" ? i18nc("@action:button", "Select file") : hashHelper.fileName
            onClicked: fileDialog.open()
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: hashField
            Accessible.name: i18n('Verification hash')
            Layout.alignment: Qt.AlignHCenter
            placeholderText: i18n('Verification hash')
        }

        QQC2.Label {
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.alignment: Qt.AlignHCenter
            readonly property int type: {
                if (hashHelper.sha256sum === "" || hashField.text === "") {
                    return 1;
                } else if (hashHelper.sha256sum === hashField.text || hashField.text === hashHelper.sha1sum || hashField.text === hashHelper.md5sum) {
                    return 0;
                } else {
                    return 2;
                }
            }
            text: type === 0 ? i18n('They match!') : i18n("They don't match!")
            visible: type !== 1
            color: type === 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
        }
    }

    DropArea {
        id: dropAreaFile
        anchors.fill: parent
        onDropped: if (drop.urls.length > 0) {
            hashHelper.file = drop.urls[0];
        } else if (drop.hasText) {
            hashField.text = drop.text;
        }
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
            text: i18n("Drag items here to verify them")
        }
    }
}
