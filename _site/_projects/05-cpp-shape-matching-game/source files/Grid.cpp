#include "Grid.h"
#include "Sign.h"
#include "Home.h"
#include "Person.h"
#include "Car.h"
#include "Flower.h"
#include "Robot.h"
#include <cstdlib>
#include <ctime>
#include <algorithm>

using namespace std;

// Constructor
Grid::Grid() {
    selectedShape = nullptr;
    currentLevel = 1;
    score = 0;
    lives = 5;
    targetMatches = 1;
    currentMatches = 0;
    srand(time(nullptr)); // Initialize random seed
    GenerateRandomShapes();
}

// Destructor
Grid::~Grid() {
    ClearAllShapes();
}

// Add random shape to the grid
void Grid::AddRandomShape(Shape* shape) {
    if(shape) {
        randomShapes.push_back(shape);
    }
}

// Add player-created shape to the grid
void Grid::AddPlayerShape(Shape* shape) {
    if(shape) {
        playerShapes.push_back(shape);
    }
}

// Delete a shape from the grid
void Grid::DeleteShape(Shape* shape) {
    if(!shape) return;

    // Remove from random shapes
    auto it = find(randomShapes.begin(), randomShapes.end(), shape);
    if(it != randomShapes.end()) {
        randomShapes.erase(it);
        delete shape;
        return;
    }

    // Remove from player shapes
    it = find(playerShapes.begin(), playerShapes.end(), shape);
    if(it != playerShapes.end()) {
        playerShapes.erase(it);
        delete shape;
        return;
    }
}

// Clear all random shapes
void Grid::ClearRandomShapes() {
    for(Shape* shape : randomShapes) {
        delete shape;
    }
    randomShapes.clear();
}

// Clear all player shapes
void Grid::ClearPlayerShapes() {
    for(Shape* shape : playerShapes) {
        delete shape;
    }
    playerShapes.clear();
}

// Clear all shapes
void Grid::ClearAllShapes() {
    ClearRandomShapes();
    ClearPlayerShapes();
    selectedShape = nullptr;
}

// Generate random shapes for current level
void Grid::GenerateRandomShapes() {
    ClearRandomShapes();

    int numShapes = (currentLevel == 1) ? 1 : (2 * currentLevel - 1);

    for(int i = 0; i < numShapes; i++) {
        Shape* shape = CreateRandomCompositeShape();
        if(shape) {
            // Set random position
            Point pos = GetRandomGridPosition();
            shape->SetRefPoint(pos);

            // Apply random transformations
            int rotations = rand() % 4;
            for(int r = 0; r < rotations; r++) {
                shape->Rotate();
            }

            int resizes = (rand() % 3) - 1; // -1, 0, or 1
            if(resizes > 0) shape->ResizeUp();
            else if(resizes < 0) shape->ResizeDown();

            // Set colors based on level
            if(currentLevel >= 3) {
                shape->SetFillColor(BLACK);
                shape->SetOutlineColor(BLACK);
            } else {
                ShapeColor colors[] = {RED, BLUE, GREEN, YELLOW, ORANGE, PURPLE};
                shape->SetFillColor(colors[rand() % 6]);
                shape->SetOutlineColor(BLACK);
            }

            AddRandomShape(shape);
        }
    }

    CalculateTargetMatches();
}

// Set game level
void Grid::SetLevel(int level) {
    currentLevel = level;
    currentMatches = 0;
    GenerateRandomShapes();
}

// Check if player shape matches any random shape
bool Grid::CheckMatch(Shape* playerShape) {
    if(!playerShape) return false;

    for(auto it = randomShapes.begin(); it != randomShapes.end(); ++it) {
        if(playerShape->Match(*it)) {
            // Found a match
            delete *it;
            randomShapes.erase(it);
            currentMatches++;

            // Update score
            score += 2;

            // Check if level completed
            if(currentMatches >= targetMatches) {
                NextLevel();
            }

            return true;
        }
    }

    // No match found - lose points
    score = max(0, score - 1);
    return false;
}

// Refresh the current level
void Grid::RefreshLevel() {
    if(lives > 0) {
        lives--;
        GenerateRandomShapes();
        currentMatches = 0;
    }
}

// Get shape at specified point
Shape* Grid::GetShapeAt(Point p) {
    // Check player shapes first
    for(Shape* shape : playerShapes) {
        if(shape && shape->IsPointInside(p)) {
            return shape;
        }
    }

    // Check random shapes
    for(Shape* shape : randomShapes) {
        if(shape && shape->IsPointInside(p)) {
            return shape;
        }
    }

    return nullptr;
}

// Set selected shape
void Grid::SetSelectedShape(Shape* shape) {
    selectedShape = shape;
}

// Draw all shapes in the grid
void Grid::Draw(GUI* pGUI) const {
    // Draw random shapes
    for(const Shape* shape : randomShapes) {
        if(shape) {
            shape->Draw(pGUI);
        }
    }

    // Draw player shapes
    for(const Shape* shape : playerShapes) {
        if(shape) {
            shape->Draw(pGUI);
        }
    }

    // Highlight selected shape
    if(selectedShape) {
        pGUI->SetPenColor(YELLOW_COLOR);
        pGUI->SetBrushColor(TRANSPARENT_COLOR);
        Point ref = selectedShape->GetRefPoint();
        pGUI->DrawRectangle(Point(ref.x - 5, ref.y - 5), 
                           Point(ref.x + 55, ref.y + 55), FRAME);
    }
}

// Go to next level
void Grid::NextLevel() {
    currentLevel++;
    currentMatches = 0;
    GenerateRandomShapes();
}

// Get random grid position
Point Grid::GetRandomGridPosition() const {
    int x = 100 + rand() % (GUI::GRID_WIDTH - 200);
    int y = GUI::TOOLBAR_HEIGHT + 100 + rand() % (GUI::GRID_HEIGHT - 200);
    return Point(x, y);
}

// Check if position is valid for shape
bool Grid::IsPositionValid(Point p, Shape* shape) const {
    // Basic bounds checking
    return (p.x >= 50 && p.x <= GUI::GRID_WIDTH - 50 &&
            p.y >= GUI::TOOLBAR_HEIGHT + 50 && 
            p.y <= GUI::WINDOW_HEIGHT - GUI::STATUS_HEIGHT - 50);
}

// Apply black fill for level 3+
void Grid::ApplyBlackFill() {
    for(Shape* shape : randomShapes) {
        if(shape) {
            shape->SetFillColor(BLACK);
            shape->SetOutlineColor(BLACK);
        }
    }
}

// Calculate target matches for current level
void Grid::CalculateTargetMatches() {
    targetMatches = randomShapes.size();
}

// Create random composite shape
Shape* Grid::CreateRandomCompositeShape() {
    int shapeType = rand() % 6; // 0-5 for 6 different composite shapes
    Point defaultPos(300, 300);

    switch(shapeType) {
        case 0: return new Sign(defaultPos);
        case 1: return new Home(defaultPos);
        case 2: return new Person(defaultPos);
        case 3: return new Car(defaultPos);
        case 4: return new Flower(defaultPos);
        case 5: return new Robot(defaultPos);
        default: return new Sign(defaultPos);
    }
}
