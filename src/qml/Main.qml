// SPDX-License-Identifier: LGPL-2.1-or-later
// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.hashomatic
import Qt.labs.platform
import org.kde.config as KConfig

Kirigami.ApplicationWindow {
    id: root

    minimumWidth: Kirigami.Units.gridUnit * 15
    width: Kirigami.Units.gridUnit * 28
    minimumHeight: Kirigami.Units.gridUnit * 20

    property bool wasEmpty: true

    KConfig.WindowStateSaver {
        configGroupName: "MainWindow"
    }

    Loader {
        active: !Kirigami.Settings.isMobile
        source: Qt.resolvedUrl("./GlobalMenu.qml")
    }

    HashHelper {
        id: hashHelper
        onErrorOccured: applicationWindow().showPassiveNotification(error, 'short')
    }

    Connections {
        target: Controller
        function onInitialFileChanged(): void {
            hashHelper.file = Controller.initialFile;
        }
    }

    FileDialog {
        id: fileDialog
        folder: StandardPaths.writableLocation(StandardPaths.DownloadsLocation)
        onAccepted: hashHelper.file = currentFile
    }

    globalDrawer: Kirigami.GlobalDrawer {
        titleIcon: "applications-graphics"
        isMenu: enabled
        enabled: !Kirigami.Settings.hasPlatformMenuBar
        actions: [
            Kirigami.Action {
                text: i18n("About")
                icon.name: "help-about-symbolic"
                onTriggered: root.pageStack.layers.push(Qt.createComponent("org.kde.kirigamiaddons.formcard", "AboutPage"))
            },
            Kirigami.Action {
                text: i18nc("@action:inmenu", "About KDE")
                icon.name: "kde-symbolic"
                onTriggered: root.pageStack.layers.push(Qt.createComponent("org.kde.kirigamiaddons.formcard", "AboutKDEPage"))
            }
        ]
    }

    footer: Kirigami.NavigationTabBar {
        actions: [
            Kirigami.Action {
                id: generateAction
                text: i18nc("@action:inmenu", "Generate")
                icon.name: "password-generate"
                onTriggered: root.pageStack.replace(Qt.createComponent("org.kde.hashomatic", "GeneratePage"), {
                    helper: hashHelper,
                })
            },
            Kirigami.Action {
                id: compareAction
                text: i18nc("@action:inmenu", "Compare")
                icon.name: "kompare"
                onTriggered: root.pageStack.replace(Qt.createComponent("org.kde.hashomatic", "ComparePage"), {
                    helper: hashHelper,
                })
            },
            Kirigami.Action {
                id: verifyAction
                text: i18nc("@action:inmenu", "Verify")
                icon.name: "document-edit-decrypt-verify"
                onTriggered: root.pageStack.replace(Qt.createComponent("org.kde.hashomatic", "VerifyPage"), {
                    helper: hashHelper,
                })
            }
        ]
    }

    pageStack.initialPage: GeneratePage {
        helper: hashHelper
    }
}
