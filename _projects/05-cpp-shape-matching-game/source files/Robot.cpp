#include "Robot.h"

// Constructor
Robot::Robot(Point ref, ShapeColor fill, ShapeColor outline)
    : CompositeShape(ref, fill, outline) {
    CreateSubShapes();
}

// Destructor
Robot::~Robot() {
}

// Create the sub-shapes for the robot
void Robot::CreateSubShapes() {
    // Rectangle body
    Rectangle* body = new Rectangle(Point(refPoint.x - 15, refPoint.y - 10), 30, 35, fillColor, outlineColor);
    AddSubShape(body);

    // Circle head
    Circle* head = new Circle(Point(refPoint.x, refPoint.y - 30), 12, fillColor, outlineColor);
    AddSubShape(head);

    // Rectangle left arm
    Rectangle* leftArm = new Rectangle(Point(refPoint.x - 25, refPoint.y - 5), 8, 20, fillColor, outlineColor);
    AddSubShape(leftArm);

    // Rectangle right arm
    Rectangle* rightArm = new Rectangle(Point(refPoint.x + 17, refPoint.y - 5), 8, 20, fillColor, outlineColor);
    AddSubShape(rightArm);

    // Triangle antenna
    Triangle* antenna = new Triangle(Point(refPoint.x - 5, refPoint.y - 45), 10, fillColor, outlineColor);
    AddSubShape(antenna);
}

// Clone this robot
Shape* Robot::Clone() const {
    Robot* clone = new Robot(refPoint, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}
