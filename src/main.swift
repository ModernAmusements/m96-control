import SwiftUI
import IOKit.hid

@MainActor
final class M96Controller: ObservableObject {
    @Published var status: String = "Ready"
    @Published var connected: Bool = false

    private var manager: IOHIDManager?
    private var device: IOHIDDevice?

    private let vendorID = 0x32C2
    private let productID = 0x6621

    func connect() {
        disconnect()

        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let match: [String: Any] = [
            kIOHIDVendorIDKey: NSNumber(value: vendorID),
            kIOHIDProductIDKey: NSNumber(value: productID)
        ]
        IOHIDManagerSetDeviceMatching(manager, match as CFDictionary)

        let managerResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        guard managerResult == kIOReturnSuccess else {
            status = String(format: "HID manager open failed: 0x%08X", managerResult)
            return
        }

        guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>,
              let device = devices.first else {
            status = "M96BT2 not found — make sure Bluetooth is connected, then Rescan."
            self.manager = manager
            return
        }

        let deviceResult = IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone))
        guard deviceResult == kIOReturnSuccess else {
            status = String(format: "Device open failed: 0x%08X", deviceResult)
            self.manager = manager
            return
        }

        self.manager = manager
        self.device = device
        connected = true

        let name = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "M96BT2"
        status = "Connected to \(name) · output report 2 ready"
    }

    func disconnect() {
        if let device {
            IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone))
        }
        if let manager {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }
        device = nil
        manager = nil
        connected = false
    }

    @discardableResult
    func send(value: UInt8) -> IOReturn {
        guard let device else {
            status = "M96BT2 not found — click Rescan."
            return kIOReturnNotOpen
        }

        let report = [value]
        let result = report.withUnsafeBufferPointer { buffer in
            IOHIDDeviceSetReport(
                device,
                kIOHIDReportTypeOutput,
                2,
                buffer.baseAddress!,
                buffer.count
            )
        }

        if result == kIOReturnSuccess {
            status = String(format: "Sent report 2 = 0x%02X (IOReturn 0)", value)
        } else {
            status = String(format: "Report failed: 0x%08X", result)
        }
        return result
    }

    func pulse() {
        send(value: 255)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.send(value: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                self?.send(value: 204)
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var controller = M96Controller()
    @State private var isOn = true
    @State private var brightness: Double = 0.8

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("M96 / BACKLIGHT")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    Text("M96BT2 · HID output report 2")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Circle()
                    .fill(controller.connected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                    .padding(.top, 7)
            }

            Divider()

            HStack {
                Text("Backlight")
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .onChange(of: isOn) { _, newValue in
                        controller.send(value: newValue ? UInt8(brightness * 255) : 0)
                    }
            }

            HStack(spacing: 10) {
                Text("Brightness")
                Slider(value: $brightness, in: 0...1)
                    .onChange(of: brightness) { _, newValue in
                        if isOn {
                            controller.send(value: UInt8(newValue * 255))
                        }
                    }
                Text("\(Int(brightness * 100))%")
                    .font(.system(size: 11, design: .monospaced))
                    .frame(width: 40, alignment: .trailing)
                    .monospacedDigit()
            }

            HStack(spacing: 8) {
                Button("Pulse test") { controller.pulse() }
                Button("Caps LED") { controller.send(value: 0x02) }
                Button("Off") { controller.send(value: 0x00) }
                Button("Rescan") { controller.connect() }
            }
            .font(.system(size: 11, design: .monospaced))

            Text(controller.status)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Divider()

            Text("This sends the only output report the M96 exposes. If the backlight does not change, the keyboard firmware has no software lighting control — the LED layer is fixed rainbow.")
                .font(.system(size: 10.5))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(width: 500)
        .onAppear { controller.connect() }
    }
}

@main
struct M96ControlApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
