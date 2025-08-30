#include "Circle.h"
#include <algorithm>

using namespace std;

// Constructor
Circle::Circle(Point ref, int r, ShapeColor fill, ShapeColor outline)
    : Shape(ref, fill, outline), radius(r) {
}

// Destructor
Circle::~Circle() {
}

// Draw circle
void Circle::Draw(GUI* pGUI) const {
    pGUI->SetPenColor(GetColorValue(outlineColor));
    pGUI->SetBrushColor(GetColorValue(fillColor));

    // Calculate circle bounds
    Point topLeft = Point(refPoint.x - radius, refPoint.y - radius);
    Point bottomRight = Point(refPoint.x + radius, refPoint.y + radius);

    // Draw filled circle
    pGUI->DrawCircle(refPoint, radius, FILLED);
}

// Rotate circle (no visual effect for circle)
void Circle::Rotate() {
    rotationCount = (rotationCount + 1) % 4;
    // Circle appearance doesn't change with rotation
}

// Resize up (double radius)
void Circle::ResizeUp() {
    radius *= 2;
    resizeCount++;
}

// Resize down (half radius)
void Circle::ResizeDown() {
    radius = max(3, radius / 2); // Minimum radius of 3
    resizeCount--;
}

// Flip circle (no visual effect for circle)
void Circle::Flip() {
    isFlipped = !isFlipped;
    // Circle appearance doesn't change with flip
}

// Check if this circle matches another shape
bool Circle::Match(const Shape* other) const {
    const Circle* otherCircle = dynamic_cast<const Circle*>(other);
    if(!otherCircle) return false;

    // Match if same radius and colors
    return radius == otherCircle->radius && 
           fillColor == otherCircle->fillColor && 
           outlineColor == otherCircle->outlineColor;
}

// Clone this circle
Shape* Circle::Clone() const {
    Circle* clone = new Circle(refPoint, radius, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}

// Save circle data
void Circle::Save(ofstream& outFile) const {
    outFile << GetShapeType() << " ";
    Shape::Save(outFile);
    outFile << radius << "\n";
}

// Load circle data
void Circle::Load(ifstream& inFile) {
    Shape::Load(inFile);
    inFile >> radius;
}
