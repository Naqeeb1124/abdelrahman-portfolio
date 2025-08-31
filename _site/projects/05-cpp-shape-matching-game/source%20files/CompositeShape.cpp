#include "CompositeShape.h"

using namespace std;

// Constructor
CompositeShape::CompositeShape(Point ref, ShapeColor fill, ShapeColor outline)
    : Shape(ref, fill, outline) {
}

// Destructor
CompositeShape::~CompositeShape() {
    ClearSubShapes();
}

// Draw all sub-shapes
void CompositeShape::Draw(GUI* pGUI) const {
    for(const Shape* shape : subShapes) {
        if(shape) {
            shape->Draw(pGUI);
        }
    }
}

// Rotate all sub-shapes and recalculate positions
void CompositeShape::Rotate() {
    rotationCount = (rotationCount + 1) % 4;

    // Rotate each sub-shape around its own center first
    for(Shape* shape : subShapes) {
        if(shape) {
            shape->Rotate();
        }
    }

    // Recalculate relative positions
    RecalculateSubShapePositions();
}

// Resize up all sub-shapes
void CompositeShape::ResizeUp() {
    resizeCount++;

    for(Shape* shape : subShapes) {
        if(shape) {
            shape->ResizeUp();
        }
    }

    RecalculateSubShapePositions();
}

// Resize down all sub-shapes
void CompositeShape::ResizeDown() {
    resizeCount--;

    for(Shape* shape : subShapes) {
        if(shape) {
            shape->ResizeDown();
        }
    }

    RecalculateSubShapePositions();
}

// Flip all sub-shapes
void CompositeShape::Flip() {
    isFlipped = !isFlipped;

    for(Shape* shape : subShapes) {
        if(shape) {
            shape->Flip();
        }
    }

    RecalculateSubShapePositions();
}

// Check if this composite shape matches another
bool CompositeShape::Match(const Shape* other) const {
    const CompositeShape* otherComposite = dynamic_cast<const CompositeShape*>(other);
    if(!otherComposite) return false;

    // Must have same number of sub-shapes
    if(subShapes.size() != otherComposite->subShapes.size()) return false;

    // Must have same shape type
    if(GetShapeType() != otherComposite->GetShapeType()) return false;

    // Check if all sub-shapes match (order matters)
    for(size_t i = 0; i < subShapes.size(); i++) {
        if(!subShapes[i]->Match(otherComposite->subShapes[i])) {
            return false;
        }
    }

    return true;
}

// Save composite shape data
void CompositeShape::Save(ofstream& outFile) const {
    outFile << GetShapeType() << " ";
    Shape::Save(outFile);
    outFile << subShapes.size() << "\n";

    // Save each sub-shape
    for(const Shape* shape : subShapes) {
        if(shape) {
            shape->Save(outFile);
        }
    }
}

// Load composite shape data
void CompositeShape::Load(ifstream& inFile) {
    Shape::Load(inFile);

    int numSubShapes;
    inFile >> numSubShapes;

    // Note: Sub-shapes should be loaded by the derived class
    // as it knows which types to create
}

// Add a sub-shape
void CompositeShape::AddSubShape(Shape* shape) {
    if(shape) {
        subShapes.push_back(shape);
        UpdateSubShapeColors();
    }
}

// Clear all sub-shapes
void CompositeShape::ClearSubShapes() {
    for(Shape* shape : subShapes) {
        delete shape;
    }
    subShapes.clear();
}

// Update all sub-shapes to have the same colors as the composite
void CompositeShape::UpdateSubShapeColors() {
    for(Shape* shape : subShapes) {
        if(shape) {
            shape->SetFillColor(fillColor);
            shape->SetOutlineColor(outlineColor);
        }
    }
}

// Recalculate sub-shape positions relative to reference point
void CompositeShape::RecalculateSubShapePositions() {
    // This is a virtual method that should be overridden by derived classes
    // to properly position their sub-shapes relative to the reference point
}
