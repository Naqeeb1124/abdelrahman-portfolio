#ifndef HOME_H
#define HOME_H

#include "CompositeShape.h"
#include "Rectangle.h"
#include "Triangle.h"

// Home shape: Rectangle base with triangle roof
// Composite of 2 different basic shapes
class Home : public CompositeShape {
public:
    // Constructor
    Home(Point ref = Point(300, 300), ShapeColor fill = RED, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Home();

    // Override functions
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 11; } // Home type = 11

private:
    void CreateSubShapes();
};

#endif
