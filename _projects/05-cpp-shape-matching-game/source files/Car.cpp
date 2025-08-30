#include "Car.h"

// Constructor
Car::Car(Point ref, ShapeColor fill, ShapeColor outline)
    : CompositeShape(ref, fill, outline) {
    CreateSubShapes();
}

// Destructor
Car::~Car() {
}

// Create the sub-shapes for the car
void Car::CreateSubShapes() {
    // Rectangle body
    Rectangle* body = new Rectangle(Point(refPoint.x - 35, refPoint.y - 15), 70, 25, fillColor, outlineColor);
    AddSubShape(body);

    // Left wheel (circle)
    Circle* leftWheel = new Circle(Point(refPoint.x - 20, refPoint.y + 15), 10, fillColor, outlineColor);
    AddSubShape(leftWheel);

    // Right wheel (circle)
    Circle* rightWheel = new Circle(Point(refPoint.x + 20, refPoint.y + 15), 10, fillColor, outlineColor);
    AddSubShape(rightWheel);
}

// Clone this car
Shape* Car::Clone() const {
    Car* clone = new Car(refPoint, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}
