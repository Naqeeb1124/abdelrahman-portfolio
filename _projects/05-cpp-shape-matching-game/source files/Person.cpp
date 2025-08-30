#include "Person.h"

// Constructor
Person::Person(Point ref, ShapeColor fill, ShapeColor outline)
    : CompositeShape(ref, fill, outline) {
    CreateSubShapes();
}

// Destructor
Person::~Person() {
}

// Create the sub-shapes for the person
void Person::CreateSubShapes() {
    // Circle head
    Circle* head = new Circle(Point(refPoint.x, refPoint.y - 30), 15, fillColor, outlineColor);
    AddSubShape(head);

    // Rectangle body
    Rectangle* body = new Rectangle(Point(refPoint.x - 10, refPoint.y - 10), 20, 30, fillColor, outlineColor);
    AddSubShape(body);

    // Rectangle legs
    Rectangle* legs = new Rectangle(Point(refPoint.x - 12, refPoint.y + 20), 24, 15, fillColor, outlineColor);
    AddSubShape(legs);
}

// Clone this person
Shape* Person::Clone() const {
    Person* clone = new Person(refPoint, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}
