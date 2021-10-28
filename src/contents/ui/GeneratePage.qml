// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.19 as Kirigami
import org.kde.hashvalidator 1.0
import Qt.labs.platform 1.1

Kirigami.Page {
    id: page

    title: i18n("Generate Hash")

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width
        QQC2.Button {
            icon.name: hashHelper.md5sum === "" ? "document-open-folder" : hashHelper.minetypeIcon
            Layout.alignment: Qt.AlignHCenter
            text: hashHelper.md5sum === "" ? i18nc("@action:button", "Select file") : hashHelper.fileName
            onClicked: fileDialog.open()
        }

        Kirigami.FormLayout {
            visible: hashHelper.md5sum !== ""
            Row {
                Kirigami.FormData.label: "MD5:"
                QQC2.TextArea {
                    text: hashHelper.md5sum
                    readOnly: true
                    background: null
                    width: sha256Text.width
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
            Row {
                Kirigami.FormData.label: "SHA1:"
                QQC2.TextArea {
                    text: hashHelper.sha1sum
                    readOnly: true
                    background: null
                    width: sha256Text.width
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
            Row {
                Kirigami.FormData.label: "SHA256:"
                QQC2.TextArea {
                    id: sha256Text
                    text: hashHelper.sha256sum
                    readOnly: true
                    wrapMode: TextEdit.WordWrap
                    background: null
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
}
