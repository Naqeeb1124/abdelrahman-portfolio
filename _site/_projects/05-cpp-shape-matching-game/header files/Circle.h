#ifndef CIRCLE_H
#define CIRCLE_H

#include "Shape.h"

class Circle : public Shape {
private:
    int radius;

public:
    // Constructor
    Circle(Point ref = Point(0, 0), int r = 25, 
           ShapeColor fill = BLUE, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Circle();

    // Override virtual functions from Shape
    virtual void Draw(GUI* pGUI) const override;
    virtual void Rotate() override; // Circle rotation doesn't change appearance
    virtual void ResizeUp() override;
    virtual void ResizeDown() override;
    virtual void Flip() override; // Circle flip doesn't change appearance
    virtual bool Match(const Shape* other) const override;
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 1; } // Circle type = 1

    // Save and load functions
    virtual void Save(ofstream& outFile) const override;
    virtual void Load(ifstream& inFile) override;

    // Getters
    int GetRadius() const { return radius; }

    // Setters
    void SetRadius(int r) { radius = r; }
};

#endif
