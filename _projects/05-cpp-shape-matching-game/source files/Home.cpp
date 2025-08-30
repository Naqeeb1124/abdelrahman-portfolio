#include "Home.h"

// Constructor
Home::Home(Point ref, ShapeColor fill, ShapeColor outline)
    : CompositeShape(ref, fill, outline) {
    CreateSubShapes();
}

// Destructor
Home::~Home() {
}

// Create the sub-shapes for the house
void Home::CreateSubShapes() {
    // Rectangle base (house body)
    Rectangle* base = new Rectangle(Point(refPoint.x - 25, refPoint.y - 20), 50, 40, fillColor, outlineColor);
    AddSubShape(base);

    // Triangle roof
    Triangle* roof = new Triangle(Point(refPoint.x - 30, refPoint.y - 20), 60, fillColor, outlineColor);
    AddSubShape(roof);
}

// Clone this home
Shape* Home::Clone() const {
    Home* clone = new Home(refPoint, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}
