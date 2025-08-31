#ifndef SHAPE_H
#define SHAPE_H

#include "CMUgraphics.h"
#include <iostream>
#include <fstream>

// Color constants
enum ShapeColor {
    RED = 1,
    BLUE = 2,
    GREEN = 3,
    YELLOW = 4,
    ORANGE = 5,
    PURPLE = 6,
    BLACK = 7,
    WHITE = 8
};

// Base class for all shapes
class Shape {
protected:
    Point refPoint;        // Reference point for the shape
    ShapeColor fillColor;  // Fill color
    ShapeColor outlineColor; // Outline color
    int rotationCount;     // Number of 90-degree rotations
    int resizeCount;       // Number of resize operations (positive = up, negative = down)
    bool isFlipped;        // Vertical flip status

public:
    // Constructor
    Shape(Point ref = Point(0, 0), ShapeColor fill = RED, ShapeColor outline = BLACK);

    // Virtual destructor
    virtual ~Shape();

    // Pure virtual functions - must be implemented by derived classes
    virtual void Draw(GUI* pGUI) const = 0;
    virtual void Rotate() = 0;
    virtual void ResizeUp() = 0;
    virtual void ResizeDown() = 0;
    virtual void Flip() = 0;
    virtual bool Match(const Shape* other) const = 0;
    virtual Shape* Clone() const = 0;
    virtual int GetShapeType() const = 0;

    // Save and load functions
    virtual void Save(ofstream& outFile) const;
    virtual void Load(ifstream& inFile);

    // Getters and setters
    Point GetRefPoint() const { return refPoint; }
    void SetRefPoint(Point p) { refPoint = p; }
    ShapeColor GetFillColor() const { return fillColor; }
    void SetFillColor(ShapeColor color) { fillColor = color; }
    ShapeColor GetOutlineColor() const { return outlineColor; }
    void SetOutlineColor(ShapeColor color) { outlineColor = color; }
    int GetRotationCount() const { return rotationCount; }
    int GetResizeCount() const { return resizeCount; }
    bool GetFlipStatus() const { return isFlipped; }

    // Utility functions
    color GetColorValue(ShapeColor c) const;
    Point RotatePoint(Point p, Point center, int rotations) const;
    void Move(int dx, int dy);
    bool IsPointInside(Point p) const;
};

#endif
