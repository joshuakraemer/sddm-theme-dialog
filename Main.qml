import QtQuick 2.8
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import SddmComponents 2.0 as SddmComponents

Rectangle {
	LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
	LayoutMirroring.childrenInherit: true
	color: config.backgroundColor ? config.backgroundColor : "#808080"

	Item {
		id: style
		/* Hack: Use DialogButtonBox spacing to detect current style */
		/* Style order: Default, Fusion, Universal, Material */
		property var buttonSpacings: [1, 6, 4, 8]
		property var spacings: [8, 6, 12, 12]
		property int id: {
			let index = buttonSpacings.indexOf(buttons.spacing);
			index < 0 ? 0 : index;
		}
		property int spacing: spacings[id]
	}

	SddmComponents.TextConstants {
		id: textConstants
	}

	Connections {
		target: sddm

		function onLoginFailed() {
			messageDisplay.text = textConstants.loginFailed
			passwordField.text = ""
			passwordField.focus = true
		}
	}

	Image {
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop

		Binding on source {
			when: config.backgroundImage != undefined
			value: config.backgroundImage
		}
	}

	DropShadow {
		width: dialog.width
		height: dialog.height
		x: dialog.x
		y: dialog.y
		source: dialog.background
		samples: 33
		opacity: 0.33
	}

	Dialog {
		id: dialog
		anchors.centerIn: parent
		closePolicy: Popup.NoAutoClose
		focus: true
		visible: true

		title: textConstants.welcomeText.arg(sddm.hostName)

		footer: DialogButtonBox {
			id: buttons

			Button {
				text: textConstants.login
				onClicked: sddm.login(userNameField.text, passwordField.text, sessionField.index)
			}

			Button {
				text: textConstants.shutdown
				onClicked: sddm.powerOff()
			}

			Button {
				text: textConstants.reboot
				onClicked: sddm.reboot()
			}
		}

		Grid {
			columns: 2
			spacing: style.spacing
			verticalItemAlignment: Grid.AlignVCenter

			Label {
				text: textConstants.userName + ":"
			}

			TextField {
				id: userNameField
				width: height*10
				text: userModel.lastUser
				onAccepted: sddm.login(userNameField.text, passwordField.text, sessionField.index)
			}

			Label {
				text: textConstants.password + ":"
			}

			TextField {
				id: passwordField
				width: height*10
				echoMode: TextInput.Password
				focus: true
				onAccepted: sddm.login(userNameField.text, passwordField.text, sessionField.index)
			}

			Label {
				text: textConstants.session + ":"
			}

			ComboBox {
				id: sessionField
				width: height*10
				height: userNameField.height
				model: sessionModel
				textRole: "name"
				currentIndex: sessionModel.lastIndex
			}
		}
	}
}
