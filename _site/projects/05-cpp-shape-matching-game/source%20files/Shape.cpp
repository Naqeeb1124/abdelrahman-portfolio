#include "Shape.h"
#include <cmath>

using namespace std;

// Constructor
Shape::Shape(Point ref, ShapeColor fill, ShapeColor outline) 
    : refPoint(ref), fillColor(fill), outlineColor(outline), 
      rotationCount(0), resizeCount(0), isFlipped(false) {
}

// Destructor
Shape::~Shape() {
}

// Save function - saves common shape data
void Shape::Save(ofstream& outFile) const {
    outFile << refPoint.x << " " << refPoint.y << " " 
            << rotationCount << " " << resizeCount << " " 
            << (int)fillColor << " " << (int)outlineColor << " ";
}

// Load function - loads common shape data
void Shape::Load(ifstream& inFile) {
    int fillCol, outlineCol;
    inFile >> refPoint.x >> refPoint.y >> rotationCount >> resizeCount 
           >> fillCol >> outlineCol;
    fillColor = (ShapeColor)fillCol;
    outlineColor = (ShapeColor)outlineCol;
}

// Convert ShapeColor enum to CMU graphics color
color Shape::GetColorValue(ShapeColor c) const {
    switch(c) {
        case RED: return RED_COLOR;
        case BLUE: return BLUE_COLOR;
        case GREEN: return GREEN_COLOR;
        case YELLOW: return YELLOW_COLOR;
        case ORANGE: return ORANGE_COLOR;
        case PURPLE: return MAGENTA_COLOR;
        case BLACK: return BLACK_COLOR;
        case WHITE: return WHITE_COLOR;
        default: return BLACK_COLOR;
    }
}

// Rotate point around center by specified number of 90-degree increments
Point Shape::RotatePoint(Point p, Point center, int rotations) const {
    Point result = p;
    rotations = rotations % 4; // Normalize to 0-3

    for(int i = 0; i < rotations; i++) {
        int newX = center.x - (result.y - center.y);
        int newY = center.y + (result.x - center.x);
        result.x = newX;
        result.y = newY;
    }

    return result;
}

// Move shape by dx, dy
void Shape::Move(int dx, int dy) {
    refPoint.x += dx;
    refPoint.y += dy;
}

// Check if point is inside shape (basic implementation)
bool Shape::IsPointInside(Point p) const {
    // Basic distance check - can be overridden in derived classes
    int dx = p.x - refPoint.x;
    int dy = p.y - refPoint.y;
    return (dx*dx + dy*dy) <= 2500; // 50 pixel radius
}
