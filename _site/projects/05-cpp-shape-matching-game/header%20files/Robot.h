#ifndef ROBOT_H
#define ROBOT_H

#include "CompositeShape.h"
#include "Rectangle.h"
#include "Circle.h"
#include "Triangle.h"

// Robot shape: Rectangle body, circle head, rectangle arms, triangle antenna
// Composite of 4 basic shapes (3 different types)
class Robot : public CompositeShape {
public:
    // Constructor
    Robot(Point ref = Point(300, 300), ShapeColor fill = ORANGE, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Robot();

    // Override functions
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 15; } // Robot type = 15

private:
    void CreateSubShapes();
};

#endif
