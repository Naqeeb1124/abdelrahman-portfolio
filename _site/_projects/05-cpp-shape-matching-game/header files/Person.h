#ifndef PERSON_H
#define PERSON_H

#include "CompositeShape.h"
#include "Rectangle.h"
#include "Circle.h"

// Person shape: Circle head with rectangle body and legs
// Composite of 3 different basic shapes
class Person : public CompositeShape {
public:
    // Constructor
    Person(Point ref = Point(300, 300), ShapeColor fill = BLUE, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Person();

    // Override functions
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 12; } // Person type = 12

private:
    void CreateSubShapes();
};

#endif
