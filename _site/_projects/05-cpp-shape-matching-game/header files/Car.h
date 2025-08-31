#ifndef CAR_H
#define CAR_H

#include "CompositeShape.h"
#include "Rectangle.h"
#include "Circle.h"

// Car shape: Rectangle body with circle wheels
// Composite of 3 different basic shapes
class Car : public CompositeShape {
public:
    // Constructor
    Car(Point ref = Point(300, 300), ShapeColor fill = GREEN, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Car();

    // Override functions
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 13; } // Car type = 13

private:
    void CreateSubShapes();
};

#endif
