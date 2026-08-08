import Foundation

/// Launch-stage audit counters for diagnosing duplicate engine/plugin registration.
enum SvaLaunchAudit {
  private(set) static var appDelegateDidFinishCount = 0
  private(set) static var sceneWillConnectCount = 0
  private(set) static var flutterEngineInitCount = 0
  private(set) static var pluginRegisterCount = 0
  private(set) static var svaBridgeRegisterCount = 0
  private(set) static var firstFrameLogged = false

  static func noteAppDelegateDidFinish() {
    appDelegateDidFinishCount += 1
    NSLog("[SVA-Launch] AppDelegate didFinish count=%d", appDelegateDidFinishCount)
  }

  static func noteSceneWillConnect() {
    sceneWillConnectCount += 1
    NSLog("[SVA-Launch] SceneDelegate connect count=%d", sceneWillConnectCount)
  }

  static func noteFlutterEngineInit() {
    flutterEngineInitCount += 1
    NSLog("[SVA-Launch] FlutterEngine create count=%d", flutterEngineInitCount)
  }

  static func notePluginRegister() {
    pluginRegisterCount += 1
    NSLog("[SVA-Launch] plugins register count=%d", pluginRegisterCount)
  }

  static func noteSvaBridgeRegister() {
    svaBridgeRegisterCount += 1
    NSLog("[SVA-Launch] SvaAlarmBridge.register count=%d", svaBridgeRegisterCount)
  }

  static func noteFirstFrame() {
    guard !firstFrameLogged else { return }
    firstFrameLogged = true
    NSLog("[SVA-Launch] first frame")
  }

  static func buildStampPayload() -> [String: Any] {
    let info = Bundle.main.infoDictionary ?? [:]
    return [
      "buildStamp": info["SVABuildStamp"] as? String ?? SvaBuildStampGenerated.stamp,
      "buildMode": info["SVABuildMode"] as? String ?? SvaBuildStampGenerated.mode,
      "buildTime": info["SVABuildTime"] as? String ?? SvaBuildStampGenerated.buildTime,
      "alarmKitStartup": info["SVAAlarmKitStartup"] as? String
        ?? SvaBuildStampGenerated.alarmKitStartup,
      "alarmKitForceOff": info["SVAAlarmKitForceOff"] as? String
        ?? SvaBuildStampGenerated.alarmKitForceOff,
      "diagStage": info["SVADiagStage"] as? String ?? SvaBuildStampGenerated.diagStage,
      "gitSha": SvaBuildStampGenerated.gitSha,
      "gitBranch": SvaBuildStampGenerated.gitBranch,
      "binaryUuid": SvaBuildStampGenerated.binaryUuid,
      "appDelegateDidFinishCount": appDelegateDidFinishCount,
      "sceneWillConnectCount": sceneWillConnectCount,
      "flutterEngineInitCount": flutterEngineInitCount,
      "pluginRegisterCount": pluginRegisterCount,
      "svaBridgeRegisterCount": svaBridgeRegisterCount,
      "firstFrameLogged": firstFrameLogged,
    ]
  }

  static func logBuildStampLine() {
    let payload = buildStampPayload()
    NSLog(
      "[SVA-Build] stamp=%@ mode=%@ alarmkit=%@ stage=%@ time=%@",
      payload["buildStamp"] as? String ?? "?",
      payload["buildMode"] as? String ?? "?",
      payload["alarmKitStartup"] as? String ?? "?",
      payload["diagStage"] as? String ?? "?",
      payload["buildTime"] as? String ?? "?"
    )
  }
}
