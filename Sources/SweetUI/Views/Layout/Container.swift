import UIKit


public class Container<Content>: UIView {

    public let content: Content

    
    init(content: Content) {
        self.content = content
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Modifiers

public extension Container {

    convenience init(content: Content, arrangeUsing contentConfigurator: (Content, Self) -> Void) where Content: UIView {
        self.init(content: content)
        self.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        contentConfigurator(content, self)
    }

    convenience init(unarrangedContent: Content, arrangeUsing contentConfigurator: (Content, Self) -> Void) {
        self.init(content: unarrangedContent)
        contentConfigurator(content, self)
    }
}
