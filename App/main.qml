import QtQuick 2.3
import QtQuick.Controls 1.4

import QtFirebase 1.0

ApplicationWindow {
    id: application

    title: qsTr('QtFirebase Example (%1x%2)').arg(width).arg(height)

    visible: true

    width: 500
    height: 832

    property bool paused: !Qt.application.active
    //color: "tomato"

    AdMob {
        appId: Qt.platform.os == "android" ? "ca-app-pub-6606648560678905~6485875670" : "ca-app-pub-6606648560678905~1693919273"

        // NOTE All banners and interstitials will use this list
        // unless they have their own testDevices list specified
        testDevices: [
            "01987FA9D5F5CEC3542F54FB2DDC89F6"
        ]
    }

    // NOTE a size of 320x50 will give a Standard banner - other sizes will give a SmartBanner
    // NOTE width and height are values relative to the native screen size - NOT any parent QML components
    AdMobBanner {
        id: banner
        adUnitId: Qt.platform.os == "android" ? "ca-app-pub-3940256099942544/6300978111" : "ca-app-pub-6606648560678905/3170652476"

        x: 0
        y: ready ? 10 : 0

        visible: loaded

        width: 320
        height: 50

        onReadyChanged: if(ready) load()

        onError: {
            // TODO fix "undefined" arguments
            console.log("Banner failed with error code",code,"and message",message)

            // See AdMob.Error* enums
            if(code === AdMob.ErrorNetworkError)
                console.log("No network available");
        }

        request: AdMobRequest {
            gender: AdMob.GenderMale
            childDirectedTreatment: AdMob.ChildDirectedTreatmentUnknown

            // NOTE remember JS Date months are 0 based
            // 1st of Januray 1980:
            birthday: new Date(1980,0,1)

            keywords: [
                "AdMob",
                "QML",
                "Qt",
                "Fun",
                "Test",
                "Firebase"
            ]

            extras: [
                { "something_extra11": "extra_stuff11" },
                { "something_extra12": "extra_stuff12" }
            ]
        }
    }

    AdMobInterstitial {
        id: interstitial
        adUnitId: Qt.platform.os == "android" ? "ca-app-pub-6606648560678905/3118450073" : "ca-app-pub-6606648560678905/7548649672"
        //adUnitId: "ca-app-pub-6606648560678905/3118450073"; // Android
        //adUnitId: "ca-app-pub-6606648560678905/7548649672"; // iOS

        onReadyChanged: if(ready) load()
        //onLoadedChanged: if(loaded) show()

        onClosed: load()

        request: AdMobRequest {
            gender: AdMob.GenderFemale
            childDirectedTreatment: AdMob.ChildDirectedTreatmentTagged

            // NOTE remember JS Date months are 0 based
            // 8th of December 1979:
            birthday: new Date(1979,11,8)

            keywords: [
                "Perfume",
                "Scent"
            ]

            extras: [
                { "something_extra1": "extra_stuff1" },
                { "something_extra2": "extra_stuff2" }
            ]
        }

        onError: {
            // TODO fix "undefined" arguments
            console.log("Interstitial failed with error code",code,"and message",message)
            // See AdMob.Error* enums
            if(code === AdMob.ErrorNetworkError)
                console.log("No network available");
        }
    }

    Analytics {
        id: analytics

        // Analytics collection enabled
        enabled: true

        // App needs to be open at least 1s before logging a valid session
        minimumSessionDuration: 1000
        // App session times out after 5s
        sessionTimeout: 5000

        // Set the user ID:
        // NOTE the user id can't be more than 36 chars long
        //userId: "A_VERY_VERY_VERY_VERY_VERY_VERY_LONG_USER_ID_WILL_BE_TRUNCATED"
        userId: "qtfirebase_test_user"
        // or call setUserId()

        // Unset the user ID:
        // userId: "" or call "unsetUserId()"

        // Set user properties:
        // Max 25 properties allowed by Google
        // See https://firebase.google.com/docs/analytics/cpp/properties
        userProperties: [
            { "sign_up_method" : "Google" },
            { "qtfirebase_power_user" : "yes" },
            { "qtfirebase_custom_property" : "test_value" }
        ]
        // or call setUserProperty()

        onReadyChanged: {
            // See: https://firebase.google.com/docs/analytics/cpp/events
            analytics.logEvent("qtfb_ready_event")
            analytics.logEvent("qtfb_ready_event","string_test","string")
            analytics.logEvent("qtfb_ready_event","int_test",getRandomInt(-100, 100))
            analytics.logEvent("qtfb_ready_event","double_test",getRandomArbitrary(-2.1, 2.7))

            analytics.logEvent("qtfb_ready_event_bundle",{
                'key_one': 'value',
                'key_two': 14,
                'key_three': 2.3
            })
        }
    }

    RemoteConfig{
        id: remoteConfig

        onReadyChanged: {
            console.log("RemoteConfig ready changed:"+ready);
            if(ready)
            {
                //2. Init remote config with parameters you want to retrieve and default values
                //default value returned if fetch config from server failed
                addParameter("remote_config_test_long", 1);
                addParameter("remote_config_test_boolean", false);
                addParameter("remote_config_test_double", 3.14);
                addParameter("remote_config_test_string","Default string");
                //3. Initiate fetch (in this example set cache expiration time to 1 second)
                //Be aware of set low cache expiration time since it will cause too much
                //requests to server, and it may cause you will be blocked for some time.
                //This called server throttling, server just refuse your requests for some time and
                //then begin accept connections again
                //Default time cache expiration is 12 hours

                requestConfig(10);
            }
        }

        onLoadedChanged: {
            console.log("RemoteConfig loaded changed:"+loaded);
            if(loaded)
            {
                //4. Retrieve data if loading success
                console.log("RemoteConfig TestLong:" + remoteConfig.getParameterValue("remote_config_test_long"));
                console.log("RemoteConfig TestBool:" + remoteConfig.getParameterValue("remote_config_test_boolean"));
                console.log("RemoteConfig TestDouble:" + remoteConfig.getParameterValue("remote_config_test_double"));
                console.log("RemoteConfig TestString:" + remoteConfig.getParameterValue("remote_config_test_string"));
            }
        }

        onError:{
            //5. Handle errors
            console.log("RemoteConfig error:" + message);
        }
    }

    function getRandomArbitrary(min, max) {
        return Math.random() * (max - min) + min;
    }

    function getRandomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    Column {
        anchors.centerIn: parent
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: interstitial.loaded
            text: enabled ? "Show interstitial" : "Interstitial loading..."
            onClicked: interstitial.show()
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: banner.visible ? "Hide banner" : "Show banner"
            onClicked: banner.visible = !banner.visible
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: banner.loaded
            text: "Move banner to random position"
            onClicked: {
                // NOTE that the banner won't leave screen on Android. Even if you set off-screen coordinates.
                // On iOS you can set the banner off-screen
                // This is not a "feature" of QtFirebase
                banner.x = getRandomInt(-banner.width+20, banner.width-20)
                banner.y = getRandomInt(-banner.height+20, application.height+banner.height-20)
            }
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Test event logging"
            onClicked: {
                analytics.logEvent("qtfb_event")
                analytics.logEvent("qtfb_event","string_test","string")
                analytics.logEvent("qtfb_event","int_test",getRandomInt(-100, 100))
                analytics.logEvent("qtfb_event","double_test",getRandomArbitrary(-2.1, 2.7))

                analytics.logEvent("qtfb_event_bundle",{
                    'key_one': 'value',
                    'key_two': 14,
                    'key_three': 2.3
                })
            }
        }
    }

}
