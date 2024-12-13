// SPDX-License-Identifier: LGPL-2.1-or-later
// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

import QtQuick 2.6
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.19 as Kirigami
import org.kde.hashomatic 1.0
import Qt.labs.platform 1.1
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
        actions: Kirigami.PagePoolAction {
            id: aboutAction
            text: i18n("About")
            icon.name: "help-about"
            page: './AboutPage.qml'
            pagePool: mainPagePool
            checkable: false
            useLayers: true
        }
    }

    Kirigami.PagePool {
        id: mainPagePool
    }

    footer: Kirigami.NavigationTabBar {
        actions: [
            Kirigami.PagePoolAction {
                id: generateAction
                text: i18nc("@action:inmenu", "Generate")
                icon.name: "password-generate"
                page: "./GeneratePage.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                id: compareAction
                text: i18nc("@action:inmenu", "Compare")
                icon.name: "kompare"
                page: "./ComparePage.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                id: verifyAction
                text: i18nc("@action:inmenu", "Verify")
                icon.name: "document-edit-decrypt-verify"
                page: "./VerifyPage.qml"
                pagePool: mainPagePool
            }
        ]
    }

    pageStack.initialPage: mainPagePool.loadPage('./GeneratePage.qml')
}
