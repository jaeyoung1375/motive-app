param(
    [ValidateSet("start", "restart", "stop", "run", "reverse", "devices")]
    [string]$Action = "start"
)

$AvdName = "motive_app"
$DeviceId = "emulator-5554"

switch ($Action) {
    "start" {
        flutter emulators --launch $AvdName
    }
    "restart" {
        adb -s $DeviceId emu kill
        Start-Sleep -Seconds 2
        flutter emulators --launch $AvdName
    }
    "stop" {
        adb -s $DeviceId emu kill
    }
    "reverse" {
        # 백엔드(localhost:9090)를 에뮬레이터 안에서도 localhost로 접근 가능하게 포워딩
        # (구글 OAuth redirect_uri가 10.0.2.2 대신 localhost로 잡히게 하려면 run 전에 필요)
        adb -s $DeviceId reverse tcp:9090 tcp:9090
    }
    "devices" {
        flutter devices
    }
    "run" {
        adb -s $DeviceId reverse tcp:9090 tcp:9090
        flutter run -d $DeviceId
    }
}
