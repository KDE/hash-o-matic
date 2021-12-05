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

    title: i18n("Generate Hash")

    ColumnLayout {
        width: parent.width
        QQC2.Button {
            icon.name: hashHelper.md5sum === "" ? "document-open-folder" : hashHelper.minetypeIcon
            Layout.alignment: Qt.AlignHCenter
            text: hashHelper.md5sum === "" ? i18nc("@action:button", "Select file") : hashHelper.fileName
            onClicked: fileDialog.open()
        }

        Kirigami.FormLayout {
            visible: hashHelper.md5sum.length > 0
            RowLayout {
                Layout.fillWidth: true
                Kirigami.FormData.label: i18nc('Hashing algorithm', 'MD5:')
                QQC2.TextArea {
                    text: hashHelper.md5sum
                    wrapMode: TextEdit.WrapAnywhere
                    readOnly: true
                    leftPadding: 0
                    background: null
                    Layout.fillWidth: true
                }
                QQC2.Button {
                    text: i18n('Copy hash')
                    icon.name: 'edit-copy'
                    onClicked: {
                        Clipboard.saveText(hashHelper.md5sum);
                        applicationWindow().showPassiveNotification(i18n("Hash copied into the clipboard"), "short");
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Kirigami.FormData.label: i18nc('Hashing algorithm', 'SHA1:')
                QQC2.TextArea {
                    text: hashHelper.sha1sum
                    readOnly: true
                    background: null
                    leftPadding: 0
                    Layout.fillWidth: true
                    wrapMode: TextEdit.WrapAnywhere
                }
                QQC2.Button {
                    text: i18n('Copy hash')
                    icon.name: 'edit-copy'
                    onClicked: {
                        Clipboard.saveText(hashHelper.sha1sum);
                        applicationWindow().showPassiveNotification(i18n("Hash copied into the clipboard"), "short");
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Kirigami.FormData.label: i18nc('Hashing algorithm', 'SHA256:')
                QQC2.TextArea {
                    id: sha256Text
                    text: hashHelper.sha256sum
                    readOnly: true
                    leftPadding: 0
                    wrapMode: TextEdit.WrapAnywhere
                    background: null
                    Layout.fillWidth: true
                    Layout.preferredWidth: page.width - Kirigami.Units.gridUnit * 3
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 30
                }
                QQC2.Button {
                    text: i18n('Copy hash')
                    icon.name: 'edit-copy'
                    onClicked: {
                        Clipboard.saveText(hashHelper.sha256sum);
                        applicationWindow().showPassiveNotification(i18n("Hash copied into the clipboard"), "short");
                    }
                }
            }
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
            text: i18n("Drag items here to share them")
        }
    }
}
