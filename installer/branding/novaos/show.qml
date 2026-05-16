// ============================================================================
// NovaOS Calamares Installation Slideshow
// ============================================================================
// QML slideshow displayed during installation.
// Shows 5 slides highlighting NovaOS features.
// ============================================================================

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    // --- Slide 1: Welcome ---
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1a2e"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Welcome to NovaOS"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#ffffff"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "A lightweight, modern Linux experience\ndesigned for everyone."
                    font.pixelSize: 16
                    color: "#b0b0c0"
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.4
                }
            }
        }
    }

    // --- Slide 2: Lightweight ---
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1a2e"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "⚡ Ultra-Lightweight"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#4fc3f7"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NovaOS uses less than 200 MB of RAM at idle.\nPerfect for older hardware and low-end PCs."
                    font.pixelSize: 14
                    color: "#b0b0c0"
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.4
                }
            }
        }
    }

    // --- Slide 3: Modern Apps ---
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1a2e"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "📦 Modern App Support"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#4fc3f7"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Install thousands of apps with Flatpak.\nRun AppImages and even Windows apps with Wine."
                    font.pixelSize: 14
                    color: "#b0b0c0"
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.4
                }
            }
        }
    }

    // --- Slide 4: Beautiful ---
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1a2e"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🎨 Beautiful & Modern"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#4fc3f7"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Clean dark theme, modern icons, smooth animations.\nLooks premium, runs light."
                    font.pixelSize: 14
                    color: "#b0b0c0"
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.4
                }
            }
        }
    }

    // --- Slide 5: Community ---
    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1a2e"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🤝 Built on Debian Stable"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#4fc3f7"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Rock-solid Debian foundation.\nSecurity updates, huge package library, community support."
                    font.pixelSize: 14
                    color: "#b0b0c0"
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.4
                }
            }
        }
    }
}
