#ifndef TRIANGLE_H
#define TRIANGLE_H

#include "Shape.h"

class Triangle : public Shape {
private:
    int sideLength;

public:
    // Constructor
    Triangle(Point ref = Point(0, 0), int side = 50, 
             ShapeColor fill = GREEN, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Triangle();

    // Override virtual functions from Shape
    virtual void Draw(GUI* pGUI) const override;
    virtual void Rotate() override;
    virtual void ResizeUp() override;
    virtual void ResizeDown() override;
    virtual void Flip() override;
    virtual bool Match(const Shape* other) const override;
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 2; } // Triangle type = 2

    // Save and load functions
    virtual void Save(ofstream& outFile) const override;
    virtual void Load(ifstream& inFile) override;

    // Getters
    int GetSideLength() const { return sideLength; }

    // Setters
    void SetSideLength(int side) { sideLength = side; }

private:
    // Helper function to calculate triangle points
    void CalculatePoints(Point& p1, Point& p2, Point& p3) const;
};

#endif
