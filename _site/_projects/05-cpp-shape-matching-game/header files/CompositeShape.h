#ifndef COMPOSITE_SHAPE_H
#define COMPOSITE_SHAPE_H

#include "Shape.h"
#include <vector>

// Base class for all composite shapes
class CompositeShape : public Shape {
protected:
    std::vector<Shape*> subShapes;

public:
    // Constructor
    CompositeShape(Point ref = Point(0, 0), ShapeColor fill = RED, ShapeColor outline = BLACK);

    // Virtual destructor
    virtual ~CompositeShape();

    // Override virtual functions from Shape
    virtual void Draw(GUI* pGUI) const override;
    virtual void Rotate() override;
    virtual void ResizeUp() override;
    virtual void ResizeDown() override;
    virtual void Flip() override;
    virtual bool Match(const Shape* other) const override;

    // Save and load functions
    virtual void Save(ofstream& outFile) const override;
    virtual void Load(ifstream& inFile) override;

    // Utility functions
    void AddSubShape(Shape* shape);
    void ClearSubShapes();
    void UpdateSubShapeColors();
    void RecalculateSubShapePositions();

    // Getters
    int GetSubShapeCount() const { return subShapes.size(); }
    Shape* GetSubShape(int index) const { return (index >= 0 && index < subShapes.size()) ? subShapes[index] : nullptr; }
};

#endif
