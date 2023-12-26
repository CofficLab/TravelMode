import OSLog
import SwiftUI

struct AppList: View {
    @State private var apps: [SmartApp] = []
    private var channel = Channel()
    private var appsVisible: [SmartApp] {
        apps.sorted(by: {
            $0.events.count > $1.events.count
        }).filter({
            $0.events.count > 0
        })
    }

    var body: some View {
        ZStack {
            if appsVisible.count == 0 {
                VStack {
                    Spacer()
                    Text("开始监控后").font(.title)
                    Text("联网的 APP 将会出现在这里").font(.title)
                    Spacer()
                }.frame(maxWidth: .infinity,maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(appsVisible) { app in
                            AppLine(app: app)
                            Divider()
                        }
                    }
                }
            }
        }
        .onAppear {
            apps = SmartApp.appList
            onNewEvent()
        }
    }

    private func onNewEvent() {
        EventManager().onNetworkFilterFlow({ e in
            let app = SmartApp.fromId(e.sourceAppIdentifier)
            if apps.contains(where: {
                $0.id == app.id
            }) {
                for (i, a) in apps.enumerated() {
                    if a.id == app.id {
                        apps[i] = a.appendEvent(e)
                    }
                }
            } else {
                apps.append(app)
            }
        })
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}

#Preview("AppList") {
    RootView {
        AppList()
    }
}

#Preview("EventList") {
    RootView {
        EventList()
    }
}
