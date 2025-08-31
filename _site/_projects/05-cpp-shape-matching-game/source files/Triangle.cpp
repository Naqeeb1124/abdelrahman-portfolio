#include "Triangle.h"
#include <algorithm>
#include <cmath>

using namespace std;

// Constructor
Triangle::Triangle(Point ref, int side, ShapeColor fill, ShapeColor outline)
    : Shape(ref, fill, outline), sideLength(side) {
}

// Destructor
Triangle::~Triangle() {
}

// Calculate triangle points based on reference point and side length
void Triangle::CalculatePoints(Point& p1, Point& p2, Point& p3) const {
    // Equilateral triangle with one vertex at refPoint (bottom left)
    // Height of equilateral triangle = side * sqrt(3) / 2
    int height = (int)(sideLength * 0.866);

    p1 = refPoint; // Bottom left
    p2 = Point(refPoint.x + sideLength, refPoint.y); // Bottom right
    p3 = Point(refPoint.x + sideLength/2, refPoint.y - height); // Top center

    // Apply flip if necessary
    if(isFlipped) {
        p1.y = refPoint.y - height;
        p2.y = refPoint.y - height;
        p3.y = refPoint.y;
    }

    // Apply rotation around center
    Point center = Point(refPoint.x + sideLength/2, refPoint.y - height/2);
    p1 = RotatePoint(p1, center, rotationCount);
    p2 = RotatePoint(p2, center, rotationCount);
    p3 = RotatePoint(p3, center, rotationCount);
}

// Draw triangle
void Triangle::Draw(GUI* pGUI) const {
    pGUI->SetPenColor(GetColorValue(outlineColor));
    pGUI->SetBrushColor(GetColorValue(fillColor));

    Point p1, p2, p3;
    CalculatePoints(p1, p2, p3);

    // Draw filled triangle
    pGUI->DrawTriangle(p1, p2, p3, FILLED);
}

// Rotate triangle by 90 degrees clockwise
void Triangle::Rotate() {
    rotationCount = (rotationCount + 1) % 4;
}

// Resize up (double side length)
void Triangle::ResizeUp() {
    sideLength *= 2;
    resizeCount++;
}

// Resize down (half side length)
void Triangle::ResizeDown() {
    sideLength = max(6, sideLength / 2); // Minimum side length of 6
    resizeCount--;
}

// Vertical flip
void Triangle::Flip() {
    isFlipped = !isFlipped;
}

// Check if this triangle matches another shape
bool Triangle::Match(const Shape* other) const {
    const Triangle* otherTriangle = dynamic_cast<const Triangle*>(other);
    if(!otherTriangle) return false;

    // Match if same side length and colors
    return sideLength == otherTriangle->sideLength && 
           fillColor == otherTriangle->fillColor && 
           outlineColor == otherTriangle->outlineColor;
}

// Clone this triangle
Shape* Triangle::Clone() const {
    Triangle* clone = new Triangle(refPoint, sideLength, fillColor, outlineColor);
    clone->rotationCount = rotationCount;
    clone->resizeCount = resizeCount;
    clone->isFlipped = isFlipped;
    return clone;
}

// Save triangle data
void Triangle::Save(ofstream& outFile) const {
    outFile << GetShapeType() << " ";
    Shape::Save(outFile);
    outFile << sideLength << "\n";
}

// Load triangle data
void Triangle::Load(ifstream& inFile) {
    Shape::Load(inFile);
    inFile >> sideLength;
}
