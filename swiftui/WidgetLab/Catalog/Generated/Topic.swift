// 生成: tools/make_manifest.py（手で直さない）

/// リファレンスの大分類。並びはホームに出す順
nonisolated enum TopicCategory: String, CaseIterable, Sendable {
    case views = "Views"
    case viewLayout = "View layout"
    case appStructure = "App structure"
    case dataAndStorage = "Data and storage"
    case eventHandling = "Event handling"
    case accessibility = "Accessibility"
}

/// リファレンスのトピック（= ジャンル）。収録が 1 件以上あるものだけ。並びはリファレンスの順
nonisolated enum Topic: String, CaseIterable, Sendable {
    case appOrganization = "app-organization"
    case scenes = "scenes"
    case windows = "windows"
    case documents = "documents"
    case navigation = "navigation"
    case modalPresentations = "modal-presentations"
    case toolbars = "toolbars"
    case search = "search"
    case appExtensions = "app-extensions"
    case modelData = "model-data"
    case environmentValues = "environment-values"
    case preferences = "preferences"
    case persistentStorage = "persistent-storage"
    case viewFundamentals = "view-fundamentals"
    case viewConfiguration = "view-configuration"
    case viewStyles = "view-styles"
    case animations = "animations"
    case textInputAndOutput = "text-input-and-output"
    case images = "images"
    case controlsAndIndicators = "controls-and-indicators"
    case menusAndCommands = "menus-and-commands"
    case shapes = "shapes"
    case drawingAndGraphics = "drawing-and-graphics"
    case layoutFundamentals = "layout-fundamentals"
    case layoutAdjustments = "layout-adjustments"
    case customLayout = "custom-layout"
    case lists = "lists"
    case tables = "tables"
    case viewGroupings = "view-groupings"
    case scrollViews = "scroll-views"
    case gestures = "gestures"
    case inputEvents = "input-events"
    case clipboard = "clipboard"
    case dragAndDrop = "drag-and-drop"
    case focus = "focus"
    case systemEvents = "system-events"
    case accessibilityFundamentals = "accessibility-fundamentals"
    case accessibleAppearance = "accessible-appearance"
    case accessibleControls = "accessible-controls"
    case accessibleDescriptions = "accessible-descriptions"
    case accessibleNavigation = "accessible-navigation"

    var title: String {
        switch self {
        case .appOrganization: "App organization"
        case .scenes: "Scenes"
        case .windows: "Windows"
        case .documents: "Documents"
        case .navigation: "Navigation"
        case .modalPresentations: "Modal presentations"
        case .toolbars: "Toolbars"
        case .search: "Search"
        case .appExtensions: "App extensions"
        case .modelData: "Model data"
        case .environmentValues: "Environment values"
        case .preferences: "Preferences"
        case .persistentStorage: "Persistent storage"
        case .viewFundamentals: "View fundamentals"
        case .viewConfiguration: "View configuration"
        case .viewStyles: "View styles"
        case .animations: "Animations"
        case .textInputAndOutput: "Text input and output"
        case .images: "Images"
        case .controlsAndIndicators: "Controls and indicators"
        case .menusAndCommands: "Menus and commands"
        case .shapes: "Shapes"
        case .drawingAndGraphics: "Drawing and graphics"
        case .layoutFundamentals: "Layout fundamentals"
        case .layoutAdjustments: "Layout adjustments"
        case .customLayout: "Custom layout"
        case .lists: "Lists"
        case .tables: "Tables"
        case .viewGroupings: "View groupings"
        case .scrollViews: "Scroll views"
        case .gestures: "Gestures"
        case .inputEvents: "Input events"
        case .clipboard: "Clipboard"
        case .dragAndDrop: "Drag and drop"
        case .focus: "Focus"
        case .systemEvents: "System events"
        case .accessibilityFundamentals: "Accessibility fundamentals"
        case .accessibleAppearance: "Accessible appearance"
        case .accessibleControls: "Accessible controls"
        case .accessibleDescriptions: "Accessible descriptions"
        case .accessibleNavigation: "Accessible navigation"
        }
    }

    var category: TopicCategory {
        switch self {
        case .appOrganization: .appStructure
        case .scenes: .appStructure
        case .windows: .appStructure
        case .documents: .appStructure
        case .navigation: .appStructure
        case .modalPresentations: .appStructure
        case .toolbars: .appStructure
        case .search: .appStructure
        case .appExtensions: .appStructure
        case .modelData: .dataAndStorage
        case .environmentValues: .dataAndStorage
        case .preferences: .dataAndStorage
        case .persistentStorage: .dataAndStorage
        case .viewFundamentals: .views
        case .viewConfiguration: .views
        case .viewStyles: .views
        case .animations: .views
        case .textInputAndOutput: .views
        case .images: .views
        case .controlsAndIndicators: .views
        case .menusAndCommands: .views
        case .shapes: .views
        case .drawingAndGraphics: .views
        case .layoutFundamentals: .viewLayout
        case .layoutAdjustments: .viewLayout
        case .customLayout: .viewLayout
        case .lists: .viewLayout
        case .tables: .viewLayout
        case .viewGroupings: .viewLayout
        case .scrollViews: .viewLayout
        case .gestures: .eventHandling
        case .inputEvents: .eventHandling
        case .clipboard: .eventHandling
        case .dragAndDrop: .eventHandling
        case .focus: .eventHandling
        case .systemEvents: .eventHandling
        case .accessibilityFundamentals: .accessibility
        case .accessibleAppearance: .accessibility
        case .accessibleControls: .accessibility
        case .accessibleDescriptions: .accessibility
        case .accessibleNavigation: .accessibility
        }
    }
}
