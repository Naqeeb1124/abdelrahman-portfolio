#include "Sign.h"

// Constructor
Sign::Sign(Point ref, ShapeColor fill, ShapeColor outline)
    : CompositeShape(ref, fill, outline) {
    CreateSubShapes();
}

// Destructor
Sign::~Sign() {
}

// Create the sub-shapes for the plus sign
void Sign::CreateSubShapes() {
    // Horizontal rectangle
    Rectangle* hRect = new Rectangle(Point(refPoint.x - 30, refPoint.y - 10), 60, 20, fillColor, outlineColor);
    AddSubShape(hRect);

    // Vertical rectangle
    Rectangle* vRect = new Rectangle(Point(refPoint.x - 10, refPoint.y - 30), 20, 60, fillColor, outlineColor);
    AddSubShape(vRect);
}

// Clone this sign
Shape* Sign::Clone() const {
    Sign* clone = new Sign(refPoint, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}
