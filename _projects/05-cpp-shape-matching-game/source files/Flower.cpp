#include "Flower.h"

// Constructor
Flower::Flower(Point ref, ShapeColor fill, ShapeColor outline)
    : CompositeShape(ref, fill, outline) {
    CreateSubShapes();
}

// Destructor
Flower::~Flower() {
}

// Create the sub-shapes for the flower
void Flower::CreateSubShapes() {
    // Rectangle stem
    Rectangle* stem = new Rectangle(Point(refPoint.x - 3, refPoint.y + 10), 6, 30, fillColor, outlineColor);
    AddSubShape(stem);

    // Circle center
    Circle* center = new Circle(Point(refPoint.x, refPoint.y), 12, fillColor, outlineColor);
    AddSubShape(center);

    // Triangle petal 1 (top)
    Triangle* petal1 = new Triangle(Point(refPoint.x - 8, refPoint.y - 20), 16, fillColor, outlineColor);
    AddSubShape(petal1);

    // Triangle petal 2 (right) - rotated
    Triangle* petal2 = new Triangle(Point(refPoint.x + 12, refPoint.y - 8), 16, fillColor, outlineColor);
    petal2->Rotate(); // Rotate to face right
    AddSubShape(petal2);
}

// Clone this flower
Shape* Flower::Clone() const {
    Flower* clone = new Flower(refPoint, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}
