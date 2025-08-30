#ifndef FLOWER_H
#define FLOWER_H

#include "CompositeShape.h"
#include "Rectangle.h"
#include "Circle.h"
#include "Triangle.h"

// Flower shape: Circle center with triangle petals and rectangle stem
// Composite of 4 basic shapes (3 different types)
class Flower : public CompositeShape {
public:
    // Constructor
    Flower(Point ref = Point(300, 300), ShapeColor fill = PURPLE, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Flower();

    // Override functions
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 14; } // Flower type = 14

private:
    void CreateSubShapes();
};

#endif
