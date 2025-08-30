#ifndef RECTANGLE_H
#define RECTANGLE_H

#include "Shape.h"

class Rectangle : public Shape {
private:
    int width, height;

public:
    // Constructor
    Rectangle(Point ref = Point(0, 0), int w = 50, int h = 30, 
              ShapeColor fill = RED, ShapeColor outline = BLACK);

    // Destructor
    virtual ~Rectangle();

    // Override virtual functions from Shape
    virtual void Draw(GUI* pGUI) const override;
    virtual void Rotate() override;
    virtual void ResizeUp() override;
    virtual void ResizeDown() override;
    virtual void Flip() override;
    virtual bool Match(const Shape* other) const override;
    virtual Shape* Clone() const override;
    virtual int GetShapeType() const override { return 0; } // Rectangle type = 0

    // Save and load functions
    virtual void Save(ofstream& outFile) const override;
    virtual void Load(ifstream& inFile) override;

    // Getters
    int GetWidth() const { return width; }
    int GetHeight() const { return height; }

    // Setters
    void SetWidth(int w) { width = w; }
    void SetHeight(int h) { height = h; }
};

#endif
