import AppKit

class MonitoredAppsView: NSView {
    init() {
        super.init(frame: .zero)

        let stackView = NSStackView(frame: .zero)
        stackView.orientation = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true

        buildView(stackView: stackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buildView(stackView: NSStackView) {
        for (index, bundleId) in MonitoredApp.allBundleIds.enumerated() {
            guard !MonitoredApp.unsupportedAppIds.contains(bundleId) else { continue }

            buildViewForApp(index: index * 2, stackView: stackView, bundleId: bundleId)
            buildViewForApp(
                index: (index * 2) + 1,
                stackView: stackView,
                bundleId: bundleId.appending("-setapp"))
        }

        stackView.addArrangedSubview(NSView())
    }

    func buildViewForApp(index: Int, stackView: NSStackView, bundleId: String) {
        guard
            let image = AppInfo.getIcon(bundleId: bundleId),
            let appName = AppInfo.getAppName(bundleId: bundleId)
        else { return }

        let currentStackView = NSStackView(frame: .zero)
        currentStackView.orientation = .horizontal
        currentStackView.distribution = .gravityAreas

        currentStackView.spacing = 32

        let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 15, height: 15))
        imageView.image = image
        imageView.layer?.cornerRadius = imageView.frame.height / 2
        currentStackView.addArrangedSubview(imageView)
        currentStackView.setCustomSpacing(8, after: imageView)

        let nameLabel = NSTextField(labelWithString: appName)
        nameLabel.alignment = .left
        let switchControl = NSSwitch()
        switchControl.state = MonitoringManager.isAppMonitored(for: bundleId) ? .on : .off
        switchControl.target = self
        switchControl.tag = index
        switchControl.action = #selector(switchToggled(_:))

        currentStackView.addArrangedSubview(nameLabel)
        currentStackView.addArrangedSubview(switchControl)

        stackView.addArrangedSubview(currentStackView)
        currentStackView.translatesAutoresizingMaskIntoConstraints = false
        currentStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        currentStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        currentStackView.huggingPriority(for: .horizontal)
        nameLabel.widthAnchor.constraint(equalTo: currentStackView.widthAnchor, multiplier: 0.7, constant: 0).isActive = true

        let divider = NSView(frame: NSRect(x: 0, y: 0, width: stackView.frame.width, height: 1))
        divider.wantsLayer = true
        divider.layer?.backgroundColor = NSColor.darkGray.cgColor
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        stackView.addArrangedSubview(divider)
    }

    @objc func switchToggled(_ sender: NSSwitch) {
        let isSetApp = !sender.tag.isMultiple(of: 2)
        let index = (isSetApp ? sender.tag - 1 : sender.tag) / 2
        var bundleId = MonitoredApp.allBundleIds[index]

        if isSetApp {
            bundleId = bundleId.appending("-setapp")
        }

        MonitoringManager.set(monitoringState: sender.state == .on ? .on : .off, for: bundleId)
    }
}
