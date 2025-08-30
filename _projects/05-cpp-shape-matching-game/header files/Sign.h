#ifndef SIGN_H
#define SIGN_H

#include "CompositeShape.h"
#include "Rectangle.h"

// Sign shape: Two rectangles forming a plus sign
// Composite of 2 basic shapes (rectangles)
class Sign : public CompositeShape {
public:
    // Constructor
    Sign(Point ref = Point(300, 300), ShapeColor fill = YELLOW, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Sign();

    // Override functions
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 10; } // Sign type = 10

private:
    void CreateSubShapes();
};

#endif
