#include "Rectangle.h"
#include <algorithm>

using namespace std;

// Constructor
Rectangle::Rectangle(Point ref, int w, int h, ShapeColor fill, ShapeColor outline)
    : Shape(ref, fill, outline), width(w), height(h) {
}

// Destructor
Rectangle::~Rectangle() {
}

// Draw rectangle
void Rectangle::Draw(GUI* pGUI) const {
    pGUI->SetPenColor(GetColorValue(outlineColor));
    pGUI->SetBrushColor(GetColorValue(fillColor));

    // Calculate actual corner positions considering rotation and flip
    Point topLeft = refPoint;
    Point topRight = Point(refPoint.x + width, refPoint.y);
    Point bottomRight = Point(refPoint.x + width, refPoint.y + height);
    Point bottomLeft = Point(refPoint.x, refPoint.y + height);

    // Apply flip if necessary
    if(isFlipped) {
        topLeft.y = refPoint.y + height;
        topRight.y = refPoint.y + height;
        bottomLeft.y = refPoint.y;
        bottomRight.y = refPoint.y;
    }

    // Apply rotation
    Point center = Point(refPoint.x + width/2, refPoint.y + height/2);
    topLeft = RotatePoint(topLeft, center, rotationCount);
    topRight = RotatePoint(topRight, center, rotationCount);
    bottomRight = RotatePoint(bottomRight, center, rotationCount);
    bottomLeft = RotatePoint(bottomLeft, center, rotationCount);

    // Draw filled rectangle
    pGUI->DrawRectangle(topLeft, bottomRight, FILLED);
}

// Rotate rectangle by 90 degrees clockwise
void Rectangle::Rotate() {
    rotationCount = (rotationCount + 1) % 4;
    // For rectangle, also swap width and height for odd rotations
    if(rotationCount % 2 == 1) {
        swap(width, height);
    }
}

// Resize up (double size)
void Rectangle::ResizeUp() {
    width *= 2;
    height *= 2;
    resizeCount++;
}

// Resize down (half size)
void Rectangle::ResizeDown() {
    width = max(5, width / 2); // Minimum size of 5
    height = max(5, height / 2);
    resizeCount--;
}

// Vertical flip
void Rectangle::Flip() {
    isFlipped = !isFlipped;
}

// Check if this rectangle matches another shape
bool Rectangle::Match(const Shape* other) const {
    const Rectangle* otherRect = dynamic_cast<const Rectangle*>(other);
    if(!otherRect) return false;

    // Match if same dimensions (considering rotation) and colors
    bool sizeMatch = (width == otherRect->width && height == otherRect->height) ||
                     (width == otherRect->height && height == otherRect->width);

    return sizeMatch && 
           fillColor == otherRect->fillColor && 
           outlineColor == otherRect->outlineColor;
}

// Clone this rectangle
Shape* Rectangle::Clone() const {
    Rectangle* clone = new Rectangle(refPoint, width, height, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}

// Save rectangle data
void Rectangle::Save(ofstream& outFile) const {
    outFile << GetShapeType() << " ";
    Shape::Save(outFile);
    outFile << width << " " << height << "\n";
}

// Load rectangle data
void Rectangle::Load(ifstream& inFile) {
    Shape::Load(inFile);
    inFile >> width >> height;
}
