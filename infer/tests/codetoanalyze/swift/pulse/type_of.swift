class BaseView {
    var id: Int = 0
}

class DerivedViewA: BaseView {
    func doA() {}
}

class DerivedViewB: BaseView {
    func doB() {}
}

struct ClassUtils {
    // Returns the metatype for DerivedViewA
    static func viewClassForVariant() -> BaseView.Type {
        return DerivedViewA.self
    }
}

final class ClassCell {
    // Held as an optional base class pointer
    var baseView: BaseView?
}

// MARK: - Tests for Matching Types

func test_class_type_of_same_type_bad() {
    let cell = ClassCell()
    cell.baseView = DerivedViewA()
    let expectedType = ClassUtils.viewClassForVariant()

    // Unwrapped! DerivedViewA.self != DerivedViewA.self -> False (Assertion fails / Bad)
    assert (type(of: cell.baseView!) != expectedType)
}

func test_class_type_of_same_type_good() {
    let cell = ClassCell()
    cell.baseView = DerivedViewA()
    let expectedType = ClassUtils.viewClassForVariant()

    // Unwrapped! DerivedViewA.self == DerivedViewA.self -> True (Good)
    assert(type(of: cell.baseView!) == expectedType)
}

// MARK: - Tests for Different Types

func test_class_type_of_different_types_bad() {
    let cell = ClassCell()
    cell.baseView = DerivedViewA()
    let expectedType = DerivedViewB.self

    // Unwrapped! DerivedViewA.self == DerivedViewB.self -> False (Assertion fails / Bad)
    assert(type(of: cell.baseView!) == expectedType)
}

func test_class_type_of_different_types_good() {
    let cell = ClassCell()
    cell.baseView = DerivedViewA()
    let expectedType = DerivedViewB.self

    // Unwrapped! DerivedViewA.self != DerivedViewB.self -> True (Good)
    assert(type(of: cell.baseView!) != expectedType)
}
